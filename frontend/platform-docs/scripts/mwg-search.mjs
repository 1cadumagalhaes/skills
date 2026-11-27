#!/usr/bin/env node
// Offline search over the vendored modern-web-guidance corpus.
//
//   node mwg-search.mjs search "<query>" [--limit N] [--category css]
//   node mwg-search.mjs retrieve <id[,id...]>
//   node mwg-search.mjs list [category]
//
// Ids are "<category>/<file>", e.g. "ui-behaviors/anchor-positioning-tab-underline".
// The index is built from the markdown itself (title, headings, first paragraph,
// category) and cached beside the guides; delete the cache to rebuild.

import { readdirSync, readFileSync, statSync, writeFileSync, existsSync, mkdirSync } from "node:fs";
import path from "node:path";
import os from "node:os";
import { createHash } from "node:crypto";
import { fileURLToPath } from "node:url";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const CANDIDATES = [
  path.join(HERE, "..", "guides"), // skill-root layout (installed)
  path.join(HERE, "..", "..", "..", "skills", "modern-web-guidance", "guides"), // vendored pack
];
const GUIDES = CANDIDATES.find((dir) => existsSync(dir));
if (!GUIDES) {
  console.error("Guides directory not found. Looked in:\n  " + CANDIDATES.join("\n  "));
  process.exit(1);
}
const CACHE_DIR = path.join(process.env.XDG_CACHE_HOME || path.join(os.homedir(), ".cache"), "mwg-search");
const CACHE = path.join(CACHE_DIR, "index-" + createHash("sha1").update(GUIDES).digest("hex").slice(0, 10) + ".json");

const STOP = new Set(
  "a an and are as at be by do does for from how i in into is it its of on or that the this to with without when what which who why you your".split(" "),
);

function walk(dir, out = []) {
  for (const entry of readdirSync(dir)) {
    const full = path.join(dir, entry);
    if (statSync(full).isDirectory()) walk(full, out);
    else if (entry.endsWith(".md")) out.push(full);
  }
  return out;
}

function parse(file) {
  const text = readFileSync(file, "utf8");
  const rel = path.relative(GUIDES, file).replace(/\\/g, "/");
  const id = rel.replace(/\.md$/, "");
  const [category, name] = id.split("/");
  const lines = text.split("\n");
  const titleLine = lines.find((l) => /^#\s+/.test(l)) || "";
  const title = titleLine.replace(/^#\s+/, "").trim() || name;
  const headings = lines.filter((l) => /^#{2,3}\s+/.test(l)).map((l) => l.replace(/^#{2,3}\s+/, "").trim());
  // first paragraph after the title
  let first = "";
  for (let i = lines.indexOf(titleLine) + 1; i < lines.length; i++) {
    const line = lines[i].trim();
    if (!line || line.startsWith("#")) continue;
    first = line;
    break;
  }
  const body = text.toLowerCase();
  return {
    id,
    category: category || "root",
    name,
    title,
    description: first.slice(0, 220),
    headings,
    bytes: text.length,
    body: body.slice(0, 4000),
  };
}

function buildIndex() {
  const rows = walk(GUIDES).sort().map(parse);
  mkdirSync(CACHE_DIR, { recursive: true });
  writeFileSync(CACHE, JSON.stringify(rows.map(({ body, ...rest }) => rest)));
  return rows;
}

function loadIndex() {
  if (existsSync(CACHE)) {
    try {
      return JSON.parse(readFileSync(CACHE, "utf8"));
    } catch {
      /* rebuild below */
    }
  }
  return buildIndex();
}

function tokens(text) {
  return text
    .toLowerCase()
    .replace(/[^a-z0-9\s-]/g, " ")
    .split(/\s+/)
    .filter((t) => t.length > 1 && !STOP.has(t));
}

function score(row, query) {
  const qs = tokens(query);
  if (qs.length === 0) return 0;
  const title = row.title.toLowerCase();
  const id = row.id.toLowerCase();
  const heads = (row.headings || []).join(" ").toLowerCase();
  const desc = (row.description || "").toLowerCase();
  let total = 0;
  for (const q of qs) {
    let hit = 0;
    if (title === q) hit += 12;
    else if (title.includes(q)) hit += 6;
    if (row.name.toLowerCase().includes(q)) hit += 5;
    if (id.includes(q)) hit += 2;
    if (heads.includes(q)) hit += 3;
    if (desc.includes(q)) hit += 2;
    total += hit;
  }
  // all query terms present somewhere in the title/name/headings is a strong signal
  const hay = `${title} ${row.name} ${heads}`;
  if (qs.every((q) => hay.includes(q))) total += 6;
  return total;
}

const args = process.argv.slice(2);
const cmd = args[0];
const flag = (name, def) => {
  const i = args.indexOf(`--${name}`);
  return i >= 0 && args[i + 1] ? args[i + 1] : def;
};
const plain = args.slice(1).filter((a, i, all) => !a.startsWith("--") && !all[i - 1]?.startsWith("--"));

if (!cmd || cmd === "-h" || cmd === "--help") {
  console.log("usage: mwg-search.mjs search \"<query>\" [--limit N] [--category css]");
  console.log("       mwg-search.mjs retrieve <id[,id...]>");
  console.log("       mwg-search.mjs list [category]");
  process.exit(cmd ? 0 : 1);
}

if (cmd === "search") {
  const query = plain.join(" ");
  if (!query) {
    console.error("search needs a query");
    process.exit(1);
  }
  const limit = Number(flag("limit", "8"));
  const category = flag("category");
  const rows = loadIndex().filter((r) => !category || r.category === category);
  const ranked = rows
    .map((row) => ({ row, s: score(row, query) }))
    .filter((r) => r.s > 0)
    .sort((a, b) => b.s - a.s)
    .slice(0, limit);
  if (ranked.length === 0) {
    console.log(`no match for "${query}". Try a concrete primitive (dialog, popover, table, anchor, form) or \`list\`.`);
    process.exit(0);
  }
  for (const { row } of ranked) {
    console.log(`${row.id}\n  ${row.title}\n  ${row.description}\n`);
  }
  process.exit(0);
}

if (cmd === "retrieve") {
  const ids = (plain.join(" ") || "").split(",").map((s) => s.trim()).filter(Boolean);
  if (ids.length === 0) {
    console.error("retrieve needs at least one id (see `list`)");
    process.exit(1);
  }
  const rows = loadIndex();
  let missing = 0;
  for (const wanted of ids) {
    const key = wanted.replace(/\.md$/, "").toLowerCase();
    const row =
      rows.find((r) => r.id.toLowerCase() === key) ||
      rows.find((r) => r.id.toLowerCase().endsWith("/" + key)) ||
      rows.find((r) => r.name.toLowerCase() === key);
    if (!row) {
      console.error(`not found: ${wanted}`);
      missing++;
      continue;
    }
    console.log(readFileSync(path.join(GUIDES, row.id + ".md"), "utf8").trimEnd());
    console.log("\n---\n");
  }
  process.exit(missing && missing === ids.length ? 1 : 0);
}

if (cmd === "list") {
  const category = plain[0];
  const rows = loadIndex().filter((r) => !category || r.category === category);
  const byCat = new Map();
  for (const r of rows) {
    if (!byCat.has(r.category)) byCat.set(r.category, []);
    byCat.get(r.category).push(r);
  }
  for (const [cat, list] of [...byCat].sort()) {
    console.log(`## ${cat} (${list.length})`);
    for (const r of list.sort((a, b) => a.id.localeCompare(b.id))) console.log("  " + r.id);
  }
  process.exit(0);
}

console.error(`unknown command: ${cmd}`);
process.exit(2);

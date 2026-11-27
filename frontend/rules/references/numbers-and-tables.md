# Numbers and tables

## Tabular figures

`[conv]` Proportional digits have different widths, so a value that updates makes its own column jump and neighbouring columns fail to line up. Tabular figures give every digit one advance width.

```css
.numeric, td.num, .timer, .price, .counter {
  font-variant-numeric: tabular-nums;
}
```

**Verify the font first.** `tabular-nums` is a no-op if the font has no `tnum` feature, and it fails silently. Measured locally with fontTools:

| font | `tnum` |
|---|---|
| Adwaita Sans | yes |
| Noto Sans | yes |
| DejaVu Sans | **no** |
| Liberation Sans | **no** |

Check a candidate font:

```bash
python3 -c "from fontTools.ttLib import TTFont as T; \
f=T('Font.ttf',lazy=True); \
print('tnum' in {r.FeatureTag for r in f['GSUB'].table.FeatureList.FeatureRecord})"
```

If it has no `tnum`, either switch fonts for numeric cells or fall back to a monospace stack for those cells — do not ship a rule that does nothing.

Other notes:

- `[conv]` Skip `tabular-nums` where the text is already monospace; it is redundant.
- `[taste]` Consider `slashed-zero` where `0` vs `O` is ambiguous (codes, serials).
- `[conv]` Use proportional (`pnum`) in prose where numbers read as words.

## Columns and alignment

- `[conv]` Right-align numeric columns (`text-align: end`, logical not `right`), left-align text; headers align with their column, and a numeric header is right-aligned too.
- `[conv]` Pad decimals to a unit (`2`, not `2.0` vs `2.00` mixing) — alignment is about the decimal point, not just digit width.
- `[conv]` Align on the decimal where magnitudes vary by orders; otherwise align right.
- `[conv]` Numbers inside a sentence stay proportional; numbers in a cell are tabular.

## Live data

- `[conv]` Reserve width for the widest realistic value (or `ch` units) so a value growing does not reflow the row.
- `[conv]` A value that changes rapidly should not resize its container: fix the container, tabular digits, and avoid re-laying-out the row.
- `[conv]` Show a stable placeholder of the same width while loading (skeleton at final size), otherwise the layout shifts twice.
- `[conv]` Announce routine updates with `role="status"` (polite), keep `role="alert"` for urgent errors only.

## Formatting

- `[conv]` Format numbers for the locale (`Intl.NumberFormat`) instead of hand-rolled separators.
- `[taste]` Abbreviate large values only when the exact number is available on hover/focus or in a detail view.
- `[conv]` Units are part of the cell: keep the unit aligned consistently, usually trailing and dimmed, not repeated in every row if a column header can carry it (`Count (GB)`).
- `[conv]` Dates and durations also need tabular digits when they update in place.

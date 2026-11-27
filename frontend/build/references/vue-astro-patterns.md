# Vue 3 and Astro patterns

Stack rules for Vue 3, Nuxt, and Astro codebases. Read `package.json` and `DESIGN.md` before choosing components or hydration boundaries.

## Vue 3 and shadcn-vue / Reka UI

- Use `<script setup lang="ts">` with typed `defineProps<...>()` and typed `defineEmits<{ ... }>()` (or `defineModel<...>()` for controlled inputs).
- Prefer `computed()` over `watch()` for derived state. Reserve `watch()` for external side effects such as syncing a query parameter or imperative DOM API, with cleanup via `onWatcherCleanup` or return callback.
- Model async view state explicitly (`loading`, `error`, `ready`) rather than scattering independent booleans that allow impossible combinations.
- Keep presentational components free of direct store or router imports when props and emits keep them reusable across pages.
- Build on the project's `Reka UI` / `shadcn-vue` primitives for dialogs, popovers, tabs, and selects so keyboard navigation, focus trapping, and ARIA attributes work out of the box.
- Use stable, unique `:key` values (entity IDs) on `v-for` lists, never array index on mutable or reorderable lists.

## Astro and static/content sites

- Ship zero client JavaScript by default. Keep static sections, navigation, comparison tables, and diagrams in `.astro` templates or plain progressive-enhancement modules unless real client state demands a framework island.
- When hydrating an interactive island (`client:visible`, `client:idle`, `client:load`), pass serializable primitive or JSON props only and hydrate the smallest leaf component rather than a whole page section.
- For bilingual sites (for example PT-BR root `/` and `/en/...`), keep route parity, `lang` attributes, `<link rel="canonical">`, `hreflang` alternates, `robots.txt`, and `llms.txt` generated from shared config rather than duplicated per page.
- Verify build-time assets (generated OG cards, SVG assets, CSS tokens) with the repo build check so image/text drift fails CI.
- Gate animations and custom canvas/SVG scripts on `IntersectionObserver` and `prefers-reduced-motion`. For custom engineering diagrams or stepped course panels, read `~/.agents/skills/frontend-diagrams/SKILL.md`.

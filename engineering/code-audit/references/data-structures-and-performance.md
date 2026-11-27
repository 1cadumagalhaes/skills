# Data structures and performance

Performance claims need either a measurement or a complexity argument. "This looks slow" is not a finding; "this is O(n²) over 40k rows in the request path" is.

## Match the structure to the access pattern

| access pattern | structure | the smell it replaces |
|---|---|---|
| lookup by key, many times | dict / hashmap | scanning a list in a loop |
| membership test | set | `x in list` inside a loop |
| ordered iteration, stable | list / array | dict relying on insertion order for logic |
| range or prefix queries | sorted list, B-tree, index | filtering the whole collection per call |
| top-N of a stream | heap of size N | `sorted(xs)[-N:]` over everything |
| dedupe, preserve order | dict/set as an ordered accumulator | nested loop comparison |
| FIFO / LIFO | `deque` | `list.pop(0)` (O(n)) |
| cache with eviction | LRU (`OrderedDict`, `functools.lru_cache`) | dict that grows forever |
| grouping | dict of lists | repeated `filter` per group |
| interval overlap | sorted intervals + sweep | O(n²) pair checks |

Ask: what is the dominant operation, how many times per request, and over how many elements? The structure should make that operation cheap and the rest irrelevant.

## Complexity in the hot path

- `[check]` Nested loops over the same collection (O(n²)) where an index would do O(n).
- `[check]` A query, HTTP call or file read inside a loop — N+1. Batch it, or join it.
- `[check]` Sorting inside a loop; re-sorting the same collection per item.
- `[check]` Repeated work per row that depends only on the loop-invariant: compile the regex, parse the config, build the index once.
- `[check]` String concatenation in a loop where a join/comprehension belongs.
- `[check]` `len()`/membership recomputed on a list that is being scanned anyway.
- `[check]` Recursive descent over a deeply nested structure with no depth bound.

## Allocation and copying

- `[check]` Building a list only to iterate it once — generator or streaming.
- `[check]` Copying large frames/arrays defensively at every step (`df.copy()`, full slices).
- `[check]` Loading a whole table/file into memory when the consumer processes it row-wise.
- `[check]` Materializing intermediate collections in a pipeline that could be lazy.

## Caching

- `[check]` Cache key includes everything that changes the answer (tenant, filters, version) — or the cache is wrong.
- `[check]` Invalidation exists and is testable; "it never changes" is an assumption, not an invalidation.
- `[check]` Memory is bounded (size / TTL); no unbounded dict keyed by request.
- `[check]` Staleness is acceptable for this caller; a dashboard can be 5 minutes old, a balance cannot.

## Prove it

- Before: the measurement. `EXPLAIN ANALYZE` for a query, `cProfile`/`py-spy` for Python, a timing harness around the function with realistic sizes.
- After: the same measurement, same inputs. State the delta and the units.
- Guard against small-n: O(n²) on 10 rows beats a hash map's constant factor. Say the size at which the analysis holds.
- A perf change must preserve semantics: ordering, stability, error behaviour, and what happens on empty input. If it changes any of those, it is not a perf change, it is a behaviour change — say so.

## Report

    [major] path/etl.py:132 — O(n²): every row scans the full `products` list (12k) → ~144M
      comparisons per run, measured 41 s. Fix: build `by_sku = {p.sku: p for p in products}`
      once before the loop; lookup becomes O(1).

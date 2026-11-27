---
name: benchmark-check
description: Vet performance, latency, throughput, or query-cost benchmarks before reporting or acting on them.
cluster: engineering
tier: leaf
disable-model-invocation: true
derived_from: {repo: backnotprop/pstack, commit: c3464c11c60b, license: MIT}
---

# Benchmark checklist

Use this whenever reporting a speedup, latency number, CV inference throughput, or BigQuery/Postgres cost reduction. Answer every question from an actual run, never from reading code.

For a quick ballpark the user explicitly asked for, one run is acceptable if you check questions 4 and 7 and label it as a single run. Never choose between options from a ballpark.

## Before measuring

1. Write down the exact claim you plan to ship with units and dataset ("p50 inference latency drops 30% on the 144-frame frozen eval set").
2. Read the benchmark script or query plan to confirm what it times, counts, and skips.
3. Check machine load (`uptime`, `nproc`, active GPU jobs) or DB load. Stop noisy neighbors or interleave alternating runs so both sides share the same noise.

## Seven vetting questions

1. **What is the limiter?** Profile in a separate unmeasured run (`py-spy`, `cProfile`, `perf`, `strace -c`, `top`, `nvidia-smi`, or `EXPLAIN (ANALYZE, BUFFERS)`). Verify the load generator or Python client did not saturate first.
2. **Were both sides production-tuned?** Match release flags, worker counts, batch sizes, DB `work_mem`, connection pools, and warm vs cold cache state to production. Do not compare a tuned option against untuned defaults.
3. **Did it stay within physical limits?** Sanity-check throughput against disk I/O, network bandwidth, CPU cores, GPU VRAM, and Amdahl's law. Dropping a stage that was 10% of total runtime cannot yield a 40% end-to-end speedup; if it did, a cache or bug fired.
4. **Did errors or rejections skew the timing?** Count failed requests, HTTP non-200s, empty outputs, and retries. Fast errors masquerade as fast code. Verify output correctness alongside latency.
5. **Does it reproduce?** Run at least 5 alternating trials (`A, B, A, B, ...`) and report median and min-max range. A difference smaller than run-to-run spread is noise.
6. **Does it move the end-to-end path?** Report both the micro number and its share of the full pipeline, API request, or Airflow DAG task under realistic data sizes.
7. **Did the timed work actually execute?** Confirm DB rows landed, generators iterated, async coroutines awaited, BigQuery actually scanned rather than hitting query cache, and GPU work synchronized before stopping the clock.

## Report format

- **Verdict.** `faster`, `slower`, `no measurable difference`, or `inconclusive`. Mark `inconclusive` whenever a side was untuned, the limiter is unknown, or questions 4 and 7 were skipped.
- **Measurement.** Primary metric with unit, run count, median, min-max range, and limiter (`p50 41 ms to 33 ms, 7 alternating runs, range 32 to 35 ms, bound by JSON serialization on 1 core`).
- Keep PR bodies to the primary verdict and link raw tables or logs in a repo artifact or comment. Apply `~/.agents/skills/unslop/SKILL.md` to the final text.

Adapted from `backnotprop/pstack` `benchmark-check` (MIT, Lauren Tan).

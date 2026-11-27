# Decomposition

Is this one job or several? The test is not line count, it is *reasons to change* and *reuse across callers*.

## Signs a unit is doing more than one job

- the name needs "and", or it is `process`/`handle`/`manage`/`do` with no object
- it takes 6+ parameters, or 3+ booleans
- its sections have their own local variables and never share them
- different parts of it change for different reasons (a format tweak, a business rule, an infra detail)
- it is called once, from one place, but is 200 lines long inside a larger flow
- the docstring needs three paragraphs to describe the steps

## Where the seam goes

- **What varies together stays together.** Parsing and validating input belong in one unit; formatting output belongs in another; neither belongs inside the retry loop.
- **Split by change driver**, not by size: if the schema changes weekly and the business rule changes yearly, they are two units.
- **Pure core, thin shell.** Extract the computation into a function whose inputs are arguments and whose output is a value; leave I/O, clock, config and logging in the caller. That is what makes it testable and reusable. Hidden inputs (`now()`, `os.environ`, a module global, a random seed, a DB handle) are what make a step impossible to reuse.
- **Data in, data out.** A step that returns a named structure (`ParsedInvoice`, `ValidationResult`) is reusable and inspectable; one that mutates an argument and returns `None` is neither.
- **Name the intermediate value.** If you cannot name what passes between two steps, the split is wrong.

## Reuse: when a step deserves extracting

Two real callers, or one caller plus a test that needs to exercise it alone. Not before.

- Extract when the same *sequence* appears twice. The third occurrence is the signal, not the first.
- Extract when the caller must choose between variants. That is a parameter, not a copy.
- Do **not** extract a 3-line helper used once; it moves the code away from where the reader is looking and names it worse than the context did.
- Do **not** build an abstraction for a shape you have seen once ("we will need this for other providers"). Duplication is cheap; a wrong abstraction is a permanent tax.
- Do **not** extract for mocking's sake. Needing a seam means the seam belongs at a boundary (I/O), not in the middle of the logic.

## Composition preference

- Composition over inheritance: three levels of subclassing is almost always a strategy object plus a function.
- Pipelines over orchestration: a list of steps that each map input to output is easier to test, reorder and observe than a function that calls ten helpers in sequence with shared mutable state.
- One public entry per module: many small private helpers are fine; the public surface should make one promise.

## When not to split

- a single-use helper that only makes sense inside its caller
- splitting that would force callers to pass three extra values to preserve what was implicit
- "one class per file" dogmatism in a codebase that does not do that
- extracting while the behaviour is not yet understood. Do not refactor code you cannot yet explain

## Dead weight

Delete, do not extract: code paths no caller can reach, `if False` branches, flags never set to the non-default, functions kept "for later", parameters nobody passes. Speculative generality is a decomposition problem in the other direction.

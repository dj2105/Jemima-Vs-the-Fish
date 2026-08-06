# Repository instructions

## Product

This repository contains a genuine ZX Spectrum 48K game, not a modern game merely styled like one.

## Technical constraints

- Primary source language: Boriel BASIC.
- Target output: auto-running `.tap` file.
- Logical board: exactly 4 columns × 3 rows unless the design document is explicitly changed.
- Use integer and byte arithmetic where practical.
- Do not add floating-point physics to the basic edition.
- Keep gameplay graphics legal under standard Spectrum 8 × 8 attributes.
- Avoid dependencies that must run on the Spectrum itself.
- Python tools and tests may be used on the development machine.

## Design constraints

- The Fish controls the rod, not the fish directly.
- Jemima's challenge is prediction from disclosed start and end points.
- Do not reintroduce free-moving pendulum physics without a design decision.
- Preserve uncertainty: do not reveal the Fish's intermediate route before resolution.
- Keep the two roles mechanically distinct.

## Validation

Run:

```sh
python3 -m unittest discover -s tests -v
```

When Boriel BASIC is available, also run:

```sh
make
```

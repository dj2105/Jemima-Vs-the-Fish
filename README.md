# Jemima vs the Fish

A two-player prediction game for the 48K ZX Spectrum, intended to run through RetroArch's Fuse core as a `.tap` file.

## Current prototype

The first playable slice uses a shared **4 × 3 rod grid**:

1. The Fish player secretly enters a four-move rod route.
2. Jemima sees only the route's start and end squares.
3. Jemima enters her predicted four-move route.
4. The routes resolve one beat at a time.
5. Every matching direction means Jemima has contact with the fish; four matches produce a complete capture in this prototype.

The graphics deliberately use ordinary Spectrum attributes: one ink and one paper colour in each 8 × 8 cell. Multicolour engines are deferred until the game itself works.

## Controls

During route entry:

- `Q`: up
- `A`: down
- `O`: left
- `P`: right
- `SPACE`: continue after results

The players take turns using the same controls, so the Fish route remains hidden.

## Build

Install Boriel BASIC 1.18 or later and ensure `zxbc` is on your `PATH`, then run:

```sh
make
```

This should produce:

```text
build/jemima-vs-the-fish.tap
```

Run the tape in RetroArch using the Fuse core and a 48K Spectrum model.

## Validation

The route rules are mirrored in Python so they can be tested without an emulator:

```sh
make test
```

## Status

This is an early rules prototype. Scoring, red-herring key presses, hiding, role swapping, presentation and final capture rules remain open design work.

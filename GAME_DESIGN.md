# Game design: basic edition

## Fixed decisions

- Platform: ZX Spectrum 48K.
- Format: `.tap`, playable through RetroArch's Fuse core.
- Two human players share one screen and take asymmetric roles.
- Player one controls Jemima, a calico cat.
- Player two is referred to as **the Fish**, but controls the rod rather than directly controlling the toy fish.
- The rod uses a fixed 4 × 3 grid.
- In the basic edition, the rod and fish share the same logical grid.
- The Fish secretly chooses the rod's route.
- Jemima is shown the rod's start and end positions and predicts the hidden movement between them.
- Matching a movement beat means Jemima has the fish during that beat.
- The game should combine deduction, reading the other player, skill and uncertainty.

## Prototype round

1. A random starting square is selected.
2. The Fish enters four valid orthogonal moves.
3. The resulting end square is revealed to Jemima alongside the start square.
4. Jemima enters four valid orthogonal moves from the same start square.
5. Actual and predicted routes resolve simultaneously.
6. Matching directions build contact.
7. Four matches currently count as a complete capture.

The four-match capture rule is provisional. It is deliberately simple so that route prediction can be tested before adding scoring layers.

## Red-herring inputs

The intended advanced rule allows the Fish to make audible but void key presses, probably by holding a modifier. This prevents Jemima from using keyboard noise as reliable route information.

This is not in prototype 0.1. It requires direct matrix-key scanning so that the modifier can be detected independently and without changing the directional key's apparent feedback.

## Presentation

The first implementation should be tense and minimal:

- black paper;
- white grid;
- cyan Jemima prediction;
- magenta Fish route;
- yellow instructions and tension indicators;
- no attempt at unrestricted multicolour sprites;
- all colour changes aligned to the Spectrum's 8 × 8 attribute cells.

## Open questions

- Must complete capture require every move to match, or a consecutive streak?
- Should longer routes appear in later rounds?
- Does the Fish score for every unmatched beat, for proximity, or for surviving a full set?
- Can either player choose the route's starting square?
- How are hiding and surprise re-entry incorporated into this turn structure?
- Should red-herring inputs consume planning beats?
- How should players swap roles and determine the overall winner?

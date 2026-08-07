# Jemima vs the Fish — Love2D network prototype

Barebones two-player prototype of the current **node-network** design, written in Lua for **LÖVE (Love2D)**. The intended eventual target is a PortMaster-style native handheld build; this branch is deliberately asset-free so the rules can be tested first.

## Implemented

- Random map of **25–30 nodes**.
- Connected network with **maximum 4 paths per node**.
- Generator aims for mostly corridors, a smaller number of 3/4-way junctions, and roughly 10% dead ends.
- Fish always begins on a **3- or 4-path junction**.
- Each end of a path has its own A/B/X/Y colour. Only the colour touching the current node determines the Fish's button choice.
  - **A = green**
  - **B = red**
  - **X = blue**
  - **Y = yellow**
- The Fish secretly enters **exactly 4 valid moves**. Backtracking and reversals are allowed.
- The map does not visually trace the Fish's hidden route while it is being entered.
- Jemima then gets a visible free-moving cursor and can pounce on **any active node**.
- The four-step route is revealed and animated.
- Pounce on move 1–3: **Brief Catch**. The node is destroyed after the full route has resolved.
- Pounce on move 4/final destination: **Full Catch**, which takes priority over any earlier visit to the same node and immediately wins the game.
- A miss leaves the map unchanged.
- Destroying a node removes its connections. Any territory disconnected from the Fish is discarded/faded out.
- If destruction leaves the Fish completely isolated, the result is **Stalemate — lesser Fish victory**.
- No score for Brief Catches; node destruction is their only reward.
- A temporary **12-turn limit** is used so the prototype has a complete game loop. Reaching it without a Full Catch gives the Fish the win. The number 12 is a tuning placeholder because the final turn count has not yet been decided.

## Controls

### Gamepad

**Fish phase**

Press `A`, `B`, `X`, or `Y` four times. At every node, read the colour half touching that node to know which button takes each available path. Invalid buttons are simply ignored.

**Jemima phase**

- D-pad / left stick: move visible cursor
- `A`: pounce on highlighted node

**Results**

- `A`: next turn
- `Start` or `A`: new game after game over

### Keyboard fallback

- Fish: literal `A`, `B`, `X`, `Y` keys
- Jemima: arrow keys + `Enter`/`Space`
- Results/new game: `Enter`/`Space`

## Run on a computer

Install LÖVE 11.x, then run from the repository directory:

```sh
love .
```

No external graphics or audio assets are required.

## Prototype presentation

Everything is drawn procedurally for now:

- white circles = active nodes
- faint nodes/paths = territory discarded after a cut
- red X = destroyed Brief Catch node
- cyan marker = Fish
- pink target = Jemima's pounce
- two-colour path halves = local A/B/X/Y controls

The goal of this branch is to test whether the **prediction, containment, node destruction and blind route input** are fun before building the proper visual treatment and PortMaster package.

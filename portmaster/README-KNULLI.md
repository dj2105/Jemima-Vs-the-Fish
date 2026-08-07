# KNULLI / PortMaster test package

This directory contains the launcher used by the barebones LÖVE prototype.

Build the copy-ready ZIP from the repository root:

```sh
bash scripts/build_knulli_package.sh
```

The script creates:

```text
build/jemima-vs-the-fish-knulli.zip
```

Extract that ZIP directly into:

```text
/userdata/roms/ports/
```

Required installed components:

- PortMaster
- PortMaster `love_11.5` runtime

After extraction, refresh/restart KNULLI's game list and launch **Jemima vs the Fish** from Ports.

If it fails to launch, inspect:

```text
/userdata/roms/ports/jemima_vs_the_fish/log.txt
```

This is a local testing package rather than a finished PortMaster catalogue submission.

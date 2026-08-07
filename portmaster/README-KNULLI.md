# KNULLI / PortMaster test package

This directory contains the PortMaster launcher and metadata for the barebones LÖVE prototype.

## Build

From the repository root:

```sh
bash scripts/build_knulli_package.sh
```

This now creates a PortMaster-style autoinstall package:

```text
build/jemima_vs_the_fish.zip
```

## Install on KNULLI

Copy the ZIP **without extracting it** to:

```text
/userdata/system/.local/share/PortMaster/autoinstall/
```

Then launch PortMaster. PortMaster should detect the ZIP and install the launcher plus game directory into the correct Ports location.

The package includes a PortMaster `port.json` and `gameinfo.xml` rather than relying on manual extraction.

## About LÖVE 11.5

PortMaster's LÖVE 11.5 files live under:

```text
PortMaster/runtimes/love_11.5/
```

They are bundled PortMaster files and are not one of the squashfs runtimes shown in Runtime Manager, so it is normal for `love_11.5` not to appear in that list.

If Jemima fails to launch because `love_11.5/love.txt` is missing, update or reinstall the normal PortMaster package rather than downloading every Runtime Manager item.

## Troubleshooting

After installation, launch **Jemima vs the Fish** from Ports. If it fails, inspect:

```text
/userdata/roms/ports/jemima_vs_the_fish/log.txt
```

This remains a local gameplay-testing package rather than a finished PortMaster catalogue submission.

# Free Fire Memory Reader for Termux

A lightweight Termux tool using Shizuku + Frida to inspect a running Free Fire process, check environment state, list processes, scan memory, and run a simple hooker without root access.

## What is new

This version adds:
- upgraded Bash architecture with reusable helper functions
- a polished TUI menu for Termux
- automatic dependency checks
- better Free Fire package detection across variants
- structured logs and cache cleanup
- validation script to check shell syntax

## Features

- No root required via Shizuku
- Frida connectivity check
- Free Fire process detection
- Memory scanner
- Memory dumper
- Game hooker
- TUI menu for Termux
- Logs and cache management
- Easy installation and quick start scripts

## Requirements

- Android 8+
- Termux
- Shizuku installed and connected
- USB debugging enabled
- Python 3
- Frida and Frida Tools
- ADB (optional but recommended)

## Quick setup

```bash
cd termux-freefire-memory-reader
bash quick_start.sh
```

Then start Free Fire and run:

```bash
./freefire_reader.sh tui
```

Or use the classic menu:

```bash
./freefire_reader.sh menu
```

## Commands

```bash
./freefire_reader.sh status
./freefire_reader.sh processes
./freefire_reader.sh scanner
./freefire_reader.sh dumper
./freefire_reader.sh hooker
./freefire_reader.sh logs
./freefire_reader.sh clean
./freefire_reader.sh tui
```

## Installation

```bash
bash install.sh
```

This will install required dependencies and add shortcuts:
- `freefire-reader`
- `freefire-tui`

## Directory layout

```text
.
├── config.sh
├── freefire_reader.sh
├── freefire_tui.sh
├── install.sh
├── quick_start.sh
├── core/
│   └── common.sh
├── scripts/
│   ├── advanced_scanner.js
│   └── string_interceptor.js
├── tests/
│   └── validate.sh
├── README.md
└── LICENSE
```

## Notes

This project is meant for educational and research use. Use it only on devices you own or control, and respect app and platform policies.

## Validation

To check shell syntax:

```bash
bash tests/validate.sh
```


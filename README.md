# [Sega Saturn](https://en.wikipedia.org/wiki/Sega_Saturn) for MiSTer

## Hardware Requirements

- 128 MB SDRAM Module (Primary)
- SDRAM Module of any size (32MB-128MB) (Secondary)

> **Note:** Dual SDRAM modules is recommended for better compatibility.

## Status

The core has matured substantially, with many games tested over the course of development.

Known issues and limitations are tracked in this repository's issue list rather than in a game-by-game list here.


## 6-Player Multitap

Set **Input → Pad 1** or **Pad 2** to **6P Multitap** to plug an emulated Sega 6-Player Multitap into that port. Each tap slot is a digital pad. MiSTer exposes at most six controllers, so they are assigned as follows:

| Setting | Port 1 | Port 2 |
|---|---|---|
| Pad 1 = 6P Multitap | Tap: P1–P6 | idle pad |
| Pad 2 = 6P Multitap | P1 | Tap: P2–P6 (slot F idle) |
| Pad 2 = 6P Multitap + Pad 1 SNAC | real hardware (e.g. a real multitap) | Tap: P1–P6 |
| Both = 6P Multitap | Tap: P1–P6 | Tap: idle |

Swap Joysticks is ignored while a tap is enabled.

**Multitap Pads** sets which tap slots report a connected pad (empty slots read as "nothing plugged in", like a real tap):

- **Auto** (default): P1 is always connected; every other player appears the first time they press a button. MiSTer can't tell whether a USB pad is assigned to a player, so a press stands in for plugging it in.
- **6, 5, 4, 3, 2**: that many slots, starting from slot A, are always connected. Use this for games that only check connected pads at boot.

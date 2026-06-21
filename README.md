# MineColonies Automation

Warehouse-based MineColonies logistics automation for **All The Mods 10 (ATM10)** built using:

* CC:Tweaked
* Advanced Peripherals
* MineColonies
* Applied Energistics 2 (AE2)

The goal of this project is to automate the supply of building materials to a MineColonies warehouse while allowing MineColonies' own logistics, crafting, and courier systems to function normally.

---

## ProjectE Is Optional

ProjectE is **not required** for this project.

The automation only requires:

* MineColonies
* CC:Tweaked
* Advanced Peripherals
* Applied Energistics 2 (AE2)

The script obtains materials through AE2 using an ME Bridge and has no direct dependency on ProjectE.

ProjectE may optionally be used as an effectively infinite resource source:

```text
ProjectE
    ↓
Transmutation Interface
    ↓
AE2
    ↓
ME Bridge
    ↓
ComputerCraft
    ↓
Warehouse
```

However, the script works equally well with:

* Traditional AE2 storage systems
* Mystical Agriculture
* Productive Bees
* Quarry outputs
* Digital Miner outputs
* Vanilla storage imported into AE2
* Any other resource generation system connected to AE2

The only requirement is that the requested materials are available somewhere within the AE2 network.

---

## Features

* Automatically scans MineColonies requests.
* Supplies approved materials from AE2.
* Supports exact item matching.
* Supports regex-based material groups.
* Compatible with ProjectE Transmutation Interfaces.
* Uses the MineColonies warehouse as the central logistics hub.
* Preserves MineColonies courier behaviour.
* Only imports materials when active requests exist.
* Only imports the quantity required to satisfy requests.
* Automatically starts using `startup.lua`.
* GitHub-hosted deployment and updates.
* No direct builder deliveries.
* No warehouse cleanup or item vacuuming.
* No interference with MineColonies crafting systems.

---

## Design Philosophy

This project intentionally keeps automation simple.

```text
AE2
    ↓
ME Bridge
    ↓
ComputerCraft
    ↓
Warehouse
    ↓
Couriers
    ↓
Builders / Citizens / Workers
```

The script acts as a supplier, not a replacement for MineColonies.

### The Script Does

* Read MineColonies requests.
* Check warehouse stock.
* Calculate missing quantities.
* Pull approved materials from AE2.
* Deliver materials into the warehouse.

### The Script Does Not

* Deliver directly to builder huts.
* Deliver directly to citizens.
* Craft items.
* Manage recipes.
* Empty the warehouse.
* Return items to AE2.
* Interfere with MineColonies couriers.
* Replace MineColonies crafting buildings.

---

## Material Philosophy

The automation is designed to supply only the materials MineColonies consumes in large quantities while preserving MineColonies' own crafting chains.

### Imported Materials

The automation may supply:

* Raw materials
* Base building materials
* Intermediate crafting materials

Examples:

* Logs
* Planks
* Cobblestone
* Stone
* Stone Bricks
* Wool
* Dyes
* Terracotta
* End Stone
* Purpur Blocks
* Domum Ornamentum `*_extra` materials

These materials are supplied only when active MineColonies requests exist and warehouse stock is insufficient.

### Non-Imported Materials

The automation intentionally does not supply:

* Finished Domum Ornamentum decorative blocks
* Architect Cutter outputs
* Worker-crafted products
* Builder-specific crafted blocks
* Colony tools, armour, or equipment

Examples:

* Framed Paper Extra
* Framed Terracotta
* Double Crossed blocks
* Architect Cutter variants
* Other Domum Ornamentum decorative outputs

These items remain the responsibility of MineColonies workers.

### Why?

The goal is to preserve MineColonies gameplay rather than replace it.

The script acts as a supplier while MineColonies continues to handle:

* Crafting
* Deliveries
* Warehouse logistics
* Courier routing
* Worker specialisation

This keeps the colony functioning naturally while eliminating repetitive resource gathering.

---

## Why Warehouse-Only?

MineColonies already contains an excellent logistics system.

By using the warehouse as the central storage point:

* Couriers continue to function normally.
* Builders receive materials from couriers.
* Crafted materials remain available for future buildings.
* Domum Ornamentum materials remain available for reuse.
* Warehouse stock acts as a cache of commonly used resources.

---

## Requirements

### Minecraft Mods

* MineColonies
* Structurize
* CC:Tweaked
* Advanced Peripherals
* Applied Energistics 2

### Optional

* ProjectE
* ProjectE Transmutation Interface

---

## Hardware Setup

Recommended layout:

```text
[AE2 Network]
      │
      ▼
 [ME Bridge]
      │
      ▼
 [Buffer Barrel]
      │
      ▼
 [MineColonies Warehouse]

      ▲
      │
[ComputerCraft Computer]
      │
      ▼
[Colony Integrator]
```

### Notes

* The barrel must be accessible to the ME Bridge.
* The computer must be connected to:

  * Colony Integrator
  * ME Bridge
  * Warehouse
  * Buffer Barrel
* Wired modems are recommended.

---

## Installation

Install the script as a startup program:

```lua
wget https://raw.githubusercontent.com/Xeals-Senpai/minecolonies-automation/main/startup.lua startup.lua
```

The script will automatically start whenever the computer boots or the world loads.

To update:

```lua
delete startup.lua
wget https://raw.githubusercontent.com/Xeals-Senpai/minecolonies-automation/main/startup.lua startup.lua
reboot
```

---

## Configuration

The script supports both exact item matching and regex-based material groups.

### Exact Items

```lua
IMPORTABLE_ITEMS = {
    ["minecraft:cobblestone"] = true,
    ["minecraft:stone"] = true,
}
```

### Regex Patterns

```lua
IMPORTABLE_PATTERNS = {
    "^minecraft:.*_dye$",
    "^minecraft:.*_wool$",
    "^minecraft:.*_terracotta$",
    "^minecraft:end_.*$",
    "^minecraft:purpur_.*$",
    "^domum_ornamentum:.*_carpet$",
    "^domum_ornamentum:.*_extra$",
}
```

Regex groups allow large collections of related materials to be imported without maintaining hundreds of individual item entries.

---

## Example Workflow

Builder requests:

```text
Oak Logs x128
```

Warehouse currently contains:

```text
Oak Logs x40
```

The script calculates:

```text
128 - 40 = 88
```

Then:

```text
AE2 supplies 88 Oak Logs
↓
Warehouse receives 88 Oak Logs
↓
Couriers deliver logs
↓
Builder continues construction
```

If the warehouse already contains enough materials, nothing is imported.

---

## Current Workflow

```text
Builder Request
↓
MineColonies Request System
↓
ComputerCraft scans requests
↓
Warehouse stock checked
↓
Missing quantity calculated
↓
AE2 supplies materials
↓
Warehouse receives items
↓
MineColonies Couriers deliver materials
↓
MineColonies Workers craft specialised items
↓
Builders continue construction
```

---

## Known Limitations

* Courier throughput can become the primary bottleneck in large colonies.
* Domum Ornamentum decorative blocks should generally be crafted by MineColonies workers rather than imported directly.
* Correct MineColonies crafting recipes must be taught to workers.
* The automation is designed around a warehouse-centric logistics model.

---

## Future Ideas

Potential improvements that remain aligned with the project's design philosophy:

* Additional importable material groups.
* Additional Domum Ornamentum intermediate material support.
* Improved request filtering.
* Improved documentation and setup guides.
* Broader modpack compatibility testing.
* Minor performance and code quality improvements.

The project intentionally avoids replacing MineColonies logistics, crafting, or courier systems.

---

## Licence

This project is licensed under the MIT License.

See the LICENSE file for details.

# MineColonies Automation

Warehouse-based MineColonies logistics automation for **ATM10**, built using:

* CC:Tweaked (ComputerCraft)
* Advanced Peripherals
* MineColonies
* Applied Energistics 2 (AE2)
* ProjectE (optional but recommended)

The goal of this project is to automate the supply of **base building materials** to a MineColonies warehouse while allowing MineColonies' own logistics system (Couriers, Warehouse, Builders, Craftsmen, etc.) to handle all deliveries and crafting.

---

## Features

* Automatically scans MineColonies colony requests.
* Supplies approved base materials from AE2.
* Compatible with ProjectE Transmutation Interfaces.
* Uses the MineColonies warehouse as the single logistics hub.
* Leaves crafted materials and leftovers inside the warehouse.
* Preserves MineColonies courier behaviour.
* Only imports materials when active requests exist.
* Only imports the amount required to satisfy current requests.
* No direct builder hut deliveries.
* No warehouse cleanup or item vacuuming.

---

## Design Philosophy

This project intentionally keeps the automation simple.

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
    ↓
Couriers
    ↓
Builders / Citizens / Workers
```

The script acts as a supplier, not a replacement for MineColonies.

### The Script Does

* Read MineColonies requests.
* Check current warehouse stock.
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

---

## Why Warehouse-Only?

MineColonies already contains an excellent logistics system.

By using the warehouse as the central storage point:

* Couriers continue to function normally.
* Builders can receive materials from couriers.
* Crafted materials remain available for future buildings.
* Domum Ornamentum blocks remain stored for reuse.
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

Download the script:

```lua
wget https://raw.githubusercontent.com/Xeals-Senpai/minecolonies-automation/main/startup.lua startup
```

Or run directly:

```lua
wget run https://raw.githubusercontent.com/Xeals-Senpai/minecolonies-automation/main/startup.lua
```

---

## Configuration

Edit the following section:

```lua
local config = {
    scanInterval = 60,
    meSide = "right"
}
```

### Allowed Materials

Only approved materials may be imported:

```lua
importableBaseMaterials = {
    ["minecraft:oak_log"] = true,
    ["minecraft:cobblestone"] = true,
    ["minecraft:stone"] = true,
}
```

Add additional EMC-compatible building materials as required.

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

## Future Ideas

* Monitor integration
* Request dashboards
* Warehouse stock reporting
* Colony statistics
* Multiple colony support
* Discord notifications
* Automatic material reporting

---

## Licence

This project is licensed under the MIT License.

See the [LICENSE](LICENSE) file for details.

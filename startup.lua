-- MineColonies + AE2/ProjectE Warehouse Supplier
-- For ATM10-style setups using:
-- ComputerCraft / CC:Tweaked
-- Advanced Peripherals
-- Applied Energistics 2
-- ProjectE Transmutation Interface
-- MineColonies
--
-- Behaviour:
-- 1. Checks MineColonies colony requests.
-- 2. Only reacts when there are active requests.
-- 3. Only imports approved base materials from AE2/ProjectE.
-- 4. Sends materials into the MineColonies warehouse only.
-- 5. Leaves all warehouse leftovers/crafted materials alone.
-- 6. Does not deliver directly to builder huts.
-- 7. Does not clean builder huts.
-- 8. Does not export warehouse contents back to AE2.

local config = {
    scanInterval = 60,
    meSide = "right",
    bufferSleep = 0.3,

    importableBaseMaterials = {
        -- Logs
        ["minecraft:oak_log"] = true,
        ["minecraft:spruce_log"] = true,
        ["minecraft:birch_log"] = true,
        ["minecraft:jungle_log"] = true,
        ["minecraft:acacia_log"] = true,
        ["minecraft:dark_oak_log"] = true,
        ["minecraft:mangrove_log"] = true,
        ["minecraft:cherry_log"] = true,

        -- Planks
        ["minecraft:oak_planks"] = true,
        ["minecraft:spruce_planks"] = true,
        ["minecraft:birch_planks"] = true,
        ["minecraft:jungle_planks"] = true,
        ["minecraft:acacia_planks"] = true,
        ["minecraft:dark_oak_planks"] = true,
        ["minecraft:mangrove_planks"] = true,
        ["minecraft:cherry_planks"] = true,

        -- Stone materials
        ["minecraft:cobblestone"] = true,
        ["minecraft:stone"] = true,
        ["minecraft:smooth_stone"] = true,
        ["minecraft:andesite"] = true,
        ["minecraft:diorite"] = true,
        ["minecraft:granite"] = true,
        ["minecraft:deepslate"] = true,
        ["minecraft:cobbled_deepslate"] = true,

        -- Earth / loose materials
        ["minecraft:dirt"] = true,
        ["minecraft:grass_block"] = true,
        ["minecraft:sand"] = true,
        ["minecraft:red_sand"] = true,
        ["minecraft:gravel"] = true,
        ["minecraft:clay_ball"] = true,
        ["minecraft:coarse_dirt"] = true,
        ["minecraft:clay"] = true,
        
        -- Nether Materials
        ["minecraft:netherrack"] = true,
        ["minecraft:nether_bricks"] = true,
        ["minecraft:quartz"] = true,
        ["minecraft:quartz_block"] = true,


        -- Common building materials
        ["minecraft:glass"] = true,
        ["minecraft:glass_pane"] = true,
        ["minecraft:bricks"] = true,
        ["minecraft:brick"] = true,

        -- Fuel / metals
        ["minecraft:coal"] = true,
        ["minecraft:coal_block"] = true,
        ["minecraft:charcoal"] = true,
        ["minecraft:iron_ingot"] = true,
        ["minecraft:copper_ingot"] = true,
        ["minecraft:diamond"] = true,
        ["minecraft:netherite_ingot"] = true,

        -- Food
        ["minecraft:beef"] = true,
        ["minecraft:chicken"] = true,
        ["minecraft:mutton"] = true,
        ["minecraft:porkchop"] = true,
        ["minecraft:salmon"] = true,

        -- Smithing Templates
        ["minecraft:netherite_upgrade_smithing_template"] = true,

        -- Basic utility materials
        ["minecraft:stick"] = true,
        ["minecraft:string"] = true,
        ["minecraft:torch"] = true,
        ["minecolonies:large_empty_bottle"] = true,
        ["minecolonies:ancienttome"] = true,
        ["minecraft:redstone"] = true,
        ["minecraft:redstone_torch"] = true,

        -- Add your own EMC-backed base materials below.
        -- Example:
        -- ["domum_ornamentum:extra_cobblestone"] = true,
        -- ["domum_ornamentum:extra_oak"] = true,
    }
}

local BLOCKED_PATTERNS = {
    "_helmet$",
    "_chestplate$",
    "_leggings$",
    "_boots$",

    "_sword$",
    "_pickaxe$",
    "_axe$",
    "_shovel$",
    "_hoe$",

    "_bow$",
    "_crossbow$",
    "_shield$",

    "_mask$",
    "_goggles$",
    "_backtank$",
}

local colony = peripheral.find("colony_integrator")
local bridge = peripheral.find("me_bridge")
local warehouse = peripheral.find("minecolonies:warehouse")
local buffer = peripheral.wrap("minecraft:barrel_0")

if not colony then error("No Colony Integrator found") end
if not bridge then error("No ME Bridge found") end
if not warehouse then error("No MineColonies warehouse found") end
if not buffer then error("No buffer barrel found") end

local warehouseName = peripheral.getName(warehouse)

local function log(message)
    print(os.date("%H:%M:%S") .. " | " .. tostring(message))
end

local function isBlockedFinishedItem(itemName)
    for _, pattern in ipairs(BLOCKED_PATTERNS) do
        if itemName:match(pattern) then
            return true
        end
    end

    return false
end

local IGNORED_PATTERNS = {
    "_ore$",
}

local function isIgnoredRequestItem(itemName)
    if isBlockedFinishedItem(itemName) then
        return true
    end

    for _, pattern in ipairs(IGNORED_PATTERNS) do
        if itemName:match(pattern) then
            return true
        end
    end

    return false
end

local function isImportableBaseMaterial(itemName)
    return config.importableBaseMaterials[itemName] == true
end

local function indexWarehouse()
    local inventory = {}

    for _, item in pairs(warehouse.list()) do
        inventory[item.name] = (inventory[item.name] or 0) + item.count
    end

    return inventory
end

local function clearBufferToWarehouse()
    local movedTotal = 0

    for slot, _ in pairs(buffer.list()) do
        local moved = buffer.pushItems(warehouseName, slot)
        movedTotal = movedTotal + moved
    end

    return movedTotal
end

local function getRequestAmount(req, item)
    return req.count or item.count or req.minCount or item.minCount or 1
end

local function supplyWarehouse(itemName, amount)
    if amount <= 0 then
        return 0
    end

    if not isImportableBaseMaterial(itemName) then
        log("Blocked non-base material: " .. itemName)
        return 0
    end

    local meItem = bridge.getItem({
        name = itemName
    })

    if not meItem or not meItem.count or meItem.count <= 0 then
        log("AE2/ProjectE cannot provide: " .. itemName)
        return 0
    end

    local pullAmount = math.min(amount, meItem.count)

    log("Importing x" .. pullAmount .. " " .. itemName .. " from AE2/ProjectE")

    bridge.exportItem({
        name = itemName,
        count = pullAmount
    }, config.meSide)

    sleep(config.bufferSleep)

    local moved = clearBufferToWarehouse()

    if moved > 0 then
        log("Moved x" .. moved .. " " .. itemName .. " into warehouse")
    else
        log("Warning: exported item but nothing moved into warehouse")
    end

    return moved
end

local function trackNotImported(notImported, itemName, count, reason)
    if notImported[itemName] then
        notImported[itemName].count = notImported[itemName].count + count
    else
        notImported[itemName] = {
            count = count,
            reason = reason
        }
    end
end

local function handleRequest(req, warehouseInventory, notImported)
    local requestName = tostring(req.name or "unknown request")

    if not req.items then
        log("Skipping request with no item options: " .. requestName)
        return
    end

    for _, item in pairs(req.items) do
        local itemName = item.name

        if itemName and isImportableBaseMaterial(itemName) then
            local requestedAmount = getRequestAmount(req, item)
            local warehouseAmount = warehouseInventory[itemName] or 0
            local topUpAmount = requestedAmount - warehouseAmount

            if topUpAmount > 0 then
                log("Request: " .. requestName)
                log("Needs x" .. requestedAmount .. " " .. itemName)
                log("Warehouse has x" .. warehouseAmount .. ", topping up x" .. topUpAmount)

                local moved = supplyWarehouse(itemName, topUpAmount)

                warehouseInventory[itemName] = warehouseAmount + moved
            else
                log("Warehouse already satisfies request for " .. itemName .. " x" .. warehouseAmount)
            end

            return
        end
    end

for _, item in pairs(req.items) do
    local missingItemName = item.name or requestName

    if not isIgnoredRequestItem(missingItemName) then
        trackNotImported(
            notImported,
            missingItemName,
            item.count or req.count or 1,
            "not in import list"
        )
    end
end

    log("No importable base material found for request: " .. requestName)
end

local function printNotImportedSummary(notImported)
    print("")
    print("========================================")
    print("      Items Missing Import Rules")
    print("========================================")
    print("")

    local hasItems = false

    for itemName, data in pairs(notImported) do
        hasItems = true
        print(string.format("%-34s x%s", itemName, data.count))
    end

    if not hasItems then
        print("None")
    end

    print("")
    print("========================================")
end

local function handleRequests()
    log("Checking colony requests")

    local requests = colony.getRequests()

    if not requests or next(requests) == nil then
        log("No active colony requests")
        return
    end

    local warehouseInventory = indexWarehouse()
    local notImported = {}

    for _, req in pairs(requests) do
        handleRequest(req, warehouseInventory, notImported)
        sleep(0.1)
    end

    printNotImportedSummary(notImported)
end

local function mainLoop()
    clearBufferToWarehouse()
    handleRequests()
    log("Sleeping for " .. config.scanInterval .. " seconds")
end

while true do
    local success, err = pcall(mainLoop)

    if not success then
        log("ERROR: " .. tostring(err))
    end

    sleep(config.scanInterval)
end
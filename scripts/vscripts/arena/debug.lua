--[[
    Defines debug members such as console commands for quick testing.
]]

local function ArenaDebugEnterVent()
    local vent = Entities:FindByNameWithin(nil, "*vent_grate", Vector(-1016, -832, 20), 32)
    local box = Entities:FindByModelWithin(nil, "models/props/plastic_container_1.vmdl", Vector(-1018.17, -853.125, 18.6429), 32)
    if vent then vent:Kill() end
    if box then box:Kill() end
    local target = Entities:FindByName(nil, "test_tp_vent")
    if target then
        Entities:GetLocalPlayer():SetOrigin(target:GetOrigin())
    end
end
Convars:RegisterCommand("arena_debug_enter_vent", ArenaDebugEnterVent, "", 0)

local function ArenaDebugExitVent()
    local target = Entities:FindByName(nil, "tp_arena_to_prison_destination")
    if target then
        Entities:GetLocalPlayer():SetOrigin(target:GetOrigin())
    end
end
Convars:RegisterCommand("arena_debug_exit_vent", ArenaDebugExitVent, "", 0)

local function ArenaDebugCage()
    local target = Entities:FindByName(nil, "test_tp_cage")
    if target then
        Entities:GetLocalPlayer():SetOrigin(target:GetOrigin())
    end
end
Convars:RegisterCommand("arena_debug_cage", ArenaDebugCage, "", 0)

local function ArenaDebugJeffEscape()
    DoEntFire("count_cage_combine", "SetValue", "0", 0, nil, nil)
    local target = Entities:FindByName(nil, "test_tp_jeff_escape")
    if target then
        Entities:GetLocalPlayer():SetOrigin(target:GetOrigin())
    end
end
Convars:RegisterCommand("arena_debug_jeff_escape", ArenaDebugJeffEscape, "", 0)


Convars:RegisterCommand("arena_debug_stage_5_dogs",
function()
    SetStage(3)
end, "", 0)
Convars:RegisterCommand("arena_debug_stage_5_combine",
function()
    SetStage(4)
end, "", 0)
Convars:RegisterCommand("arena_debug_stage_5_jeff",
function()
    SetStage(5)
end, "", 0)

print("Arena debug script executed")


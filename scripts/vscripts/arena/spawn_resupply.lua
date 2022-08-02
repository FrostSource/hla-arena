require"util.weighted_random"
require"arena.debug"

local ResupplyEntName = "resupply_point_*"
local ScavengeEntName = "scavenge_point"
local ArenaCenterName = "@arena_center"
local ArenaTopName = "@arena_top"
local ArenaCenterRadius = 800
local ArenaTopRadius = 300
--local Stage = Stage or 0

local ResupplyItems = {
    -- has pistol
    WeightedRandom({
        { class = "item_hlvr_clip_energygun", weight = 1.0 },
        { class = "item_hlvr_clip_energygun_multiple", weight = 0.3 },
        { class = "item_healthvial", weight = 0.3 },
        { class = "item_hlvr_grenade_frag", weight = 0.05 },
    }),
    -- has shotgun
    WeightedRandom({
        { class = "item_hlvr_clip_energygun", weight = 1.0 },
        { class = "item_hlvr_clip_energygun_multiple", weight = 0.3 },
        { class = "item_hlvr_clip_shotgun_single", weight = 0.7 },
        { class = "item_hlvr_clip_shotgun_shells_pair", weight = 0.65 },
        { class = "item_hlvr_clip_shotgun_multiple", weight = 0.3 },
        { class = "item_healthvial", weight = 0.35 },
        { class = "item_hlvr_grenade_frag", weight = 0.1 },
    }),
    -- has rapid (lighting dog)
    WeightedRandom({
        { class = "item_hlvr_clip_energygun", weight = 1.0 },
        { class = "item_hlvr_clip_energygun_multiple", weight = 0.35 },
        { class = "item_hlvr_clip_rapidfire", weight = 0.8 },
        { class = "item_hlvr_clip_shotgun_single", weight = 0.6 },
        { class = "item_hlvr_clip_shotgun_shells_pair", weight = 0.6 },
        { class = "item_hlvr_clip_shotgun_multiple", weight = 0.4 },
        { class = "item_healthvial", weight = 0.35 },
        { class = "item_hlvr_grenade_frag", weight = 0.025 },
    }),
    -- combat
    WeightedRandom({
        { class = "item_hlvr_clip_energygun", weight = 1.0 },
        { class = "item_hlvr_clip_energygun_multiple", weight = 0.5 },
        { class = "item_hlvr_clip_rapidfire", weight = 0.8 },
        { class = "item_hlvr_clip_shotgun_single", weight = 0.8 },
        { class = "item_hlvr_clip_shotgun_shells_pair", weight = 0.8 },
        { class = "item_hlvr_clip_shotgun_multiple", weight = 0.5 },
        { class = "item_healthvial", weight = 0.45 },
        { class = "item_hlvr_grenade_frag", weight = 0.2 },
    }),
    -- jeff
    WeightedRandom({
        { class = "item_hlvr_clip_energygun", weight = 1.0 },
        { class = "item_hlvr_clip_energygun_multiple", weight = 0.6 },
        { class = "item_hlvr_clip_rapidfire", weight = 0.6 },
        { class = "item_hlvr_clip_shotgun_single", weight = 0.6 },
        { class = "item_hlvr_clip_shotgun_shells_pair", weight = 0.6 },
        { class = "item_hlvr_clip_shotgun_multiple", weight = 0.5 },
        { class = "item_healthvial", weight = 0.3 },
        { class = "item_hlvr_grenade_frag", weight = 0.1 },
    }),
    -- chargers
    WeightedRandom({
        { class = "item_hlvr_clip_energygun", weight = 0.8 },
        { class = "item_hlvr_clip_energygun_multiple", weight = 0.6 },
        { class = "item_hlvr_clip_rapidfire", weight = 0.8 },
        { class = "item_hlvr_clip_shotgun_single", weight = 0.5 },
        { class = "item_hlvr_clip_shotgun_shells_pair", weight = 0.7 },
        { class = "item_hlvr_clip_shotgun_multiple", weight = 0.8 },
        { class = "item_healthvial", weight = 0.5 },
        { class = "item_hlvr_grenade_frag", weight = 0.3 },
    }),
    -- infinite
    WeightedRandom({
        { class = "item_hlvr_clip_energygun", weight = 1.0 },
        { class = "item_hlvr_clip_energygun_multiple", weight = 0.5 },
        { class = "item_hlvr_clip_rapidfire", weight = 0.8 },
        { class = "item_hlvr_clip_shotgun_single", weight = 0.8 },
        { class = "item_hlvr_clip_shotgun_shells_pair", weight = 0.8 },
        { class = "item_hlvr_clip_shotgun_multiple", weight = 0.5 },
        { class = "item_healthvial", weight = 0.45 },
        { class = "item_hlvr_grenade_frag", weight = 0.2 },
    }),
}

local OutOfAmmoResupply = WeightedRandom({
    { class = "item_hlvr_clip_energygun", weight = 1.0 },
    { class = "item_hlvr_clip_energygun_multiple", weight = 0.5 },
})

local ScavangeMinMax = {
    { min = 5, max = 8 }, -- pistol
    { min = 10, max = 14 }, -- shotgun
    { min = 35, max = 45 }, -- lightning dogs
    { min = 17, max = 25 }, -- combat
    { min = 26, max = 32 }, -- jeff
    { min = 25, max = 35 }, -- chargers
    { min = 20, max = 30 }, -- infinite
}

local function PlayerStoredWristItem(data)
    if string.find(data.item_name, "screwdriver_item") then
        DoEntFire("relay_override_wrist_pockets", "Disable", "", 0, nil, nil)
    end
    print("ArenaLogic", "PlayerStoredWristItem", data.item, data.item_name)
end

function GetStage()
    return thisEntity:Attribute_GetIntValue("arena_stage", 0)
end
function SetStage(stage)
    thisEntity:Attribute_SetIntValue("arena_stage", stage)
end
function NextStage()
    print("ArenaLogic", "NextStage()")
    local stage = GetStage()
    if Entities:FindByName(nil, "arena_wave_counter_"..(stage + 1)) ~= nil then
        stage = stage + 1
        SetStage(stage)
    end
    print("ArenaLogic", "Enabling wave", "arena_wave_counter_"..stage)
    DoEntFire("arena_wave_counter_"..stage, "Enable", "", 0, nil, nil)
    DoEntFire("arena_wave_counter_"..stage, "SetValueNoFire", "0", 0, nil, nil)
    DoEntFire("arena_music_counter_"..stage, "Enable", "", 0, nil, nil)
    --DoEntFire("arena_stage_counter", "Add", "1", 0, nil, nil)
    DoEntFire("arena_stage_counter", "SetValue", stage.."", 0, nil, nil)
end

local function ResupplySpawn(class)
    local allPoints = Entities:FindAllByName(ResupplyEntName)
    local chosenPoint = allPoints[RandomInt(1,#allPoints)]
    local crate = SpawnEntityFromTableSynchronous("item_item_crate", {
        origin = chosenPoint:GetOrigin(),
        ItemClass = class,
        CrateAppearance = "2",
        ItemCount = "1"
    })
    crate:SetHealth(10)
    --print("HEALTH", crate:GetHealth())
    crate:ApplyAbsVelocityImpulse(chosenPoint:GetForwardVector() * 120)
    DoEntFireByInstanceHandle(thisEntity, "FireUser1", "", 0, nil, nil)
    --print("Resupply", class)
end

local function Resupply()
    --if stage == nil then
    --    stage = GetStage()
    --end
    --if amount == nil then
    --    amount = RandomInt(2,4)
    --end
    local amount = RandomInt(2,5)
    local stage = Clamp(GetStage(), 1, #ResupplyItems)--min(GetStage(), #ResupplyItems)
    for i = 1, amount do
        local chosenItem = ResupplyItems[stage]:Random().class
        ResupplySpawn(chosenItem)
    end
    print("Resupply", "Resupply("..amount..")")
    --ResupplyStage(GetStage())
end
thisEntity:GetPrivateScriptScope().Resupply = Resupply

local function ResupplyAmount(amount)
    for i = 1, amount do
        Resupply()
    end
end

local function OutOfAmmo()
    print("ArenaLogic", "OutOfAmmo")
    local centerPoint = Entities:FindByName(nil, ArenaCenterName):GetOrigin()
    -- check for pistol ammo waiting to be picked up
    if #Entities:FindAllByClassnameWithin("item_hlvr_clip_energygun", centerPoint, ArenaCenterRadius) < 3 then
        print("ArenaLogic", "OutOfAmmo", "Spawning Ammo")
        local chosenItem = OutOfAmmoResupply:Random().class
        ResupplySpawn(chosenItem)
    else
        print("ArenaLogic", "OutOfAmmo", "Ammo is already present")
    end
end
thisEntity:GetPrivateScriptScope().OutOfAmmo = OutOfAmmo

local function SpawnScavangeAmmo()
    local stage = min(GetStage(), #ScavangeMinMax)
    local itemCount = RandomInt(ScavangeMinMax[stage].min, ScavangeMinMax[stage].max)
    local allPoints = Entities:FindAllByName(ScavengeEntName)
    for i = 1, itemCount do
        ::choose::
        local chosenItem = ResupplyItems[stage]:Random().class
        if chosenItem == "item_healthvial" and #Entities:FindAllByClassname("item_healthvial") > 1 then
            goto choose
        end
        local amountHere = 1
        local chosenPoint = allPoints[RandomInt(1,#allPoints)]
        -- turn pair into two single
        if chosenItem == "item_hlvr_clip_shotgun_shells_pair" then
            chosenItem = "item_hlvr_clip_shotgun_single"
            amountHere = 2
        end
        -- spawn number of item here (usually 1)
        for j = 1, amountHere do
            local item = SpawnEntityFromTableSynchronous(chosenItem, {
                origin = chosenPoint:GetOrigin(),
                angles = QAngle(RandomInt(0,359),RandomInt(0,359),RandomInt(0,359)),
            })
        end
    end
    print("Resupply", "SpawnScavangeAmmo()", itemCount)
end
thisEntity:GetPrivateScriptScope().SpawnScavangeAmmo = SpawnScavangeAmmo

local function RemoveUnwantedNPCs()
    local classes = {
        "npc_zombie_blind",
        "npc_combine_s",
        "npc_headcrab_black",
        "npc_headcrab_runner",
        --"npc_zombie",
        "npc_headcrab",
        "npc_manhack"
    }
    local count = 0
    for _, class in ipairs(classes) do
        local npcs = Entities:FindAllByClassname(class)
        for _, npc in ipairs(npcs) do
            npc:Kill()
            count = count + 1
        end
    end
    print("ArenaLogic", "RemoveUnwantedNPCs()", count)
end
thisEntity:GetPrivateScriptScope().RemoveUnwantedNPCs = RemoveUnwantedNPCs

local function RemoveUnwantedRagdolls()
    local models = {
        ["models/characters/combine_grunt/combine_grunt.vmdl"] = true,
        ["models/characters/combine_soldier_captain/combine_captain.vmdl"] = true,
        ["models/characters/combine_soldier_heavy/combine_soldier_heavy.vmdl"] = true,
        ["models/characters/combine_suppressor/combine_suppressor.vmdl"] = true,
        ["models/creatures/headcrab_black/headcrab_black.vmdl"] = true,
        ["models/creatures/headcrab_reviver/headcrab_reviver.vmdl"] = true,
    }

    local count = 0
    local ragdolls = Entities:FindAllByClassname("prop_ragdoll")
    for _, ragdoll in ipairs(ragdolls) do
        if models[ragdoll:GetModelName()] ~= nil then
            ragdoll:Kill()
            count = count + 1
        end
    end
    print("ArenaLogic", "RemoveUnwantedRagdolls()", count)
end
thisEntity:GetPrivateScriptScope().RemoveUnwantedRagdolls = RemoveUnwantedRagdolls

local function RemoveUnwantedItems()
    local classes = {
        "item_hlvr_clip_energygun",
        "item_hlvr_clip_energygun_multiple",
        "item_healthvial",
        "item_hlvr_grenade_frag",
        "item_hlvr_clip_shotgun_single",
        "item_hlvr_clip_shotgun_multiple",
        "item_hlvr_clip_rapidfire",
    }
    local centerPoint = Entities:FindByName(nil, ArenaCenterName):GetOrigin()

    for _, class in ipairs(classes) do
        local items = Entities:FindAllByClassnameWithin(class, centerPoint, ArenaCenterRadius)
        for _, item in ipairs(items) do
            item:Kill()
        end
    end
end
thisEntity:GetPrivateScriptScope().RemoveUnwantedItems = RemoveUnwantedItems

local function ForceRunnersReviveNearest()
    local runners = Entities:FindAllByClassname("npc_headcrab_runner")
    -- runners may find same body but game should resolve this
    local ragdolls = Entities:FindAllByClassname("prop_ragdoll")
    print("IN REVIVE")
    for _, runner in ipairs(runners) do
        print("LOOP")
        local nearestZombie = nil
        local nearestDistance = 9999999999
        for _, ragdoll in ipairs(ragdolls) do
            -- can only revive zombies
            if ragdoll:GetModelName() == "models/creatures/zombie_classic/zombie_classic.vmdl" then
                local dist = VectorDistanceSq(runner:GetOrigin(), ragdoll:GetOrigin())
                print("dist", dist)
                if dist < nearestDistance then
                    print("Found new zombie")
                    nearestZombie = ragdoll
                    nearestDistance = dist
                end
            end
        end
        -- found nearest or nil
        if nearestZombie ~= nil then
            nearestZombie:SetEntityName(nearestZombie:GetName()..DoUniqueString(""))
            print("CHANGED NAME TO", nearestZombie:GetName())
            DoEntFireByInstanceHandle(runner, "ForceRevive", nearestZombie:GetName(), 0, nil, nil)
        end
    end
    --local nearest = Entities:FindByNameNearest("*wave_zombie*", Entities:GetLocalPlayer():GetOrigin(), 2048)
    --print("NEAREST", nearest)
    --debugoverlay:Sphere(nearest:GetOrigin(), 30, 255, 0, 0, 255, true, 5)
end
thisEntity:GetPrivateScriptScope().ForceRunnersReviveNearest = ForceRunnersReviveNearest

local function PushNaughtyItems()
    local classes = {
        "item_hlvr_clip_energygun",
        "item_hlvr_clip_energygun_multiple",
        "item_healthvial",
        "item_hlvr_grenade_frag",
        "item_hlvr_clip_shotgun_single",
        "item_hlvr_clip_shotgun_multiple",
        "item_hlvr_clip_rapidfire",
        "item_item_crate",
    }
    local centerPoint = Entities:FindByName(nil, ArenaTopName):GetOrigin()

    local pushForceMultiplier = 7
    for _, class in ipairs(classes) do
        local items = Entities:FindAllByClassnameWithin(class, centerPoint, ArenaTopRadius)
        for _, item in ipairs(items) do
            item:ApplyAbsVelocityImpulse((centerPoint - item:GetOrigin()):Normalized() * 60)
            --debugoverlay:Sphere(centerPoint, 16, 255, 0, 0, 255, true, 7)
            --debugoverlay:Sphere(item:GetOrigin(), 16, 0, 255, 0, 255, true, 7)
            --debugoverlay:Line(item:GetOrigin(), item:GetOrigin() + (centerPoint - item:GetOrigin()):Normalized() * item:GetMass()*pushForceMultiplier,255,255,255,255,true,7)
        end
    end
end
thisEntity:GetPrivateScriptScope().PushNaughtyItems = PushNaughtyItems

local function FixCombineWithoutGrenade()
    local combines = Entities:FindAllByClassname("npc_combine_s")
    for _, combine in ipairs(combines) do
        for _, child in ipairs(combine:GetChildren()) do
            if child:GetClassname() == "item_hlvr_grenade_frag" then
                break
            end
            -- set input if no grenade found
            DoEntFireByInstanceHandle(combine, "SetAllowedToThrowGrenades", "0", 0, nil, nil)
        end
    end
end
thisEntity:GetPrivateScriptScope().FixCombineWithoutGrenade = FixCombineWithoutGrenade

local function DebugBackup()
    local stage = GetStage()
    if stage > 2 then
        DoEntFire("template_arena_item_shotgun", "ForceSpawn", "", 0, nil, nil)
    end
    if stage > 3 then
        DoEntFire("template_arena_item_rapid", "ForceSpawn", "", 0, nil, nil)
    end
end
thisEntity:GetPrivateScriptScope().DebugBackup = DebugBackup



local function ready(saveLoaded)
    ListenToGameEvent("player_stored_item_in_itemholder", PlayerStoredWristItem, nil)
    --ListenToGameEvent("player_death", OnPlayerDeath, thisEntity)
end

-- Fix for script executing twice on restore.
-- This binds to the new local ready function on second execution.
if thisEntity:GetPrivateScriptScope().savewasloaded then
    thisEntity:SetContextThink("init", function() ready(true) end, 0)
end

---@param activateType "0"|"1"|"2"
function Activate(activateType)
    -- If game is being restored then set the script scope ready for next execution.
    if activateType == 2 then
        thisEntity:GetPrivateScriptScope().savewasloaded = true
        return
    end
    -- Otherwise just run the ready function after "instant" delay (player will be ready).
    thisEntity:SetContextThink("init", function() ready(false) end, 0)
end

-- Add local functions to private script scope to avoid environment pollution.
-- local _a,_b=1,thisEntity:GetPrivateScriptScope()while true do local _c,_d=debug.getlocal(1,_a)if _c==nil then break end;if type(_d)=='function'then _b[_c]=_d end;_a=1+_a end

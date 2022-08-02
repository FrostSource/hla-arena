--[[
    This should all probably be moved to a core script which is called by prefab ents
]]
require"util.util"
require"util.entities"
require"util.weighted_random"

local ATTACHED_MANAGER =
{
    BASE =
    {
        classname = "ai_attached_item_manager";
        targetname = "attached_manager";
        listen_entityspawns = true;
        mark_as_removable = 1;
        -- this must be changed by script
        target = "";
    },

    -- COMBINE =
    -- {
    --     {
    --         num_attached_items = 0;
    --         item_1 = "";
    --         item_2 = "";
    --         item_3 = "";
    --         item_4 = "";
    --     },
    --     {
    --         num_attached_items = 1;
    --         item_1 = "item_hlvr_clip_energygun";
    --         item_2 = "";
    --         item_3 = "";
    --         item_4 = "";
    --     },
    --     {
    --         num_attached_items = 2;
    --         item_1 = "item_hlvr_clip_energygun";
    --         item_2 = "item_hlvr_grenade_frag";
    --         item_3 = "";
    --         item_4 = "";
    --     },
    --     {
    --         num_attached_items = 2;
    --         item_1 = "item_hlvr_clip_energygun";
    --         item_2 = "item_healthvial";
    --         item_3 = "";
    --         item_4 = "";
    --     }
    -- };

    -- ZOMBIE =
    -- {
    --     {
    --         num_attached_items = 0;
    --         item_1 = "";
    --         item_2 = "";
    --         item_3 = "";
    --         item_4 = "";
    --     },
    --     {
    --         num_attached_items = 1;
    --         item_1 = "item_hlvr_clip_energygun";
    --         item_2 = "";
    --         item_3 = "";
    --         item_4 = "";
    --     },
    --     {
    --         num_attached_items = 2;
    --         item_1 = "item_hlvr_clip_energygun";
    --         item_2 = "item_hlvr_clip_energygun";
    --         item_3 = "";
    --         item_4 = "";
    --     },
    --     {
    --         num_attached_items = 2;
    --         item_1 = "item_hlvr_clip_energygun";
    --         item_2 = "item_healthvial";
    --         item_3 = "";
    --         item_4 = "";
    --     }
    -- };

    ---@class AttacherItems
    ---@field MIN_ITEMS integer
    ---@field MAX_ITEMS integer
    ---@field ITEM_POOL WeightedRandom

    ---@type AttacherItems
    COMBINE =
    {
        MIN_ITEMS = 0;
        MAX_ITEMS = 2;
        -- #ITEMS >= MAX_ITEMS
        ITEM_POOL = WeightedRandom({
            { class = "item_hlvr_clip_energygun", weight = 1    };
            { class = "item_hlvr_grenade_frag"  , weight = 0.1  };
            { class = "item_healthvial"         , weight = 0.33 };
        });
    };

    ---@type AttacherItems
    ZOMBIE =
    {
        MIN_ITEMS = 0;
        MAX_ITEMS = 2;
        -- #ITEMS >= MAX_ITEMS
        ITEM_POOL = WeightedRandom({
            { class = "item_hlvr_clip_energygun", weight = 1    };
            { class = "item_healthvial"         , weight = 0.1875 };
        });
    };

}

-- local COMBINE_ATTACH_WEIGHTS = WeightedRandom({
--     { properties = ATTACHED_MANAGER.COMBINE[1], weight = 0.375  },
--     { properties = ATTACHED_MANAGER.COMBINE[2], weight = 0.4375 },
--     { properties = ATTACHED_MANAGER.COMBINE[3], weight = 0.125  },
--     { properties = ATTACHED_MANAGER.COMBINE[4], weight = 0.0625 },
-- })

local COMBINE =
{
    BASE =
    {
        classname = "npc_combine_s";
        squadname = "combine";
        -- make this driven by logic_script property in prefab
        min_advance_range_override = "96";
    },
    GRUNT =
    {
        model = "models/characters/combine_grunt/combine_grunt.vmdl";
        -- make this driven by logic_script property in prefab
        grenade_proclivity = "1";
    },
    GRUNT_NOTANK =
    {
        model = "models/characters/combine_grunt/combine_grunt.vmdl";
        model_state = "{\n\tmaterial_group = \"default\"\n\tconfig_state = \n\t{\n\t\tgas_tank = \"no_tank\"\n\t}\n}";
        -- make this driven by logic_script property in prefab
        grenade_proclivity = "1";
    },
    OFFICER =
    {
        model = "models/characters/combine_soldier_captain/combine_captain.vmdl";
        -- make this driven by logic_script property in prefab
        manhack_proclivity = "1";
    },
    SUPPRESSOR =
    {
        model = "models/characters/combine_suppressor/combine_suppressor.vmdl";
        sentry_position_name = "@sentry_point";
    },
    CHARGER =
    {
	    model = "models/characters/combine_soldier_heavy/combine_soldier_heavy.vmdl";
    },
}

local XEN =
{
    BASE =
    {
        squadname = "xen";
    },
    ZOMBIE =
    {
        classname = "npc_zombie";
        revivable = "1";
        -- make this driven by logic_script property in prefab
        sprint_proclivity = "3";
        -- randomize in function instead
	    bloater_position = -1;
    },
    HEADCRAB_BLACK =
    {
        classname = "npc_headcrab_black";
    },
    HEADCRAB_RUNNER =
    {
        classname = "npc_headcrab_runner";
    },
}

-- For debug purposes only, comment when shipping or disable outside tools
local DEBUG =
{
    -- [COMBINE.BASE] = "COMBINE.BASE";
    -- [] = "";
    -- [] = "";
}
for key, value in pairs(COMBINE) do
    DEBUG[value] = "COMBINE."..key
end
for key, value in pairs(XEN) do
    DEBUG[value] = "XEN."..key
end
-- End debug

---Clone a table.
---@param tbl table
---@return table
local function clone(tbl)
    -- return {table.unpack(tbl)}
    if tbl == nil then return {} end
    return vlua.tableadd({}, tbl)
end

---Needs to be named different from Spawn
---@param base table
---@param properties table
---@param attacher AttacherItems|nil
---@param spawn_target string
---@return EntityHandle
local function _Spawn(base, properties, attacher, spawn_target)
    -- print("SPAWN FUNCTION: ", base, properties, attacher)
    if base == nil or properties == nil then return nil end
    print("_Spawn", DEBUG[base], DEBUG[properties])

    local points = Entities:FindAllByName(spawn_target)
    local point = points[RandomInt(1, #points)]
    properties = vlua.tableadd(clone(properties), base)
    properties.origin = point:GetOrigin()
    properties.angles = point:GetAngles()
    properties.targetname = DoUniqueString("wave_spawned")
    -- util.PrintTable(properties)
    local ent = SpawnEntityFromTableSynchronous(properties.classname, properties)

    if attacher then
        local attach_properties = clone(ATTACHED_MANAGER.BASE)
        attach_properties.target = properties.targetname
        local encountered_grenade = false
        -- Choose random items for npc
        for i = 1, RandomInt(attacher.MIN_ITEMS, attacher.MAX_ITEMS) do
            local item = attacher.ITEM_POOL:Random()
            if item == "item_hlvr_grenade_frag" then
                encountered_grenade = true
            end
            attach_properties["item_"..i] = item
        end
        -- dont remove if grenade is present
        if encountered_grenade then
            -- should this be bool?
            attach_properties.mark_as_removable = "0"
        end
        SpawnEntityFromTableSynchronous(
            attach_properties.classname,
            attach_properties
        )
    end

    return ent
end

---Spawn a combine.
---@param properties table
---@param spawn_target string
---@param spawner EntityHandle
---@return EntityHandle
local function SpawnCombine(properties, spawn_target, spawner)
    local ent = _Spawn(
        COMBINE.BASE,
        properties,
        ATTACHED_MANAGER.COMBINE,
        spawn_target
    )
    ent:AddOutput("OnDeath", spawner:GetName(), "FireUser1")
    return ent
end
---Spawn a xen
---@param properties table
---@param spawn_target string
---@param spawner EntityHandle
---@return EntityHandle
local function SpawnXen(properties, spawn_target, spawner)
    local ent = _Spawn(
        XEN.BASE,
        properties,
        (properties == XEN.ZOMBIE) and ATTACHED_MANAGER.ZOMBIE or nil,
        spawn_target
    )
    ent:AddOutput("OnDeath", spawner:GetName(), "FireUser1")
    return ent
end
---@param spawn_target string
---@param me EntityHandle
---@return EntityHandle
local function SpawnGrunt(spawn_target, me)
    local c = COMBINE.GRUNT_NOTANK
    if RandomInt(1,6) <= 2 then c = COMBINE.GRUNT end
    return SpawnCombine(c, spawn_target, me)
end
---@param spawn_target string
---@param me EntityHandle
---@return EntityHandle
local function SpawnOfficer(spawn_target, me)
    return SpawnCombine(COMBINE.OFFICER, spawn_target, me)
end
---@param spawn_target string
---@param me EntityHandle
---@return EntityHandle
local function SpawnSuppressor(spawn_target, me)
    return SpawnCombine(COMBINE.SUPPRESSOR, spawn_target, me)
end
---@param spawn_target string
---@param me EntityHandle
---@return EntityHandle
local function SpawnCharger(spawn_target, me)
    return SpawnCombine(COMBINE.CHARGER, spawn_target, me)
end

---@param spawn_target string
---@param me EntityHandle
---@return EntityHandle
local function SpawnZombie(spawn_target, me)
    -- consider weighting chance
    XEN.ZOMBIE.bloater_position = RandomInt(-1, 4)
    -- 131588 is spawnflags with don't drop crab
    -- currently 50/50 chance
    XEN.ZOMBIE.spawnflags = ""..(516 + (RandomInt(0,1) *  131072))
    -- print("Zombie spawnflag " .. XEN.ZOMBIE.spawnflags)
    return SpawnXen(XEN.ZOMBIE, spawn_target, me)
end
---@param spawn_target string
---@param me EntityHandle
---@return EntityHandle
local function SpawnHeadcrabBlack(spawn_target, me)
    return SpawnXen(XEN.HEADCRAB_BLACK, spawn_target, me)
end
---@param spawn_target string
---@param me EntityHandle
---@return EntityHandle
local function SpawnHeadcrabRunner(spawn_target, me)
    local ent = SpawnXen(XEN.HEADCRAB_RUNNER, spawn_target, me)
    if ent ~= nil then
        ent:AddOutput("OnReviverInhabit", "@reviver_relay_inhabit", "Trigger")
        ent:AddOutput("OnReviverEscape", "@reviver_relay_escape", "Trigger")
    end
    return ent
end

local hasPrecached = false
function WavePrecache(context)
    -- Since there are 4 wave spawners this early exit will cut down on caching
    if hasPrecached then return end
    hasPrecached = true

    print("Precaching wave spawner")
    local properties
    local count = 0
    for key, value in pairs(COMBINE) do
        if key ~= "BASE" then
            properties = vlua.tableadd(clone(value), COMBINE.BASE)
            PrecacheEntityFromTable(properties.classname, properties, context)
            count = count + 1
        end
    end
    for key, value in pairs(XEN) do
        if key ~= "BASE" then
            properties = vlua.tableadd(clone(value), XEN.BASE)
            PrecacheEntityFromTable(properties.classname, properties, context)
            count = count + 1
        end
    end
    properties = vlua.tableadd(clone(XEN.ZOMBIE), XEN.BASE)
    for i = 1, 4 do
        properties.bloater_position = i
        PrecacheEntityFromTable(properties.classname, properties, context)
        count = count + 1
    end
    print("Precached "..count.." NPCs")
end

return {
    SpawnGrunt = SpawnGrunt,
    SpawnOfficer = SpawnOfficer,
    SpawnSuppressor = SpawnSuppressor,
    SpawnCharger = SpawnCharger,
    SpawnZombie = SpawnZombie,
    SpawnHeadcrabBlack = SpawnHeadcrabBlack,
    SpawnHeadcrabRunner = SpawnHeadcrabRunner,
}
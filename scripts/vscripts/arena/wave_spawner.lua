--[[
    Entity script for arena_wave.vmap
]]
local wave_spawner = require"arena.wave_spawn_core"

local name = "logic"
local prefab_name = thisEntity:GetName():sub(1, thisEntity:GetName():len() - name:len())
print("Prefab name for ["..thisEntity:GetName().."] = "..prefab_name)
local spawn_target = prefab_name .. "spawn_point"

local function SpawnGrunt()
    wave_spawner.SpawnGrunt(spawn_target, thisEntity)
end
local function SpawnOfficer()
    wave_spawner.SpawnOfficer(spawn_target, thisEntity)
end
local function SpawnSuppressor()
    wave_spawner.SpawnSuppressor(spawn_target, thisEntity)
end
local function SpawnCharger()
    wave_spawner.SpawnCharger(spawn_target, thisEntity)
end

local function SpawnZombie()
    wave_spawner.SpawnZombie(spawn_target, thisEntity)
end
local function SpawnHeadcrabBlack()
    wave_spawner.SpawnHeadcrabBlack(spawn_target, thisEntity)
end
local function SpawnHeadcrabRunner()
    wave_spawner.SpawnHeadcrabRunner(spawn_target, thisEntity)
end

function Precache(context)
    WavePrecache(context)
end

-- all OnDeath send to prefab OnNPCDeath
-- reviver OnReviverInhabit @reviver_relay_inhabit Trigger
-- reviver OnReviverEscape @reviver_relay_escape Trigger

-- Add local functions to private script scope to avoid environment pollution.
local _a,_b=1,thisEntity:GetPrivateScriptScope()while true do local _c,_d=debug.getlocal(1,_a)if _c==nil then break end;if type(_d)=='function'then _b[_c]=_d end;_a=1+_a end



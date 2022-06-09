-- Handle detours
local ENT = FindMetaTable("Entity")
GM13_ENT_Fire = GM13_ENT_Fire or ENT.Fire

-- Is ent spawned by a player

function GM13.Ent:SetSpawnedByPlayer(ent, value)
    ent:SetNWBool("gm13_spawned", true)
end

hook.Add("PlayerSpawnedProp", "gm13_spawned_by_player", function(ply, model, ent) GM13.Ent:SetSpawnedByPlayer(ent, true) end)
hook.Add("PlayerSpawnedEffect", "gm13_spawned_by_player", function(ply, model, ent) GM13.Ent:SetSpawnedByPlayer(ent, true) end)
hook.Add("PlayerSpawnedRagdoll", "gm13_spawned_by_player", function(ply, model, ent) GM13.Ent:SetSpawnedByPlayer(ent, true) end)
hook.Add("PlayerSpawnedNPC", "gm13_spawned_by_player", function(ply, ent) GM13.Ent:SetSpawnedByPlayer(ent, true) end)
hook.Add("PlayerSpawnedSENT", "gm13_spawned_by_player", function(ply, ent) GM13.Ent:SetSpawnedByPlayer(ent, true) end)
hook.Add("PlayerSpawnedSWEP", "gm13_spawned_by_player", function(ply, ent) GM13.Ent:SetSpawnedByPlayer(ent, true) end)
hook.Add("PlayerSpawnedVehicle", "gm13_spawned_by_player", function(ply, ent) GM13.Ent:SetSpawnedByPlayer(ent, true) end)

-- Damage

local function SetDamageMode(ent, mode, value, callback, args)
    if value then -- Stalker
        ent:AddEFlags(EFL_NO_DISSOLVE)
    else
        ent:RemoveEFlags(EFL_NO_DISSOLVE)
    end

    ent[mode] = value

    if callback then
        GM13.Ent:SetDamageCallback(ent, callback, args)
    end
end

function GM13.Ent:SetInvulnerable(ent, value, callback, ...)
    SetDamageMode(ent, "gm13_invulnerable", value, callback, { ... })
end

function GM13.Ent:SetReflectDamage(ent, value, callback, ...)
    SetDamageMode(ent, "gm13_damage_ricochet", value, callback, { ... })
end

function GM13.Ent:IsInvulnerable(ent)
    return ent.gm13_invulnerable
end

function GM13.Ent:IsReflectingDamage(ent)
    return ent.gm13_damage_ricochet
end

function GM13.Ent:SetDamageCallback(ent, callback, args)
    ent.gm13_damage_callback = { func = callback, args = args or {} }
end

function GM13.Ent:GetDamageCallback(ent)
    return ent.gm13_damage_callback
end

hook.Add("CanPlayerSuicide", "gm13_block_suicide", function( ply)
	return not GM13.Ent:IsInvulnerable(ply)
end)

hook.Add("EntityTakeDamage", "gm13_damage_control", function(target, dmgInfo)
    local isReflecting = GM13.Ent:IsReflectingDamage(target)
    local isInvulnerable = GM13.Ent:IsInvulnerable(target)
    local isNormal = not isReflecting and not isInvulnerable

    local callback = GM13.Ent:GetDamageCallback(target)

    if isNormal then
        if callback and isfunction(callback.func) then
            callback.func(target, dmgInfo, unpack(callback.args))
        end

        return
    end

    if isInvulnerable then
        if callback and isfunction(callback.func) then
            callback.func(target, dmgInfo, unpack(callback.args))
        end

        return true
    end

    if isReflecting then
        if callback and isfunction(callback.func) then
            callback.func(target, dmgInfo, unpack(callback.args))
        end

        local attacker = dmgInfo:GetAttacker()

        if attacker == target then -- Break the loop
            GM13.Ent:SetReflectDamage(target, false)
        end

        attacker:TakeDamageInfo(dmgInfo)

        return true
    end
end)

-- Dissolve

function GM13.Ent:Dissolve(ent, dissolveType)
    if not ent or not IsValid(ent) or not ent:IsValid() then return false end
    if not (ent:IsRagdoll() or ent:IsNPC() or ent:IsVehicle() or ent:IsWeapon() or ent:GetClass() and (
       string.find(ent:GetClass(), "prop_") or string.find(ent:GetClass(), "gm13_sent"))) then return false end

    dissolveType = dissolveType or 3

    if GM13.Ent:IsReflectingDamage(ent) then
        GM13.Ent:SetReflectDamage(ent, false)
    end

    if GM13.Ent:IsInvulnerable(ent) then
        GM13.Ent:SetInvulnerable(ent, false)
    end

    local envEntityDissolver = ents.Create("env_entity_dissolver")
    local name = tostring(ent)

    ent:SetKeyValue("targetname", name)
    envEntityDissolver:SetKeyValue("magnitude", "10")
    envEntityDissolver:SetKeyValue("target", name)
    envEntityDissolver:SetKeyValue("dissolvetype", dissolveType)
    envEntityDissolver:Fire("Dissolve")
    envEntityDissolver:Fire("kill", "", 0)

    return true
end

-- Resize
-- Thanks https://steamcommunity.com/workshop/filedetails/?id=217376234
-- In addition to porting the code compactly, I've also added a height
-- compensation so that entities don't enter the ground.
-- Note: duplicator and individual axis support were ignored.

function GM13.Ent:Resize(ent, scale)
	ent:PhysicsInit(SOLID_VPHYSICS)

	local physObj = ent:GetPhysicsObject()

	if not type(physObj) == "PhysObj" then return end

	local physMesh = physObj:GetMeshConvexes()

	if not istable(physMesh) or #physMesh < 1 then return end

    local mass = physObj:GetMass()
    local minS, maxS = ent:GetCollisionBounds()
    local boundVec = maxS - minS
    local relativeGroundPos1 = math.abs(boundVec.z / 2)

	local PhysicsData = {
		physObj:IsGravityEnabled(),
		physObj:GetMaterial(),
		physObj:IsCollisionEnabled(),
		physObj:IsDragEnabled(),
		physObj:GetVelocity(),
		physObj:GetAngleVelocity(),
		physObj:IsMotionEnabled()
    }

	for convexKey, convex in pairs(physMesh) do
		for posKey, posTab in pairs(convex) do
			convex[posKey] = posTab.pos * scale
		end
	end

	ent:PhysicsInitMultiConvex(physMesh)
	ent:EnableCustomCollisions(true)

    for i = 0, ent:GetBoneCount() do
        ent:ManipulateBoneScale(i, Vector(1, 1, 1) * scale)
    end

    ent:SetCollisionBounds(minS * scale, maxS * scale)

    physObj = ent:GetPhysicsObject()

    physObj:EnableGravity(PhysicsData[1])
    physObj:SetMaterial(PhysicsData[2])
    physObj:EnableCollisions(PhysicsData[3])
    physObj:EnableDrag(PhysicsData[4])
    physObj:SetVelocity(PhysicsData[5])
    physObj:AddAngleVelocity(PhysicsData[6] - physObj:GetAngleVelocity())
    physObj:EnableMotion(PhysicsData[7])

    physObj:SetMass(math.Clamp(mass * scale * scale * scale, 0.1, 50000))
    physObj:SetDamping(0, 0)

    minS, maxS = ent:GetCollisionBounds()
    boundVec = maxS - minS
    local relativeGroundPos2 = math.abs(boundVec.z / 2)

    ent:SetPos(ent:GetPos() + Vector(0, 0, relativeGroundPos2 - relativeGroundPos1))
end

-- Block Fire (For inputs = Map brushs only!)

function GM13.Ent:IsFireHidden(ent)
    return ent.gm13_hidden_fire
end

function GM13.Ent:HideFire(ent, value)
    if GM13.Ent:IsSpawnedByPlayer(ent) then return end

    ent.gm13_hidden_fire = value

    if value then
        ent.Fire2 = function (_self, ...)
            _self.gm13_using_fire_2 = true
            GM13_ENT_Fire(_self, ...)
        end
    else
        ent.Fire2 = nil
    end
end

ENT.Fire = function(self, ...)
    if GM13.Ent:IsFireHidden(self) then return end
    GM13_ENT_Fire(self, ...)
end

hook.Add("AcceptInput", "gm13_block_external_activations", function(ent, name, activator, caller, data)
	if GM13.Ent:IsFireHidden(ent) then
        if not ent.gm13_using_fire_2 then
    		return true
        else
            ent.gm13_using_fire_2 = false
        end
	end
end)
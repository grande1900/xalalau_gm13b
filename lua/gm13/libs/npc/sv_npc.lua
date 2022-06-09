-- Store that the entity is an npc (helps with duplication later)

hook.Add("PlayerSpawnedNPC", "gm13_set_is_npc", function(ply, npc)
    npc.gm13_is_npc = true
end)

-- Attack the closest player

local function ForceStalkerAttack(npc, ply)
    -- Note: I wasn't able to assign a squad to the existing stalker and make it attack.
    --       It was required to define a squad during the npc spawn.

    local squad = npc:GetSquad()

    local decoy = ents.Create("npc_stalker")
    decoy:Activate()
    decoy:Spawn()
    decoy:SetPos(Vector(2478.2, 3425.4, -610))

    if squad then
        decoy:SetKeyValue("squadname", squad)
    end

    local d = DamageInfo()
	d:SetDamage(decoy:Health())
	d:SetAttacker(ply)
	d:SetDamageType(DMG_DISSOLVE)

    ply:ConCommand("hud_deathnotice_time 0") -- So ugly
    timer.Simple(0.1, function()
        if not decoy:IsValid() then return end

        decoy:TakeDamageInfo(d)
        decoy:Remove()

        timer.Simple(0.5, function()
            if not ply:IsValid() then return end

            ply:ConCommand("hud_deathnotice_time 6")
        end)
    end)
end

function GM13.NPC:AttackClosestPlayer(npc, duration)
    if not npc or not npc:IsValid() or not npc:IsNPC() then return end

    local ply = GM13.Ply:GetClosestPlayer(npc:GetPos())

    if npc:GetClass() == "npc_stalker" then -- Hack to force stalkers to attack. Note: I can't stop the attack.
        ForceStalkerAttack(npc, ply)
    else
        npc:AddEntityRelationship(ply, D_HT, 99)
        npc:SetEnemy(ply)
        npc:UpdateEnemyMemory(ply, ply:GetPos())

        if duration then -- Untested
            timer.Simple(duration, function()
                if not npc:IsValid() then return end

                npc:ClearEnemyMemory()

                if ply:IsValid() then
                    npc:AddEntityRelationship(ply, D_HT, 0)
                end
            end)
        end
    end
end

-- On killed

function GM13.NPC:CallOnKilled(npc, id, callback, ...)
    if callback then
        npc.gm13_on_killed_callback = npc.gm13_on_killed_callback or {}
        npc.gm13_on_killed_callback[id] = { func = callback, args = { ... } }
    end
end

function GM13.NPC:RemoveOnNPCKilledCallback(npc, id)
    if npc.gm13_on_killed_callback then
        npc.gm13_on_killed_callback[id] = nil
    end
end

function GM13.NPC:GetOnKilledCallbacks(npc)
    return npc.gm13_on_killed_callback
end

hook.Add("OnNPCKilled", "gm13_npc_killed_callback", function(npc, attacker, inflictor)
    local callbacks = GM13.NPC:GetOnKilledCallbacks(npc)

    if callbacks then
        for id, callback in pairs(callbacks) do
            if isfunction(callback.func) then
                callback.func(unpack(callback.args))
            end
        end
    end
end)

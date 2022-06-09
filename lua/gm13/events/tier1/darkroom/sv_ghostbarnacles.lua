local eventName = "darkRoomBarnacles"

local function SpawnBarnacle(ent, pos)
    if ent:IsPlayer() and math.random(1, 100) <= 11 then
        local oldBarn = ents.FindByName("dark_barnacle")
        if oldBarn[1] then
            if oldBarn[1]:Health() >= 0 then
                return
            else
                oldBarn[1]:Remove()
            end
        end

        local barn = ents.Create("npc_barnacle")
        barn:SetName("dark_barnacle")
        barn:SetPos(pos)
        barn:SetRenderFX(kRenderFxHologram)
        barn:Spawn()
        barn:Activate()
        barn.gm13_barn = true
        timer.Simple(10, function()
            if barn:IsValid() then barn:Remove() end
        end)
    end
end

local function CreateEvent()
    util.PrecacheModel("models/barnacle.mdl")

    local trigger1 = ents.Create("gm13_trigger")
	local trigger2 = ents.Create("gm13_trigger")

    trigger1:Setup(eventName, "barn1Trigger", Vector(-5241, -2416, -142), Vector(-5241, -2475, -40))
	trigger2:Setup(eventName, "barn2Trigger", Vector(-3248, -1836, -141), Vector(-3248, -1777, -39))

	local barn1Marker = ents.Create("gm13_marker_npc")
	local barn2Marker = ents.Create("gm13_marker_npc")

    local barn1Pos = Vector(-5202, -2449, 158)
    local barn2Pos = Vector(-3291, -1806, 158)

    barn1Marker:Setup(eventName, "barn1Marker", barn1Pos, barn1Pos + Vector(-10, -10, -10))
    barn2Marker:Setup(eventName, "barn2Marker", barn2Pos, barn2Pos + Vector(-10, -10, -10))

	function trigger1:StartTouch(ent)
        SpawnBarnacle(ent, barn1Pos)
	end

	function trigger2:StartTouch(ent)
        SpawnBarnacle(ent, barn2Pos)
	end

    hook.Add("OnNPCKilled", "gm13_dark_barnacles", function(npc, attacker, inflictor)
        if npc.gm13_barn then
            timer.Simple(5, function()
                if npc:IsValid() then npc:Remove() end
            end)
        end
    end)

    return true
end

GM13.Event:SetCall(eventName, CreateEvent)

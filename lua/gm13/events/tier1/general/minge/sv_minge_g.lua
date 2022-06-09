local eventName = "generalMinge"
local mingeList = {}

local originalDecalsQuantity = GetConVar("r_decals"):GetInt()
local originalMpDecalsQuantity = GetConVar("mp_decals"):GetInt()

GM13.Event.Memory.Incompatibility:Set(eventName, "mingeSeal")

local function EnableTesting(isLocalMinge)
    if not GM13.devMode then return end

    -- Button to directly enable the lobby system
    local connect = ents.Create("gm13_func_button")
    connect:Setup(
        eventName,
        "theCabinet",
        Vector(693, -540.1, -143.9),
        Vector(715, -511.2, -73.8),
        true,
        SIMPLE_USE,
        "models/props_wasteland/controlroom_filecabinet002a.mdl",
        function()
            local delay = 0.18
            local repetitions = 10
        
            if isLocalMinge then
                GM13.Lobby:Join(delay, repetitions, nil, true)
            else
                GM13.Lobby:ForceDisconnect()
                GM13.Lobby:SelectBestServer()
            end
        end
    )
end

hook.Add("PostCleanupMap", "gm13_minge_safe_clenup_pos", function(result, invaderPos)
    if table.Count(mingeList) > 0 then
        for entIndex, minge in pairs(mingeList) do
            if minge:IsValid() then
                minge:Remove()
            end

            mingeList[entIndex] = nil
        end
    end
end)

local function PunishPlayer(ply)
	if ply:InVehicle() then
		local vehicle = ply:GetParent()
		ply:ExitVehicle()
        GM13.Ent:Dissolve(vehicle)
	end

    local ragdoll = ents.Create("prop_ragdoll")

	ragdoll:SetPos(ply:GetPos())
	ragdoll:SetAngles(ply:GetAngles())
	ragdoll:SetModel(ply:GetModel())
	ragdoll:Spawn()
	ragdoll:Activate()

    ply:SetParent(ragdoll)
	ply:Spectate(OBS_MODE_CHASE)
	ply:SpectateEntity(ragdoll)
	ply:StripWeapons()

    GM13.Map:BlockCleanup(true)
    GM13.Ent:SetInvulnerable(ply, true)
    GM13.Ent:BlockToolgun(ragdoll, true)

    local velocity = ply:GetVelocity()
    for i = 1, ragdoll:GetPhysicsObjectCount() - 1 do
        local phys = ragdoll:GetPhysicsObjectNum(i)
        phys:SetVelocity(velocity)
    end

    timer.Create(tostring(ply), 0.2, 5 * 7, function()
        if ragdoll:IsValid() then
            for i = 1, ragdoll:GetPhysicsObjectCount() - 1 do
                local phys = ragdoll:GetPhysicsObjectNum(i)
                local randomVelocity = Vector(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1)) * math.random(50, 300)
                phys:SetVelocity(randomVelocity)
            end
        end
    end)

    timer.Simple(5, function()
        GM13.Map:BlockCleanup(false)
        GM13.Ent:SetInvulnerable(ply, false)
        ply:UnSpectate()
        ply:GodDisable()
        GM13.Ent:Dissolve(ragdoll, 1)
        ply:Kill() -- yep, two bodies
    end)
end

local function SlapPlayer(ply)
    local slapSounds = {
        "physics/body/body_medium_impact_hard1.wav",
        "physics/body/body_medium_impact_hard2.wav",
        "physics/body/body_medium_impact_hard3.wav",
        "physics/body/body_medium_impact_hard5.wav",
        "physics/body/body_medium_impact_hard6.wav",
        "physics/body/body_medium_impact_soft5.wav",
        "physics/body/body_medium_impact_soft6.wav",
        "physics/body/body_medium_impact_soft7.wav"
    }

    local force = math.random(350, 600)
    local randomVelocity = Vector(math.random(force) - force/2, math.random(force) - force/2, math.random(force) - force/4)
    local randomSounds = slapSounds[math.random(#slapSounds)]
    local randomDamage = math.random(3, 10)

    ply:SetVelocity(randomVelocity)
    ply:EmitSound(randomSounds)
    ply:TakeDamage(randomDamage)
end

local function SpawnMingeBoxes(pos)
    for i = 1, math.random(8, 15) do
        local prop = ents.Create("prop_dynamic")
        prop:SetModel("models/props_junk/wood_crate001a_damaged.mdl")
        prop:SetPos(pos + Vector(math.random(0, 5), math.random(0, 5), math.random(0, 5)))
        prop:PrecacheGibs()
        prop:Spawn()

        prop:PhysicsInit(SOLID_VPHYSICS)
        prop:SetMoveType(MOVETYPE_VPHYSICS)
        prop:SetSolid(SOLID_VPHYSICS)
    
        local phys = prop:GetPhysicsObject()
    
        if phys:IsValid() then
            phys:Wake()
        end

        timer.Simple(math.random(13, 25), function()
            if prop:IsValid() then
                prop:GibBreakServer(Vector(0, 0, 0))
                prop:Remove()
            end
        end)
    end
end

local function SetPlayerPhysgunDecal()
    hook.Add("KeyPress", "gm13_ply_minge_key_pressed", function(ply, key)
        if ply:GetNWInt("gm13_lobby") == 1 and key == IN_ATTACK then
            local weapon = ply:GetActiveWeapon()

            if weapon and weapon:IsValid() and weapon:GetClass() == "weapon_physgun" then
                timer.Create("gm13_ply_physgun_minge_" .. tostring(ply), 0.02, 0, function()
                    local tr = ply:GetEyeTrace()
                    util.Decal("justamissingtexture", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
                end)
            end
        end
    end)

    hook.Add("KeyRelease", "gm13_ply_minge_key_released", function(ply, key)
        if key == IN_ATTACK then
            timer.Remove("gm13_ply_physgun_minge_" .. tostring(ply))
        end
    end)
end

local function RemovePlayerPhysgunDecal()
    hook.Remove("KeyPress", "gm13_ply_minge_key_pressed")
    hook.Remove("KeyRelease", "gm13_ply_minge_key_released")

    for k, ply in ipairs(player.GetHumans()) do
        timer.Remove("gm13_ply_physgun_minge_" .. tostring(ply))
    end

    timer.Simple(30, function()
        RunConsoleCommand("r_cleardecals")
    end)

    RunConsoleCommand("r_decals", originalDecalsQuantity)
    BroadcastLua('RunConsoleCommand("r_decals", ' .. originalDecalsQuantity .. ')')
    RunConsoleCommand("mp_decals", originalMpDecalsQuantity)
    BroadcastLua('RunConsoleCommand("mp_decals", ' .. originalMpDecalsQuantity .. ')')
end

local function FinishMinge(entIndex, status)
    local minge = mingeList[entIndex]

    if status == "defeated" then
        if minge and minge:IsValid() then
            local explosionPos = minge:GetPos() + Vector(0, 0, 35)

            timer.Simple(0.5, function()
                net.Start("gm13_create_ring_explosion")
                net.WriteVector(explosionPos)
                net.Broadcast()
            end)

            mingeList[entIndex] = nil
        end
    elseif status == "disconnected" then
        timer.Simple(0.5, function()
            if minge and minge:IsValid() then
                SpawnMingeBoxes(minge:GetPos())
            end
        end)
    end

    if minge and minge:IsValid() then
        timer.Simple(0.51, function()
            if minge and minge:IsValid() then
                minge:Remove()
            end
        end)
    end
end

local function FinishPlayer(ply, status)
    ply:SetNWInt("gm13_lobby", 2)

    if status == "defeated" then
        net.Start("gm13_hide_minges")
        net.Send(ply)

        PunishPlayer(ply)
    end
end

local function CreateEvent()
    util.PrecacheModel("models/kleiner.mdl")

    hook.Add("gm13_lobby_event_started", "gm13_start_minges", function()
        originalDecalsQuantity = GetConVar("r_decals"):GetInt()
        originalMpDecalsQuantity = GetConVar("mp_decals"):GetInt()

        if originalDecalsQuantity < 3000 then
            RunConsoleCommand("r_decals", 3000)
            BroadcastLua('RunConsoleCommand("r_decals", 3000)')
        end

        if originalMpDecalsQuantity < 3000 then
            RunConsoleCommand("mp_decals", 3000)
            BroadcastLua('RunConsoleCommand("mp_decals", 3000)')
        end

        SetPlayerPhysgunDecal()
    end)

    hook.Add("gm13_lobby_data", "gm13_minge_event", function(data, delay, max_seconds)
        local _, checkData = next(data['invaders'])
        if not data or not checkData then return end

        for entIndex, plyData in pairs(data['players']) do
            local ply = ents.GetByIndex(tonumber(entIndex))

            if ply:GetNWInt("gm13_lobby") == 1 and plyData["status"] ~= "ongoing" then
                FinishPlayer(ply, plyData["status"])
            end
        end

        for entIndex, invaderData in pairs(data['invaders']) do
            if mingeList[entIndex] and invaderData["status"] ~= "ongoing" then
                FinishMinge(entIndex, invaderData["status"])
            elseif invaderData["status"] == "ongoing" and checkData.pos then
                if not mingeList[entIndex] or not mingeList[entIndex]:IsValid() then
                    local ent = ents.Create("gm13_mingebag")
                    ent:SetTiming(delay, max_seconds)
                    ent:SetName(entIndex)
                    ent:Spawn()

                    mingeList[entIndex] = ent
                end

                mingeList[entIndex]:Control(invaderData)

                if invaderData['used_chat'] then
                    net.Start("gm13_print_cough")
                    net.Broadcast()
                end

                for k, ent in ipairs(ents.FindInSphere(invaderData['pos'], 250)) do
                    if ent:IsPlayer() and ent:GetNWInt("gm13_lobby") == 1 then
                        SlapPlayer(ent)
                    end
                end
            end
        end
    end)

    hook.Add("gm13_lobby_result", "gm13_minge_result", function(result)
        timer.Remove("gm13_minge_cough")
        RemovePlayerPhysgunDecal()

        for k, finishMinge in ipairs(ents.FindByClass("gm13_mingebag")) do
            if result == "maxtime" or result == "stopped" then
                timer.Simple(0.5, function()
                    if finishMinge and finishMinge:IsValid() then
                        SpawnMingeBoxes(finishMinge:GetPos())
                    end
                end)
            elseif result == "survived" then
                if finishMinge.weapon and finishMinge.weapon:IsValid() then
                    local weaponPos = finishMinge.weapon:GetPos()

                    timer.Simple(0.5, function()
                        net.Start("gm13_create_ring_explosion")
                        net.WriteVector(weaponPos)
                        net.Broadcast()
                    end)
                end
            end

            timer.Simple(0.51, function()
                if finishMinge and finishMinge:IsValid() then
                    finishMinge:Remove()
                end
            end)
        end

        mingeList = {}
    end)

    timer.Create("gm13_join_mingenet", ISGM13 and 180.3 or 360.3, 0, function()
        if GM13.Lobby.isEnabled then return end
        if not ISGM13 and not MINGEBAGS then return end

        if math.random(1, 100) <= (ISGM13 and MINGEBAGS and 60 or ISGM13 and 33 or MINGEBAGS and 80) then
            GM13.Lobby:SelectBestServer()
        end
    end)

    EnableTesting(false)

    return true
end

local function RemoveEvent()
    hook.Remove("gm13_lobby_data", "gm13_minge_event")
    hook.Remove("gm13_lobby_result", "gm13_minge_result")
    hook.Remove("gm13_lobby_event_started", "gm13_start_minges")

    timer.Remove("gm13_minge_cough")
    timer.Remove("gm13_join_mingenet")

    RemovePlayerPhysgunDecal()

    for entIndex, minge in pairs(mingeList) do
        if minge:IsValid() then
            minge:Remove()
        end

        mingeList[entIndex] = nil
    end
end

GM13.Event:SetCall(eventName, CreateEvent)
GM13.Event:SetDisableCall(eventName, RemoveEvent)
local eventName = "darkRoomGregori"

GM13.Event.Memory.Dependency:SetProvider(eventName, "helpMeBrother")
GM13.Event.Memory.Incompatibility:Set(eventName, "helpMeBrother", "showBigDarkRoom")

local function CreateLamp(lampMarker)
    local lamp = ents.Create("gmod_lamp")
    lamp:SetModel("models/props_wasteland/light_spotlight01_lamp.mdl")
    lamp:SetPos(lampMarker:GetPos())
    lamp:SetParent(lampMarker)
    lamp:SetSolidFlags(FSOLID_NOT_SOLID)
    lamp:SetBrightness(3)
    lamp:SetDistance(256)
    lamp:SetLightFOV(70)
    lamp:SetFlashlightTexture("effects/flashlight001")
    lamp:SetAngles(Angle(90, 0, 0))
    lamp:Spawn()
    lamp:SetOn(true)

    GM13.Ent:BlockToolgun(lamp, true)
    GM13.Ent:BlockContextMenu(lamp, true)
    GM13.Event:SetGameEntity(eventName, lamp)
    GM13.Light:SetBurnResistant(lamp, true)

    return lamp
end

local function RemovePostTransmission1Ents(monk, lamp)
    GM13.Ent:FadeOut(monk, 2, function()
        if not monk:IsValid() then return end

        monk:EmitSound("vo/ravenholm/monk_danger02.wav")
        monk:Remove()
    end)

    timer.Simple(5, function()
        if not lamp:IsValid() then return end

        lamp:Remove()
        GM13.Event.Memory:Set("helpMeBrother", true)
    end)
end

local function CreatePostTransmission1Grigory(lamp)
    local monk = ents.Create("npc_monk")
    monk:SetPos(Vector(-5221.8, -1080.8, -140))
    monk:Activate()
    monk:Spawn()
    monk:Give("weapon_annabelle")

    GM13.Ent:SetInvulnerable(monk, true)
    GM13.Ent:BlockPhysgun(monk, true)
    GM13.Ent:BlockToolgun(monk, true)
    GM13.Ent:BlockContextMenu(monk, true)

    local fastZombies = {
        { ents.Create("npc_fastzombie"), Vector(-4935.7, -1078, -140) },
        { ents.Create("npc_fastzombie"), Vector(-4988.3, -1237.3, -140) },
        { ents.Create("npc_fastzombie"), Vector(-5193.9, -1342.4, -140) }
    }

    local counter = 0
    
    for k, entTab in ipairs(fastZombies) do
        entTab[1]:SetPos(entTab[2])
        entTab[1]:Activate()
        entTab[1]:Spawn()
        entTab[1]:SetHealth(1)

        GM13.Ent:BlockPhysgun(entTab[1], true)
        GM13.Ent:BlockToolgun(entTab[1], true)
        GM13.Ent:BlockContextMenu(entTab[1], true)
        GM13.NPC:CallOnKilled(entTab[1], "sad_grigory", function()
            counter = counter + 1

            if counter == 1 then
                if not monk:IsValid() then return end

                monk:EmitSound("vo/ravenholm/monk_helpme02.wav", 90)
            end

            if counter == 3 then
                RemovePostTransmission1Ents(monk, lamp)
            end
        end)
    end 
end

local function RemovePreTransmission1Ents(lamp, lampMarker, fGregori)
    GM13.Ent:FadeOut(lamp, 1)
    GM13.Light:Blink(lamp, 1, false, nil, nil, function()
        if lamp:IsValid() then
            lamp:Remove()
        end
    end)

    if fGregori:IsValid() then
        lampMarker:EmitSound("gm13/cornergregori.wav", 80)

        fGregori:SetAngles(Angle(0, math.random(45, 135), 0))

        timer.Simple(0.2, function()
            if not fGregori:IsValid() then return end

            fGregori:SetAngles(Angle(0, math.random(180, 360), 0))

            timer.Simple(0.4, function()
                if not fGregori:IsValid() then return end

                GM13.Ent:FadeOut(fGregori, 0.49)
                fGregori:SetAngles(Angle(0, math.random(45, 135), 0))

                timer.Simple(0.6, function()
                    if not fGregori:IsValid() then return end
                    fGregori:Remove()
                end)
            end)
        end)
    end
end

local function CreatePreTransmission1Grigory(npcMarker)
    local fGregori = ents.Create("npc_monk")
    fGregori:SetPos(npcMarker:GetPos())
    fGregori:SetAngles(Angle(0, 150, 0))
    fGregori:CapabilitiesRemove(CAP_MOVE_GROUND)
    fGregori:Spawn()

    GM13.Event:SetGameEntity(eventName, fGregori)
    GM13.Ent:BlockToolgun(fGregori, true)
    GM13.Ent:BlockContextMenu(fGregori, true)
    GM13.Ent:BlockPhysgun(fGregori, true)
    GM13.Ent:SetMute(fGregori, true)
    GM13.Ent:SetReflectDamage(fGregori, true, function(target, dmgInfo)
        local attacker = dmgInfo:GetAttacker()

        if attacker ~= target and attacker:IsNPC() then
            GM13.Ent:Dissolve(attacker)
        end
    end)

    return fGregori
end

local function CreateEvent()
    util.PrecacheModel("models/monk.mdl")

    local npcMarker = ents.Create("gm13_marker_npc")
    npcMarker:Setup(eventName, "fGregori", Vector(-5221.4, -1082.3, -143.9))

    local lampMarker = ents.Create("gm13_marker")
    lampMarker:Setup(eventName, "lampMarker", Vector(-5222.3, -1082.4, 20))

    local gregoriStartTrigger1 = ents.Create("gm13_trigger")
    gregoriStartTrigger1:Setup(eventName, "gregoriStartTrigger1", Vector(-5280, -2492.6, -143.9), Vector(-5257.1, -2403, -14))

    local gregoriStartTrigger2 = ents.Create("gm13_trigger")
    gregoriStartTrigger2:Setup(eventName, "gregoriStartTrigger2", Vector(-3066.2, -1424.8, -143.9), Vector(-3076.1, -1519.9, -32.5))

    local gregoriInteractionTrigger = ents.Create("gm13_trigger")
    gregoriInteractionTrigger:Setup(eventName, "gregoriInteractionTrigger", Vector(-5247.9, -2200, 141.3), Vector(-4059.2, -1063.5, -143.9))

    local fGregori
    local lamp

    local function StartTouch(ent)
        if not ent:IsPlayer() then return end

        if (not fGregori or not fGregori:IsValid()) and math.random(1, 100) <= 10 or ent.gm13_submarine_cvar_teleport then
            lamp = CreateLamp(lampMarker)

            if ent.gm13_submarine_cvar_teleport then
                fGregori = CreatePostTransmission1Grigory(lamp)
            else
                fGregori = CreatePreTransmission1Grigory(npcMarker)
            end
        end
    end

    function gregoriStartTrigger1:StartTouch(ent)
        StartTouch(ent)
    end

    function gregoriStartTrigger2:StartTouch(ent)
        StartTouch(ent)
    end

    function gregoriInteractionTrigger:StartTouch(ent)
        if not ent:IsPlayer() or (not fGregori and not ent.gm13_submarine_cvar_teleport) then return end

        if ent.gm13_submarine_cvar_teleport then
            if lamp and lamp:IsValid() then
                lamp:Remove()
            end
            if fGregori and fGregori:IsValid() then
                fGregori:Remove()
            end

            StartTouch(ent)
        else
            RemovePreTransmission1Ents(lamp, lampMarker, fGregori)
        end
    end

    return true
end

GM13.Event:SetCall(eventName, CreateEvent)

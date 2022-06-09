local eventName = "darkRoomChair"

GM13.Event.Memory.Dependency:SetProvider(eventName, "ratmanInit", "openThePortal", "showBigDarkRoom", "startTesting")

local function StartBrokenChairStalkers(lamp, stalkerVecs)
    local stalkers = {}

    for k, stalkerVec in ipairs(stalkerVecs) do
        local stalker = ents.Create("npc_stalker")
        stalker:SetPos(stalkerVec)
        stalker:SetAngles(Angle(0, math.random(0, 360), 0))
        stalker:Activate()
        stalker:Spawn()
        stalker:SetNotSolid(true)
        GM13.Ent:SetInvulnerable(stalker, true)
        GM13.Ent:BlockPhysgun(stalker, true)
        GM13.Ent:FadeIn(stalker, 6)
        GM13.Ent:BlockToolgun(stalker, true)
        GM13.Ent:BlockContextMenu(stalker, true)
        GM13.Event:SetGameEntity(eventName, stalker)
        table.insert(stalkers, stalker)
    end

    local ratman = stalkers[math.random(1, #stalkers)]
    ratman:SetName("ratman")
    ratman:SetKeyValue("BeamPower", "2")
    ratman:SetKeyValue("squadname", "ratpeople")
    ratman:SetNotSolid(false)

    timer.Simple(30, function()
        if not ratman:IsValid() then return end

        for k, stalker in ipairs(stalkers) do
            if stalker:IsValid() then
                if stalker ~= ratman then
                    GM13.Ent:SetInvulnerable(stalker, false)
                    stalker:SetNotSolid(false)
                end

                stalker:Ignite(30)
            end
        end

        ratman:SetSaveValue("m_vecLastPosition", Vector(-3361.7, -1169.4, -143.9))
        ratman:SetSchedule(SCHED_FORCED_GO)

        timer.Simple(15, function()
            if ratman:IsValid() then
                GM13.Event:RemoveGameEntity(eventName, ratman)
                GM13.Event.Memory:Set("ratmanInit", true)
            end
        end)
    end)
end

local function FinishGladosDollChair(doll)
    local cursedPly

    for k, ply in ipairs(player.GetHumans()) do
        if ply.gm13_big_dark_confinement then
            cursedPly = ply
            break
        end
    end

    if cursedPly then
        timer.Simple(1.5, function()
            if not doll:IsValid() then return end

            local sound1 = "vo/npc/female01/heretohelp02.wav"
            local sound2 = "vo/npc/female01/gordead_ques14.wav"

            doll:EmitSound(sound1, 80)

            local duration = SoundDuration(sound1)

            timer.Simple(duration + 0.3, function()
                if not doll:IsValid() then return end

                doll:EmitSound(sound2, 80)
            end)
        end)        

        local validPlyPosEnts = {}

        for k, posEnt in ipairs(ents.FindByName("positionMesh")) do
            table.insert(validPlyPosEnts, posEnt)
        end

        local delay = 5.5
        local count = 0
        local sempers = {}

        timer.Simple(delay + 1, function()
            GM13.Event.Memory:Set("showBigDarkRoom", nil)
            GM13.Event.Memory:Set("startTesting", true)
        end)

        timer.Create("gm13_finish_01doll_chair", delay, 4, function()
            if cursedPly.gm13_big_dark_confinement then
                cursedPly.gm13_big_dark_confinement = false
                GM13.Ply:BlockNoclip(cursedPly, false)
            end

            if not cursedPly:IsValid() then
                timer.Remove("gm13_finish_01doll_chair")
                return
            end

            count = count + 1

            if count == 4 then
                for k, semper in ipairs(sempers) do
                    if semper:IsValid() then
                        semper:Remove()
                    end
                end
            else
                local plyPosEnt = validPlyPosEnts[math.random(1, #validPlyPosEnts)]

                cursedPly:SetPos(plyPosEnt:GetPos())

                local semperPos

                -- Note: for some reason ents.FindInBox didn't work here
                local fakeRandomPos = math.random(1, 5)
                local count = 0
                for k,ent in ipairs(ents.FindByName("positionMesh")) do
                    local distante = ent:GetPos():Distance(plyPosEnt:GetPos())
                    if ent ~= plyPosEnt and distante <= 1500 then
                        count = count + 1
                        if count == fakeRandomPos then
                            semperPos = ent:GetPos()
                            break
                        end
                    end
                end

                if semperPos then
                    local distanceVec = cursedPly:GetPos() - semperPos

                    local semper = ents.Create("prop_dynamic")

                    semper:SetModel("models/player.mdl")
                    semper:SetPos(semperPos)
                    semper:SetAngles(distanceVec:Angle())

                    GM13.Event:SetGameEntity(eventName, semper)

                    semper:Activate()
                    semper:Spawn()

                    table.insert(sempers, semper)
                end
            end
        end)
    end
end

local function StartGladosDollChair(doll, chair, lamp)
    local chairSit = ents.Create("gm13_trigger")
    chairSit:Setup(eventName, "chairSit", Vector(-4246.6, -1766.7, -124.3), Vector(-4261.8, -1774.1, -125))

    local bigDarkKey = ents.Create("gm13_sent_big_dark_room_key")
    bigDarkKey:Setup(eventName, doll, chair, lamp)

    GM13.Event:SetGameEntity(eventName, bigDarkKey)
    GM13.Ent:SetInvulnerable(chair, true)

    function chairSit:StartTouch(ent)
        if ent ~= doll then return end
        if not chair:IsValid() then
            GM13.Event:RemoveRenderInfoEntity(chairSit)
            chairSit:Remove()
            return
        end

        bigDarkKey:Awake()
        GM13.Event:RemoveRenderInfoEntity(chairSit)
        chairSit:Remove()
        timer.Remove("gm13_remove_middle_chair")

        local cursedPly = GM13.Ply:GetClosestPlayer(doll:GetPos())

        for k, ply in ipairs(player.GetHumans()) do
            if doll:GetPos():Distance(ply:GetPos()) <= 700 then
                ply.gm13_temp_chair_effect = true

                GM13.Ply:BlockNoclip(ply, true)
                GM13.Ent:SetInvulnerable(ply, true)
        
                ply:SetRunSpeed(200)
                ply:SetWalkSpeed(200)
                ply:SetJumpPower(20)
            end
        end

        GM13.Map:BlockCleanup(true)

        cursedPly.gm13_big_dark_confinement = true
        GM13.Event.Memory:Set("showBigDarkRoom", true)

        timer.Simple(4.5, function()
            for k, ply in ipairs(player.GetHumans()) do
                if ply.gm13_temp_chair_effect then
                    if ply ~= cursedPly then
                        GM13.Ply:BlockNoclip(ply, false)
                        GM13.Ent:SetInvulnerable(ply, false)
                    end

                    ply:SetRunSpeed(600)
                    ply:SetWalkSpeed(400)
                    ply:SetJumpPower(200)
                end
            end

            if not cursedPly:IsValid() then return bigDarkKey:Sleep() end

            if cursedPly:GetPos():Distance(Vector(-4250.85, -1771.22, -143.97)) > 900 then -- Too far from the chair confinement
                cursedPly:SetPos(Vector(-4335.5, -1764.6, -143.97))
            end

            GM13.Event.Memory:Set("openThePortal", true)

            local pitDoor = ents.FindByName("DarkRoomPit")[1]
            pitDoor:Fire2("Toggle")
        
            local pitWalls = ents.FindByName("DarkRoomPitWalls")[1]
            pitWalls:Fire2("Toggle")

            GM13.Ent:FadeOut(pitDoor, 3)

            GM13.Ent:FadeOut(pitWalls, 5, function()
                if cursedPly:IsValid() then
                    GM13.Ent:SetInvulnerable(cursedPly, false)
                end

                if not pitWalls:IsValid() then return end

                pitWalls:Fire2("Toggle")
            end)
        end)
    end
end

local function RemoveOldScene(chair, lamp)
    if lamp:IsValid() then
        lamp:Remove()
    end

    if chair:IsValid() then
        chair:Remove()
    end
end

local function StartTouch(ent, chair, lamp, stalkerVecs, chairMarker, lampMarker)
    local isGladosDoll = ent:GetName() == "GladosDoll"

    if not isGladosDoll and not ent:IsPlayer() then return chair, lamp end
    if not isGladosDoll and GM13.Event.Memory:Get("ratmanInit") then return chair, lamp end
    if not isGladosDoll and ents.FindByName("ratman")[1] then return chair, lamp end
    if isGladosDoll and GM13.Event.Memory:Get("openThePortal") then return chair, lamp end

    if chair and isGladosDoll then
        RemoveOldScene(chair, lamp)
    end

    if isGladosDoll or (not chair or not chair:IsValid()) and math.random(1, 100) <= 35 then
        lamp = ents.Create("gmod_lamp")
        lamp:SetModel("models/props_wasteland/light_spotlight01_lamp.mdl")

        lamp:SetPos(lampMarker:GetPos())
        lamp:SetSolidFlags(FSOLID_NOT_SOLID)
        lamp:SetParent(lampMarker)
        lamp:SetBrightness(3)
        lamp:SetDistance(256)
        lamp:SetLightFOV(70)
        lamp:SetFlashlightTexture("effects/flashlight001")
        lamp:SetAngles(Angle(90, 0, 0))
        lamp:Spawn()
        lamp:SetOn(true)

        GM13.Event:SetGameEntity(eventName, lamp)
        GM13.Ent:BlockContextMenu(lamp, true)
        GM13.Ent:BlockPhysgun(lamp, true)
        GM13.Light:SetBurnResistant(lamp, true)

        local ChairPosFix = not GM13.Event.Memory:Get("openThePortal") and Vector(0, 0, 0) or Vector(0, 0, 16)

        chair = ents.Create("prop_dynamic")
        chair:SetModel("models/nova/chair_wood01.mdl")
        chair:SetPos(chairMarker:GetPos() - ChairPosFix)
        chair:Activate()
        chair:SetAngles(Angle(0, 62, 0))
        chair:Spawn()

        GM13.Event:SetGameEntity(eventName, chair)
        GM13.Ent:BlockContextMenu(chair, true)
        GM13.Ent:BlockPhysgun(chair, true)

        timer.Create("gm13_remove_middle_chair", 120, 1, function()
            RemoveOldScene(chair, lamp)
        end)

        if not isGladosDoll then
            chair:SetSolidFlags(FSOLID_NOT_SOLID)

            local id = chair:StartLoopingSound("ambient/atmosphere/tone_quiet.wav")

            chair:CallOnRemove("gm13_removed_chair", function(ent)
                chair:StopLoopingSound(id)
            end)

            GM13.Prop:CallOnBreak(chair, "stalkers", function()
                if lamp:IsValid() then
                    lamp:Remove()
                end

                chair:StopLoopingSound(id)

                StartBrokenChairStalkers(lamp, stalkerVecs)
            end)
        else
            chair:PhysicsInit(SOLID_VPHYSICS)
            chair:SetMoveType(MOVETYPE_VPHYSICS)
            chair:SetSolid(SOLID_VPHYSICS)

            local phys = chair:GetPhysicsObject()
        
            if phys:IsValid() then
                phys:Wake()
            end

            StartGladosDollChair(ent, chair, lamp)

            GM13.Prop:CallOnBreak(chair, "finish_01doll", function()
                if lamp:IsValid() then
                    lamp:Remove()
                end

                FinishGladosDollChair(ent)
            end)
        end
    end

    return chair, lamp
end

local function CreateEvent()
    util.PrecacheModel("models/player.mdl")
    util.PrecacheModel("models/props_wasteland/light_spotlight01_lamp.mdl")
    util.PrecacheModel("models/nova/chair_wood01.mdl")

    if GM13.Event.Memory:Get("openThePortal") and not GM13.Event.Memory:Get("startTesting") then
        GM13.Event.Memory:Set("openThePortal", nil)
        GM13.Event.Memory:Set("showBigDarkRoom", nil)
    end

    local stalkerVecs = {
        Vector(-5050.1, -2394.4, -143.9),
        Vector(-5178.8, -1728.4, -143.9),
        Vector(-5077.4, -1147.9, -143.9),
        Vector(-4774.9, -2039.9, -143.9),
        Vector(-4608.6, -1711, -143.9),
        Vector(-4630.5, -1390, -143.9),
        Vector(-4219.6, -1328.8, -143.9),
        Vector(-4260.3, -2295.5, -143.9),
        Vector(-3894.6, -1776.3, -143.9),
        Vector(-3805.8, -1402.8, -143.9),
        Vector(-3767.5, -2178.1, -143.9),
        Vector(-3491.1, -2452.4, -143.9),
        Vector(-3439.7, -2028.8, -143.9),
        Vector(-3399.5, -1526.6, -143.9),
        Vector(-3458.3, -1129.7, -143.9)
    }

    local chair, lamp

    local chairMarker = ents.Create("gm13_marker_prop")
    chairMarker:Setup(eventName, "chairMarker", Vector(-4251, -1772.1, -143.9))

    local lampMarker = ents.Create("gm13_marker")
    lampMarker:Setup(eventName, "lampMarker", Vector(-4249.8, -1772.6, 48))

    local chairTrigger1 = ents.Create("gm13_trigger")
    chairTrigger1:Setup(eventName, "chairTrigger1", Vector(-3095.9, -1518.7, -143.9), Vector(-3086.7, -1424, -33.3))

    local chairTrigger2 = ents.Create("gm13_trigger")
    chairTrigger2:Setup(eventName, "chairTrigger2", Vector(-5312.6, -2696.7, -55.9), Vector(-5435.3, -2706.9, 71.2))

    local chairTrigger3 = ents.Create("gm13_trigger")
    chairTrigger3:Setup(eventName, "chairTrigger3", Vector(-5280.7, -2330.8, -143.9), Vector(-5471.9, -2339.2, -19.2))

    local chairVeryCloseTrigger = ents.Create("gm13_trigger")
    chairVeryCloseTrigger:Setup(eventName, "chairVeryCloseTrigger", Vector(-4152.5, -1869, -143.9), Vector(-4342.1, -1661, 159.9))

    for k, stalkerVec in ipairs(stalkerVecs) do
        local npcMarker = ents.Create("gm13_marker_npc")
        npcMarker:Setup(eventName, "darkroomStalker" .. k, stalkerVec)
    end

	function chairTrigger1:StartTouch(ent)
        chair, lamp = StartTouch(ent, chair, lamp, stalkerVecs, chairMarker, lampMarker)
	end

	function chairTrigger2:StartTouch(ent)
        chair, lamp = StartTouch(ent, chair, lamp, stalkerVecs, chairMarker, lampMarker)
	end

    function chairTrigger3:StartTouch(ent)
        chair, lamp = StartTouch(ent, chair, lamp, stalkerVecs, chairMarker, lampMarker)
	end

    -- Note: I keep this part active even in the 01doll part, because it makes the chair shake all over.
    function chairVeryCloseTrigger:StartTouch(ent)
        if not ent:IsPlayer() or not chair or not chair:IsValid() then return end

        if math.random(1, 100) <= 33 then
            local startAngle = Angle(0, 62, 0)
            local endAngle = Angle(0, 55, 0)
            local ratio = 0

            timer.Create("Turn", 0.05, 25, function()
                if not (chair and chair:IsValid()) then
                    timer.Remove("Turn")
                else
                    ratio = ratio + 0.1
                    chair:SetAngles(LerpAngle(ratio, startAngle, endAngle))
                end
            end)

            chairVeryCloseTrigger.StartTouch = nil
        end
	end

    return true
end

GM13.Event:SetCall(eventName, CreateEvent)

local eventName = "darkRoomMurderedCitizen"
local saved = false

GM13.Event.Memory.Dependency:SetProvider(eventName, "savedCitizen")
GM13.Event.Memory.Incompatibility:Set(eventName, "savedCitizen")

local function Saved()
    if next(ents.FindByClass("gm13_sent_curse_detector")) then return end

    local detector = ents.Create("gm13_sent_curse_detector")
    detector:Spawn()

    return detector
end

local function CreateMurderedCitizen()
    util.PrecacheModel("models/Humans/Group02/Female_01.mdl")

    local pathVecs = {
        Vector(-2843.1, -1472.3, -143.9),
        Vector(-2139, -952, -143),
        Vector(-3040, 132, 13),
        Vector(-3493.3, 1948.8, -107.5),
        Vector(-3995, 5219, -95),
        Vector(-4708.7, 5305, 336),
        Vector(-4706, 5363, 848),
        Vector(-4703.1, 5350, 1360),
        Vector(-4703, 5294, 1872),
        Vector(-4187, 5770, 2128),
        Vector(-4219, 4884, 2128),
        Vector(-4844, 4877, 2496),
        Vector(-4434, 4784, 2496),
        Vector(-4435, 4694, 2496),
    }

    local citizenStartPos = Vector(-3001.2, -1473.9, -143.9)

    local citizenSpawn = ents.Create("gm13_marker_npc")
    citizenSpawn:Setup(eventName, "citizen", citizenStartPos)

    local npcTrigger = ents.Create("gm13_trigger")
    local npcTrigger2 = ents.Create("gm13_trigger")

    npcTrigger:Setup(eventName, "mCitizenTrigger", Vector(-1860, -1417, 12), Vector(-2252, -1060, -143))
	npcTrigger2:Setup(eventName, "mCitizenTrigger2", Vector(113.4, -617.9, -62.3), Vector(348.8, -368.3, -148))

    local citizen
    local function startTouch(ent)
        if not ent:IsPlayer() then return end

        if (not citizen or not citizen:IsValid()) and math.random(1, 100) <= (MINGEBAGS and 85 or 17) then
            citizen = ents.Create("npc_citizen")
            citizen:SetPos(citizenStartPos)
            citizen:SetModel("models/Humans/Group02/Female_01.mdl")
            citizen.gm13_murdered_citizen = true
            citizen:SetSolid(SOLID_BSP)
            citizen:Activate()
            citizen:Spawn()

            GM13.Ent:FadeIn(citizen, 3)
            GM13.Event:SetGameEntity(eventName, citizen)
            GM13.Ent:BlockToolgun(citizen, true)
            GM13.Ent:BlockContextMenu(citizen, true)
            GM13.Ent:SetMute(citizen, true)
            GM13.Ent:BlockPhysgun(citizen, true)
            GM13.Ent:SetReflectDamage(citizen, true, function()
                if not citizen:IsValid() then return end
                GM13.Ent:SetReflectDamage(citizen, true, "")
                GM13.Ent:FadeOut(citizen, 7, function()
                    if citizen:IsValid() then
                        citizen:Remove()
                    end
                end)
            end)

            timer.Simple(0.2, function()
                if not citizen:IsValid() then return end

                citizen:SetSaveValue("m_vecLastPosition", pathVecs[1])
                citizen:SetSchedule(SCHED_FORCED_GO_RUN)
            end)
        end
    end

    function npcTrigger:StartTouch(ent)
        startTouch(ent)
    end

    function npcTrigger2:StartTouch(ent)
        startTouch(ent)
    end

    local guilty = ents.Create("gm13_npc_hydra")
	guilty:Setup(eventName, "citzenKiller", Vector(-4429.3, 4749.4, 2530.9))

    local function postionTouchCallback(ent, curVec, nextVec)
        if not ent.gm13_murdered_citizen then return end

        ent:SetSaveValue("m_vecLastPosition", nextVec)
        ent:SetSchedule(SCHED_FORCED_GO_RUN)

        local retried = 0
        timer.Create("gm13_citizen_failsafe", 13, 0, function()
            if ent and IsValid(ent) and ent:IsValid() and ent:Health() > 0 then
                if retried == 1 then
                    GM13.Ent:SetMute(ent, false)
                    ent:EmitSound("vo/trainyard/female01/cit_tvbust05.wav")
                    GM13.Ent:SetMute(ent, true)

                    GM13.Event:RemoveRenderInfoEntity(npcTrigger)
                    npcTrigger:Remove()
                    GM13.Event:RemoveRenderInfoEntity(npcTrigger2)
                    npcTrigger2:Remove()

                    timer.Simple(3, function()
                        if not ent:IsValid() then return end

                        GM13.Event.Memory:Set("savedCitizen", true)
                        GM13.Event:Remove(eventName)
                        citizenSpawn:EmitSound("gm13/oldbell.wav", 100)
                        
                        local detector = Saved()

                        GM13.Event:SetGameEntity(eventName, detector)
                        detector:SetPos(ent:GetPos() + Vector(0, 0, 25))
                    end)

                    timer.Remove("gm13_citizen_failsafe")

                    return 
                end

                retried = retried + 1
                ent:SetSaveValue("m_vecLastPosition", nextVec)
                ent:SetSchedule(SCHED_FORCED_GO_RUN)
            else
                timer.Remove("gm13_citizen_failsafe")
            end
        end)
    end

    local function lastPositionTouchCallback(ent)
        if not ent.gm13_murdered_citizen then return end

        timer.Simple(1.5, function()
            if not guilty:IsValid() or not citizen:IsValid() then return end

            GM13.Ent:SetReflectDamage(citizen, false)

            ent:TakeDamage(100, guilty)

            local witnesses = false
            local i = 3.5

            for k,v in ipairs(ents.FindInSphere(guilty:GetPos(), 500)) do
                if v:IsValid() and (v:IsNPC() or v:IsPlayer()) then
                    witnesses = true

                    timer.Simple(i, function()
                        if v:IsValid() and v:IsOnGround() then
                            v:TakeDamage(100, guilty)
                        end
                    end)

                    i = i + 0.4
                end
            end

            if witnesses then
                guilty:EmitSound("/vo/citadel/br_youneedme.wav", 75)
            end
        end)
    end

    GM13.Custom:CreatePath(pathVecs, eventName, postionTouchCallback, lastPositionTouchCallback)

    return true
end

GM13.Event:SetCall(eventName, CreateMurderedCitizen)
GM13.Event:SetFailCall(eventName, Saved)

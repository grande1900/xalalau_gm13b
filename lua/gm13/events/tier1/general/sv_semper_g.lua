local eventName = "generalSemper"
local power = {}

GM13.Event.Memory.Dependency:SetDependent(eventName, "awaken")
GM13.Event.Memory.Dependency:SetProvider(eventName, "sempersHat")

local function SetupTrigger(semperTrigger, semper)
    semperTrigger:Setup(eventName, "semperTrigger", semper:GetPos() + Vector(1000, 1000, 1000), semper:GetPos() + Vector(-1000, -1000, -50))
end

local function SetupHeadTrigger(semperHeadTrigger, semper)
    local center = semper:GetPos() + Vector(0, 0, 72)
    semperHeadTrigger:Setup(eventName, "semperHeadTrigger",center + Vector(5, 5, 5), center + Vector(-5, -5, -5))
end

-- Teleport to a new location
table.insert(power, function(semper, validVecs, semperTrigger, semperHeadTrigger)
    local newPos = validVecs[math.random(1, #validVecs)]

    if GM13.Event.Memory:Get("sempersHat") then
        local curseDetector = ents.FindByClass("gm13_sent_curse_detector")[1]

        if curseDetector then
            curseDetector:SetPos(newPos + Vector(0, 0, 72))
        end
    end

    semper:SetPos(newPos)
    semper:SetAngles(Angle(0, math.random(0, 360), 0))

    SetupTrigger(semperTrigger, semper)
    SetupHeadTrigger(semperHeadTrigger, semper)
end)

-- Stare the player
table.insert(power, function(semper, validVecs)
    local timerName = "gm13_semper_stare"

    timer.Create(timerName, 0.1, 50, function()
        if not semper:IsValid() then
            timer.Remove(timerName)
            return
        end

        local semperPos = semper:GetPos()

        local ply = GM13.Ply:GetClosestPlayer(semperPos)

        if not ply then
            timer.Remove(timerName)
            return
        end

        local distanceVec = ply:GetPos() - semperPos
        local ang = distanceVec:Angle()

        semper:SetAngles(Angle(0, ang.y, 0))
    end)
end)

local function RemoveSemper(semper, semperTrigger, semperHeadTrigger)
    if semperTrigger:IsValid() then
        GM13.Event:RemoveRenderInfoEntity(semperTrigger)
        semperTrigger:Remove()
    end

    if semperHeadTrigger:IsValid() then
        GM13.Event:RemoveRenderInfoEntity(semperHeadTrigger)
        semperHeadTrigger:Remove()
    end

    if semper:IsValid() then
        semper:Remove()

        if GM13.Event.Memory:Get("sempersHat") then
            local curseDetector = ents.FindByClass("gm13_sent_curse_detector")[1]
            if curseDetector then
                curseDetector:Remove()
            end
        end
    end
end

local function CreateEvent()
    util.PrecacheModel("models/player.mdl")

    local validVecs = table.Copy(GM13.Map:GetGroundNodesPosTab() or {})

    for k, posEnt in ipairs(ents.FindByClass("info_player_start")) do
        table.insert(validVecs, posEnt:GetPos())
    end

    if #validVecs == 0 then return end

    local semper
    local timerName = "gm13_" .. eventName .. "_auto_start"

    timer.Create(timerName, ISGM13 and 30 or 300, 0, function()
        if semper and semper:IsValid() then return end

        if not GM13.Event:IsEnabled(eventName) then
            timer.Remove(timerName)
            return
        end

        if math.random(1, ISGM13 and 100 or 120) <= (ISGM13 and 7 or 1) then
            local pos = validVecs[math.random(1, #validVecs)]
            local tr = util.QuickTrace(pos + Vector(0, 0, 100), Vector(0, 0, -5000))

            if tr and tr.HitPos then
                pos = tr.HitPos
            end

            semper = ents.Create("prop_dynamic")
            semper:SetModel("models/player.mdl")
            semper:SetPos(pos)
            semper:SetAngles(Angle(0, math.random(0, 360), 0))        
            semper:Activate()
            semper:SetName("Semper")
            semper:Spawn()

            GM13.Event:SetGameEntity(eventName, semper)

            if GM13.Event.Memory:Get("sempersHat") then
                local curseDetector = ents.Create("gm13_sent_curse_detector")
                curseDetector:Spawn()

                curseDetector:SetPos(pos + Vector(0, 0, 85.2))

                local phys = curseDetector:GetPhysicsObject()
                if phys:IsValid() then
                    phys:Sleep()
                end
            end

            local semperTrigger = ents.Create("gm13_trigger")
            SetupTrigger(semperTrigger, semper)
            semperTrigger:SetParent(semper)

            local semperHeadTrigger = ents.Create("gm13_trigger")
            SetupHeadTrigger(semperHeadTrigger, semper)
            semperHeadTrigger:SetParent(semper)

            timer.Create("gm13_semper_time", math.random(60, 180), 1, function()
                if not semper:IsValid() then return end
                RemoveSemper(semper, semperTrigger, semperHeadTrigger)
            end)

            timer.Simple(2, function()
                if not semper:IsValid() then return end

                function semperTrigger:StartTouch(ent)
                    if not ent:IsPlayer() then return end
                    if not semper:IsValid() then return end
                    if timer.Exists("gm13_semper_stare") then return end

                    if math.random(1, 100) <= 50 then
                        power[math.random(1, #power)](semper, validVecs, semperTrigger, semperHeadTrigger)
                    end
                end

                function semperHeadTrigger:StartTouch(ent)
                    if ent:GetClass() == "gm13_sent_curse_detector" then
                        GM13.Event.Memory:Set("sempersHat", true)

                        timer.Create("gm13_semper_time_with_cone", math.random(7, 14), 1, function()
                            if not semper:IsValid() then return end
                            RemoveSemper(semper, semperTrigger, semperHeadTrigger)
                        end)
                    end
                end

                function semperHeadTrigger:EndTouch(ent)
                    if ent:GetClass() == "gm13_sent_curse_detector" then
                        GM13.Event.Memory:Set("sempersHat", false)
                        timer.Remove("gm13_semper_time_with_cone")
                    end
                end
            end)
        end
    end)

    return true
end

local function RemoveEvent()
    timer.Remove("gm13_semper_time")
    timer.Remove("gm13_semper_time_with_cone")
end

GM13.Event:SetCall(eventName, CreateEvent)
GM13.Event:SetDisableCall(eventName, RemoveEvent)

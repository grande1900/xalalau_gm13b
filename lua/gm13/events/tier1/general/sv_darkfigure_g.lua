local eventName = "generalDarkFigure"

GM13.Event.Memory.Dependency:SetDependent(eventName, "awaken")

local function Move(ent, pos, moveSchedule)
    if not ent:IsValid() then return end

    ent:CapabilitiesAdd(CAP_MOVE_GROUND)

    ent:SetSaveValue("m_vecLastPosition", pos)
    ent:SetSchedule(moveSchedule or SCHED_FORCED_GO)
end

local function Flee(darkFigure, pathTab, moveSchedule)
    darkFigure.gm13_dark_figure_running = true

    timer.Simple(0.2, function()
        if not darkFigure:IsValid() then return end

        local movePos = istable(pathTab) and pathTab.finish or darkFigure:GetSaveTable()["m_vecLastPosition"] or Vector(0, 0, 0)

        Move(darkFigure, movePos, moveSchedule)
    end)

    timer.Simple(moveSchedule and 0.5 or 1.1, function()
        if not darkFigure:IsValid() then return end

        GM13.Ent:FadeOut(darkFigure, 1.2,
            function()
                if not darkFigure:IsValid() then return end
                if ISGM13 then
                    local darkFigureVeryNearTrigger = ents.FindByName("darkFigureVeryNearTrigger" .. tostring(darkFigure))[1]
                    GM13.Event:RemoveRenderInfoEntity(darkFigureVeryNearTrigger)
                end

                darkFigure:Remove()
            end
        )
    end)
end

local function CurseNPCAttacker(attacker, darkFigure, darkRoomNPCPaths)
    if not attacker:IsNPC() then return end

    attacker:AddEntityRelationship(darkFigure, D_LI, 99)
    attacker:ClearEnemyMemory(darkFigure)
    attacker:UpdateEnemyMemory(darkFigure, darkFigure:GetPos())

    attacker.gm13_cursed_by_dark_figure = true

    local nearest
    local nearestVec
    local attackerPos = attacker:GetPos()
    for k, path in pairs(darkRoomNPCPaths) do
        local distance = math.abs(attackerPos:Distance(path[1]))

        if not nearest or distance < nearest then
            nearest = distance
            nearestVec = path[1]
        end
    end

    timer.Simple(0.3, function()
        if not attacker:IsValid() then return end

        attacker:SetSaveValue("m_vecLastPosition", nearestVec)
        attacker:SetSchedule(SCHED_FORCED_GO_RUN)
    end)
end

local function CursePlayerWhoTouched(darkFigure, ply, darkRoomNPCPaths)
    if not ply:IsPlayer() then return end

    ply.gm13_cursed_by_dark_figure = true

    local nearest
    local nearestVec
    local plyPos = ply:GetPos()
    for k, path in pairs(darkRoomNPCPaths) do
        local distance = math.abs(plyPos:Distance(path[1]))

        if not nearest or distance < nearest then
            nearest = distance
            nearestVec = path[1]
        end
    end

    darkFigure:EmitSound("ambient/voices/squeal1.wav", SNDLVL_90dB)

    timer.Simple(1, function()
        if not ply:IsValid() then return end

        GM13.Ent:SetInvulnerable(ply, true)

        ply:SetPos(nearestVec)
    end)
end

local function SetupVeryNearTrigger(darkFigure, darkRoomNPCPaths)
    if not ISGM13 then return end

    local function SetVeryNearTriggerPos(darkFigureVeryNearTrigger)
        darkFigureVeryNearTrigger:Setup(eventName, "darkFigureVeryNearTrigger" .. tostring(darkFigure), darkFigure:GetPos() + Vector(20, 20, 100), darkFigure:GetPos() + Vector(-20, -20, 0))
    end

    local darkFigureVeryNearTrigger = ents.Create("gm13_trigger")
    SetVeryNearTriggerPos(darkFigureVeryNearTrigger)
    darkFigureVeryNearTrigger:SetParent(darkFigure)

    function darkFigureVeryNearTrigger:StartTouch(ent)
        CursePlayerWhoTouched(darkFigure, ent, darkRoomNPCPaths)
    end

    local timerName = "gm13_dark_figure_near_triger_pos_" .. tostring(darkFigure)
    local lastPos
    timer.Create(timerName, 0.2, 0, function()
        if not darkFigure:IsValid() or not darkFigureVeryNearTrigger:IsValid() then
            timer.Remove(timerName)
            return
        end

        if lastPos ~= darkFigure:GetPos() then
            lastPos = darkFigure:GetPos()
            SetVeryNearTriggerPos(darkFigureVeryNearTrigger)
        end
    end)
end

local function SpawnDarkNPC(startPos, pathTab, darkRoomNPCPaths)
    local darkFigure = ents.Create("npc_kleiner")
    darkFigure.gm13_dark_figure = true
    darkFigure:SetPos(startPos)
    darkFigure:SetSolid(SOLID_BSP)
    darkFigure:SetColor(color_black)
    darkFigure:Activate()
    darkFigure:Spawn()

    GM13.Event:SetGameEntity(eventName, darkFigure)
    GM13.Ent:FadeIn(darkFigure, 2)
    GM13.Ent:BlockPhysgun(darkFigure, true)
    GM13.Ent:BlockToolgun(darkFigure, true)
    GM13.Ent:BlockContextMenu(darkFigure, true)
    GM13.Ent:SetInvulnerable(darkFigure, true, function(target, dmgInfo)
        local attacker = dmgInfo:GetAttacker()

        if attacker:IsNPC() and ISGM13 then
            if math.random(1, 100) <= 25 then
                CurseNPCAttacker(attacker, darkFigure, darkRoomNPCPaths)
            end
        else
            Flee(darkFigure, pathTab, pathTab and SCHED_FORCED_GO_RUN or SCHED_RUN_RANDOM)
        end
    end)

    SetupVeryNearTrigger(darkFigure, darkRoomNPCPaths)

    darkFigure:AddCallback("PhysicsCollide", function(ent, data)
        if data.HitEntity:IsNPC() or GM13.Prop:IsSpawnedByPlayer(data.HitEntity) then
            GM13.Ent:Dissolve(data.HitEntity)
        end
    end)

    for k, ent in ipairs(ents.GetAll()) do
        if ent:IsNPC() then
            ent:AddEntityRelationship(darkFigure, D_HT, 99)
        end
    end

    return darkFigure
end

local function IsValidApparitionVec(apparitionVec)
    local isVisible = false

    for k, ply in ipairs(player.GetHumans()) do
        if ply:IsValid() and ply:VisibleVec(apparitionVec + Vector(0, 0, 20)) then
            isVisible = true
            break
        end
    end

    return not isVisible
end

local function GetValidApparitionPaths(apparitionPaths)
    local validVecs = {}

    for _, pathTab in pairs(apparitionPaths) do
        local isVisible = false

        for k, ply in ipairs(player.GetHumans()) do
            if ply:IsValid() and ply:VisibleVec(pathTab.start + Vector(0, 0, 20)) then
                isVisible = true
                break
            end
        end

        if not isVisible then
            table.insert(validVecs, pathTab)
        end
    end

    return validVecs
end

local function StartObserverEvent(darkFigure, pathTab)
    local pathEnts

    local function postionTouchCallback(ent, curVec, nextVec)
        if not ent.gm13_dark_figure then return end

        local isWaiting = curVec == pathTab.wait

        ent:CapabilitiesRemove(CAP_MOVE_GROUND)

        if isWaiting then
            local anims = {
                "startle_behind",
                "lineidle01",
                "photo_react_startle",
                "photo_react_blind"
            }
        
            local timerName = "gm13_retry_dark_figure_waiting_anim_" .. tostring(darkFigure)

            timer.Create(timerName, 5, 0, function()
                if not ent:IsValid() or ent.gm13_dark_figure_running then
                    timer.Remove(timerName)
                    return
                end

                if math.random(1, 100) <= 33 then
                    GM13.NPC:PlaySequences(ent, anims[math.random(1, #anims)])
                end
            end)
        end

        timer.Simple(isWaiting and math.random(40, 100) or 0.1, function()
            Move(ent, nextVec)
        end)
    end

    local function lastPositionTouchCallback(ent)
        if not ent.gm13_dark_figure then return end

        GM13.Ent:FadeOut(ent, 0.8, function()
            if not ent:IsValid() then return end
            local darkFigureVeryNearTrigger = ents.FindByName("darkFigureVeryNearTrigger" .. tostring(ent))[1]

            ent:Remove()
            GM13.Event:RemoveRenderInfoEntity(darkFigureVeryNearTrigger)
        end)
    end

    pathEnts = GM13.Custom:CreatePath({ pathTab.start, pathTab.wait, pathTab.finish }, eventName, postionTouchCallback, lastPositionTouchCallback)

    local name = "gm13_" .. tostring(darkFigure) .. "_auto_remove"

    timer.Create(name, 1, 0, function()
        if darkFigure:IsValid() then return end

        for k, gm13path in ipairs(pathEnts) do
            if not gm13path:IsValid() then continue end

            GM13.Event:RemoveGameEntity(eventName, gm13path)
            GM13.Event:RemoveRenderInfoEntity(gm13path)
            gm13path:Remove()
        end

        timer.Remove(name)
    end)
end

local function StartWandererEvent(darkFigure, startVec)
    timerName = "gm13_wandering_guy" .. tostring(darkFigure)
    timer.Create(timerName, 7, 0, function()
        if not darkFigure:IsValid() then
            timer.Remove(timerName)
            return
        end

        darkFigure:SetSaveValue("m_vecLastPosition", startVec)
        darkFigure:SetSchedule(SCHED_IDLE_WANDER)
    end)

    return true
end

local function CreateEvent()
    util.PrecacheModel("models/kleiner.mdl")

    local maxNPCs = ISGM13 and 3 or 1
    local darkFigures = {}
    local fadeDistance
    local pathTab

    hook.Add("OnEntityCreated", "gm13_set_dark_figure_relationship", function(ent)
        if ent:IsNPC() and next(darkFigures) then
            for darkFigure, _ in pairs(darkFigures) do
                if darkFigure and darkFigure:IsValid() then
                    ent:AddEntityRelationship(darkFigure, D_HT, 99)
                end
            end
        end
    end)

    local apparitionVecs = GM13.Map:GetGroundNodesPosTab()

    if #apparitionVecs == 0 then return end

    local darkRoomNPCPaths = {
        spawn = {
            Vector(1699.5, 838.9, -143.9),
            Vector(1696.4, 1360.8, -303.9),
            Vector(-643.6, 1381.6, -303.9),
            Vector(-4225.6, 1385.7, -303.9),
            Vector(-5373.5, 1357.4, -303.9),
            Vector(-5377.4, -230.9, -303.9),
            Vector(-5368.3, -526.2, -143.9),
            Vector(-5380.2, -2443.1, -143.9),
            Vector(-5283.1, -2448.1, -143.9),
            Vector(-5191.6, -2447, -143.9),            
            Vector(-4082.7, -2435.2, -143.9)
        },
        darkRoom = {
            Vector(-2851.8, -1471.9, -143.9),
            Vector(-3156.2, -1473.2, -143.9),
            Vector(-3171.7, -1171.4, -143.9),
            Vector(-3735.2, -1185.2, -143.9),
            Vector(-4230.3, -1664, -143.9)
        },
        buildingBTunnel = {
            Vector(-5215.1, -3505, 256),
            Vector(-5420.3, -3476.1, 250.8),
            Vector(-5384, -3183.8, 255.2),
            Vector(-5371.6, -2873.1, 56),
            Vector(-5379.7, -2466.2, -143.9),
            Vector(-5259.9, -2450.5, -143.9),
            Vector(-5116.7, -2441.3, -143.9),
            Vector(-4419.9, -1730.4, -143.9)
        },
        buildingCTunnel = {
            Vector(-4448.7, 5231.9, -95.9),
            Vector(-4696.3, 4774.3, -95.9),
            Vector(-5041, 4779.8, -303.9),
            Vector(-5396.4, 4777.4, -303.9),
            Vector(-5377.8, 1431.6, -303.9),
            Vector(-5381.7, -272.2, -303.9),
            Vector(-5372.4, -524, -143.9),
            Vector(-5375.7, -2440, -143.9),
            Vector(-5292.4, -2450.2, -143.9),
            Vector(-5195.2, -2447.7, -143.9),
            Vector(-4232.6, -2120.8, -143.9)
        }
    }

    local function postionCursedNPCsTouchCallback(ent, curVec, nextVec)
        if not ent.gm13_cursed_by_dark_figure then return end

        if ent:IsPlayer() then
            timer.Simple(0.13, function() 
                if ent:IsValid() then
                    ent:SetPos(nextVec)
                end
            end)
        else    
            Move(ent, nextVec, SCHED_FORCED_GO_RUN)
        end
    end

    local function lastPositionTouchCallback(ent, curVec, nextVec)
        if not ent.gm13_cursed_by_dark_figure then return end

        if ent:IsPlayer() then
            GM13.Ent:SetInvulnerable(ent, false)
            ent:EmitSound("ambient/voices/playground_memory.wav")
            ent:EmitSound("ambient/voices/citizen_punches2.wav")
            util.ScreenShake(ent:GetPos(), 5, 5, 10, 5000)
            ent:GodDisable()
            ent:Kill()
            ent.gm13_cursed_by_dark_figure = false
        end
    end

    if ISGM13 then
        for k, path in pairs(darkRoomNPCPaths) do
            GM13.Custom:CreatePath(path, eventName, postionCursedNPCsTouchCallback, lastPositionTouchCallback)
        end
    end

    local apparitionPaths = {
        spawn1 = {
            start = Vector(1187.6, 209, -143.9),
            wait = Vector(978.2, 112.9, -143.9),
            finish = Vector(1119.7, -23.8, -143.9)
        },
        spawn2 = {
            start = Vector(1206.8, -781, -143.9),
            wait = Vector(1069.5, -651.9, -143.9),
            finish = Vector(1057.6, -469.2, -143.9)
        },
        spawn3 = {
            start = Vector(1944.3, -671.8, -143.9),
            wait = Vector(1722.4, -698.7, -143.9),
            finish = Vector(2071.1, -896.6, -143.9)
        },
        garageBack = {
            start = Vector(-3132.3, -1092.9, 48),
            wait = Vector(-2984.3, -1004.1, 48),
            finish = Vector(-2847.3, -1068.2, 48)
        },
        garageClimbOverDarkRoomEntrace = {
            start = Vector(-2278.2, -1118.3, -143.9),
            wait = Vector(-3146.4, -1094.9, 48),
            finish = Vector(-3072, -1090, 48)
        },
        buildingALastFloor = {
            start = Vector(1041.1, -1602.7, 1136),
            wait = Vector(716.4, -1611.1, 1136),
            finish = Vector(838.2, -1727.4, 1136)
        },
        buildingAFirstFloor = {
            start = Vector(889.1, -1860.2, -143.9),
            wait = Vector(2026.2, -1189.1, -143.9),
            finish = Vector(1957.6, -706.9, -143.9)
        },
        buildingB2ndFloor = {
            start = Vector(-2607.1, -2462.5, 768),
            wait = Vector(-2588, -2255.4, 768),
            finish = Vector(-2544.7, -2366.7, 768)
        },
        buildingBBack = {
            start = Vector(-1686.5, -3390.9, 256),
            wait = Vector(-1585.3, -3342.4, 256),
            finish = Vector(-1767.4, -3348.8, 256)
        },
        buildingBTunnelsEntrace = {
            start = Vector(-5309.6, -3625, 258.1),
            wait = Vector(-5233.4, -3399.8, 256),
            finish = Vector(-5336.6, -3168.6, 256)
        },
        buildingCRoof = {
            start = Vector(-4922.4, 4711.3, 2496),
            wait = Vector(-3995.1, 4698.3, 2496),
            finish = Vector(-4040.9, 4700.2, 2496)
        },
        buildingCInterior = {
            start = Vector(-4034.1, 5556.4, -95.9),
            wait = Vector(-4036.5, 5476.2, -95.9),
            finish = Vector(-4234.1, 5341, -95.9)
        },
        buildingCClimb1 = {
            start = Vector(-4037.2, 5799.7, 80),
            wait = Vector(-4709.9, 5371.3, 592),
            finish = Vector(-4736.8, 5763.4, 592)
        },
        buildingCClimb2 = {
            start = Vector(-4914.2, 5816.3, 848),
            wait = Vector(-4219.5, 4957, 1616),
            finish = Vector(-4563.9, 4877.7, 1825.2)
        },
        buildingCGoDown = {
            start = Vector(-4851, 5773.8, 2496),
            wait = Vector(-4207.7, 4856.2, 2128),
            finish = Vector(-4198.6, 5337, 2128)
        },
        darkRoomEntrace1 = {
            start = Vector(-3182.5, -1498.1, -143.9),
            wait = Vector(-2870.6, -1471.9, -143.9),
            finish = Vector(-3030.7, -1450.3, -143.9)
        },
        darkRoomEntrace2 = {
            start = Vector(-2879.4, -1469.9, -143.9),
            wait = Vector(-1993.6, -2175.7, -143.9),
            finish = Vector(-1971.8, -2493.6, -255.9)
        },
        tunnelsNearDarkRoom = {
            start = Vector(-5378.5, -1821.8, -143.9),
            wait = Vector(-5378.5, -1811.9, -143.9),
            finish = Vector(-5282.5, -2453.2, -143.9)
        },
        tunnelsNearSpawn = {
            start = Vector(2539.5, 1380.8, -143.9),
            wait = Vector(1778.1, 740.4, -143.9),
            finish = Vector(1412.3, 1385.5, -303.9)
        },
        tunnelsNearBunker1 = {
            start = Vector(-5107.2, 1364.7, -303.9),
            wait = Vector(-2564.6, 1291.4, -303.9),
            finish = Vector(-822.6, 1313.7, -303.9)
        },
        tunnelsInBunker = {
            start = Vector(-1085.9, 1438.4, -303.9),
            wait = Vector(-2178.1, 438.3, -527.9),
            finish = Vector(-2904.1, 451.8, -303.9)
        },
        mirrorRoom = {
            start = Vector(-2603.5, -2495.1, -255.9),
            wait = Vector(-2805.1, -667.7, -511.9),
            finish = Vector(-2080.7, -133.4, -511.9)
        }
    }

    local timerName = "gm13_" .. eventName .. "_auto_start"

    timer.Create(timerName, ISGM13 and 25 or 300, 0, function()
        local countDarkFigures = 0

        for darkFigure, value in pairs(darkFigures) do
            countDarkFigures = countDarkFigures + 1

            if not darkFigure:IsValid() then
                darkFigures[darkFigure] = nil
            end
        end

        if countDarkFigures == maxNPCs then return end

        local newDarkFigure = nil

        if not GM13.Event:IsEnabled(eventName) then
            timer.Remove(timerName)
            return
        end

        if math.random(1, ISGM13 and 100 or 120) <= (ISGM13 and 4 or 1) and #apparitionVecs > 0 then
            local retry = #apparitionVecs > 30 and 30 or #apparitionVecs

            for i = 1, retry, 1 do
                local vecStart = apparitionVecs[math.random(1, #apparitionVecs)]

                if IsValidApparitionVec(vecStart) then
                    newDarkFigure = SpawnDarkNPC(vecStart + Vector(0, 0, 20), nil, darkRoomNPCPaths)
                    darkFigures[newDarkFigure] = true
                    fadeDistance = 1000

                    StartWandererEvent(newDarkFigure, vecStart)

                    break
                end
            end
        elseif ISGM13 and math.random(1, 100) <= 20 then
            local validVecs = GetValidApparitionPaths(apparitionPaths)

            if next(validVecs) then
                local retry = #validVecs
                local pathTab

                for i = 1, retry, 1 do
                    pathTab = validVecs[math.random(1, #validVecs)]

                    for darkFigure, usedPathTab in pairs(darkFigures) do
                        if usedPathTab == pathTab then
                            pathTab = nil
                        end
                    end

                    if pathTab then
                        newDarkFigure = SpawnDarkNPC(pathTab.start + Vector(0, 0, 20), pathTab, darkRoomNPCPaths)
                        darkFigures[newDarkFigure] = pathTab
                        fadeDistance = 1500

                        StartObserverEvent(newDarkFigure, pathTab)
                        break
                    end
                end
            end
        end

        if newDarkFigure and newDarkFigure:IsValid() then
            GM13.Ent:CallOnCondition(
                -- Entity responsible for this check
                newDarkFigure,
                -- Condition
                function()
                    local ply, dist = GM13.Ply:GetClosestPlayer(newDarkFigure:GetPos())
        
                    if not (ply and IsValid(ply)) then return false end
                    if dist >= fadeDistance then return false end
        
                    return true
                end,
                -- Callback
                function()
                    Flee(newDarkFigure, darkFigures[newDarkFigure], math.random(1, 100) <= 25 and SCHED_FORCED_GO_RUN)
                end
            )
        end
    end)

    return true
end

GM13.Event:SetCall(eventName, CreateEvent)

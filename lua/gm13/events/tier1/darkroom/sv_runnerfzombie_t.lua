local eventName = "darkRoomRunnerFZombie"

local function CreateFastZombie()
    util.PrecacheModel("models/zombie/fast.mdl")

    local fZombie
    local pathVecs = {
        Vector(-3170.6, -1586, -143.9),
        Vector(-3166.4, -1335, -143.9)
    }
    
    local npcMarker = ents.Create("gm13_marker_npc")
    npcMarker:Setup(eventName, "fZombie", pathVecs[1])

    local npcTrigger = ents.Create("gm13_trigger")
    npcTrigger:Setup(eventName, "fZombieTrigger", Vector(-2850.1, -1534, -25.1), Vector(-2856.4, -1410.9, -143.9))

    function npcTrigger:StartTouch(ent)
        if not ent:IsPlayer() then return end

        if (not fZombie or not fZombie:IsValid()) and math.random(1, 100) <= 7 then
            fZombie = ents.Create("npc_fastzombie")
            fZombie.gm13_fzombie = true
            fZombie:SetPos(pathVecs[1])
            fZombie:SetSolid(SOLID_BSP)
            fZombie:Activate()
            fZombie:SetRenderMode(RENDERMODE_TRANSCOLOR)
            fZombie:SetRenderFX(kRenderFxHologram)
            fZombie:Spawn()

            GM13.Event:SetGameEntity(eventName, fZombie)
            GM13.Ent:BlockPhysgun(fZombie, true)
            GM13.Ent:SetReflectDamage(fZombie, true)
            GM13.Ent:BlockToolgun(fZombie, true)
            GM13.Ent:BlockContextMenu(fZombie, true)
        end
    end

    local function postionTouchCallback(ent, curVec, nextVec)
        if not ent.gm13_fzombie then return end

        timer.Simple(0.1, function()
            if not ent:IsValid() then return end

            ent:SetSaveValue("m_vecLastPosition", nextVec)
            ent:SetSchedule(SCHED_FORCED_GO_RUN)
        end)

        timer.Simple(5, function()
            if not ent:IsValid() then return end

            GM13.Ent:Dissolve(ent)
        end)
    end

    local function lastPositionTouchCallback(ent)
        if not ent.gm13_fzombie then return end

        ent:Remove()
    end

    GM13.Custom:CreatePath(pathVecs, eventName, postionTouchCallback, lastPositionTouchCallback)

    return true
end

GM13.Event:SetCall(eventName, CreateFastZombie)

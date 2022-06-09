local eventName = "bunkerTheRealOne"

GM13.Event.Memory.Dependency:SetProvider(eventName, "realBunkerOpened")

local function SetFakeNoclip()
    local fakeBunkerNoclipVoid = ents.Create("gm13_trigger")
    fakeBunkerNoclipVoid:Setup(eventName, "fakeBunkerNoclipVoid", Vector(-911.21, 432.59, -527.97), Vector(365.13, 1260.42, -176.03))

    local lastPlysValidPos = {}

    function fakeBunkerNoclipVoid:Touch(ent)
        if ent:IsPlayer() then
            lastPlysValidPos[ent] = lastPlysValidPos[ent] or {}
            
            if ent:GetMoveType() == MOVETYPE_NOCLIP then
                lastPlysValidPos[ent] = ent:GetPos()
            elseif isvector(lastPlysValidPos[ent]) then
                ent:SetPos(lastPlysValidPos[ent])
            end
        elseif GM13.Ent:IsSpawnedByPlayer(ent) then
            ent:Remove()
        end
    end

    return fakeBunkerNoclipVoid
end

local function SetDoorBreakCallback(fakeBunkerNoclipVoid)
    local realBunkerDoor = ents.FindByName("seRcret_room_door")[1]

    realBunkerDoor:CallOnRemove("gm13_open_real_bunker_door", function()
        if realBunkerDoor:Health() > 0 then return end

        fakeBunkerNoclipVoid:Remove()
        GM13.Event.Memory:Set("realBunkerOpened", true)

        local realBunker = ents.FindByName("seRcret_room")[1]

        if not realBunker.Fire2 then return end

        realBunker:Fire2("Toggle")
    end)
end

local function InitOpenedRoom()
    timer.Create("gm13_show_real_bunker", 0.1, 100, function()
        local realBunker = ents.FindByName("seRcret_room")[1]
        local realBunkerDoor = ents.FindByName("seRcret_room_door")[1]
        
        if not realBunker.Fire2 then return end

        realBunkerDoor:Remove()
        realBunker:Fire2("Toggle")

        timer.Remove("gm13_show_real_bunker")
    end)
end

local function CreateEvent()
    if not GM13.Event.Memory:Get("realBunkerOpened") then
        local fakeBunkerNoclipVoid = SetFakeNoclip()
        SetDoorBreakCallback(fakeBunkerNoclipVoid)
    else
        InitOpenedRoom()
    end

    return true
end

GM13.Event:SetCall(eventName, CreateEvent)

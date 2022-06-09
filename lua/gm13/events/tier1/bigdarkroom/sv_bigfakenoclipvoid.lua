local eventName = "bigFakeNoclipVoid"

GM13.Event.Memory.Incompatibility:Set(eventName, "showBigDarkRoom")

local function CreateEvent()
    local voidAreas = {
        { Vector(2542.8, 4078.5, -7081.9), Vector(-11247.8, -7663.7, -3038) },
        { Vector(-827.8, 4607.5, -3038.9), Vector(-11247.8, -7663.7, -2176) },
        { Vector(-5248, -2560, -164), Vector(-3210, -990, -2160) }
    }

    for k, areaTab in ipairs(voidAreas) do
        local bigFakeNoclipVoid = ents.Create("gm13_trigger")
        bigFakeNoclipVoid:Setup(eventName, "bigFakeNoclipVoid" .. k, areaTab[1], areaTab[2])

        local lastPlysValidPos = {}

        function bigFakeNoclipVoid:Touch(ent)
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
    end

    return true
end

GM13.Event:SetCall(eventName, CreateEvent)
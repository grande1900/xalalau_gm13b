local eventName = "darkRoomTeleports"

local function CreateEvent()    
    local edge1Vecs = { Vector(-3248.1, -2559.9, -143.9), Vector(-3333.6, -2475.4, -52.3) }
    local edge2Vecs = { Vector(-5247.8, -1056, -143.9), Vector(-5184.4, -1119, -64.8) }

    local edgeDarkroom1 = ents.Create("gm13_trigger")
    edgeDarkroom1:Setup(eventName, "edgeDarkroom1", edge1Vecs[1], edge1Vecs[2])

    local edgeDarkroom2 = ents.Create("gm13_trigger")
    edgeDarkroom2:Setup(eventName, "edgeDarkroom2", edge2Vecs[1], edge2Vecs[2])

    local function edgeSwapPositions(ent, minY, maxY, ang, originVic, destinyVec)
        if not ent:IsPlayer() or not ent:IsValid() or ent.gm13_room_edge then return end

        if ang.y < minY and ang.y > maxY then
            ent.gm13_room_edge = true

            local dist = originVic - ent:GetPos()
            local newPos = dist + destinyVec
            newPos.z = ent:GetPos().z

            ent:SetPos(newPos)

            ang:RotateAroundAxis(Vector(0, 0, 1), 180)

            ent:SetAngles(ang)
            ent:SetEyeAngles(ang)

            ent:SetVelocity(ent:GetVelocity() * -2)

            timer.Simple(3, function()
                if ent:IsValid() then
                    ent.gm13_room_edge = false
                end
            end)
        end
    end

    function edgeDarkroom1:StartTouch(ent)
        edgeSwapPositions(ent, 0, -90, ent:GetAngles(), edge1Vecs[1], edge2Vecs[1])
    end

    function edgeDarkroom2:StartTouch(ent)
        edgeSwapPositions(ent, 180, 90, ent:GetAngles(), edge2Vecs[1], edge1Vecs[1])
    end

    return true
end

GM13.Event:SetCall(eventName, CreateEvent)

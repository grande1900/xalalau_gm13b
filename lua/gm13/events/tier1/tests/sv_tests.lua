do return end

local eventName = "gm13Tests"

--GM13.Event.Memory.Dependency:SetProvider(eventName, "bla1")
--GM13.Event.Memory.Incompatibility:Set(eventName, "awake")

local function CreateEvent()

    
    local duplicatorArea1 = ents.Create("gm13_trigger_persistent")
    duplicatorArea1:Setup(eventName, "duplicatorArea1", Vector(1356.33, -29.3, 219.39), Vector(1026.06, 238.37, 64.03))

    local nodrawArea1 = ents.Create("gm13_trigger_nodraw")
    nodrawArea1:Setup(eventName, "nodrawArea1", Vector(1356.33, -29.3, 219.39), Vector(1026.06, 238.37, 64.03))

    do return true end

    local confinementAuthorization = ents.Create("gm13_trigger")
    confinementAuthorization:Setup(eventName, "confinementAuthorization", Vector(1101.23, -200.31, 64.03), Vector(1026.06, -180, 219.39), "gm13_test")

    function confinementAuthorization:StartTouch(ent)
        ent.gm13_test = true
	end

    local confinementArea1 = ents.Create("gm13_trigger_ply_confinement")
    confinementArea1:Setup(eventName, "confinementArea1", Vector(1356.33, -29.3, 219.39), Vector(1026.06, 238.37, 64.03), "gm13_test")

    local confinementArea2 = ents.Create("gm13_trigger_ply_confinement")
    confinementArea2:Setup(eventName, "confinementArea2", Vector(1356.33, -29.3, 219.39), Vector(1854.87, 123.09, 64.03), "gm13_test")

    local confinementArea3 = ents.Create("gm13_trigger_ply_confinement")
    confinementArea3:Setup(eventName, "confinementArea3", Vector(1677.81, -850.97, 219.39), Vector(1356.33, -29.3, 64.03), "gm13_test")

    local confinementExit = ents.Create("gm13_trigger")
    confinementExit:Setup(eventName, "confinementExit", Vector(1677.81, -850.97, 219.39), Vector(1356.73, -811.38, 64.03), "gm13_test")

    function confinementExit:StartTouch(ent)
        ent.gm13_test = false
	end

    return true
end

-- for k, ply in ipairs(player.GetHumans()) do
--     if ply:GetPos():Distance(Vector(-4250.85, -1771.22, -143.97)) > 900 then
--         ply:SetPos(Vector(-4335.5, -1764.6, -143.97))
--     end
-- end

-- for k,ent in ipairs(ents.FindByClass("gm13_portal")) do
--     print(ent:GetPos())
--     print(ent:GetAngles())
-- end

GM13.Event:SetCall(eventName, CreateEvent)

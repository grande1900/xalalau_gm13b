local eventName = "bigPitFilter"

GM13.Event.Memory.Incompatibility:Set(eventName, "showBigDarkRoom")

local function CreateEvent()
    local pitFilter = ents.Create("gm13_trigger")
    pitFilter:Setup(eventName, "pitFilter", Vector(-5247.9, -2559.7, -2043), Vector(-3249.1, -1000, -2073))

    function pitFilter:StartTouch(ent)
        if ent:IsPlayer() then return end
        if string.find(ent:GetName(), "DarkRoom") then return end

        ent:Remove()
    end

    return true
end

GM13.Event:SetCall(eventName, CreateEvent)
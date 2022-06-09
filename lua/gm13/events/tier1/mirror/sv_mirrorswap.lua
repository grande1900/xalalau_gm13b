local eventName = "mirrorSwap"

local function CreateEvent()
    local maxAreaTriggersInfo = {
        {
            vecA = Vector(-1200.03, -2063.03, -178.63),
            vecB = Vector(-2927.23, -968.98, -399.97)
        }
    }
    
    local startTriggersInfo = {
        {
            vecA = Vector(-1200.03, -2063.03, -178.63),
            vecB = Vector(-2927.23, -968.98, -399.97),
            probability = 100
        }
    }

    local portalInfo = {
        {
            {
                pos = Vector(-2063.768555, -2062, -286.152008),
                ang = Angle(90, -90, 180),
                sizeX = 2.14,
                sizeY = 12.87,
                sizeZ = 1.1,
                noRender = true
            }
        }
    }

    GM13.Custom:CreatePortalAreas(eventName, maxAreaTriggersInfo, startTriggersInfo, portalInfo)    

    return true
end

GM13.Event:SetCall(eventName, CreateEvent)

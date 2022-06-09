local eventName = "buildingBRoofHoleSwap"

local function CreateEvent()
    local maxAreaTriggersInfo = {
        {
            vecA = Vector(-3005.58, -3007.97, 2647.62),
            vecB = Vector(-1672.03, -2479.94, 2996.78)
        }
    }

    local startTriggersInfo = {
        {
            vecA = Vector(-1675.7, -2772.61, 2976.3),
            vecB = Vector(-2215.68, -2753.9, 2848.03),
            probability = 18
        }
    }

    local portalInfo = {
        {
            {
                pos = Vector(-1831.39, -2526.79, 2814.02),
                ang = Angle(0, 180, 0),
                sizeX = 0.8,
                sizeY = 0.8,
                sizeZ = 1.1
            },
            {
                pos = Vector(-2985.03, -2950.79, 2680.57),
                ang = Angle(0, 90, 180),
                sizeX = 0.8,
                sizeY = 0.8,
                sizeZ = 1.1
            },
        }
    }

    GM13.Custom:CreatePortalAreas(eventName, maxAreaTriggersInfo, startTriggersInfo, portalInfo)

    return true
end

GM13.Event:SetCall(eventName, CreateEvent)

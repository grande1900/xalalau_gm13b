local eventName = "tunnelsSwap1"

local function CreateEvent()
    local maxAreaTriggersInfo = {
        {
            vecA = Vector(-5280.21, 1256.36, -303.97),
            vecB = Vector(2271.9, 1471.97, -176.55)
        },
        {
            vecA = Vector(2271.3, 1471.25, -303.97),
            vecB = Vector(2543.69, 1280.03, -16.2)
        }
    }

    local startTriggersInfo = {
        {
            vecA = Vector(-5278.67, 1291.79, -303.97),
            vecB = Vector(-5266.05, 1471.97, -176.87),
            probability = 18
        },
        {
            vecA = Vector(1616.12, 1279.69, -303.97),
            vecB = Vector(1775.74, 1264.36, -176.03),
            probability = 18
        }
    }

    local portalInfo = {
        {
            {
                pos = Vector(-3378.70, 1287.51, -240.57),
                ang = Angle(90, -90, 180),
                sizeX = 1.33,
                sizeY = 2,
                sizeZ = 1.1
            },
            {
                pos = Vector(2530.08, 1376.69, -79.84),
                ang = Angle(90, 0, 180),
                sizeX = 1.33,
                sizeY = 2,
                sizeZ = 1.1
            }
        }
    }

    GM13.Custom:CreatePortalAreas(eventName, maxAreaTriggersInfo, startTriggersInfo, portalInfo)

    return true
end

GM13.Event:SetCall(eventName, CreateEvent)

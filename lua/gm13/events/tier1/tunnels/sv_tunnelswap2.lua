local eventName = "tunnelsSwap2"

local function CreateEvent()
    local maxAreaTriggersInfo = {
        {
            vecA = Vector(-5471.97, 1173.45, -176.77),
            vecB = Vector(-3454.27, 1549.13, -303.97)
        },
        {
            vecA = Vector(3039.97, 1296.99, -16.2),
            vecB = Vector(2271.68, 2271.02, -303.97)
        }
    }

    local startTriggersInfo = {
        {
            vecA = Vector(-5281.73, 1513.31, -303.97),
            vecB = Vector(-5471.97, 1525.86, -176.35),
            probability = 15
        },
        {
            vecA = Vector(-5280.81, 1238.44, -303.97),
            vecB = Vector(-5471.97, 1227.25, -176.52),
            probability = 15
        },
        {
            vecA = Vector(2809.09, 2257.64, -150.69),
            vecB = Vector(2999.97, 2250.05, -17.13),
            probability = 15
        },
        {
            vecA = Vector(2289.82, 1455.81, -276.09),
            vecB = Vector(2275.47, 1296.03, -175.87),
            probability = 15
        }
    }

    local portalInfo = {
        {
            {
                pos = Vector(-3470.7495, 1376.0919, -240.5894),
                ang = Angle(90, 0, 180),
                sizeX = 1.33,
                sizeY = 2,
                sizeZ = 1.1
            },
            {
                pos = Vector(3016.4809, 1375.9347, -80.5344),
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

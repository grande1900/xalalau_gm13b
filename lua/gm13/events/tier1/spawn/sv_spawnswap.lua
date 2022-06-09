local eventName = "spawnSwap"

local function CreateEvent()
    local maxAreaTriggersInfo = {
        {
            vecA = Vector(2167.6, -1105.16, -143.97),
            vecB = Vector(1912.94, -648.83, -8.03)
        },
        {
            vecA = Vector(1947.9, -1286.92, -143.97),
            vecB = Vector(1912.41, -1160.65, -8.03)
        }
    }

    local startTriggersInfo = {
        {
            vecA = Vector(2041.43, -1104.42, -143.97),
            vecB = Vector(2167.97, -1085.51, -9.88),
            probability = 18
        }
    }

    local portalInfo = {
        {
            {
                pos = Vector(1938.64, -1224.10, -76.25),
                ang = Angle(90, 0, 180),
                sizeX = 1.42,
                sizeY = 1.34,
                sizeZ = 1.1
            },
            {
                pos = Vector(1974.22, -712.07, -76.26),
                ang = Angle(90, -180, 180),
                sizeX = 1.42,
                sizeY = 1.34,
                sizeZ = 1.1
            }
        }
    }

    GM13.Custom:CreatePortalAreas(eventName, maxAreaTriggersInfo, startTriggersInfo, portalInfo)    

    return true
end

GM13.Event:SetCall(eventName, CreateEvent)

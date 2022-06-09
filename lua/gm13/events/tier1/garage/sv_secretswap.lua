local eventName = "garageSecretSwap"

local function CreateEvent()
    local maxAreaTriggersInfo = {
        {
            vecA = Vector(-2941.48, -1012.74, 31.97),
            vecB = Vector(-2896.03, -1055.52, -14.51)
        },
        {
            vecA = Vector(-2158.75, -2368.06, 159.42),
            vecB = Vector(-2152.03, -2415.69, 113.29)
        }
    }

    local startTriggersInfo = {
        {
            vecA = Vector(-2893.24, -1023.97, -1.81),
            vecB = Vector(-2935.13, -1020.95, 31.97),
            probability = 18
        }
    }

    local portalInfo = {
        {
            {
                pos = Vector(-2920.2607, -1038.6121, 8.3779),
                ang = Angle(90, 90, 0),
                sizeX = 1.33,
                sizeY = 2,
                sizeZ = 1.1
            },
            {
                pos = Vector(-2156.9890, -2391.6606, 136.3581),
                ang = Angle(90, -180, 0),
                sizeX = 1.33,
                sizeY = 2,
                sizeZ = 1.1,
                noRender = true
            }
        }
    }

    GM13.Custom:CreatePortalAreas(eventName, maxAreaTriggersInfo, startTriggersInfo, portalInfo)

    return true
end

GM13.Event:SetCall(eventName, CreateEvent)

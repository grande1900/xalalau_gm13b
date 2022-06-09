local eventName = "buildingCSwap"

local function CreateEvent()
    local maxAreaTriggersInfo = {
        {
            vecA = Vector(-4935.15, 4812.03, 592.48),
            vecB = Vector(-4017.77, 5835.97, 1343.27)
        }
    }

    local startTriggersInfo = {
        {
            vecA = Vector(-4238.93, 5284.9, 592.03),
            vecB = Vector(-4016.03, 5248.54, 829.98),
            probability = 18
        }
    }

    local portalInfo = {
        {
            {
                pos = Vector(-4127.908203, 5387.442871, 649.233459),
                ang = Angle(90, 90, 180),
                sizeX = 1.2,
                sizeY = 2.35,
                sizeZ = 1.1,
                maxUsage = 2,
                noRender = true
            },
            {
                pos = Vector(-4127.845703, 5386.560059, 1161.220459),
                ang = Angle(90, -90, 180),
                sizeX = 1.2,
                sizeY = 2.35,
                sizeZ = 1.1,
                maxUsage = 2,
                noRender = true
            }
        }
    }

    GM13.Custom:CreatePortalAreas(eventName, maxAreaTriggersInfo, startTriggersInfo, portalInfo)    

    return true
end

GM13.Event:SetCall(eventName, CreateEvent)

local eventName = "garageShadow"
local apparitions = 0

local function CreateEvent()
    if apparitions == 2 then return end

    local shadowTop = ents.Create("gm13_marker_changed_ent")
	local shadowBottom = ents.Create("gm13_marker_changed_ent")
    local shadowTrigger = ents.Create("gm13_trigger")

    local shadowTopVecA = Vector(-2871, -1524, -143)

    shadowTrigger:Setup(eventName, "shadowTrigger", Vector(-2287, -1057, -143), Vector(-2296, -2047, -30))
    shadowTop:Setup(eventName, "shadowTop", shadowTopVecA, Vector(-2879, -1560, -91))
    shadowBottom:Setup(eventName, "shadowBottom", Vector(-2879, -1522, -139), Vector(-2747, -1565, -143))

	local shadow = ents.FindByName("evil_hello")
    local lastDist = 0

	function shadowTrigger:StartTouch(ent)
        if not ent:IsPlayer() then return end

        local alpha = -1

        if math.random(1, 100) <= 20 then
            hook.Add("Tick", "gm13_shadow_fading", function()
                if not ent or not ent:IsValid() or
                   not shadow[1] or not shadow[1]:IsValid() or
                   not shadow[2] or not shadow[2]:IsValid() then
                    hook.Remove("Tick", "gm13_shadow_fading")
                    return
                end

                local distance = ent:GetPos():Distance(shadowTopVecA)

                if alpha == -1 and distance >= 400 then return end

                -- 400 <-> 300 units
                if distance <= 300 then
                    alpha = 0
                elseif distance <= 350 then
                    alpha = (1 - (400 - distance)/100) * 255
                elseif distance < 400 then
                    alpha = (400 - distance)/100 * 255                    
                else
                    alpha = 0
                end

                shadow[1]:SetColor(Color(255, 255, 255, alpha * 1.5))
                shadow[2]:SetColor(Color(255, 255, 255, alpha * 1.5))

                if alpha == 0 then
                    apparitions = apparitions + 1
                    hook.Remove("Tick", "gm13_shadow_fading")
                end
            end)

            GM13.Event:RemoveRenderInfoEntity(shadowTrigger)
            shadowTrigger:Remove()
        end
	end

    if not shadow[1] or shadow[1].initialized then return true end

    shadow[1]:Fire("Toggle")
    shadow[2]:Fire("Toggle")

    shadow[1]:SetColor(Color(255,255,255,0))
    shadow[2]:SetColor(Color(255,255,255,0))

    shadow[1].initialized  = true

    return true
end

GM13.Event:SetCall(eventName, CreateEvent)

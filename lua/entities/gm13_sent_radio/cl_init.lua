include("shared.lua")

function ENT:Draw()
    self:DrawModel()
end

net.Receive("gm13_minge_attractor_stage", function()
    local radio = net.ReadEntity()
    local percentage = net.ReadFloat()
    local start = SysTime()
    local animationTime = 1 --s

    hook.Add("PostDrawOpaqueRenderables", "gm13_radio_attractor_stages", function()
        if not radio:IsValid() or percentage == 0 then
            hook.Remove("PostDrawOpaqueRenderables", "gm13_radio_attractor_stages")
            return
        end

        local pos = radio:GetPos()
        local ang = radio:GetAngles()
        local fixr = Angle(0,-90,90)
        pos = pos + ang:Right() * -21
        pos = pos + ang:Forward() * 8.3
        pos = pos + ang:Up() * 25
        ang:RotateAroundAxis(ang:Right(), fixr.p)
        ang:RotateAroundAxis(ang:Up(), fixr.y)
        ang:RotateAroundAxis(ang:Forward(), fixr.r)

        local progress = Lerp((SysTime() - start) / animationTime, GM13.Lobby.lastPercent * 17, percentage * 17)

        cam.Start3D2D(pos, ang, 1)
            surface.SetDrawColor(255, 165, 0, 255)
            surface.DrawRect(10, 10, progress, 3)
        cam.End3D2D()
    end)

    GM13.Lobby.lastPercent = percentage
end)

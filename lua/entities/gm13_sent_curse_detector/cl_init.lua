include("shared.lua")

local isRedBeamEnabled
local redBeamStart
local redBeamEnd

function ENT:Draw()
    self:DrawModel()
    
    isRedBeamEnabled = self:GetNWBool("gm13_enable_red_beam")

    if isRedBeamEnabled then
        redBeamStart = self:GetNWVector("gm13_draw_red_beam_start")
        redBeamEnd = self:GetNWVector("gm13_draw_red_beam_end")
    elseif redBeamStart then
        redBeamStart = nil
        redBeamEnd = nil
    end
end

hook.Add("PostDrawTranslucentRenderables", "gm13_curse_detector_red_beam", function(bDepth, bSkybox)
    if not isRedBeamEnabled or not redBeamStart then return end

    local distVec = redBeamEnd - redBeamStart
    distVec = distVec:GetNormalized() * math.random(100, 350)

    redBeamEnd = redBeamStart + distVec

    GM13.Effect:CreateBeam(redBeamStart, redBeamEnd, 2, Color(255, 0, 0))
end)

net.Receive("gm13_garageVacuum_start_particle_cl", function()
    local ent = net.ReadEntity()

    if not ent:IsValid() then return end

    local color = Color(255, 255, 255, 255)
    local vOffset = ent:GetPos()
    local numParticles = 32

	local emitter = ParticleEmitter(vOffset, true)

	for i = 0, numParticles do
		local pos = Vector(math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(-1, 1))

		local particle = emitter:Add("particles/balloon_bit", vOffset + pos * 8)

        if particle then
            local Size = math.Rand(1, 3)
            local randDarkness = math.Rand(0.8, 1.0)

            particle:SetVelocity(pos * 100)

			particle:SetLifeTime(0)
			particle:SetDieTime(10)

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)
			
			particle:SetStartSize(Size)
			particle:SetEndSize(0)

			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-2, 2))

			particle:SetAirResistance(100)
			particle:SetGravity(Vector(0, 0, -300))
			
			particle:SetColor(color.r * randDarkness, color.g * randDarkness, color.b * randDarkness)

			particle:SetCollide(true)

			particle:SetAngleVelocity(Angle(math.Rand(-160, 160), math.Rand(-160, 160), math.Rand(-160, 160)))

			particle:SetBounce(1)
			particle:SetLighting(true)
		end
	end
end)

local eventName = "garageVacuum"
local foodEvents = {}
local foodCounter = 0

table.insert(foodEvents, 6, function(blackHole)
	blackHole:EmitSound("ambient/creatures/town_moan1.wav", 130)
end)

local function GetPhysicsObject(ent)
	if ent:IsValid() and not ent:IsPlayer() and not ent:IsRagdoll() and not ent:IsVehicle() and not ent:IsNPC() then
		return ent:GetPhysicsObject()
	end
end

local function EatEnt(ent, blackHole)
	if not ent:IsValid() then return end
	if not ent.gm13_blackhole then return end

	local obj = GetPhysicsObject(ent)

	if obj and obj:IsValid() then
		obj:EnableCollisions(true)
	end

	GM13.Ent:Dissolve(ent, 1)

	foodCounter = foodCounter + 1

	if foodEvents[foodCounter] then
		foodEvents[foodCounter](blackHole)
	end
end

local function CreateEvent()
	local blackHole = ents.Create("gm13_trigger")

	blackHole:Setup(eventName, "blackHole", Vector(-3119.4, -1424.4, -143.9), Vector(-3108.8, -1519.4, -32))

	function blackHole:StartTouch(ent)
		EatEnt(ent, self)
	end

	local garageVacuum = ents.Create("gm13_trigger")
	garageVacuum:Setup(eventName, "garageVacuum", Vector(-1060.5, -1919.9, 163), Vector(-2812.9, -1058.5, -143.9))

	function garageVacuum:StartTouch(ent)
		if ent:IsPlayer() or ent:IsNPC() or ent:IsRagdoll() then return end
		if not GM13.Ent:IsSpawnedByPlayer(ent) then return end
		if ent:GetClass() and string.find(ent:GetClass(), "drone") then return end
		if ent:GetModel() == "models/props_c17/doll01.mdl" or ent:GetModel() == "models/gibs/hgibs.mdl" then return end

		if ent.gm13_eat_me then
			local obj = GetPhysicsObject(ent)

			if not obj:IsValid() or not garageVacuum:IsValid() then return end

			obj:SetMass(10)
			obj:ApplyForceCenter((garageVacuum:GetPos() - ent:GetPos()) * 100)
			obj:SetMass(100)

			return
		end

		local obj = GetPhysicsObject(ent)

		if obj and obj:IsValid() and math.random(1, 100) <= 20 then
			GM13.Ent:BlockToolgun(ent, true)
			GM13.Ent:BlockPhysgun(ent, true)
			GM13.Ent:SetInvulnerable(ent, true)

			timer.Simple(math.random(2, 5), function()
				if not ent:IsValid() then return end

				local resizingTime = 2.4

				ent.gm13_eat_me = true

				obj:SetVelocity(obj:GetVelocity() / 4)
				obj:SetAngleVelocity(obj:GetAngleVelocity() / 4)
				obj:EnableGravity(false)
				obj:EnableCollisions(false)

				ent:SetModelScale(ent:GetModelScale() * 0.25, resizingTime)

				net.Start("gm13_garageVacuum_start_particle_cl")
				net.WriteEntity(ent)
				net.Broadcast()

				for k, ply in ipairs(player.GetHumans()) do
					local trEnt = ply:GetEyeTrace().Entity

					if trEnt == ent then
						local weapon = ply:GetActiveWeapon()

						if weapon and weapon:IsValid() and weapon:GetClass() == "weapon_physgun" then
							ply:DropWeapon(weapon)
						end
					end
				end

				timer.Simple(resizingTime, function()
					if not obj:IsValid() or not garageVacuum:IsValid() or not ent:IsValid() then return end

					obj:EnableGravity(true)
					obj:SetMass(10)
					obj:ApplyForceCenter((garageVacuum:GetPos() - ent:GetPos()) * 100)
					obj:SetMass(100)

					ent:Ignite(6, 10)

					timer.Simple(5, function()
						if not ent:IsValid() then return end

						GM13.Ent:Dissolve(ent)
					end)
				end)
			end)
		end
	end

	local garageSuction = ents.Create("gm13_trigger")
	garageSuction:Setup(eventName, "garageSuction", Vector(-2082.5, -1368.5, -70.6), Vector(-1920.2, -1551.4, 14.1))

	function garageSuction:StartTouch(ent)
		if not ent.gm13_eat_me then return end

		local obj = GetPhysicsObject(ent)

		if obj and obj:IsValid() then
			obj:SetVelocity(Vector(0, 0, 0))
			obj:SetAngleVelocity(Vector(0, 0, 0))

			obj:SetMass(10)
			obj:ApplyForceCenter((Vector(-2900, -1469, -83) - ent:GetPos()) * 100)
			obj:SetMass(100)

			ent.gm13_blackhole = true

			timer.Simple(3, function()
				EatEnt(ent, blackHole)
			end)
		end
	end

	return true
end

GM13.Event:SetCall(eventName, CreateEvent)

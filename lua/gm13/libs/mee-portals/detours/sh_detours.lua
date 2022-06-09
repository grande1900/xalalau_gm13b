-- detours so stuff go through portals

-- bullet detour
hook.Add("EntityFireBullets", "gm13_portal_detour_bullet", function(entity, data)
    if not GM13.Portals or GM13.Portals.portalIndex < 1 then return end

	local tr = GM13.Portals.TraceLine({start = data.Src, endpos = data.Src + data.Dir * data.Distance, filter = entity})
	local hitPortal = tr.Entity

	if not hitPortal:IsValid() then return end

	if GM13.Ent:GetRealClass(hitPortal) == "gm13_portal" and hitPortal:GetExitPortal() and hitPortal:GetExitPortal():IsValid() then
		if (tr.HitPos - hitPortal:GetPos()):Dot(hitPortal:GetUp()) > 0 then
			local newPos, newAng = GM13.Portals.TransformPortal(hitPortal, hitPortal:GetExitPortal(), tr.HitPos, data.Dir:Angle())

			--ignoreentity doesnt seem to work for some reason
			data.IgnoreEntity = hitPortal:GetExitPortal()
			data.Src = newPos
			data.Dir = newAng:Forward()
			data.Tracer = 0

			return true
		end
	end
end)

-- effect detour (Thanks to WasabiThumb)
local oldUtilEffect = util.Effect
local function effect(name, b, c, d)
     if GM13.Portals.portalIndex > 0 and (name == "phys_freeze" or name == "phys_unfreeze") then return end
     oldUtilEffect(name, b, c, d)
end
util.Effect = effect

-- super simple traceline detour
GM13.Portals.TraceLine = GM13.Portals.TraceLine or util.TraceLine
local function editedTraceLine(data)
	local tr = GM13.Portals.TraceLine(data)

	if tr.Entity:IsValid() and
	   GM13.Ent:GetRealClass(tr.Entity) == "gm13_portal" and
	   tr.Entity:GetExitPortal() and
	   tr.Entity:GetExitPortal():IsValid() and
	   tr.Entity ~= tr.Entity:GetExitPortal()
	   	then

		local hitPortal = tr.Entity

		if tr.HitNormal:Dot(hitPortal:GetUp()) > 0 then
			local editeddata = table.Copy(data)

			editeddata.start = GM13.Portals.TransformPortal(hitPortal, hitPortal:GetExitPortal(), tr.HitPos)
			editeddata.endpos = GM13.Portals.TransformPortal(hitPortal, hitPortal:GetExitPortal(), data.endpos)
			-- filter the exit portal from being hit by the ray

			if IsEntity(data.filter) and data.filter:GetClass() ~= "player" then
				editeddata.filter = {data.filter, hitPortal:GetExitPortal()}
			else
				if istable(editeddata.filter) then
					table.insert(editeddata.filter, hitPortal:GetExitPortal())
				else
					editeddata.filter = hitPortal:GetExitPortal()
				end
			end

			return GM13.Portals.TraceLine(editeddata)
		end
	end

	return tr
end

-- use original traceline if there are no portals
timer.Create("gm13_portals_traceline", 1, 0, function()
	if GM13.Portals.portalIndex > 0 then
		util.TraceLine = editedTraceLine
	else
		util.TraceLine = GM13.Portals.TraceLine	-- THE ORIGINAL TRACELINE
	end
end)
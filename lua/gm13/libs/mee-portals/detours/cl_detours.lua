-- detours so stuff go through portals

-- sound detour
hook.Add("EntityEmitSound", "gm13_portals_detour_sound", function(t)
    if not GM13.Portals or GM13.Portals.portalIndex < 1 then return end

	for k, v in ipairs(ents.FindByClass("gm13_portal")) do
        if v.GetExitPortal and
		   v:GetExitPortal() and
		   v:GetExitPortal():IsValid() and
           t.Pos and
		   t.Entity and
		   t.Entity:IsValid()
			then

			if t.Pos:DistToSqr(v:GetPos()) < 50000 * v:GetExitPortal():GetExitSize()[1] and (t.Pos - v:GetPos()):Dot(v:GetUp()) > 0 then
				local newPos, _ = GM13.Portals.TransformPortal(v, v:GetExitPortal(), t.Pos, Angle())
				local oldPos = t.Entity:GetPos() or Vector()

				t.Entity:SetPos(newPos)
				EmitSound(t.SoundName, newPos, t.Entity:EntIndex(), t.Channel, t.Volume, t.SoundLevel, t.Flags, t.Pitch, t.DSP)
				t.Entity:SetPos(oldPos)
			end
		end
	end
end)

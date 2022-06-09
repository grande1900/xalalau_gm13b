include("shared.lua")

-- create global table
GM13.Portals.VarDrawDistance = 3500

-- only render the portals that are in the frustum, or should be rendered
GM13.Portals.ShouldRender = function(portal, eyePos, eyeAngle)
	local varDrawDistance = isnumber(GM13.Portals.VarDrawDistance) and GM13.Portals.VarDrawDistance or GM13.Portals.VarDrawDistance:GetFloat() -- Xala

	local portalPos, portalUp, exitSize = portal:GetPos(), portal:GetUp(), portal:GetExitSize()
	local infrontPortal = (eyePos - portalPos):Dot(portalUp) > (-10 * exitSize[1]) -- true if behind the portal, false otherwise
	local distPortal = eyePos:DistToSqr(portalPos) < varDrawDistance ^ 2 * exitSize[1] -- true if close enough
	local portalLooking = (eyePos - portalPos):Dot(eyeAngle:Forward()) < 50 * exitSize[1] -- true if looking at the portal, false otherwise

	return infrontPortal and distPortal and portalLooking
end

local function startUpdateMesh(ent)
    if ent.UpdatePhysmesh then
        ent:UpdatePhysmesh()
    else
        -- takes a minute to try and find the portal, if it cant, oh well...
        timer.Create("gm13_portal_init" .. GM13.Portals.portalIndex, 1, 60, function()
            if not ent or not ent:IsValid() or not ent.UpdatePhysmesh then return end

            ent:UpdatePhysmesh()
            timer.Remove("gm13_portal_init" .. GM13.Portals.portalIndex)
        end)
    end
end

function ENT:Initialize()
	self:IncrementPortal()
	startUpdateMesh(self)
end

-- set physmesh pos
function ENT:Think()
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:EnableMotion(false)
        phys:SetMaterial("glass")
        phys:SetPos(self:GetPos())
        phys:SetAngles(self:GetAngles())
    end
end

hook.Add("InitPostEntity", "gm13_portal_init", function()
    for k, v in ipairs(ents.FindByClass("gm13_portal")) do
		self:IncrementPortal()
		startUpdateMesh(v)
    end

    -- this code creates the rendertargets to be used for the portals
    GM13.Portals.PortalRTs = {}
    GM13.Portals.PortalMaterials = {}
	GM13.Portals.PixelVis = {}

    for i = 1, GM13.Portals.MaxRTs do
        GM13.Portals.PortalRTs[i] = GetRenderTarget("GM13SeamlessPortal" .. i, ScrW(), ScrH())
        GM13.Portals.PortalMaterials[i] = CreateMaterial("GM13.PortalsMaterial" .. i, "GMODScreenspace", {
            ["$basetexture"] = GM13.Portals.PortalRTs[i]:GetName(),
            ["$model"] = "1"
        })
		GM13.Portals.PixelVis[i] = util.GetPixelVisibleHandle()
    end
end)

local function DrawQuadEasier(e, multiplier, offset, rotate)
	local ex, ey, ez = e:GetForward(), e:GetRight(), e:GetUp()
	local rotate = rotate
	local mx = ey * multiplier.x
	local my = ex * multiplier.y
	local mz = ez * multiplier.z
	local ox = ey * offset.x -- currently zero
	local oy = ex * offset.y -- currently zero
	local oz = ez * offset.z

	local pos = e:GetPos() + ox + oy + oz
	if rotate == 0 then
		render.DrawQuad(
			pos + mx - my + mz,
			pos - mx - my + mz,
			pos - mx + my + mz,
			pos + mx + my + mz
		)
	elseif rotate == 1 then
		render.DrawQuad(
			pos + mx + my - mz,
			pos - mx + my - mz,
			pos - mx + my + mz,
			pos + mx + my + mz
		)
	elseif rotate == 2 then
		render.DrawQuad(
			pos + mx - my + mz,
			pos + mx - my - mz,
			pos + mx + my - mz,
			pos + mx + my + mz
		)
	else
		print("GM13 Portal: Failed processing rotation:", tostring(rotate))
	end
end

local drawMat1 = Material("models/props_combine/combine_interface_disp")
local drawMat2 = Material("null")
function ENT:Draw()
	if self:GetNWBool("BlockRendering", false) then return end

	local backAmt = 3 * self:GetExitSize()[3]
	local backVec = Vector(0, 0, -backAmt + 0.5)
	local scalex = (self:OBBMaxs().x - self:OBBMins().x) * 0.5 - 0.1
	local scaley = (self:OBBMaxs().y - self:OBBMins().y) * 0.5 - 0.1

	local exitInvalid = not self:GetExitPortal() or not self:GetExitPortal():IsValid()

	if exitInvalid then
		render.SetMaterial(drawMat1)
	else
		render.SetMaterial(drawMat2)
	end

	-- holy shit lol this if statment
	if GM13.Portals.Rendering or exitInvalid or halo.RenderedEntity() == self or not GM13.Portals.ShouldRender(self, EyePos(), EyeAngles()) then
		if not self:GetDisableBackface() then
			render.DrawBox(self:GetPos(), self:LocalToWorldAngles(Angle(0, 90, 0)), Vector(-scaley, -scalex, -backAmt * 2 + 0.5), Vector(scaley, scalex, 0.5))
		end

		return
	end

	-- outer quads
	if not self:GetDisableBackface() then
		DrawQuadEasier(self, Vector( scaley, -scalex, -backAmt), backVec, 0)
		DrawQuadEasier(self, Vector( scaley, -scalex,  backAmt), backVec, 1)
		DrawQuadEasier(self, Vector( scaley,  scalex, -backAmt), backVec, 1)
		DrawQuadEasier(self, Vector( scaley, -scalex,  backAmt), backVec, 2)
		DrawQuadEasier(self, Vector(-scaley, -scalex, -backAmt), backVec, 2)
	end

	-- do cursed stencil stuff
	render.ClearStencil()
	render.SetStencilEnable(true)
	render.SetStencilWriteMask(1)
	render.SetStencilTestMask(1)
	render.SetStencilReferenceValue(1)
	render.SetStencilFailOperation(STENCIL_KEEP)
	render.SetStencilZFailOperation(STENCIL_KEEP)
	render.SetStencilPassOperation(STENCIL_REPLACE)
	render.SetStencilCompareFunction(STENCIL_ALWAYS)

	-- draw the quad that the 2d texture will be drawn on
	-- teleporting causes flashing if the quad is drawn right next to the player, so we offset it
	DrawQuadEasier(self, Vector( scaley,  scalex, -backAmt), backVec, 0)
	DrawQuadEasier(self, Vector( scaley,  scalex,  backAmt), backVec, 1)
	DrawQuadEasier(self, Vector( scaley, -scalex, -backAmt), backVec, 1)
	DrawQuadEasier(self, Vector( scaley,  scalex,  backAmt), backVec, 2)
	DrawQuadEasier(self, Vector(-scaley,  scalex, -backAmt), backVec, 2)

	-- draw the actual portal texture
	local portalmat = GM13.Portals.PortalMaterials
	render.SetMaterial(portalmat[self.PORTAL_RT_NUMBER or 1])
	render.SetStencilCompareFunction(STENCIL_EQUAL)

	-- draw quad reversed if the portal is linked to itself
	if self.GetExitPortal and self:GetExitPortal() == self then
		render.DrawScreenQuadEx(ScrW(), 0, -ScrW(), ScrH())
	else
		render.DrawScreenQuadEx(0, 0, ScrW(), ScrH())
	end

	render.SetStencilEnable(false)
end

--funny flipped scene
local mirrorDimensionState = false
local rendering = false
local cursedRT = GetRenderTarget("GM13_Portal_Flipscene", ScrW(), ScrH())
local cursedMat = CreateMaterial("GM13_Portal_Flipscene", "GMODScreenspace", {
	["$basetexture"] = cursedRT:GetName(),
})

function GM13.Portals.ToggleMirror(enable)
	if enable == nil then
		enable = not mirrorDimensionState
	end

	mirrorDimensionState = enable

	if enable then
		hook.Add("PreRender", "gm13_portal_flip_scene", function()
			rendering = true
			render.PushRenderTarget(cursedRT)
			render.RenderView({drawviewmodel = false})
			render.PopRenderTarget()
			rendering = false
		end)

		hook.Add("PostDrawTranslucentRenderables", "gm13_portal_flip_scene", function(_, sky, sky3d)
			if rendering or GM13.Portals.Rendering then return end
			render.SetMaterial(cursedMat)
			render.DrawScreenQuadEx(ScrW(), 0, -ScrW(), ScrH())

			if LocalPlayer():Health() <= 0 then
				GM13.Portals.ToggleMirror(false)
			end
		end)

		-- invert mouse x
		hook.Add("InputMouseApply", "gm13_portal_flip_scene", function(cmd, x, y, ang)
			if LocalPlayer():WaterLevel() < 3 then
				cmd:SetViewAngles(ang + Angle(0, x / 22.5, 0))
			end
		end)

		-- invert movement x
		hook.Add("CreateMove", "gm13_portal_flip_scene", function(cmd)
			if LocalPlayer():WaterLevel() < 3 then
				cmd:SetSideMove(-cmd:GetSideMove())
			end
		end)
	else
		hook.Remove("PreRender", "gm13_portal_flip_scene")
		hook.Remove("PostDrawTranslucentRenderables", "gm13_portal_flip_scene")
		hook.Remove("InputMouseApply", "gm13_portal_flip_scene")
		hook.Remove("CreateMove", "gm13_portal_flip_scene")
	end
end

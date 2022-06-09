-- this is the code that teleports entities like props
-- it only works for things with physics since I dont want to add support to other wacked entities that dont have physics

local allEnts
timer.Create("gm13_portals_ent_update", 0.5, 0, function()
    local portals = ents.FindByClass("gm13_portal")
    allEnts = ents.GetAll()

    for i = #allEnts, 1, -1 do 
        local prop = allEnts[i]
        local removeEnt = false

        if not prop:IsValid() or
           not prop:GetPhysicsObject():IsValid() or
           prop:GetVelocity() == Vector(0, 0, 0) or 
           prop:IsPlayer() or
           GM13.Ent:GetRealClass(prop) == "gm13_portal"
            then

            table.remove(allEnts, i)
        else
            local realPos = prop:LocalToWorld(prop:OBBCenter())
            local closestPortalDist = 0
            local closestPortal = nil

            for k, portal in ipairs(portals) do
                if portal:IsValid() then
                    local dist = realPos:DistToSqr(portal:GetPos())

                    if (dist < closestPortalDist or k == 1) and portal:GetExitPortal() and portal:GetExitPortal():IsValid() then
                        closestPortalDist = dist
                        closestPortal = portal
                    end
                end
            end

            if not closestPortal or
               closestPortalDist > 1000000 * closestPortal:GetExitSize()[3] or --over 100 units away from the portal, dont bother checking
               (closestPortal:GetPos() - realPos):Dot(closestPortal:GetUp()) > 0 --behind the portal, dont bother checking
                then

                table.remove(allEnts, i)
            end
        end
    end
end)

local function seamless_check(e)
    return GM13.Ent:GetRealClass(e) == "gm13_portal" -- for traces
end

hook.Add("Tick", "gm13_portal_teleport", function()
    if not GM13.Portals or GM13.Portals.portalIndex < 1 or not allEnts then return end

    for k, prop in ipairs(allEnts) do
        if not prop:IsValid() then continue end
        if prop:IsPlayerHolding() then continue end

        local realPos = prop:GetPos()

        -- can it go through the portal?
        local obbMin = prop:OBBMins()
        local obbMax = prop:OBBMaxs()
        local tr = util.TraceHull({
            start = realPos - prop:GetVelocity() * 0.02,
            endpos = realPos + prop:GetVelocity() * 0.02,
            mins = obbMin,
            maxs = obbMax,
            filter = seamless_check,
            ignoreworld = true,
        })

        --debugoverlay.Box(realPos, obbMin, obbMax, 0.1, Color(0, 0, 0, 128))

        if not tr.Hit then continue end

        local hitPortal = tr.Entity

        if GM13.Ent:GetRealClass(hitPortal) ~= "gm13_portal" then return end

        local hitPortalExit = tr.Entity:GetExitPortal()
        if hitPortalExit and hitPortalExit:IsValid() and obbMax[1] < hitPortal:GetExitSize()[1] * 45 and obbMax[2] < hitPortal:GetExitSize()[2] * 45 and prop:GetVelocity():Dot(hitPortal:GetUp()) < -0.5 then
            local constrained = constraint.GetAllConstrainedEntities(prop)
            for k, constrainedProp in pairs(constrained) do
                local editedPos, editedPropAng = GM13.Portals.TransformPortal(hitPortal, hitPortalExit, constrainedProp:GetPos(), constrainedProp:GetAngles())
                local _, editedVel = GM13.Portals.TransformPortal(hitPortal, hitPortalExit, nil, constrainedProp:GetVelocity():Angle())
                local max = math.Max(constrainedProp:GetVelocity():Length(), hitPortalExit:GetUp():Dot(-physenv.GetGravity() / 3))

                constrainedProp:ForcePlayerDrop()
                if constrainedProp:GetPhysicsObject():IsValid() then 
                    constrainedProp:GetPhysicsObject():SetVelocity(editedVel:Forward() * max) 
                end
                constrainedProp:SetAngles(editedPropAng)
                constrainedProp:SetPos(editedPos)
            end
        end
    end
end)

-- Petrification Beam SWEP
-- https://steamcommunity.com/sharedfiles/filedetails/?id=2482196918
function GM13.Addon:WeakenPetrificationBeam(ply, weapon)
    if not (weapon:GetClass() == "weapon_petrificationbeam_ammo" or weapon:GetClass() == "weapon_petrificationbeam") then return end
    
    _think = weapon.Think

    weapon.Think = function(self)
        if self.Weapon and self.Weapon:GetNextPrimaryFire() < CurTime() and self.Owner then
            local tr = self.Owner:GetEyeTrace()
            local ent = tr.Entity

            if ent and IsValid(ent) then
                if (GM13.Ent:IsInvulnerable(ent) or GM13.Ent:IsReflectingDamage(ent)) and
                   (ent:GetNWFloat("PetrifiedAmount") or 0) >= ent:OBBMaxs().z
                   then
                    if weapon:GetClass() == "weapon_petrificationbeam" then
                        local explo = ents.Create("env_explosion")
                        explo:SetPos(weapon:GetPos())
                        explo:Spawn()
                        explo:Fire("Explode")
                        explo:SetKeyValue("IMagnitude", 20)

                        weapon:Remove()
                    else
                        self:SetNWFloat("PB_Ammo", 0)
                    end

                    ent:SetNWFloat("PetrifiedAmount", 0)
                    return
                else
                    _think(self)
                end
            end
        end
    end
end

-- Freeze Gun
-- https://steamcommunity.com/sharedfiles/filedetails/?id=216226620
function GM13.Addon:WeakenFreezeGun(ply, weapon)
    if weapon:GetClass() == "freezegun" and tranqNPC and tranqPlayer then
        _tranqNPC = tranqNPC

        function tranqNPC(npc, t)
            if GM13.Ent:IsInvulnerable(npc) or GM13.Ent:IsReflectingDamage(npc) then
                tranqPlayer(ply, t)
            else
                _tranqNPC(npc, t)
            end
        end
    end
end

hook.Add("WeaponEquip", "gm13_modify_weapons", function(weapon, ply)
    GM13.Addon:WeakenPetrificationBeam(ply, weapon)
    GM13.Addon:WeakenFreezeGun(ply, weapon)
end)
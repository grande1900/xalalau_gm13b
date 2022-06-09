-- Is prop spawned by a player

function GM13.Prop:IsSpawnedByPlayer(ent)
    return GM13.Ent:IsSpawnedByPlayer(ent) and ent:GetClass() == "prop_physics"
end

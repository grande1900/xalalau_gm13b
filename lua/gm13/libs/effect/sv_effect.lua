-- Visual effects

function GM13.Effect:StartSmokeStream(pos, ang)
    if game.SinglePlayer() then
        ParticleEffect("steam_train", pos, ang)
    else
        net.Start("gm13_create_smoke_stream")
        net.WriteVector(pos)
        net.WriteAngle(ang)
        net.Broadcast()
    end
end
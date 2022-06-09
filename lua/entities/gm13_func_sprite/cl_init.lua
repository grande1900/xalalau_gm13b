include("shared.lua")

function ENT:Initialize()
    self.ready = false 

    local timerName = "gm13_init_sprite_" .. tostring(self)
    timer.Create(timerName, 0.1, 50, function()
        if not self:IsValid() then return end

        self:SetRenderBoundsWS(self:GetNWVector("vecA"), self:GetNWVector("vecB"))

        self.ready = true

        timer.Remove(timerName)
    end)
end

function ENT:Draw()
    self:DrawModel()

    if not self.ready then return true end

    local material = Material(self:GetNWString("materialName"))

    if not material then return true end

    render.SetMaterial(material)
 
    local matrix = Matrix()
    matrix:Translate(self:GetPos())
    matrix:Rotate(self:GetAngles() + Angle(0, 0, 180))
    matrix:Scale(Vector(self:GetNWInt("height"), 0.01, self:GetNWInt("width")))
  
    local up = Vector(0, 0, 1)
    local right = Vector(1, 0, 0)
    local forward = Vector(0, 1, 0)
  
    local down = up * -1
    local left = right * -1
    local backward = forward * -1
  
    cam.PushModelMatrix(matrix)
        mesh.Begin(MATERIAL_QUADS, 6)
  
        --mesh.QuadEasy(up / 2, up, 1, 1)
        --mesh.QuadEasy(down / 2, down, 1, 1)
  
        --mesh.QuadEasy(left / 2, left, 1, 1)
        --mesh.QuadEasy(right / 2, right, 1, 1)
  
        mesh.QuadEasy(forward / 2, forward, 1, 1)
        --mesh.QuadEasy(backward / 2, backward, 1, 1)
  
        mesh.End()
    cam.PopModelMatrix()
end
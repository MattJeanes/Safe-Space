include('shared.lua')

ENT:AddHook("PlayerInitialize", "exterior", function(self)
    self.dimensions = net.ReadTable()
    self.material = net.ReadString()
    self.surfacetype = net.ReadString()
end)

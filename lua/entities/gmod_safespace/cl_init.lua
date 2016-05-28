include('shared.lua')

ENT:AddHook("PlayerInitialize", "exterior", function(self)
	self.dimensions = net.ReadTable()
end)
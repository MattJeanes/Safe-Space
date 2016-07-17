include('shared.lua')

ENT:AddHook("PlayerInitialize", "exterior", function(self)
	self.dimensions = net.ReadTable()
	self.material = net.ReadString()
	self.surfacetype = net.ReadString()
	self.mins = net.ReadVector()
	self.maxs = net.ReadVector()
end)

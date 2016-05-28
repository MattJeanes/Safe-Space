AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

ENT:AddHook("PlayerInitialize", "interior", function(self)
	net.WriteTable(self.dimensions)
end)

function ENT:Initialize()
	self.dimensions=SafeSpace:GetInteriorDimensions(self:GetCreator())
	self.Portal=self:GetPortalDimensions()
	self.BaseClass.Initialize(self)
end
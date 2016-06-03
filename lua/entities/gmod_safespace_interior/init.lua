AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

ENT:AddHook("PlayerInitialize", "interior", function(self)
	net.WriteTable(self.dimensions)
	net.WriteString(self.material)
	net.WriteString(self.surfacetype)
end)

function ENT:Initialize()
	self.dimensions=SafeSpace:GetInteriorDimensions(self:GetCreator())
	self.Portal=self:GetPortalDimensions()
	self.material = SafeSpace:GetTextureInterior(self:GetCreator()) or "models/debug/debugwhite"
	self.surfacetype = SafeSpace:GetSurfaceProperty(self:GetCreator()) or "metal"
	self.BaseClass.Initialize(self)
end

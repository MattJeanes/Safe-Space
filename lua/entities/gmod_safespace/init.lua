AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')


ENT:AddHook("PlayerInitialize", "interior", function(self)
	net.WriteTable(self.dimensions)
end)

function ENT:Initialize()
	self.dimensions=SafeSpace:GetExteriorDimensions(self:GetCreator())
	self.Portal=self:GetPortalDimensions()
	self.BaseClass.Initialize(self)
	self:SetNWString("safespace_texture_exterior",SafeSpace:GetTextureExterior(self:GetCreator()) or "sprops/sprops_grid_12x12")
	self:SetNWString("safespace_surface",SafeSpace:GetSurfaceProperty(self:GetCreator()) or "metal")
end

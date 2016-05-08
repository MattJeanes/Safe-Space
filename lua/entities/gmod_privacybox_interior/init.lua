AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function ENT:Initialize()
	self.Portal=self:GetPortalDimensions()
	self.BaseClass.Initialize(self)
end
-- Test

ENT:AddHook(SERVER and "PreInitialize" or "Initialize","safespace",function(self)
	SafeSpace:MakeInterior(self)
end)

function ENT:GetDimensions()
	return self.dimensions
end

function ENT:GetPortalDimensions()
	return SafeSpace:GetInteriorPortalDimensions(self)
end

function ENT:GetLighting()
	return SafeSpace:GetInteriorLighting(self)
end
-- Test

ENT:AddHook("Initialize","test",function(self)
	SafeSpace:MakeDoor(self)
end)

function ENT:GetDimensions()
	return self.dimensions
end

function ENT:GetPortalDimensions()
	return SafeSpace:GetExteriorPortalDimensions(self)
end

function ENT:GetLighting()
	return SafeSpace:GetExteriorLighting(self)
end
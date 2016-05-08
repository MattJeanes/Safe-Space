-- Test

ENT:AddHook("Initialize","test",function(self)
	SafeSpace:MakeDoor(self)
end)

function ENT:GetDimensions()
	return SafeSpace:GetExteriorDimensions()
end

function ENT:GetPortalDimensions()
	return SafeSpace:GetExteriorPortalDimensions()
end

function ENT:GetLighting()
	return SafeSpace:GetExteriorLighting(self)
end
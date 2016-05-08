-- Test

ENT:AddHook("Initialize","test",function(self)
	SafeSpace:MakeInterior(self)
end)

function ENT:GetDimensions()
	return SafeSpace:GetInteriorDimensions()
end

function ENT:GetPortalDimensions()
	return SafeSpace:GetInteriorPortalDimensions()
end

function ENT:GetLighting()
	return SafeSpace:GetInteriorLighting(self)
end
-- Test

ENT:AddHook("Initialize","test",function(self)
	PrivacyBox:MakeInterior(self)
end)

function ENT:GetDimensions()
	return {
		width = 200,
		height = 150,
		length = 200,
		size = 10
	}
end

function ENT:GetPortalDimensions()
	local dim=self:GetDimensions()
	local edim=self.exterior:GetDimensions()
	return {
		pos = Vector(-(dim.width-dim.size)+5-(edim.size/2),-(dim.length/2),-dim.height+(edim.height/2)),
		ang = Angle(0,0,0),
		width = edim.width-edim.size,
		height = edim.height
	}
end

function ENT:GetLighting()
	local dim=self:GetDimensions()
	local edim=self.exterior:GetDimensions()
	local portal=self:GetPortalDimensions()
	return {
		{
			color=Vector(1,1,1),
			pos=self:LocalToWorld(Vector(-dim.width/2,-dim.length/2,-dim.size-(dim.height*0.2)))
		},
		{
			color=Vector(1,1,1)*0.5,
			pos=self:LocalToWorld(portal.pos+Vector(-edim.size*5,0,0))
		}
	}
end
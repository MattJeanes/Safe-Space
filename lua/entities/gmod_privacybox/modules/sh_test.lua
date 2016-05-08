-- Test

ENT:AddHook("Initialize","test",function(self)
	PrivacyBox:MakeDoor(self)
end)

function ENT:GetDimensions()
	return {
		width = 50,
		height = 100,
		size = 10,
		texscale = 20
	}
end

function ENT:GetPortalDimensions()
	local dim=self:GetDimensions()
	return {
		pos = Vector(0,0,dim.height/2),
		ang = Angle(0,0,0),
		width = dim.width-dim.size,
		height = dim.height
	}
end

function ENT:GetLighting()
	local dim=self:GetDimensions()
	local idim=self.interior:GetDimensions()
	local portal=self:GetPortalDimensions()
	return {
		{
			color=Vector(1,1,1),
			pos=self:LocalToWorld(Vector(-idim.width/2,0,idim.height-idim.size-(idim.height*0.2))),
		},
		{
			color=Vector(1,1,1)*0.5,
			pos=self:LocalToWorld(portal.pos+Vector(dim.size*5,0,0)),
		}
	}
end
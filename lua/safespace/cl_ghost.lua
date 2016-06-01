-- Ghost

local model = "models/props_junk/PopCan01a.mdl"
function SafeSpace:CreateGhost()
	util.PrecacheModel(model)
	local exterior = ents.CreateClientProp(model)
	exterior:SetNoDraw(true)
	exterior.GetDimensions = function(ent)
		return {
			width = self:GetOption("exterior","width").tempvalue,
			height = self:GetOption("exterior","height").tempvalue,
			size = self:GetOption("global","size").tempvalue,
			texscale = self:GetOption("global","texscale").tempvalue
		}
	end
	exterior.GetLighting = function(ent)
		return self:GetExteriorLighting(ent)
	end
	exterior.GetPortalDimensions = function(ent)
		return self:GetExteriorPortalDimensions(ent)
	end
	exterior.UpdateModel = function(exterior,int)
		self:MakeDoor(exterior)
	end
	exterior:UpdateModel()
	
	self.GhostExterior = exterior
	
	local interior = ents.CreateClientProp(model)
	exterior.interior = interior
	interior.exterior = exterior
	interior:SetParent(exterior)
	interior:SetNoDraw(true)
	interior.GetDimensions = function(ent)
		return {
			width = self:GetOption("interior","width").tempvalue,
			height = self:GetOption("interior","height").tempvalue,
			length = self:GetOption("interior","length").tempvalue,
			size = self:GetOption("global","size").tempvalue
		}
	end
	interior.GetPortalDimensions = function(ent)
		return self:GetInteriorPortalDimensions(ent)
	end
	interior.GetLighting = function(ent)
		return self:GetInteriorLighting(ent)
	end
	interior.UpdateModel = function(exterior,int)
		self:MakeInterior(interior)
	end
	interior:UpdateModel()
	
	self.GhostInterior = interior
	
	return exterior, interior
end
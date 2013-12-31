AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
include('shared.lua')

function ENT:Initialize()
	self:SetModel( "models/drmatt/privacybox/door.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetRenderMode( RENDERMODE_NORMAL )
	self:SetColor(Color(255,255,255,255))
	self.phys = self:GetPhysicsObject()
	if (self.phys:IsValid()) then
		self.phys:EnableMotion(false)
	end
	
	self.portal=ents.Create("sent_privacybox_portal")
	self.portal:SetPos(self:GetPos())
	self.portal:SetAngles(self:GetAngles())
	self.portal.exterior=self.exterior
	self.portal.interior=self.interior
	self.portal.owner=self.owner
	self.portal:SetMode(true)
	self.portal:SetParent(self)
	self.portal:Spawn()
	self.portal:Activate()
	if IsValid(self.owner) then
		if SPropProtection then
			SPropProtection.PlayerMakePropOwner(self.owner, self.portal)
		else
			gamemode.Call("CPPIAssignOwnership", self.owner, self.portal)
		end
	end
end
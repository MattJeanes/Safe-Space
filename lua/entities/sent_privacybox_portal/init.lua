AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
include('shared.lua')

function ENT:Initialize()
	self:SetModel( "models/drmatt/privacybox/portal.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetRenderMode( RENDERMODE_TRANSALPHA )
	self:SetColor(Color(255,255,255,255))
	self.phys = self:GetPhysicsObject()
	self:SetNWEntity("exterior",self.exterior)
	self.usecur=0
	if (self.phys:IsValid()) then
		self.phys:EnableMotion(false)
	end
	
	self:SetNotSolid(true)
	self:SetTrigger(true)
end

//TODO: Add an option to turn off window and fix all this up to show the anim texture.
function ENT:SetMode(mode)
	self.mode=mode
	if mode then
		self:SetMaterial("")
	else
		self:SetMaterial("models/props_lab/cornerunit_cloud")
	end
end

function ENT:Touch(ent)
	if not IsValid(self.exterior) then return end
	if ent:IsPlayer() and CurTime()>self.exterior.usecur and self.exterior:PlayerAllowed(ent) then
		if self.mode then
			self.exterior:PlayerExit(ent)
		else
			self.exterior:PlayerEnter(ent)
		end
		self.exterior.usecur=CurTime()+1
	end
end
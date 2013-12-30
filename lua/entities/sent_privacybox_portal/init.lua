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
	self.mode=false
	if (self.phys:IsValid()) then
		self.phys:EnableMotion(false)
	end
	
	self:SetNotSolid(true)
	self:SetTrigger(true)
	self:SetMaterial("models/props_combine/stasisfield_beam")
end

function ENT:Touch(ent)
	if not IsValid(self.exterior) then return end
	if ent:IsPlayer() and CurTime()>self.exterior.usecur then
		if self.mode then
			self.exterior:PlayerExit(ent)
		else
			self.exterior:PlayerEnter(ent)
		end
		self.exterior.usecur=CurTime()+1
	end
end
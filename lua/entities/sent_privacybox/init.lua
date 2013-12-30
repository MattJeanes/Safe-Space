AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
include('shared.lua')

util.AddNetworkString("Player-SetPrivacyBox")
util.AddNetworkString("PrivacyBox-Request")

net.Receive("PrivacyBox-Request", function(len,ply)
	local ent=net.ReadEntity()
	if IsValid(ply)
	and IsValid(ent)
	and	IsValid(ent.interior)
	and IsValid(ent.portal)
	and IsValid(ent.owner) then
		net.Start("PrivacyBox-Request")
			net.WriteEntity(ent)
			net.WriteEntity(ent.interior)
			net.WriteEntity(ent.portal)
			net.WriteEntity(ent.owner)
		net.Send(ply)
	end
end)

function ENT:SpawnFunction( ply, tr, ClassName )
	if (  !tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 12.7
	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	local ang=Angle(0,(ply:GetPos()-SpawnPos):Angle().y,0)
	ent:SetAngles( ang )
	ent.owner=ply
	ent:Spawn()
	ent:Activate()

	return ent
end
 
function ENT:Initialize()
	self:SetModel( "models/drmatt/privacybox/door.mdl" )
	// cheers to doctor who team for the model
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetRenderMode( RENDERMODE_TRANSALPHA )
	
	self.phys = self:GetPhysicsObject()
	if (self.phys:IsValid()) then
		self.phys:Wake()
	end
	
	self.usecur=0	
	self.occupants={}
	
	// this is a bit hacky but from testing it seems to work well
	local trdata={}
	trdata.start=self:GetPos()+Vector(0,0,99999999)
	trdata.endpos=self:GetPos()
	trdata.filter={self}
	local trace=util.TraceLine(trdata)
	//another trace is run here incase the mapper has placed the 3d skybox above the map
	if tobool(GetConVarNumber("privacybox_doubletrace")) then
		local trdata={}
		trdata.start=trace.HitPos+Vector(0,0,-6000)
		trdata.endpos=trace.HitPos
		trdata.filter={self}
		trace=util.TraceLine(trdata)
		//this trace can sometimes fail if the map has a low skybox, hence why its an admin option
	end
	local offset=0
	offset=GetConVarNumber("privacybox_spawnoffset")
	self.interior=ents.Create("sent_privacybox_interior")
	self.interior:SetPos(trace.HitPos+Vector(0,0,-600+offset))
	self.interior.exterior=self
	self.interior.owner=self.owner
	self.interior:Spawn()
	self.interior:Activate()
	if IsValid(self.owner) then
		if SPropProtection then
			SPropProtection.PlayerMakePropOwner(self.owner, self.interior)
		else
			gamemode.Call("CPPIAssignOwnership", self.owner, self.interior)
		end
	end
	
	self.portal=ents.Create("sent_privacybox_portal")
	self.portal:SetPos(self:GetPos())
	self.portal:SetAngles(self:GetAngles())
	self.portal.exterior=self
	self.portal.interior=self.interior
	self.portal.owner=self.owner
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

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

if WireLib then
	function ENT:TriggerInput(k,v)
		/*
		if k=="Test" and v==1 then
			Test()
		end
		*/
	end
end

function ENT:Use( ply, caller )
	if CurTime()>self.usecur then
		self.usecur=CurTime()+1
		self:PlayerEnter(ply)
	end
end

function ENT:OnRemove()
	if self.occupants then
		for k,v in pairs(self.occupants) do
			self:PlayerExit(v,true)
		end
	end
	if self.interior and IsValid(self.interior) then
		self.interior:Remove()
		self.interior=nil
	end
	if self.portal and IsValid(self.portal) then
		self.portal:Remove()
		self.portal=nil
	end
end

function ENT:PlayerEnter( ply, override )
	if ply.privacybox and IsValid(ply.privacybox) then
		ply.privacybox:PlayerExit( ply )
	end
	ply.privacybox=self
	
	net.Start("Player-SetPrivacyBox")
		net.WriteEntity(ply)
		net.WriteEntity(self)
	net.Broadcast()
	if self.interior and IsValid(self.interior) and IsValid(self.interior.door) then
		ply:SetPos(self.interior.door:GetPos()+(self.interior.door:GetForward()*35)+self:WorldToLocal(ply:GetPos())+Vector(0,0,5))
		local ang=(ply:EyeAngles()-self:GetAngles())+self.interior:GetAngles()
		local fwd=(ply:GetVelocity():Angle()+(self.interior:GetAngles()-self:GetAngles())):Forward()
		ply:SetEyeAngles(Angle(ang.p,ang.y,0))
		ply:SetLocalVelocity(Vector(fwd.x,fwd.y,0)*ply:GetVelocity():Length())
	end
	table.insert(self.occupants,ply)
end

function ENT:PlayerExit( ply, override )
	if ply:InVehicle() then ply:ExitVehicle() end
	net.Start("Player-SetPrivacyBox")
		net.WriteEntity(ply)
		net.WriteEntity(NULL)
	net.Broadcast()
	ply.privacybox=nil
	ply:SetPos(self:GetPos()+(self:GetForward()*35)+self.interior.door:WorldToLocal(ply:GetPos())+Vector(0,0,5))
	local ang=(ply:EyeAngles()-self.interior:GetAngles())+self:GetAngles()
	local fwd=(ply:GetVelocity():Angle()+(self:GetAngles()-self.interior:GetAngles())):Forward()
	ply:SetEyeAngles(Angle(ang.p,ang.y,0))
	ply:SetLocalVelocity(Vector(fwd.x,fwd.y,0)*ply:GetVelocity():Length())
	if self.occupants then
		for k,v in pairs(self.occupants) do
			if v==ply then
				if override then
					self.occupants[k]=nil
				else
					table.remove(self.occupants,k)
				end
			end
		end
	end
end

hook.Add("PlayerSpawn", "TARDIS_PlayerSpawn", function( ply )
	local privacybox=ply.privacybox
	if privacybox and IsValid(privacybox) then
		if privacybox.interior and IsValid(privacybox.interior) then
			ply:SetPos(privacybox.interior.door:GetPos()+privacybox.interior.door:GetForward()*30)
			ply:SetEyeAngles(privacybox.interior.door:GetForward():Angle())
		else
			privacybox:PlayerExit(ply)
		end
	end
end)

function ENT:Think()
	if self.occupants then
		for k,v in pairs(self.occupants) do
			if not IsValid(v) then
				self.occupants[k]=nil
				continue
			end
		end
	end
	
	if string.lower(gmod.GetGamemode().Name)=="horizon" then
		for k,v in pairs(self.occupants) do
			if v.suitAir and v.suitCoolant and v.suitPower then
				if v.suitAir<5 then
					v.suitAir=v.suitAir+1
				end
				if v.suitCoolant<5 then
					v.suitCoolant=v.suitCoolant+1
				end
				if v.suitPower<5 then
					v.suitPower=v.suitPower+1
				end
			end
		end
	end
	
	if CAF and CAF.GetAddon("Spacebuild") then
		for k,v in pairs(self.occupants) do
			if v.LsResetSuit then
				v:LsResetSuit()
			end
		end
	end

	// this bit makes it all run faster and smoother
    self:NextThink( CurTime() )
	return true
end
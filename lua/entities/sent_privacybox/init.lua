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

	local SpawnPos = tr.HitPos + tr.HitNormal
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
	
	self.plycur=0	
	self.playercur=0	
	self.propcur=0	
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
	if IsValid(self.owner) and CPPI then
		self.interior:CPPISetOwner(self.owner)
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
end

function ENT:OnRemove()
	if self.occupants then
		for k,v in pairs(self.occupants) do
			self:PlayerExit(v,true,true)
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

function ENT:PropEnter( ent )
	if ent==self or ent.privacybox_part then return end
	if not self:PropAllowed(ent) then return end
	if not (CurTime() > self.propcur) then return end
	if self.interior and IsValid(self.interior) and IsValid(self.interior.door) then
		local phys=ent:GetPhysicsObject()
		local fwd,vel
		if IsValid(phys) then
			vel=phys:GetVelocity()
			fwd=(vel:Angle()+(self.interior:GetAngles()-self:GetAngles())):Forward()
		end
		ent:ForcePlayerDrop()
		local pos=self:WorldToLocal(ent:GetPos())
		ent:SetPos(self.interior.door:GetPos()+(self.interior.door:GetForward()*50)+Vector(0,pos.y,pos.z))
		local ang=(ent:GetAngles()-self:GetAngles())+self.interior:GetAngles()
		ent:SetAngles(ang)
		if IsValid(phys) then
			phys:SetVelocityInstantaneous(Vector(fwd.x,fwd.y,0)*vel:Length())
		end
		--self.propcur=CurTime()+1
	end
end

function ENT:PropExit( ent )
	if ent==self or ent.privacybox_part then return end
	if not self:PropAllowed(ent) then return end
	if not (CurTime() > self.propcur) then return end
	if self.interior and IsValid(self.interior) and IsValid(self.interior.door) then
		local phys=ent:GetPhysicsObject()
		local fwd,vel
		if IsValid(phys) then
			vel=phys:GetVelocity()
			fwd=(vel:Angle()+(self:GetAngles()-self.interior:GetAngles())):Forward()
		end
		ent:ForcePlayerDrop()
		ent:SetPos(self:GetPos()+(self:GetForward()*50)+self.interior.door:WorldToLocal(ent:GetPos()))
		local ang=(ent:GetAngles()-self.interior:GetAngles())+self:GetAngles()
		ent:SetAngles(ang)
		if IsValid(phys) then
			phys:SetVelocityInstantaneous(Vector(fwd.x,fwd.y,0)*vel:Length())
		end
		self.propcur=CurTime()+1
	end
end

function ENT:PropAllowed( ent )
	if CPPI then
		local ply
		if IsValid(ent.heldby) then
			ply=ent.heldby
		elseif IsValid(ent:CPPIGetOwner()) then
			ply=ent:CPPIGetOwner()
		else
			return false
		end
		return self:PlayerAllowed(ply)
	else
		return true
	end
end

function ENT:PlayerAllowed( ply )
	if CPPI then
		return self:CPPICanPhysgun(ply)
	else
		return true
	end
end

function ENT:PlayerEnter( ply, forced )
	if not self:PlayerAllowed(ent) then return end
	if not (CurTime() > self.playercur) then return end
	//TODO: Fix wrong X&Y offset when exiting box inside other box
	if ply.privacybox and IsValid(ply.privacybox) then
		ply.oldprivacybox=ply.privacybox
		ply.privacybox.plycur=CurTime()+1
		ply.privacybox:PlayerExit( ply, true )
	end
	ply.privacybox=self
	
	net.Start("Player-SetPrivacyBox")
		net.WriteEntity(ply)
		net.WriteEntity(self)
	net.Broadcast()
	if self.interior and IsValid(self.interior) and IsValid(self.interior.door) then
		local pos=self:WorldToLocal(ply:GetPos())
		ply:SetPos(self.interior.door:GetPos()+(self.interior.door:GetForward()*40)+Vector(0,pos.y,pos.z+(IsValid(ply.oldprivacybox) and ply.oldprivacybox:WorldToLocal(self:GetPos()).z+10 or 10)))
		local ang=(ply:EyeAngles()-self:GetAngles())+self.interior:GetAngles()
		local fwd=(ply:GetVelocity():Angle()+(self.interior:GetAngles()-self:GetAngles())):Forward()
		ply:SetEyeAngles(Angle(ang.p,ang.y,0))
		ply:SetLocalVelocity(Vector(fwd.x,fwd.y,0)*ply:GetVelocity():Length())
		ply.oldprivacybox=nil
	end
	table.insert(self.occupants,ply)
	self.playercur=CurTime()+1
end

function ENT:PlayerExit( ply, forced, override )
	if not self:PlayerAllowed(ent) then return end
	if not (CurTime() > self.playercur) then return end
	if forced or override then
		if ply:InVehicle() then ply:ExitVehicle() end
	end
	net.Start("Player-SetPrivacyBox")
		net.WriteEntity(ply)
		net.WriteEntity(NULL)
	net.Broadcast()
	ply.privacybox=nil
	if forced then
		ply:SetPos(self:GetPos()+(self:GetForward()*40))
	else
		ply:SetPos(self:GetPos()+(self:GetForward()*40)+self.interior.door:WorldToLocal(ply:GetPos())+Vector(0,0,5))
		local ang=(ply:EyeAngles()-self.interior:GetAngles())+self:GetAngles()
		local fwd=(ply:GetVelocity():Angle()+(self:GetAngles()-self.interior:GetAngles())):Forward()
		ply:SetEyeAngles(Angle(ang.p,ang.y,0))
		ply:SetLocalVelocity(Vector(fwd.x,fwd.y,0)*ply:GetVelocity():Length())
	end
	for k,v in pairs(self.occupants) do
		if v==ply then
			if override then
				self.occupants[k]=nil
			else
				table.remove(self.occupants,k)
			end
		end
	end
	self.playercur=CurTime()+1
end

function ENT:PlayerIn(ply)
	for k,v in pairs(self.occupants) do
		if ply==v then
			return true
		end
	end
	return false
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

hook.Add("CPPIFriendsChanged", "PrivacyBox-CPPIFriendsChanged", function(ply, newfriends)
	local privacybox=ply.privacybox
	if IsValid(privacybox) then
		if privacybox.occupants then
			for k,v in pairs(privacybox.occupants) do
				if not privacybox:PlayerAllowed(v) then
					privacybox:PlayerExit(v)
					privacybox.plycur=CurTime()+1
				end
			end
		end
	end
end)

hook.Add("PhysgunPickup", "PrivacyBox-PhysgunPickup", function(ply,ent)
	ent.heldby=ply
end)

hook.Add("PhysgunDrop", "PrivacyBox-PhysgunDrop", function(ply,ent)
	ent.heldby=ply
end)

hook.Add("EV_Goto", "PrivacyBox-EV_Goto", function(ply,pl,pos)
	if IsValid(pl.privacybox) then
		if not pl.privacybox:PlayerAllowed(ply) then
			return false
		end
	end
end)

hook.Add("EV_Bring", "PrivacyBox-EV_Bring", function(ply,pl,pos)
	if IsValid(ply.privacybox) then
		if not ply.privacybox:PlayerAllowed(pl) then
			return false
		end
	elseif IsValid(pl.privacybox) then
		pl.privacybox:PlayerExit(pl)
	end
end)

function ENT:Think()
	for k,v in pairs(self.occupants) do
		if not IsValid(v) then
			self.occupants[k]=nil
			continue
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
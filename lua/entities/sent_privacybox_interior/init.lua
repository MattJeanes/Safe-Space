AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.
include('shared.lua')

util.AddNetworkString("PrivacyBoxInt-Request")

net.Receive("PrivacyBoxInt-Request", function(len,ply)
	local ent=net.ReadEntity()
	if IsValid(ply)
	and IsValid(ent)
	and IsValid(ent.exterior)
	and ent.parts then
		net.Start("PrivacyBoxInt-Request")
			net.WriteEntity(ent)
			net.WriteEntity(ent.exterior)
			net.WriteFloat(#ent.parts)
			for k,v in pairs(ent.parts) do
				net.WriteEntity(v)
			end
		net.Send(ply)
	end
end)

function ENT:Initialize()
	//TODO: Add spawnicon.
	self:SetModel( "models/drmatt/privacybox/interior.mdl" )
	// cheers to doctor who team for the model
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetRenderMode( RENDERMODE_TRANSALPHA )
	self:DrawShadow(false)
	
	self.phys = self:GetPhysicsObject()
	if (self.phys:IsValid()) then
		self.phys:EnableMotion(false)
	end
	
	self.usecur=0
	
	self:SpawnParts()
	
	self.portals={}
	for i=1,2 do
		self.portals[i]=ents.Create("linked_portal_door")
		self.portals[i]:SetWidth(90)
		self.portals[i]:SetHeight(180)
		self.portals[i]:SetDisappearDist(200)
		self.portals[i].interior=self
		self.portals[i].exterior=self.exterior
	end
	self.portals[1]:SetPos(self.exterior:LocalToWorld(Vector(0,0,90)))
	self.portals[2]:SetPos(self:LocalToWorld(Vector(420, 0, 105)))
	self.portals[1]:SetAngles(self.exterior:GetAngles())
	self.portals[2]:SetAngles(self:LocalToWorldAngles(Angle(0,180,0)))
	self.portals[1]:SetExit(self.portals[2])
	self.portals[2]:SetExit(self.portals[1])
	self.portals[1]:SetParent(self.exterior)
	self.portals[2]:SetParent(self)
	self.portals[1].StartTouch = function(self,ent)
		if ent:IsPlayer() then
			self.exterior:PlayerEnter(ent)
		else
			self.exterior:PropEnter(ent)
		end
	end
	self.portals[2].StartTouch = function(self,ent)
		if ent:IsPlayer() then
			self.exterior:PlayerExit(ent)
		else
			self.exterior:PropExit(ent)
		end
	end
	for i=1,2 do
		self.portals[i]:Spawn()
		self.portals[i]:Activate()
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:SpawnParts()
	if self.parts then
		for k,v in pairs(self.parts) do
			if IsValid(v) then
				v:Remove()
				v=nil
			end
		end
	end
	
	self.parts={}
	
	/*
	//chairs
	local vname="Seat_Airboat"
	local chair=list.Get("Vehicles")[vname]
	self.examplechair1=self:MakeVehicle(self:LocalToWorld(Vector(130,-96,-30)), Angle(0,40,0), chair.Model, chair.Class, vname, chair)
	self.examplechair2=self:MakeVehicle(self:LocalToWorld(Vector(125,55,-30)), Angle(0,135,0), chair.Model, chair.Class, vname, chair)
	*/
	
	//parts	
	self.door=self:MakePart("sent_privacybox_door", Vector(420, 0, 11.802734), Angle(0,180,0), true)

end

function ENT:MakePart(class,vec,ang,weld)
	local ent
	if type(class)=="table" then
		ent=ents.Create(class[1])
		ent:SetModel(class[2])
	elseif type(class)=="string" then
		ent=ents.Create(class)
	else
		print("Critical error!")
	end
	ent.exterior=self.exterior
	ent.interior=self
	ent.owner=self.owner
	ent.privacybox_part=true
	ent:SetPos(self:LocalToWorld(vec))
	ent:SetAngles(ang)
	ent:Spawn()
	ent:Activate()
	if weld then
		if IsValid(ent:GetPhysicsObject()) then
			ent:GetPhysicsObject():EnableMotion(false)
		end
		constraint.Weld(self,ent,0,0)
	end
	if IsValid(self.owner) then
		if SPropProtection then
			SPropProtection.PlayerMakePropOwner(self.owner, ent)
		else
			gamemode.Call("CPPIAssignOwnership", self.owner, ent)
		end
	end
	table.insert(self.parts,ent)
	return ent
end

function ENT:MakeVehicle( Pos, Ang, Model, Class, VName, VTable ) // for the chairs
	local ent = ents.Create( Class )
	if (!ent) then return NULL end
	
	ent:SetModel( Model )
	
	-- Fill in the keyvalues if we have them
	if ( VTable && VTable.KeyValues ) then
		for k, v in pairs( VTable.KeyValues ) do
			ent:SetKeyValue( k, v )
		end
	end
		
	ent:SetAngles( Ang )
	ent:SetPos( Pos )
		
	ent:Spawn()
	ent:Activate()
	
	ent.VehicleName 	= VName
	ent.VehicleTable 	= VTable
	
	-- We need to override the class in the case of the Jeep, because it 
	-- actually uses a different class than is reported by GetClass
	ent.ClassOverride 	= Class
	
	ent.privacybox_part=true
	ent:GetPhysicsObject():EnableMotion(false)
	ent:SetRenderMode(RENDERMODE_TRANSALPHA)
	ent:SetColor(Color(255,255,255,0))
	constraint.Weld(self,ent,0,0)
	if IsValid(self.owner) then
		if SPropProtection then
			SPropProtection.PlayerMakePropOwner(self.owner, ent)
		else
			gamemode.Call("CPPIAssignOwnership", self.owner, ent)
		end
	end
	
	table.insert(self.parts,ent)

	return ent
end

function ENT:OnRemove()
	for k,v in pairs(self.parts) do
		if IsValid(v) then
			v:Remove()
			v=nil
		end
	end
end

function ENT:Use( ply )
	if CurTime()>self.usecur and self.exterior and IsValid(self.exterior) and ply.privacybox and IsValid(ply.privacybox) and ply.privacybox==self.privacybox then
		
	end
end

function ENT:InBox(ent)
	local min=self:LocalToWorld(self:OBBMins())
	local max=self:LocalToWorld(self:OBBMaxs())
	local pos = ent:GetPos()
	if (pos.X>=min.X) and (pos.X<=max.X) and (pos.Y>=min.Y) and (pos.Y<=max.Y) and (pos.Z>=min.Z) and (pos.Z<=max.Z) then
		return true
	else
		return false
	end
end

function ENT:Think()
	if self.exterior and IsValid(self.exterior) then
		local exterior=self.exterior
		if exterior.occupants then
			for k,v in pairs(exterior.occupants) do
				if self:GetPos():Distance(v:GetPos())>700 then
					exterior:PlayerExit(v,true)
					exterior.plycur=CurTime()+1
				end
			end
		end
		for k,v in pairs(player.GetAll()) do
			if self:InBox(v) and not v.privacybox then
				if exterior:PlayerAllowed(v) then
					local pos=v:GetPos()
					local eyeang=v:EyeAngles()
					local vel=v:GetVelocity()
					exterior:PlayerEnter(v)
					v:SetPos(pos)
					v:SetEyeAngles(eyeang)
					v:SetVelocity(vel)
				else
					v:SetPos( v:GetPos() + v:GetVelocity():GetNormal()*-500 )
					v:SetMoveType( MOVETYPE_WALK )
				end
			end
		end
	end
end
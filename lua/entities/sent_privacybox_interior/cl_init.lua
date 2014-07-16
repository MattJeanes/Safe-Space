include('shared.lua')
 
--[[---------------------------------------------------------
   Name: Draw
   Purpose: Draw the model in-game.
   Remember, the things you render first will be underneath!
---------------------------------------------------------]]
function ENT:Draw()
	if (self.exterior==LocalPlayer().privacybox and not LocalPlayer().privacybox_render) or worldportals and worldportals.drawing then
		//render.SuppressEngineLighting(true)
		//render.ComputeDynamicLighting(self:LocalToWorld(Vector(0,0,100)), Vector(0,0,0))
		self:DrawModel()
		//render.SuppressEngineLighting(false)
		if WireLib then
			Wire_Render(self)
		end
	end
end

function ENT:Initialize()
	self.parts={}
	net.Start("PrivacyBoxInt-Request")
		net.WriteEntity(self)
	net.SendToServer()
end

net.Receive("PrivacyBoxInt-Request", function()
	local t={}
	local interior=net.ReadEntity()
	local exterior=net.ReadEntity()
	if IsValid(interior) then
		interior.exterior=exterior
	end
	local count=net.ReadFloat()
	for i=1,count do
		local ent=net.ReadEntity()
		ent.privacybox_part=true
		if IsValid(interior) then
			table.insert(interior.parts,ent)
		end
	end
end)

function ENT:Think()
	local exterior=self.exterior
	if IsValid(exterior) and LocalPlayer().privacybox==exterior then
		if tobool(GetConVarNumber("privacyboxint_dynamiclight"))==true then
			local dlight = DynamicLight( self:EntIndex() )
			if ( dlight ) then
				local size=2048
				local c=Color(GetConVarNumber("privacyboxint_light_r"), GetConVarNumber("privacyboxint_light_g"), GetConVarNumber("privacyboxint_light_b"))
				dlight.Pos = self:LocalToWorld(Vector(0,0,300))
				dlight.r = c.r
				dlight.g = c.g
				dlight.b = c.b
				dlight.Brightness = 5
				dlight.Decay = size * 5
				dlight.Size = size
				dlight.DieTime = CurTime() + 1
			end
		end
	end
end
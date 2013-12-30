include('shared.lua')
 
--[[---------------------------------------------------------
   Name: Draw
   Purpose: Draw the model in-game.
   Remember, the things you render first will be underneath!
---------------------------------------------------------]]
function ENT:Draw() 
	self:DrawModel()
	if WireLib then
		Wire_Render(self)
	end
	local name=""
	if IsValid(self.owner) then
		name=self.owner:Nick()
	end
	cam.Start3D2D( self:LocalToWorld(Vector(0,0,150)), self:LocalToWorldAngles(Angle(0,90,90)), 1 )
		draw.DrawText(name, "ScoreboardText", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER )
	cam.End3D2D()
end

function ENT:Initialize()
	net.Start("PrivacyBox-Request")
		net.WriteEntity(self)
	net.SendToServer()
end

function ENT:Think()
end

net.Receive("PrivacyBox-Request", function()
	local ent=net.ReadEntity()
	ent.interior=net.ReadEntity()
	ent.portal=net.ReadEntity()
	ent.owner=net.ReadEntity()
end)

net.Receive("Player-SetPrivacyBox", function()
	local ply=net.ReadEntity()
	ply.privacybox=net.ReadEntity()
end)
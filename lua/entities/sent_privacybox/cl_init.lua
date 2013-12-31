include('shared.lua')

surface.CreateFont("PrivacyBoxXS", {size=16})
surface.CreateFont("PrivacyBoxS", {size=20})
surface.CreateFont("PrivacyBoxM", {size=30})

local fonts={"PrivacyBoxM", "PrivacyBoxS", "PrivacyBoxXS"}

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
	if string.len(name)>0 then
		name=name.."'s PrivacyBox"
	end
	
	local font=""
	local w,h
	for i=1,#fonts-1 do
		font=fonts[i]
		surface.SetFont(font)
		w,h=surface.GetTextSize(name)
		if w>290 then
			font=fonts[i+1]
		else
			break
		end
	end
	
	cam.Start3D2D( self:LocalToWorld(Vector(10.5,0,182)), self:LocalToWorldAngles(Angle(0,90,90)), 0.4 )
		draw.SimpleText(name, font, 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
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
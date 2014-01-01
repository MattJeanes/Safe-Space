include('shared.lua')

function ENT:Draw()
	if LocalPlayer().privacybox==self:GetNWEntity("exterior", NULL) then
		self:DrawModel()
		cam.Start3D2D( self:LocalToWorld(Vector(10.5,0,182)), self:LocalToWorldAngles(Angle(0,90,90)), 0.4 )
			draw.SimpleText("Exit", "PrivacyBoxM", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		cam.End3D2D()
	end
end
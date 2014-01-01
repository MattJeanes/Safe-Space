include('shared.lua')

function ENT:Draw()
	if LocalPlayer().privacybox==self:GetNWEntity("exterior", NULL) or not self:GetNWBool("mode",false) then
		self:DrawModel()
	end
end
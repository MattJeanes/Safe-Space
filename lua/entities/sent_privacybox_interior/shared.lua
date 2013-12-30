ENT.Type = "anim"
if WireLib then
	ENT.Base 			= "base_wire_entity"
else
	ENT.Base			= "base_gmodentity"
end 
ENT.PrintName		= "PrivacyBox Interior"
ENT.Author			= "Dr. Matt"
ENT.Spawnable		= false
ENT.AdminSpawnable	= false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Category		= "Other"
ENT.privacybox_part		= true

hook.Add("PhysgunPickup", "PrivacyBoxInt-PhysgunPickup", function(_,e)
	if e.privacybox_part then
		return false
	end
end)

hook.Add("OnPhysgunReload", "PrivacyBoxInt-OnPhysgunReload", function(_,p)
	local e = p:GetEyeTraceNoCursor().Entity
	if e.privacybox_part then
		return false
	end
end)

local modes={
	"remover"
}
hook.Add("CanTool", "PrivacyBoxInt-CanTool", function(ply,tr,mode)
	local e=tr.Entity
	if table.HasValue(modes,mode) and IsValid(e) and e.privacybox_part then
		return false
	end
end)

hook.Add("CanProperty", "PrivacyBoxInt-CanProperty", function(ply,property,e)
	if e.privacybox_part then
		return false
	end
end)

hook.Add("InitPostEntity", "PrivacyBoxInt-InitPostEntity", function()
	if pewpew and pewpew.NeverEverList then // nice and easy, blocks pewpew from damaging the interior.
		table.insert(pewpew.NeverEverList, "sent_privacybox_interior")
		hook.Add("PewPew_ShouldDamage","PrivacyBoxInt-BlockDamage",function(pewpew,e,dmg,dmgdlr)
			if e.privacybox_part then
				return false
			end
		end)
	end
	if ACF and ACF_Check then // this one is a bit hacky, but ACFs internal code is shockingly bad.
		local original=ACF_Check
		function ACF_Check(e)
			if IsValid(e) then
				local class=e:GetClass()
				if e.privacybox_part then
					if not e.ACF then ACF_Activate(e) end
					return false
				end
			end
			return original(e)
		end
	end
	if XCF and XCF_Check then // this one is also a bit hacky, but XCFs internal code is shockingly bad.
		local original=XCF_Check
		function XCF_Check(e,i)
			if IsValid(e) then
				local class=e:GetClass()
				if e.privacybox_part then
					if not e.ACF then ACF_Activate(e) end
					return false
				end
			end
			return original(e,i)
		end
	end
end)
if SERVER then
	hook.Add( "SetupPlayerVisibility", "PrivacyBox-SetupPlayerVisibility", function(ply,viewent)
		if IsValid(ply.privacybox) then
			AddOriginToPVS(ply.privacybox:GetPos())
		end
	end)
elseif CLIENT then
	local rt,mat
	local w,h=512,1024
	local CamData = {}
	CamData.x = 0
	CamData.y = 0
	CamData.fov = 90
	CamData.drawviewmodel = false
	CamData.w = w
	CamData.h = h
	
	hook.Add("InitPostEntity", "PrivacyBox-InitPostEntity", function()
		rt=GetRenderTarget("tardis_rt",w,h,false)
		mat=Material("models/drmatt/privacybox/portal")
		mat:SetTexture("$basetexture",rt)
	end)
	
	hook.Add("RenderScene", "PrivacyBox-RenderScene", function()
		if not tobool(GetConVarNumber("privacyboxint_window")) then return end
		local exterior=LocalPlayer().privacybox
		if IsValid(exterior) and IsValid(exterior.interior) then
			local interior=exterior.interior
			CamData.origin = exterior:LocalToWorld(Vector(0, 0, 60))
			CamData.angles = exterior:GetAngles()
			LocalPlayer().privacybox_render=true
			local old = render.GetRenderTarget()
			render.SetRenderTarget( rt )
			render.Clear(0,0,0,255)
			cam.Start2D()
				render.RenderView(CamData)
			cam.End2D()
			render.CopyRenderTargetToTexture(rt)
			render.SetRenderTarget(old)
			LocalPlayer().privacybox_render=false
		end
	end)
	
	/*
	hook.Add( "PreDrawHalos", "PrivacyBox-PreDrawHalos", function() // not ideal, but the new scanner sorta forced me to do this
		if tobool(GetConVarNumber("tardisint_halos"))==false then return end
		local exterior=LocalPlayer().privacybox
		if IsValid(exterior) and not LocalPlayer().privacybox_render then
			local interior=exterior:GetNWEntity("interior",NULL)
			if IsValid(interior) and interior.parts then
				for k,v in pairs(interior.parts) do
					if v.shouldglow then
						halo.Add( {v}, Color( 255, 255, 255, 255 ), 1, 1, 1, true, true )
					end
				end
			end
		end
	end )
	*/
end
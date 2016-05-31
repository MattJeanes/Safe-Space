-- Menu Options

hook.Add("PopulateToolMenu", "SafeSpace-PopulateToolMenu", function()
	spawnmenu.AddToolMenuOption("Options", "Dr. Matt", "SafeSpace_Options", "Safe Space", "", "", function(panel)
		panel:ClearControls()
		
		local DLabel = vgui.Create( "DLabel" )
		DLabel:SetText("The Safe Space Settings are available at any time using the button below:")
		panel:AddItem(DLabel)
		
		local button = vgui.Create("DButton")
		button:SetText("Open Safe Space Settings")
		button.DoClick = function(self)
			SafeSpace:OpenSettings()
		end
		panel:AddItem(button)
		
		
		panel:AddControl( "Header", { Description = "Surface Type:" } )

		local valid_surfaces = SafeSpace:GetCustomSurfaces()
		local surface_properties = vgui.Create( "DTree", panel )

		for k, v in pairs(valid_surfaces) do
			local folder = surface_properties:AddNode(k)
			local foldericon = v.icon
			folder:SetIcon((file.Exists( "materials/icon16/"..foldericon..".png", "GAME" ) and "icon16/"..foldericon..".png") or "icon16/drive.png")	

			for p, q in pairs(v) do
				if p == "icon" then continue end
				local subsurface = folder:AddNode(p)
				local subicon = q.icon
				subsurface:SetIcon((file.Exists( "materials/icon16/"..subicon..".png", "GAME" ) and "icon16/"..subicon..".png") or "icon16/page.png")	
			end
		end

		surface_properties:SetSize(panel:GetWide(),300)
		panel:AddItem(surface_properties)
		
		surface_properties.OnNodeSelected = function( self )
			local con = GetConVar("safespace_surface")
			local category = self:GetSelectedItem():GetParentNode():GetText()
			local s_surface = self:GetSelectedItem():GetText()

			if category!="" then
				local var = valid_surfaces[category][s_surface].real
				con:SetString(var)
				notification.AddLegacy("Surface Updated: "..s_surface,0,5)
				surface.PlaySound( "buttons/button15.wav" )
			end
		end


		local matselectex = panel:MatSelect( "safespace_texture_exterior", list.Get( "OverrideMaterials" ), true, 64, 64 )
		local mat_ex = vgui.Create("DCollapsibleCategory")
		panel:AddItem(mat_ex)
		mat_ex:SetLabel("Exterior Material")
		mat_ex:SetExpanded(0)
		mat_ex:SetContents(matselectex)

		local matselectint = panel:MatSelect( "safespace_texture_interior", list.Get( "OverrideMaterials" ), true, 64, 64 )
		local mat_in = vgui.Create("DCollapsibleCategory")
		panel:AddItem(mat_in)
		mat_in:SetLabel("Interior Material")
		mat_in:SetExpanded(1)
		mat_in:SetContents(matselectint)
	

	end)
end)

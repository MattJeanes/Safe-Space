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

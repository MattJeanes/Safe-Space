-- Menu Options

hook.Add("PopulateToolMenu", "SafeSpace-PopulateToolMenu", function()
	spawnmenu.AddToolMenuOption("Options", "Dr. Matt", "SafeSpace_Options", "Safe Space", "", "", function(panel)
		panel:ClearControls()
		
		local DLabel = vgui.Create( "DLabel" )
		DLabel:SetText("The Safe Space Settings is available at any time using the button below:")
		panel:AddItem(DLabel)
		
		local button = vgui.Create("DButton")
		button:SetText("Open Safe Space Settings")
		button.DoClick = function(self)
			SafeSpace:OpenSettings()
		end
		panel:AddItem(button)
	end)
end)
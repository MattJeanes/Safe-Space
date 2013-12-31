local checkbox_options={
	{"Interior window", "privacyboxint_window"},
	{"Interior dynamic light", "privacyboxint_dynamiclight"},
	//{"Control tool tips", "privacyboxint_tooltip"},
	//{"Control halos", "privacyboxint_halos"},
}

for k,v in pairs(checkbox_options) do
	CreateClientConVar(v[2], "1", true)
end

local special_checkbox_options={
	//{"Exterior snow", "privacybox_specialtex", "0", true},
	//{"Interior rails", "privacyboxint_rails", "1", true},
}

for k,v in pairs(special_checkbox_options) do
	CreateClientConVar(v[2], v[3], true, v[4])
end

CreateClientConVar("privacyboxint_light_r", "255", true)
CreateClientConVar("privacyboxint_light_g", "255", true)
CreateClientConVar("privacyboxint_light_b", "255", true)

CreateClientConVar("privacyboxint_musicvol", "1", true)

hook.Add("PopulateToolMenu", "PrivacyBox-PopulateToolMenu", function()
	spawnmenu.AddToolMenuOption("Options", "Abyss", "PrivacyBox_Options", "PrivacyBox", "", "", function(panel)
		panel:ClearControls()
		//Do menu things here
		
		local checkBox = vgui.Create( "DCheckBoxLabel" )
		checkBox:SetText( "Double spawn trace (Admin Only)" )
		checkBox:SetToolTip( "This should fix some maps where the interior doesn't spawn properly" )
		checkBox:SetValue( GetConVarNumber( "privacybox_doubletrace" ) )
		checkBox:SetDisabled(not (LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin()))
		checkBox.OnChange = function(self,val)
			if LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() then
				net.Start("PrivacyBox-DoubleTrace")
					net.WriteFloat(val==true and 1 or 0)
				net.SendToServer()
			else
				chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be an admin to change this option.")
				chat.PlaySound()
			end
		end
		panel:AddItem(checkBox)
		
		local DLabel = vgui.Create( "DLabel" )
		DLabel:SetText("Interior Lighting:")
		panel:AddItem(DLabel)
		
		local Mixer1 = vgui.Create( "DColorMixer" )
		Mixer1:SetPalette( true )  		--Show/hide the palette			DEF:true
		Mixer1:SetAlphaBar( false ) 		--Show/hide the alpha bar		DEF:true
		Mixer1:SetWangs( true )	 		--Show/hide the R G B A indicators 	DEF:true
		Mixer1:SetColor( Color(GetConVarNumber("privacyboxint_light_r"), GetConVarNumber("privacyboxint_mainlight_g"), GetConVarNumber("privacyboxint_light_b")) )	--Set the default color
		Mixer1.ValueChanged = function(self,col)
			RunConsoleCommand("privacyboxint_light_r", col.r)
			RunConsoleCommand("privacyboxint_light_g", col.g)
			RunConsoleCommand("privacyboxint_light_b", col.b)
		end
		panel:AddItem(Mixer1)
		
		local button = vgui.Create("DButton")
		button:SetText("Reset Colors")
		button.DoClick = function(self)
			Mixer1:SetColor(Color(255,255,255))
		end
		panel:AddItem(button)
		
		panel:AddControl("Slider", {
			Label="Music Volume",
			Type="float",
			Min=0.1,
			Max=1,
			Command="privacyboxint_musicvol",
		})
		
		local checkboxes={}
		for k,v in pairs(special_checkbox_options) do
			local checkBox = vgui.Create( "DCheckBoxLabel" ) 
			checkBox:SetText( v[1] ) 
			checkBox:SetValue( GetConVarNumber( v[2] ) )
			checkBox:SetConVar( v[2] )
			panel:AddItem(checkBox)
			table.insert(checkboxes, checkBox)
		end
		
		for k,v in pairs(checkbox_options) do
			local checkBox = vgui.Create( "DCheckBoxLabel" ) 
			checkBox:SetText( v[1] ) 
			checkBox:SetValue( GetConVarNumber( v[2] ) )
			checkBox:SetConVar( v[2] )
			panel:AddItem(checkBox)
			table.insert(checkboxes, checkBox)
		end
	end)
end)
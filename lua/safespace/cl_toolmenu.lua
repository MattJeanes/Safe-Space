-- Tool menu

function SafeSpace:CreateToolMenu(panel)
	panel:AddControl( "Header", { Description = "#tool.safespace.desc" } )
	for _,category in ipairs(SafeSpace:GetOptions()) do
		local label=vgui.Create("DLabel")
		label:SetFont("DermaLarge")
		label:SetDark(true)
		label:SetText(category.name)
		label:SizeToContents()
		panel:AddItem(label)
		for _,option in ipairs(category) do
			local slider=vgui.Create("DNumSlider")
			option.slider=slider
			slider.category = category.id
			slider.option = option.id
			slider:SetMin(option.min)
			slider:SetMax(option.max)
			slider:SetDecimals(0)
			slider:SetText(option.name)
			slider.Label:SetDark(true)
			slider:SetValue(option.value)
			slider.OnValueChanged = function(slider,value)
				SafeSpace:GetOption(slider.category,slider.option).tempvalue=value
				SafeSpace:UpdateGhost()
			end
			panel:AddItem(slider)
		end
	end
	
	local save=vgui.Create("DButton")
	save:SetText("Save")
	save.DoClick = function(save)
		for _,cat in ipairs(SafeSpace:GetOptions()) do
			for _,opt in ipairs(cat) do
				local o = SafeSpace:GetOption(cat.id,opt.id)
				if o and o.convar and o.tempvalue and o.value and o.tempvalue ~= o.value then
					o.convar:SetInt(o.tempvalue)
				end
			end
		end
	end
	panel:AddItem(save)
	
	local revert=vgui.Create("DButton")
	revert:SetText("Revert")
	revert.DoClick = function(revert)
		SafeSpace:ResetOptionChanges()
		SafeSpace:UpdateGhost()
	end
	panel:AddItem(revert)
	
	local default=vgui.Create("DButton")
	default:SetText("Default")
	default.DoClick = function(default)
		SafeSpace:SetDefaultOptions()
		SafeSpace:UpdateGhost()
	end
	panel:AddItem(default)
	
	local preset=vgui.Create("DButton")
	preset:SetText("Presets")
	preset.DoClick = function(preset)
		SafeSpace:OpenPresets()
	end
	panel:AddItem(preset)
	
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
	mat_in:SetExpanded(0)
	mat_in:SetContents(matselectint)
end
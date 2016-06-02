-- Tool menu

function SafeSpace:CreateToolMenu(panel)
	panel:AddControl( "Header", { Description = "#tool.safespace.desc" } )
	
	local showghost=vgui.Create("DCheckBoxLabel")
	showghost:SetConVar("safespace_showghost")
	showghost:SetText("Show Ghost")
	showghost:SetDark(true)
	showghost:SizeToContents()
	panel:AddItem(showghost)
	
	local showghostint=vgui.Create("DCheckBoxLabel")
	showghostint:SetConVar("safespace_showghostint")
	showghostint:SetText("Show Ghost Interior")
	showghostint:SetDark(true)
	showghostint:SizeToContents()
	panel:AddItem(showghostint)
	
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
			slider:SetConVar(self:GetOptionConVarName(category.id,option.id))
			slider.OnValueChanged = function(slider,value)
				SafeSpace:UpdateGhost()
			end
			panel:AddItem(slider)
		end
	end
	
	local save=vgui.Create("DButton")
	save:SetText("Save")
	save.DoClick = function(save)
		SafeSpace:SaveOptions()
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
	
	local matselect = panel:MatSelect( "safespace_texture_exterior", list.Get( "OverrideMaterials" ), true, 64, 64 )
	local scroll = vgui.Create("DScrollPanel")
	matselect:SetParent(scroll)
	local collapse = vgui.Create("DCollapsibleCategory")
	collapse:SetLabel("Exterior material")
	collapse:SetExpanded(0)
	collapse:SetContents(scroll)
	panel:AddItem(collapse)
	collapse.SizeToChildren = function(collapse)
		collapse:SetTall(200)
	end

	local matselect = panel:MatSelect( "safespace_texture_interior", list.Get( "OverrideMaterials" ), true, 64, 64 )
	local scroll = vgui.Create("DScrollPanel")
	matselect:SetParent(scroll)
	local collapse = vgui.Create("DCollapsibleCategory")
	collapse:SetLabel("Interior material")
	collapse:SetExpanded(0)
	collapse:SetContents(scroll)
	panel:AddItem(collapse)
	collapse.SizeToChildren = function(collapse)
		collapse:SetTall(200)
	end
	
	local valid_surfaces = SafeSpace:GetCustomSurfaces()
	local surface_properties = vgui.Create("DTree")
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
	surface_properties.OnNodeSelected = function(self)
		local con = GetConVar("safespace_surface")
		local category = self:GetSelectedItem():GetParentNode():GetText()
		local s_surface = self:GetSelectedItem():GetText()

		if category ~= "" then
			local var = valid_surfaces[category][s_surface].real
			con:SetString(var)
			notification.AddLegacy("Surface Updated: "..s_surface,0,5)
			surface.PlaySound( "buttons/button15.wav" )
		end
	end
	
	local collapse = vgui.Create("DCollapsibleCategory")
	collapse:SetLabel("Surface properties")
	collapse:SetExpanded(0)
	collapse:SetContents(surface_properties)
	panel:AddItem(collapse)
	collapse.SizeToChildren = function(collapse)
		collapse:SetTall(200)
	end
	
	SafeSpace:ResetOptionChanges()
	SafeSpace:UpdateGhost()
end
-- Settings

local options={
	{
		id = "global",
		name = "Global",
		{
			id = "size",
			name = "Size",
			min = 10,
			max = 1000,
			default = 25
		},
		{
			id = "texscale",
			name = "Texture Scaling",
			min = 10,
			max = 1000,
			default = 25
		}
	},
	{
		id = "exterior",
		name = "Frame",
		{
			id = "width",
			name = "Width",
			min = 50,
			max = 5000,
			default = 100
		},
		{
			id = "height",
			name = "Height",
			min = 50,
			max = 5000,
			default = 150
		}
	},
	{
		id = "interior",
		name = "Interior",
		{
			id = "width",
			name = "Width",
			min = 50,
			max = 5000,
			default = 300
		},
		{
			id = "height",
			name = "Height",
			min = 50,
			max = 5000,
			default = 250
		},
		{
			id = "length",
			name = "Length",
			min = 50,
			max = 5000,
			default = 300
		}
	}
}

function SafeSpace:GetOptions()
	return options
end

function SafeSpace:GetOption(category,option,ply)
	for _,cat in ipairs(options) do
		if cat.id==category then
			for _,opt in ipairs(cat) do
				if opt.id==option then
					if SERVER then
						opt.value = ply:GetInfoNum(self:GetOptionConVarName(cat.id,opt.id),opt.default)
					elseif opt.convar then
						opt.value = opt.convar:GetInt()
					end
					if not opt.value then
						opt.value = opt.default
					end
					opt.value = math.max(opt.min,math.min(opt.max,opt.value))
					if CLIENT and (not opt.tempvalue) then
						opt.tempvalue = opt.value
					end
					return opt
				end
			end
		end
	end
	return false
end

function SafeSpace:ResetOptionChanges()
	for _,cat in ipairs(options) do
		for _,opt in ipairs(cat) do
			local o = SafeSpace:GetOption(cat.id,opt.id)
			o.tempvalue = o.value
			if IsValid(o.slider) then
				o.slider:SetValue(o.tempvalue)
			end
		end
	end
end

function SafeSpace:SetDefaultOptions()
	for _,cat in ipairs(options) do
		for _,opt in ipairs(cat) do
			opt.tempvalue = opt.default
			if IsValid(opt.slider) then
				opt.slider:SetValue(opt.tempvalue)
			end
		end
	end
end

function SafeSpace:GetOptionConVarName(category,option)
	return "safespace_".. category .. "_" .. option
end

if CLIENT then
	for _,cat in ipairs(options) do
		for _,opt in ipairs(cat) do
			opt.convar = CreateClientConVar(SafeSpace:GetOptionConVarName(cat.id,opt.id), opt.default, true, true)
		end
	end
end

function SafeSpace:OpenSettings()
	SafeSpace:ResetOptionChanges()

	local frame=vgui.Create("DFrame")
	frame:SetSize(ScrW()*0.5,ScrH()*0.5)
	frame:SetTitle("Safe Space Settings")
	frame:SetDraggable(true)
	frame:Center()
	
	local panel=vgui.Create("DPanel",frame)
	panel:SetSize(frame:GetWide()-4,frame:GetTall()-27)
	panel:SetPos(2,25)
	
	local margin=15
	
	local modelpanel=vgui.Create("DPanel",panel)
	modelpanel:SetSize(panel:GetWide()/2,panel:GetTall())
	modelpanel:SetBackgroundColor(Color(50,50,50))
	
	local exterior=vgui.Create("DModelPanel",modelpanel)
	exterior:SetSize(modelpanel:GetWide()-margin,modelpanel:GetTall()-margin)
	exterior:SetPos(margin,0)
	exterior:SetModel("models/props_junk/PopCan01a.mdl")
	exterior.FarZ = 16000
	exterior.Entity.GetDimensions = function(ent)
		return {
			width = SafeSpace:GetOption("exterior","width").tempvalue,
			height = SafeSpace:GetOption("exterior","height").tempvalue,
			size = SafeSpace:GetOption("global","size").tempvalue,
			texscale = SafeSpace:GetOption("global","texscale").tempvalue
		}
	end
	exterior.Entity.GetLighting = function(ent)
		return SafeSpace:GetExteriorLighting(ent)
	end
	exterior.UpdateModel = function(exterior,int)
		SafeSpace:MakeDoor(exterior.Entity)
		local dim=exterior.Entity:GetDimensions()
		local big=math.Max(dim.width,dim.height)
		exterior:SetLookAt(Vector(dim.size/4,(dim.width+dim.size)/4,(dim.height+dim.size)/2))
		exterior:SetCamPos(Vector(0,big*1.5,(dim.height+dim.size)/2))
	end
	exterior:UpdateModel()
	exterior.Angles = Angle(0,90,0)
	exterior.DragMousePress = function(self)
		self.PressX, self.PressY = gui.MousePos()
		self.Pressed = true
	end
	exterior.DragMouseRelease = function(self)
		self.Pressed = false
	end
	exterior.LayoutEntity = function(self, ent)
		if self.Pressed then
			local mx, my = gui.MousePos()
			self.Angles = self.Angles - Angle( 0, ( self.PressX or mx ) - mx, 0 )
			
			self.PressX, self.PressY = gui.MousePos()
		end
		ent:SetAngles( self.Angles )
	end
	exterior.PreDrawModel = function(exterior,ent)
		ent:CustomDrawModel(true)
		return false
	end
	
	local interior=vgui.Create("DModelPanel",modelpanel)
	interior:SetVisible(false)
	interior:SetSize(modelpanel:GetWide()-margin,modelpanel:GetTall()-margin)
	interior:SetPos(margin,0)
	interior:SetModel("models/props_junk/PopCan01a.mdl")
	interior.FarZ = 16000
	interior.Entity.GetDimensions = function(ent)
		return {
			width = SafeSpace:GetOption("interior","width").tempvalue,
			height = SafeSpace:GetOption("interior","height").tempvalue,
			length = SafeSpace:GetOption("interior","length").tempvalue,
			size = SafeSpace:GetOption("global","size").tempvalue
		}
	end
	interior.Entity.GetLighting = function(ent)
		return SafeSpace:GetInteriorLighting(ent)
	end
	interior.Entity.exterior = exterior.Entity
	exterior.Entity.interior = interior.Entity
	interior.UpdateModel = function(interior,int)
		SafeSpace:MakeInterior(interior.Entity)
		local dim=interior.Entity:GetDimensions()
		local big=math.Max(dim.width,dim.height,dim.length)
		interior:SetLookAt(Vector(0,0,-dim.height-dim.size))
		interior:SetCamPos(Vector(0,big*1.5,-dim.height-dim.size))
	end
	interior:UpdateModel()
	interior.Angles = Angle(0,-90,0)
	interior.DragMousePress = function(self)
		self.PressX, self.PressY = gui.MousePos()
		self.Pressed = true
	end
	interior.DragMouseRelease = function(self)
		self.Pressed = false
	end
	interior.LayoutEntity = function(self, ent)
		if self.Pressed then
			local mx, my = gui.MousePos()
			self.Angles = self.Angles - Angle( 0, ( self.PressX or mx ) - mx, 0 )
			
			self.PressX, self.PressY = gui.MousePos()
		end
		ent:SetAngles( self.Angles )
	end
	interior.PreDrawModel = function(interior,ent)
		ent:CustomDrawModel(true)
		return false
	end
	
	local toggle=vgui.Create("DButton",modelpanel)
	toggle:SetSize(modelpanel:GetWide()*0.1,modelpanel:GetWide()*0.05)
	toggle:SetText("Toggle")
	toggle.toggled = false
	toggle.DoClick = function(toggle)
		toggle.toggled = not toggle.toggled
		if toggle.toggled then
			exterior:SetVisible(false)
			interior:SetVisible(true)
		else
			exterior:SetVisible(true)
			interior:SetVisible(false)
		end
	end
	
	local settingpanel=vgui.Create("DPanel",panel)
	settingpanel:SetSize(panel:GetWide()/2,panel:GetTall())
	settingpanel:SetPos(panel:GetWide()/2,0)
	settingpanel:SetBackgroundColor(Color(200,200,200))
	
	local th = margin
	for _,category in ipairs(SafeSpace:GetOptions()) do
		local label=vgui.Create("DLabel",settingpanel)
		label:SetFont("DermaLarge")
		label:SetDark(true)
		label:SetText(category.name)
		label:SetPos(margin,th)
		label:SizeToContents()
		th = th + 30
		for _,option in ipairs(category) do
			local slider=vgui.Create("DNumSlider",settingpanel)
			option.slider=slider
			slider.category = category.id
			slider.option = option.id
			slider:SetPos(margin,th)
			slider:SetWide(settingpanel:GetWide()-(margin))
			slider:SetMin(option.min)
			slider:SetMax(option.max)
			slider:SetDecimals(0)
			slider:SetText(option.name)
			slider.Label:SetDark(true)
			slider:SetValue(option.value)
			slider.OnValueChanged = function(slider,value)
				SafeSpace:GetOption(slider.category,slider.option).tempvalue=value
				exterior:UpdateModel()
				interior:UpdateModel()
			end
			th = th + 30
		end
		th = th + 10
	end
	
	local save=vgui.Create("DButton",settingpanel)
	save:SetSize(settingpanel:GetWide()*0.1,settingpanel:GetWide()*0.05)
	save:SetPos(settingpanel:GetWide()-save:GetWide(),settingpanel:GetTall()-save:GetTall())
	save:SetText("Save")
	save.DoClick = function(save)
		for _,cat in ipairs(options) do
			for _,opt in ipairs(cat) do
				local o = SafeSpace:GetOption(cat.id,opt.id)
				if o and o.convar and o.tempvalue and o.value and o.tempvalue ~= o.value then
					o.convar:SetInt(o.tempvalue)
				end
			end
		end
	end
	
	local revert=vgui.Create("DButton",settingpanel)
	local x,y = save:GetPos()
	revert:SetSize(settingpanel:GetWide()*0.1,settingpanel:GetWide()*0.05)
	revert:SetPos(x-revert:GetWide()-5,y)
	revert:SetText("Revert")
	revert.DoClick = function(revert)
		SafeSpace:ResetOptionChanges()
		exterior:UpdateModel()
		interior:UpdateModel()
	end
	
	local default=vgui.Create("DButton",settingpanel)
	local x,y = revert:GetPos()
	default:SetSize(settingpanel:GetWide()*0.1,settingpanel:GetWide()*0.05)
	default:SetPos(x-default:GetWide()-5,y)
	default:SetText("Default")
	default.DoClick = function(default)
		SafeSpace:SetDefaultOptions()
		exterior:UpdateModel()
		interior:UpdateModel()
	end
	
	local preset=vgui.Create("DButton",settingpanel)
	local x,y = default:GetPos()
	preset:SetSize(settingpanel:GetWide()*0.1,settingpanel:GetWide()*0.05)
	preset:SetPos(x-default:GetWide()-5,y)
	preset:SetText("Presets")
	preset.DoClick = function(preset)
		SafeSpace:OpenPresets()
	end
	
	frame:MakePopup()
end

function SafeSpace:OpenPresets()
	local frame=vgui.Create("DFrame")
	frame:SetSize(ScrW()*0.1,ScrH()*0.3)
	frame:SetTitle("Presets")
	frame:SetDraggable(true)
	frame:Center()
	frame.OldClose = frame.Close
	
	local removed={}
	local changed=false
	
	local panel=vgui.Create("DPanel",frame)
	panel:SetSize(frame:GetWide()-4,frame:GetTall()-27)
	panel:SetPos(2,25)
	
	local presetlist = vgui.Create("DListView",panel)
	presetlist:SetWide(panel:GetWide())
	presetlist:SetTall(panel:GetTall()*0.85-2)
	presetlist:SetMultiSelect(false)
	presetlist:AddColumn( "Preset" )
	local datastr=file.Read("safespace_presets.txt","DATA")
	if datastr then
		local data=Doors.von.deserialize(datastr)
		for k,v in pairs(data) do
			presetlist:AddLine(k).data=v
		end
	end
	presetlist:SelectFirstItem()
	
	local save=vgui.Create("DButton",panel)
	save:SetSize(panel:GetWide()*0.2,panel:GetTall()*0.075)
	save:SetPos(panel:GetWide()-save:GetWide(),panel:GetTall()-save:GetTall())
	save:SetText("Save")
	save.DoClick = function(save)
		local data={}
		for k,v in ipairs(presetlist:GetLines()) do
			data[v:GetValue(1)] = v.data
		end
		local datastr=Doors.von.serialize(data)
		file.Write("safespace_presets.txt",datastr)
		changed = false
	end
	
	local load=vgui.Create("DButton",panel)
	local x,y = save:GetPos()
	load:SetSize(panel:GetWide()*0.2,panel:GetTall()*0.075)
	load:SetPos(x-load:GetWide()-5,y)
	load:SetText("Load")
	load.DoClick = function(load)
		local selected = presetlist:GetSelectedLine()
		if selected then
			local line = presetlist:GetLine(selected)
			if line then
				local data=line.data
				for _,cat in ipairs(options) do
					for _,opt in ipairs(cat) do
						local o = SafeSpace:GetOption(cat.id,opt.id)
						local o2 = data[cat.id][opt.id]
						if o and o.convar and o.value and o2 and o.value ~= o2 then
							o.convar:SetInt(o2)
						end
					end
				end
				SafeSpace:ResetOptionChanges()
				frame:Close()
			end
		end
	end
	
	local new=vgui.Create("DButton",panel)
	local x,y = load:GetPos()
	new:SetSize(panel:GetWide()*0.2,panel:GetTall()*0.075)
	new:SetPos(x-new:GetWide()-5,y)
	new:SetText("New")
	new.DoClick = function(new)
		Derma_StringRequest("New preset", "Please enter a name for your preset", "", function(name)
			local data={}
			for _,cat in ipairs(options) do
				data[cat.id]={}
				for _,opt in ipairs(cat) do
					local o=SafeSpace:GetOption(cat.id,opt.id)
					if o then
						data[cat.id][opt.id]=o.value
					end
				end
			end
			presetlist:AddLine(name).data=data
			if removed[name] then
				removed[name] = nil
			end
			changed = true
		end)
	end
	
	local remove=vgui.Create("DButton",panel)
	remove:SetSize(panel:GetWide()*0.25,panel:GetTall()*0.075)
	remove:SetPos(panel:GetWide()-remove:GetWide(),panel:GetTall()-remove:GetTall()-new:GetTall()-2)
	remove:SetText("Remove")
	remove.DoClick = function(remove)
		local selected = presetlist:GetSelectedLine()
		if selected then
			local line=presetlist:GetLine(selected)
			if line then
				removed[line:GetValue(1)] = true
				presetlist:RemoveLine(selected)
				changed = true
			end
		end
		presetlist:SelectFirstItem()
	end
	
	local rename=vgui.Create("DButton",panel)
	local x,y = remove:GetPos()
	rename:SetSize(panel:GetWide()*0.25,panel:GetTall()*0.075)
	rename:SetPos(x-rename:GetWide()-5,y)
	rename:SetText("Rename")
	rename.DoClick = function(rename)
		local selected = presetlist:GetSelectedLine()
		if selected then
			local line = presetlist:GetLine(selected)
			if line then
				local old=line:GetValue(1)
				Derma_StringRequest("Rename preset", "Please enter a new name for your preset", old, function(name)
					if old ~= name then
						line:SetValue(1,name)
						removed[old] = true
						changed = true
					end
				end)
			end
		end
	end
	
	frame.Close = function(frame)
		if changed then
			Derma_Query(
				"You have unsaved changes, do you want to save?",
				"Unsaved changes",
				"Yes",
				function() save:DoClick() frame:OldClose() end,
				"No",
				function() frame:OldClose() end,
				"Cancel"
			)
		else
			frame:OldClose()
		end
	end
	
	frame:MakePopup()
end
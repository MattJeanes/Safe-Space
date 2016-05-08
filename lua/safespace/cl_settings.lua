-- Settings

local options={
	{
		id = "exterior",
		name = "Frame",
		{
			id = "width",
			name = "Width",
			min = 50,
			max = 5000,
			value = 500
		},
		{
			id = "height",
			name = "Height",
			min = 50,
			max = 5000,
			value = 500
		},
		{
			id = "size",
			name = "Size",
			min = 50,
			max = 5000,
			value = 100
		},
		{
			id = "texscale",
			name = "Texture Scaling",
			min = 50,
			max = 5000,
			value = 100
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
			value = 500
		},
		{
			id = "height",
			name = "Height",
			min = 50,
			max = 5000,
			value = 500
		},
		{
			id = "length",
			name = "Length",
			min = 50,
			max = 5000,
			value = 500
		},
		{
			id = "size",
			name = "Size",
			min = 50,
			max = 5000,
			value = 100
		},
	}
}

function SafeSpace:GetOptions()
	return options
end

function SafeSpace:GetOption(category,option)
	for _,cat in ipairs(options) do
		if cat.id==category then
			for _,opt in ipairs(cat) do
				if opt.id==option then
					return opt
				end
			end
		end
	end
	return false
end

function SafeSpace:OpenSettings()
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
			width = SafeSpace:GetOption("exterior","width").value,
			height = SafeSpace:GetOption("exterior","height").value,
			size = SafeSpace:GetOption("exterior","size").value,
			texscale = SafeSpace:GetOption("exterior","texscale").value
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
			width = SafeSpace:GetOption("interior","width").value,
			height = SafeSpace:GetOption("interior","height").value,
			length = SafeSpace:GetOption("interior","length").value,
			size = SafeSpace:GetOption("interior","size").value
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
				SafeSpace:GetOption(slider.category,slider.option).value=value
				exterior:UpdateModel()
				interior:UpdateModel()
			end
			th = th + 30
		end
		th = th + 10
	end
	
	frame:MakePopup()
end
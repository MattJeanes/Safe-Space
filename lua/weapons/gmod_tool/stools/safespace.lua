
TOOL.Category = "Construction"
TOOL.Name = "Safe Space"

cleanup.Register( "safespace" )

if CLIENT then
	language.Add("tool.safespace.name", "Safe Space")
	language.Add("tool.safespace.desc", "Create your own private areas")
	language.Add("tool.safespace.0", "Left click to create a Safe Space")
	language.Add("Undone_safespace", "Undone Safe Space")
end

function TOOL:LeftClick( trace )
	if IsValid(trace.Entity) and trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end
	local ang = trace.HitNormal:Angle()
	ang.pitch = ang.pitch + 90
	local ent = MakeSafeSpace(self:GetOwner(),trace.HitPos,ang)
	print(ent)
	if not IsValid(ent) then return false end
	return true
end

if SERVER then

	function MakeSafeSpace(ply,pos,ang)
	
		if IsValid(ply) and (not ply:CheckLimit("safespace")) then return false end
	
		local ent = ents.Create("gmod_safespace")
		if not IsValid(ent) then return false end
		
		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent:SetCreator(ply)
		ent:Spawn()
		ent:Activate()
		
		if IsValid(ply) then
			ply:AddCount("safespace", ent)
			undo.Create("safespace")
				undo.AddEntity(ent)
				undo.SetPlayer(ply)
			undo.Finish()
		end

		return ent
		
	end

	--duplicator.RegisterEntityClass( "gmod_safespace", MakeSafeSpace, "Model", "Ang", "Pos", "key", "description", "toggle", "Vel", "aVel", "frozen" )

end

if CLIENT then
	local model = "models/props_junk/PopCan01a.mdl"
	function TOOL:MakeGhostEntity()
		util.PrecacheModel(model)
		local exterior = ents.CreateClientProp(model)
		exterior:SetNoDraw(true)
		exterior.GetDimensions = function(ent)
			return {
				width = SafeSpace:GetOption("exterior","width").tempvalue,
				height = SafeSpace:GetOption("exterior","height").tempvalue,
				size = SafeSpace:GetOption("global","size").tempvalue,
				texscale = SafeSpace:GetOption("global","texscale").tempvalue
			}
		end
		exterior.GetLighting = function(ent)
			return SafeSpace:GetExteriorLighting(ent)
		end
		exterior.GetPortalDimensions = function(ent)
			return SafeSpace:GetExteriorPortalDimensions(ent)
		end
		exterior.UpdateModel = function(exterior,int)
			SafeSpace:MakeDoor(exterior)
		end
		exterior:UpdateModel()
		
		self.GhostExterior = exterior
		SafeSpace.GhostExterior = exterior
		
		local interior = ents.CreateClientProp(model)
		exterior.interior = interior
		interior.exterior = exterior
		interior:SetParent(exterior)
		interior:SetNoDraw(true)
		interior.GetDimensions = function(ent)
			return {
				width = SafeSpace:GetOption("interior","width").tempvalue,
				height = SafeSpace:GetOption("interior","height").tempvalue,
				length = SafeSpace:GetOption("interior","length").tempvalue,
				size = SafeSpace:GetOption("global","size").tempvalue
			}
		end
		interior.GetPortalDimensions = function(ent)
			return SafeSpace:GetInteriorPortalDimensions(ent)
		end
		interior.GetLighting = function(ent)
			return SafeSpace:GetInteriorLighting(ent)
		end
		interior.UpdateModel = function(exterior,int)
			SafeSpace:MakeInterior(interior)
		end
		interior:UpdateModel()
		
		self.GhostInterior = interior
		SafeSpace.GhostInterior = interior
	end
	
	hook.Add("PostDrawTranslucentRenderables","safespace-ghost",function()
		local ext = SafeSpace.GhostExterior
		local int = SafeSpace.GhostInterior
		if IsValid(ext) and IsValid(int) and ext.shoulddraw then
			ext:CustomDrawModel(true)
			int:CustomDrawModel(true)
		end
	end)
	
	function TOOL:UpdateGhost( ent, ply )
		if not IsValid(ent) then return end

		local tr = util.GetPlayerTrace(ply)
		local trace = util.TraceLine(tr)
		if not trace.Hit then return end
		
		if IsValid(trace.Entity) and trace.Entity:GetClass() == "gmod_safespace" or trace.Entity:IsPlayer() then
			ent.shoulddraw = false
			return
		end

		local ang = trace.HitNormal:Angle()
		ang.pitch = ang.pitch + 90

		local min = ent:OBBMins()
		local pos = trace.HitPos - trace.HitNormal * min.z
		ent:SetPos(pos)
		ent:SetAngles(ang)
		
		if not ent.shoulddraw then
			ent.shoulddraw = true
		end
	end

	function TOOL:Think()
		if (not IsValid(self.GhostExterior)) then
			self:MakeGhostEntity()
		end
		self:UpdateGhost( self.GhostExterior, self:GetOwner() )
	end

	function TOOL.BuildCPanel( panel )
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
				--th = th + 30
			end
			--th = th + 10
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
end
-- Dynamic

function PrivacyBox:MakeCube(pos,ang,length,width,height,texscale)
	pos=pos or Vector()
	length=length or 1
	width=width or 1
	height=height or 1
	
	-- http://wiki.unity3d.com/index.php/ProceduralPrimitives
	local p0 = Vector(-length*0.5,-width*0.5,height*0.5)+pos
	local p1 = Vector(length*0.5,-width*0.5,height*0.5)+pos
	local p2 = Vector(length*0.5,-width*0.5,-height*0.5)+pos
	local p3 = Vector(-length*0.5,-width*0.5,-height*0.5)+pos
	p0:Rotate(ang)
	p1:Rotate(ang)
	p2:Rotate(ang)
	p3:Rotate(ang)
	 
	local p4 = Vector(-length*0.5,width*0.5,height*0.5)+pos
	local p5 = Vector(length*0.5,width*0.5,height*0.5)+pos
	local p6 = Vector(length*0.5,width*0.5,-height*0.5)+pos
	local p7 = Vector(-length*0.5,width*0.5,-height*0.5)+pos
	p4:Rotate(ang)
	p5:Rotate(ang)
	p6:Rotate(ang)
	p7:Rotate(ang)
	 
	local vertices = {
		-- Left
		p0, p1, p2,
		p2, p3, p0,
	 
		-- Back
		p7, p4, p0,
		p7, p0, p3,
	 
		-- Top
		p4, p5, p1,
		p4, p1, p0,
	 
		-- Bottom
		p3, p6, p7,
		p3, p2, p6,
	 
		-- Front
		p5, p6, p2,
		p5, p2, p1,
	 
		-- Right
		p6, p5, p7,
		p5, p4, p7,
	};

	local up = Vector(0,0,1)
	local down = Vector(0,0,-1)
	local front = Vector(1,0,0)
	local back = Vector(-1,0,0)
	local left = Vector(0,-1,0)
	local right = Vector(0,1,0)
	 
	local normales = {
		-- Left
		left, left, left, left, left, left,
	 
		-- Back
		back, back, back, back, back, back,
	 
		-- Top
		up, up, up, up, up, up,
	 
		-- Bottom
		down, down, down, down, down, down,
	 
		-- Front
		front, front, front, front, front, front,
	 
		-- Right
		right, right, right, right, right, right,
	};

	local _00 = {0,0}
	local _10 = {1,0}
	local _01 = {0,1}
	local _11 = {1,1}
	 
	local uvs = {
		-- Left
		_10, _00, _01, _01, _11, _10,
	 
		-- Back
		_11, _10, _00, _11, _00, _01,
	 
		-- Top
		_00, _01, _11, _00, _11, _10,
	 
		-- Bottom
		_00, _11, _10, _00, _01, _11, 
	 
		-- Front
		_00, _01, _11, _00, _11, _10,
	 
		-- Right
		_01, _00, _11, _00, _10, _11,
	}
	
	-- scale textures correctly
	for i=1,6*6,6 do
		local n=((i-1)/6)+1
		local hm,wm
		if n==1 then -- Left
			hm=height
			wm=length
		elseif n==2 then -- Back
			hm=height
			wm=width
		elseif n==3 then -- Top
			hm=length
			wm=width
		elseif n==4 then -- Bottom
			hm=length
			wm=width
		elseif n==5 then -- Front
			hm=height
			wm=width
		elseif n==6 then -- Right
			hm=height
			wm=length
		end
		hm=hm*(1/texscale)
		wm=wm*(1/texscale)
		for j=i,i+5 do
			local o=uvs[j]
			local uv
			if o==_00 then
				uv={0,0}
			elseif o==_10 then
				uv={1*wm,0}
			elseif o==_01 then
				uv={0,1*hm}
			elseif o==_11 then
				uv={1*wm,1*hm}
			end
			uvs[j]=uv
		end
	end

	local verts = {}
	for i=1,6*6 do
		table.insert(verts,{pos = vertices[i], normal = normales[i], u = uvs[i][1], v = uvs[i][2] })
	end
	
	return verts,vertices
end

local rendermat=Material("sprops/sprops_grid_12x12")
local wireframe=Material("models/wireframe")
local scale=Vector(1,1,1)

function PrivacyBox:Init(ent)
	if CLIENT then
		local vertices={}
		for _,section in pairs(ent.sections) do
			for _,vert in pairs(section[1]) do
				table.insert(vertices,vert)
			end
		end
		ent.mesh=Mesh()
		ent.mesh:BuildFromTriangles(vertices)
	end
	local meshes={}	
	for k,v in pairs(ent.sections) do
		table.insert(meshes,v[2])
	end
	ent:PhysicsInitMultiConvex(meshes)
	ent:EnableCustomCollisions(true)
	
	ent.phys = ent:GetPhysicsObject()
	if not IsValid(ent.phys) then
		ent:Remove()
		return
	end	
	
	ent.phys:SetMass(50000)
	ent.phys:SetMaterial("metal") -- todo, custom?
	ent.phys:EnableMotion(false)
	
	if CLIENT then
		-- https://facepunch.com/showthread.php?t=1459677
		ent:AddHook("Think","phys",function(self)
			if IsValid(self.phys) then
				self.phys:EnableMotion(false)
				self.phys:SetPos(self:GetPos())
				self.phys:SetAngles(self:GetAngles())
			end
		end)
		
		ent.CustomDrawModel = function(self)
			if self.mesh then
				mat = Matrix()
				mat:Translate(self:GetPos())
				mat:Rotate(self:GetAngles())
				mat:Scale(scale)
				-- fixes it going black sometimes
				render.ResetModelLighting(0,0,0)
				render.SetLocalModelLights(self:GetLighting())
				render.SetMaterial(rendermat)
				cam.PushModelMatrix(mat)
					self.mesh:Draw()
				cam.PopModelMatrix()
				
				/*
				-- draws 'Drawing' text in top left if drawing
				cam.Start2D()
					draw.DrawText("Drawing","DermaLarge",0,0,Color(255,0,0,255))
				cam.End2D()
				
				-- draws wireframe around render bounds
				
				local mins,maxs=self:GetRenderBounds()
				render.SetMaterial(wireframe)
				render.DrawBox(self:GetPos(),self:GetAngles(),mins,maxs,Color(255,0,0,255),false)
				
				-- draws boxes around light sources
				for k,v in pairs(self:GetLighting()) do
					local mins,maxs=self:WorldToLocal(v.pos)-Vector(1,1,1)*10,self:WorldToLocal(v.pos)+Vector(1,1,1)*10
					render.SetMaterial(wireframe)
					render.DrawBox(self:GetPos(),self:GetAngles(),mins,maxs,Color(255,0,0,255),false)
				end
				*/
			end
		end
	end
end

function PrivacyBox:MakeDoor(ent)
	ent:SetRenderMode(RENDERMODE_TRANSALPHA)
	ent:SetColor(Color(255,255,255,255))
	
	local dim=ent:GetDimensions()
	ent.sections={
		{self:MakeCube(Vector(0,-dim.width/2,dim.height/2),Angle(0,0,0),dim.size,dim.size,dim.height,dim.texscale)},
		{self:MakeCube(Vector(0,0,dim.height+(dim.size/2)),Angle(0,0,0),dim.size,dim.width+dim.size,dim.size,dim.texscale)},
		{self:MakeCube(Vector(0,dim.width/2,dim.height/2),Angle(0,0,0),dim.size,dim.size,dim.height,dim.texscale)},
	}
	
	local mins,maxs=Vector(-dim.size/2,(-dim.width-dim.size)/2,0),Vector(dim.size/2,(dim.width+dim.size)/2,dim.height+dim.size)
	if CLIENT then
		ent:SetRenderBounds(mins,maxs)
	end
	
	self:Init(ent)
end

function PrivacyBox:MakeInterior(ent,width,height,length,size)
	ent:SetRenderMode(RENDERMODE_TRANSALPHA)
	ent:SetColor(Color(255,255,255,255))
	
	local texscale = 0.1
	local edim=ent.exterior:GetDimensions()
	local dim=ent:GetDimensions()
	ent:SetPos(ent:GetPos()+Vector(0,0,-dim.height))
	ent.sections={
		{self:MakeCube(Vector(-dim.width/2,-dim.length/2,(-dim.size/2)-dim.height),Angle(0,0,0),dim.width,dim.length,dim.size,edim.texscale)}, -- floor
		{self:MakeCube(Vector(-dim.width/2,-dim.length/2,(dim.height-dim.size/2)-dim.height),Angle(0,0,0),dim.width,dim.length,dim.size,edim.texscale)}, -- ceiling
		{self:MakeCube(Vector(-dim.width/2,-dim.length+(dim.size/2),(dim.height/2-(dim.size/2))-dim.height),Angle(0,0,0),dim.width,dim.size,dim.height-dim.size,edim.texscale)}, -- right wall
		{self:MakeCube(Vector(-dim.width/2,-(dim.size/2),(dim.height/2-(dim.size/2))-dim.height),Angle(0,0,0),dim.width,dim.size,dim.height-dim.size,edim.texscale)}, -- left wall
		{self:MakeCube(Vector(-dim.size/2,(-dim.length/2),(dim.height/2-(dim.size/2))-dim.height),Angle(0,0,0),dim.size,dim.length-(dim.size*2),dim.height-dim.size,edim.texscale)}, -- front wall
		{self:MakeCube(Vector(-dim.width+(dim.size/2),(-dim.length/2),(dim.height/2-(dim.size/2))-(dim.height-(edim.height/2))),Angle(0,0,0),dim.size,dim.length-(dim.size*2),dim.height-dim.size-edim.height,edim.texscale)}, -- back wall top
		{self:MakeCube(Vector(-dim.width+(dim.size/2),(-dim.length/4)+(edim.width/4)-(edim.size/4)-(dim.size/2),((edim.height/2))-dim.height),Angle(0,0,0),dim.size,((dim.length-(edim.size*4))/2)-(edim.width/2)+(edim.size*2)+(edim.size/2)-(dim.size),edim.height,edim.texscale)}, -- back right wall
		{self:MakeCube(Vector(-dim.width+(dim.size/2),(-dim.length+dim.size)+((((dim.length-(dim.size*4))/2)-(edim.width/2)+(edim.size/2))/2)+(dim.size/2),((edim.height/2))-dim.height),Angle(0,0,0),dim.size,((dim.length-(edim.size*4))/2)-(dim.size)-(edim.width/2)+(edim.size*2)+(edim.size/2),edim.height,edim.texscale)}, -- back left wall
	}
	
	local mins,maxs=Vector(-dim.width,-dim.length,-dim.height-dim.size),Vector(0,0,0)
	if SERVER then
		local allowance=Vector(1,1,1)*100 -- let people go a bit out of the box
		ent.mins,ent.maxs=ent:LocalToWorld(mins-allowance),ent:LocalToWorld(maxs+allowance)
		ent.ExitBox = {Min=ent.mins,Max=ent.maxs}
	else
		ent:SetRenderBounds(mins,maxs)
	end
	ent.Fallback={pos=Vector(-dim.width+(dim.size/2)+10,-dim.length/2,-dim.height+5)}
	
	self:Init(ent)
end
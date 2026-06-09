local RockModule = {}
local tween = game:GetService("TweenService")

function RockModule.Crater(origin, direction, rocksamount, radius, height, SizeZ, SizeX, SizeY, xAngle, speed, lifetime,height1)
	-- credit: ampro
	local rayparams = RaycastParams.new()
	rayparams.FilterType = Enum.RaycastFilterType.Include
	rayparams.FilterDescendantsInstances = {workspace.World.Map}
	local result = workspace:Raycast(origin,direction,rayparams)
	if result then
		local center = CFrame.new(result.Position,result.Position + result.Normal) * CFrame.Angles(math.rad(90),0,0)
		local angle = 360/rocksamount
		local distance = radius * math.sin(math.rad((180 - angle))/2)
		for i = 1,rocksamount do
			local size = Vector3.new(SizeZ,SizeX,1)
			local cf = center * CFrame.Angles(0,math.rad((i-1) * angle), 0) * CFrame.new(0,0,-distance) * CFrame.Angles(math.rad(xAngle),0,0)
			local newresult = workspace:Raycast(cf.Position + result.Normal * 2, result.Normal * -4, rayparams)
			if newresult then
				local diff = cf.Position - newresult.Position
				cf -= diff
				local part = Instance.new("Part",workspace.Debris)
				part.Anchored = true
				part.CollisionGroup = "Baseplate"
				part.CanCollide = false
				part.Size = size
				part.Transparency = 0
				part.Material = newresult.Instance.Material
				part.Color = newresult.Instance.Color
				part.CFrame = cf * CFrame.new(0,0,-1)
				tween:Create(part,TweenInfo.new(speed),{Size = Vector3.new(SizeZ,SizeX,SizeY),CFrame = cf * CFrame.new(0,0,-height1)}):Play()
				task.delay(lifetime,function()
					tween:Create(part,TweenInfo.new(lifetime),{Size = Vector3.new(SizeZ,SizeX,0),Position = part.Position + Vector3.new(0,height,0)}):Play()
					game.Debris:AddItem(part,lifetime)
				end)
			end
		end
	end
end

function RockModule.Rock2(origin, direction, rocksamount, distance, sidelength, height, width, xAngle, rockangle, tweencf, speedcf, tweensize, speedsize, lifetime)
	local rayparams = RaycastParams.new()
	rayparams.FilterType = Enum.RaycastFilterType.Include
	rayparams.FilterDescendantsInstances = {workspace.World.Map}
	local result = workspace:Raycast(origin,direction,rayparams)
	if result then
		local center = CFrame.new(result.Position,result.Position + result.Normal) * CFrame.Angles(math.rad(90),0,0)
		local angle = 360/rocksamount
		for i = 1,rocksamount do
			local size = Vector3.new(sidelength,height + math.random(-height, height)/10, width + math.random(-width,width)/10)
			local cf = center * CFrame.Angles(0,math.rad((i-1) * angle), 0) * CFrame.new(0,0,-distance) * CFrame.Angles(math.rad(xAngle),0,0)
			local newresult = workspace:Raycast(cf.Position + result.Normal * 2, result.Normal * -4, rayparams)
			if newresult then
				local randomrockangle = math.random(-rockangle,rockangle)
				local diff = cf.Position - newresult.Position
				cf -= diff
				local part = Instance.new("Part",workspace.Debris)
				part.Anchored = true
				part.CanCollide = false
				part.Size = size
				part.Transparency = 0
				part.Material = newresult.Instance.Material
				part.Color = newresult.Instance.Color
				part.CFrame = center * CFrame.Angles(0,math.rad((i-1) * angle), 0)
				if tweencf then
					tween:Create(part,TweenInfo.new(speedcf),{CFrame = cf}):Play()
				else
					part.CFrame = cf * CFrame.Angles(0,math.rad(randomrockangle),0)
				end
				if tweensize then
					tween:Create(part,TweenInfo.new(speedsize),{Size = size}):Play()
				else
					part.Size = size
				end
				task.delay(lifetime,function()
					tween:Create(part,TweenInfo.new(0.5),{Position = part.Position - Vector3.new(0,height,0)}):Play()
					game.Debris:AddItem(part,0.5)
				end)
			end
		end
	end
end

function RockModule.NormalRock(origin, direction, rocksamount, radius, minsize, maxsize, tweenpos, speed, tweensize, speedsize, lifetime)
	local rayparams = RaycastParams.new()
	rayparams.FilterType = Enum.RaycastFilterType.Include
	rayparams.FilterDescendantsInstances = {workspace.World.Map}
	local result = workspace:Raycast(origin,direction,rayparams)
	if result then
		local center = CFrame.new(result.Position,result.Position + result.Normal) * CFrame.Angles(math.rad(90),0,0)
		local angle = 360/rocksamount
		local distance = radius * math.sin(math.rad((180 - angle))/2)
		local sidelength = 2 * (radius) * math.sin(math.rad(180/rocksamount))
		for i = 1,rocksamount do
			local randomsize = math.random(minsize,maxsize)
			local size = Vector3.new(randomsize,randomsize,randomsize)
			local cf = center * CFrame.Angles(0,math.rad((i-1) * angle), 0) * CFrame.new(0,0,-distance) * CFrame.Angles(math.rad(math.random(-360,360)),math.rad(math.random(-360,360)),math.rad(math.random(-360,360)))
			local newresult = workspace:Raycast(cf.Position + result.Normal * 2, result.Normal * -4, rayparams)
			if newresult then
				local part = Instance.new("Part",workspace.Debris)
				part.Anchored = true
				part.CanCollide = false
				part.Size = Vector3.new(1,1,1)
				part.Transparency = 0
				part.Material = newresult.Instance.Material
				part.Color = newresult.Instance.Color
				part.CFrame = center * CFrame.Angles(0,math.rad((i-1) * angle), 0)
				if tweenpos then
					tween:Create(part,TweenInfo.new(speed),{CFrame = cf}):Play()
				else
					part.CFrame = cf
				end
				if tweensize then
					tween:Create(part,TweenInfo.new(speedsize),{Size = size}):Play()
				else
					part.Size = size
				end
				task.delay(lifetime,function()
					tween:Create(part,TweenInfo.new(0.25),{Size = Vector3.new(0,0,0)}):Play()
					game.Debris:AddItem(part,0.25)
				end)
			end
		end
	end
end

function RockModule.SideRock(pos,cf,direction,spread,xangle,xsize,height,width,lifetime)
	local rayparams = RaycastParams.new()
	rayparams.FilterType = Enum.RaycastFilterType.Include
	rayparams.FilterDescendantsInstances = {workspace.World.Map}
	local angle = 180
	for i = 1,2 do
		local resultcf = cf * CFrame.Angles(0, math.rad(angle), 0) * CFrame.new(spread, 0, 0)
		local result = workspace:Raycast(resultcf.Position,direction,rayparams)
		if result then
			local part = Instance.new("Part", workspace.Debris)
			part.Transparency = 0
			part.CanCollide = false
			part.CFrame = CFrame.new(result.Position,Vector3.new(pos.X,part.Position.Y,pos.Z)) * CFrame.new(0,-height/5,0) * CFrame.Angles(math.rad(xangle),0,0)
			part.Size = Vector3.new(xsize, width, height)
			part.Material = result.Instance.Material
			part.BrickColor = result.Instance.BrickColor
			part.Anchored = true
			task.delay(lifetime,function()
				tween:Create(part,TweenInfo.new(0.5),{Position = part.Position - Vector3.new(0,height,0)}):Play()
				game.Debris:AddItem(part,0.5)
			end)
			
			angle += 180
			if angle > 360 then
				angle = 180
			end
		end
	end
end

function RockModule.SideRock2(cf,direction,spread,size,lifetime)
	local rayparams = RaycastParams.new()
	rayparams.FilterType = Enum.RaycastFilterType.Include
	rayparams.FilterDescendantsInstances = {workspace.World.Map}
	local angle = 180
	for i = 1,2 do
		local resultcf = cf * CFrame.Angles(0, math.rad(angle), 0) * CFrame.new(spread, 0, 0)
		local result = workspace:Raycast(resultcf.Position,direction,rayparams)
		if result then
			local part = Instance.new("Part", workspace.Debris)
			part.Transparency = 0
			part.CanCollide = false
			part.CFrame = CFrame.new(result.Position) * CFrame.Angles(math.rad(math.random(-360,360)),math.rad(math.random(-360,360)),math.rad(math.random(-360,360)))
			part.Size = Vector3.new(size, size, size)
			part.Material = result.Instance.Material
			part.BrickColor = result.Instance.BrickColor
			part.Anchored = true
			task.delay(lifetime,function()
				tween:Create(part,TweenInfo.new(0.5),{Position = part.Position - Vector3.new(0,part.Size.Y,0)}):Play()
				game.Debris:AddItem(part,0.5)
			end)

			angle += 180
			if angle > 360 then
				angle = 180
			end
		end
	end
end

function RockModule.FlyRock(origin,direction,time,Size,minvel,maxvel,minup,maxup,lifetime,Rockamount)
	local rayparams = RaycastParams.new()
	rayparams.FilterType = Enum.RaycastFilterType.Include
	rayparams.FilterDescendantsInstances = {workspace.World.Map}
	local result = workspace:Raycast(origin,direction,rayparams)
	if result then
		for i = 1,Rockamount do
			local part = Instance.new("Part",workspace.Debris)
			part.Parent = workspace.Debris
			part.CollisionGroup = "Rock"
			part.Anchored = false
			part.CanCollide = false
			local size = Size
			part.Size = Vector3.new(size,size,size)
			part.Transparency = 0
			part.Material = result.Instance.Material
			part.Color = result.Instance.Color
			part.CFrame = CFrame.new(result.Position) * CFrame.Angles(math.rad(math.random(-360,360)),math.rad(math.random(-360,360)),math.rad(math.random(-360,360)))
			local bv = Instance.new("BodyVelocity", part)
			bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
			bv.Velocity = Vector3.new(math.random(minvel,maxvel),math.random(minup,maxup),math.random(minvel,maxvel))
			task.delay(lifetime,function()
				tween:Create(part,TweenInfo.new(0.5), {Size = Vector3.new(0,0,0)}):Play()
				game.Debris:AddItem(part,0.5)
			end)
			game.Debris:AddItem(bv,time)
		end
	end
end
return RockModule

local RealAssetsFolder = script.RealAssets
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")

local v3 = RaycastParams.new()
v3.FilterType = Enum.RaycastFilterType.Include
v3.FilterDescendantsInstances = {
	workspace.Map,
}

local VfxModules = {}
local AnimationIds = {
	121581332488786,
	112960241496013,
	122937264351674,
	81606194194844
}

for _, VfxModuleScript in pairs(script.VfxMods:GetChildren()) do
	VfxModules[tostring(VfxModuleScript)] = require(VfxModuleScript)
end

for _, AnimationId in pairs(AnimationIds) do
	local AnimationInstance = Instance.new("Animation")
	AnimationInstance.AnimationId = "rbxassetid://" .. AnimationId
	Debris:AddItem(AnimationInstance, 5)

	for _, Descendant in pairs(script.Assets:GetDescendants()) do
		if Descendant:IsA("AnimationController") and Descendant.Parent and tostring(Descendant.Parent):find("Cam") then
			Descendant:LoadAnimation(AnimationInstance):Play()
		end
	end
end

local AuraNerfSettings = {
	Boundless = {
		RateNerf = 2.5,
		EmitCountNerf = 2.5
	},
	TrueRage = {
		RateNerf = 4,
		EmitCountNerf = 4
	},
	Evolved = {
		RateNerf = 1.75,
		EmitCountNerf = 1.75
	}
}

for AuraName, NerfValues in pairs(AuraNerfSettings) do
	local AuraModule = script.VfxMods[tostring(AuraName)]
	AuraModule:SetAttribute("RateNerf", NerfValues.RateNerf)
	AuraModule:SetAttribute("EmitCountNerf", NerfValues.EmitCountNerf)
end

local function FindChildByName(Parent, TargetName)
	for _, Child in pairs(Parent:GetChildren()) do
		if tostring(Child) == tostring(TargetName) then
			return Child
		end
	end
end

local function GetPlayingAnimationById(Humanoid, AnimationId)
	for _, Track in pairs(Humanoid:GetPlayingAnimationTracks()) do
		if Track.Animation.AnimationId == "rbxassetid://" .. tostring(AnimationId) then
			return Track
		end
	end
end

local function doShake(Char, Intensity, Last)
	for _, player in pairs(Char) do
		if player == game.Players.LocalPlayer.Character then
			shared.repfire("Camshake",{ Intensity = Intensity, Last = Last or nil })
		end
	end
end

local function v196(v189, v190, v191)
	if not v189 or not v189.Parent then
		return
	else
		game.Debris:AddItem(v189, 30)
		for _, v193 in pairs(v189:GetDescendants()) do
			if v193:IsA("ParticleEmitter") then
				local v194 = true
				if v191 and v191.Exclude and v193.Parent == v191.Exclude then
					v194 = false
				end
				
				if v194 then
					if string.lower(v193.Name) == "smoke" and v190 then
						local v195 = workspace:Raycast(v190.PrimaryPart.Position, v190.PrimaryPart.Position, v3)
						if v195 then
							v193.Color = ColorSequence.new(v195.Instance.Color)
						end
					end
					
					v193:Emit(v193:GetAttribute("EmitCount"))
				end
			end
		end
		
		return
	end
end

local function v212(v209)
	local v210 = v209.Part:Clone()
	table.insert(v209.cleanup, v210)
	v210.Parent = workspace.Thrown
	v210.CFrame = v209.CFrame
	v196(v210, v209.Char)
	game.Debris:AddItem(v210, 5)
	
	if v209.TempWc then
		v210.Anchored = false
		v210.Massless = true
		v210.CanCollide = false
		v210.CanTouch = false
		local l_WeldConstraint_0 = Instance.new("WeldConstraint")
		l_WeldConstraint_0.Part0 = v209.WeldData.Part0
		l_WeldConstraint_0.Part1 = v210
		game.Debris:AddItem(l_WeldConstraint_0, v209.WeldData.DeletionTime)
	end
end

local function v177(v167, v168, v169)
	if not v169 then
		v169 = {}
	end
	
	local l_PrimaryPart_0 = v167.PrimaryPart
	local v171 = v168:Clone()
	game.Debris:AddItem(v171, 10)
	v171.Parent = workspace.Thrown
	
	local function v174(v172)
		local l_CFrame_4 = l_PrimaryPart_0.CFrame
		if v167:GetAttribute("ForcedCFrame") and typeof(v167:GetAttribute("ForcedCFrame")) == "CFrame" then
			l_CFrame_4 = v167:GetAttribute("ForcedCFrame")
		end
		v172.CFrame = l_CFrame_4 * v172:GetAttribute("Offset")
	end
	
	if v169.all then
		for _, v176 in pairs(v171:GetDescendants()) do
			if v176:IsA("BasePart") then
				v174(v176)
			end
		end
		
		return v171
	else
		v174(v171)
		return v171
	end
end

local function v220(v213)
	local l_anim_0 = v213.anim
	
	for v216, v217 in pairs(v213.markers) do
		local v218 = nil
		do
			local l_v218_0 = v218
			l_v218_0 = l_anim_0:GetMarkerReachedSignal(v216):Connect(function()
				if not l_anim_0.IsPlaying then
					return
				else
					if not v213.DontDisconnectMarkers then
						l_v218_0:Disconnect()
					end
					return v217(v213.sendingdata)
				end
			end)
			table.insert(v213.cleanup, l_v218_0)
			
			task.delay(20, function()
				if l_v218_0 then
					l_v218_0:Disconnect()
				end
			end)
		end
	end
end

local function v208(v197, v198, v199)
	local v200 = nil
	local v201 = nil
	for _, v203 in pairs(v198.Part:GetChildren()) do
		if v203:IsA("Attachment") then
			local v204 = v203:Clone()
			v204.Parent = v197
			game.Debris:AddItem(v204, 10)
			if tostring(v204) == "Attachment1" then
				v200 = v204
			else
				v201 = v204
			end
		end
	end
	
	for _, v206 in pairs(v198.Part:GetChildren()) do
		if v206:IsA("Beam") then
			local v207 = v206:Clone()
			game.Debris:AddItem(v207, 10)
			v207.Parent = v197
			v207.Attachment0 = v201
			v207.Attachment1 = v200
			v207.Enabled = true
			task.delay(v199, function()
				if v207 and v207.Parent then
					v207.Enabled = false
				end
			end)
		end
	end
end

local function v183(v178, v179)
	if workspace.Thrown:FindFirstChild(v178) then
		local l_FirstChild_2 = workspace.Thrown:FindFirstChild(v178)
		if l_FirstChild_2:GetAttribute("Ownership") == tostring(v179) then
			return l_FirstChild_2
		end
	end
	
	for _, v182 in pairs(workspace.Thrown:GetChildren()) do
		if tostring(v182) == v178 and v182:GetAttribute("Ownership") == tostring(v179) then
			return v182
		end
	end
end

local VFXModule = {
	Wipe = {
		ManualVfxMarkers = {
			laser = function(v995)
				local l_FirstChild_3 = v995.Char:FindFirstChild("forget device")
				for _, v998 in pairs(l_FirstChild_3:GetDescendants()) do
					if v998:IsA("ParticleEmitter") then
						v998:Emit(v998:GetAttribute("EmitCount"))
					end
				end
			end
		}, 
		CutsceneData = {
			Anim = 120814069106650, 
			NoLerpAfter = true, 
			Offset = CFrame.new(3, -0.75, -2.85) * CFrame.Angles(0, -1.5707963267948966, 0), 
			From = "HumanoidRootPart"
		}
	}, 
	
	["Heart Strike"] = {
		TransparencyData = {
			DoTransparency = true, 
			TransparencyTime = 1.95, 
			FirstDelay = 1.8
		}, 
		ManualVfxMarkers = {
			TP = function(v999) 
				doShake({
					v999.targChar, 
					v999.Char
				}, 2)
				local l_Char_39 = v999.Char
				local l_cleanup_24 = v999.cleanup
				local v1002 = script.RealAssets["Heart Strike"].TP:Clone()
				game.Debris:AddItem(v1002, 4)
				v1002.Parent = workspace.Thrown
				v1002.CFrame = l_Char_39.PrimaryPart.CFrame
				table.insert(l_cleanup_24, v1002)
				v196(v1002)
			end, 
			TP1 = function(v1003) --[[ Line: 4902 ]]
				-- upvalues: v38 (copy), v196 (copy)
				doShake({
					v1003.targChar, 
					v1003.Char
				}, 2)
				local l_Char_40 = v1003.Char
				local l_cleanup_25 = v1003.cleanup
				local v1006 = script.RealAssets["Heart Strike"].TP2:Clone()
				game.Debris:AddItem(v1006, 4)
				v1006.Parent = l_Char_40
				v1006.CFrame = l_Char_40.Torso.CFrame
				table.insert(l_cleanup_25, v1006)
				v196(v1006)
				local v1007 = script.RealAssets["Heart Strike"].RealLightning:Clone()
				table.insert(l_cleanup_25, v1007)
				game.Debris:AddItem(v1007, 5)
				v1007.Parent = l_Char_40
				local l_Weld_5 = v1007:FindFirstChildOfClass("Weld")
				l_Weld_5.Part1 = v1007
				l_Weld_5.Part0 = l_Char_40["Right Arm"]
			end, 
			lightning = function(v1009) --[[ Line: 4928 ]]
				-- upvalues: v38 (copy)
				spawn(function() --[[ Line: 4931 ]]
					-- upvalues: v38 (ref), v1009 (copy)
					local v1010 = tick()
					while task.wait(0.05) and tick() - v1010 < 0.6 do
						doShake({
							v1009.targChar, 
							v1009.Char
						}, Random.new():NextNumber(1.25, 2.25))
					end
				end)
				local l_cleanup_26 = v1009.cleanup
				local l_Char_41 = v1009.Char
				local v1013 = script.RealAssets["Heart Strike"].Shock:Clone()
				table.insert(l_cleanup_26, v1013)
				game.Debris:AddItem(v1013, 5)
				v1013.Parent = workspace.Thrown
				v1013.CFrame = l_Char_41.PrimaryPart.CFrame * CFrame.new(0, 0, 3)
				task.delay(1.65, function() --[[ Line: 4954 ]]
					-- upvalues: v1013 (copy), l_Char_41 (copy)
					if not v1013 or v1013 and not v1013.Parent then
						return
					else
						if l_Char_41:FindFirstChild("RealLightning") then
							for _, v1015 in pairs(l_Char_41.RealLightning:GetDescendants()) do
								if v1015:IsA("Trail") or v1015:IsA("ParticleEmitter") or v1015:IsA("Beam") then
									v1015.Enabled = false
								end
							end
						end
						for _, v1017 in pairs(v1013:GetDescendants()) do
							if v1017:IsA("ParticleEmitter") then
								v1017.Enabled = false
							end
						end
						return
					end
				end)
			end
		}
	}, 
	
	Weak = {
		ManualVfxMarkers = {
			start = function(v846) --[[ Line: 4105 ]]
				local l_Humiliation_0 = script.RealAssets.Humiliation
				local l_Char_29 = v846.Char
				local l_cleanup_17 = v846.cleanup
				for _, v851 in pairs(l_Humiliation_0:GetChildren()) do
					if v851:IsA("ParticleEmitter") then
						local v852 = v851:Clone()
						v852:SetAttribute("HumiliationSpeed", true)
						v852.Parent = l_Char_29["Right Arm"]
						game.Debris:AddItem(v852, 5)
						table.insert(l_cleanup_17, v852)
					end
				end
				local v853 = l_Humiliation_0.Part.Punchbarrage:Clone()
				v853:SetAttribute("CleanupVfx", true)
				v853.Parent = v846.targChar.Head
				game.Debris:AddItem(v853, 5)
				table.insert(l_cleanup_17, v853)
				if l_Char_29 ~= game.Players.LocalPlayer.Character and v846.targChar ~= game.Players.LocalPlayer.Character then
					return
				else
					local v854 = tick()
					spawn(function() --[[ Line: 4130 ]]
						-- upvalues: v854 (copy), v853 (copy)
						while true do
							if task.wait(0.01) and tick() - v854 < 1.075 and v853 then
								if not v853.Parent then
									return
								else
									shared.addshake(0.65)
								end
							else
								return
							end
						end
					end)
					return
				end
			end, 
			
			stop = function(v855) --[[ Line: 4141 ]]
				local l_Char_30 = v855.Char
				local l_cleanup_18 = v855.cleanup
				local v861 = (function(v858) --[[ Line: 4143 ]]
					-- upvalues: l_cleanup_18 (copy)
					for _, v860 in pairs(l_cleanup_18) do
						if tostring(v860) ~= "Connection" and typeof(v860) ~= "thread" and v860:IsA("Attachment") and tostring(v860) == v858 and v860:GetAttribute("CleanupVfx") then
							return v860
						end
					end
				end)("Punchbarrage")
				if v861 then
					for _, v863 in pairs(v861:GetDescendants()) do
						if v863:IsA("ParticleEmitter") then
							v863.Enabled = false
						end
					end
					game.Debris:AddItem(v861, 2)
				end
				for _, v865 in pairs(l_Char_30["Right Arm"]:GetChildren()) do
					if v865.Name:find("Speedlines") and v865:GetAttribute("HumiliationSpeed") then
						v865.Enabled = false
						task.delay(1, function() --[[ Line: 4169 ]]
							-- upvalues: v865 (copy)
							if v865 and v865.Parent then
								return v865:Destroy()
							else
								return
							end
						end)
					end
				end
			end, 
			
			crack = function(v866)
				local v869 = script.RealAssets.Humiliation.Part.Necksnap:Clone()
				v869.Parent = v866.targChar.Head
				game.Debris:AddItem(v869, 10)
				v196(v869)
			end
		}
	}, 
	
	["Wombo Combo"] = {
		CutsceneData = {
			FindPart = "Cam"
		}, 
		StartupFunction = function(v941)
			local l_targChar_9 = v941.targChar
			local l_PrimaryPart_11 = v941.Char.PrimaryPart
			local l_Character_6 = game.Players.LocalPlayer.Character
			local v945 = false
			
			if l_Character_6 == v941.Char or l_Character_6 == l_targChar_9 then
				v945 = true
				l_PrimaryPart_11 = game.Players.LocalPlayer.PlayerGui
				l_Character_6 = 3
			end
			
			if not v945 then
				local _ = function(v946)
					spawn(function()
						local v947 = tick()
						local v948 = false
						repeat
							task.wait()
							for _, v950 in pairs(v946.Humanoid:GetPlayingAnimationTracks()) do
								warn(v950)
								if v950.Animation.AnimationId == "rbxassetid://90086322730233" or v950.Animation.AnimationId == "rbxassetid://135183042782013" then
									v950:Stop(0)
									v948 = true
								end
							end
						until v948 or tick() - v947 >= 0.01
					end)
				end
				
				for _, v953 in pairs({
					v941.Char, 
					v941.targChar
					}) do
					spawn(function() --[[ Line: 4620 ]]
						-- upvalues: v953 (copy)
						local v954 = tick()
						local v955 = false
						repeat
							task.wait()
							for _, v957 in pairs(v953.Humanoid:GetPlayingAnimationTracks()) do
								warn(v957)
								if v957.Animation.AnimationId == "rbxassetid://90086322730233" or v957.Animation.AnimationId == "rbxassetid://135183042782013" then
									v957:Stop(0)
									v955 = true
								end
							end
						until v955 or tick() - v954 >= 0.01
					end)
				end
				for _, v959 in pairs(v941.Char:GetDescendants()) do
					if v959:GetAttribute("EmoteProperty") then
						v959:Destroy("")
					end
				end
				(function() --[[ Line: 4647 ]]
					-- upvalues: v941 (copy)
					local l_Char_37 = v941.Char
					local v961 = require(l_Char_37.Client:FindFirstChild("AnimationPlayer") or l_Char_37.Client:WaitForChild("AnimationPlayer"))
					return function(v962)
						return v961.playAnimation(l_Char_37:FindFirstChild("Humanoid"), v962)
					end
				end)()(94685614125909):Play()
			end
			for _, v964 in pairs({
				"rbxassetid://102910011519143", 
				"rbxassetid://90417067966179"
				}) do
				local v965 = 4.5
				if v964 == "rbxassetid://90417067966179" then
					v965 = 3
				elseif l_Character_6 == 3 then
					v965 = 2.5
				end
				local v966 = shared.sfx({
					SoundId = v964, 
					Parent = l_PrimaryPart_11, 
					Volume = v965
				})
				v966:Play()
				table.insert(v941.cleanup, v966)
			end
		end, 
		
		RealModule = script.VfxMods["2v1"],
		
		ManualVfxMarkers = {
			kick = function(v967)
				local l_targChar_10 = v967.targChar
				local l_Char_38 = v967.Char
				local l_Character_7 = game.Players.LocalPlayer.Character
				if l_Character_7 == l_Char_38 or l_targChar_10 == l_Character_7 then
					for _, v972 in pairs(l_Char_38:GetDescendants()) do
						if v972:IsA("Part") and v972:GetAttribute("Custom2V1CAM") then
							v972:Destroy("")
						end
					end
				end
				if l_Char_38 == game.Players.LocalPlayer.Character then
					local l_Position_3 = l_targChar_10.PrimaryPart.Position
					local v974 = tick()
					local v975 = nil
					do
						local l_v975_0 = v975
						l_v975_0 = game:GetService("RunService").Heartbeat:Connect(function()
							if tick() - v974 > 0.1 then
								workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
								game.Players.LocalPlayer.CameraMinZoomDistance = 0.5
								game.Players.LocalPlayer.CameraMaxZoomDistance = 128
								return l_v975_0:Disconnect()
							else
								workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
								workspace.CurrentCamera.FieldOfView = 70
								game.Players.LocalPlayer.CameraMaxZoomDistance = 45
								workspace.CurrentCamera.CFrame = CFrame.new(l_Char_38.PrimaryPart.Position, l_Position_3)
								return
							end
						end)
						
						task.delay(0.1, function()
							doShake()({
								l_Char_38, 
								l_targChar_10
							}, 4, 0.5)
						end)
					end
				end
				
				v967.RealAnim:Stop(0.8)
			end
		}
	}, 
	
	["Explosive Stomps"] = {
		CanRotate = true, 
		ManualVfxMarkers = {
			stomp = function(v712) --[[ Line: 3445 ]]
				-- upvalues: v38 (copy), v177 (copy), v196 (copy)
				local l_Char_16 = v712.Char
				local _ = v712.cleanup
				local v715 = script.RealAssets["Explosive Stomps"]
				if not v712.stompcount then
					v712.stompcount = 1
				else
					v712.stompcount = v712.stompcount + 1
				end
				local function _(v716, v717) --[[ Line: 3456 ]]
					local l_WeldConstraint_2 = Instance.new("WeldConstraint")
					l_WeldConstraint_2.Parent = v716
					l_WeldConstraint_2.Part0 = v716
					l_WeldConstraint_2.Part1 = v717.PrimaryPart
				end
				if v712.stompcount ~= 2 then
					local v720 = 2 + v712.stompcount / 10
					doShake({
						l_Char_16, 
						v712.targChar
					}, v720)
				end
				({
					[1] = function() --[[ Line: 3477 ]]
						-- upvalues: v177 (ref), l_Char_16 (copy), v715 (copy), v712 (copy), v196 (ref)
						local v721 = v177(l_Char_16, v715.NormalImpact)
						table.insert(v712.cleanup, v721)
						v196(v721)
						local l_l_Char_16_0 = l_Char_16
						local l_WeldConstraint_3 = Instance.new("WeldConstraint")
						l_WeldConstraint_3.Parent = v721
						l_WeldConstraint_3.Part0 = v721
						l_WeldConstraint_3.Part1 = l_l_Char_16_0.PrimaryPart
						v712.first = v721
					end, 
					[2] = function() --[[ Line: 3485 ]]
						-- upvalues: v177 (ref), l_Char_16 (copy), v715 (copy), v712 (copy), v196 (ref), v38 (ref)
						local v724 = v177(l_Char_16, v715.ImpactEnabled)
						table.insert(v712.cleanup, v724)
						v196(v724)
						local l_l_Char_16_1 = l_Char_16
						local l_WeldConstraint_4 = Instance.new("WeldConstraint")
						l_WeldConstraint_4.Parent = v724
						l_WeldConstraint_4.Part0 = v724
						l_WeldConstraint_4.Part1 = l_l_Char_16_1.PrimaryPart
						for _, v728 in pairs(v724:GetDescendants()) do
							if v728:IsA("ParticleEmitter") then
								task.spawn(function() --[[ Line: 3493 ]]
									-- upvalues: v728 (copy)
									v728.Enabled = true
								end)
							end
						end
						v712.impactenabled = v724
						spawn(function() --[[ Line: 3501 ]]
							-- upvalues: v724 (copy), v712 (ref), v38 (ref), l_Char_16 (ref)
							local v729 = tick()
							while true do
								if task.wait(0.015) and tick() - v729 < 3 and v724 and v724.Parent then
									if v712.stophere then
										return
									else
										doShake({
											l_Char_16, 
											v712.targChar
										}, 1)
									end
								else
									return
								end
							end
						end)
					end, 
					[3] = function() --[[ Line: 3516 ]]
						-- upvalues: v712 (copy)
						v712.stophere = true
						for _, v731 in pairs(v712.impactenabled:GetDescendants()) do
							if v731:IsA("ParticleEmitter") then
								task.spawn(function() --[[ Line: 3521 ]]
									-- upvalues: v731 (copy)
									v731:Emit(v731:GetAttribute("EmitCount"))
									v731.Enabled = false
								end)
							end
						end
					end, 
					[4] = function() --[[ Line: 3529 ]]
						-- upvalues: v712 (copy)
						for _, v733 in pairs(v712.first:GetDescendants()) do
							if v733:IsA("ParticleEmitter") then
								task.spawn(function() --[[ Line: 3532 ]]
									-- upvalues: v733 (copy)
									v733:Emit(v733:GetAttribute("EmitCount"))
								end)
							end
						end
					end, 
					[5] = function() --[[ Line: 3539 ]]
						-- upvalues: v712 (copy), v196 (ref)
						warn(v712.first)
						v196(v712.first)
					end, 
					[6] = function() --[[ Line: 3543 ]]
						-- upvalues: v196 (ref), v712 (copy)
						v196(v712.first)
					end, 
					[7] = function() --[[ Line: 3547 ]]
						-- upvalues: v177 (ref), l_Char_16 (copy), v715 (copy), v712 (copy), v196 (ref)
						local v734 = v177(l_Char_16, v715.Impact2)
						table.insert(v712.cleanup, v734)
						v196(v734)
						local l_l_Char_16_2 = l_Char_16
						local l_WeldConstraint_5 = Instance.new("WeldConstraint")
						l_WeldConstraint_5.Parent = v734
						l_WeldConstraint_5.Part0 = v734
						l_WeldConstraint_5.Part1 = l_l_Char_16_2.PrimaryPart
						for _, v738 in pairs(v734:GetDescendants()) do
							if v738:IsA("ParticleEmitter") then
								task.spawn(function() --[[ Line: 3555 ]]
									-- upvalues: v738 (copy)
									v738:Emit(v738:GetAttribute("EmitCount"))
								end)
							end
						end
					end
				})[v712.stompcount]()
			end, 
			laststomp = function(v739) --[[ Line: 3567 ]]
				-- upvalues: v177 (copy), v196 (copy)
				local l_Char_17 = v739.Char
				local v741 = script.RealAssets["Explosive Stomps"]
				local v742 = v177(l_Char_17, v741.LastImpact)
				v196(v742)
				for _, v744 in pairs(v742:GetDescendants()) do
					if v744:IsA("ParticleEmitter") then
						task.spawn(function() --[[ Line: 3577 ]]
							-- upvalues: v744 (copy)
							v744:Emit(v744:GetAttribute("EmitCount"))
						end)
					end
				end
			end
		}, 
		DontDisconnectMarkers = true
	}, 
	
	["Eternal Seal"] = {
		CutsceneData = {
			Anim = 74807066629923, 
			Offset = CFrame.new(0, 0, 0), 
			From = "HumanoidRootPart", 
			SpecificRig = script.Assets.CamRig, 
			ActualPart = "CameraPart", 
			NoLerp = true
		}, 
		Tasks = {
			[9] = function(v985)
				local l_cleanup_23 = v985.cleanup
				for _, v988 in pairs(l_cleanup_23) do
					if typeof(v988) ~= "Instance" then
						warn((typeof(v988)))
					end
					if typeof(v988) == "Instance" and v988.Parent and v988:IsA("Model") and v988.Parent == v985.Char and v988:GetAttribute("CameraModel") then
						v988:SetAttribute("ForceDestroy", true)
						local l_PrimaryPart_13 = v985.Char.PrimaryPart
						if game.Players.LocalPlayer.Character == v985.Char then
							local l_CurrentCamera_3 = workspace.CurrentCamera
							local v991 = l_PrimaryPart_13.CFrame * CFrame.new(0.121032715, 4.415802, 15.8661346, 0.999988973, -7.91892409E-4, 0.00464361906, -2.88034645E-8, 0.985767841, 0.168112651, -0.00471064448, -0.168110803, 0.985756874)
							l_CurrentCamera_3.CFrame = CFrame.new(v991.Position, (l_PrimaryPart_13.CFrame + l_PrimaryPart_13.CFrame.lookVector * 10).Position + Vector3.new(0, 2, 0, 0))
							l_CurrentCamera_3.CameraType = Enum.CameraType.Custom
							local v992 = tick()
							local v993 = nil
							do
								local l_v993_0 = v993
								l_v993_0 = game:GetService("RunService").Heartbeat:Connect(function()
									if tick() - v992 > 0.15 then
										return l_v993_0:Disconnect()
									else
										l_CurrentCamera_3.CFrame = CFrame.new(v991.Position, (l_PrimaryPart_13.CFrame + l_PrimaryPart_13.CFrame.lookVector * 10).Position)
										return
									end
								end)
							end
						end
						return
					end
				end
			end
		}
	}, 
	
	["Last Will"] = {
		StartupFunction = function(v924)
			local v925 = nil
			v925 = task.delay(2.2, function()
				if v924.Char ~= game.Players.LocalPlayer.Character and v924.targChar ~= game.Players.LocalPlayer.Character then
					return
				else
					v924.CameraPart = shared.CutsceneEvent({
						Anim = 111682516707148, 
						Offset = CFrame.new(0, -2.5, 0) * CFrame.Angles(0, 3.141592653589793, 0), 
						From = v924.Char.PrimaryPart, 
						SpecificRig = script.Assets.CamRigWithLetterBox, 
						ActualPart = "camera", 
						DontDestroy = true, 
						Fov = script.Fovs["Last Will"], 
						Name = "Last Will", 
						Char = v924.Char
					})
				end
				return
			end)
			table.insert(v924.cleanup, v925)
			local l_targChar_7 = v924.targChar
			local l_PrimaryPart_10 = v924.Char.PrimaryPart
			local l_Character_5 = game.Players.LocalPlayer.Character
			if l_Character_5 == v924.Char or l_Character_5 == l_targChar_7 then
				l_PrimaryPart_10 = game.Players.LocalPlayer.PlayerGui
				l_Character_5 = 3
			end
			local v930 = shared.sfx({
				SoundId = "rbxassetid://128113133587505", 
				Parent = l_PrimaryPart_10, 
				Volume = l_PrimaryPart_10 == game.Players.LocalPlayer.PlayerGui and 3 or 5
			})
			v930:Play()
			table.insert(v924.cleanup, v930)
		end, 
		RealModule = script.VfxMods.LastWill, 
		ManualVfxMarkers = {
			send = function(v931)
				local l_Char_36 = v931.Char
				local l_targChar_8 = v931.targChar
				if l_Char_36 == game.Players.LocalPlayer.Character or l_targChar_8 == game.Players.LocalPlayer.Character then
					wait(0.1)
					for _, v935 in pairs(l_Char_36:GetChildren()) do
						if tostring(v935) == "CamRigWithLetterBox" then
							v935:Destroy("")
						end
					end
					
					local l_Position_2 = l_targChar_8.PrimaryPart.Position
					local v937 = tick()
					local v938 = nil
					do
						local l_v938_0 = v938
						l_v938_0 = game:GetService("RunService").Heartbeat:Connect(function()
							if tick() - v937 > 0.1 then
								workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
								game.Players.LocalPlayer.CameraMinZoomDistance = 0.5
								game.Players.LocalPlayer.CameraMaxZoomDistance = 128
								return l_v938_0:Disconnect()
							else
								workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
								workspace.CurrentCamera.FieldOfView = 70
								game.Players.LocalPlayer.CameraMaxZoomDistance = 45
								local l_CFrame_7 = workspace.CurrentCamera.CFrame
								workspace.CurrentCamera.CFrame = l_CFrame_7:Lerp(CFrame.new(l_Char_36.PrimaryPart.Position, l_Position_2), 0.15)
								return
							end
						end)
						
						task.delay(0.1, function()
							doShake()({
								l_Char_36,
							}, 4, 0.5)
						end)
					end
				end
			end
		}
	}, 
	
	["Sure Hit"] = {
		TransparencyData = {
			DoTransparency = true, 
			TransparencyTime = 0.7
		}, 
		CutsceneData = {
			Anim = 102369563143078, 
			NoLerpAfter = true, 
			Offset = CFrame.new(0, 1, 0) * CFrame.Angles(0, 3.141592653589793, 0), 
			From = "HumanoidRootPart"
		}, 
		Startup = function(v748) --[[ Line: 3622 ]] --[[ Name: Startup ]]
			local v749 = nil
			v749 = shared.sfx({
				SoundId = "rbxassetid://127118341793623", 
				Parent = v748.targChar.Torso, 
				Volume = 2, 
				RollOffMaxDistance = 85
			})
			v749:Play()
			table.insert(v748.cleanup, v749)
		end, 
		ManualVfxMarkers = {
			rip = function(v750) --[[ Line: 3634 ]]
				-- upvalues: l_RealAssets_0 (copy), v196 (copy), v208 (copy), v183 (copy), l_TweenService_0 (copy)
				local l_Char_19 = v750.Char
				local l_Character_2 = game.Players.LocalPlayer.Character
				local v753 = true
				if l_Character_2 ~= l_Char_19 then
					v753 = l_Character_2 == v750.targChar
				end
				local v754 = RealAssetsFolder["Head Rip"].Background:Clone()
				v754.Parent = workspace.Thrown
				v754.Anchored = true
				v754.CFrame = l_Char_19.PrimaryPart.CFrame * CFrame.new(0, 1, -2) * CFrame.Angles(0, 1.5707963267948966, 0)
				v196(v754)
				v208(v750.targChar.Torso, RealAssetsFolder["Head Rip"].Beams, 1.75)
				local v755 = v183("DomainRipEmote", v750.Char)
				TweenService:Create(v755, TweenInfo.new(0.1), {
					Color = Color3.fromRGB(255, 255, 255)
				}):Play()
				local v756 = {}
				if v753 then
					for _, v758 in pairs({
						l_Char_19, 
						v750.targChar
						}) do
						local l_Highlight_1 = Instance.new("Highlight")
						l_Highlight_1.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						l_Highlight_1.FillColor = Color3.fromRGB(0, 0, 0)
						l_Highlight_1.FillTransparency = 0
						l_Highlight_1.OutlineTransparency = 1
						l_Highlight_1.Parent = v758
						game.Debris:AddItem(l_Highlight_1, 5)
						table.insert(v750.cleanup, l_Highlight_1)
						table.insert(v756, l_Highlight_1)
					end
				end
				wait(1.8)
				for _, v761 in pairs(v756) do
					game:GetService("TweenService"):Create(v761, TweenInfo.new(0.15), {
						FillTransparency = 1
					}):Play()
				end
				if not v755 then
					return
				else
					if v755 then
						table.remove(v750.cleanup, table.find(v750.cleanup, v755))
					end
					pcall(function() --[[ Line: 3689 ]]
						-- upvalues: v755 (copy), v750 (copy), l_TweenService_0 (ref)
						local _ = nil
						shared.sfx({
							SoundId = "rbxassetid://88322619657020", 
							CFrame = v755.CFrame, 
							Volume = 4, 
							RollOffMaxDistance = 85
						}):Play()
						local l_Callback_0 = v750.Callback
						v755:SetAttribute("DelayDeletion", 4)
						v755.Attachment["1"]:Emit(60)
						TweenService:Create(v755, TweenInfo.new(0.1), {
							Transparency = 1
						}):Play()
						if l_Callback_0[1] then
							l_Callback_0[1]()
						end
					end)
					return
				end
			end, 
			touch = function(v764) --[[ Line: 3708 ]]
				-- upvalues: l_RealAssets_0 (copy), l_TweenService_0 (copy)
				local l_cleanup_11 = v764.cleanup
				local l_Char_20 = v764.Char
				local l_Character_3 = game.Players.LocalPlayer.Character
				local v768 = true
				if l_Character_3 ~= l_Char_20 then
					v768 = l_Character_3 == v764.targChar
				end
				if not v768 then

				end
				local v769 = RealAssetsFolder["Head Rip"].DomainRipEmote:Clone()
				game.Debris:AddItem(v769, 8)
				v769.Anchored = true
				if not v768 then
					v769.Size = v769.Size * 1.5
				end
				v769.Parent = workspace.Thrown
				v769:SetAttribute("Ownership", (tostring(l_Char_20)))
				table.insert(l_cleanup_11, v769)
				v769.CFrame = l_Char_20.PrimaryPart.CFrame * CFrame.new(0, 4, 0)
				TweenService:Create(v769, TweenInfo.new(0.35), {
					Transparency = 0
				}):Play()
			end
		}
	}, 
	
	Ruthless = {
		CutsceneData = {
			Anim = 140561726291979, 
			Offset = CFrame.new() * CFrame.Angles(0, 3.141592653589793, 0), 
			From = "HumanoidRootPart", 
			SpecificRig = script.Assets.CamRigWithLetterBox3, 
			ActualPart = "camera", 
			NoLerpAfter = true
		}, 
		DontDisconnectMarkers = true, 
		StartupFunction = function(v820) --[[ Line: 3969 ]] --[[ Name: StartupFunction ]]
			local l_cleanup_14 = v820.cleanup
			local l_Char_26 = v820.Char
			local v823 = script.RealAssets.RuthlessCombo["Stone Wall"]:Clone()
			game.Debris:AddItem(v823, 5)
			table.insert(l_cleanup_14, v823)
			v823.Parent = workspace.Thrown
			v823:SetAttribute("Owner", (tostring(l_Char_26)))
			v823:SetPrimaryPartCFrame(l_Char_26.PrimaryPart.CFrame * CFrame.new(0, 0, -0.25))
			local v824 = nil
			v824 = shared.sfx({
				SoundId = "rbxassetid://88410636702731", 
				Parent = v823.handle, 
				Volume = 4, 
				RollOffMaxDistance = l_Char_26 == game.Players.LocalPlayer.Character and 150 or 80
			})
			v824:Play()
			table.insert(l_cleanup_14, v824)
			local l_Animation_3 = Instance.new("Animation")
			game.Debris:AddItem(l_Animation_3, 6)
			l_Animation_3.AnimationId = "rbxassetid://92058776469297"
			l_Animation_3.Parent = workspace.Thrown
			table.insert(l_cleanup_14, l_Animation_3)
			local v826 = v823.AnimationController:LoadAnimation(l_Animation_3)
			v826:Play()
			local v827 = nil
			v827 = v826.Stopped:Connect(function() --[[ Line: 3999 ]]
				-- upvalues: v823 (copy), l_Char_26 (copy)
				if v823 and v823.Parent then
					v823:SetPrimaryPartCFrame(l_Char_26.PrimaryPart.CFrame * CFrame.new(0, 0, -4.5))
					return
				else
					return
				end
			end)
			task.delay(5, function() --[[ Line: 4006 ]]
				-- upvalues: v827 (ref)
				if v827 then
					return v827:Disconnect()
				else
					return
				end
			end)
		end, 
		ManualVfxMarkers = {
			punch = function(v828) --[[ Line: 4014 ]]
				-- upvalues: v196 (copy)
				local v829 = nil
				local l_cleanup_15 = v828.cleanup
				local l_Char_27 = v828.Char
				if l_Char_27:FindFirstChild("RuthlessComboPart") then
					v829 = l_Char_27:FindFirstChild("RuthlessComboPart")
				else
					local v832 = script.RealAssets.RuthlessCombo.RuthlessComboPart:Clone()
					game.Debris:AddItem(v832, 5)
					table.insert(l_cleanup_15, v832)
					v832.Parent = l_Char_27
					v832.CFrame = l_Char_27.PrimaryPart.CFrame * CFrame.new(0.115600586, 0.263999939, -3.45088959, -1, 0, -8.74227766E-8, 0, 1, 0, 8.74227766E-8, 0, -1)
					v829 = v832
				end
				if not v829 or not v829.Parent then
					return
				else
					v196(v829, l_Char_27, {
						Exclude = v829.BigHit
					})
					return
				end
			end, 
			heavypunch = function(v833) --[[ Line: 4041 ]]
				-- upvalues: l_TweenService_0 (copy)
				local _ = v833.cleanup
				local l_Char_28 = v833.Char
				if l_Char_28:FindFirstChild("RuthlessComboPart") then
					local v836 = script.RealAssets.RuthlessCombo.Wide:Clone()
					v836.CFrame = l_Char_28.PrimaryPart.CFrame * CFrame.new(2, 0, -3.65) * CFrame.Angles(0, 1.5707963267948966, 0)
					v836.Parent = workspace.Thrown
					game:GetService("Debris"):AddItem(v836, 5)
					for _, v838 in pairs(v836:GetDescendants()) do
						if v838:IsA("ParticleEmitter") then
							shared.resizeparticle(v838, 2)
							v838.Speed = NumberRange.new(v838.Speed.Min * 1.85, v838.Speed.Max * 1.85)
							v838.Lifetime = NumberRange.new(v838.Lifetime.Min * 0.5, v838.Lifetime.Max * 0.5)
							v838:Emit(v838:GetAttribute("EmitCount") * 2)
						end
					end
					local v839 = nil
					for _, v841 in pairs(workspace.Thrown:GetChildren()) do
						if tostring(v841) == "Stone Wall" and v841:GetAttribute("Owner") == tostring(l_Char_28) then
							v839 = v841
							break
						end
					end
					table.remove(v833.cleanup, table.find(v833.cleanup, v839))
					for _, v843 in pairs(v839:GetDescendants()) do
						if v843:IsA("Motor6D") then
							v843:Destroy()
						elseif v843:IsA("MeshPart") then
							task.delay(0.6, function()
								if v843 and v843.Parent then
									TweenService:Create(v843, TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
										Size = Vector3.new(0, 0, 0, 0)
									}):Play()
								end
							end)
							local l_BodyVelocity_0 = Instance.new("BodyVelocity")
							l_BodyVelocity_0.Parent = v843
							l_BodyVelocity_0.Velocity = l_Char_28.PrimaryPart.CFrame.lookVector * math.random(80, 120) + Vector3.new(0, math.random(10, 30), 0) * Random.new():NextNumber(1.2, 1.35)
							l_BodyVelocity_0.MaxForce = Vector3.new(40000, 40000, 40000, 0)
							game.Debris:AddItem(l_BodyVelocity_0, Random.new():NextNumber(0.1, 0.2))
							local l_BodyAngularVelocity_0 = Instance.new("BodyAngularVelocity")
							l_BodyAngularVelocity_0.AngularVelocity = Vector3.new(math.random(-10, 10), math.random(-5, 5), math.random(-6, 6)) * Random.new():NextNumber(0.5, 1)
							l_BodyAngularVelocity_0.MaxTorque = Vector3.new(2000000000, 2000000000, 2000000000, 0)
							l_BodyAngularVelocity_0.Parent = v843
							game:service("Debris"):AddItem(l_BodyAngularVelocity_0, 0.15)
						end
					end
				end
			end
		}
	}, 
	
	["STILL FUNNY?"] = {
		CutsceneData = {
			Anim = 86760269714475, 
			Offset = CFrame.new(), 
			From = "HumanoidRootPart", 
			SpecificRig = script.Assets.CameraFunny, 
			ActualPart = "CamPart"
		}, 
		StartupFunction = function(v406) --[[ Line: 1987 ]] --[[ Name: StartupFunction ]]
			-- upvalues: v177 (copy), v38 (copy), v220 (copy)
			local l_Char_2 = v406.Char
			local _ = v406.Char.PrimaryPart
			local l_targChar_0 = v406.targChar
			local l_cleanup_2 = v406.cleanup
			local l_RealAnim_1 = v406.RealAnim
			local v412 = script.RealAssets["Still Funny?"]
			local _ = {}
			local v414 = 0
			local v415 = nil
			local v416 = nil
			local l_Character_1 = game.Players.LocalPlayer.Character
			local v418 = true
			if l_Char_2 ~= l_Character_1 then
				v418 = v406.CutsceneBind == l_Character_1
			end
			if v418 then

			end
			for _, v420 in pairs({
				"rbxassetid://130653712697442", 
				"rbxassetid://111397430619699", 
				"rbxassetid://108608355070942"
				}) do
				local v421 = 6
				local v422 = v420 == "rbxassetid://108608355070942" and l_targChar_0.PrimaryPart or v420 == "rbxassetid://111397430619699" and l_Char_2.PrimaryPart
				if v418 then
					v421 = v421 / 2
					v422 = game.Players.LocalPlayer.PlayerGui
				end
				if not v422 then
					v422 = l_Char_2.Torso
				end
				local v423 = shared.sfx({
					SoundId = v420, 
					Volume = v421, 
					Parent = v418 and game.Players.LocalPlayer.PlayerGui or v422
				})
				v423:Play()
				table.insert(l_cleanup_2, v423)
			end
			local v424 = 0
			local v446 = {
				punch = function() --[[ Line: 2038 ]]
					-- upvalues: v177 (ref), l_targChar_0 (copy), v412 (copy), l_cleanup_2 (copy)
					local v425 = v177(l_targChar_0, v412.Start)
					table.insert(l_cleanup_2, v425)
					game.Debris:AddItem(v425, 10)
					for _, v427 in v425:GetDescendants() do
						if v427:IsA("ParticleEmitter") then
							task.spawn(function() --[[ Line: 2046 ]]
								-- upvalues: v427 (copy)
								if v427:GetAttribute("EmitDelay") then
									task.wait(v427:GetAttribute("EmitDelay"))
								end
								v427:Emit(v427:GetAttribute("EmitCount"))
							end)
						end
					end
				end, 
				emit = function() --[[ Line: 2056 ]]
					-- upvalues: v414 (ref), v416 (ref), v177 (ref), l_targChar_0 (copy), v412 (copy), l_cleanup_2 (copy), l_Char_2 (copy)
					v414 = v414 + 1
					if not v416 then
						v416 = v177(l_targChar_0, v412.BasicHit)
						table.insert(l_cleanup_2, v416)
						game.Debris:AddItem(v416, 10)
					end
					for _, v429 in v416:GetDescendants() do
						if v429:IsA("ParticleEmitter") then
							v429:Emit(v429:GetAttribute("EmitCount"))
						end
					end
					if v414 == 3 then
						local l_TweenService_4 = game:GetService("TweenService")
						local v431 = v177(l_targChar_0, v412.SphereBlocked)
						v431.Transparency = 0.125
						table.insert(l_cleanup_2, v431)
						game.Debris:AddItem(v431, 10)
						local v432 = v177(l_targChar_0, v412.AP)
						table.insert(l_cleanup_2, v432)
						game.Debris:AddItem(v432, 10)
						local l_Motor6D_2 = Instance.new("Motor6D")
						table.insert(l_cleanup_2, l_Motor6D_2)
						l_Motor6D_2.C1 = CFrame.new(0, -0.217, 0)
						l_Motor6D_2.Part0 = l_Char_2["Left Arm"]
						l_Motor6D_2.Part1 = v432
						l_Motor6D_2.Parent = l_Char_2["Left Arm"]
						for _, v435 in v432:GetDescendants() do
							if v435:IsA("ParticleEmitter") then
								task.spawn(function() --[[ Line: 2091 ]]
									-- upvalues: v435 (copy)
									v435:Emit(v435:GetAttribute("EmitCount") * 2)
									v435.Enabled = true
									task.wait(v435:GetAttribute("EmitDuration"))
									v435.Enabled = false
								end)
							end
						end
						local v436 = v177(l_targChar_0, v412.Blocked)
						table.insert(l_cleanup_2, v436)
						game.Debris:AddItem(v436, 10)
						for _, v438 in v436:GetDescendants() do
							if v438:IsA("ParticleEmitter") then
								task.spawn(function() --[[ Line: 2105 ]]
									-- upvalues: v438 (copy)
									if v438:GetAttribute("EmitDelay") then
										task.wait(v438:GetAttribute("EmitDelay"))
									end
									v438:Emit(v438:GetAttribute("EmitCount") * 2)
								end)
							end
						end
						local v439 = TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
						task.wait(0.25)
						if not v436 or not v436.Parent then
							return
						else
							l_TweenService_4:Create(v431, v439, {
								Transparency = 1
							}):Play()
						end
					end
				end, 
				headbutt = function() --[[ Line: 2125 ]]
					-- upvalues: v415 (ref), v177 (ref), l_targChar_0 (copy), v412 (copy), l_cleanup_2 (copy), v424 (ref), v38 (ref), l_Char_2 (copy)
					if not v415 then
						v415 = v177(l_targChar_0, v412.HeadHit)
						table.insert(l_cleanup_2, v415)
						game.Debris:AddItem(v415, 10)
					end
					for _, v441 in v415:GetDescendants() do
						if v441:IsA("ParticleEmitter") then
							v441:Emit(v441:GetAttribute("EmitCount"))
						end
					end
					v424 = v424 + 1
					if v424 == 6 then
						local l_Accessory_2 = Instance.new("Accessory")
						l_Accessory_2.Name = "CancelCutscene"
						l_Accessory_2.Parent = workspace
						game.Debris:AddItem(l_Accessory_2, 0.25)
						doShake({
							l_Char_2
						}, 3, 0.25)
					end
				end, 
				last = function() --[[ Line: 2152 ]]
					-- upvalues: v412 (copy), l_Char_2 (copy), l_cleanup_2 (copy)
					local v443 = v412.Part.Attachment:Clone()
					v443.Parent = l_Char_2.Head
					table.insert(l_cleanup_2, v443)
					game.Debris:AddItem(v443, 10)
					for _, v445 in v443:GetChildren() do
						if v445:IsA("ParticleEmitter") then
							task.spawn(function()
								v445:Emit(v445:GetAttribute("EmitCount"))
								v445.Enabled = true
								task.wait(v445:GetAttribute("EmitDuration"))
								v445.Enabled = false
							end)
						end
					end
				end
			}
			v220({
				anim = l_RealAnim_1, 
				markers = v446, 
				DontDisconnectMarkers = true, 
				sendingdata = v406, 
				cleanup = l_cleanup_2
			})
		end
	}, 
	
	["Fly High"] = {
		Tasks = {
			[2.35] = function(v1018) 
				local l_Char_42 = v1018.Char
				local l_cleanup_27 = v1018.cleanup
				local v1021 = script.RealAssets["To Brazil"].Portall:Clone()
				table.insert(l_cleanup_27, v1021)
				game.Debris:AddItem(v1021, 7)
				v1021.Parent = l_Char_42
				local l_Weld_6 = v1021:FindFirstChildOfClass("Weld")
				table.insert(l_cleanup_27, l_Weld_6)
				game.Debris:AddItem(l_Weld_6, 7)
				l_Weld_6.Part0 = l_Char_42.PrimaryPart
				l_Weld_6.Part1 = v1021
				l_Weld_6.Parent = l_Char_42.PrimaryPart
				
				for _, v1024 in pairs(v1021.Enable:GetChildren()) do
					if v1024.Name ~= "BR" then
						v1024:Emit(v1024:GetAttribute("EmitCount"))
					end
				end
				
				local _ = nil
				
				table.insert(l_cleanup_27, (task.delay(2, function()
					if v1021 and v1021.Parent then
						local function v1030(v1026)
							for _, v1028 in pairs(v1021:GetDescendants()) do
								if v1028:IsA("ParticleEmitter") and v1028.Parent.Name:find("Attachment") then
									local v1029 = true
									if v1026 and v1028.Parent.Name ~= "Attachment" then
										v1029 = false
									end
									if v1029 then
										v1028:Emit(v1028:GetAttribute("EmitCount") / 1.25)
									end
								end
							end
						end
						v1030()
						local v1031 = nil
						v1031 = task.delay(1.15, function() 
							local function v1037(v1032)
								for _, v1034 in pairs(v1021:GetChildren()) do
									if tostring(v1034) == v1032 then
										for _, v1036 in pairs(v1034:GetChildren()) do
											v1036.Enabled = false
										end
									end
								end
							end
							for _, v1039 in pairs({
								"Beam", 
								"MainPortal"
								}) do
								v1037(v1039)
							end
							
							task.delay(0.1, function()
								if v1021 and v1021.Parent then
									v1021.Enable.BR:Emit(1)
									v1030(true)
								end
							end)
						end)
						table.insert(l_cleanup_27, v1031)
						return
					else
						return
					end
				end)))
			end
		}, 
		
		CutsceneData = {
			Anim = 104759333433670, 
			Offset = CFrame.new(0, -2.5, 0) * CFrame.Angles(0, 3.141592653589793, 0), 
			From = "HumanoidRootPart", 
			SpecificRig = script.Assets.CamRigWithLetterBox2, 
			ActualPart = "camera"
		}
	},
	
	["Time Shift"] = {
		StartupFunction = function(v505)
			local l_Char_5 = v505.Char
			local l_PrimaryPart_6 = v505.Char.PrimaryPart
			local l_targChar_3 = v505.targChar
			local l_cleanup_5 = v505.cleanup
			local l_RealAnim_4 = v505.RealAnim
			local v511 = script.RealAssets["Time Shift"]
			local l_l_TweenService_0_0 = TweenService
			local _ = {}
			local v514 = {}
			
			for _, v516 in pairs(l_Char_5:GetChildren()) do
				if v516:IsA("BasePart") then
					v514[v516.Name] = v516.CFrame
				end
			end

			local v517 = game.ReplicatedStorage.Resources.Clone_Rig:Clone()
			table.insert(l_cleanup_5, v517)
			game.Debris:AddItem(v517, 9)
			v517.Parent = workspace.Thrown
			v517.PrimaryPart.Anchored = true
			v517.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			v517.Humanoid:ApplyDescription(l_Char_5.Humanoid:GetAppliedDescription())
			table.insert(VfxModules, v517)
			for _, v519 in pairs(v517:GetDescendants()) do
				if v519:IsA("BasePart") then
					v519.CollisionGroup = "untouchable"
					v519.Massless = true
					v519.CanCollide = false
					v519.CanTouch = false
					v519.CanQuery = false
					v519.Anchored = false
				end
			end
			v517.PrimaryPart.Anchored = true
			
			v517:SetPrimaryPartCFrame(l_PrimaryPart_6.CFrame * CFrame.new(0, 1000, 0))
			task.delay(0.65, function()
				if v517 and v517.Parent then
					v517:SetPrimaryPartCFrame(l_PrimaryPart_6.CFrame)
				end
			end)
			
			local l_Animation_2 = Instance.new("Animation")
			game.Debris:AddItem(l_Animation_2, 6)
			table.insert(l_cleanup_5, l_Animation_2)
			l_Animation_2.AnimationId = "rbxassetid://119172195200261"
			local v521 = v517.Humanoid:LoadAnimation(l_Animation_2)
			v521:Play()
			v521.TimePosition = l_RealAnim_4.TimePosition
			local function _(v522, v523) --[[ Line: 2511 ]] --[[ Name: ye ]]
				-- upvalues: l_cleanup_5 (copy)
				table.insert(l_cleanup_5, v522)
				game.Debris:AddItem(v522, v523)
			end
			local _ = {}
			local v611 = {
				MirageFade = function() --[[ Line: 2520 ]]
					-- upvalues: v517 (copy), v511 (copy), v177 (ref), l_Char_5 (copy), l_l_TweenService_0_0 (copy)
					local l_v517_0 = v517
					local v527 = v511.RigClone:Clone()
					v527.Parent = workspace.Thrown
					for _, v529 in v527:GetChildren() do
						if v529:IsA("BasePart") and l_v517_0:FindFirstChild((tostring(v529))) then
							v529.CFrame = l_v517_0[v529.Name].CFrame
							v529.Color = Color3.fromRGB(0, 0, 0)
							v529.Material = Enum.Material.Neon
						end
					end
					v177(l_Char_5, v511.Shine).Shine:Emit(7)
					local v530 = v511.SparkleDestroy.Stars:Clone()
					v530.Parent = v527.Head
					v530.Enabled = true
					local v531 = {
						Size = Vector3.new(1.2000000476837158, 0, 1.2000000476837158, 0), 
						CFrame = v527.Head.CFrame * CFrame.new(0, -0.6, 0)
					}
					local v532 = TweenInfo.new(0.25, Enum.EasingStyle.Linear)
					l_l_TweenService_0_0:Create(v527.Head, v532, v531):Play()
					local v533 = v177(l_Char_5, v511.InkPool)
					v533.Splash.Enabled = true
					game.Debris:AddItem(v533, 7)
					task.wait(0.25)
					v530.Enabled = false
					v527.Head.Transparency = 1
					for _, v535 in v527:GetChildren() do
						if v535.Name == "Torso" or v535.Name == "Right Arm" or v535.Name == "Left Arm" then
							local v536 = {
								Size = Vector3.new(v535.Size.X, 0, v535.Size.Z), 
								CFrame = v535.CFrame * CFrame.new(0, -1, 0)
							}
							local v537 = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
							l_l_TweenService_0_0:Create(v535, v537, v536):Play()
							local v538 = v511.SparkleDestroy.Stars:Clone()
							v538.Parent = v535
							v538.Enabled = true
							task.spawn(function() --[[ Line: 2569 ]]
								-- upvalues: v538 (copy), v535 (copy)
								task.wait(0.5)
								v538.Enabled = false
								v535.Transparency = 1
								task.wait(0.5)
								v535:Destroy()
							end)
						end
					end
					task.wait(0.5)
					v527.Head:Destroy()
					for _, v540 in v527:GetChildren() do
						if v540.Name == "Right Leg" or v540.Name == "Left Leg" then
							local v541 = {
								Size = Vector3.new(v540.Size.X, 0, v540.Size.Z), 
								CFrame = v540.CFrame * CFrame.new(0, -1, 0)
							}
							local v542 = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
							l_l_TweenService_0_0:Create(v540, v542, v541):Play()
							local v543 = v511.SparkleDestroy.Stars:Clone()
							v543.Parent = v540
							v543.Enabled = true
							task.spawn(function() --[[ Line: 2594 ]]
								-- upvalues: v543 (copy), v540 (copy)
								task.wait(0.5)
								v543.Enabled = false
								v540.Transparency = 1
								task.wait(0.5)
								v540:Destroy()
							end)
						end
					end
					v533.Splash.Enabled = false
				end, 
				DelayedBarrage = function() --[[ Line: 2608 ]]
					-- upvalues: v177 (ref), l_Char_5 (copy), v511 (copy), l_cleanup_5 (copy), doShake (ref), l_targChar_3 (copy)
					local v544 = v177(l_Char_5, v511.DelayedBarrageCenter)
					game.Debris:AddItem(v544, 10)
					table.insert(l_cleanup_5, v544)
					game.Debris:AddItem(v544, 7)
					for _ = 1, 5 do
						doShake({
							l_Char_5, 
							l_targChar_3
						}, math.random(1, 5))
						if not v544 or not v544.Parent then
							return
						else
							local v546 = v511.Punches:GetChildren()[math.random(1, 3)]:Clone()
							table.insert(l_cleanup_5, v546)
							game.Debris:AddItem(v546, 4)
							v546.Parent = workspace.Thrown
							game.Debris:AddItem(v546, 2)
							v546.CFrame = CFrame.lookAt(v544.Position + Vector3.new(math.random(-20, 20) / 10, math.random(-20, 20) / 10, math.random(-10, 10) / 10), v544.Attachment.WorldCFrame.Position)
							for _, v548 in v546:GetDescendants() do
								if v548:IsA("ParticleEmitter") then
									v548:Emit(v548:GetAttribute("EmitCount"))
								end
							end
							task.wait(0.06)
						end
					end
					doShake({
						l_Char_5, 
						l_targChar_3
					}, 5, 0.35)
				end, 
				DelayedHit = function() --[[ Line: 2636 ]]
					-- upvalues: l_targChar_3 (copy), l_cleanup_5 (copy), v177 (ref), l_Char_5 (copy), v511 (copy), doShake (ref), l_l_TweenService_0_0 (copy)
					local l_TimeBubble_0 = l_targChar_3.Torso.TimeBubble
					l_TimeBubble_0.Constant:Destroy()
					table.insert(l_cleanup_5, l_TimeBubble_0)
					game.Debris:AddItem(l_TimeBubble_0, 5)
					local v550 = v177(l_Char_5, v511.BubbleBreak)
					doShake({
						l_Char_5, 
						l_targChar_3
					}, 2)
					table.insert(l_cleanup_5, v550)
					game.Debris:AddItem(v550, 4)
					for _, v552 in v550:GetDescendants() do
						if v552:IsA("ParticleEmitter") then
							v552:Emit(v552:GetAttribute("EmitCount"))
							local v553 = {
								TimeScale = 1
							}
							local v554 = TweenInfo.new(0.25, Enum.EasingStyle.Linear)
							l_l_TweenService_0_0:Create(v552, v554, v553):Play()
						end
					end
				end, 
				CreateClone = function() --[[ Line: 2657 ]]
					-- upvalues: v177 (ref), l_Char_5 (copy), v511 (copy), l_cleanup_5 (copy), doShake (ref), l_targChar_3 (copy)
					local v555 = v177(l_Char_5, v511.CreateClone)
					table.insert(l_cleanup_5, v555)
					game.Debris:AddItem(v555, 7)
					for _, v557 in v555:GetDescendants() do
						if v557:IsA("ParticleEmitter") then
							v557:Emit(v557:GetAttribute("EmitCount"))
						end
					end
					local v558 = v177(l_Char_5, v511.BarrageCenter)
					local l_Position_1 = v558.Attachment.WorldCFrame.Position
					table.insert(l_cleanup_5, v558)
					game.Debris:AddItem(v558, 5)
					local v560 = v177(l_Char_5, v511.PunchStreaks)
					table.insert(l_cleanup_5, v560)
					game.Debris:AddItem(v560, 5)
					v560.Attachment.Flare.Enabled = true
					v560.LineThing.Enabled = true
					local v561 = v177(l_Char_5, v511.BloodSplats)
					game.Debris:AddItem(v561, 6)
					table.insert(l_cleanup_5, v561)
					game.Debris:AddItem(v561, 5)
					for v562 = 1, 23 do
						if v555 and v555.Parent then
							local v563 = v562 % 6 + 1
							v560:FindFirstChild(v563).Swipe:Emit(1)
							v560:FindFirstChild(v563).Swipe2:Emit(1)
							v560.Shine:Emit(1)
							doShake({
								l_Char_5, 
								l_targChar_3
							}, Random.new():NextNumber(0.9, 1.35))
							local v564 = v511.BarrageFirst:Clone()
							v564.Parent = workspace.Thrown
							table.insert(l_cleanup_5, v564)
							game.Debris:AddItem(v564, 2)
							v564.CFrame = CFrame.lookAt(v558.Position + Vector3.new(math.random(-20, 20) / 10, math.random(-20, 20) / 10, math.random(-10, 10) / 10), l_Position_1)
							for _, v566 in v564:GetDescendants() do
								if v566:IsA("ParticleEmitter") then
									v566:Emit(v566:GetAttribute("EmitCount"))
								end
							end
							if v562 % 2 == 0 then
								v561.Blood:Emit(1)
							end
							if v562 > 6 then
								if v562 > 14 then
									task.wait(0.02)
								else
									task.wait(0.06)
								end
							else
								task.wait(0.08)
							end
						else
							break
						end
					end
					if not v560 or not v560.Parent then
						return
					else
						v560.Attachment.Flare.Enabled = false
						v560.LineThing.Enabled = false
						return
					end
				end, 
				Land = function() --[[ Line: 2727 ]]
					-- upvalues: v177 (ref), l_Char_5 (copy), v511 (copy), l_cleanup_5 (copy)
					local v567 = v177(l_Char_5, v511.Land)
					table.insert(l_cleanup_5, v567)
					game.Debris:AddItem(v567, 5)
					for _, v569 in v567:GetDescendants() do
						if v569:IsA("ParticleEmitter") then
							v569:Emit(v569:GetAttribute("EmitCount"))
						end
					end
					local v570 = v511.ArmTrails.ArmTrail:Clone()
					v570.Parent = l_Char_5["Left Arm"]
					game.Debris:AddItem(v570, 2)
					v570.Circle.Circle:Emit(1)
					local v571 = v511.ArmTrails.ArmTrail:Clone()
					v571.Parent = l_Char_5["Right Arm"]
					game.Debris:AddItem(v571, 2)
					v571.Circle.Circle:Emit(1)
					for _, v573 in pairs({
						v571, 
						v570
						}) do
						table.insert(l_cleanup_5, v573)
						game.Debris:AddItem(v573, 5)
					end
					task.wait(1.2)
					if not v567 or not v567.Parent then
						return
					else
						v570.Bottom.Stars.Enabled = false
						v571.Bottom.Stars.Enabled = false
						return
					end
				end, 
				EnemyFlingBack = function() --[[ Line: 2761 ]]
					-- upvalues: l_RealAnim_4 (copy), v177 (ref), l_Char_5 (copy), v511 (copy), doShake (ref), l_targChar_3 (copy), l_cleanup_5 (copy)
					task.wait(0.35)
					if not l_RealAnim_4.IsPlaying then
						return
					else
						local v574 = v177(l_Char_5, v511.TimeTrap)
						doShake({
							l_Char_5, 
							l_targChar_3
						}, 3)
						table.insert(l_cleanup_5, v574)
						game.Debris:AddItem(v574, 5)
						for _, v576 in v574:GetDescendants() do
							if v576:IsA("ParticleEmitter") then
								v576:Emit(v576:GetAttribute("EmitCount"))
							end
						end
						if not l_RealAnim_4.IsPlaying then
							return
						else
							local v577 = v511.TimeBubble.TimeBubble:Clone()
							table.insert(l_cleanup_5, v577)
							game.Debris:AddItem(v577, 4)
							v577.Parent = l_targChar_3.Torso
							game.Debris:AddItem(v577, 5)
							for _, v579 in v577.Initial:GetDescendants() do
								if v579:IsA("ParticleEmitter") then
									v579:Emit(v579:GetAttribute("EmitCount"))
								end
							end
							for _, v581 in ipairs(v577.Constant:GetChildren()) do
								v581.Enabled = true
							end
							v577.Constant.Circle:Emit(1)
							return
						end
					end
				end, 
				ImpactStart = function()
					local v582 = v177(l_Char_5, v511.PunchThrough)
					doShake({
						l_Char_5, 
						l_targChar_3
					}, 4, 0.35)
					table.insert(l_cleanup_5, v582)
					game.Debris:AddItem(v582, 4)
					local l_Thing_0 = v582.Thing
					l_Thing_0:SetPrimaryPartCFrame(l_PrimaryPart_6.CFrame * l_Thing_0.Thing:GetAttribute("Offset"))
					if not l_RealAnim_4.IsPlaying then
						return
					else
						v582.BackMore.LensFlare.Enabled = true
						for _, v585 in ipairs(v582.Thing.Thing.Constant:GetDescendants()) do
							if v585:IsA("ParticleEmitter") then
								v585.Enabled = true
							end
						end
						for _, v587 in ipairs(v582.Thing.Thing.Initial:GetDescendants()) do
							if v587:IsA("ParticleEmitter") then
								v587:Emit(v587:GetAttribute("EmitCount"))
							end
						end
						task.wait(0.4)
						if not l_RealAnim_4.IsPlaying then
							return
						else
							task.spawn(function() --[[ Line: 2825 ]]
								-- upvalues: l_RealAnim_4 (ref), v582 (copy)
								for v588 = 1, 16 do
									if not l_RealAnim_4.IsPlaying then
										return
									elseif not v582 then
										return
									else
										v582.Thing:ScaleTo(1 + v588 % 2 * -1 * (v588 / 40))
										task.wait(0.05)
									end
								end
							end)
							task.wait(0.8)
							if not l_RealAnim_4.IsPlaying then
								return
							else
								doShake({
									l_Char_5, 
									l_targChar_3
								}, 4, 0.1)
								v582.BackMore.LensFlare.Enabled = false
								v582.Thing:ScaleTo(1)
								for _, v590 in ipairs(v582.Thing.Thing.Constant:GetDescendants()) do
									if v590:IsA("ParticleEmitter") then
										v590.Enabled = false
									end
								end
								for _, v592 in v582.Boom:GetChildren() do
									if v592:IsA("ParticleEmitter") then
										v592:Emit(v592:GetAttribute("EmitCount"))
									end
								end
								return
							end
						end
					end
				end, 
				Roar = function() 
					doShake({
						l_Char_5, 
						l_targChar_3
					}, 3, 0.4)
					local v593 = v177(l_Char_5, v511.InfernalCircle)
					table.insert(l_cleanup_5, v593)
					game.Debris:AddItem(v593, 4)
					for _, v595 in v593.Ground:GetDescendants() do
						if v595:IsA("ParticleEmitter") then
							v595:Emit(v595:GetAttribute("EmitCount"))
						end
					end
					for _, v597 in v593.Constant:GetDescendants() do
						if v597:IsA("ParticleEmitter") then
							v597.Enabled = true
						end
					end
					v593.Constant.Beam.Enabled = true
					v593.Constant.Beam.Width1 = 10
					v593.Constant.Beam.Width0 = 5
					local v598 = {
						Width1 = 20, 
						Width0 = 10
					}
					local v599 = TweenInfo.new(0.2, Enum.EasingStyle.Linear)
					l_l_TweenService_0_0:Create(v593.Constant.Beam, v599, v598):Play()
					task.wait(0.6)
					if not l_RealAnim_4.IsPlaying then
						return
					else
						local v600 = v511.FireArms.FireTrail:Clone()
						v600.Parent = l_Char_5:FindFirstChild("Right Arm")
						table.insert(l_cleanup_5, v600)
						game.Debris:AddItem(v600, 4)
						game.Debris:AddItem(v600, 2)
						for _, v602 in v600.Hand:GetChildren() do
							v602:Emit(v602:GetAttribute("EmitCount"))
						end
						for _, v604 in v600:GetDescendants() do
							if v604:IsA("Trail") then
								v604.Enabled = true
							end
						end
						task.wait(0.05)
						if not l_RealAnim_4.IsPlaying then
							return
						else
							local v605 = {
								Width1 = 0, 
								Width0 = 0
							}
							local v606 = TweenInfo.new(0.2, Enum.EasingStyle.Linear)
							l_l_TweenService_0_0:Create(v593.Constant.Beam, v606, v605):Play()
							for _, v608 in v593.Constant:GetDescendants() do
								if v608:IsA("ParticleEmitter") then
									v608.Enabled = false
								end
							end
							task.wait(0.2)
							if not l_RealAnim_4.IsPlaying then
								return
							else
								v593.Constant.Beam.Enabled = false
								task.wait(0.35)
								if not l_RealAnim_4.IsPlaying then
									return
								else
									for _, v610 in v600:GetDescendants() do
										if v610:IsA("Trail") then
											v610.Enabled = false
										end
										if v610:IsA("ParticleEmitter") then
											v610.Enabled = false
										end
									end
									return
								end
							end
						end
					end
				end
			}
			
			v220({
				anim = l_RealAnim_4, 
				markers = v611, 
				DontDisconnectMarkers = false, 
				sendingdata = v505, 
				cleanup = l_cleanup_5
			})
		end
	}, 
	
	Embers = {
		CutsceneData = {
			Anim = 101879402901748, 
			Offset = CFrame.new(0, -3, 0, 0.999999881, 0, 2.98023224E-8, 0, 1, 0, 2.98023224E-8, 0, 1.00000024), 
			From = "HumanoidRootPart", 
			SpecificRig = script.Assets.Cam, 
			ActualPart = "CamPart", 
			NoLerpAfter = true, 
			NoFov = true, 
			EmberDelay = true, 
			CustomSpeed = 0.96
		}, 
		
		DontDisconnectMarkers = true, 
		
		ManualVfxMarkers = {
			hit = function(v889)
				local l_Char_33 = v889.Char
				local l_cleanup_21 = v889.cleanup
				local l_Part_2 = script.RealAssets.Ember.Part
				if not v889.hitcount then
					v889.hitcount = 0
				end
				v889.hitcount = v889.hitcount + 1
				local v893 = l_Char_33[({
					[1] = "Right Arm", 
					[2] = "Left Arm", 
					[3] = "Right Arm", 
					[4] = "Left Arm"
				})[v889.hitcount]]
				if not v893:FindFirstChild("HitEmber") then
					for _, v895 in pairs(l_Part_2:GetChildren()) do
						local v896 = v895:Clone()
						game.Debris:AddItem(v896, 10)
						table.insert(l_cleanup_21, v896)
						v896.Parent = v893
					end
				end
				for _, v898 in pairs(v893:GetChildren()) do
					if v898:IsA("Attachment") and (v898.Name == "HitEmber" or v898.Name == "Impact") then
						for _, v900 in pairs(v898:GetChildren()) do
							v900:Emit(v900:GetAttribute("EmitCount") * 2)
						end
					end
				end
				for _, v902 in pairs({
					l_Char_33, 
					v889.Victim
					}) do
					local l_cinderhighlight_0 = v902:FindFirstChild("cinderhighlight")
					if l_cinderhighlight_0 then
						l_cinderhighlight_0:Destroy("")
					end
					local l_Highlight_2 = Instance.new("Highlight")
					l_Highlight_2.Name = "cinderhighlight"
					l_Highlight_2.DepthMode = Enum.HighlightDepthMode.Occluded
					l_Highlight_2.FillColor = Color3.fromRGB(0, 0, 0)
					l_Highlight_2.OutlineColor = Color3.fromRGB(255, 255, 255)
					l_Highlight_2.OutlineTransparency = 0
					l_Highlight_2.FillTransparency = 0
					l_Highlight_2.Parent = v902
					game.Debris:AddItem(l_Highlight_2, 0.1)
				end
			end, 
			
			room = function(v905)
				local v906 = {}
				local l_Char_34 = v905.Char
				local l_cleanup_22 = v905.cleanup
				local l_PrimaryPart_9 = l_Char_34.PrimaryPart
				local v910 = true
				if l_Char_34 ~= game.Players.LocalPlayer.Character then
					v910 = v905.targChar == game.Players.LocalPlayer.Character
				end
				local v911 = script.RealAssets.Ember.ye.Lightning:Clone()
				table.insert(l_cleanup_22, v911)
				game.Debris:AddItem(v911, 2)
				v911.Parent = l_Char_34["Right Arm"]
				table.insert(v906, v911["1"])
				table.insert(v906, v911["2"])
				local l_Ember_0 = script.RealAssets.Ember
				local v913 = l_Ember_0.Background:Clone()
				table.insert(v906, v913)
				game.Debris:AddItem(v913, 10)
				v913.Parent = workspace.Thrown
				table.insert(l_cleanup_22, v913)
				v913.CFrame = l_PrimaryPart_9.CFrame * CFrame.new(0.209411621, 1.43823242, -2.70602417, -0.999999881, 0, -2.98023224E-8, 0, 1, 0, -2.98023224E-8, 0, -1.00000024)
				game:GetService("TweenService"):Create(v913, TweenInfo.new(0.65), {
					Transparency = v910 and 0 or 1
				}):Play()
				local v914 = {
					Beam1 = CFrame.new(-2.92773438, 0.416320801, -19.6693726, -0.999999881, 0, -2.98023224E-8, 0, 1, 0, -2.98023224E-8, 0, -1.00000024), 
					Beam2 = CFrame.new(0.983093262, 0.266876221, -19.6693726, -0.999999881, 0, 0, 0, 0.99619472, -0.087155737, -2.98023224E-8, -0.0871557519, -0.996194899), 
					Beam3 = CFrame.new(0.983093262, 1.34902954, -19.6693726, -0.999999881, 3.7252903E-9, -2.98023224E-8, 0, 0.991392791, 0.130921587, -2.98023224E-8, 0.130921602, -0.99139297)
				}
				if v910 then
					for _, v916 in pairs({
						l_Ember_0.Beam1, 
						l_Ember_0.Beam2, 
						l_Ember_0.Beam3
						}) do
						local v917 = v916:Clone()
						table.insert(v906, v917)
						game.Debris:AddItem(v917, 10)
						v917.Parent = workspace.Thrown
						table.insert(l_cleanup_22, v917)
						v917.CFrame = l_PrimaryPart_9.CFrame * v914[tostring(v916)]
					end
				end
				v905.othertable = v906
			end, 
			
			heavy = function(v918)
				local l_Char_35 = v918.Char
				v212({
					Part = script.RealAssets.Ember.End, 
					CFrame = v918.Char.PrimaryPart.CFrame * CFrame.new(0.307342529, 0.379882812, -1.87609863, -0.999999881, 2.98023224E-8, 0, 0, 0, 1, -2.98023224E-8, 1.00000024, 0), 
					cleanup = v918.cleanup, 
					Char = l_Char_35
				})
				v212({
					Part = script.RealAssets.Ember.Impulse, 
					CFrame = v918.Char.PrimaryPart.CFrame * CFrame.new(0.0914611816, -0.338897705, -0.94128418, 0.999999881, -2.98023224E-8, 0, 0, 0, 1, 2.98023224E-8, -1.00000024, 0), 
					cleanup = v918.cleanup, 
					Char = l_Char_35
				})
				for _, v921 in pairs(v918.othertable) do
					if v921:IsA("MeshPart") then
						game:GetService("TweenService"):Create(v921, TweenInfo.new(0.15), {
							Transparency = 1
						}):Play()
					elseif v921:IsA("ParticleEmitter") then
						v921.Enabled = false
					else
						for _, v923 in pairs(v921:GetDescendants()) do
							if v923:IsA("Beam") or v923:IsA("ParticleEmitter") or v923:IsA("PointLight") then
								v923.Enabled = false
							end
						end
					end
				end
				wait(0.1)
				v918.CutsceneCallback()
			end
		}
	}, 
	
	["Boss Raid"] = {
		CanRotate = true, 
		StartupFunction = function(v206)
			local l_Char_0 = v206.Char
			local l_PrimaryPart_1 = v206.Char.PrimaryPart
			local l_cleanup_0 = v206.cleanup
			local l_Bossraid_0 = script.RealAssets.Bossraid
			local v211 = l_Char_0["Right Arm"]
			local v212 = nil
			local l_EmoteBind_0 = v206.EmoteBind
			local v214 = nil
			
			local l_Part_0 = Instance.new("Part")
			game:GetService("Debris"):AddItem(l_Part_0, 60)
			l_Part_0.CanCollide = false
			l_Part_0.CanQuery = false
			l_Part_0.Transparency = 1
			l_Part_0:SetAttribute("Name", v206.Char.Name)
			l_Part_0:SetAttribute("DeletionImmunity", true)
			l_Part_0.Color = Color3.new(1, 1, 1)
			l_Part_0.Name = "InfBall"
			l_Part_0.Material = Enum.Material.Neon
			l_Part_0.Shape = "Ball"
			l_Part_0.Massless = true
			l_Part_0.Size = Vector3.new(20, 20, 20, 0)
			
			local l_Weld_0 = Instance.new("Weld")
			l_Weld_0.Part0 = l_PrimaryPart_1
			l_Weld_0.Part1 = l_Part_0
			l_Weld_0.Parent = l_Part_0
			l_Part_0.Parent = l_Char_0
			l_Part_0:AddTag("InfinityBall")
			
			local function v222(v217)
				if v217 then
					v211.Transparency = 1
					v212 = task.delay(1.5, function()
						local v218 = l_Bossraid_0.ArmRegen:Clone()
						v214 = v218
						table.insert(v206.cleanup, v218)
						game.Debris:AddItem(v218, 5)
						v218.Parent = l_Char_0
						
						local l_Motor6D_0 = v218:FindFirstChildOfClass("Motor6D")
						table.insert(v206.cleanup, l_Motor6D_0)
						l_Motor6D_0.Part0 = v211
						l_Motor6D_0.Part1 = v218.PrimaryPart
						l_Motor6D_0.Parent = v211
						
						local l_Animation_1 = Instance.new("Animation")
						l_Animation_1.AnimationId = "rbxassetid://86404171184181"
						l_Char_0.Humanoid:LoadAnimation(l_Animation_1):Play()
						local v221 = nil
						
						v221 = shared.sfx({
							Parent = v211, 
							SoundId = "rbxassetid://84075779987325", 
							Volume = 1.35, 
							PlaybackSpeed = Random.new():NextNumber(1, 1.075)
						}):Play()
					end)
					
					table.insert(v206.cleanup, v212)
					return
				else
					v211.Transparency = 0
					if v212 then
						task.cancel(v212)
					end
					
					return
				end
			end
			v222(true)
			
			if l_EmoteBind_0 then
				l_EmoteBind_0:GetPropertyChangedSignal("Parent"):Connect(function()
					if not l_EmoteBind_0.Parent then
						v222(false)
					end
				end)
				
				if not l_EmoteBind_0.Parent then
					v222(false)
				end
			end
			
			local v223 = {
				Texts = CFrame.new(1.39596558, -0.870697021, -0.397636414, 0.923880339, 3.17196898E-13, -0.382681459, -2.46100503E-13, 1, 2.3473698E-13, 0.382681459, -1.22690798E-13, 0.923880339), 
				Blue = CFrame.new(-0.128771782, -0.946416378, -1.34786582, 0.109281771, -0.460234433, -0.881046772, -0.148396462, 0.868868649, -0.472279489, 0.982872725, 0.182355583, 0.0266542491), 
				Activate = CFrame.new(-0.468925238, -2.06283092, 0.227512807, 1.00000036, -2.04890966E-8, -2.98023224E-8, -2.04890966E-8, 1.00000036, -5.21540642E-8, -2.98023224E-8, -5.21540642E-8, 1.0000006), 
				Slam = CFrame.new(-0.440316439, -3.11318493, -0.973331332, 1.00000036, -2.04890966E-8, -2.98023224E-8, -2.04890966E-8, 1.00000036, -5.21540642E-8, -2.98023224E-8, -5.21540642E-8, 1.0000006), 
				FloorEnable = CFrame.new(-0.940292835, -3.11318469, -0.895578265, 1.00000036, -2.04890966E-8, -2.98023224E-8, -2.04890966E-8, 1.00000036, -5.21540642E-8, -2.98023224E-8, -5.21540642E-8, 1.0000006), 
				Phase2 = CFrame.new(-0.77883029, -2.97686553, -0.781239569, 0.49037835, -0.687594295, -0.535485148, 0.206855595, 0.688705623, -0.694907486, 0.846605718, 0.229999408, 0.479958862), 
				FloorPart = CFrame.new(-1.01313972, -2.90322304, -1.35118687, 1.00000036, -2.04890966E-8, -2.98023224E-8, -2.04890966E-8, 1.00000036, -5.21540642E-8, -2.98023224E-8, -5.21540642E-8, 1.0000006), 
				Land = CFrame.new(-0.285525084, -2.90988469, 0.227512926, 1.00000036, -2.04890966E-8, -2.98023224E-8, -2.04890966E-8, 1.00000036, -5.21540642E-8, -2.98023224E-8, -5.21540642E-8, 1.0000006)
			}
			
			local function v226(v224)
				if v224:IsA("Model") and v224.PrimaryPart then
					v224 = v224.PrimaryPart
				end
				
				if v224:IsA("Part") or v224:IsA("MeshPart") and v223[tostring(v224)] then
					v224.CFrame = l_PrimaryPart_1.CFrame * v223[tostring(v224)]
				end
				
				if tostring(v224) == "Blue" then
					v224.Anchored = false
					v224.Massless = true
					v224.CanTouch = false
					v224.CanQuery = false
					if tostring(v224) == "Blue" then
						v224.Parent.Parent = l_Char_0
					else
						v224.Parent = l_Char_0
					end
					
					local v225 = v224.Parent:FindFirstChildOfClass("Motor6D") or v224:FindFirstChildOfClass("Motor6D")
					v225.Part0 = l_Char_0.PrimaryPart
					v225.Part1 = v224
					v225.Parent = l_Char_0.PrimaryPart
				end
			end
			
			local v227 = nil
			local function v230(v228)
				local v229 = v228:Clone()
				if not v227 then
					v227 = v229
				end
				
				v229.Parent = workspace.Thrown
				table.insert(l_cleanup_0, v229)
				
				if tostring(v228) ~= "SteamArm" then
					v226(v229)
					table.insert(v206.cleanup, v229)
					
					if v228.Name ~= "Texts" then
						game.Debris:AddItem(v229, 10)
						return v229
					else
						v229.Parent = l_Char_0
					end
				end
				
				return v229
			end
			
			local function v239()
				local v235 = v230(l_Bossraid_0.Texts)
				local l_EmoteBind_1 = v206.EmoteBind
				
				if l_EmoteBind_1 then
					l_EmoteBind_1:GetPropertyChangedSignal("Parent"):Connect(function()
						if not l_EmoteBind_1.Parent then
							game:GetService("Debris"):AddItem(v235, 0)
						end
					end)
					
					if not l_EmoteBind_1.Parent then
						game:GetService("Debris"):AddItem(v235, 0)
					end
				else
					game:GetService("Debris"):AddItem(v235, 0)
				end
				
				for _, v238 in pairs(v235:GetDescendants()) do
					if (v238:IsA("ParticleEmitter") or v238:IsA("Trail") or v238:IsA("Beam")) and v238:GetAttribute("EmitDelay") then
						task.delay(v238:GetAttribute("EmitDelay"), function()
							v238:Emit(v238:GetAttribute("EmitCount"))
							task.delay(5, function()
								v238.TimeScale = 0
							end)
						end)
					end
				end
			end
			
			local v240 = nil
			v240 = task.delay(2.15, function()
				v239()
			end)
			
			v240 = nil
			local v241 = nil
			local v242 = nil
			local v243 = nil
			
			local v291 = {
				[0.07] = function()
					local v244 = v230(l_Bossraid_0.Blue)
					v240 = v244
					v244:ScaleTo(1)
					v244 = v244.PrimaryPart
					
					local v245 = v230(l_Bossraid_0.Activate)
					for _, v247 in pairs(v245:GetDescendants()) do
						if v247:IsA("ParticleEmitter") then
							v247:Emit(v247:GetAttribute("EmitCount"))
						end
					end
					
					for _, v249 in pairs(v244:GetDescendants()) do
						if v249:IsA("ParticleEmitter") or v249:IsA("Trail") then
							v249.Enabled = true
						end
					end
					
					v244.PointLight.Brightness = 7
					
					TweenService:Create(v244.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						Brightness = 1
					}):Play()
				end, 
				
				[0.647] = function()
					spawn(function()
						for _ = 1, 5 do
							doShake({ l_Char_0 }, 2)
							task.wait(0.02)
						end
					end)
					
					v240:ScaleTo(1.8)
					local v251 = v230(l_Bossraid_0.Slam)
					for _, v253 in pairs(v251:GetDescendants()) do
						if v253:IsA("ParticleEmitter") then
							v253:Emit(v253:GetAttribute("EmitCount"))
						end
					end
					
					local v254 = v230(l_Bossraid_0.FloorEnable)
					v241 = v254
					
					for _, v256 in pairs(v254:GetDescendants()) do
						if v256:IsA("ParticleEmitter") then
							v256:Emit(v256:GetAttribute("EmitCount"))
							v256.Enabled = true
						end
					end
				end, 
				
				[1.25] = function()
					local l_v240_0 = v240
					local v258 = 1
					
					local v259 = v230(l_Bossraid_0.Phase2)
					v242 = v259
					v259.PointLight.Brightness = 0
					
					TweenService:Create(v259.PointLight, TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						Brightness = 2
					}):Play()
					
					for _, v261 in pairs(v259:GetDescendants()) do
						if v261:IsA("ParticleEmitter") or v261:IsA("Trail") then
							v261.Enabled = true
						end
					end
					
					for _, v263 in pairs(v241:GetDescendants()) do
						if v263:IsA("ParticleEmitter") then
							v263:Emit(v263:GetAttribute("EmitCount"))
							v263.Enabled = false
						end
					end
					
					local v264 = v230(l_Bossraid_0.FloorPart)
					v243 = v264
					for _, v266 in pairs(v264:GetDescendants()) do
						if v266:IsA("ParticleEmitter") or v266:IsA("Trail") then
							v266:Emit(v266:GetAttribute("EmitCount"))
							v266.Enabled = true
						end
					end
					
					local v267 = nil
					v267 = task.delay(0.2, function()
						local l_Position_0 = l_PrimaryPart_1.Position
						local _, v274 = workspace:FindFirstChildOfClass("Camera"):WorldToScreenPoint(l_Position_0)
						
						if v274 then
							local v275 = nil
							v275 = game:GetService("RunService").Heartbeat:Connect(function()
								if v240 and v240.Parent and v264 and v264.Parent then
									v264.CFrame = CFrame.new(v264.Position:Lerp(Vector3.new(v240.PrimaryPart.Position.X, v264.Position.Y, v240.PrimaryPart.Position.Z), 0.25)) * CFrame.Angles(0, 1.5707963267948966, 0)
								end
							end)
							
							do
								local l_v275_0 = v275
								task.delay(1, function()
									if l_v275_0 then
										return l_v275_0:Disconnect()
									else
										return
									end
								end)
								
								table.insert(l_cleanup_0, l_v275_0)
							end
						end
					end)
					
					table.insert(l_cleanup_0, v267)
					task.spawn(function()
						for _ = 1, 7 do
							if l_v240_0 and l_v240_0.Parent then
								l_v240_0:ScaleTo(v258)
								v258 = v258 + 0.4
								wait(0.02)
							else
								return
							end
						end
					end)
				end, 
				
				[1.4] = function()
					for _, v279 in pairs(v240:GetDescendants()) do
						if v279:IsA("ParticleEmitter") or v279:IsA("Trail") then
							v279.Enabled = false
						end
					end
					
					task.delay(0.325, function()
						for _, v281 in pairs(v243:GetDescendants()) do
							if v281:IsA("ParticleEmitter") or v281:IsA("Trail") then
								v281.Enabled = false
							end
						end
					end)
					
					for _, v283 in pairs(v242:GetDescendants()) do
						if v283:IsA("ParticleEmitter") or v283:IsA("Trail") then
							v283.Enabled = false
						end
					end
					
					TweenService:Create(v240.Blue.PointLight, TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						Brightness = 0
					}):Play()
					
					TweenService:Create(v242.PointLight, TweenInfo.new(0.76, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						Brightness = 0
					}):Play()
				end, 
				
				[2.09] = function()
					local v284 = v230(l_Bossraid_0.Land)
					
					for _, v286 in pairs(v284:GetDescendants()) do
						if v286:IsA("ParticleEmitter") then
							v286:Emit(v286:GetAttribute("EmitCount"))
						end
					end
				end, 
				
				[2.29] = function()
					if v240 and v240.Parent then
						TweenService:Create(v211, TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Transparency = 0
						}):Play()
					end
					
					if v214 then
						if shared.OnScreen(l_PrimaryPart_1.Position) then
							for _, v288 in pairs(v214:GetDescendants()) do
								if v288:IsA("Part") or v288:IsA("MeshPart") then
									TweenService:Create(v288, TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
										Transparency = 1
									}):Play()
								end
							end
							
							game.Debris:AddItem(v214, 1)
						else
							v214:Destroy()
						end
					end
					
					local v289 = l_Bossraid_0.SteamArm.ParticleEmitter:Clone()
					v289.Parent = l_Char_0["Right Arm"]
					
					local l_EmoteBind_2 = v206.EmoteBind
					if l_EmoteBind_2 then
						l_EmoteBind_2:GetPropertyChangedSignal("Parent"):Connect(function()
							if not l_EmoteBind_2.Parent then
								game:GetService("Debris"):AddItem(v289, 0)
							end
						end)
						
						if not l_EmoteBind_2.Parent then
							game:GetService("Debris"):AddItem(v289, 0)
						end
					else
						game:GetService("Debris"):AddItem(v289, 0)
					end
					
					task.delay(0.12, function()
						if v289 and v289.Parent then
							v289.Enabled = true
						end
					end)
				end
			}
			
			local v292 = {}
			for v293, v294 in pairs(v291) do
				local v295 = nil
				
				v295 = task.delay(v293 + 0.15, function()
					v294()
				end)
				
				table.insert(v292, v295)
				table.insert(l_cleanup_0, v295)
			end
		end
	},
	["Final Spark"] = {
		CutsceneData = {
			Anim = 89862527827052, 
			Offset = CFrame.new(0, -3, 0), 
			From = "HumanoidRootPart", 
			SpecificRig = script.Assets.CamEntire, 
			ActualPart = "CamPart", 
			NoLerpAfter = true
		}, 
		StartupFunction = function(Params)
			local EnemyChar = Params.targChar
			local PrimaryPart = Params.Char.PrimaryPart
			local Character = game.Players.LocalPlayer.Character
			
			if Character == Params.Char or Character == EnemyChar then
				PrimaryPart = game.Players.LocalPlayer.PlayerGui
				Character = 3
			end
			
			for _, soundID in pairs({
				"rbxassetid://131415313616651", 
				"rbxassetid://131415313616651"
				}) do
				local vol = 4.5
				
				if soundID == "rbxassetid://131415313616651" then
					vol = 1.75
				elseif Character == 3 then
					vol = 2.5
				end
				
				local SFX = shared.sfx({
					SoundId = soundID, 
					Parent = PrimaryPart, 
					Volume = vol
				})
				SFX:Play()
				
				table.insert(Params.cleanup, SFX)
			end
		end, 
		RealModule = script.VfxMods.Flasher
	}, 
	["Energy Explosion"] = {
		StartupFunction = function(_)
			
		end, 
		CanRotate = true, 
		RealModule = script.VfxMods.EnergyExplosion
	}, 
    ["Boundless Rage"] = {
        CutsceneData = {
			Anim = 80853051953447, 
            Offset = CFrame.new(0, -2.5, 0), 
            From = "HumanoidRootPart", 
            SpecificRig = script.Assets.Cam, 
            ActualPart = "CamPart", 
            NoLerpAfter = true
        }, 
        RealModule = script.VfxMods.Boundless
	}, 
	["Divine Form"] = {
		CutsceneData = {
			Anim = 112358592597450, 
			Offset = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1), 
			NewCamera = {
				CFrame = CFrame.new(0, 1.5, -9.59999847, -1, 0, -1.49011612E-7, 0, 1.00000012, 0, 1.49011612E-7, 0, -1), 
				Zoom = 9.6
			}, 
			From = "HumanoidRootPart", 
			SpecificRig = script.Assets.CamRigNy, 
			ActualPart = "CameraPart", 
			NoLerpAfter = true
		}, 
		
		StartupFunction = function(Params)
			local cleanupTable = Params.cleanup
			local Character = Params.Char
			local isLocalPlayerCharacter = Character == game.Players.LocalPlayer.Character
			
			local SFX = shared.sfx({
				SoundId = "rbxassetid://104606088514319", 
				Parent = isLocalPlayerCharacter and game.Players.LocalPlayer.PlayerGui or Character.PrimaryPart, 
				Volume = isLocalPlayerCharacter and 1.35 or 3.25
			})
			SFX:Play()
			
			table.insert(cleanupTable, SFX)
			task.delay(14, function()
				if SFX and SFX.Parent then
					table.remove(cleanupTable, table.find(cleanupTable, SFX))
				end
			end)
		end, 
		
		RealModule = script.VfxMods.Evolved
	}, 
	["True Aura"] = {
		CutsceneData = {
			Anim = 138572240585698, 
			Offset = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1), 
			From = "HumanoidRootPart", 
			SpecificRig = script.Assets.CamRigDook, 
			ActualPart = "CameraPart", 
			NoLerpAfter = true
		}, 
		
		StartupFunction = function(_)

		end, 
		
		RealModule = script.VfxMods.TrueRage
	}, 
	["Shadow Eruption"] = {
		StartupFunction = function(Params)
			local LocalCharacter = Params.Char == game.Players.LocalPlayer.Character
			
			local SFX = shared.sfx({
				SoundId = "rbxassetid://89818228552804", 
				Parent = LocalCharacter and game.Players.LocalPlayer.PlayerGui or Params.Char.Torso, 
				Volume = LocalCharacter and 3 or 6, 
				PlaybackSpeed = 1
			})
			SFX:Play()
			
			table.insert(Params.cleanup, SFX)
		end, 
		
		CanRotate = true, 
		RealModule = script.VfxMods.ShadowEruption, 
		CutsceneData = {
			Anim = 98353548951241, 
			Offset = CFrame.new(0, -3, 0, 0.999999881, 0, 2.98023224E-8, 0, 1, 0, 2.98023224E-8, 0, 1.00000024), 
			From = "HumanoidRootPart", 
			SpecificRig = script.Assets.CamEzee, 
			ActualPart = "CamPart", 
			NoLerpAfter = true
		}
	}, 
}

local PlayerCleanupRegistry = {}

if game:GetService("RunService"):IsClient() then
	game.Players.PlayerRemoving:Connect(function(Player)
		if PlayerCleanupRegistry[Player] then
			local CleanupData = PlayerCleanupRegistry[Player]
			
			for _, Item in pairs(CleanupData.cleanup) do
				if tostring(Item) == "Connection" then
					Item:Disconnect()
				elseif typeof(Item) == "thread" then
					task.cancel(Item)
				elseif typeof(Item) == "Instance" then
					if Item:GetAttribute("DelayDeletion") then
						Debris:AddItem(Item, Item:GetAttribute("DelayDeletion"))
					else
						Item:Destroy()
					end
				end
			end
			
			for _, Task in pairs(CleanupData.tasks) do
				task.cancel(Task)
			end

			PlayerCleanupRegistry[Player] = nil
		end
	end)
end

VFXModule.MainFunction = function(_, Params)
	local VFXData = VFXModule[Params.vfxName]
	assert(VFXData, "No table data found, put it in.")
	
    if not Params.Victim then
        Params.Victim = Params.Character
	end
	
	local Character = Params.Character
    local Victim = Params.Victim
	local ActiveEffects = {}
	
	local playingAnimation = GetPlayingAnimationById(Character.Humanoid, Params.AnimSent)
    if not playingAnimation then
        return
    else
        local cleanupTasks = {}
        local additionalTasks = {}
        local playerInstance = game.Players:FindFirstChild((tostring(Character)))
		
		if game:GetService("RunService"):IsClient() then
            if not playerInstance then
                playerInstance = workspace.Live:FindFirstChild((tostring(Character)))
			end
			
            if table.find(PlayerCleanupRegistry, playerInstance) then
                table.remove(PlayerCleanupRegistry, table.find(PlayerCleanupRegistry, playerInstance))
			end
			
            PlayerCleanupRegistry[playerInstance] = {
                cleanup = ActiveEffects, 
                tasks = additionalTasks
            }
		end
		
        local animationBind = nil
        local callbacks = {}
		local isInterrupted = false
		
        local emoteData = {
            Char = Character, 
            CleanupTable = ActiveEffects, 
            RealAnim = playingAnimation, 
            Bind = animationBind, 
            Callback = callbacks, 
            targChar = Victim, 
            cleanup = ActiveEffects, 
            Interrupted = isInterrupted, 
			EmoteCall = true,
			CutsceneBind = Params.CutsceneBind,
			CutsceneCallback = nil
		}
		
        if VFXData.RealModule then
			table.insert(ActiveEffects, animationBind)
			
            spawn(function()
				VfxModules[tostring(VFXData.RealModule)].FirstEvent(emoteData)
            end)
		end
		
        if Params.RealBind then
            animationBind = Params.RealBind
            animationBind:SetAttribute("EmoteBindThing", true)
            emoteData.Bind = animationBind
		end
		
        local function SetCharacterTransparency(Model, TransparencyValue)
            if Character:FindFirstChild("SpiderLegs") then
                Character:FindFirstChild("SpiderLegs"):FindFirstChildOfClass("MeshPart").Transparency = 1
			end
			
            if TransparencyValue == 0 then
                for part, originalTransparency in pairs(cleanupTasks) do
                    part.Transparency = originalTransparency
				end
				
				return
            else
                for _, descendant in pairs(Model:GetDescendants()) do
                    if (descendant:IsA("Part") or descendant:IsA("MeshPart") or descendant:IsA("Decal") or descendant:IsA("UnionOperation")) and not descendant:GetAttribute("WeaponProperty") then
                        cleanupTasks[descendant] = descendant.Transparency
                        descendant.Transparency = TransparencyValue
                    end
				end
				
                return
            end
		end
		
        local function StopEmoteEffects(v423)
            if not isInterrupted then
				isInterrupted = true
				
                if PlayerCleanupRegistry[playerInstance] then
                    PlayerCleanupRegistry[playerInstance] = nil
				end
				
                if PlayerCleanupRegistry[Character] then
                    PlayerCleanupRegistry[Character] = nil
				end
				
                for _, effect in pairs(ActiveEffects) do
                    if tostring(effect) == "Connection" then
						effect:Disconnect()
						
                    elseif typeof(effect) == "thread" then
						task.cancel(effect)
						
                    elseif typeof(effect) == "Instance" then
                        if effect:GetAttribute("DelayDeletion") then
							Debris:AddItem(effect, effect:GetAttribute("DelayDeletion"))
							
                        else
                            effect:Destroy()
                        end
                    end
				end
				
				for _, taskHandle in pairs(additionalTasks) do
					task.cancel(taskHandle)
                end
				
				local stopVfxAccessory = Instance.new("Accessory")
				stopVfxAccessory.Name = "StopEmoteVfx"
			   
				if v423 then
					stopVfxAccessory:SetAttribute("AnimStopped", true)
				end
				
				stopVfxAccessory.Parent = Params.Character
				Debris:AddItem(stopVfxAccessory, 1)
				
                SetCharacterTransparency(Params.Character, 0)
                return
            else
                return
            end
		end
		
        if not VFXData.CanRotate then
			local NoRotate = Instance.new("Accessory")
			NoRotate.Name = "NoRotate"
			NoRotate.Parent = Character
			
			Debris:AddItem(NoRotate, 15)
			table.insert(ActiveEffects, NoRotate)
		end
		
        if VFXData.StartupFunction then
            VFXData.StartupFunction(emoteData)
		end
		
        if VFXData.TransparencyData then
			local TransparencyData = VFXData.TransparencyData
			
			if TransparencyData.FirstDelay then
				table.insert(additionalTasks, (task.delay(TransparencyData.FirstDelay, function()
                    SetCharacterTransparency(Params.Character, 1)
                end)))
            else
                SetCharacterTransparency(Params.Character, 1)
			end
			
			table.insert(additionalTasks, (task.delay(TransparencyData.TransparencyTime, function()
                SetCharacterTransparency(Params.Character, 0)
            end)))
		end
		
        if VFXData.Tasks then
			for delayTime, taskFunction in pairs(VFXData.Tasks) do
				local delayedTask = nil
                do
					local taskRef = delayedTask
					taskRef = task.delay(delayTime, function()
                        if isInterrupted then
                            return
                        else
							if table.find(ActiveEffects, taskRef) then
								table.remove(ActiveEffects, table.find(ActiveEffects, taskRef))
							end
							
							taskFunction(emoteData)
                            return
                        end
					end)
					
					table.insert(ActiveEffects, taskRef)
					table.insert(additionalTasks, taskRef)
                end
            end
		end
		
        local LocalCharacter = game.Players.LocalPlayer.Character
        if VFXData.CutsceneData and (LocalCharacter == Character or LocalCharacter == Victim) then
            local CutsceneData = VFXData.CutsceneData
            CutsceneData.Char = Character
			CutsceneData.From = FindChildByName(Character, CutsceneData.From)
            CutsceneData.AnimSent = playingAnimation
			CutsceneData.Bind = animationBind
			
			local Cutscene = shared.CutsceneEvent(CutsceneData, ActiveEffects)
			table.insert(callbacks, Cutscene)
			emoteData.CutsceneCallback = Cutscene
		end
		
        if VFXData.Startup then
            VFXData.Startup(emoteData)
		end
		
        if VFXData.ManualVfxMarkers then
			for markerName, markerFunction in pairs(VFXData.ManualVfxMarkers) do
				local connection = nil
                do
					local connRef = connection
					connRef = playingAnimation:GetMarkerReachedSignal(markerName):Connect(function()
                        if not playingAnimation.IsPlaying then
                            return
                        else
                            if not VFXData.DontDisconnectMarkers then
								connRef:Disconnect()
							end
							
							return markerFunction(emoteData)
                        end
					end)
					
					table.insert(ActiveEffects, connRef)
                    task.delay(10, function()
						if connRef then
							connRef:Disconnect()
                        end
                    end)
                end
            end
		end
		
		local stopConnection = nil
		stopConnection = playingAnimation.Stopped:Connect(function()
            StopEmoteEffects()
		end)
		
        return
    end
end

return VFXModule
--// Services
local TweenService = game:GetService("TweenService")
local l_Debris_0 = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
--//By TzeDev

--// Import
local Modules = ReplicatedStorage.Modules
local VFXUtil = require(Modules.VFXUtil)
local Crater = require(Modules.RockModule2)
local Trove = require(Modules.Trove)

--// Storage
local Assets = ReplicatedStorage.Assets.VFX

local LocalPlayer = game.Players.LocalPlayer
--//Castom local 
local l_CurrentCamera_0 = workspace.CurrentCamera;
--local l_AnimatedTitles_0 = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("AnimatedTitles"));
local v93 = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("CameraShaker")).new(Enum.RenderPriority.Camera.Value, function(v91) --[[ Line: 221 ]]
	-- upvalues: l_CurrentCamera_0 (copy)
	local l_l_CurrentCamera_0_0 = l_CurrentCamera_0;
	l_l_CurrentCamera_0_0.CFrame = l_l_CurrentCamera_0_0.CFrame * v91;
end);
local v22 = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local TS = TweenService
local RNS = RunService
local v41 = nil;
local l_PreRender_0 = RunService.PreRender
--// Module
local v9 = game:GetService("CollectionService");
local v81 = {
	AutoSkill = true, 
	Blood = true, 
	PhotosensitiveMode = false, 
	HideAccessories = false, 
	HidePackages = false, 
	HideLeaderboards = false, 
	MuteAwakeningMusic = false, 
	CameraShakeMultiplier = 1, 
	VolumeMultiplier = 1, 
	EmoteVolumeMultiplier = 1, 
	DestructionPhysics = true, 
	ShiftlockOffset = 1.75, 
	ConsoleSettings = {
		ShowControls = true, 
		Sensitivity = 1
	}, 
	MobileButtons = {
		Dash = {
			ScaleX = 0, 
			OffsetX = 0, 
			ScaleY = 0, 
			OffsetY = 0, 
			SizeMultiplier = 1
		}, 
		M1 = {
			ScaleX = 0, 
			OffsetX = 0, 
			ScaleY = 0, 
			OffsetY = 0, 
			SizeMultiplier = 1
		}, 
		Block = {
			ScaleX = 0, 
			OffsetX = 0, 
			ScaleY = 0, 
			OffsetY = 0, 
			SizeMultiplier = 1
		}, 
		Shiftlock = {
			ScaleX = 0, 
			OffsetX = 0, 
			ScaleY = 0, 
			OffsetY = 0, 
			SizeMultiplier = 1
		}
	}, 
	KillSound = false, 
	HideKills = false, 
	HideKillstreak = false, 
	HideVIPJoinMessage = false
};

_game = game;
_workspace = workspace;
_require = require;
USERSETTINGS = UserSettings();
_pairs = pairs;
_ipairs = ipairs;
_pcall = pcall;
task_wait = task.wait;
task_spawn = task.spawn;
task_delay = task.delay;
task_cancel = task.cancel;
task_desynchronize = task.desynchronize;
task_synchronize = task.synchronize;
math_sin = math.sin;
math_asin = math.asin;
math_cos = math.cos;
math_acos = math.acos;
math_huge = 1e999;
math_pi = 3.141592653589793;
math_floor = math.floor;
math_ceil = math.ceil;
math_round = math.round;
math_min = math.min;
math_sqrt = math.sqrt;
math_pow = math.pow;
math_max = math.max;
math_clamp = math.clamp;
math_rad = math.rad;
math_exp = math.exp;
math_abs = math.abs;
math_random = math.random;
math_modf = math.modf;
CFrame_new = CFrame.new;
CFrame_Angles = CFrame.Angles;
vector_create = vector.create;
Vector3_zero = Vector3.new(0, 0, 0, 0);
TweenInfo_new = TweenInfo.new;
Color3_fromRGB = Color3.fromRGB;
Color3_new = Color3.new;
table_insert = table.insert;
table_sort = table.sort;
table_clear = table.clear;
table_remove = table.remove;
table_find = table.find;
Instance_new = Instance.new;
Random_new = Random.new();
ColorSequence_new = ColorSequence.new;
NumberSequence_new = NumberSequence.new;
NumberSequenceKeypoint_new = NumberSequenceKeypoint.new;
UDim2_new = UDim2.new;
_tostring = tostring;
_tonumber = tonumber;
os_clock = os.clock;
string_sub = string.sub;
OverlapParams_new = OverlapParams.new;
RaycastParams_new = RaycastParams.new;
Enum_EasingDirection_In = Enum.EasingDirection.In;
Enum_EasingDirection_Out = Enum.EasingDirection.Out;
Enum_EasingDirection_InOut = Enum.EasingDirection.InOut;
Enum_EasingStyle_Sine = Enum.EasingStyle.Sine;
Enum_EasingStyle_Cubic = Enum.EasingStyle.Cubic;
Enum_EasingStyle_Quad = Enum.EasingStyle.Quad;
Enum_EasingStyle_Linear = Enum.EasingStyle.Linear;
Enum_EasingStyle_Exponential = Enum.EasingStyle.Exponential;
Enum_EasingStyle_Circular = Enum.EasingStyle.Circular;
Enum_EasingStyle_Back = Enum.EasingStyle.Back;
Enum_EasingStyle_Quint = Enum.EasingStyle.Quint;
Enum_EasingStyle_Bounce = Enum.EasingStyle.Bounce;
Enum_CameraType_Custom = Enum.CameraType.Custom;
Enum_CameraType_Track = Enum.CameraType.Track;
Enum_CameraType_Scriptable = Enum.CameraType.Scriptable;
Enum_RaycastFilterType_Include = Enum.RaycastFilterType.Include;
Enum_RaycastFilterType_Exclude = Enum.RaycastFilterType.Exclude;
Enum_CoreGuiType_Backpack = Enum.CoreGuiType.Backpack;
Enum_CoreGuiType_EmotesMenu = Enum.CoreGuiType.EmotesMenu;
Enum_RenderPriority_Camera_Value = Enum.RenderPriority.Camera.Value;
Enum_RenderPriority_First_Value = Enum.RenderPriority.First.Value;
Enum_RenderPriority_Character_Value = Enum.RenderPriority.Character.Value;
Enum_Material_Plastic = Enum.Material.Plastic;
Enum_Material_SmoothPlastic = Enum.Material.SmoothPlastic;
Enum_Material_Neon = Enum.Material.Neon;
Enum_Material_Concrete = Enum.Material.Concrete;
Enum_Material_Glass = Enum.Material.Glass;
Enum_Material_Slate = Enum.Material.Slate;
Enum_Material_Wood = Enum.Material.Wood;
Vector3_new = Vector3.new;
Enum_Material_DiamondPlate = Enum.Material.DiamondPlate;
Enum_Material_WoodPlanks = Enum.Material.WoodPlanks;
Enum_AnimationPriority_Action3 = Enum.AnimationPriority.Action3;
Enum_AnimationPriority_Action4 = Enum.AnimationPriority.Action4;
Enum_HighlightDepthMode_Occluded = Enum.HighlightDepthMode.Occluded;
Enum_PlaybackState_Begin = Enum.PlaybackState.Begin;
Enum_PlaybackState_Completed = Enum.PlaybackState.Completed;
Enum_KeyCode_B = Enum.KeyCode.B;
Enum_KeyCode_E = Enum.KeyCode.E;
Enum_KeyCode_P = Enum.KeyCode.P;
Enum_KeyCode_DPadRight = Enum.KeyCode.DPadRight;
Enum_KeyCode_DPadLeft = Enum.KeyCode.DPadLeft;
Enum_KeyCode_RightShift = Enum.KeyCode.RightShift;
Enum_KeyCode_LeftShift = Enum.KeyCode.LeftShift;
Enum_KeyCode_ButtonL1 = Enum.KeyCode.ButtonL1;
Enum_KeyCode_ButtonL2 = Enum.KeyCode.ButtonL2;
Enum_KeyCode_ButtonR2 = Enum.KeyCode.ButtonR2;
Enum_KeyCode_ButtonR1 = Enum.KeyCode.ButtonR1;
Enum_KeyCode_ButtonL3 = Enum.KeyCode.ButtonL3;
Enum_UserInputType_Keyboard = Enum.UserInputType.Keyboard;
Enum_UserInputType_MouseButton1 = Enum.UserInputType.MouseButton1;
Enum_UserInputType_MouseButton2 = Enum.UserInputType.MouseButton2;
Enum_UserInputType_MouseButton3 = Enum.UserInputType.MouseButton3;
Enum_UserInputType_MouseMovement = Enum.UserInputType.MouseMovement;
Enum_UserInputType_Touch = Enum.UserInputType.Touch;
Enum_UserInputState_Begin = Enum.UserInputState.Begin;
Enum_UserInputState_End = Enum.UserInputState.End;
Enum_AccessoryType_Hair = Enum.AccessoryType.Hair;
Enum_AccessoryType_Hat = Enum.AccessoryType.Hat;
Enum_AccessoryType_Shoulder = Enum.AccessoryType.Shoulder;
Enum_AccessoryType_Unknown = Enum.AccessoryType.Unknown;
Enum_AccessoryType_Face = Enum.AccessoryType.Face;
Enum_RotationType_CameraRelative = Enum.RotationType.CameraRelative;
Enum_HumanoidStateType_Dead = Enum.HumanoidStateType.Dead;


local v102 = _require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("BoatTween"));
local l_Players_0 = _game:GetService("Players");
local l_GuiService_0 = _game:GetService("GuiService");
local l_UserInputService_0 = _game:GetService("UserInputService");
local l_UserService_0 = _game:GetService("UserService");
local l_RunService_0 = _game:GetService("RunService");
local l_Lighting_0 = _game:GetService("Lighting");
local l_RenderStepped_0 = l_RunService_0.RenderStepped;
local l_CurrentCamera_0 = _workspace.CurrentCamera;
local l_Enum_CameraType_Custom_0 = Enum_CameraType_Custom;
local l_LocalPlayer_0 = l_Players_0.LocalPlayer;
local l_PlayerGui_0 = l_LocalPlayer_0:WaitForChild("PlayerGui");
local v19 = l_LocalPlayer_0.Character or l_LocalPlayer_0.CharacterAdded:Wait();
local l_Map_0 = workspace.Map
local v66 = RaycastParams_new();
v66.FilterType = Enum_RaycastFilterType_Include;
v66.FilterDescendantsInstances = {
	l_Map_0:WaitForChild("Parts"), 
};
local l_Tiles_0 = l_Map_0:WaitForChild("Parts"):WaitForChild("Tile");
local v68 = RaycastParams_new();
v68.FilterType = Enum_RaycastFilterType_Include;
v68.FilterDescendantsInstances = {
	l_Tiles_0
};

local l_CurrentCamera_1 = _workspace.CurrentCamera;
local l_Torso_0 = v19:WaitForChild("Torso");
local l_Humanoid_0 = v19:WaitForChild("Humanoid");
local l_Head_0 = v19:WaitForChild("Head");
local l_HumanoidRootPart_0 = v19:WaitForChild("HumanoidRootPart");
local l_Trees_0 = l_Map_0:WaitForChild("Bushes")
local l_Bushes_0 = l_Map_0:WaitForChild("Trees")
local RS = game.ReplicatedStorage
local l_Assets_0 = RS.Assets
local l_VFX_0 = workspace.VFX
local l_TweenService_0 = TweenService
local l_Sounds_0 = RS.Assets.Sounds
local l_FlyingRocksStorage_0 = workspace.VFX.FlyingRocksStorage
local v79 = _require(RS:WaitForChild("Modules"):WaitForChild("CameraShaker")).new(Enum_RenderPriority_Camera_Value, function(v77) --[[ Line: 319 ]]
	-- upvalues: l_CurrentCamera_1 (copy)
	local l_l_CurrentCamera_1_0 = l_CurrentCamera_1;
	l_l_CurrentCamera_1_0.CFrame = l_l_CurrentCamera_1_0.CFrame * v77;
end);
local l_Cutscenes_0 = l_Assets_0:WaitForChild("Cutscenes");
local l_Cutscenes_1= workspace:WaitForChild("Cutscenes");
local l_Characters_0 = _workspace:WaitForChild("Live");
local l_Borders_0 = workspace.Map.Parts:WaitForChild('BackGround/MapSide')
local v34 = {};
local v35 = {};
local v36 = false;
local v37 = false;
local v38 = false;
local v39 = nil;
local v99 = {
	PlaySoundInInstance = function(v82, v83, v84, v85) --[[ Line: 407 ]] --[[ Name: PlaySoundInInstance ]]
		-- upvalues: l_Sounds_0 (copy), v81 (copy)
		if typeof(v82) ~= "Instance" then
			return;
		elseif typeof(v83) ~= "string" then
			return;
		else
			local l_l_Sounds_0_FirstChild_0 = l_Sounds_0:FindFirstChild(v83);
			if not l_l_Sounds_0_FirstChild_0 then
				return;
			else
				if typeof(v84) ~= "boolean" then
					v84 = true;
				end;
				if typeof(v85) ~= "boolean" then
					v85 = false;
				end;
				local v87 = l_l_Sounds_0_FirstChild_0:Clone();
				if v84 == true then
					v87.Ended:Once(function() --[[ Line: 417 ]]
						-- upvalues: v87 (copy)
						if v87 ~= nil and v87.Parent ~= nil then
							v87:Destroy();
						end;
					end);
				end;
				v87.Looped = v85;
				v87:SetAttribute("DefaultVolume", v87.Volume);
				v87.Volume = v87.Volume 
				v87.Parent = v82;
				v87:Play();
				return v87;
			end;
		end;
	end, 
	EndCameraShake = function() --[[ Line: 1985 ]] --[[ Name: EndCameraShake ]]
		-- upvalues: v93 (copy)
		v93:EndCameraShake();
	end, 
	PlaySoundAtCFrame = function(v88, v89, v90, v91) --[[ Line: 432 ]] --[[ Name: PlaySoundAtCFrame ]]
		-- upvalues: l_Sounds_0 (copy), v81 (copy), l_VFX_0 (copy)
		if typeof(v88) ~= "CFrame" and typeof(v88) ~= "Vector3" then
			return;
		elseif typeof(v89) ~= "string" then
			return;
		else
			local l_l_Sounds_0_FirstChild_1 = l_Sounds_0:FindFirstChild(v89);
			if not l_l_Sounds_0_FirstChild_1 then
				return;
			else
				if typeof(v90) ~= "boolean" then
					v90 = true;
				end;
				if typeof(v91) ~= "boolean" then
					v91 = false;
				end;
				local v93 = Instance_new("Part");
				v93.Name = "SoundPlayerPart";
				v93.Material = Enum_Material_SmoothPlastic;
				v93.Anchored = true;
				v93.Massless = true;
				v93.CanCollide = false;
				v93.CanQuery = false;
				v93.CanTouch = false;
				v93.CastShadow = false;
				v93.EnableFluidForces = false;
				v93.Transparency = 1;
				v93.Size = Vector3_zero;
				if typeof(v88) == "CFrame" then
					v93.CFrame = v88;
				else
					v93.Position = v88;
				end;
				local v94 = l_l_Sounds_0_FirstChild_1:Clone();
				if v90 == true then
					v94.Ended:Once(function() --[[ Line: 463 ]]
						-- upvalues: v93 (copy)
						if v93 ~= nil and v93.Parent ~= nil then
							v93:Destroy();
						end;
					end);
				end;
				v94.Looped = v91;
				v94:SetAttribute("DefaultVolume", v94.Volume);
				v94.Volume = v94.Volume 
				v94.Parent = v93;
				v93.Parent = l_VFX_0;
				v94:Play();
				return v94, v93;
			end;
		end;
	end, 
	PlaySound = function(v95, v96, v97) --[[ Line: 483 ]] --[[ Name: PlaySound ]]
		-- upvalues: l_Sounds_0 (copy), v81 (copy), l_VFX_0 (copy)
		if typeof(v96) ~= "boolean" then
			v96 = true;
		end;
		if typeof(v97) ~= "boolean" then
			v97 = false;
		end;
		local v98 = l_Sounds_0[v95]:Clone();
		if v96 == true then
			v98.Ended:Once(function() --[[ Line: 491 ]]
				-- upvalues: v98 (copy)
				if v98 ~= nil and v98.Parent ~= nil then
					v98:Destroy();
				end;
			end);
		end;
		v98.Looped = v97;
		v98:SetAttribute("DefaultVolume", v98.Volume);
		v98.Volume = v98.Volume 
		v98.Parent = l_VFX_0;
		v98:Play();
		return v98;
	end
};
l_LocalPlayer_0.CharacterAdded:Connect(function(v44) --[[ Line: 200 ]]
	-- upvalues: v19 (ref), l_HumanoidRootPart_0 (ref), l_Network_0 (ref), l_Torso_0 (ref), l_Humanoid_0 (ref), l_CurrentCamera_0 (copy), l_Head_0 (ref), v43 (copy), l_Animator_0 (ref), l_Skills_0 (ref), l_PlayerGui_0 (copy), l_Buttons_0 (ref)
	v19 = v44;
	l_HumanoidRootPart_0 = v44:WaitForChild("HumanoidRootPart");
	l_Torso_0 = v44:WaitForChild("Torso");
	l_Humanoid_0 = v44:WaitForChild("Humanoid");
	l_CurrentCamera_0.CameraSubject = l_Humanoid_0;
	l_Head_0 = v44:WaitForChild("Head");
end);
VFXService = {
	EndCameraShake = function() --[[ Line: 1985 ]] --[[ Name: EndCameraShake ]]
		-- upvalues: v93 (copy)
		v93:EndCameraShake();
	end, 
	PlaySoundAtCFrame = function(v88, v89, v90, v91) --[[ Line: 432 ]] --[[ Name: PlaySoundAtCFrame ]]
		-- upvalues: l_Sounds_0 (copy), v81 (copy), l_VFX_0 (copy)
		if typeof(v88) ~= "CFrame" and typeof(v88) ~= "Vector3" then
			return;
		elseif typeof(v89) ~= "string" then
			return;
		else
			local l_l_Sounds_0_FirstChild_1 = l_Sounds_0:FindFirstChild(v89);
			if not l_l_Sounds_0_FirstChild_1 then
				return;
			else
				if typeof(v90) ~= "boolean" then
					v90 = true;
				end;
				if typeof(v91) ~= "boolean" then
					v91 = false;
				end;
				local v93 = Instance_new("Part");
				v93.Name = "SoundPlayerPart";
				v93.Material = Enum_Material_SmoothPlastic;
				v93.Anchored = true;
				v93.Massless = true;
				v93.CanCollide = false;
				v93.CanQuery = false;
				v93.CanTouch = false;
				v93.CastShadow = false;
				v93.EnableFluidForces = false;
				v93.Transparency = 1;
				v93.Size = Vector3_zero;
				if typeof(v88) == "CFrame" then
					v93.CFrame = v88;
				else
					v93.Position = v88;
				end;
				local v94 = l_l_Sounds_0_FirstChild_1:Clone();
				if v90 == true then
					v94.Ended:Once(function() --[[ Line: 463 ]]
						-- upvalues: v93 (copy)
						if v93 ~= nil and v93.Parent ~= nil then
							v93:Destroy();
						end;
					end);
				end;
				v94.Looped = v91;
				v94:SetAttribute("DefaultVolume", v94.Volume);
				v94.Volume = v94.Volume 
				v94.Parent = v93;
				v93.Parent = l_VFX_0;
				v94:Play();
				return v94, v93;
			end;
		end;
	end, 
	PlaySound = function(v95, v96, v97) --[[ Line: 483 ]] --[[ Name: PlaySound ]]
		-- upvalues: l_Sounds_0 (copy), v81 (copy), l_VFX_0 (copy)
		if typeof(v96) ~= "boolean" then
			v96 = true;
		end;
		if typeof(v97) ~= "boolean" then
			v97 = false;
		end;
		local v98 = l_Sounds_0[v95]:Clone();
		if v96 == true then
			v98.Ended:Once(function() --[[ Line: 491 ]]
				-- upvalues: v98 (copy)
				if v98 ~= nil and v98.Parent ~= nil then
					v98:Destroy();
				end;
			end);
		end;
		v98.Looped = v97;
		v98:SetAttribute("DefaultVolume", v98.Volume);
		v98.Volume = v98.Volume 
		v98.Parent = l_VFX_0;
		v98:Play();
		return v98;
	end,
	CreateBind = function(v197, v198, v199) --[[ Line: 1203 ]] --[[ Name: CreateBind ]]
		-- upvalues: l_Players_0 (copy)
		if typeof(v197) ~= "Instance" then
			return;
		elseif not v197:IsA("Model") then
			return;
		elseif typeof(v198) ~= "string" then
			return;
		else
			local v200 = Instance_new("Configuration");
			v200.Name = v198;
			v200:SetAttribute("Bind", true);
			v200.Parent = v197;
			local v201 = nil;
			local v202 = nil;
			local v203 = nil;
			local function v204() --[[ Line: 1217 ]] --[[ Name: OnEnd ]]
				-- upvalues: v201 (ref), v202 (ref), v203 (ref), v199 (copy)
				if v201 ~= nil then
					v201:Disconnect();
					v201 = nil;
				end;
				if v202 ~= nil then
					v202:Disconnect();
					v202 = nil;
				end;
				if v203 ~= nil then
					v203:Disconnect();
					v203 = nil;
				end;
				if typeof(v199) == "function" then
					v199();
				end;
			end;
			local l_l_Players_0_PlayerFromCharacter_0 = l_Players_0:GetPlayerFromCharacter(v197);
			v201 = if l_l_Players_0_PlayerFromCharacter_0 ~= nil and l_l_Players_0_PlayerFromCharacter_0.Parent ~= nil then l_l_Players_0_PlayerFromCharacter_0.CharacterRemoving:Once(v204) else v197.HumanoidRootPart.Destroying:Once(v204);
			v202 = v200.Destroying:Once(v204);
			v203 = v197.Destroying:Once(v204);
			return v200;
		end;
	end, 
	DestroyBind = function(v206, v207, v208) --[[ Line: 1239 ]] --[[ Name: DestroyBind ]]
		if typeof(v206) ~= "Instance" then
			return;
		elseif not v206:IsA("Model") then
			return;
		elseif typeof(v207) ~= "string" then
			return;
		else
			if typeof(v208) ~= "boolean" then
				v208 = false;
			end;
			if v208 == false then
				for _, v210 in _pairs(v206:GetChildren()) do
					if v210:IsA("Configuration") and v210.Name == v207 then
						v210:Destroy();
						break;
					end;
				end;
			end;
			if v208 == true then
				for _, v212 in _pairs(v206:GetChildren()) do
					if v212:IsA("Configuration") and v212.Name == v207 then
						v212:Destroy();
					end;
				end;
			end;
			return;
		end;
	end, 
	CheckBind = function(v213, v214) --[[ Line: 1269 ]] --[[ Name: CheckBind ]]
		if typeof(v213) ~= "Instance" then
			return;
		elseif not v213:IsA("Model") then
			return;
		elseif typeof(v214) ~= "string" then
			return;
		else
			local v215 = false;
			for _, v217 in _pairs(v213:GetChildren()) do
				if v217:IsA("Configuration") and v217.Name == v214 then
					return true;
				end;
			end;
			return v215;
		end;
	end, 
	DestroyAllBinds = function(v218, v219) --[[ Line: 1288 ]] --[[ Name: DestroyAllBinds ]]
		if typeof(v218) ~= "Instance" then
			return;
		elseif not v218:IsA("Model") then
			return;
		else
			if typeof(v219) ~= "table" then
				v219 = {};
			end;
			for _, v221 in _pairs(v218:GetChildren()) do
				if v221:IsA("Configuration") and not table_find(v219, v221.Name) then
					v221:Destroy();
				end;
			end;
			return;
		end;
	end, 
	MakeDarker = function(v222, v223, v224, v225) --[[ Line: 1302 ]] --[[ Name: MakeDarker ]]
		if typeof(v223) ~= "number" then
			v223 = 10;
		end;
		if typeof(v224) ~= "number" then
			v224 = 10;
		end;
		if typeof(v225) ~= "number" then
			v225 = 10;
		end;
		local v226 = v222.R * 255 - v223;
		if v226 < 0 then
			v226 = 0;
		end;
		if v226 > 255 then
			v226 = 255;
		end;
		local v227 = v222.G * 255 - v224;
		if v227 < 0 then
			v227 = 0;
		end;
		if v227 > 255 then
			v227 = 255;
		end;
		local v228 = v222.B * 255 - v225;
		if v228 < 0 then
			v228 = 0;
		end;
		if v228 > 255 then
			v228 = 255;
		end;
		return Color3_fromRGB(v226, v227, v228);
	end, 
	GetCircularWallRocksProperties = function(v229, v230, v231, v232, v233, v234, v235, v236, v237, v238, v239, v240, v241, v242, v243, v244, v245, v246) --[[ Line: 1325 ]] --[[ Name: GetCircularWallRocksProperties ]]
		-- upvalues: v66 (copy)
		if typeof(v229) ~= "table" then
			v229 = {};
		end;
		if typeof(v230) ~= "CFrame" then
			return;
		elseif typeof(v231) ~= "number" and typeof(v231) ~= "table" then
			return;
		elseif typeof(v232) ~= "number" then
			return;
		elseif typeof(v233) ~= "number" and typeof(v233) ~= "table" then
			return;
		elseif typeof(v234) ~= "number" and typeof(v234) ~= "table" then
			return;
		elseif typeof(v235) ~= "number" and typeof(v235) ~= "table" then
			return;
		elseif typeof(v236) ~= "number" and typeof(v236) ~= "table" then
			return;
		elseif typeof(v237) ~= "number" and typeof(v237) ~= "table" then
			return;
		elseif typeof(v238) ~= "number" and typeof(v238) ~= "table" then
			return;
		elseif typeof(v239) ~= "table" then
			return;
		else
			if typeof(v240) ~= "number" then
				v240 = 5;
			end;
			if typeof(v241) ~= "boolean" then
				v241 = false;
			end;
			if typeof(v242) ~= "table" then
				v242 = {
					IncludeDuplicate = true, 
					ShrinkFactor = 1.25, 
					RadiusOffset = 1
				};
			end;
			if typeof(v243) ~= "number" then
				v243 = 25;
			end;
			if typeof(v244) ~= "number" and typeof(v244) ~= "table" then
				v244 = {
					0, 
					0
				};
			end;
			if typeof(v245) ~= "number" and typeof(v245) ~= "table" then
				v245 = {
					0, 
					0
				};
			end;
			if typeof(v246) ~= "number" and typeof(v246) ~= "table" then
				v246 = {
					0, 
					0
				};
			end;
			local v247 = 0;
			local v248 = 360 / v232;
			local _ = {};
			local l_v230_0 = v230;
			local l_v231_0 = v231;
			local l_v233_0 = v233;
			local l_v234_0 = v234;
			local l_v235_0 = v235;
			local l_v236_0 = v236;
			local l_v237_0 = v237;
			local l_v238_0 = v238;
			local l_v244_0 = v244;
			local l_v245_0 = v245;
			local l_v246_0 = v246;
			local v261 = _workspace:Raycast(l_v230_0.Position + l_v230_0.UpVector, -l_v230_0.UpVector * math_abs(v243 + 1), v66);
			if v261 then
				local l_LookVector_1 = v230.LookVector;
				local _ = l_LookVector_1.X;
				local _ = l_LookVector_1.Z;
				l_v230_0 = CFrame_new(v261.Position, v261.Position + v261.Normal);
				for _ = 1, v232 do
					v231 = l_v231_0;
					v233 = l_v233_0;
					v234 = l_v234_0;
					v235 = l_v235_0;
					v236 = l_v236_0;
					v237 = l_v237_0;
					v238 = l_v238_0;
					v244 = l_v244_0;
					v245 = l_v245_0;
					v246 = l_v246_0;
					if typeof(l_v231_0) == "table" then
						v231 = Random_new:NextNumber(l_v231_0[1], l_v231_0[2]);
					end;
					if typeof(l_v233_0) == "table" then
						v233 = Random_new:NextNumber(l_v233_0[1], l_v233_0[2]);
					end;
					if typeof(l_v234_0) == "table" then
						v234 = Random_new:NextNumber(l_v234_0[1], l_v234_0[2]);
					end;
					if typeof(l_v235_0) == "table" then
						v235 = Random_new:NextNumber(l_v235_0[1], l_v235_0[2]);
					end;
					if typeof(l_v236_0) == "table" then
						v236 = Random_new:NextNumber(l_v236_0[1], l_v236_0[2]);
					end;
					if typeof(l_v237_0) == "table" then
						v237 = Random_new:NextNumber(l_v237_0[1], l_v237_0[2]);
					end;
					if typeof(l_v238_0) == "table" then
						v238 = Random_new:NextNumber(l_v238_0[1], l_v238_0[2]);
					end;
					if typeof(l_v244_0) == "table" then
						v244 = Random_new:NextNumber(l_v244_0[1], l_v244_0[2]);
					end;
					if typeof(l_v245_0) == "table" then
						v245 = Random_new:NextNumber(l_v245_0[1], l_v245_0[2]);
					end;
					if typeof(l_v246_0) == "table" then
						v246 = Random_new:NextNumber(l_v246_0[1], l_v246_0[2]);
					end;
					local v266 = vector_create(v233, v234, v235);
					local v267 = Color3_fromRGB();
					local l_Enum_Material_Concrete_0 = Enum_Material_Concrete;
					local v269 = nil;
					local v270 = nil;
					local v271 = nil;
					local v272 = {
						v233, 
						v234, 
						v235
					};
					table.sort(v272);
					local v273 = v272[3];
					local v274 = l_v230_0 * CFrame_Angles(0, 0, math_rad(v247)) * CFrame_new(v231, 0, v273);
					local l_Position_2 = v274.Position;
					local v276 = _workspace:Raycast(l_Position_2 + l_v230_0.LookVector * v273 * 2, -l_v230_0.LookVector * v273 * 2.5, v66);
					if v276 then
						v267 = VFXService.MakeDarker(v276.Instance.Color, 10, 10, 10);
						l_Enum_Material_Concrete_0 = if v276.Instance.Material == Enum_Material_Plastic then Enum_Material_SmoothPlastic else v276.Instance.Material;
						local v277 = math_acos(v276.Normal:Dot(vector_create(0, 1, 0)));
						v274 = v274 * CFrame_Angles(0, v277 / 2, math_pi / 2);
						l_Position_2 = v276.Position;
						for _, v279 in _pairs(v276.Instance:GetChildren()) do
							if v279:IsA("Texture") then
								v270 = v279.Texture;
								v271 = v279.Transparency;
								break;
							end;
						end;
						if v241 == true then
							v269 = vector_create(math_random(-180, 180), math_random(-180, 180), math_random(-180, 180));
						else
							l_Position_2 = l_Position_2 - l_v230_0.LookVector * (v234 / 8);
						end;
						v229[#v229 + 1] = {
							Lifetime = v240, 
							AnimationStyle = v239, 
							Size = v266, 
							Color = v267, 
							Material = l_Enum_Material_Concrete_0, 
							Orientation = v269, 
							CFrame = v274 * CFrame_new(v244, v245, v246), 
							Position = l_Position_2, 
							Texture = v270, 
							TextureTransparency = v271
						};
						if v242.IncludeDuplicate == true then
							v229[#v229 + 1] = {
								Lifetime = v240, 
								AnimationStyle = v239, 
								Size = v266 / (v242.ShrinkFactor or 1.15), 
								Color = v267, 
								Material = l_Enum_Material_Concrete_0, 
								Orientation = v269, 
								CFrame = v274 * CFrame_new(v244, v245, v246), 
								Position = l_Position_2 + CFrame_new(l_Position_2, l_v230_0.Position).LookVector * (v242.RadiusOffset or 1), 
								Texture = v270, 
								TextureTransparency = v271
							};
						end;
						v247 = v247 + v248;
					end;
				end;
				return;
			else
				return;
			end;
		end;
	end, 
	GetCircularRocksProperties = function(v280, v281, v282, v283, v284, v285, v286, v287, v288, v289, v290, v291, v292, v293, v294, v295, v296, v297, v298, v299) --[[ Line: 1478 ]] --[[ Name: GetCircularRocksProperties ]]
		-- upvalues: v66 (copy)
		if typeof(v280) ~= "table" then
			v280 = {};
		end;
		if typeof(v281) ~= "CFrame" then
			return;
		elseif typeof(v282) ~= "number" and typeof(v282) ~= "table" then
			return;
		elseif typeof(v283) ~= "number" then
			return;
		elseif typeof(v284) ~= "number" and typeof(v284) ~= "table" then
			return;
		elseif typeof(v285) ~= "number" and typeof(v285) ~= "table" then
			return;
		elseif typeof(v286) ~= "number" and typeof(v286) ~= "table" then
			return;
		elseif typeof(v287) ~= "number" and typeof(v287) ~= "table" then
			return;
		elseif typeof(v288) ~= "number" and typeof(v288) ~= "table" then
			return;
		elseif typeof(v289) ~= "number" and typeof(v289) ~= "table" then
			return;
		elseif typeof(v290) ~= "table" then
			return;
		else
			if typeof(v291) ~= "number" then
				v291 = 5;
			end;
			if typeof(v292) ~= "boolean" then
				v292 = false;
			end;
			if typeof(v293) ~= "table" then
				v293 = {
					IncludeDuplicate = true, 
					ShrinkFactor = 1.25, 
					RadiusOffset = 1
				};
			end;
			if typeof(v294) ~= "number" then
				v294 = 25;
			end;
			if typeof(v295) ~= "number" and typeof(v295) ~= "table" then
				v295 = {
					0, 
					0
				};
			end;
			if typeof(v296) ~= "number" and typeof(v296) ~= "table" then
				v296 = {
					0, 
					0
				};
			end;
			if typeof(v297) ~= "number" and typeof(v297) ~= "table" then
				v297 = {
					0, 
					0
				};
			end;
			local v300 = 0;
			local v301 = 360 / v283;
			local _ = {};
			local l_v281_0 = v281;
			local l_v282_0 = v282;
			local l_v284_0 = v284;
			local l_v285_0 = v285;
			local l_v286_0 = v286;
			local l_v287_0 = v287;
			local l_v288_0 = v288;
			local l_v289_0 = v289;
			local l_v295_0 = v295;
			local l_v296_0 = v296;
			local l_v297_0 = v297;
			local v314 = _workspace:Raycast(l_v281_0.Position + vector_create(0, 1, 0), vector_create(0, -math_abs(v294 + 1), 0), v66);
			if v314 then
				local l_LookVector_2 = v281.LookVector;
				local l_X_1 = l_LookVector_2.X;
				local l_Z_1 = l_LookVector_2.Z;
				local v318 = 0;
				if l_X_1 == 0 and l_Z_1 == 0 then
					v318 = 0.001;
				end;
				l_v281_0 = CFrame_new(v314.Position, v314.Position + vector_create(l_X_1, v318, l_Z_1));
				for _ = 1, v283 do
					v282 = l_v282_0;
					v284 = l_v284_0;
					v285 = l_v285_0;
					v286 = l_v286_0;
					v287 = l_v287_0;
					v288 = l_v288_0;
					v289 = l_v289_0;
					if typeof(l_v282_0) == "table" then
						v282 = Random_new:NextNumber(l_v282_0[1], l_v282_0[2]);
					end;
					if typeof(l_v284_0) == "table" then
						v284 = Random_new:NextNumber(l_v284_0[1], l_v284_0[2]);
					end;
					if typeof(l_v285_0) == "table" then
						v285 = Random_new:NextNumber(l_v285_0[1], l_v285_0[2]);
					end;
					if typeof(l_v286_0) == "table" then
						v286 = Random_new:NextNumber(l_v286_0[1], l_v286_0[2]);
					end;
					if typeof(l_v287_0) == "table" then
						v287 = Random_new:NextNumber(l_v287_0[1], l_v287_0[2]);
					end;
					if typeof(l_v288_0) == "table" then
						v288 = Random_new:NextNumber(l_v288_0[1], l_v288_0[2]);
					end;
					if typeof(l_v289_0) == "table" then
						v289 = Random_new:NextNumber(l_v289_0[1], l_v289_0[2]);
					end;
					if typeof(l_v295_0) == "table" then
						v295 = Random_new:NextNumber(l_v295_0[1], l_v295_0[2]);
					end;
					if typeof(l_v296_0) == "table" then
						v296 = Random_new:NextNumber(l_v296_0[1], l_v296_0[2]);
					end;
					if typeof(l_v297_0) == "table" then
						v297 = Random_new:NextNumber(l_v297_0[1], l_v297_0[2]);
					end;
					v318 = vector_create(v284, v285, v286);
					local v320 = Color3_fromRGB(120, 120, 120);
					local l_Enum_Material_Concrete_1 = Enum_Material_Concrete;
					local v322 = nil;
					local v323 = nil;
					local v324 = nil;
					local v325 = {
						v284, 
						v285, 
						v286
					};
					table.sort(v325);
					local v326 = v325[3];
					local v327 = l_v281_0 * CFrame_Angles(0, math_rad(v300), 0) * CFrame_new(0, 0, v282);
					local l_Position_3 = v327.Position;
					local v329 = _workspace:Raycast(l_Position_3 + vector_create(0, 5, 0), vector_create(0, -v326 * 2.5, 0), v66);
					if v329 then
						v320 = VFXService.MakeDarker(v329.Instance.Color, 10, 10, 10);
						l_Enum_Material_Concrete_1 = if v329.Instance.Material == Enum_Material_Plastic then Enum_Material_SmoothPlastic else v329.Instance.Material;
						if v329.Normal.Y ~= 1 then
							v327 = CFrame_new(v329.Position, v329.Position + v329.Normal);
						end;
						l_Position_3 = v329.Position;
						for _, v331 in _pairs(v329.Instance:GetChildren()) do
							if v331:IsA("Texture") then
								v323 = v331.Texture;
								v324 = v331.Transparency;
								break;
							end;
						end;
						if v292 == true then
							v322 = vector_create(math_random(-180, 180), math_random(-180, 180), math_random(-180, 180));
						else
							local v332 = nil;
							v332 = if typeof(v298) == "Vector3" then v298 else if typeof(v299) == "number" then vector_create(0, v282 * v299 or 1, 0) else vector_create(0, v282, 0);
							v327 = CFrame_new(v329.Position, l_v281_0.Position + v332);
							local v333 = math_sqrt(math_pow(v332.Y, 2) + math_pow(v282, 2));
							local v334 = 2 * (v285 * 0.5 / math_cos(math_asin(v332.Y / v333)));
							if v295 ~= 0 or v296 ~= 0 or v297 ~= 0 then
								local l_Position_4 = l_v281_0.Position;
								local v336 = vector_create(l_Position_3.X, l_Position_4.Y, l_Position_3.Z);
								local v337 = CFrame_new(l_Position_4, v336);
								l_Position_3 = l_Position_3 + (v337.LookVector * v297 + v337.RightVector * v295);
								local v338 = _workspace:Raycast(l_Position_3 + vector_create(0, 5, 0), vector_create(0, -v326 * 2.5, 0), v66);
								if v338 then
									v320 = VFXService.MakeDarker(v338.Instance.Color, 10, 10, 10);
									l_Enum_Material_Concrete_1 = if v338.Instance.Material == Enum_Material_Plastic then Enum_Material_SmoothPlastic else v338.Instance.Material;
									l_Position_3 = v338.Position;
									for _, v340 in _pairs(v338.Instance:GetChildren()) do
										if v340:IsA("Texture") then
											v323 = v340.Texture;
											v324 = v340.Transparency;
											break;
										end;
									end;
								else
									continue;
								end;
							end;
							l_Position_3 = l_Position_3 - vector_create(0, v334 / 8 + v296, 0);
						end;
						v280[#v280 + 1] = {
							Lifetime = v291, 
							AnimationStyle = v290, 
							Size = v318, 
							Color = v320, 
							Material = l_Enum_Material_Concrete_1, 
							Orientation = v322, 
							CFrame = v327, 
							Position = l_Position_3, 
							Texture = v323, 
							TextureTransparency = v324
						};
						if v293.IncludeDuplicate == true then
							v280[#v280 + 1] = {
								Lifetime = v291, 
								AnimationStyle = v290, 
								Size = v318 / (v293.ShrinkFactor or 1.15), 
								Color = v320, 
								Material = l_Enum_Material_Concrete_1, 
								Orientation = v322, 
								CFrame = v327, 
								Position = l_Position_3 + v327.LookVector * (v293.RadiusOffset or v318.Z / 4) + v327.UpVector * (v293.RadiusOffsetY or -v318.Y / 4) + vector_create(0, v293.LinearOffsetY or 0, 0), 
								Texture = v323, 
								TextureTransparency = v324
							};
						end;
						v300 = v300 + v301;
					end;
				end;
				return;
			else
				return;
			end;
		end;
	end, 

	MatchCharacter = function(v790, v791) --[[ Line: 3344 ]] --[[ Name: MatchCharacter ]]
		if typeof(v790) ~= "Instance" or typeof(v791) ~= "Instance" then
			return;
		else
			local v792 = {};
			local l_face_0 = v790.Head:FindFirstChild("face");
			local l_Mesh_0 = v790["Right Arm"]:FindFirstChild("Mesh");
			local l_Mesh_1 = v790["Left Arm"]:FindFirstChild("Mesh");
			local l_Mesh_2 = v790["Right Leg"]:FindFirstChild("Mesh");
			local l_Mesh_3 = v790["Left Leg"]:FindFirstChild("Mesh");
			local l_Mesh_4 = v790.Torso:FindFirstChild("Mesh");
			local l_Mesh_5 = v790.Head:FindFirstChild("Mesh");
			local l_Color_0 = v790["Right Arm"].Color;
			local l_Color_1 = v790["Left Arm"].Color;
			local l_Color_2 = v790["Right Leg"].Color;
			local l_Color_3 = v790["Left Leg"].Color;
			local l_Color_4 = v790.Head.Color;
			local l_Color_5 = v790.Torso.Color;
			local v806 = v791.Torso.Transparency == 1;
			for _, v808 in pairs(v790:GetChildren()) do
				if v808:IsA("Shirt") or v808:IsA("Pants") or v808:IsA("CharacterMesh") then
					table.insert(v792, (v808:Clone()));
				end;
			end;
			for _, v810 in pairs(v790.Head:GetChildren()) do
				if v810:IsA("Accessory") then
					local v811 = v810:Clone();
					if v806 then
						v811.Handle.Transparency = 1;
					end;
					table.insert(v792, v811);
				end;
			end;
			for _, v813 in pairs(v791:GetChildren()) do
				if v813:IsA("Accessory") or v813:IsA("Shirt") or v813:IsA("Pants") or v813:IsA("CharacterMesh") then
					v813:Destroy();
				end;
				if v813:IsA("BasePart") and v813.Name ~= "Head" and v813.Name ~= "Torso" and v813.Name ~= "Right Arm" and v813.Name ~= "Left Arm" and v813.Name ~= "Right Leg" and v813.Name ~= "Left Leg" and v813.Name ~= "HumanoidRootPart" then
					v813:Destroy();
				end;
				if v813:IsA("Model") then
					v813:Destroy();
				end;
			end;
			if v791.Head:FindFirstChild("face") then
				v791.Head.face:Destroy();
			end;
			if v791.Head:FindFirstChild("Mesh") then
				v791.Head.Mesh:Destroy();
			end;
			if v791.Torso:FindFirstChild("Mesh") then
				v791.Torso.Mesh:Destroy();
			end;
			if v791["Right Arm"]:FindFirstChild("Mesh") then
				v791["Right Arm"].Mesh:Destroy();
			end;
			if v791["Left Arm"]:FindFirstChild("Mesh") then
				v791["Left Arm"].Mesh:Destroy();
			end;
			if v791["Right Leg"]:FindFirstChild("Mesh") then
				v791["Right Leg"].Mesh:Destroy();
			end;
			if v791["Left Leg"]:FindFirstChild("Mesh") then
				v791["Left Leg"].Mesh:Destroy();
			end;
			v791["Right Arm"].Color = l_Color_0;
			v791["Left Arm"].Color = l_Color_1;
			v791["Right Leg"].Color = l_Color_2;
			v791["Left Leg"].Color = l_Color_3;
			v791.Head.Color = l_Color_4;
			v791.Torso.Color = l_Color_5;
			for _, v815 in pairs(v792) do
				local v816 = v815:Clone();
				if v816:IsA("Accessory") and v816:FindFirstChild("AccessoryWeld") then
					local l_Name_0 = v816.AccessoryWeld.Part1.Name;
					v816.AccessoryWeld.Part0 = v816.Handle;
					if v791:FindFirstChild(l_Name_0) then
						v816.AccessoryWeld.Part1 = v791:FindFirstChild(l_Name_0);
					end;
					v816.AccessoryWeld.C1 = v816.AccessoryWeld.C1;
				end;
				v816.Parent = v791;
			end;
			if l_face_0 ~= nil and l_face_0.Parent ~= nil then
				local v818 = l_face_0:Clone();
				if v806 == true then
					v818.Transparency = 1;
				end;
				v818.Parent = v791.Head;
			end;
			if l_Mesh_5 ~= nil and l_Mesh_5.Parent ~= nil then
				l_Mesh_5:Clone().Parent = v791.Head;
			end;
			if l_Mesh_4 ~= nil and l_Mesh_4.Parent ~= nil then
				l_Mesh_4:Clone().Parent = v791.Torso;
			end;
			if l_Mesh_0 ~= nil and l_Mesh_0.Parent ~= nil then
				l_Mesh_0:Clone().Parent = v791["Right Arm"];
			end;
			if l_Mesh_1 ~= nil and l_Mesh_1.Parent ~= nil then
				l_Mesh_1:Clone().Parent = v791["Left Arm"];
			end;
			if l_Mesh_2 ~= nil and l_Mesh_2.Parent ~= nil then
				l_Mesh_2:Clone().Parent = v791["Right Leg"];
			end;
			if l_Mesh_3 ~= nil and l_Mesh_3.Parent ~= nil then
				l_Mesh_3:Clone().Parent = v791["Left Leg"];
			end;
			return;
		end;
	end,

	GetCharacterClone = function(Character: Model, DisableCollisions, CheckOutfitChanges,MatchCharacter)
		if not Character or not Character.Parent then return end
		DisableCollisions = DisableCollisions or true
		CheckOutfitChanges = CheckOutfitChanges or true

		Character.Archivable = true
		local DisableCollisions = Character:Clone()
		DisableCollisions.Humanoid.PlatformStand = true
		if DisableCollisions then
			for _, v833 in pairs(DisableCollisions:GetDescendants()) do
				if v833:IsA("BasePart") then
					v833.CanCollide = false
					v833.Massless = true
					v833.CollisionGroup = "Nothing"
				elseif (v833:IsA("Script") or v833:IsA("LocalScript")) and v833.Name ~= "Animate" or v833:IsA("Configuration") then
					v833:Destroy()
				end
			end
		else
			for _, v835 in pairs(DisableCollisions:GetDescendants()) do
				if (v835:IsA("Script") or v835:IsA("LocalScript")) and v835.Name ~= "Animate" or v835:IsA("Configuration") then
					v835:Destroy()
				end
			end
		end

		if CheckOutfitChanges then
			local OutfitChanged = nil
			OutfitChanged = Character.ChildAdded:Connect(function(Child)
				if Child.ClassName == "Configuration" and Child.Name == "NewHumanoidDescriptionApplied" and Character ~= nil and Character.Parent ~= nil and DisableCollisions ~= nil and DisableCollisions.Parent ~= nil then
					MatchCharacter(Character, DisableCollisions)
				end
			end)

			DisableCollisions.Destroying:Once(function()
				if OutfitChanged ~= nil then
					OutfitChanged:Disconnect()
				end
				OutfitChanged = nil
			end)
		end

		return DisableCollisions
	end,

	ApplyCircularRocksProperties = function(v341) --[[ Line: 1680 ]] --[[ Name: ApplyCircularRocksProperties ]]
		-- upvalues: l_VFX_0 (copy), l_TweenService_0 (copy)
		if #v341 <= 0 then
			return;
		else
			local v342 = Instance_new("Folder");
			v342.Name = "CircularRocks";
			v342.Parent = l_VFX_0;
			for v343, v344 in _pairs(v341) do
				local v345 = {};
				local l_AnimationStyle_0 = v344.AnimationStyle;
				local l_Lifetime_0 = v344.Lifetime;
				local v348 = Instance_new("Part");
				table_insert(v345, v348);
				v348.Name = "Rock" .. v343;
				v348.Anchored = true;
				v348.CollisionGroup = "Circular Rocks";
				v348.EnableFluidForces = false;
				v348.Massless = true;
				v348.CanQuery = false;
				v348.CanTouch = false;

				for v349, v350 in _pairs(v344) do
					if v350 ~= nil then
						if v349 ~= "Texture" and v349 ~= "Lifetime" and v349 ~= "AnimationStyle" and v349 ~= "TextureTransparency" then
							v348[v349] = v350;
						elseif v349 == "Texture" then
							for v351 = 1, 6 do
								local v352 = Instance_new("Texture");
								v352.Texture = v350;
								if v351 == 1 then
									v352.Face = "Front";
								elseif v351 == 2 then
									v352.Face = "Left";
								elseif v351 == 3 then
									v352.Face = "Right";
								elseif v351 == 4 then
									v352.Face = "Back";
								elseif v351 == 5 then
									v352.Face = "Top";
								elseif v351 == 6 then
									v352.Face = "Bottom";
								end;
								v352.Transparency = v344.TextureTransparency;
								v352.Parent = v348;
							end;
						end;
					end;
				end;
				if typeof(l_AnimationStyle_0) == "table" then
					local v353 = l_AnimationStyle_0[1] or "Rise";
					local v354 = l_AnimationStyle_0[2] or "Sink";
					local v355 = l_AnimationStyle_0[3] or 0.35;
					local v356 = l_AnimationStyle_0[4] or 1.75;
					if v353 == "Rise" then
						local v357 = TweenInfo_new(v355, Enum_EasingStyle_Cubic, Enum_EasingDirection_Out);
						for _, v359 in _pairs(v345) do
							local v360 = {
								v359.Size.X, 
								v359.Size.Y, 
								v359.Size.Z
							};
							local v361 = 0;
							for _, v363 in _ipairs(v360) do
								if v361 < v363 then
									v361 = v363;
								end;
							end;
							local l_Orientation_0 = v359.Orientation;
							v359.Orientation = vector_create(math_random(-180, 180), math_random(-180, 180), math_random(-180, 180));
							v359.Position = v359.Position - vector_create(0, v361 + 1, 0);
							v359.Parent = v342;
							l_TweenService_0:Create(v359, v357, {
								Orientation = l_Orientation_0, 
								Position = v359.Position + vector_create(0, v361 + 1, 0)
							}):Play();
						end;
					end;
					if v353 == "Grow" then
						local v365 = TweenInfo_new(v355, Enum_EasingStyle_Cubic, Enum_EasingDirection_Out);
						for _, v367 in _pairs(v345) do
							local l_Size_0 = v367.Size;
							v367.Size = Vector3_zero;
							v367.Parent = v342;
							l_TweenService_0:Create(v367, v365, {
								Size = l_Size_0
							}):Play();
						end;
					end;
					task_delay(l_Lifetime_0 or 5, function() --[[ Line: 1768 ]]
						-- upvalues: v354 (copy), v356 (copy), v345 (copy), l_TweenService_0 (ref), v342 (copy)
						if v354 == "Sink" then
							local v369 = TweenInfo_new(v356, Enum_EasingStyle_Circular, Enum_EasingDirection_In);
							for _, v371 in _pairs(v345) do
								local l_X_2 = v371.Orientation.X;
								local l_Y_0 = v371.Orientation.Y;
								local _ = v371.Orientation.Z;
								local _ = l_X_2 + math_random(-20, 20);
								local _ = l_Y_0 + math_random(-20, 20);
								local _ = l_Y_0 + math_random(-20, 20);
								l_TweenService_0:Create(v371, v369, {
									Position = v371.Position - vector_create(0, v371.Size.Y + 10, 0)
								}):Play();
							end;
							task_wait(v356);
							v342:Destroy();
						end;
						if v354 == "Shrink" then
							local v378 = TweenInfo_new(v356, Enum_EasingStyle_Circular, Enum_EasingDirection_Out);
							for _, v380 in _pairs(v345) do
								l_TweenService_0:Create(v380, v378, {
									Size = Vector3_zero
								}):Play();
							end;
							task_wait(v356);
							v342:Destroy();
						end;
					end);
				end;
			end;
			return v342;
		end;
	end, 
	GetFlyingRocksProperties = function(v381, v382, v383, v384, v385, v386, v387, v388, v389, v390, v391, v392) --[[ Line: 1807 ]] --[[ Name: GetFlyingRocksProperties ]]
		-- upvalues: v66 (copy)
		if typeof(v382) ~= "CFrame" then
			return;
		else
			if typeof(v384) ~= "table" then
				v384 = {
					15, 
					50
				};
			end;
			if typeof(v385) ~= "table" then
				v385 = {
					40, 
					40
				};
			end;
			if typeof(v386) ~= "table" then
				v386 = {
					15, 
					50
				};
			end;
			if typeof(v387) ~= "number" then
				v387 = 1;
			end;
			if typeof(v388) ~= "number" then
				v388 = 1;
			end;
			if typeof(v389) ~= "number" then
				v389 = 1;
			end;
			if typeof(v390) ~= "number" then
				v390 = 2;
			end;
			v392 = typeof(v392) ~= "number" and 20 or math_abs(v392);
			local v393 = vector_create(v387, v388, v389);
			local v394 = {
				-1, 
				1
			};
			local v395 = #v394;
			for _ = 1, v383 do
				local v397 = nil;
				local v398 = nil;
				local v399 = nil;
				local v400 = nil;
				local l_v382_0 = v382;
				local v402 = _workspace:Raycast(v382.Position, vector_create(0, -v392, 0), v66);
				if v402 then
					v397 = VFXService.MakeDarker(v402.Instance.Color, 10, 10, 10);
					v398 = if v402.Instance.Material == Enum_Material_Plastic then Enum_Material_SmoothPlastic else v402.Instance.Material;
					l_v382_0 = CFrame_new(v402.Position) + vector_create(0, v388 / 2, 0);
					for _, v404 in _pairs(v402.Instance:GetChildren()) do
						if v404:IsA("Texture") then
							v399 = v404.Texture;
							v400 = v404.Transparency;
							break;
						end;
					end;
					local v405 = Random_new:NextNumber(v384[1], v384[2]) * v394[Random_new:NextInteger(1, v395)];
					local v406 = Random_new:NextNumber(v385[1], v385[2]);
					local v407 = Random_new:NextNumber(v386[1], v386[2]) * v394[Random_new:NextInteger(1, v395)];
					local v408 = v390 * v394[Random_new:NextInteger(1, v395)];
					local v409 = v390 * v394[Random_new:NextInteger(1, v395)];
					local v410 = v390 * v394[Random_new:NextInteger(1, v395)];
					v381[#v381 + 1] = {
						Lifetime = v391, 
						Color = v397, 
						Material = v398, 
						Texture = v399, 
						TextureTransparency = v400, 
						CFrame = l_v382_0, 
						Size = v393, 
						AssemblyAngularVelocity = vector_create(v408, v409, v410), 
						AssemblyLinearVelocity = vector_create(v405, v406, v407)
					};
				end;
			end;
			return;
		end;
	end, 
	ApplyFlyingRocksProperties = function(v411) --[[ Line: 1882 ]] --[[ Name: ApplyFlyingRocksProperties ]]
		-- upvalues: l_FlyingRocksStorage_0 (copy), l_TweenService_0 (copy)
		local v412 = Instance_new("Folder");
		v412.Name = "FlyingRocks";
		v412.Parent = l_FlyingRocksStorage_0;
		for v413, v414 in _pairs(v411) do
			local v415 = {};
			local _ = v414.AnimationStyle;
			local l_Lifetime_1 = v414.Lifetime;
			local v418 = Instance_new("Part");
			table_insert(v415, v418);
			v418.Name = "Rock" .. v413;
			v418.CollisionGroup = "Rocks";
			v418.Massless = true;
			v418.CanQuery = false;
			v418.EnableFluidForces = false;
			v418.CanTouch = false;
			v418.Parent = v412;
			for v419, v420 in _pairs(v414) do
				if v420 ~= nil then
					if v419 ~= "Texture" and v419 ~= "Lifetime" and v419 ~= "TextureTransparency" then
						v418[v419] = v420;
					elseif v419 == "Texture" then
						for v421 = 1, 6 do
							local v422 = Instance_new("Texture");
							v422.Texture = v420;
							v422.Face = "Front";
							if v421 == 2 then
								v422.Face = "Left";
							elseif v421 == 3 then
								v422.Face = "Right";
							elseif v421 == 4 then
								v422.Face = "Back";
							elseif v421 == 5 then
								v422.Face = "Top";
							elseif v421 == 6 then
								v422.Face = "Bottom";
							end;
							v422.Transparency = v414.TextureTransparency;
							v422.Parent = v418;
						end;
					end;
				end;
			end;
			task_delay(l_Lifetime_1 or 8, function() --[[ Line: 1931 ]]
				-- upvalues: v415 (copy), l_TweenService_0 (ref), v412 (copy)
				local v423 = TweenInfo_new(0.5, Enum_EasingStyle_Sine, Enum_EasingDirection_Out);
				for _, v425 in _pairs(v415) do
					for _, v427 in _pairs(v425:GetChildren()) do
						if v427:IsA("Texture") then
							l_TweenService_0:Create(v427, v423, {
								Transparency = 1
							}):Play();
						end;
					end;
					local v428 = l_TweenService_0:Create(v425, v423, {
						Size = v425.Size / 2, 
						Transparency = 1
					});
					v428.Completed:Once(function() --[[ Line: 1940 ]]
						-- upvalues: v425 (copy)
						if v425 ~= nil and v425.Parent ~= nil then
							v425:Destroy();
						end;
					end);
					v428:Play();
				end;
				task_wait(0.5);
				v412:Destroy();
			end);
		end;
		return v412;
	end, 
	EmitFromCFrame = function(v429, v430, v431, v432, v433, v434) --[[ Line: 1957 ]] --[[ Name: EmitFromCFrame ]]
		-- upvalues: l_VFX_0 (copy)
		if typeof(v429) ~= "CFrame" then
			return;
		elseif typeof(v430) ~= "table" then
			return;
		else
			if typeof(v431) ~= "number" then
				v431 = 3;
			end;
			if typeof(v432) ~= "boolean" then
				v432 = true;
			end;
			if typeof(v433) ~= "table" then
				v433 = {};
				for _, v436 in _pairs(v430) do
					local l_v436_Attribute_0 = v436:GetAttribute("EmitCount");
					if typeof(l_v436_Attribute_0) == "number" then
						table_insert(v433, l_v436_Attribute_0);
					else
						l_v436_Attribute_0 = _tonumber(v436.Name);
						if typeof(l_v436_Attribute_0) == "number" then
							table_insert(v433, l_v436_Attribute_0);
						else
							return;
						end;
					end;
				end;
			end;
			local v438 = Instance_new("Part");
			v438.CFrame = v429;
			v438.Size = Vector3_zero;
			v438.Material = Enum_Material_SmoothPlastic;
			v438.Massless = true;
			v438.EnableFluidForces = false;
			v438.CanCollide = false;
			v438.Anchored = true;
			v438.CanQuery = false;
			v438.CanTouch = false;
			v438.CastShadow = false;
			v438.Transparency = 1;
			v438.Parent = l_VFX_0;
			local v439 = {};
			for _, v441 in _pairs(v430) do
				local v442 = v441:Clone();
				if typeof(v434) == "Color3" then
					v442.Color = ColorSequence_new(v434);
				end;
				table_insert(v439, v442);
			end;
			if v432 == true then
				local v443 = Instance_new("Attachment");
				v443.Parent = v438;
				for _, v445 in _pairs(v439) do
					v445.Parent = v443;
				end;
			else
				for _, v447 in _pairs(v439) do
					v447.Parent = v438;
				end;
			end;
			for v448, _ in _pairs(v430) do
				local v450 = v433[v448];
				v439[v448]:Emit(v450);
			end;
			v439 = nil;
			task_delay(v431, function() --[[ Line: 2030 ]]
				-- upvalues: v438 (copy)
				if v438 ~= nil and v438.Parent ~= nil then
					v438:Destroy();
				end;
			end);
			return v438;
		end;
	end, 
	EmitFromAttachment = function(v451, v452, v453, _, v455, v456) --[[ Line: 2040 ]] --[[ Name: EmitFromAttachment ]]
		if typeof(v451) ~= "Instance" then
			return;
		elseif not v451:IsA("Attachment") then
			return;
		elseif typeof(v452) ~= "table" then
			return;
		else
			if typeof(v453) ~= "number" then
				v453 = 3;
			end;
			if typeof(v455) ~= "table" then
				v455 = {};
				for _, v458 in _pairs(v452) do
					local l_v458_Attribute_0 = v458:GetAttribute("EmitCount");
					if typeof(l_v458_Attribute_0) == "number" then
						table_insert(v455, l_v458_Attribute_0);
					else
						l_v458_Attribute_0 = _tonumber(v458.Name);
						if typeof(l_v458_Attribute_0) == "number" then
							table_insert(v455, l_v458_Attribute_0);
						else
							return;
						end;
					end;
				end;
			end;
			local v460 = {};
			for _, v462 in _pairs(v452) do
				local v463 = v462:Clone();
				if typeof(v456) == "Color3" then
					v463.Color = ColorSequence_new(v456);
				end;
				table_insert(v460, v463);
			end;
			for _, v465 in _pairs(v460) do
				v465.Parent = v451;
			end;
			for v466, _ in _pairs(v452) do
				local v468 = v455[v466];
				v460[v466]:Emit(v468);
			end;
			task_delay(v453, function() --[[ Line: 2084 ]]
				-- upvalues: v460 (ref)
				for _, v470 in _pairs(v460) do
					if v470 ~= nil and v470.Parent ~= nil then
						v470:Destroy();
					end;
				end;
				v460 = nil;
			end);
			return;
		end;
	end, 
	ShakeCamera = function(v471, v472, v473, v474, v475, v476, v477, v478) --[[ Line: 2095 ]] --[[ Name: ShakeCamera ]]
		-- upvalues: v81 (copy), v37 (ref), v79 (copy)
		local l_CameraShakeMultiplier_0 = 1
		if l_CameraShakeMultiplier_0 <= 0 and v478 ~= true then
			return;
		elseif v37 == true and v477 ~= true then
			return;
		else
			if typeof(v471) ~= "number" then
				v471 = 0;
			end;
			if typeof(v472) ~= "number" then
				v472 = 0.4;
			end;
			if typeof(v473) ~= "number" then
				v473 = 15;
			end;
			if typeof(v474) ~= "number" then
				v474 = 0.25;
			end;
			if typeof(v475) ~= "number" then
				v475 = 0.5;
			end;
			if typeof(v476) ~= "number" then
				v476 = 0.25;
			end;
			if v478 ~= true then
				v473 = v473 * l_CameraShakeMultiplier_0;
			end;
			local v480 = vector_create(v474, v475, v476);
			if v79._running == false then
				v79:Start();
			end;
			v79:ShakeOnce(v473, v473, v471, v472, v480, Vector3_zero);
			return;
		end;
	end, 

	EmitParticlesInInstance = function(v481) --[[ Line: 2126 ]] --[[ Name: EmitParticlesInInstance ]]
		if typeof(v481) ~= "Instance" then
			return;
		else
			for _, v483 in _pairs(v481:GetDescendants()) do
				if v483:IsA("ParticleEmitter") then
					local l_v483_Attribute_0 = v483:GetAttribute("EmitDelay");
					if typeof(l_v483_Attribute_0) ~= "number" or l_v483_Attribute_0 <= 0 then
						v483:Emit(v483:GetAttribute("EmitCount") or _tonumber(v483.Name) or 1);
						local v485 = _tonumber(v483:GetAttribute("EmitDuration"));
						if typeof(v485) == "number" and v485 > 0 then
							v483.Enabled = true;
							task_delay(v485, function() --[[ Line: 2138 ]]
								-- upvalues: v483 (copy)
								if v483 ~= nil and v483.Parent ~= nil then
									v483.Enabled = false;
								end;
							end);
						end;
					else
						task_delay(l_v483_Attribute_0, function() --[[ Line: 2145 ]]
							-- upvalues: v483 (copy)
							if v483 ~= nil and v483.Parent ~= nil then
								v483:Emit(v483:GetAttribute("EmitCount") or _tonumber(v483.Name) or 1);
								local v486 = _tonumber(v483:GetAttribute("EmitDuration"));
								if typeof(v486) == "number" and v486 > 0 then
									v483.Enabled = true;
									task_delay(v486, function() --[[ Line: 2151 ]]
										-- upvalues: v483 (ref)
										if v483 ~= nil and v483.Parent ~= nil then
											v483.Enabled = false;
										end;
									end);
								end;
							end;
						end);
					end;
				elseif v483:IsA("Beam") then
					local l_v483_Attribute_1 = v483:GetAttribute("EmitDuration");
					if typeof(l_v483_Attribute_1) == "number" and l_v483_Attribute_1 > 0 then
						local l_v483_Attribute_2 = v483:GetAttribute("EmitDelay");
						if typeof(l_v483_Attribute_2) == "number" and l_v483_Attribute_2 > 0 then
							task_delay(l_v483_Attribute_2, function() --[[ Line: 2165 ]]
								-- upvalues: v483 (copy), l_v483_Attribute_1 (copy)
								if v483 ~= nil and v483.Parent ~= nil then
									v483.Enabled = true;
									task_delay(l_v483_Attribute_1, function() --[[ Line: 2168 ]]
										-- upvalues: v483 (ref)
										if v483 ~= nil and v483.Parent ~= nil then
											v483.Enabled = false;
										end;
									end);
								end;
							end);
						else
							v483.Enabled = true;
							task_delay(l_v483_Attribute_1, function() --[[ Line: 2177 ]]
								-- upvalues: v483 (copy)
								if v483 ~= nil and v483.Parent ~= nil then
									v483.Enabled = false;
								end;
							end);
						end;
					end;
				end;
			end;
			return;
		end;
	end, 
	DestroyParticleContainer = function(v489, v490) --[[ Line: 2188 ]] --[[ Name: DestroyParticleContainer ]]
		if typeof(v489) ~= "Instance" or v489 == nil or v489.Parent == nil then
			return;
		else
			if typeof(v490) ~= "number" then
				v490 = 4.5;
			end;
			task_delay(v490, function() --[[ Line: 2193 ]]
				-- upvalues: v489 (copy)
				if v489 ~= nil and v489.Parent ~= nil then
					v489:Destroy();
				end;
			end);
			return;
		end;
	end, 
	CreateProjectile = function(v774, v775, v776, v777) --[[ Line: 3519 ]] --[[ Name: CreateProjectile ]]
		-- upvalues: v34 (copy)
		if typeof(v774) == "number" then
			v774 = tostring(v774);
		end;
		if typeof(v774) ~= "string" then
			return;
		else
			if typeof(v776) ~= "table" then
				v776 = {};
			end;
			if typeof(v777) ~= "function" then
				return;
			else
				v34[v774] = {
					v777, 
				};
				if typeof(v775) == "number" then
					task_delay(v775, function() --[[ Line: 3526 ]]
						-- upvalues: v34 (ref), v774 (ref)
						if typeof(v34[v774]) == "table" then
							v34[v774] = nil;
						end;
					end);
				end;
				return;
			end;
		end;
	end, 
	GetProjectileInfo = function(v778) --[[ Line: 3534 ]] --[[ Name: GetProjectileInfo ]]
		-- upvalues: v34 (copy)
		if typeof(v778) == "number" then
			v778 = tostring(v778);
		end;
		if typeof(v778) ~= "string" then
			return;
		elseif typeof(v34[v778]) == "table" and typeof(v34[v778][2]) == "table" then
			return v34[v778][2];
		else
			return {};
		end;
	end, 
	DestroyProjectile = function(v779) --[[ Line: 3543 ]] --[[ Name: DestroyProjectile ]]
		-- upvalues: v34 (copy)
		if typeof(v779) == "number" then
			v779 = tostring(v779);
		end;
		if typeof(v779) ~= "string" then
			return;
		else
			if typeof(v34[v779]) == "table" and typeof(v34[v779][1]) == "function" then
				v34[v779][1]();
				v34[v779] = nil;
			end;
			return;
		end;
	end,
	FindGroundPosition = function(v491, v492, v493) --[[ Line: 2201 ]] --[[ Name: FindGroundPosition ]]
		-- upvalues: v66 (copy)
		if typeof(v491) ~= "Vector3" then
			return;
		else
			if typeof(v492) ~= "number" then
				v492 = 7.5;
			end;
			if typeof(v493) ~= "RaycastParams" then
				v493 = v66;
			end;
			if v492 < 0 then
				v492 = math_abs(v492);
			end;
			return (_workspace:Raycast(v491, vector_create(0, -v492, 0), v493));
		end;
	end, 
	CheckBloodParticles = function(v494) --[[ Line: 2215 ]] --[[ Name: CheckBloodParticles ]]
		-- upvalues: v81 (copy)
		if typeof(v494) ~= "Instance" then
			return;
		else
			--if v81.Blood == false then
			--	for _, v496 in _pairs(v494:GetDescendants()) do
			--		if v496:IsA("ParticleEmitter") and v496.Name == "Blood" then
			--			v496:Destroy();
			--		end;
			--	end;
			--end;
			return;
		end;
	end, 
	GetRandomAngle = function(v497, v498) --[[ Line: 2229 ]] --[[ Name: GetRandomAngle ]]
		if typeof(v497) ~= "number" then
			v497 = 0;
		end;
		if typeof(v498) ~= "number" then
			v498 = math_pi * 2;
		end;
		if v498 <= v497 then
			return;
		else
			return Random_new:NextNumber(v497, v498);
		end;
	end, 
	InitiateCutscene = function(v499, v500, v501, v502, v503, v504, v505, v506, v507, v508) --[[ Line: 2239 ]] --[[ Name: InitiateCutscene ]]
		-- upvalues: l_Cutscenes_0 (copy), v19 (ref), l_CurrentCamera_1 (copy), l_VFX_0 (copy), l_RunService_0 (copy), l_TweenService_0 (copy), l_Enum_CameraType_Custom_0 (ref), v37 (ref), v36 (ref), v81 (copy), v35 (copy)
		if typeof(v499) ~= "string" then
			return;
		else
			if typeof(v500) ~= "number" then
				v500 = 60;
			end;
			if typeof(v502) ~= "Instance" or v502 == nil or v502.Parent == nil then
				return;
			elseif not v502:IsA("BasePart") then
				return;
			else
				if typeof(v503) ~= "CFrame" then
					v503 = CFrame_new();
				end;
				if typeof(v504) ~= "table" then
					v504 = {
						Time = 0.8, 
						EasingStyle = Enum_EasingStyle_Exponential, 
						EasingDirection = Enum_EasingDirection_Out
					};
				end;
				if typeof(v505) ~= "table" then
					v505 = {
						Time = 0.6, 
						EasingStyle = Enum_EasingStyle_Exponential, 
						EasingDirection = Enum_EasingDirection_Out
					};
				end;
				if typeof(v504.Time) ~= "number" then
					v504.Time = 1.2;
				end;
				if typeof(v504.EasingStyle) ~= "EnumItem" then
					v504.EasingStyle = Enum_EasingStyle_Exponential;
				end;
				if typeof(v504.EasingDirection) ~= "EnumItem" then
					v504.EasingDirection = Enum_EasingDirection_Out;
				end;
				if typeof(v505.Time) ~= "number" then
					v505.Time = 1;
				end;
				if typeof(v505.EasingStyle) ~= "EnumItem" then
					v505.EasingStyle = Enum_EasingStyle_Sine;
				end;
				if typeof(v505.EasingDirection) ~= "EnumItem" then
					v505.EasingDirection = Enum_EasingDirection_Out;
				end;
				if typeof(v506) ~= "number" then
					v506 = -1;
				end;
				if typeof(v507) ~= "boolean" then
					v507 = true;
				end;
				if typeof(v508) ~= "boolean" then
					v508 = true;
				end;
				local l_l_Cutscenes_0_FirstChild_0 = l_Cutscenes_0:FindFirstChild(v499);
				if l_l_Cutscenes_0_FirstChild_0 == nil or l_l_Cutscenes_0_FirstChild_0.Parent == nil or typeof(l_l_Cutscenes_0_FirstChild_0) ~= "Instance" then
					return;
				else
					local l_FOV_0 = l_l_Cutscenes_0_FirstChild_0:FindFirstChild("FOV");
					if l_FOV_0 == nil or l_FOV_0.Parent == nil or typeof(l_FOV_0) ~= "Instance" then
						return;
					else
						VFXService.DestroyBind(v19, "CutsceneCameraBind", true);
						VFXService.DestroyBind(v19, "CutsceneSmoothOutBind", true);
						local _ = (l_CurrentCamera_1.Focus.Position - l_CurrentCamera_1.CFrame.Position).Magnitude;
						l_CurrentCamera_1.CameraType = Enum_CameraType_Scriptable;
						local l_CFrame_0 = l_CurrentCamera_1.CFrame;
						local l_FieldOfView_0 = l_CurrentCamera_1.FieldOfView;
						local v514 = os_clock();
						local v515 = Instance_new("Model");
						v515.Name = "CameraRig";
						v515.Parent = l_VFX_0;
						local v516 = Instance_new("Part");
						v516.Name = "Camera";
						v516.Transparency = 1;
						v516.CanCollide = false;
						v516.CanTouch = false;
						v516.CastShadow = false;
						v516.CanQuery = false;
						v516.EnableFluidForces = false;
						v516.Anchored = false;
						v516.Size = Vector3_zero;
						v516.Massless = true;
						v516.Material = Enum_Material_SmoothPlastic;
						v516.Parent = v515;
						local v517 = Instance_new("Part");
						v517.Name = "HumanoidRootPart";
						v517.Transparency = 1;
						v517.CanCollide = false;
						v517.CanTouch = false;
						v517.CastShadow = false;
						v517.CanQuery = false;
						v517.EnableFluidForces = false;
						v517.Anchored = false;
						v517.Size = Vector3_zero;
						v517.Massless = true;
						v517.Material = Enum_Material_SmoothPlastic;
						local v518 = Instance_new("WeldConstraint");
						v518.Parent = v517;
						v518.Part0 = v502;
						v517.Parent = v515;
						v517.CFrame = v502.CFrame * v503;
						v518.Part1 = v517;
						local v519 = Instance_new("Motor6D");
						v519.Parent = v517;
						v519.Part0 = v517;
						v519.Part1 = v516;
						if typeof(v501) == "number" then
							local v520 = Instance_new("Humanoid");
							v520.Parent = v515;
							local v521 = Instance_new("Animator");
							v521.Parent = v520;
							local v522 = Instance_new("Animation");
							v522.AnimationId = "rbxassetid://" .. _tostring(v501);
							local v523 = v521:LoadAnimation(v522);
							v522:Destroy();
							v523.Priority = Enum_AnimationPriority_Action4;
							local v524 = nil;
							local v535 = VFXService.CreateBind(v19, "CutsceneCameraBind", function() --[[ Line: 2345 ]]
								-- upvalues: l_RunService_0 (ref), v514 (copy), v515 (copy), v505 (ref), v524 (ref), l_CurrentCamera_1 (ref), l_TweenService_0 (ref), v19 (ref), l_Enum_CameraType_Custom_0 (ref), v507 (ref), v37 (ref), v508 (ref), v36 (ref), v81 (ref), v35 (ref)
								l_RunService_0:UnbindFromRenderStep("CutsceneCamera" .. v514);
								if v515 ~= nil and v515.Parent ~= nil then
									v515:Destroy();
								end;
								if v505.Time > 0 then
									v524 = l_CurrentCamera_1.CFrame;
									local v525 = os_clock();
									l_RunService_0:BindToRenderStep("CutsceneCameraSmoothOut" .. v525, Enum_RenderPriority_Camera_Value, function() --[[ Line: 2359 ]]
										-- upvalues: l_CurrentCamera_1 (ref), v525 (copy), v505 (ref), v524 (ref), l_TweenService_0 (ref)
										local l_CFrame_1 = l_CurrentCamera_1.CFrame;
										local v527 = (os_clock() - v525) / v505.Time;
										l_CurrentCamera_1.CFrame = v524:Lerp(l_CFrame_1, l_TweenService_0:GetValue(v527, v505.EasingStyle, v505.EasingDirection));
									end);
									local v528 = nil;
									if l_CurrentCamera_1.FieldOfView ~= 70 then
										v528 = l_TweenService_0:Create(l_CurrentCamera_1, TweenInfo_new(v505.Time, v505.EasingStyle, v505.EasingDirection), {
											FieldOfView = 70
										});
										v528:Play();
									end;
									do
										local l_v528_0 = v528;
										local v530 = VFXService.CreateBind(v19, "CutsceneSmoothOutBind", function() --[[ Line: 2371 ]]
											-- upvalues: l_RunService_0 (ref), v525 (copy), l_v528_0 (ref)
											l_RunService_0:UnbindFromRenderStep("CutsceneCameraSmoothOut" .. v525);
											if l_v528_0 ~= nil then
												l_v528_0:Cancel();
											end;
										end);
										l_CurrentCamera_1.CameraType = l_Enum_CameraType_Custom_0;
										task_delay(v505.Time, function() --[[ Line: 2380 ]]
											-- upvalues: v530 (copy)
											if v530 ~= nil and v530.Parent ~= nil then
												v530:Destroy();
											end;
										end);
									end;
								else
									v524 = l_CurrentCamera_1.CFrame;
									l_CurrentCamera_1.CameraType = l_Enum_CameraType_Custom_0;
									l_CurrentCamera_1.FieldOfView = 70;
								end;
								if v507 == true then
									v37 = false;
								end;
								if v508 == true then
									v36 = false;

									for _, v534 in _pairs(v35) do
										if v534 ~= nil and v534.Parent ~= nil then
											v534.Volume = (v534:GetAttribute("DefaultVolume") or 0.5) * 1
										end

									end;
								end;
							end);
							if v507 == true then
								v37 = true;
							end;
							if v508 == true then
								v36 = true;
								for _, v537 in _pairs(v35) do
									if v537 ~= nil and v537.Parent ~= nil then
										v537.Volume = 0;
									end;
								end;
							end;
							v523:Play(v506);
							local v538 = 0;
							if v504.Time > 0 then
								local v539 = Instance_new("Part");
								v539.Name = "Follow";
								v539.Transparency = 1;
								v539.CanCollide = false;
								v539.CanTouch = false;
								v539.CastShadow = false;
								v539.CanQuery = false;
								v539.EnableFluidForces = false;
								v539.Anchored = true;
								v539.Size = Vector3_zero;
								v539.Massless = true;
								v539.Material = Enum_Material_SmoothPlastic;
								v539.Parent = v515;
								v539.CFrame = l_CFrame_0;
								l_RunService_0:BindToRenderStep("CutsceneCamera" .. v514, Enum_RenderPriority_Camera_Value, function(v540) --[[ Line: 2447 ]]
									-- upvalues: v538 (ref), v502 (copy), v535 (copy), v516 (copy), v539 (copy), l_TweenService_0 (ref), v504 (ref), l_CFrame_0 (copy), l_CurrentCamera_1 (ref), v500 (ref), l_FOV_0 (copy), l_FieldOfView_0 (copy), l_RunService_0 (ref), v514 (copy)
									v538 = v538 + v540;
									if v502 ~= nil and v502.Parent ~= nil and v502.Parent.Parent ~= nil and v535 ~= nil and v535.Parent ~= nil and v516 ~= nil and v516.Parent ~= nil and v539 ~= nil and v539.Parent ~= nil then
										local l_CFrame_2 = v516.CFrame;
										local l_l_TweenService_0_Value_0 = l_TweenService_0:GetValue(v538 / v504.Time, v504.EasingStyle, v504.EasingDirection);
										v539.CFrame = l_CFrame_0:Lerp(l_CFrame_2, l_l_TweenService_0_Value_0);
										l_CurrentCamera_1.CFrame = v539.CFrame;
										local v543 = v538 * v500;
										local v544 = math_floor(v543);
										local v545 = math_round(v538 * v500);
										local v546 = _tostring(v545);
										local v547 = _tostring(v545 + 1);
										if l_FOV_0:FindFirstChild(v546) then
											if l_FOV_0:FindFirstChild(v547) then
												local l_Value_0 = l_FOV_0[v546].Value;
												local l_Value_1 = l_FOV_0[v547].Value;
												local v550 = math_max(l_Value_1, l_Value_0);
												local v551 = (v543 - v544) * (l_Value_0 - v550) + v550;
												if v551 < l_FieldOfView_0 then
													l_CurrentCamera_1.FieldOfView = l_l_TweenService_0_Value_0 * (v551 - l_FieldOfView_0) + l_FieldOfView_0;
												else
													l_CurrentCamera_1.FieldOfView = l_FieldOfView_0 + l_l_TweenService_0_Value_0 * (v551 - l_FieldOfView_0);
												end;
											else
												l_CurrentCamera_1.FieldOfView = l_FOV_0[v546].Value;
											end;
										else
											local l_Value_2 = l_FOV_0["0"].Value;
											local v553 = math_min(l_Value_2, l_FieldOfView_0);
											local v554 = math_max(l_Value_2, l_FieldOfView_0);
											l_CurrentCamera_1.FieldOfView = l_l_TweenService_0_Value_0 * (v553 - v554) + v554;
										end;
										if l_l_TweenService_0_Value_0 >= 1 then
											l_RunService_0:UnbindFromRenderStep("CutsceneCamera" .. v514);
											l_RunService_0:BindToRenderStep("CutsceneCamera" .. v514, Enum_RenderPriority_Camera_Value, function(v555) --[[ Line: 2481 ]]
												-- upvalues: v538 (ref), v502 (ref), v535 (ref), v516 (ref), l_CurrentCamera_1 (ref), v500 (ref), l_FOV_0 (ref)
												v538 = v538 + v555;
												if v502 ~= nil and v502.Parent ~= nil and v502.Parent.Parent ~= nil and v535 ~= nil and v535.Parent ~= nil and v516 ~= nil and v516.Parent ~= nil then
													l_CurrentCamera_1.CFrame = v516.CFrame;
													local v556 = _tostring(math_round(v538 * v500));
													if l_FOV_0:FindFirstChild(v556) then
														l_CurrentCamera_1.FieldOfView = l_FOV_0[v556].Value;
														return;
													end;
												else
													VFXService.EndCutscene();
												end;
											end);
											return;
										end;
									else
										VFXService.EndCutscene();
									end;
								end);
							else
								l_RunService_0:BindToRenderStep("CutsceneCamera" .. v514, Enum_RenderPriority_Camera_Value, function(v557) --[[ Line: 2502 ]]
									-- upvalues: v538 (ref), v502 (copy), v535 (copy), v516 (copy), l_CurrentCamera_1 (ref), v500 (ref), l_FOV_0 (copy)
									v538 = v538 + v557;
									if v502 ~= nil and v502.Parent ~= nil and v502.Parent.Parent ~= nil and v535 ~= nil and v535.Parent ~= nil and v516 ~= nil and v516.Parent ~= nil then
										l_CurrentCamera_1.CFrame = v516.CFrame;
										local v558 = _tostring(math_round(v538 * v500));
										if l_FOV_0:FindFirstChild(v558) then
											l_CurrentCamera_1.FieldOfView = l_FOV_0[v558].Value;
											return;
										end;
									else
										VFXService.EndCutscene();
									end;
								end);
							end;
							v523.Stopped:Connect(function() --[[ Line: 2517 ]]
								-- upvalues: v535 (copy)
								if v535 ~= nil and v535.Parent ~= nil then
									v535:Destroy();
								end;
							end);
							return v515, v523;
						else
							local l_Frames_0 = l_l_Cutscenes_0_FirstChild_0:FindFirstChild("Frames");
							local v560 = nil;
							local v571 = VFXService.CreateBind(v19, "CutsceneCameraBind", function() --[[ Line: 2530 ]]
								-- upvalues: l_RunService_0 (ref), v514 (copy), v515 (copy), v505 (ref), v560 (ref), l_CurrentCamera_1 (ref), l_TweenService_0 (ref), v19 (ref), l_Enum_CameraType_Custom_0 (ref), v507 (ref), v37 (ref), v508 (ref), v36 (ref), v81 (ref), v35 (ref)
								l_RunService_0:UnbindFromRenderStep("CutsceneCamera" .. v514);
								if v515 ~= nil and v515.Parent ~= nil then
									v515:Destroy();
								end;
								if v505.Time > 0 then
									v560 = l_CurrentCamera_1.CFrame;
									local v561 = os_clock();
									l_RunService_0:BindToRenderStep("CutsceneCameraSmoothOut" .. v561, Enum_RenderPriority_Camera_Value, function() --[[ Line: 2544 ]]
										-- upvalues: l_CurrentCamera_1 (ref), v561 (copy), v505 (ref), v560 (ref), l_TweenService_0 (ref)
										local l_CFrame_3 = l_CurrentCamera_1.CFrame;
										local v563 = (os_clock() - v561) / v505.Time;
										l_CurrentCamera_1.CFrame = v560:Lerp(l_CFrame_3, l_TweenService_0:GetValue(v563, v505.EasingStyle, v505.EasingDirection));
									end);
									local v564 = nil;
									if l_CurrentCamera_1.FieldOfView ~= 70 then
										v564 = l_TweenService_0:Create(l_CurrentCamera_1, TweenInfo_new(v505.Time, v505.EasingStyle, v505.EasingDirection), {
											FieldOfView = 70
										});
										v564:Play();
									end;
									do
										local l_v564_0 = v564;
										local v566 = VFXService.CreateBind(v19, "CutsceneSmoothOutBind", function() --[[ Line: 2556 ]]
											-- upvalues: l_RunService_0 (ref), v561 (copy), l_v564_0 (ref)
											l_RunService_0:UnbindFromRenderStep("CutsceneCameraSmoothOut" .. v561);
											if l_v564_0 ~= nil then
												l_v564_0:Cancel();
											end;
										end);
										l_CurrentCamera_1.CameraType = l_Enum_CameraType_Custom_0;
										task_delay(v505.Time, function() --[[ Line: 2565 ]]
											-- upvalues: v566 (copy)
											if v566 ~= nil and v566.Parent ~= nil then
												v566:Destroy();
											end;
										end);
									end;
								else
									v560 = l_CurrentCamera_1.CFrame;
									l_CurrentCamera_1.CameraType = l_Enum_CameraType_Custom_0;
									l_CurrentCamera_1.FieldOfView = 70;
								end;
								if v507 == true then
									v37 = false;
								end;
								if v508 == true then
									v36 = false;
									if v36 ~= true then
										for _, v570 in _pairs(v35) do
											if v570 ~= nil and v570.Parent ~= nil then
												v570.Volume = (v570:GetAttribute("DefaultVolume") or 0.5) * 1
											end;
										end;
									end;
								end;
							end);
							if v507 == true then
								v37 = true;
							end;
							if v508 == true then
								v36 = true;
								for _, v573 in _pairs(v35) do
									if v573 ~= nil and v573.Parent ~= nil then
										v573.Volume = 0;
									end;
								end;
							end;
							local v574 = 0;
							v515:SetAttribute("Frame", 0);
							if v504.Time > 0 then
								local v575 = Instance_new("Part");
								v575.Name = "Follow";
								v575.Transparency = 1;
								v575.CanCollide = false;
								v575.CanTouch = false;
								v575.CastShadow = false;
								v575.CanQuery = false;
								v575.EnableFluidForces = false;
								v575.Anchored = true;
								v575.Size = Vector3_zero;
								v575.Massless = true;
								v575.Material = Enum_Material_SmoothPlastic;
								v575.Parent = v515;
								v575.CFrame = l_CFrame_0;
								l_RunService_0:BindToRenderStep("CutsceneCamera" .. v514, Enum_RenderPriority_Camera_Value, function(v576) --[[ Line: 2634 ]]
									-- upvalues: v574 (ref), v502 (copy), v571 (copy), v516 (copy), v575 (copy), v519 (copy), v500 (ref), l_TweenService_0 (ref), v504 (ref), l_Frames_0 (copy), l_CurrentCamera_1 (ref), l_CFrame_0 (copy), l_FOV_0 (copy), l_FieldOfView_0 (copy), v515 (copy), l_RunService_0 (ref), v514 (copy)
									v574 = v574 + v576;
									if v502 ~= nil and v502.Parent ~= nil and v502.Parent.Parent ~= nil and v571 ~= nil and v571.Parent ~= nil and v516 ~= nil and v516.Parent ~= nil and v575 ~= nil and v575.Parent ~= nil and v519 ~= nil and v519.Parent ~= nil then
										local v577 = v574 * v500;
										local v578 = math_floor(v577);
										local v579 = math_round(v574 * v500);
										local v580 = _tostring(v579);
										local l_l_TweenService_0_Value_1 = l_TweenService_0:GetValue(v574 / v504.Time, v504.EasingStyle, v504.EasingDirection);
										if l_Frames_0:FindFirstChild(v580) then
											v519.C0 = l_Frames_0[v580].Value;
										end;
										local l_CFrame_4 = v516.CFrame;
										l_CurrentCamera_1.CFrame = l_CFrame_0:Lerp(l_CFrame_4, l_l_TweenService_0_Value_1);
										local v583 = _tostring(v579 + 1);
										if l_FOV_0:FindFirstChild(v580) then
											if l_FOV_0:FindFirstChild(v583) then
												local l_Value_3 = l_FOV_0[v580].Value;
												local l_Value_4 = l_FOV_0[v583].Value;
												local v586 = math_max(l_Value_4, l_Value_3);
												local v587 = (v577 - v578) * (l_Value_3 - v586) + v586;
												if v587 < l_FieldOfView_0 then
													l_CurrentCamera_1.FieldOfView = l_l_TweenService_0_Value_1 * (v587 - l_FieldOfView_0) + l_FieldOfView_0;
												else
													l_CurrentCamera_1.FieldOfView = l_FieldOfView_0 + l_l_TweenService_0_Value_1 * (v587 - l_FieldOfView_0);
												end;
											else
												l_CurrentCamera_1.FieldOfView = l_FOV_0[v580].Value;
											end;
										else
											local l_Value_5 = l_FOV_0["0"].Value;
											local v589 = math_min(l_Value_5, l_FieldOfView_0);
											local v590 = math_max(l_Value_5, l_FieldOfView_0);
											l_CurrentCamera_1.FieldOfView = l_l_TweenService_0_Value_1 * (v589 - v590) + v590;
										end;
										v515:SetAttribute("Frame", v579);
										if l_l_TweenService_0_Value_1 >= 1 then
											l_RunService_0:UnbindFromRenderStep("CutsceneCamera" .. v514);
											l_RunService_0:BindToRenderStep("CutsceneCamera" .. v514, Enum_RenderPriority_Camera_Value, function(v591) --[[ Line: 2671 ]]
												-- upvalues: v574 (ref), v502 (ref), v571 (ref), v516 (ref), v500 (ref), l_Frames_0 (ref), v519 (ref), l_CurrentCamera_1 (ref), l_FOV_0 (ref), v515 (ref)
												v574 = v574 + v591;
												if v502 ~= nil and v502.Parent ~= nil and v502.Parent.Parent ~= nil and v571 ~= nil and v571.Parent ~= nil and v516 ~= nil and v516.Parent ~= nil then
													local v592 = math_round(v574 * v500);
													local v593 = _tostring(v592);
													if l_Frames_0:FindFirstChild(v593) then
														v519.C0 = l_Frames_0[v593].Value;
													end;
													l_CurrentCamera_1.CFrame = v516.CFrame;
													if l_FOV_0:FindFirstChild(v593) then
														l_CurrentCamera_1.FieldOfView = l_FOV_0[v593].Value;
													end;
													v515:SetAttribute("Frame", v592);
													return;
												else
													VFXService.EndCutscene();
													return;
												end;
											end);
											return;
										end;
									else
										VFXService.EndCutscene();
									end;
								end);
							else
								l_RunService_0:BindToRenderStep("CutsceneCamera" .. v514, Enum_RenderPriority_Camera_Value, function(v594) --[[ Line: 2696 ]]
									-- upvalues: v574 (ref), v502 (copy), v571 (copy), v516 (copy), v500 (ref), l_Frames_0 (copy), v519 (copy), l_CurrentCamera_1 (ref), l_FOV_0 (copy), v515 (copy)
									v574 = v574 + v594;
									if v502 ~= nil and v502.Parent ~= nil and v502.Parent.Parent ~= nil and v571 ~= nil and v571.Parent ~= nil and v516 ~= nil and v516.Parent ~= nil then
										local v595 = math_round(v574 * v500);
										local v596 = _tostring(v595);
										if l_Frames_0:FindFirstChild(v596) then
											v519.C0 = l_Frames_0[v596].Value;
										end;
										l_CurrentCamera_1.CFrame = v516.CFrame;
										if l_FOV_0:FindFirstChild(v596) then
											l_CurrentCamera_1.FieldOfView = l_FOV_0[v596].Value;
										end;
										v515:SetAttribute("Frame", v595);
										return;
									else
										VFXService.EndCutscene();
										return;
									end;
								end);
							end;
							return v515;
						end;
					end;
				end;
			end;
		end;
	end, 
	EndCutscene = function() --[[ Line: 2722 ]] --[[ Name: EndCutscene ]]
		-- upvalues: v19 (ref)
		VFXService.DestroyBind(v19, "CutsceneCameraBind", true);
	end, 
	GetTile = function(v597, v598) --[[ Line: 2726 ]] --[[ Name: GetTile ]]
		-- upvalues: v68 (copy)
		if typeof(v597) ~= "Vector3" then
			return;
		else
			if typeof(v598) ~= "number" then
				v598 = 7;
			end;
			local v599 = _workspace:Raycast(v597, vector_create(0, -math_abs(v598), 0), v68);
			if v599 and v599.Instance and v599.Instance:GetAttribute("Destroyed") ~= true then
				return v599.Instance;
			else
				return;
			end;
		end;
	end, 
	DestroyTile = function(v600, v601, v602, v603, v604, v605) --[[ Line: 2739 ]] --[[ Name: DestroyTile ]]
		-- upvalues: v99 (copy), l_FlyingRocksStorage_0 (copy), l_TweenService_0 (copy)
		if typeof(v600) ~= "Instance" or v600 == nil or v600.Parent == nil then
			return;
		elseif v600:GetAttribute("Destroyed") == true then
			return;
		else
			if typeof(v601) ~= "table" then
				v601 = {
					20, 
					30
				};
			end;
			if typeof(v602) ~= "table" then
				v602 = {
					60, 
					70
				};
			end;
			if typeof(v605) ~= "boolean" then
				v605 = true;
			end;
			if typeof(v603) ~= "table" then
				v603 = {
					4, 
					5
				};
			end;
			if typeof(v604) ~= "number" then
				v604 = Random_new:NextNumber(9, 13);
			end;
			v600:SetAttribute("Destroyed", true);
			if v605 == true then
				v99.PlaySoundAtCFrame(v600.CFrame, "TileBreakConcrete");
			end;
			local v606 = math_random(1, 2);
			local v607 = v600.Size.X / 2;
			local v608 = v600.Size.Z / 2;
			local v609 = Random_new:NextNumber(v603[1], v603[2]);
			local v610 = Random_new:NextNumber(v603[1], v603[2]);
			local v611 = Instance_new("Folder");
			v611.Name = "FlyingRocks";
			local v612 = v600:Clone();
			v612:SetAttribute("Destroyed", nil);
			v612.Anchored = false;
			v612.CastShadow = true;
			v612.Color = VFXService.MakeDarker(v600.Color, 5, 5, 5);
			v612.CollisionGroup = "Only Floor";
			if v606 == 1 then
				v612.Size = vector_create(v607, v600.Size.Y + 0.075, v612.Size.Z);
			elseif v606 == 2 then
				v612.Size = vector_create(v612.Size.X, 0, v608);
			end;
			local v613 = v612:Clone();
			if v606 == 1 then
				v612.Position = v612.Position - vector_create(v607 / 2, 0, 0);
				v613.Position = v613.Position + vector_create(v607 / 2, 0, 0);
			elseif v606 == 2 then
				v612.Position = v612.Position - vector_create(0, 0, v608 / 2);
				v613.Position = v613.Position + vector_create(0, 0, v608 / 2);
			end;
			local v614 = CFrame_new(v600.Position, v612.Position).LookVector * Random_new:NextNumber(v601[1], v601[2]) + vector_create(0, Random_new:NextNumber(v602[1], v602[2]), 0);
			local v615 = CFrame_new(v600.Position, v613.Position).LookVector * Random_new:NextNumber(v601[1], v601[2]) + vector_create(0, Random_new:NextNumber(v602[1], v602[2]), 0);
			local v616 = vector_create(math_random(2, 3), math_random(2, 3), math_random(2, 3));
			local v617 = vector_create(math_random(2, 3), math_random(2, 3), math_random(2, 3));
			v600.Position = v600.Position - vector_create(0, 10, 0);
			v612.Parent = v611;
			v613.Parent = v611;
			v611.Parent = l_FlyingRocksStorage_0;
			v612.AssemblyLinearVelocity = v614;
			v613.AssemblyLinearVelocity = v615;
			v612.AssemblyAngularVelocity = v616;
			v613.AssemblyAngularVelocity = v617;
			local v618 = l_TweenService_0:Create(v600, TweenInfo_new(1.5, Enum_EasingStyle_Sine, Enum_EasingDirection_Out), {
				Transparency = 0
			});
			local v619 = l_TweenService_0:Create(v612, TweenInfo_new(1.5, Enum_EasingStyle_Sine, Enum_EasingDirection_Out), {
				Transparency = 1
			});
			local v620 = l_TweenService_0:Create(v613, TweenInfo_new(1.5, Enum_EasingStyle_Sine, Enum_EasingDirection_Out), {
				Transparency = 1
			});
			v619.Completed:Connect(function() --[[ Line: 2813 ]]
				-- upvalues: v612 (ref), v611 (copy), v613 (ref)
				if v612 ~= nil and v612.Parent ~= nil then
					v612:Destroy();
					v612 = nil;
				end;
				if v611 ~= nil and v611.Parent ~= nil and (v613 == nil or v613.Parent == nil) then
					v611:Destroy();
				end;
			end);
			v620.Completed:Connect(function() --[[ Line: 2823 ]]
				-- upvalues: v613 (ref), v611 (copy), v612 (ref)
				if v613 ~= nil and v613.Parent ~= nil then
					v613:Destroy();
					v613 = nil;
				end;
				if v611 ~= nil and v611.Parent ~= nil and (v612 == nil or v612.Parent == nil) then
					v611:Destroy();
				end;
			end);
			v618.Completed:Connect(function() --[[ Line: 2833 ]]
				-- upvalues: v600 (copy)
				if v600 ~= nil and v600.Parent ~= nil then
					v600.CanCollide = true;
					v600:SetAttribute("Destroyed", nil);
				end;
			end);
			task_delay(v609, function() --[[ Line: 2840 ]]
				-- upvalues: v612 (ref), v619 (copy)
				if v612 ~= nil and v612.Parent ~= nil then
					v619:Play();
				end;
			end);
			task_delay(v610, function() --[[ Line: 2846 ]]
				-- upvalues: v613 (ref), v620 (copy)
				if v613 ~= nil and v613.Parent ~= nil then
					v620:Play();
				end;
			end);
			task_delay(v604, function() --[[ Line: 2852 ]]
				-- upvalues: v600 (copy), v618 (copy)
				if v600 ~= nil and v600.Parent ~= nil then
					v600.Name = "TEMPORARY NAME";
					v600.Transparency = 1;
					v600.CanCollide = false;
					local l_v600_0 = v600;
					l_v600_0.Position = l_v600_0.Position + vector_create(0, 10, 0);
					v618:Play();
				end;
			end);
			return;
		end;
	end, 
	LoadMeshPartAnimation = function(v622, v623) --[[ Line: 2866 ]] --[[ Name: LoadMeshPartAnimation ]]
		-- upvalues: l_TweenService_0 (copy)
		if v622 == nil or typeof(v622) ~= "Instance" or v622.Parent == nil then
			return;
		elseif typeof(v623) ~= "table" then
			return;
		else
			local v624 = {};
			if typeof(v623.Size) == "table" then
				local v625 = v623.Size.X or v622.Size.X;
				local v626 = v623.Size.Y or v622.Size.Y;
				local v627 = v623.Size.Z or v622.Size.Z;
				local v628 = v623.Size.Time or 0.5;
				local v629 = v623.Size.EasingStyle or Enum_EasingStyle_Sine;
				local v630 = v623.Size.EasingDirection or Enum_EasingDirection_Out;
				local v631 = TweenInfo_new(v628, v629, v630);
				local v632 = l_TweenService_0:Create(v622, v631, {
					Size = vector_create(v625, v626, v627)
				});
				table_insert(v624, v632);
			end;
			if typeof(v623.Transparency) == "table" then
				local v633 = v623.Transparency.Value or 1;
				local v634 = v623.Transparency.Time or 1;
				local v635 = v623.Transparency.EasingStyle or Enum_EasingStyle_Sine;
				local v636 = v623.Transparency.EasingDirection or Enum_EasingDirection_Out;
				local v637 = TweenInfo_new(v634, v635, v636);
				local v638 = l_TweenService_0:Create(v622, v637, {
					Transparency = v633
				});
				table_insert(v624, v638);
			end;
			local l_CFrame_5 = v622.CFrame;
			local v640 = nil;
			local v641 = nil;
			if typeof(v623.LinearDisplacement) == "table" then
				local v642 = v623.LinearDisplacement.X or 0;
				local v643 = v623.LinearDisplacement.Y or 0;
				local v644 = v623.LinearDisplacement.Z or 0;
				local v645 = v623.LinearDisplacement.Time or 1;
				local v646 = v623.LinearDisplacement.EasingStyle or Enum_EasingStyle_Sine;
				local v647 = v623.LinearDisplacement.EasingDirection or Enum_EasingDirection_Out;
				local v648 = TweenInfo_new(v645, v646, v647);
				v641 = l_CFrame_5 + l_CFrame_5.LookVector * v642 + l_CFrame_5.UpVector * v643 + l_CFrame_5.RightVector * v644;
				v640 = l_TweenService_0:Create(v622, v648, {
					CFrame = v641
				});
				table_insert(v624, v640);
			end;
			if typeof(v623.AngularDisplacement) == "table" then
				local v649 = v623.AngularDisplacement.X or 0;
				local v650 = v623.AngularDisplacement.Y or 0;
				local v651 = v623.AngularDisplacement.Z or 0;
				local v652 = v623.AngularDisplacement.Time or 1;
				local v653 = v623.AngularDisplacement.EasingStyle or Enum_EasingStyle_Sine;
				local v654 = v623.AngularDisplacement.EasingDirection or Enum_EasingDirection_Out;
				local v655 = TweenInfo_new(v652, v653, v654);
				local v656 = nil;
				if v641 ~= nil then
					v656 = v641;
					table_remove(v624, table_find(v624, v640));
					v640 = nil;
				else
					v656 = v622.CFrame;
				end;
				local v657 = l_TweenService_0:Create(v622, v655, {
					CFrame = v656 * CFrame_Angles(v649, v650, v651)
				});
				table_insert(v624, v657);
			end;
			return v624;
		end;
	end, 
	ScreenFlash = function(v658, v659, v660, v661, v662, v663) --[[ Line: 2966 ]] --[[ Name: ScreenFlash ]]
		-- upvalues: l_TweenService_0 (copy), l_PlayerGui_0 (copy)
		if typeof(v658) ~= "Color3" then
			v658 = Color3_new(255, 255, 255);
		end;
		if typeof(v659) ~= "number" then
			v659 = 0;
		end;
		if typeof(v660) ~= "number" then
			v660 = 1;
		end;
		if typeof(v661) ~= "number" then
			v661 = 0.35;
		end;
		if typeof(v662) ~= "EnumItem" then
			v662 = Enum_EasingStyle_Exponential;
		end;
		if typeof(v663) ~= "EnumItem" then
			v663 = Enum_EasingDirection_Out;
		end;
		local v664 = Instance_new("ScreenGui");
		v664.IgnoreGuiInset = true;
		v664.Name = "ScreenFlashEffect";
		local v665 = Instance_new("Frame");
		v665.Size = UDim2_new(1.5, 0, 1.5, 0);
		v665.BackgroundColor3 = v658;
		v665.BackgroundTransparency = v659;
		v665.Name = "Flash";
		v665.Parent = v664;
		local v666 = l_TweenService_0:Create(v665, TweenInfo_new(v661, v662, v663), {
			BackgroundTransparency = v660
		});
		v666.Completed:Once(function() --[[ Line: 2988 ]]
			-- upvalues: v664 (copy)
			if v664 ~= nil and v664.Parent ~= nil then
				v664:Destroy();
			end;
		end);
		v664.Parent = l_PlayerGui_0;
		v666:Play();
	end, 
	EndScreenFlashes = function() --[[ Line: 3000 ]] --[[ Name: EndScreenFlashes ]]
		-- upvalues: l_PlayerGui_0 (copy)
		for _, v668 in _pairs(l_PlayerGui_0:GetChildren()) do
			if v668:IsA("ScreenGUI") and v668.Name == "ScreenFlashEffect" then
				v668:Destroy();
			end;
		end;
	end, 
	CinematicFrame = function(v669, v670, v671) --[[ Line: 3008 ]] --[[ Name: CinematicFrame ]]
		-- upvalues: l_TweenService_0 (copy), l_PlayerGui_0 (copy)
		if typeof(v669) ~= "table" then
			v669 = {
				Visible = true, 
				ScreenPercentage = 0.09, 
				SmoothIn = {
					Time = 0.3, 
					EasingStyle = Enum_EasingStyle_Sine, 
					EasingDirection = Enum_EasingDirection_Out
				}, 
				SmoothOut = {
					Time = 0.3, 
					EasingStyle = Enum_EasingStyle_Sine, 
					EasingDirection = Enum_EasingDirection_Out
				}
			};
		end;
		if typeof(v670) ~= "table" then
			v670 = {
				Visible = true, 
				InitialTransparency = 1, 
				TargetTransparency = 0, 
				SmoothIn = {
					Time = 0.3, 
					EasingStyle = Enum_EasingStyle_Sine, 
					EasingDirection = Enum_EasingDirection_Out
				}, 
				SmoothOut = {
					Time = 0.3, 
					EasingStyle = Enum_EasingStyle_Sine, 
					EasingDirection = Enum_EasingDirection_Out
				}
			};
		end;
		if typeof(v671) ~= "number" then
			v671 = 3;
		end;
		local v672 = Instance_new("ScreenGui");
		v672.IgnoreGuiInset = true;
		v672.ResetOnSpawn = false;
		v672.Name = "CinematicFrameEffect";
		local v673 = {};
		local v674 = {};
		local v675 = {};
		local v676 = 0;
		local v677 = 0;
		if v669.Visible == true then
			local v678 = Instance_new("Frame");
			v678.BorderSizePixel = 0;
			v678.BackgroundColor3 = Color3_fromRGB();
			v678.Size = UDim2_new(3, 0, v669.ScreenPercentage, 0);
			v678.Position = UDim2_new(0, 0, -v669.ScreenPercentage);
			local v679 = Instance_new("Frame");
			v679.BorderSizePixel = 0;
			v679.BackgroundColor3 = Color3_fromRGB();
			v679.Size = UDim2_new(3, 0, v669.ScreenPercentage, 0);
			v679.Position = UDim2_new(0, 0, 1, 0);
			local v680 = UDim2_new();
			local v681 = UDim2_new(0, 0, 1 - v669.ScreenPercentage, 0);
			local l_SmoothIn_0 = v669.SmoothIn;
			if typeof(l_SmoothIn_0) ~= "table" then
				l_SmoothIn_0 = {
					Time = 0.3, 
					EasingStyle = Enum_EasingStyle_Sine, 
					EasingDirection = Enum_EasingDirection_Out
				};
			end;
			local l_Time_0 = l_SmoothIn_0.Time;
			local l_EasingStyle_0 = l_SmoothIn_0.EasingStyle;
			local l_EasingDirection_0 = l_SmoothIn_0.EasingDirection;
			if typeof(l_Time_0) ~= "number" then
				l_Time_0 = 0.3;
			end;
			if typeof(l_EasingStyle_0) ~= "EnumItem" then
				l_EasingStyle_0 = Enum_EasingStyle_Sine;
			end;
			if typeof(l_EasingDirection_0) ~= "EnumItem" then
				l_EasingDirection_0 = Enum_EasingDirection_Out;
			end;
			local l_SmoothIn_1 = v669.SmoothIn;
			if typeof(l_SmoothIn_1) ~= "table" then
				l_SmoothIn_1 = {
					Time = 0.3, 
					EasingStyle = Enum_EasingStyle_Sine, 
					EasingDirection = Enum_EasingDirection_Out
				};
			end;
			local l_Time_1 = l_SmoothIn_1.Time;
			local l_EasingStyle_1 = l_SmoothIn_1.EasingStyle;
			local l_EasingDirection_1 = l_SmoothIn_1.EasingDirection;
			if typeof(l_Time_1) ~= "number" then
				l_Time_1 = 0.3;
			end;
			if typeof(l_EasingStyle_1) ~= "EnumItem" then
				l_EasingStyle_1 = Enum_EasingStyle_Sine;
			end;
			if typeof(l_EasingDirection_1) ~= "EnumItem" then
				l_EasingDirection_1 = Enum_EasingDirection_Out;
			end;
			local v690 = TweenInfo_new(l_Time_0, l_EasingStyle_0, l_EasingDirection_0);
			local v691 = TweenInfo_new(l_Time_1, l_EasingStyle_1, l_EasingDirection_1);
			local v692 = l_TweenService_0:Create(v678, v690, {
				Position = v680
			});
			table_insert(v673, v692);
			local v693 = l_TweenService_0:Create(v679, v690, {
				Position = v681
			});
			table_insert(v673, v693);
			local v694 = l_TweenService_0:Create(v678, v691, {
				Position = v678.Position
			});
			table_insert(v674, v694);
			local v695 = l_TweenService_0:Create(v679, v691, {
				Position = v679.Position
			});
			table_insert(v674, v695);
			v678.Parent = v672;
			v679.Parent = v672;
			v692:Play();
			v693:Play();
			local v696 = nil;
			local l_v678_0 = v678 --[[ copy: 9 -> 29 ]];
			local l_v679_0 = v679 --[[ copy: 10 -> 30 ]];
			v696 = task_delay(v671, function() --[[ Line: 3134 ]]
				-- upvalues: l_v678_0 (copy), v694 (copy), l_v679_0 (copy), v695 (copy)
				if l_v678_0 ~= nil and l_v678_0.Parent ~= nil and v694 ~= nil then
					v694:Play();
				end;
				if l_v679_0 ~= nil and l_v679_0.Parent ~= nil and v695 ~= nil then
					v695:Play();
				end;
			end);
			table_insert(v675, v696);
			v676 = l_Time_1;
		end;
		if v670.Visible == true then
			local v699 = Instance_new("ImageLabel");
			v699.BackgroundTransparency = 1;
			v699.Image = "rbxassetid://4576475446";
			v699.Size = UDim2_new(1, 0, 1, 0);
			v699.Position = UDim2_new();
			local l_SmoothIn_2 = v670.SmoothIn;
			if typeof(l_SmoothIn_2) ~= "table" then
				l_SmoothIn_2 = {
					Time = 0.3, 
					EasingStyle = Enum_EasingStyle_Sine, 
					EasingDirection = Enum_EasingDirection_Out
				};
			end;
			local l_Time_2 = l_SmoothIn_2.Time;
			local l_EasingStyle_2 = l_SmoothIn_2.EasingStyle;
			local l_EasingDirection_2 = l_SmoothIn_2.EasingDirection;
			if typeof(l_Time_2) ~= "number" then
				l_Time_2 = 0.3;
			end;
			if typeof(l_EasingStyle_2) ~= "EnumItem" then
				l_EasingStyle_2 = Enum_EasingStyle_Sine;
			end;
			if typeof(l_EasingDirection_2) ~= "EnumItem" then
				l_EasingDirection_2 = Enum_EasingDirection_Out;
			end;
			local l_SmoothIn_3 = v670.SmoothIn;
			if typeof(l_SmoothIn_3) ~= "table" then
				l_SmoothIn_3 = {
					Time = 0.3, 
					EasingStyle = Enum_EasingStyle_Sine, 
					EasingDirection = Enum_EasingDirection_Out
				};
			end;
			local l_Time_3 = l_SmoothIn_3.Time;
			local l_EasingStyle_3 = l_SmoothIn_3.EasingStyle;
			local l_EasingDirection_3 = l_SmoothIn_3.EasingDirection;
			if typeof(l_Time_3) ~= "number" then
				l_Time_3 = 0.3;
			end;
			if typeof(l_EasingStyle_3) ~= "EnumItem" then
				l_EasingStyle_3 = Enum_EasingStyle_Sine;
			end;
			if typeof(l_EasingDirection_3) ~= "EnumItem" then
				l_EasingDirection_3 = Enum_EasingDirection_Out;
			end;
			local v708 = TweenInfo_new(l_Time_2, l_EasingStyle_2, l_EasingDirection_2);
			local v709 = TweenInfo_new(l_Time_3, l_EasingStyle_3, l_EasingDirection_3);
			local l_InitialTransparency_0 = v670.InitialTransparency;
			local l_TargetTransparency_0 = v670.TargetTransparency;
			if typeof(l_InitialTransparency_0) ~= "number" then
				l_InitialTransparency_0 = 1;
			end;
			if typeof(l_TargetTransparency_0) ~= "number" then
				l_TargetTransparency_0 = 0;
			end;
			v699.ImageTransparency = l_InitialTransparency_0;
			local v712 = l_TweenService_0:Create(v699, v708, {
				ImageTransparency = l_TargetTransparency_0
			});
			table_insert(v673, v712);
			local v713 = l_TweenService_0:Create(v699, v709, {
				ImageTransparency = 1
			});
			table_insert(v674, v713);
			v699.Parent = v672;
			v712:Play();
			local v714 = nil;
			local l_v699_0 = v699 --[[ copy: 9 -> 28 ]];
			v714 = task_delay(v671, function() --[[ Line: 3214 ]]
				-- upvalues: l_v699_0 (copy), v713 (copy)
				if l_v699_0 ~= nil and l_v699_0.Parent ~= nil and v713 ~= nil then
					v713:Play();
				end;
			end);
			table_insert(v675, v714);
			v677 = l_Time_3;
		end;
		task_delay(v671 + math_max(v676, v677), function() --[[ Line: 3226 ]]
			-- upvalues: v672 (copy)
			if v672 ~= nil and v672.Parent ~= nil then
				v672:Destroy();
			end;
		end);
		table_insert(v675, nil);
		local v716 = false;
		v672.ChildAdded:Connect(function(v717) --[[ Line: 3234 ]]
			-- upvalues: v716 (ref), v673 (copy), v675 (copy), v674 (copy), v676 (ref), v677 (ref), v672 (copy)
			if v716 == true then
				return;
			else
				if v717.Name == "EndFrame" then
					v716 = true;
					for _, v719 in _pairs(v673) do
						if v719 ~= nil then
							v719:Cancel();
						end;
					end;
					for _, v721 in _pairs(v675) do
						_pcall(function() --[[ Line: 3244 ]]
							-- upvalues: v721 (copy)
							task_cancel(v721);
						end);
					end;
					for _, v723 in _pairs(v674) do
						if v723 ~= nil and v723.PlaybackState == Enum_PlaybackState_Begin then
							v723:Play();
						end;
					end;
					task_delay(math_max(v676, v677), function() --[[ Line: 3255 ]]
						-- upvalues: v672 (ref)
						if v672 ~= nil and v672.Parent ~= nil then
							v672:Destroy();
						end;
					end);
				end;
				return;
			end;
		end);
		v672.Parent = l_PlayerGui_0;
		return v672;
	end, 
	EndCinematicFrame = function(v724) --[[ Line: 3270 ]] --[[ Name: EndCinematicFrame ]]
		-- upvalues: l_PlayerGui_0 (copy)
		if v724 ~= nil and typeof(v724) == "Instance" and v724.Parent ~= nil and v724:IsA("ScreenGui") then
			local v725 = Instance_new("Configuration");
			v725.Name = "EndFrame";
			v725.Parent = v724;
			return;
		else
			for _, v727 in _pairs(l_PlayerGui_0:GetChildren()) do
				if v727:IsA("ScreenGui") and v727.Name == "CinematicFrameEffect" then
					local v728 = Instance_new("Configuration");
					v728.Name = "EndFrame";
					v728.Parent = v727;
				end;
			end;
			return;
		end;
	end, 
	PreloadImages = function(v729, v730) --[[ Line: 3288 ]] --[[ Name: PreloadImages ]]
		-- upvalues: l_PlayerGui_0 (copy)
		if typeof(v729) ~= "table" then
			return;
		else
			if typeof(v730) ~= "number" then
				v730 = 3;
			end;
			local v731 = Instance_new("ScreenGui");
			v731.IgnoreGuiInset = true;
			v731.ResetOnSpawn = false;
			v731.Name = "ImagePreloader";
			for _, v733 in _pairs(v729) do
				if typeof(v733) == "string" then
					local v734 = Instance_new("ImageLabel");
					if typeof(v733) == "number" or typeof(_tonumber(v733)) == "number" then
						v734.Image = "rbxassetid://" .. _tostring(v733);
					elseif typeof(v733) == "string" then
						v734.Image = v733;
					end;
					v734.Size = UDim2_new(1.0E-5, 0, 1.0E-5, 0);
					v734.Parent = v731;
				end;
			end;
			task_delay(v730, function() --[[ Line: 3312 ]]
				-- upvalues: v731 (copy)
				if v731 ~= nil and v731.Parent ~= nil then
					v731:Destroy();
				end;
			end);
			v731.Parent = l_PlayerGui_0;
			return;
		end;
	end, 
	ImpactFrameSequence = function(v735, v736, v737, v738) --[[ Line: 3322 ]] --[[ Name: ImpactFrameSequence ]]
		-- upvalues: l_PlayerGui_0 (copy), l_RenderStepped_0 (copy)
		if typeof(v735) ~= "table" then
			return;
		else
			if typeof(v736) ~= "number" then
				v736 = 0.041666666666666664;
			end;
			if typeof(v737) ~= "boolean" then
				v737 = true;
			end;
			if typeof(v738) ~= "boolean" then
				v738 = false;
			end;
			local v739 = Instance_new("ScreenGui");
			v739.Name = "ImpactFrameSequence";
			v739.IgnoreGuiInset = true;
			v739.ResetOnSpawn = false;
			v739.Parent = l_PlayerGui_0;
			local v740 = 0;
			local v741 = #v735;
			local v742 = UDim2_new(1.0E-5, 0, 1.0E-5, 0);
			local v743 = UDim2_new(1, 0, 1, 0);
			for v744, v745 in _pairs(v735) do
				local v746 = Instance_new("ImageLabel");
				v746.BackgroundTransparency = 1;
				if typeof(v745) == "number" or typeof(_tonumber(v745)) == "number" then
					v746.Image = "rbxassetid://" .. _tostring(v745);
				elseif typeof(v745) == "string" then
					v746.Image = v745;
				end;
				v746.Name = _tostring(v744);
				if v744 == 1 then
					v746.Size = v743;
				else
					v746.Size = v742;
				end;
				v746.ZIndex = v744;
				v746.Parent = v739;
			end;
			local v747 = nil;
			local v748 = math_pow(v736, -1);
			v747 = if v738 == false then l_RenderStepped_0:Connect(function(v749) --[[ Line: 3366 ]]
				-- upvalues: v739 (copy), v747 (ref), v740 (ref), v748 (copy), v743 (copy), v741 (copy), v737 (ref), v736 (ref)
				if v739 == nil or v739.Parent == nil then
					if v747 ~= nil then
						v747:Disconnect();
						v747 = nil;
					end;
					return;
					else
					v740 = v740 + v749;
					local v750 = math_ceil(v748 * v740);
					local v751 = _tostring(v750);
					local l_v739_FirstChild_0 = v739:FindFirstChild(v751);
					if l_v739_FirstChild_0 ~= nil and l_v739_FirstChild_0.Parent ~= nil then
						l_v739_FirstChild_0.Size = v743;
						return;
					else
						if v741 <= v750 then
							if v737 == true then
								task_delay(v741 * v736 - v740, function() --[[ Line: 3383 ]]
									-- upvalues: v739 (ref)
									if v739 ~= nil and v739.Parent ~= nil then
										v739:Destroy();
									end;
								end);
							end;
							if v747 ~= nil then
								v747:Disconnect();
								v747 = nil;
							end;
						end;
						return;
					end;
				end;
			end) else l_RenderStepped_0:Connect(function(v753) --[[ Line: 3397 ]]
		-- upvalues: v739 (copy), v747 (ref), v740 (ref), v748 (copy), v743 (copy), v741 (copy), v737 (ref), v736 (ref)
		if v739 == nil or v739.Parent == nil then
			if v747 ~= nil then
				v747:Disconnect();
				v747 = nil;
			end;
			return;
		else
			v740 = v740 + v753;
			local v754 = math_ceil(v748 * v740);
			local v755 = _tostring(v754);
			local l_v739_FirstChild_1 = v739:FindFirstChild(v755);
			if l_v739_FirstChild_1 ~= nil and l_v739_FirstChild_1.Parent ~= nil then
				l_v739_FirstChild_1.Size = v743;
				local l_v739_FirstChild_2 = v739:FindFirstChild(_tostring(v754 - 1));
				if l_v739_FirstChild_2 ~= nil and l_v739_FirstChild_2.Parent ~= nil then
					l_v739_FirstChild_2:Destroy();
					return;
				end;
			elseif v741 <= v754 then
				if v737 == true then
					task_delay(v741 * v736 - v740, function() --[[ Line: 3418 ]]
						-- upvalues: v739 (ref)
						if v739 ~= nil and v739.Parent ~= nil then
							v739:Destroy();
						end;
					end);
				end;
				if v747 ~= nil then
					v747:Disconnect();
					v747 = nil;
				end;
			end;
			return;
		end;
	end);
	return v739;
end;
end, 
EndImpactFrameSequences = function() --[[ Line: 3437 ]] --[[ Name: EndImpactFrameSequences ]]
	-- upvalues: l_PlayerGui_0 (copy)
	for _, v759 in _pairs(l_PlayerGui_0:GetChildren()) do
		if v759.Name == "ImpactFrameSequence" then
			v759:Destroy();
		end;
	end;
end, 
MeshFlipbookSequence = function(v760, v761, v762) --[[ Line: 3445 ]] --[[ Name: MeshFlipbookSequence ]]
	-- upvalues: l_RenderStepped_0 (copy)
	if typeof(v760) ~= "table" then
		return;
	else
		if typeof(v761) ~= "number" then
			v761 = 0.016666666666666666;
		end;
		if typeof(v762) ~= "function" then
			return;
		else
			local v763 = 1;
			v762(v763);
			local v764 = nil;
			local v765 = false;
			local v766 = 0;
			v764 = l_RenderStepped_0:Connect(function(v767) --[[ Line: 3460 ]]
				-- upvalues: v765 (ref), v764 (ref), v766 (ref), v761 (ref), v763 (ref), v762 (copy), v760 (copy)
				if v765 == true then
					if v764 ~= nil then
						v764:Disconnect();
					end;
					v764 = nil;
					return;
				else
					v766 = v766 + v767;
					if v761 <= v766 then
						v763 = v763 + 1;
						v766 = 0;
						v762(v763);
					end;
					if v763 >= #v760 then
						v765 = true;
						if v764 ~= nil then
							v764:Disconnect();
						end;
						v764 = nil;
						return;
					else
						return;
					end;
				end;
			end);
			return;
		end;
	end;
end, 
GetCharacterClone2 = function(v819, v820, v821) --[[ Line: 3461 ]] --[[ Name: GetCharacterClone ]]
	if v819 == nil or v819.Parent == nil then
		return;
	else
		if typeof(v820) ~= "boolean" then
			v820 = true;
		end;
		if typeof(v821) ~= "boolean" then
			v821 = true;
		end;
		local v822 = v819:Clone();
		v822.Humanoid.PlatformStand = true;
		if v820 then
			for _, v824 in pairs(v822:GetDescendants()) do
				if v824:IsA("BasePart") then
					v824.CanCollide = false;
					v824.Massless = true;
					v824.CollisionGroup = "Nothing";
				elseif (v824:IsA("Script") or v824:IsA("LocalScript")) and v824.Name ~= "Animate" or v824:IsA("Configuration") then
					v824:Destroy();
				end;
			end;
		else
			for _, v826 in pairs(v822:GetDescendants()) do
				if (v826:IsA("Script") or v826:IsA("LocalScript")) and v826.Name ~= "Animate" or v826:IsA("Configuration") then
					v826:Destroy();
				end;
			end;
		end;
		if v821 then
			local v827 = nil;
			v827 = v819.ChildAdded:Connect(function(v828) --[[ Line: 3488 ]]
				-- upvalues: v819 (copy), v822 (copy)
				local l_Name_1 = v828.Name;
				if v828.ClassName == "Configuration" and l_Name_1 == "NewHumanoidDescriptionApplied" and v819 ~= nil and v819.Parent ~= nil and v822 ~= nil and v822.Parent ~= nil then
					VFXService.MatchCharacter(v819, v822);
				end;
			end);
			do
				local l_v827_0 = v827;
				v822.Destroying:Once(function() --[[ Line: 3495 ]]
					-- upvalues: l_v827_0 (ref)
					if l_v827_0 ~= nil then
						l_v827_0:Disconnect();
					end;
					l_v827_0 = nil;
				end);
			end;
		end;
		return v822;
	end;
end, 


TweenBeamTransparency = function(v768, v769, v770, v771, v772) --[[ Line: 3486 ]] --[[ Name: TweenBeamTransparency ]]
	-- upvalues: v102 (copy)
	if typeof(v768) ~= "Instance" or v768 == nil or v768.Parent == nil or not v768:IsA("Beam") then
		return;
	else
		if typeof(v769) ~= "number" then
			v769 = 0.63;
		end;
		if typeof(v770) ~= "EnumItem" then
			v770 = Enum_EasingStyle_Sine;
		end;
		if typeof(v771) ~= "EnumItem" then
			v771 = Enum_EasingDirection_Out;
		end;
		if typeof(v772) ~= "number" then
			v772 = 1;
		end;
		v772 = NumberSequence_new(v772, 1);
		local v773 = v102:Create(v768, {
			Time = v769, 
			EasingStyle = v770.Name, 
			EasingDirection = v771.Name, 
			Reverses = false, 
			DelayTime = 0, 
			RepeatCount = 0, 
			StepType = "Heartbeat", 
			Goal = {
				Transparency = v772
			}
		});
		v773:Play();
		return v773;
	end;
end, 

SetCharacterInvisible = function(v831) --[[ Line: 3505 ]] --[[ Name: SetCharacterInvisible ]]
	if v831 == nil or v831.Parent == nil then
		return;
	else
		VFXService.DestroyBind(v831, "IE", true);
		for _, v833 in pairs(v831:GetDescendants()) do
			if v833:GetAttribute("IE") == nil then
				if v833:IsA("BasePart") or v833:IsA("Decal") then
					v833:SetAttribute("IE", v833.Transparency);
					v833.Transparency = 1;
				end;
				if v833:IsA("BillboardGui") and v833.Name ~= "ConsoleLockOnUI" or v833:IsA("Highlight") then
					v833:SetAttribute("IE", v833.Enabled);
					v833.Enabled = false;
				end;
			end;
		end;
		local v834 = nil;
		VFXService.CreateBind(v831, "IE", function() --[[ Line: 3525 ]]
			-- upvalues: v834 (ref), v831 (copy)
			if v834 ~= nil then
				v834:Disconnect();
			end;
			v834 = nil;
			if v831 ~= nil and v831.Parent ~= nil then
				for _, v836 in pairs(v831:GetDescendants()) do
					if v836:GetAttribute("IE") ~= nil then
						local l_v836_Attribute_0 = v836:GetAttribute("IE");
						local v838 = typeof(l_v836_Attribute_0);
						if v838 == "number" then
							v836:SetAttribute("IE", nil);
							v836.Transparency = l_v836_Attribute_0;
						elseif v838 == "boolean" then
							v836:SetAttribute("IE", nil);
							v836.Enabled = l_v836_Attribute_0;
						end;
					end;
				end;
			end;
		end);
		v834 = v831.ChildAdded:Connect(function(v839) --[[ Line: 3546 ]]
			-- upvalues: v831 (copy)
			if v831 == nil or v831.Parent == nil then
				return;
			else
				if v839:IsA("BasePart") then
					v839:SetAttribute("IE", v839.Transparency);
					v839.Transparency = 1;
					for _, v841 in pairs(v839:GetDescendants()) do
						if v841:GetAttribute("IE") == nil then
							if v841:IsA("BasePart") or v841:IsA("Decal") then
								v841:SetAttribute("IE", v841.Transparency);
								v841.Transparency = 1;
							end;
							if v841:IsA("BillboardGui") and v841.Name ~= "ConsoleLockOnUI" or v841:IsA("Highlight") then
								v841:SetAttribute("IE", v841.Enabled);
								v841.Enabled = false;
							end;
						end;
					end;
				else
					for _, v843 in pairs(v839:GetDescendants()) do
						if v843:GetAttribute("IE") == nil then
							if v843:IsA("BasePart") or v843:IsA("Decal") then
								v843:SetAttribute("IE", v843.Transparency);
								v843.Transparency = 1;
							end;
							if v843:IsA("BillboardGui") and v843.Name ~= "ConsoleLockOnUI" or v843:IsA("Highlight") then
								v843:SetAttribute("IE", v843.Enabled);
								v843.Enabled = false;
							end;
						end;
					end;
					task.spawn(function() --[[ Line: 3574 ]]
						-- upvalues: v839 (copy), v831 (ref)
						task.wait();
						if v839 ~= nil and v839.Parent ~= nil and v839.Parent == v831 then
							for _, v845 in pairs(v839:GetDescendants()) do
								if v845:GetAttribute("IE") == nil then
									if v845:IsA("BasePart") or v845:IsA("Decal") then
										v845:SetAttribute("IE", v845.Transparency);
										v845.Transparency = 1;
									end;
									if v845:IsA("BillboardGui") and v845.Name ~= "ConsoleLockOnUI" or v845:IsA("Highlight") then
										v845:SetAttribute("IE", v845.Enabled);
										v845.Enabled = false;
									end;
								end;
							end;
						end;
					end);
				end;
				for _, v847 in pairs(v831:GetDescendants()) do
					if v847:GetAttribute("IE") == nil then
						if v847:IsA("BasePart") or v847:IsA("Decal") then
							v847:SetAttribute("IE", v847.Transparency);
							v847.Transparency = 1;
						end;
						if v847:IsA("BillboardGui") and v847.Name ~= "ConsoleLockOnUI" or v847:IsA("Highlight") then
							v847:SetAttribute("IE", v847.Enabled);
							v847.Enabled = false;
						end;
					end;
				end;
				return;
			end;
		end);
		return;
	end;
end, 


SetCharacterVisible = function(v848) --[[ Line: 3606 ]] --[[ Name: SetCharacterVisible ]]
	if v848 == nil or v848.Parent == nil then
		return;
	else
		VFXService.DestroyBind(v848, "IE", true);
		return;
	end;
end, 
}


local function CreateBind(Character: Model, Name: string, DestroyFunction)
	local Bind = Instance.new("Folder")
	Bind.Name = Name
	Bind.Destroying:Once(DestroyFunction)
	Bind.Parent = Character
	return Bind
end

local function DestroyBind(Character: Model, Name: string, DestroyAll: boolean)
	DestroyAll = DestroyAll or true

	for _, v in Character:GetChildren() do
		if v.Name ~= Name then continue end

		v:Destroy()

		if not DestroyAll then return end
	end
end

local function DTWait(WaitTime)
	local eTime = 0
	while eTime < WaitTime do
		eTime += RNS.RenderStepped:Wait()
	end

	return eTime
end

local function Wind1(Part, TweenDivider, AxisMod, PositionAxis, AngleAxis, UseMesh, UseDecal, TweenSize)
	local TweenTime = 0.65 / TweenDivider
	local Position = {
		X = 0, 
		Y = 0, 
		Z = 0
	}
	local Angle = {
		X = 0, 
		Y = 0, 
		Z = 0
	}

	Position[PositionAxis] = -10 * AxisMod
	Angle[AngleAxis] = -math.pi / 2


	TS:Create(Part, TweenInfo.new(0.85 / TweenDivider, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = Part.CFrame * CFrame.new(Position.X, Position.Y, Position.Z) * CFrame.Angles(Angle.X, Angle.Y, Angle.Z)
	}):Play()

	TS:Create(UseDecal and Part.Decal or Part, TweenInfo.new(TweenTime, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Transparency = 1
	}):Play()

	if TweenSize then
		TS:Create(UseMesh and Part.Mesh or Part, TweenInfo.new(TweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			(UseMesh and
				{ Scale = Vector3.new(Part.Mesh.Scale.X * 1.25, 0, Part.Mesh.Scale.Z * 1.25) }
				or
				{ Size = Vector3.new(Part.Size.X * 1.25, 0, Part.Size.Z * 1.25) }
			)
		):Play()
	end

	Position = nil
	Angle = nil
end

local function Wind2(v872, v873, v874, v875, v876, v877, v878)
	local v879 = {
		X = 0, 
		Y = 0, 
		Z = 0, 
		[v875] = -9 * v874
	}
	local v880 = if v876 then v872.Mesh else v872
	local v881 = if v877 then v872.Decal else v872
	TS:Create(v872, TweenInfo.new(0.85 / v873, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = v872.CFrame * CFrame.new(v879.X, v879.Y, v879.Z)
	}):Play()
	local v882 = 0.65 / v873
	TS:Create(v881, TweenInfo.new(v882, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Transparency = 1
	}):Play()
	if v878 then
		local v883 = nil
		v883 = if v876 then {
			Scale = Vector3.new(v872.Mesh.Scale.X * 3, 0, v872.Mesh.Scale.Z * 3)
		} else {
				Size = Vector3.new(v872.Size.X * 3, 0, v872.Size.Z * 3)
			}
		TS:Create(v880, TweenInfo.new(v882, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), v883):Play()
		v883 = nil
	end
	v879 = nil
end

local function Wind3(v884, v885, v886, v887, v888, v889)
	local v890 = if v887 then v884.Mesh else v884
	local v891 = if v888 then v884.Decal else v884
	local v892 = 0.65 / v885
	TS:Create(v891, TweenInfo.new(v892, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Transparency = 1
	}):Play()
	if v889 then
		local v893 = nil
		v893 = if v887 then {
			Scale = v884.Mesh.Scale * v886
		} else {
				Size = v884.Size * v886
			}
		TS:Create(v890, TweenInfo.new(v892, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), v893):Play()
		v893 = nil
	end
end

local function Wind4(Part, TweenDivider, Multiplier, Axis, UseMesh, UseDecal, TweenSize)
	local TweenTime = 0.65 / TweenDivider
	local Position = {
		X = 0,
		Y = 0,
		Z = 0
	}
	Position[Axis] = -4 * Multiplier


	TS:Create(Part, TweenInfo.new(0.85 / TweenDivider, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = Part.CFrame * CFrame.new(Position.X, Position.Y, Position.Z)
	}):Play()

	TS:Create(UseDecal and Part.Decal or Part, TweenInfo.new(TweenTime, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Transparency = 1
	}):Play()

	if TweenSize then
		TS:Create(UseMesh and Part.Mesh or Part, TweenInfo.new(TweenTime, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			(UseMesh and
				{ Scale = Vector3.new(Part.Mesh.Scale.X * 2, Part.Mesh.Scale.Y * 1.15, Part.Mesh.Scale.Z * 2) }
				or
				{ Size = Vector3.new(Part.Size.X * 2, Part.Size.Y * 1.15, Part.Size.Z * 2) }
			)
		):Play()
	end

	Position = nil
end

local function Wind5(v906, v907, v908, v909, v910, v911, v912, v913, v914)
	local v915 = {
		X = 0, 
		Y = 0, 
		Z = 0, 
		[v909] = if v914 then 6.5 * v908 else -6.5 * v908
	}
	local v916 = if v911 then v906.Mesh else v906
	local v917 = if v912 then v906.Decal else v906
	local v918 = {
		X = 0, 
		Y = 0, 
		Z = 0, 
		[v910] = 6
	}
	TS:Create(v906, TweenInfo.new(0.85 / v907, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = v906.CFrame * CFrame.new(v915.X, v915.Y, v915.Z)
	}):Play()
	local v919 = 0.65 / v907
	TS:Create(v917, TweenInfo.new(v919, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Transparency = 1
	}):Play()
	if v913 then
		local v920 = nil
		v920 = if v911 then {
			Scale = Vector3.new(v906.Mesh.Scale.X * v918.X, v906.Mesh.Scale.Y * v918.Y, v906.Mesh.Scale.Z * v918.Z)
		} else {
				Size = Vector3.new(v906.Size.X * v918.X, v906.Size.Y * v918.Y, v906.Size.Z * v918.Z)
			}
		TS:Create(v916, TweenInfo.new(v919, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), v920):Play()
		v920 = nil
	end
	v915 = nil
	v918 = nil
end

local function Wind6(v921, v922, v923, v924, v925, v926, v927)
	local v928 = {
		X = 0, 
		Y = 0, 
		Z = 0, 
		[v924] = -2 * v923
	}
	local v929 = if v925 then v921.Mesh else v921
	local v930 = if v926 then v921.Decal else v921
	TS:Create(v921, TweenInfo.new(0.85 / v922, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = v921.CFrame * CFrame.new(v928.X, v928.Y, v928.Z)
	}):Play()
	local v931 = 0.65 / v922
	TS:Create(v930, TweenInfo.new(v931, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Transparency = 1
	}):Play()
	if v927 then
		local v932 = nil
		v932 = if v925 then {
			Scale = Vector3.new(v921.Mesh.Scale.X, v921.Mesh.Scale.Y * 3.225, v921.Mesh.Scale.Z)
		} else {
				Size = Vector3.new(v921.Size.X, v921.Size.Y * 3.225, v921.Size.Z)
			}
		TS:Create(v929, TweenInfo.new(v931, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), v932):Play()
		v932 = nil
	end
	v928 = nil
end

local function Wind7(Part, TweenDivider, AxisMultiplier, PositionAxis, SizeAxis, AngleAxis, UseMesh, UseDecal, TweenSize, AddPosition)
	local TweenTime = 0.65 / TweenDivider
	local Position = {
		X = 0,
		Y = 0,
		Z = 0
	}
	local Angle = {
		X = 0,
		Y = 0,
		Z = 0
	}
	local Size = {
		X = 1.25,
		Y = 1.25,
		Z = 1.25
	}

	Position[PositionAxis] = if AddPosition then 6.5 * AxisMultiplier else -6.5 * AxisMultiplier
	Angle[AngleAxis] = math.pi / 1.5
	Size[SizeAxis] = 4.5


	TS:Create(Part, TweenInfo.new(0.85 / TweenDivider, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = Part.CFrame * CFrame.new(Position.X, Position.Y, Position.Z) * CFrame.Angles(Angle.X, Angle.Y, Angle.Z)
	}):Play()

	TS:Create(UseDecal and Part.Decal or Part, TweenInfo.new(TweenTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Transparency = 1
	}):Play()

	if TweenSize then
		TS:Create(UseMesh and Part.Mesh or Part, TweenInfo.new(TweenTime, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			(UseMesh and
				{ Scale = Vector3.new(Part.Mesh.Scale.X * Size.X, Part.Mesh.Scale.Y * Size.Y, Part.Mesh.Scale.Z * Size.Z) }
				or
				{ Size = Vector3.new(Part.Size.X * Size.X, Part.Size.Y * Size.Y, Part.Size.Z * Size.Z) }
			)
		):Play()
	end

	Position = nil
	Angle = nil
	Size = nil
end

local function Wind8(Part, TweenDivider, PositionMultiplier, PositionAxis, SizeAxis, UseMesh, UseDecal, TweenSize, RemovePosition)
	local TweenTime = 0.65 / TweenDivider
	local Position = {
		X = 0,
		Y = 0,
		Z = 0
	}
	local Size = {
		X = 3.5,
		Y = 3.5,
		Z = 3.5
	}

	Position[PositionAxis] = RemovePosition and -4 * PositionMultiplier or 4 * PositionMultiplier
	Size[SizeAxis] = 1.45


	TS:Create(Part, TweenInfo.new(0.85 / TweenDivider, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		CFrame = Part.CFrame * CFrame.new(Position.X, Position.Y, Position.Z)
	}):Play()

	TS:Create(UseDecal and Part.Decal or Part, TweenInfo.new(TweenTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Transparency = 1
	}):Play()

	if TweenSize then
		TS:Create(UseMesh and Part.Mesh or Part, TweenInfo.new(TweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			(UseMesh and
				{ Scale = Vector3.new(Part.Mesh.Scale.X * Size.X, Part.Mesh.Scale.Y * Size.Y, Part.Mesh.Scale.Z * Size.Z) }
				or
				{ Size = Vector3.new(Part.Size.X * Size.X, Part.Size.Y * Size.Y, Part.Size.Z * Size.Z) }
			)
		):Play()
	end

	Position = nil
	Size = nil
end

local function Wind9(Part, TweenDivider, SizeModifier, AngleAxis, UseMesh, UseDecal, TweenSize, PositiveAngle)
	local TweenTime = 0.65 / TweenDivider
	local ZAngle = math.rad(179)
	local Angle = {
		X = 0, 
		Y = 0, 
		Z = 0, 
	}

	Angle[AngleAxis] = PositiveAngle and ZAngle or -ZAngle


	TS:Create(Part, TweenInfo.new(1.25 / TweenDivider, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = Part.CFrame * CFrame.Angles(Angle.X, Angle.Y, Angle.Z)
	}):Play()

	TS:Create(UseDecal and Part.Decal or Part, TweenInfo.new(TweenTime, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Transparency = 1
	}):Play()

	if TweenSize then
		TS:Create(UseMesh and Part.Mesh or Part, TweenInfo.new(TweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			(UseMesh and
				{ Scale = Part.Mesh.Scale * SizeModifier }
				or
				{ Size = Part.Size * SizeModifier }
			)
		):Play()
	end

	Angle = nil
end

local function Wind10(v984, v985, v986, v987, v988, v989, v990, v991)
	local v992 = {
		X = 0, 
		Y = 0, 
		Z = 0, 
		[v987] = -4 * v986
	}
	local v993 = if v989 then v984.Mesh else v984
	local v994 = if v990 then v984.Decal else v984
	local v995 = {
		X = 0, 
		Y = 0, 
		Z = 0, 
		[v988] = 0.25
	}
	for v996, _ in pairs(v995) do
		if v996 ~= v988 then
			v995[v996] = 2
		end
	end
	local v998 = 0.65 / v985
	TS:Create(v984, TweenInfo.new(0.85 / v985, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = v984.CFrame * CFrame.new(v992.X, v992.Y, v992.Z)
	}):Play()
	TS:Create(v994, TweenInfo.new(v998, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Transparency = 1
	}):Play()
	if v991 then
		local v999 = nil
		v999 = if v989 then {
			Scale = Vector3.new(v984.Mesh.Scale.X * v995.X, v984.Mesh.Scale.Y * v995.Y, v984.Mesh.Scale.Z * v995.Z)
		} else {
				Size = Vector3.new(v984.Size.X * v995.X, v984.Size.Y * v995.Y, v984.Size.Z * v995.Z)
			}
		TS:Create(v993, TweenInfo.new(v998, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), v999):Play()
		v999 = nil
	end
	v992 = nil
end

local function adjustParticleEmitterZOffset(fxData)
	local fx = fxData.FX
	local count = fxData.Count

	for _, descendant in pairs(fx:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			descendant.ZOffset = descendant.ZOffset + count
		end
	end
end

local function adjustParticleEmitterLifetime(fxData)
	local fx = fxData.FX
	local scale = fxData.Scale

	for _, descendant in pairs(fx:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			descendant.Lifetime = NumberRange.new(
				descendant.Lifetime.Min * scale, 
				descendant.Lifetime.Max * scale
			)
		end
	end
end

local function Wind11(v1000, v1001, v1002, v1003, v1004, v1005, v1006, v1007, v1008)
	local v1009 = {
		X = 0, 
		Y = 0, 
		Z = 0
	}
	local v1010 = {
		X = 0, 
		Y = 0, 
		Z = 0
	}
	local v1011 = if v1006 then v1000.Mesh else v1000
	local v1012 = if v1007 then v1000.Decal else v1000
	local v1013 = {
		X = 0, 
		Y = 0, 
		Z = 0, 
		[v1005] = 1.05
	}
	for v1014, _ in pairs(v1013) do
		if v1014 ~= v1005 then
			v1013[v1014] = 1.5
		end
	end
	v1009[v1003] = -10 * v1002
	v1010[v1004] = -math.pi / 2
	local v1016 = 0.65 / v1001
	TS:Create(v1000, TweenInfo.new(0.85 / v1001, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = v1000.CFrame * CFrame.new(v1009.X, v1009.Y, v1009.Z) * CFrame.Angles(v1010.X, v1010.Y, v1010.Z)
	}):Play()
	TS:Create(v1012, TweenInfo.new(v1016, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Transparency = 1
	}):Play()
	if v1008 then
		local v1017 = nil
		v1017 = if v1006 then {
			Scale = Vector3.new(v1000.Mesh.Scale.X * v1013.X, v1000.Mesh.Scale.Y * v1013.Y, v1000.Mesh.Scale.Z * v1013.Z)
		} else {
				Size = Vector3.new(v1000.Size.X * v1013.X, v1000.Size.Y * v1013.Y, v1000.Size.Z * v1013.Z)
			}
		TS:Create(v1011, TweenInfo.new(v1016, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), v1017):Play()
		v1017 = nil
	end
	v1009 = nil
	v1010 = nil
	v1013 = nil
end






local module = {
    ['ShinjiRep'] = function(v777)
	   local l_Request_1 = v777.Request;
		if l_Request_1 == "ObliterationCam" then
			local l_Debris_0 = require(game.ReplicatedStorage.Modules.Debris)
            local Effects = game.ReplicatedStorage.Assets.Particles.Emotes.Obliteration
			local l_U_21 = v777.Char
			if l_U_21 == nil or l_U_21.Parent == nil then
				return;
			else
				local v2163 = VFXService.InitiateCutscene("Obliteration", 60, 138408795832056, l_U_21.HumanoidRootPart, CFrame.new(0, -3, 0), {
					Time = 0.4
				});
				--local v2164 = Sound.Play(Effects.ObliterationEmote, l_U_21.Torso)
				local v2164 = VFXService.PlaySound("ObliterationEmote");
				local v2165 = l_TweenService_0:Create(v2164, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Volume = 0
				});
				local l_v2164_0 = v2164 --[[ copy: 4 -> 1436 ]];
				v2165.Completed:Once(function() --[[ Line: 7751 ]]
					-- upvalues: l_v2164_0 (copy)
					if l_v2164_0 ~= nil then
						l_v2164_0:Destroy();
					end;
				end);
				local v2167 = nil;
				do
					local l_v2167_0 = v2167;
					l_v2167_0 = v22.ChildAdded:Connect(function(v2169) --[[ Line: 7757 ]]
						-- upvalues: l_v2167_0 (ref), l_v2164_0 (copy)
						if v2169.Name == "ObliterationEnd" then
							if l_v2167_0 ~= nil then
								l_v2167_0:Disconnect();
							end;
							l_v2167_0 = nil;
							if l_v2164_0 ~= nil and l_v2164_0.Parent ~= nil then
								l_v2164_0:SetAttribute("Ended", true);
							end;
						end;
					end);
					local l_v2165_0 = v2165 --[[ copy: 5 -> 1437 ]];
					VFXService.CreateBind(v22, "ObliterationSFX", function() --[[ Line: 7767 ]]
						-- upvalues: l_v2167_0 (ref), l_v2164_0 (copy), l_v2165_0 (copy)
						if l_v2167_0 ~= nil then
							l_v2167_0:Disconnect();
						end;
						l_v2167_0 = nil;
						if l_v2164_0 ~= nil and l_v2164_0.Parent ~= nil and not l_v2164_0:GetAttribute("Ended") and l_v2165_0 ~= nil then
							l_v2165_0:Play();
						end;
					end);
					local l_CamFX_0 = l_Assets_0.Particles.Emotes.Obliteration.CamFX;
					local v2172 = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
					local v2173 = {
						TextureSpeed = 0.1
					};
					local l_v2163_0 = v2163 --[[ copy: 3 -> 1438 ]];
					local l_l_CamFX_0_0 = l_CamFX_0 --[[ copy: 7 -> 1439 ]];
					local l_v2172_0 = v2172 --[[ copy: 8 -> 1440 ]];
					local l_v2173_0 = v2173 --[[ copy: 9 -> 1441 ]];
					task.delay(2.6333333333333333, function() --[[ Line: 7779 ]]
						-- upvalues: l_v2163_0 (copy), l_l_CamFX_0_0 (copy), v22 (ref), l_Debris_0 (ref), l_VFX_0 (ref), l_TweenService_0 (ref), l_v2172_0 (copy), l_v2173_0 (copy)
						if l_v2163_0 ~= nil and l_v2163_0.Parent ~= nil then
							VFXService.ScreenFlash(nil, nil, nil, 0.6);
							local v2178 = l_l_CamFX_0_0:Clone();
							v2178.Attach.Part0 = l_v2163_0.Camera;
							VFXService.CreateBind(v22, "ObliterationCamFX", function() --[[ Line: 7784 ]]
								-- upvalues: v2178 (copy), l_Debris_0 (ref)
								if v2178 ~= nil and v2178.Parent ~= nil then
									v2178.Attach:Destroy();
									v2178.Primary.Anchored = true;
									for _, v2180 in pairs(v2178:GetDescendants()) do
										if v2180:IsA("ParticleEmitter") then
											v2180.Enabled = false;
										end;
									end;
									l_Debris_0.AddItem(v2178, 3);
								end;
							end);
							v2178.Parent = l_VFX_0;
							for _, v2182 in pairs(v2178:GetDescendants()) do
								if v2182:IsA("Beam") then
									VFXService.TweenBeamTransparency(v2182, 1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 1);
									l_TweenService_0:Create(v2182, l_v2172_0, l_v2173_0):Play();
								end;
							end;
							task.delay(2.0333333333333337, function() --[[ Line: 7803 ]]
								-- upvalues: l_v2163_0 (ref), v2178 (copy)
								if l_v2163_0 ~= nil and l_v2163_0.Parent ~= nil and v2178 ~= nil and v2178.Parent ~= nil then
									for _, v2184 in pairs(v2178:GetDescendants()) do
										if v2184:IsA("ParticleEmitter") then
											v2184:Emit(1);
											v2184.Enabled = true;
										end;
									end;
								end;
							end);
						end;
					end);
				
				end;
			end;
		elseif l_Request_1 == "ObliterationSFX" then
			local l_Debris_0 = require(game.ReplicatedStorage.Modules.Debris)
			local l_U_22 = v777.Char;
			if l_U_22 == nil or l_U_22.Parent == nil then
				return;
			else
				local v2193 = VFXService.PlaySoundAtCFrame(l_U_22.HumanoidRootPart.CFrame, "ObliterationOutsideEmote");
				local v2194 = l_TweenService_0:Create(v2193, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Volume = 0
				});
				local l_v2193_0 = v2193 --[[ copy: 3 -> 1434 ]];
				v2194.Completed:Once(function() --[[ Line: 7834 ]]
					-- upvalues: l_v2193_0 (copy)
					if l_v2193_0 ~= nil and l_v2193_0.Parent ~= nil then
						l_v2193_0:Destroy();
					end;
				end);
				local v2196 = nil;
				do
					local l_v2196_0 = v2196;
					l_v2196_0 = l_U_22.ChildAdded:Connect(function(v2198) --[[ Line: 7840 ]]
						-- upvalues: l_v2196_0 (ref), l_v2193_0 (copy)
						if v2198.Name == "ObliterationEnd" then
							if l_v2196_0 ~= nil then
								l_v2196_0:Disconnect();
							end;
							l_v2196_0 = nil;
							if l_v2193_0 ~= nil and l_v2193_0.Parent ~= nil then
								l_v2193_0:SetAttribute("Ended", true);
							end;
						end;
					end);
					local l_v2194_0 = v2194 --[[ copy: 4 -> 1435 ]];
					VFXService.CreateBind(l_U_22, "ObliterationSFX", function() --[[ Line: 7850 ]]
						-- upvalues: l_v2196_0 (ref), l_v2193_0 (copy), l_v2194_0 (copy)
						if l_v2196_0 ~= nil then
							l_v2196_0:Disconnect();
						end;
						l_v2196_0 = nil;
						if l_v2193_0 ~= nil and l_v2193_0.Parent ~= nil and not l_v2193_0:GetAttribute("Ended") and l_v2194_0 ~= nil then--DestroyBind(U, "ObliterationSwordSpin", true)
							l_v2194_0:Play();
						end;
					end);
				end;
			end;
		elseif l_Request_1 == "SwordSpinEnd" then
			local l_U_23 = v777.Emeny;
			VFXService.DestroyBind(l_U_23, "ObliterationSwordSpin", true)

		elseif l_Request_1 == "CObliteration" then
        
			local l_U_23 = v777.Char;
			if l_U_23 == nil or l_U_23.Parent == nil then
				return;
			else
				VFXService.DestroyBind(l_U_23, "ObliterationSwordSpin", true);
				VFXService.DestroyBind(l_U_23, "ObliterationSpinDrop", true);
				VFXService.DestroyBind(l_U_23, "ObliterationSFX", true);
				if l_U_23 == v22 or v777.Emeny == v22 then
					VFXService.DestroyBind(v22, "ObliterationSFX", true);
					VFXService.DestroyBind(v22, "ObliterationCamFX", true);
					VFXService.EndCutscene();
				end;
			end;
		elseif l_Request_1 == "ObliterationKick" then
			local l_Debris_0 = require(game.ReplicatedStorage.Modules.Debris)
			local l_T_4 = v777.Emeny;
			if l_T_4 == nil or l_T_4.Parent == nil then
				return;
			else
				local v2202 = l_Assets_0.Particles.Emotes.Obliteration.Container.Kick1:Clone();
				v2202.Parent = l_T_4.HumanoidRootPart;
				VFXService.EmitParticlesInInstance(v2202);
				l_Debris_0.AddItem(v2202, 3);
			end;
		elseif l_Request_1 == "ObliterationKick1Release" then
			local l_Debris_0 = require(game.ReplicatedStorage.Modules.Debris)
			local l_U_24 = v777.Char;
			if l_U_24 == nil or l_U_24.Parent == nil then
				return;
			else
				local l_Obliteration_0 = l_Assets_0.Particles.Emotes.Obliteration;
				local l_Kick_0 = l_Obliteration_0.Kick;
				local l_EmoteKick3_0 = l_Obliteration_0.EmoteKick3;
				local l_l_U_24_0 = l_U_24 --[[ copy: 2 -> 1430 ]];
				local l_l_Kick_0_0 = l_Kick_0 --[[ copy: 4 -> 1431 ]];
				local function v2218(v2209, v2210, v2211) --[[ Line: 7894 ]] --[[ Name: MeshPreset1 ]]
					-- upvalues: l_l_U_24_0 (copy), l_l_Kick_0_0 (copy), l_VFX_0 (ref), l_Debris_0 (ref)
					if l_l_U_24_0 == nil or l_l_U_24_0.Parent == nil then
						return;
					else
						local l_CFrame_23 = l_l_U_24_0.HumanoidRootPart.CFrame;
						local v2213 = l_l_Kick_0_0.ring:Clone();
						v2213.CFrame = l_CFrame_23 * CFrame.new(0, 4.25 * v2210, v2211) * CFrame.Angles(0, math.random(-3, 3), 0);
						local v2214 = l_l_Kick_0_0.LightWind1:Clone();
						local v2215 = CFrame.new(0, v2210, v2211);
						v2214.CFrame = l_CFrame_23 * v2215 * CFrame.Angles(0, math.random(-3, 3), 0);
						local v2216 = l_l_Kick_0_0.LightWind2:Clone();
						v2216.CFrame = l_CFrame_23 * v2215 * CFrame.Angles(math.random(-3, 3), math.random(-3, 3), math.random(-3, 3));
						v2213.Parent = l_VFX_0;
						v2214.Parent = l_VFX_0;
						v2216.Parent = l_VFX_0;
						local v2217 = 0.5 * v2210;
						Wind1(v2213, 0.35 * v2209, v2217, "Y", "Y", true, true, true);
						Wind1(v2214, 0.15 * v2209, v2217, "Y", "Y", false, false, true);
						Wind9(v2216, 2 * v2209, 1.5 * v2210, "Y", false, false, true, true);
						l_Debris_0.AddItem(v2213, 3);
						l_Debris_0.AddItem(v2214, 3);
						l_Debris_0.AddItem(v2216, 3);
						return;
					end;
				end;
				local v2219 = CFrame.Angles(1.5707963267948966, 0, 0);
				local l_l_EmoteKick3_0_0 = l_EmoteKick3_0 --[[ copy: 5 -> 1432 ]];
				local l_v2219_0 = v2219 --[[ copy: 7 -> 1433 ]];
				local function v2227(v2222, v2223) --[[ Line: 7917 ]] --[[ Name: MovePreset ]]
					-- upvalues: l_l_U_24_0 (copy), l_l_EmoteKick3_0_0 (copy), l_v2219_0 (copy), l_VFX_0 (ref), l_Debris_0 (ref)
					if l_l_U_24_0 == nil or l_l_U_24_0.Parent == nil then
						return;
					else
						local l_CFrame_24 = l_l_U_24_0.HumanoidRootPart.CFrame;
						local v2225 = l_l_EmoteKick3_0_0.mesh:Clone();
						v2225.CFrame = l_CFrame_24 * CFrame.new(0, 0, -9 + v2223) * l_v2219_0;
						local v2226 = l_l_EmoteKick3_0_0.WindSwirl:Clone();
						v2226.CFrame = l_CFrame_24 * CFrame.new(0, 0, -1.5 + v2223) * CFrame.Angles(1.5707963267948966, math.random(-3, 3), 0);
						v2225.Parent = l_VFX_0;
						v2226.Parent = l_VFX_0;
						Wind1(v2225, v2222, -0.75, "Y", "Y", false, false, true);
						Wind7(v2226, 0.35 * v2222, 1, "Y", "Y", "Y", false, false, true, false);
						l_Debris_0.AddItem(v2225, 3);
						l_Debris_0.AddItem(v2226, 3);
						return;
					end;
				end;
				v2218(2, 1, -5);
				v2227(2, 0);
			end;
		elseif l_Request_1 == "ObliterationKick2" then
			local l_Debris_0 = require(game.ReplicatedStorage.Modules.Debris)
			local l_U_25 = v777.Char
			if l_U_25 == nil or l_U_25.Parent == nil then
				return;
			else
				local l_T_5 = v777.Emeny
				if l_T_5 == nil or l_T_5.Parent == nil then
					return;
				else
					local l_Obliteration_1 = l_Assets_0.Particles.Emotes.Obliteration;
					local l_Kick_1 = l_Obliteration_1.Kick;
					local l_EmoteKick3_1 = l_Obliteration_1.EmoteKick3;
					local l_l_U_25_0 = l_U_25 --[[ copy: 2 -> 1425 ]];
					local l_l_T_5_0 = l_T_5 --[[ copy: 3 -> 1426 ]];
					local l_l_Kick_1_0 = l_Kick_1 --[[ copy: 5 -> 1427 ]];
					local function v2245(v2236, v2237, v2238) --[[ Line: 7949 ]] --[[ Name: MeshPreset1 ]]
						-- upvalues: l_l_U_25_0 (copy), l_l_T_5_0 (copy), l_l_Kick_1_0 (copy), l_VFX_0 (ref), l_Debris_0 (ref)
						if l_l_U_25_0 == nil or l_l_U_25_0.Parent == nil or l_l_T_5_0 == nil or l_l_T_5_0.Parent == nil then
							return;
						else
							local l_CFrame_25 = l_l_U_25_0.HumanoidRootPart.CFrame;
							local v2240 = l_l_Kick_1_0.ring:Clone();
							v2240.CFrame = l_CFrame_25 * CFrame.new(0, 4.25 * v2237, v2238) * CFrame.Angles(0, math.random(-3, 3), 0);
							local v2241 = l_l_Kick_1_0.LightWind1:Clone();
							local v2242 = CFrame.new(0, v2237, v2238);
							v2241.CFrame = l_CFrame_25 * v2242 * CFrame.Angles(0, math.random(-3, 3), 0);
							local v2243 = l_l_Kick_1_0.LightWind2:Clone();
							v2243.CFrame = l_CFrame_25 * v2242 * CFrame.Angles(math.random(-3, 3), math.random(-3, 3), math.random(-3, 3));
							v2240.Parent = l_VFX_0;
							v2241.Parent = l_VFX_0;
							v2243.Parent = l_VFX_0;
							local v2244 = 0.5 * v2237;
							Wind1(v2240, 0.35 * v2236, v2244, "Y", "Y", true, true, true);
							Wind1(v2241, 0.15 * v2236, v2244, "Y", "Y", false, false, true);
							Wind9(v2243, 2 * v2236, 1.5 * v2237, "Y", false, false, true, true);
							l_Debris_0.AddItem(v2240, 3);
							l_Debris_0.AddItem(v2241, 3);
							l_Debris_0.AddItem(v2243, 3);
							return;
						end;
					end;
					local v2246 = CFrame.Angles(1.5707963267948966, 0, 0);
					local l_l_EmoteKick3_1_0 = l_EmoteKick3_1 --[[ copy: 6 -> 1428 ]];
					local l_v2246_0 = v2246 --[[ copy: 8 -> 1429 ]];
					local function v2254(v2249, v2250) --[[ Line: 7974 ]] --[[ Name: MovePreset ]]
						-- upvalues: l_l_U_25_0 (copy), l_l_T_5_0 (copy), l_l_EmoteKick3_1_0 (copy), l_v2246_0 (copy), l_VFX_0 (ref), l_Debris_0 (ref)
						if l_l_U_25_0 == nil or l_l_U_25_0.Parent == nil or l_l_T_5_0 == nil or l_l_T_5_0.Parent == nil then
							return;
						else
							local l_CFrame_26 = l_l_U_25_0.HumanoidRootPart.CFrame;
							local v2252 = l_l_EmoteKick3_1_0.mesh:Clone();
							v2252.CFrame = l_CFrame_26 * CFrame.new(0, 0, -9 + v2250) * l_v2246_0;
							local v2253 = l_l_EmoteKick3_1_0.WindSwirl:Clone();
							v2253.CFrame = l_CFrame_26 * CFrame.new(0, 0, -1.5 + v2250) * CFrame.Angles(1.5707963267948966, math.random(-3, 3), 0);
							v2252.Parent = l_VFX_0;
							v2253.Parent = l_VFX_0;
							Wind1(v2252, v2249, -0.75, "Y", "Y", false, false, true);
							Wind7(v2253, 0.35 * v2249, 1, "Y", "Y", "Y", false, false, true, false);
							l_Debris_0.AddItem(v2252, 3);
							l_Debris_0.AddItem(v2253, 3);
							return;
						end;
					end;
					v2245(2, 1, -15);
					v2254(2, -10);
					local v2255 = l_Obliteration_1.Container.Kick2:Clone();
					v2255.Parent = l_T_5.HumanoidRootPart;
					local v2256 = l_Obliteration_1.Container.Torso:Clone();
					v2256.Parent = l_T_5.Torso;
					VFXService.EmitParticlesInInstance(v2255);
					VFXService.EmitParticlesInInstance(v2256);
					l_Debris_0.AddItem(v2255, 3.5);
					l_Debris_0.AddItem(v2256, 3.5);
				end;
			end;
		elseif l_Request_1 == "ObliterationKick3" then
			local l_Debris_0 = require(game.ReplicatedStorage.Modules.Debris)
			local l_U_26 = v777.Char;
			if l_U_26 == nil or l_U_26.Parent == nil then
				return;
			else
				local l_T_6 = v777.Emeny
				if l_T_6 == nil or l_T_6.Parent == nil then
					return;
				else
					local l_Obliteration_2 = l_Assets_0.Particles.Emotes.Obliteration;
					local _ = l_Obliteration_2.Kick;
					local l_EmoteKick3_2 = l_Obliteration_2.EmoteKick3;
					local v2262 = CFrame.Angles(1.5707963267948966, 0, 0);
					local l_l_U_26_0 = l_U_26 --[[ copy: 2 -> 1421 ]];
					local l_l_T_6_0 = l_T_6 --[[ copy: 3 -> 1422 ]];
					local l_l_EmoteKick3_2_0 = l_EmoteKick3_2 --[[ copy: 6 -> 1423 ]];
					local l_v2262_0 = v2262 --[[ copy: 7 -> 1424 ]];
					(function(v2267, v2268) --[[ Line: 8016 ]] --[[ Name: MovePreset ]]
						-- upvalues: l_l_U_26_0 (copy), l_l_T_6_0 (copy), l_l_EmoteKick3_2_0 (copy), l_v2262_0 (copy), l_VFX_0 (ref), l_Debris_0 (ref)
						if l_l_U_26_0 == nil or l_l_U_26_0.Parent == nil or l_l_T_6_0 == nil or l_l_T_6_0.Parent == nil then
							return;
						else
							local l_CFrame_27 = l_l_U_26_0.HumanoidRootPart.CFrame;
							local v2270 = l_l_EmoteKick3_2_0.mesh:Clone();
							v2270.CFrame = l_CFrame_27 * CFrame.new(0, 0, -9 + v2268) * l_v2262_0;
							local v2271 = l_l_EmoteKick3_2_0.WindSwirl:Clone();
							v2271.CFrame = l_CFrame_27 * CFrame.new(0, 0, -1.5 + v2268) * CFrame.Angles(1.5707963267948966, math.random(-3, 3), 0);
							v2270.Parent = l_VFX_0;
							v2271.Parent = l_VFX_0;
							Wind1(v2270, v2267, -0.75, "Y", "Y", false, false, true);
							Wind7(v2271, 0.35 * v2267, 1, "Y", "Y", "Y", false, false, true, false);
							l_Debris_0.AddItem(v2270, 3);
							l_Debris_0.AddItem(v2271, 3);
							return;
						end;
					end)(1.35, -18);
					local v2272 = l_Obliteration_2.Container.Kick3:Clone();
					v2272.Parent = l_T_6.HumanoidRootPart;
					local v2273 = l_Obliteration_2.Container.Torso:Clone();
					v2273.Parent = l_T_6.Torso;
					VFXService.EmitParticlesInInstance(v2272);
					VFXService.EmitParticlesInInstance(v2273);
					l_Debris_0.AddItem(v2272, 3.5);
					l_Debris_0.AddItem(v2273, 3.5);
				end;
			end;
		elseif l_Request_1 == "ObliterationSlash1" then
			local l_Debris_0 = require(game.ReplicatedStorage.Modules.Debris)
			local l_U_27 = v777.Emeny
			if l_U_27 == nil or l_U_27.Parent == nil then
				return;
			else
				local l_T_7 = v777.Emeny
				if l_T_7 == nil or l_T_7.Parent == nil then
					return;
				else
					local l_Obliteration_3 = l_Assets_0.Particles.Emotes.Obliteration;
					local _ = l_Obliteration_3.Kick;
					local l_EmoteKick3_3 = l_Obliteration_3.EmoteKick3;
					local v2279 = CFrame.Angles(1.5707963267948966, 0, 0);
					local l_l_U_27_0 = l_U_27 --[[ copy: 2 -> 1417 ]];
					local l_l_T_7_0 = l_T_7 --[[ copy: 3 -> 1418 ]];
					local l_l_EmoteKick3_3_0 = l_EmoteKick3_3 --[[ copy: 6 -> 1419 ]];
					local l_v2279_0 = v2279 --[[ copy: 7 -> 1420 ]];
					(function(v2284, v2285) --[[ Line: 8057 ]] --[[ Name: MovePreset ]]
						-- upvalues: l_l_U_27_0 (copy), l_l_T_7_0 (copy), l_l_EmoteKick3_3_0 (copy), l_v2279_0 (copy), l_VFX_0 (ref), l_Debris_0 (ref)
						if l_l_U_27_0 == nil or l_l_U_27_0.Parent == nil or l_l_T_7_0 == nil or l_l_T_7_0.Parent == nil then
							return;
						else
							local l_CFrame_28 = l_l_U_27_0.HumanoidRootPart.CFrame;
							local v2287 = l_l_EmoteKick3_3_0.mesh:Clone();
							v2287.CFrame = l_CFrame_28 * CFrame.new(0, 0, -9 + v2285) * l_v2279_0;
							local v2288 = l_l_EmoteKick3_3_0.WindSwirl:Clone();
							v2288.CFrame = l_CFrame_28 * CFrame.new(0, 0, -1.5 + v2285) * CFrame.Angles(1.5707963267948966, math.random(-3, 3), 0);
							v2287.Parent = l_VFX_0;
							v2288.Parent = l_VFX_0;
							Wind1(v2287, v2284, -0.75, "Y", "Y", false, false, true);
							Wind7(v2288, 0.35 * v2284, 1, "Y", "Y", "Y", false, false, true, false);
							l_Debris_0.AddItem(v2287, 3);
							l_Debris_0.AddItem(v2288, 3);
							return;
						end;
					end)(2, -12);
					local v2289 = l_Obliteration_3.Container.Slash1:Clone();
					v2289.Parent = l_T_7.HumanoidRootPart;
					VFXService.EmitParticlesInInstance(v2289);
					l_Debris_0.AddItem(v2289, 3.8);
				end;
			end;
		elseif l_Request_1 == "ObliterationSwordSpin" then
			local l_Debris_0 = require(game.ReplicatedStorage.Modules.Debris)
			local l_U_28 = v777.Char
			if l_U_28 == nil or l_U_28.Parent == nil then
				return;
			else
				local l_Obliteration_4 = l_Assets_0.Particles.Emotes.Obliteration;
				local l_EmoteSwordSpin_0 = l_Obliteration_4.EmoteSwordSpin;
				local v2293 = TweenInfo.new(0.075, Enum.EasingStyle.Quad, Enum.EasingDirection.In);
				local v2294 = TweenInfo.new(0.175, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
				local v2295 = {
					Width0 = 0, 
					Width1 = 0
				};
				local function v2300(v2296, v2297) --[[ Line: 8096 ]] --[[ Name: ScaleTo ]]
					for _, v2299 in pairs(v2297:GetDescendants()) do
						if v2299:IsA("Beam") then
							v2299.Width0 = v2299.Width0 * v2296;
							v2299.Width1 = v2299.Width1 * v2296;
						end;
					end;
				end;
				local l_l_EmoteSwordSpin_0_0 = l_EmoteSwordSpin_0 --[[ copy: 4 -> 1403 ]];
				local l_v2300_0 = v2300 --[[ copy: 8 -> 1404 ]];
				local l_v2293_0 = v2293 --[[ copy: 5 -> 1405 ]];
				local l_v2295_0 = v2295 --[[ copy: 7 -> 1406 ]];
				local l_v2294_0 = v2294 --[[ copy: 6 -> 1407 ]];
				local function v2311(v2306) --[[ Line: 8105 ]] --[[ Name: RandomBeamsSlash ]]
					-- upvalues: l_l_EmoteSwordSpin_0_0 (copy), l_v2300_0 (copy), l_VFX_0 (ref), l_TweenService_0 (ref), l_v2293_0 (copy), l_v2295_0 (copy), l_v2294_0 (copy), l_Debris_0 (ref)
					local v2307 = math.random(-7, 7);
					local v2308 = math.random(-360, 360);
					local v2309 = math.random(-7, 7);
					local v2310 = l_l_EmoteSwordSpin_0_0.BeamSlash:Clone();
					v2310.CFrame = v2306 * CFrame.Angles(1.5707963267948966 + math.rad(v2307), math.rad(v2308), (math.rad(v2309)));
					l_v2300_0(1.25, v2310);
					v2310.Parent = l_VFX_0;
					l_TweenService_0:Create(v2310.Beam, l_v2293_0, l_v2295_0):Play();
					l_TweenService_0:Create(v2310.Attachment, l_v2294_0, {
						Orientation = v2310.Attachment.Orientation + Vector3.new(0, math.random(90, 180), 0)
					}):Play();
					l_Debris_0.AddItem(v2310, 0.4);
				end;
				local v2312 = CFrame.new(0, 1, -35);
				local v2313 = CFrame.new(0, 3, -35);
				local v2314 = CFrame.new(0, -1, -35);
				local l_l_U_28_0 = l_U_28 --[[ copy: 2 -> 1408 ]];
				local l_v2312_0 = v2312 --[[ copy: 10 -> 1409 ]];
				local l_v2313_0 = v2313 --[[ copy: 11 -> 1410 ]];
				local l_v2314_0 = v2314 --[[ copy: 12 -> 1411 ]];
				local function v2326() --[[ Line: 8119 ]] --[[ Name: MeshPreset2 ]]
					-- upvalues: l_l_U_28_0 (copy), l_l_EmoteSwordSpin_0_0 (copy), l_v2312_0 (copy), l_v2313_0 (copy), l_v2314_0 (copy), l_v2300_0 (copy), l_VFX_0 (ref), l_Debris_0 (ref)
					local l_CFrame_29 = l_l_U_28_0.HumanoidRootPart.CFrame;
					local _ = math.rad((math.random(-180, 180)));
					local v2321 = l_l_EmoteSwordSpin_0_0.LightWind1:Clone();
					local v2322 = l_CFrame_29 * l_v2312_0;
					v2321.CFrame = v2322;
					local v2323 = l_l_EmoteSwordSpin_0_0.GroundSw:Clone();
					v2323.CFrame = v2322;
					local v2324 = l_l_EmoteSwordSpin_0_0.ring:Clone();
					v2324.CFrame = l_CFrame_29 * l_v2313_0;
					local v2325 = l_l_EmoteSwordSpin_0_0.mesh2:Clone();
					v2325.CFrame = l_CFrame_29 * l_v2314_0;
					l_v2300_0(1.5, v2321);
					l_v2300_0(1.5, v2323);
					l_v2300_0(1.5, v2324);
					l_v2300_0(1.5, v2325);
					v2321.Parent = l_VFX_0;
					v2323.Parent = l_VFX_0;
					v2324.Parent = l_VFX_0;
					v2325.Parent = l_VFX_0;
					Wind1(v2321, 0.3, 0.5, "Y", "Y", false, false, true);
					Wind4(v2323, 6, 1, "Y", false, false, true);
					Wind1(v2324, 0.7, 0.5, "Y", "Y", true, true, true);
					Wind1(v2325, 2.9, 0.75, "Y", "Y", false, false, true);
					l_Debris_0.AddItem(v2321, 3.5);
					l_Debris_0.AddItem(v2323, 3.5);
					l_Debris_0.AddItem(v2324, 3.5);
					l_Debris_0.AddItem(v2325, 3.5);
				end;
				local v2327 = nil;
				local v2328 = l_Obliteration_4.Container.SwordSpin:Clone();
				v2328.Parent = l_U_28.HumanoidRootPart;
				local l_v2328_0 = v2328 --[[ copy: 15 -> 1412 ]];
				local l_v2311_0 = v2311 --[[ copy: 9 -> 1413 ]];
				do
					local l_v2327_0 = v2327;
					local function v2332() --[[ Line: 8160 ]] --[[ Name: Function2 ]]
						-- upvalues: l_l_U_28_0 (copy), l_v2328_0 (copy), l_v2327_0 (ref), l_v2311_0 (copy)
						if l_l_U_28_0 == nil or l_l_U_28_0.Parent == nil or l_v2328_0 == nil or l_v2328_0.Parent == nil then
							pcall(function() --[[ Line: 8162 ]]
								-- upvalues: l_v2327_0 (ref)
								task.cancel(l_v2327_0);
							end);
							l_v2327_0 = nil;
							return;
						else
							l_v2311_0(l_l_U_28_0.HumanoidRootPart.SwordSpin.WorldCFrame);
							return;
						end;
					end;
					local l_v2326_0 = v2326 --[[ copy: 13 -> 1414 ]];
					local function v2334() --[[ Line: 8171 ]] --[[ Name: Function1 ]]
						-- upvalues: l_l_U_28_0 (copy), l_v2328_0 (copy), l_v2327_0 (ref), l_v2326_0 (copy)
						if l_l_U_28_0 == nil or l_l_U_28_0.Parent == nil or l_v2328_0 == nil or l_v2328_0.Parent == nil then
							pcall(function() --[[ Line: 8173 ]]
								-- upvalues: l_v2327_0 (ref)
								task.cancel(l_v2327_0);
							end);
							l_v2327_0 = nil;
							return;
						else
							l_v2326_0(-35);
							return;
						end;
					end;
					local l_v2334_0 = v2334 --[[ copy: 17 -> 1415 ]];
					local l_v2332_0 = v2332 --[[ copy: 16 -> 1416 ]];
					l_v2327_0 = task.spawn(function() --[[ Line: 8182 ]]
						-- upvalues: l_v2334_0 (copy), l_v2332_0 (copy)
						local v2337 = 0;
						while true do
							v2337 = v2337 + 1;
							if v2337 % 3 == 0 then
								task.spawn(l_v2334_0);
							end;
							if v2337 % 1 == 0 then
								task.spawn(l_v2332_0);
							end;
							if v2337 >= 4 then
								v2337 = 0;
							end;
							task.wait(0.05);
						end;
					end);
					local v2340 = VFXService.CreateBind(l_U_28, "ObliterationSwordSpin", function() --[[ Line: 8199 ]]
						-- upvalues: l_v2327_0 (ref), l_v2328_0 (copy)
						pcall(function() --[[ Line: 8200 ]]
							-- upvalues: l_v2327_0 (ref)
							task.cancel(l_v2327_0);
						end);
						l_v2327_0 = nil;
						if l_v2328_0 ~= nil and l_v2328_0.Parent ~= nil then
							for _, v2339 in pairs(l_v2328_0:GetDescendants()) do
								if v2339:IsA("ParticleEmitter") then
									v2339.Enabled = false;
								end;
							end;
						end;
					end);
					l_Debris_0.AddItem(v2340, 0.56);
					VFXService.EmitParticlesInInstance(v2328);
					l_Debris_0.AddItem(v2328, 4.2);
				end;
			end;
		elseif l_Request_1 == "ObliterationSlash2" then
			local l_Debris_0 = require(game.ReplicatedStorage.Modules.Debris)
			local l_U_29 = v777.Emeny
			if l_U_29 == nil or l_U_29.Parent == nil then
				return;
			else
				local l_T_8 = v777.Emeny
				if l_T_8 == nil or l_T_8.Parent == nil then
					return;
				else
					local l_Obliteration_5 = l_Assets_0.Particles.Emotes.Obliteration;
					local l_EmoteSwordSpin_1 = l_Obliteration_5.EmoteSwordSpin;
					local l_EmoteKick3_4 = l_Obliteration_5.EmoteKick3;
					local function _(v2346, v2347) --[[ Line: 8232 ]] --[[ Name: ScaleTo ]]
						-- upvalues: l_VFX_0 (ref)
						local l_Model_1 = Instance.new("Model");
						l_Model_1.Parent = l_VFX_0;
						local l_Parent_0 = v2347.Parent;
						v2347.Parent = l_Model_1;
						l_Model_1:ScaleTo(v2346);
						v2347.Parent = l_Parent_0;
						l_Model_1:Destroy();
					end;
					local function v2355(v2351, v2352) --[[ Line: 8242 ]] --[[ Name: Multiply ]]
						for _, v2354 in pairs(v2351:GetDescendants()) do
							if v2354:IsA("Beam") then
								v2354.Width0 = v2354.Width0 * v2352;
								v2354.Width1 = v2354.Width1 * v2352;
							end;
						end;
					end;
					local v2356 = {
						Width0 = 0, 
						Width1 = 0
					};
					local v2357 = CFrame.new(0, 0, -2);
					local l_l_U_29_0 = l_U_29 --[[ copy: 2 -> 1394 ]];
					local l_l_T_8_0 = l_T_8 --[[ copy: 3 -> 1395 ]];
					local l_l_Obliteration_5_0 = l_Obliteration_5 --[[ copy: 4 -> 1396 ]];
					local l_v2357_0 = v2357 --[[ copy: 10 -> 1397 ]];
					local l_l_EmoteSwordSpin_1_0 = l_EmoteSwordSpin_1 --[[ copy: 5 -> 1398 ]];
					local l_v2355_0 = v2355 --[[ copy: 8 -> 1399 ]];
					local l_v2356_0 = v2356 --[[ copy: 9 -> 1400 ]];
					local function v2375(v2365, v2366, v2367, v2368) --[[ Line: 8253 ]] --[[ Name: Slashes ]]
						-- upvalues: l_l_U_29_0 (copy), l_l_T_8_0 (copy), l_l_Obliteration_5_0 (copy), l_v2357_0 (copy), l_VFX_0 (ref), l_l_EmoteSwordSpin_1_0 (copy), l_v2355_0 (copy), l_TweenService_0 (ref), l_v2356_0 (copy), l_Debris_0 (ref)
						if l_l_U_29_0 == nil or l_l_U_29_0.Parent == nil or l_l_T_8_0 == nil or l_l_T_8_0.Parent == nil then
							return;
						else
							local v2369 = l_l_Obliteration_5_0.Slash:Clone();
							v2369.CFrame = v2365 * l_v2357_0;
							if not v2368 then
								local l_Model_2 = Instance.new("Model");
								l_Model_2.Parent = l_VFX_0;
								local l_Parent_1 = v2369.Parent;
								v2369.Parent = l_Model_2;
								l_Model_2:ScaleTo(0.75);
								v2369.Parent = l_Parent_1;
								l_Model_2:Destroy();
							end;
							v2369.Parent = l_VFX_0;
							local v2372 = l_l_EmoteSwordSpin_1_0.BeamSlash:Clone();
							v2372.CFrame = v2365;
							local l_Model_3 = Instance.new("Model");
							l_Model_3.Parent = l_VFX_0;
							local l_Parent_2 = v2372.Parent;
							v2372.Parent = l_Model_3;
							l_Model_3:ScaleTo(0.75);
							v2372.Parent = l_Parent_2;
							l_Model_3:Destroy();
							l_v2355_0(v2372, 2);
							v2372.Parent = l_VFX_0;
							VFXService.EmitParticlesInInstance(v2369);
							l_TweenService_0:Create(v2372.Beam, TweenInfo.new(0.075 * v2366, Enum.EasingStyle.Quad, Enum.EasingDirection.In), l_v2356_0):Play();
							l_TweenService_0:Create(v2372.Attachment, TweenInfo.new(0.175 * v2366, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
								Orientation = v2372.Attachment.Orientation + Vector3.new(0, v2367, 0)
							}):Play();
							l_Debris_0.AddItem(v2369, 3);
							l_Debris_0.AddItem(v2372, 3);
							return;
						end;
					end;
					local v2376 = CFrame.Angles(1.5707963267948966, 0, 0);
					local l_l_EmoteKick3_4_0 = l_EmoteKick3_4 --[[ copy: 6 -> 1401 ]];
					local l_v2376_0 = v2376 --[[ copy: 12 -> 1402 ]];
					local function v2384(v2379, v2380, v2381) --[[ Line: 8275 ]] --[[ Name: MovePreset2 ]]
						-- upvalues: l_l_U_29_0 (copy), l_l_T_8_0 (copy), l_l_EmoteKick3_4_0 (copy), l_v2376_0 (copy), l_VFX_0 (ref), l_Debris_0 (ref)
						if l_l_U_29_0 == nil or l_l_U_29_0.Parent == nil or l_l_T_8_0 == nil or l_l_T_8_0.Parent == nil then
							return;
						else
							local v2382 = l_l_EmoteKick3_4_0.mesh:Clone();
							v2382.CFrame = v2379 * CFrame.new(0, 0, -9 + v2381) * l_v2376_0;
							local v2383 = l_l_EmoteKick3_4_0.WindSwirl:Clone();
							v2383.CFrame = v2379 * CFrame.new(0, 0, -1.5 + v2381) * CFrame.Angles(1.5707963267948966, math.random(-3, 3), 0);
							v2382.Parent = l_VFX_0;
							v2383.Parent = l_VFX_0;
							Wind1(v2382, v2380, -0.75, "Y", "Y", false, false, true);
							Wind7(v2383, 0.35 * v2380, 1, "Y", "Y", "Y", false, false, true, false);
							l_Debris_0.AddItem(v2382, 3);
							l_Debris_0.AddItem(v2383, 3);
							return;
						end;
					end;
					local v2385 = CFrame.new(l_T_8.Torso.Position) * (l_U_29.HumanoidRootPart.CFrame - l_U_29.HumanoidRootPart.Position);
					v2375(v2385 * CFrame.new(0, 2, 2) * CFrame.Angles(0, 0, -1.5707963267948966), 2, 210, true);
					v2384(v2385 * CFrame.new(0, 0, 2) * CFrame.Angles(1.2217304763960306, 0, 0), 1, 0);
				end;
			end;
		elseif l_Request_1 == "ObliterationSlash3" then
			local l_Debris_0 = require(game.ReplicatedStorage.Modules.Debris)
		    local l_U_30 = v777.Char;
			if l_U_30 == nil or l_U_30.Parent == nil then
				return;
			else
				local l_T_9 = v777.Emeny
				if l_T_9 == nil or l_T_9.Parent == nil then
					return;
				else
					local l_Obliteration_6 = l_Assets_0.Particles.Emotes.Obliteration;
					local l_EmoteSwordSpin_2 = l_Obliteration_6.EmoteSwordSpin;
					local l_EmoteKick3_5 = l_Obliteration_6.EmoteKick3;
					local function _(v2391, v2392) --[[ Line: 8308 ]] --[[ Name: ScaleTo ]]
						-- upvalues: l_VFX_0 (ref)
						local l_Model_4 = Instance.new("Model");
						l_Model_4.Parent = l_VFX_0;
						local l_Parent_3 = v2392.Parent;
						v2392.Parent = l_Model_4;
						l_Model_4:ScaleTo(v2391);
						v2392.Parent = l_Parent_3;
						l_Model_4:Destroy();
					end;
					local function v2400(v2396, v2397) --[[ Line: 8318 ]] --[[ Name: Multiply ]]
						for _, v2399 in pairs(v2396:GetDescendants()) do
							if v2399:IsA("Beam") then
								v2399.Width0 = v2399.Width0 * v2397;
								v2399.Width1 = v2399.Width1 * v2397;
							end;
						end;
					end;
					local v2401 = {
						Width0 = 0, 
						Width1 = 0
					};
					local v2402 = CFrame.new(0, 0, -2);
					local l_l_U_30_0 = l_U_30 --[[ copy: 2 -> 1385 ]];
					local l_l_T_9_0 = l_T_9 --[[ copy: 3 -> 1386 ]];
					local l_l_Obliteration_6_0 = l_Obliteration_6 --[[ copy: 4 -> 1387 ]];
					local l_v2402_0 = v2402 --[[ copy: 10 -> 1388 ]];
					local l_l_EmoteSwordSpin_2_0 = l_EmoteSwordSpin_2 --[[ copy: 5 -> 1389 ]];
					local l_v2400_0 = v2400 --[[ copy: 8 -> 1390 ]];
					local l_v2401_0 = v2401 --[[ copy: 9 -> 1391 ]];
					local function v2420(v2410, v2411, v2412, v2413) --[[ Line: 8329 ]] --[[ Name: Slashes ]]
						-- upvalues: l_l_U_30_0 (copy), l_l_T_9_0 (copy), l_l_Obliteration_6_0 (copy), l_v2402_0 (copy), l_VFX_0 (ref), l_l_EmoteSwordSpin_2_0 (copy), l_v2400_0 (copy), l_TweenService_0 (ref), l_v2401_0 (copy), l_Debris_0 (ref)
						if l_l_U_30_0 == nil or l_l_U_30_0.Parent == nil or l_l_T_9_0 == nil or l_l_T_9_0.Parent == nil then
							return;
						else
							local v2414 = l_l_Obliteration_6_0.Slash:Clone();
							v2414.CFrame = v2410 * l_v2402_0;
							if not v2413 then
								local l_Model_5 = Instance.new("Model");
								l_Model_5.Parent = l_VFX_0;
								local l_Parent_4 = v2414.Parent;
								v2414.Parent = l_Model_5;
								l_Model_5:ScaleTo(0.75);
								v2414.Parent = l_Parent_4;
								l_Model_5:Destroy();
							end;
							v2414.Parent = l_VFX_0;
							local v2417 = l_l_EmoteSwordSpin_2_0.BeamSlash:Clone();
							v2417.CFrame = v2410;
							local l_Model_6 = Instance.new("Model");
							l_Model_6.Parent = l_VFX_0;
							local l_Parent_5 = v2417.Parent;
							v2417.Parent = l_Model_6;
							l_Model_6:ScaleTo(0.75);
							v2417.Parent = l_Parent_5;
							l_Model_6:Destroy();
							l_v2400_0(v2417, 2);
							v2417.Parent = l_VFX_0;
							VFXService.EmitParticlesInInstance(v2414);
							l_TweenService_0:Create(v2417.Beam, TweenInfo.new(0.075 * v2411, Enum.EasingStyle.Quad, Enum.EasingDirection.In), l_v2401_0):Play();
							l_TweenService_0:Create(v2417.Attachment, TweenInfo.new(0.175 * v2411, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
								Orientation = v2417.Attachment.Orientation + Vector3.new(0, v2412, 0)
							}):Play();
							l_Debris_0.AddItem(v2414, 3);
							l_Debris_0.AddItem(v2417, 3);
							return;
						end;
					end;
					local v2421 = CFrame.Angles(1.5707963267948966, 0, 0);
					local l_l_EmoteKick3_5_0 = l_EmoteKick3_5 --[[ copy: 6 -> 1392 ]];
					local l_v2421_0 = v2421 --[[ copy: 12 -> 1393 ]];
					local function v2429(v2424, v2425, v2426) --[[ Line: 8351 ]] --[[ Name: MovePreset2 ]]
						-- upvalues: l_l_U_30_0 (copy), l_l_T_9_0 (copy), l_l_EmoteKick3_5_0 (copy), l_v2421_0 (copy), l_VFX_0 (ref), l_Debris_0 (ref)
						if l_l_U_30_0 == nil or l_l_U_30_0.Parent == nil or l_l_T_9_0 == nil or l_l_T_9_0.Parent == nil then
							return;
						else
							local v2427 = l_l_EmoteKick3_5_0.mesh:Clone();
							v2427.CFrame = v2424 * CFrame.new(0, 0, -9 + v2426) * l_v2421_0;
							local v2428 = l_l_EmoteKick3_5_0.WindSwirl:Clone();
							v2428.CFrame = v2424 * CFrame.new(0, 0, -1.5 + v2426) * CFrame.Angles(1.5707963267948966, math.random(-3, 3), 0);
							v2427.Parent = l_VFX_0;
							v2428.Parent = l_VFX_0;
							Wind1(v2427, v2425, -0.75, "Y", "Y", false, false, true);
							Wind7(v2428, 0.35 * v2425, 1, "Y", "Y", "Y", false, false, true, false);
							l_Debris_0.AddItem(v2427, 3);
							l_Debris_0.AddItem(v2428, 3);
							return;
						end;
					end;
					local v2430 = CFrame.new(l_T_9.Torso.Position) * (l_U_30.HumanoidRootPart.CFrame - l_U_30.HumanoidRootPart.Position);
					v2420(v2430 * CFrame.new(0, 0, 2) * CFrame.Angles(0, 0, -1.5707963267948966), 2, 210);
					v2429(v2430 * CFrame.new(0, -5, 2) * CFrame.Angles(1.5707963267948966, 0, 0), 3, 0);
				end;
			end;
		elseif l_Request_1 == "ObliterationSlash4" then
			local l_Debris_0 = require(game.ReplicatedStorage.Modules.Debris)
			local l_U_31 = v777.Char
			if l_U_31 == nil or l_U_31.Parent == nil then
				return;
			else
				local l_T_10 = v777.Emeny
				if l_T_10 == nil or l_T_10.Parent == nil then
					return;
				else
					local l_Obliteration_7 = l_Assets_0.Particles.Emotes.Obliteration;
					local l_EmoteSwordSpin_3 = l_Obliteration_7.EmoteSwordSpin;
					local l_EmoteKick3_6 = l_Obliteration_7.EmoteKick3;
					local function _(v2436, v2437) --[[ Line: 8384 ]] --[[ Name: ScaleTo ]]
						-- upvalues: l_VFX_0 (ref)
						local l_Model_7 = Instance.new("Model");
						l_Model_7.Parent = l_VFX_0;
						local l_Parent_6 = v2437.Parent;
						v2437.Parent = l_Model_7;
						l_Model_7:ScaleTo(v2436);
						v2437.Parent = l_Parent_6;
						l_Model_7:Destroy();
					end;
					local function v2445(v2441, v2442) --[[ Line: 8394 ]] --[[ Name: Multiply ]]
						for _, v2444 in pairs(v2441:GetDescendants()) do
							if v2444:IsA("Beam") then
								v2444.Width0 = v2444.Width0 * v2442;
								v2444.Width1 = v2444.Width1 * v2442;
							end;
						end;
					end;
					local v2446 = {
						Width0 = 0, 
						Width1 = 0
					};
					local v2447 = CFrame.new(0, 0, -2);
					local l_l_U_31_0 = l_U_31 --[[ copy: 2 -> 1376 ]];
					local l_l_T_10_0 = l_T_10 --[[ copy: 3 -> 1377 ]];
					local l_l_Obliteration_7_0 = l_Obliteration_7 --[[ copy: 4 -> 1378 ]];
					local l_v2447_0 = v2447 --[[ copy: 10 -> 1379 ]];
					local l_l_EmoteSwordSpin_3_0 = l_EmoteSwordSpin_3 --[[ copy: 5 -> 1380 ]];
					local l_v2445_0 = v2445 --[[ copy: 8 -> 1381 ]];
					local l_v2446_0 = v2446 --[[ copy: 9 -> 1382 ]];
					local function v2465(v2455, v2456, v2457, v2458) --[[ Line: 8405 ]] --[[ Name: Slashes ]]
						-- upvalues: l_l_U_31_0 (copy), l_l_T_10_0 (copy), l_l_Obliteration_7_0 (copy), l_v2447_0 (copy), l_VFX_0 (ref), l_l_EmoteSwordSpin_3_0 (copy), l_v2445_0 (copy), l_TweenService_0 (ref), l_v2446_0 (copy), l_Debris_0 (ref)
						if l_l_U_31_0 == nil or l_l_U_31_0.Parent == nil or l_l_T_10_0 == nil or l_l_T_10_0.Parent == nil then
							return;
						else
							local v2459 = l_l_Obliteration_7_0.Slash:Clone();
							v2459.CFrame = v2455 * l_v2447_0;
							if not v2458 then
								local l_Model_8 = Instance.new("Model");
								l_Model_8.Parent = l_VFX_0;
								local l_Parent_7 = v2459.Parent;
								v2459.Parent = l_Model_8;
								l_Model_8:ScaleTo(0.75);
								v2459.Parent = l_Parent_7;
								l_Model_8:Destroy();
							end;
							v2459.Parent = l_VFX_0;
							local v2462 = l_l_EmoteSwordSpin_3_0.BeamSlash:Clone();
							v2462.CFrame = v2455;
							local l_Model_9 = Instance.new("Model");
							l_Model_9.Parent = l_VFX_0;
							local l_Parent_8 = v2462.Parent;
							v2462.Parent = l_Model_9;
							l_Model_9:ScaleTo(0.75);
							v2462.Parent = l_Parent_8;
							l_Model_9:Destroy();
							l_v2445_0(v2462, 2);
							v2462.Parent = l_VFX_0;
							VFXService.EmitParticlesInInstance(v2459);
							l_TweenService_0:Create(v2462.Beam, TweenInfo.new(0.075 * v2456, Enum.EasingStyle.Quad, Enum.EasingDirection.In), l_v2446_0):Play();
							l_TweenService_0:Create(v2462.Attachment, TweenInfo.new(0.175 * v2456, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
								Orientation = v2462.Attachment.Orientation + Vector3.new(0, v2457, 0)
							}):Play();
							l_Debris_0.AddItem(v2459, 3);
							l_Debris_0.AddItem(v2462, 3);
							return;
						end;
					end;
					local v2466 = CFrame.Angles(1.5707963267948966, 0, 0);
					local l_l_EmoteKick3_6_0 = l_EmoteKick3_6 --[[ copy: 6 -> 1383 ]];
					local l_v2466_0 = v2466 --[[ copy: 12 -> 1384 ]];
					local function v2474(v2469, v2470, v2471) --[[ Line: 8427 ]] --[[ Name: MovePreset2 ]]
						-- upvalues: l_l_U_31_0 (copy), l_l_T_10_0 (copy), l_l_EmoteKick3_6_0 (copy), l_v2466_0 (copy), l_VFX_0 (ref), l_Debris_0 (ref)
						if l_l_U_31_0 == nil or l_l_U_31_0.Parent == nil or l_l_T_10_0 == nil or l_l_T_10_0.Parent == nil then
							return;
						else
							local v2472 = l_l_EmoteKick3_6_0.mesh:Clone();
							v2472.CFrame = v2469 * CFrame.new(0, 0, -9 + v2471) * l_v2466_0;
							local v2473 = l_l_EmoteKick3_6_0.WindSwirl:Clone();
							v2473.CFrame = v2469 * CFrame.new(0, 0, -1.5 + v2471) * CFrame.Angles(1.5707963267948966, math.random(-3, 3), 0);
							v2472.Parent = l_VFX_0;
							v2473.Parent = l_VFX_0;
							Wind1(v2472, v2470, -0.75, "Y", "Y", false, false, true);
							Wind7(v2473, 0.35 * v2470, 1, "Y", "Y", "Y", false, false, true, false);
							l_Debris_0.AddItem(v2472, 3);
							l_Debris_0.AddItem(v2473, 3);
							return;
						end;
					end;
					local v2475 = CFrame.new(l_T_10.Torso.Position) * (l_U_31.HumanoidRootPart.CFrame - l_U_31.HumanoidRootPart.Position);
					v2465(v2475 * CFrame.new(0, 0, 2) * CFrame.Angles(0, 0, 1.5707963267948966), 2, 210);
					v2474(v2475 * CFrame.new(0, -5, 2) * CFrame.Angles(1.5707963267948966, 0, 0), 3, 0);
				end;
			end;
		elseif l_Request_1 == "ObliterationSlash5" then
			local l_Debris_0 = require(game.ReplicatedStorage.Modules.Debris)
			local l_U_32 = v777.Char
			if l_U_32 == nil or l_U_32.Parent == nil then
				return;
			else
				local l_T_11 = v777.Emeny
				if l_T_11 == nil or l_T_11.Parent == nil then
					return;
				else
					local l_Obliteration_8 = l_Assets_0.Particles.Emotes.Obliteration;
					local l_EmoteSwordSpin_4 = l_Obliteration_8.EmoteSwordSpin;
					local l_EmoteKick3_7 = l_Obliteration_8.EmoteKick3;
					local function _(v2481, v2482) --[[ Line: 8460 ]] --[[ Name: ScaleTo ]]
						-- upvalues: l_VFX_0 (ref)
						local l_Model_10 = Instance.new("Model");
						l_Model_10.Parent = l_VFX_0;
						local l_Parent_9 = v2482.Parent;
						v2482.Parent = l_Model_10;
						l_Model_10:ScaleTo(v2481);
						v2482.Parent = l_Parent_9;
						l_Model_10:Destroy();
					end;
					local function v2490(v2486, v2487) --[[ Line: 8470 ]] --[[ Name: Multiply ]]
						for _, v2489 in pairs(v2486:GetDescendants()) do
							if v2489:IsA("Beam") then
								v2489.Width0 = v2489.Width0 * v2487;
								v2489.Width1 = v2489.Width1 * v2487;
							end;
						end;
					end;
					local v2491 = {
						Width0 = 0, 
						Width1 = 0
					};
					local v2492 = CFrame.new(0, 0, -2);
					local l_l_U_32_0 = l_U_32 --[[ copy: 2 -> 1367 ]];
					local l_l_T_11_0 = l_T_11 --[[ copy: 3 -> 1368 ]];
					local l_l_Obliteration_8_0 = l_Obliteration_8 --[[ copy: 4 -> 1369 ]];
					local l_v2492_0 = v2492 --[[ copy: 10 -> 1370 ]];
					local l_l_EmoteSwordSpin_4_0 = l_EmoteSwordSpin_4 --[[ copy: 5 -> 1371 ]];
					local l_v2490_0 = v2490 --[[ copy: 8 -> 1372 ]];
					local l_v2491_0 = v2491 --[[ copy: 9 -> 1373 ]];
					local function v2510(v2500, v2501, v2502, v2503) --[[ Line: 8481 ]] --[[ Name: Slashes ]]
						-- upvalues: l_l_U_32_0 (copy), l_l_T_11_0 (copy), l_l_Obliteration_8_0 (copy), l_v2492_0 (copy), l_VFX_0 (ref), l_l_EmoteSwordSpin_4_0 (copy), l_v2490_0 (copy), l_TweenService_0 (ref), l_v2491_0 (copy), l_Debris_0 (ref)
						if l_l_U_32_0 == nil or l_l_U_32_0.Parent == nil or l_l_T_11_0 == nil or l_l_T_11_0.Parent == nil then
							return;
						else
							local v2504 = l_l_Obliteration_8_0.Slash:Clone();
							v2504.CFrame = v2500 * l_v2492_0;
							if not v2503 then
								local l_Model_11 = Instance.new("Model");
								l_Model_11.Parent = l_VFX_0;
								local l_Parent_10 = v2504.Parent;
								v2504.Parent = l_Model_11;
								l_Model_11:ScaleTo(0.75);
								v2504.Parent = l_Parent_10;
								l_Model_11:Destroy();
							end;
							v2504.Parent = l_VFX_0;
							local v2507 = l_l_EmoteSwordSpin_4_0.BeamSlash:Clone();
							v2507.CFrame = v2500;
							local l_Model_12 = Instance.new("Model");
							l_Model_12.Parent = l_VFX_0;
							local l_Parent_11 = v2507.Parent;
							v2507.Parent = l_Model_12;
							l_Model_12:ScaleTo(0.75);
							v2507.Parent = l_Parent_11;
							l_Model_12:Destroy();
							l_v2490_0(v2507, 2);
							v2507.Parent = l_VFX_0;
							VFXService.EmitParticlesInInstance(v2504);
							l_TweenService_0:Create(v2507.Beam, TweenInfo.new(0.075 * v2501, Enum.EasingStyle.Quad, Enum.EasingDirection.In), l_v2491_0):Play();
							l_TweenService_0:Create(v2507.Attachment, TweenInfo.new(0.175 * v2501, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
								Orientation = v2507.Attachment.Orientation + Vector3.new(0, v2502, 0)
							}):Play();
							l_Debris_0.AddItem(v2504, 3);
							l_Debris_0.AddItem(v2507, 3);
							return;
						end;
					end;
					local v2511 = CFrame.Angles(1.5707963267948966, 0, 0);
					local l_l_EmoteKick3_7_0 = l_EmoteKick3_7 --[[ copy: 6 -> 1374 ]];
					local l_v2511_0 = v2511 --[[ copy: 12 -> 1375 ]];
					local function v2519(v2514, v2515, v2516) --[[ Line: 8503 ]] --[[ Name: MovePreset2 ]]
						-- upvalues: l_l_U_32_0 (copy), l_l_T_11_0 (copy), l_l_EmoteKick3_7_0 (copy), l_v2511_0 (copy), l_VFX_0 (ref), l_Debris_0 (ref)
						if l_l_U_32_0 == nil or l_l_U_32_0.Parent == nil or l_l_T_11_0 == nil or l_l_T_11_0.Parent == nil then
							return;
						else
							local v2517 = l_l_EmoteKick3_7_0.mesh:Clone();
							v2517.CFrame = v2514 * CFrame.new(0, 0, -9 + v2516) * l_v2511_0;
							local v2518 = l_l_EmoteKick3_7_0.WindSwirl:Clone();
							v2518.CFrame = v2514 * CFrame.new(0, 0, -1.5 + v2516) * CFrame.Angles(1.5707963267948966, math.random(-3, 3), 0);
							v2517.Parent = l_VFX_0;
							v2518.Parent = l_VFX_0;
							Wind1(v2517, v2515, -0.75, "Y", "Y", false, false, true);
							Wind7(v2518, 0.35 * v2515, 1, "Y", "Y", "Y", false, false, true, false);
							l_Debris_0.AddItem(v2517, 3);
							l_Debris_0.AddItem(v2518, 3);
							return;
						end;
					end;
					local v2520 = CFrame.new(l_T_11.Torso.Position) * (l_U_32.HumanoidRootPart.CFrame - l_U_32.HumanoidRootPart.Position);
					v2510(v2520 * CFrame.new(0, 0, 2) * CFrame.Angles(0, 0, -3.141592653589793), 2, 210);
					v2519(v2520 * CFrame.new(0, -5, 2) * CFrame.Angles(1.5707963267948966, 0, 0), 3, 0);
				end;
			end;
		elseif l_Request_1 == "ObliterationSlash6" then
			local l_Debris_0 = require(game.ReplicatedStorage.Modules.Debris)
			local l_U_33 = v777.Char
			if l_U_33 == nil or l_U_33.Parent == nil then
				return;
			else
				local l_T_12 = v777.Emeny
				if l_T_12 == nil or l_T_12.Parent == nil then
					return;
				else
					local l_Obliteration_9 = l_Assets_0.Particles.Emotes.Obliteration;
					local l_EmoteSwordSpin_5 = l_Obliteration_9.EmoteSwordSpin;
					local l_EmoteKick3_8 = l_Obliteration_9.EmoteKick3;
					local function _(v2526, v2527) --[[ Line: 8536 ]] --[[ Name: ScaleTo ]]
						-- upvalues: l_VFX_0 (ref)
						local l_Model_13 = Instance.new("Model");
						l_Model_13.Parent = l_VFX_0;
						local l_Parent_12 = v2527.Parent;
						v2527.Parent = l_Model_13;
						l_Model_13:ScaleTo(v2526);
						v2527.Parent = l_Parent_12;
						l_Model_13:Destroy();
					end;
					local function v2535(v2531, v2532) --[[ Line: 8546 ]] --[[ Name: Multiply ]]
						for _, v2534 in pairs(v2531:GetDescendants()) do
							if v2534:IsA("Beam") then
								v2534.Width0 = v2534.Width0 * v2532;
								v2534.Width1 = v2534.Width1 * v2532;
							end;
						end;
					end;
					local v2536 = {
						Width0 = 0, 
						Width1 = 0
					};
					local v2537 = CFrame.new(0, 0, -2);
					local l_l_U_33_0 = l_U_33 --[[ copy: 2 -> 1358 ]];
					local l_l_T_12_0 = l_T_12 --[[ copy: 3 -> 1359 ]];
					local l_l_Obliteration_9_0 = l_Obliteration_9 --[[ copy: 4 -> 1360 ]];
					local l_v2537_0 = v2537 --[[ copy: 10 -> 1361 ]];
					local l_l_EmoteSwordSpin_5_0 = l_EmoteSwordSpin_5 --[[ copy: 5 -> 1362 ]];
					local l_v2535_0 = v2535 --[[ copy: 8 -> 1363 ]];
					local l_v2536_0 = v2536 --[[ copy: 9 -> 1364 ]];
					local function v2555(v2545, v2546, v2547, v2548) --[[ Line: 8557 ]] --[[ Name: Slashes ]]
						-- upvalues: l_l_U_33_0 (copy), l_l_T_12_0 (copy), l_l_Obliteration_9_0 (copy), l_v2537_0 (copy), l_VFX_0 (ref), l_l_EmoteSwordSpin_5_0 (copy), l_v2535_0 (copy), l_TweenService_0 (ref), l_v2536_0 (copy), l_Debris_0 (ref)
						if l_l_U_33_0 == nil or l_l_U_33_0.Parent == nil or l_l_T_12_0 == nil or l_l_T_12_0.Parent == nil then
							return;
						else
							local v2549 = l_l_Obliteration_9_0.Slash:Clone();
							v2549.CFrame = v2545 * l_v2537_0;
							if not v2548 then
								local l_Model_14 = Instance.new("Model");
								l_Model_14.Parent = l_VFX_0;
								local l_Parent_13 = v2549.Parent;
								v2549.Parent = l_Model_14;
								l_Model_14:ScaleTo(0.75);
								v2549.Parent = l_Parent_13;
								l_Model_14:Destroy();
							end;
							v2549.Parent = l_VFX_0;
							local v2552 = l_l_EmoteSwordSpin_5_0.BeamSlash:Clone();
							v2552.CFrame = v2545;
							local l_Model_15 = Instance.new("Model");
							l_Model_15.Parent = l_VFX_0;
							local l_Parent_14 = v2552.Parent;
							v2552.Parent = l_Model_15;
							l_Model_15:ScaleTo(0.75);
							v2552.Parent = l_Parent_14;
							l_Model_15:Destroy();
							l_v2535_0(v2552, 2);
							v2552.Parent = l_VFX_0;
							VFXService.EmitParticlesInInstance(v2549);
							l_TweenService_0:Create(v2552.Beam, TweenInfo.new(0.075 * v2546, Enum.EasingStyle.Quad, Enum.EasingDirection.In), l_v2536_0):Play();
							l_TweenService_0:Create(v2552.Attachment, TweenInfo.new(0.175 * v2546, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
								Orientation = v2552.Attachment.Orientation + Vector3.new(0, v2547, 0)
							}):Play();
							l_Debris_0.AddItem(v2549, 3);
							l_Debris_0.AddItem(v2552, 3);
							return;
						end;
					end;
					local v2556 = CFrame.Angles(1.5707963267948966, 0, 0);
					local l_l_EmoteKick3_8_0 = l_EmoteKick3_8 --[[ copy: 6 -> 1365 ]];
					local l_v2556_0 = v2556 --[[ copy: 12 -> 1366 ]];
					local function v2564(v2559, v2560, v2561) --[[ Line: 8579 ]] --[[ Name: MovePreset2 ]]
						-- upvalues: l_l_U_33_0 (copy), l_l_T_12_0 (copy), l_l_EmoteKick3_8_0 (copy), l_v2556_0 (copy), l_VFX_0 (ref), l_Debris_0 (ref)
						if l_l_U_33_0 == nil or l_l_U_33_0.Parent == nil or l_l_T_12_0 == nil or l_l_T_12_0.Parent == nil then
							return;
						else
							local v2562 = l_l_EmoteKick3_8_0.mesh:Clone();
							v2562.CFrame = v2559 * CFrame.new(0, 0, -9 + v2561) * l_v2556_0;
							local v2563 = l_l_EmoteKick3_8_0.WindSwirl:Clone();
							v2563.CFrame = v2559 * CFrame.new(0, 0, -1.5 + v2561) * CFrame.Angles(1.5707963267948966, math.random(-3, 3), 0);
							v2562.Parent = l_VFX_0;
							v2563.Parent = l_VFX_0;
							Wind1(v2562, v2560, -0.75, "Y", "Y", false, false, true);
							Wind7(v2563, 0.35 * v2560, 1, "Y", "Y", "Y", false, false, true, false);
							l_Debris_0.AddItem(v2562, 3);
							l_Debris_0.AddItem(v2563, 3);
							return;
						end;
					end;
					local v2565 = CFrame.new(l_T_12.Torso.Position) * (l_U_33.HumanoidRootPart.CFrame - l_U_33.HumanoidRootPart.Position);
					v2555(v2565 * CFrame.new(0, 0, 2), 2, 210);
					v2564(v2565 * CFrame.new(0, -5, 2) * CFrame.Angles(1.5707963267948966, 0, 0), 3, 0);
				end;
			end;
		elseif l_Request_1 == "ObliterationSlash7" then
			local l_Debris_0 = require(game.ReplicatedStorage.Modules.Debris)
			local l_U_34 = v777.Char
			if l_U_34 == nil or l_U_34.Parent == nil then
				return;
			else
				local l_T_13 = v777.Emeny
				if l_T_13 == nil or l_T_13.Parent == nil then
					return;
				else
					local l_Obliteration_10 = l_Assets_0.Particles.Emotes.Obliteration;
					local l_EmoteSwordSpin_6 = l_Obliteration_10.EmoteSwordSpin;
					local l_EmoteKick3_9 = l_Obliteration_10.EmoteKick3;
					local function _(v2571, v2572) --[[ Line: 8612 ]] --[[ Name: ScaleTo ]]
						-- upvalues: l_VFX_0 (ref)
						local l_Model_16 = Instance.new("Model");
						l_Model_16.Parent = l_VFX_0;
						local l_Parent_15 = v2572.Parent;
						v2572.Parent = l_Model_16;
						l_Model_16:ScaleTo(v2571);
						v2572.Parent = l_Parent_15;
						l_Model_16:Destroy();
					end;
					local function v2580(v2576, v2577) --[[ Line: 8622 ]] --[[ Name: Multiply ]]
						for _, v2579 in pairs(v2576:GetDescendants()) do
							if v2579:IsA("Beam") then
								v2579.Width0 = v2579.Width0 * v2577;
								v2579.Width1 = v2579.Width1 * v2577;
							end;
						end;
					end;
					local v2581 = {
						Width0 = 0, 
						Width1 = 0
					};
					local v2582 = CFrame.new(0, 0, -2);
					local l_l_U_34_0 = l_U_34 --[[ copy: 2 -> 1349 ]];
					local l_l_T_13_0 = l_T_13 --[[ copy: 3 -> 1350 ]];
					local l_l_Obliteration_10_0 = l_Obliteration_10 --[[ copy: 4 -> 1351 ]];
					local l_v2582_0 = v2582 --[[ copy: 10 -> 1352 ]];
					local l_l_EmoteSwordSpin_6_0 = l_EmoteSwordSpin_6 --[[ copy: 5 -> 1353 ]];
					local l_v2580_0 = v2580 --[[ copy: 8 -> 1354 ]];
					local l_v2581_0 = v2581 --[[ copy: 9 -> 1355 ]];
					local function v2600(v2590, v2591, v2592, v2593) --[[ Line: 8633 ]] --[[ Name: Slashes ]]
						-- upvalues: l_l_U_34_0 (copy), l_l_T_13_0 (copy), l_l_Obliteration_10_0 (copy), l_v2582_0 (copy), l_VFX_0 (ref), l_l_EmoteSwordSpin_6_0 (copy), l_v2580_0 (copy), l_TweenService_0 (ref), l_v2581_0 (copy), l_Debris_0 (ref)
						if l_l_U_34_0 == nil or l_l_U_34_0.Parent == nil or l_l_T_13_0 == nil or l_l_T_13_0.Parent == nil then
							return;
						else
							local v2594 = l_l_Obliteration_10_0.Slash:Clone();
							v2594.CFrame = v2590 * l_v2582_0;
							if not v2593 then
								local l_Model_17 = Instance.new("Model");
								l_Model_17.Parent = l_VFX_0;
								local l_Parent_16 = v2594.Parent;
								v2594.Parent = l_Model_17;
								l_Model_17:ScaleTo(0.75);
								v2594.Parent = l_Parent_16;
								l_Model_17:Destroy();
							end;
							v2594.Parent = l_VFX_0;
							local v2597 = l_l_EmoteSwordSpin_6_0.BeamSlash:Clone();
							v2597.CFrame = v2590;
							local l_Model_18 = Instance.new("Model");
							l_Model_18.Parent = l_VFX_0;
							local l_Parent_17 = v2597.Parent;
							v2597.Parent = l_Model_18;
							l_Model_18:ScaleTo(0.75);
							v2597.Parent = l_Parent_17;
							l_Model_18:Destroy();
							l_v2580_0(v2597, 2);
							v2597.Parent = l_VFX_0;
							VFXService.EmitParticlesInInstance(v2594);
							l_TweenService_0:Create(v2597.Beam, TweenInfo.new(0.075 * v2591, Enum.EasingStyle.Quad, Enum.EasingDirection.In), l_v2581_0):Play();
							l_TweenService_0:Create(v2597.Attachment, TweenInfo.new(0.175 * v2591, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
								Orientation = v2597.Attachment.Orientation + Vector3.new(0, v2592, 0)
							}):Play();
							l_Debris_0.AddItem(v2594, 3);
							l_Debris_0.AddItem(v2597, 3);
							return;
						end;
					end;
					local v2601 = CFrame.Angles(1.5707963267948966, 0, 0);
					local l_l_EmoteKick3_9_0 = l_EmoteKick3_9 --[[ copy: 6 -> 1356 ]];
					local l_v2601_0 = v2601 --[[ copy: 12 -> 1357 ]];
					local function v2609(v2604, v2605, v2606) --[[ Line: 8655 ]] --[[ Name: MovePreset2 ]]
						-- upvalues: l_l_U_34_0 (copy), l_l_T_13_0 (copy), l_l_EmoteKick3_9_0 (copy), l_v2601_0 (copy), l_VFX_0 (ref), l_Debris_0 (ref)
						if l_l_U_34_0 == nil or l_l_U_34_0.Parent == nil or l_l_T_13_0 == nil or l_l_T_13_0.Parent == nil then
							return;
						else
							local v2607 = l_l_EmoteKick3_9_0.mesh:Clone();
							v2607.CFrame = v2604 * CFrame.new(0, 0, -9 + v2606) * l_v2601_0;
							local v2608 = l_l_EmoteKick3_9_0.WindSwirl:Clone();
							v2608.CFrame = v2604 * CFrame.new(0, 0, -1.5 + v2606) * CFrame.Angles(1.5707963267948966, math.random(-3, 3), 0);
							v2607.Parent = l_VFX_0;
							v2608.Parent = l_VFX_0;
							Wind1(v2607, v2605, -0.75, "Y", "Y", false, false, true);
							Wind7(v2608, 0.35 * v2605, 1, "Y", "Y", "Y", false, false, true, false);
							l_Debris_0.AddItem(v2607, 3);
							l_Debris_0.AddItem(v2608, 3);
							return;
						end;
					end;
					local v2610 = CFrame.new(l_T_13.Torso.Position) * (l_U_34.HumanoidRootPart.CFrame - l_U_34.HumanoidRootPart.Position);
					v2600(v2610 * CFrame.new(0, 0, 2) * CFrame.Angles(0, 0, -1.5707963267948966), 2, 210);
					v2609(v2610 * CFrame.new(0, -5, 2) * CFrame.Angles(1.5707963267948966, 0, 0), 3, 0);
				end;
			end;
		elseif l_Request_1 == "ObliterationSpinDrop" then
			local l_Debris_0 = require(game.ReplicatedStorage.Modules.Debris)
			local l_U_35 = v777.Char
			if l_U_35 == nil or l_U_35.Parent == nil then
				return;
			else
				local l_T_14 = v777.Emeny
				if l_T_14 == nil or l_T_14.Parent == nil then
					return;
				else
					local l_Obliteration_11 = l_Assets_0.Particles.Emotes.Obliteration;
					local l_EmoteSwordSpin_7 = l_Obliteration_11.EmoteSwordSpin;
					local l_EmoteKick3_10 = l_Obliteration_11.EmoteKick3;
					local v2616 = TweenInfo.new(0.075, Enum.EasingStyle.Quad, Enum.EasingDirection.In);
					local v2617 = TweenInfo.new(0.175, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
					local v2618 = {
						Width0 = 0, 
						Width1 = 0
					};
					local function v2623(v2619, v2620) --[[ Line: 8693 ]] --[[ Name: ScaleTo ]]
						for _, v2622 in pairs(v2620:GetDescendants()) do
							if v2622:IsA("Beam") then
								v2622.Width0 = v2622.Width0 * v2619;
								v2622.Width1 = v2622.Width1 * v2619;
							end;
						end;
					end;
					local l_l_EmoteSwordSpin_7_0 = l_EmoteSwordSpin_7 --[[ copy: 5 -> 1332 ]];
					local l_v2623_0 = v2623 --[[ copy: 10 -> 1333 ]];
					local l_v2616_0 = v2616 --[[ copy: 7 -> 1334 ]];
					local l_v2618_0 = v2618 --[[ copy: 9 -> 1335 ]];
					local l_v2617_0 = v2617 --[[ copy: 8 -> 1336 ]];
					local function v2634(v2629) --[[ Line: 8702 ]] --[[ Name: RandomBeamsSlash ]]
						-- upvalues: l_l_EmoteSwordSpin_7_0 (copy), l_v2623_0 (copy), l_VFX_0 (ref), l_TweenService_0 (ref), l_v2616_0 (copy), l_v2618_0 (copy), l_v2617_0 (copy), l_Debris_0 (ref)
						local v2630 = math.random(-7, 7);
						local v2631 = math.random(-360, 360);
						local v2632 = math.random(-7, 7);
						local v2633 = l_l_EmoteSwordSpin_7_0.BeamSlash:Clone();
						v2633.CFrame = v2629 * CFrame.Angles(1.5707963267948966 + math.rad(v2630), math.rad(v2631), (math.rad(v2632)));
						l_v2623_0(1.25, v2633);
						v2633.Parent = l_VFX_0;
						l_TweenService_0:Create(v2633.Beam, l_v2616_0, l_v2618_0):Play();
						l_TweenService_0:Create(v2633.Attachment, l_v2617_0, {
							Orientation = v2633.Attachment.Orientation + Vector3.new(0, math.random(90, 180), 0)
						}):Play();
						l_Debris_0.AddItem(v2633, 0.4);
					end;
					local v2635 = CFrame.Angles(1.5707963267948966, 0, 0);
					local l_l_U_35_0 = l_U_35 --[[ copy: 2 -> 1337 ]];
					local l_l_EmoteKick3_10_0 = l_EmoteKick3_10 --[[ copy: 6 -> 1338 ]];
					local l_v2635_0 = v2635 --[[ copy: 12 -> 1339 ]];
					local function v2644(v2639, v2640, v2641) --[[ Line: 8719 ]] --[[ Name: MovePreset2 ]]
						-- upvalues: l_l_U_35_0 (copy), l_l_EmoteKick3_10_0 (copy), l_v2635_0 (copy), l_VFX_0 (ref), l_Debris_0 (ref)
						if l_l_U_35_0 == nil or l_l_U_35_0.Parent == nil then
							return;
						else
							local v2642 = l_l_EmoteKick3_10_0.mesh:Clone();
							v2642.CFrame = v2639 * CFrame.new(0, 0, -9 + v2641) * l_v2635_0;
							local v2643 = l_l_EmoteKick3_10_0.WindSwirl:Clone();
							v2643.CFrame = v2639 * CFrame.new(0, 0, -1.5 + v2641) * CFrame.Angles(1.5707963267948966, math.random(-3, 3), 0);
							v2642.Parent = l_VFX_0;
							v2643.Parent = l_VFX_0;
							Wind1(v2642, v2640, -0.75, "Y", "Y", false, false, true);
							Wind7(v2643, 0.35 * v2640, 1, "Y", "Y", "Y", false, false, true, false);
							l_Debris_0.AddItem(v2642, 3);
							l_Debris_0.AddItem(v2643, 3);
							return;
						end;
					end;
					local v2645 = l_Obliteration_11.Container.SpinDrop:Clone();
					v2645.Parent = l_U_35.HumanoidRootPart;
					local l_v2645_0 = v2645 --[[ copy: 14 -> 1340 ]];
					local l_v2634_0 = v2634 --[[ copy: 11 -> 1341 ]];
					local function v2648() --[[ Line: 8736 ]] --[[ Name: Function2 ]]
						-- upvalues: l_l_U_35_0 (copy), l_v2645_0 (copy), l_v2634_0 (copy)
						if l_l_U_35_0 == nil or l_l_U_35_0.Parent == nil or l_v2645_0 == nil or l_v2645_0.Parent == nil then
							return;
						else
							l_v2634_0(l_v2645_0.WorldCFrame);
							return;
						end;
					end;
					local v2649 = CFrame.new(0, 0, 2);
					local v2650 = CFrame.Angles(-2.443460952792061, 0, 0);
					local v2651 = CFrame.new(0, 0, 5);
					local l_l_T_14_0 = l_T_14 --[[ copy: 3 -> 1342 ]];
					local l_v2644_0 = v2644 --[[ copy: 13 -> 1343 ]];
					local l_v2649_0 = v2649 --[[ copy: 16 -> 1344 ]];
					local l_v2650_0 = v2650 --[[ copy: 17 -> 1345 ]];
					local l_v2651_0 = v2651 --[[ copy: 18 -> 1346 ]];
					local function v2658() --[[ Line: 8744 ]] --[[ Name: Function1 ]]
						-- upvalues: l_l_U_35_0 (copy), l_l_T_14_0 (copy), l_v2644_0 (copy), l_v2649_0 (copy), l_v2650_0 (copy), l_v2651_0 (copy)
						if l_l_U_35_0 == nil or l_l_U_35_0.Parent == nil or l_l_T_14_0 == nil or l_l_T_14_0.Parent == nil then
							return;
						else
							local v2657 = CFrame.new(l_l_T_14_0.Torso.Position) * (l_l_U_35_0.HumanoidRootPart.CFrame - l_l_U_35_0.HumanoidRootPart.Position);
							l_v2644_0(v2657 * l_v2649_0 * l_v2650_0 * l_v2651_0, 1, 0, 1.15);
							return;
						end;
					end;
					local v2659 = nil;
					local l_v2658_0 = v2658 --[[ copy: 19 -> 1347 ]];
					local l_v2648_0 = v2648 --[[ copy: 15 -> 1348 ]];
					v2659 = task.spawn(function() --[[ Line: 8751 ]]
						-- upvalues: l_v2658_0 (copy), l_v2648_0 (copy)
						local v2662 = 0;
						while true do
							v2662 = v2662 + 1;
							if v2662 % 3 == 0 then
								task.spawn(l_v2658_0);
							end;
							if v2662 % 1 == 0 then
								task.spawn(l_v2648_0);
							end;
							if v2662 >= 4 then
								v2662 = 0;
							end;
							task.wait(0.05);
						end;
					end);
					do
						local l_v2659_0 = v2659;
						local v2666 = VFXService.CreateBind(l_U_35, "ObliterationSpinDrop", function() --[[ Line: 8768 ]]
							-- upvalues: l_v2659_0 (ref), l_v2645_0 (copy)
							pcall(function() --[[ Line: 8769 ]]
								-- upvalues: l_v2659_0 (ref)
								task.cancel(l_v2659_0);
							end);
							l_v2659_0 = nil;
							if l_v2645_0 ~= nil and l_v2645_0.Parent ~= nil then
								for _, v2665 in pairs(l_v2645_0:GetDescendants()) do
									if v2665:IsA("ParticleEmitter") then
										v2665.Enabled = false;
									end;
								end;
							end;
						end);
						l_Debris_0.AddItem(v2666, 0.5);
						l_TweenService_0:Create(v2645, TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
							Position = Vector3.new(0, 0, -27.5, 0)
						}):Play();
						VFXService.EmitParticlesInInstance(v2645);
						l_Debris_0.AddItem(v2645, 3.5);
					end;
				end;
			end;
		elseif l_Request_1 == "ObliterationBlitz" then
			local l_Debris_0 = require(game.ReplicatedStorage.Modules.Debris)
			local l_U_36 = v777.Char
			if l_U_36 == nil or l_U_36.Parent == nil then
				return;
			else
				local l_CFrame_30 = l_U_36.HumanoidRootPart.CFrame;
				local l_Obliteration_12 = l_Assets_0.Particles.Emotes.Obliteration;
				local l_Contact_0 = l_Obliteration_12.Contact;
				local v2671 = CFrame.new(0, 5.625, -15);
				local v2672 = CFrame.new(0, -1.875, -15);
				local v2673 = CFrame.new(0, 7.5, -15);
				local l_l_Contact_0_0 = l_Contact_0 --[[ copy: 5 -> 1325 ]];
				local l_l_CFrame_30_0 = l_CFrame_30 --[[ copy: 3 -> 1326 ]];
				local l_v2671_0 = v2671 --[[ copy: 6 -> 1327 ]];
				local l_v2672_0 = v2672 --[[ copy: 7 -> 1328 ]];
				local l_v2673_0 = v2673 --[[ copy: 8 -> 1329 ]];
				local function v2685() --[[ Line: 8803 ]] --[[ Name: MeshPreset3 ]]
					-- upvalues: l_l_Contact_0_0 (copy), l_l_CFrame_30_0 (copy), l_v2671_0 (copy), l_v2672_0 (copy), l_v2673_0 (copy), l_VFX_0 (ref), l_Debris_0 (ref)
					local v2679 = l_l_Contact_0_0.LightWind1:Clone();
					local v2680 = l_l_CFrame_30_0 * l_v2671_0;
					v2679.CFrame = v2680 * CFrame.Angles(0, math.random(-3, 3), 0);
					local v2681 = l_l_Contact_0_0.Wave:Clone();
					v2681.CFrame = v2680;
					local v2682 = l_l_Contact_0_0.mesh:Clone();
					v2682.CFrame = l_l_CFrame_30_0 * l_v2672_0;
					local v2683 = l_l_Contact_0_0.mesh:Clone();
					v2683.CFrame = l_l_CFrame_30_0 * l_v2673_0;
					local v2684 = l_l_Contact_0_0.ring:Clone();
					v2684.CFrame = v2680 * CFrame.Angles(0, math.random(-3, 3), 0);
					v2679.Parent = l_VFX_0;
					v2681.Parent = l_VFX_0;
					v2682.Parent = l_VFX_0;
					v2683.Parent = l_VFX_0;
					v2684.Parent = l_VFX_0;
					Wind1(v2679, 0.2925, 0.9375, "Y", "Y", false, false, true);
					Wind2(v2681, 0.65, 1.875, "Y", false, false, true);
					Wind1(v2682, 0.9425, 1.40625, "Y", "Y", false, false, true);
					Wind3(v2683, 0.4875, 2.71875, false, false, true);
					Wind1(v2684, 0.2275, 0.9375, "Y", "Y", true, true, true);
					l_Debris_0.AddItem(v2679, 2.5);
					l_Debris_0.AddItem(v2681, 2.5);
					l_Debris_0.AddItem(v2682, 2.5);
					l_Debris_0.AddItem(v2683, 2.5);
					l_Debris_0.AddItem(v2684, 2.5);
				end;
				if l_U_36 == v22 then
					l_Humanoid_0.CameraOffset = Vector3.new(0, 50, 0, 0);
					local l_CameraMinZoomDistance_1 = l_LocalPlayer_0.CameraMinZoomDistance;
					local l_CameraMaxZoomDistance_1 = l_LocalPlayer_0.CameraMaxZoomDistance;
					l_LocalPlayer_0.CameraMinZoomDistance = 50;
					l_LocalPlayer_0.CameraMaxZoomDistance = 50;
					l_CurrentCamera_0.CFrame = l_HumanoidRootPart_0.CFrame * CFrame.Angles(0.39269908169872414, 3.141592653589793, 0);
					VFXService.EndCutscene();
					VFXService.ScreenFlash(nil, nil, nil, 0.8);
					VFXService.ShakeCamera(0, 0.8, 48, 0.67, 0.67, 0.67);
					l_LocalPlayer_0.CameraMinZoomDistance = l_CameraMinZoomDistance_1;
					l_LocalPlayer_0.CameraMaxZoomDistance = l_CameraMaxZoomDistance_1;
					local l_Configuration_8 = Instance.new("Configuration");
					l_Configuration_8.Name = "ObliterationEnd";
					l_Configuration_8.Parent = v22;
					l_Configuration_8:Destroy();
					VFXService.DestroyBind(v22, "ObliterationSFX", true);
					VFXService.DestroyBind(v22, "ObliterationCamFX", true);
				end;
				local v2689 = l_Obliteration_12.FinalCut:Clone();
				local v2690 = l_CFrame_30 * CFrame.new(0, 0, -15);
				v2689.CFrame = v2690;
				v2689.Parent = l_VFX_0;
				if l_U_36 ~= v22 and v777.Emeny ~= v22 then
					VFXService.PlaySoundAtCFrame(v2690, "ObliterationFinalCutEmote");
					local l_Configuration_9 = Instance.new("Configuration");
					l_Configuration_9.Name = "ObliterationEnd";
					l_Configuration_9.Parent = l_U_36;
					l_Configuration_9:Destroy();
					VFXService.DestroyBind(l_U_36, "ObliterationSFX", true);
				end;
				VFXService.EmitParticlesInInstance(v2689);
				v2685();
				local l_l_U_36_0 = l_U_36 --[[ copy: 2 -> 1330 ]];
				local l_v2685_0 = v2685 --[[ copy: 9 -> 1331 ]];
				task.delay(0.5, function() --[[ Line: 8866 ]]
					-- upvalues: l_l_U_36_0 (copy), v22 (ref), l_v2685_0 (copy)
					if l_l_U_36_0 == v22 then
						VFXService.ShakeCamera(0, 0.5, 27, 0.42, 0.42, 0.42);
					end;
					l_v2685_0();
				end);
				l_Debris_0.AddItem(v2689, 4);
			end;
		elseif l_Request_1 == "ObliterationBlitzV" then
			local l_Debris_0 = require(game.ReplicatedStorage.Modules.Debris)
			l_Humanoid_0.CameraOffset = Vector3.new(0, 50, 0, 0);
			local l_CameraMinZoomDistance_2 = l_LocalPlayer_0.CameraMinZoomDistance;
			local l_CameraMaxZoomDistance_2 = l_LocalPlayer_0.CameraMaxZoomDistance;
			l_LocalPlayer_0.CameraMinZoomDistance = 50;
			l_LocalPlayer_0.CameraMaxZoomDistance = 50;
			l_CurrentCamera_0.CFrame = l_HumanoidRootPart_0.CFrame * CFrame.Angles(-0.39269908169872414, 0, 0);
			VFXService.EndCutscene();
			VFXService.ScreenFlash(nil, nil, nil, 0.8);
			VFXService.ShakeCamera(0, 0.8, 48, 0.67, 0.67, 0.67);
			l_LocalPlayer_0.CameraMinZoomDistance = l_CameraMinZoomDistance_2;
			l_LocalPlayer_0.CameraMaxZoomDistance = l_CameraMaxZoomDistance_2;
			local l_Configuration_10 = Instance.new("Configuration");
			l_Configuration_10.Name = "ObliterationEnd";
			l_Configuration_10.Parent = v22;
			l_Configuration_10:Destroy();
			VFXService.DestroyBind(v22, "ObliterationSFX", true);
			VFXService.DestroyBind(v22, "ObliterationCamFX", true);
			task.delay(0.5, function() --[[ Line: 8889 ]]
				VFXService.ShakeCamera(0, 0.5, 27, 0.42, 0.42, 0.42);
			end);
		elseif l_Request_1 == "ObliterationSlice" then
			local l_Debris_0 = require(game.ReplicatedStorage.Modules.Debris)
			local l_T_15 = v777.Emeny
			if l_T_15 == nil or l_T_15.Parent == nil then
				return;
			else
				local v2698 = l_Assets_0.CharacterStorage.Jun.CloneTemplate:Clone();
				VFXService.MatchCharacter(l_T_15, v2698);
				local v2699 = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out);
				for _, v2701 in pairs(l_T_15:GetDescendants()) do
					if v2701:IsA("BasePart") or v2701:IsA("Decal") then
						v2701.Transparency = 1;
					elseif v2701:IsA("BillboardGui") then
						v2701.Enabled = false;
					elseif v2701:IsA("ParticleEmitter") or v2701:IsA("Trail") then
						v2701.Enabled = false;
					elseif v2701:IsA("Beam") then
						l_TweenService_0:Create(v2701, v2699, {
							Width0 = 0, 
							Width1 = 0
						});
					end;
				end;
				local l_l_T_15_0 = l_T_15 --[[ copy: 2 -> 1321 ]];
				l_T_15.ChildAdded:Connect(function(v2703) --[[ Line: 8914 ]]
					-- upvalues: l_l_T_15_0 (copy)
					if l_l_T_15_0 == nil or l_l_T_15_0.Parent == nil then
						return;
					else
						if v2703:IsA("BasePart") then
							v2703.Transparency = 1;
							for _, v2705 in pairs(v2703:GetDescendants()) do
								if v2705:IsA("BasePart") or v2705:IsA("Decal") then
									v2705.Transparency = 1;
								end;
								if v2705:IsA("BillboardGui") then
									v2705.Enabled = false;
								end;
							end;
						else
							for _, v2707 in pairs(v2703:GetDescendants()) do
								if v2707:IsA("BasePart") or v2707:IsA("Decal") then
									v2707.Transparency = 1;
								end;
								if v2707:IsA("BillboardGui") then
									v2707.Enabled = false;
								end;
							end;
							task.spawn(function() --[[ Line: 8935 ]]
								-- upvalues: v2703 (copy), l_l_T_15_0 (ref)
								task.wait();
								if v2703 ~= nil and v2703.Parent ~= nil and v2703.Parent == l_l_T_15_0 then
									for _, v2709 in pairs(v2703:GetDescendants()) do
										if v2709:IsA("BasePart") or v2709:IsA("Decal") then
											v2709.Transparency = 1;
										end;
										if v2709:IsA("BillboardGui") then
											v2709.Enabled = false;
										end;
									end;
								end;
							end);
						end;
						for _, v2711 in pairs(l_l_T_15_0:GetDescendants()) do
							if v2711:IsA("BasePart") or v2711:IsA("Decal") then
								v2711.Transparency = 1;
							end;
							if v2711:IsA("BillboardGui") then
								v2711.Enabled = false;
							end;
						end;
						return;
					end;
				end);
				v2698:PivotTo(l_T_15:GetPivot());
				v2698.HumanoidRootPart.Anchored = true;
				local l_Torso_3 = v2698.Torso;
				local _ = l_Torso_3.Position;
				local l_CFrame_31 = v2698.HumanoidRootPart.CFrame;
				local v2715 = l_CFrame_31.LookVector * 65;
				local v2716 = v2715 * 3;
				local v2717 = v2715 * 2.8;
				local l_RightVector_1 = l_CFrame_31.RightVector;
				local v2719 = Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10));
				local v2720 = Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10));
				local v2721 = Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10));
				local v2722 = Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10));
				local v2723 = Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10));
				local v2724 = Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10));
				local v2725 = v2716 + Vector3.new(0, 270, 0, 0);
				local v2726 = v2715 + (l_RightVector_1 * 65 + Vector3.new(0, 160, 0, 0));
				local v2727 = v2715 + (-l_RightVector_1 * 65 + Vector3.new(0, 160, 0, 0));
				local v2728 = v2717 + l_RightVector_1 * 65;
				local v2729 = v2717 + -l_RightVector_1 * 65;
				local v2730 = v2715 + Vector3.new(0, 160, 0, 0);
				local v2731 = v2698["Right Arm"];
				v2731.CollisionGroup = "Flying Rocks";
				local v2732 = v2698["Left Arm"];
				v2732.CollisionGroup = "Flying Rocks";
				local v2733 = v2698["Right Leg"];
				v2733.CollisionGroup = "Flying Rocks";
				local v2734 = v2698["Left Leg"];
				v2734.CollisionGroup = "Flying Rocks";
				local l_Head_1 = v2698.Head;
				l_Head_1.CollisionGroup = "Flying Rocks";
				v2698.HumanoidRootPart.RootJoint:Destroy();
				l_Torso_3["Right Hip"]:Destroy();
				l_Torso_3["Left Hip"]:Destroy();
				l_Torso_3["Right Shoulder"]:Destroy();
				l_Torso_3["Left Shoulder"]:Destroy();
				l_Torso_3.Neck:Destroy();
				v2698.Parent = l_VFX_0;
				v2733.CanCollide = true;
				v2734.CanCollide = true;
				v2731.CanCollide = true;
				v2732.CanCollide = true;
				l_Head_1.CanCollide = true;
				l_Torso_3:ApplyImpulse(v2725);
				v2731:ApplyImpulse(v2726);
				v2732:ApplyImpulse(v2727);
				v2733:ApplyImpulse(v2728);
				v2734:ApplyImpulse(v2729);
				l_Head_1:ApplyImpulse(v2730);
				l_Torso_3:ApplyAngularImpulse(v2719);
				v2731:ApplyAngularImpulse(v2720);
				v2732:ApplyAngularImpulse(v2721);
				v2733:ApplyAngularImpulse(v2722);
				v2734:ApplyAngularImpulse(v2723);
				l_Head_1:ApplyAngularImpulse(v2724);
				local v2736 = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out);
				local v2737 = {
					Transparency = 1
				};
				local l_v2698_0 = v2698 --[[ copy: 3 -> 1322 ]];
				local l_v2736_0 = v2736 --[[ copy: 29 -> 1323 ]];
				local l_v2737_0 = v2737 --[[ copy: 30 -> 1324 ]];
				task.delay(5, function() --[[ Line: 9016 ]]
					-- upvalues: l_v2698_0 (copy), l_TweenService_0 (ref), l_v2736_0 (copy), l_v2737_0 (copy), l_Debris_0 (ref)
					if l_v2698_0 ~= nil and l_v2698_0.Parent ~= nil then
						for _, v2742 in pairs(l_v2698_0:GetDescendants()) do
							if (v2742:IsA("BasePart") or v2742:IsA("Decal")) and v2742.Transparency < 1 then
								l_TweenService_0:Create(v2742, l_v2736_0, l_v2737_0):Play();
							end;
						end;
						l_Debris_0.AddItem(l_v2698_0, 0.4);
					end;
				end);
			end;
		end;
    end
}

return module;

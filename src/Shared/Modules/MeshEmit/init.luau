local v0 = {}
v0.__index = v0
local l_TweenService_0 = game:GetService("TweenService")
local l_RunService_0 = game:GetService("RunService")
local l_Debris_0 = game:GetService("Debris")
local l_VFX_0 = workspace:WaitForChild("Thrown")
local l_new_0 = CFrame.new
local l_Angles_0 = CFrame.Angles
local l_rad_0 = math.rad
local l_random_0 = math.random
local l_new_1 = TweenInfo.new
local l_EasingStyle_0 = Enum.EasingStyle
local l_EasingDirection_0 = Enum.EasingDirection

local function v24(v21) --[[ Line: 48 ]] --[[ Name: RetrieveProperities ]]
    local v22 = {}
    if (v21:IsA("Part") and v21:FindFirstChildOfClass("SpecialMesh") and "SpecialMesh" or "Mesh") == "SpecialMesh" then
        local l_SpecialMesh_0 = v21:FindFirstChildOfClass("SpecialMesh")
        if not l_SpecialMesh_0 then
            return {}
        else
            v22.Scale = l_SpecialMesh_0.Scale
        end
    else
        v22.Size = v21.Size
    end
    v22.Position = v21.CFrame.Position
    return v22
end

local v25 = {}
local v26 = {}
local v27 = {}
local v28 = nil

function v0.new(v39)
    return (setmetatable({
        Model = v39, 
        Type = v39.Start:IsA("Part") and v39.Start:FindFirstChildOfClass("SpecialMesh") and "SpecialMesh" or "Mesh", 
        Properities = v24(v39.Start), 
        EndProperities = v24(v39.End), 
        Settings = v39:GetAttributes()
    }, v0))
end
function v0:SetFlipbook(v41) --[[ Line: 137 ]] --[[ Name: SetFlipbook ]]
    self.__Flipbook = require(v41)
end
function v0:RandomizeSize(v43, v44) --[[ Line: 141 ]] --[[ Name: RandomizeSize ]]
    -- upvalues: l_new_0 (copy), l_random_0 (copy)
    if self.Type == "SpecialMesh" then
        self.EndProperities.Scale = l_new_0(l_random_0(v43.X, v44.X), l_random_0(v43.Y, v44.Y), l_random_0(v43.Z, v44.Z))
        return
    else
        self.EndProperities.Size = l_new_0(l_random_0(v43.X, v44.X), l_random_0(v43.Y, v44.Y), l_random_0(v43.Z, v44.Z))
        return
    end
end
function v0:RotateMesh(v46, v47, v48) --[[ Line: 150 ]] --[[ Name: RotateMesh ]]
    -- upvalues: v26 (copy), v28 (ref), l_RunService_0 (copy), v25 (copy), l_Angles_0 (copy), l_rad_0 (copy), v27 (copy)
    table.insert(v26, {
        Part = v46, 
        Speed = v47, 
        TimeLeft = v48
    })
    if v28 then
        return
    else
        v28 = l_RunService_0.RenderStepped:Connect(function(v49) --[[ Line: 71 ]]
            -- upvalues: v25 (ref), v26 (ref), l_Angles_0 (ref), l_rad_0 (ref), v27 (ref), v28 (ref)
            for v50 = #v25, 1, -1 do
                local v51 = v25[v50]
                v51.Passed = v51.Passed + v49
                if v51.Passed >= v51.Rate then
                    v51.Passed = 0
                    v51.Emitter:Emit(v51.CFrame)
                end
                v51.TimeLeft = v51.TimeLeft - v49
                if v51.TimeLeft <= 0 then
                    table.remove(v25, v50)
                end
            end
            for v52 = #v26, 1, -1 do
                local v53 = v26[v52]
                local l_Part_1 = v53.Part
                l_Part_1.CFrame = l_Part_1.CFrame * l_Angles_0(0, l_rad_0(v53.Speed), 0)
                v53.TimeLeft = v53.TimeLeft - v49
                if v53.TimeLeft <= 0 then
                    table.remove(v26, v52)
                end
            end
            for v55 = #v27, 1, -1 do
                local v56 = v27[v55]
                v56.Passed = v56.Passed + v49
                if v56.Passed >= v56.FrameTime then
                    v56.Passed = 0
                    v56.Index = v56.Index + 1
                    if v56.Index > #v56.Frames then
                        table.remove(v27, v55)
                    elseif v56.Type == "SpecialMesh" then
                        local l_Decal_1 = v56.Part:FindFirstChildOfClass("Decal")
                        if l_Decal_1 then
                            l_Decal_1.Texture = v56.Frames[v56.Index]
                        end
                    else
                        v56.Part.TextureId = v56.Frames[v56.Index]
                    end
                end
            end
            if #v25 == 0 and #v26 == 0 and #v27 == 0 and v28 ~= nil then
                v28:Disconnect()
                v28 = nil
            end
        end)
        return
    end
end
function v0:PlayFlipbook(v59)
    local l___Flipbook_0 = self.__Flipbook
    if not l___Flipbook_0 then
        return
    else
        local v61 = 1 / self.Settings.FlipbookRate or 0.016666666666666666
        table.insert(v27, {
            Part = v59, 
            Frames = l___Flipbook_0, 
            Index = 1, 
            Passed = v61 + 1, 
            FrameTime = v61, 
            Type = self.Type
        })
        if v28 then
            return
        else
            v28 = l_RunService_0.RenderStepped:Connect(function(v62) --[[ Line: 71 ]]
                -- upvalues: v25 (ref), v26 (ref), l_Angles_0 (ref), l_rad_0 (ref), v27 (ref), v28 (ref)
                for v63 = #v25, 1, -1 do
                    local v64 = v25[v63]
                    v64.Passed = v64.Passed + v62
                    if v64.Passed >= v64.Rate then
                        v64.Passed = 0
                        v64.Emitter:Emit(v64.CFrame)
                    end
                    v64.TimeLeft = v64.TimeLeft - v62
                    if v64.TimeLeft <= 0 then
                        table.remove(v25, v63)
                    end
                end
                for v65 = #v26, 1, -1 do
                    local v66 = v26[v65]
                    local l_Part_2 = v66.Part
                    l_Part_2.CFrame = l_Part_2.CFrame * l_Angles_0(0, l_rad_0(v66.Speed), 0)
                    v66.TimeLeft = v66.TimeLeft - v62
                    if v66.TimeLeft <= 0 then
                        table.remove(v26, v65)
                    end
                end
                for v68 = #v27, 1, -1 do
                    local v69 = v27[v68]
                    v69.Passed = v69.Passed + v62
                    if v69.Passed >= v69.FrameTime then
                        v69.Passed = 0
                        v69.Index = v69.Index + 1
                        if v69.Index > #v69.Frames then
                            table.remove(v27, v68)
                        elseif v69.Type == "SpecialMesh" then
                            local l_Decal_2 = v69.Part:FindFirstChildOfClass("Decal")
                            if l_Decal_2 then
                                l_Decal_2.Texture = v69.Frames[v69.Index]
                            end
                        else
                            v69.Part.TextureId = v69.Frames[v69.Index]
                        end
                    end
                end
                if #v25 == 0 and #v26 == 0 and #v27 == 0 and v28 ~= nil then
                    v28:Disconnect()
                    v28 = nil
                end
            end)
            return
        end
    end
end
function v0:Emit(v72)
    local l_Lifetime_0 = self.Settings.Lifetime
    local v74 = l_EasingStyle_0[self.Settings.EasingStyle]
    local v75 = l_EasingDirection_0[self.Settings.EasingDirection]
    local v76 = self.Settings.Transparency or 1
    local v77 = self.Settings.StartTransparency or 1
    local l_RotationX_0 = self.Settings.RotationX
    local v79 = not l_RotationX_0 and 0 or l_random_0(l_RotationX_0.Min, l_RotationX_0.Max)
    local l_RotationY_0 = self.Settings.RotationY
    l_RotationX_0 = not l_RotationY_0 and 0 or l_random_0(l_RotationY_0.Min, l_RotationY_0.Max)
    local l_RotationZ_0 = self.Settings.RotationZ
    l_RotationY_0 = not l_RotationZ_0 and 0 or l_random_0(l_RotationZ_0.Min, l_RotationZ_0.Max)
    l_RotationZ_0 = l_new_1(l_Lifetime_0, v74, v75)
    local v82 = self.Model.Start:Clone()
    self:PlayFlipbook(v82)
    v82.CFrame = (typeof(v72) == "CFrame" and v72 or v72.CFrame) * l_Angles_0(l_rad_0(v79), l_rad_0(l_RotationX_0), (l_rad_0(l_RotationY_0)))
    v82.Parent = l_VFX_0
    l_Debris_0:AddItem(v82, l_Lifetime_0)
    local v83 = self.Model.Start.CFrame:ToObjectSpace(self.Model.End.CFrame)
    self.EndProperities.Position = nil
    if self.Settings.RotationSpeed then
        self:RotateMesh(v82, self.Settings.RotationSpeed, l_Lifetime_0)
    end
    if self.Type == "SpecialMesh" then
        local l_SpecialMesh_1 = v82:FindFirstChildOfClass("SpecialMesh")
        local l_Decal_3 = v82:FindFirstChildOfClass("Decal")
        if l_SpecialMesh_1 then
            local v86 = l_TweenService_0:Create(l_SpecialMesh_1, l_RotationZ_0, self.EndProperities)
            local v87 = l_TweenService_0:Create(v82, l_RotationZ_0, {
                CFrame = v82.CFrame * v83
            })
            v86:Play()
            v87:Play()
            v86.Completed:Once(function() --[[ Line: 205 ]]
                -- upvalues: l_SpecialMesh_1 (copy), self (copy), v82 (copy)
                l_SpecialMesh_1.Scale = self.Properities.Scale or Vector3.new(1, 1, 1, 0)
                v82.Transparency = 1
            end)
        end
        if l_Decal_3 then
            l_Decal_3.Transparency = v77
            local v88 = l_new_1(l_Lifetime_0, l_EasingStyle_0[self.Settings.TransparencyEasingStyle], l_EasingDirection_0[self.Settings.TransparencyEasingDirection])
            l_TweenService_0:Create(l_Decal_3, v88, {
                Transparency = v76, 
                Color3 = self.Model.End:FindFirstChildOfClass("Decal").Color3
            }):Play()
            return
        end
    else
        v82.Transparency = v77
        local _ = l_new_1(l_Lifetime_0, l_EasingStyle_0[self.Settings.TransparencyEasingStyle], l_EasingDirection_0[self.Settings.TransparencyEasingDirection])
        if self.Settings.Movement then
            self.EndProperities.CFrame = v82.CFrame * v83
        end
        self.EndProperities.Transparency = v76
        local v90 = l_TweenService_0:Create(v82, l_RotationZ_0, self.EndProperities)
        v90:Play()
        v90.Completed:Once(function() --[[ Line: 226 ]]
            -- upvalues: v82 (copy), self (copy)
            v82.Size = self.Properities.Size or Vector3.new(1, 1, 1, 0)
            v82.Transparency = 1
        end)
    end
end
function v0:EmitRate(v92, v93, v94)
    local v95 = v92 / 60
    table.insert(v25, {
        Emitter = self, 
        Rate = v95, 
        TimeLeft = v93, 
        CFrame = v94, 
        Passed = v95 + 1
    })
    if v28 then
        return
    else
        v28 = l_RunService_0.RenderStepped:Connect(function(v96) --[[ Line: 71 ]]
            -- upvalues: v25 (ref), v26 (ref), l_Angles_0 (ref), l_rad_0 (ref), v27 (ref), v28 (ref)
            for v97 = #v25, 1, -1 do
                local v98 = v25[v97]
                v98.Passed = v98.Passed + v96
                if v98.Passed >= v98.Rate then
                    v98.Passed = 0
                    v98.Emitter:Emit(v98.CFrame)
                end
                v98.TimeLeft = v98.TimeLeft - v96
                if v98.TimeLeft <= 0 then
                    table.remove(v25, v97)
                end
            end
            for v99 = #v26, 1, -1 do
                local v100 = v26[v99]
                local l_Part_3 = v100.Part
                l_Part_3.CFrame = l_Part_3.CFrame * l_Angles_0(0, l_rad_0(v100.Speed), 0)
                v100.TimeLeft = v100.TimeLeft - v96
                if v100.TimeLeft <= 0 then
                    table.remove(v26, v99)
                end
            end
            for v102 = #v27, 1, -1 do
                local v103 = v27[v102]
                v103.Passed = v103.Passed + v96
                if v103.Passed >= v103.FrameTime then
                    v103.Passed = 0
                    v103.Index = v103.Index + 1
                    if v103.Index > #v103.Frames then
                        table.remove(v27, v102)
                    elseif v103.Type == "SpecialMesh" then
                        local l_Decal_4 = v103.Part:FindFirstChildOfClass("Decal")
                        if l_Decal_4 then
                            l_Decal_4.Texture = v103.Frames[v103.Index]
                        end
                    else
                        v103.Part.TextureId = v103.Frames[v103.Index]
                    end
                end
            end
            if #v25 == 0 and #v26 == 0 and #v27 == 0 and v28 ~= nil then
                v28:Disconnect()
                v28 = nil
            end
        end)
        return
    end
end
return v0
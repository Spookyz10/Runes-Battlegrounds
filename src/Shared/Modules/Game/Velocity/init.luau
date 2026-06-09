
local v0 = {};
v0.__index = v0;
local l_ReplicatedStorage_0 = game:GetService("ReplicatedStorage")
local l_RunService_0 = game:GetService("RunService")
local v3 = require(l_ReplicatedStorage_0.Modules.Game.Job)
local v4 = require(l_ReplicatedStorage_0.Modules.Game.Utility)

v0.Remove = function(v5) --[[ Line: 10 ]] --[[ Name: Remove ]]
    if v5.Removed then
        return;
    else
        v5.Removed = true;
        v5.Job:Destroy();
        return;
    end;
end;
v0.Destroy = function(v6) --[[ Line: 17 ]] --[[ Name: Destroy ]]
    -- upvalues: l_RunService_0 (copy)
    if v6.Removed then
        return;
    else
        v6:Remove();
        if l_RunService_0:IsServer() then
            v6.LuaPlayer.Replication.Attributes:SetAttribute("Velocity", nil);
        end;
        return;
    end;
end;
v0.Create = function(v7) --[[ Line: 27 ]] --[[ Name: Create ]]
    -- upvalues: l_RunService_0 (copy), v4 (copy)
    if v7.Removed then
        return;
    else
        local l_BodyVelocity_0 = v7.Combat:CreateBodyVelocity(v7.Settings.Name);
        if l_BodyVelocity_0 ~= nil then
            l_BodyVelocity_0:SetAttribute("RemoveOn", v7.LuaPlayer.Player.name);
            l_BodyVelocity_0:AddTag("RemoveOnEvasive", true);
            l_BodyVelocity_0.MaxForce = v7.Settings.MaxForce or Vector3.new(80000, 80000, 80000, 0);
            if not v7.Settings.Controllable and v7.Settings.Velocity then
                l_BodyVelocity_0.Velocity = v7.Settings.Velocity;
            end;
            local v9 = os.clock();
            v7.Job:Task(l_RunService_0.PreAnimation:Connect(function() --[[ Line: 43 ]]
                -- upvalues: v7 (copy), v4 (ref), l_BodyVelocity_0 (copy), v9 (copy)
                if v7.Settings.Controllable then
                    if v4.IsFacingOnAWall(v7.LuaCharacter.RootPart) then
                        l_BodyVelocity_0.Velocity = Vector3.new(0, 0, 0, 0);
                        return;
                    else
                        local l_CFrame_0 = v7.LuaCharacter.RootPart.CFrame;
                        local v11 = Vector3.new(0, 0, 0, 0);
                        if v7.Settings.X then
                            v11 = v11 + l_CFrame_0.RightVector * v7.Settings.X;
                        end;
                        if v7.Settings.Y then
                            v11 = v11 + l_CFrame_0.UpVector * v7.Settings.Y;
                        end;
                        if v7.Settings.Z then
                            v11 = v11 + l_CFrame_0.LookVector * v7.Settings.Z;
                        end;
                        if v7.Settings.Duration then
                            l_BodyVelocity_0.Velocity = v11 * math.max(0, v7.Settings.Duration - (os.clock() - v9) / v7.Settings.Duration);
                            return;
                        else
                            l_BodyVelocity_0.Velocity = v11;
                            return;
                        end;
                    end;
                else
                    if v7.Settings.Velocity and v7.Settings.Duration then
                        l_BodyVelocity_0.Velocity = v7.Settings.Velocity * (v7.Settings.DontScale and 1 or math.max(0, v7.Settings.Duration - (os.clock() - v9) / v7.Settings.Duration));
                    end;
                    return;
                end;
            end));
            l_BodyVelocity_0.Destroying:Once(function() --[[ Line: 76 ]]
                -- upvalues: v7 (copy)
                v7:Remove();
            end);
            v7.Object = l_BodyVelocity_0;
            l_BodyVelocity_0.Parent = v7.LuaCharacter.RootPart;
            v7.Job:Task(l_BodyVelocity_0);
        end;
        return;
    end;
end;
v0.Fire = function(v12) --[[ Line: 87 ]] --[[ Name: Fire ]]
    -- upvalues: l_RunService_0 (copy)
    if v12.Removed or not v12.LuaCharacter.HumanoidExists then
        return;
    else
        if l_RunService_0:IsServer() then
            if v12.LuaPlayer.IsNPC then
                v12:Create();
            else
                v12.LuaPlayer.Remotes.Combat.Velocity:FireClient(v12.LuaPlayer.Player, v12.Settings);
            end;
            v12.LuaPlayer.Replication.Attributes:SetAttribute("Velocity", true);
        elseif v12.Settings.DoesntNeedVelocityAttribute or v12.LuaPlayer.Replication.Attributes:GetAttribute("Velocity") then
            v12:Create();
            if l_RunService_0:IsClient() then
                v12.Job:Task(v12.LuaPlayer.Replication.Attributes:GetAttributeChangedSignal("Velocity"):Connect(function() --[[ Line: 104 ]]
                    -- upvalues: v12 (copy)
                    if not v12.LuaPlayer.Replication.Attributes:GetAttribute("Velocity") then
                        v12:Remove();
                    end;
                end));
            end;
        end;
        if v12.Settings.RemoveTime then
            task.delay(v12.Settings.RemoveTime, v12.Remove, v12);
        end;
        return;
    end;
end;
return {
    Utility = require(script.VelocityUtil), 
    new = function(v13) --[[ Line: 121 ]] --[[ Name: new ]]
        -- upvalues: v0 (copy), v3 (copy)
        local v14 = setmetatable({}, v0);
        v14.Combat = v13;
        v14.LuaCharacter = v13.LuaCharacter;
        v14.LuaPlayer = v13.LuaPlayer;
        v14.Settings = {};
        v14.Job = v3.new();
        v14.Removed = false;
        v14.Job:Task(v14.LuaCharacter.OnHumanoidAvailabilityChanged:Connect(function() --[[ Line: 133 ]]
            -- upvalues: v14 (copy)
            if not v14.LuaCharacter.HumanoidExists then
                v14:Remove();
            end;
        end));
        return v14;
    end
};
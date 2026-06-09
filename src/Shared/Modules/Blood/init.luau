local l_ReplicatedStorage_0 = game:GetService("ReplicatedStorage");
local l_TweenService_0 = game:GetService("TweenService");
local l_RunService_0 = game:GetService("RunService");
local l_LocalPlayer_0 = game:GetService("Players").LocalPlayer;
local v6 = {};
v6.CanShowBlood = function() --[[ Line: 68 ]] --[[ Name: CanShowBlood ]]
    -- upvalues: l_LocalPlayer_0 (copy)
    return l_LocalPlayer_0:GetAttribute("Blood") == true;
end;
v6.ParticleSupportsBlood = function(v12) --[[ Line: 72 ]] --[[ Name: ParticleSupportsBlood ]]
    -- upvalues: v6 (copy)
    if string.find(string.lower(v12.Name), "blood") then
        return v6.CanShowBlood();
    else
        return true;
    end;
end;
return v6;
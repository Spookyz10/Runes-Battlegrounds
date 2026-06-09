-- Saved by UniversalSynSaveInstance https://discord.gg/wx4ThpAsmw

local _ = game:GetService("Players");
local _ = game:GetService("ReplicatedStorage");
local l_Debris_0 = game:GetService("Debris");
local l_RunService_0 = game:GetService("RunService");
return {
    play = function(_, v5, v6, v7, v8) --[[ Line: 8 ]] --[[ Name: play ]]
        if v5 == nil then
            return;
        else
            v7 = v7 or {};
            if typeof(v5) == "table" then
                for v9 = 1, #v5 do
                    if v5[v9] == nil then
                        table.remove(v5, v9);
                    end;
                end;
                v5 = v5[math.random(1, #v5)]:Clone();
            else
                v5 = v5:Clone();
            end;
            for v10, v11 in pairs(v7) do
                v5[v10] = v11;
            end;
            v5.Parent = v6;
            if v8 then
                v5.PlayOnRemove = true;
                v5:Destroy();
            else
                v5:Play();
                if l_RunService_0:IsServer() == true then
                    if v5.Looped == false then
                        l_Debris_0:AddItem(v5, v5.TimeLength + 1);
                    end;
                elseif l_RunService_0:IsClient() == true and v5.Looped == false then
                    v5.Ended:Connect(function() --[[ Line: 42 ]]
                        v5:Destroy();
                    end);
                end;
            end;
            return v5;
        end;
    end
};
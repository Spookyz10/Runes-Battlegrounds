local l_ReplicatedStorage_0 = game:GetService("ReplicatedStorage");
local l_RunService_0 = game:GetService("RunService");
local v2 = require(l_ReplicatedStorage_0.Modules.Utility);
local v3 = {};
local v4 = {};
local v5 = {};
local v6 = {};
local function _(v7, v8) --[[ Name: GetCF ]]
    return (v7.ClassName == "Attachment" and v7.WorldCFrame or v7.CFrame) * v8;
end;
l_RunService_0:BindToRenderStep("FakeWelds", v2.CharacterRenderPriority, function()
    -- upvalues: v5 (copy), v6 (copy), v4 (copy)
    table.clear(v5);
    table.clear(v6);
    for v10, v11 in v4 do
        local l_To_0 = v11.To;
        if v10 ~= nil and v10.Parent ~= nil and l_To_0 ~= nil and l_To_0.Parent ~= nil then
            local l_Offset_0 = v11.Offset;
            local v14 = (l_To_0.ClassName == "Attachment" and l_To_0.WorldCFrame or l_To_0.CFrame) * l_Offset_0;
            if v11.PivotMethod then
                v10:PivotTo(v14);
            else
                table.insert(v5, v10);
                table.insert(v6, v14);
            end;
        end;
    end;
    workspace:BulkMoveTo(v5, v6, Enum.BulkMoveMode.FireCFrameChanged);
end);
v3.new = function(v15, v16, v17) --[[ Name: new ]]
    -- upvalues: v4 (copy)
    if v4[v15] ~= nil then
        return;
    else
        v4[v15] = {
            PivotMethod = v15:IsA("Model"), 
            To = v16, 
            Offset = v17 or CFrame.identity
        };
        local v18 = nil;
        v18 = v15.AncestryChanged:Connect(function(_, v20)
            -- upvalues: v18 (ref), v4 (ref), v15 (copy)
            if v20 == nil then
                v18:Disconnect();
                if v4[v15] then
                    v4[v15] = nil;
                end;
            end;
        end);
        return;
    end;
end;
return v3;
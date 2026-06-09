local v0 = {}
local v1 = {}
local v2 = {}
local l_ReplicatedStorage_0 = game:GetService("ReplicatedStorage")
local v4 = require(l_ReplicatedStorage_0.Modules.Game.EffectUtility.AenoirEmit)

return function(v5, v6)
    for _, v8 in ipairs(v5:GetDescendants()) do
        if not v8:GetAttribute("Transparent") and not v8:HasTag("RagdollCollider") then
            if v8:IsA("BasePart") and v8.Name ~= "HumanoidRootPart" or v8:IsA("Decal") then
                if v6 == 0 then
                    v8.Transparency = v0[v8] or 0
                    if v0[v8] then
                        v0[v8] = nil
                    end
                else
                    if v0[v8] == nil then
                        v0[v8] = v8.Transparency
                    end
                    v8.Transparency = math.max(v6, v0[v8] or 0)
                end
            elseif (v8:IsA("ParticleEmitter") or v8:IsA("Beam")) and v8:HasTag("Aura") or v8:IsA("BillboardGui") then
                local v9 = v8:IsA("ParticleEmitter") or v8:IsA("Beam")
                if v1[v8] == nil then
                    v1[v8] = v8.Enabled
                end
                if v9 and v2[v8] == nil then
                    v2[v8] = v8.Transparency
                end
                if v6 == 1 then
                    v8.Enabled = false
                    if v9 then
                        v8.Transparency = NumberSequence.new(1)
                    end
                else
                    v8.Enabled = v1[v8]
                    if v9 then
                        v8.Transparency = v4.LerpNumberSequence(v2[v8], 1, v6)
                    end
                    if v6 == 0 then
                        v2[v8] = nil
                    end
                    v1[v8] = nil
                end
            end
        end
    end
end
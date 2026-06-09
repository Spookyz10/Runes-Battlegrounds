-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Bytecode (Base64):
-- BgMZBkNGcmFtZRFDYW5ub3RDYW1lcmFTaGFrZQxHZXRBdHRyaWJ1dGUMQ2FtZXJhX1NoYWtlBEZpcmUEZ2FtZRFSZXBsaWNhdGVkU3RvcmFnZQpHZXRTZXJ2aWNlB1BsYXllcnMLTG9jYWxQbGF5ZXIJd29ya3NwYWNlDUN1cnJlbnRDYW1lcmEHcmVxdWlyZQdNb2R1bGVzBlNoYXJlZAlVdGlsaXRpZXMMQ2FtZXJhU2hha2VyA25ldwRFbnVtDlJlbmRlclByaW9yaXR5BkNhbWVyYQVWYWx1ZRlHZXRBdHRyaWJ1dGVDaGFuZ2VkU2lnbmFsB0Nvbm5lY3QFU3RhcnQABAMBAQAABgMAAAUBBwf7AQAATQIBhQAAAAAJAgIAMAIBhQAAAACCAAEAAQMBAAkAARgAAAAAAAABCgAAAAADAAIAAAAH+wABAG8CAAC8AAASAQAAAJ8AAwLeAAAAggABAAIDAgMDAA8AARgAAAAAAAABEAAAAAAOBgMAAAsIAAAFBgICAgIIiBX7BgAAKwYHAPsGAQBvCAAAvAYGEgEAAACfBgMCDQYCAAIAAICCAAEA+wYCAFIIAABSCQEAUgoCAFILAwBSDAQAUg0FALwGBt0DAAAAnwYIAIIGAAAEAwQDAwIAAAAAAAAAAAMFABUAARgAAAAAAAAAAAABAwAAAAAAAAAAAAAWAAAAAAoAAAECADyjAAAApAABAAAAAEBvAgIAvAAAFgMAAACfAAMCpAEBAAAAAEBvAwQAvAEBFgMAAACfAQMCTQIBMQUAAACkBAcAAABgQE0DBEgIAAAApAQKAAAAkEBNCADoCwAAAE0HCBIMAAAATQYHtQ0AAABNBQbgDgAAAJ8EAgJNBQTvDwAAAKQIFAATSBDBTQcI7BUAAACVBgcQwAcWABIAAwCfBQMCqQYAAG8JFwC8BwIWGAAAAJ8HAwLZCQEAEgEG/xIAAgC8BwfHGQAAAJ8HAwG8BwUcGgAAAJ8HAgHZBwIAEgEG/xIAAgASAAUAwQYAAIIHAgAbAwYEAAAAQAMHAwgDCQMKAwsEAABgQAMMAw0EAACQQAMOAw8DEAMRAxICAAAAAAAAJEADEwMUAxUEE0gQwQMWBgADAgMXAxgDGQMAAQIBAAEYAAAAAAAAAAEAAAAAAAIAAQAAAAIAAAAAAAAAAAAAAgAAAAAAAAAAAAQCAAAAAAAAAAAABAAAAgAAAAAAAQAAAAADpBgD/g7ZiySW3Glq5IopfCpKUq6H8uEQ3l0lY3V7PYs5gM2LjBPi3g==

local l_ReplicatedStorage_0 = game:GetService("ReplicatedStorage");
local l_LocalPlayer_0 = game:GetService("Players").LocalPlayer;
local l_CurrentCamera_0 = workspace.CurrentCamera;
local v5 = require(script.CameraShaker).new(Enum.RenderPriority.Camera.Value + 10, function(v3) --[[ Line: 9 ]]
    -- upvalues: l_CurrentCamera_0 (copy)
    local l_l_CurrentCamera_0_0 = l_CurrentCamera_0;
    l_l_CurrentCamera_0_0.CFrame = l_l_CurrentCamera_0_0.CFrame * v3;
end);
local v6 = false;
l_LocalPlayer_0:GetAttributeChangedSignal("CannotCameraShake"):Connect(function() --[[ Line: 15 ]]
    -- upvalues: v6 (ref), l_LocalPlayer_0 (copy)
    v6 = l_LocalPlayer_0:GetAttribute("CannotCameraShake");
end);
v5:Start();
return function(v7, v8, v9, v10, v11, v12) --[[ Line: 21 ]]
    -- upvalues: v6 (ref), l_LocalPlayer_0 (copy), v5 (copy)
    if v6 or l_LocalPlayer_0:GetAttribute("Camera_Shake") == 0 then
        return;
    else
        return v5:Fire(v7, v8, v9, v10, v11, v12);
    end;
end;
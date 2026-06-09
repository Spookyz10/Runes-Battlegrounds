-- Saved by UniversalSynSaveInstance (Join to Copy Games) https://discord.gg/wx4ThpAsmw

-- Bytecode (Base64):
-- BgMaBkNvbG9yMwdmcm9tUkdCBmFjdGlvbgp0b2dnbGVhYmxlBW90aGVyCnJlc2l6ZUluZm8OcmVwb3NpdGlvbkluZm8JVHdlZW5JbmZvA25ldwRFbnVtC0Vhc2luZ1N0eWxlBEJhY2sKZGVzZWxlY3RlZAhzZWxlY3RlZBFpY29uR3JhZGllbnRDb2xvchRpY29uR3JhZGllbnRSb3RhdGlvbhFub3RpY2VDaXJjbGVDb2xvchFub3RpY2VDaXJjbGVJbWFnZQ9ub3RpY2VUZXh0Q29sb3IUY2FwdGlvbk92ZXJsaW5lQ29sb3INQ29sb3JTZXF1ZW5jZSpodHRwOi8vd3d3LnJvYmxveC5jb20vYXNzZXQvP2lkPTQ4ODI0MzAwMDUTaWNvbkJhY2tncm91bmRDb2xvchppY29uQmFja2dyb3VuZFRyYW5zcGFyZW5jeQ5pY29uSW1hZ2VDb2xvcg1pY29uVGV4dENvbG9yAAEKAAABAgBxowAAAKQAAgAABACAjAEAAIwCqgCMA/8AnwAEAqQBAgAABACAjAIAAIwDeACMBLQAnwEEAqQCAgAABACAjAP/AIwE/wCMBf8AnwIEAuIDBgDiBAkApAUMAAAsoIBvBg0ApAcRABA84MCfBQMCMAUEXwcAAACkBQwAACyggG8GDQCkBxEAEDzgwJ8FAwIwBQTACAAAADAEA2IDAAAA4gQUAOIFGwCkBh0AACzAgVIHAABSCAEAnwYDAjAGBUwVAAAAjAZaADAGBYAWAAAAMAAFFxcAAABvBh4AMAYFUhgAAAAwAgUvGQAAADAABXkaAAAAMAUE3hIAAADiBSMApAYCAAAEAICMB/8AjAj/AIwJ/wCfBgQCMAYFeh8AAABvBiQAMAYFYCAAAACkBh0AACzAgVIHAABSCAEAnwYDAjAGBUwVAAAAjAZaADAGBYAWAAAApAYCAAAEAICMB/8AjAj/AIwJ/wCfBgQCMAYFSiEAAACkBgIAAAQAgIwH/wCMCP8AjAn/AJ8GBAIwBgWIIgAAADACBRcXAAAAMAAFLxkAAAAwBQRNEwAAADAEA7AEAAAA/wQAAAAAAAAwBAPABQAAAIIDAgAlAwEDAgQABACAAwMDBAMFBQMDBAUDBgMHBQIHCAMIAwkEACyggAKamZmZmZnJPwMKAwsDDAQQPODAAw0DDgUCEhMDDwMQAxEDEgMTAxQFBhUWFxgZGgMVBAAswIEDFgMXAxgDGQMaBQgfIBUWISIXGQKamZmZmZm5PwABAAEYAAEAAAAAAAEAAAAAAAEAAAAAAAEDAQAAAAAAAAABAAAAAAAAAP4ABgIBAAAAAAAAAQAAAQABAAABAAEA+gAKAQAAAAAAAAABAAABAAAAAAAAAQAAAQAAAAAAAAABAAAAAAAAAAEAAQD4APQAGQAAAAABAAAAAAA72F0GkRnV3AkcN5KHY43pvOqqgwHpWX2wOGsV/HGujrmTz65dYoWR

local v0 = Color3.fromRGB(0, 170, 255);
local v1 = Color3.fromRGB(0, 120, 180);
local v2 = Color3.fromRGB(255, 255, 255);
return {
    action = {
        resizeInfo = TweenInfo.new(0.2, Enum.EasingStyle.Back), 
        repositionInfo = TweenInfo.new(0.2, Enum.EasingStyle.Back)
    }, 
    toggleable = {
        deselected = {
            iconGradientColor = ColorSequence.new(v0, v1), 
            iconGradientRotation = 90, 
            noticeCircleColor = v0, 
            noticeCircleImage = "http://www.roblox.com/asset/?id=4882430005", 
            noticeTextColor = v2, 
            captionOverlineColor = v0
        }, 
        selected = {
            iconBackgroundColor = Color3.fromRGB(255, 255, 255), 
            iconBackgroundTransparency = 0.1, 
            iconGradientColor = ColorSequence.new(v0, v1), 
            iconGradientRotation = 90, 
            iconImageColor = Color3.fromRGB(255, 255, 255), 
            iconTextColor = Color3.fromRGB(255, 255, 255), 
            noticeCircleColor = v2, 
            noticeTextColor = v0
        }
    }, 
    other = {}
};

local ReplicatedStorage_upvr = game:GetService("ReplicatedStorage")
local module = {}
local Utility_upvr = require(ReplicatedStorage_upvr.Utility)
local LocalPlayer_upvr = Utility_upvr.Services.Players.LocalPlayer
if not LocalPlayer_upvr then
    LocalPlayer_upvr = Utility_upvr.Services.Players.PlayerAdded:Wait()
end
local mouse_2_upvr = LocalPlayer_upvr:GetMouse()
local tbl_2_upvr = {Enum.KeyCode.E, Enum.KeyCode.R, Enum.KeyCode.T, Enum.KeyCode.Y, Enum.KeyCode.G, Enum.KeyCode.H}
local PlayerGui_upvr = LocalPlayer_upvr.PlayerGui

function module.CLASH(arg1, arg2)
    local var67 = arg1
    if not var67 then
        var67 = tbl_2_upvr[math.random(1, #tbl_2_upvr)]
    end
    local var68_upvw = var67
    local var69_upvw = 0
    local clone_2_upvr = ReplicatedStorage_upvr.Resources.UIs.CLASH:Clone()
    clone_2_upvr.Parent = LocalPlayer_upvr.PlayerGui.MainScreen
    clone_2_upvr.GroupTransparency = 1
    clone_2_upvr.Frame.Keybind.Text = var68_upvw.Name
    Utility_upvr.Services.Tween:Create(clone_2_upvr, TweenInfo.new(0.35), {
        GroupTransparency = 0;
    }):Play()
    local var72_upvw = 0
    local function addPoint_upvr() 
        Utility_upvr.Modules.GuiShakerModule:ShakeOnce(clone_2_upvr, 1, 0.5, 0)
        clone_2_upvr.Frame.Size = UDim2.new(0.11800000000000001, 0, 0.16999999999999998, 0)
        clone_2_upvr.Frame.Click.ImageTransparency = 0
        Utility_upvr.Services.Tween:Create(clone_2_upvr.Frame.Click, TweenInfo.new(0.2), {
            ImageTransparency = 1;
        }):Play()
        Utility_upvr.Services.Tween:Create(clone_2_upvr.Frame, TweenInfo.new(0.3), {
            Size = UDim2.new(0.068, 0, 0.12, 0);
        }):Play()
        var69_upvw += 1
        var72_upvw += 0.15
        clone_2_upvr.Frame.Score.Text = `x{var69_upvw}`
        Utility_upvr.Modules.soundPlaying:play(ReplicatedStorage_upvr.Resources.UIs.CLASHS, Utility_upvr.Services.Sound).PitchShiftSoundEffect.Octave = var72_upvw
    end
    local var75
    if Utility_upvr.Services.UserInputService.TouchEnabled then
        clone_2_upvr.Frame.Keybind.Text = "Click"
        var75 = clone_2_upvr.Frame.Button.MouseButton1Click:Connect(addPoint_upvr)
    else
        var75 = Utility_upvr.Services.UserInputService.InputBegan:Connect(function(arg1_4, arg2_4) 
            if arg2_4 then
            elseif arg1_4.KeyCode == var68_upvw then
                addPoint_upvr()
            end
        end)
    end
    repeat
        task.wait()
    until arg2 <= os.clock() - os.clock()
    var75:Disconnect()
    Utility_upvr.Services.Tween:Create(clone_2_upvr, TweenInfo.new(0.35), {
        GroupTransparency = 1;
    }):Play()
    Utility_upvr.Services.Debris:AddItem(clone_2_upvr, 0.35)
    return var69_upvw
end

return module
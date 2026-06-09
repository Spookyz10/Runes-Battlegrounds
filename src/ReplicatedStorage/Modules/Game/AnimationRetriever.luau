local AnimationRetriever = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = game:GetService("Players").LocalPlayer
local JobModule = require(ReplicatedStorage.Modules.Game.Job)
local AenoirUtil = require(ReplicatedStorage.Modules.Game.Utility.AenoirUtil)
local ActiveJobs = {}

AnimationRetriever.RemoveActive = function(model)
    if ActiveJobs[model] then
        ActiveJobs[model]:Destroy()
    end
end

AnimationRetriever.new = function(model, animationTrack)
    if model == nil or model.Parent == nil then
        return
    else
        AnimationRetriever.RemoveActive(model)

		if animationTrack == nil then
			return
        else
            local job = JobModule.new()
            job:Task(function()
                if ActiveJobs[model] then
                    ActiveJobs[model] = nil
                end
            end)

            job:Task(model.AncestryChanged:Connect(function(_, parent)
                if parent == nil then
                    AnimationRetriever.RemoveActive(model)
                end
            end))

            job:Task(animationTrack.Stopped:Connect(function()
                AnimationRetriever.RemoveActive(model)
            end))

            ActiveJobs[model] = job

            return {
                Animation = animationTrack,
				Job = job,
				IsLocalSource = LocalPlayer.Character == model
            }
        end
    end
end

return AnimationRetriever
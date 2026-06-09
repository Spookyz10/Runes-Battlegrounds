local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Effects = {
	Require = require(ReplicatedStorage.Effects),
	VFXS  = ReplicatedStorage.Effects
}
ReplicatedStorage.Replicated.OnClientEvent:Connect(function(args,...)
	if typeof(args) ~= 'table' then return end
	if Effects[args[1]] then
		if args[1] == 'Require' then
			if Effects.Require[args[2]] then
				Effects.Require[args[2]](...)
			end
		else
			local Modules = ReplicatedStorage.Effects:FindFirstChild(args[2])
			if Modules and Modules:IsA('ModuleScript') then
				require(Modules)[args[3]](...)
			end
		end
	end
end)

ReplicatedStorage.DomainControl.OnClientInvoke = function(args,...)
	if args.Request == 'Clash' then
		require(ReplicatedStorage.Replicator).CLASH(...)
	end
end
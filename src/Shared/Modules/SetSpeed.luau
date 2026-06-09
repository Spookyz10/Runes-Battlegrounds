local module = {}
local starttime = {}
local rs = game:GetService("RunService")
local newspeed
function module:ChangeSpeed(hum,speed,jumpheight,time, uselowestspeed)
	local connection
	newspeed = speed
	starttime[hum.Parent] = tick()
	connection = rs.Heartbeat:Connect(function()
		if tick() - starttime[hum.Parent] >= time then
			connection:Disconnect()
			hum.WalkSpeed = 16
			hum.JumpHeight = 7.2
		else
			if uselowestspeed then
				if newspeed < speed then
					hum.WalkSpeed = newspeed
					hum.JumpHeight = jumpheight
				else
					hum.WalkSpeed = speed
					hum.JumpHeight = jumpheight
				end
			else
				hum.WalkSpeed = newspeed
				hum.JumpHeight = jumpheight
			end
		end
	end)
end

return module

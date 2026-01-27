local testoTimer = script.Parent.TextLabel

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvent = ReplicatedStorage:WaitForChild("SincronizzaTempo")

local function CambiaTesto(timerValue, text)
	if timerValue > 0 then
		while timerValue > 0 do
			testoTimer.Text = text .. tostring(timerValue)
			wait(1)
			timerValue -= 1
		end
	else
		testoTimer.Text = text
	end
end

RemoteEvent.OnClientEvent:Connect(function(timerValue, text)
	CambiaTesto(timerValue, text)
end)

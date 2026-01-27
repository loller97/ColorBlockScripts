local Players = game:GetService("Players")
local teleport = script.Parent
local partsLobby = workspace.TeleportsLobby:GetChildren()
local teleportPointsLobby = {}

for _, part in pairs(partsLobby) do
	local position = part.Position + Vector3.new(0,2,0)
	table.insert(teleportPointsLobby, position)
end

local function getRandomTeleportPoint(spawns)
	local randomIndex = math.random(1, #spawns)
	return spawns[randomIndex]
end

local function LoseTeleport(part)
	local character = part.Parent
	if character:IsA("Model") and character:FindFirstChild("HumanoidRootPart") then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		humanoidRootPart.CFrame = CFrame.new(getRandomTeleportPoint(teleportPointsLobby))
		local player = Players:GetPlayerFromCharacter(character)
		if player then
			player:SetAttribute("tag", nil)
		end
	end
end

teleport.Touched:Connect(LoseTeleport)

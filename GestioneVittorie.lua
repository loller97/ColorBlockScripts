local DataStoreService = game:GetService("DataStoreService")
local WinsDataStore = DataStoreService:GetDataStore("WinsDataStore")

local function CaricaVittorieGiocatore(giocatore)
	local successo, vittorie = pcall(function()
		return WinsDataStore:GetAsync(giocatore.UserId)
	end)
	
	if successo then
		local folder = Instance.new("Folder", giocatore)
		folder.Name = "leaderstats"
		local wins = Instance.new("IntValue", folder)
		wins.Name = "Wins"
		wins.Value = vittorie or 0
	end
end

game.Players.PlayerAdded:Connect(function(giocatore)
	CaricaVittorieGiocatore(giocatore)
end)

local DataStoreService = game:GetService("DataStoreService")
local WinsDataStore = DataStoreService:GetDataStore("WinsDataStore")

local pezziDellaLobby = workspace.TeleportsLobby:GetChildren()

local teletrasportiNelGioco = {}
local teletrasportiNellaLobby = {}

local giocatori = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RoundTimer = require(ReplicatedStorage:WaitForChild("ModuleScript"))

-- Riferimenti agli oggetti IntValue che memorizzano il numero di voti
local VotiMap1 = ReplicatedStorage:FindFirstChild("Map1")
local VotiMap2 = ReplicatedStorage:FindFirstChild("Map2")
-- Il riferimento a ServerStorage (il luogo in cui vengono memorizzate le mappe)
local ServerStorage = game:GetService("ServerStorage")
-- Riferimenti alle cartelle con le nostre mappe
local mappa1 = ServerStorage:WaitForChild("Map1")
local mappa2 = ServerStorage:WaitForChild("Map2")

local vincitore = ReplicatedStorage:WaitForChild("Winner")
local spawnVincitore = workspace.SpawnVincitore

local RemoteEvent = ReplicatedStorage:WaitForChild("SincronizzaTempo")

-- Raccoglie le posizioni per i teletrasporti


for _, part in ipairs(pezziDellaLobby) do
	local posizione = part.Position + Vector3.new(0, 2, 0)
	table.insert(teletrasportiNellaLobby, posizione)
end

-- Funzione per trovare un punto di teletrasporto casuale
local function PuntoDiTeleportACaso(spawn)
	local numero = math.random(1, #spawn)
	return spawn[numero]
end

-- Teletrasporta il giocatore in un punto casuale
local function TeletrasportaGiocatoreInPuntoACaso(giocatore, spawn)
	local character = giocatore.Character
	if character then
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if rootPart then
			rootPart.CFrame = CFrame.new(PuntoDiTeleportACaso(spawn))
		end
	end
end

local function CopiaVincitore(nome)
	local character = game.Players[nome].Character
	character.archivable = true
	clone = character:Clone()
	
	local humanoidRootPart = clone:FindFirstChild("HumanoidRootPart")
	humanoidRootPart.CFrame = CFrame.new(spawnVincitore.Position + Vector3.new(0, 2, 0))
	clone.Parent = workspace
	clone:ScaleTo(8)
	
	local humanoid = clone:FindFirstChild("Humanoid")
	-- Creare l'oggetto animazione
	local animation = Instance.new("Animation")
	-- Assegnare l'animazione
	animation.AnimationId = "rbxassetid://15122972413"
	-- Caricare l'animazione sul clone
	local animationTrack = humanoid:LoadAnimation(animation)
	-- Avviare l'animazione, che verrà eseguita all'infinito
	animationTrack:Play()
end

--qua è dove gestisce tutto il gioco letteralmente
while true do
	RoundTimer.WaitPlayersTime = true
	while #giocatori:GetPlayers() < 2 do
		RemoteEvent:FireAllClients(0, "Aspettando i giocatori")
		wait()
	end
	RoundTimer.WaitPlayersTime = false
	
	RoundTimer.VoteStart = true
	RemoteEvent:FireAllClients(RoundTimer.VoteTime, "Vota per la mappa! : ")
	wait(RoundTimer.VoteTime)
	RoundTimer.VoteStart = false
	
	local sceltaCausale = math.random(1, 2)
	--prendo la mappa in base ai voti
	--sistemato aggiungendo .Value
	if VotiMap1.Value > VotiMap2.Value then
		parti = mappa1:GetChildren()
	elseif VotiMap2.Value > VotiMap1.Value then
		parti = mappa2:GetChildren()
	else
		if sceltaCausale == 1 then
			parti = mappa1:GetChildren()
		else
			parti = mappa2:GetChildren()
		end
	end
	
	--carica la mappa nel workspace
	for _, parte in pairs(parti) do
		local nuovParte = parte:Clone()
		nuovParte.Parent = workspace.LevelParts
	end
	
	local pezziDelGioco = workspace.LevelParts:GetChildren()
	
	for _, part in ipairs(pezziDelGioco) do
		local posizione = part.Position + Vector3.new(0, 2, 0)
		table.insert(teletrasportiNelGioco, posizione)
	end
	
	RemoteEvent:FireAllClients(RoundTimer.RestTime, "Tempo di attesa: ")
	
	wait(RoundTimer.RestTime)
	
	for _, giocatore in ipairs(game.Players:GetPlayers()) do
		giocatore:SetAttribute("tag", "match")
		TeletrasportaGiocatoreInPuntoACaso(giocatore, teletrasportiNelGioco)
	end
	
	RemoteEvent:FireAllClients(RoundTimer.PreparationTime, "Preparazione: ")
	wait(RoundTimer.PreparationTime)
	RoundTimer.GameTime = true
	
	while wait() do	
		-- Creare un array vuoto 
		local playersWithTag = {}
		-- Passare in rassegna tutti i giocatori del gioco
		for _, player in pairs(giocatori:GetPlayers()) do
			-- Assicurarsi che il giocatore abbia l'attributo “Match”	
			local tagAttribute = player:GetAttribute("tag", "match")
			-- In caso affermativo, li aggiungiamo all'array dichiarato in precedenza
			if tagAttribute then
				table.insert(playersWithTag, player)
			end
		end
		
		if #playersWithTag == 1 then
			vincitore.Value = playersWithTag[1].Name
			RoundTimer.GameTime = false
			break
		elseif #playersWithTag < 1 then
			winner.Value = ""
			RoundTimer.GameTime = false
			break
		end
		
	end	
	
	for _, giocatore in ipairs(game.Players:GetPlayers()) do
		if giocatore:GetAttribute("tag", "match") then
			
			local classifica = giocatore:WaitForChild("leaderstats")
			local vittorie = classifica:FindFirstChild("Wins")
			vittorie.Value = vittorie.Value + 1
			WinsDataStore:SetAsync(giocatore.UserId, vittorie.Value)
			
			giocatore:SetAttribute("tag", nil)
			TeletrasportaGiocatoreInPuntoACaso(giocatore, teletrasportiNellaLobby)
		end
	end
	
	--dimenticato vincitore.Value qua
	if vincitore.Value ~= "" then
		CopiaVincitore(vincitore.Value)
		RemoteEvent:FireAllClients(0, "Il vincitore è: " .. vincitore.Value)
	else
		RemoteEvent:FireAllClients(0, "Non ha vinto nessuno :c")
	end
	
	
	for _, parte in pairs(pezziDelGioco) do
		parte:Destroy()
	end
	
	wait(RoundTimer.WinnerTime)
	if vincitore.Value ~= "" then
		clone:Destroy()
	end
	
end

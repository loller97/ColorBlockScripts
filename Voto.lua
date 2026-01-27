-- Riferimento al pulsante della prima piattaforma
local bottonePrimaMappa = game.Workspace.VotePlatform.VoteFirstMap.VoteButton
-- Riferimento al pulsante della seconda piattaforma
local bottoneSecondaMappa = game.Workspace.VotePlatform.VoteSecondMap.VoteButton
-- Il riferimento all'elemento di testo che rappresenta i voti sulla prima piattaforma
local scrittaPrimaMappa = bottonePrimaMappa.Parent.VoteCount.SurfaceGui.TextLabel
-- Il riferimento all'elemento di testo che rappresenta i voti sulla seconda piattaforma
local scrittaSecondaMappa = bottoneSecondaMappa.Parent.VoteCount.SurfaceGui.TextLabel
-- Le variabili del contatore che memorizzeranno i voti per ogni mappa
local contoPrimaMappa = 0
local contoSecondaMappa = 0

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RoundTimer = require(ReplicatedStorage:WaitForChild("ModuleScript"))

local contoMap1 = ReplicatedStorage:FindFirstChild("Map1")
local contoMap2 = ReplicatedStorage:FindFirstChild("Map2")

-- Questa funzione richiede:
-- il pulsante, l'altro pulsante, gli IntValues di entrambi i pulsanti,
-- il numero di voti in entrambi i pulsanti, nonché il testo sul contatore dei pulsanti.
-- Infine, ha bisogno delle informazioni sul giocatore che ha calpestato il pulsante.
local function Vote(button, otherButton, storage, otherStorage, count, otherCount, text, otherText, hit)
	local giocatore = game.Players:GetPlayerFromCharacter(hit.Parent)
	if giocatore and not button:FindFirstChild(giocatore.Name) and not otherButton:FindFirstChild(giocatore.Name) then
		local vote = Instance.new("StringValue")
		vote.Name = giocatore.Name
		--aggiustato aggiungendo la riga sotto
		vote.Parent = button
		storage.Value += 1
		count = storage.Value
		text.Text = "Count: " .. tostring(count)
	elseif giocatore and not button:FindFirstChild(giocatore.Name) and otherButton:FindFirstChild(giocatore.Name) then
		local vote = Instance.new("StringValue")
		vote.Name = giocatore.Name
		--same
		vote.Parent = button
		storage.Value += 1
		count = storage.Value
		text.Text = "Count: " .. tostring(count)
		
		otherButton:FindFirstChild(giocatore.Name):Destroy()
		otherStorage.Value -= 1
		otherCount = otherStorage.Value
		otherText.Text = "Count" .. tostring(otherCount)
	end
end

bottonePrimaMappa.Touched:Connect(function(hit)
	if RoundTimer.VoteStart then
		Vote(bottonePrimaMappa, bottoneSecondaMappa, contoMap1, contoMap2, contoPrimaMappa, contoSecondaMappa, scrittaPrimaMappa, scrittaSecondaMappa, hit)
	end
end)

bottoneSecondaMappa.Touched:Connect(function(hit)
	if RoundTimer.VoteStart then
		Vote(bottoneSecondaMappa, bottonePrimaMappa, contoMap2, contoMap1, contoSecondaMappa, contoPrimaMappa, scrittaSecondaMappa, scrittaPrimaMappa, hit)
	end
end)

game:GetService("RunService").Heartbeat:Connect(function()
	if RoundTimer.VoteStart == false then
		scrittaPrimaMappa.Text = "Count: 0"
		scrittaSecondaMappa.Text = "Count: 0"
		contoPrimaMappa = 0
		contoSecondaMappa = 0
		
		for _, nome in ipairs(bottonePrimaMappa:GetChildren()) do
			if nome:IsA("StringValue") then
				nome:Destroy()
			end
		end
		for _, nome in ipairs(bottoneSecondaMappa:GetChildren()) do
			if nome:IsA("StringValue") then
				nome:Destroy()
			end
		end
	end
end)

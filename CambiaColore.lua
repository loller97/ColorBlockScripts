local colori = {
	BrickColor.new("Really red"),
	BrickColor.new("Really blue"),
	BrickColor.new("Lime green"),
	BrickColor.new("New Yeller"),
	BrickColor.new("Magenta"),
	BrickColor.new("Cyan"),
	BrickColor.new("Neon orange"),
	BrickColor.new("Royal purple")
}

local coloriUsati = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RoundTimer = require(ReplicatedStorage:WaitForChild("ModuleScript"))

local RemoteEvent = ReplicatedStorage:WaitForChild("SincronizzaTempo")

local function ColoreRandom(parte)
	local coloriDisponibili = {}
	for _, colore in ipairs(colori) do
		if not coloriUsati[colore.Number] then
			table.insert(coloriDisponibili, colore)
		end
	end
	
	--nel caso in cui non ci siano più colori disponibili
	if #coloriDisponibili == 0 then
		coloriUsati = {}
		coloriDisponibili = colori
	end
	
	local numero = math.random(1, #coloriDisponibili)
	local coloreScelto = coloriDisponibili[numero]
	
	parte.BrickColor = coloreScelto
	coloriUsati[coloreScelto.Number] = true
end

local function CambiaColori()
	while true do
		wait()
		while RoundTimer.GameTime do
			local coloreRound = colori[math.random(1, #colori)]
			print(coloreRound)
			local parti = workspace.LevelParts:GetChildren()
			for _, parte in ipairs(parti) do
				ColoreRandom(parte)
			end
			
			RemoteEvent:FireAllClients(RoundTimer.RoundTime, "Vai sul colore " .. tostring(coloreRound) .. " tempo rimasto: ")
			
			wait(RoundTimer.RoundTime)
			
			for _, parte in ipairs(parti) do
				--ALT 126 = ~
				if parte.BrickColor ~= coloreRound then
					parte.Transparency = 1
					parte.CanCollide = false
				end
			end
			
			RemoteEvent:FireAllClients(0, "Preparati per il prossimo Round!")
			
			wait(RoundTimer.RoundTime)
			
			for _, parte in ipairs(parti) do
				parte.Transparency = 0
				parte.CanCollide = true
			end
		end
	end
end

CambiaColori()

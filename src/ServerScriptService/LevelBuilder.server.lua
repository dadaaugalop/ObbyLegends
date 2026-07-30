--[[
	LevelBuilder.server.lua (Script)
	Emplacement dans Studio : ServerScriptService > LevelBuilder

	Construit automatiquement, au démarrage du serveur (ou en appuyant sur
	Play dans Studio) :
	- le Lobby (plateforme de spawn)
	- les 10 premiers niveaux du Monde 1, chacun terminé par un checkpoint

	But : avoir un prototype jouable tout de suite, sans construction manuelle.
	Tu pourras ensuite éditer/décorer ces parts à la main dans Studio, ou
	relancer ce script pour régénérer une nouvelle base si besoin (il ne fait
	rien si "World1" existe déjà dans Workspace, pour ne pas écraser ton travail).

	Chaque checkpoint reçoit :
	- le tag CollectionService "Checkpoint" (lu par CheckpointService)
	- les attributs World (number) et Index (number)
]]

local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")

local GameConfig = require(game:GetService("ReplicatedStorage").Modules.GameConfig)

if Workspace:FindFirstChild("World1") then
	-- Déjà construit : on ne touche à rien pour préserver le travail existant.
	return
end

local PLATFORM_SIZE = GameConfig.Level.PlatformSize
local GAP = GameConfig.Level.GapDistance
local START_POS = GameConfig.Level.StartPosition

local function makePart(name, size, cframe, color, parent)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Anchored = true
	part.Color = color
	part.Material = Enum.Material.SmoothPlastic
	part.Parent = parent
	return part
end

-- === LOBBY ===
local lobby = Instance.new("Folder")
lobby.Name = "Lobby"
lobby.Parent = Workspace

local baseplate = makePart(
	"Baseplate",
	Vector3.new(60, 4, 60),
	CFrame.new(START_POS - Vector3.new(0, 8, 0)),
	Color3.fromRGB(90, 200, 120),
	lobby
)

local spawnLocation = Instance.new("SpawnLocation")
spawnLocation.Name = "MainSpawn"
spawnLocation.Size = Vector3.new(6, 1, 6)
spawnLocation.CFrame = CFrame.new(START_POS - Vector3.new(0, 5.5, 0))
spawnLocation.Anchored = true
spawnLocation.Transparency = 0.5
spawnLocation.Color = Color3.fromRGB(120, 170, 255)
spawnLocation.Parent = lobby

local signPart = makePart(
	"World1Sign",
	Vector3.new(8, 6, 1),
	CFrame.new(START_POS + Vector3.new(0, 2, GAP * 0.6)),
	Color3.fromRGB(40, 40, 50),
	lobby
)

local billboard = Instance.new("BillboardGui")
billboard.Size = UDim2.new(0, 200, 0, 50)
billboard.StudsOffset = Vector3.new(0, 1, 0)
billboard.AlwaysOnTop = true
billboard.Parent = signPart

local signLabel = Instance.new("TextLabel")
signLabel.Size = UDim2.new(1, 0, 1, 0)
signLabel.BackgroundTransparency = 1
signLabel.Text = "MONDE 1 - LES PLAINES"
signLabel.TextColor3 = Color3.new(1, 1, 1)
signLabel.Font = Enum.Font.GothamBold
signLabel.TextSize = 20
signLabel.Parent = billboard

-- === MONDE 1 : 10 premiers niveaux ===
local world1 = Instance.new("Folder")
world1.Name = "World1"
world1.Parent = Workspace

local LEVEL_COUNT = 10 -- V0.1 : les 10 premiers niveaux (les 40 suivants arrivent en V0.2)

for i = 1, LEVEL_COUNT do
	local levelFolder = Instance.new("Folder")
	levelFolder.Name = ("Level_%02d"):format(i)
	levelFolder.Parent = world1

	local offset = Vector3.new(0, 0, GAP * (i + 1))
	local platformCFrame = CFrame.new(START_POS + offset)

	makePart(
		"Platform",
		PLATFORM_SIZE,
		platformCFrame,
		Color3.fromRGB(150, 150, 160),
		levelFolder
	)

	-- Checkpoint : petite dalle lumineuse posée sur la plateforme
	local checkpoint = makePart(
		"Checkpoint",
		Vector3.new(6, 0.5, 6),
		platformCFrame + Vector3.new(0, PLATFORM_SIZE.Y / 2 + 0.3, 0),
		Color3.fromRGB(255, 215, 0),
		levelFolder
	)
	checkpoint.Material = Enum.Material.Neon
	checkpoint.CanCollide = false

	checkpoint:SetAttribute("World", 1)
	checkpoint:SetAttribute("Index", i)
	CollectionService:AddTag(checkpoint, "Checkpoint")

	local levelLabel = Instance.new("BillboardGui")
	levelLabel.Size = UDim2.new(0, 100, 0, 30)
	levelLabel.StudsOffset = Vector3.new(0, 3, 0)
	levelLabel.AlwaysOnTop = true
	levelLabel.Parent = checkpoint

	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(1, 0, 1, 0)
	text.BackgroundTransparency = 1
	text.Text = ("Niveau %d"):format(i)
	text.TextColor3 = Color3.new(1, 1, 1)
	text.Font = Enum.Font.GothamBold
	text.TextSize = 16
	text.Parent = levelLabel
end

print(("[LevelBuilder] Lobby + %d niveaux du Monde 1 générés."):format(LEVEL_COUNT))

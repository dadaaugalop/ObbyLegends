--[[
	CheckpointService.server.lua (Script)
	Emplacement dans Studio : ServerScriptService > CheckpointService

	Gère les checkpoints de l'obby :
	- chaque checkpoint est un Part taggé "Checkpoint" (CollectionService) avec
	  deux attributs : World (number, ex: 1) et Index (number, ex: 3)
	- quand un joueur touche un checkpoint plus avancé que son record actuel,
	  on met à jour son Stage, on sauvegarde sa progression et on lui donne
	  des Coins de récompense
	- quand le personnage du joueur apparaît, il est téléporté à son dernier
	  checkpoint atteint (ou au lobby s'il n'a encore rien atteint)

	Le générateur de niveaux (LevelBuilder) est responsable de créer les
	parts et de leur poser les bons attributs.
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local GameConfig = require(game:GetService("ReplicatedStorage").Modules.GameConfig)
local DataManager = require(ServerScriptService.DataManager)

local CHECKPOINT_TAG = "Checkpoint"

-- Index rapide : checkpoints[world][index] = BasePart
local checkpointsIndex = {}

local function registerCheckpoint(part)
	local world = part:GetAttribute("World")
	local index = part:GetAttribute("Index")
	if not world or not index then
		warn(("[CheckpointService] %s n'a pas d'attributs World/Index"):format(part:GetFullName()))
		return
	end

	checkpointsIndex[world] = checkpointsIndex[world] or {}
	checkpointsIndex[world][index] = part
end

for _, part in ipairs(CollectionService:GetTagged(CHECKPOINT_TAG)) do
	registerCheckpoint(part)
end
CollectionService:GetInstanceAddedSignal(CHECKPOINT_TAG):Connect(registerCheckpoint)

local function worldKey(worldNumber)
	return "World" .. tostring(worldNumber)
end

local function globalStage(world, index)
	return (world - 1) * 50 + index
end

local function getSpawnCFrame(player)
	local data = DataManager.Get(player)
	if not data then
		return nil
	end

	-- Cherche le monde/checkpoint le plus avancé atteint par le joueur
	local bestWorld, bestIndex = nil, 0
	for worldNumber = 1, #GameConfig.Worlds do
		local reached = data.Checkpoints[worldKey(worldNumber)] or 0
		if reached > 0 then
			bestWorld, bestIndex = worldNumber, reached
		end
	end

	if bestWorld and checkpointsIndex[bestWorld] and checkpointsIndex[bestWorld][bestIndex] then
		local part = checkpointsIndex[bestWorld][bestIndex]
		return part.CFrame + Vector3.new(0, 5, 0)
	end

	-- Aucun checkpoint atteint : on renvoie au lobby (SpawnLocation par défaut)
	return nil
end

local function onCharacterAdded(player, character)
	local cframe = getSpawnCFrame(player)
	if not cframe then
		return
	end

	local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
	if humanoidRootPart then
		character:PivotTo(cframe)
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)
end)

local function onCheckpointTouched(part, hit)
	local character = hit:FindFirstAncestorOfClass("Model")
	if not character then
		return
	end

	local player = Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end

	local data = DataManager.Get(player)
	if not data then
		return
	end

	local world = part:GetAttribute("World")
	local index = part:GetAttribute("Index")
	if not world or not index then
		return
	end

	local key = worldKey(world)
	local currentBest = data.Checkpoints[key] or 0

	if index > currentBest then
		data.Checkpoints[key] = index

		local newStage = globalStage(world, index)
		if newStage > data.Stage then
			data.Stage = newStage
			local leaderstats = player:FindFirstChild("leaderstats")
			if leaderstats then
				leaderstats.Stage.Value = newStage
			end
		end

		-- Récompense de progression
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			leaderstats.Coins.Value = leaderstats.Coins.Value + GameConfig.CoinsPerCheckpoint
		end
	end
end

CollectionService:GetInstanceAddedSignal(CHECKPOINT_TAG):Connect(function(part)
	part.Touched:Connect(function(hit)
		onCheckpointTouched(part, hit)
	end)
end)

for _, part in ipairs(CollectionService:GetTagged(CHECKPOINT_TAG)) do
	part.Touched:Connect(function(hit)
		onCheckpointTouched(part, hit)
	end)
end

--[[
	Main.server.lua (Script)
	Emplacement dans Studio : ServerScriptService > Main

	Point d'entrée serveur pour la V0.1 :
	- crée les leaderstats (Stage, Coins, Gems) pour chaque joueur
	- charge/sauvegarde les données via DataManager
	- boucle de sauvegarde automatique
	- sauvegarde à la fermeture du serveur (BindToClose)
]]

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local GameConfig = require(game:GetService("ReplicatedStorage").Modules.GameConfig)
local DataManager = require(ServerScriptService.DataManager)

local function createLeaderstats(player, data)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local stage = Instance.new("IntValue")
	stage.Name = "Stage"
	stage.Value = data.Stage
	stage.Parent = leaderstats

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = data.Coins
	coins.Parent = leaderstats

	local gems = Instance.new("IntValue")
	gems.Name = "Gems"
	gems.Value = data.Gems
	gems.Parent = leaderstats

	-- Quand le joueur gagne des Coins/Gems ailleurs dans le jeu (checkpoints,
	-- coffres, quêtes...), on met à jour à la fois le leaderstat ET la donnée
	-- persistée pour rester synchronisé.
	stage.Changed:Connect(function(newValue)
		data.Stage = newValue
	end)
	coins.Changed:Connect(function(newValue)
		data.Coins = newValue
	end)
	gems.Changed:Connect(function(newValue)
		data.Gems = newValue
	end)
end

Players.PlayerAdded:Connect(function(player)
	local data = DataManager.Load(player)
	createLeaderstats(player, data)
end)

Players.PlayerRemoving:Connect(function(player)
	DataManager.Save(player)
	DataManager.Release(player)
end)

-- Sauvegarde automatique périodique
task.spawn(function()
	while true do
		task.wait(GameConfig.AutoSaveInterval)
		DataManager.SaveAll()
	end
end)

-- Sauvegarde à l'arrêt du serveur (redémarrage, mise à jour du jeu, etc.)
game:BindToClose(function()
	DataManager.SaveAll()
	-- Petite marge pour laisser le temps aux requêtes SetAsync de partir
	task.wait(1)
end)

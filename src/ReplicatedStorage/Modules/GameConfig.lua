--[[
	GameConfig.lua (ModuleScript)
	Emplacement dans Studio : ReplicatedStorage > Modules > GameConfig

	Configuration centrale du jeu. Toutes les valeurs (nombre de niveaux,
	récompenses, clés de DataStore, etc.) doivent passer par ce module afin
	d'éviter les "nombres magiques" éparpillés dans le code.
]]

local GameConfig = {}

-- Structure générale du jeu
GameConfig.Worlds = {
	{ Name = "World1", DisplayName = "Monde 1 - Les Plaines", LevelCount = 50 },
	{ Name = "World2", DisplayName = "Monde 2 - Les Cavernes", LevelCount = 50 },
	{ Name = "World3", DisplayName = "Monde 3 - Le Ciel", LevelCount = 50 },
}

GameConfig.TotalLevels = 150

-- DataStore
GameConfig.DataStoreName = "ObbyLegends_PlayerData_v1"
GameConfig.AutoSaveInterval = 120 -- secondes entre deux sauvegardes automatiques

-- Valeurs par défaut d'un nouveau joueur
GameConfig.DefaultData = {
	Stage = 1,       -- niveau global (1 à 150)
	Coins = 0,
	Gems = 0,
	Checkpoints = {  -- dernier checkpoint atteint par monde, ex: {World1 = 3, World2 = 0, World3 = 0}
		World1 = 0,
		World2 = 0,
		World3 = 0,
	},
}

-- Récompenses de base pour la V0.1 (seront étendues plus tard)
GameConfig.CoinsPerCheckpoint = 5
GameConfig.GemsPerLevelComplete = 1

-- Dimensions utilisées par le générateur de niveaux (LevelBuilder)
GameConfig.Level = {
	PlatformSize = Vector3.new(12, 1, 12),
	GapDistance = 14,      -- distance entre deux plateformes
	StartPosition = Vector3.new(0, 5, 0),
}

return GameConfig

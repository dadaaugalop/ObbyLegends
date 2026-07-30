--[[
	DataManager.lua (ModuleScript)
	Emplacement dans Studio : ServerScriptService > DataManager

	Gère la sauvegarde/chargement des données joueur via DataStoreService.
	Expose : DataManager.Load(player), DataManager.Save(player), DataManager.Get(player)

	Toutes les opérations DataStore sont protégées par pcall pour éviter de
	faire planter le serveur en cas d'erreur réseau ou de coupure du service.
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local GameConfig = require(game:GetService("ReplicatedStorage").Modules.GameConfig)

local DataManager = {}

local store = DataStoreService:GetDataStore(GameConfig.DataStoreName)

-- Cache en mémoire : [Player] = donnees
local cache = {}

-- Recopie profonde des valeurs par défaut pour ne jamais modifier le modèle original
local function deepCopy(tbl)
	local copy = {}
	for k, v in pairs(tbl) do
		if type(v) == "table" then
			copy[k] = deepCopy(v)
		else
			copy[k] = v
		end
	end
	return copy
end

-- Fusionne les données sauvegardées avec les valeurs par défaut
-- (utile si on ajoute de nouveaux champs dans une future version)
local function reconcile(saved, defaults)
	local result = deepCopy(defaults)
	if type(saved) ~= "table" then
		return result
	end
	for k, v in pairs(saved) do
		if type(v) == "table" and type(result[k]) == "table" then
			for k2, v2 in pairs(v) do
				result[k][k2] = v2
			end
		else
			result[k] = v
		end
	end
	return result
end

function DataManager.Load(player)
	local key = "Player_" .. player.UserId
	local success, result = pcall(function()
		return store:GetAsync(key)
	end)

	local data
	if success then
		data = reconcile(result, GameConfig.DefaultData)
	else
		warn(("[DataManager] Echec du chargement pour %s : %s"):format(player.Name, tostring(result)))
		data = deepCopy(GameConfig.DefaultData)
	end

	cache[player] = data
	return data
end

function DataManager.Get(player)
	return cache[player]
end

function DataManager.Save(player)
	local data = cache[player]
	if not data then
		return false
	end

	local key = "Player_" .. player.UserId
	local success, err = pcall(function()
		store:SetAsync(key, data)
	end)

	if not success then
		warn(("[DataManager] Echec de la sauvegarde pour %s : %s"):format(player.Name, tostring(err)))
	end

	return success
end

function DataManager.Release(player)
	cache[player] = nil
end

-- Sauvegarde tout le monde d'un coup (utilisé à l'arrêt du serveur)
function DataManager.SaveAll()
	for _, player in ipairs(Players:GetPlayers()) do
		DataManager.Save(player)
	end
end

return DataManager

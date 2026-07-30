--[[
	HUDController.client.lua (LocalScript)
	Emplacement dans Studio : StarterPlayer > StarterPlayerScripts > HUDController

	Construit l'interface (HUD) entièrement par script : pas besoin de designer
	un ScreenGui à la main dans Studio pour la V0.1. Affiche Stage / Coins / Gems
	en haut de l'écran et se met à jour en temps réel via les leaderstats.
]]

local Players = game:GetService("Players")

local player = Players.LocalPlayer

local function createStatPill(parent, name, iconText, iconColor, layoutOrder)
	local pill = Instance.new("Frame")
	pill.Name = name .. "Pill"
	pill.Size = UDim2.new(0, 120, 0, 40)
	pill.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	pill.BackgroundTransparency = 0.15
	pill.LayoutOrder = layoutOrder
	pill.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = pill

	local icon = Instance.new("Frame")
	icon.Name = "Icon"
	icon.Size = UDim2.new(0, 28, 0, 28)
	icon.Position = UDim2.new(0, 6, 0.5, -14)
	icon.BackgroundColor3 = iconColor
	icon.Parent = pill

	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(1, 0)
	iconCorner.Parent = icon

	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.new(1, 0, 1, 0)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text = iconText
	iconLabel.TextColor3 = Color3.new(1, 1, 1)
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.TextSize = 16
	iconLabel.Parent = icon

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Name = "Value"
	valueLabel.Size = UDim2.new(1, -42, 1, 0)
	valueLabel.Position = UDim2.new(0, 40, 0, 0)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = "0"
	valueLabel.TextColor3 = Color3.new(1, 1, 1)
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextSize = 20
	valueLabel.TextXAlignment = Enum.TextXAlignment.Left
	valueLabel.Parent = pill

	return valueLabel
end

local function buildHud()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "HUD"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = false
	screenGui.Parent = player:WaitForChild("PlayerGui")

	local container = Instance.new("Frame")
	container.Name = "StatsContainer"
	container.Size = UDim2.new(0, 400, 0, 40)
	container.Position = UDim2.new(0.5, -200, 0, 12)
	container.BackgroundTransparency = 1
	container.Parent = screenGui

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Padding = UDim.new(0, 10)
	layout.Parent = container

	local stageLabel = createStatPill(container, "Stage", "S", Color3.fromRGB(80, 150, 255), 1)
	local coinsLabel = createStatPill(container, "Coins", "C", Color3.fromRGB(255, 205, 60), 2)
	local gemsLabel = createStatPill(container, "Gems", "G", Color3.fromRGB(120, 230, 160), 3)

	return stageLabel, coinsLabel, gemsLabel
end

local function bindLeaderstat(label, statValueObject, prefix)
	label.Text = prefix .. tostring(statValueObject.Value)
	statValueObject.Changed:Connect(function(newValue)
		label.Text = prefix .. tostring(newValue)
	end)
end

local function onLeaderstatsReady()
	local leaderstats = player:WaitForChild("leaderstats")
	local stage = leaderstats:WaitForChild("Stage")
	local coins = leaderstats:WaitForChild("Coins")
	local gems = leaderstats:WaitForChild("Gems")

	local stageLabel, coinsLabel, gemsLabel = buildHud()

	bindLeaderstat(stageLabel, stage, "")
	bindLeaderstat(coinsLabel, coins, "")
	bindLeaderstat(gemsLabel, gems, "")
end

onLeaderstatsReady()

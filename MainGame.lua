local Players = game:GetService("Players")

local base = Instance.new("Part", workspace)
base.Name = "MainPlatform"
base.Size = Vector3.new(50, 1, 50)
base.Position = Vector3.new(0, 0.5, 0)
base.Anchored = true
base.Material = Enum.Material.Glass
base.Transparency = 0.3
base.Reflectance = 0.1
base.BrickColor = BrickColor.new("Institutional white")
base.TopSurface = Enum.SurfaceType.Smooth
base.BottomSurface = Enum.SurfaceType.Smooth

local texture = Instance.new("Texture")
texture.Texture = "rbxassetid://9163011782"
texture.StudsPerTileU = 8
texture.StudsPerTileV = 8
texture.Face = Enum.NormalId.Top
texture.Parent = base

local light = Instance.new("SurfaceLight", base)
light.Face = Enum.NormalId.Top
light.Brightness = 2
light.Range = 15
light.Angle = 120
light.Color = Color3.fromRGB(0, 255, 255)

local platformCenter = base.Position
local platformSize = base.Size

local boundaryThickness = 1
local boundaryHeight = 20

local function createBoundaryPart(position, size)
	local part = Instance.new("Part", workspace)
	part.Anchored = true
	part.CanCollide = true
	part.Size = size
	part.Position = position
	part.Transparency = 1
	part.Name = "BoundaryWall"
	return part
end

createBoundaryPart(platformCenter + Vector3.new(platformSize.X/2 + boundaryThickness/2, boundaryHeight/2, 0), Vector3.new(boundaryThickness, boundaryHeight, platformSize.Z + boundaryThickness*2))
createBoundaryPart(platformCenter + Vector3.new(-platformSize.X/2 - boundaryThickness/2, boundaryHeight/2, 0), Vector3.new(boundaryThickness, boundaryHeight, platformSize.Z + boundaryThickness*2))
createBoundaryPart(platformCenter + Vector3.new(0, boundaryHeight/2, platformSize.Z/2 + boundaryThickness/2), Vector3.new(platformSize.X + boundaryThickness*2, boundaryHeight, boundaryThickness))
createBoundaryPart(platformCenter + Vector3.new(0, boundaryHeight/2, -platformSize.Z/2 - boundaryThickness/2), Vector3.new(platformSize.X + boundaryThickness*2, boundaryHeight, boundaryThickness))

local function getRandomPositionOnPlatform()
	local halfX = platformSize.X / 2 - 3
	local halfZ = platformSize.Z / 2 - 3
	local x = math.random(-halfX, halfX)
	local z = math.random(-halfZ, halfZ)
	return Vector3.new(platformCenter.X + x, 0.5, platformCenter.Z + z)
end

local function isPlayerOnPart(part, player)
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
	local dist = (char.HumanoidRootPart.Position - part.Position).magnitude
	return dist < 5
end

Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder", player)
	leaderstats.Name = "leaderstats"
	local score = Instance.new("IntValue", leaderstats)
	score.Name = "Score"
	score.Value = 0

	local playing = Instance.new("BoolValue", player)
	playing.Name = "IsPlaying"
	playing.Value = true

	player.CharacterAdded:Connect(function(char)
		wait(1)
		char:MoveTo(Vector3.new(0, 5, 0))

		local gui = Instance.new("ScreenGui")
		gui.ResetOnSpawn = false
		gui.Name = "MainUI"
		gui.Parent = player:WaitForChild("PlayerGui")

		local scoreLabel = Instance.new("TextLabel", gui)
		scoreLabel.Name = "ScoreLabel"
		scoreLabel.Size = UDim2.new(0, 200, 0, 50)
		scoreLabel.Position = UDim2.new(0, 10, 0, 10)
		scoreLabel.Text = "Score: 0"
		scoreLabel.TextScaled = true
		scoreLabel.BackgroundTransparency = 1
		scoreLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		scoreLabel.Font = Enum.Font.FredokaOne

		local gameOverLabel = Instance.new("TextLabel", gui)
		gameOverLabel.Name = "GameOverLabel"
		gameOverLabel.Size = UDim2.new(0.7, 0, 0.2, 0)
		gameOverLabel.Position = UDim2.new(0.15, 0, 0.35, 0)
		gameOverLabel.Text = "Game Over"
		gameOverLabel.TextScaled = true
		gameOverLabel.BackgroundTransparency = 1
		gameOverLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
		gameOverLabel.Font = Enum.Font.Arcade
		gameOverLabel.TextStrokeTransparency = 0.5
		gameOverLabel.TextStrokeColor3 = Color3.fromRGB(100, 0, 0)
		gameOverLabel.Visible = false

		local restartButton = Instance.new("TextButton", gui)
		restartButton.Name = "RestartButton"
		restartButton.Size = UDim2.new(0, 220, 0, 60)
		restartButton.AnchorPoint = Vector2.new(0.5, 0.5)
		restartButton.Position = UDim2.new(0.5, 0, 0.7, 0)
		restartButton.Text = "Play Again"
		restartButton.TextScaled = true
		restartButton.Visible = false
		restartButton.BackgroundColor3 = Color3.fromRGB(30, 150, 30)
		restartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		restartButton.Font = Enum.Font.FredokaOne
		restartButton.BorderSizePixel = 0
		restartButton.AutoButtonColor = true
		restartButton.TextStrokeTransparency = 0.3
		restartButton.TextStrokeColor3 = Color3.fromRGB(50, 50, 50)
		restartButton.BackgroundTransparency = 0

		score:GetPropertyChangedSignal("Value"):Connect(function()
			scoreLabel.Text = "Score: " .. score.Value
		end)

		restartButton.MouseButton1Click:Connect(function()
			player:LoadCharacter()
			score.Value = 0
			playing.Value = true
			gameOverLabel.Visible = false
			restartButton.Visible = false
		end)
	end)
end)

while true do
	wait(0.5)
	for _, player in pairs(Players:GetPlayers()) do
		local char = player.Character
		local isPlaying = player:FindFirstChild("IsPlaying")
		local score = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Score")

		if not char or not isPlaying or not isPlaying.Value or not score then continue end

		local gui = player:FindFirstChild("PlayerGui")
		local screen = gui and gui:FindFirstChild("MainUI")
		local gameOverLabel = screen and screen:FindFirstChild("GameOverLabel")
		local restartButton = screen and screen:FindFirstChild("RestartButton")

		if not screen or not gameOverLabel or not restartButton then continue end

		local baseDelay = 10
		local delay = math.max(2, baseDelay - score.Value * 0.5)
		local step = math.max(0.05, 0.1 - score.Value * 0.002)
		local limit = math.floor(delay / step)

		local cube = Instance.new("Part", workspace)
		cube.Size = Vector3.new(6, 1, 6)
		local pos = getRandomPositionOnPlatform()
		pos = Vector3.new(pos.X, 20, pos.Z)
		cube.Position = pos
		cube.Anchored = false
		cube.BrickColor = BrickColor.Random()
		cube.Name = "FallingCube"

		local success = false
		for i = 1, limit do
			wait(step)
			if not isPlaying.Value then break end
			if isPlayerOnPart(cube, player) then
				success = true
				break
			end
		end

		if success then
			score.Value += 1
			cube:Destroy()
		else
			isPlaying.Value = false
			gameOverLabel.Visible = true
			restartButton.Visible = true
			cube:Destroy()
		end
	end
end

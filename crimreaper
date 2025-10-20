--[[
    The Crimson Harvest
    - Killaura functionality by tomato.txt (EXACT 1:1 LOGIC PRESERVED)
    - UI, State Management, Anti-Hacker, Defense, and Passive Alerts by Gemini
    - Utilizes Obsidian UI Library by deividcomsono
]]

-- Services
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- State management tables
local killauraState = { running = false, cloneRootPart = nil, originalRootPart = nil, originalRootJoint = nil, lastPositions = {}, specificTarget = nil, rootPartHighlight = nil, targetChanged = false }
local antiRetaliationState = { isRetaliating = false, healthConnection = nil }
local persistentPlayerData = {}
local passiveAlertState = { isScanning = false, detectionCooldowns = {}, playerTrackingData = {}, highlightedPlayers = {}, playerListLabels = {}, hackerListContainer = nil }

-- Settings tables
local killauraSettings = { Enabled = false, Invisibility = false, Killaura = true, MaxDistance = 30, Visualize = true }
local targetSettings = { Guards = true, Inmates = true, Criminals = true, Hackers = true }
local antiHackerSettings = { Enabled = true, VelocityTrigger = 350, TeleportRange = 120, PursuitMode = "Predictive", AttackBurst = 5 }
local antiRetaliationSettings = { Enabled = false, Altitude = 2000, ScrambleRange = 1000, Duration = 5 }
local passiveAlertSettings = { HighlightHackers = true, DetectVelocity = true, DetectTeleport = true, DetectRotation = true, DetectFlight = true, DetectAutoKill = true, DetectAutoRespawn = true, TeleportRange = 120 }

-- Forward declare the killaura loop function
local killauraLoop

-- Main cleanup function
local function restoreCharacterState()
    local char = Players.LocalPlayer.Character
    if killauraState.originalRootPart and killauraState.cloneRootPart and killauraState.cloneRootPart.Parent then
        killauraState.originalRootPart.CFrame = killauraState.cloneRootPart.CFrame
    end
    if killauraState.rootPartHighlight and killauraState.rootPartHighlight.Parent then killauraState.rootPartHighlight:Destroy() end
    if killauraState.cloneRootPart and killauraState.cloneRootPart.Parent then killauraState.cloneRootPart:Destroy() end
    if killauraState.originalRootPart and killauraState.originalRootPart.Parent ~= char then
        killauraState.originalRootPart.Parent = char
        killauraState.originalRootPart.CanTouch = true
        killauraState.originalRootPart.CanQuery = true
        killauraState.originalRootPart.Velocity = Vector3.zero
        killauraState.originalRootPart.Transparency = 1
        if char then
            char.PrimaryPart = killauraState.originalRootPart
        end
    end
    if killauraState.originalRootJoint and killauraState.originalRootJoint.Parent then
        killauraState.originalRootJoint.Enabled = true
    end
    killauraState.running, killauraState.cloneRootPart, killauraState.originalRootPart, killauraState.originalRootJoint, killauraState.rootPartHighlight = false, nil, nil, nil, nil
    killauraState.lastPositions = {}
end

-- Killaura initialization function
local function initializeKillaura()
    if killauraState.running then return end
    local char = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    local humanoid = char:WaitForChild("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then return end
    killauraState.running = true
    killauraState.originalRootPart = root
    killauraState.originalRootJoint = root:FindFirstChild("RootJoint")
    killauraState.cloneRootPart = root:Clone()
    killauraState.cloneRootPart.Parent = char
    char.PrimaryPart = killauraState.cloneRootPart
    if killauraState.originalRootJoint then killauraState.originalRootJoint.Enabled = false end
    root.Parent = workspace
    root.CanTouch = false
    root.CanQuery = false
    root.Transparency = killauraSettings.Visualize and 0 or 1
    local rootHighlight = Instance.new("Highlight", root)
    rootHighlight.Name = "KillauraRootHighlight"
    rootHighlight.FillColor = Color3.new(1, 1, 1)
    rootHighlight.OutlineColor = Color3.new(1, 1, 1)
    rootHighlight.FillTransparency = 0.5
    killauraState.rootPartHighlight = rootHighlight
    coroutine.wrap(killauraLoop)()
end

-- Anti-Aim functions
local function stopRetaliation()
    if not antiRetaliationState.isRetaliating then return end
    antiRetaliationState.isRetaliating = false
    local rootPart = killauraState.originalRootPart or (Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
    local clonePart = killauraState.cloneRootPart or (Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
    if rootPart and clonePart then
        rootPart.CFrame = clonePart.CFrame * CFrame.new(0, 3, 0)
    end
end

local function startRetaliationLoop()
    if antiRetaliationState.isRetaliating then return end
    antiRetaliationState.isRetaliating = true
    local rootPart = killauraState.originalRootPart or (Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
    if not rootPart then
        antiRetaliationState.isRetaliating = false;
        return
    end
    rootPart.CFrame = CFrame.new(rootPart.Position.X, antiRetaliationSettings.Altitude, rootPart.Position.Z)
    if antiRetaliationSettings.Duration > 0 then
        task.delay(antiRetaliationSettings.Duration, stopRetaliation)
    end
    while antiRetaliationState.isRetaliating do
        local range = antiRetaliationSettings.ScrambleRange
        rootPart.CFrame = rootPart.CFrame + Vector3.new(math.random(-range, range), 0, math.random(-range, range))
        task.wait()
    end
end


-- The Killaura coroutine loop
killauraLoop = function()
    local LocalPlayer = Players.LocalPlayer
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then return end
    local meleeEvent = game:GetService("ReplicatedStorage"):WaitForChild("meleeEvent")
    local RootPart, CloneRootPart = killauraState.originalRootPart, killauraState.cloneRootPart

    local function resetRootPartPosition()
        if not RootPart or not CloneRootPart or not CloneRootPart.Parent then return end
        if killauraSettings.Invisibility then
            if CloneRootPart.Velocity.Y == 0 then
                RootPart.CFrame = CloneRootPart.CFrame * CFrame.new(0, -3, 0) * CFrame.Angles(math.rad(90), 0, 0)
            else
                RootPart.CFrame = CloneRootPart.CFrame * CFrame.new(0, -8, 0)
            end
        else
            RootPart.CFrame = CloneRootPart.CFrame
        end
    end

    local function UnequipAll()
        for _, v in pairs(Character:GetChildren()) do
            if v:IsA("Tool") then
                v.Parent = LocalPlayer.Backpack
            end
        end
    end

    local function executeAttack(targetPlayer, targetRoot)
        UnequipAll()
        local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
        local Highlight = Instance.new("Highlight", targetPlayer.Character)
        Highlight.FillColor = targetPlayer.Team.TeamColor.Color
        Highlight.OutlineColor = targetPlayer.Team.TeamColor.Color
        local isHacker = passiveAlertState.highlightedPlayers[targetPlayer] ~= nil
        repeat
            task.wait()
            if not killauraState.running or not targetPlayer.Character or not humanoid or humanoid.Health <= 0 then break end
            if isHacker then
                local cframe = targetRoot.CFrame
                if targetRoot.Velocity.Magnitude > 0.1 and antiHackerSettings.PursuitMode == "Predictive" then
                    cframe = cframe * CFrame.new(targetRoot.Velocity.Unit)
                end
                RootPart.CFrame = cframe
                for i = 1, antiHackerSettings.AttackBurst do
                    meleeEvent:FireServer(targetPlayer)
                end
            else
                RootPart.CFrame = targetRoot.CFrame * CFrame.new(0, -6.5, 0) * CFrame.Angles(math.rad(90), 0, 0)
                meleeEvent:FireServer(targetPlayer)
                RootPart.CFrame = targetRoot.CFrame * CFrame.new(0, -13, 0) * CFrame.Angles(math.rad(90), 0, 0)
            end
        until not targetPlayer.Character or humanoid.Health <= 0 or not killauraState.running
        Highlight:Destroy()
        resetRootPartPosition()
    end

    local function meleeAll()
        if killauraState.specificTarget then
            local target = killauraState.specificTarget
            local char = target.Character
            if not target.Parent or not char then
                killauraState.specificTarget = nil
                killauraState.targetChanged = true
                return
            end
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local targetRoot = char:FindFirstChild("HumanoidRootPart")
            if not humanoid or humanoid.Health <= 0 or not targetRoot then
                killauraState.specificTarget = nil
                killauraState.targetChanged = true
                return
            end
            executeAttack(target, targetRoot)
            return
        end
        for _, v in pairs(Players:GetPlayers()) do
            local Char = v.Character
            if v ~= LocalPlayer and Char and Char:FindFirstChild("HumanoidRootPart") then
                local HumanoidTarget = Char:FindFirstChild("Humanoid")
                if HumanoidTarget and HumanoidTarget.Health > 0 and not Char:FindFirstChild("ForceField") then
                    local TargetRoot = Char.HumanoidRootPart
                    local isHacker = passiveAlertState.highlightedPlayers[v] ~= nil
                    local team = v.Team
                    local isTeamTargeted = team and ((targetSettings.Guards and team.Name == "Guards") or (targetSettings.Inmates and team.Name == "Inmates") or (targetSettings.Criminals and team.Name == "Criminals"))
                    local shouldAttack = (isHacker and targetSettings.Hackers) or (not isHacker and isTeamTargeted)
                    local inRange = (killauraSettings.MaxDistance == 0) or (TargetRoot.Position - RootPart.Position).Magnitude <= killauraSettings.MaxDistance
                    if shouldAttack and inRange then
                        executeAttack(v, TargetRoot)
                    end
                end
            end
        end
    end

    while task.wait() and Humanoid.Health > 0 and killauraState.running do
        if not CloneRootPart or not CloneRootPart.Parent then break end
        if antiRetaliationState.isRetaliating then continue end
        resetRootPartPosition()
        if killauraSettings.Killaura then meleeAll() end
    end
    if killauraState.running then restoreCharacterState() end
end

-- Create the UI Window
local Window = Library:CreateWindow({ Title = "The Crimson Harvest", Footer = "Killaura by tomato.txt | UI by Gemini", Center = true, AutoShow = true, Resizable = true })
local MainTab = Window:AddTab({ Name = "Main" })
local AntiHackerTab = Window:AddTab({ Name = "Anti-Hacker" })
local HackerAlertsTab = Window:AddTab({ Name = "Hacker Alerts" })
local SettingsTab = Window:AddTab({ Name = "Settings" })
local AuraBox = MainTab:AddLeftGroupbox("Aura Controls")
local TargetingBox = MainTab:AddRightGroupbox("Kill Options")
local PlayerBox = MainTab:AddLeftGroupbox("Player State")
local DetectionBox = AntiHackerTab:AddLeftGroupbox("Detection")
local CounterBox = AntiHackerTab:AddLeftGroupbox("Countermeasures")
local AntiAimBox = AntiHackerTab:AddRightGroupbox("Anti-Aim")
local PassiveDetectionBox = HackerAlertsTab:AddLeftGroupbox("Passive Detection")
local HackerListBox = HackerAlertsTab:AddRightGroupbox("Detected Players")
local VisualsBox = SettingsTab:AddLeftGroupbox("Visuals")
local killauraToggle = AuraBox:AddToggle("killauraToggle", { Text = "Enable Killaura", Default = killauraSettings.Enabled })
local distanceSlider = AuraBox:AddSlider("distanceSlider", { Text = "Max Distance", Default = killauraSettings.MaxDistance, Min = 0, Max = 300, Rounding = 0, Suffix = " studs" })
local targetGuardsToggle = TargetingBox:AddToggle("targetGuards", { Text = "Kill Guards", Default = targetSettings.Guards })
local targetInmatesToggle = TargetingBox:AddToggle("targetInmates", { Text = "Kill Inmates", Default = targetSettings.Inmates })
local targetCriminalsToggle = TargetingBox:AddToggle("targetCriminals", { Text = "Kill Criminals", Default = targetSettings.Criminals })
local targetHackersToggle = TargetingBox:AddToggle("targetHackers", { Text = "Kill Hackers", Default = targetSettings.Hackers })
TargetingBox:AddDivider()
local playerDropdown, targetPlayerButton, clearTargetButton, currentTargetLabel
local updateTargetUI
updateTargetUI = function()
    if killauraState.specificTarget then
        currentTargetLabel:SetText("Current Kill Order: " .. killauraState.specificTarget.Name)
        clearTargetButton:SetDisabled(false)
    else
        currentTargetLabel:SetText("Current Kill Order: None")
        clearTargetButton:SetDisabled(true)
    end
end
local initialPlayerNames = {}
for _, player in pairs(Players:GetPlayers()) do if player ~= Players.LocalPlayer then table.insert(initialPlayerNames, player.Name) end end
playerDropdown = TargetingBox:AddDropdown("playerDropdown", { Text = "Select Player to Kill", Values = initialPlayerNames, AllowNull = true })
targetPlayerButton = TargetingBox:AddButton({
    Text = "Kill Selected Player",
    Func = function()
        local selectedPlayerName = playerDropdown.Value
        if not selectedPlayerName then
            Library:Notify("No player selected.")
            return
        end
        local targetPlayer = Players:FindFirstChild(selectedPlayerName)
        if targetPlayer then
            killauraState.specificTarget = targetPlayer
            killauraState.targetChanged = true
            if not killauraSettings.Enabled then
                killauraToggle:SetValue(true)
            end
        else
            Library:Notify("Could not find selected player.")
        end
    end
})
clearTargetButton = TargetingBox:AddButton({ Text = "Clear Kill Order", Disabled = true, Func = function()
    killauraState.specificTarget = nil
    killauraState.targetChanged = true
end })
currentTargetLabel = TargetingBox:AddLabel("currentTarget", { Text = "Current Kill Order: None" })
local invisibilityToggle = PlayerBox:AddToggle("invisibilityToggle", { Text = "Invisibility", Default = killauraSettings.Invisibility })
local visualizeToggle = VisualsBox:AddToggle("visualizeToggle", { Text = "Visualize Root Part", Default = killauraSettings.Visualize })
local antiAimToggle = AntiAimBox:AddToggle("antiAimToggle", { Text = "Enable Anti-Aim", Default = antiRetaliationSettings.Enabled, Tooltip = "When damaged, teleports you to the sky to escape." })
local altitudeSlider = AntiAimBox:AddSlider("altitudeSlider", { Text = "Evasion Altitude", Default = antiRetaliationSettings.Altitude, Min = 1000, Max = 5000, Rounding = 0, Suffix = " studs" })
local scrambleSlider = AntiAimBox:AddSlider("scrambleSlider", { Text = "Scramble Range", Default = antiRetaliationSettings.ScrambleRange, Min = 500, Max = 2000, Rounding = 0, Suffix = " studs" })
local durationSlider = AntiAimBox:AddSlider("durationSlider", { Text = "Duration", Default = antiRetaliationSettings.Duration, Min = 0, Max = 30, Rounding = 1, Suffix = " s (0=inf)" })
local antiHackerToggle = DetectionBox:AddToggle("antiHackerEnable", { Text = "Enable Anti-Hacker Methods", Default = antiHackerSettings.Enabled })
local velocitySlider = DetectionBox:AddSlider("velocitySlider", { Text = "Killaura Velocity Trigger", Default = antiHackerSettings.VelocityTrigger, Min = 150, Max = 700, Rounding = 0, Suffix = " studs/s" })
local teleportSlider = DetectionBox:AddSlider("teleportSlider", { Text = "Killaura Teleport Trigger", Default = antiHackerSettings.TeleportRange, Min = 50, Max = 400, Rounding = 0, Suffix = " studs" })
local pursuitDropdown = CounterBox:AddDropdown("pursuitMode", { Text = "Pursuit Mode", Values = {"Predictive"}, Default = "Predictive" })
local burstSlider = CounterBox:AddSlider("burstSlider", { Text = "Attack Burst Count", Default = antiHackerSettings.AttackBurst, Min = 2, Max = 15, Rounding = 0, Suffix = " attacks" })
local passiveScanToggle = PassiveDetectionBox:AddToggle("passiveScanToggle", { Text = "Enable Passive Alerts", Default = false, Tooltip = "Continuously scans for hackers and alerts you." })
local highlightHackersToggle = PassiveDetectionBox:AddToggle("highlightHackersToggle", { Text = "Highlight Detected Hackers", Default = passiveAlertSettings.HighlightHackers, Tooltip = "Permanently highlights players flagged by the passive scanner." })
PassiveDetectionBox:AddDivider()
local detectVelocityToggle = PassiveDetectionBox:AddToggle("detectVelocity", { Text = "Detect High Velocity", Default = passiveAlertSettings.DetectVelocity })
local detectTeleportToggle = PassiveDetectionBox:AddToggle("detectTeleport", { Text = "Detect Teleportation", Default = passiveAlertSettings.DetectTeleport })
local detectRotationToggle = PassiveDetectionBox:AddToggle("detectRotation", { Text = "Detect Unnatural Rotation", Default = passiveAlertSettings.DetectRotation })
local detectFlightToggle = PassiveDetectionBox:AddToggle("detectFlight", {Text = "Detect Flight", Default = passiveAlertSettings.DetectFlight})
local detectAutoKillToggle = PassiveDetectionBox:AddToggle("detectAutoKill", {Text = "Detect Auto-Kill", Default = passiveAlertSettings.DetectAutoKill})
local detectAutoRespawnToggle = PassiveDetectionBox:AddToggle("detectAutoRespawn", {Text = "Detect Auto-Respawn", Default = passiveAlertSettings.DetectAutoRespawn})
PassiveDetectionBox:AddDivider()
local passiveTeleportSlider = PassiveDetectionBox:AddSlider("passiveTeleportSlider", { Text = "Passive Teleport Trigger", Default = passiveAlertSettings.TeleportRange, Min = 50, Max = 400, Rounding = 0, Suffix = " studs" })
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
local HackerListFrame = HackerListBox:AddUIPassthrough("hackerListFrame", { Instance = scrollingFrame, Height = 300 })
HackerListFrame.Instance.BackgroundTransparency = 1
HackerListFrame.Instance.BorderSizePixel = 0
HackerListFrame.Instance.ScrollBarThickness = 3
local listLayout = Instance.new("UIListLayout", HackerListFrame.Instance)
listLayout.Padding = UDim.new(0, 5)
listLayout.SortOrder = Enum.SortOrder.Name
passiveAlertState.hackerListContainer = HackerListFrame.Instance
local function updatePlayerList()
    local playerNames = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            table.insert(playerNames, player.Name)
        end
    end
    playerDropdown:SetValues(playerNames)
end
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
killauraToggle:OnChanged(function(value) killauraSettings.Enabled = value if value then initializeKillaura() else restoreCharacterState() end end)
distanceSlider:OnChanged(function(v) killauraSettings.MaxDistance = v end)
invisibilityToggle:OnChanged(function(v) killauraSettings.Invisibility = v end)
visualizeToggle:OnChanged(function(v) killauraSettings.Visualize = v if killauraState.running and killauraState.originalRootPart then killauraState.originalRootPart.Transparency = v and 0 or 1 end end)
targetGuardsToggle:OnChanged(function(v) targetSettings.Guards = v end)
targetInmatesToggle:OnChanged(function(v) targetSettings.Inmates = v end)
targetCriminalsToggle:OnChanged(function(v) targetSettings.Criminals = v end)
targetHackersToggle:OnChanged(function(v) targetSettings.Hackers = v end)
antiHackerToggle:OnChanged(function(v) antiHackerSettings.Enabled = v end)
velocitySlider:OnChanged(function(v) antiHackerSettings.VelocityTrigger = v end)
teleportSlider:OnChanged(function(v) antiHackerSettings.TeleportRange = v end)
pursuitDropdown:OnChanged(function(v) antiHackerSettings.PursuitMode = v end)
burstSlider:OnChanged(function(v) antiHackerSettings.AttackBurst = v end)
altitudeSlider:OnChanged(function(v) antiRetaliationSettings.Altitude = v end)
scrambleSlider:OnChanged(function(v) antiRetaliationSettings.ScrambleRange = v end)
durationSlider:OnChanged(function(v) antiRetaliationSettings.Duration = v end)
antiAimToggle:OnChanged(function(v)
    antiRetaliationSettings.Enabled = v
    local char = Players.LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if v then
        if not antiRetaliationState.healthConnection and hum then
            antiRetaliationState.healthConnection = hum.HealthChanged:Connect(function(h)
                if h < hum.MaxHealth and antiRetaliationSettings.Enabled and not antiRetaliationState.isRetaliating then
                    coroutine.wrap(startRetaliationLoop)()
                end
            end)
        end
    else
        if antiRetaliationState.healthConnection then
            antiRetaliationState.healthConnection:Disconnect()
            antiRetaliationState.healthConnection = nil
        end
        stopRetaliation()
    end
end)
detectVelocityToggle:OnChanged(function(v) passiveAlertSettings.DetectVelocity = v end)
detectTeleportToggle:OnChanged(function(v) passiveAlertSettings.DetectTeleport = v end)
detectRotationToggle:OnChanged(function(v) passiveAlertSettings.DetectRotation = v end)
detectFlightToggle:OnChanged(function(v) passiveAlertSettings.DetectFlight = v end)
detectAutoKillToggle:OnChanged(function(v) passiveAlertSettings.DetectAutoKill = v end)
detectAutoRespawnToggle:OnChanged(function(v) passiveAlertSettings.DetectAutoRespawn = v end)
passiveTeleportSlider:OnChanged(function(v) passiveAlertSettings.TeleportRange = v end)
local function clearHackerList()
    if passiveAlertState.hackerListContainer then
        passiveAlertState.hackerListContainer:ClearAllChildren()
        local layout = Instance.new("UIListLayout", passiveAlertState.hackerListContainer)
        layout.Padding = UDim.new(0, 5)
        layout.SortOrder = Enum.SortOrder.Name
    end
    passiveAlertState.playerListLabels = {}
end
local function removeHackerFromList(player)
    if passiveAlertState.playerListLabels[player] then
        passiveAlertState.playerListLabels[player]:Destroy()
        passiveAlertState.playerListLabels[player] = nil
    end
end
local function updateHackerListEntry(player)
    if passiveAlertState.playerListLabels[player] and passiveAlertState.highlightedPlayers[player] then
        local data = passiveAlertState.highlightedPlayers[player]
        passiveAlertState.playerListLabels[player].Text = string.format("  [%d] %s", data.count, player.Name)
    end
end
local function addHackerToList(player)
    if not passiveAlertState.hackerListContainer or passiveAlertState.playerListLabels[player] then return end
    local data = passiveAlertState.highlightedPlayers[player]
    if not data then return end
    local label = Instance.new("TextLabel")
    label.Name = player.Name
    label.Text = string.format("  [%d] %s", data.count, player.Name)
    label.Parent = passiveAlertState.hackerListContainer
    label.BackgroundTransparency = 1
    label.TextSize = 14
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Size = UDim2.new(1, 0, 0, 18)
    passiveAlertState.playerListLabels[player] = label
end
passiveScanToggle:OnChanged(function(value)
    passiveAlertState.isScanning = value
    if not value then
        passiveAlertState.detectionCooldowns = {}
        clearHackerList()
    else
        clearHackerList()
        for player, _ in pairs(passiveAlertState.highlightedPlayers) do
            if player and player.Parent then
                addHackerToList(player)
            end
        end
    end
end)
local function applyHighlight(character)
    if not character or not passiveAlertSettings.HighlightHackers then return end
    if character:FindFirstChild("TomatoSlicer_Highlight") then return end
    local highlight = Instance.new("Highlight", character)
    highlight.Name = "TomatoSlicer_Highlight"
    highlight.FillColor = Color3.new(0, 0, 0)
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
end
local function removeAllHighlights()
    for player, _ in pairs(passiveAlertState.highlightedPlayers) do
        if player and player.Character then
            local highlight = player.Character:FindFirstChild("TomatoSlicer_Highlight")
            if highlight then
                highlight:Destroy()
            end
        end
    end
end
highlightHackersToggle:OnChanged(function(value)
    passiveAlertSettings.HighlightHackers = value
    if not value then
        removeAllHighlights()
    else
        for player, _ in pairs(passiveAlertState.highlightedPlayers) do
            if player and player.Character then
                applyHighlight(player.Character)
            end
        end
    end
end)

-- Global Heartbeat Connections
RunService.Heartbeat:Connect(function()
    if killauraState.running and killauraState.originalRootPart and killauraState.originalRootPart.Parent then
        killauraState.originalRootPart.Velocity = Vector3.new(0, 0, 0)
    end
    if killauraState.targetChanged then
        updateTargetUI()
        killauraState.targetChanged = false
    end
    if not passiveAlertState.isScanning then return end
    
    local allPlayers = Players:GetPlayers()
    for i, playerA in ipairs(allPlayers) do
        local pData = persistentPlayerData[playerA]
        if pData then
            if pData.violationCount > 0 and pData.lastDetectionTime and (tick() - pData.lastDetectionTime > 20) then
                pData.violationCount = pData.violationCount - 1
                pData.lastDetectionTime = tick()
                if passiveAlertState.highlightedPlayers[playerA] then
                    if pData.violationCount < 5 then
                        passiveAlertState.highlightedPlayers[playerA] = nil
                        removeHackerFromList(playerA)
                        if playerA.Character then
                            local highlight = playerA.Character:FindFirstChild("TomatoSlicer_Highlight")
                            if highlight then highlight:Destroy() end
                        end
                    else
                        passiveAlertState.highlightedPlayers[playerA].count = pData.violationCount
                        updateHackerListEntry(playerA)
                    end
                end
            end
        end

        local charA = playerA.Character
        local humanoidA = charA and charA:FindFirstChildOfClass("Humanoid")
        local rootPartA = charA and charA:FindFirstChild("HumanoidRootPart")
        if playerA == Players.LocalPlayer or not rootPartA or not humanoidA or humanoidA.Health <= 0 or charA:FindFirstChild("ForceField") then continue end
        
        local trackedData = passiveAlertState.playerTrackingData[playerA]
        local detectionVector = nil
        
        if trackedData and trackedData.character == charA then
            local humanoidStateA = humanoidA:GetState()
            if humanoidA.FloorMaterial == Enum.Material.Air then
                if not trackedData.airborneStartTime then trackedData.airborneStartTime = tick() end
            else
                trackedData.airborneStartTime = nil
            end

            if passiveAlertSettings.DetectVelocity and humanoidA.Sit == false and rootPartA.Velocity.Magnitude > antiHackerSettings.VelocityTrigger then
                detectionVector = "High Velocity"
            end
            if not detectionVector and passiveAlertSettings.DetectFlight and trackedData.airborneStartTime and (tick() - trackedData.airborneStartTime > 4.5) then
                local isSafeState = (humanoidStateA == Enum.HumanoidStateType.Seated or humanoidStateA == Enum.HumanoidStateType.Ragdoll or humanoidStateA == Enum.HumanoidStateType.FallingDown or humanoidStateA == Enum.HumanoidStateType.Swimming)
                if not isSafeState and not humanoidA.SeatPart then
                    if rootPartA.Velocity.Y > -10 then detectionVector = "Flying" end
                end
            end
            if not detectionVector and passiveAlertSettings.DetectTeleport and trackedData.spawnTime and (tick() - trackedData.spawnTime > 5) then
                local isSafeState = (humanoidStateA == Enum.HumanoidStateType.Seated or humanoidStateA == Enum.HumanoidStateType.Ragdoll or humanoidStateA == Enum.HumanoidStateType.FallingDown)
                if not isSafeState and not humanoidA.SeatPart then
                    if (rootPartA.Position - trackedData.position).Magnitude > passiveAlertSettings.TeleportRange then detectionVector = "Teleportation" end
                end
            end
            if not detectionVector and passiveAlertSettings.DetectRotation then
                local isSafeState = (humanoidStateA == Enum.HumanoidStateType.Seated or humanoidStateA == Enum.HumanoidStateType.Ragdoll or humanoidStateA == Enum.HumanoidStateType.FallingDown or humanoidStateA == Enum.HumanoidStateType.Swimming)
                if not isSafeState then
                    if math.abs(rootPartA.CFrame.UpVector:Dot(Vector3.new(0, 1, 0))) < 0.1 then detectionVector = "Unnatural Rotation" end
                end
            end
            if not detectionVector and passiveAlertSettings.DetectAutoKill then
                if humanoidStateA ~= Enum.HumanoidStateType.Climbing then
                    for j, playerB in ipairs(allPlayers) do
                        if i ~= j then
                            local charB = playerB.Character
                            local rootPartB = charB and charB:FindFirstChild("HumanoidRootPart")
                            if rootPartB then
                                local diff = rootPartB.Position - rootPartA.Position
                                if diff.Y > 3 and diff.Y < 7 and Vector3.new(diff.X, 0, diff.Z).Magnitude < 0.1 then
                                    detectionVector = "Auto-Kill"
                                    break
                                end
                            end
                        end
                    end
                end
            end
            if not detectionVector and passiveAlertSettings.DetectAutoRespawn and trackedData.spawnTime and (tick() - trackedData.spawnTime < 4) and pData.lastDeathPosition then
                local distFromDeathSpot = (rootPartA.Position - pData.lastDeathPosition).Magnitude
                local distFromSpawnSpot = (rootPartA.Position - trackedData.spawnPosition).Magnitude
                if distFromDeathSpot < 15 and distFromSpawnSpot > 50 then
                    detectionVector = "Auto Respawn"
                    pData.lastDeathPosition = nil 
                end
            end
        end

        if trackedData then trackedData.position = rootPartA.Position end
        
        if detectionVector then
            local now = tick()
            local cooldownDuration = 15
            if detectionVector == "Flying" then
                cooldownDuration = 0.5
            end
            local lastAlert = passiveAlertState.detectionCooldowns[playerA]
            if not lastAlert or (now - lastAlert > cooldownDuration) then
                passiveAlertState.detectionCooldowns[playerA] = now
                pData.violationCount = pData.violationCount + 1
                pData.lastDetectionTime = now
                local currentViolations = pData.violationCount
                if passiveAlertState.highlightedPlayers[playerA] then
                    passiveAlertState.highlightedPlayers[playerA].count = currentViolations
                    passiveAlertState.highlightedPlayers[playerA].reason = detectionVector
                    updateHackerListEntry(playerA)
                elseif currentViolations >= 5 then
                    passiveAlertState.highlightedPlayers[playerA] = { count = currentViolations, reason = detectionVector }
                    if playerA.Character then applyHighlight(playerA.Character) end
                    addHackerToList(playerA)
                end
                Library:Notify({ Title = "Suspicious Activity", Description = string.format("%s detected for: %s (%d/5)", playerA.Name, detectionVector, currentViolations) })
            end
        end
    end
end)

-- PLAYER EVENT HANDLERS
local function setupPlayer(player)
    player.CharacterAdded:Connect(function(character)
        local rootPart = character:WaitForChild("HumanoidRootPart", 5)
        local humanoid = character:WaitForChild("Humanoid")
        if not rootPart or not humanoid then return end
        passiveAlertState.playerTrackingData[player] = { character = character, position = rootPart.Position, spawnTime = tick(), airborneStartTime = nil, spawnPosition = rootPart.Position }
        if passiveAlertState.highlightedPlayers[player] then
            task.wait(0.2)
            applyHighlight(character)
        end
        humanoid.Died:Connect(function()
            if character:FindFirstChild("HumanoidRootPart") then
                persistentPlayerData[player].lastDeathPosition = character.HumanoidRootPart.Position
            end
        end)
    end)
end
for _, player in pairs(Players:GetPlayers()) do
    if player ~= Players.LocalPlayer then
        setupPlayer(player)
        persistentPlayerData[player] = { violationCount = 0, lastDeathPosition = nil, lastDetectionTime = tick() }
    end
end
Players.PlayerAdded:Connect(function(player)
    if player ~= Players.LocalPlayer then
        setupPlayer(player)
        persistentPlayerData[player] = { violationCount = 0, lastDeathPosition = nil, lastDetectionTime = tick() }
    end
end)
Players.LocalPlayer.CharacterAdded:Connect(function(character)
    local hum = character:WaitForChild("Humanoid")
    if antiRetaliationSettings.Enabled then
        if antiRetaliationState.healthConnection then antiRetaliationState.healthConnection:Disconnect() end
        antiRetaliationState.healthConnection = hum.HealthChanged:Connect(function(h)
            if h < hum.MaxHealth and antiRetaliationSettings.Enabled and not antiRetaliationState.isRetaliating then
                coroutine.wrap(startRetaliationLoop)()
            end
        end)
    end
    if killauraSettings.Enabled then
        task.wait(0.5)
        initializeKillaura()
    end
end)
Players.LocalPlayer.CharacterRemoving:Connect(function()
    if killauraState.running then restoreCharacterState() end
    if antiRetaliationState.isRetaliating then stopRetaliation() end
end)
Players.PlayerRemoving:Connect(function(p)
    if killauraState.lastPositions[p] then killauraState.lastPositions[p] = nil end
    if passiveAlertState.detectionCooldowns[p] then passiveAlertState.detectionCooldowns[p] = nil end
    if passiveAlertState.playerTrackingData[p] then passiveAlertState.playerTrackingData[p] = nil end
    if passiveAlertState.highlightedPlayers[p] then passiveAlertState.highlightedPlayers[p] = nil end
    persistentPlayerData[p] = nil
    removeHackerFromList(p)
    if killauraState.specificTarget == p then
        killauraState.specificTarget = nil
        killauraState.targetChanged = true
    end
end)

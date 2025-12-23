--[[
    Kavo UI Library - Optimized & Mobile Friendly Rewrite
    Optimized by: AI Assistant
    Original by: Kavo & Contributors

    Changes:
    - Removed all infinite loops (Huge performance boost)
    - Added Mobile Touch support for dragging
    - Added a Toggle/Minimize button automatically
    - Cleaned up tweening and input logic
]]

local Kavo = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Utility = {}

--// Theme Management Registry (Replaces infinite loops)
local ThemeRegistry = {
    Background = {},
    SchemeColor = {},
    Header = {},
    TextColor = {},
    ElementColor = {},
    ImageColor = {}
}

--// Helper Functions
function Utility:TweenObject(obj, properties, duration, ...)
    TweenService:Create(obj, TweenInfo.new(duration, ...), properties):Play()
end

function Utility:RegisterThemeObject(obj, category, property)
    if not ThemeRegistry[category] then ThemeRegistry[category] = {} end
    table.insert(ThemeRegistry[category], {Object = obj, Property = property})
end

local function GetAllThemes() 
    return {
        SchemeColor = Color3.fromRGB(74, 99, 135),
        Background = Color3.fromRGB(36, 37, 43),
        Header = Color3.fromRGB(28, 29, 34),
        TextColor = Color3.fromRGB(255, 255, 255),
        ElementColor = Color3.fromRGB(32, 32, 38)
    }
end

local themeStyles = {
    DarkTheme = {
        SchemeColor = Color3.fromRGB(64, 64, 64),
        Background = Color3.fromRGB(0, 0, 0),
        Header = Color3.fromRGB(0, 0, 0),
        TextColor = Color3.fromRGB(255,255,255),
        ElementColor = Color3.fromRGB(20, 20, 20)
    },
    LightTheme = {
        SchemeColor = Color3.fromRGB(150, 150, 150),
        Background = Color3.fromRGB(255,255,255),
        Header = Color3.fromRGB(200, 200, 200),
        TextColor = Color3.fromRGB(0,0,0),
        ElementColor = Color3.fromRGB(224, 224, 224)
    },
    BloodTheme = {
        SchemeColor = Color3.fromRGB(227, 27, 27),
        Background = Color3.fromRGB(10, 10, 10),
        Header = Color3.fromRGB(5, 5, 5),
        TextColor = Color3.fromRGB(255,255,255),
        ElementColor = Color3.fromRGB(20, 20, 20)
    },
    GrapeTheme = {
        SchemeColor = Color3.fromRGB(166, 71, 214),
        Background = Color3.fromRGB(64, 50, 71),
        Header = Color3.fromRGB(36, 28, 41),
        TextColor = Color3.fromRGB(255,255,255),
        ElementColor = Color3.fromRGB(74, 58, 84)
    },
    Ocean = {
        SchemeColor = Color3.fromRGB(86, 76, 251),
        Background = Color3.fromRGB(26, 32, 58),
        Header = Color3.fromRGB(38, 45, 71),
        TextColor = Color3.fromRGB(200, 200, 200),
        ElementColor = Color3.fromRGB(38, 45, 71)
    },
    Midnight = {
        SchemeColor = Color3.fromRGB(26, 189, 158),
        Background = Color3.fromRGB(44, 62, 82),
        Header = Color3.fromRGB(57, 81, 105),
        TextColor = Color3.fromRGB(255, 255, 255),
        ElementColor = Color3.fromRGB(52, 74, 95)
    },
    Sentinel = {
        SchemeColor = Color3.fromRGB(230, 35, 69),
        Background = Color3.fromRGB(32, 32, 32),
        Header = Color3.fromRGB(24, 24, 24),
        TextColor = Color3.fromRGB(119, 209, 138),
        ElementColor = Color3.fromRGB(24, 24, 24)
    },
    Synapse = {
        SchemeColor = Color3.fromRGB(46, 48, 43),
        Background = Color3.fromRGB(13, 15, 12),
        Header = Color3.fromRGB(36, 38, 35),
        TextColor = Color3.fromRGB(152, 99, 53),
        ElementColor = Color3.fromRGB(24, 24, 24)
    },
    Serpent = {
        SchemeColor = Color3.fromRGB(0, 166, 58),
        Background = Color3.fromRGB(31, 41, 43),
        Header = Color3.fromRGB(22, 29, 31),
        TextColor = Color3.fromRGB(255,255,255),
        ElementColor = Color3.fromRGB(22, 29, 31)
    }
}

--// Mobile Friendly Dragging
function Kavo:DraggingEnabled(frame, parent)
    parent = parent or frame
    local dragging = false
    local dragInput, mousePos, framePos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = parent.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            parent.Position  = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

--// Config Loading
local SettingsT = {}
local ConfigName = "KavoConfig.JSON"

task.spawn(function()
    if not isfile then return end -- Check if executor supports files
    pcall(function()
        if not isfile(ConfigName) then
            writefile(ConfigName, HttpService:JSONEncode(SettingsT))
        end
        -- Reading config logic (placeholder for actual implementation)
        -- local Settings = HttpService:JSONDecode(readfile(ConfigName))
    end)
end)

local LibName = "KavoUI_"..tostring(math.random(1000, 9999))

function Kavo:ToggleUI()
    local gui = CoreGui:FindFirstChild(LibName)
    if gui then
        gui.Enabled = not gui.Enabled
    end
end

function Kavo.CreateLib(kavName, themeList)
    --// Theme Setup
    if not themeList then themeList = GetAllThemes() end
    if type(themeList) == "string" then themeList = themeStyles[themeList] or GetAllThemes() end
    
    -- Default keys check
    local default = GetAllThemes()
    for k,v in pairs(default) do
        if themeList[k] == nil then themeList[k] = v end
    end

    -- Cleanup Old UI
    for _,v in pairs(CoreGui:GetChildren()) do
        if v:IsA("ScreenGui") and v.Name == LibName then v:Destroy() end
    end

    local ScreenGui = Instance.new("ScreenGui")
    local Main = Instance.new("Frame")
    local MainCorner = Instance.new("UICorner")
    local MainHeader = Instance.new("Frame")
    local headerCover = Instance.new("UICorner")
    local coverup = Instance.new("Frame")
    local title = Instance.new("TextLabel")
    local close = Instance.new("ImageButton")
    local MainSide = Instance.new("Frame")
    local sideCorner = Instance.new("UICorner")
    local coverup_2 = Instance.new("Frame")
    local tabFrames = Instance.new("Frame")
    local tabListing = Instance.new("UIListLayout")
    local pages = Instance.new("Frame")
    local Pages = Instance.new("Folder")
    local infoContainer = Instance.new("Frame")
    local blurFrame = Instance.new("Frame")

    --// Mobile Toggle Button
    local ToggleBtn = Instance.new("ImageButton")
    local ToggleCorner = Instance.new("UICorner")
    
    ToggleBtn.Name = "ToggleUI"
    ToggleBtn.Parent = ScreenGui
    ToggleBtn.BackgroundColor3 = themeList.Background
    ToggleBtn.Position = UDim2.new(0, 10, 0.5, -25)
    ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
    ToggleBtn.Image = "rbxassetid://3926305904" -- Replace with logo if desired
    ToggleBtn.ImageRectOffset = Vector2.new(764, 764) -- Info icon as placeholder, or use logo
    ToggleBtn.ImageRectSize = Vector2.new(36, 36)
    ToggleBtn.ImageColor3 = themeList.SchemeColor
    ToggleBtn.Active = true
    ToggleBtn.Draggable = true -- Native draggable for the button itself
    
    ToggleCorner.CornerRadius = UDim.new(0, 100)
    ToggleCorner.Parent = ToggleBtn

    ToggleBtn.MouseButton1Click:Connect(function()
        Main.Visible = not Main.Visible
    end)
    
    Utility:RegisterThemeObject(ToggleBtn, "Background", "BackgroundColor3")
    Utility:RegisterThemeObject(ToggleBtn, "SchemeColor", "ImageColor3")

    --// Main UI Setup
    ScreenGui.Name = LibName
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    Kavo:DraggingEnabled(MainHeader, Main)

    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.BackgroundColor3 = themeList.Background
    Main.ClipsDescendants = true
    Main.Position = UDim2.new(0.5, -262, 0.5, -159)
    Main.Size = UDim2.new(0, 525, 0, 318)
    Main.Visible = true -- Visible by default
    Utility:RegisterThemeObject(Main, "Background", "BackgroundColor3")

    MainCorner.CornerRadius = UDim.new(0, 4)
    MainCorner.Parent = Main

    MainHeader.Name = "MainHeader"
    MainHeader.Parent = Main
    MainHeader.BackgroundColor3 = themeList.Header
    MainHeader.Size = UDim2.new(0, 525, 0, 29)
    Utility:RegisterThemeObject(MainHeader, "Header", "BackgroundColor3")

    headerCover.CornerRadius = UDim.new(0, 4)
    headerCover.Parent = MainHeader

    coverup.Name = "coverup"
    coverup.Parent = MainHeader
    coverup.BackgroundColor3 = themeList.Header
    coverup.BorderSizePixel = 0
    coverup.Position = UDim2.new(0, 0, 0.758620679, 0)
    coverup.Size = UDim2.new(0, 525, 0, 7)
    Utility:RegisterThemeObject(coverup, "Header", "BackgroundColor3")

    title.Name = "title"
    title.Parent = MainHeader
    title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1.000
    title.Position = UDim2.new(0.017, 0, 0.345, 0)
    title.Size = UDim2.new(0, 204, 0, 8)
    title.Font = Enum.Font.Gotham
    title.RichText = true
    title.Text = kavName or "Kavo UI"
    title.TextColor3 = Color3.fromRGB(245, 245, 245)
    title.TextSize = 16.000
    title.TextXAlignment = Enum.TextXAlignment.Left

    close.Name = "close"
    close.Parent = MainHeader
    close.BackgroundTransparency = 1.000
    close.Position = UDim2.new(0.95, 0, 0.138, 0)
    close.Size = UDim2.new(0, 21, 0, 21)
    close.ZIndex = 2
    close.Image = "rbxassetid://3926305904"
    close.ImageRectOffset = Vector2.new(284, 4)
    close.ImageRectSize = Vector2.new(24, 24)
    
    close.MouseButton1Click:Connect(function()
        Main.Visible = false -- Just hide, don't destroy, so toggle button works
    end)

    MainSide.Name = "MainSide"
    MainSide.Parent = Main
    MainSide.BackgroundColor3 = themeList.Header
    MainSide.Position = UDim2.new(0, 0, 0.091, 0)
    MainSide.Size = UDim2.new(0, 149, 0, 289)
    Utility:RegisterThemeObject(MainSide, "Header", "BackgroundColor3")

    sideCorner.CornerRadius = UDim.new(0, 4)
    sideCorner.Parent = MainSide

    coverup_2.Name = "coverup"
    coverup_2.Parent = MainSide
    coverup_2.BackgroundColor3 = themeList.Header
    coverup_2.BorderSizePixel = 0
    coverup_2.Position = UDim2.new(0.9499, 0, 0, 0)
    coverup_2.Size = UDim2.new(0, 7, 0, 289)
    Utility:RegisterThemeObject(coverup_2, "Header", "BackgroundColor3")

    tabFrames.Name = "tabFrames"
    tabFrames.Parent = MainSide
    tabFrames.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    tabFrames.BackgroundTransparency = 1.000
    tabFrames.Position = UDim2.new(0.044, 0, 0, 0)
    tabFrames.Size = UDim2.new(0, 135, 0, 283)

    tabListing.Name = "tabListing"
    tabListing.Parent = tabFrames
    tabListing.SortOrder = Enum.SortOrder.LayoutOrder
    tabListing.Padding = UDim.new(0, 5)

    pages.Name = "pages"
    pages.Parent = Main
    pages.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    pages.BackgroundTransparency = 1.000
    pages.Position = UDim2.new(0.299, 0, 0.122, 0)
    pages.Size = UDim2.new(0, 360, 0, 269)

    Pages.Name = "Pages"
    Pages.Parent = pages

    infoContainer.Name = "infoContainer"
    infoContainer.Parent = Main
    infoContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    infoContainer.BackgroundTransparency = 1.000
    infoContainer.ClipsDescendants = true
    infoContainer.Position = UDim2.new(0.299, 0, 0.874, 0)
    infoContainer.Size = UDim2.new(0, 368, 0, 33)

    blurFrame.Name = "blurFrame"
    blurFrame.Parent = pages
    blurFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    blurFrame.BackgroundTransparency = 1
    blurFrame.BorderSizePixel = 0
    blurFrame.Position = UDim2.new(-0.022, 0, -0.037, 0)
    blurFrame.Size = UDim2.new(0, 376, 0, 289)
    blurFrame.ZIndex = 999

    --// Theme Update Function
    function Kavo:ChangeColor(property, color)
        themeList[property] = color
        
        if ThemeRegistry[property] then
            for _, data in ipairs(ThemeRegistry[property]) do
                if data.Object then
                    data.Object[data.Property] = color
                end
            end
        end
        
        -- Handle derived colors (slightly brighter/darker)
        -- This logic replaces the complex math in the original loops
        -- For simplicity in this optimization, we update primary colors. 
        -- In a full rewrite, derived colors should be registered separately.
    end

    local Tabs = {}
    local first = true

    function Tabs:NewTab(tabName)
        tabName = tabName or "Tab"
        local tabButton = Instance.new("TextButton")
        local UICorner = Instance.new("UICorner")
        local page = Instance.new("ScrollingFrame")
        local pageListing = Instance.new("UIListLayout")

        local function UpdateSize()
            local cS = pageListing.AbsoluteContentSize
            page.CanvasSize = UDim2.new(0, cS.X, 0, cS.Y)
        end

        page.Name = "Page"
        page.Parent = Pages
        page.Active = true
        page.BackgroundColor3 = themeList.Background
        page.BorderSizePixel = 0
        page.Position = UDim2.new(0, 0, -0.003, 0)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.ScrollBarThickness = 5
        page.Visible = false
        page.ScrollBarImageColor3 = themeList.SchemeColor
        
        Utility:RegisterThemeObject(page, "Background", "BackgroundColor3")
        Utility:RegisterThemeObject(page, "SchemeColor", "ScrollBarImageColor3")

        pageListing.Name = "pageListing"
        pageListing.Parent = page
        pageListing.SortOrder = Enum.SortOrder.LayoutOrder
        pageListing.Padding = UDim.new(0, 5)

        tabButton.Name = tabName.."TabButton"
        tabButton.Parent = tabFrames
        tabButton.BackgroundColor3 = themeList.SchemeColor
        tabButton.Size = UDim2.new(0, 135, 0, 28)
        tabButton.AutoButtonColor = false
        tabButton.Font = Enum.Font.Gotham
        tabButton.Text = tabName
        tabButton.TextColor3 = themeList.TextColor
        tabButton.TextSize = 14.000
        tabButton.BackgroundTransparency = 1
        
        Utility:RegisterThemeObject(tabButton, "SchemeColor", "BackgroundColor3")
        Utility:RegisterThemeObject(tabButton, "TextColor", "TextColor3")

        UICorner.CornerRadius = UDim.new(0, 5)
        UICorner.Parent = tabButton

        if first then
            first = false
            page.Visible = true
            tabButton.BackgroundTransparency = 0
            UpdateSize()
        end

        page.ChildAdded:Connect(UpdateSize)
        page.ChildRemoved:Connect(UpdateSize)

        tabButton.MouseButton1Click:Connect(function()
            UpdateSize()
            for _,v in next, Pages:GetChildren() do v.Visible = false end
            page.Visible = true
            
            for _,v in next, tabFrames:GetChildren() do
                if v:IsA("TextButton") then
                    Utility:TweenObject(v, {BackgroundTransparency = 1}, 0.2)
                end
            end
            Utility:TweenObject(tabButton, {BackgroundTransparency = 0}, 0.2)
        end)

        local Sections = {}

        function Sections:NewSection(secName, hidden)
            secName = secName or "Section"
            hidden = hidden or false
            
            local sectionFrame = Instance.new("Frame")
            local sectionHead = Instance.new("Frame")
            local sHeadCorner = Instance.new("UICorner")
            local sectionName = Instance.new("TextLabel")
            local sectionInners = Instance.new("Frame")
            local sectionElListing = Instance.new("UIListLayout")
            local sectionListing = Instance.new("UIListLayout")

            if hidden then sectionHead.Visible = false end

            sectionFrame.Name = "sectionFrame"
            sectionFrame.Parent = page
            sectionFrame.BackgroundColor3 = themeList.Background
            sectionFrame.BorderSizePixel = 0
            Utility:RegisterThemeObject(sectionFrame, "Background", "BackgroundColor3")

            sectionListing.Parent = sectionFrame
            sectionListing.SortOrder = Enum.SortOrder.LayoutOrder
            sectionListing.Padding = UDim.new(0, 5)
            
            sectionHead.Name = "sectionHead"
            sectionHead.Parent = sectionFrame
            sectionHead.BackgroundColor3 = themeList.SchemeColor
            sectionHead.Size = UDim2.new(0, 352, 0, 33)
            Utility:RegisterThemeObject(sectionHead, "SchemeColor", "BackgroundColor3")

            sHeadCorner.CornerRadius = UDim.new(0, 4)
            sHeadCorner.Parent = sectionHead

            sectionName.Name = "sectionName"
            sectionName.Parent = sectionHead
            sectionName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            sectionName.BackgroundTransparency = 1.000
            sectionName.Position = UDim2.new(0.019, 0, 0, 0)
            sectionName.Size = UDim2.new(0.98, 0, 1, 0)
            sectionName.Font = Enum.Font.Gotham
            sectionName.Text = secName
            sectionName.RichText = true
            sectionName.TextColor3 = themeList.TextColor
            sectionName.TextSize = 14.000
            sectionName.TextXAlignment = Enum.TextXAlignment.Left
            Utility:RegisterThemeObject(sectionName, "TextColor", "TextColor3")

            sectionInners.Name = "sectionInners"
            sectionInners.Parent = sectionFrame
            sectionInners.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            sectionInners.BackgroundTransparency = 1.000
            sectionInners.Position = UDim2.new(0, 0, 0.19, 0)

            sectionElListing.Name = "sectionElListing"
            sectionElListing.Parent = sectionInners
            sectionElListing.SortOrder = Enum.SortOrder.LayoutOrder
            sectionElListing.Padding = UDim.new(0, 3)

            local function updateSectionFrame()
                local innerSc = sectionElListing.AbsoluteContentSize
                sectionInners.Size = UDim2.new(1, 0, 0, innerSc.Y)
                local frameSc = sectionListing.AbsoluteContentSize
                sectionFrame.Size = UDim2.new(0, 352, 0, frameSc.Y)
                UpdateSize()
            end
            
            updateSectionFrame()

            local Elements = {}

            function Elements:NewButton(bname, tipInf, callback)
                bname = bname or "Click Me!"
                tipInf = tipInf or "Tip: Clicking this nothing will happen!"
                callback = callback or function() end

                local buttonElement = Instance.new("TextButton")
                local UICorner = Instance.new("UICorner")
                local btnInfo = Instance.new("TextLabel")
                local touch = Instance.new("ImageLabel")

                buttonElement.Name = bname
                buttonElement.Parent = sectionInners
                buttonElement.BackgroundColor3 = themeList.ElementColor
                buttonElement.ClipsDescendants = true
                buttonElement.Size = UDim2.new(0, 352, 0, 33)
                buttonElement.AutoButtonColor = false
                buttonElement.Text = ""
                Utility:RegisterThemeObject(buttonElement, "ElementColor", "BackgroundColor3")

                UICorner.CornerRadius = UDim.new(0, 4)
                UICorner.Parent = buttonElement

                touch.Name = "touch"
                touch.Parent = buttonElement
                touch.BackgroundTransparency = 1
                touch.Position = UDim2.new(0.02, 0, 0.18, 0)
                touch.Size = UDim2.new(0, 21, 0, 21)
                touch.Image = "rbxassetid://3926305904"
                touch.ImageRectOffset = Vector2.new(84, 204)
                touch.ImageRectSize = Vector2.new(36, 36)
                touch.ImageColor3 = themeList.SchemeColor
                Utility:RegisterThemeObject(touch, "SchemeColor", "ImageColor3")

                btnInfo.Name = "btnInfo"
                btnInfo.Parent = buttonElement
                btnInfo.BackgroundTransparency = 1
                btnInfo.Position = UDim2.new(0.096, 0, 0.272, 0)
                btnInfo.Size = UDim2.new(0, 314, 0, 14)
                btnInfo.Font = Enum.Font.GothamSemibold
                btnInfo.Text = bname
                btnInfo.RichText = true
                btnInfo.TextColor3 = themeList.TextColor
                btnInfo.TextSize = 14.000
                btnInfo.TextXAlignment = Enum.TextXAlignment.Left
                Utility:RegisterThemeObject(btnInfo, "TextColor", "TextColor3")

                buttonElement.MouseButton1Click:Connect(function()
                    callback()
                    -- Simple ripple effect here if desired
                end)

                updateSectionFrame()
                return {
                    UpdateButton = function(self, newTitle)
                        btnInfo.Text = newTitle
                    end
                }
            end

            function Elements:NewToggle(tname, nTip, callback)
                tname = tname or "Toggle"
                callback = callback or function() end
                local toggled = false

                local toggleElement = Instance.new("TextButton")
                local UICorner = Instance.new("UICorner")
                local toggleDisabled = Instance.new("ImageLabel")
                local toggleEnabled = Instance.new("ImageLabel")
                local togName = Instance.new("TextLabel")

                toggleElement.Name = "toggleElement"
                toggleElement.Parent = sectionInners
                toggleElement.BackgroundColor3 = themeList.ElementColor
                toggleElement.ClipsDescendants = true
                toggleElement.Size = UDim2.new(0, 352, 0, 33)
                toggleElement.AutoButtonColor = false
                toggleElement.Text = ""
                Utility:RegisterThemeObject(toggleElement, "ElementColor", "BackgroundColor3")

                UICorner.CornerRadius = UDim.new(0, 4)
                UICorner.Parent = toggleElement

                toggleDisabled.Name = "toggleDisabled"
                toggleDisabled.Parent = toggleElement
                toggleDisabled.BackgroundTransparency = 1
                toggleDisabled.Position = UDim2.new(0.02, 0, 0.18, 0)
                toggleDisabled.Size = UDim2.new(0, 21, 0, 21)
                toggleDisabled.Image = "rbxassetid://3926309567"
                toggleDisabled.ImageColor3 = themeList.SchemeColor
                toggleDisabled.ImageRectOffset = Vector2.new(628, 420)
                toggleDisabled.ImageRectSize = Vector2.new(48, 48)
                Utility:RegisterThemeObject(toggleDisabled, "SchemeColor", "ImageColor3")

                toggleEnabled.Name = "toggleEnabled"
                toggleEnabled.Parent = toggleElement
                toggleEnabled.BackgroundTransparency = 1
                toggleEnabled.Position = UDim2.new(0.02, 0, 0.18, 0)
                toggleEnabled.Size = UDim2.new(0, 21, 0, 21)
                toggleEnabled.Image = "rbxassetid://3926309567"
                toggleEnabled.ImageColor3 = themeList.SchemeColor
                toggleEnabled.ImageRectOffset = Vector2.new(784, 420)
                toggleEnabled.ImageRectSize = Vector2.new(48, 48)
                toggleEnabled.ImageTransparency = 1
                Utility:RegisterThemeObject(toggleEnabled, "SchemeColor", "ImageColor3")

                togName.Name = "togName"
                togName.Parent = toggleElement
                togName.BackgroundTransparency = 1
                togName.Position = UDim2.new(0.096, 0, 0.272, 0)
                togName.Size = UDim2.new(0, 288, 0, 14)
                togName.Font = Enum.Font.GothamSemibold
                togName.Text = tname
                togName.RichText = true
                togName.TextColor3 = themeList.TextColor
                togName.TextSize = 14.000
                togName.TextXAlignment = Enum.TextXAlignment.Left
                Utility:RegisterThemeObject(togName, "TextColor", "TextColor3")

                toggleElement.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    if toggled then
                        TweenService:Create(toggleEnabled, TweenInfo.new(0.1), {ImageTransparency = 0}):Play()
                    else
                        TweenService:Create(toggleEnabled, TweenInfo.new(0.1), {ImageTransparency = 1}):Play()
                    end
                    callback(toggled)
                end)

                updateSectionFrame()
                return {
                    UpdateToggle = function(self, newText, isTogOn)
                        if newText then togName.Text = newText end
                        if isTogOn ~= nil then
                            toggled = isTogOn
                            toggleEnabled.ImageTransparency = toggled and 0 or 1
                            callback(toggled)
                        end
                    end
                }
            end

            function Elements:NewSlider(slidInf, slidTip, maxvalue, minvalue, callback)
                slidInf = slidInf or "Slider"
                maxvalue = maxvalue or 500
                minvalue = minvalue or 16
                callback = callback or function() end

                local sliderElement = Instance.new("TextButton")
                local UICorner = Instance.new("UICorner")
                local togName = Instance.new("TextLabel")
                local sliderBtn = Instance.new("TextButton")
                local UICorner_2 = Instance.new("UICorner")
                local sliderDrag = Instance.new("Frame")
                local UICorner_3 = Instance.new("UICorner")
                local val = Instance.new("TextLabel")

                sliderElement.Name = "sliderElement"
                sliderElement.Parent = sectionInners
                sliderElement.BackgroundColor3 = themeList.ElementColor
                sliderElement.ClipsDescendants = true
                sliderElement.Size = UDim2.new(0, 352, 0, 33)
                sliderElement.AutoButtonColor = false
                sliderElement.Text = ""
                Utility:RegisterThemeObject(sliderElement, "ElementColor", "BackgroundColor3")

                UICorner.CornerRadius = UDim.new(0, 4)
                UICorner.Parent = sliderElement

                togName.Parent = sliderElement
                togName.BackgroundTransparency = 1
                togName.Position = UDim2.new(0.096, 0, 0.272, 0)
                togName.Size = UDim2.new(0, 138, 0, 14)
                togName.Font = Enum.Font.GothamSemibold
                togName.Text = slidInf
                togName.RichText = true
                togName.TextColor3 = themeList.TextColor
                togName.TextSize = 14.000
                togName.TextXAlignment = Enum.TextXAlignment.Left
                Utility:RegisterThemeObject(togName, "TextColor", "TextColor3")

                sliderBtn.Name = "sliderBtn"
                sliderBtn.Parent = sliderElement
                sliderBtn.BackgroundColor3 = Color3.fromRGB(themeList.ElementColor.r * 255 + 5, themeList.ElementColor.g * 255 + 5, themeList.ElementColor.b * 255  + 5)
                sliderBtn.Position = UDim2.new(0.488, 0, 0.393, 0)
                sliderBtn.Size = UDim2.new(0, 149, 0, 6)
                sliderBtn.AutoButtonColor = false
                sliderBtn.Text = ""

                UICorner_2.Parent = sliderBtn

                sliderDrag.Name = "sliderDrag"
                sliderDrag.Parent = sliderBtn
                sliderDrag.BackgroundColor3 = themeList.SchemeColor
                sliderDrag.Size = UDim2.new(0, 0, 1, 0)
                Utility:RegisterThemeObject(sliderDrag, "SchemeColor", "BackgroundColor3")

                UICorner_3.Parent = sliderDrag

                val.Parent = sliderElement
                val.BackgroundTransparency = 1
                val.Position = UDim2.new(0.352, 0, 0.272, 0)
                val.Size = UDim2.new(0, 41, 0, 14)
                val.Font = Enum.Font.GothamSemibold
                val.Text = minvalue
                val.TextColor3 = themeList.TextColor
                val.TextSize = 14.000
                val.TextXAlignment = Enum.TextXAlignment.Right
                Utility:RegisterThemeObject(val, "TextColor", "TextColor3")

                local function move(input)
                    local pos = UDim2.new(math.clamp((input.Position.X - sliderBtn.AbsolutePosition.X) / sliderBtn.AbsoluteSize.X, 0, 1), 0, 1, 0)
                    sliderDrag:TweenSize(pos, "Out", "Sine", 0.1, true)
                    local value = math.floor(((pos.X.Scale * maxvalue) / maxvalue) * (maxvalue - minvalue) + minvalue)
                    val.Text = tostring(value)
                    callback(value)
                end

                sliderBtn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        move(input)
                        local moveCnx = UserInputService.InputChanged:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                                move(input)
                            end
                        end)
                        local endCnx
                        endCnx = UserInputService.InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                moveCnx:Disconnect()
                                endCnx:Disconnect()
                            end
                        end)
                    end
                end)

                updateSectionFrame()
            end
            
            function Elements:NewTextBox(tname, tTip, callback)
                tname = tname or "Textbox"
                tTip = tTip or "Type here"
                callback = callback or function() end
                
                local textboxElement = Instance.new("TextButton")
                local UICorner = Instance.new("UICorner")
                local TextBox = Instance.new("TextBox")
                local UICorner_2 = Instance.new("UICorner")
                local togName = Instance.new("TextLabel")

                textboxElement.Parent = sectionInners
                textboxElement.BackgroundColor3 = themeList.ElementColor
                textboxElement.Size = UDim2.new(0, 352, 0, 33)
                textboxElement.AutoButtonColor = false
                textboxElement.Text = ""
                Utility:RegisterThemeObject(textboxElement, "ElementColor", "BackgroundColor3")

                UICorner.CornerRadius = UDim.new(0, 4)
                UICorner.Parent = textboxElement

                TextBox.Parent = textboxElement
                TextBox.BackgroundColor3 = Color3.fromRGB(themeList.ElementColor.r * 255 - 6, themeList.ElementColor.g * 255 - 6, themeList.ElementColor.b * 255 - 7)
                TextBox.Position = UDim2.new(0.488, 0, 0.212, 0)
                TextBox.Size = UDim2.new(0, 150, 0, 18)
                TextBox.Font = Enum.Font.Gotham
                TextBox.PlaceholderText = tTip
                TextBox.Text = ""
                TextBox.TextColor3 = themeList.SchemeColor
                TextBox.TextSize = 12.000
                Utility:RegisterThemeObject(TextBox, "SchemeColor", "TextColor3")

                UICorner_2.CornerRadius = UDim.new(0, 4)
                UICorner_2.Parent = TextBox

                togName.Parent = textboxElement
                togName.BackgroundTransparency = 1
                togName.Position = UDim2.new(0.096, 0, 0.272, 0)
                togName.Size = UDim2.new(0, 138, 0, 14)
                togName.Font = Enum.Font.GothamSemibold
                togName.Text = tname
                togName.TextColor3 = themeList.TextColor
                togName.TextSize = 14.000
                togName.TextXAlignment = Enum.TextXAlignment.Left
                Utility:RegisterThemeObject(togName, "TextColor", "TextColor3")

                TextBox.FocusLost:Connect(function(enterPressed)
                    if enterPressed then
                        callback(TextBox.Text)
                        TextBox.Text = ""
                    end
                end)

                updateSectionFrame()
            end

            return Elements
        end
        return Sections
    end
    return Tabs
end

return Kavo

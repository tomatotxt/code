--[[
    Kavo UI Library - Optimized & Mobile Friendly Rewrite (Fixed)
    Optimized by: AI Assistant
    
    Changes:
    - Fixed missing NewKeybind, NewDropdown, and NewColorPicker
    - Fully compatible with old Kavo scripts
    - Mobile Touch support for Sliders, Color Pickers, and Dragging
    - Performance: Removed all "while wait() do" loops
]]

local Kavo = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Utility = {}

--// Theme Management Registry
local ThemeRegistry = {
    Background = {},
    SchemeColor = {},
    Header = {},
    TextColor = {},
    ElementColor = {},
    ImageColor = {}
}

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
    DarkTheme = { SchemeColor = Color3.fromRGB(64, 64, 64), Background = Color3.fromRGB(0, 0, 0), Header = Color3.fromRGB(0, 0, 0), TextColor = Color3.fromRGB(255,255,255), ElementColor = Color3.fromRGB(20, 20, 20) },
    LightTheme = { SchemeColor = Color3.fromRGB(150, 150, 150), Background = Color3.fromRGB(255,255,255), Header = Color3.fromRGB(200, 200, 200), TextColor = Color3.fromRGB(0,0,0), ElementColor = Color3.fromRGB(224, 224, 224) },
    BloodTheme = { SchemeColor = Color3.fromRGB(227, 27, 27), Background = Color3.fromRGB(10, 10, 10), Header = Color3.fromRGB(5, 5, 5), TextColor = Color3.fromRGB(255,255,255), ElementColor = Color3.fromRGB(20, 20, 20) },
    GrapeTheme = { SchemeColor = Color3.fromRGB(166, 71, 214), Background = Color3.fromRGB(64, 50, 71), Header = Color3.fromRGB(36, 28, 41), TextColor = Color3.fromRGB(255,255,255), ElementColor = Color3.fromRGB(74, 58, 84) },
    Ocean = { SchemeColor = Color3.fromRGB(86, 76, 251), Background = Color3.fromRGB(26, 32, 58), Header = Color3.fromRGB(38, 45, 71), TextColor = Color3.fromRGB(200, 200, 200), ElementColor = Color3.fromRGB(38, 45, 71) },
    Midnight = { SchemeColor = Color3.fromRGB(26, 189, 158), Background = Color3.fromRGB(44, 62, 82), Header = Color3.fromRGB(57, 81, 105), TextColor = Color3.fromRGB(255, 255, 255), ElementColor = Color3.fromRGB(52, 74, 95) },
    Sentinel = { SchemeColor = Color3.fromRGB(230, 35, 69), Background = Color3.fromRGB(32, 32, 32), Header = Color3.fromRGB(24, 24, 24), TextColor = Color3.fromRGB(119, 209, 138), ElementColor = Color3.fromRGB(24, 24, 24) },
    Synapse = { SchemeColor = Color3.fromRGB(46, 48, 43), Background = Color3.fromRGB(13, 15, 12), Header = Color3.fromRGB(36, 38, 35), TextColor = Color3.fromRGB(152, 99, 53), ElementColor = Color3.fromRGB(24, 24, 24) },
    Serpent = { SchemeColor = Color3.fromRGB(0, 166, 58), Background = Color3.fromRGB(31, 41, 43), Header = Color3.fromRGB(22, 29, 31), TextColor = Color3.fromRGB(255,255,255), ElementColor = Color3.fromRGB(22, 29, 31) }
}

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
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
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

local LibName = "KavoUI_"..tostring(math.random(1000, 9999))

function Kavo:ToggleUI()
    local gui = CoreGui:FindFirstChild(LibName)
    if gui then gui.Enabled = not gui.Enabled end
end

function Kavo.CreateLib(kavName, themeList)
    if not themeList then themeList = GetAllThemes() end
    if type(themeList) == "string" then themeList = themeStyles[themeList] or GetAllThemes() end
    local default = GetAllThemes()
    for k,v in pairs(default) do if themeList[k] == nil then themeList[k] = v end end

    for _,v in pairs(CoreGui:GetChildren()) do if v:IsA("ScreenGui") and v.Name == LibName then v:Destroy() end end

    local ScreenGui = Instance.new("ScreenGui")
    local Main = Instance.new("Frame")
    local MainCorner = Instance.new("UICorner")
    local MainHeader = Instance.new("Frame")
    local MainSide = Instance.new("Frame")
    local tabFrames = Instance.new("Frame")
    local tabListing = Instance.new("UIListLayout")
    local pages = Instance.new("Frame")
    local Pages = Instance.new("Folder")
    
    -- Mobile Toggle
    local ToggleBtn = Instance.new("ImageButton")
    local ToggleCorner = Instance.new("UICorner")
    ToggleBtn.Name = "ToggleUI"
    ToggleBtn.Parent = ScreenGui
    ToggleBtn.BackgroundColor3 = themeList.Background
    ToggleBtn.Position = UDim2.new(0, 10, 0.5, -25)
    ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
    ToggleBtn.Image = "rbxassetid://3926305904"
    ToggleBtn.ImageRectOffset = Vector2.new(764, 764)
    ToggleBtn.ImageRectSize = Vector2.new(36, 36)
    ToggleBtn.ImageColor3 = themeList.SchemeColor
    ToggleBtn.Draggable = true
    ToggleBtn.Active = true
    ToggleCorner.CornerRadius = UDim.new(0, 100)
    ToggleCorner.Parent = ToggleBtn
    ToggleBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)
    Utility:RegisterThemeObject(ToggleBtn, "Background", "BackgroundColor3")
    Utility:RegisterThemeObject(ToggleBtn, "SchemeColor", "ImageColor3")

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
    Utility:RegisterThemeObject(Main, "Background", "BackgroundColor3")
    MainCorner.CornerRadius = UDim.new(0, 4)
    MainCorner.Parent = Main

    MainHeader.Name = "MainHeader"
    MainHeader.Parent = Main
    MainHeader.BackgroundColor3 = themeList.Header
    MainHeader.Size = UDim2.new(0, 525, 0, 29)
    Utility:RegisterThemeObject(MainHeader, "Header", "BackgroundColor3")
    local title = Instance.new("TextLabel")
    title.Parent = MainHeader
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0.017, 0, 0.345, 0)
    title.Size = UDim2.new(0, 204, 0, 8)
    title.Font = Enum.Font.Gotham
    title.RichText = true
    title.Text = kavName or "Kavo UI"
    title.TextColor3 = Color3.fromRGB(245, 245, 245)
    title.TextSize = 16.000
    title.TextXAlignment = Enum.TextXAlignment.Left

    local close = Instance.new("ImageButton")
    close.Parent = MainHeader
    close.BackgroundTransparency = 1
    close.Position = UDim2.new(0.95, 0, 0.138, 0)
    close.Size = UDim2.new(0, 21, 0, 21)
    close.Image = "rbxassetid://3926305904"
    close.ImageRectOffset = Vector2.new(284, 4)
    close.ImageRectSize = Vector2.new(24, 24)
    close.MouseButton1Click:Connect(function() Main.Visible = false end)

    MainSide.Parent = Main
    MainSide.BackgroundColor3 = themeList.Header
    MainSide.Position = UDim2.new(0, 0, 0.091, 0)
    MainSide.Size = UDim2.new(0, 149, 0, 289)
    Utility:RegisterThemeObject(MainSide, "Header", "BackgroundColor3")
    local sideCorner = Instance.new("UICorner")
    sideCorner.CornerRadius = UDim.new(0, 4)
    sideCorner.Parent = MainSide

    tabFrames.Parent = MainSide
    tabFrames.BackgroundTransparency = 1
    tabFrames.Position = UDim2.new(0.044, 0, 0, 0)
    tabFrames.Size = UDim2.new(0, 135, 0, 283)
    tabListing.Parent = tabFrames
    tabListing.SortOrder = Enum.SortOrder.LayoutOrder
    tabListing.Padding = UDim.new(0, 5)

    pages.Parent = Main
    pages.BackgroundTransparency = 1
    pages.Position = UDim2.new(0.299, 0, 0.122, 0)
    pages.Size = UDim2.new(0, 360, 0, 269)
    Pages.Parent = pages

    function Kavo:ChangeColor(property, color)
        themeList[property] = color
        if ThemeRegistry[property] then
            for _, data in ipairs(ThemeRegistry[property]) do
                if data.Object then data.Object[data.Property] = color end
            end
        end
    end

    local Tabs = {}
    local first = true

    function Tabs:NewTab(tabName)
        tabName = tabName or "Tab"
        local tabButton = Instance.new("TextButton")
        local UICorner = Instance.new("UICorner")
        local page = Instance.new("ScrollingFrame")
        local pageListing = Instance.new("UIListLayout")

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

        pageListing.Parent = page
        pageListing.SortOrder = Enum.SortOrder.LayoutOrder
        pageListing.Padding = UDim.new(0, 5)

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
        end

        local function UpdateSize()
            page.CanvasSize = UDim2.new(0, 0, 0, pageListing.AbsoluteContentSize.Y)
        end
        page.ChildAdded:Connect(UpdateSize)
        page.ChildRemoved:Connect(UpdateSize)

        tabButton.MouseButton1Click:Connect(function()
            UpdateSize()
            for _,v in next, Pages:GetChildren() do v.Visible = false end
            page.Visible = true
            for _,v in next, tabFrames:GetChildren() do
                if v:IsA("TextButton") then TweenService:Create(v, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play() end
            end
            TweenService:Create(tabButton, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        end)

        local Sections = {}
        function Sections:NewSection(secName, hidden)
            secName = secName or "Section"
            local sectionFrame = Instance.new("Frame")
            local sectionHead = Instance.new("Frame")
            local sectionName = Instance.new("TextLabel")
            local sectionInners = Instance.new("Frame")
            local sectionElListing = Instance.new("UIListLayout")
            local sectionListing = Instance.new("UIListLayout")

            if hidden then sectionHead.Visible = false end

            sectionFrame.Parent = page
            sectionFrame.BackgroundColor3 = themeList.Background
            sectionFrame.BorderSizePixel = 0
            Utility:RegisterThemeObject(sectionFrame, "Background", "BackgroundColor3")
            sectionListing.Parent = sectionFrame
            sectionListing.SortOrder = Enum.SortOrder.LayoutOrder
            sectionListing.Padding = UDim.new(0, 5)

            sectionHead.Parent = sectionFrame
            sectionHead.BackgroundColor3 = themeList.SchemeColor
            sectionHead.Size = UDim2.new(0, 352, 0, 33)
            Utility:RegisterThemeObject(sectionHead, "SchemeColor", "BackgroundColor3")
            local sHeadCorner = Instance.new("UICorner")
            sHeadCorner.CornerRadius = UDim.new(0, 4)
            sHeadCorner.Parent = sectionHead

            sectionName.Parent = sectionHead
            sectionName.BackgroundTransparency = 1
            sectionName.Position = UDim2.new(0.019, 0, 0, 0)
            sectionName.Size = UDim2.new(0.98, 0, 1, 0)
            sectionName.Font = Enum.Font.Gotham
            sectionName.Text = secName
            sectionName.RichText = true
            sectionName.TextColor3 = themeList.TextColor
            sectionName.TextSize = 14.000
            sectionName.TextXAlignment = Enum.TextXAlignment.Left
            Utility:RegisterThemeObject(sectionName, "TextColor", "TextColor3")

            sectionInners.Parent = sectionFrame
            sectionInners.BackgroundTransparency = 1
            sectionInners.Position = UDim2.new(0, 0, 0.19, 0)
            sectionElListing.Parent = sectionInners
            sectionElListing.SortOrder = Enum.SortOrder.LayoutOrder
            sectionElListing.Padding = UDim.new(0, 3)

            local function updateSectionFrame()
                sectionInners.Size = UDim2.new(1, 0, 0, sectionElListing.AbsoluteContentSize.Y)
                sectionFrame.Size = UDim2.new(0, 352, 0, sectionListing.AbsoluteContentSize.Y)
                UpdateSize()
            end

            local Elements = {}

            function Elements:NewButton(bname, tipInf, callback)
                bname = bname or "Click Me!"
                callback = callback or function() end
                local buttonElement = Instance.new("TextButton")
                local UICorner = Instance.new("UICorner")
                local btnInfo = Instance.new("TextLabel")
                local touch = Instance.new("ImageLabel")

                buttonElement.Parent = sectionInners
                buttonElement.BackgroundColor3 = themeList.ElementColor
                buttonElement.Size = UDim2.new(0, 352, 0, 33)
                buttonElement.AutoButtonColor = false
                buttonElement.Text = ""
                Utility:RegisterThemeObject(buttonElement, "ElementColor", "BackgroundColor3")
                UICorner.CornerRadius = UDim.new(0, 4)
                UICorner.Parent = buttonElement

                touch.Parent = buttonElement
                touch.BackgroundTransparency = 1
                touch.Position = UDim2.new(0.02, 0, 0.18, 0)
                touch.Size = UDim2.new(0, 21, 0, 21)
                touch.Image = "rbxassetid://3926305904"
                touch.ImageRectOffset = Vector2.new(84, 204)
                touch.ImageRectSize = Vector2.new(36, 36)
                touch.ImageColor3 = themeList.SchemeColor
                Utility:RegisterThemeObject(touch, "SchemeColor", "ImageColor3")

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

                buttonElement.MouseButton1Click:Connect(callback)
                updateSectionFrame()
                return { UpdateButton = function(_, t) btnInfo.Text = t end }
            end

            function Elements:NewToggle(tname, nTip, callback)
                tname = tname or "Toggle"
                callback = callback or function() end
                local toggled = false
                local toggleElement = Instance.new("TextButton")
                local UICorner = Instance.new("UICorner")
                local toggleEnabled = Instance.new("ImageLabel")
                local togName = Instance.new("TextLabel")

                toggleElement.Parent = sectionInners
                toggleElement.BackgroundColor3 = themeList.ElementColor
                toggleElement.Size = UDim2.new(0, 352, 0, 33)
                toggleElement.AutoButtonColor = false
                toggleElement.Text = ""
                Utility:RegisterThemeObject(toggleElement, "ElementColor", "BackgroundColor3")
                UICorner.CornerRadius = UDim.new(0, 4)
                UICorner.Parent = toggleElement

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
                    TweenService:Create(toggleEnabled, TweenInfo.new(0.1), {ImageTransparency = toggled and 0 or 1}):Play()
                    callback(toggled)
                end)
                updateSectionFrame()
                return { UpdateToggle = function(_, t, v) if t then togName.Text=t end if v~=nil then toggled=v toggleEnabled.ImageTransparency=toggled and 0 or 1 callback(toggled) end end }
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
                local sliderDrag = Instance.new("Frame")
                local val = Instance.new("TextLabel")

                sliderElement.Parent = sectionInners
                sliderElement.BackgroundColor3 = themeList.ElementColor
                sliderElement.Size = UDim2.new(0, 352, 0, 33)
                sliderElement.AutoButtonColor = false
                sliderElement.Text = ""
                Utility:RegisterThemeObject(sliderElement, "ElementColor", "BackgroundColor3")
                UICorner.CornerRadius = UDim.new(0, 4)
                UICorner.Parent = sliderElement

                togName.Parent = sliderElement
                togName.BackgroundTransparency = 1
                togName.Position = UDim2.new(0.096, 0, 0.272, 0)
                togName.Font = Enum.Font.GothamSemibold
                togName.Text = slidInf
                togName.TextColor3 = themeList.TextColor
                togName.TextSize = 14.000
                togName.TextXAlignment = Enum.TextXAlignment.Left
                togName.Size = UDim2.new(0, 138, 0, 14)
                Utility:RegisterThemeObject(togName, "TextColor", "TextColor3")

                sliderBtn.Parent = sliderElement
                sliderBtn.BackgroundColor3 = Color3.fromRGB(themeList.ElementColor.r * 255 + 5, themeList.ElementColor.g * 255 + 5, themeList.ElementColor.b * 255 + 5)
                sliderBtn.Position = UDim2.new(0.488, 0, 0.393, 0)
                sliderBtn.Size = UDim2.new(0, 149, 0, 6)
                sliderBtn.AutoButtonColor = false
                sliderBtn.Text = ""
                local UICorner_2 = Instance.new("UICorner"); UICorner_2.Parent = sliderBtn

                sliderDrag.Parent = sliderBtn
                sliderDrag.BackgroundColor3 = themeList.SchemeColor
                sliderDrag.Size = UDim2.new(0, 0, 1, 0)
                Utility:RegisterThemeObject(sliderDrag, "SchemeColor", "BackgroundColor3")
                local UICorner_3 = Instance.new("UICorner"); UICorner_3.Parent = sliderDrag

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
                            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then move(input) end
                        end)
                        local endCnx; endCnx = UserInputService.InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                moveCnx:Disconnect(); endCnx:Disconnect()
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
                local UICorner_2 = Instance.new("UICorner"); UICorner_2.Parent = TextBox; UICorner_2.CornerRadius = UDim.new(0,4)

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

                TextBox.FocusLost:Connect(function(enter)
                    if enter then callback(TextBox.Text) TextBox.Text = "" end
                end)
                updateSectionFrame()
            end

            --// Fixed NewKeybind
            function Elements:NewKeybind(keytext, keyinf, first, callback)
                keytext = keytext or "Keybind"
                callback = callback or function() end
                local oldKey = first.Name
                local keybindElement = Instance.new("TextButton")
                local UICorner = Instance.new("UICorner")
                local togName = Instance.new("TextLabel")
                local togName_2 = Instance.new("TextLabel")

                keybindElement.Parent = sectionInners
                keybindElement.BackgroundColor3 = themeList.ElementColor
                keybindElement.Size = UDim2.new(0, 352, 0, 33)
                keybindElement.AutoButtonColor = false
                keybindElement.Text = ""
                Utility:RegisterThemeObject(keybindElement, "ElementColor", "BackgroundColor3")
                UICorner.CornerRadius = UDim.new(0, 4)
                UICorner.Parent = keybindElement

                togName.Parent = keybindElement
                togName.BackgroundTransparency = 1
                togName.Position = UDim2.new(0.096, 0, 0.272, 0)
                togName.Size = UDim2.new(0, 222, 0, 14)
                togName.Font = Enum.Font.GothamSemibold
                togName.Text = keytext
                togName.TextColor3 = themeList.TextColor
                togName.TextSize = 14.000
                togName.TextXAlignment = Enum.TextXAlignment.Left
                Utility:RegisterThemeObject(togName, "TextColor", "TextColor3")

                togName_2.Parent = keybindElement
                togName_2.BackgroundTransparency = 1
                togName_2.Position = UDim2.new(0.727, 0, 0.272, 0)
                togName_2.Size = UDim2.new(0, 70, 0, 14)
                togName_2.Font = Enum.Font.GothamSemibold
                togName_2.Text = oldKey
                togName_2.TextColor3 = themeList.SchemeColor
                togName_2.TextSize = 14.000
                togName_2.TextXAlignment = Enum.TextXAlignment.Right
                Utility:RegisterThemeObject(togName_2, "SchemeColor", "TextColor3")

                keybindElement.MouseButton1Click:Connect(function()
                    togName_2.Text = ". . ."
                    local input, gameProcessed = UserInputService.InputBegan:Wait()
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        togName_2.Text = input.KeyCode.Name
                        oldKey = input.KeyCode.Name
                    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                        togName_2.Text = "MB1"
                        oldKey = "MouseButton1"
                    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                        togName_2.Text = "MB2"
                        oldKey = "MouseButton2"
                    else
                        togName_2.Text = oldKey
                    end
                end)

                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if not gameProcessed then
                        local key = input.KeyCode.Name
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then key = "MouseButton1" end
                        if input.UserInputType == Enum.UserInputType.MouseButton2 then key = "MouseButton2" end
                        if key == oldKey then callback() end
                    end
                end)
                updateSectionFrame()
            end

            --// Fixed NewDropdown
            function Elements:NewDropdown(dropname, dropinf, list, callback)
                local DropFunction = {}
                dropname = dropname or "Dropdown"
                list = list or {}
                callback = callback or function() end
                local opened = false
                local dropFrame = Instance.new("Frame")
                local dropOpen = Instance.new("TextButton")
                local itemTextbox = Instance.new("TextLabel")
                local listImg = Instance.new("ImageLabel")
                local UICorner = Instance.new("UICorner")
                local UIListLayout = Instance.new("UIListLayout")

                dropFrame.Parent = sectionInners
                dropFrame.BackgroundColor3 = themeList.Background
                dropFrame.BorderSizePixel = 0
                dropFrame.Size = UDim2.new(0, 352, 0, 33)
                dropFrame.ClipsDescendants = true
                Utility:RegisterThemeObject(dropFrame, "Background", "BackgroundColor3")

                dropOpen.Parent = dropFrame
                dropOpen.BackgroundColor3 = themeList.ElementColor
                dropOpen.Size = UDim2.new(0, 352, 0, 33)
                dropOpen.AutoButtonColor = false
                dropOpen.Text = ""
                Utility:RegisterThemeObject(dropOpen, "ElementColor", "BackgroundColor3")
                UICorner.CornerRadius = UDim.new(0, 4)
                UICorner.Parent = dropOpen

                itemTextbox.Parent = dropOpen
                itemTextbox.BackgroundTransparency = 1
                itemTextbox.Position = UDim2.new(0.097, 0, 0.273, 0)
                itemTextbox.Size = UDim2.new(0, 138, 0, 14)
                itemTextbox.Font = Enum.Font.GothamSemibold
                itemTextbox.Text = dropname
                itemTextbox.TextColor3 = themeList.TextColor
                itemTextbox.TextSize = 14.000
                itemTextbox.TextXAlignment = Enum.TextXAlignment.Left
                Utility:RegisterThemeObject(itemTextbox, "TextColor", "TextColor3")

                listImg.Parent = dropOpen
                listImg.BackgroundTransparency = 1
                listImg.Position = UDim2.new(0.019, 0, 0.18, 0)
                listImg.Size = UDim2.new(0, 21, 0, 21)
                listImg.Image = "rbxassetid://3926305904"
                listImg.ImageColor3 = themeList.SchemeColor
                listImg.ImageRectOffset = Vector2.new(644, 364)
                listImg.ImageRectSize = Vector2.new(36, 36)
                Utility:RegisterThemeObject(listImg, "SchemeColor", "ImageColor3")

                UIListLayout.Parent = dropFrame
                UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                UIListLayout.Padding = UDim.new(0, 3)

                local function RefreshList(newList)
                    for _,v in next, dropFrame:GetChildren() do if v.Name == "optionSelect" then v:Destroy() end end
                    for _,v in next, newList do
                        local optionSelect = Instance.new("TextButton")
                        local UICorner_2 = Instance.new("UICorner")
                        optionSelect.Name = "optionSelect"
                        optionSelect.Parent = dropFrame
                        optionSelect.BackgroundColor3 = themeList.ElementColor
                        optionSelect.Size = UDim2.new(0, 352, 0, 33)
                        optionSelect.AutoButtonColor = false
                        optionSelect.Font = Enum.Font.GothamSemibold
                        optionSelect.Text = "  "..v
                        optionSelect.TextColor3 = themeList.TextColor
                        optionSelect.TextSize = 14.000
                        optionSelect.TextXAlignment = Enum.TextXAlignment.Left
                        Utility:RegisterThemeObject(optionSelect, "ElementColor", "BackgroundColor3")
                        Utility:RegisterThemeObject(optionSelect, "TextColor", "TextColor3")
                        UICorner_2.CornerRadius = UDim.new(0, 4)
                        UICorner_2.Parent = optionSelect

                        optionSelect.MouseButton1Click:Connect(function()
                            opened = false
                            callback(v)
                            itemTextbox.Text = v
                            dropFrame:TweenSize(UDim2.new(0, 352, 0, 33), "InOut", "Linear", 0.08)
                            updateSectionFrame()
                        end)
                    end
                end
                RefreshList(list)

                dropOpen.MouseButton1Click:Connect(function()
                    opened = not opened
                    if opened then
                        dropFrame:TweenSize(UDim2.new(0, 352, 0, UIListLayout.AbsoluteContentSize.Y), "InOut", "Linear", 0.08, true)
                    else
                        dropFrame:TweenSize(UDim2.new(0, 352, 0, 33), "InOut", "Linear", 0.08)
                    end
                    updateSectionFrame()
                end)

                updateSectionFrame()
                function DropFunction:Refresh(nList) RefreshList(nList) end
                return DropFunction
            end

            --// Fixed NewColorPicker
            function Elements:NewColorPicker(colText, colInf, defcolor, callback)
                colText = colText or "ColorPicker"
                callback = callback or function() end
                defcolor = defcolor or Color3.fromRGB(255, 255, 255)
                local h, s, v = Color3.toHSV(defcolor)
                local colorOpened = false
                
                local colorElement = Instance.new("TextButton")
                local UICorner = Instance.new("UICorner")
                local colorHeader = Instance.new("Frame")
                local togName = Instance.new("TextLabel")
                local colorCurrent = Instance.new("Frame")
                local colorInners = Instance.new("Frame")
                local rgb = Instance.new("ImageButton")
                local rbgcircle = Instance.new("ImageLabel")
                
                colorElement.Parent = sectionInners
                colorElement.BackgroundColor3 = themeList.ElementColor
                colorElement.BackgroundTransparency = 1
                colorElement.Size = UDim2.new(0, 352, 0, 33)
                colorElement.AutoButtonColor = false
                colorElement.Text = ""
                UICorner.CornerRadius = UDim.new(0, 4)
                UICorner.Parent = colorElement

                colorHeader.Parent = colorElement
                colorHeader.BackgroundColor3 = themeList.ElementColor
                colorHeader.Size = UDim2.new(0, 352, 0, 33)
                Utility:RegisterThemeObject(colorHeader, "ElementColor", "BackgroundColor3")
                local UICorner_2 = Instance.new("UICorner"); UICorner_2.CornerRadius = UDim.new(0,4); UICorner_2.Parent = colorHeader

                togName.Parent = colorHeader
                togName.BackgroundTransparency = 1
                togName.Position = UDim2.new(0.096, 0, 0.272, 0)
                togName.Size = UDim2.new(0, 288, 0, 14)
                togName.Font = Enum.Font.GothamSemibold
                togName.Text = colText
                togName.TextColor3 = themeList.TextColor
                togName.TextSize = 14.000
                togName.TextXAlignment = Enum.TextXAlignment.Left
                Utility:RegisterThemeObject(togName, "TextColor", "TextColor3")

                colorCurrent.Parent = colorHeader
                colorCurrent.BackgroundColor3 = defcolor
                colorCurrent.Position = UDim2.new(0.792, 0, 0.212, 0)
                colorCurrent.Size = UDim2.new(0, 42, 0, 18)
                local UICorner_3 = Instance.new("UICorner"); UICorner_3.CornerRadius = UDim.new(0,4); UICorner_3.Parent = colorCurrent

                colorInners.Parent = colorElement
                colorInners.BackgroundColor3 = themeList.ElementColor
                colorInners.Position = UDim2.new(0, 0, 0.255, 0)
                colorInners.Size = UDim2.new(0, 352, 0, 105)
                Utility:RegisterThemeObject(colorInners, "ElementColor", "BackgroundColor3")
                local UICorner_4 = Instance.new("UICorner"); UICorner_4.CornerRadius = UDim.new(0,4); UICorner_4.Parent = colorInners

                rgb.Parent = colorInners
                rgb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                rgb.BackgroundTransparency = 1
                rgb.Position = UDim2.new(0.019, 0, 0.047, 0)
                rgb.Size = UDim2.new(0, 211, 0, 93)
                rgb.Image = "http://www.roblox.com/asset/?id=6523286724"
                local UICorner_5 = Instance.new("UICorner"); UICorner_5.CornerRadius = UDim.new(0,4); UICorner_5.Parent = rgb

                rbgcircle.Parent = rgb
                rbgcircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                rbgcircle.BackgroundTransparency = 1
                rbgcircle.Size = UDim2.new(0, 14, 0, 14)
                rbgcircle.Image = "rbxassetid://3926309567"
                rbgcircle.ImageRectOffset = Vector2.new(628, 420)
                rbgcircle.ImageRectSize = Vector2.new(48, 48)

                local function updateColor(input)
                    local pos = UDim2.new(math.clamp((input.Position.X - rgb.AbsolutePosition.X) / rgb.AbsoluteSize.X, 0, 1), 0, math.clamp((input.Position.Y - rgb.AbsolutePosition.Y) / rgb.AbsoluteSize.Y, 0, 1), 0)
                    rbgcircle.Position = UDim2.new(pos.X.Scale, -7, pos.Y.Scale, -7)
                    local color = Color3.fromHSV(1 - pos.X.Scale, 1 - pos.Y.Scale, 1)
                    colorCurrent.BackgroundColor3 = color
                    callback(color)
                end

                rgb.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        updateColor(input)
                        local moveCnx = UserInputService.InputChanged:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then updateColor(input) end
                        end)
                        local endCnx; endCnx = UserInputService.InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                moveCnx:Disconnect(); endCnx:Disconnect()
                            end
                        end)
                    end
                end)

                colorHeader.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        colorOpened = not colorOpened
                        colorElement:TweenSize(UDim2.new(0, 352, 0, colorOpened and 141 or 33), "InOut", "Linear", 0.08, true)
                        updateSectionFrame()
                    end
                end)
                updateSectionFrame()
            end

            function Elements:NewLabel(title)
                local label = Instance.new("TextLabel")
                local UICorner = Instance.new("UICorner")
                label.Parent = sectionInners
                label.BackgroundColor3 = themeList.SchemeColor
                label.Text = "  "..title
                label.Size = UDim2.new(0, 352, 0, 33)
                label.Font = Enum.Font.Gotham
                label.RichText = true
                label.TextColor3 = themeList.TextColor
                label.TextSize = 14.000
                label.TextXAlignment = Enum.TextXAlignment.Left
                Utility:RegisterThemeObject(label, "SchemeColor", "BackgroundColor3")
                Utility:RegisterThemeObject(label, "TextColor", "TextColor3")
                UICorner.CornerRadius = UDim.new(0, 4)
                UICorner.Parent = label
                updateSectionFrame()
                return { UpdateLabel = function(_, t) label.Text = "  "..t end }
            end

            return Elements
        end
        return Sections
    end
    return Tabs
end

return Kavo

--[[
    RadiantUI - Professional Roblox GUI Library
    Version: 2.0.0
    Author: RadiantHub Development Team
]]--

local RadiantUI = {}
RadiantUI.__index = RadiantUI
RadiantUI.Version = "2.0.0"

-- Services
local Players = game:GetService('Players')
local TweenService = game:GetService('TweenService')
local UserInputService = game:GetService('UserInputService')
local RunService = game:GetService('RunService')

-- Constants
local MAX_USER_TABS = 4
local SETTINGS_TAB_INDEX = 5

-- Default Configuration
local DEFAULT_CONFIG = {
    Title = "RadiantUI",
    Size = UDim2.new(0, 1000, 0, 600),
    Position = UDim2.new(0.5, -500, 0.5, -300),
    Theme = {
        Primary = Color3.fromRGB(255, 51, 51),
        Background = Color3.fromRGB(18, 18, 18),
        Secondary = Color3.fromRGB(30, 30, 30),
        Sidebar = Color3.fromRGB(20, 20, 20),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(170, 170, 170),
        Border = Color3.fromRGB(51, 51, 51)
    },
    DefaultKeybind = Enum.KeyCode.RightControl,
    ShowWatermark = true,
    EnableNotifications = true
}

-- GLOBALER Z-INDEX MANAGER für Dropdown-Überlappung
local DROPDOWN_Z_INDEX_BASE = 1000
local DROPDOWN_Z_INDEX_COUNTER = 0

local function getNextDropdownZIndex()
    DROPDOWN_Z_INDEX_COUNTER = DROPDOWN_Z_INDEX_COUNTER + 10
    return DROPDOWN_Z_INDEX_BASE + DROPDOWN_Z_INDEX_COUNTER
end

function RadiantUI.new(config)
    local self = setmetatable({}, RadiantUI)
    
    self.Config = config or {}
    for key, value in pairs(DEFAULT_CONFIG) do
        if self.Config[key] == nil then
            self.Config[key] = value
        end
    end
    
    self.Tabs = {}
    self.CurrentTab = 1
    self.GuiVisible = true
    self.ToggleKeybind = self.Config.DefaultKeybind
    self.Elements = {}
    self.Connections = {}
    self.Tweens = {}
    self.Notifications = {}
    self.KeybindCooldown = false -- Cooldown für Keybind-Änderungen
    
    self:Initialize()
    return self
end

function RadiantUI:Initialize()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild('PlayerGui')
    
    self.ScreenGui = Instance.new('ScreenGui')
    self.ScreenGui.Name = 'RadiantUI_' .. tick()
    self.ScreenGui.Parent = playerGui
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.IgnoreGuiInset = true
    
    self.MainFrame = Instance.new('Frame')
    self.MainFrame.Name = 'MainContainer'
    self.MainFrame.Size = self.Config.Size
    self.MainFrame.Position = self.Config.Position
    self.MainFrame.BackgroundColor3 = self.Config.Theme.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.ClipsDescendants = false
    self.MainFrame.Parent = self.ScreenGui
    
    local mainCorner = Instance.new('UICorner')
    mainCorner.CornerRadius = UDim.new(0, 20)
    mainCorner.Parent = self.MainFrame
    
    local mainStroke = Instance.new('UIStroke')
    mainStroke.Thickness = 2
    mainStroke.Color = self.Config.Theme.Border
    mainStroke.Parent = self.MainFrame
    
    self:CreateHeader()
    self:CreateSidebar()
    self:CreateContent()
    self:CreateWatermark()
    self:MakeDraggable()
    self:SetupKeybinds()
    -- Settings tab wird später erstellt nach User-Tabs
    
    -- Fade animations entfernt für bessere Performance
    
    task.spawn(function()
        task.wait(1)
        self:ShowNotification("RadiantUI " .. self.Version .. " loaded successfully!", 4)
        -- Erstelle Settings Tab falls noch nicht erstellt
        if not self.SettingsTab then
            self:CreateSettingsTab()
        end
        
        -- WICHTIG: Initialisiere den ersten Tab automatisch
        if #self.Tabs > 0 and not self.Tabs[1].Content then
            self:CreateTabContent(1)
            if self.Tabs[1].Content then
                self.Tabs[1].Content.Visible = true
            end
        end
    end)
end

function RadiantUI:CreateHeader()
    self.HeaderFrame = Instance.new('Frame')
    self.HeaderFrame.Name = 'Header'
    self.HeaderFrame.Size = UDim2.new(1, 0, 0, 60)
    self.HeaderFrame.Position = UDim2.new(0, 0, 0, 0)
    self.HeaderFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
    self.HeaderFrame.BorderSizePixel = 0
    self.HeaderFrame.Parent = self.MainFrame
    
    local headerCorner = Instance.new('UICorner')
    headerCorner.CornerRadius = UDim.new(0, 20)
    headerCorner.Parent = self.HeaderFrame
    
    -- Header corner covers to make bottom corners square
    local headerBottomLeftCover = Instance.new('Frame')
    headerBottomLeftCover.Name = 'HeaderBottomLeftCover'
    headerBottomLeftCover.Size = UDim2.new(0, 20, 0, 20)
    headerBottomLeftCover.Position = UDim2.new(0, 0, 1, -20)
    headerBottomLeftCover.BackgroundColor3 = Color3.fromRGB(26, 26, 26) -- Exakte Header-Farbe
    headerBottomLeftCover.BorderSizePixel = 0
    headerBottomLeftCover.Parent = self.HeaderFrame
    
    local headerBottomRightCover = Instance.new('Frame')
    headerBottomRightCover.Name = 'HeaderBottomRightCover'
    headerBottomRightCover.Size = UDim2.new(0, 20, 0, 20)
    headerBottomRightCover.Position = UDim2.new(1, -20, 1, -20)
    headerBottomRightCover.BackgroundColor3 = Color3.fromRGB(26, 26, 26) -- Exakte Header-Farbe
    headerBottomRightCover.BorderSizePixel = 0
    headerBottomRightCover.Parent = self.HeaderFrame
    
    self.TitleLabel = Instance.new('TextLabel')
    self.TitleLabel.Size = UDim2.new(0, 250, 1, 0)
    self.TitleLabel.Position = UDim2.new(0, 20, 0, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Config.Title
    self.TitleLabel.TextColor3 = self.Config.Theme.Primary
    self.TitleLabel.TextSize = 24
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.Parent = self.HeaderFrame
    
    self:CreateControlButtons()
    
    local headerBorder = Instance.new('Frame')
    headerBorder.Size = UDim2.new(1, 0, 0, 2)
    headerBorder.Position = UDim2.new(0, 0, 1, -2)
    headerBorder.BackgroundColor3 = self.Config.Theme.Border
    headerBorder.BorderSizePixel = 0
    headerBorder.Parent = self.HeaderFrame
end

function RadiantUI:CreateControlButtons()
    local controlsFrame = Instance.new('Frame')
    controlsFrame.Size = UDim2.new(0, 100, 0, 20)
    controlsFrame.Position = UDim2.new(1, -90, 0.5, -10)
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.BorderSizePixel = 0
    controlsFrame.Visible = true  -- Explizit sichtbar
    controlsFrame.Parent = self.HeaderFrame
    
    local buttons = {
        {name = "Minimize", color = Color3.fromRGB(255, 189, 46)},
        {name = "Maximize", color = Color3.fromRGB(40, 202, 66)},
        {name = "Close", color = Color3.fromRGB(255, 95, 87)}
    }
    
    for i, buttonData in ipairs(buttons) do
        local button = Instance.new('TextButton')
        button.Name = buttonData.name
        button.Size = UDim2.new(0, 12, 0, 12)
        button.Position = UDim2.new(0, (i - 1) * 20, 0.5, -6)
        button.BackgroundColor3 = buttonData.color
        button.BorderSizePixel = 0
        button.Text = ''
        button.Parent = controlsFrame
        
        local corner = Instance.new('UICorner')
        corner.CornerRadius = UDim.new(0.5, 0)
        corner.Parent = button
        
        if buttonData.name == "Close" then
            button.MouseButton1Click:Connect(function()
                self:Destroy()
            end)
        elseif buttonData.name == "Minimize" then
            button.MouseButton1Click:Connect(function()
                local isMinimized = self.MainFrame.Size.Y.Offset <= 60
                local targetSize = isMinimized and self.Config.Size or UDim2.new(0, 1000, 0, 60)
                TweenService:Create(self.MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Size = targetSize}):Play()
            end)
        end
        
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.3), {Size = UDim2.new(0, 14, 0, 14)}):Play()
        end)
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.3), {Size = UDim2.new(0, 12, 0, 12)}):Play()
        end)
    end
end

function RadiantUI:CreateSidebar()
    self.SidebarFrame = Instance.new('ScrollingFrame')
    self.SidebarFrame.Size = UDim2.new(0, 200, 1, -60)
    self.SidebarFrame.Position = UDim2.new(0, 0, 0, 60)
    self.SidebarFrame.BackgroundColor3 = self.Config.Theme.Sidebar
    self.SidebarFrame.BorderSizePixel = 0
    self.SidebarFrame.ScrollBarThickness = 2
    self.SidebarFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    self.SidebarFrame.ScrollBarImageTransparency = 0.3
    self.SidebarFrame.CanvasSize = UDim2.new(0, 0, 0, 800) -- Fixed canvas size
    self.SidebarFrame.Parent = self.MainFrame
    
    local sidebarCorner = Instance.new('UICorner')
    sidebarCorner.CornerRadius = UDim.new(0, 15)
    sidebarCorner.Parent = self.SidebarFrame
    
    -- Corner covers to make sharp corners at the bottom
    -- Bottom-left corner cover
    local sidebarBottomLeftCover = Instance.new('Frame')
    sidebarBottomLeftCover.Name = 'SidebarBottomLeftCover'
    sidebarBottomLeftCover.Size = UDim2.new(0, 15, 0, 15)
    sidebarBottomLeftCover.Position = UDim2.new(0, 0, 1, -15)
    sidebarBottomLeftCover.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Exakte Sidebar-Farbe
    sidebarBottomLeftCover.BorderSizePixel = 0
    sidebarBottomLeftCover.Parent = self.SidebarFrame
    
    -- Bottom-right corner cover
    local sidebarBottomRightCover = Instance.new('Frame')
    sidebarBottomRightCover.Name = 'SidebarBottomRightCover'
    sidebarBottomRightCover.Size = UDim2.new(0, 15, 0, 15)
    sidebarBottomRightCover.Position = UDim2.new(1, -15, 1, -15)
    sidebarBottomRightCover.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Exakte Sidebar-Farbe
    sidebarBottomRightCover.BorderSizePixel = 0
    sidebarBottomRightCover.Parent = self.SidebarFrame
    
    self:CreateAvatarSection()
end

function RadiantUI:CreateAvatarSection()
	-- Avatar section positioned at the bottom of the visible sidebar (NOT in ScrollingFrame)
	local avatarSection = Instance.new("Frame")
	avatarSection.Name = "AvatarSection"
	avatarSection.Size = UDim2.new(0, 200, 0, 90) -- Fixed width like sidebar
	avatarSection.Position = UDim2.new(0, 0, 1, -80) -- Etwas näher zum unteren Rand
	avatarSection.BackgroundTransparency = 1 -- Transparent
	avatarSection.BorderSizePixel = 0
	avatarSection.Parent = self.MainFrame -- Parent ist MainFrame, NICHT SidebarFrame!

	-- Avatar circle
	local avatarCircle = Instance.new("Frame")
	avatarCircle.Name = "AvatarCircle"
	avatarCircle.Size = UDim2.new(0, 50, 0, 50)
	avatarCircle.Position = UDim2.new(0, 15, 0.5, -25)
	avatarCircle.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	avatarCircle.BorderSizePixel = 0
	avatarCircle.Parent = avatarSection

	-- Avatar corner radius
	local avatarCorner = Instance.new("UICorner")
	avatarCorner.CornerRadius = UDim.new(0.5, 0)
	avatarCorner.Parent = avatarCircle

	-- Avatar image (Roblox avatar)
	local avatarImage = Instance.new("ImageLabel")
	avatarImage.Name = "AvatarImage"
	avatarImage.Size = UDim2.new(1, -4, 1, -4)
	avatarImage.Position = UDim2.new(0, 2, 0, 2)
	avatarImage.BackgroundTransparency = 1
	avatarImage.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. Players.LocalPlayer.UserId .. "&width=420&height=420&format=png"
	avatarImage.Parent = avatarCircle

	-- Avatar image corner radius
	local avatarImgCorner = Instance.new("UICorner")
	avatarImgCorner.CornerRadius = UDim.new(0.5, 0)
	avatarImgCorner.Parent = avatarImage

	-- Red status circle
	local statusCircle = Instance.new("Frame")
	statusCircle.Name = "StatusCircle"
	statusCircle.Size = UDim2.new(0, 8, 0, 8)
	statusCircle.Position = UDim2.new(1, -10, 1, -10)
	statusCircle.BackgroundColor3 = Color3.fromRGB(255, 51, 51) -- Red color
	statusCircle.BorderSizePixel = 0
	statusCircle.Parent = avatarCircle

	-- Status circle corner radius (makes it round)
	local statusCorner = Instance.new("UICorner")
	statusCorner.CornerRadius = UDim.new(0.5, 0)
	statusCorner.Parent = statusCircle

	-- Username label
	local usernameLabel = Instance.new("TextLabel")
	usernameLabel.Name = "UsernameLabel"
	usernameLabel.Size = UDim2.new(1, -75, 0, 25)
	usernameLabel.Position = UDim2.new(0, 70, 0, 23) -- Ein wenig nach unten verschoben
	usernameLabel.BackgroundTransparency = 1
	usernameLabel.Text = Players.LocalPlayer.Name
	usernameLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text
	usernameLabel.TextSize = 18
	usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
	usernameLabel.TextYAlignment = Enum.TextYAlignment.Center
	usernameLabel.Font = Enum.Font.SourceSansBold
	usernameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	usernameLabel.Parent = avatarSection

	-- Subscription label
	local subscriptionLabel = Instance.new("TextLabel")
	subscriptionLabel.Name = "SubscriptionLabel"
	subscriptionLabel.Size = UDim2.new(1, -75, 0, 20)
	subscriptionLabel.Position = UDim2.new(0, 70, 0, 48) -- Ein wenig nach unten verschoben
	subscriptionLabel.BackgroundTransparency = 1
	subscriptionLabel.Text = "Lifetime"
	subscriptionLabel.TextColor3 = Color3.fromRGB(255, 51, 51) -- Red color
	subscriptionLabel.TextSize = 16
	subscriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
	subscriptionLabel.TextYAlignment = Enum.TextYAlignment.Center
	subscriptionLabel.Font = Enum.Font.SourceSans
	subscriptionLabel.Parent = avatarSection

	-- Store references to avatar elements für spätere Verwendung
	self.AvatarSection = avatarSection
	self.AvatarCircle = avatarCircle
    self.AvatarImage = avatarImage
    self.StatusCircle = statusCircle
    self.UsernameLabel = usernameLabel
    self.SubscriptionLabel = subscriptionLabel
end

function RadiantUI:CreateContent()
    self.ContentFrame = Instance.new('Frame')
    self.ContentFrame.Size = UDim2.new(1, -202, 1, -60)
    self.ContentFrame.Position = UDim2.new(0, 202, 0, 60)
    self.ContentFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    self.ContentFrame.BorderSizePixel = 0
    self.ContentFrame.Parent = self.MainFrame
    
    local contentCorner = Instance.new('UICorner')
    contentCorner.CornerRadius = UDim.new(0, 15)
    contentCorner.Parent = self.ContentFrame
    
    local separator = Instance.new('Frame')
    separator.Size = UDim2.new(0, 2, 1, -60)
    separator.Position = UDim2.new(0, 199, 0, 60)
    separator.BackgroundColor3 = self.Config.Theme.Border
    separator.BorderSizePixel = 0
    separator.Parent = self.MainFrame
end

function RadiantUI:CreateWatermark()
    if not self.Config.ShowWatermark then return end
    
    self.WatermarkFrame = Instance.new('Frame')
    self.WatermarkFrame.Size = UDim2.new(0, 350, 0, 80)
    self.WatermarkFrame.Position = UDim2.new(1, -370, 0, 20)
    self.WatermarkFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    self.WatermarkFrame.BackgroundTransparency = 0.1
    self.WatermarkFrame.BorderSizePixel = 0
    self.WatermarkFrame.Parent = self.ScreenGui
    
    local watermarkCorner = Instance.new('UICorner')
    watermarkCorner.CornerRadius = UDim.new(0, 8)
    watermarkCorner.Parent = self.WatermarkFrame
    
    -- Make watermark draggable when menu is open
    self:MakeWatermarkDraggable()
    
    local watermarkTitle = Instance.new('TextLabel')
    watermarkTitle.Size = UDim2.new(0, 200, 0, 30)
    watermarkTitle.Position = UDim2.new(0, 15, 0, 17)
    watermarkTitle.BackgroundTransparency = 1
    watermarkTitle.Text = self.Config.Title
    watermarkTitle.TextColor3 = self.Config.Theme.Primary
    watermarkTitle.TextSize = 24
    watermarkTitle.Font = Enum.Font.GothamBold
    watermarkTitle.TextXAlignment = Enum.TextXAlignment.Left
    watermarkTitle.Parent = self.WatermarkFrame
    
    local watermarkSub = Instance.new('TextLabel')
    watermarkSub.Size = UDim2.new(0, 140, 0, 20)
    watermarkSub.Position = UDim2.new(0, 15, 0, 47)
    watermarkSub.BackgroundTransparency = 1
    watermarkSub.Text = "Premium"
    watermarkSub.TextColor3 = self.Config.Theme.Text
    watermarkSub.TextSize = 14
    watermarkSub.Font = Enum.Font.Gotham
    watermarkSub.TextXAlignment = Enum.TextXAlignment.Left
    watermarkSub.Parent = self.WatermarkFrame
    
    self.FPSLabel = Instance.new('TextLabel')
    self.FPSLabel.Size = UDim2.new(0, 120, 0, 18)
    self.FPSLabel.Position = UDim2.new(1, -125, 0, 8)
    self.FPSLabel.BackgroundTransparency = 1
    self.FPSLabel.Text = 'FPS: 60'
    self.FPSLabel.TextColor3 = self.Config.Theme.Text
    self.FPSLabel.TextSize = 13
    self.FPSLabel.Font = Enum.Font.Gotham
    self.FPSLabel.TextXAlignment = Enum.TextXAlignment.Right
    self.FPSLabel.Parent = self.WatermarkFrame
    
    self.PingLabel = Instance.new('TextLabel')
    self.PingLabel.Size = UDim2.new(0, 120, 0, 18)
    self.PingLabel.Position = UDim2.new(1, -125, 0, 28)
    self.PingLabel.BackgroundTransparency = 1
    self.PingLabel.Text = 'Ping: 50ms'
    self.PingLabel.TextColor3 = self.Config.Theme.Text
    self.PingLabel.TextSize = 13
    self.PingLabel.Font = Enum.Font.Gotham
    self.PingLabel.TextXAlignment = Enum.TextXAlignment.Right
    self.PingLabel.Parent = self.WatermarkFrame
    
    self.PlayerLabel = Instance.new('TextLabel')
    self.PlayerLabel.Size = UDim2.new(0, 120, 0, 18)
    self.PlayerLabel.Position = UDim2.new(1, -125, 0, 48)
    self.PlayerLabel.BackgroundTransparency = 1
    self.PlayerLabel.Text = 'Players: ' .. #Players:GetPlayers()
    self.PlayerLabel.TextColor3 = self.Config.Theme.TextSecondary
    self.PlayerLabel.TextSize = 12
    self.PlayerLabel.Font = Enum.Font.Gotham
    self.PlayerLabel.TextXAlignment = Enum.TextXAlignment.Right
    self.PlayerLabel.Parent = self.WatermarkFrame
    
    self:StartWatermarkUpdates()
end

function RadiantUI:StartWatermarkUpdates()
    if not self.Config.ShowWatermark then return end
    
    local fpsCounter = 0
    local lastUpdate = tick()
    
    local connection = RunService.Heartbeat:Connect(function()
        fpsCounter = fpsCounter + 1
        
        if tick() - lastUpdate >= 1 then
            if self.FPSLabel then
                self.FPSLabel.Text = 'FPS: ' .. fpsCounter
                local color = Color3.fromRGB(255, 255, 255)
                if fpsCounter >= 50 then
                    color = Color3.fromRGB(0, 255, 0)
                elseif fpsCounter >= 30 then
                    color = Color3.fromRGB(255, 255, 0)
                else
                    color = Color3.fromRGB(255, 0, 0)
                end
                self.FPSLabel.TextColor3 = color
            end
            
            if self.PingLabel then
                local stats = game:GetService("Stats")
                local ping = math.floor(stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                self.PingLabel.Text = 'Ping: ' .. ping .. 'ms'
            end
            
            if self.PlayerLabel then
                self.PlayerLabel.Text = 'Players: ' .. #Players:GetPlayers()
            end
            
            fpsCounter = 0
            lastUpdate = tick()
        end
    end)
    
    table.insert(self.Connections, connection)
end

function RadiantUI:MakeWatermarkDraggable()
    if not self.WatermarkFrame then return end
    
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    self.WatermarkFrame.InputBegan:Connect(function(input)
        -- Nur verschiebbar wenn Menu offen ist
        if input.UserInputType == Enum.UserInputType.MouseButton1 and self.GuiVisible then
            dragging = true
            dragStart = input.Position
            startPos = self.WatermarkFrame.Position
        end
    end)
    
    local connection1 = UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement and self.GuiVisible then
            local delta = input.Position - dragStart
            self.WatermarkFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    local connection2 = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    table.insert(self.Connections, connection1)
    table.insert(self.Connections, connection2)
end

function RadiantUI:AddTab(config)
    if #self.Tabs >= MAX_USER_TABS then
        warn("RadiantUI: Maximum number of tabs (" .. MAX_USER_TABS .. ") reached")
        return nil
    end
    
    local tabIndex = #self.Tabs + 1
    local tab = {
        Name = config.Name or "Tab " .. tabIndex,
        Icon = config.Icon or "rbxassetid://4483345998",
        IconActive = config.IconActive or config.Icon,
        Sections = {},
        Content = nil,
        Button = nil
    }
    
    self.Tabs[tabIndex] = tab
    self:CreateTabButton(tab, tabIndex)
    
    -- Automatisch den ersten Tab aktivieren
    if tabIndex == 1 then
        spawn(function()
            wait(0.1) -- Kurze Verzögerung für GUI-Initialisierung
            self:SwitchTab(1)
        end)
    end
    
    -- Erstelle Settings Tab wenn dies der letzte User-Tab ist
    if #self.Tabs == MAX_USER_TABS then
        self:CreateSettingsTab()
    end
    
    return {
        AddSection = function(sectionConfig)
            return self:AddSection(tabIndex, sectionConfig)
        end,
        SetVisible = function(visible)
            self:SetTabVisible(tabIndex, visible)
        end,
        Remove = function()
            self:RemoveTab(tabIndex)
        end
    }
end

function RadiantUI:CreateTabButton(tab, tabIndex)
    local button = Instance.new('TextButton')
    button.Size = UDim2.new(1, 0, 0, 50)
    button.Position = UDim2.new(0, 0, 0, (tabIndex - 1) * 50 + 20)
    button.BackgroundTransparency = 1
    button.Text = ''
    button.Parent = self.SidebarFrame
    
    local indicator = Instance.new('Frame')
    indicator.Size = UDim2.new(0, 4, 0, 0)
    indicator.Position = UDim2.new(0, 0, 0.5, 0)
    indicator.AnchorPoint = Vector2.new(0, 0.5)
    indicator.BackgroundColor3 = self.Config.Theme.Primary
    indicator.BorderSizePixel = 0
    indicator.Parent = button
    
    local indicatorCorner = Instance.new('UICorner')
    indicatorCorner.CornerRadius = UDim.new(0, 2)
    indicatorCorner.Parent = indicator
    
    local icon = Instance.new('ImageLabel')
    icon.Size = UDim2.new(0, 24, 0, 24)
    icon.Position = UDim2.new(0, 12, 0.5, -12)
    icon.BackgroundTransparency = 1
    icon.Image = tab.Icon
    icon.Parent = button
    
    local text = Instance.new('TextLabel')
    text.Size = UDim2.new(1, -44, 1, 0)
    text.Position = UDim2.new(0, 42, 0, 0)
    text.BackgroundTransparency = 1
    text.Text = tab.Name
    text.TextColor3 = self.Config.Theme.TextSecondary
    text.TextSize = 16
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Font = Enum.Font.SourceSansBold
    text.Parent = button
    
    tab.Button = {
        Frame = button,
        Indicator = indicator,
        Icon = icon,
        Text = text
    }
    
    -- Setze ersten Tab als aktiv
    if tabIndex == 1 then
        button.BackgroundTransparency = 0.85
        text.TextColor3 = self.Config.Theme.Primary
        indicator.Size = UDim2.new(0, 4, 0, 30)
        icon.Image = tab.IconActive or tab.Icon
    end
    
    button.MouseButton1Click:Connect(function()
        self:SwitchTab(tabIndex)
    end)
    
    button.MouseEnter:Connect(function()
        if self.CurrentTab ~= tabIndex then
            TweenService:Create(button, TweenInfo.new(0.3), {BackgroundTransparency = 0.9}):Play()
            TweenService:Create(text, TweenInfo.new(0.3), {TextColor3 = self.Config.Theme.Text}):Play()
        end
    end)
    
    button.MouseLeave:Connect(function()
        if self.CurrentTab ~= tabIndex then
            TweenService:Create(button, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            TweenService:Create(text, TweenInfo.new(0.3), {TextColor3 = self.Config.Theme.TextSecondary}):Play()
        end
    end)
end

function RadiantUI:SwitchTab(tabIndex)
    if self.CurrentTab == tabIndex then return end
    
    local currentTab = self.Tabs[self.CurrentTab] or self.SettingsTab
    if currentTab and currentTab.Button then
        TweenService:Create(currentTab.Button.Frame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(currentTab.Button.Text, TweenInfo.new(0.3), {TextColor3 = self.Config.Theme.TextSecondary}):Play()
        TweenService:Create(currentTab.Button.Indicator, TweenInfo.new(0.3), {Size = UDim2.new(0, 4, 0, 0)}):Play()
        -- Inaktiver Tab bekommt normales Icon (grau)
        currentTab.Button.Icon.Image = currentTab.Icon
        
        if currentTab.Content then
            currentTab.Content.Visible = false
        end
    end
    
    local newTab = self.Tabs[tabIndex] or (tabIndex == SETTINGS_TAB_INDEX and self.SettingsTab)
    if newTab and newTab.Button then
        TweenService:Create(newTab.Button.Frame, TweenInfo.new(0.3), {BackgroundTransparency = 0.85}):Play()
        TweenService:Create(newTab.Button.Text, TweenInfo.new(0.3), {TextColor3 = self.Config.Theme.Primary}):Play()
        TweenService:Create(newTab.Button.Indicator, TweenInfo.new(0.3), {Size = UDim2.new(0, 4, 0, 30)}):Play()
        -- Aktiver Tab bekommt IconActive (rot) oder fallback auf normales Icon
        newTab.Button.Icon.Image = newTab.IconActive or newTab.Icon
        
        if not newTab.Content then
            self:CreateTabContent(tabIndex)
        end
        
        if newTab.Content then
            newTab.Content.Visible = true
        end
    end
    
    self.CurrentTab = tabIndex
end

function RadiantUI:CreateTabContent(tabIndex)
    local tab = self.Tabs[tabIndex] or (tabIndex == SETTINGS_TAB_INDEX and self.SettingsTab)
    if not tab then return end
    
    local contentFrame = Instance.new('Frame')
    contentFrame.Name = 'TabContent' .. (tab.Name or 'Unknown')
    contentFrame.Size = UDim2.new(1, -60, 1, -30)
    contentFrame.Position = UDim2.new(0, 30, 0, 15)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = self.ContentFrame
    contentFrame.Visible = tabIndex == self.CurrentTab
    
    local leftColumn = Instance.new('ScrollingFrame')
    leftColumn.Name = 'LeftColumn'
    leftColumn.Size = UDim2.new(0.48, -5, 1, 0)
    leftColumn.Position = UDim2.new(0, 0, 0, 0)
    leftColumn.BackgroundTransparency = 1
    leftColumn.BorderSizePixel = 0
    leftColumn.ScrollBarThickness = 2
    leftColumn.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    leftColumn.ScrollBarImageTransparency = 0.4
    leftColumn.CanvasSize = UDim2.new(0, 0, 3, 0)  -- Größere Canvas
    leftColumn.Parent = contentFrame
    
    local rightColumn = Instance.new('ScrollingFrame')
    rightColumn.Name = 'RightColumn'
    rightColumn.Size = UDim2.new(0.48, -5, 1, 0)
    rightColumn.Position = UDim2.new(0.52, 5, 0, 0)
    rightColumn.BackgroundTransparency = 1
    rightColumn.BorderSizePixel = 0
    rightColumn.ScrollBarThickness = 2
    rightColumn.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    rightColumn.ScrollBarImageTransparency = 0.4
    rightColumn.CanvasSize = UDim2.new(0, 0, 3, 0)  -- Größere Canvas
    rightColumn.Parent = contentFrame
    
    local leftLayout = Instance.new('UIListLayout')
    leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    leftLayout.Padding = UDim.new(0, 15)
    leftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    leftLayout.Parent = leftColumn
    
    local rightLayout = Instance.new('UIListLayout')
    rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rightLayout.Padding = UDim.new(0, 15)
    rightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    rightLayout.Parent = rightColumn
    
    local leftPadding = Instance.new('UIPadding')
    leftPadding.PaddingTop = UDim.new(0, 15)
    leftPadding.PaddingBottom = UDim.new(0, 15)
    leftPadding.PaddingLeft = UDim.new(0, 5)
    leftPadding.PaddingRight = UDim.new(0, 5)
    leftPadding.Parent = leftColumn
    
    local rightPadding = Instance.new('UIPadding')
    rightPadding.PaddingTop = UDim.new(0, 15)
    rightPadding.PaddingBottom = UDim.new(0, 15)
    rightPadding.PaddingLeft = UDim.new(0, 5)
    rightPadding.PaddingRight = UDim.new(0, 5)
    rightPadding.Parent = rightColumn
    
    -- Store references for sections
    tab.Content = contentFrame
    tab.LeftColumn = leftColumn
    tab.RightColumn = rightColumn
    
    -- Create existing sections (only once!)
    for i, section in ipairs(tab.Sections) do
        if not section.Frame then  -- Only create if not already created
            local parentColumn = (i % 2 == 1) and leftColumn or rightColumn
            self:CreateSection(section, parentColumn, math.ceil(i / 2))
        end
    end
end

function RadiantUI:AddSection(tabIndex, config)
    local tab = self.Tabs[tabIndex]
    if not tab then
        warn("RadiantUI: Tab " .. tabIndex .. " does not exist")
        return nil
    end
    
    local section = {
        Title = config.Title or "Section",
        Elements = {},
        Frame = nil
    }
    
    table.insert(tab.Sections, section)
    
    if tab.Content then
        local parentColumn = (#tab.Sections % 2 == 1) and tab.LeftColumn or tab.RightColumn
        self:CreateSection(section, parentColumn, math.ceil(#tab.Sections / 2))
    end
    
    return {
        AddToggle = function(elementConfig)
            return self:AddElement(section, 'Toggle', elementConfig)
        end,
        AddSlider = function(elementConfig)
            return self:AddElement(section, 'Slider', elementConfig)
        end,
        AddButton = function(elementConfig)
            return self:AddElement(section, 'Button', elementConfig)
        end,
        AddDropdown = function(elementConfig)
            print("🔍 DEBUG Section:AddDropdown called with:")
            print("  elementConfig.Name:", elementConfig and elementConfig.Name)
            print("  elementConfig.Options:", elementConfig and elementConfig.Options and #elementConfig.Options or "NIL")
            return self:AddElement(section, 'Dropdown', elementConfig)
        end,
        AddMultiDropdown = function(elementConfig)
            print("🔍 DEBUG Section:AddMultiDropdown called with:")
            print("  elementConfig.Name:", elementConfig and elementConfig.Name)
            print("  elementConfig.Options:", elementConfig and elementConfig.Options and #elementConfig.Options or "NIL")
            return self:AddElement(section, 'MultiDropdown', elementConfig)
        end,
        AddInput = function(elementConfig)
            return self:AddElement(section, 'Input', elementConfig)
        end,
        AddColorPicker = function(elementConfig)
            return self:AddElement(section, 'ColorPicker', elementConfig)
        end,
        AddKeybind = function(elementConfig)
            return self:AddElement(section, 'Keybind', elementConfig)
        end,
        AddLabel = function(elementConfig)
            return self:AddElement(section, 'Label', elementConfig)
        end,
        AddElement = function(elementConfig)
            -- Ensure elementConfig has a Type field
            if not elementConfig or not elementConfig.Type then
                warn("RadiantUI: AddElement called without Type in elementConfig")
                return
            end
            return self:AddElement(section, elementConfig.Type, elementConfig)
        end
    }
end

function RadiantUI:CreateSection(section, parentColumn, layoutOrder)
    -- Prevent double creation
    if section.Frame then
        warn("RadiantUI: Section '" .. section.Title .. "' already exists, skipping creation")
        return
    end
    
    local headerHeight = 55
    local itemHeight = 35
    local itemSpacing = 15
    local bottomPadding = 20
    local totalItems = #section.Elements
    local calculatedHeight = headerHeight + (totalItems * itemHeight) + ((totalItems - 1) * itemSpacing) + bottomPadding
    
    local sectionFrame = Instance.new('Frame')
    sectionFrame.Size = UDim2.new(1, -10, 0, calculatedHeight)
    sectionFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)  -- Dunklerer Hintergrund
    sectionFrame.BorderSizePixel = 0
    sectionFrame.LayoutOrder = layoutOrder
    sectionFrame.Parent = parentColumn
    
    local sectionCorner = Instance.new('UICorner')
    sectionCorner.CornerRadius = UDim.new(0, 12)
    sectionCorner.Parent = sectionFrame
    
    local sectionStroke = Instance.new('UIStroke')
    sectionStroke.Thickness = 1
    sectionStroke.Color = Color3.fromRGB(55, 55, 55)
    sectionStroke.Transparency = 0.4
    sectionStroke.Parent = sectionFrame
    
    local sectionTitle = Instance.new('TextLabel')
    sectionTitle.Size = UDim2.new(1, -45, 0, 25)
    sectionTitle.Position = UDim2.new(0, 20, 0, 15)
    sectionTitle.BackgroundTransparency = 1
    sectionTitle.Text = section.Title
    sectionTitle.TextColor3 = self.Config.Theme.Primary
    sectionTitle.TextSize = 15
    sectionTitle.Font = Enum.Font.GothamBold
    sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    sectionTitle.Parent = sectionFrame
    
    local titleAccent = Instance.new('Frame')
    titleAccent.Size = UDim2.new(0, 3, 0, 15)
    titleAccent.Position = UDim2.new(0, 12, 0, 20)
    titleAccent.BackgroundColor3 = self.Config.Theme.Primary
    titleAccent.BorderSizePixel = 0
    titleAccent.Parent = sectionFrame
    
    local accentCorner = Instance.new('UICorner')
    accentCorner.CornerRadius = UDim.new(0, 2)
    accentCorner.Parent = titleAccent
    
    local itemsFrame = Instance.new('Frame')
    itemsFrame.Name = 'ItemsFrame'
    itemsFrame.Size = UDim2.new(1, -40, 0, (totalItems * itemHeight) + ((totalItems - 1) * itemSpacing))
    itemsFrame.Position = UDim2.new(0, 20, 0, 45)
    itemsFrame.BackgroundTransparency = 1
    itemsFrame.Parent = sectionFrame
    
    section.ItemsFrame = itemsFrame  -- Store reference
    section.Frame = sectionFrame     -- Store section frame reference
    
    local itemLayout = Instance.new('UIListLayout')
    itemLayout.SortOrder = Enum.SortOrder.LayoutOrder
    itemLayout.Padding = UDim.new(0, itemSpacing)
    itemLayout.Parent = itemsFrame
    
    -- Create elements if they exist (only once!)
    for i, element in ipairs(section.Elements) do
        self:CreateElement(element, itemsFrame, i)
    end
    
    sectionFrame.MouseEnter:Connect(function()
        TweenService:Create(sectionStroke, TweenInfo.new(0.3), {
            Color = self.Config.Theme.Primary,
            Transparency = 0.1
        }):Play()
    end)
    
    sectionFrame.MouseLeave:Connect(function()
        TweenService:Create(sectionStroke, TweenInfo.new(0.3), {
            Color = Color3.fromRGB(55, 55, 55),
            Transparency = 0.4
        }):Play()
    end)
end

function RadiantUI:AddElement(section, elementType, config)
    -- STEP 1: Parameter-Validierung und Normalisierung
    local actualElementType, actualConfig
    
    if type(elementType) == "table" and elementType.Type then
        -- Direkter Aufruf: section:AddElement({Type = 'MultiDropdown', Options = {...}})
        actualElementType = elementType.Type
        actualConfig = elementType -- Komplette Struktur beibehalten
    else
        -- Normaler Aufruf: section:AddMultiDropdown({Options = {...}})
        actualElementType = elementType
        actualConfig = config or {}
    end
    
    -- 🔍 DEBUG: AddElement Input
    print("═══════════════════════════════════════")
    print("🔍 DEBUG AddElement INPUT:")
    print("  elementType:", elementType)
    print("  actualElementType:", actualElementType)
    if actualConfig then
        print("  actualConfig.Name:", actualConfig.Name)
        print("  actualConfig.Options type:", type(actualConfig.Options))
        if actualConfig.Options then
            print("  actualConfig.Options count:", #actualConfig.Options)
            if #actualConfig.Options > 0 then
                print("  actualConfig.Options[1]:", actualConfig.Options[1])
                print("  actualConfig.Options[2]:", actualConfig.Options[2])
                print("  actualConfig.Options[3]:", actualConfig.Options[3])
            end
        end
        print("  actualConfig.Placeholder:", actualConfig.Placeholder)
        print("  actualConfig.Default:", actualConfig.Default)
    else
        print("  actualConfig: NIL!")
    end
    print("═══════════════════════════════════════")
    
    -- STEP 2: Validierung der Parameter
    if not actualElementType then
        warn("RadiantUI: elementType is nil in AddElement call")
        return nil
    end
    
    if not actualConfig then
        warn("RadiantUI: config is nil in AddElement call")
        return nil
    end
    
    -- STEP 3: Element-Name bestimmen
    local elementName = actualConfig.Name or actualConfig.Title or ("Element_" .. actualElementType)
    
    -- STEP 4: KRITISCHER FIX - Element-Objekt mit DIREKTER Options-Zuweisung
    local element = {
        Type = actualElementType,
        Name = elementName,
        Config = actualConfig, -- Original Config für Rückwärtskompatibilität
        Frame = nil,
        
        -- KRITISCH: Alle wichtigen Properties DIREKT im element-Objekt
        Options = actualConfig.Options, -- DIREKT zuweisen
        Placeholder = actualConfig.Placeholder,
        Default = actualConfig.Default,
        
        -- Wert-Initialisierung basierend auf Element-Typ
        Value = (function()
            if actualElementType == 'MultiDropdown' then
                return actualConfig.Default or {}
            else
                return actualConfig.Default or false
            end
        end)(),
        
        Callback = actualConfig.Callback or function() end
    }
    
    -- 🔍 DEBUG: Element Object Created
    print("🔍 DEBUG ELEMENT OBJECT CREATED:")
    print("  element.Name:", element.Name)
    print("  element.Type:", element.Type)
    print("  element.Options type:", type(element.Options))
    if element.Options then
        print("  element.Options count:", #element.Options)
        if #element.Options > 0 then
            print("  element.Options[1]:", element.Options[1])
            print("  element.Options[2]:", element.Options[2])
            print("  element.Options[3]:", element.Options[3])
        end
    else
        print("  element.Options: NIL!")
    end
    print("  element.Placeholder:", element.Placeholder)
    print("  element.Default:", element.Default)
    
    -- STEP 5: Options successfully transferred to element object
    
    -- STEP 6: Element zur Section hinzufügen
    table.insert(section.Elements, element)
    
    -- STEP 7: Sofortige Erstellung falls ItemsFrame existiert
    if section.ItemsFrame then
        self:CreateElement(element, section.ItemsFrame, #section.Elements)
        self:UpdateSectionHeight(section)
    end
    
    -- STEP 8: Return-Objekt mit Utility-Funktionen
    return {
        SetValue = function(value)
            element.Value = value
            if element.UpdateFunction then
                element.UpdateFunction(value)
            end
        end,
        GetValue = function()
            return element.Value
        end,
        SetOptions = function(newOptions) -- NEUE FUNKTION!
            element.Options = newOptions
            if element.Config then
                element.Config.Options = newOptions
            end
            -- Refresh dropdown falls geöffnet
            if element.UpdateFunction then
                element.UpdateFunction(element.Value)
            end
        end,
        SetVisible = function(visible)
            if element.Frame then
                element.Frame.Visible = visible
            end
        end,
        Remove = function()
            self:RemoveElement(section, element)
        end
    }
end

function RadiantUI:CreateElement(element, parent, layoutOrder)
    local itemFrame = Instance.new('Frame')
    itemFrame.Size = UDim2.new(1, 0, 0, 30)
    itemFrame.BackgroundTransparency = 1
    itemFrame.LayoutOrder = layoutOrder
    itemFrame.Parent = parent
    
    -- Proper label creation with element name
    local label = Instance.new('TextLabel')
    label.Size = UDim2.new(0.55, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = element.Name or element.Config.Name or element.Config.Title or "Element" -- Use the actual element name
    label.TextColor3 = self.Config.Theme.TextSecondary
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = itemFrame
    
    element.Frame = itemFrame
    
    if element.Type == 'Toggle' then
        self:CreateToggle(element, itemFrame)
    elseif element.Type == 'Slider' then
        self:CreateSlider(element, itemFrame)
    elseif element.Type == 'Button' then
        self:CreateButton(element, itemFrame)
        -- For buttons, hide the label since button shows its own text
        label.Text = ""
    elseif element.Type == 'Dropdown' then
        print("🔍 DEBUG CreateElement: Creating Dropdown for element:", element.Name)
        -- Use new dropdown system - CORRECT parameter order: gui, element, parent, isMulti
        local dropdown = self.DropdownComponent.new(self, element, itemFrame, false) -- false = not multi
        print("🔍 DEBUG CreateElement: Dropdown created successfully")
    elseif element.Type == 'MultiDropdown' then
        print("🔍 DEBUG CreateElement: Creating MultiDropdown for element:", element.Name)
        -- Use new multi-dropdown system - CORRECT parameter order: gui, element, parent, isMulti  
        local multiDropdown = self.DropdownComponent.new(self, element, itemFrame, true) -- true = multi
        print("🔍 DEBUG CreateElement: MultiDropdown created successfully")
    elseif element.Type == 'Input' then
        self:CreateInput(element, itemFrame)
    elseif element.Type == 'ColorPicker' then
        self:CreateColorPicker(element, itemFrame)
    elseif element.Type == 'Keybind' then
        self:CreateKeybind(element, itemFrame)
    elseif element.Type == 'Label' then
        label.Size = UDim2.new(1, 0, 1, 0)
        label.TextXAlignment = Enum.TextXAlignment.Center
    end
    
    if layoutOrder < #parent:GetChildren() then
        local separator = Instance.new('Frame')
        separator.Size = UDim2.new(1, 0, 0, 1)
        separator.Position = UDim2.new(0, 0, 1, 7)
        separator.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        separator.BackgroundTransparency = 0.6
        separator.BorderSizePixel = 0
        separator.Parent = itemFrame
    end
end

function RadiantUI:CreateToggle(element, parent)
    local toggleFrame = Instance.new('Frame')
    toggleFrame.Size = UDim2.new(0, 50, 0, 24)
    toggleFrame.Position = UDim2.new(1, -50, 0.5, -12)
    toggleFrame.BackgroundColor3 = element.Value and self.Config.Theme.Primary or Color3.fromRGB(51, 51, 51)
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = parent
    
    local toggleCorner = Instance.new('UICorner')
    toggleCorner.CornerRadius = UDim.new(0, 12)
    toggleCorner.Parent = toggleFrame
    
    local toggleButton = Instance.new('Frame')
    toggleButton.Size = UDim2.new(0, 18, 0, 18)
    toggleButton.Position = UDim2.new(0, element.Value and 29 or 3, 0.5, -9)
    toggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.BorderSizePixel = 0
    toggleButton.Parent = toggleFrame
    
    local buttonCorner = Instance.new('UICorner')
    buttonCorner.CornerRadius = UDim.new(0.5, 0)
    buttonCorner.Parent = toggleButton
    
    local clickDetector = Instance.new('TextButton')
    clickDetector.Size = UDim2.new(1, 0, 1, 0)
    clickDetector.BackgroundTransparency = 1
    clickDetector.Text = ''
    clickDetector.Parent = toggleFrame
    
    element.UpdateFunction = function(value)
        element.Value = value
        TweenService:Create(toggleFrame, TweenInfo.new(0.3), {
            BackgroundColor3 = value and self.Config.Theme.Primary or Color3.fromRGB(51, 51, 51)
        }):Play()
        TweenService:Create(toggleButton, TweenInfo.new(0.3), {
            Position = UDim2.new(0, value and 29 or 3, 0.5, -9)
        }):Play()
    end
    
    clickDetector.MouseButton1Click:Connect(function()
        element.Value = not element.Value
        element.UpdateFunction(element.Value)
        element.Callback(element.Value)
    end)
end

function RadiantUI:CreateSlider(element, parent)
    local sliderFrame = Instance.new('Frame')
    sliderFrame.Size = UDim2.new(0, 160, 0, 24)
    sliderFrame.Position = UDim2.new(1, -160, 0.5, -12)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = parent
    
    local sliderTrack = Instance.new('Frame')
    sliderTrack.Size = UDim2.new(0, 120, 0, 8)
    sliderTrack.Position = UDim2.new(0, 0, 0.5, -4)
    sliderTrack.BackgroundColor3 = Color3.fromRGB(51, 51, 51)
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Parent = sliderFrame
    
    local trackCorner = Instance.new('UICorner')
    trackCorner.CornerRadius = UDim.new(0, 4)
    trackCorner.Parent = sliderTrack
    
    local min = element.Config.Min or 0
    local max = element.Config.Max or 100
    local value = element.Config.Default or min
    element.Value = value
    
    local valueBar = Instance.new('Frame')
    valueBar.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    valueBar.Position = UDim2.new(0, 0, 0, 0)
    valueBar.BackgroundColor3 = self.Config.Theme.Primary
    valueBar.BorderSizePixel = 0
    valueBar.Parent = sliderTrack
    
    local barCorner = Instance.new('UICorner')
    barCorner.CornerRadius = UDim.new(0, 4)
    barCorner.Parent = valueBar
    
    local valueLabel = Instance.new('TextLabel')
    valueLabel.Size = UDim2.new(0, 35, 1, 0)
    valueLabel.Position = UDim2.new(1, -35, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(value)
    valueLabel.TextColor3 = self.Config.Theme.Primary
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = sliderFrame
    
    local dragging = false
    
    local function updateSlider(input)
        local relativeX = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
        local newValue = math.floor(min + (max - min) * relativeX)
        element.Value = newValue
        
        TweenService:Create(valueBar, TweenInfo.new(0.1), {
            Size = UDim2.new(relativeX, 0, 1, 0)
        }):Play()
        
        valueLabel.Text = tostring(newValue)
        element.Callback(newValue)
    end
    
    element.UpdateFunction = function(value)
        element.Value = value
        local relativeX = (value - min) / (max - min)
        valueBar.Size = UDim2.new(relativeX, 0, 1, 0)
        valueLabel.Text = tostring(value)
    end
    
    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)
    
    local connection1 = UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    local connection2 = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    table.insert(self.Connections, connection1)
    table.insert(self.Connections, connection2)
end

function RadiantUI:CreateButton(element, parent)
    local button = Instance.new('TextButton')
    button.Size = UDim2.new(0, 80, 0, 32)
    button.Position = UDim2.new(1, -80, 0.5, -16)
    button.BackgroundColor3 = Color3.fromRGB(180, 15, 15)
    button.BorderSizePixel = 0
    button.Text = element.Config and element.Config.ButtonText or "Execute"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 13
    button.Font = Enum.Font.GothamBold
    button.Parent = parent
    
    local buttonCorner = Instance.new('UICorner')
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(200, 10, 10)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(180, 15, 15)
        }):Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(0, 76, 0, 30)}):Play()
        spawn(function()
            wait(0.1)
            TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(0, 80, 0, 32)}):Play()
        end)
        element.Callback()
    end)
end

-- ===== NEUES DROPDOWN MANAGEMENT SYSTEM =====
-- Globale Dropdown-Verwaltung
if not RadiantUI.DropdownManager then
    RadiantUI.DropdownManager = {
        activeDropdowns = {},
        zIndexCounter = 10000,  -- Viel höhere Basis für bessere Layering
        globalConnections = {}
    }
end

-- Globale Z-Index Verwaltung
function RadiantUI:GetNextDropdownZIndex()
    self.DropdownManager.zIndexCounter = self.DropdownManager.zIndexCounter + 50
    return self.DropdownManager.zIndexCounter
end

-- Alle aktiven Dropdowns schließen
function RadiantUI:CloseAllDropdowns(except)
    for id, dropdown in pairs(self.DropdownManager.activeDropdowns) do
        if dropdown ~= except and dropdown.isOpen then
            dropdown:Close()
        end
    end
end

-- Dropdown-Komponenten-Klasse (Teil von RadiantUI)
RadiantUI.DropdownComponent = {}
RadiantUI.DropdownComponent.__index = RadiantUI.DropdownComponent

function RadiantUI.DropdownComponent.new(gui, element, parent, isMulti)
    local self = setmetatable({}, RadiantUI.DropdownComponent)
    
    -- 🔍 DEBUG: DropdownComponent.new INPUT
    print("═══════════════════════════════════════")
    print("🔍 DEBUG DropdownComponent.new INPUT:")
    print("  gui:", gui and "EXISTS" or "NIL")
    print("  element:", element and "EXISTS" or "NIL")
    if element then
        print("  element.Name:", element.Name)
        print("  element.Type:", element.Type)
        print("  element.Options type:", type(element.Options))
        if element.Options then
            print("  element.Options count:", #element.Options)
            if #element.Options > 0 then
                print("  element.Options[1]:", element.Options[1])
                print("  element.Options[2]:", element.Options[2])
                print("  element.Options[3]:", element.Options[3])
            end
        else
            print("  element.Options: NIL!")
        end
        print("  element.Placeholder:", element.Placeholder)
        print("  element.Default:", element.Default)
        
        -- Also check Config fallback
        if element.Config then
            print("  element.Config.Options type:", type(element.Config.Options))
            if element.Config.Options then
                print("  element.Config.Options count:", #element.Config.Options)
                if #element.Config.Options > 0 then
                    print("  element.Config.Options[1]:", element.Config.Options[1])
                end
            else
                print("  element.Config.Options: NIL!")
            end
        end
    end
    print("  parent:", parent and "EXISTS" or "NIL")
    print("  isMulti:", isMulti)
    print("═══════════════════════════════════════")
    
    -- Core Properties
    self.gui = gui
    self.element = element
    self.parent = parent
    self.isMulti = isMulti or false
    self.isOpen = false
    self.id = "dropdown_" .. tostring(math.random(100000, 999999))
    
    -- Configuration
    self.options = self:ExtractOptions()
    self.placeholder = element.Placeholder or "Select..."
    self.defaultValue = element.Default
    self.callback = element.Callback or function() end
    
    -- 🔍 DEBUG: Configuration Set
    print("🔍 DEBUG Configuration Set:")
    print("  self.options count:", self.options and #self.options or "NIL")
    print("  self.placeholder:", self.placeholder)
    print("  self.defaultValue:", self.defaultValue)
    
    -- State Management
    self.filteredOptions = {}
    self.selectedValue = self.isMulti and {} or nil
    self.selectedValues = self.isMulti and {} or nil
    self.connections = {}
    self.baseZIndex = 0
    
    -- UI Elements
    self.container = nil
    self.menuContainer = nil
    self.searchInput = nil
    self.optionsList = nil
    self.mainButton = nil
    self.arrow = nil
    
    -- Initialize
    self:Initialize()
    self:BuildUI()
    self:SetupEvents()
    
    -- Register in manager
    gui.DropdownManager.activeDropdowns[self.id] = self
    
    -- 🔍 DEBUG: DropdownComponent.new COMPLETE
    print("🔍 DEBUG DropdownComponent.new COMPLETE:")
    print("  ID:", self.id)
    print("  Final options count:", self.options and #self.options or "NIL")
    print("  Final placeholder:", self.placeholder)
    print("═══════════════════════════════════════")
    
    return self
end

function RadiantUI.DropdownComponent:ExtractOptions()
    -- 🔍 DEBUG: ExtractOptions START
    print("🔍 DEBUG ExtractOptions START:")
    print("  self.element.Options type:", type(self.element.Options))
    print("  self.element.Options:", self.element.Options)
    if self.element.Options then
        print("  self.element.Options count:", #self.element.Options)
        for i, opt in ipairs(self.element.Options) do
            print("    Option " .. i .. ":", opt)
            if i > 5 then 
                print("    ... and more")
                break 
            end
        end
    end
    
    local options = self.element.Options or {}
    
    -- Validate and sanitize options
    local validOptions = {}
    for i, opt in ipairs(options) do
        local sanitized = tostring(opt or ""):gsub("^%s*(.-)%s*$", "%1")
        if sanitized ~= "" then
            table.insert(validOptions, sanitized)
        end
    end
    
    print("  validOptions count after sanitizing:", #validOptions)
    
    -- Fallback wenn keine gültigen Optionen
    if #validOptions == 0 then
        print("  ⚠️ NO VALID OPTIONS FOUND - Using fallback!")
        validOptions = self.isMulti and {"Option 1", "Option 2", "Option 3"} or {"Option 1", "Option 2", "Option 3"}
    else
        print("  ✅ Using real options!")
        for i, opt in ipairs(validOptions) do
            print("    Final Option " .. i .. ":", opt)
            if i > 5 then 
                print("    ... and more")
                break 
            end
        end
    end
    
    print("🔍 DEBUG ExtractOptions END")
    return validOptions
end

function RadiantUI.DropdownComponent:Initialize()
    -- Copy options to filtered list
    self.filteredOptions = {}
    for _, option in ipairs(self.options) do
        table.insert(self.filteredOptions, option)
    end
    
    -- Initialize selection
    if self.isMulti then
        self.selectedValues = {}
        if self.defaultValue then
            for _, value in ipairs(self.defaultValue) do
                self.selectedValues[value] = true
            end
        end
        self.selectedValue = self.defaultValue or {}
    else
        self.selectedValue = self.defaultValue
    end
    
    -- Set element value
    self.element.Value = self.selectedValue
end

function RadiantUI.DropdownComponent:BuildUI()
    -- Main container
    self.container = Instance.new('Frame')
    self.container.Name = "DropdownContainer_" .. self.id
    self.container.Size = UDim2.new(0, 140, 0, 32)
    self.container.Position = UDim2.new(1, -140, 0.5, -16)
    self.container.BackgroundTransparency = 1
    self.container.Parent = self.parent
    
    -- Dropdown button frame
    local buttonFrame = Instance.new('Frame')
    buttonFrame.Name = "ButtonFrame"
    buttonFrame.Size = UDim2.new(1, 0, 1, 0)
    buttonFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    buttonFrame.BorderSizePixel = 0
    buttonFrame.Parent = self.container
    
    local buttonCorner = Instance.new('UICorner')
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = buttonFrame
    
    local buttonStroke = Instance.new('UIStroke')
    buttonStroke.Name = "ButtonStroke"
    buttonStroke.Thickness = 1
    buttonStroke.Color = Color3.fromRGB(85, 85, 85)
    buttonStroke.Transparency = 0.3
    buttonStroke.Parent = buttonFrame
    
    -- Main button
    self.mainButton = Instance.new('TextButton')
    self.mainButton.Name = "MainButton"
    self.mainButton.Size = UDim2.new(1, -25, 1, 0)
    self.mainButton.Position = UDim2.new(0, 8, 0, 0)
    self.mainButton.BackgroundTransparency = 1
    self.mainButton.Text = self:GetDisplayText()
    self.mainButton.TextColor3 = self:GetTextColor()
    self.mainButton.TextSize = 12
    self.mainButton.Font = Enum.Font.Gotham
    self.mainButton.TextXAlignment = Enum.TextXAlignment.Left
    self.mainButton.Parent = buttonFrame
    
    -- 🔍 DEBUG: BuildUI MainButton
    print("🔍 DEBUG BuildUI MainButton:")
    print("  mainButton.Text:", self.mainButton.Text)
    print("  options available:", self.options and #self.options or "NIL")
    if self.options and #self.options > 0 then
        print("  first option:", self.options[1])
    end
    
    -- Arrow indicator
    self.arrow = Instance.new('TextLabel')
    self.arrow.Name = "Arrow"
    self.arrow.Size = UDim2.new(0, 20, 1, 0)
    self.arrow.Position = UDim2.new(1, -20, 0, 0)
    self.arrow.BackgroundTransparency = 1
    self.arrow.Text = "▼"
    self.arrow.TextColor3 = self.gui.Config.Theme.TextSecondary
    self.arrow.TextSize = 10
    self.arrow.Font = Enum.Font.Gotham
    self.arrow.Parent = buttonFrame
    
    -- Menu container (initially hidden)
    self:BuildMenuContainer()
end

function RadiantUI.DropdownComponent:BuildMenuContainer()
    self.menuContainer = Instance.new('Frame')
    self.menuContainer.Name = "MenuContainer"
    self.menuContainer.Size = UDim2.new(1, 0, 0, 0)
    self.menuContainer.Position = UDim2.new(0, 0, 1, 2)
    self.menuContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    self.menuContainer.BorderSizePixel = 0
    self.menuContainer.Visible = false
    self.menuContainer.ClipsDescendants = true
    self.menuContainer.ZIndex = 10000  -- Will be updated dynamically
    self.menuContainer.Parent = self.container
    
    local menuCorner = Instance.new('UICorner')
    menuCorner.CornerRadius = UDim.new(0, 8)
    menuCorner.Parent = self.menuContainer
    
    local menuStroke = Instance.new('UIStroke')
    menuStroke.Name = "MenuStroke"
    menuStroke.Thickness = 1
    menuStroke.Color = Color3.fromRGB(70, 70, 70)
    menuStroke.Transparency = 0.4
    menuStroke.Parent = self.menuContainer
    
    -- Search input
    self.searchInput = Instance.new('TextBox')
    self.searchInput.Name = "SearchInput"
    self.searchInput.Size = UDim2.new(1, -16, 0, 28)
    self.searchInput.Position = UDim2.new(0, 8, 0, 8)
    self.searchInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    self.searchInput.BorderSizePixel = 0
    self.searchInput.Text = ""
    self.searchInput.PlaceholderText = "Search options..."
    self.searchInput.PlaceholderColor3 = self.gui.Config.Theme.TextSecondary
    self.searchInput.TextColor3 = self.gui.Config.Theme.Text
    self.searchInput.TextSize = 11
    self.searchInput.Font = Enum.Font.Gotham
    self.searchInput.TextXAlignment = Enum.TextXAlignment.Left
    self.searchInput.ZIndex = 10005
    self.searchInput.Parent = self.menuContainer
    
    local searchCorner = Instance.new('UICorner')
    searchCorner.CornerRadius = UDim.new(0, 6)
    searchCorner.Parent = self.searchInput
    
    local searchPadding = Instance.new('UIPadding')
    searchPadding.PaddingLeft = UDim.new(0, 8)
    searchPadding.PaddingRight = UDim.new(0, 8)
    searchPadding.Parent = self.searchInput
    
    -- Options list
    self.optionsList = Instance.new('ScrollingFrame')
    self.optionsList.Name = "OptionsList"
    self.optionsList.Size = UDim2.new(1, 0, 0, 120)
    self.optionsList.Position = UDim2.new(0, 0, 0, 44)
    self.optionsList.BackgroundTransparency = 1
    self.optionsList.BorderSizePixel = 0
    self.optionsList.ScrollBarThickness = 4
    self.optionsList.ScrollBarImageColor3 = self.gui.Config.Theme.Primary
    self.optionsList.ScrollBarImageTransparency = 0.3
    self.optionsList.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.optionsList.ZIndex = 10005
    self.optionsList.Parent = self.menuContainer
    
    local listLayout = Instance.new('UIListLayout')
    listLayout.Name = "ListLayout"
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 2)
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.Parent = self.optionsList
    
    -- Auto-update canvas size
    listLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
        self.optionsList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
    end)
end

-- ===== DROPDOWN COMPONENT METHODS =====

function RadiantUI.DropdownComponent:GetDisplayText()
    local displayText
    if self.isMulti then
        local count = 0
        local selectedList = {}
        for value, isSelected in pairs(self.selectedValues or {}) do
            if isSelected then
                count = count + 1
                table.insert(selectedList, value)
            end
        end
        
        if count == 0 then
            displayText = self.placeholder
        elseif count == 1 then
            displayText = selectedList[1]
        else
            displayText = count .. " selected"
        end
    else
        displayText = self.selectedValue or self.placeholder
    end
    
    -- 🔍 DEBUG: GetDisplayText
    print("🔍 DEBUG GetDisplayText:")
    print("  isMulti:", self.isMulti)
    print("  placeholder:", self.placeholder)
    print("  selectedValue:", self.selectedValue)
    print("  displayText:", displayText)
    
    return displayText
end

function RadiantUI.DropdownComponent:GetTextColor()
    local hasSelection = false
    if self.isMulti then
        for _, isSelected in pairs(self.selectedValues or {}) do
            if isSelected then
                hasSelection = true
                break
            end
        end
    else
        hasSelection = self.selectedValue ~= nil
    end
    
    return hasSelection and self.gui.Config.Theme.Text or self.gui.Config.Theme.TextSecondary
end

function RadiantUI.DropdownComponent:UpdateDisplay()
    if self.mainButton and self.mainButton.Parent then
        self.mainButton.Text = self:GetDisplayText()
        self.mainButton.TextColor3 = self:GetTextColor()
    end
end

function RadiantUI.DropdownComponent:SetupEvents()
    -- Main button click
    local mainButtonConnection = self.mainButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    table.insert(self.connections, mainButtonConnection)
    
    -- Search functionality
    local searchConnection = self.searchInput:GetPropertyChangedSignal('Text'):Connect(function()
        self:FilterOptions()
    end)
    table.insert(self.connections, searchConnection)
    
    -- Outside click detection
    local outsideClickConnection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and self.isOpen then
            if not self:IsMouseOverDropdown() then
                self:Close()
            end
        end
    end)
    table.insert(self.connections, outsideClickConnection)
end

function RadiantUI.DropdownComponent:IsMouseOverDropdown()
    local mouse = UserInputService:GetMouseLocation()
    local guiInset = game:GetService("GuiService"):GetGuiInset()
    
    local correctedMouse = Vector2.new(mouse.X - guiInset.X, mouse.Y - guiInset.Y)
    
    -- Check container
    local containerPos = self.container.AbsolutePosition
    local containerSize = self.container.AbsoluteSize
    local containerBounds = {
        left = containerPos.X,
        right = containerPos.X + containerSize.X,
        top = containerPos.Y,
        bottom = containerPos.Y + containerSize.Y
    }
    
    if self.menuContainer.Visible then
        -- Include menu in bounds
        local menuPos = self.menuContainer.AbsolutePosition
        local menuSize = self.menuContainer.AbsoluteSize
        containerBounds.bottom = math.max(containerBounds.bottom, menuPos.Y + menuSize.Y)
    end
    
    return correctedMouse.X >= containerBounds.left and correctedMouse.X <= containerBounds.right and
           correctedMouse.Y >= containerBounds.top and correctedMouse.Y <= containerBounds.bottom
end

function RadiantUI.DropdownComponent:FilterOptions()
    local searchText = self.searchInput.Text:lower()
    self.filteredOptions = {}
    
    for _, option in ipairs(self.options) do
        if option:lower():find(searchText, 1, true) then
            table.insert(self.filteredOptions, option)
        end
    end
    
    self:RefreshOptionsList()
end

function RadiantUI.DropdownComponent:RefreshOptionsList()
    -- Clear existing options
    for _, child in pairs(self.optionsList:GetChildren()) do
        if child:IsA('GuiObject') and child.Name:find('Option_') then
            child:Destroy()
        end
    end
    
    -- Create new option elements
    for i, option in ipairs(self.filteredOptions) do
        self:CreateOptionElement(option, i)
    end
end

function RadiantUI.DropdownComponent:CreateOptionElement(optionText, index)
    if self.isMulti then
        self:CreateMultiOptionElement(optionText, index)
    else
        self:CreateSingleOptionElement(optionText, index)
    end
end

function RadiantUI.DropdownComponent:CreateSingleOptionElement(optionText, index)
    local optionFrame = Instance.new('TextButton')
    optionFrame.Name = "Option_" .. index
    optionFrame.Size = UDim2.new(1, -8, 0, 28)
    optionFrame.Position = UDim2.new(0, 4, 0, 0)
    optionFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    optionFrame.BackgroundTransparency = 1
    optionFrame.BorderSizePixel = 0
    optionFrame.Text = optionText
    optionFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
    optionFrame.TextSize = 12
    optionFrame.Font = Enum.Font.Gotham
    optionFrame.TextXAlignment = Enum.TextXAlignment.Left
    optionFrame.LayoutOrder = index
    optionFrame.ZIndex = self.baseZIndex + 10
    optionFrame.Parent = self.optionsList
    
    local optionCorner = Instance.new('UICorner')
    optionCorner.CornerRadius = UDim.new(0, 4)
    optionCorner.Parent = optionFrame
    
    local optionPadding = Instance.new('UIPadding')
    optionPadding.PaddingLeft = UDim.new(0, 8)
    optionPadding.Parent = optionFrame
    
    -- Hover effects
    optionFrame.MouseEnter:Connect(function()
        TweenService:Create(optionFrame, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.2
        }):Play()
    end)
    
    optionFrame.MouseLeave:Connect(function()
        TweenService:Create(optionFrame, TweenInfo.new(0.2), {
            BackgroundTransparency = 1
        }):Play()
    end)
    
    -- Click handler
    optionFrame.MouseButton1Click:Connect(function()
        self:SelectOption(optionText)
    end)
end

function RadiantUI.DropdownComponent:CreateMultiOptionElement(optionText, index)
    local optionFrame = Instance.new('Frame')
    optionFrame.Name = "Option_" .. index
    optionFrame.Size = UDim2.new(1, -8, 0, 28)
    optionFrame.Position = UDim2.new(0, 4, 0, 0)
    optionFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    optionFrame.BackgroundTransparency = 1
    optionFrame.BorderSizePixel = 0
    optionFrame.LayoutOrder = index
    optionFrame.ZIndex = self.baseZIndex + 10
    optionFrame.Parent = self.optionsList
    
    local optionCorner = Instance.new('UICorner')
    optionCorner.CornerRadius = UDim.new(0, 4)
    optionCorner.Parent = optionFrame
    
    -- Checkbox
    local checkbox = Instance.new('Frame')
    checkbox.Name = "Checkbox"
    checkbox.Size = UDim2.new(0, 16, 0, 16)
    checkbox.Position = UDim2.new(0, 8, 0.5, -8)
    checkbox.BackgroundColor3 = self.selectedValues[optionText] and self.gui.Config.Theme.Primary or Color3.fromRGB(60, 60, 60)
    checkbox.BorderSizePixel = 0
    checkbox.ZIndex = self.baseZIndex + 11
    checkbox.Parent = optionFrame
    
    local checkboxCorner = Instance.new('UICorner')
    checkboxCorner.CornerRadius = UDim.new(0, 2)
    checkboxCorner.Parent = checkbox
    
    local checkmark = Instance.new('TextLabel')
    checkmark.Name = "Checkmark"
    checkmark.Size = UDim2.new(1, 0, 1, 0)
    checkmark.BackgroundTransparency = 1
    checkmark.Text = self.selectedValues[optionText] and "✓" or ""
    checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
    checkmark.TextSize = 10
    checkmark.Font = Enum.Font.GothamBold
    checkmark.ZIndex = self.baseZIndex + 12
    checkmark.Parent = checkbox
    
    -- Text label
    local textLabel = Instance.new('TextLabel')
    textLabel.Name = "TextLabel"
    textLabel.Size = UDim2.new(1, -32, 1, 0)
    textLabel.Position = UDim2.new(0, 28, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = optionText
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 12
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.ZIndex = self.baseZIndex + 11
    textLabel.Parent = optionFrame
    
    -- Click button
    local clickButton = Instance.new('TextButton')
    clickButton.Name = "ClickButton"
    clickButton.Size = UDim2.new(1, 0, 1, 0)
    clickButton.BackgroundTransparency = 1
    clickButton.Text = ""
    clickButton.ZIndex = self.baseZIndex + 13
    clickButton.Parent = optionFrame
    
    -- Hover effects
    clickButton.MouseEnter:Connect(function()
        TweenService:Create(optionFrame, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.2
        }):Play()
    end)
    
    clickButton.MouseLeave:Connect(function()
        TweenService:Create(optionFrame, TweenInfo.new(0.2), {
            BackgroundTransparency = 1
        }):Play()
    end)
    
    -- Click handler
    clickButton.MouseButton1Click:Connect(function()
        self:ToggleMultiOption(optionText, checkbox, checkmark)
    end)
end

function RadiantUI.DropdownComponent:SelectOption(optionText)
    self.selectedValue = optionText
    self.element.Value = optionText
    self:UpdateDisplay()
    
    -- Execute callback
    spawn(function()
        local success, err = pcall(self.callback, optionText)
        if not success then
            warn("RadiantUI Dropdown Callback Error:", err)
        end
    end)
    
    self:Close()
end

function RadiantUI.DropdownComponent:ToggleMultiOption(optionText, checkbox, checkmark)
    local wasSelected = self.selectedValues[optionText]
    self.selectedValues[optionText] = not wasSelected
    local isNowSelected = self.selectedValues[optionText]
    
    -- Update visual state
    TweenService:Create(checkbox, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        BackgroundColor3 = isNowSelected and self.gui.Config.Theme.Primary or Color3.fromRGB(60, 60, 60)
    }):Play()
    
    checkmark.Text = isNowSelected and "✓" or ""
    
    -- Update selected values list
    local selectedList = {}
    for value, isSelected in pairs(self.selectedValues) do
        if isSelected then
            table.insert(selectedList, value)
        end
    end
    
    self.selectedValue = selectedList
    self.element.Value = selectedList
    self:UpdateDisplay()
    
    -- Execute callback
    spawn(function()
        local success, err = pcall(self.callback, selectedList)
        if not success then
            warn("RadiantUI MultiDropdown Callback Error:", err)
        end
    end)
end

function RadiantUI.DropdownComponent:Open()
    if self.isOpen then return end
    
    -- Close other dropdowns
    self.gui:CloseAllDropdowns(self)
    
    self.isOpen = true
    
    -- Set Z-Index
    self.baseZIndex = self.gui:GetNextDropdownZIndex()
    self.menuContainer.ZIndex = self.baseZIndex
    self.searchInput.ZIndex = self.baseZIndex + 5
    self.optionsList.ZIndex = self.baseZIndex + 5
    
    -- Show menu
    self.menuContainer.Visible = true
    
    -- Reset search
    self.searchInput.Text = ""
    self.filteredOptions = {}
    for _, option in ipairs(self.options) do
        table.insert(self.filteredOptions, option)
    end
    
    -- Refresh options
    self:RefreshOptionsList()
    
    -- Focus search input
    spawn(function()
        wait(0.1)
        if self.isOpen and self.searchInput and self.searchInput.Parent then
            self.searchInput:CaptureFocus()
        end
    end)
    
    -- Animations
    local buttonStroke = self.container:FindFirstChild("ButtonFrame"):FindFirstChild("ButtonStroke")
    
    TweenService:Create(self.menuContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Size = UDim2.new(1, 0, 0, 172)
    }):Play()
    
    TweenService:Create(self.arrow, TweenInfo.new(0.3), {
        Rotation = 180
    }):Play()
    
    if buttonStroke then
        TweenService:Create(buttonStroke, TweenInfo.new(0.3), {
            Color = self.gui.Config.Theme.Primary,
            Transparency = 0.1
        }):Play()
    end
end

function RadiantUI.DropdownComponent:Close()
    if not self.isOpen then return end
    
    self.isOpen = false
    
    local buttonStroke = self.container:FindFirstChild("ButtonFrame"):FindFirstChild("ButtonStroke")
    
    -- Animations
    TweenService:Create(self.menuContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Size = UDim2.new(1, 0, 0, 0)
    }):Play()
    
    TweenService:Create(self.arrow, TweenInfo.new(0.3), {
        Rotation = 0
    }):Play()
    
    if buttonStroke then
        TweenService:Create(buttonStroke, TweenInfo.new(0.3), {
            Color = Color3.fromRGB(85, 85, 85),
            Transparency = 0.3
        }):Play()
    end
    
    -- Hide after animation
    spawn(function()
        wait(0.3)
        if not self.isOpen then
            self.menuContainer.Visible = false
        end
    end)
end

function RadiantUI.DropdownComponent:Toggle()
    if self.isOpen then
        self:Close()
    else
        self:Open()
    end
end

function RadiantUI.DropdownComponent:Destroy()
    -- Disconnect all connections
    for _, connection in pairs(self.connections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    -- Remove from manager
    if self.gui.DropdownManager.activeDropdowns[self.id] then
        self.gui.DropdownManager.activeDropdowns[self.id] = nil
    end
    
    -- Destroy UI
    if self.container and self.container.Parent then
        self.container:Destroy()
    end
end

-- ===== NEW DROPDOWN FUNCTIONS =====

function RadiantUI:CreateDropdown(element, parent)
    -- Create new dropdown component
    local dropdown = self.DropdownComponent.new(self, element, parent, false)
    return dropdown
end

function RadiantUI:CreateMultiDropdown(element, parent)
    -- Create new multi-dropdown component
    local dropdown = self.DropdownComponent.new(self, element, parent, true)
    return dropdown
end

-- Helper function to update existing element with options
function RadiantUI:SetOptions(element, newOptions)
    if not element or not element.Value then return end
    
    -- Find dropdown by element
    for id, dropdown in pairs(self.DropdownManager.activeDropdowns) do
        if dropdown.element == element then
            dropdown.options = newOptions or {}
            dropdown.filteredOptions = {}
            for _, option in ipairs(dropdown.options) do
                table.insert(dropdown.filteredOptions, option)
            end
            
            if dropdown.isOpen then
                dropdown:RefreshOptionsList()
            end
            break
        end
    end
end

-- Cleanup function for when GUI is destroyed
function RadiantUI:CleanupDropdowns()
    for id, dropdown in pairs(self.DropdownManager.activeDropdowns) do
        dropdown:Destroy()
    end
    self.DropdownManager.activeDropdowns = {}
    
    -- Disconnect global connections
    for _, connection in pairs(self.DropdownManager.globalConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    self.DropdownManager.globalConnections = {}
end

function RadiantUI:CreateInput(element, parent)
    local inputFrame = Instance.new('Frame')
    inputFrame.Size = UDim2.new(0, 120, 0, 28)
    inputFrame.Position = UDim2.new(1, -120, 0.5, -14)
    inputFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    inputFrame.BorderSizePixel = 0
    inputFrame.Parent = parent
    
    local inputCorner = Instance.new('UICorner')
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = inputFrame
    
    local textBox = Instance.new('TextBox')
    textBox.Size = UDim2.new(1, -16, 1, 0)
    textBox.Position = UDim2.new(0, 8, 0, 0)
    textBox.BackgroundTransparency = 1
    textBox.Text = element.Config.Default or ''
    textBox.PlaceholderText = element.Config.Placeholder or ''
    textBox.PlaceholderColor3 = self.Config.Theme.TextSecondary
    textBox.TextColor3 = self.Config.Theme.Text
    textBox.TextSize = 12
    textBox.Font = Enum.Font.Gotham
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.Parent = inputFrame
    
    element.Value = textBox.Text
    
    textBox:GetPropertyChangedSignal('Text'):Connect(function()
        element.Value = textBox.Text
        element.Callback(textBox.Text)
    end)
end

function RadiantUI:CreateColorPicker(element, parent)
    local initialColor = element.Config.Default or self.Config.Theme.Primary
    
    local colorPickerFrame = Instance.new('Frame')
    colorPickerFrame.Size = UDim2.new(0, 32, 0, 220)
    colorPickerFrame.Position = UDim2.new(1, -32, 0.5, -16)
    colorPickerFrame.BackgroundTransparency = 1
    colorPickerFrame.Parent = parent
    
    -- Color preview button
    local colorButton = Instance.new('TextButton')
    colorButton.Size = UDim2.new(0, 32, 0, 32)
    colorButton.Position = UDim2.new(0, 0, 0, 0)
    colorButton.BackgroundColor3 = initialColor
    colorButton.BorderSizePixel = 0
    colorButton.Text = ''
    colorButton.Parent = colorPickerFrame
    
    local colorCorner = Instance.new('UICorner')
    colorCorner.CornerRadius = UDim.new(0, 8)
    colorCorner.Parent = colorButton
    
    local colorOutline = Instance.new('UIStroke')
    colorOutline.Thickness = 1
    colorOutline.Color = Color3.fromRGB(80, 80, 80)
    colorOutline.Transparency = 0.3
    colorOutline.Parent = colorButton
    
    -- Color picker menu - positioned to the left and under the button
    local colorMenu = Instance.new('Frame')
    colorMenu.Size = UDim2.new(0, 260, 0, 220)
    colorMenu.Position = UDim2.new(0, -200, 0, 40)
    colorMenu.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    colorMenu.BorderSizePixel = 0
    colorMenu.Visible = false
    colorMenu.ZIndex = 15
    colorMenu.Parent = colorPickerFrame
    
    local menuCorner = Instance.new('UICorner')
    menuCorner.CornerRadius = UDim.new(0, 8)
    menuCorner.Parent = colorMenu
    
    local menuOutline = Instance.new('UIStroke')
    menuOutline.Thickness = 1
    menuOutline.Color = Color3.fromRGB(60, 60, 60)
    menuOutline.Transparency = 0.4
    menuOutline.Parent = colorMenu
    
    -- Color square (HSV selector)
    local colorSquare = Instance.new('Frame')
    colorSquare.Size = UDim2.new(0, 175, 0, 140)
    colorSquare.Position = UDim2.new(0, 15, 0, 15)
    colorSquare.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    colorSquare.BorderSizePixel = 0
    colorSquare.ZIndex = 16
    colorSquare.Parent = colorMenu
    
    local squareCorner = Instance.new('UICorner')
    squareCorner.CornerRadius = UDim.new(0, 6)
    squareCorner.Parent = colorSquare
    
    -- White overlay for saturation
    local whiteOverlay = Instance.new('Frame')
    whiteOverlay.Size = UDim2.new(1, 0, 1, 0)
    whiteOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    whiteOverlay.BorderSizePixel = 0
    whiteOverlay.ZIndex = 17
    whiteOverlay.Parent = colorSquare
    
    local whiteCorner = Instance.new('UICorner')
    whiteCorner.CornerRadius = UDim.new(0, 6)
    whiteCorner.Parent = whiteOverlay
    
    local whiteGradient = Instance.new('UIGradient')
    whiteGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
    whiteGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    whiteGradient.Parent = whiteOverlay
    
    -- Black overlay for brightness
    local blackOverlay = Instance.new('Frame')
    blackOverlay.Size = UDim2.new(1, 0, 1, 0)
    blackOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    blackOverlay.BorderSizePixel = 0
    blackOverlay.ZIndex = 18
    blackOverlay.Parent = colorSquare
    
    local blackCorner = Instance.new('UICorner')
    blackCorner.CornerRadius = UDim.new(0, 6)
    blackCorner.Parent = blackOverlay
    
    local blackGradient = Instance.new('UIGradient')
    blackGradient.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
    blackGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0)
    })
    blackGradient.Rotation = 90
    blackGradient.Parent = blackOverlay
    
    -- Square selector
    local squareSelector = Instance.new('Frame')
    squareSelector.Size = UDim2.new(0, 8, 0, 8)
    squareSelector.Position = UDim2.new(1, -4, 0, -4)
    squareSelector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    squareSelector.BorderSizePixel = 1
    squareSelector.BorderColor3 = Color3.fromRGB(0, 0, 0)
    squareSelector.ZIndex = 19
    squareSelector.Parent = colorSquare
    
    local selectorCorner = Instance.new('UICorner')
    selectorCorner.CornerRadius = UDim.new(0.5, 0)
    selectorCorner.Parent = squareSelector
    
    -- Hue bar
    local hueBar = Instance.new('Frame')
    hueBar.Size = UDim2.new(0, 28, 0, 140)
    hueBar.Position = UDim2.new(0, 200, 0, 15)
    hueBar.BorderSizePixel = 0
    hueBar.ZIndex = 16
    hueBar.Parent = colorMenu
    
    local hueCorner = Instance.new('UICorner')
    hueCorner.CornerRadius = UDim.new(0, 6)
    hueCorner.Parent = hueBar
    
    -- Hue gradient
    local hueGradient = Instance.new('UIGradient')
    hueGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    })
    hueGradient.Rotation = 90
    hueGradient.Parent = hueBar
    
    -- Hue selector
    local hueSelector = Instance.new('Frame')
    hueSelector.Size = UDim2.new(1, 0, 0, 3)
    hueSelector.Position = UDim2.new(0, 0, 0, -1)
    hueSelector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hueSelector.BorderSizePixel = 1
    hueSelector.BorderColor3 = Color3.fromRGB(0, 0, 0)
    hueSelector.ZIndex = 17
    hueSelector.Parent = hueBar
    
    -- RGB inputs
    local rgbFrame = Instance.new('Frame')
    rgbFrame.Size = UDim2.new(0, 210, 0, 35)
    rgbFrame.Position = UDim2.new(0, 15, 0, 165)
    rgbFrame.BackgroundTransparency = 1
    rgbFrame.ZIndex = 16
    rgbFrame.Parent = colorMenu
    
    local rgbLayout = Instance.new('UIListLayout')
    rgbLayout.FillDirection = Enum.FillDirection.Horizontal
    rgbLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    rgbLayout.Padding = UDim.new(0, 8)
    rgbLayout.Parent = rgbFrame
    
    -- Create RGB inputs
    local function createRGBInput(label, initialValue)
        local container = Instance.new('Frame')
        container.Size = UDim2.new(0, 65, 0, 35)
        container.BackgroundTransparency = 1
        container.ZIndex = 16
        container.Parent = rgbFrame
        
        local labelText = Instance.new('TextLabel')
        labelText.Size = UDim2.new(0, 20, 1, 0)
        labelText.Position = UDim2.new(0, 0, 0, 0)
        labelText.BackgroundTransparency = 1
        labelText.Text = label
        labelText.TextColor3 = Color3.fromRGB(200, 200, 200)
        labelText.TextSize = 15
        labelText.Font = Enum.Font.GothamBold
        labelText.TextXAlignment = Enum.TextXAlignment.Center
        labelText.ZIndex = 17
        labelText.Parent = container
        
        local inputField = Instance.new('Frame')
        inputField.Size = UDim2.new(1, -24, 1, 0)
        inputField.Position = UDim2.new(0, 24, 0, 0)
        inputField.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        inputField.BorderSizePixel = 0
        inputField.ZIndex = 17
        inputField.Parent = container
        
        local fieldCorner = Instance.new('UICorner')
        fieldCorner.CornerRadius = UDim.new(0, 4)
        fieldCorner.Parent = inputField
        
        local inputBox = Instance.new('TextBox')
        inputBox.Size = UDim2.new(1, -8, 1, 0)
        inputBox.Position = UDim2.new(0, 4, 0, 0)
        inputBox.BackgroundTransparency = 1
        inputBox.Text = tostring(initialValue)
        inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        inputBox.TextSize = 14
        inputBox.Font = Enum.Font.Gotham
        inputBox.TextXAlignment = Enum.TextXAlignment.Center
        inputBox.ZIndex = 18
        inputBox.Parent = inputField
        
        return inputBox
    end
    
    local rInput = createRGBInput('R', math.floor(initialColor.R * 255))
    local gInput = createRGBInput('G', math.floor(initialColor.G * 255))
    local bInput = createRGBInput('B', math.floor(initialColor.B * 255))
    
    -- Color state
    local currentColor = initialColor
    local currentHue = 0
    local currentSaturation = 1
    local currentValue = 1
    local isMenuOpen = false
    
    -- HSV to RGB conversion
    local function HSVtoRGB(h, s, v)
        local r, g, b
        local i = math.floor(h * 6)
        local f = h * 6 - i
        local p = v * (1 - s)
        local q = v * (1 - f * s)
        local t = v * (1 - (1 - f) * s)
        
        local imod = i % 6
        if imod == 0 then
            r, g, b = v, t, p
        elseif imod == 1 then
            r, g, b = q, v, p
        elseif imod == 2 then
            r, g, b = p, v, t
        elseif imod == 3 then
            r, g, b = p, q, v
        elseif imod == 4 then
            r, g, b = t, p, v
        elseif imod == 5 then
            r, g, b = v, p, q
        end
        
        return Color3.fromRGB(
            math.clamp(math.floor(r * 255 + 0.5), 0, 255),
            math.clamp(math.floor(g * 255 + 0.5), 0, 255),
            math.clamp(math.floor(b * 255 + 0.5), 0, 255)
        )
    end
    
    -- Update color display
    local function updateColor()
        currentColor = HSVtoRGB(currentHue, currentSaturation, currentValue)
        colorButton.BackgroundColor3 = currentColor
        
        -- Update RGB inputs
        rInput.Text = tostring(math.floor(currentColor.R * 255))
        gInput.Text = tostring(math.floor(currentColor.G * 255))
        bInput.Text = tostring(math.floor(currentColor.B * 255))
        
        -- Update hue bar background
        local hueColor = HSVtoRGB(currentHue, 1, 1)
        colorSquare.BackgroundColor3 = hueColor
        
        -- Update element value and callback
        element.Value = currentColor
        element.Callback(currentColor)
    end
    
    -- Square interaction
    local squareButton = Instance.new('TextButton')
    squareButton.Size = UDim2.new(1, 0, 1, 0)
    squareButton.BackgroundTransparency = 1
    squareButton.Text = ''
    squareButton.ZIndex = 20
    squareButton.Parent = colorSquare
    
    local squareDragging = false
    
    local function updateSquare(inputPos)
        local squarePos = colorSquare.AbsolutePosition
        local squareSize = colorSquare.AbsoluteSize
        
        -- Correct for GUI inset
        local guiInset = game:GetService("GuiService"):GetGuiInset()
        local correctedX = inputPos.X - guiInset.X
        local correctedY = inputPos.Y - guiInset.Y
        
        local relativeX = math.clamp((correctedX - squarePos.X) / squareSize.X, 0, 1)
        local relativeY = math.clamp((correctedY - squarePos.Y) / squareSize.Y, 0, 1)
        
        currentSaturation = relativeX
        currentValue = 1 - relativeY
        
        squareSelector.Position = UDim2.new(relativeX, -4, relativeY, -4)
        updateColor()
    end
    
    squareButton.MouseButton1Down:Connect(function()
        squareDragging = true
        updateSquare(UserInputService:GetMouseLocation())
    end)
    
    -- Hue bar interaction
    local hueButton = Instance.new('TextButton')
    hueButton.Size = UDim2.new(1, 0, 1, 0)
    hueButton.BackgroundTransparency = 1
    hueButton.Text = ''
    hueButton.ZIndex = 18
    hueButton.Parent = hueBar
    
    local hueDragging = false
    
    local function updateHue(inputPos)
        local huePos = hueBar.AbsolutePosition
        local hueSize = hueBar.AbsoluteSize
        
        -- Correct for GUI inset
        local guiInset = game:GetService("GuiService"):GetGuiInset()
        local correctedX = inputPos.X - guiInset.X
        local correctedY = inputPos.Y - guiInset.Y
        
        local relativeY = math.clamp((correctedY - huePos.Y) / hueSize.Y, 0, 1)
        currentHue = relativeY
        
        hueSelector.Position = UDim2.new(0, 0, relativeY, -1)
        updateColor()
    end
    
    hueButton.MouseButton1Down:Connect(function()
        hueDragging = true
        updateHue(UserInputService:GetMouseLocation())
    end)
    
    -- Global mouse events
    local connection1 = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if squareDragging then
                updateSquare(UserInputService:GetMouseLocation())
            elseif hueDragging then
                updateHue(UserInputService:GetMouseLocation())
            end
        end
    end)
    
    local connection2 = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            squareDragging = false
            hueDragging = false
        end
    end)
    
    table.insert(self.Connections, connection1)
    table.insert(self.Connections, connection2)
    
    -- Toggle menu by clicking the color button
    colorButton.MouseButton1Click:Connect(function()
        isMenuOpen = not isMenuOpen
        colorMenu.Visible = isMenuOpen
    end)
    
    -- Close menu when clicking outside
    local clickConnection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and isMenuOpen then
            local mousePos = UserInputService:GetMouseLocation()
            local guiInset = game:GetService("GuiService"):GetGuiInset()
            local correctedX = mousePos.X - guiInset.X
            local correctedY = mousePos.Y - guiInset.Y
            
            local menuPos = colorMenu.AbsolutePosition
            local menuSize = colorMenu.AbsoluteSize
            local buttonPos = colorButton.AbsolutePosition
            local buttonSize = colorButton.AbsoluteSize
            
            -- Check if click is outside menu and button
            local outsideMenu = correctedX < menuPos.X or correctedX > menuPos.X + menuSize.X or
                               correctedY < menuPos.Y or correctedY > menuPos.Y + menuSize.Y
            local outsideButton = correctedX < buttonPos.X or correctedX > buttonPos.X + buttonSize.X or
                                 correctedY < buttonPos.Y or correctedY > buttonPos.Y + buttonSize.Y
            
            if outsideMenu and outsideButton then
                isMenuOpen = false
                colorMenu.Visible = false
            end
        end
    end)
    
    table.insert(self.Connections, clickConnection)
    
    -- Initialize element value
    element.Value = currentColor
    
    -- Initialize color display
    updateColor()
end

function RadiantUI:CreateKeybind(element, parent)
    -- Key name mapping für bessere Anzeige
    local keyNames = {
        [Enum.KeyCode.LeftControl] = 'LCtrl',
        [Enum.KeyCode.RightControl] = 'RCtrl',
        [Enum.KeyCode.LeftShift] = 'LShift',
        [Enum.KeyCode.RightShift] = 'RShift',
        [Enum.KeyCode.LeftAlt] = 'LAlt',
        [Enum.KeyCode.RightAlt] = 'RAlt',
        [Enum.KeyCode.Space] = 'Space',
        [Enum.KeyCode.Return] = 'Enter',
        [Enum.KeyCode.Backspace] = 'Backspace',
        [Enum.KeyCode.Tab] = 'Tab',
        [Enum.KeyCode.CapsLock] = 'Caps',
        [Enum.KeyCode.Escape] = 'Esc',
        [Enum.KeyCode.F1] = 'F1',
        [Enum.KeyCode.F2] = 'F2',
        [Enum.KeyCode.F3] = 'F3',
        [Enum.KeyCode.F4] = 'F4',
        [Enum.KeyCode.F5] = 'F5',
        [Enum.KeyCode.F6] = 'F6',
        [Enum.KeyCode.F7] = 'F7',
        [Enum.KeyCode.F8] = 'F8',
        [Enum.KeyCode.F9] = 'F9',
        [Enum.KeyCode.F10] = 'F10',
        [Enum.KeyCode.F11] = 'F11',
        [Enum.KeyCode.F12] = 'F12',
    }
    
    local function getKeyDisplayName(keyCode)
        if keyNames[keyCode] then
            return keyNames[keyCode]
        else
            local keyString = tostring(keyCode)
            return keyString:match('%.(%w+)$') or keyString
        end
    end
    
    local keybindFrame = Instance.new('Frame')
    keybindFrame.Size = UDim2.new(0, 120, 0, 32)
    keybindFrame.Position = UDim2.new(1, -120, 0.5, -16)
    keybindFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    keybindFrame.BorderSizePixel = 0
    keybindFrame.Parent = parent
    
    local keybindCorner = Instance.new('UICorner')
    keybindCorner.CornerRadius = UDim.new(0, 8)
    keybindCorner.Parent = keybindFrame
    
    local keybindButton = Instance.new('TextButton')
    keybindButton.Size = UDim2.new(1, 0, 1, 0)
    keybindButton.BackgroundTransparency = 1
    keybindButton.Text = element.Config.Default or 'None'
    keybindButton.TextColor3 = self.Config.Theme.Text
    keybindButton.TextSize = 12
    keybindButton.Font = Enum.Font.Gotham
    keybindButton.Parent = keybindFrame
    
    local isBinding = false
    element.Value = element.Config.Default
    
    keybindButton.MouseButton1Click:Connect(function()
        if isBinding then return end
        isBinding = true
        keybindButton.Text = 'Press key...'
        keybindButton.TextColor3 = self.Config.Theme.Primary
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local keyName = getKeyDisplayName(input.KeyCode)
                element.Value = keyName
                keybindButton.Text = keyName
                keybindButton.TextColor3 = self.Config.Theme.Text
                element.Callback(input.KeyCode)
                isBinding = false
                connection:Disconnect()
                
                -- Cooldown hinzufügen damit Menü nicht sofort schließt
                self.KeybindCooldown = true
                spawn(function()
                    wait(0.5) -- 500ms Cooldown
                    self.KeybindCooldown = false
                end)
            end
        end)
        
        table.insert(self.Connections, connection)
    end)
end

function RadiantUI:UpdateSectionHeight(section)
    if not section.Frame then return end
    
    local headerHeight = 55
    local itemHeight = 35
    local itemSpacing = 15
    local bottomPadding = 20
    local totalItems = #section.Elements
    local calculatedHeight = headerHeight + (totalItems * itemHeight) + ((totalItems - 1) * itemSpacing) + bottomPadding
    
    section.Frame.Size = UDim2.new(1, -10, 0, calculatedHeight)
    section.ItemsFrame.Size = UDim2.new(1, -40, 0, (totalItems * itemHeight) + ((totalItems - 1) * itemSpacing))
end

function RadiantUI:CreateSettingsTab()
    self.SettingsTab = {
        Name = "Settings",
        Icon = "rbxassetid://4483345998",
        IconActive = "rbxassetid://4483345998",
        Sections = {},
        Content = nil,
        Button = nil
    }
    
    local tabIndex = SETTINGS_TAB_INDEX
    local button = Instance.new('TextButton')
    button.Size = UDim2.new(1, 0, 0, 50)
    button.Position = UDim2.new(0, 0, 0, (#self.Tabs) * 50 + 20)
    button.BackgroundTransparency = 1
    button.Text = ''
    button.Parent = self.SidebarFrame
    
    local indicator = Instance.new('Frame')
    indicator.Size = UDim2.new(0, 4, 0, 0)
    indicator.Position = UDim2.new(0, 0, 0.5, 0)
    indicator.AnchorPoint = Vector2.new(0, 0.5)
    indicator.BackgroundColor3 = self.Config.Theme.Primary
    indicator.BorderSizePixel = 0
    indicator.Parent = button
    
    local indicatorCorner = Instance.new('UICorner')
    indicatorCorner.CornerRadius = UDim.new(0, 2)
    indicatorCorner.Parent = indicator
    
    local icon = Instance.new('ImageLabel')
    icon.Size = UDim2.new(0, 24, 0, 24)
    icon.Position = UDim2.new(0, 12, 0.5, -12)
    icon.BackgroundTransparency = 1
    icon.Image = self.SettingsTab.Icon
    icon.Parent = button
    
    local text = Instance.new('TextLabel')
    text.Size = UDim2.new(1, -44, 1, 0)
    text.Position = UDim2.new(0, 42, 0, 0)
    text.BackgroundTransparency = 1
    text.Text = self.SettingsTab.Name
    text.TextColor3 = self.Config.Theme.TextSecondary
    text.TextSize = 16
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Font = Enum.Font.SourceSansBold
    text.Parent = button
    
    self.SettingsTab.Button = {
        Frame = button,
        Indicator = indicator,
        Icon = icon,
        Text = text
    }
    
    button.MouseButton1Click:Connect(function()
        self:SwitchTab(SETTINGS_TAB_INDEX)
    end)
    
    button.MouseEnter:Connect(function()
        if self.CurrentTab ~= SETTINGS_TAB_INDEX then
            TweenService:Create(button, TweenInfo.new(0.3), {BackgroundTransparency = 0.9}):Play()
            TweenService:Create(text, TweenInfo.new(0.3), {TextColor3 = self.Config.Theme.Text}):Play()
        end
    end)
    
    button.MouseLeave:Connect(function()
        if self.CurrentTab ~= SETTINGS_TAB_INDEX then
            TweenService:Create(button, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            TweenService:Create(text, TweenInfo.new(0.3), {TextColor3 = self.Config.Theme.TextSecondary}):Play()
        end
    end)
    
    self:AddDefaultSettings()
end

function RadiantUI:AddDefaultSettings()
    local guiSection = {
        Title = "GUI Settings",
        Elements = {}
    }
    
    table.insert(guiSection.Elements, {
        Type = 'Toggle',
        Name = 'Show Watermark',
        Value = self.Config.ShowWatermark,
        Callback = function(value)
            self.Config.ShowWatermark = value
            if self.WatermarkFrame then
                self.WatermarkFrame.Visible = value
            end
        end
    })
    
    table.insert(guiSection.Elements, {
        Type = 'Toggle',
        Name = 'Enable Notifications',
        Value = self.Config.EnableNotifications,
        Callback = function(value)
            self.Config.EnableNotifications = value
        end
    })
    
    table.insert(guiSection.Elements, {
        Type = 'Keybind',
        Name = 'Toggle GUI',
        Value = 'RCtrl',
        Config = {Default = 'RCtrl'},
        Callback = function(keyCode)
            self.ToggleKeybind = keyCode
        end
    })
    
    table.insert(self.SettingsTab.Sections, guiSection)
    
    local configSection = {
        Title = "Configuration",
        Elements = {}
    }
    
    table.insert(configSection.Elements, {
        Type = 'Button',
        Name = 'Save Config',
        Callback = function()
            self:SaveConfig()
            self:ShowNotification("Configuration saved!", 3)
        end
    })
    
    table.insert(configSection.Elements, {
        Type = 'Button',
        Name = 'Load Config',
        Callback = function()
            self:LoadConfig()
            self:ShowNotification("Configuration loaded!", 3)
        end
    })
    
    table.insert(self.SettingsTab.Sections, configSection)
end

function RadiantUI:MakeDraggable()
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    self.HeaderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
        end
    end)
    
    local connection1 = UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    local connection2 = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    table.insert(self.Connections, connection1)
    table.insert(self.Connections, connection2)
end

function RadiantUI:SetupKeybinds()
    local connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        -- Keybind Cooldown prüfen um versehentliches Schließen zu verhindern
        if self.KeybindCooldown then return end
        
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == self.ToggleKeybind then
            self:ToggleGUI()
        end
    end)
    
    table.insert(self.Connections, connection)
end

function RadiantUI:ToggleGUI()
    self.GuiVisible = not self.GuiVisible
    self.MainFrame.Visible = self.GuiVisible
    
    -- Watermark bleibt immer sichtbar (User-Request)
    if self.WatermarkFrame then
        self.WatermarkFrame.Visible = self.Config.ShowWatermark
    end
    
    if self.Config.EnableNotifications then
        -- Notification entfernt (User-Request)
    end
end

function RadiantUI:ToggleMinimize()
    local isMinimized = self.MainFrame.Size.Y.Offset <= 60
    local targetSize = isMinimized and self.Config.Size or UDim2.new(0, 1000, 0, 60)
    
    TweenService:Create(self.MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
        Size = targetSize
    }):Play()
end

-- Fade functions removed for better performance

function RadiantUI:ShowNotification(text, duration)
    if not self.Config.EnableNotifications then return end
    
    duration = duration or 5
    
    -- Create notification container with modern styling
    local notification = Instance.new('Frame')
    notification.Size = UDim2.new(0, 400, 0, 85)
    notification.Position = UDim2.new(1, 50, 1, -120 - (#self.Notifications * 95)) -- Start off-screen right
    notification.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Changed background color
    notification.BorderSizePixel = 0
    notification.Parent = self.ScreenGui
    notification.ZIndex = 200

    -- Modern rounded corners
    local notifCorner = Instance.new('UICorner')
    notifCorner.CornerRadius = UDim.new(0, 16)
    notifCorner.Parent = notification

    -- Subtle shadow effect with inner glow
    local shadowFrame = Instance.new('Frame')
    shadowFrame.Size = UDim2.new(1, 8, 1, 8)
    shadowFrame.Position = UDim2.new(0, -4, 0, -4)
    shadowFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadowFrame.BackgroundTransparency = 0.7
    shadowFrame.BorderSizePixel = 0
    shadowFrame.ZIndex = 199
    shadowFrame.Parent = notification

    local shadowCorner = Instance.new('UICorner')
    shadowCorner.CornerRadius = UDim.new(0, 20)
    shadowCorner.Parent = shadowFrame

    -- Main text content - repositioned without icon
    local notifText = Instance.new('TextLabel')
    notifText.Size = UDim2.new(1, -40, 1, -20)
    notifText.Position = UDim2.new(0, 20, 0, 10)
    notifText.BackgroundTransparency = 1
    notifText.Text = text
    notifText.TextColor3 = Color3.fromRGB(245, 245, 245) -- Slightly off-white for better readability
    notifText.TextSize = 16
    notifText.Font = Enum.Font.GothamMedium
    notifText.TextWrapped = true
    notifText.TextXAlignment = Enum.TextXAlignment.Center
    notifText.TextYAlignment = Enum.TextYAlignment.Center
    notifText.ZIndex = 201
    notifText.Parent = notification

    -- Modern progress bar background
    local progressBg = Instance.new('Frame')
    progressBg.Size = UDim2.new(1, -40, 0, 4)
    progressBg.Position = UDim2.new(0, 20, 1, -12)
    progressBg.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    progressBg.BorderSizePixel = 0
    progressBg.ZIndex = 201
    progressBg.Parent = notification

    local progressBgCorner = Instance.new('UICorner')
    progressBgCorner.CornerRadius = UDim.new(0, 2)
    progressBgCorner.Parent = progressBg

    -- Modern red progress bar with glow effect
    local progressBar = Instance.new('Frame')
    progressBar.Size = UDim2.new(1, 0, 1, 0)
    progressBar.Position = UDim2.new(0, 0, 0, 0)
    progressBar.BackgroundColor3 = self.Config.Theme.Primary -- Use theme color
    progressBar.BorderSizePixel = 0
    progressBar.ZIndex = 202
    progressBar.Parent = progressBg

    local progressBarCorner = Instance.new('UICorner')
    progressBarCorner.CornerRadius = UDim.new(0, 2)
    progressBarCorner.Parent = progressBar

    -- Progress bar glow effect
    local progressGlow = Instance.new('Frame')
    progressGlow.Size = UDim2.new(1, 4, 1, 4)
    progressGlow.Position = UDim2.new(0, -2, 0, -2)
    progressGlow.BackgroundColor3 = self.Config.Theme.Primary
    progressGlow.BackgroundTransparency = 0.8
    progressGlow.BorderSizePixel = 0
    progressGlow.ZIndex = 201
    progressGlow.Parent = progressBg

    local progressGlowCorner = Instance.new('UICorner')
    progressGlowCorner.CornerRadius = UDim.new(0, 4)
    progressGlowCorner.Parent = progressGlow

    -- Add to active notifications
    table.insert(self.Notifications, notification)

    -- Slide in from right (nach links rein) with modern easing
    local targetPos = UDim2.new(1, -420, 1, -120 - ((#self.Notifications - 1) * 95))
    local slideInTween = TweenService:Create(notification, 
        TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), 
        { Position = targetPos }
    )
    slideInTween:Play()

    -- Progress bar animations (countdown with glow)
    local progressTween = TweenService:Create(progressBar, 
        TweenInfo.new(duration, Enum.EasingStyle.Linear), 
        { Size = UDim2.new(0, 0, 1, 0) }
    )
    
    local progressGlowTween = TweenService:Create(progressGlow, 
        TweenInfo.new(duration, Enum.EasingStyle.Linear), 
        { Size = UDim2.new(0, 4, 1, 4) }
    )
    
    -- Start progress animation after slide-in completes
    slideInTween.Completed:Connect(function()
        progressTween:Play()
        progressGlowTween:Play()
    end)

    -- Auto dismiss after duration
    task.spawn(function()
        task.wait(duration)
        if notification and notification.Parent then
            self:DismissNotification(notification, progressTween, progressGlowTween)
        end
    end)

    -- Click to dismiss with modern interaction
    local clickDetector = Instance.new('TextButton')
    clickDetector.Size = UDim2.new(1, 0, 1, 0)
    clickDetector.BackgroundTransparency = 1
    clickDetector.Text = ''
    clickDetector.ZIndex = 204
    clickDetector.Parent = notification

    clickDetector.MouseButton1Click:Connect(function()
        if progressTween then
            progressTween:Cancel()
        end
        if progressGlowTween then
            progressGlowTween:Cancel()
        end
        self:DismissNotification(notification)
    end)

    -- Modern hover effects
    clickDetector.MouseEnter:Connect(function()
        TweenService:Create(notification, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        }):Play()
    end)

    clickDetector.MouseLeave:Connect(function()
        TweenService:Create(notification, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        }):Play()
    end)
end

function RadiantUI:DismissNotification(notification, progressTween, progressGlowTween)
    -- Cancel any running tweens
    if progressTween then
        progressTween:Cancel()
    end
    if progressGlowTween then
        progressGlowTween:Cancel()
    end
    
    -- Remove from notifications list
    for i, notif in ipairs(self.Notifications) do
        if notif == notification then
            table.remove(self.Notifications, i)
            break
        end
    end
    
    -- Slide out to right (nach rechts raus) with modern easing
    local slideOutTween = TweenService:Create(notification, 
        TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), 
        { Position = UDim2.new(1, 50, notification.Position.Y.Scale, notification.Position.Y.Offset) }
    )
    slideOutTween:Play()

    -- Reposition remaining notifications with smooth animation
    for i, notif in ipairs(self.Notifications) do
        if notif and notif.Parent then
            local newPos = UDim2.new(1, -420, 1, -120 - ((i - 1) * 95))
            TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { Position = newPos }):Play()
        end
    end

    -- Clean up after slide out
    slideOutTween.Completed:Connect(function()
        if notification and notification.Parent then
            notification:Destroy()
        end
    end)
end

function RadiantUI:SaveConfig()
    local config = {
        Title = self.Config.Title,
        Theme = self.Config.Theme,
        ShowWatermark = self.Config.ShowWatermark,
        EnableNotifications = self.Config.EnableNotifications,
        Position = {
            X = {Scale = self.MainFrame.Position.X.Scale, Offset = self.MainFrame.Position.X.Offset},
            Y = {Scale = self.MainFrame.Position.Y.Scale, Offset = self.MainFrame.Position.Y.Offset}
        }
    }
    
    _G.RadiantUI_SavedConfig = config
end

function RadiantUI:LoadConfig()
    local config = _G.RadiantUI_SavedConfig
    if not config then return end
    
    if config.Title then self.Config.Title = config.Title end
    if config.Theme then self.Config.Theme = config.Theme end
    if config.ShowWatermark ~= nil then self.Config.ShowWatermark = config.ShowWatermark end
    if config.EnableNotifications ~= nil then self.Config.EnableNotifications = config.EnableNotifications end
    
    if config.Position then
        self.MainFrame.Position = UDim2.new(
            config.Position.X.Scale, config.Position.X.Offset,
            config.Position.Y.Scale, config.Position.Y.Offset
        )
    end
    
    if self.TitleLabel then
        self.TitleLabel.Text = self.Config.Title
    end
    
    if self.WatermarkFrame then
        self.WatermarkFrame.Visible = self.Config.ShowWatermark
    end
end

function RadiantUI:Destroy()
    for _, connection in pairs(self.Connections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    for _, tween in pairs(self.Tweens) do
        if tween then
            tween:Cancel()
        end
    end
    
    for _, notification in pairs(self.Notifications) do
        if notification and notification.Parent then
            notification:Destroy()
        end
    end
    
    if self.ScreenGui and self.ScreenGui.Parent then
        self.ScreenGui:Destroy()
    end
    
    if _G.RadiantUI_Instance == self then
        _G.RadiantUI_Instance = nil
    end
end

function RadiantUI:SetTitle(title)
    self.Config.Title = title
    if self.TitleLabel then
        self.TitleLabel.Text = title
    end
end

function RadiantUI:SetTheme(theme)
    for key, value in pairs(theme) do
        if self.Config.Theme[key] then
            self.Config.Theme[key] = value
        end
    end
    if self.TitleLabel then
        self.TitleLabel.TextColor3 = self.Config.Theme.Primary
    end
end

function RadiantUI:GetCurrentTab()
    return self.CurrentTab
end

function RadiantUI:SetVisible(visible)
    self.GuiVisible = visible
    self.MainFrame.Visible = visible
    if self.WatermarkFrame then
        self.WatermarkFrame.Visible = visible and self.Config.ShowWatermark
    end
end

function RadiantUI:IsVisible()
    return self.GuiVisible
end

-- Export the library
_G.RadiantUI = RadiantUI
return RadiantUI

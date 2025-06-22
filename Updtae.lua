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
local MAX_USER_TABS = 5
local SETTINGS_TAB_INDEX = 6

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
    EnableNotifications = true,
    FadeAnimations = true
}

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
    
    if self.Config.FadeAnimations then
        self:FadeIn()
    end
    
    spawn(function()
        wait(1)
        self:ShowNotification("RadiantUI " .. self.Version .. " loaded successfully!", 4)
        -- Erstelle Settings Tab falls noch nicht erstellt
        if not self.SettingsTab then
            self:CreateSettingsTab()
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
                self:ToggleMinimize()
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
    self.SidebarFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
    self.SidebarFrame.Parent = self.MainFrame
    
    local sidebarCorner = Instance.new('UICorner')
    sidebarCorner.CornerRadius = UDim.new(0, 15)
    sidebarCorner.Parent = self.SidebarFrame
    
    self:CreateAvatarSection()
end

function RadiantUI:CreateAvatarSection()
    local avatarSection = Instance.new("Frame")
    avatarSection.Size = UDim2.new(1, 0, 0, 90)
    avatarSection.Position = UDim2.new(0, 0, 1, -150)
    avatarSection.BackgroundTransparency = 1
    avatarSection.Parent = self.SidebarFrame
    
    local avatarCircle = Instance.new("Frame")
    avatarCircle.Size = UDim2.new(0, 50, 0, 50)
    avatarCircle.Position = UDim2.new(0, 15, 0.5, -25)
    avatarCircle.BackgroundTransparency = 1
    avatarCircle.Parent = avatarSection
    
    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(0.5, 0)
    avatarCorner.Parent = avatarCircle
    
    local avatarImage = Instance.new("ImageLabel")
    avatarImage.Size = UDim2.new(1, -4, 1, -4)
    avatarImage.Position = UDim2.new(0, 2, 0, 2)
    avatarImage.BackgroundTransparency = 1
    avatarImage.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. Players.LocalPlayer.UserId .. "&width=420&height=420&format=png"
    avatarImage.Parent = avatarCircle
    
    local avatarImgCorner = Instance.new("UICorner")
    avatarImgCorner.CornerRadius = UDim.new(0.5, 0)
    avatarImgCorner.Parent = avatarImage
    
    local statusCircle = Instance.new("Frame")
    statusCircle.Size = UDim2.new(0, 8, 0, 8)
    statusCircle.Position = UDim2.new(1, -10, 1, -10)
    statusCircle.BackgroundColor3 = self.Config.Theme.Primary
    statusCircle.Parent = avatarCircle
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0.5, 0)
    statusCorner.Parent = statusCircle
    
    local usernameLabel = Instance.new("TextLabel")
    usernameLabel.Size = UDim2.new(1, -75, 0, 25)
    usernameLabel.Position = UDim2.new(0, 70, 0, 23)
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.Text = Players.LocalPlayer.Name
    usernameLabel.TextColor3 = self.Config.Theme.Text
    usernameLabel.TextSize = 18
    usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    usernameLabel.Font = Enum.Font.SourceSansBold
    usernameLabel.Parent = avatarSection
    
    local subscriptionLabel = Instance.new("TextLabel")
    subscriptionLabel.Size = UDim2.new(1, -75, 0, 20)
    subscriptionLabel.Position = UDim2.new(0, 70, 0, 48)
    subscriptionLabel.BackgroundTransparency = 1
    subscriptionLabel.Text = "Premium User"
    subscriptionLabel.TextColor3 = self.Config.Theme.Primary
    subscriptionLabel.TextSize = 14
    subscriptionLabel.Font = Enum.Font.SourceSans
    subscriptionLabel.Parent = avatarSection
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

function RadiantUI:AddTab(config)
    if #self.Tabs >= MAX_USER_TABS then
        warn("RadiantUI: Maximum number of tabs (" .. MAX_USER_TABS .. ") reached")
        return nil
    end
    
    local tabIndex = #self.Tabs + 1
    local tab = {
        Name = config.Name or "Tab " .. tabIndex,
        Icon = config.Icon or "rbxassetid://82459568409030",
        IconActive = config.IconActive or config.Icon,
        Sections = {},
        Content = nil,
        Button = nil
    }
    
    self.Tabs[tabIndex] = tab
    self:CreateTabButton(tab, tabIndex)
    
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
    contentFrame.Size = UDim2.new(1, -60, 1, -30)
    contentFrame.Position = UDim2.new(0, 30, 0, 15)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = self.ContentFrame
    contentFrame.Visible = tabIndex == self.CurrentTab
    
    local leftColumn = Instance.new('ScrollingFrame')
    leftColumn.Size = UDim2.new(0.48, -5, 1, 0)
    leftColumn.Position = UDim2.new(0, 0, 0, 0)
    leftColumn.BackgroundTransparency = 1
    leftColumn.BorderSizePixel = 0
    leftColumn.ScrollBarThickness = 2
    leftColumn.CanvasSize = UDim2.new(0, 0, 2, 0)
    leftColumn.Parent = contentFrame
    
    local rightColumn = Instance.new('ScrollingFrame')
    rightColumn.Size = UDim2.new(0.48, -5, 1, 0)
    rightColumn.Position = UDim2.new(0.52, 5, 0, 0)
    rightColumn.BackgroundTransparency = 1
    rightColumn.BorderSizePixel = 0
    rightColumn.ScrollBarThickness = 2
    rightColumn.CanvasSize = UDim2.new(0, 0, 2, 0)
    rightColumn.Parent = contentFrame
    
    local leftLayout = Instance.new('UIListLayout')
    leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    leftLayout.Padding = UDim.new(0, 15)
    leftLayout.Parent = leftColumn
    
    local rightLayout = Instance.new('UIListLayout')
    rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rightLayout.Padding = UDim.new(0, 15)
    rightLayout.Parent = rightColumn
    
    local leftPadding = Instance.new('UIPadding')
    leftPadding.PaddingTop = UDim.new(0, 15)
    leftPadding.PaddingBottom = UDim.new(0, 15)
    leftPadding.Parent = leftColumn
    
    local rightPadding = Instance.new('UIPadding')
    rightPadding.PaddingTop = UDim.new(0, 15)
    rightPadding.PaddingBottom = UDim.new(0, 15)
    rightPadding.Parent = rightColumn
    
    tab.Content = contentFrame
    tab.LeftColumn = leftColumn
    tab.RightColumn = rightColumn
    
    for i, section in ipairs(tab.Sections) do
        local parentColumn = (i % 2 == 1) and leftColumn or rightColumn
        self:CreateSection(section, parentColumn, math.ceil(i / 2))
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
            return self:AddElement(section, 'Dropdown', elementConfig)
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
        end
    }
end

function RadiantUI:CreateSection(section, parentColumn, layoutOrder)
    local headerHeight = 55
    local itemHeight = 35
    local itemSpacing = 15
    local bottomPadding = 20
    local totalItems = #section.Elements
    local calculatedHeight = headerHeight + (totalItems * itemHeight) + ((totalItems - 1) * itemSpacing) + bottomPadding
    
    local sectionFrame = Instance.new('Frame')
    sectionFrame.Size = UDim2.new(1, -10, 0, calculatedHeight)
    sectionFrame.BackgroundColor3 = self.Config.Theme.Secondary
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
    itemsFrame.Size = UDim2.new(1, -40, 0, (totalItems * itemHeight) + ((totalItems - 1) * itemSpacing))
    itemsFrame.Position = UDim2.new(0, 20, 0, 45)
    itemsFrame.BackgroundTransparency = 1
    itemsFrame.Parent = sectionFrame
    
    local itemLayout = Instance.new('UIListLayout')
    itemLayout.SortOrder = Enum.SortOrder.LayoutOrder
    itemLayout.Padding = UDim.new(0, itemSpacing)
    itemLayout.Parent = itemsFrame
    
    section.Frame = sectionFrame
    section.ItemsFrame = itemsFrame
    
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
    local element = {
        Type = elementType,
        Name = config.Name or "Element",
        Config = config,
        Frame = nil,
        Value = config.Default or false,
        Callback = config.Callback or function() end
    }
    
    table.insert(section.Elements, element)
    
    if section.ItemsFrame then
        self:CreateElement(element, section.ItemsFrame, #section.Elements)
        self:UpdateSectionHeight(section)
    end
    
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
    
    local label = Instance.new('TextLabel')
    label.Size = UDim2.new(0.55, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = element.Name
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
        label.Text = ''
    elseif element.Type == 'Dropdown' then
        self:CreateDropdown(element, itemFrame)
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
    button.Text = element.Name
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

function RadiantUI:CreateDropdown(element, parent)
    local dropdownFrame = Instance.new('Frame')
    dropdownFrame.Size = UDim2.new(0, 140, 0, 32)
    dropdownFrame.Position = UDim2.new(1, -140, 0.5, -16)
    dropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.Parent = parent
    
    local dropdownCorner = Instance.new('UICorner')
    dropdownCorner.CornerRadius = UDim.new(0, 8)
    dropdownCorner.Parent = dropdownFrame
    
    local dropdownButton = Instance.new('TextButton')
    dropdownButton.Size = UDim2.new(1, 0, 1, 0)
    dropdownButton.BackgroundTransparency = 1
    dropdownButton.Text = element.Config.Placeholder or 'Select...'
    dropdownButton.TextColor3 = self.Config.Theme.TextSecondary
    dropdownButton.TextSize = 12
    dropdownButton.Font = Enum.Font.Gotham
    dropdownButton.TextXAlignment = Enum.TextXAlignment.Left
    dropdownButton.Parent = dropdownFrame
    
    local buttonPadding = Instance.new('UIPadding')
    buttonPadding.PaddingLeft = UDim.new(0, 12)
    buttonPadding.PaddingRight = UDim.new(0, 30)
    buttonPadding.Parent = dropdownButton
    
    local arrowIcon = Instance.new('TextLabel')
    arrowIcon.Size = UDim2.new(0, 20, 1, 0)
    arrowIcon.Position = UDim2.new(1, -25, 0, 0)
    arrowIcon.BackgroundTransparency = 1
    arrowIcon.Text = '▼'
    arrowIcon.TextColor3 = self.Config.Theme.TextSecondary
    arrowIcon.TextSize = 10
    arrowIcon.Font = Enum.Font.Gotham
    arrowIcon.Parent = dropdownFrame
    
    local options = element.Config.Options or {}
    
    dropdownButton.MouseButton1Click:Connect(function()
        if #options > 0 then
            element.Value = options[1]
            dropdownButton.Text = options[1]
            dropdownButton.TextColor3 = self.Config.Theme.Text
            element.Callback(options[1])
        end
    end)
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
    local colorFrame = Instance.new('Frame')
    colorFrame.Size = UDim2.new(0, 32, 0, 32)
    colorFrame.Position = UDim2.new(1, -32, 0.5, -16)
    colorFrame.BackgroundColor3 = element.Config.Default or self.Config.Theme.Primary
    colorFrame.BorderSizePixel = 0
    colorFrame.Parent = parent
    
    local colorCorner = Instance.new('UICorner')
    colorCorner.CornerRadius = UDim.new(0, 8)
    colorCorner.Parent = colorFrame
    
    local colorButton = Instance.new('TextButton')
    colorButton.Size = UDim2.new(1, 0, 1, 0)
    colorButton.BackgroundTransparency = 1
    colorButton.Text = ''
    colorButton.Parent = colorFrame
    
    element.Value = colorFrame.BackgroundColor3
    
    colorButton.MouseButton1Click:Connect(function()
        local colors = {
            Color3.fromRGB(255, 51, 51),
            Color3.fromRGB(51, 255, 51),
            Color3.fromRGB(51, 51, 255),
            Color3.fromRGB(255, 255, 51),
            Color3.fromRGB(255, 51, 255),
            Color3.fromRGB(51, 255, 255)
        }
        local randomColor = colors[math.random(1, #colors)]
        element.Value = randomColor
        colorFrame.BackgroundColor3 = randomColor
        element.Callback(randomColor)
    end)
end

function RadiantUI:CreateKeybind(element, parent)
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
                local keyName = tostring(input.KeyCode):match('%.(%w+)') or tostring(input.KeyCode)
                element.Value = keyName
                keybindButton.Text = keyName
                keybindButton.TextColor3 = self.Config.Theme.Text
                element.Callback(input.KeyCode)
                isBinding = false
                connection:Disconnect()
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
        Icon = "rbxassetid://105710018760458",
        IconActive = "rbxassetid://105710018760458",
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
        
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == self.ToggleKeybind then
            self:ToggleGUI()
        end
    end)
    
    table.insert(self.Connections, connection)
end

function RadiantUI:ToggleGUI()
    self.GuiVisible = not self.GuiVisible
    
    if self.Config.FadeAnimations then
        if self.GuiVisible then
            self.MainFrame.Visible = true
            self:FadeIn()
        else
            self:FadeOut()
            spawn(function()
                wait(0.5)
                if not self.GuiVisible then
                    self.MainFrame.Visible = false
                end
            end)
        end
    else
        self.MainFrame.Visible = self.GuiVisible
        if self.WatermarkFrame then
            self.WatermarkFrame.Visible = self.GuiVisible and self.Config.ShowWatermark
        end
    end
    
    if self.Config.EnableNotifications then
        self:ShowNotification("GUI " .. (self.GuiVisible and "Opened" or "Closed"), 2)
    end
end

function RadiantUI:ToggleMinimize()
    local isMinimized = self.MainFrame.Size.Y.Offset <= 60
    local targetSize = isMinimized and self.Config.Size or UDim2.new(0, 1000, 0, 60)
    
    TweenService:Create(self.MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
        Size = targetSize
    }):Play()
end

function RadiantUI:FadeIn()
    local elements = self:GetAllFadeableElements()
    
    for _, element in pairs(elements) do
        if element.Type == 'Frame' then
            element.Element.BackgroundTransparency = 1
            TweenService:Create(element.Element, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
        elseif element.Type == 'Text' then
            element.Element.TextTransparency = 1
            TweenService:Create(element.Element, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
        elseif element.Type == 'Image' then
            element.Element.ImageTransparency = 1
            TweenService:Create(element.Element, TweenInfo.new(0.5), {ImageTransparency = 0}):Play()
        end
    end
end

function RadiantUI:FadeOut()
    local elements = self:GetAllFadeableElements()
    
    for _, element in pairs(elements) do
        if element.Type == 'Frame' then
            TweenService:Create(element.Element, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        elseif element.Type == 'Text' then
            TweenService:Create(element.Element, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        elseif element.Type == 'Image' then
            TweenService:Create(element.Element, TweenInfo.new(0.4), {ImageTransparency = 1}):Play()
        end
    end
end

function RadiantUI:GetAllFadeableElements()
    local elements = {}
    
    table.insert(elements, {Type = 'Frame', Element = self.MainFrame})
    table.insert(elements, {Type = 'Frame', Element = self.HeaderFrame})
    table.insert(elements, {Type = 'Text', Element = self.TitleLabel})
    
    local function addChildElements(parent)
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA('Frame') then
                table.insert(elements, {Type = 'Frame', Element = child})
            elseif child:IsA('TextLabel') or child:IsA('TextButton') then
                table.insert(elements, {Type = 'Text', Element = child})
            elseif child:IsA('ImageLabel') then
                table.insert(elements, {Type = 'Image', Element = child})
            end
            addChildElements(child)
        end
    end
    
    addChildElements(self.MainFrame)
    return elements
end

function RadiantUI:ShowNotification(text, duration)
    if not self.Config.EnableNotifications then return end
    
    duration = duration or 5
    
    local notification = Instance.new('Frame')
    notification.Size = UDim2.new(0, 400, 0, 85)
    notification.Position = UDim2.new(1, 50, 1, -120 - (#self.Notifications * 95))
    notification.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    notification.BorderSizePixel = 0
    notification.Parent = self.ScreenGui
    notification.ZIndex = 200
    
    local notifCorner = Instance.new('UICorner')
    notifCorner.CornerRadius = UDim.new(0, 16)
    notifCorner.Parent = notification
    
    local notifText = Instance.new('TextLabel')
    notifText.Size = UDim2.new(1, -40, 1, -20)
    notifText.Position = UDim2.new(0, 20, 0, 10)
    notifText.BackgroundTransparency = 1
    notifText.Text = text
    notifText.TextColor3 = Color3.fromRGB(245, 245, 245)
    notifText.TextSize = 16
    notifText.Font = Enum.Font.GothamMedium
    notifText.TextWrapped = true
    notifText.TextXAlignment = Enum.TextXAlignment.Center
    notifText.TextYAlignment = Enum.TextYAlignment.Center
    notifText.Parent = notification
    
    local progressBg = Instance.new('Frame')
    progressBg.Size = UDim2.new(1, -40, 0, 4)
    progressBg.Position = UDim2.new(0, 20, 1, -12)
    progressBg.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    progressBg.BorderSizePixel = 0
    progressBg.Parent = notification
    
    local progressBar = Instance.new('Frame')
    progressBar.Size = UDim2.new(1, 0, 1, 0)
    progressBar.BackgroundColor3 = self.Config.Theme.Primary
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressBg
    
    table.insert(self.Notifications, notification)
    
    local targetPos = UDim2.new(1, -420, 1, -120 - ((#self.Notifications - 1) * 95))
    TweenService:Create(notification, TweenInfo.new(0.6, Enum.EasingStyle.Quart), {Position = targetPos}):Play()
    
    TweenService:Create(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)}):Play()
    
    spawn(function()
        wait(duration)
        self:DismissNotification(notification)
    end)
    
    local clickDetector = Instance.new('TextButton')
    clickDetector.Size = UDim2.new(1, 0, 1, 0)
    clickDetector.BackgroundTransparency = 1
    clickDetector.Text = ''
    clickDetector.Parent = notification
    
    clickDetector.MouseButton1Click:Connect(function()
        self:DismissNotification(notification)
    end)
end

function RadiantUI:DismissNotification(notification)
    for i, notif in ipairs(self.Notifications) do
        if notif == notification then
            table.remove(self.Notifications, i)
            break
        end
    end
    
    TweenService:Create(notification, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {
        Position = UDim2.new(1, 50, notification.Position.Y.Scale, notification.Position.Y.Offset)
    }):Play()
    
    for i, notif in ipairs(self.Notifications) do
        local newPos = UDim2.new(1, -420, 1, -120 - ((i - 1) * 95))
        TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = newPos}):Play()
    end
    
    spawn(function()
        wait(0.4)
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
        FadeAnimations = self.Config.FadeAnimations,
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
    if config.FadeAnimations ~= nil then self.Config.FadeAnimations = config.FadeAnimations end
    
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
        if self.Config.FadeAnimations then
            self:FadeOut()
            spawn(function()
                wait(0.5)
                self.ScreenGui:Destroy()
            end)
        else
            self.ScreenGui:Destroy()
        end
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
    if self.Config.FadeAnimations then
        if visible then
            self.MainFrame.Visible = true
            self:FadeIn()
        else
            self:FadeOut()
            spawn(function()
                wait(0.5)
                if not self.GuiVisible then
                    self.MainFrame.Visible = false
                end
            end)
        end
    else
        self.MainFrame.Visible = visible
        if self.WatermarkFrame then
            self.WatermarkFrame.Visible = visible and self.Config.ShowWatermark
        end
    end
end

function RadiantUI:IsVisible()
    return self.GuiVisible
end

-- Export the library
_G.RadiantUI = RadiantUI
return RadiantUI

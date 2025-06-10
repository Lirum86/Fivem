-- VOLLSTÄNDIG KORRIGIERTES CONFIG SYSTEM
-- Alle Fehler behoben: Notifications, Dropdown, Methodenaufrufe

local ConfigManager = {}
ConfigManager.__index = ConfigManager

local HttpService = game:GetService('HttpService')

function ConfigManager.new(hubInstance)
    local self = setmetatable({}, ConfigManager)
    self.hubInstance = hubInstance
    self.configFolder = 'RadiantHub_Configs'
    self.httpService = HttpService
    self.currentConfig = 'default'
    self.autoLoadConfig = nil
    
    -- Verzögerte Initialisierung mit mehreren Versuchen
    task.spawn(function()
        local attempts = 0
        while attempts < 10 do
            if hubInstance and hubInstance.notifications then
                task.wait(0.5)
                self:initializeConfigSystem()
                break
            end
            task.wait(0.2)
            attempts = attempts + 1
        end
    end)
    
    return self
end

-- KORRIGIERTE safeNotify Funktion
function ConfigManager:safeNotify(notifType, title, message, duration)
    duration = duration or 3
    
    -- Robuste Überprüfung der Notification-Verfügbarkeit
    local success = pcall(function()
        if self.hubInstance and 
           self.hubInstance.notifications and 
           type(self.hubInstance.notifications) == "table" then
            
            -- Versuche die spezifische Notification-Methode zu finden
            local method = self.hubInstance.notifications[notifType]
            
            if method and type(method) == "function" then
                -- Sichere Ausführung der Notification
                method(self.hubInstance.notifications, title, message, duration)
                return true
            end
        end
        return false
    end)
    
    -- Fallback zu print wenn Notifications nicht verfügbar oder fehlgeschlagen
    if not success then
        print('[' .. string.upper(notifType) .. '] ' .. title .. ': ' .. message)
    end
end

function ConfigManager:initializeConfigSystem()
    if not isfolder or not makefolder then
        self:safeNotify('error', 'File System Error', 'File system functions not available!', 5)
        return false
    end
    
    if not isfolder(self.configFolder) then
        makefolder(self.configFolder)
        self:safeNotify('info', 'Config System', 'Created config folder: ' .. self.configFolder, 3)
    end
    
    if not isfile(self.configFolder .. '/default.json') then
        self:createDefaultConfig()
    end
    
    task.delay(2, function()
        self:checkAutoLoad()
    end)
    
    return true
end

function ConfigManager:createDefaultConfig()
    local defaultSettings = {
        metadata = {
            version = "2.1",
            created = tick(),
            description = "Default RadiantHub configuration",
            creator = game.Players.LocalPlayer.Name
        },
        globalSettings = {
            menuToggleKey = "RightShift",
            watermarkVisible = true
        },
        tabs = {}
    }
    
    local success, error = pcall(function()
        local jsonString = self.httpService:JSONEncode(defaultSettings)
        writefile(self.configFolder .. '/default.json', jsonString)
    end)
    
    if success then
        self:safeNotify('success', 'Default Config', 'Default configuration created!', 3)
    else
        self:safeNotify('error', 'Config Error', 'Failed to create default config', 4)
    end
end

function ConfigManager:validateConfigName(name)
    if not name or name == '' then
        return false, 'Config name cannot be empty'
    end
    
    if #name > 50 then
        return false, 'Config name too long (max 50 characters)'
    end
    
    if name:match('[<>:"/\\|?*]') then
        return false, 'Config name contains invalid characters'
    end
    
    local reserved = {'con', 'prn', 'aux', 'nul'}
    for _, word in ipairs(reserved) do
        if name:lower() == word then
            return false, 'Config name is a reserved system name'
        end
    end
    
    return true, 'Valid name'
end

function ConfigManager:createNewConfig(configName)
    local isValid, errorMsg = self:validateConfigName(configName)
    
    if not isValid then
        self:safeNotify('error', 'Invalid Name', errorMsg, 4)
        return false
    end
    
    local filePath = self.configFolder .. '/' .. configName .. '.json'
    if isfile(filePath) then
        self:safeNotify('warning', 'Config Exists', 'Config "' .. configName .. '" already exists!', 4)
        return false
    end
    
    local success = self:saveConfig(configName)
    
    if success then
        task.wait(0.1) -- Kurze Pause für file system
        self:updateConfigList()
        self:safeNotify('success', 'Config Created', 'Configuration "' .. configName .. '" created!', 4)
    end
    
    return success
end

function ConfigManager:saveConfig(configName)
    if not configName or configName == '' then
        self:safeNotify('error', 'Invalid Name', 'Config name cannot be empty!', 3)
        return false
    end
    
    local success, result = pcall(function()
        if not self.hubInstance or not self.hubInstance.gatherAllSettings then
            error('Hub instance not available or missing gatherAllSettings method')
        end
        
        local settings = self.hubInstance:gatherAllSettings()
        
        local configData = {
            name = configName,
            settings = settings,
            metadata = {
                version = "2.1",
                created = isfile(self.configFolder .. '/' .. configName .. '.json') and 
                         (self:getConfigMetadata(configName) and self:getConfigMetadata(configName).created) or tick(),
                lastModified = tick(),
                creator = game.Players.LocalPlayer.Name,
                description = "RadiantHub configuration: " .. configName
            }
        }
        
        local jsonString = self.httpService:JSONEncode(configData)
        local filePath = self.configFolder .. '/' .. configName .. '.json'
        writefile(filePath, jsonString)
        
        return true
    end)
    
    if success then
        self.currentConfig = configName
        self:updateConfigList()
        self:safeNotify('success', 'Config Saved', 'Configuration "' .. configName .. '" saved!', 3)
        return true
    else
        self:safeNotify('error', 'Save Failed', 'Failed to save config: ' .. tostring(result), 4)
        return false
    end
end

function ConfigManager:loadConfig(configName)
    if not configName or configName == '' then
        self:safeNotify('error', 'Invalid Config', 'No config name provided!', 3)
        return false
    end
    
    local filePath = self.configFolder .. '/' .. configName .. '.json'
    
    if not isfile(filePath) then
        self:safeNotify('error', 'Config Not Found', 'Configuration "' .. configName .. '" does not exist!', 4)
        return false
    end
    
    local success, result = pcall(function()
        local fileContent = readfile(filePath)
        local configData = self.httpService:JSONDecode(fileContent)
        
        if not configData.settings then
            error('Invalid config format: missing settings')
        end
        
        return configData
    end)
    
    if success and result then
        local applySuccess = false
        
        if self.hubInstance and self.hubInstance.applySettings then
            applySuccess = self.hubInstance:applySettings(result.settings)
        end
        
        if applySuccess then
            self.currentConfig = configName
            
            -- KORRIGIERTE Dropdown-Update (kein FindFirstChild auf table)
            if self.hubInstance and 
               self.hubInstance.configDropdown and 
               type(self.hubInstance.configDropdown) == "table" then
                
                pcall(function()
                    self.hubInstance.configDropdown.selectedValue = configName
                    if self.hubInstance.configDropdown.selected then
                        self.hubInstance.configDropdown.selected.Text = configName
                    end
                end)
            end
            
            self:safeNotify('success', 'Config Loaded', 'Configuration "' .. configName .. '" loaded!', 4)
            return true
        else
            self:safeNotify('error', 'Apply Failed', 'Failed to apply settings from "' .. configName .. '"!', 4)
            return false
        end
    else
        self:safeNotify('error', 'Load Failed', 'Failed to load config: ' .. tostring(result), 4)
        return false
    end
end

function ConfigManager:deleteConfig(configName)
    if configName == 'default' then
        self:safeNotify('error', 'Cannot Delete', 'The default config cannot be deleted!', 3)
        return false
    end
    
    if not configName or configName == '' then
        self:safeNotify('error', 'Invalid Config', 'No config name provided!', 3)
        return false
    end
    
    local filePath = self.configFolder .. '/' .. configName .. '.json'
    
    if not isfile(filePath) then
        self:safeNotify('error', 'Config Not Found', 'Config "' .. configName .. '" does not exist!', 3)
        return false
    end
    
    local success, error = pcall(function()
        delfile(filePath)
    end)
    
    if success then
        if self.autoLoadConfig == configName then
            self:setAutoLoad(nil)
        end
        
        if self.currentConfig == configName then
            self.currentConfig = 'default'
            self:loadConfig('default')
        end
        
        self:updateConfigList()
        self:safeNotify('success', 'Config Deleted', 'Configuration "' .. configName .. '" deleted!', 3)
        return true
    else
        self:safeNotify('error', 'Delete Failed', 'Failed to delete config', 4)
        return false
    end
end

function ConfigManager:getConfigList()
    local configs = {}
    
    if not isfolder(self.configFolder) then
        return {'default'}
    end
    
    local success, files = pcall(function()
        return listfiles(self.configFolder)
    end)
    
    if success and files then
        for _, filePath in ipairs(files) do
            local fileName = filePath:match('([^/\\]+)%.json$')
            if fileName and fileName ~= 'autoload' then -- Ignore autoload.txt
                table.insert(configs, fileName)
            end
        end
    end
    
    -- Ensure default is first
    local hasDefault = false
    for i, config in ipairs(configs) do
        if config == 'default' then
            table.remove(configs, i)
            hasDefault = true
            break
        end
    end
    
    table.sort(configs) -- Sort others alphabetically
    table.insert(configs, 1, 'default') -- Insert default at beginning
    
    return configs
end

-- KORRIGIERTE updateConfigList Funktion
function ConfigManager:updateConfigList()
    if not (self.hubInstance and 
            self.hubInstance.configDropdown and 
            type(self.hubInstance.configDropdown) == "table") then
        return
    end
    
    local success, configs = pcall(function()
        return self:getConfigList()
    end)
    
    if success and configs then
        pcall(function()
            -- Sichere Ausführung der updateOptions Methode
            if self.hubInstance.configDropdown.updateOptions and 
               type(self.hubInstance.configDropdown.updateOptions) == "function" then
                
                self.hubInstance.configDropdown:updateOptions(configs)
                
                -- Update selection
                if table.find(configs, self.currentConfig) then
                    self.hubInstance.configDropdown.selectedValue = self.currentConfig
                    if self.hubInstance.configDropdown.selected then
                        self.hubInstance.configDropdown.selected.Text = self.currentConfig
                    end
                end
            end
        end)
    end
end

function ConfigManager:setAutoLoad(configName)
    local autoLoadFile = self.configFolder .. '/autoload.txt'
    
    if configName and configName ~= '' then
        local configFile = self.configFolder .. '/' .. configName .. '.json'
        if not isfile(configFile) then
            self:safeNotify('error', 'Config Not Found', 'Cannot set autoload: Config "' .. configName .. '" does not exist!', 4)
            return false
        end
        
        local success = pcall(function()
            writefile(autoLoadFile, configName)
        end)
        
        if success then
            self.autoLoadConfig = configName
            self:safeNotify('success', 'AutoLoad Set', 'Config "' .. configName .. '" will auto-load on startup', 4)
            return true
        else
            self:safeNotify('error', 'AutoLoad Failed', 'Failed to set autoload', 4)
            return false
        end
    else
        local success = pcall(function()
            if isfile(autoLoadFile) then
                delfile(autoLoadFile)
            end
        end)
        
        if success then
            self.autoLoadConfig = nil
            self:safeNotify('info', 'AutoLoad Disabled', 'Automatic config loading disabled', 3)
            return true
        else
            self:safeNotify('error', 'AutoLoad Failed', 'Failed to disable autoload', 4)
            return false
        end
    end
end

function ConfigManager:checkAutoLoad()
    local autoLoadFile = self.configFolder .. '/autoload.txt'
    
    if not isfile(autoLoadFile) then
        return false
    end
    
    local success, configName = pcall(function()
        return readfile(autoLoadFile)
    end)
    
    if success and configName and configName ~= '' then
        local configFile = self.configFolder .. '/' .. configName .. '.json'
        if not isfile(configFile) then
            self:safeNotify('warning', 'AutoLoad Error', 'AutoLoad config "' .. configName .. '" not found. Disabled autoload.', 4)
            self:setAutoLoad(nil)
            return false
        end
        
        self:safeNotify('info', 'AutoLoad Active', 'Loading config "' .. configName .. '"...', 3)
        
        task.wait(0.5)
        return self:loadConfig(configName)
    end
    
    return false
end

function ConfigManager:getConfigMetadata(configName)
    local filePath = self.configFolder .. '/' .. configName .. '.json'
    
    if not isfile(filePath) then
        return nil
    end
    
    local success, result = pcall(function()
        local fileContent = readfile(filePath)
        local configData = self.httpService:JSONDecode(fileContent)
        return configData.metadata
    end)
    
    return success and result or nil
end

function ConfigManager:exportConfig(configName, exportPath)
    local filePath = self.configFolder .. '/' .. configName .. '.json'
    
    if not isfile(filePath) then
        self:safeNotify('error', 'Export Failed', 'Config "' .. configName .. '" does not exist!', 3)
        return false
    end
    
    local success = pcall(function()
        local content = readfile(filePath)
        writefile(exportPath, content)
    end)
    
    if success then
        self:safeNotify('success', 'Export Success', 'Config exported to: ' .. exportPath, 4)
        return true
    else
        self:safeNotify('error', 'Export Failed', 'Failed to export config', 4)
        return false
    end
end

function ConfigManager:importConfig(importPath, newConfigName)
    if not isfile(importPath) then
        self:safeNotify('error', 'Import Failed', 'Import file does not exist!', 3)
        return false
    end
    
    local isValid, errorMsg = self:validateConfigName(newConfigName)
    if not isValid then
        self:safeNotify('error', 'Invalid Name', errorMsg, 4)
        return false
    end
    
    local success = pcall(function()
        local content = readfile(importPath)
        local configData = self.httpService:JSONDecode(content)
        
        if not configData.settings then
            error('Invalid config format')
        end
        
        configData.name = newConfigName
        configData.metadata = configData.metadata or {}
        configData.metadata.imported = tick()
        configData.metadata.originalName = configData.name
        
        local jsonString = self.httpService:JSONEncode(configData)
        writefile(self.configFolder .. '/' .. newConfigName .. '.json', jsonString)
        
        return true
    end)
    
    if success then
        self:updateConfigList()
        self:safeNotify('success', 'Import Success', 'Config "' .. newConfigName .. '" imported!', 4)
        return true
    else
        self:safeNotify('error', 'Import Failed', 'Failed to import config', 4)
        return false
    end
end

function ConfigManager:destroy()
    self.hubInstance = nil
    self.configManager = nil
end

return ConfigManager

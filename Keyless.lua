local player = game.Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

getgenv().MasterScriptID = tick()
local myScriptID = getgenv().MasterScriptID

local function getUIFolder()
    if gethui then return gethui() end
    return game:GetService("CoreGui")
end

for _, gui in pairs(player.PlayerGui:GetChildren()) do
    if string.match(gui.Name, "FarmUI") or string.match(gui.Name, "MasterFarmUI") then
        gui:Destroy()
    end
end

local configFileName = "MasterFarm_Config.json"

local function loadSettings()
    if readfile and isfile and isfile(configFileName) then
        local success, json = pcall(function() return readfile(configFileName) end)
        if success then
            local data = HttpService:JSONDecode(json)
            getgenv().generalFarmActive = data.generalFarmActive or false
            getgenv().trialFarmActive = data.trialFarmActive or false
            getgenv().runeFarmActive = data.runeFarmActive or false
            getgenv().autoChestActive = data.autoChestActive or false
            getgenv().autoBossActive = data.autoBossActive or false
            getgenv().autoTierRoll = data.autoTierRoll or false
            getgenv().autoRuneRoll = data.autoRuneRoll or false
            getgenv().indexFarmActive = data.indexFarmActive or false
            getgenv().autoNearbyUpgrades = data.autoNearbyUpgrades or false
            getgenv().trialDifficulty = data.trialDifficulty or "Hard"
            getgenv().trialWaveLimit = data.trialWaveLimit or 38
            getgenv().uiScale = data.uiScale or 1
            getgenv().afkModeEnabled = data.afkModeEnabled or false
            getgenv().afkFpsCap = data.afkFpsCap or 10
            getgenv().normalFpsCap = data.normalFpsCap or 60
            getgenv().categoryToggles = data.categoryToggles or {Stars=false,SpacePoints=false,Moon=false,PlanetsUpgrades=false,Knowledge=false,AlienCash=false,Blackholes=false}
            getgenv().selectedSpecificUpgrades = data.selectedSpecificUpgrades or {Stars={},SpacePoints={},Moon={},PlanetsUpgrades={},Knowledge={},AlienCash={},Blackholes={},PlanetsList={}}
            getgenv().selectedMobNames = data.selectedMobNames or {}
        else
            getgenv().generalFarmActive = false 
            getgenv().trialFarmActive = false
            getgenv().runeFarmActive = false
            getgenv().autoChestActive = false
            getgenv().autoBossActive = false
            getgenv().autoTierRoll = false
            getgenv().autoRuneRoll = false
            getgenv().indexFarmActive = false
            getgenv().autoNearbyUpgrades = false
            getgenv().trialDifficulty = "Hard"
            getgenv().trialWaveLimit = 38
            getgenv().uiScale = 1
            getgenv().afkModeEnabled = false
            getgenv().afkFpsCap = 10
            getgenv().normalFpsCap = 60
            getgenv().categoryToggles = {Stars=false,SpacePoints=false,Moon=false,PlanetsUpgrades=false,Knowledge=false,AlienCash=false,Blackholes=false}
            getgenv().selectedSpecificUpgrades = {Stars={},SpacePoints={},Moon={},PlanetsUpgrades={},Knowledge={},AlienCash={},Blackholes={},PlanetsList={}}
            getgenv().selectedMobNames = {}
        end
    else
        getgenv().generalFarmActive = false 
        getgenv().trialFarmActive = false
        getgenv().runeFarmActive = false
        getgenv().autoChestActive = false
        getgenv().autoBossActive = false
        getgenv().autoTierRoll = false
        getgenv().autoRuneRoll = false
        getgenv().indexFarmActive = false
        getgenv().autoNearbyUpgrades = false
        getgenv().trialDifficulty = "Hard"
        getgenv().trialWaveLimit = 38
        getgenv().uiScale = 1
        getgenv().afkModeEnabled = false
        getgenv().afkFpsCap = 10
        getgenv().normalFpsCap = 60
        getgenv().categoryToggles = {Stars=false,SpacePoints=false,Moon=false,PlanetsUpgrades=false,Knowledge=false,AlienCash=false,Blackholes=false}
        getgenv().selectedSpecificUpgrades = {Stars={},SpacePoints={},Moon={},PlanetsUpgrades={},Knowledge={},AlienCash={},Blackholes={},PlanetsList={}}
        getgenv().selectedMobNames = {}
    end
end

local function saveSettings()
    local dataToSave = {
        generalFarmActive = getgenv().generalFarmActive,
        trialFarmActive = getgenv().trialFarmActive,
        runeFarmActive = getgenv().runeFarmActive,
        autoChestActive = getgenv().autoChestActive,
        autoBossActive = getgenv().autoBossActive,
        autoTierRoll = getgenv().autoTierRoll,
        autoRuneRoll = getgenv().autoRuneRoll,
        indexFarmActive = getgenv().indexFarmActive,
        autoNearbyUpgrades = getgenv().autoNearbyUpgrades,
        trialDifficulty = getgenv().trialDifficulty,
        trialWaveLimit = getgenv().trialWaveLimit,
        uiScale = getgenv().uiScale,
        afkModeEnabled = getgenv().afkModeEnabled,
        afkFpsCap = getgenv().afkFpsCap,
        normalFpsCap = getgenv().normalFpsCap,
        categoryToggles = getgenv().categoryToggles,
        selectedSpecificUpgrades = getgenv().selectedSpecificUpgrades,
        selectedMobNames = getgenv().selectedMobNames
    }
    if writefile then
        pcall(function()
            local json = HttpService:JSONEncode(dataToSave)
            writefile(configFileName, json)
        end)
    end
end

loadSettings()

local trialBlackList = {} 
getgenv().farmState = "IDLE"
getgenv().savedWorldPos = nil 
getgenv().runeLocation = nil 
getgenv().inTrial = false 
getgenv().isSummaryScreenOpen = false
local maxDistance = 3000 
local lastPortalAttempt = 0 

local function applyAfkSettings()
    local cg = getUIFolder()
    if getgenv().afkModeEnabled then
        RunService:Set3dRenderingEnabled(false)
        if setfpscap then setfpscap(getgenv().afkFpsCap) end
        
        if not cg:FindFirstChild("MasterAFKScreen") then
            local sg = Instance.new("ScreenGui")
            sg.Name = "MasterAFKScreen"
            sg.IgnoreGuiInset = true
            sg.DisplayOrder = 999999
            sg.Parent = cg
            
            local bg = Instance.new("Frame")
            bg.Size = UDim2.new(1, 0, 1, 0)
            bg.BackgroundColor3 = Color3.new(0, 0, 0)
            bg.Parent = sg
            
            local txt = Instance.new("TextLabel")
            txt.Size = UDim2.new(1, 0, 1, 0)
            txt.Text = "AFK MODE ACTIVE\n3D Rendering Disabled"
            txt.TextColor3 = Color3.new(1, 1, 1)
            txt.BackgroundTransparency = 1
            txt.TextSize = 24
            txt.Font = Enum.Font.SourceSansBold
            txt.Parent = bg
        end
    else
        RunService:Set3dRenderingEnabled(true)
        if setfpscap then setfpscap(getgenv().normalFpsCap) end
        if cg:FindFirstChild("MasterAFKScreen") then
            cg.MasterAFKScreen:Destroy()
        end
    end
end

applyAfkSettings()

local maclib_code = nil
local links_to_try = {
    "https://github.com/biggaboy212/Maclib/releases/latest/download/maclib.txt",
    "https://raw.githubusercontent.com/biggaboy212/Maclib/main/maclib.lua",
    "https://raw.githubusercontent.com/x2Swiftz/UI-Library/main/maclib.txt"
}

for _, link in ipairs(links_to_try) do
    local success, result = pcall(function()
        return game:HttpGet(link)
    end)
    if success and result and not string.match(result, "404: Not Found") then
        maclib_code = result
        break
    end
end

if not maclib_code then
    player:Kick("Maclib library not found! GitHub links might be down.")
    return
end

local Maclib = loadstring(maclib_code)()

local Window = Maclib:Window({
    Title = "Master Farm Hub",
    Subtitle = "Tester Edition",
    Size = UDim2.fromOffset(868, 650),
    DragSpace = 50,
    Color = Color3.fromRGB(138, 43, 226), 
})

local function updateScriptUIScale(scaleVal)
    pcall(function()
        local uiFolder = getUIFolder()
        for _, screenGui in pairs(uiFolder:GetChildren()) do
            if screenGui:IsA("ScreenGui") then
                local isOurs = false
                for _, desc in pairs(screenGui:GetDescendants()) do
                    if desc:IsA("TextLabel") and (desc.Text == "Master Farm Hub" or desc.Text == "Tester Edition") then
                        isOurs = true
                        break
                    end
                end
                
                if isOurs then
                    for _, child in pairs(screenGui:GetChildren()) do
                        if child:IsA("GuiObject") then
                            local scaleObj = child:FindFirstChildWhichIsA("UIScale")
                            if not scaleObj then
                                scaleObj = Instance.new("UIScale")
                                scaleObj.Parent = child
                            end
                            scaleObj.Scale = scaleVal
                        end
                    end
                end
            end
        end
    end)
end

task.spawn(function()
    task.wait(2)
    updateScriptUIScale(getgenv().uiScale)
end)

local TabGroup = Window:TabGroup()

local TabFarm = TabGroup:Tab({ Name = "Combat & Farm", Image = "lucide-swords" })
local TabCollect = TabGroup:Tab({ Name = "Collectors", Image = "lucide-box" })
local TabUpgrade = TabGroup:Tab({ Name = "Upgrades", Image = "lucide-zap" })
local TabMisc = TabGroup:Tab({ Name = "Misc", Image = "lucide-settings" })

local FarmSection = TabFarm:Section({ Side = "Left" })

FarmSection:Toggle({
    Name = "Mob Farm",
    Default = getgenv().generalFarmActive,
    Callback = function(Value)
        getgenv().generalFarmActive = Value
        saveSettings()
    end,
})

FarmSection:Toggle({
    Name = "Trial Farm (Auto Enter/Leave)",
    Default = getgenv().trialFarmActive,
    Callback = function(Value)
        getgenv().trialFarmActive = Value
        saveSettings()
    end,
})

FarmSection:Dropdown({
    Name = "Trial Difficulty",
    Options = {"Easy", "Medium", "Hard"},
    Default = getgenv().trialDifficulty,
    Callback = function(Value)
        getgenv().trialDifficulty = Value
        saveSettings()
    end,
})

FarmSection:Slider({
    Name = "Leave Wave Limit",
    Default = getgenv().trialWaveLimit,
    Minimum = 1,
    Maximum = 100,
    Step = 1,
    DisplayMethod = "Value",
    Callback = function(Value)
        local val = math.clamp(math.floor(tonumber(Value) or 38), 1, 100)
        getgenv().trialWaveLimit = val
        saveSettings()
    end,
})

FarmSection:Toggle({
    Name = "Rune AFK (Locks to Current Position)",
    Default = getgenv().runeFarmActive,
    Callback = function(Value)
        getgenv().runeFarmActive = Value
        if Value then
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then getgenv().runeLocation = hrp.CFrame end
        end
        saveSettings()
    end,
})

local IndexSection = TabFarm:Section({ Side = "Right" })

IndexSection:Toggle({
    Name = "Index Farm (Selectable Mobs)",
    Default = getgenv().indexFarmActive,
    Callback = function(Value)
        getgenv().indexFarmActive = Value
        saveSettings()
    end,
})

local mobDropdownInput = ""
IndexSection:Input({
    Name = "Add/Remove Mob Name",
    Placeholder = "Enter exact mob name...",
    Callback = function(Text)
        mobDropdownInput = Text
    end,
})

IndexSection:Button({
    Name = "Add Mob to Farm List",
    Callback = function()
        if mobDropdownInput and mobDropdownInput ~= "" then
            getgenv().selectedMobNames[string.lower(mobDropdownInput)] = true
            saveSettings()
        end
    end,
})

IndexSection:Button({
    Name = "Clear Selected Mobs List",
    Callback = function()
        getgenv().selectedMobNames = {}
        saveSettings()
    end,
})

local CollectSection = TabCollect:Section({ Side = "Left" })

CollectSection:Toggle({
    Name = "Auto Chest/Capsule",
    Default = getgenv().autoChestActive,
    Callback = function(Value)
        getgenv().autoChestActive = Value
        saveSettings()
    end,
})

CollectSection:Toggle({
    Name = "Auto Tier Roll (Phantom Lock)",
    Default = getgenv().autoTierRoll,
    Callback = function(Value)
        getgenv().autoTierRoll = Value
        saveSettings()
    end,
})

CollectSection:Toggle({
    Name = "Auto Rune Roll (Phantom Lock)",
    Default = getgenv().autoRuneRoll,
    Callback = function(Value)
        getgenv().autoRuneRoll = Value
        saveSettings()
    end,
})

CollectSection:Toggle({
    Name = "Auto Realm 3 Boss Spawn",
    Default = getgenv().autoBossActive,
    Callback = function(Value)
        getgenv().autoBossActive = Value
        saveSettings()
    end,
})

local generalUpgradeList = {
    Stars = { "MoreStars", "EvenMoreStars", "MoreSpacePoints", "FasterRespawn", "Oof", "BoostStarsMutationLuck" },
    SpacePoints = { "MoreSpacePoints", "MultiStar", "BoostStarsCollectRadius", "MoreMoon", "Blackholes" },
    Moon = { "MoreMoon", "BoostStars", "MoreSpaceXP", "MorePlanets", "EvenMoreStars" },
    PlanetsUpgrades = { "MorePlanets", "MoreStars", "MorePoints", "Heatetheplanet", "Oofs", "Blackholes" },
    Knowledge = { "MoreKnowledge", "BoostSpaceXP", "MoreAlienCash" },
    AlienCash = { "MoreAlienCash", "MoreAlienXP", "BoostAlienMutationLuck", "Blackholes" },
    Blackholes = { "MoreBlackholes", "Planet", "FasterRespawn", "Oofs", "Aliencash" }
}
local planetList = { "Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune" }

local UpgradeSectionLeft = TabUpgrade:Section({ Side = "Left" })
local UpgradeSectionRight = TabUpgrade:Section({ Side = "Right" })

UpgradeSectionLeft:Toggle({
    Name = "Auto Max ALL Nearby Upgrades (W1/W2/W3)",
    Default = getgenv().autoNearbyUpgrades,
    Callback = function(Value)
        getgenv().autoNearbyUpgrades = Value
        saveSettings()
    end,
})

local categoryKeys = {"Stars", "SpacePoints", "Moon", "PlanetsUpgrades", "Knowledge", "AlienCash", "Blackholes"}

for i, category in ipairs(categoryKeys) do
    local targetSection = (i % 2 == 1) and UpgradeSectionLeft or UpgradeSectionRight
    local displayName = category
    if category == "PlanetsUpgrades" then displayName = "Planets" end

    targetSection:Toggle({
        Name = "Auto " .. displayName,
        Default = getgenv().categoryToggles[category],
        Callback = function(Value)
            getgenv().categoryToggles[category] = Value
            saveSettings()
        end,
    })

    local defaultSelections = {}
    if getgenv().selectedSpecificUpgrades[category] then
        for k, v in pairs(getgenv().selectedSpecificUpgrades[category]) do
            if v == true and type(k) == "string" then
                table.insert(defaultSelections, k)
            end
        end
    end

    targetSection:Dropdown({
        Name = displayName .. " Sub-Upgrades",
        Multi = true,
        Options = generalUpgradeList[category],
        Default = defaultSelections,
        Callback = function(Selected)
            local dict = {}
            if type(Selected) == "table" then
                for k, v in pairs(Selected) do
                    if type(k) == "number" and type(v) == "string" then
                        dict[v] = true
                    elseif type(k) == "string" and v == true then
                        dict[k] = true
                    end
                end
            end
            getgenv().selectedSpecificUpgrades[category] = dict
            saveSettings()
        end,
    })
    
    if category == "PlanetsUpgrades" then
        local planetDefaults = {}
        if getgenv().selectedSpecificUpgrades.PlanetsList then
            for k, v in pairs(getgenv().selectedSpecificUpgrades.PlanetsList) do
                if v == true and type(k) == "string" then
                    table.insert(planetDefaults, k)
                end
            end
        end

        targetSection:Dropdown({
            Name = "Unlock Planets (Purchase)",
            Multi = true,
            Options = planetList,
            Default = planetDefaults,
            Callback = function(Selected)
                local dict = {}
                if type(Selected) == "table" then
                    for k, v in pairs(Selected) do
                        if type(k) == "number" and type(v) == "string" then
                            dict[v] = true
                        elseif type(k) == "string" and v == true then
                            dict[k] = true
                        end
                    end
                end
                getgenv().selectedSpecificUpgrades.PlanetsList = dict
                saveSettings()
            end,
        })
    end
end

local UtilsSection = TabMisc:Section({ Side = "Left" })

UtilsSection:Toggle({
    Name = "AFK Mode (Disable 3D Render)",
    Default = getgenv().afkModeEnabled,
    Callback = function(Value)
        getgenv().afkModeEnabled = Value
        saveSettings()
        applyAfkSettings()
    end,
})

UtilsSection:Slider({
    Name = "AFK FPS Cap",
    Default = getgenv().afkFpsCap,
    Minimum = 1,
    Maximum = 60,
    Step = 1,
    DisplayMethod = "Value",
    Callback = function(Value)
        local val = math.clamp(math.floor(tonumber(Value) or 10), 1, 60)
        getgenv().afkFpsCap = val
        saveSettings()
        if getgenv().afkModeEnabled and setfpscap then
            setfpscap(val)
        end
    end,
})

UtilsSection:Slider({
    Name = "Normal FPS Cap",
    Default = getgenv().normalFpsCap,
    Minimum = 30,
    Maximum = 240,
    Step = 1,
    DisplayMethod = "Value",
    Callback = function(Value)
        local val = math.clamp(math.floor(tonumber(Value) or 60), 30, 240)
        getgenv().normalFpsCap = val
        saveSettings()
        if not getgenv().afkModeEnabled and setfpscap then
            setfpscap(val)
        end
    end,
})

UtilsSection:Slider({
    Name = "Script Menu Size (%)",
    Default = math.floor(getgenv().uiScale * 100),
    Minimum = 50,
    Maximum = 150,
    Step = 1,
    DisplayMethod = "Value",
    Callback = function(Value)
        local val = math.clamp(math.floor(tonumber(Value) or 100), 50, 150)
        getgenv().uiScale = val / 100
        saveSettings()
        updateScriptUIScale(getgenv().uiScale)
    end,
})

UtilsSection:Button({
    Name = "Rejoin Server",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
    end,
})

UtilsSection:Button({
    Name = "Destroy UI",
    Callback = function()
        getgenv().MasterScriptID = 0 
        local cg = getUIFolder()
        if cg:FindFirstChild("MasterAFKScreen") then
            cg.MasterAFKScreen:Destroy()
        end
        RunService:Set3dRenderingEnabled(true)
        if setfpscap then setfpscap(getgenv().normalFpsCap) end
        
        for _, child in pairs(cg:GetChildren()) do
            if child:IsA("ScreenGui") then
                for _, desc in pairs(child:GetDescendants()) do
                    if desc:IsA("TextLabel") and (desc.Text == "Master Farm Hub" or desc.Text == "Tester Edition") then
                        child:Destroy()
                        break
                    end
                end
            end
        end
        for _, gui in pairs(player.PlayerGui:GetChildren()) do
            if string.match(gui.Name, "FarmUI") or string.match(gui.Name, "MasterFarmUI") then
                gui:Destroy()
            end
        end
    end,
})

local function isGuiVisible(gui)
    local current = gui
    while current and current:IsA("GuiObject") do
        if not current.Visible then return false end
        current = current.Parent
    end
    return true
end

local function forceClick(btn)
    if not btn then return end
    pcall(function()
        if getconnections then
            for _, conn in pairs(getconnections(btn.MouseButton1Click)) do conn:Fire() end
            for _, conn in pairs(getconnections(btn.MouseButton1Down)) do conn:Fire() end
            for _, conn in pairs(getconnections(btn.Activated)) do conn:Fire() end
        end
        local pos = btn.AbsolutePosition
        local size = btn.AbsoluteSize
        VirtualInputManager:SendMouseButtonEvent(pos.X + size.X/2, pos.Y + size.Y/2 + 36, 0, true, game, 1)
        task.wait(0.01)
        VirtualInputManager:SendMouseButtonEvent(pos.X + size.X/2, pos.Y + size.Y/2 + 36, 0, false, game, 1)
    end)
end

local cachedTierRollPart = nil
local lastTierScan = 0

task.spawn(function()
    local lastRoll = 0
    while task.wait(0.1) do
        if getgenv().MasterScriptID ~= myScriptID then break end
        
        if getgenv().autoTierRoll and not getgenv().isSummaryScreenOpen then
            if tick() - lastRoll > 0.5 then 
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if tick() - lastTierScan > 5 or not cachedTierRollPart or not cachedTierRollPart:IsDescendantOf(workspace) then
                        cachedTierRollPart = nil
                        local gc = workspace:FindFirstChild("__GAME_CONTENT")
                        local searchArea = gc and gc:FindFirstChild("Contents") or workspace
                        for _, v in pairs(searchArea:GetDescendants()) do
                            if v:IsA("BasePart") and string.lower(v.Name) == "tierrollpart" then
                                cachedTierRollPart = v
                                break
                            end
                        end
                        lastTierScan = tick()
                    end

                    if cachedTierRollPart and cachedTierRollPart.Parent then
                        pcall(function()
                            local cam = workspace.CurrentCamera
                            local oldCamCF = cam.CFrame
                            local oldCamType = cam.CameraType
                            local oldCF = hrp.CFrame
                            local oldVel = hrp.Velocity
                            
                            cam.CameraType = Enum.CameraType.Scriptable
                            cam.CFrame = oldCamCF
                            
                            hrp.CFrame = cachedTierRollPart.CFrame * CFrame.new(0, 1.5, 0)
                            hrp.Velocity = Vector3.zero
                            
                            task.wait(0.15) 
                            
                            hrp.CFrame = oldCF
                            hrp.Velocity = oldVel
                            
                            cam.CameraType = oldCamType
                            cam.CFrame = oldCamCF
                        end)
                        lastRoll = tick()
                    end
                end
            end
        end
    end
end)

local cachedRuneRollPart = nil
local lastRuneScan = 0

task.spawn(function()
    local lastRuneRoll = 0
    while task.wait(0.1) do
        if getgenv().MasterScriptID ~= myScriptID then break end
        
        if getgenv().autoRuneRoll then
            if tick() - lastRuneRoll > 0.5 then 
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if tick() - lastRuneScan > 5 or not cachedRuneRollPart or not cachedRuneRollPart:IsDescendantOf(workspace) then
                        cachedRuneRollPart = nil
                        local gc = workspace:FindFirstChild("__GAME_CONTENT")
                        local searchArea = gc and gc:FindFirstChild("Contents") or workspace
                        for _, v in pairs(searchArea:GetDescendants()) do
                            if v:IsA("BasePart") then
                                local n = string.lower(v.Name)
                                local p = v.Parent and string.lower(v.Parent.Name) or ""
                                if string.find(n, "rune") or string.find(p, "rune") then
                                    if string.find(n, "roll") or string.find(n, "part") or string.find(p, "zone") then
                                        cachedRuneRollPart = v
                                        break
                                    end
                                end
                            end
                        end
                        lastRuneScan = tick()
                    end

                    if cachedRuneRollPart and cachedRuneRollPart.Parent then
                        pcall(function()
                            local cam = workspace.CurrentCamera
                            local oldCamCF = cam.CFrame
                            local oldCamType = cam.CameraType
                            local oldCF = hrp.CFrame
                            local oldVel = hrp.Velocity
                            
                            cam.CameraType = Enum.CameraType.Scriptable
                            cam.CFrame = oldCamCF
                            
                            hrp.CFrame = cachedRuneRollPart.CFrame * CFrame.new(0, 1.5, 0)
                            hrp.Velocity = Vector3.zero
                            
                            task.wait(0.15) 
                            
                            hrp.CFrame = oldCF
                            hrp.Velocity = oldVel
                            
                            cam.CameraType = oldCamType
                            cam.CFrame = oldCamCF
                        end)
                        lastRuneRoll = tick()
                    end
                end
            end
        end
    end
end)

local cachedMaxButtons = {}
local lastGuiCacheTime = 0

task.spawn(function()
    while task.wait(1.5) do 
        if getgenv().MasterScriptID ~= myScriptID then break end
        
        local activeTargets = {}
        local hasAnyActive = false
        
        for category, upgradesList in pairs(generalUpgradeList) do
            if getgenv().categoryToggles[category] then
                local selected = getgenv().selectedSpecificUpgrades[category]
                if type(selected) == "table" then
                    for k, v in pairs(selected) do
                        if v == true and type(k) == "string" then
                            activeTargets[string.lower(string.gsub(k, "%s+", ""))] = true
                            hasAnyActive = true
                        end
                    end
                end
                
                if category == "PlanetsUpgrades" and type(getgenv().selectedSpecificUpgrades.PlanetsList) == "table" then
                    for k, v in pairs(getgenv().selectedSpecificUpgrades.PlanetsList) do
                        if v == true and type(k) == "string" then
                            activeTargets[string.lower(string.gsub(k, "%s+", ""))] = true
                            hasAnyActive = true
                        end
                    end
                end
            end
        end

        if hasAnyActive or getgenv().autoNearbyUpgrades then
            if tick() - lastGuiCacheTime > 20 then
                cachedMaxButtons = {}
                local guisToScan = {}
                
                local pGui = player:FindFirstChild("PlayerGui")
                if pGui then
                    for _, sg in pairs(pGui:GetChildren()) do
                        if sg:IsA("ScreenGui") and sg.Enabled then
                            for _, v in pairs(sg:GetDescendants()) do
                                if v:IsA("SurfaceGui") or v:IsA("BillboardGui") then
                                    table.insert(guisToScan, v)
                                end
                            end
                        end
                    end
                end
                
                local gc = workspace:FindFirstChild("__GAME_CONTENT")
                local wsScanFolder = gc or workspace
                for _, v in pairs(wsScanFolder:GetDescendants()) do
                    if v:IsA("SurfaceGui") or v:IsA("BillboardGui") then
                        table.insert(guisToScan, v)
                    end
                end
                
                for _, gui in ipairs(guisToScan) do
                    local isWorkspaceGui = gui:IsDescendantOf(workspace)
                    local objPart = isWorkspaceGui and (gui.Adornee or gui.Parent) or nil
                    if objPart and not objPart:IsA("BasePart") then objPart = nil end
                    
                    local isGlobalTarget = false
                    if hasAnyActive then
                        for _, txt in pairs(gui:GetDescendants()) do
                            if txt:IsA("TextLabel") and txt.Text then
                                local rawText = string.lower(string.gsub(txt.Text, "%s+", ""))
                                if activeTargets[rawText] then
                                    isGlobalTarget = true
                                    break
                                end
                            end
                        end
                    end
                    
                    if isGlobalTarget or (getgenv().autoNearbyUpgrades and isWorkspaceGui) then
                        for _, btn in pairs(gui:GetDescendants()) do
                            if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                                local bText = ""
                                if btn:IsA("TextButton") then bText = btn.Text end
                                local cTxt = btn:FindFirstChildWhichIsA("TextLabel")
                                if cTxt then bText = cTxt.Text end
                                
                                local lowText = string.lower(bText)
                                local lowName = string.lower(btn.Name)
                                if string.match(lowText, "max") or string.match(lowName, "max") then
                                    table.insert(cachedMaxButtons, {
                                        btn = btn,
                                        isGlobal = isGlobalTarget,
                                        part = objPart
                                    })
                                end
                            end
                        end
                    end
                end
                lastGuiCacheTime = tick()
            end

            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            for _, data in ipairs(cachedMaxButtons) do
                if data.btn and data.btn.Parent then
                    local shouldClick = false
                    if data.isGlobal then
                        shouldClick = true
                    elseif getgenv().autoNearbyUpgrades and data.part and hrp then
                        if (hrp.Position - data.part.Position).Magnitude < 40 then
                             shouldClick = true
                        end
                    end
                    
                    if shouldClick then
                        forceClick(data.btn)
                        task.wait(0.05) 
                    end
                end
            end
        end
    end
end)

local cachedTrialText = nil
local lastTrialDeepScan = 0
local function isInsideTrial()
    if cachedTrialText and cachedTrialText.Parent and isGuiVisible(cachedTrialText) then
        local t = string.lower(cachedTrialText.Text)
        if string.match(t, "leave trial") or string.match(t, "wave %d+") or string.match(t, "enemies left") then
            return true
        end
    end
    
    if tick() - lastTrialDeepScan < 1 then
        return getgenv().inTrial or false
    end
    lastTrialDeepScan = tick()

    local gui = player:FindFirstChild("PlayerGui")
    if not gui then return false end
    for _, sg in pairs(gui:GetChildren()) do
        if sg:IsA("ScreenGui") and sg.Enabled then
            for _, v in pairs(sg:GetDescendants()) do
                if (v:IsA("TextLabel") or v:IsA("TextButton")) and v.Text then
                    local text = string.lower(v.Text)
                    if string.match(text, "leave trial") or string.match(text, "wave %d+") or string.match(text, "enemies left") then
                        if isGuiVisible(v) then 
                            cachedTrialText = v
                            return true 
                        end
                    end
                end
            end
        end
    end
    cachedTrialText = nil
    return false
end

local function isInLobby()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local lobbyPortal = workspace:FindFirstChild("__Trial" .. getgenv().trialDifficulty .. "Room", true)
    if hrp and lobbyPortal then
        local pos = lobbyPortal:IsA("Model") and lobbyPortal:GetPivot().Position or lobbyPortal.Position
        return (hrp.Position - pos).Magnitude < 2500
    end
    return false
end

local function getTargetFolder()
    local gc = workspace:FindFirstChild("__GAME_CONTENT")
    if getgenv().inTrial then
        local trials = gc and gc:FindFirstChild("Trials")
        local trialRoom = trials and trials:FindFirstChild(getgenv().trialDifficulty .. "TrialRoom")
        return trialRoom and trialRoom:FindFirstChild("Mobs")
    else
        if gc and gc:FindFirstChild("Mobs") then return gc.Mobs end
        if workspace:FindFirstChild("Mobs") then return workspace.Mobs end
    end
    return nil
end

local function leaveTrial()
    for _, gui in pairs(player.PlayerGui:GetDescendants()) do
        if gui:IsA("TextButton") and gui.Text and string.match(gui.Text:lower(), "leave trial") then
            forceClick(gui)
        elseif gui:IsA("TextLabel") and gui.Text and string.match(gui.Text:lower(), "leave trial") then
            if gui.Parent and (gui.Parent:IsA("TextButton") or gui.Parent:IsA("ImageButton")) then
                forceClick(gui.Parent)
            end
        end
    end
end

local function getCurrentWave()
    local trialStatus = ReplicatedStorage:FindFirstChild("TrialsStatus")
    local difficulty = trialStatus and trialStatus:FindFirstChild(getgenv().trialDifficulty)
    local room = difficulty and difficulty:FindFirstChild("Room")
    return room and room.Value or 0
end

local function attemptEnterTrial()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local targetPortal = isInLobby() and workspace:FindFirstChild("__Trial" .. getgenv().trialDifficulty .. "Room", true) or workspace:FindFirstChild("__TrialTeleport", true)
    
    if targetPortal then
        local tp = targetPortal:FindFirstChild("TouchPart") or targetPortal:FindFirstChildWhichIsA("BasePart")
        if tp then
            hrp.CFrame = tp.CFrame
            if firetouchinterest then
                task.spawn(function()
                    for i = 1, 15 do
                        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then break end
                        firetouchinterest(player.Character.HumanoidRootPart, tp, 0)
                        task.wait(0.05)
                        firetouchinterest(player.Character.HumanoidRootPart, tp, 1)
                    end
                end)
            end
        end
    end
end

local function isMobDead(mob)
    if not mob or not mob.Parent then return true end
    local char = mob:FindFirstChild("MobCharacter") or mob
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    if hum and hum.Health <= 0 then return true end
    if mob:GetAttribute("Health") and tonumber(mob:GetAttribute("Health")) <= 0 then return true end
    if char:GetAttribute("Health") and tonumber(char:GetAttribute("Health")) <= 0 then return true end
    if not char:FindFirstChild("HumanoidRootPart") then return true end
    
    if getgenv().inTrial then
        for _, gui in pairs(mob:GetChildren()) do 
            if gui:IsA("BillboardGui") then
                for _, txt in pairs(gui:GetDescendants()) do
                    if txt:IsA("TextLabel") and txt.Text then
                        local t = string.lower(txt.Text)
                        if string.find(t, "respawning") then return true end
                        if string.match(t, "^0%s*/") or string.match(t, "^0%a+%s*/") then return true end
                    end
                end
            end
        end
    end
    
    return false 
end

local function isValidTarget(mobName)
    if getgenv().inTrial then
        if not getgenv().trialFarmActive then return false end
        local nameStr = string.lower(mobName)
        for _, bad in ipairs(trialBlackList) do
            if string.find(nameStr, string.lower(bad)) then return false end
        end
        return true
    else
        if getgenv().generalFarmActive then return true end
        if getgenv().indexFarmActive then
            local lowerName = string.lower(mobName)
            if getgenv().selectedMobNames[lowerName] then return true end
            for selectedName, _ in pairs(getgenv().selectedMobNames) do
                if string.find(lowerName, selectedName, 1, true) then
                    return true
                end
            end
        end
        return false
    end
end

local function findTargetMob()
    local folder = getTargetFolder()
    if not folder then return nil end
    local closestMob = nil
    local closestDistance = math.huge
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    for _, mob in pairs(folder:GetChildren()) do
        if mob:IsA("Model") and mob.Name then
            if isValidTarget(mob.Name) and not isMobDead(mob) then
                local distance = (hrp.Position - mob:GetPivot().Position).Magnitude
                if distance < closestDistance and distance < maxDistance then
                    closestDistance = distance
                    closestMob = mob
                end
            end
        end
    end
    return closestMob
end

task.spawn(function()
    while task.wait(0.5) do
        if getgenv().MasterScriptID ~= myScriptID then break end 
        
        if getgenv().autoChestActive then
            local clickedChest = false
            local summaryFound = false
            local pGui = player:FindFirstChild("PlayerGui")
            
            if pGui then
                for _, sg in pairs(pGui:GetChildren()) do
                    if sg:IsA("ScreenGui") and sg.Enabled then
                        for _, gui in pairs(sg:GetDescendants()) do
                            if gui:IsA("TextLabel") and gui.Text then
                                local text = string.lower(gui.Text)
                                
                                if string.find(text, "click anywhere to close") or string.find(text, "rolled summary") then
                                    summaryFound = true
                                    if isGuiVisible(gui) then
                                        local targetBtn = gui:FindFirstAncestorWhichIsA("TextButton") or gui:FindFirstAncestorWhichIsA("ImageButton") or gui
                                        forceClick(targetBtn)
                                        local parentSg = gui:FindFirstAncestorWhichIsA("ScreenGui")
                                        if parentSg then
                                            for _, v in pairs(parentSg:GetDescendants()) do
                                                if v:IsA("TextButton") or v:IsA("ImageButton") then
                                                    forceClick(v)
                                                end
                                            end
                                        end
                                        clickedChest = true
                                    end
                                end

                                if text == "t1 trial chest" or text == "t2 trial chest" or text == "chest" or text == "capsule" then
                                    if isGuiVisible(gui) then
                                        local btn = gui.Parent
                                        if btn and (btn:IsA("ImageButton") or btn:IsA("TextButton")) and isGuiVisible(btn) then
                                            forceClick(btn)
                                            clickedChest = true
                                            break 
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end

            getgenv().isSummaryScreenOpen = summaryFound
            if clickedChest then task.wait(0.1) end 
            
            if pGui then
                for _, sg in pairs(pGui:GetChildren()) do
                    if sg:IsA("ScreenGui") and sg.Enabled then
                        for _, gui in pairs(sg:GetDescendants()) do
                            if (gui:IsA("TextButton") or gui:IsA("TextLabel")) and gui.Text then
                                local text = string.lower(gui.Text)
                                if text == "use" or text == "open" or string.find(text, "bulk use") then
                                    if isGuiVisible(gui) then
                                        local targetBtn = gui:IsA("TextLabel") and gui.Parent or gui
                                        if targetBtn and (targetBtn:IsA("ImageButton") or targetBtn:IsA("TextButton")) and isGuiVisible(targetBtn) then
                                            forceClick(targetBtn)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

local cachedBossButtons = {}
local scannedBosses = false
task.spawn(function()
    while task.wait(2) do
        if getgenv().MasterScriptID ~= myScriptID then break end 
        
        if getgenv().autoBossActive then
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if not scannedBosses then
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("SurfaceGui") then
                            local btn = obj:FindFirstChild("Spawn", true) 
                            if btn and (btn:IsA("TextButton") or btn:IsA("ImageButton")) then
                                table.insert(cachedBossButtons, {gui = obj, btn = btn})
                            end
                        end
                    end
                    scannedBosses = true
                end

                for _, data in ipairs(cachedBossButtons) do
                    if data.gui.Parent and data.btn.Parent then
                        local boardPart = data.gui.Adornee or data.gui.Parent
                        if boardPart and boardPart:IsA("BasePart") then
                            if (hrp.Position - boardPart.Position).Magnitude <= maxDistance then
                                forceClick(data.btn)
                            end
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if getgenv().MasterScriptID ~= myScriptID then break end 
        
        local inTrialStatus = isInsideTrial()
        getgenv().inTrial = inTrialStatus
        
        local currentWave = getCurrentWave()
        local currentMinute = tonumber(os.date("%M"))
        local isPortalTime = (currentMinute == 29 or currentMinute == 59)
        
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        
        if getgenv().trialFarmActive then
            if inTrialStatus then
                if currentWave >= getgenv().trialWaveLimit then
                    getgenv().farmState = "LEAVING"
                    leaveTrial()
                    task.wait(2)
                else
                    getgenv().farmState = "FARMING"
                end
            else
                if isPortalTime then
                    if tick() - lastPortalAttempt > 3 then
                        attemptEnterTrial()
                        lastPortalAttempt = tick()
                    end
                    getgenv().farmState = "WAITING"
                else
                    if isInLobby() then
                        if hrp then
                            if getgenv().runeFarmActive and getgenv().runeLocation then
                                hrp.CFrame = hrp.CFrame:Lerp(getgenv().runeLocation, 0.3)
                            elseif getgenv().savedWorldPos then
                                hrp.CFrame = hrp.CFrame:Lerp(getgenv().savedWorldPos, 0.3)
                            else
                                local mainPortal = workspace:FindFirstChild("__TrialTeleport", true)
                                if mainPortal then
                                    local tp = mainPortal:FindFirstChild("TouchPart") or mainPortal:FindFirstChildWhichIsA("BasePart")
                                    if tp then hrp.CFrame = hrp.CFrame:Lerp(tp.CFrame * CFrame.new(0, 10, 30), 0.3) end
                                end
                            end
                            task.wait(1)
                        end
                    else
                        if hrp and not getgenv().runeFarmActive then 
                            getgenv().savedWorldPos = hrp.CFrame 
                        end
                        
                        if getgenv().runeFarmActive and getgenv().runeLocation then
                            getgenv().farmState = "RUNE_AFK"
                        elseif getgenv().generalFarmActive or getgenv().indexFarmActive then
                            getgenv().farmState = "FARMING"
                        else
                            getgenv().farmState = "IDLE"
                        end
                    end
                end
            end
        else
            if not inTrialStatus and not isInLobby() then
                if hrp and not getgenv().runeFarmActive then getgenv().savedWorldPos = hrp.CFrame end
            end
            
            if getgenv().runeFarmActive and getgenv().runeLocation and not inTrialStatus then
                getgenv().farmState = "RUNE_AFK"
            elseif (getgenv().generalFarmActive or getgenv().indexFarmActive) and not inTrialStatus then
                getgenv().farmState = "FARMING"
            else
                getgenv().farmState = "IDLE"
            end
        end
    end
end)

getgenv().currentMobTarget = nil
task.spawn(function()
    while task.wait(0.2) do
        if getgenv().MasterScriptID ~= myScriptID then break end
        if getgenv().farmState == "FARMING" and not getgenv().inTrial then
            if not getgenv().currentMobTarget or not getgenv().currentMobTarget.Parent or isMobDead(getgenv().currentMobTarget) then
                getgenv().currentMobTarget = findTargetMob()
            end
        else
            getgenv().currentMobTarget = nil
        end
    end
end)

task.spawn(function()
    while task.wait(0.01) do
        if getgenv().MasterScriptID ~= myScriptID then break end 
        
        local state = getgenv().farmState
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            if state == "FARMING" then
                local target = nil
                if getgenv().inTrial then
                    target = findTargetMob()
                else
                    target = getgenv().currentMobTarget
                end

                if target and target.Parent then
                    local goalCF = target:GetPivot() * CFrame.new(0, 2, 0)
                    hrp.CFrame = hrp.CFrame:Lerp(goalCF, 0.3)
                    hrp.Velocity = Vector3.zero
                end
            elseif state == "RUNE_AFK" then
                if getgenv().runeLocation then
                    hrp.CFrame = hrp.CFrame:Lerp(getgenv().runeLocation, 0.3)
                    hrp.Velocity = Vector3.zero
                end
            end
        end
    end
end)

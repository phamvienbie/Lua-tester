--[[
    ╔═══════════════════════════════════════════════════╗
    ║     KING LEGACY AUTO FARM - Level 1 to 5450      ║
    ║     UI: Ryzen Hub v7                              ║
    ║     Features: Quest, Boss, Combo, Bring Mob       ║
    ║     + ReAttack (Fixed Background M1, No Lag)      ║
    ║     ⚠ Use at your own risk - may cause ban        ║
    ╚═══════════════════════════════════════════════════╝
--]]

-- =====================================================
-- SERVICES
-- =====================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- =====================================================
-- SETTINGS
-- =====================================================
local Settings = {
    -- Farm
    AutoFarm = false,
    AutoBoss = false,
    AutoCombo = true,
    BringMob = true,
    HoverFarm = true,           -- Hover above mob head
    HoverHeight = 14,           -- Height above mob head (studs)
    LockLookAtMob = true,       -- Lock character face toward mob

    -- Weapon & Stats
    WeaponType = "Melee",       -- "Melee" | "Sword" | "Fruit" | "All (ReAttack)"
    SelectedWeapon = "",        -- Specific weapon name in backpack
    AutoStats = false,
    StatsList = {"Melee", "Defense"},
    StatsPoints = 3,

    -- Codes
    AutoRedeemCodes = false,

    -- Combat
    AttackRange = 60,
    FarmRange = 150,
    BringRange = 500,
    BringOffset = 10,
    SafeHP = 25,
    FarmDelay = 0.3,

    -- Skill & Skill Hold
    SkillKeys = {"Z", "X", "C", "V"},
    SkillDelay = 0.3,
    ComboCD = 2,
    SkillHold = {
        Z = {Enabled = true,  Hold = 0},
        X = {Enabled = true,  Hold = 0},
        C = {Enabled = true,  Hold = 0},
        V = {Enabled = true,  Hold = 0},
        B = {Enabled = false, Hold = 0},
        E = {Enabled = false, Hold = 0},
    },

    -- ReAttack
    ReAttack = false,
    ReAttackWeapons = {},       -- Empty = cycle all weapons in backpack
    SwapInterval = 0.22,
    EquipSettle = 0.06,
    M1Rate = 0.05,
    M1Method = "Activate",      -- "Activate" | "Remote" | "Both"
    BurstSkills = true,         -- Burst Z X C V B skills during ReAttack

    -- Teleport
    InstantTP = true,           -- 1-shot instant TP bypass
    TeleportDelay = 0.05,       -- Short delay after TP

    -- Activities & All Sea
    CustomMob = nil,            -- Selected quest/mob entry from Sea tab
    AutoFarmCustomMob = false,
    AutoChest = false,
    AutoFruitSniper = false,
    AutoDungeon = false,
    AutoSeaEvent = false,
    AutoGhostShip = false,
    AutoKenHaki = false,
    WalkOnWater = true,
    AutoRandomFruit = false,
    AutoFarmMaterial = false,
    SelectedMaterial = "Carrot (Rabbit / Mink - Sea 2)",

    -- Second Sea (SK Hydra, Sea Beast, Ghost Ship, Dragon & Orb)
    AutoKillHydra = false,
    AutoKillSeaBeast = false,
    AutoKillGhostShip = false,  -- Auto Kill Ghost Ship
    AutoCollectHydraChest = true, -- Auto TP & collect SK Hydra / Sea Beast / Ghost Ship chest
    AutoKillDragon = false,
    AutoSpawnDragon = false,
    AutoFarmDragonOrb = false,

    -- PvP
    TargetPlayerName = "",
    SpectatePlayer = false,
    LockLookAtPlayer = false,
    SafeEscapePvP = false,
    SafeEscapeHP = 20,

    -- Misc
    AntiAFK = true,
    FastAttack = false,
    AutoHaki = true,            -- Auto Armament Haki enabled by default
    HakiKey = "G",              -- Armament Haki hotkey (G / J / T / H)

    -- Player
    WalkSpeed = 16,
    JumpPower = 50,
}

-- =====================================================
-- STATE
-- =====================================================
local _running = true
local _currentQuest = nil
local _lastComboTime = 0
local _farmStatus = "Idle"
local _bringCount = 0
local _selectedBoss = nil
local _reattackReady = false
local _reattackStatus = "OFF"
local _m1Count = 0
local _hakiLastCheck = 0
local _hoverBV = nil
local _hoverBG = nil
local _redeeming = false
local _redeemedCount = 0
local _waterPlatform = nil
local _hydraSpawnTime = nil
local _hydraLastSeenDead = tick()
local _seaBeastSpawnTime = nil
local _seaBeastLastSeenDead = tick()
local _ghostShipSpawnTime = nil
local _ghostShipLastSeenDead = tick()
local _lastHydraPos = nil
local _lastSeaBeastPos = nil
local _lastGhostShipPos = nil
local _hydraActive = false
local _seaBeastActive = false
local _ghostShipActive = false
local _dragonKillActive = false
local _dragonOrbActive = false
local _sea2EventActive = false
local _materialFarmActive = false
local _scriptStartTime = tick()

local ActivateHaki

-- Update Character on respawn
Player.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    _hoverBV = nil
    _hoverBG = nil
    task.wait(1.5)
    if Settings.AutoHaki and ActivateHaki then
        pcall(ActivateHaki)
    end
end)

-- =====================================================
-- QUEST DATABASE
-- =====================================================
local QuestData = {
    -- ============= FIRST SEA =============
    {MinLevel = 1,    MaxLevel = 10,   Sea = 1, QuestNPC = "Bandit Quest", MobName = "Bandit",
     NPCPos = CFrame.new(-1138, 15, 4305), MobArea = CFrame.new(-1245, 15, 4382)},
    {MinLevel = 10,   MaxLevel = 25,   Sea = 1, QuestNPC = "Monkey Quest", MobName = "Monkey",
     NPCPos = CFrame.new(-1479, 50, 4454), MobArea = CFrame.new(-1552, 55, 4530)},
    {MinLevel = 25,   MaxLevel = 50,   Sea = 1, QuestNPC = "Gorilla Quest", MobName = "Gorilla",
     NPCPos = CFrame.new(-1193, 15, 4597), MobArea = CFrame.new(-1100, 20, 4700)},
    {MinLevel = 50,   MaxLevel = 75,   Sea = 1, QuestNPC = "Pirate Quest", MobName = "Pirate",
     NPCPos = CFrame.new(-1425, 15, 3893), MobArea = CFrame.new(-1500, 15, 3800)},
    {MinLevel = 75,   MaxLevel = 100,  Sea = 1, QuestNPC = "Marine Quest", MobName = "Marine Soldier",
     NPCPos = CFrame.new(-1050, 15, 3850), MobArea = CFrame.new(-950, 15, 3780)},
    {MinLevel = 100,  MaxLevel = 150,  Sea = 1, QuestNPC = "Clown Quest", MobName = "Clown",
     NPCPos = CFrame.new(1005, 16, 4448), MobArea = CFrame.new(1100, 16, 4500)},
    {MinLevel = 150,  MaxLevel = 200,  Sea = 1, QuestNPC = "Cook Quest", MobName = "Cook Pirate",
     NPCPos = CFrame.new(-85, 38, 1740), MobArea = CFrame.new(-20, 38, 1820)},
    {MinLevel = 200,  MaxLevel = 275,  Sea = 1, QuestNPC = "FishMan Quest", MobName = "FishMan",
     NPCPos = CFrame.new(2588, 15, 528), MobArea = CFrame.new(2650, 15, 600)},
    {MinLevel = 275,  MaxLevel = 350,  Sea = 1, QuestNPC = "FishMan Commander Quest", MobName = "FishMan Commander",
     NPCPos = CFrame.new(2588, 15, 528), MobArea = CFrame.new(2750, 15, 480)},
    {MinLevel = 350,  MaxLevel = 425,  Sea = 1, QuestNPC = "Swordsman Quest", MobName = "Swordsman",
     NPCPos = CFrame.new(-1900, 15, -600), MobArea = CFrame.new(-1980, 15, -680)},
    {MinLevel = 425,  MaxLevel = 500,  Sea = 1, QuestNPC = "Marine Captain Quest", MobName = "Marine Captain",
     NPCPos = CFrame.new(-1900, 15, -600), MobArea = CFrame.new(-1820, 15, -520)},
    {MinLevel = 500,  MaxLevel = 575,  Sea = 1, QuestNPC = "Snow Bandit Quest", MobName = "Snow Bandit",
     NPCPos = CFrame.new(-5300, 100, -3350), MobArea = CFrame.new(-5400, 100, -3430)},
    {MinLevel = 575,  MaxLevel = 650,  Sea = 1, QuestNPC = "Snow Soldier Quest", MobName = "Snow Soldier",
     NPCPos = CFrame.new(-5300, 100, -3350), MobArea = CFrame.new(-5200, 100, -3270)},
    {MinLevel = 650,  MaxLevel = 750,  Sea = 1, QuestNPC = "Desert Guard Quest", MobName = "Desert Guard",
     NPCPos = CFrame.new(899, 15, -4998), MobArea = CFrame.new(980, 15, -5080)},
    {MinLevel = 750,  MaxLevel = 850,  Sea = 1, QuestNPC = "Desert Officer Quest", MobName = "Desert Officer",
     NPCPos = CFrame.new(899, 15, -4998), MobArea = CFrame.new(820, 15, -4920)},
    {MinLevel = 850,  MaxLevel = 950,  Sea = 1, QuestNPC = "Sky Soldier Quest", MobName = "Sky Soldier",
     NPCPos = CFrame.new(-4777, 790, -2740), MobArea = CFrame.new(-4850, 790, -2820)},
    {MinLevel = 950,  MaxLevel = 1050, Sea = 1, QuestNPC = "Sky Commander Quest", MobName = "Sky Commander",
     NPCPos = CFrame.new(-4777, 790, -2740), MobArea = CFrame.new(-4700, 790, -2660)},
    {MinLevel = 1050, MaxLevel = 1150, Sea = 1, QuestNPC = "Prison Guard Quest", MobName = "Prison Guard",
     NPCPos = CFrame.new(-4228, 15, 1458), MobArea = CFrame.new(-4310, 15, 1540)},
    {MinLevel = 1150, MaxLevel = 1250, Sea = 1, QuestNPC = "Prison Officer Quest", MobName = "Prison Officer",
     NPCPos = CFrame.new(-4228, 15, 1458), MobArea = CFrame.new(-4150, 15, 1380)},
    {MinLevel = 1250, MaxLevel = 1350, Sea = 1, QuestNPC = "Marine Admiral Quest", MobName = "Marine Admiral",
     NPCPos = CFrame.new(-4600, 15, 950), MobArea = CFrame.new(-4680, 15, 1030)},

    -- ============= SECOND SEA =============
    {MinLevel = 1350, MaxLevel = 1500, Sea = 2, QuestNPC = "Fishman Island Quest", MobName = "Fishman Warrior",
     NPCPos = CFrame.new(-257, 15, 1427), MobArea = CFrame.new(-340, 15, 1510)},
    {MinLevel = 1500, MaxLevel = 1650, Sea = 2, QuestNPC = "Punk Hazard Quest", MobName = "Hazard Soldier",
     NPCPos = CFrame.new(1230, 15, -4120), MobArea = CFrame.new(1310, 15, -4200)},
    {MinLevel = 1650, MaxLevel = 1800, Sea = 2, QuestNPC = "Dressrosa Quest", MobName = "Gladiator",
     NPCPos = CFrame.new(430, 15, -1730), MobArea = CFrame.new(510, 15, -1810)},
    {MinLevel = 1800, MaxLevel = 1975, Sea = 2, QuestNPC = "Dressrosa Quest 2", MobName = "Elite Gladiator",
     NPCPos = CFrame.new(430, 15, -1730), MobArea = CFrame.new(350, 15, -1650)},
    {MinLevel = 1975, MaxLevel = 2150, Sea = 2, QuestNPC = "Zou Quest", MobName = "Mink Warrior",
     NPCPos = CFrame.new(-2500, 400, -1300), MobArea = CFrame.new(-2580, 400, -1380)},
    {MinLevel = 2150, MaxLevel = 2325, Sea = 2, QuestNPC = "Zou Quest 2", MobName = "Mink Guardian",
     NPCPos = CFrame.new(-2500, 400, -1300), MobArea = CFrame.new(-2420, 400, -1220)},
    {MinLevel = 2325, MaxLevel = 2500, Sea = 2, QuestNPC = "Whole Cake Quest", MobName = "Chess Soldier",
     NPCPos = CFrame.new(2050, 15, 2300), MobArea = CFrame.new(2130, 15, 2380)},
    {MinLevel = 2500, MaxLevel = 2700, Sea = 2, QuestNPC = "Whole Cake Quest 2", MobName = "Chess Commander",
     NPCPos = CFrame.new(2050, 15, 2300), MobArea = CFrame.new(1970, 15, 2220)},

    -- ============= THIRD SEA =============
    {MinLevel = 2700, MaxLevel = 2900, Sea = 3, QuestNPC = "Wano Quest 1", MobName = "Samurai",
     NPCPos = CFrame.new(-720, 15, 1430), MobArea = CFrame.new(-800, 15, 1510)},
    {MinLevel = 2900, MaxLevel = 3100, Sea = 3, QuestNPC = "Wano Quest 2", MobName = "Samurai Commander",
     NPCPos = CFrame.new(-720, 15, 1430), MobArea = CFrame.new(-640, 15, 1350)},
    {MinLevel = 3100, MaxLevel = 3350, Sea = 3, QuestNPC = "Onigashima Quest", MobName = "Beast Pirate",
     NPCPos = CFrame.new(1200, 100, -800), MobArea = CFrame.new(1280, 100, -880)},
    {MinLevel = 3350, MaxLevel = 3600, Sea = 3, QuestNPC = "Onigashima Quest 2", MobName = "Beast Commander",
     NPCPos = CFrame.new(1200, 100, -800), MobArea = CFrame.new(1120, 100, -720)},
    {MinLevel = 3600, MaxLevel = 3900, Sea = 3, QuestNPC = "Elbaf Quest", MobName = "Giant Warrior",
     NPCPos = CFrame.new(-3200, 15, 500), MobArea = CFrame.new(-3280, 15, 580)},
    {MinLevel = 3900, MaxLevel = 4200, Sea = 3, QuestNPC = "Elbaf Quest 2", MobName = "Giant Guardian",
     NPCPos = CFrame.new(-3200, 15, 500), MobArea = CFrame.new(-3120, 15, 420)},
    {MinLevel = 4200, MaxLevel = 4500, Sea = 3, QuestNPC = "Egghead Quest", MobName = "Cipher Agent",
     NPCPos = CFrame.new(2600, 50, -2100), MobArea = CFrame.new(2680, 50, -2180)},
    {MinLevel = 4500, MaxLevel = 4800, Sea = 3, QuestNPC = "Egghead Quest 2", MobName = "Cipher Commander",
     NPCPos = CFrame.new(2600, 50, -2100), MobArea = CFrame.new(2520, 50, -2020)},
    {MinLevel = 4800, MaxLevel = 5100, Sea = 3, QuestNPC = "Final Island Quest", MobName = "Elite Pirate",
     NPCPos = CFrame.new(-1500, 15, -3200), MobArea = CFrame.new(-1580, 15, -3280)},
    {MinLevel = 5100, MaxLevel = 5450, Sea = 3, QuestNPC = "Final Island Quest 2", MobName = "Pirate King Guard",
     NPCPos = CFrame.new(-1500, 15, -3200), MobArea = CFrame.new(-1420, 15, -3120)},
}

local BossData = {
    {MinLevel = 75,   Name = "Captain Morgan",    Sea = 1, Pos = CFrame.new(-1050, 20, 3700)},
    {MinLevel = 150,  Name = "Buggy",              Sea = 1, Pos = CFrame.new(1100, 20, 4600)},
    {MinLevel = 275,  Name = "Arlong",             Sea = 1, Pos = CFrame.new(2800, 15, 500)},
    {MinLevel = 500,  Name = "Wapol",              Sea = 1, Pos = CFrame.new(-5500, 120, -3500)},
    {MinLevel = 750,  Name = "Crocodile",          Sea = 1, Pos = CFrame.new(900, 20, -5200)},
    {MinLevel = 950,  Name = "Enel",               Sea = 1, Pos = CFrame.new(-4900, 800, -2900)},
    {MinLevel = 1250, Name = "Akainu",             Sea = 1, Pos = CFrame.new(-4700, 20, 900)},
    {MinLevel = 1650, Name = "Doflamingo",         Sea = 2, Pos = CFrame.new(500, 20, -1900)},
    {MinLevel = 2500, Name = "Katakuri",           Sea = 2, Pos = CFrame.new(2200, 20, 2500)},
    {MinLevel = 3350, Name = "Kaido",              Sea = 3, Pos = CFrame.new(1300, 110, -900)},
    {MinLevel = 4500, Name = "Kizaru",             Sea = 3, Pos = CFrame.new(2700, 55, -2200)},
}

local BossNames = {}
for _, b in ipairs(BossData) do
    table.insert(BossNames, b.Name .. " (Lv." .. b.MinLevel .. ")")
end

-- =====================================================
-- UTILITY FUNCTIONS
-- =====================================================
local function GetLevel()
    local stats = Player:FindFirstChild("Data") or Player:FindFirstChild("leaderstats") or Player:FindFirstChild("Stats")
    if stats then
        local level = stats:FindFirstChild("Level") or stats:FindFirstChild("Lv") or stats:FindFirstChild("LV")
        if level then return level.Value end
    end
    for _, child in pairs(Player:GetDescendants()) do
        if child.Name == "Level" and (child:IsA("IntValue") or child:IsA("NumberValue")) then
            return child.Value
        end
    end
    return 0
end

local function GetHPPercent()
    if Humanoid and Humanoid.Health and Humanoid.MaxHealth > 0 then
        return (Humanoid.Health / Humanoid.MaxHealth) * 100
    end
    return 100
end

local function FormatNumber(n)
    local num = math.floor(tonumber(n) or 0)
    local sign = num < 0 and "-" or ""
    local absStr = tostring(math.abs(num)):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
    return sign .. absStr
end

local function GetStatByKeywords(keywords, wantString)
    local function scanContainer(container)
        if not container then return nil end
        for _, obj in ipairs(container:GetDescendants()) do
            local lname = obj.Name:lower()
            for _, kw in ipairs(keywords) do
                if lname:find(kw, 1, true) then
                    if wantString and obj:IsA("StringValue") then
                        if obj.Value ~= "" and obj.Value ~= "None" then
                            return obj.Value
                        end
                    elseif not wantString and (obj:IsA("IntValue") or obj:IsA("NumberValue")) then
                        return obj.Value
                    end
                end
            end
        end
        return nil
    end

    for _, folderName in ipairs({"Data", "leaderstats", "PlayerStats", "Stats"}) do
        local val = scanContainer(Player:FindFirstChild(folderName))
        if val ~= nil then return val end
    end

    return scanContainer(Player)
end

local function GetBeli()
    return GetStatByKeywords({"beli", "belly", "money", "cash", "gold"}, false) or 0
end

local function GetGems()
    return GetStatByKeywords({"gem", "gems", "diamond"}, false) or 0
end

local function GetBounty()
    return GetStatByKeywords({"bounty", "honor"}, false) or 0
end

local function GetEquippedFruitName()
    return GetStatByKeywords({"devilfruit", "fruit", "df"}, true) or "None"
end

local function FastTeleport(targetCFrame, instantLock)
    if not HumanoidRootPart or not HumanoidRootPart.Parent then return end
    if not Humanoid or not Humanoid.Parent then return end

    task.spawn(function()
        pcall(function()
            Player:RequestStreamAroundAsync(targetCFrame.Position)
        end)
    end)

    local function resetVelocity()
        if HumanoidRootPart and HumanoidRootPart.Parent then
            HumanoidRootPart.Velocity = Vector3.zero
            HumanoidRootPart.RotVelocity = Vector3.zero
            pcall(function()
                HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end

    resetVelocity()

    if Settings.InstantTP or instantLock then
        HumanoidRootPart.CFrame = targetCFrame
        for _ = 1, 2 do
            RunService.Heartbeat:Wait()
            if not HumanoidRootPart or not HumanoidRootPart.Parent then break end
            resetVelocity()
            HumanoidRootPart.CFrame = targetCFrame
        end
        if Settings.TeleportDelay > 0 then
            task.wait(Settings.TeleportDelay)
        end
    else
        HumanoidRootPart.CFrame = targetCFrame + Vector3.new(0, 5, 0)
        task.wait(Settings.TeleportDelay)
    end
end

local function GetQuestForLevel(level)
    for i = #QuestData, 1, -1 do
        if level >= QuestData[i].MinLevel and level <= QuestData[i].MaxLevel then
            return QuestData[i]
        end
    end
    local closest, minDiff = QuestData[1], math.huge
    for _, q in ipairs(QuestData) do
        local diff = math.abs(level - q.MinLevel)
        if diff < minDiff then minDiff = diff; closest = q end
    end
    return closest
end

local function GetBossForLevel(level)
    local best = nil
    for _, boss in ipairs(BossData) do
        if level >= boss.MinLevel then best = boss end
    end
    return best
end

local function GetBossByName(name)
    for _, boss in ipairs(BossData) do
        if name:find(boss.Name) then return boss end
    end
    return nil
end

-- =====================================================
-- NPC INTERACTION
-- =====================================================
local function InteractWithNPC(npcName)
    local npcs = {}
    for _, folder in pairs({Workspace:FindFirstChild("NPCs"), Workspace:FindFirstChild("NPC"), Workspace:FindFirstChild("QuestNPCs"), Workspace}) do
        if folder then
            for _, obj in pairs(folder:GetDescendants()) do
                if obj.Name:find(npcName) or (obj:IsA("Model") and obj.Name:lower():find(npcName:lower())) then
                    table.insert(npcs, obj)
                end
            end
        end
    end
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            if remote.Name:lower():find("quest") or remote.Name:lower():find("accept") then
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer("Accept", npcName)
                        remote:FireServer(npcName)
                    else
                        remote:InvokeServer("Accept", npcName)
                        remote:InvokeServer(npcName)
                    end
                end)
            end
        end
    end
    for _, npc in pairs(npcs) do
        if npc:IsA("Model") or npc:IsA("Part") then
            for _, desc in pairs(npc:GetDescendants()) do
                if desc:IsA("ProximityPrompt") then
                    fireproximityprompt(desc); wait(0.5)
                elseif desc:IsA("ClickDetector") then
                    fireclickdetector(desc); wait(0.5)
                end
            end
        end
    end
    wait(0.5)
end

local function HasActiveQuest()
    local playerGui = Player:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in pairs(playerGui:GetDescendants()) do
            if gui:IsA("TextLabel") or gui:IsA("TextButton") then
                local text = gui.Text:lower()
                if text:find("quest") and (text:find("/") or text:find("defeat") or text:find("kill")) then
                    return true
                end
            end
        end
    end
    local data = Player:FindFirstChild("Data") or Player:FindFirstChild("QuestData")
    if data then
        local questActive = data:FindFirstChild("Quest") or data:FindFirstChild("QuestActive")
        if questActive and questActive.Value ~= "" and questActive.Value ~= "None" then
            return true
        end
    end
    return false
end

-- =====================================================
-- FIND MOB / BOSS
-- =====================================================
local function FindNearestMob(mobName, maxRange)
    local nearestMob, nearestDist = nil, maxRange or Settings.FarmRange
    for _, folder in pairs({Workspace:FindFirstChild("Mobs"), Workspace:FindFirstChild("Monsters"), Workspace:FindFirstChild("Enemies"), Workspace:FindFirstChild("NPCs"), Workspace}) do
        if folder then
            for _, mob in pairs(folder:GetChildren()) do
                if mob:IsA("Model") and mob.Name:find(mobName) then
                    local hum = mob:FindFirstChild("Humanoid") or mob:FindFirstChildOfClass("Humanoid")
                    local root = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
                    if hum and root and hum.Health > 0 then
                        local dist = (HumanoidRootPart.Position - root.Position).Magnitude
                        if dist < nearestDist then nearestDist = dist; nearestMob = mob end
                    end
                end
            end
        end
    end
    return nearestMob
end

local function FindAllMobs(mobName, maxRange)
    local mobs = {}
    maxRange = maxRange or Settings.BringRange
    for _, folder in pairs({Workspace:FindFirstChild("Mobs"), Workspace:FindFirstChild("Monsters"), Workspace:FindFirstChild("Enemies"), Workspace:FindFirstChild("NPCs"), Workspace}) do
        if folder then
            for _, mob in pairs(folder:GetChildren()) do
                if mob:IsA("Model") and mob.Name:find(mobName) then
                    local hum = mob:FindFirstChild("Humanoid") or mob:FindFirstChildOfClass("Humanoid")
                    local root = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
                    if hum and root and hum.Health > 0 then
                        local dist = (HumanoidRootPart.Position - root.Position).Magnitude
                        if dist < maxRange then table.insert(mobs, mob) end
                    end
                end
            end
        end
    end
    return mobs
end

local function FindBoss(bossName)
    for _, folder in pairs({Workspace:FindFirstChild("Bosses"), Workspace:FindFirstChild("Boss"), Workspace}) do
        if folder then
            for _, obj in pairs(folder:GetDescendants()) do
                if obj:IsA("Model") and obj.Name:find(bossName) then
                    local hum = obj:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then return obj end
                end
            end
        end
    end
    return nil
end

-- =====================================================
-- REATTACK SYSTEM (FIXED BACKGROUND M1, NO MOUSE TOUCH)
-- =====================================================
-- Cache combat remotes once
local _combatRemotes = {}
local function CacheCombatRemotes()
    if #_combatRemotes > 0 then return end
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            local n = remote.Name:lower()
            if n:find("combat") or n:find("attack") or n:find("damage")
               or n:find("swing") or n:find("hit") or n:find("m1")
               or n:find("punch") or n:find("slash") then
                table.insert(_combatRemotes, remote)
            end
        end
    end
end

--[[
    ====== FIXED BACKGROUND M1 ======
    Previous issues:
      - VirtualUser:Button1Down/Up -> steals real mouse, clicks UI, sticks touch
      - mouse1click() -> interferes with real mobile/desktop input
      - VIM:SendMouseButtonEvent -> goes through input pipeline

    New 3-layer fix without touching real mouse/input:
      Layer 1: tool:Activate() / Deactivate() -> direct Tool API call
      Layer 2: firesignal(tool.Activated) -> internal signal trigger (if supported)
      Layer 3: Fire combat RemoteEvent directly -> server fallback

    Result: Fast M1 spam, zero lag, does not affect touch/mouse input
--]]
local function BackgroundM1_Safe()
    local char = Player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end

    _m1Count = _m1Count + 1

    -- === LAYER 1: Direct Tool API (primary, always works) ===
    pcall(function()
        tool.ManualActivationOnly = false
        tool:Activate()
    end)

    -- Deactivate after 1 frame so tool does not get stuck held
    task.defer(function()
        pcall(function()
            if tool and tool.Parent == char then
                tool:Deactivate()
            end
        end)
    end)

    -- === LAYER 2: Internal firesignal (if supported by executor) ===
    if typeof(firesignal) == "function" then
        pcall(function() firesignal(tool.Activated) end)
    end

    -- === LAYER 3: Fire combat remote directly (backup) ===
    if Settings.M1Method == "Remote" or Settings.M1Method == "Both" then
        CacheCombatRemotes()
        for _, remote in ipairs(_combatRemotes) do
            pcall(function()
                remote:FireServer()
            end)
        end
    end
end

-- Get combat weapons (Melee / Sword / Fruit)
local function GetCombatTools(char)
    local tools = {}
    if #Settings.ReAttackWeapons > 0 then
        for _, name in ipairs(Settings.ReAttackWeapons) do
            local t = char:FindFirstChild(name) or Player.Backpack:FindFirstChild(name)
            if t and t:IsA("Tool") then table.insert(tools, t) end
        end
    else
        local seen = {}
        for _, container in ipairs({Player.Backpack, char}) do
            for _, item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") and not seen[item.Name] then
                    seen[item.Name] = true
                    table.insert(tools, item)
                end
            end
        end
        table.sort(tools, function(a, b) return a.Name < b.Name end)
    end
    return tools
end

-- Burst Skills Z X C V B (non-blocking)
local ReAttackSkillKeys = {
    Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C,
    Enum.KeyCode.V, Enum.KeyCode.B
}

local function BurstSkillsNonBlocking()
    if not Settings.BurstSkills then return end
    if UIS:GetFocusedTextBox() then return end
    for _, key in ipairs(ReAttackSkillKeys) do
        task.spawn(function()
            VirtualInputManager:SendKeyEvent(true, key, false, game)
            task.wait(0.02)
            VirtualInputManager:SendKeyEvent(false, key, false, game)
        end)
    end
end

-- =====================================================
-- WEAPON EQUIP HELPER
-- =====================================================
local function GetToolNames()
    local names = {}
    local seen = {}
    local char = Player.Character
    for _, container in ipairs({Player.Backpack, char}) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") and not seen[item.Name] then
                    seen[item.Name] = true
                    table.insert(names, item.Name)
                end
            end
        end
    end
    table.sort(names)
    if #names == 0 then return {"None"} end
    return names
end

local function EquipSelectedWeapon()
    if Settings.ReAttack then return end
    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not hum or hum.Health <= 0 then return end

    local targetTool = nil
    local sel = Settings.SelectedWeapon
    if sel and sel ~= "" and sel ~= "None" then
        targetTool = char:FindFirstChild(sel) or Player.Backpack:FindFirstChild(sel)
    end

    if not targetTool then
        local wType = (Settings.WeaponType or "Melee"):lower()
        for _, container in ipairs({char, Player.Backpack}) do
            if container then
                for _, item in ipairs(container:GetChildren()) do
                    if item:IsA("Tool") then
                        local n = item.Name:lower()
                        local tip = (item.ToolTip or ""):lower()
                        if wType == "sword" and (n:find("sword") or n:find("katana") or n:find("blade") or n:find("bisento") or n:find("yoru") or tip:find("sword")) then
                            targetTool = item; break
                        elseif wType == "fruit" and (n:find("fruit") or tip:find("fruit") or tip:find("devil")) then
                            targetTool = item; break
                        elseif wType == "melee" and (n:find("combat") or n:find("step") or n:find("dragon") or n:find("electro") or n:find("karate") or n:find("human") or tip:find("melee")) then
                            targetTool = item; break
                        end
                    end
                end
            end
            if targetTool then break end
        end
    end

    if not targetTool then
        targetTool = char:FindFirstChildOfClass("Tool") or Player.Backpack:FindFirstChildOfClass("Tool")
    end

    if targetTool and targetTool.Parent ~= char then
        pcall(function() hum:EquipTool(targetTool) end)
    end
end

-- =====================================================
-- NORMAL ATTACK (when ReAttack is off)
-- =====================================================
local function AutoAttack_Normal()
    -- Use Tool:Activate directly without touching mouse input
    local char = Player.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        pcall(function()
            tool.ManualActivationOnly = false
            tool:Activate()
        end)
        task.defer(function()
            pcall(function()
                if tool and tool.Parent == char then tool:Deactivate() end
            end)
        end)
    end
end

local SkillHoldOrder = {"Z", "X", "C", "V", "B", "E"}

local function UseCombo()
    if not Settings.AutoCombo then return end
    if UIS:GetFocusedTextBox() then return end
    local now = tick()
    if now - _lastComboTime < Settings.ComboCD then return end
    _lastComboTime = now

    for _, key in ipairs(SkillHoldOrder) do
        local cfg = Settings.SkillHold[key]
        if cfg and cfg.Enabled then
            local keyCode = Enum.KeyCode[key]
            local holdTime = math.max(0.05, cfg.Hold or 0)
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
                task.wait(holdTime)
                VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
            end)
            task.wait(Settings.SkillDelay)
        end
    end
end

-- =====================================================
-- HOVER LOCK (HOVER ABOVE MOB + LOCK FACE)
-- =====================================================
local function EnableHoverLock(hoverPos, lookAtPos)
    if not HumanoidRootPart or not HumanoidRootPart.Parent then return end
    if not Character or not Character.Parent then return end

    if not _hoverBV or not _hoverBV.Parent then
        local existingBV = HumanoidRootPart:FindFirstChild("KL_HoverBV")
        if existingBV then existingBV:Destroy() end
        _hoverBV = Instance.new("BodyVelocity")
        _hoverBV.Name = "KL_HoverBV"
        _hoverBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        _hoverBV.Velocity = Vector3.zero
        _hoverBV.Parent = HumanoidRootPart
    else
        _hoverBV.Velocity = Vector3.zero
    end

    if not _hoverBG or not _hoverBG.Parent then
        local existingBG = HumanoidRootPart:FindFirstChild("KL_HoverBG")
        if existingBG then existingBG:Destroy() end
        _hoverBG = Instance.new("BodyGyro")
        _hoverBG.Name = "KL_HoverBG"
        _hoverBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        _hoverBG.P = 1e4
        _hoverBG.D = 100
        _hoverBG.Parent = HumanoidRootPart
    end

    local lockedCF = Settings.LockLookAtMob
        and CFrame.lookAt(hoverPos, lookAtPos)
        or CFrame.new(hoverPos)

    HumanoidRootPart.Velocity = Vector3.zero
    HumanoidRootPart.RotVelocity = Vector3.zero
    HumanoidRootPart.CFrame = lockedCF
    _hoverBG.CFrame = lockedCF

    for _, part in ipairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

local function DisableHoverLock()
    if _hoverBV and _hoverBV.Parent then
        _hoverBV:Destroy()
    end
    _hoverBV = nil

    if _hoverBG and _hoverBG.Parent then
        _hoverBG:Destroy()
    end
    _hoverBG = nil

    if HumanoidRootPart and HumanoidRootPart.Parent then
        local oldBV = HumanoidRootPart:FindFirstChild("KL_HoverBV")
        if oldBV then oldBV:Destroy() end
        local oldBG = HumanoidRootPart:FindFirstChild("KL_HoverBG")
        if oldBG then oldBG:Destroy() end
    end
end

-- =====================================================
-- AUTO ARMAMENT HAKI
-- =====================================================
local function IsHakiActive(char)
    if not char then return false end

    if char:FindFirstChild("Buso")
       or char:FindFirstChild("Haki")
       or char:FindFirstChild("Armament")
       or char:FindFirstChild("Busoshoku") then
        return true
    end

    if char:GetAttribute("Buso") == true
       or char:GetAttribute("Haki") == true
       or char:GetAttribute("Armament") == true then
        return true
    end

    for _, desc in ipairs(char:GetDescendants()) do
        local lname = desc.Name:lower()
        if lname:find("buso") or lname:find("haki") or lname:find("armament") then
            if desc:IsA("BoolValue") then
                if desc.Value == true then return true end
            elseif desc:IsA("ParticleEmitter") or desc:IsA("Highlight") then
                if desc.Enabled then return true end
            elseif desc:IsA("BasePart") or desc:IsA("MeshPart") or desc:IsA("Model") or desc:IsA("Accessory") then
                return true
            end
        end
    end

    for _, containerName in ipairs({"Data", "PlayerStats"}) do
        local stats = Player:FindFirstChild(containerName)
        if stats then
            local flag = stats:FindFirstChild("BusoActive")
                or stats:FindFirstChild("HakiActive")
                or stats:FindFirstChild("Buso")
                or stats:FindFirstChild("Haki")
            if flag and flag:IsA("BoolValue") and flag.Value == true then
                return true
            end
        end
    end

    return false
end

ActivateHaki = function()
    local char = Player.Character
    if not char or IsHakiActive(char) then return end

    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local n = remote.Name:lower()
            if n:find("buso") or n:find("haki") or n:find("armament") then
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer()
                    else
                        remote:InvokeServer()
                    end
                end)
                task.wait(0.15)
                if IsHakiActive(char) then return end
            end
        end
    end

    if not IsHakiActive(char) and not UIS:GetFocusedTextBox() then
        local keyCode = Enum.KeyCode[Settings.HakiKey] or Enum.KeyCode.G
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
        end)
    end
end

-- =====================================================
-- BRING MOB
-- =====================================================
local function BringMobs(mobName, anchorPos)
    if not Settings.BringMob then return 0 end
    if not HumanoidRootPart or not HumanoidRootPart.Parent then return 0 end

    local mobs = FindAllMobs(mobName, Settings.BringRange)
    local playerPos = HumanoidRootPart.Position
    local isHovering = HumanoidRootPart:FindFirstChild("KL_HoverBV") ~= nil
    local centerPos = anchorPos or Vector3.new(
        playerPos.X,
        playerPos.Y - ((Settings.HoverFarm and isHovering) and Settings.HoverHeight or 0),
        playerPos.Z
    )

    local brought = 0
    for _, mob in ipairs(mobs) do
        pcall(function()
            local root = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
            local hum = mob:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then
                for _, part in ipairs(mob:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
                root.CFrame = CFrame.new(centerPos)
                root.Velocity = Vector3.zero
                root.RotVelocity = Vector3.zero
                pcall(function()
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                end)
                pcall(function() hum:MoveTo(centerPos) end)
                brought = brought + 1
            end
        end)
    end
    _bringCount = brought
    return brought
end

-- =====================================================
-- ATTACK MOB (Integrates ReAttack and Normal Attack)
-- =====================================================
local function AttackMob(mob)
    if not mob or not mob.Parent then return false end
    local humanoid = mob:FindFirstChildOfClass("Humanoid")
    local rootPart = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
    if not humanoid or humanoid.Health <= 0 or not rootPart then return false end

    local mobPos = rootPart.Position

    -- Hover above mob head + Lock character face toward mob
    if Settings.HoverFarm then
        local hoverPos = mobPos + Vector3.new(0, Settings.HoverHeight, 0)
        EnableHoverLock(hoverPos, mobPos)
    else
        DisableHoverLock()
        if Settings.BringMob then
            if HumanoidRootPart and HumanoidRootPart.Parent then
                HumanoidRootPart.CFrame = CFrame.lookAt(HumanoidRootPart.Position, mobPos)
            end
        else
            local targetCFrame = rootPart.CFrame * CFrame.new(0, 0, -Settings.AttackRange * 0.3)
            if HumanoidRootPart and HumanoidRootPart.Parent then
                HumanoidRootPart.CFrame = targetCFrame
                HumanoidRootPart.CFrame = CFrame.lookAt(HumanoidRootPart.Position, mobPos)
            end
        end
    end

    -- When ReAttack is on, it handles M1 separately; only equip & combo when off
    if not Settings.ReAttack then
        EquipSelectedWeapon()
        AutoAttack_Normal()
        UseCombo()
    end

    return true
end

-- =====================================================
-- AUTO REDEEM CODES
-- =====================================================
local KingLegacyCodes = {
    "2MFAV", "Peodiz", "DinoxLive", "3xKT", "Update7",
    "OwnerMeteor", "WELCOMETOKINGLEGACY", "FREESTATSRESET",
    "2BVISITS", "1MLIKES", "PlayKingLegacyFor5Gems",
    "Sub2Leepungg", "DRAGON", "KIORU", "3xEXP", "Update8",
}

local function RedeemCode(code)
    if not code or code == "" then return false end
    local fired = false
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local n = remote.Name:lower()
            if n:find("code") or n:find("redeem") then
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer(code)
                    else
                        remote:InvokeServer(code)
                    end
                    fired = true
                end)
            end
        end
    end
    return fired
end

local function RedeemAllCodes(notifyFn)
    if _redeeming then return end
    _redeeming = true
    _redeemedCount = 0
    task.spawn(function()
        for _, code in ipairs(KingLegacyCodes) do
            if not _running then break end
            if RedeemCode(code) then
                _redeemedCount = _redeemedCount + 1
            end
            task.wait(0.25)
        end
        _redeeming = false
        if notifyFn then
            pcall(notifyFn, _redeemedCount)
        end
    end)
end

-- =====================================================
-- AUTO STATS LOOP
-- =====================================================
task.spawn(function()
    while _running do
        if Settings.AutoStats and #Settings.StatsList > 0 then
            pcall(function()
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                        local n = remote.Name:lower()
                        if n:find("stat") or n:find("point") or n:find("addpoint") then
                            for _, statName in ipairs(Settings.StatsList) do
                                pcall(function()
                                    if remote:IsA("RemoteEvent") then
                                        remote:FireServer(statName, Settings.StatsPoints)
                                    else
                                        remote:InvokeServer(statName, Settings.StatsPoints)
                                    end
                                end)
                            end
                        end
                    end
                end
            end)
        end
        task.wait(1)
    end
end)

-- =====================================================
-- ALL SEA / ACTIVITIES / SHOP / PVP HELPERS & LOOPS
-- =====================================================
local function FindDroppedFruits()
    local fruits = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if (obj:IsA("Tool") or obj:IsA("Model")) and obj.Name:lower():find("fruit") then
            local handle = obj:FindFirstChild("Handle") or (obj:IsA("Model") and obj.PrimaryPart) or obj:FindFirstChildOfClass("BasePart")
            if handle and not obj:IsDescendantOf(Character) then
                table.insert(fruits, {obj = obj, part = handle})
            end
        end
    end
    return fruits
end

local function CollectTargetPart(part)
    if not part or not part.Parent or not HumanoidRootPart or not HumanoidRootPart.Parent then return end
    FastTeleport(part.CFrame + Vector3.new(0, 3, 0), true)
    for _, desc in ipairs(part.Parent:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            pcall(function() fireproximityprompt(desc) end)
        elseif desc:IsA("ClickDetector") then
            pcall(function() fireclickdetector(desc) end)
        end
    end
    if typeof(firetouchinterest) == "function" then
        pcall(function()
            firetouchinterest(HumanoidRootPart, part, 0)
            task.wait(0.05)
            firetouchinterest(HumanoidRootPart, part, 1)
        end)
    end
end

-- Auto Chest & Fruit Sniper Loop
task.spawn(function()
    while _running do
        if Settings.AutoFruitSniper then
            pcall(function()
                local fruits = FindDroppedFruits()
                if #fruits > 0 then
                    _farmStatus = "Grabbing Fruit: " .. fruits[1].obj.Name
                    CollectTargetPart(fruits[1].part)
                end
            end)
        end
        if Settings.AutoChest then
            pcall(function()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if not Settings.AutoChest or not _running then break end
                    if obj.Name:lower():find("chest") and (obj:IsA("BasePart") or obj:IsA("Model")) then
                        local part = obj:IsA("BasePart") and obj or (obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart"))
                        if part and part.Transparency < 1 then
                            _farmStatus = "Collecting Chest: " .. obj.Name
                            CollectTargetPart(part)
                            task.wait(0.3)
                        end
                    end
                end
            end)
        end
        task.wait(1)
    end
end)

-- Auto Ken Haki & Walk On Water & Auto Random Fruit Loop
task.spawn(function()
    while _running do
        if Settings.AutoKenHaki then
            pcall(function()
                local char = Player.Character
                if char and not char:FindFirstChild("Ken") and not char:FindFirstChild("Observation") then
                    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                            local n = remote.Name:lower()
                            if n:find("ken") or n:find("observation") then
                                pcall(function()
                                    if remote:IsA("RemoteEvent") then remote:FireServer() else remote:InvokeServer() end
                                end)
                                break
                            end
                        end
                    end
                end
            end)
        end

        if Settings.AutoRandomFruit then
            pcall(function()
                for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                        local n = remote.Name:lower()
                        if n:find("fruit") and (n:find("random") or n:find("gacha") or n:find("buy") or n:find("spin")) then
                            pcall(function()
                                if remote:IsA("RemoteEvent") then remote:FireServer() else remote:InvokeServer() end
                            end)
                        end
                    end
                end
            end)
        end

        if Settings.WalkOnWater then
            pcall(function()
                local water = Workspace:FindFirstChild("Water") or Workspace:FindFirstChild("Sea")
                if HumanoidRootPart and HumanoidRootPart.Parent and water and water:IsA("BasePart") then
                    if not _waterPlatform or not _waterPlatform.Parent then
                        _waterPlatform = Instance.new("Part")
                        _waterPlatform.Name = "KL_WaterWalk"
                        _waterPlatform.Size = Vector3.new(20, 1, 20)
                        _waterPlatform.Anchored = true
                        _waterPlatform.Transparency = 1
                        _waterPlatform.CanCollide = true
                        _waterPlatform.Parent = Workspace
                    end
                    _waterPlatform.Position = Vector3.new(HumanoidRootPart.Position.X, water.Position.Y + water.Size.Y * 0.5, HumanoidRootPart.Position.Z)
                end
            end)
        elseif _waterPlatform and _waterPlatform.Parent then
            _waterPlatform:Destroy()
            _waterPlatform = nil
        end

        task.wait(1)
    end
end)

-- Activities Loop (Dungeon / Raid, Sea Events, Ghost Ship)
task.spawn(function()
    while _running do
        if Settings.AutoDungeon then
            pcall(function()
                for _, mob in ipairs(Workspace:GetDescendants()) do
                    if not Settings.AutoDungeon or not _running then break end
                    if mob:IsA("Model") and mob ~= Character and not Players:GetPlayerFromCharacter(mob) then
                        local hum = mob:FindFirstChildOfClass("Humanoid")
                        local root = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
                        if hum and root and hum.Health > 0 and (mob.Name:lower():find("raid") or mob.Name:lower():find("dungeon") or Workspace:FindFirstChild("Dungeon")) then
                            _farmStatus = "Raid/Dungeon: " .. mob.Name
                            AttackMob(mob)
                            task.wait(Settings.FarmDelay)
                        end
                    end
                end
            end)
        end
        if Settings.AutoSeaEvent and not _sea2EventActive then
            pcall(function()
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if not Settings.AutoSeaEvent or _sea2EventActive or not _running then break end
                    if obj:IsA("Model") then
                        local n = obj.Name:lower()
                        local isSea = n:find("sea king") or n:find("hydra") or n:find("kraken") or n:find("seabeast")
                        if isSea then
                            local hum = obj:FindFirstChildOfClass("Humanoid")
                            if hum and hum.Health > 0 then
                                _farmStatus = "Sea Event: " .. obj.Name
                                AttackMob(obj)
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- Shop & Travel Helpers
local function BuyFromShop(itemName)
    local bought = false
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local n = remote.Name:lower()
            if n:find("buy") or n:find("shop") or n:find("learn") or n:find("style") or n:find("haki") or n:find("fruit") then
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer(itemName)
                        remote:FireServer("Buy", itemName)
                    else
                        remote:InvokeServer(itemName)
                        remote:InvokeServer("Buy", itemName)
                    end
                    bought = true
                end)
            end
        end
    end
    return bought
end

local function TravelToSea(seaNum)
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local n = remote.Name:lower()
            if n:find("sea") or n:find("travel") or n:find("teleport") or n:find("world") then
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer(seaNum)
                        remote:FireServer("Sea" .. seaNum)
                    else
                        remote:InvokeServer(seaNum)
                        remote:InvokeServer("Sea" .. seaNum)
                    end
                end)
            end
        end
    end
end

-- PvP Helpers & Loop
local function GetPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player then
            table.insert(names, p.Name)
        end
    end
    table.sort(names)
    if #names == 0 then return {"None"} end
    return names
end

local function FindTargetPlayer()
    if not Settings.TargetPlayerName or Settings.TargetPlayerName == "" or Settings.TargetPlayerName == "None" then
        return nil
    end
    return Players:FindFirstChild(Settings.TargetPlayerName)
end

local function SpectateTarget(enable)
    local cam = Workspace.CurrentCamera
    if not cam then return end
    if enable then
        local target = FindTargetPlayer()
        if target and target.Character then
            local hum = target.Character:FindFirstChildOfClass("Humanoid")
            if hum then cam.CameraSubject = hum end
        end
    else
        local hum = Character and Character:FindFirstChildOfClass("Humanoid")
        if hum then cam.CameraSubject = hum end
    end
end

local function ServerHop()
    local ts = game:GetService("TeleportService")
    local hs = game:GetService("HttpService")
    local ok = pcall(function()
        local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", game.PlaceId)
        local data = hs:JSONDecode(game:HttpGet(url))
        for _, server in ipairs(data.data or {}) do
            if server.id ~= game.JobId and server.playing < server.maxPlayers then
                ts:TeleportToPlaceInstance(game.PlaceId, server.id, Player)
                return
            end
        end
    end)
    if not ok then
        ts:Teleport(game.PlaceId, Player)
    end
end

task.spawn(function()
    while _running do
        if Settings.LockLookAtPlayer then
            pcall(function()
                local target = FindTargetPlayer()
                local tRoot = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
                if tRoot and HumanoidRootPart and HumanoidRootPart.Parent then
                    HumanoidRootPart.CFrame = CFrame.lookAt(HumanoidRootPart.Position, tRoot.Position)
                end
            end)
        end
        if Settings.SafeEscapePvP and GetHPPercent() < Settings.SafeEscapeHP then
            pcall(function()
                if HumanoidRootPart and HumanoidRootPart.Parent then
                    FastTeleport(HumanoidRootPart.CFrame + Vector3.new(0, 250, 0), true)
                end
            end)
            task.wait(3)
        end
        task.wait(0.1)
    end
end)

-- =====================================================
-- SECOND SEA: SK HYDRA, SEA BEAST, DRAGON & DRAGON ORB
-- =====================================================
local function FormatTimeMMSS(sec)
    sec = math.max(0, math.floor(sec))
    if sec >= 3600 then
        local h = math.floor(sec / 3600)
        local m = math.floor((sec % 3600) / 60)
        local s = sec % 60
        return string.format("%02d:%02d:%02d", h, m, s)
    end
    local m = math.floor(sec / 60)
    local s = sec % 60
    return string.format("%02d:%02d", m, s)
end

local function FindSeaMonsterByKeywords(keywords)
    local containers = {
        Workspace:FindFirstChild("SeaMonster"),
        Workspace:FindFirstChild("SeaMonsters"),
        Workspace:FindFirstChild("Bosses"),
        Workspace:FindFirstChild("Mobs"),
        Workspace:FindFirstChild("Enemies"),
        Workspace
    }
    for _, folder in ipairs(containers) do
        if folder then
            local list = (folder == Workspace) and Workspace:GetDescendants() or folder:GetChildren()
            for _, obj in ipairs(list) do
                if obj:IsA("Model") and obj ~= Character and not Players:GetPlayerFromCharacter(obj) then
                    local lname = obj.Name:lower()
                    for _, kw in ipairs(keywords) do
                        if lname:find(kw, 1, true) then
                            local hum = obj:FindFirstChildOfClass("Humanoid")
                            local root = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
                            if hum and root and hum.Health > 0 then
                                return obj
                            end
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function FindHydraModel()
    return FindSeaMonsterByKeywords({"hydra", "sea king", "seaking"})
end

local function FindSeaBeastModel()
    return FindSeaMonsterByKeywords({"sea beast", "seabeast", "kraken"})
end

local function FindDragonBoss()
    return FindSeaMonsterByKeywords({"dragon", "kaido"})
end

local function GetShipHealth(model)
    local hum = model:FindFirstChildOfClass("Humanoid")
    if hum then return hum.Health end
    for _, child in ipairs(model:GetDescendants()) do
        if child:IsA("IntValue") or child:IsA("NumberValue") then
            local lname = child.Name:lower()
            if lname == "health" or lname == "hp" or lname:find("shiphp", 1, true) then
                return child.Value
            end
        end
    end
    local attrHP = model:GetAttribute("Health") or model:GetAttribute("HP")
    if type(attrHP) == "number" then return attrHP end
    return nil
end

local function FindGhostShipModel()
    local shipKeywords = {"ghost ship", "ghostship", "ghost_ship", "thuyen ma", "cursed ship", "pirate ship"}
    local containers = {
        Workspace:FindFirstChild("GhostShip"),
        Workspace:FindFirstChild("SeaMonster"),
        Workspace:FindFirstChild("SeaMonsters"),
        Workspace:FindFirstChild("Bosses"),
        Workspace:FindFirstChild("Mobs"),
        Workspace:FindFirstChild("Enemies"),
        Workspace
    }
    for _, folder in ipairs(containers) do
        if folder then
            local list = (folder == Workspace) and Workspace:GetDescendants() or folder:GetChildren()
            for _, obj in ipairs(list) do
                if obj:IsA("Model") and obj ~= Character and not Players:GetPlayerFromCharacter(obj) then
                    local lname = obj.Name:lower()
                    for _, kw in ipairs(shipKeywords) do
                        if lname:find(kw, 1, true) then
                            local root = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
                            local hp = GetShipHealth(obj)
                            if root and (hp == nil or hp > 0) then
                                return obj
                            end
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function AttackSeaEventTarget(targetModel)
    if not targetModel or not targetModel.Parent then return false end
    local hum = targetModel:FindFirstChildOfClass("Humanoid")
    if hum then
        return AttackMob(targetModel)
    end

    local targetPart = targetModel.PrimaryPart or targetModel:FindFirstChild("HumanoidRootPart") or targetModel:FindFirstChildOfClass("BasePart")
    if not targetPart then return false end

    local targetPos = targetPart.Position
    if Settings.HoverFarm then
        local hoverPos = targetPos + Vector3.new(0, Settings.HoverHeight, 0)
        EnableHoverLock(hoverPos, targetPos)
    else
        DisableHoverLock()
        if HumanoidRootPart and HumanoidRootPart.Parent then
            HumanoidRootPart.CFrame = targetPart.CFrame * CFrame.new(0, 5, -Settings.AttackRange * 0.3)
            HumanoidRootPart.CFrame = CFrame.lookAt(HumanoidRootPart.Position, targetPos)
        end
    end

    if not Settings.ReAttack then
        EquipSelectedWeapon()
        AutoAttack_Normal()
        UseCombo()
    end
    return true
end

local function GetInGameSeaTimer(keyword1, keyword2)
    local sources = {Workspace, ReplicatedStorage, Player:FindFirstChild("PlayerGui")}
    for _, src in ipairs(sources) do
        if src then
            for _, obj in ipairs(src:GetDescendants()) do
                if obj:IsA("TextLabel") or obj:IsA("StringValue") then
                    local val = obj:IsA("TextLabel") and obj.Text or obj.Value
                    local n = obj.Name:lower()
                    local vlow = tostring(val):lower()
                    if (n:find(keyword1, 1, true) or n:find(keyword2, 1, true) or vlow:find(keyword1, 1, true) or vlow:find(keyword2, 1, true)) then
                        local timerStr = tostring(val):match("%d+:%d+[:%d]*")
                        if timerStr then
                            return timerStr
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function GetDragonOrbTool()
    local char = Player.Character
    for _, container in ipairs({char, Player:FindFirstChild("Backpack")}) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") then
                    local lname = item.Name:lower()
                    if lname:find("dragon orb", 1, true) or lname:find("dragonorb", 1, true) then
                        return item
                    end
                end
            end
        end
    end
    return nil
end

local function CountDragonOrbs()
    local count = 0
    local foundTool = nil
    local char = Player.Character
    for _, container in ipairs({char, Player:FindFirstChild("Backpack")}) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") then
                    local lname = item.Name:lower()
                    if lname:find("dragon orb", 1, true) or lname:find("dragonorb", 1, true) then
                        count = count + 1
                        if not foundTool then foundTool = item end
                    end
                end
            end
        end
    end
    for _, folderName in ipairs({"Data", "Inventory", "PlayerStats"}) do
        local folder = Player:FindFirstChild(folderName)
        if folder then
            for _, val in ipairs(folder:GetDescendants()) do
                if (val:IsA("IntValue") or val:IsA("NumberValue")) then
                    local lname = val.Name:lower()
                    if lname:find("dragonorb", 1, true) or lname:find("dragon orb", 1, true) then
                        if val.Value > count then count = val.Value end
                    end
                end
            end
        end
    end
    return count, foundTool
end

local function GetSea2LiveStatusText()
    local now = tick()
    local hydra = FindHydraModel()
    local hydraText
    if hydra then
        if not _hydraSpawnTime then _hydraSpawnTime = now end
        local hum = hydra:FindFirstChildOfClass("Humanoid")
        local hp = hum and math.floor(hum.Health) or 0
        hydraText = string.format("🟢 SPAWNED! (HP: %d | Alive: %s)", hp, FormatTimeMMSS(now - _hydraSpawnTime))
    else
        if _hydraSpawnTime then
            _hydraSpawnTime = nil
            _hydraLastSeenDead = now
        end
        local igTimer = GetInGameSeaTimer("hydra", "seaking")
        if igTimer then
            hydraText = "⏳ Spawns in: " .. igTimer
        else
            hydraText = string.format("⏳ Not Spawned (Waited: %s / ~30-60m)", FormatTimeMMSS(now - _hydraLastSeenDead))
        end
    end

    local sb = FindSeaBeastModel()
    local sbText
    if sb then
        if not _seaBeastSpawnTime then _seaBeastSpawnTime = now end
        local hum = sb:FindFirstChildOfClass("Humanoid")
        local hp = hum and math.floor(hum.Health) or 0
        sbText = string.format("🟢 SPAWNED! (HP: %d | Alive: %s)", hp, FormatTimeMMSS(now - _seaBeastSpawnTime))
    else
        if _seaBeastSpawnTime then
            _seaBeastSpawnTime = nil
            _seaBeastLastSeenDead = now
        end
        local igTimer = GetInGameSeaTimer("seabeast", "sea beast")
        if igTimer then
            sbText = "⏳ Spawns in: " .. igTimer
        else
            sbText = string.format("⏳ Not Spawned (Waited: %s / ~20-40m)", FormatTimeMMSS(now - _seaBeastLastSeenDead))
        end
    end

    local gs = FindGhostShipModel()
    local gsText
    if gs then
        if not _ghostShipSpawnTime then _ghostShipSpawnTime = now end
        local hp = GetShipHealth(gs)
        if hp then
            gsText = string.format("🟢 SPAWNED! (HP: %d | Alive: %s)", math.floor(hp), FormatTimeMMSS(now - _ghostShipSpawnTime))
        else
            gsText = string.format("🟢 SPAWNED! (Alive: %s)", FormatTimeMMSS(now - _ghostShipSpawnTime))
        end
    else
        if _ghostShipSpawnTime then
            _ghostShipSpawnTime = nil
            _ghostShipLastSeenDead = now
        end
        local igTimer = GetInGameSeaTimer("ghost", "ship")
        if igTimer then
            gsText = "⏳ Spawns in: " .. igTimer
        else
            gsText = string.format("⏳ Not Spawned (Waited: %s / ~30-60m)", FormatTimeMMSS(now - _ghostShipLastSeenDead))
        end
    end

    local dragon = FindDragonBoss()
    local dragonText
    if dragon then
        local hum = dragon:FindFirstChildOfClass("Humanoid")
        local hp = hum and math.floor(hum.Health) or 0
        dragonText = string.format("🟢 SPAWNED! (HP: %d)", hp)
    else
        dragonText = "⏳ Not Summoned"
    end

    local orbCount = CountDragonOrbs()

    return string.format(
        "🐉 SK Hydra: %s\n🌊 Sea Beast: %s\n🚢 Ghost Ship: %s\n🐲 Dragon Boss: %s\n🔮 Dragon Orb: %d in backpack",
        hydraText, sbText, gsText, dragonText, orbCount
    )
end

local function FindDragonShrinePart()
    local triggers = {"statue", "shrine", "altar", "summon", "orb"}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local lname = obj.Name:lower()
            if lname:find("dragon", 1, true) then
                for _, trig in ipairs(triggers) do
                    if lname:find(trig, 1, true) then
                        local part = obj:IsA("BasePart") and obj or (obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart"))
                        if part then
                            return part, obj
                        end
                    end
                end
            end
        end
    end
    return nil, nil
end

local function SpawnDragonWithOrb()
    local tool = GetDragonOrbTool()
    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if tool and hum and tool.Parent ~= char then
        pcall(function() hum:EquipTool(tool) end)
        task.wait(0.15)
    end

    local shrinePart, shrineObj = FindDragonShrinePart()
    if shrinePart then
        DisableHoverLock()
        FastTeleport(shrinePart.CFrame + Vector3.new(0, 4, 0), true)
        task.wait(0.2)
        for _, desc in ipairs((shrineObj or shrinePart):GetDescendants()) do
            if desc:IsA("ProximityPrompt") then
                pcall(function() fireproximityprompt(desc) end)
            elseif desc:IsA("ClickDetector") then
                pcall(function() fireclickdetector(desc) end)
            end
        end
    end

    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local n = remote.Name:lower()
            if (n:find("dragon", 1, true) and (n:find("summon", 1, true) or n:find("spawn", 1, true) or n:find("orb", 1, true))) or n:find("shrine", 1, true) then
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer()
                        remote:FireServer("Dragon Orb")
                    else
                        remote:InvokeServer()
                        remote:InvokeServer("Dragon Orb")
                    end
                end)
            end
        end
    end
end

local DragonOrbMobs = {
    "Dead Troop", "Elite Skeleton", "Skull Pirate", "Ryu",
    "Chosen One", "Elite Gladiator", "Hazard Soldier"
}
local _orbAreaToggle = false

local function FarmDragonOrbStep()
    if not HumanoidRootPart or not HumanoidRootPart.Parent then return end
    local nearestMob = nil
    local nearestDist = math.huge

    for _, mobName in ipairs(DragonOrbMobs) do
        local m = FindNearestMob(mobName, 5000)
        if m then
            local root = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
            if root then
                local d = (HumanoidRootPart.Position - root.Position).Magnitude
                if d < nearestDist then
                    nearestDist = d
                    nearestMob = m
                end
            end
        end
    end

    if nearestMob then
        local mobRoot = nearestMob:FindFirstChild("HumanoidRootPart") or nearestMob.PrimaryPart
        if Settings.BringMob and mobRoot then
            BringMobs(nearestMob.Name, mobRoot.Position)
        end
        AttackMob(nearestMob)
    else
        DisableHoverLock()
        _orbAreaToggle = not _orbAreaToggle
        local areaCF = _orbAreaToggle and CFrame.new(-5400, 310, -4600) or CFrame.new(350, 15, -1650)
        FastTeleport(areaCF, true)
        task.wait(0.8)
    end
end

local function FindSeaEventChestParts(eventType, lastKnownPos)
    local specificKeywords = {
        "hydrachest", "seakingchest", "seabeastchest", "ghostchest",
        "shipchest", "cursedchest", "legacychest", "eventchest", "islandchest", "treasurechest"
    }
    local eventFilter = {
        hydra = {"hydra", "seaking", "sea king", "legacy"},
        seabeast = {"seabeast", "sea beast", "kraken", "legacy", "sea"},
        ghost = {"ghost", "ship", "cursed", "legacy"},
    }

    local results = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local lname = obj.Name:lower()
            if lname:find("chest", 1, true) then
                local opened = obj:FindFirstChild("Opened") or obj:GetAttribute("Opened")
                local isOpened = (typeof(opened) == "Instance" and opened:IsA("BoolValue") and opened.Value) or (opened == true)
                if not isOpened then
                    local part = obj:IsA("BasePart") and obj or (obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart"))
                    if part and part.Transparency < 1 then
                        local isSpecific = false
                        for _, kw in ipairs(specificKeywords) do
                            if lname:find(kw, 1, true) then
                                isSpecific = true
                                break
                            end
                        end

                        local matchesEvent = false
                        if eventType and eventFilter[eventType] then
                            for _, kw in ipairs(eventFilter[eventType]) do
                                if lname:find(kw, 1, true) then
                                    matchesEvent = true
                                    break
                                end
                            end
                        end

                        local nearLast = false
                        if lastKnownPos and (part.Position - lastKnownPos).Magnitude <= 1500 then
                            nearLast = true
                        end

                        local inEventIsland = false
                        local ancestor = obj.Parent
                        while ancestor and ancestor ~= Workspace do
                            local aname = ancestor.Name:lower()
                            if aname:find("hydra", 1, true) or aname:find("seaking", 1, true) or aname:find("seabeast", 1, true) or aname:find("seaevent", 1, true) or aname:find("ghost", 1, true) then
                                inEventIsland = true
                                break
                            end
                            ancestor = ancestor.Parent
                        end

                        if isSpecific or matchesEvent or nearLast or inEventIsland then
                            local priority = (matchesEvent and 1) or (isSpecific and 2) or (inEventIsland and 3) or 4
                            table.insert(results, {part = part, obj = obj, priority = priority})
                        end
                    end
                end
            end
        end
    end

    table.sort(results, function(a, b)
        if a.priority ~= b.priority then
            return a.priority < b.priority
        end
        if lastKnownPos then
            return (a.part.Position - lastKnownPos).Magnitude < (b.part.Position - lastKnownPos).Magnitude
        end
        return false
    end)

    return results
end

local function CollectSeaEventChest(eventType, lastKnownPos, waitForSpawn)
    local attempts = waitForSpawn and 12 or 1
    local collectedAny = false

    for attempt = 1, attempts do
        if not _running then break end
        local chests = FindSeaEventChestParts(eventType, lastKnownPos)
        if #chests > 0 then
            DisableHoverLock()
            for _, item in ipairs(chests) do
                if not _running then break end
                if item.part and item.part.Parent and item.part.Transparency < 1 then
                    CollectTargetPart(item.part)
                    collectedAny = true
                    task.wait(0.25)
                end
            end
            if collectedAny then
                return true
            end
        elseif waitForSpawn then
            if attempt == 1 and lastKnownPos then
                DisableHoverLock()
                FastTeleport(CFrame.new(lastKnownPos) + Vector3.new(0, 20, 0), true)
            end
            task.wait(0.5)
        end
    end

    return collectedAny
end

local function UpdateSea2HoverState()
    local wasActive = _sea2EventActive
    _sea2EventActive = _hydraActive or _seaBeastActive or _ghostShipActive or _dragonKillActive or _dragonOrbActive
    if wasActive and not _sea2EventActive then
        if not Settings.AutoFarm and not Settings.AutoFarmCustomMob and not Settings.AutoBoss and not _materialFarmActive then
            DisableHoverLock()
        end
    end
end

-- 1. Independent Feature: Auto Kill Hydra + TP Hydra Chest
local function LoopAutoKillHydra()
    while _running do
        if Settings.AutoKillHydra then
            pcall(function()
                if not Character or not Character.Parent or not HumanoidRootPart or not HumanoidRootPart.Parent then
                    return
                end
                local hydra = FindHydraModel()
                if hydra then
                    local root = hydra:FindFirstChild("HumanoidRootPart") or hydra.PrimaryPart
                    if root then _lastHydraPos = root.Position end
                    _hydraActive = true
                    UpdateSea2HoverState()
                    _farmStatus = "🐉 Killing SK Hydra"
                    AttackMob(hydra)
                elseif _lastHydraPos then
                    local pos = _lastHydraPos
                    _lastHydraPos = nil
                    if Settings.AutoCollectHydraChest then
                        _hydraActive = true
                        UpdateSea2HoverState()
                        _farmStatus = "🎁 Teleporting to SK Hydra Chest!"
                        CollectSeaEventChest("hydra", pos, true)
                    end
                    _hydraActive = false
                    UpdateSea2HoverState()
                else
                    if Settings.AutoCollectHydraChest then
                        CollectSeaEventChest("hydra", nil, false)
                    end
                    _hydraActive = false
                    UpdateSea2HoverState()
                end
            end)
        else
            _lastHydraPos = nil
            if _hydraActive then
                _hydraActive = false
                UpdateSea2HoverState()
            end
        end
        task.wait(Settings.FarmDelay)
    end
end

-- 2. Independent Feature: Auto Kill Sea Beast + TP Sea Beast Chest
local function LoopAutoKillSeaBeast()
    while _running do
        if Settings.AutoKillSeaBeast then
            pcall(function()
                if not Character or not Character.Parent or not HumanoidRootPart or not HumanoidRootPart.Parent then
                    return
                end
                local sb = FindSeaBeastModel()
                if sb then
                    local root = sb:FindFirstChild("HumanoidRootPart") or sb.PrimaryPart
                    if root then _lastSeaBeastPos = root.Position end
                    _seaBeastActive = true
                    UpdateSea2HoverState()
                    _farmStatus = "🌊 Killing Sea Beast"
                    AttackMob(sb)
                elseif _lastSeaBeastPos then
                    local pos = _lastSeaBeastPos
                    _lastSeaBeastPos = nil
                    if Settings.AutoCollectHydraChest then
                        _seaBeastActive = true
                        UpdateSea2HoverState()
                        _farmStatus = "🎁 Teleporting to Sea Beast Chest!"
                        CollectSeaEventChest("seabeast", pos, true)
                    end
                    _seaBeastActive = false
                    UpdateSea2HoverState()
                else
                    if Settings.AutoCollectHydraChest then
                        CollectSeaEventChest("seabeast", nil, false)
                    end
                    _seaBeastActive = false
                    UpdateSea2HoverState()
                end
            end)
        else
            _lastSeaBeastPos = nil
            if _seaBeastActive then
                _seaBeastActive = false
                UpdateSea2HoverState()
            end
        end
        task.wait(Settings.FarmDelay)
    end
end

-- 3. Independent Feature: Auto Kill Ghost Ship + TP Ghost Ship Chest
local function LoopAutoKillGhostShip()
    while _running do
        if Settings.AutoKillGhostShip or Settings.AutoGhostShip then
            pcall(function()
                if not Character or not Character.Parent or not HumanoidRootPart or not HumanoidRootPart.Parent then
                    return
                end
                local gs = FindGhostShipModel()
                if gs then
                    local root = gs.PrimaryPart or gs:FindFirstChild("HumanoidRootPart") or gs:FindFirstChildOfClass("BasePart")
                    if root then _lastGhostShipPos = root.Position end
                    _ghostShipActive = true
                    UpdateSea2HoverState()
                    _farmStatus = "🚢 Killing Ghost Ship"
                    AttackSeaEventTarget(gs)
                elseif _lastGhostShipPos then
                    local pos = _lastGhostShipPos
                    _lastGhostShipPos = nil
                    if Settings.AutoCollectHydraChest then
                        _ghostShipActive = true
                        UpdateSea2HoverState()
                        _farmStatus = "🎁 Teleporting to Ghost Ship Chest!"
                        CollectSeaEventChest("ghost", pos, true)
                    end
                    _ghostShipActive = false
                    UpdateSea2HoverState()
                else
                    if Settings.AutoCollectHydraChest then
                        CollectSeaEventChest("ghost", nil, false)
                    end
                    _ghostShipActive = false
                    UpdateSea2HoverState()
                end
            end)
        else
            _lastGhostShipPos = nil
            if _ghostShipActive then
                _ghostShipActive = false
                UpdateSea2HoverState()
            end
        end
        task.wait(Settings.FarmDelay)
    end
end

-- 4. Independent Feature: Auto Kill Dragon
local function LoopAutoKillDragon()
    while _running do
        if Settings.AutoKillDragon then
            pcall(function()
                if not Character or not Character.Parent or not HumanoidRootPart or not HumanoidRootPart.Parent then
                    return
                end
                local dragon = FindDragonBoss()
                if dragon then
                    _dragonKillActive = true
                    UpdateSea2HoverState()
                    _farmStatus = "🐲 Killing Dragon Boss"
                    AttackMob(dragon)
                else
                    _dragonKillActive = false
                    UpdateSea2HoverState()
                end
            end)
        else
            if _dragonKillActive then
                _dragonKillActive = false
                UpdateSea2HoverState()
            end
        end
        task.wait(Settings.FarmDelay)
    end
end

-- 5. Independent Feature: Auto Spam Dragon
local function LoopAutoSpawnDragon()
    while _running do
        if Settings.AutoSpawnDragon then
            local spawned = false
            pcall(function()
                if not Character or not Character.Parent or not HumanoidRootPart or not HumanoidRootPart.Parent then
                    return
                end
                if not FindDragonBoss() and CountDragonOrbs() > 0 then
                    _farmStatus = "🔮 Summoning Dragon..."
                    SpawnDragonWithOrb()
                    spawned = true
                end
            end)
            task.wait(spawned and 2.5 or 0.5)
        else
            task.wait(0.5)
        end
    end
end

-- 6. Independent Feature: Auto Farm Dragon Orb
local function LoopAutoFarmDragonOrb()
    while _running do
        if Settings.AutoFarmDragonOrb then
            pcall(function()
                if not Character or not Character.Parent or not HumanoidRootPart or not HumanoidRootPart.Parent then
                    return
                end
                _dragonOrbActive = true
                UpdateSea2HoverState()
                _farmStatus = "🔮 Farming Dragon Orb..."
                FarmDragonOrbStep()
            end)
        else
            if _dragonOrbActive then
                _dragonOrbActive = false
                UpdateSea2HoverState()
            end
        end
        task.wait(Settings.FarmDelay)
    end
end

task.spawn(LoopAutoKillHydra)
task.spawn(LoopAutoKillSeaBeast)
task.spawn(LoopAutoKillGhostShip)
task.spawn(LoopAutoKillDragon)
task.spawn(LoopAutoSpawnDragon)
task.spawn(LoopAutoFarmDragonOrb)

-- =====================================================
-- MATERIAL FARMING
-- =====================================================
local MaterialData = {
    {
        Label = "Carrot (Rabbit / Mink - Sea 2)",
        Name = "Carrot",
        Sea = 2,
        Mobs = {"Mink Warrior", "Mink Guardian", "Rabbit", "Bunny", "Carrot"},
        Area = CFrame.new(-2500, 400, -1300),
        CollectGround = true,
        GroundKeywords = {"carrot"},
    },
    {
        Label = "Fresh Fish (Fishman - Sea 1 & 2)",
        Name = "Fresh Fish",
        Sea = 1,
        Mobs = {"FishMan", "FishMan Commander", "Fishman Warrior", "Karate Fishman"},
        Area = CFrame.new(2650, 15, 600),
    },
    {
        Label = "Shark Canine (Shark Tooth - Sea 1 & 2)",
        Name = "Shark Canine",
        Sea = 1,
        Mobs = {"FishMan Commander", "Arlong", "Shark", "Fishman Warrior"},
        Area = CFrame.new(2750, 15, 480),
    },
    {
        Label = "Angels Feather (Skypiea - Sea 1)",
        Name = "Angels Feather",
        Sea = 1,
        Mobs = {"Sky Soldier", "Sky Commander", "God's Guard", "Shura"},
        Area = CFrame.new(-4850, 790, -2820),
    },
    {
        Label = "Leather (Beast Hide - Sea 1 & 2)",
        Name = "Leather",
        Sea = 1,
        Mobs = {"Gorilla", "Monkey", "Snow Bandit", "Mink Warrior", "Beast Pirate"},
        Area = CFrame.new(-1100, 20, 4700),
    },
    {
        Label = "Scrap Metal (All Seas)",
        Name = "Scrap Metal",
        Sea = 1,
        Mobs = {"Pirate", "Marine Soldier", "Clown", "Hazard Soldier", "Gladiator"},
        Area = CFrame.new(-1500, 15, 3800),
    },
    {
        Label = "Gunpowder (Sea 1 & 2)",
        Name = "Gunpowder",
        Sea = 1,
        Mobs = {"Pirate", "Clown", "Marine Captain", "Prison Guard", "Beast Pirate"},
        Area = CFrame.new(1100, 16, 4500),
    },
    {
        Label = "Undeads Ooze (Skull Island - Sea 2)",
        Name = "Undeads Ooze",
        Sea = 2,
        Mobs = {"Zombie", "Skeleton", "Dead Troop", "Elite Skeleton"},
        Area = CFrame.new(-5400, 310, -4600),
    },
    {
        Label = "Vampires Vitalfluid (Skull Island - Sea 2)",
        Name = "Vampires Vitalfluid",
        Sea = 2,
        Mobs = {"Vampire", "Dead Troop", "Skull Pirate"},
        Area = CFrame.new(-5500, 310, -4750),
    },
    {
        Label = "Magma Crystal (Punk Hazard - Sea 2)",
        Name = "Magma Crystal",
        Sea = 2,
        Mobs = {"Hazard Soldier", "Lava Pirate", "Magma Ninja", "Hot Soldier"},
        Area = CFrame.new(1310, 15, -4200),
    },
    {
        Label = "Ice Crystal (Punk Hazard - Sea 2)",
        Name = "Ice Crystal",
        Sea = 2,
        Mobs = {"Snow Soldier", "Cold Soldier", "Ice Admiral", "Arctic Warrior"},
        Area = CFrame.new(1250, 15, -4050),
    },
    {
        Label = "Dragon Scale (Dragon / Beast - Sea 2 & 3)",
        Name = "Dragon Scale",
        Sea = 2,
        Mobs = {"Dragon", "Kaido", "Beast Commander", "Beast Pirate", "Ryu"},
        Area = CFrame.new(1280, 100, -880),
    },
    {
        Label = "Sea Kings Fin (Hydra / Sea King - Sea 2)",
        Name = "Sea Kings Fin",
        Sea = 2,
        Mobs = {"Hydra", "Sea King", "SeaKing", "Sea Beast"},
        Area = CFrame.new(-257, 15, 1427),
    },
    {
        Label = "Coral & Pearl (Wano / Deep Sea - Sea 3)",
        Name = "Coral & Pearl",
        Sea = 3,
        Mobs = {"Fishman Warrior", "Deep Diver", "Sea Soldier", "Samurai"},
        Area = CFrame.new(-800, 15, 1510),
    },
    {
        Label = "Lucifers Inferno (Final Island - Sea 3)",
        Name = "Lucifers Inferno",
        Sea = 3,
        Mobs = {"Elite Pirate", "Pirate King Guard", "Cipher Commander", "Samurai Commander"},
        Area = CFrame.new(-1580, 15, -3280),
    },
}

local MaterialLabels = {}
for _, m in ipairs(MaterialData) do
    table.insert(MaterialLabels, m.Label)
end

local function GetMaterialEntry(label)
    for _, m in ipairs(MaterialData) do
        if m.Label == label or m.Name == label then
            return m
        end
    end
    return MaterialData[1]
end

local function GetMaterialCount(matName)
    local count = 0
    local targetLower = matName:lower():gsub("[%s&]+", "")
    local targetRaw = matName:lower()

    local function matchesName(str)
        local l = str:lower()
        return l:find(targetRaw, 1, true) or l:gsub("[%s&]+", ""):find(targetLower, 1, true)
    end

    local char = Player.Character
    for _, container in ipairs({Player:FindFirstChild("Backpack"), char}) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") and matchesName(item.Name) then
                    local qty = item:FindFirstChild("Amount") or item:FindFirstChild("Count") or item:FindFirstChild("Quantity")
                    if qty and (qty:IsA("IntValue") or qty:IsA("NumberValue")) then
                        count = count + qty.Value
                    else
                        count = count + 1
                    end
                end
            end
        end
    end

    for _, folderName in ipairs({"Data", "Inventory", "Materials", "PlayerStats"}) do
        local folder = Player:FindFirstChild(folderName)
        if folder then
            for _, val in ipairs(folder:GetDescendants()) do
                if (val:IsA("IntValue") or val:IsA("NumberValue")) and matchesName(val.Name) then
                    if val.Value > count then
                        count = val.Value
                    end
                elseif val:IsA("StringValue") and matchesName(val.Name) then
                    local num = tonumber(val.Value)
                    if num and num > count then count = num end
                end
            end
        end
    end

    return count
end

local function CollectGroundMaterial(keywords)
    if not keywords or #keywords == 0 then return false end
    local collected = false
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if not Settings.AutoFarmMaterial or not _running then break end
        if (obj:IsA("BasePart") or obj:IsA("Model")) and (not Character or not obj:IsDescendantOf(Character)) then
            local lname = obj.Name:lower()
            for _, kw in ipairs(keywords) do
                if lname:find(kw, 1, true) then
                    local hum = obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid")
                    if not hum then
                        local part = obj:IsA("BasePart") and obj or (obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart"))
                        if part and part.Transparency < 1 then
                            local hasPrompt = obj:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChildOfClass("ClickDetector") or obj:FindFirstChildOfClass("TouchTransmitter")
                            if hasPrompt or obj:IsA("Tool") or part:FindFirstChildOfClass("TouchTransmitter") then
                                CollectTargetPart(part)
                                collected = true
                                task.wait(0.2)
                            end
                        end
                    end
                    break
                end
            end
        end
    end
    return collected
end

local function FarmMaterialStep(entry)
    if not entry then return end
    if not HumanoidRootPart or not HumanoidRootPart.Parent then return end

    if entry.CollectGround and entry.GroundKeywords then
        if CollectGroundMaterial(entry.GroundKeywords) then
            return
        end
    end

    local nearestMob = nil
    local nearestDist = math.huge
    for _, mobName in ipairs(entry.Mobs) do
        local m = FindNearestMob(mobName, 3000)
        if m then
            local root = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
            if root then
                local d = (HumanoidRootPart.Position - root.Position).Magnitude
                if d < nearestDist then
                    nearestDist = d
                    nearestMob = m
                end
            end
        end
    end

    if nearestMob then
        local mobRoot = nearestMob:FindFirstChild("HumanoidRootPart") or nearestMob.PrimaryPart
        if Settings.BringMob and mobRoot then
            BringMobs(nearestMob.Name, mobRoot.Position)
        end
        AttackMob(nearestMob)
    else
        DisableHoverLock()
        FastTeleport(entry.Area, true)
        task.wait(0.6)
    end
end

-- Material Farming Background Loop
task.spawn(function()
    while _running do
        if Settings.AutoFarmMaterial and not _sea2EventActive then
            _materialFarmActive = true
            pcall(function()
                if not Character or not Character.Parent or not HumanoidRootPart or not HumanoidRootPart.Parent then
                    return
                end
                local entry = GetMaterialEntry(Settings.SelectedMaterial)
                if entry then
                    _farmStatus = string.format("🥕 Farming Material: %s (Have: %d)", entry.Name, GetMaterialCount(entry.Name))
                    FarmMaterialStep(entry)
                end
            end)
        else
            if _materialFarmActive then
                _materialFarmActive = false
                if not Settings.AutoFarm and not Settings.AutoFarmCustomMob and not Settings.AutoBoss and not _sea2EventActive then
                    DisableHoverLock()
                end
            end
        end
        task.wait(Settings.FarmDelay)
    end
end)

-- =====================================================
-- REATTACK LOOPS
-- =====================================================
-- LUỒNG 1: Đổi vũ khí + M1 + Skill burst
task.spawn(function()
    local weaponIndex = 1
    while task.wait(0.01) do
        if _running and Settings.ReAttack then
            pcall(function()
                local char = Player.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then
                    _reattackStatus = "Chờ respawn..."
                    return
                end

                local tools = GetCombatTools(char)
                if #tools == 0 then
                    _reattackStatus = "Không có vũ khí"
                    return
                end

                if weaponIndex > #tools then weaponIndex = 1 end
                local targetTool = tools[weaponIndex]
                weaponIndex = weaponIndex + 1

                local slotStart = os.clock()
                _reattackReady = false

                -- Equip vũ khí
                if targetTool and targetTool.Parent ~= char then
                    hum:EquipTool(targetTool)
                end

                -- Chờ vũ khí khởi tạo xong
                task.wait(Settings.EquipSettle)
                _reattackReady = true

                -- M1 + Skills
                BackgroundM1_Safe()
                BurstSkillsNonBlocking()

                _reattackStatus = string.format("Swap: %s | M1: %d", targetTool.Name, _m1Count)

                local elapsed = os.clock() - slotStart
                local remaining = Settings.SwapInterval - elapsed
                if remaining > 0 then task.wait(remaining) end
            end)
        else
            _reattackReady = false
            if not Settings.ReAttack then
                _reattackStatus = "OFF"
            end
        end
    end
end)

-- LUỒNG 2: Spam M1 nền độc lập (giữa các lần swap)
task.spawn(function()
    while true do
        task.wait(Settings.M1Rate)
        if _running and Settings.ReAttack and _reattackReady then
            pcall(BackgroundM1_Safe)
        end
    end
end)

-- =====================================================
-- AUTO HAKI BACKGROUND LOOP
-- =====================================================
task.spawn(function()
    while _running do
        if Settings.AutoHaki then
            pcall(function()
                local now = tick()
                if now - _hakiLastCheck >= 2 then
                    _hakiLastCheck = now
                    local char = Player.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 and not IsHakiActive(char) then
                        ActivateHaki()
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- =====================================================
-- FARM LOOPS
-- =====================================================
local function FarmQuest()
    while _running do
        local isCustom = Settings.AutoFarmCustomMob and Settings.CustomMob ~= nil
        if (Settings.AutoFarm or isCustom) and not _sea2EventActive and not _materialFarmActive then
            pcall(function()
                if not Character or not Character.Parent or not HumanoidRootPart or not HumanoidRootPart.Parent then
                    DisableHoverLock()
                    Character = Player.Character or Player.CharacterAdded:Wait()
                    Humanoid = Character:WaitForChild("Humanoid")
                    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
                    wait(2); return
                end
                local level = GetLevel()
                local quest = isCustom and Settings.CustomMob or GetQuestForLevel(level)
                if not quest then
                    DisableHoverLock()
                    _farmStatus = "No quest for Lv." .. level
                    wait(3); return
                end

                _currentQuest = quest
                _farmStatus = string.format("Lv.%d | %s", level, quest.MobName)

                if GetHPPercent() < Settings.SafeHP then
                    _farmStatus = "HP thấp, hồi..."
                    DisableHoverLock()
                    FastTeleport(quest.NPCPos + Vector3.new(0, 50, 0), true); wait(5); return
                end

                if not isCustom and not HasActiveQuest() then
                    _farmStatus = "Nhận quest..."
                    DisableHoverLock()
                    FastTeleport(quest.NPCPos, true); wait(0.5)
                    InteractWithNPC(quest.QuestNPC); wait(0.5); return
                end

                if Settings.BringMob then
                    local dist = (HumanoidRootPart.Position - quest.MobArea.Position).Magnitude
                    if dist > Settings.BringRange then
                        DisableHoverLock()
                        FastTeleport(quest.MobArea, true); wait(0.3)
                    end
                    local mob = FindNearestMob(quest.MobName, Settings.BringRange)
                    if mob then
                        local mobRoot = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
                        if mobRoot then
                            BringMobs(quest.MobName, mobRoot.Position)
                        else
                            BringMobs(quest.MobName)
                        end
                        AttackMob(mob)
                    else
                        DisableHoverLock()
                        _farmStatus = "Chờ respawn..."; wait(1)
                    end
                else
                    local mob = FindNearestMob(quest.MobName, Settings.FarmRange)
                    if mob then
                        _farmStatus = string.format("Đánh: %s", quest.MobName)
                        AttackMob(mob)
                    else
                        DisableHoverLock()
                        _farmStatus = "Tìm mob..."; FastTeleport(quest.MobArea, true); wait(0.5)
                    end
                end
            end)
        elseif not _sea2EventActive and not _materialFarmActive then
            if not Settings.AutoBoss then
                DisableHoverLock()
            end
            _farmStatus = "Idle"
        end
        wait(Settings.FarmDelay)
    end
end

local function FarmBoss()
    while _running do
        if Settings.AutoBoss and not _sea2EventActive and not _materialFarmActive then
            pcall(function()
                if not Character or not Character.Parent or not HumanoidRootPart then
                    DisableHoverLock()
                    wait(2); return
                end
                local boss = _selectedBoss and GetBossByName(_selectedBoss) or GetBossForLevel(GetLevel())
                if not boss then wait(5); return end
                local bossModel = FindBoss(boss.Name)
                if bossModel then
                    _farmStatus = "Boss: " .. boss.Name
                    if Settings.BringMob and not Settings.HoverFarm then
                        pcall(function()
                            local root = bossModel:FindFirstChild("HumanoidRootPart") or bossModel.PrimaryPart
                            if root then root.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, 0, -Settings.BringOffset) end
                        end)
                    end
                    AttackMob(bossModel)
                else
                    DisableHoverLock()
                    _farmStatus = "Chờ Boss: " .. boss.Name; FastTeleport(boss.Pos, true); wait(5)
                end
            end)
        elseif not _sea2EventActive and not _materialFarmActive then
            if not Settings.AutoFarm and not Settings.AutoFarmCustomMob then
                DisableHoverLock()
            end
        end
        wait(0.3)
    end
end

-- =====================================================
-- ANTI AFK
-- =====================================================
local function AntiAFK()
    if not Settings.AntiAFK then return end
    Player.Idled:Connect(function()
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
        end)
    end)
end

-- =====================================================
-- RYZEN HUB UI (13 TABS)
-- =====================================================
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/phamvienbie/Lua-tester/refs/heads/main/HubUI_v7.lua"))()

local Window = UI:CreateWindow({
    Title = "Ryzen Hub",
    Author = "King Legacy",
    Icon = "crown",
    Folder = "Ryzen Hub",
    Size = UDim2.fromOffset(580, 300),
    Scale = 1,
    ToggleKey = Enum.KeyCode.RightControl,
    Hidden = true,
})

local loading = Window:Loading("Loading", "King Legacy Hub đang khởi tạo...")

-- ============================================================
-- 1. TAB: Home
-- ============================================================
local Home = Window:Tab({Title = "Home", Icon = "house"})

local InfoSec = Home:Section({Title = "About Ryzen Hub", Side = "Left"})
InfoSec:Paragraph({
    Title = "👑 Ryzen Hub - T3 Studio",
    Desc = "Ryzen Hub was created by kaibeo, a member of T3 Studio specializing in script creation and executors, etc.",
})
local HomeTimeParagraph = InfoSec:Paragraph({
    Title = "🕒 Time Server & Time Game",
    Desc = "🖥 Time SV: --\n⏱ Time Game (Session): --\n🌞 Giờ Trong Game: --\n🕰 Giờ Thực Tế: --\n👥 Server Players: --",
})
InfoSec:Button({
    Title = "Rejoin Server", Icon = "refresh-cw",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
    end,
})
InfoSec:Button({
    Title = "Server Hop", Icon = "globe",
    Callback = function()
        ServerHop()
    end,
})

local HomeStatsSec = Home:Section({Title = "Tiền, Gem & Nhân Vật", Side = "Right"})
local HomeStatsParagraph = HomeStatsSec:Paragraph({
    Title = "💰 Thông Tin Tài Khoản",
    Desc = "👤 Player: --\n📊 Level: --\n💵 Tiền (Beli): --\n💎 Gem: --\n🏴‍☠️ Bounty: --\n🍎 Fruit: --\n❤ HP: --%",
})

local PlayerSec = Home:Section({Title = "Player Settings", Side = "Right"})
PlayerSec:Slider({
    Title = "WalkSpeed", Step = 1, Value = {Min = 16, Max = 500, Default = 16}, Flag = "WalkSpeed",
    Callback = function(v)
        Settings.WalkSpeed = v
        local h = Character and Character:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = v end
    end,
})
PlayerSec:Slider({
    Title = "JumpPower", Step = 1, Value = {Min = 50, Max = 500, Default = 50}, Flag = "JumpPower",
    Callback = function(v)
        Settings.JumpPower = v
        local h = Character and Character:FindFirstChildOfClass("Humanoid")
        if h then h.UseJumpPower = true; h.JumpPower = v end
    end,
})
PlayerSec:Toggle({
    Title = "Anti AFK", Value = true, Flag = "AntiAFK",
    Callback = function(v)
        Settings.AntiAFK = v
        if v then AntiAFK() end
    end,
})

-- ============================================================
-- 2. TAB: Farm
-- ============================================================
local Farm = Window:Tab({Title = "Farm", Icon = "swords"})

local FarmMainSec = Farm:Section({Title = "Farm Level", Side = "Left"})
FarmMainSec:Toggle({
    Title = "Auto Farm Level", Value = false, Flag = "AutoFarmLevel",
    Callback = function(v)
        Settings.AutoFarm = v
        if v then Settings.AutoFarmCustomMob = false end
        UI:Notify({Title = "Auto Farm", Content = v and "Bắt đầu farm level!" or "Đã tắt", Kind = v and "success" or "info", Duration = 2})
        if not v then
            _farmStatus = "Idle"
            if not Settings.AutoBoss and not Settings.AutoFarmCustomMob and not _sea2EventActive and not _materialFarmActive then DisableHoverLock() end
        end
    end,
})
FarmMainSec:Toggle({
    Title = "Hover Trên Đầu Quái", Value = true, Flag = "HoverFarm",
    Callback = function(v)
        Settings.HoverFarm = v
        if not v then DisableHoverLock() end
        UI:Notify({Title = "Hover Farm", Content = v and "ON - Treo trên đầu quái" or "OFF", Kind = v and "success" or "info", Duration = 2})
    end,
})
FarmMainSec:Toggle({
    Title = "Lock Mặt Vào Quái", Value = true, Flag = "LockLookAtMob",
    Callback = function(v) Settings.LockLookAtMob = v end,
})
FarmMainSec:Toggle({
    Title = "TP Bypass (1 Lần Ăn Luôn)", Value = true, Flag = "InstantTP",
    Callback = function(v) Settings.InstantTP = v end,
})
local StatusParagraph = FarmMainSec:Paragraph({
    Title = "⚡ Farm Status",
    Desc = "Level: --\nQuest: --\nTarget: --\nHP: --%\nBring: 0 mobs",
})

local MatSec = Farm:Section({Title = "Farm Nguyên Liệu (Material)", Side = "Left"})
MatSec:Dropdown({
    Title = "Chọn Nguyên Liệu", Values = MaterialLabels, Value = MaterialLabels[1], Flag = "SelectedMaterial",
    Callback = function(v)
        Settings.SelectedMaterial = v
        local entry = GetMaterialEntry(v)
        UI:Notify({
            Title = "Nguyên Liệu",
            Content = string.format("Đã chọn: %s (Sea %d)", entry.Name, entry.Sea),
            Kind = "info",
            Duration = 2,
        })
    end,
})
MatSec:Toggle({
    Title = "Auto Farm Nguyên Liệu", Value = false, Flag = "AutoFarmMaterial",
    Callback = function(v)
        Settings.AutoFarmMaterial = v
        local entry = GetMaterialEntry(Settings.SelectedMaterial)
        UI:Notify({
            Title = "Farm Nguyên Liệu",
            Content = v and ("ON - Đang farm: " .. entry.Name) or "OFF",
            Kind = v and "success" or "info",
            Duration = 2,
        })
        if not v then
            _materialFarmActive = false
            if not Settings.AutoFarm and not Settings.AutoFarmCustomMob and not Settings.AutoBoss and not _sea2EventActive then
                DisableHoverLock()
            end
        end
    end,
})
MatSec:Button({
    Title = "TP Đến Bãi Nguyên Liệu", Icon = "map-pin",
    Callback = function()
        local entry = GetMaterialEntry(Settings.SelectedMaterial)
        if entry then
            DisableHoverLock()
            FastTeleport(entry.Area, true)
            UI:Notify({Title = "Teleport", Content = "Đã TP tới bãi " .. entry.Name .. " (Sea " .. entry.Sea .. ")", Kind = "success", Duration = 2})
        end
    end,
})
local MaterialStatusParagraph = MatSec:Paragraph({
    Title = "🎒 Túi Nguyên Liệu",
    Desc = "Đang chọn: Carrot | Số lượng: --",
})

local CodeSec = Farm:Section({Title = "Redeem Code & Quick Boss", Side = "Right"})
CodeSec:Toggle({
    Title = "Auto Redeem All Codes", Value = false, Flag = "AutoRedeemCodes",
    Callback = function(v)
        Settings.AutoRedeemCodes = v
        if v then
            RedeemAllCodes(function(count)
                UI:Notify({Title = "Codes", Content = "Đã gửi " .. count .. " mã code!", Kind = "success", Duration = 2.5})
            end)
        end
    end,
})
CodeSec:Button({
    Title = "Redeem All Codes Ngay", Icon = "gift",
    Callback = function()
        UI:Notify({Title = "Codes", Content = "Đang nhập " .. #KingLegacyCodes .. " codes...", Kind = "info", Duration = 2})
        RedeemAllCodes(function(count)
            UI:Notify({Title = "Codes", Content = "Hoàn tất gửi " .. count .. " code!", Kind = "success", Duration = 3})
        end)
    end,
})
CodeSec:Input({
    Title = "Nhập Code", Placeholder = "VD: 2MFAV", Flag = "ManualCode",
    Callback = function(text)
        local trimmed = text:match("^%s*(.-)%s*$")
        if trimmed and trimmed ~= "" then
            local ok = RedeemCode(trimmed)
            UI:Notify({Title = "Redeem Code", Content = ok and ("Đã gửi code: " .. trimmed) or "Không tìm thấy remote code", Kind = ok and "success" or "error", Duration = 2})
        end
    end,
})
CodeSec:Toggle({
    Title = "Auto Farm Boss Hiện Tại", Value = false, Flag = "QuickAutoBoss",
    Callback = function(v)
        Settings.AutoBoss = v
        UI:Notify({Title = "Boss", Content = v and "Farm boss bật!" or "Đã tắt", Kind = v and "success" or "info", Duration = 2})
        if not v and not Settings.AutoFarm and not Settings.AutoFarmCustomMob and not _sea2EventActive and not _materialFarmActive then
            DisableHoverLock()
        end
    end,
})

-- ============================================================
-- 3. TAB: Setting Farm
-- ============================================================
local FSet = Window:Tab({Title = "Setting Farm", Icon = "settings"})

local WeaponBringSec = FSet:Section({Title = "Vũ Khí & Bring Mob", Side = "Left"})
WeaponBringSec:Dropdown({
    Title = "Chọn Loại Vũ Khí", Values = {"Melee", "Sword", "Fruit", "All (ReAttack)"}, Value = "Melee", Flag = "WeaponType",
    Callback = function(v)
        Settings.WeaponType = v
        if v == "All (ReAttack)" then
            Settings.ReAttack = true
        end
    end,
})
local initialTools = GetToolNames()
local WeaponDropdown = WeaponBringSec:Dropdown({
    Title = "Chọn Vũ Khí Trong Balo", Values = initialTools, Value = initialTools[1], Flag = "SelectedWeapon",
    Callback = function(v)
        Settings.SelectedWeapon = v
        UI:Notify({Title = "Weapon", Content = "Đã chọn: " .. v, Kind = "info", Duration = 1.5})
    end,
})
WeaponBringSec:Button({
    Title = "Làm Mới Vũ Khí", Icon = "refresh-cw",
    Callback = function()
        local tools = GetToolNames()
        pcall(function()
            if WeaponDropdown.Refresh then WeaponDropdown:Refresh(tools)
            elseif WeaponDropdown.SetValues then WeaponDropdown:SetValues(tools) end
        end)
        UI:Notify({Title = "Weapons", Content = "Tìm thấy " .. #tools .. " món: " .. table.concat(tools, ", "), Kind = "info", Duration = 2.5})
    end,
})
WeaponBringSec:Toggle({
    Title = "Bring Mobs", Value = true, Flag = "BringMobs",
    Callback = function(v)
        Settings.BringMob = v
        UI:Notify({Title = "Bring Mob", Content = v and "ON - Kéo mob về" or "OFF - Farm thường", Kind = v and "success" or "info", Duration = 2})
    end,
})
WeaponBringSec:Slider({
    Title = "Bring Range", Step = 50, Value = {Min = 100, Max = 1500, Default = 500}, Flag = "BringRange",
    Callback = function(v) Settings.BringRange = v end,
})
WeaponBringSec:Slider({
    Title = "Bring Offset", Step = 2, Value = {Min = 4, Max = 50, Default = 10}, Flag = "BringOffset",
    Callback = function(v) Settings.BringOffset = v end,
})
WeaponBringSec:Slider({
    Title = "Độ Cao Treo (Hover Height)", Step = 1, Value = {Min = 5, Max = 35, Default = 14}, Flag = "HoverHeight",
    Callback = function(v) Settings.HoverHeight = v end,
})
WeaponBringSec:Slider({
    Title = "Attack Range", Step = 5, Value = {Min = 10, Max = 200, Default = 60}, Flag = "AttackRange",
    Callback = function(v) Settings.AttackRange = v end,
})
WeaponBringSec:Slider({
    Title = "Farm Delay", Step = 0.05, Value = {Min = 0.05, Max = 2, Default = 0.3}, Flag = "FarmDelay",
    Callback = function(v) Settings.FarmDelay = v end,
})
WeaponBringSec:Slider({
    Title = "Safe HP (%)", Step = 5, Value = {Min = 0, Max = 80, Default = 25}, Flag = "SafeHP",
    Callback = function(v) Settings.SafeHP = v end,
})
WeaponBringSec:Toggle({
    Title = "Auto Haki Vũ Trang", Value = true, Flag = "AutoHaki",
    Callback = function(v)
        Settings.AutoHaki = v
        if v then task.spawn(function() pcall(ActivateHaki) end) end
    end,
})
WeaponBringSec:Dropdown({
    Title = "Phím Haki (Fallback)", Values = {"G", "J", "T", "H"}, Value = "G", Flag = "HakiKey",
    Callback = function(v) Settings.HakiKey = v end,
})

local StatsReSec = FSet:Section({Title = "Cộng Stats & ReAttack", Side = "Right"})
StatsReSec:Toggle({
    Title = "Auto Cộng Stats", Value = false, Flag = "AutoStats",
    Callback = function(v)
        Settings.AutoStats = v
        UI:Notify({Title = "Auto Stats", Content = v and "Đang tự cộng điểm" or "Đã tắt", Kind = v and "success" or "info", Duration = 2})
    end,
})
StatsReSec:Dropdown({
    Title = "Chọn Stats", Multi = true, Values = {"Melee", "Defense", "Sword", "Fruit"}, Value = {"Melee", "Defense"}, Flag = "StatsList",
    Callback = function(list)
        if type(list) == "table" then
            Settings.StatsList = list
        end
    end,
})
StatsReSec:Slider({
    Title = "Điểm Mỗi Lần", Step = 1, Value = {Min = 1, Max = 50, Default = 3}, Flag = "StatsPoints",
    Callback = function(v) Settings.StatsPoints = v end,
})
StatsReSec:Toggle({
    Title = "Enable ReAttack (Spam M1 Nền)", Value = false, Flag = "ReAttack",
    Callback = function(v)
        Settings.ReAttack = v
        _m1Count = 0
        UI:Notify({Title = "ReAttack", Content = v and "ON - M1 Spam nền đã bật!" or "OFF", Kind = v and "success" or "info", Duration = 2})
    end,
})
StatsReSec:Toggle({
    Title = "Burst Skills (ZXCVB)", Value = true, Flag = "BurstSkills",
    Callback = function(v) Settings.BurstSkills = v end,
})
StatsReSec:Dropdown({
    Title = "M1 Method", Values = {"Activate", "Remote", "Both"}, Value = "Activate", Flag = "M1Method",
    Callback = function(v) Settings.M1Method = v end,
})
StatsReSec:Slider({
    Title = "Swap Interval", Step = 0.02, Value = {Min = 0.08, Max = 1, Default = 0.22}, Flag = "SwapInterval",
    Callback = function(v) Settings.SwapInterval = v end,
})
StatsReSec:Slider({
    Title = "M1 Rate", Step = 0.01, Value = {Min = 0.02, Max = 0.5, Default = 0.05}, Flag = "M1Rate",
    Callback = function(v) Settings.M1Rate = v end,
})
StatsReSec:Input({
    Title = "Weapons ReAttack (phẩy cách)", Placeholder = "Trống = tự xoay vòng balo", Flag = "WeaponInput",
    Callback = function(text)
        local weapons = {}
        for name in text:gmatch("[^,]+") do
            local trimmed = name:match("^%s*(.-)%s*$")
            if trimmed and trimmed ~= "" then table.insert(weapons, trimmed) end
        end
        Settings.ReAttackWeapons = weapons
    end,
})
local ReStatusParagraph = StatsReSec:Paragraph({
    Title = "📊 ReAttack Status",
    Desc = "Status: OFF\nM1 Count: 0",
})

-- ============================================================
-- 4. TAB: Activities
-- ============================================================
local ActTab = Window:Tab({Title = "Activities", Icon = "target"})

local BossSec = ActTab:Section({Title = "Boss Farm", Side = "Left"})
BossSec:Dropdown({
    Title = "Select Boss", Values = BossNames, Value = BossNames[1], Flag = "SelectBoss",
    Callback = function(v)
        _selectedBoss = v
        UI:Notify({Title = "Boss", Content = "Selected: " .. v, Kind = "info", Duration = 2})
    end,
})
BossSec:Toggle({
    Title = "Auto Farm Boss", Value = false, Flag = "AutoFarmBoss",
    Callback = function(v)
        Settings.AutoBoss = v
        if v then
            UI:Notify({Title = "Boss", Content = "Farm boss bật!", Kind = "success", Duration = 2})
        elseif not Settings.AutoFarm and not Settings.AutoFarmCustomMob then
            DisableHoverLock()
        end
    end,
})
local bossListText = ""
for _, b in ipairs(BossData) do
    bossListText = bossListText .. string.format("⚔ %s - Lv.%d (Sea %d)\n", b.Name, b.MinLevel, b.Sea)
end
BossSec:Paragraph({Title = "Danh sách Boss", Desc = bossListText})

local EventSec = ActTab:Section({Title = "Sea Events & Raid", Side = "Right"})
EventSec:Toggle({
    Title = "Auto Dungeon / Raid", Value = false, Flag = "AutoDungeon",
    Callback = function(v) Settings.AutoDungeon = v end,
})
EventSec:Toggle({
    Title = "Auto Sea King / Hydra", Value = false, Flag = "AutoSeaEvent",
    Callback = function(v) Settings.AutoSeaEvent = v end,
})
EventSec:Toggle({
    Title = "Auto Ghost Ship", Value = false, Flag = "AutoGhostShip",
    Callback = function(v) Settings.AutoGhostShip = v end,
})
EventSec:Toggle({
    Title = "Auto Random Fruit", Value = false, Flag = "ActAutoRandomFruit",
    Callback = function(v) Settings.AutoRandomFruit = v end,
})

-- ============================================================
-- 5. TAB: skill hold
-- ============================================================
local SkillTab = Window:Tab({Title = "skill hold", Icon = "zap"})

local SkillToggleSec = SkillTab:Section({Title = "Bật / Tắt Skill", Side = "Left"})
SkillToggleSec:Toggle({
    Title = "Auto Combo (Skill)", Value = true, Flag = "SkillAutoCombo",
    Callback = function(v) Settings.AutoCombo = v end,
})
for _, key in ipairs(SkillHoldOrder) do
    SkillToggleSec:Toggle({
        Title = "Skill " .. key, Value = Settings.SkillHold[key].Enabled, Flag = "EnableSkill_" .. key,
        Callback = function(v)
            Settings.SkillHold[key].Enabled = v
        end,
    })
end

local SkillHoldSec = SkillTab:Section({Title = "Thời Gian Giữ (Hold Time)", Side = "Right"})
for _, key in ipairs(SkillHoldOrder) do
    SkillHoldSec:Slider({
        Title = "Hold " .. key .. " (s)", Step = 0.1, Value = {Min = 0, Max = 3, Default = Settings.SkillHold[key].Hold}, Flag = "HoldSkill_" .. key,
        Callback = function(v)
            Settings.SkillHold[key].Hold = v
        end,
    })
end
SkillHoldSec:Slider({
    Title = "Combo Cooldown (s)", Step = 0.5, Value = {Min = 0.5, Max = 10, Default = 2}, Flag = "ComboCD",
    Callback = function(v) Settings.ComboCD = v end,
})
SkillHoldSec:Slider({
    Title = "Skill Delay (s)", Step = 0.05, Value = {Min = 0.05, Max = 1, Default = 0.3}, Flag = "SkillDelay",
    Callback = function(v) Settings.SkillDelay = v end,
})

-- ============================================================
-- 6, 7, 8. TABS: First Sea, Second sea, Third Sea
-- ============================================================
local function BuildSeaTab(tab, seaNumber, seaTitle)
    local seaQuests = {}
    local seaLabels = {}
    local seaInfoText = ""

    for _, q in ipairs(QuestData) do
        if q.Sea == seaNumber then
            table.insert(seaQuests, q)
            local lbl = string.format("%s (Lv.%d-%d)", q.MobName, q.MinLevel, q.MaxLevel)
            table.insert(seaLabels, lbl)
            seaInfoText = seaInfoText .. string.format("Lv.%d-%d: %s [%s]\n", q.MinLevel, q.MaxLevel, q.MobName, q.QuestNPC)
        end
    end

    local selectedQuest = seaQuests[1]
    local function findQuestByLabel(lbl)
        for idx, name in ipairs(seaLabels) do
            if name == lbl then return seaQuests[idx] end
        end
        return seaQuests[1]
    end

    local LeftSec = tab:Section({Title = "Farm & Teleport", Side = "Left"})
    LeftSec:Dropdown({
        Title = "Chọn Quái / Quest", Values = seaLabels, Value = seaLabels[1], Flag = "Sea" .. seaNumber .. "Mob",
        Callback = function(v)
            selectedQuest = findQuestByLabel(v)
            if Settings.AutoFarmCustomMob then
                Settings.CustomMob = selectedQuest
            end
        end,
    })
    LeftSec:Toggle({
        Title = "Auto Farm Mob Đã Chọn", Value = false, Flag = "FarmCustomSea" .. seaNumber,
        Callback = function(v)
            if v then
                Settings.AutoFarm = false
                Settings.CustomMob = selectedQuest
                Settings.AutoFarmCustomMob = true
                UI:Notify({Title = seaTitle, Content = "Đang farm: " .. (selectedQuest and selectedQuest.MobName or ""), Kind = "success", Duration = 2})
            else
                Settings.AutoFarmCustomMob = false
                if not Settings.AutoFarm and not Settings.AutoBoss and not _sea2EventActive then DisableHoverLock() end
            end
        end,
    })
    LeftSec:Button({
        Title = "Teleport Đến Đảo Này", Icon = "map-pin",
        Callback = function()
            if selectedQuest then
                DisableHoverLock()
                FastTeleport(selectedQuest.MobArea, true)
                UI:Notify({Title = "Teleport", Content = "Đã TP tới bãi " .. selectedQuest.MobName, Kind = "success", Duration = 2})
            end
        end,
    })
    LeftSec:Button({
        Title = "Teleport Đến NPC Nhận Quest", Icon = "flag",
        Callback = function()
            if selectedQuest then
                DisableHoverLock()
                FastTeleport(selectedQuest.NPCPos, true)
                UI:Notify({Title = "Teleport", Content = "Đã TP tới " .. selectedQuest.QuestNPC, Kind = "success", Duration = 2})
            end
        end,
    })

    local RightSec = tab:Section({Title = "Thông Tin " .. seaTitle, Side = "Right"})
    local bossText = "\n--- Bosses ---\n"
    for _, b in ipairs(BossData) do
        if b.Sea == seaNumber then
            bossText = bossText .. string.format("⚔ %s (Lv.%d)\n", b.Name, b.MinLevel)
        end
    end
    RightSec:Paragraph({
        Title = "Quests & Bosses",
        Desc = seaInfoText .. bossText,
    })
end

local Sea1Tab = Window:Tab({Title = "First Sea", Icon = "compass"})
BuildSeaTab(Sea1Tab, 1, "First Sea (Lv.1-1350)")

local Sea2Tab = Window:Tab({Title = "Second sea", Icon = "compass"})

-- Left: SK Hydra, Sea Beast & Thuyền Ma (Sea 2)
local Sea2EventSec = Sea2Tab:Section({Title = "SK Hydra, Sea Beast & Thuyền Ma", Side = "Left"})
local Sea2TimerParagraph = Sea2EventSec:Paragraph({
    Title = "⏱ Timer SK Hydra, Sea Beast & Thuyền Ma",
    Desc = "Đang tải dữ liệu...",
})
Sea2EventSec:Toggle({
    Title = "Auto Kill Hydra (SK Hydra)", Value = false, Flag = "AutoKillHydra",
    Callback = function(v)
        Settings.AutoKillHydra = v
        if not v then _lastHydraPos = nil end
        UI:Notify({Title = "SK Hydra", Content = v and "ON - Tự săn SK Hydra" or "OFF", Kind = v and "success" or "info", Duration = 2})
    end,
})
Sea2EventSec:Toggle({
    Title = "Auto Kill Sea Beast", Value = false, Flag = "AutoKillSeaBeast",
    Callback = function(v)
        Settings.AutoKillSeaBeast = v
        if not v then _lastSeaBeastPos = nil end
        UI:Notify({Title = "Sea Beast", Content = v and "ON - Tự săn Sea Beast" or "OFF", Kind = v and "success" or "info", Duration = 2})
    end,
})
Sea2EventSec:Toggle({
    Title = "Auto Kill Thuyền Ma (Ghost Ship)", Value = false, Flag = "AutoKillGhostShip",
    Callback = function(v)
        Settings.AutoKillGhostShip = v
        Settings.AutoGhostShip = v
        if not v then _lastGhostShipPos = nil end
        UI:Notify({Title = "Thuyền Ma", Content = v and "ON - Tự săn Thuyền Ma" or "OFF", Kind = v and "success" or "info", Duration = 2})
    end,
})
Sea2EventSec:Toggle({
    Title = "Auto TP Nhặt Rương Hydra / Sea Beast", Value = true, Flag = "AutoCollectHydraChest",
    Callback = function(v) Settings.AutoCollectHydraChest = v end,
})
Sea2EventSec:Button({
    Title = "TP Tới Rương Sea Event Ngay", Icon = "gift",
    Callback = function()
        task.spawn(function()
            local ok = CollectSeaEventChest(nil, HumanoidRootPart and HumanoidRootPart.Position, false)
            UI:Notify({
                Title = "Rương Sea Event",
                Content = ok and "Đã TP và nhặt rương thành công!" or "Không tìm thấy rương Hydra / Sea Beast / Thuyền Ma trên map",
                Kind = ok and "success" or "info",
                Duration = 2.5,
            })
        end)
    end,
})

-- Right: Dragon & Dragon Orb (Sea 2)
local Sea2DragonSec = Sea2Tab:Section({Title = "Dragon & Dragon Orb (Sea 2)", Side = "Right"})
Sea2DragonSec:Toggle({
    Title = "Auto Kill Dragon", Value = false, Flag = "AutoKillDragon",
    Callback = function(v)
        Settings.AutoKillDragon = v
        UI:Notify({Title = "Dragon Boss", Content = v and "ON - Tự diệt Dragon" or "OFF", Kind = v and "success" or "info", Duration = 2})
    end,
})
Sea2DragonSec:Toggle({
    Title = "Auto Spam Dragon (Auto Triệu Hồi)", Value = false, Flag = "AutoSpawnDragon",
    Callback = function(v)
        Settings.AutoSpawnDragon = v
        UI:Notify({Title = "Spam Dragon", Content = v and "ON - Tự triệu hồi khi có Orb" or "OFF", Kind = v and "success" or "info", Duration = 2})
    end,
})
Sea2DragonSec:Toggle({
    Title = "Auto Cày Dragon Orb", Value = false, Flag = "AutoFarmDragonOrb",
    Callback = function(v)
        Settings.AutoFarmDragonOrb = v
        UI:Notify({Title = "Dragon Orb", Content = v and "ON - Đang cày Dragon Orb" or "OFF", Kind = v and "success" or "info", Duration = 2})
    end,
})
Sea2DragonSec:Button({
    Title = "Triệu Hồi Dragon Ngay (1 Lần)", Icon = "flame",
    Callback = function()
        task.spawn(function()
            local orbCount = CountDragonOrbs()
            SpawnDragonWithOrb()
            UI:Notify({
                Title = "Triệu Hồi Dragon",
                Content = orbCount > 0 and ("Đã gửi lệnh triệu hồi (Orb: " .. orbCount .. ")") or "Không thấy Dragon Orb trong túi, vẫn thử kích hoạt Shrine",
                Kind = orbCount > 0 and "success" or "info",
                Duration = 2.5,
            })
        end)
    end,
})
Sea2DragonSec:Button({
    Title = "TP Đến Đảo Rồng (Dragon Shrine)", Icon = "map-pin",
    Callback = function()
        local shrinePart = FindDragonShrinePart()
        DisableHoverLock()
        if shrinePart then
            FastTeleport(shrinePart.CFrame + Vector3.new(0, 5, 0), true)
            UI:Notify({Title = "Dragon Shrine", Content = "Đã TP tới " .. shrinePart.Name, Kind = "success", Duration = 2})
        else
            FastTeleport(CFrame.new(-5400, 310, -4600), true)
            UI:Notify({Title = "Dragon Shrine", Content = "Đã TP tới khu vực Đảo Xương / Shrine", Kind = "info", Duration = 2})
        end
    end,
})

BuildSeaTab(Sea2Tab, 2, "Second Sea (Lv.1350-2700)")

local Sea3Tab = Window:Tab({Title = "Third Sea", Icon = "compass"})
BuildSeaTab(Sea3Tab, 3, "Third Sea (Lv.2700-5450)")

-- ============================================================
-- 9. TAB: all sea
-- ============================================================
local AllSeaTab = Window:Tab({Title = "all sea", Icon = "globe"})

local CollectSec = AllSeaTab:Section({Title = "Auto Collect", Side = "Left"})
CollectSec:Toggle({
    Title = "Auto Nhặt Rương (Chest)", Value = false, Flag = "AutoChest",
    Callback = function(v)
        Settings.AutoChest = v
        UI:Notify({Title = "Auto Chest", Content = v and "Đang tìm nhặt rương..." or "Đã tắt", Kind = v and "success" or "info", Duration = 2})
    end,
})
CollectSec:Toggle({
    Title = "Auto Nhặt Trái (Fruit Sniper)", Value = false, Flag = "AutoFruitSniper",
    Callback = function(v)
        Settings.AutoFruitSniper = v
        UI:Notify({Title = "Fruit Sniper", Content = v and "Đang quét trái ác quỷ..." or "Đã tắt", Kind = v and "success" or "info", Duration = 2})
    end,
})
CollectSec:Button({
    Title = "TP Tới Trái Ác Quỷ Trên Map", Icon = "search",
    Callback = function()
        local fruits = FindDroppedFruits()
        if #fruits > 0 then
            CollectTargetPart(fruits[1].part)
            UI:Notify({Title = "Fruit Found", Content = "Đã TP tới: " .. fruits[1].obj.Name, Kind = "success", Duration = 2.5})
        else
            UI:Notify({Title = "Fruit", Content = "Không có trái nào rơi trên map", Kind = "info", Duration = 2})
        end
    end,
})

local UtilSec = AllSeaTab:Section({Title = "Tiện Ích Chung", Side = "Right"})
UtilSec:Toggle({
    Title = "Auto Haki Quan Sát (Ken)", Value = false, Flag = "AutoKenHaki",
    Callback = function(v) Settings.AutoKenHaki = v end,
})
UtilSec:Toggle({
    Title = "Đi Trên Nước (Walk On Water)", Value = true, Flag = "WalkOnWater",
    Callback = function(v) Settings.WalkOnWater = v end,
})
UtilSec:Toggle({
    Title = "ReAttack M1 Nền", Value = false, Flag = "AllSeaReAttack",
    Callback = function(v) Settings.ReAttack = v end,
})

-- ============================================================
-- 10. TAB: Travel
-- ============================================================
local TravelTab = Window:Tab({Title = "Travel", Icon = "map"})

local function BuildSeaIslandLists(seaNum)
    local names, map = {}, {}
    local seen = {}
    for _, q in ipairs(QuestData) do
        if q.Sea == seaNum then
            local islandName = q.QuestNPC:gsub(" Quest.*", "") .. " (" .. q.MobName .. ")"
            if not seen[islandName] then
                seen[islandName] = true
                table.insert(names, islandName)
                map[islandName] = q.NPCPos
            end
        end
    end
    return names, map
end

local s1Names, s1Map = BuildSeaIslandLists(1)
local s2Names, s2Map = BuildSeaIslandLists(2)
local s3Names, s3Map = BuildSeaIslandLists(3)
local selS1, selS2, selS3 = s1Names[1], s2Names[1], s3Names[1]

local IslandTPSec = TravelTab:Section({Title = "Teleport Đảo Theo Sea", Side = "Left"})
IslandTPSec:Dropdown({
    Title = "Đảo Sea 1", Values = s1Names, Value = s1Names[1], Flag = "IslandSea1",
    Callback = function(v) selS1 = v end,
})
IslandTPSec:Button({
    Title = "Teleport Sea 1 Island", Icon = "navigation",
    Callback = function()
        if s1Map[selS1] then DisableHoverLock(); FastTeleport(s1Map[selS1], true) end
    end,
})
IslandTPSec:Dropdown({
    Title = "Đảo Sea 2", Values = s2Names, Value = s2Names[1], Flag = "IslandSea2",
    Callback = function(v) selS2 = v end,
})
IslandTPSec:Button({
    Title = "Teleport Sea 2 Island", Icon = "navigation",
    Callback = function()
        if s2Map[selS2] then DisableHoverLock(); FastTeleport(s2Map[selS2], true) end
    end,
})
IslandTPSec:Dropdown({
    Title = "Đảo Sea 3", Values = s3Names, Value = s3Names[1], Flag = "IslandSea3",
    Callback = function(v) selS3 = v end,
})
IslandTPSec:Button({
    Title = "Teleport Sea 3 Island", Icon = "navigation",
    Callback = function()
        if s3Map[selS3] then DisableHoverLock(); FastTeleport(s3Map[selS3], true) end
    end,
})

local SeaTravelSec = TravelTab:Section({Title = "Chuyển Sea", Side = "Right"})
SeaTravelSec:Button({
    Title = "Teleport First Sea", Icon = "compass",
    Callback = function()
        TravelToSea(1)
        UI:Notify({Title = "Travel", Content = "Đang chuyển sang First Sea...", Kind = "info", Duration = 2})
    end,
})
SeaTravelSec:Button({
    Title = "Teleport Second Sea", Icon = "compass",
    Callback = function()
        TravelToSea(2)
        UI:Notify({Title = "Travel", Content = "Đang chuyển sang Second Sea...", Kind = "info", Duration = 2})
    end,
})
SeaTravelSec:Button({
    Title = "Teleport Third Sea", Icon = "compass",
    Callback = function()
        TravelToSea(3)
        UI:Notify({Title = "Travel", Content = "Đang chuyển sang Third Sea...", Kind = "info", Duration = 2})
    end,
})
SeaTravelSec:Paragraph({
    Title = "Lưu ý chuyển Sea",
    Desc = "First Sea: Lv.1+\nSecond Sea: Yêu cầu Lv.2250+\nThird Sea: Yêu cầu Lv.3500+\nCần hoàn thành quest mở khóa Sea tương ứng.",
})

-- ============================================================
-- 11. TAB: shop
-- ============================================================
local ShopTab = Window:Tab({Title = "shop", Icon = "shopping-cart"})

local StyleList = {"Black Leg", "Electro", "Fishman Karate", "Dragon Claw", "Superhuman", "Death Step", "Sharkman Karate", "Electric Claw"}
local SkillShopList = {"Buso Haki", "Ken Haki", "Geppo", "Soru"}
local selStyle, selSkillShop = StyleList[1], SkillShopList[1]

local ShopLeftSec = ShopTab:Section({Title = "Võ & Kiếm & Haki", Side = "Left"})
ShopLeftSec:Dropdown({
    Title = "Fighting Styles", Values = StyleList, Value = StyleList[1], Flag = "ShopStyle",
    Callback = function(v) selStyle = v end,
})
ShopLeftSec:Button({
    Title = "Mua / Học Võ", Icon = "shopping-bag",
    Callback = function()
        local ok = BuyFromShop(selStyle)
        UI:Notify({Title = "Shop", Content = ok and ("Đã gửi yêu cầu mua: " .. selStyle) or "Không tìm thấy remote shop", Kind = ok and "success" or "error", Duration = 2})
    end,
})
ShopLeftSec:Dropdown({
    Title = "Haki / Kỹ Năng", Values = SkillShopList, Value = SkillShopList[1], Flag = "ShopSkill",
    Callback = function(v) selSkillShop = v end,
})
ShopLeftSec:Button({
    Title = "Mua Kỹ Năng", Icon = "shopping-bag",
    Callback = function()
        local ok = BuyFromShop(selSkillShop)
        UI:Notify({Title = "Shop", Content = ok and ("Đã gửi yêu cầu mua: " .. selSkillShop) or "Không tìm thấy remote shop", Kind = ok and "success" or "error", Duration = 2})
    end,
})

local ShopRightSec = ShopTab:Section({Title = "Fruit Shop / Gacha", Side = "Right"})
ShopRightSec:Button({
    Title = "Random Trái Ác Quỷ (Gacha)", Icon = "sparkles",
    Callback = function()
        local ok = BuyFromShop("RandomFruit")
        UI:Notify({Title = "Gacha Fruit", Content = ok and "Đã quay Random Fruit!" or "Không tìm thấy remote Gacha", Kind = ok and "success" or "info", Duration = 2})
    end,
})
ShopRightSec:Toggle({
    Title = "Auto Random Fruit", Value = false, Flag = "AutoRandomFruit",
    Callback = function(v) Settings.AutoRandomFruit = v end,
})
ShopRightSec:Button({
    Title = "TP Đến Fruit Dealer", Icon = "map-pin",
    Callback = function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name:lower():find("fruit") and (obj.Name:lower():find("dealer") or obj.Name:lower():find("shop") or obj.Name:lower():find("gacha")) then
                local root = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
                if root then
                    DisableHoverLock()
                    FastTeleport(root.CFrame, true)
                    UI:Notify({Title = "Fruit Dealer", Content = "Đã TP tới " .. obj.Name, Kind = "success", Duration = 2})
                    return
                end
            end
        end
        UI:Notify({Title = "Fruit Dealer", Content = "Không tìm thấy NPC gần đây", Kind = "info", Duration = 2})
    end,
})

-- ============================================================
-- 12. TAB: PvP
-- ============================================================
local PvPTab = Window:Tab({Title = "PvP", Icon = "crosshair"})

local PvPTargetSec = PvPTab:Section({Title = "Target Player", Side = "Left"})
local initialPlayers = GetPlayerNames()
Settings.TargetPlayerName = initialPlayers[1]
local PlayerDropdown = PvPTargetSec:Dropdown({
    Title = "Chọn Player", Values = initialPlayers, Value = initialPlayers[1], Flag = "TargetPlayer",
    Callback = function(v)
        Settings.TargetPlayerName = v
        if Settings.SpectatePlayer then SpectateTarget(true) end
    end,
})
PvPTargetSec:Button({
    Title = "Refresh Player List", Icon = "refresh-cw",
    Callback = function()
        local pList = GetPlayerNames()
        pcall(function()
            if PlayerDropdown.Refresh then PlayerDropdown:Refresh(pList)
            elseif PlayerDropdown.SetValues then PlayerDropdown:SetValues(pList) end
        end)
        UI:Notify({Title = "Players", Content = "Có " .. #pList .. " player trong server", Kind = "info", Duration = 2})
    end,
})
PvPTargetSec:Toggle({
    Title = "Spectate Player", Value = false, Flag = "SpectatePlayer",
    Callback = function(v)
        Settings.SpectatePlayer = v
        SpectateTarget(v)
    end,
})
PvPTargetSec:Button({
    Title = "Teleport Tới Player", Icon = "navigation",
    Callback = function()
        local target = FindTargetPlayer()
        local tRoot = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if tRoot then
            DisableHoverLock()
            FastTeleport(tRoot.CFrame * CFrame.new(0, 3, -5), true)
            UI:Notify({Title = "PvP TP", Content = "Đã TP tới " .. target.Name, Kind = "success", Duration = 2})
        else
            UI:Notify({Title = "PvP TP", Content = "Không tìm thấy nhân vật mục tiêu", Kind = "error", Duration = 2})
        end
    end,
})

local PvPSupportSec = PvPTab:Section({Title = "Hỗ Trợ PvP", Side = "Right"})
PvPSupportSec:Toggle({
    Title = "Lock Mặt Vào Player", Value = false, Flag = "LockLookAtPlayer",
    Callback = function(v) Settings.LockLookAtPlayer = v end,
})
PvPSupportSec:Toggle({
    Title = "Auto Trốn Khi Máu Thấp", Value = false, Flag = "SafeEscapePvP",
    Callback = function(v) Settings.SafeEscapePvP = v end,
})
PvPSupportSec:Slider({
    Title = "Mức Máu Trốn (%)", Step = 5, Value = {Min = 5, Max = 60, Default = 20}, Flag = "SafeEscapeHP",
    Callback = function(v) Settings.SafeEscapeHP = v end,
})

-- ============================================================
-- 13. TAB: Setting
-- ============================================================
Window:Divider()

local SettingsTab = Window:Tab({Title = "Setting", Icon = "sliders"})

local UISec = SettingsTab:Section({Title = "Interface & Server", Side = "Left"})
UISec:Slider({
    Title = "UI Scale", Step = 0.05, Value = {Min = 0.6, Max = 1.3, Default = 1},
    Callback = function(v) Window:SetScale(v) end,
})
UISec:Keybind({
    Title = "Toggle UI", Value = "RightControl",
    OnChange = function(name) Window:SetToggleKey(name) end,
})
UISec:Button({
    Title = "Rejoin Server", Icon = "refresh-cw",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
    end,
})
UISec:Button({
    Title = "Server Hop", Icon = "globe",
    Callback = function()
        ServerHop()
    end,
})

local CfgSec = SettingsTab:Section({Title = "Config", Side = "Right"})
CfgSec:Button({
    Title = "Save Config", Icon = "check",
    Callback = function()
        UI:Notify({Title = "Config", Content = Window:SaveConfig("KingLegacy") and "Đã lưu!" or "Executor không hỗ trợ", Kind = "success", Duration = 2})
    end,
})
CfgSec:Button({
    Title = "Load Config", Icon = "layers",
    Callback = function()
        UI:Notify({Title = "Config", Content = Window:LoadConfig("KingLegacy") and "Đã load!" or "Chưa có config", Kind = "info", Duration = 2})
    end,
})
CfgSec:Button({
    Title = "Destroy UI", Icon = "x",
    Callback = function()
        _running = false
        DisableHoverLock()
        SpectateTarget(false)
        if _waterPlatform and _waterPlatform.Parent then _waterPlatform:Destroy() end
        Window:Destroy()
    end,
})

-- ============================================================
-- STATUS UPDATER
-- ============================================================
spawn(function()
    while _running do
        pcall(function()
            local level = GetLevel()
            local hp = math.floor(GetHPPercent())
            local questName = _currentQuest and _currentQuest.QuestNPC or "--"
            local mobName = _currentQuest and _currentQuest.MobName or "--"
            local sea = _currentQuest and ("Sea " .. _currentQuest.Sea) or "--"
            local hakiState = IsHakiActive(Player.Character) and "ON" or "OFF"

            StatusParagraph:SetDesc(string.format(
                "🌊 %s | Level: %d / 5450\n📋 Quest: %s\n🎯 Target: %s\n❤ HP: %d%% | 🛡 Haki: %s\n🧲 Bring: %d mobs | 🦅 Hover: %s\n⚡ %s",
                sea, level, questName, mobName, hp, hakiState, _bringCount, Settings.HoverFarm and ("ON (" .. Settings.HoverHeight .. ")") or "OFF", _farmStatus
            ))

            ReStatusParagraph:SetDesc(string.format(
                "Status: %s\nM1 Count: %d\nMethod: %s",
                _reattackStatus, _m1Count, Settings.M1Method
            ))

            Sea2TimerParagraph:SetDesc(GetSea2LiveStatusText())

            local matEntry = GetMaterialEntry(Settings.SelectedMaterial)
            if matEntry then
                local matCount = GetMaterialCount(matEntry.Name)
                MaterialStatusParagraph:SetDesc(string.format(
                    "📦 Nguyên liệu: %s (Sea %d)\n🎯 Mob: %s\n🎒 Số lượng trong túi: %d\n⚡ Trạng thái: %s",
                    matEntry.Name, matEntry.Sea, table.concat(matEntry.Mobs, ", "), matCount, Settings.AutoFarmMaterial and "Đang farm" or "Tắt"
                ))
            end

            local svTime = FormatTimeMMSS(Workspace.DistributedGameTime or 0)
            local gameSessionTime = FormatTimeMMSS(tick() - _scriptStartTime)
            local lighting = game:GetService("Lighting")
            local clockTime = lighting and lighting.ClockTime or 12
            local dayNight = (clockTime >= 6 and clockTime < 18) and "Ban Ngày ☀️" or "Ban Đêm 🌙"
            local inGameTimeStr = (lighting and lighting.TimeOfDay and lighting.TimeOfDay:sub(1, 5) or "12:00") .. " (" .. dayNight .. ")"
            local realTimeStr = os.date("%H:%M:%S")
            local pCount = #Players:GetPlayers() .. "/" .. Players.MaxPlayers

            HomeTimeParagraph:SetDesc(string.format(
                "🖥 Time SV: %s\n⏱ Time Game (Session): %s\n🌞 Giờ Trong Game: %s\n🕰 Giờ Thực Tế: %s\n👥 Server Players: %s",
                svTime, gameSessionTime, inGameTimeStr, realTimeStr, pCount
            ))

            HomeStatsParagraph:SetDesc(string.format(
                "👤 Player: %s\n📊 Level: %s / 5450\n💵 Tiền (Beli): %s\n💎 Gem: %s\n🏴‍☠️ Bounty: %s\n🍎 Fruit: %s\n❤ HP: %d%%",
                Player.Name, FormatNumber(level), FormatNumber(GetBeli()), FormatNumber(GetGems()), FormatNumber(GetBounty()), GetEquippedFruitName(), hp
            ))
        end)
        wait(0.5)
    end
end)

-- ============================================================
-- START
-- ============================================================
Window:SelectTab(2) -- Mở sẵn tab "Farm"
loading:Success("Loaded", "King Legacy Hub 13 Tabs loaded!")
Window:SetVisible(true, nil, true)

AntiAFK()
if Settings.AutoHaki then
    task.spawn(function() pcall(ActivateHaki) end)
end
spawn(FarmQuest)
spawn(FarmBoss)

print("╔═══════════════════════════════════════════╗")
print("║  King Legacy Hub - 13 Tabs                ║")
print("║  Lv.1-5450 | Hover | Bring | ReAttack     ║")
print("║  Press RightCtrl to toggle UI              ║")
print("╚═══════════════════════════════════════════╝")

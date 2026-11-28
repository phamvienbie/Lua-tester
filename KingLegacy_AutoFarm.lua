--[[
    ╔═══════════════════════════════════════════════════╗
    ║     KING LEGACY AUTO FARM - Level 1 to 5450      ║
    ║     UI: Ryzen Hub v7                              ║
    ║     Features: Quest, Boss, Combo, Bring Mob       ║
    ║     + ReAttack (Fixed Background M1, No Lag)      ║
    ║     [!] Use at your own risk - may cause ban      ║
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
    M1Method = "Both",          -- "Activate" | "Remote" | "Both"
    BurstSkills = true,         -- Burst Z X C V B skills during ReAttack

    -- Farm Positioning, Aimbot & Nearest
    FarmPosition = "Above",     -- "Above" | "Beside" | "Lower"
    AutoFarmNearest = false,
    SkillAimbot = true,

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

    -- Dungeon
    DungeonMode = "Normal",
    DungeonDifficulty = "Normal",
    DungeonPlayMode = "Hover Above (Tween)", -- "Hover Above (Tween)" | "Behind Target" | "Safe Evasion"
    DungeonTweenSpeed = 280,
    DungeonHoverHeight = 14,
    DungeonSafeHoverHeight = 65,
    DungeonLowHPThreshold = 0.25,
    DungeonRecoveryHPThreshold = 0.55,
    DungeonCombatRange = 35,
    DungeonHitboxSize = 30,
    DungeonM1Delay = 0.13,
    DungeonWeaponSwapDelay = 0.3,
    DungeonEquipSettleDelay = 0.06,
    DungeonWeapons = {},
    DungeonPartner = "",
    DungeonPartnerMode = false,
    DungeonFriends = {},
    DungeonAutoFriends = true,
    DungeonStatus = "Idle",

    -- Misc
    AntiAFK = true,
    FastAttack = false,
    AutoHaki = true,            -- Auto Armament Haki enabled by default
    HakiKey = "G",              -- Armament Haki hotkey (G / J / T / H)

    -- Accessories & Passive
    SelectedAccessory = "",
    AutoEquipAccessory = false,
    AutoPassiveTree = false,

    -- FPS Boost / Anti-Lag
    WhiteScreen = false,
    HideLevelUpUI = false,
    HideMobHealth = false,
    DeleteDamageText = false,
    DeleteHeavyEffects = false,

    -- Unlocks / Quests / Events
    AutoSea2Unlock = false,
    AutoSea3Unlock = false,
    AutoHakiV2 = false,
    AutoObserveV2 = false,
    AutoKillMinion = false,
    AutoFarmCandy = false,
    AutoKillJackO = false,
    AutoSummonJackO = false,
    AutoKillSkullKing = false,

    -- Third Sea Events
    AutoAbyssalTyrant = false,
    AutoChaosKraken = false,
    AutoDeepseaCrusher = false,
    AutoDrakenfyr = false,

    -- ESP
    ESPPlayer = false,
    ESPFruit = false,
    ESPLegacyIsland = false,
    ESPHydraIsland = false,
    ESPGhostShip = false,

    -- Fruit / Key / Movement Extras
    BringAllFruits = false,
    AutoStoreFruit = false,
    InfGeppo = false,
    SelectedKey = "Copper Key",
    AutoBuyKey = false,
    AutoOpenKey = false,
    SelectedStockFruit = "DragonFruit",
    AutoBuyStockFruit = false,

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

local ActivateHaki, IsHakiActive
local _hakiState = {
    remotes = nil,
    activating = false,
    activatedChar = nil,
    activatedTime = 0,
    detectSupported = false,
    baselineChar = nil,
    limbColors = {},
    limbMaterials = {},
    visibleObjs = {},
    hoverActive = false,
    hoverPos = nil,
    hoverLook = nil,
    hoverRoot = nil,
    hoverConn = nil,
    lastCombatTick = 0,
    lastSimTick = 0,
    lastFarmPos = nil,
    lastFarmMobName = nil,
    lastBossPos = nil,
    lastMatPos = nil,
    lastOrbPos = nil,
    mobLevelCache = setmetatable({}, {__mode = "k"}),
    lastAttemptTime = 0,
    lastAttemptChar = nil,
    lastKenTick = 0,
    m1RemoteBusy = false,
    m1RemoteBusySince = 0,
    skillActionRemote = nil,
    getOfficialQuest = nil,
    skillAimbotHooked = false,
    origEffects = nil,
    friendCache = {},
    getDungeonFriendList = nil,
    parseDungeonFriends = nil,
    getDungeonFriendSummary = nil,
    dungeonOnRespawn = nil,
}

-- Update Character on respawn
Player.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    _hoverBV = nil
    _hoverBG = nil
    _hakiLastCheck = tick()
    if _hakiState.dungeonOnRespawn then
        pcall(_hakiState.dungeonOnRespawn)
    end
    if Settings.WalkSpeed and Settings.WalkSpeed ~= 16 then
        pcall(function() Humanoid.WalkSpeed = Settings.WalkSpeed end)
    end
    if Settings.JumpPower and Settings.JumpPower ~= 50 then
        pcall(function()
            Humanoid.UseJumpPower = true
            Humanoid.JumpPower = Settings.JumpPower
        end)
    end
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
    local containers = {
        Player:FindFirstChild("PlayerStats"),
        Player:FindFirstChild("Data"),
        Player:FindFirstChild("leaderstats"),
        Player:FindFirstChild("Stats"),
    }
    for _, stats in ipairs(containers) do
        if stats then
            for _, child in ipairs(stats:GetChildren()) do
                local lname = child.Name:lower()
                if lname == "level" or lname == "lvl" or lname == "lv" then
                    if child:IsA("IntValue") or child:IsA("NumberValue") then
                        if child.Value > 0 then return child.Value end
                    elseif child:IsA("StringValue") then
                        local n = tonumber(child.Value)
                        if n and n > 0 then return n end
                    end
                end
            end
        end
    end

    local attr = Player:GetAttribute("Level") or Player:GetAttribute("lvl") or Player:GetAttribute("Lvl")
    if type(attr) == "number" and attr > 0 then
        return attr
    end

    local playerGui = Player:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in ipairs(playerGui:GetDescendants()) do
            if gui:IsA("TextLabel") and gui.Visible then
                local txt = gui.Text
                local lv = txt:match("Lv%.?%s*(%d+)") or txt:match("Level%s*:?%s*(%d+)")
                if lv then
                    local n = tonumber(lv)
                    if n and n > 0 then return n end
                end
            end
        end
    end

    return 1
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

local function ExtractStatValue(obj, wantString)
    if wantString then
        if obj:IsA("StringValue") and obj.Value ~= "" and obj.Value ~= "None" then
            return obj.Value
        end
    else
        if obj:IsA("IntValue") or obj:IsA("NumberValue") then
            return obj.Value
        elseif obj:IsA("StringValue") then
            local clean = obj.Value:gsub(",", "")
            local num = tonumber(clean)
            if num then return num end
        end
    end
    return nil
end

local function GetStatByKeywords(exactNames, substringKeywords, wantString)
    local containers = {
        Player:FindFirstChild("PlayerStats"),
        Player:FindFirstChild("Data"),
        Player:FindFirstChild("leaderstats"),
        Player:FindFirstChild("Stats"),
    }

    -- Pass 1: exact name match on direct children and 1-level subfolders
    for _, container in ipairs(containers) do
        if container then
            for _, child in ipairs(container:GetChildren()) do
                local lname = child.Name:lower()
                for _, exact in ipairs(exactNames) do
                    if lname == exact then
                        local v = ExtractStatValue(child, wantString)
                        if v ~= nil then return v end
                    end
                end
                if child:IsA("Folder") or child:IsA("Configuration") then
                    for _, sub in ipairs(child:GetChildren()) do
                        local slname = sub.Name:lower()
                        for _, exact in ipairs(exactNames) do
                            if slname == exact then
                                local v = ExtractStatValue(sub, wantString)
                                if v ~= nil then return v end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Pass 2: substring fallback in PlayerStats / Data only
    for i = 1, 2 do
        local container = containers[i]
        if container then
            for _, obj in ipairs(container:GetDescendants()) do
                local lname = obj.Name:lower()
                for _, kw in ipairs(substringKeywords) do
                    if lname:find(kw, 1, true) then
                        local v = ExtractStatValue(obj, wantString)
                        if v ~= nil then return v end
                    end
                end
            end
        end
    end

    return nil
end

local function GetBeli()
    return GetStatByKeywords({"beli", "belis", "money", "belly"}, {"beli", "belly", "money", "cash", "gold"}, false) or 0
end

local function GetGems()
    return GetStatByKeywords({"gem", "gems"}, {"gem", "diamond"}, false) or 0
end

local function GetBounty()
    return GetStatByKeywords({"bounty", "honor"}, {"bounty", "honor"}, false) or 0
end

local function GetEquippedFruitName()
    return GetStatByKeywords({"devilfruit", "df", "fruit"}, {"devilfruit", "fruit"}, true) or "None"
end

local function FastTeleport(targetCFrame, instantLock)
    if not HumanoidRootPart or not HumanoidRootPart.Parent then return end
    if not Humanoid or not Humanoid.Parent then return end

    local dist = (HumanoidRootPart.Position - targetCFrame.Position).Magnitude

    if dist > 250 then
        task.spawn(function()
            pcall(function()
                Player:RequestStreamAroundAsync(targetCFrame.Position)
            end)
        end)
    end

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
    HumanoidRootPart.CFrame = targetCFrame

    if (Settings.InstantTP or instantLock) and dist > 80 then
        for _ = 1, 2 do
            RunService.Heartbeat:Wait()
            if not HumanoidRootPart or not HumanoidRootPart.Parent then break end
            resetVelocity()
            HumanoidRootPart.CFrame = targetCFrame
        end
    end

    if dist > 80 and Settings.TeleportDelay > 0 then
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
-- NPC INTERACTION (CACHED REMOTES)
-- =====================================================
local _questRemotes = nil
local function GetQuestRemotes()
    if _questRemotes then return _questRemotes end
    _questRemotes = {}
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local lname = remote.Name:lower()
            if lname:find("quest", 1, true) or lname:find("accept", 1, true) then
                table.insert(_questRemotes, remote)
            end
        end
    end
    return _questRemotes
end

local function InteractWithNPC(npcName)
    local npcs = {}
    local searchFolders = {
        Workspace:FindFirstChild("AllNPC"),
        Workspace:FindFirstChild("NPCs"),
        Workspace:FindFirstChild("NPC"),
        Workspace:FindFirstChild("QuestNPCs"),
    }
    local lowerNpc = npcName:lower()
    for _, folder in ipairs(searchFolders) do
        if folder then
            for _, obj in ipairs(folder:GetChildren()) do
                if obj.Name:lower():find(lowerNpc, 1, true) then
                    table.insert(npcs, obj)
                end
            end
        end
    end

    for _, remote in ipairs(GetQuestRemotes()) do
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

    for _, npc in ipairs(npcs) do
        if npc:IsA("Model") or npc:IsA("BasePart") then
            for _, desc in ipairs(npc:GetDescendants()) do
                if desc:IsA("ProximityPrompt") then
                    pcall(function() fireproximityprompt(desc) end)
                    task.wait(0.25)
                elseif desc:IsA("ClickDetector") then
                    pcall(function() fireclickdetector(desc) end)
                    task.wait(0.25)
                end
            end
        end
    end

    local playerGui = Player:FindFirstChild("PlayerGui")
    if playerGui then
        task.wait(0.15)
        for _, screen in ipairs(playerGui:GetChildren()) do
            local sname = screen.Name:lower()
            if sname:find("quest", 1, true) or sname:find("dialog", 1, true) or sname:find("talk", 1, true) or sname:find("npc", 1, true) then
                for _, gui in ipairs(screen:GetDescendants()) do
                    if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and gui.Visible then
                        local btnName = gui.Name:lower()
                        local btnText = gui:IsA("TextButton") and (gui.Text or ""):lower() or ""
                        if btnName:find("accept", 1, true) or btnName:find("confirm", 1, true) or btnName:find("yes", 1, true)
                            or btnText:find("accept", 1, true) or btnText:find("confirm", 1, true) or btnText:find("yes", 1, true) then
                            if typeof(firesignal) == "function" then
                                pcall(function() firesignal(gui.MouseButton1Click) end)
                                pcall(function() firesignal(gui.Activated) end)
                            end
                        end
                    end
                end
            end
        end
    end
    task.wait(0.25)
end

local function HasActiveQuest()
    local cq = Player:FindFirstChild("CurrentQuest")
    if cq and cq:IsA("StringValue") then
        local lv = (cq.Value or ""):lower()
        if lv ~= "" and lv ~= "none" and lv ~= "0" then
            return true
        end
    end

    local playerGui = Player:FindFirstChild("PlayerGui")
    if playerGui then
        for _, child in ipairs(playerGui:GetChildren()) do
            local lname = child.Name:lower()
            if lname:find("quest", 1, true) or lname:find("hud", 1, true) or lname:find("main", 1, true) then
                for _, gui in ipairs(child:GetDescendants()) do
                    if (gui:IsA("TextLabel") or gui:IsA("TextButton")) and gui.Visible then
                        local text = (gui.Text or ""):lower()
                        local parentQuest = gui.Parent and gui.Parent.Name:lower():find("quest", 1, true)
                        local grandQuest = (gui.Parent and gui.Parent.Parent) and gui.Parent.Parent.Name:lower():find("quest", 1, true)
                        if (text:find("defeat", 1, true) or text:find("eliminate", 1, true) or text:find("kill", 1, true)) and text:match("%d+") then
                            return true
                        elseif text:match("%d+%s*/%s*%d+") and (parentQuest or grandQuest) then
                            return true
                        elseif text:find("quest", 1, true) and (text:find("/", 1, true) or text:find("defeat", 1, true) or text:find("kill", 1, true)) then
                            return true
                        end
                    end
                end
            end
        end
    end

    for _, folderName in ipairs({"PlayerStats", "Data", "QuestData"}) do
        local data = Player:FindFirstChild(folderName)
        if data then
            for _, keyName in ipairs({"Quest", "QuestName", "CurrentQuest", "QuestActive"}) do
                local val = data:FindFirstChild(keyName)
                if val then
                    if val:IsA("StringValue") then
                        local lv = (val.Value or ""):lower()
                        if lv ~= "" and lv ~= "none" and lv ~= "0" then
                            return true
                        end
                    elseif val:IsA("BoolValue") and val.Value == true then
                        return true
                    elseif (val:IsA("IntValue") or val:IsA("NumberValue")) and val.Value > 0 then
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- =====================================================
-- FIND MOB / BOSS (CACHED LIVING MOB SCANNER)
-- =====================================================
local _cachedMobs = {}
local _cachedMobsTime = 0

local function ParseMobLevel(mob, hum)
    if _hakiState.mobLevelCache[mob] ~= nil then
        return _hakiState.mobLevelCache[mob] or nil
    end

    local function extractFromStr(str)
        if not str or str == "" then return nil end
        local lv = str:match("%[Lv%.?%s*(%d+)%]")
            or str:match("Lv%.?%s*(%d+)")
            or str:match("Level%s*:?%s*(%d+)")
        return lv and tonumber(lv) or nil
    end

    local parsed = extractFromStr(mob.Name)
    if not parsed and hum then
        parsed = extractFromStr(hum.DisplayName)
    end
    if not parsed then
        for _, key in ipairs({"Level", "Lv", "MobLevel"}) do
            local v = mob:FindFirstChild(key)
            if v and (v:IsA("IntValue") or v:IsA("NumberValue")) and v.Value > 0 then
                parsed = v.Value
                break
            end
        end
    end
    if not parsed then
        for _, subName in ipairs({"Data", "Stats", "Configuration"}) do
            local sub = mob:FindFirstChild(subName)
            if sub then
                for _, key in ipairs({"Level", "Lv", "MobLevel"}) do
                    local v = sub:FindFirstChild(key)
                    if v and (v:IsA("IntValue") or v:IsA("NumberValue")) and v.Value > 0 then
                        parsed = v.Value
                        break
                    end
                end
            end
            if parsed then break end
        end
    end
    if not parsed then
        local attr = mob:GetAttribute("Level") or mob:GetAttribute("Lv") or mob:GetAttribute("MobLevel")
        if type(attr) == "number" and attr > 0 then
            parsed = attr
        end
    end
    if not parsed then
        for _, desc in ipairs(mob:GetDescendants()) do
            if desc:IsA("TextLabel") then
                local n = extractFromStr(desc.Text)
                if n and n > 0 then
                    parsed = n
                    break
                end
            end
        end
    end

    _hakiState.mobLevelCache[mob] = parsed or false
    return parsed
end

local function GetLivingMobs()
    local now = tick()
    if now - _cachedMobsTime < 0.25 and #_cachedMobs > 0 then
        local stillAlive = {}
        for _, entry in ipairs(_cachedMobs) do
            if entry.mob and entry.mob.Parent and entry.hum and entry.hum.Health > 0 and entry.root and entry.root.Parent then
                table.insert(stillAlive, entry)
            end
        end
        if #stillAlive > 0 then
            _cachedMobs = stillAlive
            return _cachedMobs
        end
    end

    local results = {}
    local seen = {}
    local function addIfMob(obj, isBossHint)
        if not obj:IsA("Model") or seen[obj] or obj == Character then return end
        if Players:GetPlayerFromCharacter(obj) then return end
        local lname = obj.Name:lower()
        if lname:find("quest", 1, true) or lname:find("dealer", 1, true)
            or lname:find("shop", 1, true) or lname:find("gacha", 1, true)
            or lname:find("merchant", 1, true) then
            return
        end
        local hum = obj:FindFirstChildOfClass("Humanoid")
        local root = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
        if hum and root and hum.Health > 0 then
            seen[obj] = true
            local isBoss = isBossHint or lname:find("boss", 1, true) ~= nil
            table.insert(results, {
                mob = obj,
                hum = hum,
                root = root,
                lname = lname,
                isBoss = isBoss,
                level = ParseMobLevel(obj, hum),
            })
        end
    end

    local containers = {
        Workspace:FindFirstChild("Monster"),
        Workspace:FindFirstChild("Monsters"),
        Workspace:FindFirstChild("Mobs"),
        Workspace:FindFirstChild("Enemies"),
        Workspace:FindFirstChild("SeaMonster"),
        Workspace:FindFirstChild("SeaMonsters"),
    }

    local foundContainer = false
    for _, folder in ipairs(containers) do
        if folder then
            foundContainer = true
            for _, child in ipairs(folder:GetChildren()) do
                if child:IsA("Model") then
                    addIfMob(child, false)
                elseif child:IsA("Folder") then
                    local subBoss = child.Name:lower():find("boss", 1, true) ~= nil
                    for _, subChild in ipairs(child:GetChildren()) do
                        if subChild:IsA("Model") then
                            addIfMob(subChild, subBoss)
                        elseif subChild:IsA("Folder") then
                            for _, leaf in ipairs(subChild:GetChildren()) do
                                addIfMob(leaf, subBoss)
                            end
                        end
                    end
                end
            end
        end
    end

    if not foundContainer or #results == 0 then
        for _, child in ipairs(Workspace:GetChildren()) do
            if child:IsA("Model") then
                addIfMob(child, false)
            end
        end
    end

    _cachedMobs = results
    _cachedMobsTime = now
    return results
end

local function FindNearestMob(mobName, maxRange, playerLevel)
    Character = Player.Character
    HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart or not HumanoidRootPart.Parent then return nil end
    local rangeLimit = maxRange or Settings.FarmRange
    local living = GetLivingMobs()
    local targetLower = mobName and mobName:lower() or ""
    local playerPos = HumanoidRootPart.Position

    if playerLevel then
        -- Priority 1: Match active quest mob name from visible PlayerGui text
        local questTextLower = nil
        local playerGui = Player:FindFirstChild("PlayerGui")
        if playerGui then
            for _, screen in ipairs(playerGui:GetChildren()) do
                local sname = screen.Name:lower()
                if sname:find("quest", 1, true) or sname:find("hud", 1, true) or sname:find("main", 1, true) then
                    for _, gui in ipairs(screen:GetDescendants()) do
                        if (gui:IsA("TextLabel") or gui:IsA("TextButton")) and gui.Visible then
                            local txt = (gui.Text or ""):lower()
                            if txt:find("defeat", 1, true) or txt:find("eliminate", 1, true) or txt:find("kill", 1, true) or txt:match("%d+%s*/%s*%d+") then
                                questTextLower = (questTextLower and (questTextLower .. " ") or "") .. txt
                            end
                        end
                    end
                end
            end
        end

        if questTextLower then
            local qMob, qDist = nil, rangeLimit
            for _, entry in ipairs(living) do
                if not entry.isBoss then
                    local baseName = entry.lname:gsub("%[.-%]", ""):gsub("lv%.?%s*%d+", ""):match("^%s*(.-)%s*$") or ""
                    if #baseName >= 3 and questTextLower:find(baseName, 1, true) then
                        local dist = (playerPos - entry.root.Position).Magnitude
                        if dist < qDist then
                            qDist = dist
                            qMob = entry.mob
                        end
                    end
                end
            end
            if qMob then return qMob end
        end

        -- Priority 2: Best target level matching playerLevel from real in-game mobs
        local bestBelowLv, bestBelowDiff = nil, math.huge
        local bestAboveLv, bestAboveDiff = nil, math.huge
        for _, entry in ipairs(living) do
            if not entry.isBoss and entry.level then
                local dist = (playerPos - entry.root.Position).Magnitude
                if dist < rangeLimit then
                    if entry.level <= playerLevel then
                        local diff = playerLevel - entry.level
                        if diff < bestBelowDiff then
                            bestBelowDiff = diff
                            bestBelowLv = entry.level
                        end
                    elseif entry.level <= playerLevel + 25 then
                        local diff = entry.level - playerLevel
                        if diff < bestAboveDiff then
                            bestAboveDiff = diff
                            bestAboveLv = entry.level
                        end
                    end
                end
            end
        end
        local chosenLv = bestBelowLv or bestAboveLv
        if chosenLv then
            local lvMob, lvDist = nil, rangeLimit
            for _, entry in ipairs(living) do
                if not entry.isBoss and entry.level == chosenLv then
                    local dist = (playerPos - entry.root.Position).Magnitude
                    if dist < lvDist then
                        lvDist = dist
                        lvMob = entry.mob
                    end
                end
            end
            if lvMob then return lvMob end
        end
    end

    -- Priority 3: substring match by mobName
    local nearestMob, nearestDist = nil, rangeLimit
    if targetLower ~= "" then
        for _, entry in ipairs(living) do
            if entry.lname:find(targetLower, 1, true) then
                local dist = (playerPos - entry.root.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearestMob = entry.mob
                end
            end
        end
    end
    if nearestMob then return nearestMob end

    -- Priority 4: nearest non-boss living mob fallback
    if playerLevel then
        local anyMob, anyDist = nil, rangeLimit
        for _, entry in ipairs(living) do
            if not entry.isBoss then
                local dist = (playerPos - entry.root.Position).Magnitude
                if dist < anyDist then
                    anyDist = dist
                    anyMob = entry.mob
                end
            end
        end
        return anyMob
    end

    return nil
end

local function FindAllMobs(mobName, maxRange)
    local mobs = {}
    if not HumanoidRootPart or not HumanoidRootPart.Parent then return mobs end
    local limit = maxRange or Settings.BringRange
    local targetLower = mobName and mobName:lower() or ""
    local playerPos = HumanoidRootPart.Position

    for _, entry in ipairs(GetLivingMobs()) do
        if targetLower == "" or entry.lname:find(targetLower, 1, true) then
            local dist = (playerPos - entry.root.Position).Magnitude
            if dist < limit then
                table.insert(mobs, entry.mob)
            end
        end
    end
    return mobs
end

local function FindBoss(bossName)
    local bossLower = bossName:lower()
    for _, entry in ipairs(GetLivingMobs()) do
        if entry.lname:find(bossLower, 1, true) then
            return entry.mob
        end
    end
    for _, folder in ipairs({Workspace:FindFirstChild("Bosses"), Workspace:FindFirstChild("Boss")}) do
        if folder then
            for _, obj in ipairs(folder:GetDescendants()) do
                if obj:IsA("Model") and obj.Name:lower():find(bossLower, 1, true) then
                    local hum = obj:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then return obj end
                end
            end
        end
    end
    if not _selectedBoss then
        for _, entry in ipairs(GetLivingMobs()) do
            if entry.isBoss then
                return entry.mob
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

    if Settings.M1Method ~= "Remote" then
        -- === LAYER 1: Direct Tool API (primary) ===
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
    end

    -- === LAYER 3: Official King Legacy SkillAction remote (plus backup scan) ===
    if Settings.M1Method == "Remote" or Settings.M1Method == "Both" then
        if _hakiState.skillActionRemote == nil then
            local chest = ReplicatedStorage:FindFirstChild("Chest")
            local remotes = chest and chest:FindFirstChild("Remotes")
            local funcs = remotes and remotes:FindFirstChild("Functions")
            local sa = funcs and funcs:FindFirstChild("SkillAction")
            _hakiState.skillActionRemote = sa or false
        end
        local skillAction = _hakiState.skillActionRemote
        if skillAction and skillAction ~= false then
            if not _hakiState.m1RemoteBusy or (tick() - (_hakiState.m1RemoteBusySince or 0)) > 1.5 then
                _hakiState.m1RemoteBusy = true
                _hakiState.m1RemoteBusySince = tick()
                local tip = tool.ToolTip
                local prefix = (tip == "Sword" and "SW") or (tip == "Fruit Power" and "FP") or "FS"
                local actionName = prefix .. "_" .. tool.Name .. "_M1"
                task.spawn(function()
                    pcall(function()
                        skillAction:InvokeServer(actionName)
                    end)
                    _hakiState.m1RemoteBusy = false
                end)
            end
        else
            CacheCombatRemotes()
            for _, remote in ipairs(_combatRemotes) do
                pcall(function()
                    remote:FireServer()
                end)
            end
        end
    end
end

-- Get combat weapons (Melee / Sword / Fruit)
local function IsCombatWeaponTool(item)
    if not item or not item:IsA("Tool") then return false end
    local lname = item.Name:lower()
    for _, kw in ipairs({
        "dragon orb", "orb", "key", "torch", "cup", "ticket", "scroll",
        "carrot", "log", "pile", "pearl", "artifact", "compass", "map",
        "book", "chalice", "flower",
    }) do
        if lname:find(kw, 1, true) then
            return false
        end
    end
    return true
end

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
            if container then
                for _, item in ipairs(container:GetChildren()) do
                    if IsCombatWeaponTool(item) and not seen[item.Name] then
                        seen[item.Name] = true
                        table.insert(tools, item)
                    end
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
                    if IsCombatWeaponTool(item) then
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
        for _, container in ipairs({char, Player.Backpack}) do
            if container then
                for _, item in ipairs(container:GetChildren()) do
                    if IsCombatWeaponTool(item) then
                        targetTool = item
                        break
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
    BackgroundM1_Safe()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(9999, 9999))
    end)
end

local SkillHoldOrder = {"Z", "X", "C", "V", "B", "E"}

local function UseCombo()
    if not Settings.AutoCombo then return end
    if UIS:GetFocusedTextBox() then return end
    if _hakiState.comboRunning then return end
    local now = tick()
    if now - _lastComboTime < Settings.ComboCD then return end
    _lastComboTime = now
    _hakiState.comboRunning = true

    task.spawn(function()
        pcall(function()
            for _, key in ipairs(SkillHoldOrder) do
                if not _running or not Settings.AutoCombo or UIS:GetFocusedTextBox() then break end
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
        end)
        _hakiState.comboRunning = false
    end)
end

-- =====================================================
-- HOVER LOCK (60-FPS HEARTBEAT HOVER + SAFE LOOKAT)
-- =====================================================
local function SafeLookAt(fromPos, lookPos)
    local dx = lookPos.X - fromPos.X
    local dz = lookPos.Z - fromPos.Z
    if (dx * dx + dz * dz) < 0.04 then
        lookPos = Vector3.new(fromPos.X, lookPos.Y, fromPos.Z - 0.35)
    end
    return CFrame.lookAt(fromPos, lookPos)
end

local function EnableHoverLock(hoverPos, lookAtPos, targetRoot)
    Character = Player.Character
    HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
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

    _hakiState.hoverPos = hoverPos
    _hakiState.hoverLook = lookAtPos
    _hakiState.hoverRoot = targetRoot
    _hakiState.hoverActive = true

    if not _hakiState.getHoverOffset then
        _hakiState.getHoverOffset = function()
            local posMode = Settings.FarmPosition or "Above"
            local dist = Settings.HoverHeight or 14
            if posMode == "Beside" then
                return Vector3.new(0, 2, math.clamp(dist, 6, 25))
            elseif posMode == "Lower" then
                return Vector3.new(0, -math.clamp(dist, 6, 18), 0)
            end
            return Vector3.new(0, dist, 0)
        end
    end

    if not _hakiState.hoverConn then
        _hakiState.hoverConn = RunService.Heartbeat:Connect(function()
            if not _running then
                if _hakiState.hoverConn then
                    _hakiState.hoverConn:Disconnect()
                    _hakiState.hoverConn = nil
                end
                return
            end
            if not _hakiState.hoverActive or Settings.AutoDungeon then return end
            local char = Player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not char or not hrp then return end

            local pos = _hakiState.hoverPos
            local look = _hakiState.hoverLook
            local tRoot = _hakiState.hoverRoot
            if tRoot and tRoot.Parent then
                local tModel = tRoot.Parent
                local tHum = tModel and tModel:FindFirstChildOfClass("Humanoid")
                if not tHum or tHum.Health > 0 then
                    look = tRoot.Position
                    pos = look + _hakiState.getHoverOffset()
                    _hakiState.hoverPos = pos
                    _hakiState.hoverLook = look
                    if typeof(getgenv) == "function" then
                        pcall(function() getgenv().PosMonSkill = tRoot.CFrame end)
                    end
                end
            end
            if not pos or not look then return end

            local cf = Settings.LockLookAtMob and SafeLookAt(pos, look) or CFrame.new(pos)
            hrp.Velocity = Vector3.zero
            hrp.RotVelocity = Vector3.zero
            hrp.CFrame = cf
            if _hoverBG and _hoverBG.Parent then
                _hoverBG.CFrame = cf
            end
            if _hoverBV and _hoverBV.Parent then
                _hoverBV.Velocity = Vector3.zero
            end
        end)
    end

    local lockedCF = Settings.LockLookAtMob and SafeLookAt(hoverPos, lookAtPos) or CFrame.new(hoverPos)
    HumanoidRootPart.Velocity = Vector3.zero
    HumanoidRootPart.RotVelocity = Vector3.zero
    HumanoidRootPart.CFrame = lockedCF
    _hoverBG.CFrame = lockedCF

    for _, part in ipairs(Character:GetChildren()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end

local function DisableHoverLock()
    _hakiState.hoverActive = false
    _hakiState.hoverRoot = nil
    _hakiState.hoverPos = nil
    _hakiState.hoverLook = nil
    if typeof(getgenv) == "function" then
        pcall(function() getgenv().PosMonSkill = nil end)
    end

    Character = Player.Character
    HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")

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

    if not Settings.AutoDungeon and Character and Character.Parent then
        for _, partName in ipairs({"HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso", "Head"}) do
            local p = Character:FindFirstChild(partName)
            if p and p:IsA("BasePart") then
                p.CanCollide = true
            end
        end
    end
end

-- =====================================================
-- AUTO ARMAMENT HAKI
-- =====================================================
do
    local limbNames = {
        "Right Arm", "Left Arm",
        "RightHand", "LeftHand",
        "RightLowerArm", "LeftLowerArm",
        "RightUpperArm", "LeftUpperArm",
        "Right Leg", "Left Leg",
    }
    local armNames = {
        ["Right Arm"] = "R", ["Left Arm"] = "L",
        ["RightHand"] = "R", ["LeftHand"] = "L",
        ["RightLowerArm"] = "R", ["LeftLowerArm"] = "L",
    }
    local activeFlagNames = {
        "BusoActive", "HakiActive", "ArmamentActive",
        "UsingBuso", "UsingHaki", "BusoOn", "HakiOn",
    }

    local function isExcludedHakiName(lname)
        return lname:find("ken", 1, true)
            or lname:find("observ", 1, true)
            or lname:find("conquer", 1, true)
            or lname:find("hao", 1, true)
    end

    local function matchesBusoAttr(name)
        local lname = tostring(name):lower()
        if isExcludedHakiName(lname) then return false end
        return lname:find("buso", 1, true)
            or lname:find("armament", 1, true)
            or lname:find("busoshoku", 1, true)
            or lname:find("aura", 1, true)
            or lname:find("haki", 1, true)
    end

    local function matchesBusoDesc(name)
        local lname = tostring(name):lower()
        if isExcludedHakiName(lname) then return false end
        return lname:find("buso", 1, true)
            or lname:find("armament", 1, true)
            or lname:find("busoshoku", 1, true)
            or lname:find("aura", 1, true)
            or lname:find("coating", 1, true)
            or lname:find("haki", 1, true)
    end

    local function isTruthyVal(val)
        local t = typeof(val)
        if t == "boolean" then
            return val == true
        elseif t == "number" then
            return val > 0
        elseif t == "string" then
            local lv = val:lower()
            return lv ~= "" and lv ~= "0" and lv ~= "false" and lv ~= "off" and lv ~= "none"
        end
        return false
    end

    local function colorDistance(c1, c2)
        local dr = c1.R - c2.R
        local dg = c1.G - c2.G
        local db = c1.B - c2.B
        return math.sqrt(dr * dr + dg * dg + db * db)
    end

    local function isUnderTool(inst, stopRoot)
        local cur = inst.Parent
        while cur and cur ~= stopRoot do
            if cur:IsA("Tool") then return true end
            cur = cur.Parent
        end
        return false
    end

    local function CheckPositiveHakiIndicators(char)
        if not char then return false end

        for _, target in ipairs({char, Player}) do
            local ok, attrs = pcall(function() return target:GetAttributes() end)
            if ok and type(attrs) == "table" then
                for k, v in pairs(attrs) do
                    if matchesBusoAttr(k) and isTruthyVal(v) then
                        return true
                    end
                end
            end
        end

        for _, desc in ipairs(char:GetDescendants()) do
            if desc:IsA("Highlight") and desc.Enabled then
                return true
            end
            if matchesBusoDesc(desc.Name) then
                if desc:IsA("BoolValue") then
                    if desc.Value == true then return true end
                elseif desc:IsA("IntValue") or desc:IsA("NumberValue") then
                    if desc.Value > 0 then return true end
                elseif desc:IsA("StringValue") then
                    if isTruthyVal(desc.Value) then return true end
                elseif desc:IsA("ParticleEmitter") or desc:IsA("Sparkles") or desc:IsA("Beam")
                    or desc:IsA("Trail") or desc:IsA("Fire") or desc:IsA("Smoke") then
                    if desc.Enabled then return true end
                elseif desc:IsA("BasePart") or desc:IsA("MeshPart") or desc:IsA("UnionOperation")
                    or desc:IsA("Decal") or desc:IsA("Texture") then
                    if desc.Transparency < 0.95 then return true end
                elseif desc:IsA("SpecialMesh") or desc:IsA("SurfaceAppearance") then
                    if desc.Parent and desc.Parent:IsA("BasePart") and desc.Parent.Transparency < 0.95 then
                        return true
                    end
                elseif desc:IsA("Model") or desc:IsA("Folder") or desc:IsA("Accessory") then
                    for _, sub in ipairs(desc:GetDescendants()) do
                        if (sub:IsA("BasePart") and sub.Transparency < 0.95)
                            or ((sub:IsA("ParticleEmitter") or sub:IsA("Highlight")) and sub.Enabled) then
                            return true
                        end
                    end
                end
            end
        end

        local head = char:FindFirstChild("Head")
        local bodyColors = char:FindFirstChildOfClass("BodyColors")
        for _, limbName in ipairs(limbNames) do
            local limb = char:FindFirstChild(limbName)
            if limb and limb:IsA("BasePart") then
                for _, child in ipairs(limb:GetChildren()) do
                    if (child:IsA("BasePart") or child:IsA("MeshPart") or child:IsA("UnionOperation")
                        or child:IsA("Decal") or child:IsA("Texture")) and child.Transparency < 0.95 then
                        return true
                    elseif (child:IsA("Highlight") or child:IsA("ParticleEmitter")) and child.Enabled then
                        return true
                    elseif child:IsA("SurfaceAppearance") then
                        return true
                    end
                end

                local side = armNames[limbName]
                if side then
                    if (limb.Material == Enum.Material.Neon or limb.Material == Enum.Material.ForceField
                        or limb.Material == Enum.Material.Metal or limb.Material == Enum.Material.Glass)
                        and (not head or not head:IsA("BasePart") or limb.Material ~= head.Material) then
                        return true
                    end
                    if bodyColors then
                        local baseColor = (side == "R") and bodyColors.RightArmColor3 or bodyColors.LeftArmColor3
                        if colorDistance(limb.Color, baseColor) > 0.08 then
                            return true
                        end
                    end
                    if head and head:IsA("BasePart") then
                        if limb.Color.R < 0.15 and limb.Color.G < 0.15 and limb.Color.B < 0.15
                            and (head.Color.R > 0.25 or head.Color.G > 0.25 or head.Color.B > 0.25) then
                            return true
                        end
                    end
                end
            end
        end

        for _, containerName in ipairs({"Data", "PlayerStats"}) do
            local stats = Player:FindFirstChild(containerName)
            if stats then
                for _, flagName in ipairs(activeFlagNames) do
                    local flag = stats:FindFirstChild(flagName)
                    if flag then
                        if flag:IsA("BoolValue") and flag.Value == true then
                            return true
                        elseif (flag:IsA("IntValue") or flag:IsA("NumberValue")) and flag.Value > 0 then
                            return true
                        end
                    end
                end
            end
        end

        return false
    end

    local function CaptureHakiBaseline(char)
        if not char then return end
        _hakiState.baselineChar = char
        _hakiState.limbColors = {}
        _hakiState.limbMaterials = {}
        _hakiState.visibleObjs = {}

        for _, limbName in ipairs(limbNames) do
            local limb = char:FindFirstChild(limbName)
            if limb and limb:IsA("BasePart") then
                _hakiState.limbColors[limb] = limb.Color
                _hakiState.limbMaterials[limb] = limb.Material
            end
        end

        for _, desc in ipairs(char:GetDescendants()) do
            local dName = desc.Name
            if dName ~= "KL_HoverBV" and dName ~= "KL_HoverBG" and dName ~= "KL_DungeonBV" and not isUnderTool(desc, char) then
                if ((desc:IsA("BasePart") or desc:IsA("MeshPart") or desc:IsA("UnionOperation")
                    or desc:IsA("Decal") or desc:IsA("Texture")) and desc.Transparency < 0.95)
                    or ((desc:IsA("Highlight") or desc:IsA("ParticleEmitter")) and desc.Enabled) then
                    _hakiState.visibleObjs[desc] = true
                end
            end
        end
    end

    local function HasHakiBaselineDiff(char)
        if not char or _hakiState.baselineChar ~= char then return false end
        for limb, oldColor in pairs(_hakiState.limbColors) do
            if limb and limb.Parent == char then
                if colorDistance(limb.Color, oldColor) > 0.05 then
                    return true
                end
                if limb.Material ~= _hakiState.limbMaterials[limb] then
                    return true
                end
            end
        end
        for _, desc in ipairs(char:GetDescendants()) do
            local dName = desc.Name
            if dName ~= "KL_HoverBV" and dName ~= "KL_HoverBG" and dName ~= "KL_DungeonBV" and not isUnderTool(desc, char) then
                if not _hakiState.visibleObjs[desc] then
                    if ((desc:IsA("BasePart") or desc:IsA("MeshPart") or desc:IsA("UnionOperation")
                        or desc:IsA("Decal") or desc:IsA("Texture")) and desc.Transparency < 0.95)
                        or ((desc:IsA("Highlight") or desc:IsA("ParticleEmitter")) and desc.Enabled) then
                        return true
                    end
                end
            end
        end
        return false
    end

    local function GetHakiRemotes()
        if _hakiState.remotes then return _hakiState.remotes end
        _hakiState.remotes = {}
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                local n = remote.Name:lower()
                local isBuso = n:find("buso", 1, true) or n:find("armament", 1, true) or n:find("haki", 1, true)
                local isExcluded = n:find("ken", 1, true) or n:find("observ", 1, true)
                    or n:find("buy", 1, true) or n:find("shop", 1, true)
                    or n:find("color", 1, true) or n:find("colour", 1, true)
                    or n:find("dealer", 1, true) or n:find("quest", 1, true)
                    or n:find("stat", 1, true) or n:find("upgrade", 1, true)
                    or n:find("reroll", 1, true) or n:find("conquer", 1, true)
                    or n:find("hao", 1, true)
                if isBuso and not isExcluded then
                    table.insert(_hakiState.remotes, remote)
                end
            end
        end
        return _hakiState.remotes
    end

    IsHakiActive = function(char)
        if not char then return false end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then
            if _hakiState.activatedChar == char then
                _hakiState.activatedChar = nil
            end
            return false
        end

        local services = char:FindFirstChild("Services")
        local hakiVal = services and services:FindFirstChild("Haki")
        if hakiVal and (hakiVal:IsA("IntValue") or hakiVal:IsA("NumberValue")) then
            _hakiState.detectSupported = true
            if hakiVal.Value >= 1 then
                _hakiState.activatedChar = char
                return true
            end
            if _hakiState.activatedChar == char then
                _hakiState.activatedChar = nil
            end
            return false
        end

        if CheckPositiveHakiIndicators(char) or (_hakiState.baselineChar == char and HasHakiBaselineDiff(char)) then
            _hakiState.activatedChar = char
            _hakiState.detectSupported = true
            return true
        end

        if _hakiState.activatedChar == char then
            if (tick() - _hakiState.activatedTime) < 4.0 then
                return true
            end
            if not _hakiState.detectSupported then
                return true
            end
        end

        return false
    end

    ActivateHaki = function()
        if _hakiState.activating then return end
        local char = Player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not char or not hum or hum.Health <= 0 then return end
        if IsHakiActive(char) then return end
        if _hakiState.lastAttemptChar == char and (tick() - (_hakiState.lastAttemptTime or 0)) < 2.5 then
            return
        end

        _hakiState.activating = true
        _hakiState.lastAttemptChar = char
        _hakiState.lastAttemptTime = tick()
        _hakiLastCheck = tick()

        if _hakiState.baselineChar ~= char then
            CaptureHakiBaseline(char)
        end

        local detected = false

        -- Primary: Official King Legacy Armament remote
        local chest = ReplicatedStorage:FindFirstChild("Chest")
        local remotes = chest and chest:FindFirstChild("Remotes")
        local events = remotes and remotes:FindFirstChild("Events")
        local armament = events and events:FindFirstChild("Armament")
        if armament then
            pcall(function()
                local stats = Player:FindFirstChild("PlayerStats")
                local busoVal = stats and stats:FindFirstChild("BusoShopValue")
                if busoVal and busoVal:IsA("StringValue") then
                    busoVal.Value = "BusoHaki"
                end
                armament:FireServer()
            end)
            task.wait(0.4)
            if IsHakiActive(char) or CheckPositiveHakiIndicators(char) or HasHakiBaselineDiff(char) then
                detected = true
            end
        end

        -- Fallback 1: Hotkey
        if not detected and not UIS:GetFocusedTextBox() then
            local keyCode = Enum.KeyCode[Settings.HakiKey] or Enum.KeyCode.G
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
            end)
            task.wait(0.55)
            if IsHakiActive(char) or CheckPositiveHakiIndicators(char) or HasHakiBaselineDiff(char) then
                detected = true
            end
        end

        -- Fallback 2: Scanned Buso remotes
        if not detected then
            for _, remote in ipairs(GetHakiRemotes()) do
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer()
                    else
                        remote:InvokeServer()
                    end
                end)
                task.wait(0.35)
                if IsHakiActive(char) or CheckPositiveHakiIndicators(char) or HasHakiBaselineDiff(char) then
                    detected = true
                    break
                end
            end
        end

        if detected or not (char:FindFirstChild("Services") and char.Services:FindFirstChild("Haki")) then
            _hakiState.activatedChar = char
            _hakiState.activatedTime = tick()
        end
        if detected then
            _hakiState.detectSupported = true
        end
        _hakiLastCheck = tick()
        _hakiState.activating = false
    end
end

-- =====================================================
-- BRING MOB
-- =====================================================
local function BringMobs(mobName, anchorPos)
    if not Settings.BringMob then return 0 end
    Character = Player.Character
    HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart or not HumanoidRootPart.Parent then return 0 end

    local bringLimit = math.min(Settings.BringRange or 350, 350)
    local mobs = FindAllMobs(mobName, math.max(Settings.BringRange or 500, 500))
    local playerPos = HumanoidRootPart.Position
    local isHovering = HumanoidRootPart:FindFirstChild("KL_HoverBV") ~= nil
    local centerPos = anchorPos or Vector3.new(
        playerPos.X,
        playerPos.Y - ((Settings.HoverFarm and isHovering) and Settings.HoverHeight or 0),
        playerPos.Z
    )

    local now = tick()
    if (now - (_hakiState.lastSimTick or 0)) >= 2.0 then
        _hakiState.lastSimTick = now
        if typeof(sethiddenproperty) == "function" then
            pcall(sethiddenproperty, Player, "SimulationRadius", math.huge)
        end
    end

    local brought = 0
    for _, mob in ipairs(mobs) do
        if brought >= 10 then break end
        pcall(function()
            local root = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
            local hum = mob:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then
                local dist = (root.Position - centerPos).Magnitude
                if dist <= bringLimit then
                    if dist > 2 then
                        root.CFrame = CFrame.new(centerPos)
                    end
                    hum.WalkSpeed = 0
                    hum.JumpPower = 0
                    root.Size = Vector3.new(28, 28, 28)
                    root.Transparency = 0.8
                    root.CanCollide = false
                    root.Velocity = Vector3.zero
                    root.RotVelocity = Vector3.zero
                    pcall(function()
                        root.AssemblyLinearVelocity = Vector3.zero
                        root.AssemblyAngularVelocity = Vector3.zero
                    end)
                    brought = brought + 1
                end
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
    Character = Player.Character
    HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    local humanoid = mob:FindFirstChildOfClass("Humanoid")
    local rootPart = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
    if not humanoid or humanoid.Health <= 0 or not rootPart then return false end

    _hakiState.lastCombatTick = tick()

    pcall(function()
        rootPart.Size = Vector3.new(28, 28, 28)
        rootPart.Transparency = 0.8
        rootPart.CanCollide = false
    end)

    local mobPos = rootPart.Position
    if typeof(getgenv) == "function" then
        pcall(function() getgenv().PosMonSkill = rootPart.CFrame end)
    end

    -- Position relative to mob (Above / Beside / Lower) + Lock character face toward mob
    if Settings.HoverFarm then
        local offset = _hakiState.getHoverOffset and _hakiState.getHoverOffset() or Vector3.new(0, Settings.HoverHeight, 0)
        local hoverPos = mobPos + offset
        EnableHoverLock(hoverPos, mobPos, rootPart)
    else
        DisableHoverLock()
        if Settings.BringMob then
            if HumanoidRootPart and HumanoidRootPart.Parent then
                HumanoidRootPart.CFrame = SafeLookAt(HumanoidRootPart.Position, mobPos)
            end
        else
            local targetCFrame = rootPart.CFrame * CFrame.new(0, 0, -Settings.AttackRange * 0.3)
            if HumanoidRootPart and HumanoidRootPart.Parent then
                HumanoidRootPart.CFrame = SafeLookAt(targetCFrame.Position, mobPos)
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
    "IslandQuestRepeat", "X100KSuccess", "FruitAwakeningTime", "Halloween2024",
    "Update7.1", "DragonColorRefund", "PlayKingLegacyFor5Gems", "RainbowDragon",
    "<3LEEPUNGG", "Update7.0.4", "SKGames", "PassiveMaster",
    "InfernoKingAwaits", "Update7Release", "TelekinesisFruitPower", "EpicAdventure",
    "WELCOMETOKINGLEGACY", "FREESTATSRESET", "DinoxLive", "2MFAV", "Peodiz",
}

local function RedeemCode(code)
    if not code or code == "" then return false end
    local chest = ReplicatedStorage:FindFirstChild("Chest")
    local remotes = chest and chest:FindFirstChild("Remotes")
    local funcs = remotes and remotes:FindFirstChild("Functions")
    local officialRedeem = funcs and funcs:FindFirstChild("redeemcode")
    if officialRedeem and officialRedeem:IsA("RemoteFunction") then
        local ok = pcall(function()
            officialRedeem:InvokeServer(code)
        end)
        if ok then return true end
    end

    if not _hakiState.codeRemotes then
        _hakiState.codeRemotes = {}
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                local n = remote.Name:lower()
                if n:find("code") or n:find("redeem") then
                    table.insert(_hakiState.codeRemotes, remote)
                end
            end
        end
    end
    local fired = false
    for _, remote in ipairs(_hakiState.codeRemotes) do
        pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer(code)
            else
                remote:InvokeServer(code)
            end
            fired = true
        end)
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
                local pg = Player:FindFirstChild("PlayerGui")
                local mg = pg and pg:FindFirstChild("MainGui")
                local sf = mg and mg:FindFirstChild("StarterFrame")
                local statsFrame = sf and sf:FindFirstChild("StatsFrame")
                local officialStatRemote = statsFrame and statsFrame:FindFirstChild("RemoteEvent")
                if officialStatRemote and officialStatRemote:IsA("RemoteEvent") then
                    for _, statName in ipairs(Settings.StatsList) do
                        pcall(function()
                            officialStatRemote:FireServer(statName, Settings.StatsPoints)
                        end)
                    end
                    return
                end

                if not _hakiState.statRemotes then
                    _hakiState.statRemotes = {}
                    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                            local n = remote.Name:lower()
                            if n:find("stat") or n:find("point") or n:find("addpoint") then
                                table.insert(_hakiState.statRemotes, remote)
                            end
                        end
                    end
                end
                for _, remote in ipairs(_hakiState.statRemotes) do
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
                if not char then return end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then return end
                local services = char:FindFirstChild("Services")
                local kenObj = services and services:FindFirstChild("KenHaki")
                local kenOff = false
                if kenObj then
                    if kenObj:IsA("BoolValue") then
                        kenOff = not kenObj.Value
                    elseif kenObj:IsA("IntValue") or kenObj:IsA("NumberValue") then
                        kenOff = kenObj.Value == 0
                    elseif kenObj:IsA("ValueBase") then
                        kenOff = not kenObj.Value
                    end
                else
                    kenOff = not char:FindFirstChild("Ken") and not char:FindFirstChild("Observation")
                end
                if kenOff and not UIS:GetFocusedTextBox() and (tick() - (_hakiState.lastKenTick or 0)) >= 2.0 then
                    _hakiState.lastKenTick = tick()
                    pcall(function()
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Y, false, game)
                        task.wait(0.05)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Y, false, game)
                    end)
                end
            end)
        end

        if Settings.AutoRandomFruit then
            pcall(function()
                if not _hakiState.gachaRemotes then
                    _hakiState.gachaRemotes = {}
                    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                            local n = remote.Name:lower()
                            if n:find("fruit") and (n:find("random") or n:find("gacha") or n:find("buy") or n:find("spin")) then
                                table.insert(_hakiState.gachaRemotes, remote)
                            end
                        end
                    end
                end
                for _, remote in ipairs(_hakiState.gachaRemotes) do
                    pcall(function()
                        if remote:IsA("RemoteEvent") then remote:FireServer() else remote:InvokeServer() end
                    end)
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

-- Activities Loop (Full A-Z Auto Dungeon + Friends Co-op + Sea Events)
do
    local dState = {
        activeTween = nil,
        steppedConn = nil,
        inCombatRange = false,
        currentMob = nil,
        evadingLowHP = false,
        mobCache = nil,
        mobCacheRoot = nil,
        mobCacheTime = 0,
        padCache = nil,
        padCacheTime = 0,
        origCanCollide = {},
        wasActive = false,
        waitingAnchor = nil,
        friendCheckPending = {},
    }

    local npcExcludeFolders = {
        AllNPC = true, NPCs = true, NPC = true, QuestNPCs = true, Shop = true, Shops = true,
    }

    local function isPlayerRobloxFriend(p, allowYield)
        if not p or p == Player then return false end
        local uid = p.UserId
        local cached = _hakiState.friendCache[uid]
        if cached ~= nil then
            return cached
        end
        if allowYield then
            local ok, res = pcall(function() return Player:IsFriendsWith(uid) end)
            cached = (ok and res == true) or false
            _hakiState.friendCache[uid] = cached
            return cached
        elseif not dState.friendCheckPending[uid] then
            dState.friendCheckPending[uid] = true
            task.spawn(function()
                local ok, res = pcall(function() return Player:IsFriendsWith(uid) end)
                _hakiState.friendCache[uid] = (ok and res == true) or false
                dState.friendCheckPending[uid] = nil
            end)
        end
        return false
    end

    local function stripFriendTag(name)
        return tostring(name or ""):gsub("%s*%[Friend%]$", "")
    end

    local function parseDungeonFriends(val)
        local list = {}
        local seen = {}
        local function addName(raw)
            local clean = stripFriendTag(raw):match("^%s*(.-)%s*$")
            if clean and clean ~= "" and clean ~= "None" and not seen[clean] then
                seen[clean] = true
                table.insert(list, clean)
            end
        end
        if type(val) == "string" then
            addName(val)
        elseif type(val) == "table" then
            for k, v in pairs(val) do
                if type(k) == "number" and type(v) == "string" then
                    addName(v)
                elseif type(k) == "string" and v == true then
                    addName(k)
                end
            end
        end
        return list
    end
    _hakiState.parseDungeonFriends = parseDungeonFriends

    local function getDungeonFriendList()
        local friendEntries, otherEntries = {}, {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= Player then
                if isPlayerRobloxFriend(p, true) then
                    table.insert(friendEntries, p.Name .. " [Friend]")
                else
                    table.insert(otherEntries, p.Name)
                end
            end
        end
        table.sort(friendEntries)
        table.sort(otherEntries)
        local merged = {}
        for _, v in ipairs(friendEntries) do table.insert(merged, v) end
        for _, v in ipairs(otherEntries) do table.insert(merged, v) end
        if #merged == 0 then
            return {"None"}
        end
        return merged
    end
    _hakiState.getDungeonFriendList = getDungeonFriendList

    local function getActiveDungeonFriendTargets()
        local targets = {}
        local seen = {}

        if type(Settings.DungeonFriends) == "table" then
            for _, uname in ipairs(Settings.DungeonFriends) do
                local clean = stripFriendTag(uname)
                if clean ~= "" and clean ~= "None" and not seen[clean] then
                    local p = Players:FindFirstChild(clean)
                    if p and p ~= Player then
                        seen[clean] = true
                        table.insert(targets, p)
                    end
                end
            end
        end

        if Settings.DungeonPartner and Settings.DungeonPartner ~= "" and Settings.DungeonPartner ~= "None" then
            local clean = stripFriendTag(Settings.DungeonPartner)
            if not seen[clean] then
                local p = Players:FindFirstChild(clean)
                if p and p ~= Player then
                    seen[clean] = true
                    table.insert(targets, p)
                end
            end
        end

        if Settings.DungeonAutoFriends then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= Player and not seen[p.Name] and isPlayerRobloxFriend(p, false) then
                    seen[p.Name] = true
                    table.insert(targets, p)
                end
            end
        end

        return targets
    end

    local function getDungeonFriendSummary()
        if not Settings.DungeonPartnerMode then
            return "OFF (Solo)"
        end
        local targets = getActiveDungeonFriendTargets()
        if #targets == 0 then
            return Settings.DungeonAutoFriends and "ON (No friends online)" or "ON (No friend selected)"
        end
        local names = {}
        for i, p in ipairs(targets) do
            if i <= 2 then
                table.insert(names, p.Name)
            end
        end
        if #targets > 2 then
            return string.format("ON (%s +%d)", table.concat(names, ", "), #targets - 2)
        end
        return string.format("ON (%s)", table.concat(names, ", "))
    end
    _hakiState.getDungeonFriendSummary = getDungeonFriendSummary

    local function cleanupDungeon()
        pcall(function()
            if dState.activeTween then
                dState.activeTween:Cancel()
                dState.activeTween = nil
            end
        end)
        dState.inCombatRange = false
        dState.currentMob = nil
        dState.mobCache = nil
        dState.mobCacheRoot = nil
        dState.mobCacheTime = 0
        dState.evadingLowHP = false
        dState.waitingAnchor = nil
        if typeof(getgenv) == "function" then
            pcall(function() getgenv().PosMonSkill = nil end)
        end

        local char = Player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bv = hrp:FindFirstChild("KL_DungeonBV")
                if bv then bv:Destroy() end
            end
            for _, partName in ipairs({"HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso", "Head"}) do
                local p = char:FindFirstChild(partName)
                if p and p:IsA("BasePart") then
                    p.CanCollide = true
                end
            end
        end
        for part, orig in pairs(dState.origCanCollide) do
            if part and part.Parent then
                pcall(function() part.CanCollide = orig end)
            end
        end
        dState.origCanCollide = {}
        Settings.DungeonStatus = "Idle"
    end
    Settings.CleanupDungeon = cleanupDungeon

    _hakiState.dungeonOnRespawn = function()
        pcall(function()
            if dState.activeTween then
                dState.activeTween:Cancel()
                dState.activeTween = nil
            end
        end)
        dState.inCombatRange = false
        dState.currentMob = nil
        dState.mobCache = nil
        dState.mobCacheRoot = nil
        dState.evadingLowHP = false
        dState.origCanCollide = {}
    end

    local function isShopOrNpcModel(model)
        local n = model.Name:lower()
        return n:find("quest", 1, true)
            or n:find("dealer", 1, true)
            or n:find("shop", 1, true)
            or n:find("gacha", 1, true)
            or n:find("merchant", 1, true)
    end

    local function isUnderBlacklistedFolder(inst)
        local cur = inst.Parent
        while cur and cur ~= Workspace do
            if npcExcludeFolders[cur.Name] then
                return true
            end
            cur = cur.Parent
        end
        return false
    end

    local function scanDungeonMobFolder(container, char, best, maxDepth, depth)
        depth = depth or 0
        if not container or npcExcludeFolders[container.Name] then return end
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("Model") then
                if child ~= char and not Players:GetPlayerFromCharacter(child)
                    and not isUnderBlacklistedFolder(child) and not isShopOrNpcModel(child) then
                    local hum = child:FindFirstChildOfClass("Humanoid")
                    local root = child:FindFirstChild("HumanoidRootPart") or child.PrimaryPart
                    if hum and root and hum.Health > 0 then
                        local dist = (root.Position - best.origin).Magnitude
                        if dist < best.dist then
                            best.mob = child
                            best.root = root
                            best.dist = dist
                        end
                    end
                end
            elseif depth < (maxDepth or 1) and (child:IsA("Folder") or child:IsA("Configuration")) and not npcExcludeFolders[child.Name] then
                scanDungeonMobFolder(child, char, best, maxDepth, depth + 1)
            end
        end
    end

    local function GetClosestDungeonMob()
        local char = Player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not char or not hrp then return nil, nil, math.huge end

        local now = tick()
        if dState.mobCache and dState.mobCache.Parent and dState.mobCacheRoot and dState.mobCacheRoot.Parent then
            local hum = dState.mobCache:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and (now - dState.mobCacheTime) < 0.2 then
                return dState.mobCache, dState.mobCacheRoot, (dState.mobCacheRoot.Position - hrp.Position).Magnitude
            end
        end

        local best = {mob = nil, root = nil, dist = math.huge, origin = hrp.Position}
        for _, folderName in ipairs({"MOB", "Monster", "Monsters", "Mobs", "Enemies", "Dungeon", "Raid"}) do
            local folder = Workspace:FindFirstChild(folderName)
            if folder then
                scanDungeonMobFolder(folder, char, best, 2, 0)
            end
        end
        if not best.mob then
            scanDungeonMobFolder(Workspace, char, best, 1, 0)
        end

        dState.mobCache = best.mob
        dState.mobCacheRoot = best.root
        dState.mobCacheTime = now
        return best.mob, best.root, best.dist
    end

    local function getDungeonValidCombatTools(char)
        local customList = Settings.DungeonWeapons
        if type(customList) == "table" and #customList > 0 then
            local tools = {}
            for _, name in ipairs(customList) do
                local t = char:FindFirstChild(name) or Player.Backpack:FindFirstChild(name)
                if t and t:IsA("Tool") then
                    table.insert(tools, t)
                end
            end
            if #tools > 0 then
                return tools
            end
        end
        return GetCombatTools(char)
    end

    local function FindDungeonPad()
        local char = Player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local diffLower = (Settings.DungeonMode or Settings.DungeonDifficulty or "Normal"):lower()
        local matchDiff = diffLower ~= "all / auto" and diffLower ~= ""

        local now = tick()
        local bestPad = nil
        if dState.padCache and dState.padCache.Parent and dState.padCacheMode == diffLower and (now - dState.padCacheTime) < 1.5 then
            bestPad = dState.padCache
        else
            local bestScore = -math.huge
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local hasTouch = obj:FindFirstChildOfClass("TouchTransmitter") ~= nil
                    local pName = obj.Name:lower()
                    local parName = obj.Parent and obj.Parent.Name:lower() or ""
                    local gName = (obj.Parent and obj.Parent.Parent) and obj.Parent.Parent.Name:lower() or ""
                    local combined = pName .. " " .. parName .. " " .. gName

                    local isDungeonCtx = combined:find("dungeon", 1, true)
                        or combined:find("raid", 1, true)
                        or combined:find("lobby", 1, true)
                        or combined:find("pad", 1, true)
                        or combined:find("portal", 1, true)
                        or combined:find("gate", 1, true)
                        or combined:find("start", 1, true)

                    if (hasTouch and isDungeonCtx) or (isDungeonCtx and (combined:find("dungeon", 1, true) or combined:find("raid", 1, true))) then
                        local score = 10
                        if hasTouch then score = score + 50 end
                        if combined:find("dungeon", 1, true) or combined:find("raid", 1, true) then score = score + 30 end
                        if combined:find("pad", 1, true) or combined:find("portal", 1, true) or combined:find("start", 1, true) then score = score + 20 end
                        if matchDiff and combined:find(diffLower, 1, true) then score = score + 100 end
                        if hrp then
                            score = score - ((obj.Position - hrp.Position).Magnitude * 0.001)
                        end
                        if score > bestScore then
                            bestScore = score
                            bestPad = obj
                        end
                    end
                end
            end
            dState.padCache = bestPad
            dState.padCacheMode = diffLower
            dState.padCacheTime = now
        end

        if Settings.DungeonPartnerMode then
            local manualSet = {}
            if type(Settings.DungeonFriends) == "table" then
                for _, uname in ipairs(Settings.DungeonFriends) do
                    manualSet[stripFriendTag(uname)] = true
                end
            end
            if Settings.DungeonPartner and Settings.DungeonPartner ~= "" then
                manualSet[stripFriendTag(Settings.DungeonPartner)] = true
            end

            local activeFriends = getActiveDungeonFriendTargets()
            local bestFriendRoot, bestFriendName = nil, nil
            local bestScore = -math.huge
            for _, friendPlayer in ipairs(activeFriends) do
                local fChar = friendPlayer.Character
                local fHum = fChar and fChar:FindFirstChildOfClass("Humanoid")
                local fRoot = fChar and fChar:FindFirstChild("HumanoidRootPart")
                if fHum and fHum.Health > 0 and fRoot then
                    local distFromMe = hrp and (fRoot.Position - hrp.Position).Magnitude or 0
                    local distToPad = bestPad and (fRoot.Position - bestPad.Position).Magnitude or math.huge
                    local isManual = manualSet[friendPlayer.Name] == true
                    local nearPad = bestPad and (distToPad <= 150)
                    local eligible = nearPad or (isManual and distFromMe <= 2000) or (distFromMe <= 450)
                    if eligible then
                        local score = (nearPad and 1000 or 0) + (isManual and 500 or 0) - (distFromMe * 0.01)
                        if score > bestScore then
                            bestScore = score
                            bestFriendRoot = fRoot
                            bestFriendName = friendPlayer.Name
                        end
                    end
                end
            end
            if bestFriendRoot then
                return bestFriendRoot, true, bestFriendName
            end
        end

        return bestPad, false, nil
    end

    local function TweenToCFrame(hrp, targetCF)
        local speed = Settings.DungeonTweenSpeed or 280
        local dist = (hrp.Position - targetCF.Position).Magnitude
        if dist < 8 then
            if dState.activeTween then
                pcall(function() dState.activeTween:Cancel() end)
                dState.activeTween = nil
            end
            hrp.CFrame = targetCF
        else
            if dState.activeTween then
                pcall(function() dState.activeTween:Cancel() end)
            end
            local duration = math.max(dist / speed, 0.03)
            local tw = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCF})
            dState.activeTween = tw
            tw:Play()
        end
    end

    dState.steppedConn = RunService.Stepped:Connect(function()
        if not _running then
            if dState.wasActive then
                dState.wasActive = false
                cleanupDungeon()
            end
            if dState.steppedConn then
                dState.steppedConn:Disconnect()
                dState.steppedConn = nil
            end
            return
        end

        if not Settings.AutoDungeon then
            if dState.wasActive then
                dState.wasActive = false
                cleanupDungeon()
            end
            return
        end

        dState.wasActive = true
        local char = Player.Character
        if not char then return end
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") and part.CanCollide then
                if dState.origCanCollide[part] == nil then
                    dState.origCanCollide[part] = true
                end
                part.CanCollide = false
            end
        end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local hb = hrp:FindFirstChild("KL_HoverBV")
            if hb then hb:Destroy() end
            local hg = hrp:FindFirstChild("KL_HoverBG")
            if hg then hg:Destroy() end

            local bv = hrp:FindFirstChild("KL_DungeonBV")
            if not bv then
                bv = Instance.new("BodyVelocity")
                bv.Name = "KL_DungeonBV"
                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                bv.P = 1250
                bv.Velocity = Vector3.zero
                bv.Parent = hrp
            else
                bv.Velocity = Vector3.zero
            end
        end
    end)

    -- Main Auto Dungeon A-Z Loop
    task.spawn(function()
        while _running do
            if Settings.AutoDungeon then
                pcall(function()
                    local char = Player.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if not char or not hum or hum.Health <= 0 or not hrp then
                        dState.inCombatRange = false
                        return
                    end

                    local playMode = Settings.DungeonPlayMode or "Hover Above (Tween)"
                    local lowThreshold = Settings.DungeonLowHPThreshold or 0.25
                    if playMode == "Safe Evasion" then
                        lowThreshold = math.max(lowThreshold, 0.40)
                    end
                    local recThreshold = Settings.DungeonRecoveryHPThreshold or 0.55

                    local hpRatio = hum.MaxHealth > 0 and (hum.Health / hum.MaxHealth) or 1
                    if lowThreshold > 0 and hpRatio < lowThreshold then
                        dState.evadingLowHP = true
                    elseif hpRatio >= recThreshold or lowThreshold <= 0 then
                        dState.evadingLowHP = false
                    end

                    local mob, mobRoot = GetClosestDungeonMob()
                    if mob and mobRoot then
                        dState.currentMob = mob
                        dState.waitingAnchor = mobRoot.Position
                        if typeof(getgenv) == "function" then
                            pcall(function() getgenv().PosMonSkill = mobRoot.CFrame end)
                        end

                        pcall(function()
                            local hb = Settings.DungeonHitboxSize or 30
                            mobRoot.Size = Vector3.new(hb, hb, hb)
                            mobRoot.Transparency = 0.8
                            mobRoot.CanCollide = false
                        end)

                        local safeH = Settings.DungeonSafeHoverHeight or 65
                        local hoverH = Settings.DungeonHoverHeight or 14
                        if playMode == "Safe Evasion" and not dState.evadingLowHP then
                            hoverH = math.max(hoverH, 22)
                        end

                        local targetCF
                        if dState.evadingLowHP then
                            local hoverPos = mobRoot.Position + Vector3.new(0, safeH, 0.35)
                            targetCF = SafeLookAt(hoverPos, mobRoot.Position)
                        elseif playMode == "Behind Target" then
                            local behindPos = (mobRoot.CFrame * CFrame.new(0, 4, 8)).Position
                            targetCF = SafeLookAt(behindPos, mobRoot.Position)
                        else
                            local hoverPos = mobRoot.Position + Vector3.new(0, hoverH, 0.35)
                            targetCF = SafeLookAt(hoverPos, mobRoot.Position)
                        end
                        TweenToCFrame(hrp, targetCF)

                        local actualDist = (hrp.Position - mobRoot.Position).Magnitude
                        dState.inCombatRange = (not dState.evadingLowHP) and (actualDist < (Settings.DungeonCombatRange or 35))
                        Settings.DungeonStatus = (dState.evadingLowHP and ("Low HP Evading (" .. safeH .. "s): ") or "Fighting: ") .. mob.Name
                    else
                        dState.inCombatRange = false
                        dState.currentMob = nil
                        if typeof(getgenv) == "function" then
                            pcall(function() getgenv().PosMonSkill = nil end)
                        end

                        local pad, isFriend, friendName = FindDungeonPad()
                        if pad and pad.Parent then
                            if isFriend then
                                local targetPos = (pad.CFrame * CFrame.new(0, 1.5, -2.5)).Position
                                TweenToCFrame(hrp, SafeLookAt(targetPos, pad.Position))
                                Settings.DungeonStatus = "Friends Co-op: With " .. tostring(friendName)
                            else
                                TweenToCFrame(hrp, pad.CFrame + Vector3.new(0, 2.5, 0))
                                Settings.DungeonStatus = "Entering Pad (" .. (Settings.DungeonMode or "Normal") .. "): " .. pad.Name
                            end
                        else
                            if not dState.waitingAnchor or (hrp.Position - dState.waitingAnchor).Magnitude > 400 then
                                dState.waitingAnchor = hrp.Position
                            end
                            local safeWaitPos = dState.waitingAnchor + Vector3.new(0, 20, 0)
                            TweenToCFrame(hrp, CFrame.new(safeWaitPos))
                            Settings.DungeonStatus = "Waiting for next Wave / Dungeon..."
                        end
                    end
                end)
                task.wait(0.08)
            else
                task.wait(0.3)
            end
        end
    end)

    -- Combat Thread 1: Auto Buso Haki (only turns ON when OFF)
    task.spawn(function()
        while _running do
            if Settings.AutoDungeon and dState.inCombatRange and Settings.AutoHaki then
                pcall(function()
                    local char = Player.Character
                    if char and not IsHakiActive(char) then
                        ActivateHaki()
                    end
                end)
            end
            task.wait(2.5)
        end
    end)

    -- Combat Thread 2: Auto M1 (0.13s headless Tool API + SkillAction Remote + VirtualUser fallback)
    task.spawn(function()
        local skillActionRemote = nil
        local skillActionChecked = false
        local m1RemoteBusy = false
        local m1RemoteBusySince = 0

        while _running do
            if Settings.AutoDungeon and dState.inCombatRange then
                pcall(function()
                    local char = Player.Character
                    local tool = char and char:FindFirstChildOfClass("Tool")
                    if tool then
                        pcall(function() tool.ManualActivationOnly = false end)
                        tool:Activate()
                        task.delay(0.02, function()
                            pcall(function()
                                if tool and tool.Parent == char then
                                    tool:Deactivate()
                                end
                            end)
                        end)

                        if not skillActionChecked then
                            skillActionChecked = true
                            local chest = ReplicatedStorage:FindFirstChild("Chest")
                            local remotes = chest and chest:FindFirstChild("Remotes")
                            local funcs = remotes and remotes:FindFirstChild("Functions")
                            skillActionRemote = funcs and funcs:FindFirstChild("SkillAction")
                        end
                        if skillActionRemote and (not m1RemoteBusy or (tick() - m1RemoteBusySince) > 1.5) then
                            m1RemoteBusy = true
                            m1RemoteBusySince = tick()
                            local tip = tool.ToolTip
                            local prefix = (tip == "Sword" and "SW") or (tip == "Fruit Power" and "FP") or "FS"
                            local actionName = prefix .. "_" .. tool.Name .. "_M1"
                            task.spawn(function()
                                pcall(function()
                                    skillActionRemote:InvokeServer(actionName)
                                end)
                                m1RemoteBusy = false
                            end)
                        end
                    end
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton1(Vector2.new(9999, 9999))
                end)
            end
            task.wait(Settings.DungeonM1Delay or 0.13)
        end
    end)

    -- Combat Thread 3: Weapon Cycle (0.3s) & Skill Burst Z X C V B
    local dungeonSkillKeys = {
        Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C,
        Enum.KeyCode.V, Enum.KeyCode.B,
    }
    task.spawn(function()
        local weaponIdx = 1
        while _running do
            if Settings.AutoDungeon and dState.inCombatRange then
                pcall(function()
                    local char = Player.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if char and hum and hum.Health > 0 then
                        local tools = getDungeonValidCombatTools(char)
                        if #tools > 0 then
                            if weaponIdx > #tools then weaponIdx = 1 end
                            local tool = tools[weaponIdx]
                            weaponIdx = weaponIdx + 1
                            if tool and tool.Parent ~= char then
                                hum:EquipTool(tool)
                                task.wait(Settings.DungeonEquipSettleDelay or 0.06)
                            end
                            if not UIS:GetFocusedTextBox() then
                                for _, key in ipairs(dungeonSkillKeys) do
                                    if not Settings.AutoDungeon or not dState.inCombatRange then break end
                                    task.spawn(function()
                                        VirtualInputManager:SendKeyEvent(true, key, false, game)
                                        task.wait(0.02)
                                        VirtualInputManager:SendKeyEvent(false, key, false, game)
                                    end)
                                end
                            end
                        end
                    end
                end)
            end
            task.wait(Settings.DungeonWeaponSwapDelay or 0.3)
        end
    end)
end

-- Sea Event Loop
task.spawn(function()
    while _running do
        if Settings.AutoSeaEvent and not _sea2EventActive and not Settings.AutoDungeon then
            pcall(function()
                local foundTarget = nil
                for _, entry in ipairs(GetLivingMobs()) do
                    local n = entry.lname
                    if n:find("sea king", 1, true) or n:find("hydra", 1, true) or n:find("kraken", 1, true) or n:find("seabeast", 1, true) or n:find("sea beast", 1, true) then
                        foundTarget = entry.mob
                        break
                    end
                end
                if not foundTarget then
                    for _, folder in ipairs({Workspace:FindFirstChild("SeaMonster"), Workspace:FindFirstChild("SeaMonsters"), Workspace:FindFirstChild("Bosses"), Workspace}) do
                        if folder then
                            for _, obj in ipairs(folder:GetChildren()) do
                                if obj:IsA("Model") and obj ~= Character and not Players:GetPlayerFromCharacter(obj) then
                                    local n = obj.Name:lower()
                                    if n:find("sea king", 1, true) or n:find("hydra", 1, true) or n:find("kraken", 1, true) or n:find("seabeast", 1, true) or n:find("sea beast", 1, true) then
                                        local hum = obj:FindFirstChildOfClass("Humanoid")
                                        if hum and hum.Health > 0 then
                                            foundTarget = obj
                                            break
                                        end
                                    end
                                end
                            end
                        end
                        if foundTarget then break end
                    end
                end
                if foundTarget then
                    _farmStatus = "Sea Event: " .. foundTarget.Name
                    AttackMob(foundTarget)
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
    -- Try official Sea travel NPCs first (Elite Pirate / Traveler / The Squid)
    local npcPriority
    if seaNum == 1 then
        npcPriority = {"Elite Pirate", "Traveler"}
    elseif seaNum == 2 then
        npcPriority = {"Traveler", "Elite Pirate"}
    else
        npcPriority = {"The Squid", "Elite Pirate"}
    end

    local allNPC = Workspace:FindFirstChild("AllNPC")
    if allNPC then
        for _, npcName in ipairs(npcPriority) do
            local npc = allNPC:FindFirstChild(npcName)
            if npc then
                local root = npc:IsA("BasePart") and npc or (npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart or npc:FindFirstChildOfClass("BasePart"))
                if root then
                    DisableHoverLock()
                    FastTeleport(root.CFrame + Vector3.new(0, 3, 2), true)
                    task.wait(0.15)
                    InteractWithNPC(npc.Name)
                    break
                end
            end
        end
    end

    local chest = ReplicatedStorage:FindFirstChild("Chest")
    local remotes = chest and chest:FindFirstChild("Remotes")
    local funcs = remotes and remotes:FindFirstChild("Functions")
    local etcFn = funcs and funcs:FindFirstChild("EtcFunction")
    if etcFn and etcFn:IsA("RemoteFunction") then
        pcall(function()
            etcFn:InvokeServer("Travel", seaNum)
        end)
    end

    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local n = remote.Name:lower()
            if n:find("sea") or n:find("travel") or n:find("world") then
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
    for _, entry in ipairs(GetLivingMobs()) do
        for _, kw in ipairs(keywords) do
            if entry.lname:find(kw, 1, true) then
                return entry.mob
            end
        end
    end
    local containers = {
        Workspace:FindFirstChild("SeaMonster"),
        Workspace:FindFirstChild("SeaMonsters"),
        Workspace:FindFirstChild("Bosses"),
        Workspace,
    }
    for _, folder in ipairs(containers) do
        if folder then
            for _, obj in ipairs(folder:GetChildren()) do
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
    for _, child in ipairs(model:GetChildren()) do
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
        Workspace:FindFirstChild("Monster"),
        Workspace:FindFirstChild("Bosses"),
        Workspace,
    }
    for _, folder in ipairs(containers) do
        if folder then
            for _, obj in ipairs(folder:GetChildren()) do
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

    _hakiState.lastCombatTick = tick()
    local targetPos = targetPart.Position
    if Settings.HoverFarm then
        local hoverPos = targetPos + Vector3.new(0, Settings.HoverHeight, 0)
        EnableHoverLock(hoverPos, targetPos, targetPart)
    else
        DisableHoverLock()
        if HumanoidRootPart and HumanoidRootPart.Parent then
            local cf = targetPart.CFrame * CFrame.new(0, 5, -Settings.AttackRange * 0.3)
            HumanoidRootPart.CFrame = SafeLookAt(cf.Position, targetPos)
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
    local attrNames
    local k1, k2 = (keyword1 or ""):lower(), (keyword2 or ""):lower()
    if k1:find("ghost", 1, true) or k2:find("ship", 1, true) then
        attrNames = {"GhostShipSpawnText"}
    elseif k1:find("third", 1, true) or k2:find("kraken", 1, true) or k1:find("abyssal", 1, true) then
        attrNames = {"ThirdSeaMonsterSpawnText"}
    else
        attrNames = {"SeaMonsterSpawnText"}
    end
    for _, attrName in ipairs(attrNames) do
        local ok, val = pcall(function() return ReplicatedStorage:GetAttribute(attrName) end)
        if ok and val ~= nil and tostring(val) ~= "" then
            local timerStr = tostring(val):match("%d+:%d+[:%d]*")
            if timerStr then
                return timerStr
            end
        end
    end

    local playerGui = Player:FindFirstChild("PlayerGui")
    local seaFolder = Workspace:FindFirstChild("SeaMonster") or Workspace:FindFirstChild("SeaMonsters")
    local sources = {playerGui, seaFolder, ReplicatedStorage}
    for _, src in ipairs(sources) do
        if src then
            local list = (src == playerGui) and src:GetDescendants() or src:GetChildren()
            for _, obj in ipairs(list) do
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

local _sea2TimerCacheText = ""
local _sea2TimerCacheTime = 0

local function _BuildSea2LiveStatusText()
    local now = tick()
    local hydra = FindHydraModel()
    local hydraText
    if hydra then
        if not _hydraSpawnTime then _hydraSpawnTime = now end
        local hum = hydra:FindFirstChildOfClass("Humanoid")
        local hp = hum and math.floor(hum.Health) or 0
        hydraText = string.format("SPAWNED! (HP: %d | Alive: %s)", hp, FormatTimeMMSS(now - _hydraSpawnTime))
    else
        if _hydraSpawnTime then
            _hydraSpawnTime = nil
            _hydraLastSeenDead = now
        end
        local igTimer = GetInGameSeaTimer("hydra", "seaking")
        if igTimer then
            hydraText = "Spawns in: " .. igTimer
        else
            hydraText = string.format("Not Spawned (Waited: %s / ~30-60m)", FormatTimeMMSS(now - _hydraLastSeenDead))
        end
    end

    local sb = FindSeaBeastModel()
    local sbText
    if sb then
        if not _seaBeastSpawnTime then _seaBeastSpawnTime = now end
        local hum = sb:FindFirstChildOfClass("Humanoid")
        local hp = hum and math.floor(hum.Health) or 0
        sbText = string.format("SPAWNED! (HP: %d | Alive: %s)", hp, FormatTimeMMSS(now - _seaBeastSpawnTime))
    else
        if _seaBeastSpawnTime then
            _seaBeastSpawnTime = nil
            _seaBeastLastSeenDead = now
        end
        local igTimer = GetInGameSeaTimer("seabeast", "sea beast")
        if igTimer then
            sbText = "Spawns in: " .. igTimer
        else
            sbText = string.format("Not Spawned (Waited: %s / ~20-40m)", FormatTimeMMSS(now - _seaBeastLastSeenDead))
        end
    end

    local gs = FindGhostShipModel()
    local gsText
    if gs then
        if not _ghostShipSpawnTime then _ghostShipSpawnTime = now end
        local hp = GetShipHealth(gs)
        if hp then
            gsText = string.format("SPAWNED! (HP: %d | Alive: %s)", math.floor(hp), FormatTimeMMSS(now - _ghostShipSpawnTime))
        else
            gsText = string.format("SPAWNED! (Alive: %s)", FormatTimeMMSS(now - _ghostShipSpawnTime))
        end
    else
        if _ghostShipSpawnTime then
            _ghostShipSpawnTime = nil
            _ghostShipLastSeenDead = now
        end
        local igTimer = GetInGameSeaTimer("ghost", "ship")
        if igTimer then
            gsText = "Spawns in: " .. igTimer
        else
            gsText = string.format("Not Spawned (Waited: %s / ~30-60m)", FormatTimeMMSS(now - _ghostShipLastSeenDead))
        end
    end

    local dragon = FindDragonBoss()
    local dragonText
    if dragon then
        local hum = dragon:FindFirstChildOfClass("Humanoid")
        local hp = hum and math.floor(hum.Health) or 0
        dragonText = string.format("SPAWNED! (HP: %d)", hp)
    else
        dragonText = "Not Summoned"
    end

    local orbCount = CountDragonOrbs()

    return string.format(
        "SK Hydra: %s\nSea Beast: %s\nGhost Ship: %s\nDragon Boss: %s\nDragon Orb: %d in backpack",
        hydraText, sbText, gsText, dragonText, orbCount
    )
end

local function GetSea2LiveStatusText()
    local now = tick()
    if _sea2TimerCacheText ~= "" and (now - _sea2TimerCacheTime) < 2.0 then
        return _sea2TimerCacheText
    end
    _sea2TimerCacheText = _BuildSea2LiveStatusText()
    _sea2TimerCacheTime = now
    return _sea2TimerCacheText
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
        if mobRoot then
            _hakiState.lastOrbPos = mobRoot.Position
            if Settings.BringMob then
                BringMobs(nearestMob.Name, mobRoot.Position)
            end
        end
        AttackMob(nearestMob)
    else
        local anchor = _hakiState.lastOrbPos or HumanoidRootPart.Position
        local hoverPos = anchor + Vector3.new(0, Settings.HoverHeight, 0)
        EnableHoverLock(hoverPos, anchor)
        task.wait(0.8)
    end
end

local function FindSeaEventChestParts(eventType, lastKnownPos, allowSpawnerCFrame)
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
    local seenParts = {}

    local function addResult(part, obj, priority, allowTransparent)
        if not part or seenParts[part] then return end
        seenParts[part] = true
        table.insert(results, {part = part, obj = obj, priority = priority, allowTransparent = allowTransparent})
    end

    -- Primary: Official Sea Event Island ChestSpawner & HydraStand paths
    local islandFolder = Workspace:FindFirstChild("Island")
    if islandFolder then
        for _, child in ipairs(islandFolder:GetChildren()) do
            local cname = child.Name
            local clower = cname:lower()
            if (clower:find("legacy island", 1, true) and (not eventType or eventType == "seabeast" or eventType == "hydra"))
               or ((cname:sub(1, 8) == "Sea King" or clower:find("sea king", 1, true)) and (not eventType or eventType == "hydra" or eventType == "seabeast")) then
                local spawner = child:FindFirstChild("ChestSpawner") or child:FindFirstChild("HydraStand")
                if spawner then
                    local addedInner = false
                    for _, desc in ipairs(spawner:GetDescendants()) do
                        if (desc:IsA("BasePart") and desc.Transparency < 1) and (desc.Name:lower():find("chest", 1, true) or desc:FindFirstChildOfClass("TouchTransmitter") or desc:FindFirstChildOfClass("ProximityPrompt") or desc:FindFirstChildOfClass("ClickDetector")) then
                            addResult(desc, desc, 1, false)
                            addedInner = true
                        end
                    end
                    local sPart = spawner:IsA("BasePart") and spawner or (spawner:IsA("Model") and (spawner.PrimaryPart or spawner:FindFirstChildOfClass("BasePart")))
                    if sPart and (not addedInner) and (allowSpawnerCFrame or sPart.Transparency < 1) then
                        addResult(sPart, spawner, 2, allowSpawnerCFrame == true)
                    end
                end
            end
        end
    end

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
                            if aname:find("hydra", 1, true) or aname:find("seaking", 1, true) or aname:find("seabeast", 1, true) or aname:find("seaevent", 1, true) or aname:find("ghost", 1, true) or aname:find("legacy island", 1, true) then
                                inEventIsland = true
                                break
                            end
                            ancestor = ancestor.Parent
                        end

                        if isSpecific or matchesEvent or nearLast or inEventIsland then
                            local priority = (matchesEvent and 1) or (isSpecific and 2) or (inEventIsland and 3) or 4
                            addResult(part, obj, priority, false)
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
        local chests = FindSeaEventChestParts(eventType, lastKnownPos, waitForSpawn == true)
        if #chests > 0 then
            DisableHoverLock()
            for _, item in ipairs(chests) do
                if not _running then break end
                if item.part and item.part.Parent and (item.part.Transparency < 1 or item.allowTransparent) then
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
    local lastChestScan = 0
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
                    _farmStatus = "Killing SK Hydra"
                    AttackMob(hydra)
                elseif _lastHydraPos then
                    local pos = _lastHydraPos
                    _lastHydraPos = nil
                    if Settings.AutoCollectHydraChest then
                        _hydraActive = true
                        UpdateSea2HoverState()
                        _farmStatus = "Teleporting to SK Hydra Chest!"
                        CollectSeaEventChest("hydra", pos, true)
                    end
                    _hydraActive = false
                    UpdateSea2HoverState()
                else
                    if Settings.AutoCollectHydraChest and (tick() - lastChestScan) >= 3.0 then
                        lastChestScan = tick()
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
    local lastChestScan = 0
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
                    _farmStatus = "Killing Sea Beast"
                    AttackMob(sb)
                elseif _lastSeaBeastPos then
                    local pos = _lastSeaBeastPos
                    _lastSeaBeastPos = nil
                    if Settings.AutoCollectHydraChest then
                        _seaBeastActive = true
                        UpdateSea2HoverState()
                        _farmStatus = "Teleporting to Sea Beast Chest!"
                        CollectSeaEventChest("seabeast", pos, true)
                    end
                    _seaBeastActive = false
                    UpdateSea2HoverState()
                else
                    if Settings.AutoCollectHydraChest and (tick() - lastChestScan) >= 3.0 then
                        lastChestScan = tick()
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
    local lastChestScan = 0
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
                    _farmStatus = "Killing Ghost Ship"
                    AttackSeaEventTarget(gs)
                elseif _lastGhostShipPos then
                    local pos = _lastGhostShipPos
                    _lastGhostShipPos = nil
                    if Settings.AutoCollectHydraChest then
                        _ghostShipActive = true
                        UpdateSea2HoverState()
                        _farmStatus = "Teleporting to Ghost Ship Chest!"
                        CollectSeaEventChest("ghost", pos, true)
                    end
                    _ghostShipActive = false
                    UpdateSea2HoverState()
                else
                    if Settings.AutoCollectHydraChest and (tick() - lastChestScan) >= 3.0 then
                        lastChestScan = tick()
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
                    _farmStatus = "Killing Dragon Boss"
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
                    _farmStatus = "Summoning Dragon..."
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
                _farmStatus = "Farming Dragon Orb..."
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
        Label = "Carrot (Beast Swordman - Sea 2)",
        Name = "Carrot",
        Sea = 2,
        Mobs = {"Beast Swordman [Lv. 2300]", "Beast Swordman", "Mink Warrior"},
        Area = CFrame.new(-2500, 400, -1300),
        CollectGround = true,
        GroundKeywords = {"carrot"},
    },
    {
        Label = "Rusted Scrap (Elite Soldier / Beast Swordman)",
        Name = "Rusted Scrap",
        Sea = 1,
        Mobs = {"Elite Soldier [Lv. 1000]", "Beast Swordman [Lv. 2300]", "Elite Soldier", "Beast Swordman"},
        Area = CFrame.new(-1500, 15, 3800),
    },
    {
        Label = "Iron Ingot (Beast Pirate - Sea 2)",
        Name = "Iron Ingot",
        Sea = 2,
        Mobs = {"Beast Pirate [Lv. 2250]", "Beast Pirate"},
        Area = CFrame.new(-1900, 20, -2400),
    },
    {
        Label = "Leather (Commander / Duke)",
        Name = "Leather",
        Sea = 1,
        Mobs = {"Commander [Lv. 100]", "Duke [Lv. 2550]", "Commander", "Duke"},
        Area = CFrame.new(-1100, 20, 4700),
    },
    {
        Label = "Angellic's Feather (Sky Soldier - Sea 1)",
        Name = "Angellic's Feather",
        Sea = 1,
        Mobs = {"Sky Soldier [Lv. 800]", "Sky Soldier"},
        Area = CFrame.new(-4850, 790, -2820),
    },
    {
        Label = "Gun Powder (Ball Man / Lomeo)",
        Name = "Gun Powder",
        Sea = 1,
        Mobs = {"Ball Man [Lv. 850]", "Lomeo [Lv. 3675]", "Ball Man", "Lomeo"},
        Area = CFrame.new(1100, 16, 4500),
    },
    {
        Label = "Fresh Fish (Karate Fishman - Sea 1)",
        Name = "Fresh Fish",
        Sea = 1,
        Mobs = {"Karate Fishman [Lv. 200]", "Karate Fishman", "Fishman"},
        Area = CFrame.new(2650, 15, 600),
    },
    {
        Label = "Undead Ooze (Zombie / Sally)",
        Name = "Undead Ooze",
        Sea = 2,
        Mobs = {"Zombie [Lv. 1500]", "Sally [Lv. 3450]", "Zombie", "Sally"},
        Area = CFrame.new(-5400, 310, -4600),
    },
    {
        Label = "Shark Canine (Seasoned Fishman)",
        Name = "Shark Canine",
        Sea = 1,
        Mobs = {"Seasoned Fishman [Lv. 2200]", "Seasoned Fishman"},
        Area = CFrame.new(2750, 15, 480),
    },
    {
        Label = "Bread Crumps (Chess Soldier - Sea 2)",
        Name = "Bread Crumps",
        Sea = 2,
        Mobs = {"Chess Soldier [Lv. 3200]", "Chess Soldier"},
        Area = CFrame.new(-3200, 30, -1900),
    },
    {
        Label = "Pile of Bones (Skull Pirate - Sea 2)",
        Name = "Pile of Bones",
        Sea = 2,
        Mobs = {"Skull Pirate [Lv. 3050]", "Skull Pirate"},
        Area = CFrame.new(-5450, 310, -4650),
    },
    {
        Label = "Thief's Rag (Desert Thief - Sea 2)",
        Name = "Thief's Rag",
        Sea = 2,
        Mobs = {"Desert Thief [Lv. 3125]", "Desert Thief"},
        Area = CFrame.new(1100, 20, -2100),
    },
    {
        Label = "Dragon Orb (Elite Skeleton - Sea 2)",
        Name = "Dragon Orb",
        Sea = 2,
        Mobs = {"Elite Skeleton [Lv. 3100]", "Elite Skeleton"},
        Area = CFrame.new(-5400, 310, -4600),
    },
    {
        Label = "Lucidu's Totem (Vice Admiral - Sea 2)",
        Name = "Lucidu's Totem",
        Sea = 2,
        Mobs = {"Vice Admiral [Lv. 3500]", "Vice Admiral"},
        Area = CFrame.new(1400, 20, -3400),
    },
    {
        Label = "Dark Beard Totem (Dark Beard Servant)",
        Name = "Dark Beard Totem",
        Sea = 2,
        Mobs = {"Dark Beard Servant [Lv. 3400]", "Dark Beard Servant"},
        Area = CFrame.new(-4900, 250, -4200),
    },
    {
        Label = "Magma Crystal (The Volcano - Sea 2)",
        Name = "Magma Crystal",
        Sea = 2,
        Mobs = {"The Volcano [Lv. 3325]", "The Volcano"},
        Area = CFrame.new(1310, 15, -4200),
    },
    {
        Label = "Ice Crystals (Azlan - Sea 2)",
        Name = "Ice Crystals",
        Sea = 2,
        Mobs = {"Azlan [Lv. 3300]", "Azlan"},
        Area = CFrame.new(1250, 15, -4050),
    },
    {
        Label = "Samurai Bandage (Kitsune Samurai)",
        Name = "Samurai Bandage",
        Sea = 2,
        Mobs = {"Kitsune Samurai [Lv. 2650]", "Kitsune Samurai"},
        Area = CFrame.new(2500, 40, -1800),
    },
    {
        Label = "Lost Ruby (Anubis - Sea 2)",
        Name = "Lost Ruby",
        Sea = 2,
        Mobs = {"Anubis [Lv. 3150]", "Anubis"},
        Area = CFrame.new(1200, 25, -2200),
    },
    {
        Label = "Essence of Fire (Flame User - Sea 2)",
        Name = "Essence of Fire",
        Sea = 2,
        Mobs = {"Flame User [Lv. 3200]", "Flame User"},
        Area = CFrame.new(1350, 25, -2300),
    },
    {
        Label = "Twilight Orb (Shadow Master - Lv.1600)",
        Name = "Twilight Orb",
        Sea = 1,
        Mobs = {"Shadow Master [Lv. 1600]", "Shadow Master"},
        Area = CFrame.new(-3200, 40, 2100),
    },
    {
        Label = "Vital Fluid (Shadow Master - Lv.1650)",
        Name = "Vital Fluid",
        Sea = 1,
        Mobs = {"Shadow Master [Lv. 1650]", "Shadow Master"},
        Area = CFrame.new(-3250, 40, 2150),
    },
    {
        Label = "Coral and Pearl (Fugitive - Sea 3)",
        Name = "Coral and Pearl",
        Sea = 3,
        Mobs = {"Fugitive [Lv. 4050]", "Fugitive"},
        Area = CFrame.new(-800, 15, 1510),
    },
    {
        Label = "Shark Fin (Fishman Guardian - Sea 3)",
        Name = "Shark Fin",
        Sea = 3,
        Mobs = {"Fishman Guardian [Lv. 4150]", "Fishman Guardian"},
        Area = CFrame.new(-900, 15, 1650),
    },
    {
        Label = "Diverse Sphere (Gazelle Man - Sea 2)",
        Name = "Diverse Sphere",
        Sea = 2,
        Mobs = {"Gazelle Man [Lv. 2350]", "Gazelle Man"},
        Area = CFrame.new(-2600, 35, -1400),
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
    local targetLower = matName:lower():gsub("[%s&'%.]+", "")
    local targetRaw = matName:lower()

    local function matchesName(str)
        local l = str:lower()
        return l:find(targetRaw, 1, true) or l:gsub("[%s&'%.]+", ""):find(targetLower, 1, true)
    end

    -- Primary: Official PlayerStats.Material JSON
    local stats = Player:FindFirstChild("PlayerStats")
    local matJsonVal = stats and stats:FindFirstChild("Material")
    if matJsonVal and matJsonVal:IsA("StringValue") and matJsonVal.Value ~= "" then
        local ok, decoded = pcall(function()
            return game:GetService("HttpService"):JSONDecode(matJsonVal.Value)
        end)
        if ok and type(decoded) == "table" then
            if type(decoded[matName]) == "number" then
                return decoded[matName]
            end
            for k, v in pairs(decoded) do
                if type(v) == "number" and matchesName(tostring(k)) then
                    if v > count then count = v end
                end
            end
            if count > 0 then return count end
        end
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
        if mobRoot then
            _hakiState.lastMatPos = mobRoot.Position
            if Settings.BringMob then
                BringMobs(nearestMob.Name, mobRoot.Position)
            end
        end
        AttackMob(nearestMob)
    else
        local anchor = _hakiState.lastMatPos or HumanoidRootPart.Position
        local hoverPos = anchor + Vector3.new(0, Settings.HoverHeight, 0)
        EnableHoverLock(hoverPos, anchor)
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
                    _farmStatus = string.format("Farming Material: %s (Have: %d)", entry.Name, GetMaterialCount(entry.Name))
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
-- THREAD 1: Swap weapon + M1 + Skill burst
task.spawn(function()
    local weaponIndex = 1
    while _running do
        if Settings.ReAttack then
            pcall(function()
                local char = Player.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then
                    _reattackStatus = "Waiting for respawn..."
                    return
                end

                local tools = GetCombatTools(char)
                if #tools == 0 then
                    _reattackStatus = "No weapons found"
                    return
                end

                if weaponIndex > #tools then weaponIndex = 1 end
                local targetTool = tools[weaponIndex]
                weaponIndex = weaponIndex + 1

                local slotStart = os.clock()
                _reattackReady = false

                -- Equip weapon
                if targetTool and targetTool.Parent ~= char then
                    hum:EquipTool(targetTool)
                end

                -- Wait for weapon initialization
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
            _reattackStatus = "OFF"
        end
        task.wait(Settings.ReAttack and 0.01 or 0.15)
    end
end)

-- THREAD 2: Background M1 spam (between swaps OR during active combat)
task.spawn(function()
    while _running do
        local inCombat = (tick() - (_hakiState.lastCombatTick or 0)) < 0.45
        if (Settings.ReAttack and _reattackReady) or inCombat then
            pcall(function()
                BackgroundM1_Safe()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(9999, 9999))
            end)
            task.wait(Settings.M1Rate or 0.05)
        else
            task.wait(0.12)
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
                if now - _hakiLastCheck >= 3 then
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
do
    local questMaterialSpecs = {
        [3350] = {MaterialNeed = "Ice Crystal", BossName = "Azlan [Lv. 3300]", LevelNeed = 3300, QuestName = "Kill 4 Azlan"},
        [3375] = {MaterialNeed = "Magma Crystal", BossName = "The Volcano [Lv. 3325]", LevelNeed = 3325, QuestName = "Kill 4 The Volcano"},
        [3475] = {MaterialNeed = "Dark Beard's Totem", BossName = "Sally [Lv. 3450]", LevelNeed = 3450, QuestName = "Kill 1 Sally"},
        [3575] = {MaterialNeed = "Lucidus's Totem", BossName = "Vice Admiral [Lv. 3500]", LevelNeed = 3500, QuestName = "Kill 5 Vice Admiral"},
    }
    local qmTable = nil
    local qmTried = false

    _hakiState.getOfficialQuest = function(level)
        if not qmTried then
            qmTried = true
            local ok, mod = pcall(function()
                return require(ReplicatedStorage.Chest.Modules.QuestManager)
            end)
            if ok and type(mod) == "table" then
                qmTable = mod
            end
        end
        if not qmTable then return nil end

        local pid = game.PlaceId
        local minSeaLv, maxSeaLv = 1, 99999
        if pid == 4520749081 then
            minSeaLv, maxSeaLv = 1, 2249
        elseif pid == 6381829480 then
            minSeaLv, maxSeaLv = 2250, 3999
        elseif pid == 15759515082 then
            minSeaLv, maxSeaLv = 4000, 99999
        end

        local mobTemplates = ReplicatedStorage:FindFirstChild("MOB")
        local bestTitle, bestInfo, bestLv = nil, nil, -1
        for title, info in pairs(qmTable) do
            if type(info) == "table" and tonumber(info.Level) and info.Mob and not info.DailyQuest then
                local qLv = info.Level
                if qLv <= level and qLv >= minSeaLv and qLv <= maxSeaLv then
                    local qmSpec = questMaterialSpecs[qLv]
                    local usable = true
                    if qmSpec then
                        local hasMat = GetMaterialCount(qmSpec.MaterialNeed) >= 1
                        local bossAlive = FindNearestMob(qmSpec.BossName, 50000) ~= nil
                        if not hasMat and not bossAlive then
                            usable = false
                        end
                    end
                    if usable then
                        local score = qLv + ((mobTemplates and mobTemplates:FindFirstChild(info.Mob)) and 0.5 or 0)
                        if score > bestLv then
                            bestLv = score
                            bestTitle = title
                            bestInfo = info
                        end
                    end
                end
            end
        end

        if not bestInfo then return nil end
        return {
            Title = bestTitle,
            MinLevel = bestInfo.Level,
            MobName = bestInfo.Mob,
            QuestNPC = bestTitle,
            QuestMaterial = questMaterialSpecs[bestInfo.Level],
        }
    end
end

local _lastSmartQuestAttempt = 0
local function TryAcceptQuestSmart(quest, nearPos)
    if not quest or HasActiveQuest() then return end
    local now = tick()
    if (now - _lastSmartQuestAttempt) < 6 then return end
    _lastSmartQuestAttempt = now

    pcall(function()
        local chest = ReplicatedStorage:FindFirstChild("Chest")
        local remotes = chest and chest:FindFirstChild("Remotes")
        local funcs = remotes and remotes:FindFirstChild("Functions")

        if quest.QuestMaterial and funcs then
            local etcFn = funcs:FindFirstChild("EtcFunction")
            if etcFn and etcFn:IsA("RemoteFunction") then
                pcall(function()
                    etcFn:InvokeServer("QuestSpawnBoss", {
                        SuccessQuest = "Quest Accepted.",
                        BossName = quest.QuestMaterial.BossName,
                        LevelNeed = quest.QuestMaterial.LevelNeed,
                        QuestName = quest.QuestMaterial.QuestName,
                        MaterialNeed = quest.QuestMaterial.MaterialNeed,
                    })
                end)
            end
        end

        if not HasActiveQuest() and funcs and (quest.Title or quest.QuestNPC) then
            local questRemote = funcs:FindFirstChild("Quest")
            if questRemote and questRemote:IsA("RemoteFunction") then
                pcall(function()
                    questRemote:InvokeServer("take", quest.Title or quest.QuestNPC)
                end)
            end
        end

        if HasActiveQuest() then return end

        local remotesFallback = GetQuestRemotes()
        for _, r in ipairs(remotesFallback) do
            if r:IsA("RemoteEvent") then
                pcall(function() r:FireServer("CheckQuest", quest.QuestNPC) end)
                pcall(function() r:FireServer(quest.QuestNPC) end)
            elseif r:IsA("RemoteFunction") then
                pcall(function() r:InvokeServer("CheckQuest", quest.QuestNPC) end)
            end
        end

        if nearPos and not HasActiveQuest() then
            local npcNameLower = quest.QuestNPC and string.lower(quest.QuestNPC) or ""
            local closestNPC, closestRoot, bestDist = nil, nil, 1500
            for _, folderName in ipairs({"AllNPC", "NPCs", "NPC", "QuestNPCs"}) do
                local folder = Workspace:FindFirstChild(folderName)
                if folder then
                    for _, npc in ipairs(folder:GetChildren()) do
                        if npc:IsA("Model") then
                            local root = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart or npc:FindFirstChildOfClass("BasePart")
                            if root then
                                local d = (root.Position - nearPos).Magnitude
                                if npcNameLower ~= "" and string.find(string.lower(npc.Name), npcNameLower, 1, true) and d <= 1500 then
                                    closestNPC, closestRoot, bestDist = npc, root, d
                                    break
                                elseif string.find(string.lower(npc.Name), "quest", 1, true) and d < bestDist then
                                    closestNPC, closestRoot, bestDist = npc, root, d
                                end
                            end
                        end
                    end
                end
                if closestNPC and npcNameLower ~= "" and string.find(string.lower(closestNPC.Name), npcNameLower, 1, true) then
                    break
                end
            end
            if closestNPC and closestRoot then
                DisableHoverLock()
                FastTeleport(closestRoot.CFrame + Vector3.new(0, 3, 0), true)
                task.wait(0.15)
                InteractWithNPC(closestNPC.Name)
            end
        end
    end)
end

local function FarmQuest()
    while _running do
        local isCustom = Settings.AutoFarmCustomMob and Settings.CustomMob ~= nil
        if (Settings.AutoFarm or isCustom) and not _sea2EventActive and not _materialFarmActive and not Settings.AutoDungeon then
            pcall(function()
                if Settings.AutoFarm then
                    Settings.HoverFarm = true
                    Settings.LockLookAtMob = true
                    Settings.InstantTP = true
                end

                Character = Player.Character
                Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
                HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
                if not Character or not Character.Parent or not Humanoid or not HumanoidRootPart or not HumanoidRootPart.Parent then
                    DisableHoverLock()
                    Character = Player.Character or Player.CharacterAdded:Wait()
                    Humanoid = Character:WaitForChild("Humanoid")
                    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
                    wait(2); return
                end
                local level = GetLevel()
                local quest = isCustom and Settings.CustomMob or (_hakiState.getOfficialQuest and _hakiState.getOfficialQuest(level)) or GetQuestForLevel(level)
                if not quest then
                    DisableHoverLock()
                    _farmStatus = "No quest for Lv." .. level
                    wait(3); return
                end

                _currentQuest = quest
                _farmStatus = string.format("Lv.%d | %s", level, quest.MobName)

                if GetHPPercent() < Settings.SafeHP then
                    _farmStatus = "Low HP, hovering safely..."
                    local curPos = HumanoidRootPart.Position
                    local targetY = math.max(curPos.Y, math.min(curPos.Y + 35, 250))
                    local safePos = Vector3.new(curPos.X, targetY, curPos.Z)
                    EnableHoverLock(safePos, safePos - Vector3.new(0, 10, 0))
                    wait(2); return
                end

                if not isCustom and not HasActiveQuest() then
                    _farmStatus = "Accepting quest..."
                    TryAcceptQuestSmart(quest, _hakiState.lastFarmPos or HumanoidRootPart.Position)
                end

                local mob = FindNearestMob(quest.MobName, 10000, level)
                if mob then
                    local mobRoot = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart or mob:FindFirstChildOfClass("BasePart")
                    if mobRoot then
                        _hakiState.lastFarmPos = mobRoot.Position
                        _hakiState.lastFarmMobName = mob.Name
                        if not isCustom and not HasActiveQuest() then
                            _farmStatus = "Accepting quest..."
                            TryAcceptQuestSmart(quest, mobRoot.Position)
                        end
                        if Settings.BringMob then
                            BringMobs(mob.Name, mobRoot.Position)
                        end
                    end
                    _farmStatus = string.format("Attacking: %s", mob.Name)
                    AttackMob(mob)
                else
                    _farmStatus = "Streaming / waiting for mob: " .. tostring(quest.MobName)
                    local mobFolder = ReplicatedStorage:FindFirstChild("MOB")
                    local tpl = mobFolder and mobFolder:FindFirstChild(quest.MobName)
                    if not tpl and mobFolder and quest.MobName then
                        local stripped = quest.MobName:gsub("%s*%[Lv%.?%s*%d+%]%s*", ""):lower()
                        for _, c in ipairs(mobFolder:GetChildren()) do
                            if c.Name:lower():find(stripped, 1, true) then
                                tpl = c
                                break
                            end
                        end
                    end
                    if tpl and tpl:IsA("Model") then
                        local ok, tplCF = pcall(function() return tpl:GetModelCFrame() end)
                        if ok and typeof(tplCF) == "CFrame" then
                            _hakiState.lastFarmPos = tplCF.Position
                            if (HumanoidRootPart.Position - tplCF.Position).Magnitude > 140 then
                                local off = _hakiState.getHoverOffset and _hakiState.getHoverOffset() or Vector3.new(0, Settings.HoverHeight, 0)
                                FastTeleport(tplCF + off, true)
                            end
                        end
                    end

                    local anchor = nil
                    if _hakiState.lastFarmPos and (HumanoidRootPart.Position - _hakiState.lastFarmPos).Magnitude <= 2500 then
                        anchor = _hakiState.lastFarmPos
                    end
                    if not anchor then
                        for _, fName in ipairs({"Monster", "MOB"}) do
                            local mFolder = Workspace:FindFirstChild(fName)
                            if mFolder then
                                local bestD = 2500
                                for _, obj in ipairs(mFolder:GetDescendants()) do
                                    if obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj) then
                                        local r = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
                                        if r then
                                            local d = (HumanoidRootPart.Position - r.Position).Magnitude
                                            if d < bestD then
                                                bestD = d
                                                anchor = r.Position
                                            end
                                        end
                                    end
                                end
                            end
                            if anchor then break end
                        end
                    end
                    if not anchor then
                        for _, fName in ipairs({"AllNPC", "NPCs"}) do
                            local f = Workspace:FindFirstChild(fName)
                            if f then
                                local bestD = 2500
                                for _, npc in ipairs(f:GetChildren()) do
                                    if npc:IsA("Model") then
                                        local r = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart or npc:FindFirstChildOfClass("BasePart")
                                        if r then
                                            local d = (HumanoidRootPart.Position - r.Position).Magnitude
                                            if d < bestD then
                                                bestD = d
                                                anchor = r.Position
                                            end
                                        end
                                    end
                                end
                            end
                            if anchor then break end
                        end
                    end
                    anchor = anchor or HumanoidRootPart.Position
                    local off = _hakiState.getHoverOffset and _hakiState.getHoverOffset() or Vector3.new(0, Settings.HoverHeight, 0)
                    local hoverWaitPos = anchor + off
                    EnableHoverLock(hoverWaitPos, anchor)
                    wait(1)
                end
            end)
        elseif not _sea2EventActive and not _materialFarmActive and not Settings.AutoDungeon then
            if not Settings.AutoBoss and not _hakiState.extraCombatActive then
                DisableHoverLock()
            end
            _farmStatus = "Idle"
        end
        wait(Settings.FarmDelay)
    end
end

local function FarmBoss()
    while _running do
        if Settings.AutoBoss and not _sea2EventActive and not _materialFarmActive and not Settings.AutoDungeon then
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
                    local root = bossModel:FindFirstChild("HumanoidRootPart") or bossModel.PrimaryPart
                    if root then
                        _hakiState.lastBossPos = root.Position
                        if Settings.BringMob and not Settings.HoverFarm then
                            pcall(function()
                                root.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, 0, -Settings.BringOffset)
                            end)
                        end
                    end
                    AttackMob(bossModel)
                else
                    local anchor = _hakiState.lastBossPos or HumanoidRootPart.Position
                    local off = _hakiState.getHoverOffset and _hakiState.getHoverOffset() or Vector3.new(0, Settings.HoverHeight, 0)
                    local hoverPos = anchor + off
                    EnableHoverLock(hoverPos, anchor)
                    _farmStatus = "Waiting for Boss: " .. boss.Name
                    wait(2)
                end
            end)
        elseif not _sea2EventActive and not _materialFarmActive and not Settings.AutoDungeon then
            if not Settings.AutoFarm and not Settings.AutoFarmCustomMob and not _hakiState.extraCombatActive then
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
-- OFFICIAL EXTRA FEATURES, AIMBOT, EVENTS, ESP, FPS BOOST
-- =====================================================
do
    local function getChestFunctions()
        local chest = ReplicatedStorage:FindFirstChild("Chest")
        local remotes = chest and chest:FindFirstChild("Remotes")
        return remotes and remotes:FindFirstChild("Functions")
    end

    local function getEtcFunction()
        local funcs = getChestFunctions()
        return funcs and funcs:FindFirstChild("EtcFunction")
    end

    -- 1. Auto Enter Game (if still on Loading / Menu screen)
    task.spawn(function()
        task.wait(0.8)
        if not _running then return end
        local pg = Player:FindFirstChild("PlayerGui")
        local shouldEnter = (not Player.Character)
        if pg then
            for _, g in ipairs(pg:GetChildren()) do
                local n = g.Name:lower()
                if (n:find("loading", 1, true) or n:find("menu", 1, true) or n:find("enter", 1, true)) and (g:IsA("ScreenGui") and g.Enabled) then
                    shouldEnter = true
                    break
                end
            end
        end
        if shouldEnter then
            local etcFn = getEtcFunction()
            if etcFn and etcFn:IsA("RemoteFunction") then
                pcall(function()
                    etcFn:InvokeServer("EnterTheGame", {})
                end)
            end
        end
    end)

    -- 2. Guarded SkillAction __namecall Aimbot Hook
    if not _hakiState.skillAimbotHooked
        and typeof(getrawmetatable) == "function"
        and typeof(getnamecallmethod) == "function"
        and typeof(setreadonly) == "function" then
        _hakiState.skillAimbotHooked = true
        pcall(function()
            local mt = getrawmetatable(game)
            if not mt or not mt.__namecall then return end
            local oldNamecall = mt.__namecall
            local wrapFn = (typeof(newcclosure) == "function") and newcclosure or function(f) return f end
            setreadonly(mt, false)
            mt.__namecall = wrapFn(function(self, ...)
                local method = getnamecallmethod()
                local args = {...}
                if _running and Settings.SkillAimbot and method == "InvokeServer" and tostring(self) == "SkillAction" then
                    local targetCF = (typeof(getgenv) == "function") and getgenv().PosMonSkill or nil
                    if typeof(targetCF) == "CFrame" and type(args[3]) == "table" and (args[3].Type == "Up" or args[3].Type == "Down") then
                        args[3].MouseHit = targetCF
                        return oldNamecall(self, table.unpack(args))
                    end
                end
                return oldNamecall(self, ...)
            end)
            setreadonly(mt, true)
        end)
    end

    -- 3. Shared Combat & Helper Utilities
    local function fightTarget(mob, statusText)
        if not mob or not mob.Parent then return false end
        local root = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart or mob:FindFirstChildOfClass("BasePart")
        if root and Settings.BringMob then
            BringMobs(mob.Name, root.Position)
        end
        _farmStatus = statusText
        return AttackMob(mob)
    end

    local function findFirstAliveTarget(namesList, maxDist)
        for _, name in ipairs(namesList) do
            local mob = FindNearestMob(name, maxDist or 50000)
            if mob then return mob end
        end
        for _, folderName in ipairs({"SeaMonster", "SeaMonsters", "Monster", "MOB"}) do
            local folder = Workspace:FindFirstChild(folderName)
            if folder then
                for _, obj in ipairs(folder:GetChildren()) do
                    if obj:IsA("Model") then
                        local hum = obj:FindFirstChildOfClass("Humanoid")
                        local root = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
                        if hum and hum.Health > 0 and root then
                            local lname = obj.Name:lower()
                            for _, targetName in ipairs(namesList) do
                                if lname:find(targetName:lower(), 1, true) then
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

    local function farmNamedTargets(namesList, statusLabel)
        local mob = findFirstAliveTarget(namesList, 50000)
        if mob then
            fightTarget(mob, statusLabel .. ": " .. mob.Name)
            return true
        end
        -- Check ReplicatedStorage.MOB template to stream far islands
        local mobFolder = ReplicatedStorage:FindFirstChild("MOB")
        if mobFolder and HumanoidRootPart and HumanoidRootPart.Parent then
            for _, targetName in ipairs(namesList) do
                local tLower = targetName:lower()
                for _, tpl in ipairs(mobFolder:GetChildren()) do
                    if tpl:IsA("Model") and tpl.Name:lower():find(tLower, 1, true) then
                        local ok, cf = pcall(function() return tpl:GetModelCFrame() end)
                        if ok and typeof(cf) == "CFrame" and (HumanoidRootPart.Position - cf.Position).Magnitude > 180 then
                            local off = _hakiState.getHoverOffset and _hakiState.getHoverOffset() or Vector3.new(0, Settings.HoverHeight, 0)
                            FastTeleport(cf + off, true)
                            _farmStatus = "Streaming " .. tpl.Name .. "..."
                            return true
                        end
                    end
                end
            end
        end
        return false
    end

    local function visitNPCAndInteract(npcName, statusLabel)
        local allNPC = Workspace:FindFirstChild("AllNPC")
        local npc = allNPC and allNPC:FindFirstChild(npcName)
        if not npc then
            for _, fName in ipairs({"NPCs", "NPC", "QuestNPCs"}) do
                local f = Workspace:FindFirstChild(fName)
                npc = f and f:FindFirstChild(npcName)
                if npc then break end
            end
        end
        if npc then
            local root = npc:IsA("BasePart") and npc or (npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart or npc:FindFirstChildOfClass("BasePart"))
            if root and HumanoidRootPart and HumanoidRootPart.Parent then
                DisableHoverLock()
                FastTeleport(root.CFrame + Vector3.new(0, 3, 2), true)
                task.wait(0.15)
                _farmStatus = statusLabel or ("Talking to " .. npcName)
                InteractWithNPC(npcName)
                return true
            end
        end
        return false
    end

    -- Third Sea Live Status Helper
    local thirdSeaBossSpecs = {
        {label = "Abyssal Tyrant", name = "SeaDragon"},
        {label = "Chaos Kraken", name = "FuryTentacle"},
        {label = "Deepsea Crusher", name = "ThirdSeaEldritch Crab"},
        {label = "Drakenfyr", name = "ThirdSeaDragon"},
    }
    _hakiState.getSea3LiveStatusText = function()
        local parts = {}
        local ig = GetInGameSeaTimer("third", "kraken")
        table.insert(parts, "Sea 3 Timer: " .. (ig or "Waiting / Not Shown"))
        for _, spec in ipairs(thirdSeaBossSpecs) do
            local m = findFirstAliveTarget({spec.name}, 80000)
            if m then
                local hum = m:FindFirstChildOfClass("Humanoid")
                local hp = hum and math.floor(hum.Health) or 0
                table.insert(parts, string.format("%s: SPAWNED! (HP: %d)", spec.label, hp))
            else
                table.insert(parts, spec.label .. ": Not Spawned")
            end
        end
        return table.concat(parts, "\n")
    end

    -- 4. Extra Combat / Third Sea / Unlocks / Events / Nearest Loop
    task.spawn(function()
        local lastNpcTick = 0
        while _running do
            local didWork = false
            local blocked = Settings.AutoDungeon or _sea2EventActive or _materialFarmActive
            if not blocked and Character and Character.Parent and HumanoidRootPart and HumanoidRootPart.Parent and Humanoid and Humanoid.Health > 0 then
                pcall(function()
                    -- Third Sea Event Bosses
                    if Settings.AutoDrakenfyr and farmNamedTargets({"ThirdSeaDragon", "Drakenfyr"}, "Killing Drakenfyr") then
                        didWork = true
                    elseif Settings.AutoChaosKraken and farmNamedTargets({"FuryTentacle", "Chaos Kraken"}, "Killing Chaos Kraken") then
                        didWork = true
                    elseif Settings.AutoDeepseaCrusher and farmNamedTargets({"ThirdSeaEldritch Crab", "Eldritch Crab"}, "Killing Deepsea Crusher") then
                        didWork = true
                    elseif Settings.AutoAbyssalTyrant and farmNamedTargets({"SeaDragon", "Abyssal Tyrant"}, "Killing Abyssal Tyrant") then
                        didWork = true
                    end

                    -- Sea 2 Unlock Quest
                    if not didWork and Settings.AutoSea2Unlock then
                        local stats = Player:FindFirstChild("PlayerStats")
                        local s2 = stats and stats:FindFirstChild("SecondSeaProgression")
                        if not s2 or tostring(s2.Value) ~= "Yes" then
                            if farmNamedTargets({"Seasoned Fishman"}, "Sea 2 Quest") then
                                didWork = true
                            elseif (tick() - lastNpcTick) >= 3 then
                                lastNpcTick = tick()
                                if visitNPCAndInteract("Traveler", "Sea 2 Quest: Traveler") then
                                    didWork = true
                                end
                            end
                        end
                    end

                    -- Sea 3 Unlock Quest
                    if not didWork and Settings.AutoSea3Unlock then
                        local heartCount = GetMaterialCount("Heart of Sea")
                        local cacheCount = GetMaterialCount("Kraken's Cache")
                        if cacheCount >= 1 then
                            if (tick() - lastNpcTick) >= 3 then
                                lastNpcTick = tick()
                                visitNPCAndInteract("The Squid", "Sea 3 Quest: The Squid")
                            end
                            didWork = true
                        elseif heartCount >= 1 then
                            if farmNamedTargets({"Tentacle"}, "Sea 3 Quest: Tentacle") then
                                didWork = true
                            elseif (tick() - lastNpcTick) >= 3 then
                                lastNpcTick = tick()
                                visitNPCAndInteract("Summon Tentacle", "Sea 3 Quest: Summon Tentacle")
                                didWork = true
                            end
                        elseif (tick() - lastNpcTick) >= 3 then
                            lastNpcTick = tick()
                            if visitNPCAndInteract("Jack Stones", "Sea 3 Quest: Jack Stones") then
                                didWork = true
                            end
                        end
                    end

                    -- Haki V2 & Observation V2 Quests
                    if not didWork and Settings.AutoHakiV2 then
                        if farmNamedTargets({"Dark Beard", "Sally"}, "Haki V2 Quest") then
                            didWork = true
                        elseif (tick() - lastNpcTick) >= 3 then
                            lastNpcTick = tick()
                            if not visitNPCAndInteract("Lee", "Haki V2: Lee") then
                                visitNPCAndInteract("Pung", "Haki V2: Pung")
                            end
                            didWork = true
                        end
                    end

                    if not didWork and Settings.AutoObserveV2 then
                        if farmNamedTargets({"LeePung"}, "Observation V2 Quest") then
                            didWork = true
                        elseif (tick() - lastNpcTick) >= 3 then
                            lastNpcTick = tick()
                            if visitNPCAndInteract("Stranger Uncle", "Observation V2: Stranger Uncle") then
                                didWork = true
                            end
                        end
                    end

                    -- Passive Tree
                    if not didWork and Settings.AutoPassiveTree and (tick() - lastNpcTick) >= 3 then
                        lastNpcTick = tick()
                        visitNPCAndInteract("PassiveTree", "Passive Tree")
                    end

                    -- Jack o Lantern / Skull King / Candy / Event Minions
                    if not didWork and Settings.AutoKillJackO then
                        if farmNamedTargets({"Jack o lantern", "Jack o Lantern"}, "Killing Jack o Lantern") then
                            didWork = true
                        elseif Settings.AutoSummonJackO and GetMaterialCount("Candy") > 50 and (tick() - lastNpcTick) >= 3 then
                            lastNpcTick = tick()
                            if visitNPCAndInteract("SummonJackolantern", "Summoning Jack o Lantern") then
                                didWork = true
                            end
                        end
                    elseif not didWork and Settings.AutoSummonJackO and GetMaterialCount("Candy") > 50 and (tick() - lastNpcTick) >= 3 then
                        lastNpcTick = tick()
                        visitNPCAndInteract("SummonJackolantern", "Summoning Jack o Lantern")
                        didWork = true
                    end

                    if not didWork and Settings.AutoKillSkullKing and farmNamedTargets({"Skull King"}, "Killing Skull King") then
                        didWork = true
                    end

                    if not didWork and Settings.AutoKillMinion then
                        local evSpawns = Workspace:FindFirstChild("EventSpawns")
                        if evSpawns then
                            for _, sp in ipairs(evSpawns:GetChildren()) do
                                local chest = sp:FindFirstChild("Chest")
                                local root = chest and (chest:FindFirstChild("RootPart") or chest:FindFirstChildOfClass("BasePart"))
                                if root and root.Transparency < 1 then
                                    CollectTargetPart(root)
                                    didWork = true
                                    break
                                end
                            end
                        end
                        if not didWork then
                            for i = 1, 7 do
                                local c = Workspace:FindFirstChild("Chest" .. i)
                                if c then
                                    local p = c:IsA("BasePart") and c or (c:FindFirstChild("RootPart") or c:FindFirstChildOfClass("BasePart"))
                                    if p and p.Transparency < 1 then
                                        CollectTargetPart(p)
                                        didWork = true
                                        break
                                    end
                                end
                            end
                        end
                        if not didWork and farmNamedTargets({"Minion", "Halloween"}, "Killing Event Minions") then
                            didWork = true
                        end
                    end

                    if not didWork and Settings.AutoFarmCandy and farmNamedTargets({"Candy", "Skeleton", "Pumpkin", "Jack"}, "Farming Candy") then
                        didWork = true
                    end

                    -- Auto Farm Nearest Mob (yields to Farm Level / Custom Mob / Boss)
                    if not didWork and Settings.AutoFarmNearest and not Settings.AutoFarm and not Settings.AutoFarmCustomMob and not Settings.AutoBoss then
                        local mob = FindNearestMob(nil, 2500)
                        if mob then
                            didWork = fightTarget(mob, "Nearest: " .. mob.Name)
                        end
                    end
                end)
            end

            local wasExtra = _hakiState.extraCombatActive
            _hakiState.extraCombatActive = didWork
            if wasExtra and not didWork and not Settings.AutoFarm and not Settings.AutoFarmCustomMob and not Settings.AutoBoss and not _sea2EventActive and not _materialFarmActive and not Settings.AutoDungeon then
                DisableHoverLock()
            end
            task.wait(0.25)
        end
    end)

    -- 5. Fruit / Keys / Stock / Accessories / InfGeppo Utilities
    task.spawn(function()
        local lastKeyTick, lastStockTick, lastAccTick = 0, 0, 0
        while _running do
            local now = tick()
            pcall(function()
                -- Bring All Workspace Fruits to Player
                if Settings.BringAllFruits and HumanoidRootPart and HumanoidRootPart.Parent then
                    for _, obj in ipairs(Workspace:GetChildren()) do
                        if obj:IsA("Tool") and obj.Name:lower():find("fruit", 1, true) then
                            local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildOfClass("BasePart")
                            if handle then
                                handle.CFrame = HumanoidRootPart.CFrame
                            end
                        end
                    end
                end

                -- Auto Store Fruit
                if Settings.AutoStoreFruit then
                    local pg = Player:FindFirstChild("PlayerGui")
                    local char = Player.Character
                    local bp = Player:FindFirstChild("Backpack")
                    if char and not char:FindFirstChildOfClass("Tool") and bp then
                        for _, t in ipairs(bp:GetChildren()) do
                            if t:IsA("Tool") and t.Name:lower():find("fruit", 1, true) and not IsCombatWeaponTool(t) then
                                local hum = char:FindFirstChildOfClass("Humanoid")
                                if hum then pcall(function() hum:EquipTool(t) end) end
                                break
                            end
                        end
                    end
                    local becky = pg and pg:FindFirstChild("EatFruitBecky")
                    local dlg = becky and becky:FindFirstChild("Dialogue")
                    local collectBtn = dlg and dlg:FindFirstChild("Collect")
                    if collectBtn and typeof(firesignal) == "function" then
                        pcall(function() firesignal(collectBtn.MouseButton1Click) end)
                        pcall(function() firesignal(collectBtn.Activated) end)
                    end
                end

                -- Auto Buy / Open Keys
                if (Settings.AutoBuyKey or Settings.AutoOpenKey) and (now - lastKeyTick) >= 1.5 then
                    lastKeyTick = now
                    local funcs = getChestFunctions()
                    if funcs then
                        local keyName = Settings.SelectedKey or "Copper Key"
                        if Settings.AutoBuyKey then
                            local buyKey = funcs:FindFirstChild("BuyKey")
                            if buyKey and buyKey:IsA("RemoteFunction") then
                                pcall(function() buyKey:InvokeServer(keyName, 1) end)
                            end
                        end
                        if Settings.AutoOpenKey then
                            local useKey = funcs:FindFirstChild("UseKey")
                            if useKey and useKey:IsA("RemoteFunction") then
                                pcall(function() useKey:InvokeServer(keyName, "Open1") end)
                            end
                        end
                    end
                end

                -- Auto Buy Fruit Stock
                if Settings.AutoBuyStockFruit and Settings.SelectedStockFruit ~= "" and (now - lastStockTick) >= 2.0 then
                    lastStockTick = now
                    local funcs = getChestFunctions()
                    local buyStock = funcs and funcs:FindFirstChild("BuyFruitStock")
                    if buyStock and buyStock:IsA("RemoteFunction") then
                        pcall(function() buyStock:InvokeServer(Settings.SelectedStockFruit, true) end)
                    end
                end

                -- Auto Equip Accessory
                if Settings.AutoEquipAccessory and Settings.SelectedAccessory ~= "" and (now - lastAccTick) >= 2.5 then
                    lastAccTick = now
                    local char = Player.Character
                    if char and not char:FindFirstChild(Settings.SelectedAccessory) then
                        local funcs = getChestFunctions()
                        local accEq = funcs and funcs:FindFirstChild("AccessoryEq")
                        if accEq and accEq:IsA("RemoteFunction") then
                            pcall(function() accEq:InvokeServer(Settings.SelectedAccessory) end)
                        end
                    end
                end
            end)
            task.wait(0.5)
        end
    end)

    -- Inf Geppo via JumpRequest
    do
        local geppoConn
        geppoConn = UIS.JumpRequest:Connect(function()
            if not _running then
                if geppoConn then geppoConn:Disconnect(); geppoConn = nil end
                return
            end
            if not Settings.InfGeppo then return end
            pcall(function()
                local char = Player.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end)
    end

    -- 6. FPS Boost / Anti-Lag Loop + Restore on Disable
    task.spawn(function()
        local whiteApplied = false
        local uiHiddenApplied = false
        local effectsMoved = false
        while _running do
            pcall(function()
                if Settings.WhiteScreen then
                    if not whiteApplied then
                        whiteApplied = true
                        RunService:Set3dRenderingEnabled(false)
                    end
                elseif whiteApplied then
                    whiteApplied = false
                    RunService:Set3dRenderingEnabled(true)
                end

                local pg = Player:FindFirstChild("PlayerGui")
                local chest = ReplicatedStorage:FindFirstChild("Chest")
                local chestGui = chest and chest:FindFirstChild("Gui")
                if Settings.HideLevelUpUI then
                    uiHiddenApplied = true
                    for _, parentGui in ipairs({pg, chestGui}) do
                        if parentGui then
                            for _, name in ipairs({"LevelUp", "ItemDrop"}) do
                                local g = parentGui:FindFirstChild(name)
                                if g and g:IsA("LayerCollector") then g.Enabled = false end
                            end
                        end
                    end
                elseif uiHiddenApplied then
                    uiHiddenApplied = false
                    for _, parentGui in ipairs({pg, chestGui}) do
                        if parentGui then
                            for _, name in ipairs({"LevelUp", "ItemDrop"}) do
                                local g = parentGui:FindFirstChild(name)
                                if g and g:IsA("LayerCollector") then g.Enabled = true end
                            end
                        end
                    end
                end

                if Settings.HideMobHealth then
                    for _, fName in ipairs({"Monster", "MOB"}) do
                        local f = Workspace:FindFirstChild(fName)
                        if f then
                            for _, d in ipairs(f:GetDescendants()) do
                                if d:IsA("BillboardGui") then
                                    d.Enabled = false
                                elseif d:IsA("Humanoid") then
                                    d.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                                end
                            end
                        end
                    end
                end

                if Settings.DeleteDamageText then
                    for _, container in ipairs({Workspace, pg}) do
                        if container then
                            local dmg = container:FindFirstChild("DamageShow")
                            if dmg then
                                if dmg:IsA("LayerCollector") then
                                    dmg.Enabled = false
                                else
                                    dmg:ClearAllChildren()
                                end
                            end
                        end
                    end
                end

                local effects = Workspace:FindFirstChild("Effects")
                local cam = Workspace.CurrentCamera
                if Settings.DeleteHeavyEffects and effects and cam then
                    effectsMoved = true
                    for _, child in ipairs(effects:GetChildren()) do
                        child.Parent = cam
                    end
                elseif effectsMoved and effects and cam then
                    effectsMoved = false
                    for _, child in ipairs(cam:GetChildren()) do
                        if not child:IsA("Camera") then
                            child.Parent = effects
                        end
                    end
                end
            end)
            task.wait(1.0)
        end
        pcall(function() RunService:Set3dRenderingEnabled(true) end)
    end)

    -- 7. Lightweight ESP Loop + Cleanup
    task.spawn(function()
        local activeEsps = {}
        local function clearAllEsp()
            for obj, bb in pairs(activeEsps) do
                pcall(function()
                    if bb and bb.Parent then bb:Destroy() end
                end)
                activeEsps[obj] = nil
            end
        end

        local function setEspTag(targetPart, textStr, color3)
            if not targetPart or not targetPart.Parent then return end
            local bb = activeEsps[targetPart]
            if not bb or not bb.Parent then
                bb = Instance.new("BillboardGui")
                bb.Name = "KL_ESP"
                bb.AlwaysOnTop = true
                bb.Size = UDim2.fromOffset(160, 26)
                bb.StudsOffset = Vector3.new(0, 3, 0)
                local lbl = Instance.new("TextLabel")
                lbl.Name = "Label"
                lbl.BackgroundTransparency = 1
                lbl.Size = UDim2.fromScale(1, 1)
                lbl.Font = Enum.Font.SourceSansBold
                lbl.TextSize = 13
                lbl.TextStrokeTransparency = 0.3
                lbl.TextColor3 = color3
                lbl.Parent = bb
                bb.Parent = targetPart
                activeEsps[targetPart] = bb
            end
            local lbl = bb:FindFirstChild("Label")
            if lbl then
                lbl.Text = textStr
                lbl.TextColor3 = color3
            end
        end

        while _running do
            local anyEsp = Settings.ESPPlayer or Settings.ESPFruit or Settings.ESPLegacyIsland or Settings.ESPHydraIsland or Settings.ESPGhostShip
            if not anyEsp then
                clearAllEsp()
            else
                local wanted = {}
                local myRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                local function getDist(part)
                    return myRoot and math.floor((part.Position - myRoot.Position).Magnitude) or 0
                end

                pcall(function()
                    if Settings.ESPPlayer then
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p ~= Player and p.Character then
                                local r = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Head")
                                if r then
                                    wanted[r] = true
                                    setEspTag(r, string.format("[Player] %s (%dm)", p.Name, getDist(r)), Color3.fromRGB(100, 220, 255))
                                end
                            end
                        end
                    end

                    if Settings.ESPFruit then
                        for _, obj in ipairs(Workspace:GetChildren()) do
                            if (obj:IsA("Tool") or obj:IsA("Model")) and obj.Name:lower():find("fruit", 1, true) then
                                local r = obj:FindFirstChild("Handle") or obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
                                if r then
                                    wanted[r] = true
                                    setEspTag(r, string.format("[Fruit] %s (%dm)", obj.Name, getDist(r)), Color3.fromRGB(255, 190, 60))
                                end
                            end
                        end
                    end

                    local islandFolder = Workspace:FindFirstChild("Island")
                    if islandFolder then
                        for _, child in ipairs(islandFolder:GetChildren()) do
                            local cl = child.Name:lower()
                            if Settings.ESPLegacyIsland and cl:find("legacy island", 1, true) then
                                local r = child:FindFirstChild("ChestSpawner") or child.PrimaryPart or child:FindFirstChildOfClass("BasePart")
                                local p = (r and r:IsA("BasePart") and r) or (r and r:FindFirstChildOfClass("BasePart"))
                                if p then
                                    wanted[p] = true
                                    setEspTag(p, string.format("[Legacy Island] (%dm)", getDist(p)), Color3.fromRGB(120, 255, 140))
                                end
                            elseif Settings.ESPHydraIsland and (cl:find("sea king", 1, true) or cl:find("hydra", 1, true)) then
                                local r = child:FindFirstChild("HydraStand") or child.PrimaryPart or child:FindFirstChildOfClass("BasePart")
                                local p = (r and r:IsA("BasePart") and r) or (r and r:FindFirstChildOfClass("BasePart"))
                                if p then
                                    wanted[p] = true
                                    setEspTag(p, string.format("[Hydra Island] (%dm)", getDist(p)), Color3.fromRGB(255, 90, 90))
                                end
                            end
                        end
                    end

                    if Settings.ESPGhostShip then
                        local gs = FindGhostShipModel()
                        if gs then
                            local p = gs.PrimaryPart or gs:FindFirstChildOfClass("BasePart")
                            if p then
                                wanted[p] = true
                                setEspTag(p, string.format("[Ghost Ship] (%dm)", getDist(p)), Color3.fromRGB(190, 130, 255))
                            end
                        end
                    end
                end)

                for obj, bb in pairs(activeEsps) do
                    if not wanted[obj] or not obj.Parent then
                        pcall(function() if bb and bb.Parent then bb:Destroy() end end)
                        activeEsps[obj] = nil
                    end
                end
            end
            task.wait(0.6)
        end
        clearAllEsp()
    end)
end

-- =====================================================
-- RYZEN HUB UI (13 TABS)
-- =====================================================
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/phamvienbie/Lua-tester/refs/heads/main/HubUI_v7.lua"))()

local Window = UI:CreateWindow({
    Title = "Ryzen Hub",
    Author = "King Legacy",
    Folder = "Ryzen Hub",
    Size = UDim2.fromOffset(580, 300),
    Scale = 1,
    ToggleKey = Enum.KeyCode.RightControl,
    Hidden = true,
})

local loading = Window:Loading("Loading", "Initializing King Legacy Hub...")

local HomeTimeParagraph, HomeStatsParagraph, StatusParagraph, MaterialStatusParagraph, ReStatusParagraph, Sea2TimerParagraph, DungeonStatusParagraph

-- ============================================================
-- 1. TAB: Home
-- ============================================================
do
local Home = Window:Tab({Title = "Home"})

local InfoSec = Home:Section({Title = "About Ryzen Hub", Side = "Left"})
InfoSec:Paragraph({
    Title = "Ryzen Hub - T3 Studio",
    Desc = "Ryzen Hub was created by kaibeo, a member of T3 Studio specializing in script creation and executors, etc.",
})
HomeTimeParagraph = InfoSec:Paragraph({
    Title = "Time Server & Time Game",
    Desc = "Server Time: --\nGame Time (Session): --\nIn-Game Time: --\nReal Time: --\nServer Players: --",
})
InfoSec:Button({
    Title = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
    end,
})
InfoSec:Button({
    Title = "Server Hop",
    Callback = function()
        ServerHop()
    end,
})

local HomeStatsSec = Home:Section({Title = "Money, Gems & Character", Side = "Right"})
HomeStatsParagraph = HomeStatsSec:Paragraph({
    Title = "Account Info",
    Desc = "Player: --\nLevel: --\nBeli: --\nGems: --\nBounty: --\nFruit: --\nHP: --%",
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

end

-- ============================================================
-- 2. TAB: Farm
-- ============================================================
do
local Farm = Window:Tab({Title = "Farm"})

local FarmMainSec = Farm:Section({Title = "Farm Level", Side = "Left"})
FarmMainSec:Toggle({
    Title = "Auto Farm Level", Value = false, Flag = "AutoFarmLevel",
    Callback = function(v)
        Settings.AutoFarm = v
        if v then
            Settings.AutoFarmCustomMob = false
            Settings.HoverFarm = true
            Settings.LockLookAtMob = true
            Settings.InstantTP = true
        end
        UI:Notify({
            Title = "Auto Farm",
            Content = v and "Started Auto Farm Level (Hover + Lock + TP Bypass)!" or "Stopped Auto Farm Level",
            Kind = v and "success" or "info",
            Duration = 2,
        })
        if not v then
            _farmStatus = "Idle"
            if not Settings.AutoBoss and not Settings.AutoFarmCustomMob and not _sea2EventActive and not _materialFarmActive and not _hakiState.extraCombatActive then DisableHoverLock() end
        end
    end,
})
FarmMainSec:Toggle({
    Title = "Auto Farm Nearest Mob", Value = false, Flag = "AutoFarmNearest",
    Callback = function(v)
        Settings.AutoFarmNearest = v
        if not v and not Settings.AutoFarm and not Settings.AutoBoss and not Settings.AutoFarmCustomMob then
            DisableHoverLock()
        end
    end,
})
FarmMainSec:Dropdown({
    Title = "Farm Position Mode", Values = {"Above", "Beside", "Lower"}, Value = "Above", Flag = "FarmPosition",
    Callback = function(v) Settings.FarmPosition = v end,
})
FarmMainSec:Toggle({
    Title = "Skill Aimbot (SkillAction)", Value = true, Flag = "SkillAimbot",
    Callback = function(v) Settings.SkillAimbot = v end,
})
StatusParagraph = FarmMainSec:Paragraph({
    Title = "Farm Status",
    Desc = "Level: --\nQuest: --\nTarget: --\nHP: --%\nBring: 0 mobs",
})

local MatSec = Farm:Section({Title = "Material Farm", Side = "Left"})
MatSec:Dropdown({
    Title = "Select Material", Values = MaterialLabels, Value = MaterialLabels[1], Flag = "SelectedMaterial",
    Callback = function(v)
        Settings.SelectedMaterial = v
        local entry = GetMaterialEntry(v)
        UI:Notify({
            Title = "Material",
            Content = string.format("Selected: %s (Sea %d)", entry.Name, entry.Sea),
            Kind = "info",
            Duration = 2,
        })
    end,
})
MatSec:Toggle({
    Title = "Auto Farm Material", Value = false, Flag = "AutoFarmMaterial",
    Callback = function(v)
        Settings.AutoFarmMaterial = v
        local entry = GetMaterialEntry(Settings.SelectedMaterial)
        UI:Notify({
            Title = "Material Farm",
            Content = v and ("ON - Farming: " .. entry.Name) or "OFF",
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
    Title = "TP To Material Area",
    Callback = function()
        local entry = GetMaterialEntry(Settings.SelectedMaterial)
        if entry then
            DisableHoverLock()
            FastTeleport(entry.Area, true)
            UI:Notify({Title = "Teleport", Content = "Teleported to " .. entry.Name .. " area (Sea " .. entry.Sea .. ")", Kind = "success", Duration = 2})
        end
    end,
})
MaterialStatusParagraph = MatSec:Paragraph({
    Title = "Material Bag",
    Desc = "Selected: Carrot | Count: --",
})

local CodeSec = Farm:Section({Title = "Redeem Code & Quick Boss", Side = "Right"})
CodeSec:Toggle({
    Title = "Auto Redeem All Codes", Value = false, Flag = "AutoRedeemCodes",
    Callback = function(v)
        Settings.AutoRedeemCodes = v
        if v then
            RedeemAllCodes(function(count)
                UI:Notify({Title = "Codes", Content = "Submitted " .. count .. " codes!", Kind = "success", Duration = 2.5})
            end)
        end
    end,
})
CodeSec:Button({
    Title = "Redeem All Codes Now",
    Callback = function()
        UI:Notify({Title = "Codes", Content = "Redeeming " .. #KingLegacyCodes .. " codes...", Kind = "info", Duration = 2})
        RedeemAllCodes(function(count)
            UI:Notify({Title = "Codes", Content = "Finished redeeming " .. count .. " codes!", Kind = "success", Duration = 3})
        end)
    end,
})
CodeSec:Input({
    Title = "Enter Code", Placeholder = "e.g. 2MFAV", Flag = "ManualCode",
    Callback = function(text)
        local trimmed = text:match("^%s*(.-)%s*$")
        if trimmed and trimmed ~= "" then
            local ok = RedeemCode(trimmed)
            UI:Notify({Title = "Redeem Code", Content = ok and ("Submitted code: " .. trimmed) or "Code remote not found", Kind = ok and "success" or "error", Duration = 2})
        end
    end,
})
CodeSec:Toggle({
    Title = "Auto Farm Current Boss", Value = false, Flag = "QuickAutoBoss",
    Callback = function(v)
        Settings.AutoBoss = v
        UI:Notify({Title = "Boss", Content = v and "Boss farm enabled!" or "Disabled", Kind = v and "success" or "info", Duration = 2})
        if not v and not Settings.AutoFarm and not Settings.AutoFarmCustomMob and not _sea2EventActive and not _materialFarmActive then
            DisableHoverLock()
        end
    end,
})

end

-- ============================================================
-- 3. TAB: Setting Farm
-- ============================================================
do
local FSet = Window:Tab({Title = "Setting Farm"})

local WeaponBringSec = FSet:Section({Title = "Weapons & Bring Mob", Side = "Left"})
WeaponBringSec:Dropdown({
    Title = "Select Weapon Type", Values = {"Melee", "Sword", "Fruit", "All (ReAttack)"}, Value = "Melee", Flag = "WeaponType",
    Callback = function(v)
        Settings.WeaponType = v
        if v == "All (ReAttack)" then
            Settings.ReAttack = true
        end
    end,
})
local initialTools = GetToolNames()
local WeaponDropdown = WeaponBringSec:Dropdown({
    Title = "Select Weapon From Backpack", Values = initialTools, Value = initialTools[1], Flag = "SelectedWeapon",
    Callback = function(v)
        Settings.SelectedWeapon = v
        UI:Notify({Title = "Weapon", Content = "Selected: " .. v, Kind = "info", Duration = 1.5})
    end,
})
WeaponBringSec:Button({
    Title = "Refresh Weapons",
    Callback = function()
        local tools = GetToolNames()
        pcall(function()
            if WeaponDropdown.Refresh then WeaponDropdown:Refresh(tools)
            elseif WeaponDropdown.SetValues then WeaponDropdown:SetValues(tools) end
        end)
        UI:Notify({Title = "Weapons", Content = "Found " .. #tools .. " weapon(s): " .. table.concat(tools, ", "), Kind = "info", Duration = 2.5})
    end,
})
WeaponBringSec:Toggle({
    Title = "Bring Mobs", Value = true, Flag = "BringMobs",
    Callback = function(v)
        Settings.BringMob = v
        UI:Notify({Title = "Bring Mob", Content = v and "ON - Pulling mobs" or "OFF - Normal farm", Kind = v and "success" or "info", Duration = 2})
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
    Title = "Hover Height", Step = 1, Value = {Min = 5, Max = 35, Default = 14}, Flag = "HoverHeight",
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
    Title = "Auto Buso Haki", Value = true, Flag = "AutoHaki",
    Callback = function(v)
        Settings.AutoHaki = v
        if v then task.spawn(function() pcall(ActivateHaki) end) end
    end,
})
WeaponBringSec:Dropdown({
    Title = "Haki Key (Fallback)", Values = {"G", "J", "T", "H"}, Value = "G", Flag = "HakiKey",
    Callback = function(v) Settings.HakiKey = v end,
})

local StatsReSec = FSet:Section({Title = "Auto Stats & ReAttack", Side = "Right"})
StatsReSec:Toggle({
    Title = "Auto Upgrade Stats", Value = false, Flag = "AutoStats",
    Callback = function(v)
        Settings.AutoStats = v
        UI:Notify({Title = "Auto Stats", Content = v and "Auto-upgrading stats" or "Disabled", Kind = v and "success" or "info", Duration = 2})
    end,
})
StatsReSec:Dropdown({
    Title = "Select Stats", Multi = true, Values = {"Melee", "Defense", "Sword", "Fruit"}, Value = {"Melee", "Defense"}, Flag = "StatsList",
    Callback = function(list)
        if type(list) == "table" then
            Settings.StatsList = list
        end
    end,
})
StatsReSec:Slider({
    Title = "Points Per Upgrade", Step = 1, Value = {Min = 1, Max = 50, Default = 3}, Flag = "StatsPoints",
    Callback = function(v) Settings.StatsPoints = v end,
})
StatsReSec:Toggle({
    Title = "Enable ReAttack (Background M1 Spam)", Value = false, Flag = "ReAttack",
    Callback = function(v)
        Settings.ReAttack = v
        _m1Count = 0
        UI:Notify({Title = "ReAttack", Content = v and "ON - Background M1 spam enabled!" or "OFF", Kind = v and "success" or "info", Duration = 2})
    end,
})
StatsReSec:Toggle({
    Title = "Burst Skills (ZXCVB)", Value = true, Flag = "BurstSkills",
    Callback = function(v) Settings.BurstSkills = v end,
})
StatsReSec:Dropdown({
    Title = "M1 Method", Values = {"Activate", "Remote", "Both"}, Value = "Both", Flag = "M1Method",
    Callback = function(v) Settings.M1Method = v end,
})
do
    local function getAccessoryNames()
        local list = {}
        local accFolder = Player:FindFirstChild("Accessories")
        if accFolder then
            for _, child in ipairs(accFolder:GetChildren()) do
                table.insert(list, child.Name)
            end
        end
        table.sort(list)
        if #list == 0 then return {"None"} end
        return list
    end
    local initAcc = getAccessoryNames()
    local AccDropdown = StatsReSec:Dropdown({
        Title = "Select Accessory", Values = initAcc, Value = initAcc[1], Flag = "SelectedAccessory",
        Callback = function(v) Settings.SelectedAccessory = (v ~= "None") and v or "" end,
    })
    StatsReSec:Button({
        Title = "Refresh Accessories",
        Callback = function()
            local list = getAccessoryNames()
            pcall(function()
                if AccDropdown.Refresh then AccDropdown:Refresh(list)
                elseif AccDropdown.SetValues then AccDropdown:SetValues(list) end
            end)
            UI:Notify({Title = "Accessories", Content = "Found " .. #list .. " accessory item(s)", Kind = "info", Duration = 2})
        end,
    })
    StatsReSec:Toggle({
        Title = "Auto Equip Accessory", Value = false, Flag = "AutoEquipAccessory",
        Callback = function(v) Settings.AutoEquipAccessory = v end,
    })
    StatsReSec:Toggle({
        Title = "Auto Passive Tree", Value = false, Flag = "AutoPassiveTree",
        Callback = function(v) Settings.AutoPassiveTree = v end,
    })
end
StatsReSec:Slider({
    Title = "Swap Interval", Step = 0.02, Value = {Min = 0.08, Max = 1, Default = 0.22}, Flag = "SwapInterval",
    Callback = function(v) Settings.SwapInterval = v end,
})
StatsReSec:Slider({
    Title = "M1 Rate", Step = 0.01, Value = {Min = 0.02, Max = 0.5, Default = 0.05}, Flag = "M1Rate",
    Callback = function(v) Settings.M1Rate = v end,
})
StatsReSec:Input({
    Title = "ReAttack Weapons (comma-separated)", Placeholder = "Empty = auto cycle backpack", Flag = "WeaponInput",
    Callback = function(text)
        local weapons = {}
        for name in text:gmatch("[^,]+") do
            local trimmed = name:match("^%s*(.-)%s*$")
            if trimmed and trimmed ~= "" then table.insert(weapons, trimmed) end
        end
        Settings.ReAttackWeapons = weapons
    end,
})
ReStatusParagraph = StatsReSec:Paragraph({
    Title = "ReAttack Status",
    Desc = "Status: OFF\nM1 Count: 0",
})

end

-- ============================================================
-- 4. TAB: Activities
-- ============================================================
do
local ActTab = Window:Tab({Title = "Activities"})

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
            UI:Notify({Title = "Boss", Content = "Boss farm enabled!", Kind = "success", Duration = 2})
        elseif not Settings.AutoFarm and not Settings.AutoFarmCustomMob then
            DisableHoverLock()
        end
    end,
})
local bossListText = ""
for _, b in ipairs(BossData) do
    bossListText = bossListText .. string.format("- %s - Lv.%d (Sea %d)\n", b.Name, b.MinLevel, b.Sea)
end
BossSec:Paragraph({Title = "Boss List", Desc = bossListText})

local EventSec = ActTab:Section({Title = "Sea Events", Side = "Left"})
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

local DungeonSec = ActTab:Section({Title = "Auto Dungeon & Co-op", Side = "Right"})
DungeonSec:Dropdown({
    Title = "Select Dungeon Mode",
    Values = {"Easy", "Normal", "Hard", "Insane", "All / Auto"},
    Value = "Normal",
    Flag = "DungeonDifficulty",
    Callback = function(v)
        Settings.DungeonMode = v
        Settings.DungeonDifficulty = v
        UI:Notify({Title = "Dungeon Mode", Content = "Selected: " .. v, Kind = "info", Duration = 2})
    end,
})
DungeonSec:Dropdown({
    Title = "Dungeon Combat Style",
    Values = {"Hover Above (Tween)", "Behind Target", "Safe Evasion"},
    Value = "Hover Above (Tween)",
    Flag = "DungeonPlayMode",
    Callback = function(v)
        Settings.DungeonPlayMode = v
        UI:Notify({Title = "Dungeon Style", Content = "Style: " .. v, Kind = "info", Duration = 2})
    end,
})
DungeonSec:Toggle({
    Title = "Auto Dungeon",
    Value = false,
    Flag = "AutoDungeon",
    Callback = function(v)
        Settings.AutoDungeon = v
        if v then
            Settings.AutoFarm = false
            Settings.AutoFarmCustomMob = false
            Settings.AutoBoss = false
            DisableHoverLock()
            UI:Notify({
                Title = "Auto Dungeon",
                Content = "ON - Mode: " .. (Settings.DungeonMode or "Normal") .. " (" .. (Settings.DungeonPlayMode or "Hover") .. ")",
                Kind = "success",
                Duration = 2,
            })
        else
            if Settings.CleanupDungeon then Settings.CleanupDungeon() end
            UI:Notify({Title = "Auto Dungeon", Content = "OFF", Kind = "info", Duration = 2})
        end
    end,
})
do
    local initFriends = GetPlayerNames()
    local FriendsDropdown = DungeonSec:Dropdown({
        Title = "Shared Friends (Select Teammates)",
        Multi = true,
        Values = initFriends,
        Value = {},
        Flag = "DungeonFriends",
        Callback = function(val)
            local parsed = _hakiState.parseDungeonFriends and _hakiState.parseDungeonFriends(val) or {}
            Settings.DungeonFriends = parsed
            Settings.DungeonPartner = parsed[1] or ""
        end,
    })
    task.delay(1.5, function()
        if not _running or not _hakiState.getDungeonFriendList then return end
        local fList = _hakiState.getDungeonFriendList()
        pcall(function()
            if FriendsDropdown.Refresh then FriendsDropdown:Refresh(fList)
            elseif FriendsDropdown.SetValues then FriendsDropdown:SetValues(fList) end
        end)
    end)
    DungeonSec:Button({
        Title = "Refresh Friends List",
        Callback = function()
            local fList = (_hakiState.getDungeonFriendList and _hakiState.getDungeonFriendList()) or GetPlayerNames()
            pcall(function()
                if FriendsDropdown.Refresh then FriendsDropdown:Refresh(fList)
                elseif FriendsDropdown.SetValues then FriendsDropdown:SetValues(fList) end
            end)
            local friendCount = 0
            for _, entry in ipairs(fList) do
                if entry:find("%[Friend%]$") then
                    friendCount = friendCount + 1
                end
            end
            UI:Notify({
                Title = "Shared Friends",
                Content = string.format("Found %d player(s) (%d Roblox Friend(s))", (#fList == 1 and fList[1] == "None") and 0 or #fList, friendCount),
                Kind = "info",
                Duration = 2.5,
            })
        end,
    })
end
DungeonSec:Toggle({
    Title = "Friends Co-op Mode (Go Together)",
    Value = false,
    Flag = "DungeonPartnerMode",
    Callback = function(v)
        Settings.DungeonPartnerMode = v
        local summary = (_hakiState.getDungeonFriendSummary and _hakiState.getDungeonFriendSummary()) or (v and "ON" or "OFF")
        UI:Notify({
            Title = "Friends Co-op Mode",
            Content = v and ("Enabled - " .. summary) or "Disabled (Solo Mode)",
            Kind = v and "success" or "info",
            Duration = 2,
        })
    end,
})
DungeonSec:Toggle({
    Title = "Auto Detect Roblox Friends",
    Value = true,
    Flag = "DungeonAutoFriends",
    Callback = function(v)
        Settings.DungeonAutoFriends = v
    end,
})
DungeonSec:Slider({
    Title = "Dungeon Tween Speed",
    Step = 10,
    Value = {Min = 100, Max = 350, Default = 280},
    Flag = "DungeonTweenSpeed",
    Callback = function(v) Settings.DungeonTweenSpeed = v end,
})
DungeonSec:Slider({
    Title = "Dungeon Safe HP (%)",
    Step = 5,
    Value = {Min = 0, Max = 75, Default = 25},
    Flag = "DungeonSafeHP",
    Callback = function(v)
        Settings.DungeonLowHPThreshold = v / 100
        Settings.DungeonRecoveryHPThreshold = math.min(0.95, math.max(0.55, (v / 100) + 0.25))
    end,
})
DungeonStatusParagraph = DungeonSec:Paragraph({
    Title = "Dungeon Status",
    Desc = "Mode: Normal | Style: Hover Above (Tween)\nFriends Co-op: OFF (Solo)\nStatus: Idle",
})
DungeonSec:Button({
    Title = "TP To Raid Entrance",
    Callback = function()
        DisableHoverLock()
        FastTeleport(CFrame.new(-4567, 223, -80), true)
        UI:Notify({Title = "Raid Entrance", Content = "Teleported to Raid Entrance!", Kind = "success", Duration = 2})
    end,
})

local ProgSec = ActTab:Section({Title = "Progression & Events", Side = "Right"})
ProgSec:Toggle({
    Title = "Auto Sea 2 Unlock Quest", Value = false, Flag = "AutoSea2Unlock",
    Callback = function(v) Settings.AutoSea2Unlock = v end,
})
ProgSec:Toggle({
    Title = "Auto Sea 3 Unlock Quest", Value = false, Flag = "AutoSea3Unlock",
    Callback = function(v) Settings.AutoSea3Unlock = v end,
})
ProgSec:Toggle({
    Title = "Auto Haki V2 Quest", Value = false, Flag = "AutoHakiV2",
    Callback = function(v) Settings.AutoHakiV2 = v end,
})
ProgSec:Toggle({
    Title = "Auto Observation V2 Quest", Value = false, Flag = "AutoObserveV2",
    Callback = function(v) Settings.AutoObserveV2 = v end,
})
ProgSec:Toggle({
    Title = "Auto Kill Event Minions", Value = false, Flag = "AutoKillMinion",
    Callback = function(v) Settings.AutoKillMinion = v end,
})
ProgSec:Toggle({
    Title = "Auto Farm Candy", Value = false, Flag = "AutoFarmCandy",
    Callback = function(v) Settings.AutoFarmCandy = v end,
})
ProgSec:Toggle({
    Title = "Auto Summon Jack o Lantern", Value = false, Flag = "AutoSummonJackO",
    Callback = function(v) Settings.AutoSummonJackO = v end,
})
ProgSec:Toggle({
    Title = "Auto Kill Jack o Lantern", Value = false, Flag = "AutoKillJackO",
    Callback = function(v) Settings.AutoKillJackO = v end,
})
ProgSec:Toggle({
    Title = "Auto Kill Skull King", Value = false, Flag = "AutoKillSkullKing",
    Callback = function(v) Settings.AutoKillSkullKing = v end,
})

end

-- ============================================================
-- 5. TAB: skill hold
-- ============================================================
do
local SkillTab = Window:Tab({Title = "skill hold"})

local SkillToggleSec = SkillTab:Section({Title = "Enable / Disable Skills", Side = "Left"})
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

local SkillHoldSec = SkillTab:Section({Title = "Hold Duration (Hold Time)", Side = "Right"})
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

end

-- ============================================================
-- 6, 7, 8. TABS: First Sea, Second sea, Third Sea
-- ============================================================
do
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
        Title = "Select Mob / Quest", Values = seaLabels, Value = seaLabels[1], Flag = "Sea" .. seaNumber .. "Mob",
        Callback = function(v)
            selectedQuest = findQuestByLabel(v)
            if Settings.AutoFarmCustomMob then
                Settings.CustomMob = selectedQuest
            end
        end,
    })
    LeftSec:Toggle({
        Title = "Auto Farm Selected Mob", Value = false, Flag = "FarmCustomSea" .. seaNumber,
        Callback = function(v)
            if v then
                Settings.AutoFarm = false
                Settings.CustomMob = selectedQuest
                Settings.AutoFarmCustomMob = true
                UI:Notify({Title = seaTitle, Content = "Farming: " .. (selectedQuest and selectedQuest.MobName or ""), Kind = "success", Duration = 2})
            else
                Settings.AutoFarmCustomMob = false
                if not Settings.AutoFarm and not Settings.AutoBoss and not _sea2EventActive then DisableHoverLock() end
            end
        end,
    })
    LeftSec:Button({
        Title = "Teleport To This Island",
        Callback = function()
            if selectedQuest then
                DisableHoverLock()
                FastTeleport(selectedQuest.MobArea, true)
                UI:Notify({Title = "Teleport", Content = "Teleported to " .. selectedQuest.MobName .. " area", Kind = "success", Duration = 2})
            end
        end,
    })
    LeftSec:Button({
        Title = "Teleport To Quest NPC",
        Callback = function()
            if selectedQuest then
                DisableHoverLock()
                FastTeleport(selectedQuest.NPCPos, true)
                UI:Notify({Title = "Teleport", Content = "Teleported to " .. selectedQuest.QuestNPC, Kind = "success", Duration = 2})
            end
        end,
    })

    local RightSec = tab:Section({Title = seaTitle .. " Info", Side = "Right"})
    local bossText = "\n--- Bosses ---\n"
    for _, b in ipairs(BossData) do
        if b.Sea == seaNumber then
            bossText = bossText .. string.format("- %s (Lv.%d)\n", b.Name, b.MinLevel)
        end
    end
    RightSec:Paragraph({
        Title = "Quests & Bosses",
        Desc = seaInfoText .. bossText,
    })
end

local Sea1Tab = Window:Tab({Title = "First Sea"})
BuildSeaTab(Sea1Tab, 1, "First Sea (Lv.1-1350)")

local Sea2Tab = Window:Tab({Title = "Second sea"})

-- Left: SK Hydra, Sea Beast & Ghost Ship (Sea 2)
local Sea2EventSec = Sea2Tab:Section({Title = "SK Hydra, Sea Beast & Ghost Ship", Side = "Left"})
Sea2TimerParagraph = Sea2EventSec:Paragraph({
    Title = "SK Hydra, Sea Beast & Ghost Ship Timer",
    Desc = "Loading data...",
})
Sea2EventSec:Toggle({
    Title = "Auto Kill Hydra (SK Hydra)", Value = false, Flag = "AutoKillHydra",
    Callback = function(v)
        Settings.AutoKillHydra = v
        if not v then _lastHydraPos = nil end
        UI:Notify({Title = "SK Hydra", Content = v and "ON - Hunting SK Hydra" or "OFF", Kind = v and "success" or "info", Duration = 2})
    end,
})
Sea2EventSec:Toggle({
    Title = "Auto Kill Sea Beast", Value = false, Flag = "AutoKillSeaBeast",
    Callback = function(v)
        Settings.AutoKillSeaBeast = v
        if not v then _lastSeaBeastPos = nil end
        UI:Notify({Title = "Sea Beast", Content = v and "ON - Hunting Sea Beast" or "OFF", Kind = v and "success" or "info", Duration = 2})
    end,
})
Sea2EventSec:Toggle({
    Title = "Auto Kill Ghost Ship", Value = false, Flag = "AutoKillGhostShip",
    Callback = function(v)
        Settings.AutoKillGhostShip = v
        Settings.AutoGhostShip = v
        if not v then _lastGhostShipPos = nil end
        UI:Notify({Title = "Ghost Ship", Content = v and "ON - Hunting Ghost Ship" or "OFF", Kind = v and "success" or "info", Duration = 2})
    end,
})
Sea2EventSec:Toggle({
    Title = "Auto TP Collect Hydra / Sea Beast Chest", Value = true, Flag = "AutoCollectHydraChest",
    Callback = function(v) Settings.AutoCollectHydraChest = v end,
})
Sea2EventSec:Button({
    Title = "TP To Sea Event Chest Now",
    Callback = function()
        task.spawn(function()
            local ok = CollectSeaEventChest(nil, HumanoidRootPart and HumanoidRootPart.Position, false)
            UI:Notify({
                Title = "Sea Event Chest",
                Content = ok and "Teleported and collected chest successfully!" or "No Hydra / Sea Beast / Ghost Ship chest found on map",
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
        UI:Notify({Title = "Dragon Boss", Content = v and "ON - Hunting Dragon Boss" or "OFF", Kind = v and "success" or "info", Duration = 2})
    end,
})
Sea2DragonSec:Toggle({
    Title = "Auto Spam Dragon (Auto Summon)", Value = false, Flag = "AutoSpawnDragon",
    Callback = function(v)
        Settings.AutoSpawnDragon = v
        UI:Notify({Title = "Spam Dragon", Content = v and "ON - Auto summoning with Orb" or "OFF", Kind = v and "success" or "info", Duration = 2})
    end,
})
Sea2DragonSec:Toggle({
    Title = "Auto Farm Dragon Orb", Value = false, Flag = "AutoFarmDragonOrb",
    Callback = function(v)
        Settings.AutoFarmDragonOrb = v
        UI:Notify({Title = "Dragon Orb", Content = v and "ON - Farming Dragon Orb" or "OFF", Kind = v and "success" or "info", Duration = 2})
    end,
})
Sea2DragonSec:Button({
    Title = "Summon Dragon Now (Once)",
    Callback = function()
        task.spawn(function()
            local orbCount = CountDragonOrbs()
            SpawnDragonWithOrb()
            UI:Notify({
                Title = "Summon Dragon",
                Content = orbCount > 0 and ("Sent summon request (Orbs: " .. orbCount .. ")") or "No Dragon Orb found in bag, trying Shrine anyway",
                Kind = orbCount > 0 and "success" or "info",
                Duration = 2.5,
            })
        end)
    end,
})
Sea2DragonSec:Button({
    Title = "TP To Dragon Island (Dragon Shrine)",
    Callback = function()
        local shrinePart = FindDragonShrinePart()
        DisableHoverLock()
        if shrinePart then
            FastTeleport(shrinePart.CFrame + Vector3.new(0, 5, 0), true)
            UI:Notify({Title = "Dragon Shrine", Content = "Teleported to " .. shrinePart.Name, Kind = "success", Duration = 2})
        else
            FastTeleport(CFrame.new(-5400, 310, -4600), true)
            UI:Notify({Title = "Dragon Shrine", Content = "Teleported to Skull Island / Shrine area", Kind = "info", Duration = 2})
        end
    end,
})

BuildSeaTab(Sea2Tab, 2, "Second Sea (Lv.1350-2700)")

local Sea3Tab = Window:Tab({Title = "Third Sea"})
do
    local Sea3EventSec = Sea3Tab:Section({Title = "Third Sea Events & Bosses", Side = "Left"})
    _hakiState.sea3TimerParagraph = Sea3EventSec:Paragraph({
        Title = "Sea 3 Live Timers",
        Desc = "Sea 3 Timer: Checking...\nAbyssal Tyrant: Checking...\nChaos Kraken: Checking...\nDeepsea Crusher: Checking...\nDrakenfyr: Checking...",
    })
    Sea3EventSec:Toggle({
        Title = "Auto Abyssal Tyrant (SeaDragon)", Value = false, Flag = "AutoAbyssalTyrant",
        Callback = function(v) Settings.AutoAbyssalTyrant = v end,
    })
    Sea3EventSec:Toggle({
        Title = "Auto Chaos Kraken (FuryTentacle)", Value = false, Flag = "AutoChaosKraken",
        Callback = function(v) Settings.AutoChaosKraken = v end,
    })
    Sea3EventSec:Toggle({
        Title = "Auto Deepsea Crusher (Crab)", Value = false, Flag = "AutoDeepseaCrusher",
        Callback = function(v) Settings.AutoDeepseaCrusher = v end,
    })
    Sea3EventSec:Toggle({
        Title = "Auto Drakenfyr (ThirdSeaDragon)", Value = false, Flag = "AutoDrakenfyr",
        Callback = function(v) Settings.AutoDrakenfyr = v end,
    })
end
BuildSeaTab(Sea3Tab, 3, "Third Sea (Lv.2700-5450)")

end

-- ============================================================
-- 9. TAB: all sea
-- ============================================================
do
local AllSeaTab = Window:Tab({Title = "all sea"})

local CollectSec = AllSeaTab:Section({Title = "Auto Collect", Side = "Left"})
CollectSec:Toggle({
    Title = "Auto Collect Chests", Value = false, Flag = "AutoChest",
    Callback = function(v)
        Settings.AutoChest = v
        UI:Notify({Title = "Auto Chest", Content = v and "Searching for chests..." or "Disabled", Kind = v and "success" or "info", Duration = 2})
    end,
})
CollectSec:Toggle({
    Title = "Auto Collect Fruits (Fruit Sniper)", Value = false, Flag = "AutoFruitSniper",
    Callback = function(v)
        Settings.AutoFruitSniper = v
        UI:Notify({Title = "Fruit Sniper", Content = v and "Scanning for fruits..." or "Disabled", Kind = v and "success" or "info", Duration = 2})
    end,
})
CollectSec:Button({
    Title = "TP To Fruit On Map",
    Callback = function()
        local fruits = FindDroppedFruits()
        if #fruits > 0 then
            CollectTargetPart(fruits[1].part)
            UI:Notify({Title = "Fruit Found", Content = "Teleported to: " .. fruits[1].obj.Name, Kind = "success", Duration = 2.5})
        else
            UI:Notify({Title = "Fruit", Content = "No dropped fruits found on map", Kind = "info", Duration = 2})
        end
    end,
})

local UtilSec = AllSeaTab:Section({Title = "General Utilities", Side = "Right"})
UtilSec:Toggle({
    Title = "Auto Observation Haki (Ken)", Value = false, Flag = "AutoKenHaki",
    Callback = function(v) Settings.AutoKenHaki = v end,
})
UtilSec:Toggle({
    Title = "Walk On Water", Value = true, Flag = "WalkOnWater",
    Callback = function(v) Settings.WalkOnWater = v end,
})
UtilSec:Toggle({
    Title = "Background M1 ReAttack", Value = false, Flag = "AllSeaReAttack",
    Callback = function(v) Settings.ReAttack = v end,
})
UtilSec:Toggle({
    Title = "Bring All Workspace Fruits", Value = false, Flag = "BringAllFruits",
    Callback = function(v) Settings.BringAllFruits = v end,
})
UtilSec:Toggle({
    Title = "Auto Store Fruit", Value = false, Flag = "AutoStoreFruit",
    Callback = function(v) Settings.AutoStoreFruit = v end,
})
UtilSec:Toggle({
    Title = "Infinite Geppo (Air Jump)", Value = false, Flag = "InfGeppo",
    Callback = function(v) Settings.InfGeppo = v end,
})

local EspSec = AllSeaTab:Section({Title = "ESP", Side = "Left"})
EspSec:Toggle({
    Title = "ESP Players", Value = false, Flag = "ESPPlayer",
    Callback = function(v) Settings.ESPPlayer = v end,
})
EspSec:Toggle({
    Title = "ESP Devil Fruits", Value = false, Flag = "ESPFruit",
    Callback = function(v) Settings.ESPFruit = v end,
})
EspSec:Toggle({
    Title = "ESP Legacy Island", Value = false, Flag = "ESPLegacyIsland",
    Callback = function(v) Settings.ESPLegacyIsland = v end,
})
EspSec:Toggle({
    Title = "ESP Hydra Island", Value = false, Flag = "ESPHydraIsland",
    Callback = function(v) Settings.ESPHydraIsland = v end,
})
EspSec:Toggle({
    Title = "ESP Ghost Ship", Value = false, Flag = "ESPGhostShip",
    Callback = function(v) Settings.ESPGhostShip = v end,
})

end

-- ============================================================
-- 10. TAB: Travel
-- ============================================================
do
local TravelTab = Window:Tab({Title = "Travel"})

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

local IslandTPSec = TravelTab:Section({Title = "Island Teleport By Sea", Side = "Left"})
IslandTPSec:Dropdown({
    Title = "Sea 1 Islands", Values = s1Names, Value = s1Names[1], Flag = "IslandSea1",
    Callback = function(v) selS1 = v end,
})
IslandTPSec:Button({
    Title = "Teleport Sea 1 Island",
    Callback = function()
        if s1Map[selS1] then DisableHoverLock(); FastTeleport(s1Map[selS1], true) end
    end,
})
IslandTPSec:Dropdown({
    Title = "Sea 2 Islands", Values = s2Names, Value = s2Names[1], Flag = "IslandSea2",
    Callback = function(v) selS2 = v end,
})
IslandTPSec:Button({
    Title = "Teleport Sea 2 Island",
    Callback = function()
        if s2Map[selS2] then DisableHoverLock(); FastTeleport(s2Map[selS2], true) end
    end,
})
IslandTPSec:Dropdown({
    Title = "Sea 3 Islands", Values = s3Names, Value = s3Names[1], Flag = "IslandSea3",
    Callback = function(v) selS3 = v end,
})
IslandTPSec:Button({
    Title = "Teleport Sea 3 Island",
    Callback = function()
        if s3Map[selS3] then DisableHoverLock(); FastTeleport(s3Map[selS3], true) end
    end,
})

local SeaTravelSec = TravelTab:Section({Title = "Sea Travel", Side = "Right"})
SeaTravelSec:Button({
    Title = "Teleport First Sea",
    Callback = function()
        TravelToSea(1)
        UI:Notify({Title = "Travel", Content = "Traveling to First Sea...", Kind = "info", Duration = 2})
    end,
})
SeaTravelSec:Button({
    Title = "Teleport Second Sea",
    Callback = function()
        TravelToSea(2)
        UI:Notify({Title = "Travel", Content = "Traveling to Second Sea...", Kind = "info", Duration = 2})
    end,
})
SeaTravelSec:Button({
    Title = "Teleport Third Sea",
    Callback = function()
        TravelToSea(3)
        UI:Notify({Title = "Travel", Content = "Traveling to Third Sea...", Kind = "info", Duration = 2})
    end,
})
SeaTravelSec:Paragraph({
    Title = "Sea Travel Notes",
    Desc = "First Sea: Lv.1+\nSecond Sea: Requires Lv.2250+\nThird Sea: Requires Lv.3500+\nYou must complete the corresponding Sea unlock quest.",
})

do
    local function getLiveAreas()
        local list = {}
        local areas = Workspace:FindFirstChild("Areas")
        if areas then
            for _, a in ipairs(areas:GetChildren()) do
                table.insert(list, a.Name)
            end
        end
        table.sort(list)
        if #list == 0 then return {"None"} end
        return list
    end
    local function getLiveNPCs()
        local list = {}
        local allNpc = Workspace:FindFirstChild("AllNPC")
        if allNpc then
            for _, n in ipairs(allNpc:GetChildren()) do
                table.insert(list, n.Name)
            end
        end
        table.sort(list)
        if #list == 0 then return {"None"} end
        return list
    end

    local areaList = getLiveAreas()
    local npcList = getLiveNPCs()
    local selArea, selNPC = areaList[1], npcList[1]

    local LiveNavSec = TravelTab:Section({Title = "Live Areas & NPCs (Current Sea)", Side = "Right"})
    local AreaDropdown = LiveNavSec:Dropdown({
        Title = "Select Workspace Area", Values = areaList, Value = areaList[1], Flag = "LiveAreaSelect",
        Callback = function(v) selArea = v end,
    })
    LiveNavSec:Button({
        Title = "Refresh Areas",
        Callback = function()
            local l = getLiveAreas()
            selArea = l[1]
            pcall(function()
                if AreaDropdown.Refresh then AreaDropdown:Refresh(l)
                elseif AreaDropdown.SetValues then AreaDropdown:SetValues(l) end
            end)
        end,
    })
    LiveNavSec:Button({
        Title = "TP To Selected Area",
        Callback = function()
            local areas = Workspace:FindFirstChild("Areas")
            local target = areas and areas:FindFirstChild(selArea)
            if target then
                local cf = target:IsA("BasePart") and target.CFrame or (target:IsA("Model") and target:GetPivot())
                if cf then
                    DisableHoverLock()
                    FastTeleport(cf + Vector3.new(0, 15, 0), true)
                    UI:Notify({Title = "Area Teleport", Content = "Teleported to " .. selArea, Kind = "success", Duration = 2})
                    return
                end
            end
            UI:Notify({Title = "Area Teleport", Content = "Area not found in current sea", Kind = "info", Duration = 2})
        end,
    })

    local NPCDropdown = LiveNavSec:Dropdown({
        Title = "Select Workspace NPC", Values = npcList, Value = npcList[1], Flag = "LiveNPCSelect",
        Callback = function(v) selNPC = v end,
    })
    LiveNavSec:Button({
        Title = "Refresh NPCs",
        Callback = function()
            local l = getLiveNPCs()
            selNPC = l[1]
            pcall(function()
                if NPCDropdown.Refresh then NPCDropdown:Refresh(l)
                elseif NPCDropdown.SetValues then NPCDropdown:SetValues(l) end
            end)
        end,
    })
    LiveNavSec:Button({
        Title = "TP To Selected NPC",
        Callback = function()
            local allNpc = Workspace:FindFirstChild("AllNPC")
            local target = allNpc and allNpc:FindFirstChild(selNPC)
            if target then
                local r = target:IsA("BasePart") and target or (target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart or target:FindFirstChildOfClass("BasePart"))
                if r then
                    DisableHoverLock()
                    FastTeleport(r.CFrame + Vector3.new(0, 3, 2), true)
                    UI:Notify({Title = "NPC Teleport", Content = "Teleported to " .. selNPC, Kind = "success", Duration = 2})
                    return
                end
            end
            UI:Notify({Title = "NPC Teleport", Content = "NPC not found in current sea", Kind = "info", Duration = 2})
        end,
    })
end

end

-- ============================================================
-- 11. TAB: shop
-- ============================================================
do
local ShopTab = Window:Tab({Title = "shop"})

local StyleList = {"Black Leg", "Electro", "Fishman Karate", "Dragon Claw", "Superhuman", "Death Step", "Sharkman Karate", "Electric Claw"}
local SkillShopList = {"Buso Haki", "Ken Haki", "Geppo", "Soru"}
local selStyle, selSkillShop = StyleList[1], SkillShopList[1]

local ShopLeftSec = ShopTab:Section({Title = "Styles, Swords & Haki", Side = "Left"})
ShopLeftSec:Dropdown({
    Title = "Fighting Styles", Values = StyleList, Value = StyleList[1], Flag = "ShopStyle",
    Callback = function(v) selStyle = v end,
})
ShopLeftSec:Button({
    Title = "Buy / Learn Style",
    Callback = function()
        local ok = BuyFromShop(selStyle)
        UI:Notify({Title = "Shop", Content = ok and ("Sent purchase request: " .. selStyle) or "Shop remote not found", Kind = ok and "success" or "error", Duration = 2})
    end,
})
ShopLeftSec:Dropdown({
    Title = "Haki / Skills", Values = SkillShopList, Value = SkillShopList[1], Flag = "ShopSkill",
    Callback = function(v) selSkillShop = v end,
})
ShopLeftSec:Button({
    Title = "Buy Skill",
    Callback = function()
        local ok = BuyFromShop(selSkillShop)
        UI:Notify({Title = "Shop", Content = ok and ("Sent purchase request: " .. selSkillShop) or "Shop remote not found", Kind = ok and "success" or "error", Duration = 2})
    end,
})

local ShopRightSec = ShopTab:Section({Title = "Fruit Shop / Gacha", Side = "Right"})
ShopRightSec:Button({
    Title = "Random Fruit (Gacha)",
    Callback = function()
        local ok = BuyFromShop("RandomFruit")
        UI:Notify({Title = "Gacha Fruit", Content = ok and "Rolled Random Fruit!" or "Gacha remote not found", Kind = ok and "success" or "info", Duration = 2})
    end,
})
ShopRightSec:Toggle({
    Title = "Auto Random Fruit", Value = false, Flag = "AutoRandomFruit",
    Callback = function(v) Settings.AutoRandomFruit = v end,
})
ShopRightSec:Button({
    Title = "TP To Fruit Dealer",
    Callback = function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name:lower():find("fruit") and (obj.Name:lower():find("dealer") or obj.Name:lower():find("shop") or obj.Name:lower():find("gacha")) then
                local root = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
                if root then
                    DisableHoverLock()
                    FastTeleport(root.CFrame, true)
                    UI:Notify({Title = "Fruit Dealer", Content = "Teleported to " .. obj.Name, Kind = "success", Duration = 2})
                    return
                end
            end
        end
        UI:Notify({Title = "Fruit Dealer", Content = "No nearby NPC found", Kind = "info", Duration = 2})
    end,
})

do
    local function getFuncs()
        local c = ReplicatedStorage:FindFirstChild("Chest")
        local r = c and c:FindFirstChild("Remotes")
        return r and r:FindFirstChild("Functions")
    end

    local keyList = {"Copper Key", "Iron Key", "Gold Key"}
    local KeySec = ShopTab:Section({Title = "Keys & Fruit Stock", Side = "Left"})
    KeySec:Dropdown({
        Title = "Select Key", Values = keyList, Value = "Copper Key", Flag = "SelectedKey",
        Callback = function(v) Settings.SelectedKey = v end,
    })
    KeySec:Button({
        Title = "Buy Selected Key (1x)",
        Callback = function()
            local funcs = getFuncs()
            local rem = funcs and funcs:FindFirstChild("BuyKey")
            local ok = rem and rem:IsA("RemoteFunction") and pcall(function() rem:InvokeServer(Settings.SelectedKey, 1) end)
            UI:Notify({Title = "Buy Key", Content = ok and ("Requested: " .. Settings.SelectedKey) or "BuyKey remote not found", Kind = ok and "success" or "info", Duration = 2})
        end,
    })
    KeySec:Button({
        Title = "Open Selected Key (1x)",
        Callback = function()
            local funcs = getFuncs()
            local rem = funcs and funcs:FindFirstChild("UseKey")
            local ok = rem and rem:IsA("RemoteFunction") and pcall(function() rem:InvokeServer(Settings.SelectedKey, "Open1") end)
            UI:Notify({Title = "Open Key", Content = ok and ("Opened: " .. Settings.SelectedKey) or "UseKey remote not found", Kind = ok and "success" or "info", Duration = 2})
        end,
    })
    KeySec:Toggle({
        Title = "Auto Buy Key", Value = false, Flag = "AutoBuyKey",
        Callback = function(v) Settings.AutoBuyKey = v end,
    })
    KeySec:Toggle({
        Title = "Auto Open Key", Value = false, Flag = "AutoOpenKey",
        Callback = function(v) Settings.AutoOpenKey = v end,
    })

    local fruitStockList = {
        "SpinFruit", "ClearFruit", "BombFruit", "SpikeFruit",
        "BarrierFruit", "GumFruit", "SmokeFruit", "FlameFruit",
        "SandFruit", "IceFruit", "DarkFruit", "QuakeFruit",
        "LightFruit", "MagmaFruit", "RumbleFruit", "GravityFruit",
        "PawFruit", "ShadowFruit", "VenomFruit", "ControlFruit",
        "SpiritFruit", "SnowFruit", "BuddhaFruit", "MagnetFruit",
        "StringFruit", "GasFruit", "DragonFruit", "OpFruit",
    }
    KeySec:Dropdown({
        Title = "Select Stock Fruit", Values = fruitStockList, Value = "DragonFruit", Flag = "SelectedStockFruit",
        Callback = function(v) Settings.SelectedStockFruit = v end,
    })
    KeySec:Button({
        Title = "Buy Stock Fruit Now",
        Callback = function()
            local funcs = getFuncs()
            local rem = funcs and funcs:FindFirstChild("BuyFruitStock")
            local ok = rem and rem:IsA("RemoteFunction") and pcall(function() rem:InvokeServer(Settings.SelectedStockFruit, true) end)
            UI:Notify({Title = "Fruit Stock", Content = ok and ("Requested: " .. Settings.SelectedStockFruit) or "BuyFruitStock remote not found", Kind = ok and "success" or "info", Duration = 2})
        end,
    })
    KeySec:Toggle({
        Title = "Auto Buy Selected Stock Fruit", Value = false, Flag = "AutoBuyStockFruit",
        Callback = function(v) Settings.AutoBuyStockFruit = v end,
    })

    local shopNpcMap = {
        ["Soru"] = {"soru"},
        ["Buso Haki"] = {"buso", "armament"},
        ["Ken Haki"] = {"ken", "observ"},
        ["Katana"] = {"katana"},
        ["Pipe Sword"] = {"pipe"},
        ["Mini Race"] = {"mini"},
        ["Water Style"] = {"water"},
        ["Dragon Claw"] = {"dragon claw", "dragon"},
        ["Sky Jump"] = {"sky", "geppo"},
        ["Reroll Race"] = {"race", "reroll"},
        ["Reset Stat"] = {"stat", "reset"},
        ["Black Leg"] = {"black leg", "sanji"},
        ["Cyborg"] = {"cyborg"},
    }
    local shopNames = {
        "Soru", "Buso Haki", "Ken Haki", "Katana", "Pipe Sword",
        "Mini Race", "Water Style", "Dragon Claw", "Sky Jump",
        "Reroll Race", "Reset Stat", "Black Leg", "Cyborg",
    }
    local selShopNpc = shopNames[1]
    local ShopTpSec = ShopTab:Section({Title = "Ability & Style Shop Teleports", Side = "Right"})
    ShopTpSec:Dropdown({
        Title = "Select Shop NPC", Values = shopNames, Value = shopNames[1], Flag = "SelectedShopNPC",
        Callback = function(v) selShopNpc = v end,
    })
    ShopTpSec:Button({
        Title = "TP To Selected Shop NPC",
        Callback = function()
            local keywords = shopNpcMap[selShopNpc] or {selShopNpc:lower()}
            for _, folderName in ipairs({"AllNPC", "NPCs", "NPC"}) do
                local folder = Workspace:FindFirstChild(folderName)
                if folder then
                    for _, npc in ipairs(folder:GetChildren()) do
                        local lname = npc.Name:lower()
                        for _, kw in ipairs(keywords) do
                            if lname:find(kw, 1, true) then
                                local r = npc:IsA("BasePart") and npc or (npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart or npc:FindFirstChildOfClass("BasePart"))
                                if r then
                                    DisableHoverLock()
                                    FastTeleport(r.CFrame + Vector3.new(0, 3, 2), true)
                                    UI:Notify({Title = "Shop Teleport", Content = "Teleported to " .. npc.Name, Kind = "success", Duration = 2})
                                    return
                                end
                            end
                        end
                    end
                end
            end
            UI:Notify({Title = "Shop Teleport", Content = selShopNpc .. " NPC not found in current sea", Kind = "info", Duration = 2})
        end,
    })
end

end

-- ============================================================
-- 12. TAB: PvP
-- ============================================================
do
local PvPTab = Window:Tab({Title = "PvP"})

local PvPTargetSec = PvPTab:Section({Title = "Target Player", Side = "Left"})
local initialPlayers = GetPlayerNames()
Settings.TargetPlayerName = initialPlayers[1]
local PlayerDropdown = PvPTargetSec:Dropdown({
    Title = "Select Player", Values = initialPlayers, Value = initialPlayers[1], Flag = "TargetPlayer",
    Callback = function(v)
        Settings.TargetPlayerName = v
        if Settings.SpectatePlayer then SpectateTarget(true) end
    end,
})
PvPTargetSec:Button({
    Title = "Refresh Player List",
    Callback = function()
        local pList = GetPlayerNames()
        pcall(function()
            if PlayerDropdown.Refresh then PlayerDropdown:Refresh(pList)
            elseif PlayerDropdown.SetValues then PlayerDropdown:SetValues(pList) end
        end)
        UI:Notify({Title = "Players", Content = #pList .. " player(s) in server", Kind = "info", Duration = 2})
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
    Title = "Teleport To Player",
    Callback = function()
        local target = FindTargetPlayer()
        local tRoot = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if tRoot then
            DisableHoverLock()
            FastTeleport(tRoot.CFrame * CFrame.new(0, 3, -5), true)
            UI:Notify({Title = "PvP TP", Content = "Teleported to " .. target.Name, Kind = "success", Duration = 2})
        else
            UI:Notify({Title = "PvP TP", Content = "Target character not found", Kind = "error", Duration = 2})
        end
    end,
})

local PvPSupportSec = PvPTab:Section({Title = "PvP Support", Side = "Right"})
PvPSupportSec:Toggle({
    Title = "Lock Look At Player", Value = false, Flag = "LockLookAtPlayer",
    Callback = function(v) Settings.LockLookAtPlayer = v end,
})
PvPSupportSec:Toggle({
    Title = "Auto Escape At Low HP", Value = false, Flag = "SafeEscapePvP",
    Callback = function(v) Settings.SafeEscapePvP = v end,
})
PvPSupportSec:Slider({
    Title = "Escape HP Threshold (%)", Step = 5, Value = {Min = 5, Max = 60, Default = 20}, Flag = "SafeEscapeHP",
    Callback = function(v) Settings.SafeEscapeHP = v end,
})

end

-- ============================================================
-- 13. TAB: Setting
-- ============================================================
do
Window:Divider()

local SettingsTab = Window:Tab({Title = "Setting"})

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
    Title = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
    end,
})
UISec:Button({
    Title = "Server Hop",
    Callback = function()
        ServerHop()
    end,
})

local CfgSec = SettingsTab:Section({Title = "Config", Side = "Right"})
CfgSec:Button({
    Title = "Save Config",
    Callback = function()
        UI:Notify({Title = "Config", Content = Window:SaveConfig("KingLegacy") and "Config saved!" or "Executor not supported", Kind = "success", Duration = 2})
    end,
})
CfgSec:Button({
    Title = "Load Config",
    Callback = function()
        UI:Notify({Title = "Config", Content = Window:LoadConfig("KingLegacy") and "Config loaded!" or "No saved config found", Kind = "info", Duration = 2})
    end,
})
CfgSec:Button({
    Title = "Destroy UI",
    Callback = function()
        _running = false
        Settings.AutoDungeon = false
        Settings.WhiteScreen = false
        pcall(function() RunService:Set3dRenderingEnabled(true) end)
        if typeof(getgenv) == "function" then
            pcall(function() getgenv().PosMonSkill = nil end)
        end
        if Settings.CleanupDungeon then Settings.CleanupDungeon() end
        DisableHoverLock()
        SpectateTarget(false)
        if _waterPlatform and _waterPlatform.Parent then _waterPlatform:Destroy() end
        Window:Destroy()
    end,
})

local FpsSec = SettingsTab:Section({Title = "FPS Boost & Anti-Lag", Side = "Left"})
FpsSec:Toggle({
    Title = "White Screen (Disable 3D Render)", Value = false, Flag = "WhiteScreen",
    Callback = function(v) Settings.WhiteScreen = v end,
})
FpsSec:Toggle({
    Title = "Hide LevelUp / ItemDrop UI", Value = false, Flag = "HideLevelUpUI",
    Callback = function(v) Settings.HideLevelUpUI = v end,
})
FpsSec:Toggle({
    Title = "Hide Mob Health Bars", Value = false, Flag = "HideMobHealth",
    Callback = function(v) Settings.HideMobHealth = v end,
})
FpsSec:Toggle({
    Title = "Delete Damage Text", Value = false, Flag = "DeleteDamageText",
    Callback = function(v) Settings.DeleteDamageText = v end,
})
FpsSec:Toggle({
    Title = "Hide Heavy Effects", Value = false, Flag = "DeleteHeavyEffects",
    Callback = function(v) Settings.DeleteHeavyEffects = v end,
})
end

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
                "Sea: %s | Level: %d / 5450\nQuest: %s\nTarget: %s\nHP: %d%% | Haki: %s\nBring: %d mobs | Hover: %s\nStatus: %s",
                sea, level, questName, mobName, hp, hakiState, _bringCount, Settings.HoverFarm and ("ON (" .. Settings.HoverHeight .. ")") or "OFF", _farmStatus
            ))

            ReStatusParagraph:SetDesc(string.format(
                "Status: %s\nM1 Count: %d\nMethod: %s",
                _reattackStatus, _m1Count, Settings.M1Method
            ))

            Sea2TimerParagraph:SetDesc(GetSea2LiveStatusText())
            if _hakiState.sea3TimerParagraph and _hakiState.getSea3LiveStatusText then
                _hakiState.sea3TimerParagraph:SetDesc(_hakiState.getSea3LiveStatusText())
            end

            if DungeonStatusParagraph then
                local friendSummary = (_hakiState.getDungeonFriendSummary and _hakiState.getDungeonFriendSummary()) or (Settings.DungeonPartnerMode and "ON" or "OFF (Solo)")
                DungeonStatusParagraph:SetDesc(string.format(
                    "Mode: %s | Style: %s\nFriends Co-op: %s\nStatus: %s",
                    Settings.DungeonMode or Settings.DungeonDifficulty or "Normal",
                    Settings.DungeonPlayMode or "Hover Above (Tween)",
                    friendSummary,
                    Settings.DungeonStatus or "Idle"
                ))
            end

            local matEntry = GetMaterialEntry(Settings.SelectedMaterial)
            if matEntry then
                local matCount = GetMaterialCount(matEntry.Name)
                MaterialStatusParagraph:SetDesc(string.format(
                    "Material: %s (Sea %d)\nMob: %s\nIn Bag: %d\nStatus: %s",
                    matEntry.Name, matEntry.Sea, table.concat(matEntry.Mobs, ", "), matCount, Settings.AutoFarmMaterial and "Farming" or "Off"
                ))
            end

            local svTime = FormatTimeMMSS(Workspace.DistributedGameTime or 0)
            local gameSessionTime = FormatTimeMMSS(tick() - _scriptStartTime)
            local lighting = game:GetService("Lighting")
            local clockTime = lighting and lighting.ClockTime or 12
            local dayNight = (clockTime >= 6 and clockTime < 18) and "Day" or "Night"
            local inGameTimeStr = (lighting and lighting.TimeOfDay and lighting.TimeOfDay:sub(1, 5) or "12:00") .. " (" .. dayNight .. ")"
            local realTimeStr = os.date("%H:%M:%S")
            local pCount = #Players:GetPlayers() .. "/" .. Players.MaxPlayers

            HomeTimeParagraph:SetDesc(string.format(
                "Server Time: %s\nGame Time (Session): %s\nIn-Game Time: %s\nReal Time: %s\nServer Players: %s",
                svTime, gameSessionTime, inGameTimeStr, realTimeStr, pCount
            ))

            HomeStatsParagraph:SetDesc(string.format(
                "Player: %s\nLevel: %s / 5450\nBeli: %s\nGems: %s\nBounty: %s\nFruit: %s\nHP: %d%%",
                Player.Name, FormatNumber(level), FormatNumber(GetBeli()), FormatNumber(GetGems()), FormatNumber(GetBounty()), GetEquippedFruitName(), hp
            ))
        end)
        wait(1)
    end
end)

-- ============================================================
-- START
-- ============================================================
Window:SelectTab(2) -- Open "Farm" tab by default
loading:Success("Loaded", "King Legacy Hub 13 Tabs loaded!")
Window:SetVisible(true, nil, true)

AntiAFK()
spawn(FarmQuest)
spawn(FarmBoss)

print("╔═══════════════════════════════════════════╗")
print("║  King Legacy Hub - 13 Tabs                ║")
print("║  Lv.1-5450 | Hover | Bring | ReAttack     ║")
print("║  Press RightCtrl to toggle UI              ║")
print("╚═══════════════════════════════════════════╝")

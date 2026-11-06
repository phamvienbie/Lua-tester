do
    local ALLOWED_PLACES = {
        [13379208636] = true,
        [14916516914] = true,
        [13379349730] = true,
        [14012874501] = true,
        [13904207646] = true,
        [14638336319] = true,
        [15220308770] = true,
        [17688739434] = true,
        [15824912319] = true,
        [126678335159530] = true,
    }
    local allowed = ALLOWED_PLACES[game.PlaceId] == true
    if not allowed then
        pcall(function()
            if not game:IsLoaded() then game.Loaded:Wait() end
            local assets = game:GetService("ReplicatedStorage"):WaitForChild("Assets", 5)
            local remotes = assets and assets:WaitForChild("Remotes", 5)
            allowed = remotes ~= nil and remotes:FindFirstChild("GET") ~= nil and remotes:FindFirstChild("POST") ~= nil
        end)
    end
    if not allowed then
        pcall(function()
            game:GetService("Players").LocalPlayer:Kick("This script works only in Attack on Titan Revolution. / สคริปต์นี้ใช้ได้เฉพาะเกม Attack on Titan Revolution")
        end)
        return
    end
end
local MENU_PLACE_ID = 13379208636
local MIN_DELAY, MAX_DELAY = 5, 60
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local IN_MENU = (game.PlaceId == MENU_PLACE_ID)
local SH = { DEV = false }
function SH.say(...) print("[Smooth Hub]", ...) end
function SH.dbg(...) if SH.DEV then print(...) end end
-- 🛡️ กันบล็อกสร้างหน้าจอ/ฟีเจอร์ที่พัง ไม่ให้ลากทั้งสคริปต์ล้ม (เดิม error บล็อกเดียว = แท็บที่เหลือว่างเปล่า)
-- บล็อกที่พังจะพิมพ์ error ลง Console (F9) พร้อมเลขบรรทัดเดิม ส่วนบล็อกอื่นยังทำงานต่อ
function SH.Guard(name, fn)
    local ok, err = xpcall(fn, function(e) return tostring(e) .. "\n" .. debug.traceback() end)
    if not ok then warn("[Smooth Hub] block " .. tostring(name) .. " failed to load: " .. tostring(err)) end
end
SH.say("Loading Smooth Hub | Attack on Titan Revolution (" .. (IN_MENU and "Lobby" or "In-game") .. ") ...")
if type(_G.SmoothHubCleanup) == "function" then pcall(_G.SmoothHubCleanup) end
local token = {}
_G.SmoothHubReplayToken = token
local function Alive() return _G.SmoothHubReplayToken == token end
local AppRef = nil
_G.SmoothHubCleanup = function()
    pcall(function() if AppRef and AppRef.Destroy then AppRef:Destroy() end end)
end
local Cfg = {
    Slot = 1,
    AutoSelect = false,
    AutoJoin = false,
    JoinDelay = 10,
    AutoClaimMain = true,
    AutoClaimSide = true,
    AutoClaimAchievements = true,
    AutoClaimWeekly = true,
    AutoClaimDaily = true,
    AutoOpenPages = true,
    AutoQuestThunder = false,
    AutoQuestThunderR1 = false,
    AutoQuestThunderR2 = false,
    AutoQuestThunderR3 = false,
    QuestR3Played = 0,
    AutoUpgradeBlade = false,
    AutoUpgradeThunder = false,
    AutoEquipThunder = false,
    AutoEquipBlade = false,
    UseThunderSpears = false,
    MissionSelect = "Shiganshina",
    MissionObjective = "Skirmish",
    MissionDifficulty = {},
    MissionModifiers = {},
    AutoBestGrade = false,
    AutoBoostMission = false,
    AutoCreateMission = false,
    AutoStartMission = false,
    MissionLevel = "Easy (E- Grade)",
    MissionJoinDelay = 10,
    RaidSelect = "Attack Titan",
    RaidModifiers = {},
    RaidLevel = "Hard",
    AutoCreateRaid = false,
    AutoStartRaid = false,
    RaidJoinDelay = 10,
    WaveSelect = "Trost",
    WaveLevel = "Easy (E- Grade)",
    AutoCreateWave = false,
    AutoStartWave = false,
    WaveJoinDelay = 10,
    AutoRefillWave = false,
    AutoRollBlessing = false,
    RollStopOnMatch = true,
    AutoHealInjuries = false,
    AutoUpgradeChar = false,
    AutoUpgradeBlades = false,
    UpgMaxHP = true,
    UpgRegen = true,
    UpgReplenish = false,
    UpgRefills = false,
    UpgRevive = false,
    AutoLootCrate = false,
    AutoShop = false,
    ShopPerk = true,
    ShopArtifact = false,
    ShopMemory = false,
    ShopCrates = false,
    ShopStar1 = true, ShopStar2 = true, ShopStar3 = true, ShopStar4 = true, ShopStar5 = true,
    ShopPerkStar1 = true, ShopPerkStar2 = true, ShopPerkStar3 = true, ShopPerkStar4 = true, ShopPerkStar5 = true,
    ShopArtifactStar1 = true, ShopArtifactStar2 = true, ShopArtifactStar3 = true, ShopArtifactStar4 = true, ShopArtifactStar5 = true,
    ShopMemoryStar1 = true, ShopMemoryStar2 = true, ShopMemoryStar3 = true, ShopMemoryStar4 = true, ShopMemoryStar5 = true,
    ShopPriority = "Highest star first",
    ShopMaxPrice = 0,
    ShopReserve = 0,
    WaveMinGold = 0,
    AutoSpin = false,
    SpinStopRarity = "Epic",
    SpinShowList = false,
    SpinListSize = 15,
    SpinUseDelay = true,
    SpinDelay = 3,
    SpinOnKeep = "Stop",
    SpinFamilyRules = "",
    AutoFarm = false,
    AutoPlay = false,
    AutoClearWave = false,
    ClearWaveRange = 300,
    AutoFarmThunder = false,
    ThunderTargets = 200,   -- Thunder Spears: ไททันต่อการยิงหนึ่งชุด (0 หรือ 200 = ทุกตัว)
    ThunderRange = 10000,   -- Thunder Spears: ยิงเฉพาะไททันที่อยู่ในระยะนี้จากตัวคุณ (สตัด)
    AutoFarmSmart = false,
    FarmMode = "Smart",
    RefillEnabled = false,
    RefillPickBlade = true,
    RefillPickThunder = true,
    SafeFarm = false,
    AutoReload = false,
    AutoRefillsBlade = false,
    AutoRefillsThunder = false,
    DamageMultiplier = false,
    SafeTime = 32,
    FailSafeAt = 20,
    AutoFailSafe = false,
    Streak = 0,
    NoClip = true,
    HitAllParts = true,
    FlySpeed = 600,
    StartDelay = 4,
    PartCooldown = 7,
    FlyHeight = 230,
    WaitForBoss = false,
    BossSettle = 5,
    AttackSpeed = 0,
    AutoOpenChestFree = false,
    AutoCannon = false,
    CannonFarmSmall = false,
    AutoDefendEren = false,
    DefendErenRadius = 400,
    AutoFinishChest = false,
    AutoOpenChestPremium = false,
    AutoSkipCutscene = false,
    AutoRetry = false,
    AutoLeave = false,
    AutoReady = false,
    AutoVoteSkip = false,
    AutoLeaveAtWave = false,
    LeaveAtWave = 10,
    AutoSkill1 = false, AutoSkill2 = false, AutoSkill3 = false, AutoSkill4 = false, AutoSkill5 = false,
    AutoSkillMode1 = "Instant", AutoSkillMode2 = "Instant", AutoSkillMode3 = "Instant", AutoSkillMode4 = "Instant", AutoSkillMode5 = "Instant",
    AutoSkillHoldTime = 3,
    AutoSkillDelay = 2,
    RetryAmount = 3,
    RetryDone = 0,
    AutoLeaveWhenRetryComplete = false,
    AutoUpgradeSkills = false,
    SkillLeft = false,
    SkillMiddle = false,
    SkillRight = false,
    SkillLeftPick = "Regen VI",
    SkillMiddlePick = "Damage V",
    SkillRightPick = "Tank VIII",
    SkillLeftPriority = 1,
    SkillMiddlePriority = 2,
    SkillRightPriority = 1,
    AutoCraftPerks = false,
    CraftCommonRare = false,
    CraftRareEpic = false,
    CraftEpicLegendary = false,
    CraftLegendaryMythic = false,
    CraftChanceCommonRare = 100,
    CraftChanceRareEpic = 100,
    CraftChanceEpicLegendary = 100,
    CraftChanceLegendaryMythic = 100,
    AutoPrestige = false,
    PrestigeBoost1 = "Luck",
    PrestigeBoost2 = "Luck",
    PrestigeBoost3 = "Luck",
    PrestigeBoost4 = "Luck",
    PrestigeBoost5 = "Luck",
    PrestigeStopAt = 3,
}
-- ▶️ Auto Play = สวิตช์หลัก: ฟีเจอร์ในโหมด Wave จะทำงานก็ต่อเมื่อ Auto Play เปิดอยู่เท่านั้น
function SH.PlayOn() return Cfg.AutoPlay == true end
-- 🧠 SMART COORDINATOR: เปิดหลายฟังก์ชันพร้อมกันได้โดยไม่ชนกัน
-- งานสำคัญ (เช่น Auto Prestige) ประกาศตัวเองว่า "มีงานค้าง / กำลังทำ"
-- ตัวที่ "พาตัวละครออกไปที่อื่น" (Auto Join Lobby / Create / Start ห้อง / Quest Round) จะรอจนงานนั้นเสร็จก่อน
-- ถ้างานค้างนานเกิน giveUp วินาที จะปล่อยให้ตัวอื่นไปต่อ (กันค้างตลอดชีพตอน AFK) ส่วนงานที่กำลังทำอยู่จะไม่ถูกขัดจังหวะ
-- prio: เลขน้อย = สำคัญกว่า (Prestige = 10, ตัวออกเดินทาง = 100)
SH.Coord = { jobs = {}, last = nil }
function SH.Coord.Register(name, prio, pending, busy, giveUp)
    SH.Coord.jobs[name] = { prio = prio, pending = pending, busy = busy, giveUp = giveUp or 240, since = nil, seen = nil, warned = false }
end
function SH.Coord.Blocker(askerPrio)
    local now = os.clock()
    local found = nil
    for name, j in pairs(SH.Coord.jobs) do
        local okB, isBusy = pcall(j.busy)
        local okP, isPending = pcall(j.pending)
        isBusy = okB and isBusy == true
        isPending = okP and isPending == true
        if isBusy or isPending then
            j.since = j.since or now
            if j.seen and now - j.seen > 5 then j.since = now end
            j.seen = now
            if (not isBusy) and now - j.since > j.giveUp then
                if not j.warned then
                    j.warned = true
                    SH.say(name .. " is taking too long - continuing with the other features")
                end
            elseif j.prio < askerPrio and not found then
                found = name
            end
        else
            j.since, j.seen, j.warned = nil, nil, false
        end
    end
    SH.Coord.last = found
    return found
end
local FARM_RANGES = {
    SafeTime = { 0, 300 },
    FailSafeAt = { 0, 100 },
    FlySpeed = { 600, 2000 },
    StartDelay = { 0, 60 },
    PartCooldown = { 4, 10 },
    FlyHeight = { 150, 500 },
    BossSettle = { 0, 30 },
    LeaveAtWave = { 1, 50 },
    ShopMaxPrice = { 0, 1000000 },
    ShopReserve = { 0, 1000000 },
    ClearWaveRange = { 50, 2000 },
    WaveMinGold = { 0, 10000000 },
    AutoSkillHoldTime = { 1, 10 },
    AutoSkillDelay = { 1, 30 },
    AttackSpeed = { 0, 5 },
    RetryAmount = { 1, 50 },
    SpinListSize = { 5, 100 },
    DefendErenRadius = { 50, 2000 },
    ThunderTargets = { 0, 200 },
    ThunderRange = { 50, 10000 },
    SkillLeftPriority = { 1, 3 },
    SkillMiddlePriority = { 1, 3 },
    SkillRightPriority = { 1, 3 },
    CraftChanceCommonRare = { 0, 100 },
    CraftChanceRareEpic = { 0, 100 },
    CraftChanceEpicLegendary = { 0, 100 },
    CraftChanceLegendaryMythic = { 0, 100 },
    PrestigeStopAt = { 1, 5 },
}
SH.Memories = {
    { Id = "Thanatophobia", Name = "[Defense] Thanatophobia", Stars = 4, Desc = "When below 40.0% HEALTH: +25.0% DMG RED., +15.0% INJURY CHANCE RED. and heal an injury every 15s" },
    { Id = "Necromantic", Name = "[Defense] Necromantic", Stars = 4, Desc = "Upon ignoring death, gain +20.0% DMG, +25.0% HEALTH and +15.0% SPEED" },
    { Id = "SteelFrame", Name = "[Defense] Steel Frame", Stars = 3, Desc = "All explosions deal 25.0% less self DMG and grant immunity to any explosions for 5s" },
    { Id = "Resilience", Name = "[Defense] Resilience", Stars = 3, Desc = "Ignore up to 1 killing blows per match" },
    { Id = "Vengeflare", Name = "[Defense] Vengeflare", Stars = 3, Desc = "Reflect 50.0% of any incoming damage for the next 20s when Tough As Nails is active" },
    { Id = "Aegisurge", Name = "[Defense] Aegisurge", Stars = 2, Desc = "Gain a temporary shield that has 15.0% of your MAX HEALTH for 20s after a titan kill" },
    { Id = "Riposte", Name = "[Defense] Riposte", Stars = 2, Desc = "Successful counters instantly execute a titan" },
    { Id = "Guardian", Name = "[Defense] Guardian", Stars = 1, Desc = "Ignore up to 2 injuries per match" },
    { Id = "Deflectra", Name = "[Defense] Deflectra", Stars = 1, Desc = "5.0% chance to completely block incoming damage" },
    { Id = "Afterimages", Name = "[Offense] Afterimages", Stars = 4, Desc = "Explosions create a smaller explosion in their wake, doing 40.0% DMG (4s CD)" },
    { Id = "Overslash", Name = "[Offense] Overslash", Stars = 4, Desc = "30.0% of any excess DMG from a finishing blow applies to other titans in a 125m radius (4s CD)" },
    { Id = "Gambler", Name = "[Offense] Gambler", Stars = 4, Desc = "All DMG dealt fluctuates between 75.0% - 130.0% (Perfect Form makes this 85.0% - 140.0%)" },
    { Id = "Supernova", Name = "[Offense] Supernova", Stars = 3, Desc = "Increase TS DMG by 25.0%, but for every 100m away from your explosion, lose 2.5% TS DMG" },
    { Id = "Amputation", Name = "[Offense] Amputation", Stars = 3, Desc = "Critical hits dealt to non-boss type titans' limbs disables limb regeneration" },
    { Id = "Assassin", Name = "[Offense] Assassin", Stars = 3, Desc = "Blade skills deal 25.0% more DMG and have +15.0% SKILL CD REDUCTION" },
    { Id = "Quakestrike", Name = "[Offense] Quakestrike", Stars = 3, Desc = "Each kill increases DMG by 1.5%, resets after reloading" },
    { Id = "Furyforge", Name = "[Offense] Furyforge", Stars = 3, Desc = "Increase DMG by 0.4% for every 1.0% of HEALTH lost" },
    { Id = "Stormcharged", Name = "[Offense] Stormcharged", Stars = 2, Desc = "DMG increases by 3.0% for each shifter currently active in a match" },
    { Id = "Stalwart", Name = "[Offense] Stalwart", Stars = 2, Desc = "BLADE DURABILITY increases by 3.0% for every broken segment" },
    { Id = "Surgeshot", Name = "[Offense] Surgeshot", Stars = 1, Desc = "Holding your Spears M1 for longer increases the BLAST RADIUS" },
    { Id = "Swiftshot", Name = "[Offense] Swiftshot", Stars = 1, Desc = "Refilling your gas and blades is 25.0% faster" },
    { Id = "Crescendo", Name = "[Offense] Crescendo", Stars = 1, Desc = "Deal an additional 20.0% DMG to titans that are stunned" },
    { Id = "Blitzblade", Name = "[Offense] Blitzblade", Stars = 1, Desc = "Holding your Blades M1 for longer increases the total DMG" },
    { Id = "Bloodthief", Name = "[Support] Bloodthief", Stars = 4, Desc = "Being hooked onto an enemy titan recovers 3.0% HEALTH every 2s" },
    { Id = "Apotheosis", Name = "[Support] Apotheosis", Stars = 4, Desc = "Awakening Bar fills 15.0% faster, can shift at 60.0% bar and +1.25% DMG for every 10.0% of Bar filled" },
    { Id = "Tactician", Name = "[Support] Tactician", Stars = 3, Desc = "All support skill effects are multiplied by 1.15x" },
    { Id = "Omnirange", Name = "[Support] Omnirange", Stars = 3, Desc = "Any ranged skills now affect all players, regardless of range" },
    { Id = "Flashstep", Name = "[Support] Flashstep", Stars = 3, Desc = "Dashes/Flips now have I-Frames" },
    { Id = "GemFiend", Name = "[Support] Gem Fiend", Stars = 2, Desc = "Obtain +10.0% more Gems from AFK Zone/Mission Streak" },
    { Id = "Vitalize", Name = "[Support] Vitalize", Stars = 2, Desc = "Saving a teammate heals both of you for 10.0% HEALTH, each dealing 25.0% more DMG next hit" },
    { Id = "Lifefeed", Name = "[Support] Lifefeed", Stars = 2, Desc = "Gain 2.0% of your HEALTH back per titan kill" },
    { Id = "CooldownBlitz", Name = "[Support] Cooldown Blitz", Stars = 1, Desc = "SKILL COOLDOWN REDUCTION increases by 10.0%" },
    { Id = "Mendmaster", Name = "[Support] Mendmaster", Stars = 1, Desc = "Gain 1 extra bandage after refilling your gas and blades" },
}
for _, m in ipairs(SH.Memories) do
    m.Key = "Mem_" .. m.Id
    Cfg[m.Key] = 5
    FARM_RANGES[m.Key] = { 0, 10 }
end
local UiSync = { Defaults = { Cfg = {}, Hub = {} }, Refreshers = {} }
for key, value in pairs(Cfg) do
    if type(value) == "table" then
        local copy = {}
        for i, item in ipairs(value) do copy[i] = item end
        UiSync.Defaults.Cfg[key] = copy
    else
        UiSync.Defaults.Cfg[key] = value
    end
end
function UiSync.Add(fn)
    UiSync.Refreshers[#UiSync.Refreshers + 1] = fn
end
function UiSync.Link(control, tbl, key, extra)
    UiSync.Add(function()
        local want = tbl[key]
        if control.Value ~= want then control.Value = want end
        if extra then extra(control, want) end
    end)
    return control
end
function UiSync.Refresh()
    for _, fn in ipairs(UiSync.Refreshers) do pcall(fn) end
end
local SAVE_DIR = "SmoothHub"
local LEGACY_PATH = SAVE_DIR .. "/AOTR_Menu_" .. tostring(LocalPlayer.UserId) .. ".json"
local canSave = type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
local function ClampDelay(v)
    v = tonumber(v) or 10
    return math.clamp(math.floor(v + 0.5), MIN_DELAY, MAX_DELAY)
end
local function ApplyCfgData(data)
    if type(data) ~= "table" then return end
    if type(data.Slot) == "number" and data.Slot >= 1 and data.Slot <= 3 then Cfg.Slot = math.floor(data.Slot) end
    if data.JoinDelay ~= nil then Cfg.JoinDelay = ClampDelay(data.JoinDelay) end
    if data.MissionJoinDelay ~= nil then Cfg.MissionJoinDelay = ClampDelay(data.MissionJoinDelay) end
    if data.RaidJoinDelay ~= nil then Cfg.RaidJoinDelay = ClampDelay(data.RaidJoinDelay) end
    if data.WaveJoinDelay ~= nil then Cfg.WaveJoinDelay = ClampDelay(data.WaveJoinDelay) end
    for _, key in ipairs({
        "AutoSelect", "AutoJoin", "AutoSpin", "SpinUseDelay", "SpinShowList",
        "AutoClaimMain", "AutoClaimSide", "AutoClaimAchievements", "AutoClaimWeekly", "AutoClaimDaily", "AutoOpenPages", "AutoQuestThunder", "AutoQuestThunderR1", "AutoQuestThunderR2", "AutoQuestThunderR3",
        "AutoUpgradeBlade", "AutoUpgradeThunder", "AutoEquipThunder", "AutoEquipBlade",
        "AutoBestGrade", "AutoBoostMission", "AutoCreateMission", "AutoStartMission", "AutoCreateRaid", "AutoStartRaid", "AutoCreateWave", "AutoStartWave", "AutoLootCrate", "AutoRefillWave", "AutoRollBlessing", "RollStopOnMatch", "AutoHealInjuries", "AutoUpgradeChar", "AutoUpgradeBlades", "UpgMaxHP", "UpgRegen", "UpgReplenish", "UpgRefills", "UpgRevive",
        "AutoShop", "ShopPerk", "ShopArtifact", "ShopMemory", "ShopCrates", "ShopStar1", "ShopStar2", "ShopStar3", "ShopStar4", "ShopStar5",
        "ShopPerkStar1", "ShopPerkStar2", "ShopPerkStar3", "ShopPerkStar4", "ShopPerkStar5", "ShopArtifactStar1", "ShopArtifactStar2", "ShopArtifactStar3", "ShopArtifactStar4", "ShopArtifactStar5", "ShopMemoryStar1", "ShopMemoryStar2", "ShopMemoryStar3", "ShopMemoryStar4", "ShopMemoryStar5",
        "AutoFarm", "WaitForBoss", "AutoPlay", "AutoClearWave", "AutoFarmThunder", "AutoFarmSmart", "RefillEnabled", "RefillPickBlade", "RefillPickThunder", "SafeFarm", "AutoReload", "AutoRefillsBlade", "AutoRefillsThunder", "DamageMultiplier", "AutoFailSafe", "NoClip", "HitAllParts",
        "AutoRetry", "AutoLeave", "AutoLeaveWhenRetryComplete", "AutoReady", "AutoVoteSkip", "AutoLeaveAtWave", "AutoSkipCutscene", "AutoOpenChestFree", "AutoOpenChestPremium", "AutoFinishChest", "AutoCannon", "CannonFarmSmall", "AutoDefendEren", "UseThunderSpears",
        "AutoSkill1", "AutoSkill2", "AutoSkill3", "AutoSkill4", "AutoSkill5", "AutoUpgradeSkills", "SkillLeft", "SkillMiddle", "SkillRight",
        "AutoCraftPerks", "CraftCommonRare", "CraftRareEpic", "CraftEpicLegendary", "CraftLegendaryMythic", "AutoPrestige",
    }) do
        if type(data[key]) == "boolean" then Cfg[key] = data[key] end
    end
    for i = 1, 5 do -- [NEW] ย้ายค่าดาวรวมเดิม (ShopStar1-5) ไปเป็นค่าแยกหมวด
        local old = data["ShopStar" .. i]
        if type(old) == "boolean" then
            for _, p in ipairs({ "ShopPerkStar", "ShopArtifactStar", "ShopMemoryStar" }) do
                if data[p .. i] == nil then Cfg[p .. i] = old end
            end
        end
    end
    if type(data.RetryDone) == "number" and data.RetryDone == data.RetryDone and data.RetryDone >= 0 then
        Cfg.RetryDone = math.floor(data.RetryDone)
    end
    if type(data.QuestR3Played) == "number" and data.QuestR3Played == data.QuestR3Played and data.QuestR3Played >= 0 then
        Cfg.QuestR3Played = math.floor(data.QuestR3Played)
    end
    if type(data.Streak) == "number" and data.Streak == data.Streak and data.Streak >= 0 then
        Cfg.Streak = math.floor(data.Streak)
    end
    for key, range in pairs(FARM_RANGES) do
        if type(data[key]) == "number" and data[key] == data[key] then
            Cfg[key] = math.clamp(math.floor(data[key] + 0.5), range[1], range[2])
        end
    end
    if type(data.SpinDelay) == "number" and data.SpinDelay == data.SpinDelay then
        Cfg.SpinDelay = math.clamp(math.floor(data.SpinDelay * 2 + 0.5) / 2, 0.5, 10)
    end
    if data.AutoCreateMission == nil and type(data.RememberAutoCreate) == "boolean" then Cfg.AutoCreateMission = data.RememberAutoCreate end
    if data.AutoStartMission == nil and type(data.RememberAutoStart) == "boolean" then Cfg.AutoStartMission = data.RememberAutoStart end
    for _, key in ipairs({ "FarmMode", "MissionSelect", "MissionObjective", "MissionLevel", "RaidSelect", "RaidLevel", "WaveSelect", "WaveLevel", "ShopPriority", "SpinStopRarity", "SpinOnKeep", "SpinFamilyRules", "AutoSkillMode1", "AutoSkillMode2", "AutoSkillMode3", "AutoSkillMode4", "AutoSkillMode5", "SkillLeftPick", "SkillMiddlePick", "SkillRightPick", "PrestigeBoost1", "PrestigeBoost2", "PrestigeBoost3", "PrestigeBoost4", "PrestigeBoost5" }) do
        if type(data[key]) == "string" then Cfg[key] = data[key] end
    end
    for _, key in ipairs({ "MissionDifficulty", "MissionModifiers", "RaidModifiers" }) do
        if type(data[key]) == "table" then
            local names = {}
            for _, v in ipairs(data[key]) do
                if type(v) == "string" then names[#names + 1] = v end
            end
            Cfg[key] = names
        end
    end
end
local function ReadLegacyCfg()
    if not canSave then return nil end
    local ok, data = pcall(function()
        if not isfile(LEGACY_PATH) then return nil end
        return HttpService:JSONDecode(readfile(LEGACY_PATH))
    end)
    if ok and type(data) == "table" then return data end
    return nil
end
local saveHook = nil
local saveQueued = false
local function Save()
    if saveQueued then return end
    saveQueued = true
    task.delay(0.4, function()
        saveQueued = false
        if saveHook then pcall(saveHook) end
    end)
end
local ConfigStore = {
    DEFAULT_NAME = "Smooth Hub | Default",
        DEFAULT_LOOK = { Theme = "Red", Accent = "Red", UIBlur = true, Dropshadow = true, Keybind = "B" },
}
do
    local DEFAULT_CONFIG_NAME = ConfigStore.DEFAULT_NAME
    local DEFAULT_LOOK = ConfigStore.DEFAULT_LOOK
    local PATH = SAVE_DIR .. "/AOTR_Configs_" .. tostring(LocalPlayer.UserId) .. ".json"
    local data = { Autoload = nil, Active = nil, AutoSync = true, List = {} }
    local sigs = {}
    local defaultSnap = nil
    local function Flush()
        if not canSave then return false end
        return (pcall(function()
            if type(makefolder) == "function" and type(isfolder) == "function" and not isfolder(SAVE_DIR) then
                makefolder(SAVE_DIR)
            end
            writefile(PATH, HttpService:JSONEncode(data))
        end))
    end
    local function CopyValue(v)
        if type(v) == "table" then
            local out = {}
            for _, item in ipairs(v) do
                if type(item) == "string" then out[#out + 1] = item end
            end
            return out
        end
        return v
    end
    function ConfigStore.Reload()
        data = { Autoload = nil, Active = nil, AutoSync = true, List = {} }
        sigs = {}
        if defaultSnap then data.List[DEFAULT_CONFIG_NAME] = defaultSnap end
        if not canSave then return end
        local ok, decoded = pcall(function()
            if not isfile(PATH) then return nil end
            return HttpService:JSONDecode(readfile(PATH))
        end)
        if ok and type(decoded) == "table" then
            if type(decoded.List) == "table" then
                for name, snap in pairs(decoded.List) do
                    if type(name) == "string" and type(snap) == "table" and name ~= DEFAULT_CONFIG_NAME then data.List[name] = snap end
                end
            end
            if type(decoded.Autoload) == "string" and data.List[decoded.Autoload] then data.Autoload = decoded.Autoload end
            if type(decoded.Active) == "string" and data.List[decoded.Active] then data.Active = decoded.Active end
            if decoded.AutoSync == false then data.AutoSync = false end
        end
    end
    function ConfigStore.Names()
        local names = {}
        for name in pairs(data.List) do names[#names + 1] = name end
        table.sort(names, function(a, b)
            if a == DEFAULT_CONFIG_NAME then return b ~= DEFAULT_CONFIG_NAME end
            if b == DEFAULT_CONFIG_NAME then return false end
            return a:lower() < b:lower()
        end)
        return names
    end
    function ConfigStore.IsDefault(name) return name == DEFAULT_CONFIG_NAME end
    function ConfigStore.Exists(name) return data.List[name] ~= nil end
    function ConfigStore.Get(name) return data.List[name] end
    function ConfigStore.Autoload() return data.Autoload end
    function ConfigStore.Active() return data.Active end
    function ConfigStore.AutoloadSnapshot() return data.Autoload and data.List[data.Autoload] or nil end
    function ConfigStore.Snapshot(hub)
        local snap = { Cfg = {}, Hub = {} }
        for k, v in pairs(Cfg) do snap.Cfg[k] = CopyValue(v) end
        if hub then
            for k, v in pairs(hub) do
                local t = type(v)
                if t == "boolean" or t == "number" or t == "string" then snap.Hub[k] = v end
            end
        end
        if ConfigStore.GetUI then
            local okUi, ui = pcall(ConfigStore.GetUI)
            if okUi and type(ui) == "table" then snap.UI = ui end
        end
        return snap
    end
    function ConfigStore.Put(name, snap)
        if name == DEFAULT_CONFIG_NAME then return false end
        data.List[name] = snap
        sigs[name] = nil
        return Flush()
    end
    function ConfigStore.Delete(name)
        if name == DEFAULT_CONFIG_NAME then return false end
        data.List[name] = nil
        sigs[name] = nil
        if data.Autoload == name then data.Autoload = nil end
        if data.Active == name then data.Active = nil end
        return Flush()
    end
    function ConfigStore.SetAutoload(name)
        if name ~= nil and not data.List[name] then return false end
        data.Autoload = name
        return Flush()
    end
    function ConfigStore.SetActive(name)
        if name ~= nil and not data.List[name] then return false end
        if data.Active == name then return true end
        data.Active = name
        return Flush()
    end
    function ConfigStore.SyncActive(hub)
        if data.AutoSync == false then return false end
        local name = data.Active
        if not name or not data.List[name] then return false end
        if name == DEFAULT_CONFIG_NAME then return false end
        local snap = ConfigStore.Snapshot(hub)
        local okSig, sig = pcall(function() return HttpService:JSONEncode(snap) end)
        if not okSig or sigs[name] == sig then return false end
        data.List[name] = snap
        if Flush() then sigs[name] = sig return true end
        return false
    end
    function ConfigStore.AutoSync() return data.AutoSync ~= false end
    function ConfigStore.SetAutoSync(value)
        data.AutoSync = value and true or false
        return Flush()
    end
    function ConfigStore.SaveActive(hub)
        local name = data.Active
        if not name or not data.List[name] then return false, nil end
        if name == DEFAULT_CONFIG_NAME then return false, name end
        local snap = ConfigStore.Snapshot(hub)
        data.List[name] = snap
        sigs[name] = nil
        local ok = Flush()
        if ok then
            local okSig, sig = pcall(function() return HttpService:JSONEncode(snap) end)
            if okSig then sigs[name] = sig end
        end
        return ok, name
    end
    local function SameValue(x, y)
        if type(x) ~= type(y) then return false end
        if type(x) == "table" then
            if #x ~= #y then return false end
            for i = 1, #x do
                if x[i] ~= y[i] then return false end
            end
            return true
        end
        return x == y
    end
    local function SameMap(current, saved)
        if type(saved) ~= "table" then return true end
        for k, v in pairs(current) do
            if saved[k] ~= nil and not SameValue(v, saved[k]) then return false end
        end
        return true
    end
    function ConfigStore.IsDirty(hub)
        local name = data.Active
        local saved = name and data.List[name]
        if not saved then return false end
        local snap = ConfigStore.Snapshot(hub)
        return not (SameMap(snap.Cfg, saved.Cfg) and SameMap(snap.Hub, saved.Hub) and SameMap(snap.UI or {}, saved.UI))
    end
    function ConfigStore.ApplyCfg(snap)
        if type(snap) ~= "table" or type(snap.Cfg) ~= "table" then return end
        local saved = snap.Cfg
        for k, v in pairs(saved) do
            local cur = Cfg[k]
            if cur ~= nil and type(cur) == type(v) then
                if type(v) == "table" then
                    Cfg[k] = CopyValue(v)
                elseif k == "JoinDelay" or k == "MissionJoinDelay" or k == "RaidJoinDelay" or k == "WaveJoinDelay" then
                    Cfg[k] = ClampDelay(v)
                elseif k == "Slot" then
                    Cfg[k] = math.clamp(math.floor(v), 1, 3)
                elseif k == "SpinDelay" and v == v then
                    Cfg[k] = math.clamp(math.floor(v * 2 + 0.5) / 2, 0.5, 10)
                elseif FARM_RANGES[k] and v == v then
                    Cfg[k] = math.clamp(math.floor(v + 0.5), FARM_RANGES[k][1], FARM_RANGES[k][2])
                else
                    Cfg[k] = v
                end
            end
        end
        if saved.AutoCreateMission == nil and type(saved.RememberAutoCreate) == "boolean" then Cfg.AutoCreateMission = saved.RememberAutoCreate end
        if saved.AutoStartMission == nil and type(saved.RememberAutoStart) == "boolean" then Cfg.AutoStartMission = saved.RememberAutoStart end
    end
    function ConfigStore.ApplyHub(hub, snap)
        if type(snap) ~= "table" or type(snap.Hub) ~= "table" then return end
        for k, v in pairs(snap.Hub) do
            if hub[k] ~= nil and type(hub[k]) == type(v) then hub[k] = v end
        end
    end
    function ConfigStore.ApplyUI(snap)
        if type(snap) ~= "table" or type(snap.UI) ~= "table" then return end
        if ConfigStore.UIApplier then pcall(ConfigStore.UIApplier, snap.UI) end
    end
    function ConfigStore.BuildDefault(hubDefaults)
        local snap = { Cfg = {}, Hub = {}, UI = {} }
        for k, v in pairs(UiSync.Defaults.Cfg) do snap.Cfg[k] = CopyValue(v) end
        if hubDefaults then
            for k, v in pairs(hubDefaults) do
                local t = type(v)
                if t == "boolean" or t == "number" or t == "string" then snap.Hub[k] = v end
            end
        end
        for k, v in pairs(DEFAULT_LOOK) do snap.UI[k] = v end
        defaultSnap = snap
        data.List[DEFAULT_CONFIG_NAME] = snap
        sigs[DEFAULT_CONFIG_NAME] = nil
    end
    ConfigStore.BuildDefault()
    ConfigStore.Reload()
end
SH.say("Loading interface...")
local okLib, Cascade = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/smoothhubv1-prog/Cascade-UI-Library/refs/heads/main/Ui.luau"))()
end)
if not okLib or type(Cascade) ~= "table" then
    SH.say("Could not load the interface. Check your internet connection.")
    SH.dbg("[SmoothHub] โหลด UI ไม่สำเร็จ:", tostring(Cascade))
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Smooth Hub", Text = "โหลด UI ไม่สำเร็จ (เช็คเน็ต/ลิงก์ GitHub)", Duration = 8,
        })
    end)
    return
end
SH.say("Interface ready.")
do
    local mainRed = Color3.fromHex("#FF1E3C")
    local glowRed = Color3.fromHex("#FF4D66")
    local darkRed = Color3.fromHex("#8F0018")
    
    local bgDeep = Color3.fromHex("#080001")
    local bgView = Color3.fromHex("#0D0003")
    local bgSide = Color3.fromHex("#0A0002")
    local bgTitle = Color3.fromHex("#1C0005")
    local bgMenu = Color3.fromHex("#100003")

    local function buildSet()
        return {
            SwitchAccent = mainRed,
            Selection = darkRed,
            SelectionFocused = glowRed,
            Toggle = { SwitchOn = mainRed },
            Button = { FillPrimary = ColorSequence.new(glowRed, darkRed) },
        }
    end

    local dark = buildSet()
    dark.Background = bgDeep
    dark.View = bgView
    dark.Sidebar = bgSide
    dark.Titlebar = bgTitle
    dark.MenuButton = { MenuBackground = bgMenu }

    local redTheme = {
        _id = "Red",
        Dark = dark,
        Light = buildSet(),
    }

    if Cascade and Cascade.Accents then
        for _, name in ipairs({"Red", "Dark", "Pink", "Blue", "Purple", "Green", "Graphite", "Blood", "Crimson"}) do
            Cascade.Accents[name] = redTheme
        end
    end
end
local function Icon(...)
    for _, name in ipairs({ ... }) do
        if Cascade.Symbols[name] then return Cascade.Symbols[name] end
    end
    return Cascade.Symbols["boltFill"]
end
local function BindButton(btn, fn)
    local last = 0
    local function run()
        if os.clock() - last < 0.5 then return end
        last = os.clock()
        task.spawn(fn)
    end
    pcall(function()
        if btn.__instance then
            local obj = btn.__instance:FindFirstChildWhichIsA("TextButton", true) or btn.__instance
            obj.MouseButton1Click:Connect(run)
        end
    end)
    return run
end
local SettingsStore = {}
do
    local HttpService = game:GetService("HttpService")
    local owner = game:GetService("Players").LocalPlayer
    local ROOT = "SmoothHub"
    local DIR = ROOT .. "/" .. tostring(owner.UserId)
    local canSave = type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
    local canFolder = type(makefolder) == "function" and type(isfolder) == "function"
    local flushers = {}
    function SettingsStore.Path(fileName)
        if canFolder then
            return DIR .. "/" .. fileName .. ".json"
        end
        return ROOT .. "_" .. tostring(owner.UserId) .. "_" .. fileName .. ".json"
    end
    local function ensureFolder()
        if not canFolder then return end
        pcall(function()
            if not isfolder(ROOT) then makefolder(ROOT) end
            if not isfolder(DIR) then makefolder(DIR) end
        end)
    end
    local function copy(value)
        if type(value) ~= "table" then return value end
        local out = {}
        for k, v in pairs(value) do
            out[k] = copy(v)
        end
        return out
    end
    local function clean(value, depth)
        depth = depth or 0
        local kind = type(value)
        if kind == "string" or kind == "boolean" then return value end
        if kind == "number" then
            if value ~= value or value == math.huge or value == -math.huge then return nil end
            return value
        end
        if kind ~= "table" or depth > 6 then return nil end
        local count, isArray = 0, true
        for k in pairs(value) do
            count = count + 1
            if type(k) ~= "number" then isArray = false end
        end
        if isArray then
            for i = 1, count do
                if value[i] == nil then
                    isArray = false
                    break
                end
            end
        end
        local out = {}
        if isArray then
            for i = 1, count do
                local c = clean(value[i], depth + 1)
                if c ~= nil then table.insert(out, c) end
            end
        else
            for k, v in pairs(value) do
                local c = clean(v, depth + 1)
                if c ~= nil then out[tostring(k)] = c end
            end
        end
        return out
    end
    function SettingsStore.Load(fileName)
        if not canSave then return {} end
        local ok, data = pcall(function()
            local path = SettingsStore.Path(fileName)
            if not isfile(path) then return nil end
            return HttpService:JSONDecode(readfile(path))
        end)
        if ok and type(data) == "table" then return data end
        return {}
    end
    function SettingsStore.Write(fileName, data)
        if not canSave then return false end
        ensureFolder()
        local ok = pcall(function()
            writefile(SettingsStore.Path(fileName), HttpService:JSONEncode(data))
        end)
        return ok
    end
    function SettingsStore.Restore(target, saved)
        if type(target) ~= "table" or type(saved) ~= "table" then return end
        for key, default in pairs(target) do
            local value = saved[key]
            if value ~= nil then
                if type(default) == "table" then
                    if type(value) == "table" then
                        if next(default) == nil then
                            target[key] = copy(value)
                        else
                            SettingsStore.Restore(default, value)
                        end
                    end
                elseif type(default) == type(value) then
                    target[key] = value
                end
            end
        end
    end
    function SettingsStore.IndexOf(options, name, fallback)
        return table.find(options, name) or fallback or 1
    end
    function SettingsStore.IndexesFromMap(options, map)
        local out = {}
        if type(map) == "table" then
            for i, name in ipairs(options) do
                if map[name] then table.insert(out, i) end
            end
        end
        return out
    end
    function SettingsStore.ValidIndexes(list, max)
        local out, seen = {}, {}
        if type(list) == "table" then
            for _, index in ipairs(list) do
                if type(index) == "number" and index >= 1 and index <= max and index % 1 == 0 and not seen[index] then
                    seen[index] = true
                    table.insert(out, index)
                end
            end
        end
        return out
    end
    function SettingsStore.StartAutoSave(fileName, getData, interval)
        if flushers[fileName] then return end
        local last = nil
        local function flush()
            local ok, snapshot = pcall(function()
                return clean(getData())
            end)
            if not ok or type(snapshot) ~= "table" then return end
            local okSig, signature = pcall(function()
                return HttpService:JSONEncode(snapshot)
            end)
            if not okSig or signature == last then return end
            snapshot.SavedAt = os.time()
            snapshot.Account = owner.Name
            if SettingsStore.Write(fileName, snapshot) then
                last = signature
                if SettingsStore.OnSaved then pcall(SettingsStore.OnSaved, snapshot.SavedAt) end
            end
        end
        flushers[fileName] = flush
        task.spawn(function()
            while true do
                task.wait(interval or 1.5)
                flush()
            end
        end)
    end
    function SettingsStore.Flush(fileName)
        local flush = flushers[fileName]
        if flush then pcall(flush) end
    end
end
local SavedData = SettingsStore.Load("AOTR")
local SavedUi = type(SavedData.UI) == "table" and SavedData.UI or {}
do
    local autoSnap = ConfigStore.AutoloadSnapshot()
    if autoSnap and type(autoSnap.UI) == "table" then
        for k, v in pairs(autoSnap.UI) do SavedUi[k] = v end
    end
end
if type(SavedData.Cfg) == "table" then ApplyCfgData(SavedData.Cfg) else ApplyCfgData(ReadLegacyCfg()) end
if ConfigStore.AutoloadSnapshot() then
    ConfigStore.ApplyCfg(ConfigStore.AutoloadSnapshot())
    ConfigStore.SetActive(ConfigStore.Autoload())
end
-- ============================================================
--  🔁 Legacy config support — รองรับคอนฟิกแบบ getgenv().Configs = { ['Auto Prestige'] = {...}, ... }
--   • ตั้ง getgenv().Configs ก่อนรันสคริปต์ → ใช้ค่าอัตโนมัติตอนเริ่ม
--   • หรือวางข้อความคอนฟิกลงช่อง Import ในแท็บ Config → นำเข้าเป็นคอนฟิกใหม่
--  ตัวอ่านเป็นตัวแยกข้อความล้วน ๆ (ไม่ได้ loadstring/รันโค้ดที่วางมา) จึงปลอดภัยแม้คอนฟิกมาจากคนอื่น
--  ค่าที่ Smooth Hub ไม่มีฟีเจอร์คู่กันจะถูกข้าม (เช่น Codes, Sell Cosmetics, Webhook)
-- ============================================================
SH.Legacy = {}
do
    local function Clamp(n, lo, hi) return math.max(lo, math.min(hi, n)) end

    -- ---------- ตัวอ่านตาราง Lua แบบปลอดภัย ----------
    local function Parse(src)
        src = tostring(src or "")
        if #src > 300000 then return nil, "Config text is too large" end
        local pos, len = 1, #src
        local ParseValue
        local function skip()
            while pos <= len do
                local c = src:sub(pos, pos)
                if c:match("%s") then
                    pos = pos + 1
                elseif src:sub(pos, pos + 1) == "--" then
                    local lb = src:match("^%-%-%[(=*)%[", pos)
                    if lb then
                        local close = "]" .. lb .. "]"
                        local e = src:find(close, pos, true)
                        pos = e and (e + #close) or (len + 1)
                    else
                        local e = src:find("\n", pos, true)
                        pos = e and (e + 1) or (len + 1)
                    end
                else
                    break
                end
            end
        end
        local ESC = { n = "\n", t = "\t", r = "\r", ["\\"] = "\\", ['"'] = '"', ["'"] = "'" }
        local function ParseString()
            local q = src:sub(pos, pos)
            pos = pos + 1
            local buf = {}
            while pos <= len do
                local c = src:sub(pos, pos)
                if c == q then
                    pos = pos + 1
                    return table.concat(buf)
                end
                if c == "\\" then
                    local n = src:sub(pos + 1, pos + 1)
                    buf[#buf + 1] = ESC[n] or n
                    pos = pos + 2
                else
                    buf[#buf + 1] = c
                    pos = pos + 1
                end
            end
            error("unterminated string")
        end
        local function ParseTable(depth)
            if depth > 12 then error("table nested too deep") end
            pos = pos + 1 -- {
            local t, arr = {}, 0
            while true do
                skip()
                local c = src:sub(pos, pos)
                if c == "" then error("unexpected end of text") end
                if c == "}" then
                    pos = pos + 1
                    return t
                elseif c == "," or c == ";" then
                    pos = pos + 1
                elseif c == "[" and not src:match("^%[=*%[", pos) then
                    pos = pos + 1
                    skip()
                    local key = ParseValue(depth + 1)
                    skip()
                    if src:sub(pos, pos) ~= "]" then error("expected ]") end
                    pos = pos + 1
                    skip()
                    if src:sub(pos, pos) ~= "=" then error("expected =") end
                    pos = pos + 1
                    local value = ParseValue(depth + 1)
                    if key ~= nil then t[key] = value end
                else
                    local name = src:match("^([%a_][%w_]*)%s*=[^=]", pos)
                    if name then
                        pos = pos + #name
                        skip()
                        pos = pos + 1 -- =
                        t[name] = ParseValue(depth + 1)
                    else
                        arr = arr + 1
                        t[arr] = ParseValue(depth + 1)
                    end
                end
            end
        end
        ParseValue = function(depth)
            skip()
            local c = src:sub(pos, pos)
            if c == "{" then
                return ParseTable(depth)
            elseif c == '"' or c == "'" then
                return ParseString()
            elseif c == "[" then
                local lb = src:match("^%[(=*)%[", pos)
                if not lb then error("unexpected [") end
                local close = "]" .. lb .. "]"
                local s = pos + #lb + 2
                local e = src:find(close, s, true)
                if not e then error("unterminated string") end
                pos = e + #close
                return src:sub(s, e - 1)
            end
            local numStr = src:match("^%-?%d[%d%._eE%+%-]*", pos)
            if numStr then
                local n = tonumber((numStr:gsub("_", "")))
                if not n then error("bad number") end
                pos = pos + #numStr
                return n
            end
            local word = src:match("^[%a_][%w_]*", pos)
            if word == "true" then pos = pos + 4 return true end
            if word == "false" then pos = pos + 5 return false end
            if word == "nil" then pos = pos + 3 return nil end
            error("unsupported value near position " .. pos)
        end
        local s = src:find("{", 1, true)
        if not s then return nil, "No config table { ... } found" end
        pos = s
        local ok, res = pcall(ParseTable, 1)
        if not ok then return nil, "Can't read config text: " .. tostring(res):gsub("^.-:%d+:%s*", "") end
        return res
    end

    -- ---------- แปลงคีย์ของคอนฟิกแบบเดิม → คีย์ของ Smooth Hub ----------
    local function Norm(s) return (tostring(s):lower():gsub("[^%w]", "")) end
    local function G(t, key)
        if type(t) ~= "table" then return nil end
        local want = Norm(key)
        for k, v in pairs(t) do
            if type(k) == "string" and Norm(k) == want then return v end
        end
        return nil
    end
    local SLOT_NUM = { A = 1, B = 2, C = 3 }
    local SKILL_PICKS = {
        Left = { "Regen VI", "Injury III" },
        Middle = { "Damage V", "Crit Damage V" },
        Right = { "Tank VIII", "Health XI" },
    }
    local function Has(list, v)
        for _, x in ipairs(list) do if x == v then return true end end
        return false
    end
    local UNSUPPORTED = {
        "Codes", "Sell Cosmetics", "Remove Perks", "Equip Perks", "Join Private Server", "Webhook",
    }

    local function Translate(tbl)
        local cfg, hub, applied, skipped = {}, {}, {}, {}
        local function Set(key, value, label)
            if Cfg[key] ~= nil and type(Cfg[key]) == type(value) then
                cfg[key] = value
                applied[#applied + 1] = label or key
            else
                skipped[#skipped + 1] = label or key
            end
        end
        local function Skip(label) skipped[#skipped + 1] = label end
        local function Bool(v) if type(v) == "boolean" then return v end return nil end
        local function Num(v) if type(v) == "number" and v == v then return v end return nil end

        local v = Bool(G(tbl, "Auto Thunder Spears"))
        if v ~= nil then Set("UseThunderSpears", v, "Auto Thunder Spears") end

        local p = G(tbl, "Auto Prestige")
        if type(p) == "table" then
            local e = Bool(G(p, "Enabled"))
            if e ~= nil then Set("AutoPrestige", e, "Auto Prestige") end
            local s = Num(G(p, "Prestige Stop At"))
            if s then Set("PrestigeStopAt", Clamp(math.floor(s + 0.5), 1, 5), "Prestige Stop At") end
            if G(p, "Gold Requirement") ~= nil then Skip("Prestige Gold Requirement") end
        end

        local slot = G(tbl, "Farm Slot")
        local slotN = type(slot) == "string" and SLOT_NUM[slot:upper()] or (Num(slot) and Clamp(math.floor(slot), 1, 3)) or nil
        if slotN then
            Set("Slot", slotN, "Farm Slot")
            Set("AutoSelect", true, "Auto Select Slot")
        end

        if G(tbl, "Colossal Raid") == true then
            Set("RaidSelect", "Colossal Titan", "Colossal Raid")
            Set("RaidLevel", "Aberrant", "Colossal Raid (level)")
            Set("AutoCreateRaid", true, "Colossal Raid (auto create)")
            Set("AutoStartRaid", true, "Colossal Raid (auto start)")
        end

        local fam = G(tbl, "Families")
        if type(fam) == "table" then
            local rules, any = {}, false
            local function AddFamilies(list)
                if type(list) ~= "table" then return end
                for _, name in ipairs(list) do
                    if type(name) == "string" then
                        name = name:gsub("[=;]", ""):match("^%s*(.-)%s*$")
                        if name ~= "" then rules[name:upper()] = "Keep" any = true end
                    end
                end
            end
            local roll = G(fam, "Auto Roll")
            if type(roll) == "table" then
                local e = Bool(G(roll, "Enabled"))
                if e ~= nil then Set("AutoSpin", e, "Auto Roll") end
                AddFamilies(G(roll, "Families"))
                if G(roll, "Lock Spins") ~= nil then Skip("Auto Roll > Lock Spins") end
            end
            local st = G(fam, "Auto Storage")
            if type(st) == "table" and G(st, "Enabled") == true then
                Set("SpinOnKeep", "Store", "Auto Storage")
                AddFamilies(G(st, "Families"))
            end
            if any then
                local parts = {}
                for k, r in pairs(rules) do parts[#parts + 1] = k .. "=" .. r end
                table.sort(parts)
                Set("SpinFamilyRules", table.concat(parts, ";"), "Families")
            end
        end

        local cp = G(tbl, "Craft Perks")
        if type(cp) == "table" then
            local e = Bool(G(cp, "Enabled"))
            if e ~= nil then Set("AutoCraftPerks", e, "Craft Perks") end
            local ch = G(cp, "Chance")
            if type(ch) == "table" then
                for src, key in pairs({ Rare = "CraftChanceCommonRare", Epic = "CraftChanceRareEpic",
                        Legendary = "CraftChanceEpicLegendary", Mythic = "CraftChanceLegendaryMythic" }) do
                    local n = Num(G(ch, src))
                    if n then Set(key, Clamp(math.floor(n + 0.5), 0, 100), "Craft Chance " .. src) end
                end
            end
            for src, key in pairs({ Epic = "CraftRareEpic", Legendary = "CraftEpicLegendary", Mythic = "CraftLegendaryMythic" }) do
                local b = Bool(G(cp, "Craft " .. src))
                if b ~= nil then Set(key, b, "Craft " .. src) end
            end
        end

        local sk = G(tbl, "Skill Trees")
        if type(sk) == "table" then
            local e = Bool(G(sk, "Enabled"))
            if e ~= nil then Set("AutoUpgradeSkills", e, "Skill Trees") end
            for _, lane in ipairs({ "Left", "Middle", "Right" }) do
                local node = G(sk, lane)
                if type(node) == "table" then
                    local on = Bool(G(node, "Enabled"))
                    if on ~= nil then Set("Skill" .. lane, on, "Skill " .. lane) end
                    local pick = G(node, "Skill")
                    if type(pick) == "string" then
                        if Has(SKILL_PICKS[lane], pick) then Set("Skill" .. lane .. "Pick", pick, "Skill " .. lane .. " Path")
                        else Skip("Skill " .. lane .. " Path (" .. pick .. ")") end
                    end
                end
            end
            if G(sk, "Upgrade Priority") ~= nil then Skip("Skill Upgrade Priority") end
        end

        local perf = G(tbl, "Performance")
        if type(perf) == "table" then
            local lock = G(perf, "FPS Lock")
            if type(lock) == "table" then
                local on = Bool(G(lock, "Enabled"))
                if on ~= nil then hub.EnableFPSLock = on applied[#applied + 1] = "FPS Lock" end
                local f = Num(G(lock, "FPS"))
                if f then hub.FPSLimit = Clamp(math.floor(f + 0.5), 1, 9999) applied[#applied + 1] = "FPS Limit" end
            end
            if G(perf, "FPS Boost") ~= nil then Skip("FPS Boost") end
        end

        for _, name in ipairs(UNSUPPORTED) do
            if G(tbl, name) ~= nil then Skip(name) end
        end
        return { cfg = cfg, hub = hub, applied = applied, skipped = skipped }
    end

    SH.Legacy.Parse = Parse
    SH.Legacy.Translate = Translate
    function SH.Legacy.Summary(res)
        local s = #res.applied .. " applied"
        if #res.skipped > 0 then s = s .. ", " .. #res.skipped .. " not supported" end
        return s
    end

    -- ---------- getgenv().Configs ตอนเริ่มสคริปต์ ----------
    local okEnv, genv = pcall(function() return type(getgenv) == "function" and getgenv() or nil end)
    local legacy = okEnv and genv and genv.Configs or nil
    if type(legacy) == "table" then
        local ok, res = pcall(Translate, legacy)
        if ok and res then
            ConfigStore.ApplyCfg({ Cfg = res.cfg })
            SH.LegacyHub = res.hub
            SH.say("Loaded getgenv().Configs: " .. SH.Legacy.Summary(res))
            if #res.skipped > 0 then SH.say("Not supported (skipped): " .. table.concat(res.skipped, ", ")) end
        end
    end
end
Cfg.JoinDelay = ClampDelay(Cfg.JoinDelay)
Cfg.MissionJoinDelay = ClampDelay(Cfg.MissionJoinDelay)
Cfg.RaidJoinDelay = ClampDelay(Cfg.RaidJoinDelay)
Cfg.WaveJoinDelay = ClampDelay(Cfg.WaveJoinDelay)
local AccentOrder
do
local WindowTints = {
    Blue     = { Background = "#0F1722", View = "#121C2A", Sidebar = "#111B29", Titlebar = "#1D2D45", Menu = "#182436" },
    Purple   = { Background = "#1A1226", View = "#1F1630", Sidebar = "#1C1429", Titlebar = "#33214D", Menu = "#261A38" },
    Pink     = { Background = "#25121A", View = "#2C161F", Sidebar = "#281420", Titlebar = "#4A2133", Menu = "#361B28" },
    Red      = { Background = "#080001", View = "#0D0003", Sidebar = "#0A0002", Titlebar = "#1C0005", Menu = "#100003" },
    Orange   = { Background = "#241A0F", View = "#2B1F12", Sidebar = "#271C10", Titlebar = "#4A3317", Menu = "#35261A" },
    Yellow   = { Background = "#222010", View = "#292611", Sidebar = "#252210", Titlebar = "#453D16", Menu = "#322E18" },
    Green    = { Background = "#0F2016", View = "#12271A", Sidebar = "#112318", Titlebar = "#1D4029", Menu = "#1A3022" },
    Graphite = { Background = "#1C1C1E", View = "#1F1F21", Sidebar = "#202023", Titlebar = "#363636", Menu = "#2C2C2E" },
}
for accentName, tint in pairs(WindowTints) do
    pcall(function()
        local dark = Cascade.Accents[accentName].Dark
        dark.Background = Color3.fromHex(tint.Background)
        dark.View = Color3.fromHex(tint.View)
        dark.Sidebar = Color3.fromHex(tint.Sidebar)
        dark.Titlebar = Color3.fromHex(tint.Titlebar)
        dark.MenuButton = { MenuBackground = Color3.fromHex(tint.Menu) }
    end)
end
local ExtraAccents = {
    { "Black", "#9A9AA0", { Background = "#000000", View = "#090909", Sidebar = "#050505", Titlebar = "#141414", Menu = "#101010" } },
    { "Midnight", "#4C6EF5", { Background = "#05080F", View = "#0A0F1A", Sidebar = "#070B14", Titlebar = "#131C30", Menu = "#0E1524" } },
    { "Red",        "#FF1E3C" },
    { "Crimson",    "#FF1E3C" },
    { "Blood",      "#FF1E3C" },
    { "Sky",        "#64D2FF" },
    { "Cyan",       "#00C7E6" },
    { "Teal",       "#30B0C7" },
    { "Turquoise",  "#40E0D0" },
    { "Aqua",       "#00E5FF" },
    { "Mint",       "#63E6BE" },
    { "Emerald",    "#10B981" },
    { "Forest",     "#2E8B57" },
    { "Lime",       "#A3E635" },
    { "Neon Green", "#39FF14" },
    { "Olive",      "#8A9A2B" },
    { "Gold",       "#FFC83D" },
    { "Amber",      "#FFA726" },
    { "Sand",       "#D9B97A" },
    { "Sunset",     "#FF7A45" },
    { "Peach",      "#FF9E80" },
    { "Coral",      "#FF6F61" },
    { "Cherry",     "#E0245E" },
    { "Crimson",    "#DC143C" },
    { "Maroon",     "#A52A2A" },
    { "Rose",       "#FF5C8A" },
    { "Hot Pink",   "#FF2E93" },
    { "Magenta",    "#E040FB" },
    { "Violet",     "#8B5CF6" },
    { "Lavender",   "#B39DDB" },
    { "Indigo",     "#5E5CE6" },
    { "Ocean",      "#1E88E5" },
    { "Navy",       "#3A5BA0" },
    { "Slate",      "#7C8DA6" },
    { "Silver",     "#B0B7C3" },
    { "Brown",      "#A2845E" },
}
local function MakeAccent(name, hex, customBg)
    local main = Color3.fromHex(hex)
    local h, s, val = main:ToHSV()
    local selection = Color3.fromHSV(h, math.min(s * 1.05, 1), math.min(val * 0.78, 0.72))
    local focused = Color3.fromHSV(h, s, math.min(val * 0.88, 0.80))
    local buttonBottom = Color3.fromHSV(h, math.min(s * 1.1, 1), math.min(val * 0.6, 0.55))
    local bgS = math.min(s * 0.6, 0.55)
        local function buildSet()
        return {
            SwitchAccent = main,
            Selection = selection,
            SelectionFocused = focused,
            Toggle = { 
                SwitchOn = main,
                SwitchOff = Color3.fromHex("#200005"), 
                Fill = Color3.fromHex("#200005")
            },
            Slider = { 
                Fill = main, 
                Empty = Color3.fromHex("#200005") 
            },
            Button = { FillPrimary = ColorSequence.new(focused, buttonBottom) },
        }
    end
    local dark = buildSet()
    dark.Background = Color3.fromHSV(h, bgS, 0.13)
    dark.View = Color3.fromHSV(h, bgS, 0.16)
    dark.Sidebar = Color3.fromHSV(h, bgS * 0.95, 0.15)
    dark.Titlebar = Color3.fromHSV(h, bgS * 0.85, 0.28)
    dark.MenuButton = { MenuBackground = Color3.fromHSV(h, bgS * 0.8, 0.20) }
    if customBg then
        dark.Background = Color3.fromHex(customBg.Background)
        dark.View = Color3.fromHex(customBg.View)
        dark.Sidebar = Color3.fromHex(customBg.Sidebar)
        dark.Titlebar = Color3.fromHex(customBg.Titlebar)
        dark.MenuButton = { MenuBackground = Color3.fromHex(customBg.Menu) }
    end
    Cascade.Accents[name] = {
        _id = name,
        Dark = dark,
        Light = buildSet(),
    }
end
do
    local originalSet = function()
        return {
            SwitchAccent = Color3.fromHex("#0A84FF"),
            Selection = Color3.fromHex("#007AFF"),
            SelectionFocused = Color3.fromHex("#0A82FF"),
            Toggle = { SwitchOn = Color3.fromHex("#0A84FF") },
            Button = {
                FillPrimary = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(72, 148, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 110, 255)),
                }),
            },
        }
    end
    local darkSet = originalSet()
    darkSet.Background = Color3.fromHex("#1C1C1E")
    darkSet.View = Color3.fromHex("#1F1F21")
    darkSet.Sidebar = Color3.fromHex("#202023")
    darkSet.Titlebar = Color3.fromHex("#363636")
    darkSet.MenuButton = { MenuBackground = Color3.fromHex("#2C2C2E") }
    Cascade.Accents.Dark = {
        _id = "Dark",
        Dark = darkSet,
        Light = originalSet(),
    }
end
AccentOrder = { "Blue", "Purple", "Pink", "Red", "Orange", "Yellow", "Green", "Graphite", "Dark" }
for _, entry in ipairs(ExtraAccents) do
    pcall(MakeAccent, entry[1], entry[2], entry[3])
    if Cascade.Accents[entry[1]] then
        table.insert(AccentOrder, entry[1])
    end
end
do
    local function DeepCrimson(mainHex, glowHex, darkHex)
        local main = Color3.fromHex(mainHex)
        local glow = Color3.fromHex(glowHex)
        local dark = Color3.fromHex(darkHex)

        local bg      = Color3.fromHex("#050001")
        local view    = Color3.fromHex("#0A0002")
        local sidebar = Color3.fromHex("#080001")
        local title   = Color3.fromHex("#150003")
        local menu    = Color3.fromHex("#0D0002")

        local function buildSet(withBackground)
            local set = {
                SwitchAccent     = main,
                Selection        = dark,
                SelectionFocused = glow,
                Toggle = {
                    SwitchOn  = main,
                    SwitchOff = Color3.fromHex("#200005"),
                    Fill      = Color3.fromHex("#200005"),
                },
                Slider = {
                    Fill  = main,
                    Empty = Color3.fromHex("#200005"),
                },
                Button = {
                    FillPrimary = ColorSequence.new({
                        ColorSequenceKeypoint.new(0,   glow),
                        ColorSequenceKeypoint.new(0.5, main),
                        ColorSequenceKeypoint.new(1,   dark),
                    }),
                },
            }
            if withBackground then
                set.Background = bg
                set.View       = view
                set.Sidebar    = sidebar
                set.Titlebar   = title
                set.MenuButton = { MenuBackground = menu }
            end
            return set
        end

        return {
            _id   = "Crimson",
            Dark  = buildSet(true),
            Light = buildSet(false),   
        }
    end

    local ultimateRed = DeepCrimson("#FF1E3C", "#FF4D66", "#8F0018")
    Cascade.Accents.Red     = ultimateRed
    Cascade.Accents.Crimson = ultimateRed
    Cascade.Accents.Blood   = ultimateRed

    if not table.find(AccentOrder, "Blood") then
        table.insert(AccentOrder, "Blood")
    end
end
end
local function StyleDropdown(btn)
    pcall(function()
        local indicator = btn.__instance:FindFirstChild("PullDownIndicator")
        local img = indicator and indicator:FindFirstChild("Indicators")
        if img then
            img.Image = "rbxassetid://115187614425058"
            img.ImageColor3 = Color3.fromRGB(255, 255, 255)
            img.Size = UDim2.fromOffset(18, 18)
            img.Position = UDim2.fromScale(0.5, 0.5)
            img.AnchorPoint = Vector2.new(0.5, 0.5)
        end
    end)
end
local function CopyText(text)
    pcall(function()
        if setclipboard then setclipboard(text)
        elseif toclipboard then toclipboard(text)
        elseif syn and syn.write_clipboard then syn.write_clipboard(text)
        elseif Clipboard and Clipboard.set then Clipboard.set(text) end
    end)
end
local RedFlatTheme = {
    Background = Color3.fromHex("#080001"),
    View       = Color3.fromHex("#0D0003"),
    Sidebar    = Color3.fromHex("#0A0002"),
    Titlebar   = Color3.fromHex("#1C0005"),
    MenuButton = { MenuBackground = Color3.fromHex("#100003") },
}

local App = Cascade.New({
    Name = "Smooth Hub AOTR",
    WindowPill = true,
    Theme = Cascade.Themes.Dark,   -- GIỮ NGUYÊN DÒNG NÀY
Accent = (table.find(AccentOrder, SavedUi.Theme) and Cascade.Accents[SavedUi.Theme]) or Cascade.Accents[ConfigStore.DEFAULT_LOOK.Theme] or Cascade.Accents.Pink,
})
AppRef = App

pcall(function()
    App.Accent = Cascade.Accents.Red
end)
local WindowSize = UDim2.fromOffset(850, 530)
pcall(function()
    local cam = workspace.CurrentCamera
    if cam then
        local vp = cam.ViewportSize
        WindowSize = UDim2.fromOffset(math.clamp(vp.X - 30, 320, 850), math.clamp(vp.Y - 30, 240, 530))
    end
end)
local Window = App:Window({
    Title = "Attack on Titan Revolution",
    Subtitle = "Smooth Hub | Version 11.5",
    Size = WindowSize,
    Resizable = true,
    Draggable = true,
    UIBlur = true
})
UiSync.Defaults.UIBlur = false
UiSync.Defaults.Dropshadow = Window.Dropshadow
-- [smooth] Auto Hide Menu: hide right away from the saved setting, don't wait for the whole script to load
SH.MenuTouched = false
SH.MenuEarlyHidden = false
do
    local hub = type(SavedData) == "table" and SavedData.Hub
    if type(hub) == "table" and hub.AutoHideMenu == true then
        local ok = pcall(function() Window.Minimized = true end)
        SH.MenuEarlyHidden = ok
    end
end
pcall(function() Window.Maximized = false end) -- เริ่มที่ขนาดปกติเสมอ (กันหน้าต่างเต็มจอค้างหลังรีโหลด)
task.delay(4, function() -- กันหน้าต่างค้างเต็มจอหลังโหลดธีมเสร็จ
    pcall(function() if Window.Maximized then Window.Maximized = false end end)
end)
local MenuCategory = Cascade.Components.Section(Window, {
    Title = "Menu",
    Disclosure = false
})
local CharTab = MenuCategory:Tab({
    Title = "Menu Lobby",
    Icon = Icon("houseDoorFill", "houseFill", "personCircleFill"),
})
local StatusSection = CharTab:PageSection({
    Title = "📋 Status",
    Subtitle = IN_MENU and "You are in the menu place." or "Not in the menu place - menu features are idle."
})
local StatusForm = StatusSection:Form()
local StatusRow = StatusForm:Row()
StatusRow:Left():TitleStack({ Title = "Status", Subtitle = "What the script is doing right now." })
local StatusLabel = StatusRow:Right():Label({ Text = IN_MENU and "Idle" or "N/A" })
local function SetStatus(text)
    pcall(function() StatusLabel.Text = tostring(text) end)
end
local SLOT_LETTERS = { "A", "B", "C" }
local SlotOptions = { "Slot A", "Slot B", "Slot C" }
local function TextOf(o)
    local t = o.Text or ""
    t = t:gsub("<[^>]->", "")
    t = t:gsub("^%s+", ""):gsub("%s+$", "")
    return t:upper()
end
local function IsTextObj(o)
    return o:IsA("TextLabel") or o:IsA("TextButton")
end
local function IsShown(obj)
    local cur = obj
    while cur and cur ~= PlayerGui do
        if cur:IsA("GuiObject") and not cur.Visible then return false end
        if cur:IsA("ScreenGui") and not cur.Enabled then return false end
        cur = cur.Parent
    end
    return obj:IsA("GuiObject") and obj.AbsoluteSize.X > 0 and obj.AbsoluteSize.Y > 0
end
local function ToButton(o)
    if o:IsA("GuiButton") then return o end
    local cur = o.Parent
    for _ = 1, 3 do
        if not cur then break end
        if cur:IsA("GuiButton") then return cur end
        cur = cur.Parent
    end
    local p = o.Parent
    if p then return p:FindFirstChildWhichIsA("GuiButton", true) end
    return nil
end
local function FindSelectIn(container)
    for _, d in ipairs(container:GetDescendants()) do
        if IsTextObj(d) and TextOf(d) == "SELECT" and IsShown(d) then
            local b = ToButton(d)
            if b then return b end
        end
    end
    return nil
end
local function FindSlotButton(letter)
    local want = "SLOT " .. letter
    for _, d in ipairs(PlayerGui:GetDescendants()) do
        if IsTextObj(d) and TextOf(d) == want and IsShown(d) then
            local cur = d.Parent
            for _ = 1, 6 do
                if not cur or cur == PlayerGui then break end
                local btn = FindSelectIn(cur)
                if btn then return btn end
                cur = cur.Parent
            end
        end
    end
    return nil
end
local function SlotScreenVisible()
    for _, d in ipairs(PlayerGui:GetDescendants()) do
        if IsTextObj(d) and TextOf(d) == "SLOT A" and IsShown(d) then return true end
    end
    return false
end
local function ActivateButton(btn)
    pcall(function() GuiService.SelectedObject = btn end)
    task.wait(0.15)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
    end)
    task.wait(1.0)
    if btn.Parent and IsShown(btn) then
        pcall(function()
            if type(firesignal) == "function" then
                firesignal(btn.MouseButton1Click)
                firesignal(btn.Activated)
            end
        end)
    end
    pcall(function()
        if GuiService.SelectedObject == btn then GuiService.SelectedObject = nil end
    end)
end
local selecting = false
local function SelectCharacter()
    if selecting then return false end
    if not IN_MENU then SetStatus("N/A") return false end
    selecting = true
    local letter = SLOT_LETTERS[Cfg.Slot] or "A"
    local btn = FindSlotButton(letter)
    local result = false
    if btn then
        SetStatus("Selecting Slot " .. letter .. "...")
        ActivateButton(btn)
        SetStatus("Selected Slot " .. letter)
        result = true
    else
        SetStatus("Slot " .. letter .. " UI not found")
    end
    selecting = false
    return result
end
local CharSection = CharTab:PageSection({
    Title = "🎭 Character Selection",
    Subtitle = "Pick one slot. The script presses its SELECT button for you."
})
local CharForm = CharSection:Form()
local SlotRow = CharForm:Row()
SlotRow:Left():TitleStack({ Title = "Slot", Subtitle = "Choose which character slot to use (one at a time)." })
UiSync.Slot = SlotRow:Right():PullDownButton({
    Label = SlotOptions[Cfg.Slot],
    Options = SlotOptions,
    Value = Cfg.Slot,
    ValueChanged = function(self, index)
        if type(index) == "table" then index = index[1] end
        if type(index) ~= "number" or not SlotOptions[index] then return end
        Cfg.Slot = index
        self.Label = SlotOptions[index]
        Save()
    end
})
UiSync.Add(function()
    local i = SlotOptions[Cfg.Slot] and Cfg.Slot or 1
    UiSync.Slot.Value = i
    UiSync.Slot.Label = SlotOptions[i]
end)
local AutoSelRow = CharForm:Row()
AutoSelRow:Left():TitleStack({
    Title = "Select Character",
    Subtitle = "Automatically press SELECT on the chosen slot when the screen shows up."
})
UiSync.Link(AutoSelRow:Right():Toggle({
    Value = Cfg.AutoSelect,
    ValueChanged = function(self, value)
        Cfg.AutoSelect = value and true or false
        Save()
    end
}), Cfg, "AutoSelect")
local SelNowRow = CharForm:Row()
SelNowRow:Left():TitleStack({ Title = "Select Now", Subtitle = "Press SELECT on the chosen slot once." })
local SelNowBtn = SelNowRow:Right():Button({
    Label = "Select",
    Callback = function() end
})
BindButton(SelNowBtn, SelectCharacter)
local function GetLobbyRemote()
    local ok, remote = pcall(function()
        local assets = ReplicatedStorage:WaitForChild("Assets", 5)
        local remotes = assets and assets:WaitForChild("Remotes", 5)
        return remotes and remotes:WaitForChild("GET", 5)
    end)
    return ok and remote or nil
end
local cachedRemote = nil
local lastRequestAt = 0
local function JoinLobby()
    if not IN_MENU then SetStatus("N/A") return end
    if os.clock() - lastRequestAt < 3 then return end
    lastRequestAt = os.clock()
    task.spawn(function()
        local remote = cachedRemote
        if not remote or not remote.Parent then
            remote = GetLobbyRemote()
            cachedRemote = remote
        end
        if not remote then SetStatus("Lobby remote not found") return end
        SetStatus("Joining lobby...")
        local ok, err = pcall(function()
            return remote:InvokeServer("Functions", "Teleport", "Lobby", nil)
        end)
        SetStatus(ok and "Join request sent" or ("Join failed: " .. tostring(err)))
    end)
end
local JoinSection = CharTab:PageSection({
    Title = "🚪 Auto Join Lobby",
    Subtitle = "Repeatedly requests the lobby. Delay is " .. MIN_DELAY .. " - " .. MAX_DELAY .. " seconds."
})
local JoinForm = JoinSection:Form()
local AutoJoinRow = JoinForm:Row()
AutoJoinRow:Left():TitleStack({
    Title = "Auto Join Lobby",
    Subtitle = "Send the join-lobby request every Join Delay seconds."
})
UiSync.Link(AutoJoinRow:Right():Toggle({
    Value = Cfg.AutoJoin,
    ValueChanged = function(self, value)
        Cfg.AutoJoin = value and true or false
        Save()
    end
}), Cfg, "AutoJoin")
local DelayRow = JoinForm:Row()
DelayRow:Left():TitleStack({
    Title = "Join Delay",
    Subtitle = "Seconds between requests (" .. MIN_DELAY .. " - " .. MAX_DELAY .. "). Minimum is " .. MIN_DELAY .. "s so it can't spam by accident."
})
local DelayRight = DelayRow:Right()
local DelayLabel = DelayRight:Label({ Text = Cfg.JoinDelay .. "s" })
UiSync.Link(DelayRight:Slider({
    Minimum = MIN_DELAY,
    Maximum = MAX_DELAY,
    Value = Cfg.JoinDelay,
    ValueChanged = function(self, value)
        Cfg.JoinDelay = ClampDelay(value)
        pcall(function() DelayLabel.Text = Cfg.JoinDelay .. "s" end)
        Save()
    end
}), Cfg, "JoinDelay", function(_, want)
    pcall(function() DelayLabel.Text = want .. "s" end)
end)
local CountdownRow = JoinForm:Row()
CountdownRow:Left():TitleStack({
    Title = "Next Join",
    Subtitle = "Countdown until the next join-lobby request."
})
local CountdownLabel = CountdownRow:Right():Label({ Text = "Off" })
local lastCountdownText = nil
local function SetCountdown(text)
    if text == lastCountdownText then return end
    lastCountdownText = text
    pcall(function() CountdownLabel.Text = text end)
end
local JoinNowRow = JoinForm:Row()
JoinNowRow:Left():TitleStack({ Title = "Join Now", Subtitle = "Send the join-lobby request once." })
local JoinNowBtn = JoinNowRow:Right():Button({
    Label = "Join",
    Callback = function() end
})
BindButton(JoinNowBtn, JoinLobby)
do
    local RANK = { COMMON = 1, UNCOMMON = 2, RARE = 3, EPIC = 4, LEGENDARY = 5, MYTHIC = 6, SECRET = 7, EXCLUSIVE = 8 }
    local STOP_OPTIONS = { "Rare", "Epic", "Legendary", "Mythic", "Off" }
    if not table.find(STOP_OPTIONS, Cfg.SpinStopRarity) then Cfg.SpinStopRarity = "Epic" end
    local KEEP_ACTIONS = { "Stop", "Store", "Ask" }
    local KEEP_LABELS = { "Stop spinning", "Store & keep spinning", "Ask me" }
    if not table.find(KEEP_ACTIONS, Cfg.SpinOnKeep) then Cfg.SpinOnKeep = "Stop" end
    local FAMILY_RARITY = {
        HELOS = "MYTHIC", FRITZ = "MYTHIC",
        YEAGER = "LEGENDARY", ACKERMAN = "LEGENDARY", REISS = "LEGENDARY",
        GALLIARD = "EPIC", ZOE = "EPIC", LEONHART = "EPIC", TYBUR = "EPIC",
        KSAVER = "EPIC", BRAUN = "EPIC", FINGER = "EPIC", ARLERT = "EPIC",
        BRAUS = "RARE", KRUGER = "RARE", AZUMABITO = "RARE", SMITH = "RARE",
        GRICE = "RARE", SPRINGER = "RARE", KIRSTEIN = "RARE",
    }
    local function Cap(s)
        return (tostring(s):lower():gsub("^%l", string.upper))
    end
    local function Pretty(name)
        return (tostring(name):lower():gsub("(%a)([%w_']*)", function(a, b) return a:upper() .. b end))
    end
    local FAMILY_LIST, FAMILY_LABELS = {}, {}
    for key, rar in pairs(FAMILY_RARITY) do FAMILY_LIST[#FAMILY_LIST + 1] = { key = key, rarity = rar } end
    table.sort(FAMILY_LIST, function(a, b)
        if RANK[a.rarity] ~= RANK[b.rarity] then return RANK[a.rarity] > RANK[b.rarity] end
        return a.key < b.key
    end)
    for i, f in ipairs(FAMILY_LIST) do FAMILY_LABELS[i] = Pretty(f.key) .. " (" .. Cap(f.rarity) .. ")" end
    local rulesSrc, rulesCache = nil, {}
    local function Rules()
        if rulesSrc ~= Cfg.SpinFamilyRules then
            rulesSrc = Cfg.SpinFamilyRules
            rulesCache = {}
            for key, rule in tostring(rulesSrc):gmatch("([^=;]+)=(%a+)") do
                if rule == "Keep" or rule == "Skip" or rule == "Ask" then rulesCache[key:upper()] = rule end
            end
        end
        return rulesCache
    end
    local function WriteRules(map)
        local parts = {}
        for k, v in pairs(map) do parts[#parts + 1] = k .. "=" .. v end
        table.sort(parts)
        Cfg.SpinFamilyRules = table.concat(parts, ";")
        Save()
    end
    local function SetRule(name, rule)
        local copy = {}
        for k, v in pairs(Rules()) do copy[k] = v end
        copy[tostring(name):upper()] = rule
        WriteRules(copy)
    end
    local function RulesSummary()
        local keep, skip, ask = {}, {}, {}
        for key, rule in pairs(Rules()) do
            local list = (rule == "Keep" and keep) or (rule == "Skip" and skip) or ask
            list[#list + 1] = Pretty(key)
        end
        local function J(l)
            table.sort(l)
            return #l > 0 and table.concat(l, ", ") or "-"
        end
        return ("Always keep: %s | Never keep: %s | Always ask: %s"):format(J(keep), J(skip), J(ask))
    end
    local function Decide(name, rarity)
        local rule = Rules()[tostring(name):upper()]
        if rule == "Skip" then return "roll" end
        if rule == "Ask" then return "ask" end
        local stopRank = Cfg.SpinStopRarity == "Off" and math.huge or (RANK[Cfg.SpinStopRarity:upper()] or RANK.EPIC)
        local keeper = rule == "Keep" or (RANK[tostring(rarity):upper()] or 0) >= stopRank
        if not keeper then return "roll" end
        if Cfg.SpinOnKeep == "Store" then return "store" end
        if Cfg.SpinOnKeep == "Ask" then return "ask" end
        return "stop"
    end
    SH.Spin = SH.Spin or {}
    SH.Spin.Decide = Decide
    SH.Spin.SetRule = SetRule
    local SpinForm = CharTab:PageSection({
        Title = "🎰 Roll Family",
        Subtitle = "Auto roll your family."
    }):Form()
    local RuleForm = CharTab:PageSection({
        Title = "⚙️ Settings Roll",
        Subtitle = "Choose which families to keep."
    }):Form()
    local ShowForm = CharTab:PageSection({
        Title = "📜 Show Roll",
        Subtitle = "Your roll history."
    }):Form()
    local spinToggle
    local spinRow = SpinForm:Row()
    spinRow:Left():TitleStack({
        Title = "Auto Spin [ Lucky999+ ]",
        Subtitle = "Keeps pressing ROLL for you."
    })
    spinToggle = UiSync.Link(spinRow:Right():Toggle({
        Value = Cfg.AutoSpin,
        ValueChanged = function(self, value)
            Cfg.AutoSpin = value and true or false
            Save()
        end
    }), Cfg, "AutoSpin")
    local statusRow = SpinForm:Row()
    statusRow:Left():TitleStack({ Title = "Spin Status", Subtitle = "What Auto Spin is doing now." })
    local statusLabel = statusRow:Right():Label({ Text = "Off" })
    local lastStatus = nil
    local function Status(text)
        text = tostring(text)
        if text == lastStatus then return end
        lastStatus = text
        pcall(function() statusLabel.Text = text end)
    end
    local lastRow = SpinForm:Row()
    local lastStack = lastRow:Left():TitleStack({ Title = "Last Roll", Subtitle = "No rolls yet." })
    local lastLabel = lastRow:Right():Label({ Text = "-" })
    local stopRow = RuleForm:Row()
    stopRow:Left():TitleStack({
        Title = "Keep Rarity",
        Subtitle = "Keep this rarity or higher. Off = never stop for rarity."
    })
    local function StopIndex()
        return table.find(STOP_OPTIONS, Cfg.SpinStopRarity) or 2
    end
    local stopDrop = stopRow:Right():PullDownButton({
        Label = STOP_OPTIONS[StopIndex()],
        Options = STOP_OPTIONS,
        Value = StopIndex(),
        ValueChanged = function(self, index)
            if type(index) == "table" then index = index[1] end
            if type(index) ~= "number" or not STOP_OPTIONS[index] then return end
            Cfg.SpinStopRarity = STOP_OPTIONS[index]
            self.Label = STOP_OPTIONS[index]
            Save()
        end
    })
    UiSync.Add(function()
        local i = StopIndex()
        stopDrop.Value = i
        stopDrop.Label = STOP_OPTIONS[i]
    end)
    local keepRow = RuleForm:Row()
    keepRow:Left():TitleStack({
        Title = "When I Get A Keeper",
        Subtitle = "Stop, store it and keep rolling, or ask me."
    })
    local function KeepIndex()
        return table.find(KEEP_ACTIONS, Cfg.SpinOnKeep) or 1
    end
    local keepDrop = keepRow:Right():PullDownButton({
        Label = KEEP_LABELS[KeepIndex()],
        Options = KEEP_LABELS,
        Value = KeepIndex(),
        ValueChanged = function(self, index)
            if type(index) == "table" then index = index[1] end
            if type(index) ~= "number" or not KEEP_ACTIONS[index] then return end
            Cfg.SpinOnKeep = KEEP_ACTIONS[index]
            self.Label = KEEP_LABELS[index]
            Save()
        end
    })
    local rulePickers, syncingRules, rulesStack = {}, false, nil
    local function PickedIndexes(rule)
        local picked = {}
        for i, f in ipairs(FAMILY_LIST) do
            if Rules()[f.key] == rule then picked[#picked + 1] = i end
        end
        return picked
    end
    local function RefreshRulePickers()
        if rulesStack then pcall(function() rulesStack.Subtitle = RulesSummary() end) end
        syncingRules = true
        for rule, p in pairs(rulePickers) do
            if p.multi then pcall(function() p.btn.Value = PickedIndexes(rule) end) end
        end
        syncingRules = false
    end
    local function ApplyPicked(rule, indexes)
        local picked = {}
        for _, i in ipairs(SettingsStore.ValidIndexes(indexes, #FAMILY_LIST)) do picked[FAMILY_LIST[i].key] = true end
        local copy = {}
        for k, v in pairs(Rules()) do copy[k] = v end
        for _, f in ipairs(FAMILY_LIST) do
            if picked[f.key] then
                copy[f.key] = rule
            elseif copy[f.key] == rule then
                copy[f.key] = nil
            end
        end
        WriteRules(copy)
        RefreshRulePickers()
    end
    local function AddRulePicker(title, subtitle, rule)
        local row = RuleForm:Row()
        row:Left():TitleStack({ Title = title, Subtitle = subtitle })
        local ok, btn = pcall(function()
            return row:Right():PopUpButton({
                Options = FAMILY_LABELS,
                Maximum = #FAMILY_LABELS,
                Value = PickedIndexes(rule),
                ValueChanged = function(self, value)
                    if syncingRules then return end
                    ApplyPicked(rule, type(value) == "table" and value or { value })
                end
            })
        end)
        if ok and btn then
            rulePickers[rule] = { btn = btn, multi = true }
        else
            btn = row:Right():PullDownButton({
                Label = "Tap a family to add / remove",
                Options = FAMILY_LABELS,
                Value = 1,
                ValueChanged = function(self, index)
                    if syncingRules then return end
                    if type(index) == "table" then index = index[1] end
                    if type(index) ~= "number" or not FAMILY_LIST[index] then return end
                    local picked = PickedIndexes(rule)
                    local at = table.find(picked, index)
                    if at then table.remove(picked, at) else picked[#picked + 1] = index end
                    ApplyPicked(rule, picked)
                    self.Label = (at and "Removed " or "Added ") .. FAMILY_LABELS[index]
                end
            })
            rulePickers[rule] = { btn = btn, multi = false }
        end
        StyleDropdown(btn)
    end
    AddRulePicker("Always Keep Families",
        "Always keep these, even below Keep Rarity.", "Keep")
    AddRulePicker("Always Ask Families",
        "Ask me every time these roll.", "Ask")
    AddRulePicker("Never Keep Families",
        "Never keep these, even above Keep Rarity.", "Skip")
    local rulesRow = RuleForm:Row()
    rulesStack = rulesRow:Left():TitleStack({ Title = "Saved Rules", Subtitle = RulesSummary() })
    UiSync.Add(function()
        local i = KeepIndex()
        keepDrop.Value = i
        keepDrop.Label = KEEP_LABELS[i]
        RefreshRulePickers()
    end)
    local useDelayRow = SpinForm:Row()
    useDelayRow:Left():TitleStack({
        Title = "Use Spin Delay",
        Subtitle = "On: wait after every roll. Off: go on as soon as the result shows."
    })
    UiSync.Link(useDelayRow:Right():Toggle({
        Value = Cfg.SpinUseDelay ~= false,
        ValueChanged = function(self, value)
            Cfg.SpinUseDelay = value and true or false
            Save()
        end
    }), Cfg, "SpinUseDelay")
    local delayRow = SpinForm:Row()
    delayRow:Left():TitleStack({
        Title = "Spin Delay",
        Subtitle = "Seconds to wait after each roll (0.5 - 10)."
    })
    local delayRight = delayRow:Right()
    local delayLabel = delayRight:Label({ Text = Cfg.SpinDelay .. "s" })
    UiSync.Link(delayRight:Slider({
        Minimum = 0.5,
        Maximum = 10,
        Value = Cfg.SpinDelay,
        ValueChanged = function(self, value)
            Cfg.SpinDelay = math.clamp(math.floor((tonumber(value) or 3) * 2 + 0.5) / 2, 0.5, 10)
            pcall(function() delayLabel.Text = Cfg.SpinDelay .. "s" end)
            Save()
        end
    }), Cfg, "SpinDelay", function(_, want)
        pcall(function() delayLabel.Text = want .. "s" end)
    end)
    local history, stats = {}, { rolls = 0, byRarity = {} }
    SH.Spin.History = history
    local RARITY_ORDER = { "EXCLUSIVE", "SECRET", "MYTHIC", "LEGENDARY", "EPIC", "UNCOMMON", "RARE", "COMMON" }
    local RefreshList = function() end
    local showListRow = ShowForm:Row()
    showListRow:Left():TitleStack({
        Title = "Show Rolled Families",
        Subtitle = "Show or hide the list."
    })
    UiSync.Link(showListRow:Right():Toggle({
        Value = Cfg.SpinShowList == true,
        ValueChanged = function(self, value)
            Cfg.SpinShowList = value and true or false
            Save()
            RefreshList()
        end
    }), Cfg, "SpinShowList", function() RefreshList() end)
    local sizeRow = ShowForm:Row()
    sizeRow:Left():TitleStack({
        Title = "List Size",
        Subtitle = "Recent rolls to show (5 - 100)."
    })
    local sizeRight = sizeRow:Right()
    local sizeLabel = sizeRight:Label({ Text = tostring(Cfg.SpinListSize) })
    UiSync.Link(sizeRight:Slider({
        Minimum = 5,
        Maximum = 100,
        Value = Cfg.SpinListSize,
        ValueChanged = function(self, value)
            Cfg.SpinListSize = math.clamp(math.floor((tonumber(value) or 15) + 0.5), 5, 100)
            pcall(function() sizeLabel.Text = tostring(Cfg.SpinListSize) end)
            Save()
            RefreshList()
        end
    }), Cfg, "SpinListSize", function(_, want)
        pcall(function() sizeLabel.Text = tostring(want) end)
        RefreshList()
    end)
    local listRow = ShowForm:Row()
    local listStack = listRow:Left():TitleStack({ Title = "Rolled Families", Subtitle = "Nothing rolled yet." })
    local function ListText()
        local lines = {}
        for i = #history, math.max(1, #history - (math.clamp(tonumber(Cfg.SpinListSize) or 15, 5, 100) - 1)), -1 do
            local e = history[i]
            lines[#lines + 1] = (e.n == 0 and "Start" or ("#" .. e.n)) .. "   " .. e.name .. " (" .. e.rarity .. ")"
        end
        return #lines > 0 and table.concat(lines, "\n") or "Nothing rolled yet."
    end
    local function SummaryText()
        local parts = {}
        for _, r in ipairs(RARITY_ORDER) do
            local n = stats.byRarity[r]
            if n and n > 0 then parts[#parts + 1] = Cap(r) .. " " .. n end
        end
        return ("%d rolls%s"):format(stats.rolls, #parts > 0 and (" | " .. table.concat(parts, " · ")) or "")
    end
    RefreshList = function()
        pcall(function()
            if Cfg.SpinShowList then
                listStack.Subtitle = ListText()
            elseif #history > 0 then
                listStack.Subtitle = "Hidden | " .. SummaryText()
            else
                listStack.Subtitle = "Hidden. Turn on 'Show Rolled Families'."
            end
        end)
    end
    RefreshList()
    local function LogResult(name, rarity, isStart)
        if not isStart then
            stats.rolls += 1
            stats.byRarity[rarity] = (stats.byRarity[rarity] or 0) + 1
        end
        local stamp = ""
        pcall(function() stamp = os.date("%H:%M:%S") end)
        local entry = { n = isStart and 0 or stats.rolls, name = Pretty(name), rarity = Cap(rarity), time = stamp }
        history[#history + 1] = entry
        if #history > 300 then table.remove(history, 1) end
        SH.dbg(("[SmoothHub] Spin %s: %s (%s)"):format(isStart and "(start)" or ("#" .. entry.n), entry.name, entry.rarity))
        pcall(function()
            lastLabel.Text = entry.name .. " (" .. entry.rarity .. ")"
            lastStack.Subtitle = (isStart and "Current family when you started" or ("Roll #" .. entry.n)) .. " | " .. SummaryText()
        end)
        RefreshList()
    end
    local function HistoryText()
        local lines = {}
        for _, e in ipairs(history) do
            lines[#lines + 1] = ("%s  %s  %s (%s)"):format(e.n == 0 and "start" or ("#" .. e.n), e.time, e.name, e.rarity)
        end
        lines[#lines + 1] = "--- " .. SummaryText()
        return table.concat(lines, "\n")
    end
    function SH.Spin.PrintHistory() SH.dbg(HistoryText()) end
    function SH.Spin.Clear()
        for i = #history, 1, -1 do history[i] = nil end
        stats.rolls, stats.byRarity = 0, {}
        pcall(function() lastLabel.Text = "-" lastStack.Subtitle = "No rolls yet." end)
        RefreshList()
    end
    local copyRow = ShowForm:Row()
    copyRow:Left():TitleStack({ Title = "Spin Log", Subtitle = "Copy all rolls to the clipboard." })
    local copyBtn = copyRow:Right():Button({ Label = "Copy", Callback = function() end })
    BindButton(copyBtn, function()
        local text = HistoryText()
        pcall(function()
            if type(setclipboard) == "function" then setclipboard(text) elseif type(toclipboard) == "function" then toclipboard(text) end
        end)
        SH.dbg(text)
    end)
    local rollObj, rollScanAt = nil, 0
    local function FindRoll()
        if rollObj and rollObj.Parent and IsShown(rollObj) then return rollObj end
        rollObj = nil
        if os.clock() - rollScanAt < 1 then return nil end
        rollScanAt = os.clock()
        local n = 0
        for _, d in ipairs(PlayerGui:GetDescendants()) do
            n += 1
            if n % 800 == 0 then task.wait() end
            if IsTextObj(d) and TextOf(d):match("^ROLL") and IsShown(d) then
                rollObj = d
                return d
            end
        end
        return nil
    end
    local function RollCount(obj)
        return tonumber(TextOf(obj):match("%((%d+)%)"))
    end
    local famObj, famScanAt = nil, 0
    local function ParseFamily(o)
        local name, rarity = TextOf(o):match("^(.-)%s*%((%a+)%)$")
        if name and RANK[rarity] then return name, rarity end
        return nil
    end
    local function ReadFamily()
        if famObj and famObj.Parent and IsShown(famObj) then
            local n, r = ParseFamily(famObj)
            if n then return n, r end
        end
        famObj = nil
        if os.clock() - famScanAt < 0.4 then return nil end
        famScanAt = os.clock()
        local n = 0
        for _, d in ipairs(PlayerGui:GetDescendants()) do
            n += 1
            if n % 800 == 0 then task.wait() end
            if IsTextObj(d) and IsShown(d) then
                local name, rarity = ParseFamily(d)
                if name then
                    famObj = d
                    return name, rarity
                end
            end
        end
        return nil
    end
    local function WaitForNewFamily(nameBefore, rarityBefore, maxWait)
        local t0 = os.clock()
        local seenKey, seenAt = nil, 0
        while os.clock() - t0 < maxWait do
            if not Alive() or not Cfg.AutoSpin then return false end
            local n, r = ReadFamily()
            if n and (n ~= nameBefore or r ~= rarityBefore) then
                local key = n .. "|" .. r
                if key ~= seenKey then
                    seenKey, seenAt = key, os.clock()
                elseif os.clock() - seenAt >= 0.3 then
                    return true
                end
            else
                seenKey = nil
            end
            task.wait(0.05)
        end
        return false
    end
    task.spawn(function()
        local lastKey, scanAt, hinted = nil, 0, false
        while Alive() do
            task.wait(0.15)
            local n, r
            if famObj and famObj.Parent and IsShown(famObj) then
                n, r = ParseFamily(famObj)
            elseif IN_MENU and os.clock() - scanAt >= 3 then
                scanAt = os.clock()
                n, r = ReadFamily()
            end
            if n then
                hinted = false
                local key = n .. "|" .. r
                if key ~= lastKey then
                    lastKey = key
                    pcall(function()
                        lastLabel.Text = Pretty(n) .. " (" .. Cap(r) .. ")"
                        lastStack.Subtitle = "Live - your current family | " .. SummaryText()
                    end)
                end
            elseif not hinted and lastKey == nil and #history == 0 then
                hinted = true
                pcall(function() lastStack.Subtitle = "Open the Family page to see your current family live." end)
            end
        end
    end)
    local pressPref = 1
    local PRESS_METHODS = {
        { name = "Enter", run = function(btn)
            pcall(function() GuiService.SelectedObject = btn end)
            task.wait(0.1)
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
            end)
            return true
        end },
        { name = "Activated signal", run = function(btn)
            if type(firesignal) ~= "function" then return false end
            return (pcall(firesignal, btn.Activated))
        end },
        { name = "Click signal", run = function(btn)
            if type(firesignal) ~= "function" then return false end
            return (pcall(firesignal, btn.MouseButton1Click))
        end },
        { name = "Mouse click", run = function(btn)
            local gui = btn:FindFirstAncestorOfClass("ScreenGui")
            local inset = (gui and gui.IgnoreGuiInset) and Vector2.zero or GuiService:GetGuiInset()
            local pos = btn.AbsolutePosition + btn.AbsoluteSize / 2 + inset
            return (pcall(function()
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
            end))
        end },
        { name = "Gamepad A", run = function(btn)
            pcall(function() GuiService.SelectedObject = btn end)
            task.wait(0.1)
            return (pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.ButtonA, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.ButtonA, false, game)
            end))
        end },
    }
    local function PressRoll(obj, attempt)
        local btn = ToButton(obj)
        if not btn then return nil end
        local count = #PRESS_METHODS
        for step = 0, count - 1 do
            local idx = ((pressPref - 1 + (attempt or 0) + step) % count) + 1
            local m = PRESS_METHODS[idx]
            if m.run(btn) then return idx, m.name end
        end
        return nil
    end
    local function WaitCountDrop(obj, before, maxWait, nameBefore, rarityBefore)
        local t0 = os.clock()
        while os.clock() - t0 < maxWait do
            if not (obj.Parent) then return true end
            local now = RollCount(obj)
            if now ~= nil and now < before then return true end
            if nameBefore and famObj and famObj.Parent then
                local n, r = ParseFamily(famObj)
                if n and (n ~= nameBefore or r ~= rarityBefore) then return true end
            end
            task.wait(0.1)
        end
        return false
    end
    local function PressButton(btn)
        pcall(function() GuiService.SelectedObject = btn end)
        task.wait(0.1)
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
        end)
    end
    local function FindShownButton(match)
        local n = 0
        for _, d in ipairs(PlayerGui:GetDescendants()) do
            n += 1
            if n % 800 == 0 then task.wait() end
            if d:IsA("GuiButton") and IsShown(d) and match(d) then return d end
        end
        return nil
    end
    local function FindBottomIcon()
        local cam = workspace.CurrentCamera
        local vp = cam and cam.ViewportSize or Vector2.new(1920, 1080)
        local cands, n = {}, 0
        for _, d in ipairs(PlayerGui:GetDescendants()) do
            n += 1
            if n % 800 == 0 then task.wait() end
            if d:IsA("GuiButton") and IsShown(d) then
                local s = d.AbsoluteSize
                if s.X >= 40 and s.X <= 220 and s.Y >= 40 and s.Y <= 220 and math.abs(s.X / s.Y - 1) <= 0.2 then
                    local c = d.AbsolutePosition + s / 2
                    if c.X < vp.X * 0.3 then cands[#cands + 1] = { btn = d, y = c.Y } end
                end
            end
        end
        if #cands < 4 then return nil end
        table.sort(cands, function(a, b) return a.y > b.y end)
        return cands[1].btn
    end
    local function ClickableFor(o)
        if o:IsA("GuiButton") then return o end
        local cur = o.Parent
        for _ = 1, 3 do
            if not cur or cur == PlayerGui then break end
            if cur:IsA("GuiButton") then return cur end
            cur = cur.Parent
        end
        local c = o.AbsolutePosition + o.AbsoluteSize / 2
        local best, bestArea = nil, math.huge
        for _, d in ipairs(PlayerGui:GetDescendants()) do
            if d:IsA("GuiButton") and IsShown(d) then
                local pos, size = d.AbsolutePosition, d.AbsoluteSize
                if c.X >= pos.X and c.X <= pos.X + size.X and c.Y >= pos.Y and c.Y <= pos.Y + size.Y then
                    local area = size.X * size.Y
                    if area < bestArea then best, bestArea = d, area end
                end
            end
        end
        return best
    end
    local function FindMainMenuCustomize()
        local custObj, hasPlay, hasCodes = nil, false, false
        local n = 0
        for _, d in ipairs(PlayerGui:GetDescendants()) do
            n += 1
            if n % 800 == 0 then task.wait() end
            if IsTextObj(d) and IsShown(d) then
                local t = TextOf(d)
                if t == "CUSTOMIZATION" then custObj = d
                elseif t == "PLAY" then hasPlay = true
                elseif t == "CODES" then hasCodes = true end
            end
        end
        if custObj and hasPlay and hasCodes then return ClickableFor(custObj) end
        return nil
    end
    local navAt, navTries = 0, 0
    local function OpenFamilyPage()
        if os.clock() - navAt < 2.5 then return end
        navAt = os.clock()
        if navTries >= 8 then
            Status("Couldn't open the Family page - open it once yourself")
            return
        end
        local famBtn = FindShownButton(function(d)
            if not d.Name:lower():find("family", 1, true) then return false end
            local t = d:IsA("TextButton") and TextOf(d) or ""
            return not t:find("X2", 1, true) and t ~= "BACK"
        end)
        if famBtn then
            navTries += 1
            Status("Opening the Family page...")
            PressButton(famBtn)
            return
        end
        local iconBtn = FindBottomIcon()
        if iconBtn then
            navTries += 1
            Status("Opening the Family page (F icon)...")
            PressButton(iconBtn)
            return
        end
        local custBtn = FindMainMenuCustomize()
        if custBtn then
            navTries += 1
            Status("Opening Customization...")
            PressButton(custBtn)
            return
        end
        Status("Open the Family page (menu buttons not found)")
    end
    SH.Spin = SH.Spin or {}
    function SH.Spin.DumpButtons()
        local lines = { "=== visible buttons (path | class | text | image) ===" }
        for _, d in ipairs(PlayerGui:GetDescendants()) do
            if d:IsA("GuiButton") and IsShown(d) then
                local path = d:GetFullName():gsub("^Players%.[^%.]+%.PlayerGui%.", "")
                local t = d:IsA("TextButton") and (d.Text or "") or ""
                local img = d:IsA("ImageButton") and tostring(d.Image) or ""
                lines[#lines + 1] = path .. " | " .. d.ClassName .. " | " .. t .. " | " .. img
            end
        end
        local text = table.concat(lines, "\n")
        pcall(function()
            if type(setclipboard) == "function" then setclipboard(text) elseif type(toclipboard) == "function" then toclipboard(text) end
        end)
        pcall(function() if type(writefile) == "function" then writefile("SmoothHub_buttons.txt", text) end end)
        SH.dbg(text)
        return #lines - 1
    end
    local function Notify(text)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Smooth Hub - Auto Spin", Text = text, Duration = 8,
            })
        end)
    end
    local getRemote = nil
    local function InvokeGet(...)
        if not getRemote or not getRemote.Parent then getRemote = GetLobbyRemote() end
        if not getRemote then return false, "remote not found" end
        local remote, args = getRemote, table.pack(...)
        local done, ok, res = false, false, nil
        task.spawn(function()
            ok, res = pcall(function() return remote:InvokeServer(table.unpack(args, 1, args.n)) end)
            done = true
        end)
        local t0 = os.clock()
        while not done and os.clock() - t0 < 8 do task.wait(0.05) end
        if not done then return false, "timeout" end
        return ok, res
    end
    local function StoreCurrent(name, rarity)
        Status(("Storing %s..."):format(Pretty(name)))
        local ok, res = InvokeGet("Family", "Store")
        SH.dbg("[SmoothHub] Auto Spin: Store ->", ok, res)
        if not ok then return false, tostring(res) end
        local t0 = os.clock()
        while os.clock() - t0 < 4 do
            task.wait(0.4)
            if not Alive() or not Cfg.AutoSpin then return false, "stopped" end
            local n2, r2 = ReadFamily()
            if n2 == nil or n2 ~= name or r2 ~= rarity then return true end
        end
        return false, "your family didn't change after Store"
    end
    local function AskUser(name, rarity)
        local gui = Instance.new("ScreenGui")
        gui.Name = "SmoothHubSpinAsk"
        gui.ResetOnSpawn = false
        gui.DisplayOrder = 10000
        gui.IgnoreGuiInset = true
        local parented = false
        for _, getParent in ipairs({
            function() return type(gethui) == "function" and gethui() or nil end,
            function() return game:GetService("CoreGui") end,
            function() return PlayerGui end,
        }) do
            local okP, parent = pcall(getParent)
            if okP and parent and pcall(function() gui.Parent = parent end) and gui.Parent then
                parented = true
                break
            end
        end
        if not parented then gui:Destroy() return nil end
        local frame = Instance.new("Frame")
        frame.AnchorPoint = Vector2.new(0.5, 0.5)
        frame.Position = UDim2.fromScale(0.5, 0.35)
        frame.Size = UDim2.fromOffset(400, 200)
        frame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
        frame.Parent = gui
        local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 12) corner.Parent = frame
        local stroke = Instance.new("UIStroke") stroke.Color = Color3.fromRGB(70, 70, 80) stroke.Thickness = 1 stroke.Parent = frame
        local function Label(text, y, h, size, color, bold)
            local l = Instance.new("TextLabel")
            l.BackgroundTransparency = 1
            l.Position = UDim2.fromOffset(16, y)
            l.Size = UDim2.new(1, -32, 0, h)
            l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
            l.TextSize = size
            l.TextColor3 = color
            l.Text = text
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.Parent = frame
            return l
        end
        Label("You rolled a family", 14, 20, 14, Color3.fromRGB(160, 160, 170), false)
        Label(Pretty(name) .. "  -  " .. Cap(rarity), 36, 34, 24, Color3.fromRGB(255, 255, 255), true)
        Label("Do you want to keep it?", 76, 20, 14, Color3.fromRGB(200, 200, 210), false)
        local choice = nil
        local function Button(text, x, w, color, value)
            local b = Instance.new("TextButton")
            b.Position = UDim2.fromOffset(x, 118)
            b.Size = UDim2.fromOffset(w, 52)
            b.BackgroundColor3 = color
            b.AutoButtonColor = true
            b.Font = Enum.Font.GothamBold
            b.TextSize = 13
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
            b.TextWrapped = true
            b.Text = text
            b.Parent = frame
            local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 8) c.Parent = b
            b.MouseButton1Click:Connect(function() choice = value end)
        end
        Button("Keep it and stop", 16, 116, Color3.fromRGB(46, 125, 80), "stop")
        Button("Store it and keep spinning", 142, 116, Color3.fromRGB(45, 95, 170), "store")
        Button("Discard and roll again", 268, 116, Color3.fromRGB(150, 60, 60), "roll")
        while choice == nil and Alive() and Cfg.AutoSpin do task.wait(0.1) end
        gui:Destroy()
        return choice
    end
    local function StopSpin(message)
        Cfg.AutoSpin = false
        Save()
        pcall(function() spinToggle.Value = false end)
        Status(message)
        SH.dbg("[SmoothHub] Auto Spin:", message)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Smooth Hub - Auto Spin", Text = message, Duration = 10,
            })
        end)
    end
    task.spawn(function()
        local fails = 0
        local pendingLog, startLogged = false, false
        local emptySlotOk, storesSinceRoll = false, 0
        while Alive() do
            task.wait(0.4)
            if not Cfg.AutoSpin then
                fails, pendingLog, startLogged, emptySlotOk, storesSinceRoll = 0, false, false, false, 0
                Status("Off")
            else
                local roll = FindRoll()
                if not roll then
                    OpenFamilyPage()
                else
                    navTries = 0
                    local rolls = RollCount(roll)
                    local name, rarity = ReadFamily()
                    if name then
                        if not startLogged then
                            startLogged = true
                            LogResult(name, rarity, true)
                        elseif pendingLog then
                            pendingLog = false
                            LogResult(name, rarity, false)
                        end
                    end
                    local canRoll = false
                    if not name then
                        if emptySlotOk then
                            canRoll = true
                        else
                            Status("Can't read your current family yet...")
                        end
                    else
                        emptySlotOk = false
                        local label = ("%s (%s)"):format(Pretty(name), Cap(rarity))
                        local action = Decide(name, rarity)
                        if action == "ask" then
                            Status("Waiting for your choice: " .. label)
                            Notify("You rolled " .. label .. " - keep it? Answer in the box on screen.")
                            local choice = AskUser(name, rarity)
                            action = choice or "wait"
                            if choice == nil and Cfg.AutoSpin then
                                StopSpin("Stopped: couldn't show the question box, so you keep " .. label)
                                action = "wait"
                            end
                        end
                        if action == "stop" then
                            StopSpin("Stopped: you have " .. label)
                        elseif action == "store" then
                            if storesSinceRoll >= 2 then
                                StopSpin("Stopped: Store doesn't clear your family slot, so you keep " .. label)
                            else
                                local ok, why = StoreCurrent(name, rarity)
                                if ok then
                                    storesSinceRoll += 1
                                    emptySlotOk = true
                                    SH.dbg("[SmoothHub] Auto Spin: stored " .. label)
                                    Notify("Stored " .. label)
                                elseif why ~= "stopped" then
                                    StopSpin(("Stopped: couldn't store %s (%s)"):format(label, why))
                                end
                            end
                        elseif action == "roll" then
                            canRoll = true
                        end
                    end
                    if canRoll then
                        if rolls ~= nil and rolls <= 0 then
                            StopSpin("Stopped: no rolls left")
                        else
                            Status(("Rolling... (%s left)"):format(rolls ~= nil and tostring(rolls) or "?"))
                            local before = rolls
                            local idx, used = PressRoll(roll, fails)
                            local registered = true
                            if idx == nil then
                                registered, used = false, "no usable press method"
                            elseif before ~= nil then
                                registered = WaitCountDrop(roll, before, 4, name, rarity)
                            end
                            if not registered then
                                fails += 1
                                SH.dbg(("[SmoothHub] Auto Spin: roll didn't register (%d/%d) via %s"):format(fails, #PRESS_METHODS, tostring(used)))
                                Status(("Roll didn't register (%d/%d) via %s"):format(fails, #PRESS_METHODS, tostring(used)))
                                if fails >= #PRESS_METHODS then StopSpin("Stopped: ROLL button doesn't respond (tried every press method)") end
                            else
                                if idx then pressPref = idx end
                                fails = 0
                                pendingLog = true
                                emptySlotOk, storesSinceRoll = false, 0
                                if Cfg.SpinUseDelay ~= false then
                                    for _ = 1, math.floor(Cfg.SpinDelay * 10) do
                                        if not Alive() or not Cfg.AutoSpin then break end
                                        task.wait(0.1)
                                    end
                                else
                                    WaitForNewFamily(name, rarity, 2.5)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end
local ReplicatedStorageSvc = game:GetService("ReplicatedStorage")
local StatusCategory = Cascade.Components.Section(Window, {
    Title = "Status",
    Disclosure = false
})
local AccountTab = StatusCategory:Tab({
    Title = "Account",
    Icon = Icon("bookmarkFill", "bookmark"),
    Selected = true
})
local OverviewTab = AccountTab
local OverviewSection = OverviewTab:PageSection({
    Title = "📊 Account Overview",
    Subtitle = "Read from your player data. N/A = this value was not found."
})
local OverviewForm = OverviewSection:Form()
local function FindGui(path)
    local cur = PlayerGui
    for seg in path:gmatch("[^%.]+") do
        cur = cur and cur:FindFirstChild(seg)
        if not cur then return nil end
    end
    return cur
end
local function CountShards()
    local items = FindGui("Interface.Inventory.Main.Holder.Items")
    if not items then return nil end
    local total = 0
    for _, c in ipairs(items:GetChildren()) do
        if c.Name:lower():find("shard", 1, true) then
            local q = 1
            local label = c:FindFirstChild("Quantity", true)
            if label and (label:IsA("TextLabel") or label:IsA("TextButton")) then
                q = tonumber((label.Text:gsub("[^%d]", ""))) or 1
            end
            total += q
        end
    end
    return total
end
local function CurrentFamily()
    local items = FindGui("Interface.Inventory.Main.Holder.Items")
    if not items then return nil end
    for _, c in ipairs(items:GetChildren()) do
        local id, name = c.Name:match("^(%d+)%s*%-%s*(.+)$")
        if id and tonumber(id) % 100 == 2 then
            local main = c:FindFirstChild("Main")
            local eq = main and main:FindFirstChild("Equipped")
            if eq and eq:IsA("GuiObject") and eq.Visible then
                local check = eq:FindFirstChild("Checkmark")
                local on = true
                if check and check:IsA("ImageLabel") and check.ImageTransparency >= 1 then on = false end
                if on then return name end
            end
        end
    end
    return "None"
end
local function AttrTrue(v)
    if type(v) == "boolean" then return v end
    if type(v) == "number" then return v ~= 0 end
    if type(v) == "string" then
        local x = v:lower()
        return x == "true" or x == "yes" or x == "1"
    end
    return false
end
local hiddenLabelCache, hiddenLabelAt = nil, 0
local function FindWarningLabel()
    if os.clock() - hiddenLabelAt < 15 then return hiddenLabelCache end
    hiddenLabelAt = os.clock()
    hiddenLabelCache = false
    local n = 0
    for _, d in ipairs(PlayerGui:GetDescendants()) do
        n += 1
        if n % 600 == 0 then task.wait() end
        if d:IsA("TextLabel") or d:IsA("TextButton") then
            local t = (d.Text or ""):lower()
            if t:find("exploiter", 1, true) or t:find("shadow ban", 1, true) or t:find("shadowban", 1, true) then
                hiddenLabelCache = d:GetFullName():gsub("^Players%.[^%.]+%.PlayerGui%.", "")
                break
            end
        end
    end
    return hiddenLabelCache
end
local function ShadowStatus()
    if FindWarningLabel() then return "✅" end
    if AttrTrue(LocalPlayer:GetAttribute("Exploiter")) or AttrTrue(LocalPlayer:GetAttribute("Blacklisted")) then
        return "✅"
    end
    return "❌"
end
local function FlagCompare()
    local others, flagged = 0, 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            others += 1
            if AttrTrue(plr:GetAttribute("Exploiter")) or AttrTrue(plr:GetAttribute("Blacklisted")) then
                flagged += 1
            end
        end
    end
    local mine = (AttrTrue(LocalPlayer:GetAttribute("Exploiter")) or AttrTrue(LocalPlayer:GetAttribute("Blacklisted"))) and "flagged" or "clear"
    return ("You: %s | Others flagged: %d/%d"):format(mine, flagged, others)
end
local FIELDS = {
    { key = "ShadowBan", title = "🛠️ Shadow Ban", raw = true, aliases = {}, calc = ShadowStatus,
      colors = { ["✅"] = Color3.fromRGB(80, 200, 120), ["❌"] = Color3.fromRGB(235, 87, 87) } },
    { key = "FlagCompare", title = "🔍 Flag Compare", raw = true, aliases = {}, calc = FlagCompare },
    { key = "Blacklisted", title = "🚫 Blacklisted", flag = true, aliases = { "blacklisted" } },
    { key = "Exploiter", title = "⚠️ Exploiter Flag", flag = true, aliases = { "exploiter" } },
    { key = "Level",     title = "▶️ Level",    aliases = { "level", "lvl", "playerlevel" } },
    { key = "XP",        title = "📈 XP",       aliases = {}, strip = "^XP:%s*",
      gui = "Interface.Gear_Up.XP.Percentage" },
    { key = "Prestige",  title = "🔺 Prestige", aliases = { "prestige", "prestigelevel" } },
    { key = "Gold",      title = "💰 Gold",     aliases = { "gold", "coins", "money" },
      gui = "Interface.Topbar.Main.Currencies.Gold.Amount" },
    { key = "Gems",      title = "💎 Gems",     aliases = { "gems", "gem" },
      gui = "Interface.Topbar.Main.Currencies.Gems.Amount" },
    { key = "Family",    title = "⚡ Family",   aliases = { "family", "familyname", "clan" }, calc = CurrentFamily },
    { key = "Title",     title = "🏷️ Title",    aliases = { "title" }, pretty = true },
    { key = "Shards",    title = "✨ Shards",   aliases = { "shards", "shard" }, calc = CountShards },
}
for _, f in ipairs(FIELDS) do
    local row = OverviewForm:Row()
    row:Left():TitleStack({ Title = f.title })
    f.label = row:Right():Label({ Text = "..." })
    f.last = nil
end
local function NormName(s)
    return (tostring(s):lower():gsub("[^%w]", ""))
end
local function Fmt(v)
    if type(v) == "number" then
        if v ~= math.floor(v) then return string.format("%.2f", v) end
        local s = tostring(math.floor(v))
        local neg = s:sub(1, 1) == "-"
        if neg then s = s:sub(2) end
        s = s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
        return (neg and "-" or "") .. s
    end
    return tostring(v)
end
local function Truthy(v)
    if type(v) == "boolean" then return v end
    if type(v) == "number" then return v ~= 0 end
    if type(v) == "string" then
        local s = v:lower()
        return s == "true" or s == "yes" or s == "1"
    end
    return false
end
local dataRoots = { LocalPlayer }
local lastRootScan = 0
local function ScanRoots(force)
    if not force and os.clock() - lastRootScan < 15 then return end
    lastRootScan = os.clock()
    local roots = { LocalPlayer }
    local uid = tostring(LocalPlayer.UserId)
    local n = 0
    for _, d in ipairs(ReplicatedStorageSvc:GetDescendants()) do
        n += 1
        if n % 500 == 0 then task.wait() end
        if d.Name == LocalPlayer.Name or d.Name == uid then
            table.insert(roots, d)
        end
    end
    dataRoots = roots
end
local SKIP_NAMES = { PlayerGui = true, PlayerScripts = true }
local function CollectEntries()
    local entries = {}
    local function keep(v)
        local t = type(v)
        return t == "number" or t == "string" or t == "boolean"
    end
    local function walk(inst, depth)
        pcall(function()
            for k, v in pairs(inst:GetAttributes()) do
                if keep(v) then
                    entries[#entries + 1] = { name = k, value = v, path = inst:GetFullName() .. " @" .. k }
                end
            end
            if inst:IsA("ValueBase") then
                local ok, v = pcall(function() return inst.Value end)
                if ok and keep(v) then
                    entries[#entries + 1] = { name = inst.Name, value = v, path = inst:GetFullName() }
                end
            end
        end)
        if depth >= 6 then return end
        for _, c in ipairs(inst:GetChildren()) do
            if not SKIP_NAMES[c.Name] then walk(c, depth + 1) end
        end
    end
    for _, root in ipairs(dataRoots) do
        if root and root.Parent then walk(root, 0) end
    end
    return entries
end
local function IsExcludedPath(path)
    return path:find("%.Boosts") ~= nil or path:find("%.Gamepasses") ~= nil
end
local function LookupField(entries, field)
    for _, alias in ipairs(field.aliases) do
        for _, e in ipairs(entries) do
            if NormName(e.name) == alias and not IsExcludedPath(e.path) then
                return e.value
            end
        end
    end
    return nil
end
local function ReadGui(path)
    local cur = FindGui(path)
    if cur and (cur:IsA("TextLabel") or cur:IsA("TextButton")) then
        local t = (cur.Text or ""):gsub("<[^>]->", "")
        t = t:gsub("^%s+", ""):gsub("%s+$", "")
        if t ~= "" then return t end
    end
    return nil
end
local function LabelObject(label)
    local inst = label and label.__instance
    if not inst then return nil end
    if inst:IsA("TextLabel") then return inst end
    return inst:FindFirstChildWhichIsA("TextLabel", true)
end
local lastEntries = {}
local function RefreshOverview()
    ScanRoots(false)
    local entries = CollectEntries()
    lastEntries = entries
    for _, f in ipairs(FIELDS) do
        local v
        if f.calc then
            local okC, r = pcall(f.calc)
            if okC then v = r end
        end
        if v == nil and f.gui then v = ReadGui(f.gui) end
        if v == nil then v = LookupField(entries, f) end
        local text
        if v == nil then
            text = "N/A"
        elseif f.raw then
            text = tostring(v)
        elseif f.flag then
            text = Truthy(v) and "⚠️ Yes" or "✅ No"
        elseif f.strip then
            text = (tostring(v):gsub(f.strip, ""))
        elseif f.pretty then
            text = (tostring(v):gsub("_", " "))
        else
            text = Fmt(v)
        end
        if text ~= f.last then
            f.last = text
            pcall(function() f.label.Text = text end)
            if f.colors and f.colors[text] then
                pcall(function()
                    local obj = LabelObject(f.label)
                    if obj then obj.TextColor3 = f.colors[text] end
                end)
            end
        end
    end
end
task.spawn(function()
    while Alive() do
        pcall(RefreshOverview)
        for _ = 1, 12 do
            if not Alive() then return end
            task.wait(0.25)
        end
    end
end)
task.spawn(function()
    while Alive() do
        if IN_MENU and Cfg.AutoSelect and not selecting then
            if SelectCharacter() then
                for _ = 1, 16 do
                    if not Alive() then return end
                    task.wait(0.25)
                end
            end
        end
        task.wait(1)
    end
end)
task.spawn(function()
    local lastFire = nil
    local slotVisible, slotCheckAt = false, 0
    while Alive() do
        if not IN_MENU then
            lastFire = nil
            SetCountdown("N/A")
        elseif not Cfg.AutoJoin then
            lastFire = nil
            SetCountdown("Off")
        else
            local now = os.clock()
            if Cfg.AutoSelect then
                if now >= slotCheckAt then
                    slotVisible = SlotScreenVisible()
                    slotCheckAt = now + 1
                end
            else
                slotVisible = false
            end
            if slotVisible then
                lastFire = nil
                SetCountdown("Waiting for character select")
            elseif SH.Coord.Blocker(100) then
                lastFire = nil
                SetCountdown("Waiting: " .. tostring(SH.Coord.last))
            else
                local delay = ClampDelay(Cfg.JoinDelay)
                if not lastFire then lastFire = now end
                local remaining = lastFire + delay - now
                if remaining <= 0 then
                    SetCountdown("Joining now...")
                    lastFire = os.clock()
                    JoinLobby()
                else
                    SetCountdown(("Next join in %ds"):format(math.ceil(remaining)))
                end
            end
        end
        task.wait(0.25)
    end
end)
local MainCategory = Cascade.Components.Section(Window, {
    Title = "In-Game",
    Disclosure = false
})
local FarmTab = MainCategory:Tab({
    Title = "Auto Farm",
    Icon = Icon("boltFill"),
})
local Farm = {}
SH.Farm = Farm
function Farm.OnRetryAmount(amount) end
function Farm.Fire(name, ...)
    local fn = Farm[name]
    if type(fn) == "function" then
        local ok, err = pcall(fn, ...)
        if not ok then SH.dbg("[SmoothHub] Farm." .. tostring(name) .. ":", err) end
    end
end
do
    if Cfg.AutoLeave and Cfg.AutoLeaveWhenRetryComplete then Cfg.AutoLeave = false end
    local MainForm = FarmTab:PageSection({
        Title = "⚔️ Auto Farm",
        Subtitle = "The essentials - turn these on and go",
    }):Form()
    local ReloadForm = FarmTab:PageSection({
        Title = "🔄 Reload & Refill",
        Subtitle = "Reload blades and refill supplies automatically",
    }):Form()
    local OptionsForm = FarmTab:PageSection({
        Title = "⚙️ After the Match",
        Subtitle = "What to do when a mission ends",
    }):Form()
    local function AddFarmToggle(form, title, subtitle, key, handler)
        local row = form:Row()
        row:Left():TitleStack({ Title = title, Subtitle = subtitle })
        Farm.Toggles = Farm.Toggles or {}
        Farm.Toggles[key] = UiSync.Link(row:Right():Toggle({
            Value = Cfg[key],
            ValueChanged = function(self, value)
                Cfg[key] = value and true or false
                Save()
                Farm.Fire(handler, Cfg[key])
            end
        }), Cfg, key)
    end
    local function AddFarmSlider(form, titleFor, subtitle, key, handler)
        local range = FARM_RANGES[key]
        local row = form:Row()
        local stack = row:Left():TitleStack({ Title = titleFor(Cfg[key]), Subtitle = subtitle })
        UiSync.Link(row:Right():Slider({
            Minimum = range[1],
            Maximum = range[2],
            Value = Cfg[key],
            ValueChanged = function(self, value)
                local v = math.clamp(math.floor(value + 0.5), range[1], range[2])
                Cfg[key] = v
                pcall(function() stack.Title = titleFor(v) end)
                Save()
                Farm.Fire(handler, v)
            end
        }), Cfg, key, function(_, want)
            pcall(function() stack.Title = titleFor(want) end)
        end)
    end
    local function AddCounterRow(form, titleFor, refreshHandler)
        local row = form:Row()
        local stack = row:Left():TitleStack({ Title = titleFor(0) })
        local run
        local btn = row:Right():Button({
            Label = "Refresh",
            Callback = function() if run then run() end end
        })
        run = BindButton(btn, function() Farm.Fire(refreshHandler) end)
        return function(n)
            pcall(function() stack.Title = titleFor(n) end)
        end
    end
    -- ===== Enable [ Auto Farm ] + ดรอปดาวเลือกโหมด (Smart / Blades / Thunder Spears) ได้ทีละอย่าง =====
    local FARM_MODES = { "Smart", "Blades", "Thunder Spears" }
    local farmDrop, farmToggle, farmSyncing = nil, nil, false
    local function FarmEnabled() return Cfg.AutoFarmSmart or Cfg.AutoFarm or Cfg.AutoFarmThunder end
    local function FarmModeIdx()
        if Cfg.AutoFarmSmart then return 1 end
        if Cfg.AutoFarm then return 2 end
        if Cfg.AutoFarmThunder then return 3 end
        return table.find(FARM_MODES, Cfg.FarmMode) or 1
    end
    local function RefreshFarmUi()
        local idx = FarmModeIdx()
        if FarmEnabled() then Cfg.FarmMode = FARM_MODES[idx] end
        farmSyncing = true
        if farmToggle then pcall(function() farmToggle.Value = FarmEnabled() and true or false end) end
        if farmDrop then pcall(function() farmDrop.Value = idx farmDrop.Label = FARM_MODES[idx] end) end
        farmSyncing = false
    end
    -- idx: 0 = ปิด, 1 = Smart, 2 = Blades, 3 = Thunder Spears
    local function ApplyFarmMode(idx)
        Cfg.AutoFarmSmart = (idx == 1)
        if idx == 0 then
            Cfg.AutoFarm, Cfg.AutoFarmThunder = false, false
        elseif idx == 2 then
            Cfg.AutoFarm, Cfg.AutoFarmThunder = true, false
        elseif idx == 3 then
            Cfg.AutoFarm, Cfg.AutoFarmThunder = false, true
        end
        if idx > 0 then Cfg.FarmMode = FARM_MODES[idx] end
        Save()
        if idx == 0 then
            Farm.Fire("OnAutoFarm", false)
            Farm.Fire("OnAutoFarmThunder", false)
        elseif Cfg.AutoFarm then
            Farm.Fire("OnAutoFarm", true)
        elseif Cfg.AutoFarmThunder then
            Farm.Fire("OnAutoFarmThunder", true)
        end
        Farm.Fire("OnAutoFarmSmart", Cfg.AutoFarmSmart)
        RefreshFarmUi()
    end
    do
        local trow = MainForm:Row()
        trow:Left():TitleStack({
            Title = "Enable [ Auto Farm ]",
            Subtitle = "Turn Auto Farm on or off.",
        })
        farmToggle = trow:Right():Toggle({
            Value = FarmEnabled() and true or false,
            ValueChanged = function(self, value)
                if farmSyncing then return end
                local want = value and true or false
                if want == (FarmEnabled() and true or false) then return end
                ApplyFarmMode(want and (table.find(FARM_MODES, Cfg.FarmMode) or 1) or 0)
            end
        })
        local row = MainForm:Row()
        row:Left():TitleStack({
            Title = "Select Equip",
            Subtitle = "Blades, Thunder Spears, or Smart (switches automatically).",
        })
        farmDrop = row:Right():PullDownButton({
            Label = FARM_MODES[FarmModeIdx()],
            Options = FARM_MODES,
            Value = FarmModeIdx(),
            ValueChanged = function(self, index)
                if farmSyncing then return end
                if type(index) == "table" then index = index[1] end
                if type(index) ~= "number" or not FARM_MODES[index] then return end
                self.Label = FARM_MODES[index]
                if FarmEnabled() then
                    if index ~= FarmModeIdx() then ApplyFarmMode(index) end
                else
                    Cfg.FarmMode = FARM_MODES[index] -- ยังปิดอยู่: จำโหมดไว้ รอกด Enable
                    Save()
                end
            end
        })
        pcall(StyleDropdown, farmDrop)
        -- แถว Status: บอกว่า Auto Farm กำลังทำอะไร + ไททันเหลือกี่ตัว + ฆ่าไปแล้วกี่ตัว
        -- สี: เหลือง = กำลังทำงาน | เขียว = ฟาร์มเสร็จ (ขึ้นหน้า MISSION COMPLETED) | สีปกติ = ปิดอยู่/ไม่ได้อยู่ในแมตช์
        -- (อ่านค่าจากตัวแปรที่ระบบฟาร์มมีอยู่แล้ว ไม่แตะลูปฟาร์ม)
        local statusRow = MainForm:Row()
        statusRow:Left():TitleStack({ Title = "Status" })
        local statusLabel = statusRow:Right():Label({ Text = "Off" })
        local STATUS_YELLOW = Color3.fromRGB(255, 214, 10)
        local STATUS_GREEN = Color3.fromRGB(48, 209, 88)
        local statusDefault = nil
        local lastStatus, lastColorKey = nil, nil
        local function SetStatusColor(key) -- key: "yellow" | "green" | "default"
            if key == lastColorKey then return end
            local ok = pcall(function()
                local o = LabelObject(statusLabel)
                if not o then error("label not ready") end
                if not statusDefault then statusDefault = o.TextColor3 end
                if key == "yellow" then o.TextColor3 = STATUS_YELLOW
                elseif key == "green" then o.TextColor3 = STATUS_GREEN
                else o.TextColor3 = statusDefault end
            end)
            if ok then lastColorKey = key end
        end
        -- นับไททัน: seen = ตัวที่เคยเห็นว่ายังมีชีวิต ถ้าตัวนั้นตาย/หายไป = ฆ่าเพิ่ม 1 (นับรวมที่คนอื่นฆ่าด้วย)
        local seen, kills = {}, 0
        local lastSpawn, wasOn = nil, false
        local function IsLive(t)
            local hum = t and t.Parent and t:FindFirstChildOfClass("Humanoid")
            return hum ~= nil and hum.Health > 0
        end
        local function CountTitans()
            local folder = workspace:FindFirstChild("Titans")
            local left = 0
            if folder then
                for _, t in ipairs(folder:GetChildren()) do
                    if t:IsA("Model") and IsLive(t) then
                        left += 1
                        seen[t] = true
                    end
                end
            end
            for t in pairs(seen) do
                if not IsLive(t) then
                    seen[t] = nil
                    kills += 1
                end
            end
            return left
        end
        task.spawn(function()
            while Alive() do
                task.wait(0.3)
                local text, color = "Off", "default"
                pcall(function()
                    local on = FarmEnabled() or Cfg.AutoClearWave
                    if on and not wasOn then
                        kills = 0
                        seen = {}
                    end
                    wasOn = on
                    if not on then return end
                    if not Farm.CanUseHere() then text = "Not in a match" return end
                    -- เกิดตัวละครใหม่ = แมตช์ใหม่ เริ่มนับใหม่
                    if Farm.CharSpawnAt ~= lastSpawn then
                        lastSpawn = Farm.CharSpawnAt
                        kills = 0
                        seen = {}
                    end
                    -- ฟาร์มเสร็จ: หน้า MISSION COMPLETED ขึ้นแล้ว (หยุดนับ กันไททันหายตอนจบแมตช์ถูกนับเป็นฆ่า)
                    if Farm.CompleteScreenShown and Farm.CompleteScreenShown() then
                        text = ("Completed | Killed %d"):format(kills)
                        color = "green"
                        return
                    end
                    local left = CountTitans()
                    local action
                    if Farm.LootBusy then action = "Looting crate"
                    elseif Farm.NpcBusy then action = Farm.NpcCurrent and ("NPC visit: " .. tostring(Farm.NpcCurrent)) or "NPC visit"
                    elseif Farm.Refilling then action = "Refilling"
                    elseif Farm.FailSafeActive then action = "Fail safe"
                    elseif Farm.BladesBusy and Farm.BladesBusy() then action = "Reloading"
                    elseif Cfg.WaitForBoss and Farm.BossBlock and Farm.BossBlock() then action = tostring(Farm.BossStatus or "Waiting for boss")
                    elseif Cfg.AutoClearWave then action = tostring(Farm.ClearWaveStatus or "Clearing")
                    else action = tostring((Farm.Blades and Farm.Blades.Status) or "Farming") end
                    text = ("%s | Left %d | Killed %d"):format(action, left, kills)
                    color = "yellow"
                end)
                if text ~= lastStatus then
                    lastStatus = text
                    pcall(function() statusLabel.Text = text end)
                    lastColorKey = nil -- เปลี่ยนข้อความแล้ว ตั้งสีใหม่ทุกครั้ง กันสีถูกรีเซ็ต
                end
                SetStatusColor(color)
            end
        end)
        UiSync.Add(RefreshFarmUi)
    end
    -- ตัวแทนสวิตช์เดิม: โค้ดส่วนอื่นยังสั่ง Farm.Toggles.AutoFarm.Value = ... ได้เหมือนเดิม และปุ่ม/ดรอปดาวจะอัปเดตตาม
    do
        local function Proxy(key, handler)
            Farm.Toggles = Farm.Toggles or {}
            Farm.Toggles[key] = setmetatable({}, {
                __index = function(_, k) if k == "Value" then return Cfg[key] end end,
                __newindex = function(_, k, v)
                    if k ~= "Value" then return end
                    Cfg[key] = v and true or false
                    Save()
                    RefreshFarmUi()
                    if handler then Farm.Fire(handler, Cfg[key]) end
                end,
            })
        end
        Proxy("AutoFarm", "OnAutoFarm")
        Proxy("AutoFarmThunder", "OnAutoFarmThunder")
        Proxy("AutoFarmSmart", "OnAutoFarmSmart")
    end
    AddFarmToggle(MainForm, "Bypass Farm (No Shadow Ban)",
        "Auto-jumps while farming so your gas gets used.",
        "SafeFarm", "OnSafeFarm")
    AddFarmToggle(ReloadForm, "Auto Reload", "Reloads your blades when they run out.", "AutoReload", "OnAutoReload")
    -- ===== Enable [ Auto Refill ] + ดรอปดาวติ๊กได้ทั้ง Blade และ Thunder Spears พร้อมกัน =====
    do
        local REFILL_OPTS = { "Blade", "Thunder Spears" }
        local PICK_KEYS = { "RefillPickBlade", "RefillPickThunder" }
        local LIVE_KEYS = { "AutoRefillsBlade", "AutoRefillsThunder" }
        local LIVE_HANDLERS = { "OnAutoRefillsBlade", "OnAutoRefillsThunder" }
        -- เซฟรุ่นเก่าที่เปิด Refill ไว้ -> ย้ายมาเป็น Enable + ตัวเลือกที่เคยเปิด
        if not Cfg.RefillEnabled and (Cfg.AutoRefillsBlade or Cfg.AutoRefillsThunder) then
            Cfg.RefillEnabled = true
            Cfg.RefillPickBlade = Cfg.AutoRefillsBlade and true or false
            Cfg.RefillPickThunder = Cfg.AutoRefillsThunder and true or false
        end
        -- ค่าที่ระบบเติมของใช้จริง = เปิดใช้งาน และติ๊กตัวเลือกนั้นไว้
        local function SyncLive()
            for i, live in ipairs(LIVE_KEYS) do
                local want = (Cfg.RefillEnabled and Cfg[PICK_KEYS[i]]) and true or false
                if Cfg[live] ~= want then
                    Cfg[live] = want
                    Farm.Fire(LIVE_HANDLERS[i], want)
                end
            end
            Save()
        end
        SyncLive()
        local function Picked()
            local list = {}
            for i, k in ipairs(PICK_KEYS) do if Cfg[k] then list[#list + 1] = i end end
            return list
        end
        local syncing = false
        local refillToggle, popBtn, fbBtn = nil, nil, nil
        local OPTS4 = { "None", "Blade", "Thunder Spears", "Both" }
        local function Idx4()
            if Cfg.RefillPickBlade and Cfg.RefillPickThunder then return 4 end
            if Cfg.RefillPickBlade then return 2 end
            if Cfg.RefillPickThunder then return 3 end
            return 1
        end
        local function RefreshRefillUi()
            syncing = true
            if refillToggle then pcall(function() refillToggle.Value = Cfg.RefillEnabled and true or false end) end
            if popBtn then pcall(function() popBtn.Value = Picked() end) end
            if fbBtn then pcall(function() fbBtn.Value = Idx4() fbBtn.Label = OPTS4[Idx4()] end) end
            syncing = false
        end
        local function ApplyPicks(value)
            local indexes = type(value) == "table" and value or { value }
            local valid = SettingsStore.ValidIndexes(indexes, #REFILL_OPTS)
            for i, k in ipairs(PICK_KEYS) do Cfg[k] = table.find(valid, i) ~= nil end
            SyncLive()
        end
        local trow = ReloadForm:Row()
        trow:Left():TitleStack({
            Title = "Enable [ Auto Refill ]",
            Subtitle = "Turn Auto Refill on or off.",
        })
        refillToggle = trow:Right():Toggle({
            Value = Cfg.RefillEnabled and true or false,
            ValueChanged = function(self, value)
                if syncing then return end
                Cfg.RefillEnabled = value and true or false
                SyncLive()
            end
        })
        local row = ReloadForm:Row()
        row:Left():TitleStack({
            Title = "Select Equip",
            Subtitle = "Choose what to refill: Blade, Thunder Spears, or both.",
        })
        local okPop, btn = pcall(function()
            return row:Right():PopUpButton({
                Options = REFILL_OPTS,
                Maximum = #REFILL_OPTS,
                Value = Picked(),
                ValueChanged = function(self, value)
                    if syncing then return end
                    ApplyPicks(value)
                end
            })
        end)
        if okPop and btn then
            popBtn = btn
            pcall(StyleDropdown, btn)
        else
            -- สำรอง: ถ้า PopUpButton ใช้ไม่ได้ ใช้ดรอปดาวเลือกทีละแบบ (รวมตัวเลือก Both)
            local map = { {}, { 1 }, { 2 }, { 1, 2 } }
            fbBtn = row:Right():PullDownButton({
                Label = OPTS4[Idx4()],
                Options = OPTS4,
                Value = Idx4(),
                ValueChanged = function(self, index)
                    if syncing then return end
                    if type(index) == "table" then index = index[1] end
                    if type(index) ~= "number" or not map[index] then return end
                    self.Label = OPTS4[index]
                    ApplyPicks(map[index])
                end
            })
            pcall(StyleDropdown, fbBtn)
        end
        UiSync.Add(function()
            -- โหลดคอนฟิกใหม่: อัปเดตปุ่ม/ดรอปดาว และคำนวณค่าที่ใช้จริงใหม่
            SyncLive()
            RefreshRefillUi()
        end)
    end
    -- แถว Status ของหมวด Reload & Refill: โชว์ว่ากำลังรีโหลด/เติมของอยู่ไหม (อ่านจากตัวแปรที่ระบบมีอยู่แล้ว)
    do
        local statusRow = ReloadForm:Row()
        statusRow:Left():TitleStack({ Title = "Status" })
        local statusLabel = statusRow:Right():Label({ Text = "Off" })
        local lastStatus = nil
        task.spawn(function()
            while Alive() do
                task.wait(0.5)
                local text
                pcall(function()
                    if not (Cfg.AutoReload or Cfg.AutoRefillsBlade or Cfg.AutoRefillsThunder) then text = "Off"
                    elseif not Farm.CanUseHere() then text = "Not in a match"
                    elseif Farm.Refilling then text = tostring((Farm.RefillStatus and Farm.RefillStatus()) or "Refilling")
                    elseif Cfg.AutoReload and Farm.BladesBusy and Farm.BladesBusy() then text = "Reloading"
                    else
                        local st = Farm.RefillStatus and Farm.RefillStatus()
                        text = (st and st ~= "Idle") and tostring(st) or "Ready"
                    end
                end)
                text = text or "Ready"
                if text ~= lastStatus then
                    lastStatus = text
                    pcall(function() statusLabel.Text = text end)
                end
            end
        end)
    end
    AddFarmToggle(MainForm, "Damage Multiplier ( x10 )", "Deal 10x damage to Titans.", "DamageMultiplier", "OnDamageMultiplier")
    AddFarmSlider(MainForm, function(v) return "Set Start Farm ( " .. v .. "s )" end,
        "Wait after spawning before farming. 0 = start right away.", "StartDelay", "OnStartDelay")
    AddFarmSlider(MainForm, function(v) return "Fly Height ( " .. v .. " studs )" end,
        "How high you fly above the titan (150-500). Higher is safer.", "FlyHeight", "OnFlyHeight")
    -- [hidden] AddFarmSlider(MainForm, function(v) return "Thunder Spears Range ( " .. v .. " studs )" end,
    -- [hidden] "Auto Farm [ TS ]: hits every titan within this distance of you (50-10000).", "ThunderRange", nil)
    -- [hidden] AddFarmSlider(MainForm, function(v) return "Thunder Spears Targets per Shot ( " .. ((v <= 0 or v >= 200) and "All" or v) .. " )" end,
    -- [hidden] "Auto Farm [ TS ]: titans hit per shot. 0 or 200 = all of them in range.", "ThunderTargets", nil)
    AddFarmToggle(OptionsForm, "Auto Retry", "Automatically Retry when completed.", "AutoRetry", "OnAutoRetry")
    AddFarmToggle(OptionsForm, "Auto Leave", "Leave to the lobby right when the match ends.", "AutoLeave", "OnAutoLeave")
    AddFarmToggle(OptionsForm, "Auto Leave After X Matches",
        "Retry up to the Retry Amount, then leave (needs Auto Retry). Not together with Auto Leave.",
        "AutoLeaveWhenRetryComplete", "OnAutoLeaveWhenRetryComplete")
    AddFarmSlider(OptionsForm, function(v) return "Retry Amount ( " .. v .. " )" end,
        "Matches to retry before leaving (used by Auto Leave After X Matches).", "RetryAmount", "OnRetryAmount")
    Farm.SetRetry = AddCounterRow(OptionsForm, function(n) return "Current Retry ( " .. tostring(n) .. " )" end, "RefreshRetry")
    do
        local RtRow = OptionsForm:Row()
        RtRow:Left():TitleStack({ Title = "Status" })
        local RtLabel = RtRow:Right():Label({ Text = "Off" })
        local lastRt = nil
        function Farm.SetRetryStatus(text)
            if text == lastRt then return end
            lastRt = text
            pcall(function() RtLabel.Text = tostring(text) end)
        end
    end
    local SafetyForm = FarmTab:PageSection({
        Title = "🛟 Safety",
        Subtitle = "Keep missions from finishing too fast and break long win streaks",
    }):Form()
    AddFarmSlider(SafetyForm, function(v) return "Safe Time ( " .. v .. "s )" end,
        "A mission can't finish sooner than this. 0 = off.", "SafeTime", "OnSafeTime")
    AddFarmSlider(SafetyForm, function(v) return "Fail Safe At [ " .. v .. " ]" end,
        "Lose on purpose after this many wins in a row. 0 = never.", "FailSafeAt", "OnFailSafeAt")
    Farm.SetStreak = AddCounterRow(SafetyForm, function(n) return "Current Streak ( " .. tostring(n) .. " )" end, "RefreshStreak")
    function Farm.RefreshStreak()
        if Farm.SetStreak then Farm.SetStreak(Cfg.Streak) end
    end
    task.defer(Farm.RefreshStreak)
    AddFarmToggle(SafetyForm, "Auto Fail Safe", "When the win streak reaches the number above, the next match is lost on purpose: you stand still and let the titans kill you, then the streak resets.", "AutoFailSafe", "OnAutoFailSafe")
    do
        local FsRow = SafetyForm:Row()
        FsRow:Left():TitleStack({ Title = "Fail Safe Status" })
        local FsLabel = FsRow:Right():Label({ Text = "Off" })
        local lastFs = nil
        function Farm.SetFailSafeStatus(text)
            if text == lastFs then return end
            lastFs = text
            pcall(function() FsLabel.Text = tostring(text) end)
        end
    end
end
Farm.Debug = false
function Farm.CanUseHere()
    return not IN_MENU and game.PlaceId ~= 14916516914
end
do
    local RunService = game:GetService("RunService")
    local ATTACK_GAP = { [0] = 0.4, [1] = 0.8, [2] = 0.3, [3] = 0.2, [4] = 0.12, [5] = 0.08 }
    local OTHER_PARTS = { "Eyes", "LeftArm", "RightArm", "LeftLeg", "RightLeg" }
    local ARRIVE_DIST = 12
    local ATTACK_BEFORE_ARRIVE = true
    local ORBIT_ON = true
    local ORBIT_RADIUS = 14
    local ORBIT_SPEED = 1.6
    local ORBIT_BOB = 5
    local HIT_COUNT = 10 -- จำนวนไททันที่ฟันหลังคอพร้อมกันต่อรอบ (ตัวหลัก + ตัวใกล้สุดอีก HIT_COUNT-1) | เดิม 9
    local DAMAGE_MULT = 10
    local BOSS_MULT = 10 -- ตัวคูณดาเมจใส่ Colossal Titan (ตอนมีบอส) | ไททันตัวเล็กยังใช้ BOSS_SMALL_MULT (x10) | ปรับเลขนี้ได้
    local OTHER_MULT = 10
    local RAID_SMALL = HIT_COUNT - 1 -- ตอนมี Colossal: ฟันไททันตัวเล็กได้เต็มโควตาเหมือนตอนไม่มีบอส (เดิม 3 ตัว)
    local BOSS_ALWAYS = true
    local PRIORITY = {}
    local BOSS_NORMAL_HP = 0
    local BOSS_SMALL_MULT = DAMAGE_MULT -- ตอนมี Colossal ไททันตัวเล็กก็โดน x10 เหมือนบอส (เดิม x1)
    local MultState = { full = DAMAGE_MULT, other = OTHER_MULT }
    local function Mult() return Cfg.DamageMultiplier and MultState.full or 1 end
    local function OtherMult() return Cfg.DamageMultiplier and math.min(MultState.other, MultState.full) or 1 end
    local B = { Target = nil, Hits = 0, Status = "Idle" }
    Farm.Blades = B
    local post = nil
    local function Post()
        if not post or not post.Parent then
            local ok, r = pcall(function()
                return game:GetService("ReplicatedStorage").Assets.Remotes:WaitForChild("POST", 5)
            end)
            post = ok and r or nil
        end
        return post
    end
    local function MyRoot()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if char and hum and root and hum.Health > 0 then return root, char end
        return nil
    end
    local function HitParts(titan)
        local hb = titan:FindFirstChild("Hitboxes")
        return hb and hb:FindFirstChild("Hit")
    end
    local function NapeOf(titan)
        local hit = HitParts(titan)
        local nape = hit and hit:FindFirstChild("Nape")
        if nape and nape:IsA("BasePart") then return nape end
        return nil
    end
    local function TitanAlive(titan)
        local hum = titan and titan.Parent and titan:FindFirstChildOfClass("Humanoid")
        return hum ~= nil and hum.Health > 0
    end
    -- 🛰️ Boss Check (Raid): เช็กว่าบอส "เกิดครบและพร้อมสู้" แล้วหรือยัง ก่อนเริ่มฟาร์ม
    -- บอสบางครั้งโผล่ในโฟลเดอร์ Titans แล้วแต่ยังโหลดไม่ครบ / ยืนนิ่ง ไม่ขยับ (บั๊กของเกม)
    -- ลำดับ: ยังไม่มีบอส -> โหลดไม่ครบ (ไม่มี Humanoid/Root/Nape หรือ Root ยังถูกล็อก) -> รอให้นิ่ง BossSettle วินาที -> พร้อม
    -- "active" = เห็นบอสขยับ / เปลี่ยนท่าอนิเมชัน / เลือดลด (ถ้าไม่ active จะแสดงว่า idle แต่ยังฟาร์มได้ เพราะบางทีบอสตื่นตอนโดนตี)
    local BOSS_PATTERNS = { "^colossal", "^armored", "^female", "^attack" }
    local BOSS_GIVEUP = 120 -- ถ้ารอบอสที่โหลดไม่ครบเกินนี้ (วินาที) จะเลิกรอแล้วฟาร์มต่อ กันค้างถาวร
    local bossInfo = setmetatable({}, { __mode = "k" })
    Farm.BossStatus = "Off"
    local function IsBossName(n)
        n = tostring(n):lower()
        if not n:find("titan", 1, true) then return false end
        for _, pat in ipairs(BOSS_PATTERNS) do
            if n:find(pat) then return true end
        end
        return false
    end
    function Farm.FindBoss()
        local folder = workspace:FindFirstChild("Titans")
        for _, t in ipairs(folder and folder:GetChildren() or {}) do
            if t:IsA("Model") and IsBossName(t.Name) then return t end
        end
        return nil
    end
    local function PlayingAnimIds(boss)
        local ids, n = {}, 0
        local ok, animator = pcall(function() return boss:FindFirstChildWhichIsA("Animator", true) end)
        if ok and animator then
            local ok2, tracks = pcall(function() return animator:GetPlayingAnimationTracks() end)
            if ok2 and tracks then
                for _, tr in ipairs(tracks) do
                    local id = tr.Animation and tr.Animation.AnimationId
                    if id and id ~= "" then ids[id] = true n += 1 end
                end
            end
        end
        return ids, n
    end
    -- คืน state: "loading" | "settling" | "ready" | "dead", พร้อมเหตุผล/รายละเอียด
    function Farm.BossReadiness(boss)
        local now = os.clock()
        local hum = boss:FindFirstChildOfClass("Humanoid")
        local root = boss.PrimaryPart or boss:FindFirstChild("HumanoidRootPart")
        if not hum then return "loading", "no Humanoid" end
        if hum.Health <= 0 then return "dead", "defeated" end
        if not root then return "loading", "no root part" end
        if not NapeOf(boss) then return "loading", "no nape hitbox" end
        if hum.MaxHealth <= 0 then return "loading", "no health yet" end
        if root.Anchored then return "loading", "root still anchored" end
        local info = bossInfo[boss]
        if not info then
            local ids = PlayingAnimIds(boss)
            info = { seen = now, pos = root.Position, hp = hum.Health, ids = ids, active = false }
            bossInfo[boss] = info
        end
        if not info.active then
            if (root.Position - info.pos).Magnitude > 2 or hum.Health < info.hp - 0.5 then
                info.active = true
            else
                local ids = PlayingAnimIds(boss)
                for id in pairs(ids) do
                    if not info.ids[id] then info.active = true break end
                end
            end
        end
        local age = now - info.seen
        local settle = Cfg.BossSettle or 5
        if age < settle then return "settling", math.ceil(settle - age) end
        return "ready", info.active and "active" or "idle", age
    end
    local bossCacheAt, bossCacheVal, bossFirstSeen = 0, false, nil
    -- true = ต้องรอ (อย่าเพิ่งฟาร์ม)
    function Farm.BossBlock()
        if not Cfg.WaitForBoss then Farm.BossStatus = "Off" return false end
        local now = os.clock()
        if now - bossCacheAt < 0.25 then return bossCacheVal end
        bossCacheAt = now
        local settle = Cfg.BossSettle or 5
        local boss = Farm.FindBoss()
        local block = false
        if not boss then
            bossFirstSeen = nil
            local since = now - (Farm.CharSpawnAt or now)
            if since < settle then
                Farm.BossStatus = ("Waiting for boss to spawn (%ds)"):format(math.ceil(settle - since))
                block = true
            else
                Farm.BossStatus = "No boss in this match"
            end
        else
            bossFirstSeen = bossFirstSeen or now
            local st, a = Farm.BossReadiness(boss)
            if st == "loading" then
                if now - bossFirstSeen > BOSS_GIVEUP then
                    Farm.BossStatus = "Boss not loading (" .. tostring(a) .. ") - farming anyway"
                else
                    Farm.BossStatus = "Boss loading: " .. tostring(a)
                    block = true
                end
            elseif st == "settling" then
                Farm.BossStatus = ("Boss spawned, settling (%ds)"):format(tonumber(a) or 0)
                block = true
            elseif st == "dead" then
                Farm.BossStatus = "Boss defeated"
            else
                Farm.BossStatus = (a == "active") and "Boss ready (active)" or "Boss ready (idle - not moving yet)"
            end
        end
        bossCacheVal = block
        return block
    end
    function Farm.BossDump()
        local folder = workspace:FindFirstChild("Titans")
        local names = {}
        for _, t in ipairs(folder and folder:GetChildren() or {}) do names[#names + 1] = t.Name end
        print("[SmoothHub][Boss] Titans in folder (" .. #names .. "): " .. table.concat(names, ", "))
        local boss = Farm.FindBoss()
        if not boss then print("[SmoothHub][Boss] no boss model matched " .. table.concat(BOSS_PATTERNS, " ")) return end
        local hum = boss:FindFirstChildOfClass("Humanoid")
        local root = boss.PrimaryPart or boss:FindFirstChild("HumanoidRootPart")
        local ids, n = PlayingAnimIds(boss)
        local idList = {}
        for id in pairs(ids) do idList[#idList + 1] = id end
        local st, a = Farm.BossReadiness(boss)
        print(("[SmoothHub][Boss] %s | state=%s (%s) | health=%s/%s | anchored=%s | nape=%s | tracks=%d"):format(
            boss:GetFullName(), tostring(st), tostring(a),
            hum and tostring(math.floor(hum.Health)) or "?", hum and tostring(math.floor(hum.MaxHealth)) or "?",
            root and tostring(root.Anchored) or "?", tostring(NapeOf(boss) ~= nil), n))
        if #idList > 0 then print("[SmoothHub][Boss] playing animations: " .. table.concat(idList, ", ")) end
        for k, v in pairs(boss:GetAttributes()) do print(("[SmoothHub][Boss] attribute %s = %s"):format(tostring(k), tostring(v))) end
    end
    Farm.DefendErenActive = false
    function Farm.ErenRoot()
        local c = Farm.ErenCache
        if c and c.Parent then return c end
        Farm.ErenCache = nil
        Farm.ErenModel = nil
        if os.clock() < (Farm.ErenSearchAt or 0) then return nil end
        Farm.ErenMisses = Farm.ErenMisses or 0
        Farm.ErenSearchAt = os.clock() + math.min(3 + Farm.ErenMisses * 3, 20)
        local chars = workspace:FindFirstChild("Characters")
        local titans = workspace:FindFirstChild("Titans")
        local exact, loose = nil, nil
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("Model") and not (chars and d:IsDescendantOf(chars)) and not (titans and d:IsDescendantOf(titans)) then
                local n = d.Name:lower()
                if n:find("eren", 1, true) then
                    if n == "eren" or n == "eren_yeager" or n == "eren yeager" or n == "erenyeager" then
                        exact = exact or d
                    else
                        loose = loose or d
                    end
                end
            end
        end
        local m = exact or loose
        if not m then Farm.ErenMisses += 1 return nil end
        Farm.ErenMisses = 0
        local part = m.PrimaryPart or m:FindFirstChild("HumanoidRootPart") or m:FindFirstChildWhichIsA("BasePart", true)
        if not part then return nil end
        Farm.ErenCache = part
        Farm.ErenModel = m
        return part
    end
    function Farm.ErenThreats()
        local eren = Farm.ErenRoot()
        if not eren then return 0, nil end
        local folder = workspace:FindFirstChild("Titans")
        local radius = Cfg.DefendErenRadius or 400
        local n = 0
        for _, t in ipairs(folder and folder:GetChildren() or {}) do
            if t:IsA("Model") and t.Name ~= "Colossal_Titan" and TitanAlive(t) then
                local nape = NapeOf(t)
                if nape and (nape.Position - eren.Position).Magnitude <= radius then n = n + 1 end
            end
        end
        return n, eren
    end
    local function PickTitan(root)
        local folder = workspace:FindFirstChild("Titans")
        if not folder then return nil end
        local erenPart = Farm.DefendErenActive and Farm.ErenRoot() or nil
        local radius = Cfg.DefendErenRadius or 400
        local best, bestDist = nil, math.huge
        for _, t in ipairs(folder:GetChildren()) do
            if t:IsA("Model") and TitanAlive(t) and not (erenPart and t.Name == "Colossal_Titan") then
                local nape = NapeOf(t)
                if nape then
                    local d
                    if erenPart then
                        d = (nape.Position - erenPart.Position).Magnitude
                        if d > radius then d = nil end
                    else
                        d = (nape.Position - root.Position).Magnitude
                    end
                    if d and d < bestDist then best, bestDist = t, d end
                end
            end
        end
        return best
    end
    local function Running()
        if not (Cfg.AutoFarm or Cfg.AutoFarmThunder) or not Farm.CanUseHere() then return false end
        if Farm.Refilling then return false end
        if Farm.FailSafeActive then return false end
        if Farm.PauseUntil and Farm.PauseUntil > os.clock() then return false end
        return true
    end
    -- 🚦 จำกัดจำนวนคำสั่ง Hitboxes.Register ต่อวินาที กัน remote ท่วมจนปิงพุ่ง (Damage Multiplier x10 + Attack Speed สูง)
    -- เกินงบแล้วจะลดจำนวนรอบคูณลง (ต่ำสุด 1 รอบ = ฟาร์มยังทำงานปกติ) | ปรับ REMOTE_BUDGET ได้, 0 = ไม่จำกัด
    local REMOTE_BUDGET = 150
    local budgetStart, budgetUsed = os.clock(), 0
    local function Reps(nParts)
        local want = Mult()
        if REMOTE_BUDGET <= 0 or want <= 1 then return want end
        local now = os.clock()
        if now - budgetStart >= 1 then budgetStart, budgetUsed = now, 0 end
        local n = math.max(nParts, 1)
        local budget = REMOTE_BUDGET * math.max(1, want / DAMAGE_MULT)
        local reps = math.max(1, math.min(want, math.floor((budget - budgetUsed) / n)))
        budgetUsed = budgetUsed + reps * n
        return reps
    end
    -- 📦 ตัวส่ง remote เป็นชุด: เข้าคิวก่อน แล้วปล่อยทีละ NET_BATCH คำสั่งต่อเฟรม (เรียงลำดับเดิมทุกคำสั่ง)
    -- แทนที่จะยิงร้อยกว่าคำสั่งในเฟรมเดียว | คิวยาวเกิน NET_QUEUE_MAX = ข้ามรอบโจมตีนั้น กันคิวค้างสะสม
    local NET_BATCH = 12
    local NET_QUEUE_MAX = 400
    local netQ, netHead, netTail = {}, 1, 0
    local function NetPending() return netTail - netHead + 1 end
    local function NetPush(remote, ...)
        netTail = netTail + 1
        netQ[netTail] = { remote = remote, args = table.pack(...) }
    end
    local netConn
    netConn = RunService.Heartbeat:Connect(function()
        if not Alive() then
            if netConn then netConn:Disconnect() end
            return
        end
        local sent = 0
        while netHead <= netTail and sent < NET_BATCH do
            local it = netQ[netHead]
            netQ[netHead] = nil
            netHead = netHead + 1
            sent = sent + 1
            if it.remote and it.remote.Parent then
                pcall(it.remote.FireServer, it.remote, table.unpack(it.args, 1, it.args.n))
            end
        end
        if netHead > netTail then netHead, netTail = 1, 0 end
    end)
    local function Slash(parts)
        local remote = Post()
        if not remote then return false end
        if typeof(parts) == "Instance" then parts = { parts } end
        if NetPending() > NET_QUEUE_MAX then return false end
        local reps = Reps(#parts)
        NetPush(remote, "Attacks", "Slash", true)
        for r = 1, reps do
            for i, part in ipairs(parts) do
                if PRIORITY[part] or r <= OtherMult() then
                    NetPush(remote, "Hitboxes", "Register", part, 143 + math.random() * 10, 0.26 + math.random() * 0.25)
                end
            end
        end
        NetPush(remote, "Attacks", "Slash", false)
        B.Hits = B.Hits + #parts
        return true
    end
    -- 🎯 Thunder Spears: จำนวนเป้าต่อชุด (0 หรือ 200 = ทุกตัว) | ใช้ค่าจากสไลเดอร์ แทน HIT_COUNT ของดาบ
    local function SpearLimit()
        local n = Cfg.ThunderTargets or 0
        if n <= 0 or n >= 200 then return math.huge end
        return n
    end
    local function NapesAround(main, spear)
        local mainNape = NapeOf(main)
        if not mainNape then return {} end
        local cap = spear and SpearLimit() or HIT_COUNT
        local rangeFrom, rangeMax = nil, Cfg.ThunderRange or 10000
        if spear then
            local rr = MyRoot()
            rangeFrom = rr and rr.Position or mainNape.Position
        end
        local folder = workspace:FindFirstChild("Titans")
        local boss, bossNape = nil, nil
        if BOSS_ALWAYS and folder then
            local c = folder:FindFirstChild("Colossal_Titan")
            if c and c:IsA("Model") and TitanAlive(c) then
                bossNape = NapeOf(c)
                if bossNape then boss = c end
            end
        end
        local others = {}
        for _, t in ipairs(folder and folder:GetChildren() or {}) do
            if t ~= main and t ~= boss and t:IsA("Model") and TitanAlive(t) then
                local n = NapeOf(t)
                if n and (not spear or (n.Position - rangeFrom).Magnitude <= rangeMax) then
                    others[#others + 1] = { part = n, d = (n.Position - mainNape.Position).Magnitude }
                end
            end
        end
        table.sort(others, function(a, b) return a.d < b.d end)
        local list = {}
        if boss then
            PRIORITY = { [bossNape] = true }
            list[1] = bossNape
            local hum = boss:FindFirstChildOfClass("Humanoid")
            local ratio = hum and (hum.Health / math.max(hum.MaxHealth, 1)) or 1
            if ratio <= BOSS_NORMAL_HP then
                MultState.full, MultState.other = 1, 1
            else
                MultState.full, MultState.other = BOSS_MULT, BOSS_SMALL_MULT
            end
            local smallLeft = spear and (cap - 1) or math.min(RAID_SMALL, HIT_COUNT - 1)
            if main ~= boss and smallLeft > 0 then
                list[#list + 1] = mainNape
                smallLeft = smallLeft - 1
            end
            for i = 1, math.min(smallLeft, #others) do
                list[#list + 1] = others[i].part
            end
        else
            MultState.full, MultState.other = DAMAGE_MULT, OTHER_MULT
            PRIORITY = { [mainNape] = true }
            list[1] = mainNape
            for i = 1, math.min(cap - 1, #others) do
                list[#list + 1] = others[i].part
            end
        end
        return list
    end
    local function TurnOffOther(key)
        if Cfg[key] then
            Cfg[key] = false
            Save()
            local ctl = Farm.Toggles and Farm.Toggles[key]
            if ctl then pcall(function() ctl.Value = false end) end
        end
    end
    local function Stopped()
        if Cfg.AutoFarm or Cfg.AutoFarmThunder then return end
        B.Target = nil
        B.Status = "Idle"
        local root = MyRoot()
        if root then pcall(function() root.AssemblyLinearVelocity = Vector3.zero end) end
    end
    function Farm.OnAutoFarm(on)
        if on then TurnOffOther("AutoFarmThunder") TurnOffOther("AutoClearWave") end
        Stopped()
    end
    function Farm.OnAutoFarmThunder(on)
        if on then TurnOffOther("AutoFarm") TurnOffOther("AutoClearWave") end
        Stopped()
    end
    -- Safe Farm เป็นตัวเสริมของ Auto Farm (ลูปฟาร์มต้องมี AutoFarm หรือ AutoFarmThunder เปิดอยู่)
    function Farm.OnSafeFarm(on)
        if on and not (Cfg.AutoFarm or Cfg.AutoFarmThunder or Cfg.AutoClearWave) then
            Cfg.AutoFarm = true
            Save()
            local ctl = Farm.Toggles and Farm.Toggles.AutoFarm
            if ctl then pcall(function() ctl.Value = true end) end
            Farm.Fire("OnAutoFarm", true)
        end
    end
    -- ============================================================
    --  🧠 Auto Farm [ Smart ]: ดูว่ากำลังใช้อาวุธอะไร แล้วสลับ Auto Farm ให้ตรงกัน
    --  ตัวละครมี Attribute "Spears" (จำนวนหอกที่เหลือ) เมื่อใช้ Thunder Spears -> ฟาร์มหอก
    --  ไม่มี Attribute นี้ -> ฟาร์มดาบ | ถ้าเปิด Auto Clear Wave อยู่จะไม่ยุ่ง
    -- ============================================================
    local function HeldWeapon()
        local char = LocalPlayer.Character
        if not char then return nil end
        if type(char:GetAttribute("Spears")) == "number" then return "thunder" end
        return "blade"
    end
    local function SetFarmMode(wantThunder)
        local key, other = "AutoFarm", "AutoFarmThunder"
        if wantThunder then key, other = other, key end
        if Cfg[key] and not Cfg[other] then return end
        Cfg[other] = false
        Cfg[key] = true
        Save()
        local t = Farm.Toggles
        if t and t[other] then pcall(function() t[other].Value = false end) end
        if t and t[key] then pcall(function() t[key].Value = true end) end
        Farm.Fire(wantThunder and "OnAutoFarmThunder" or "OnAutoFarm", true)
        SH.say("Smart Auto Farm: " .. (wantThunder and "Thunder Spears" or "Blades"))
    end
    function Farm.OnAutoFarmSmart(on) end
    task.spawn(function()
        local lastSeen, same = nil, 0
        while Alive() do
            task.wait(1)
            if Cfg.AutoFarmSmart and Farm.CanUseHere() and not Cfg.AutoClearWave and not SH.QuestHold then
                local w = HeldWeapon()
                if w == nil then
                    lastSeen, same = nil, 0
                elseif w == lastSeen then
                    same += 1
                else
                    lastSeen, same = w, 1
                end
                -- ต้องเห็นอาวุธเดิมติดกัน 2 รอบก่อนสลับ (กันสลับรัวตอนเกิดใหม่/โหลดตัวละคร)
                if same >= 2 then SetFarmMode(w == "thunder") end
            else
                lastSeen, same = nil, 0
            end
        end
    end)
    local getRemote = nil
    local function Get()
        if not getRemote or not getRemote.Parent then
            local ok, r = pcall(function()
                return game:GetService("ReplicatedStorage").Assets.Remotes:WaitForChild("GET", 5)
            end)
            getRemote = ok and r or nil
        end
        return getRemote
    end
    local function SpearsLeft()
        local char = LocalPlayer.Character
        local n = char and char:GetAttribute("Spears")
        if type(n) == "number" then return n end
        return nil
    end
    Farm.SpearsLeft = SpearsLeft
    local lastSide, lastCount = 8, nil
    local usedIds = {}
    local stuck, stuckCount = 0, nil
    local stuckAt = 0
    local function NextSpearId(count)
        if lastCount ~= nil and count ~= nil and count > lastCount then usedIds = {} end
        lastCount = count
        if count == nil or count > 8 then
            usedIds = {}
            lastSide = (lastSide == 8) and 7 or 8
            return lastSide
        end
        local char = LocalPlayer.Character
        local rig = char and char:FindFirstChild("Rig_" .. LocalPlayer.Name)
        local gameUsed = {}
        for _, armName in ipairs({ "RightLowerArm", "LeftLowerArm" }) do
            local arm = rig and rig:FindFirstChild(armName)
            local folder = arm and arm:FindFirstChild("Spears")
            for _, d in ipairs(folder and folder:GetChildren() or {}) do
                if d.Name:match("^%d+$") and d:GetAttribute("Used") then gameUsed[tonumber(d.Name)] = true end
            end
        end
        local free = {}
        for id = 1, 8 do
            if not usedIds[id] and not gameUsed[id] then free[#free + 1] = id end
        end
        if #free == 0 then return nil end
        local pick = free[math.random(1, #free)]
        usedIds[pick] = true
        return pick
    end
    function Farm.SpearStuck()
        return stuck >= 4 and SpearsLeft() == stuckCount
    end
    local fireBusy, fireBusyAt = false, 0
    local function Spear(parts)
        local get, remote = Get(), Post()
        if not get or not remote then return false end
        local left = SpearsLeft()
        if left ~= nil and left <= 0 then return false end
        if stuck > 0 and left ~= stuckCount then stuck = 0 end
        if Farm.SpearStuck() then
            -- [smooth] หอกยังเหลือ = ไม่ได้หมดจริง: พัก 1s แล้วลองยิงใหม่ ไม่หยุดยิงถาวร
            if left ~= nil and left > 0 and os.clock() - stuckAt > 1 then
                stuck, usedIds = 0, {}
            else
                return false
            end
        end
        if fireBusy and os.clock() - fireBusyAt < 10 then return false end -- S_Fire ก่อนหน้ายังรอเซิร์ฟเวอร์อยู่
        local id = NextSpearId(left)
        if id == nil then
            usedIds = {}
            stuck, stuckCount, stuckAt = stuck + 1, left, os.clock()
            return false
        end
        local done = false
        fireBusy, fireBusyAt = true, os.clock()
        task.spawn(function()
            pcall(function() get:InvokeServer("Spears", "S_Fire", tostring(id)) end)
            done = true
            fireBusy = false
        end)
        local t0 = os.clock()
        while not done and os.clock() - t0 < 1.5 do task.wait() end
        -- [smooth] ไม่หน่วงตายตัว 0.35s: เช็กจำนวนหอกทุกเฟรม ออกทันทีที่ลด (เพดานรอ 1s เท่าเดิม)
        local after = SpearsLeft()
        if after == nil then task.wait(0.1) end
        local tw = os.clock()
        while left ~= nil and after ~= nil and after >= left and os.clock() - tw < 1.0 do
            task.wait()
            after = SpearsLeft()
        end
        if left ~= nil and after ~= nil and after >= left then
            usedIds[id] = nil
            stuck, stuckCount, stuckAt = stuck + 1, left, os.clock()
            if stuck == 4 then print("[SmoothHub][Thunder] S_Fire not accepted 4 times in a row, spears left =", tostring(left), "id =", tostring(id)) end
            return false
        end
        stuck = 0
        local reps = Reps(#parts)
        if NetPending() <= NET_QUEUE_MAX then
            for r = 1, reps do
                for i, part in ipairs(parts) do
                    if part and part.Parent and (PRIORITY[part] or r <= OtherMult()) then
                        NetPush(remote, "Spears", "S_Explode", part.Position, 0.10 + math.random() * 0.09)
                    end
                end
            end
        end
        for _, part in ipairs(parts) do
            if part and part.Parent then B.Hits = B.Hits + 1 end
        end
        return true
    end
    local SAFE = { start = os.clock(), zeroSince = nil, n = 0, lastLog = 0 }
    local function SafeLeft()
        local need = Cfg.SafeTime or 0
        if need <= 0 or not Farm.CanUseHere() then return 0 end
        return math.max(0, need - (os.clock() - SAFE.start))
    end
    Farm.SafeLeft = SafeLeft
    task.spawn(function()
        while Alive() do
            task.wait(0.5)
            local now = os.clock()
            if not Farm.CanUseHere() then
                SAFE.start, SAFE.zeroSince, SAFE.n = now, nil, 0
            else
                local folder = workspace:FindFirstChild("Titans")
                local n = 0
                for _, t in ipairs(folder and folder:GetChildren() or {}) do
                    if t:IsA("Model") and TitanAlive(t) then n = n + 1 end
                end
                SAFE.n = n
                if n == 0 then
                    SAFE.zeroSince = SAFE.zeroSince or now
                else
                    if SAFE.zeroSince and now - SAFE.zeroSince > 20 then SAFE.start = now end
                    SAFE.zeroSince = nil
                end
            end
        end
    end)
    local function SafeFilter(list)
        local left = SafeLeft()
        if left <= 0 then return list end
        local folder = workspace:FindFirstChild("Titans")
        if not folder then return list end
        local allowed = SAFE.n - 1
        local out, chosen, count = {}, {}, 0
        for _, part in ipairs(list) do
            local t = part
            while t and t.Parent ~= folder do t = t.Parent end
            if t then
                if chosen[t] then
                    out[#out + 1] = part
                elseif count < allowed then
                    chosen[t] = true
                    count = count + 1
                    out[#out + 1] = part
                end
            end
        end
        if #out < #list and os.clock() - SAFE.lastLog > 5 then
            SAFE.lastLog = os.clock()
            print(string.format("[SmoothHub][SafeTime] holding the last titan, %ds left (alive=%d)", math.ceil(left), SAFE.n))
        end
        return out
    end
    -- Safe Farm (Gas Mode): กดกระโดด 2 ครั้งทุก JUMP_EVERY วินาทีระหว่างฟาร์ม เพื่อให้แก๊สถูกใช้
    -- PC = ปุ่ม Space, มือถือ = ปุ่มกระโดดบนจอของ Roblox
    local JUMP_EVERY = 2     -- วินาทีที่กดค้างหลังการกดครั้งที่ 2
    local JUMP_GAP = 0.9     -- วินาทีระหว่างการกดครั้งที่ 1 และ 2
    local function FindJumpButton()
        local touchGui = PlayerGui:FindFirstChild("TouchGui")
        local frame = touchGui and touchGui:FindFirstChild("TouchControlFrame")
        local btn = frame and frame:FindFirstChild("JumpButton")
        if btn and btn:IsA("GuiObject") and btn.Visible and btn.AbsoluteSize.X > 0 then return btn end
        return nil
    end
    local function PressJump()
        local VIM = game:GetService("VirtualInputManager")
        local btn = game:GetService("UserInputService").TouchEnabled and FindJumpButton() or nil
        if btn then
            local p = btn.AbsolutePosition + btn.AbsoluteSize / 2
            local id = math.random(100000, 999999)
            pcall(function() VIM:SendTouchEvent(id, 0, p.X, p.Y) end)
            task.wait(0.05)
            pcall(function() VIM:SendTouchEvent(id, 2, p.X, p.Y) end)
        else
            pcall(function() VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game) end)
            task.wait(0.05)
            pcall(function() VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game) end)
        end
    end
    local jumpHeld = nil
    local function JumpDown()
        if jumpHeld then return end
        local VIM = game:GetService("VirtualInputManager")
        local btn = game:GetService("UserInputService").TouchEnabled and FindJumpButton() or nil
        if btn then
            local p = btn.AbsolutePosition + btn.AbsoluteSize / 2
            local id = math.random(100000, 999999)
            jumpHeld = { touch = true, id = id, x = p.X, y = p.Y }
            pcall(function() VIM:SendTouchEvent(id, 0, p.X, p.Y) end)
        else
            jumpHeld = { touch = false }
            pcall(function() VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game) end)
        end
    end
    local function JumpUp()
        local h = jumpHeld
        if not h then return end
        jumpHeld = nil
        local VIM = game:GetService("VirtualInputManager")
        if h.touch then
            pcall(function() VIM:SendTouchEvent(h.id, 2, h.x, h.y) end)
        else
            pcall(function() VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game) end)
        end
    end
    task.spawn(function()
        local function active()
            return Cfg.SafeFarm and Running() and B.Target
        end
        while Alive() do
            if active() then
                pcall(PressJump)                 -- กระโดดครั้งที่ 1 (แตะ)
                task.wait(JUMP_GAP)
                if active() then
                    pcall(JumpDown)              -- กระโดดครั้งที่ 2 แล้วกดค้าง
                    local t0 = os.clock()
                    while os.clock() - t0 < JUMP_EVERY and active() do task.wait(0.05) end
                    pcall(JumpUp)
                end
            else
                pcall(JumpUp)
                task.wait(0.2)
            end
        end
        pcall(JumpUp)
    end)
    local lastChar, readyAt = nil, 0
    task.spawn(function()
        local lastPick = 0
        local orbitAngle = 0
        while Alive() do
            local dt = RunService.Heartbeat:Wait()
            orbitAngle = (orbitAngle + ORBIT_SPEED * dt) % (math.pi * 2)
            local root, char = MyRoot()
            if char ~= lastChar then
                lastChar = char
                Farm.CharSpawnAt = os.clock()
                readyAt = os.clock() + (Cfg.StartDelay or 0)
            end
            if Cfg.AutoFarm and Running() and Farm.BladesBusy and Farm.BladesBusy() then
                B.Status = "Reloading"
                if root then pcall(function() root.AssemblyLinearVelocity = Vector3.zero end) end
            elseif not Running() then
                B.Target = nil
                if Cfg.AutoFarm or Cfg.AutoFarmThunder then B.Status = "Paused" else B.Status = "Idle" end
            elseif not root then
                B.Target = nil
                B.Status = "Waiting for character"
            elseif os.clock() < readyAt then
                B.Status = "Start delay"
            elseif Farm.BossBlock() then
                B.Target = nil
                B.Status = "Waiting for boss"
                pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
            else
                if B.Target and not TitanAlive(B.Target) then
                    B.Target = nil
                    pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
                end
                if not B.Target and os.clock() - lastPick > 0.4 then
                    lastPick = os.clock()
                    B.Target = PickTitan(root)
                end
                local nape = B.Target and NapeOf(B.Target)
                if nape then
                    local offset = Vector3.new(0, math.max(Cfg.FlyHeight or 150, 0), 0)
                    if ORBIT_ON then
                        offset = offset + Vector3.new(
                            math.cos(orbitAngle) * ORBIT_RADIUS,
                            math.sin(orbitAngle * 2) * ORBIT_BOB,
                            math.sin(orbitAngle) * ORBIT_RADIUS
                        )
                    end
                    local goal = nape.Position + offset
                    local diff = goal - root.Position
                    local dist = diff.Magnitude
                    pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
                    if dist > 1 then
                        local step = math.min((Cfg.FlySpeed or 600) * dt, dist)
                        local newPos = root.Position + diff.Unit * step
                        if ORBIT_ON and dist <= ARRIVE_DIST then
                            root.CFrame = CFrame.lookAt(newPos, Vector3.new(nape.Position.X, newPos.Y, nape.Position.Z))
                        else
                            root.CFrame = CFrame.new(newPos)
                        end
                    end
                    B.Status = (dist <= ARRIVE_DIST) and "Attacking" or "Flying to titan"
                else
                    B.Target = nil
                    B.Status = "Searching for titans"
                    pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
                end
            end
        end
    end)
    -- 💥 Burst Mode (ทำงานเมื่อเปิด Damage Multiplier): ยิงเป็นชุดละ BURST_SIZE ครั้งใส่ไททัน "เฉพาะตอนบินถึงตัวแล้ว"
    -- แล้วพัก BURST_GAP วินาทีค่อยยิงชุดถัดไป (แทนการทยอยยิงทีละ 1 ใส่ไททัน 9 ตัวตลอดเวลา) | BURST_TARGETS = จำนวนไททันต่อชุด
    local BURST_MODE = false -- Blades: กลับไปแบบเดิม (ฟันหลายตัวพร้อมกันต่อรอบ) | Thunder Spears ยิงเป็นชุดแยกด้านล่าง (SPEAR_BURST)
    local BURST_SIZE = 10
    local BURST_GAP = 0.1   -- ยิงชุดแรกทันทีที่ถึงตัว | ถ้าไททันยังไม่ตาย รอครบเวลานี้ก่อนยิงชุดถัดไป
    local BURST_TARGETS = 10 -- โหมด Damage Multiplier: ยิงชุดละกี่ตัว | เดิม 1 (ถ้าปิงพุ่ง/กระตุก ลดเลขนี้ลง)
    local burstAt = 0 -- เวลายิงชุดล่าสุด (ใช้ร่วมกันทุกตัว ไม่รอไททันตัวหลักเปลี่ยน/บินถึงตัวก่อน)
    -- 🎯 Colossal Titan > Fake: ตอนมี Colossal ให้ยิงทุกชิ้นส่วน (BasePart) ในโฟลเดอร์ Fake ด้วย
    local FAKE_ENABLED = false    -- false = ปิดฟีเจอร์นี้
    local FAKE_MAX_PARTS = 30    -- จำกัดจำนวนชิ้นต่อรอบ กัน remote ท่วม (ถ้า Fake มีชิ้นเยอะมาก)
    local fakeLast = 0
    local function FakeParts()
        if not FAKE_ENABLED then return nil end
        local folder = workspace:FindFirstChild("Titans")
        local boss = folder and folder:FindFirstChild("Colossal_Titan")
        if not (boss and boss:IsA("Model") and TitanAlive(boss)) then return nil end
        local fake = boss:FindFirstChild("Fake")
        if not fake then return nil end
        local out = {}
        if fake:IsA("BasePart") then out[1] = fake end
        for _, d in ipairs(fake:GetDescendants()) do
            if d:IsA("BasePart") and d.Parent then
                out[#out + 1] = d
                if #out >= FAKE_MAX_PARTS then break end
            end
        end
        return #out > 0 and out or nil
    end
    local function SlashBurst(parts)
        local remote = Post()
        if not remote or NetPending() > NET_QUEUE_MAX then return false end
        NetPush(remote, "Attacks", "Slash", true)
        local total = 0
        for _, part in ipairs(parts) do
            local size = BURST_SIZE
            if PRIORITY[part] and MultState.full > DAMAGE_MULT then
                size = math.floor(BURST_SIZE * MultState.full / DAMAGE_MULT) -- Colossal: x30 = 3 เท่าของชุดปกติ
            end
            for _ = 1, size do
                NetPush(remote, "Hitboxes", "Register", part, 143 + math.random() * 10, 0.26 + math.random() * 0.25)
            end
            total = total + size
        end
        NetPush(remote, "Attacks", "Slash", false)
        B.Hits = B.Hits + total
        return true
    end
    local StatsSvc = game:GetService("Stats")
    local PING_BACKOFF = true   -- ตั้งเป็น false ถ้าไม่อยากให้ลดความถี่ตามปิง
    local PING_LIMIT = 350      -- ms: ปิงเกินนี้จะหน่วงช่วงโจมตีให้ห่างขึ้น
    local function PingMs()
        local ok, v = pcall(function() return StatsSvc.Network.ServerStatsItem["Data Ping"]:GetValue() end)
        return (ok and tonumber(v)) or 0
    end
    task.spawn(function()
        local partLast = setmetatable({}, { __mode = "k" })
        while Alive() do
            local gap = ATTACK_GAP[Cfg.AttackSpeed or 0] or 0.4
            if PING_BACKOFF then
                local ping = PingMs()
                if ping > PING_LIMIT then gap = gap * math.clamp(ping / PING_LIMIT, 1, 4) end
            end
            task.wait(gap)
            local target = B.Target
            local root = MyRoot()
            local bladesBusy = Farm.BladesBusy and Farm.BladesBusy()
            if Cfg.AutoFarm and Running() and root and target and TitanAlive(target) and not bladesBusy and (B.Status == "Attacking" or (ATTACK_BEFORE_ARRIVE and B.Status == "Flying to titan")) then
                local nape = NapeOf(target)
                if nape then
                    local safeList = SafeFilter(NapesAround(target))
                    local burstOn = BURST_MODE and Cfg.DamageMultiplier
                    if burstOn then
                        if #safeList > 0 and os.clock() - burstAt >= BURST_GAP then
                            burstAt = os.clock()
                            local picked = {}
                            for i = 1, math.min(BURST_TARGETS, #safeList) do picked[i] = safeList[i] end
                            SlashBurst(picked)
                        end
                    elseif #safeList > 0 then
                        Slash(safeList)
                    end
                    if #safeList > 0 then
                        local fakeParts = FakeParts()
                        if fakeParts then
                            if burstOn then
                                if B.Status == "Attacking" and os.clock() - fakeLast >= BURST_GAP then
                                    fakeLast = os.clock()
                                    Slash(fakeParts)
                                end
                            else
                                Slash(fakeParts)
                            end
                        end
                    end
                    if Cfg.HitAllParts and #safeList > 0 and SafeLeft() <= 0 and not (burstOn and B.Status ~= "Attacking") then
                        local hit = HitParts(target)
                        local cd = math.max(Cfg.PartCooldown or 7, 4)
                        for _, name in ipairs(OTHER_PARTS) do
                            local part = hit and hit:FindFirstChild(name)
                            if part and part:IsA("BasePart") and os.clock() - (partLast[part] or 0) >= cd then
                                partLast[part] = os.clock()
                                Slash(part)
                            end
                        end
                    end
                end
            end
        end
    end)
    task.spawn(function()
        local SPEAR_BURST = true   -- Thunder Spears: ยิงเป็นชุดทุก BURST_GAP วินาที (ไม่รัวต่อเนื่อง)
        local spearAt = 0          -- เวลายิงชุดล่าสุด ใช้ร่วมกันทุกตัว เปลี่ยนเป้าหมายแล้วไม่ต้องรอใหม่
        while Alive() do
            task.wait(SPEAR_BURST and 0 or math.max(ATTACK_GAP[Cfg.AttackSpeed or 0] or 0.4, 0.6))
            local target = B.Target
            local root = MyRoot()
            if Cfg.AutoFarmThunder and Running() and root and target and TitanAlive(target) and (B.Status == "Attacking" or (ATTACK_BEFORE_ARRIVE and B.Status == "Flying to titan"))
                and (not SPEAR_BURST or os.clock() - spearAt >= 0.03) then
                local safeList = SafeFilter(NapesAround(target, true))
                if #safeList > 0 then
                    if SPEAR_BURST then
                        spearAt = os.clock()
                        local picked = {}
                        for i = 1, math.min(SpearLimit(), #safeList) do picked[i] = safeList[i] end
                        safeList = picked
                    end
                    Spear(safeList)
                end
            end
        end
    end)
    -- ⚔️ Auto Clear Wave: ใช้ระบบโจมตีเดียวกับ Auto Farm [ Blades ] แต่ "ยืนอยู่กับที่" ไม่บินไปหาไททัน
    -- โจมตีไททันที่อยู่ในระยะ (Cfg.ClearWaveRange) จากตำแหน่งปัจจุบัน | เปิดตัวนี้ = Auto Farm [ Blades ] / [ TS ] ถูกปิดให้อัตโนมัติ
    Farm.ClearWaveStatus = "Off"
    function Farm.OnAutoClearWave(on)
        if on and SH.PlayOn() then
            TurnOffOther("AutoFarm")
            TurnOffOther("AutoFarmThunder")
        else
            Farm.ClearWaveStatus = "Off"
        end
    end
    task.spawn(function()
        local partLast = setmetatable({}, { __mode = "k" })
        while Alive() do
            task.wait(ATTACK_GAP[Cfg.AttackSpeed or 0] or 0.4)
            if not (Cfg.AutoClearWave and SH.PlayOn()) then
                Farm.ClearWaveStatus = (Cfg.AutoClearWave and "Waiting for Auto Play") or "Off"
            elseif not Farm.CanUseHere() then
                Farm.ClearWaveStatus = "Waiting for wave mode"
            elseif Farm.BossBlock() then
                Farm.ClearWaveStatus = "Waiting for boss"
            elseif Farm.FailSafeActive then
                Farm.ClearWaveStatus = "Paused (Fail Safe is losing on purpose)"
            elseif Farm.Refilling then
                Farm.ClearWaveStatus = "Paused (refilling)"
            elseif Farm.BladesBusy and Farm.BladesBusy() then
                Farm.ClearWaveStatus = "Reloading blades"
            else
                local root = MyRoot()
                local folder = workspace:FindFirstChild("Titans")
                if not root then
                    Farm.ClearWaveStatus = "Waiting for character"
                elseif not folder then
                    Farm.ClearWaveStatus = "No titans yet"
                else
                    local range = Cfg.ClearWaveRange or 300
                    local best, bestD, alive = nil, math.huge, 0
                    for _, t in ipairs(folder:GetChildren()) do
                        if t:IsA("Model") and TitanAlive(t) then
                            alive += 1
                            local nape = NapeOf(t)
                            if nape then
                                local d = (nape.Position - root.Position).Magnitude
                                if d <= range and d < bestD then best, bestD = t, d end
                            end
                        end
                    end
                    if not best then
                        Farm.ClearWaveStatus = (alive == 0) and "No titans alive" or ("No titan in range (%d alive)"):format(alive)
                    else
                        local list = {}
                        for _, part in ipairs(SafeFilter(NapesAround(best))) do
                            if (part.Position - root.Position).Magnitude <= range then list[#list + 1] = part end
                        end
                        if #list > 0 then
                            Slash(list)
                            Farm.ClearWaveStatus = ("Clearing: hitting %d titan(s) in range (%d alive)"):format(#list, alive)
                            if Cfg.HitAllParts and SafeLeft() <= 0 then
                                local hit = HitParts(best)
                                local cd = math.max(Cfg.PartCooldown or 7, 4)
                                for _, name in ipairs(OTHER_PARTS) do
                                    local part = hit and hit:FindFirstChild(name)
                                    if part and part:IsA("BasePart") and os.clock() - (partLast[part] or 0) >= cd
                                        and (part.Position - root.Position).Magnitude <= range then
                                        partLast[part] = os.clock()
                                        Slash(part)
                                    end
                                end
                            end
                        else
                            Farm.ClearWaveStatus = "Holding the last titan (Safe Time)"
                        end
                    end
                end
            end
        end
    end)
    local ncParts, ncChar, ncAdded, ncStepped = {}, nil, nil, nil
    ncStepped = RunService.Stepped:Connect(function()
        if not Alive() then
            if ncAdded then ncAdded:Disconnect() ncAdded = nil end
            if ncStepped then ncStepped:Disconnect() end
            return
        end
        if not Cfg.NoClip or not Running() then return end
        local _, char = MyRoot()
        if not char then return end
        if char ~= ncChar then
            ncChar = char
            if ncAdded then ncAdded:Disconnect() end
            ncParts = {}
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then ncParts[#ncParts + 1] = p end
            end
            ncAdded = char.DescendantAdded:Connect(function(d)
                if d:IsA("BasePart") then ncParts[#ncParts + 1] = d end
            end)
        end
        for i = #ncParts, 1, -1 do
            local p = ncParts[i]
            if p.Parent then
                if p.CanCollide then p.CanCollide = false end
            else
                table.remove(ncParts, i)
            end
        end
    end)
end
do
    local token = tostring(os.clock()) .. "_" .. tostring(math.random(100000, 999999))
    local lastBeat, lastBeatAt = nil, 0
    local function Get(name) return LocalPlayer:GetAttribute(name) end
    local function Fresh()
        local beat = Get("SH_Beat")
        if beat == nil or Get("SH_ActorToken") ~= token then return false end
        if beat ~= lastBeat then lastBeat, lastBeatAt = beat, os.clock() end
        return os.clock() - lastBeatAt < 2
    end
    function Farm.ActorActive() return Fresh() end
    local TRUST_ACTOR = false
    function Farm.ActorSegments() if TRUST_ACTOR and Fresh() then return tonumber(Get("SH_Segments")) end return nil end
    function Farm.ActorReloads() if TRUST_ACTOR and Fresh() then return tonumber(Get("SH_Reloads")) end return nil end
    local CODE = [==[
        local TOKEN = "__TOKEN__"
        pcall(task.synchronize)
        repeat task.wait() until game:IsLoaded()
        local LP = game:GetService("Players").LocalPlayer
        local Host
        for _, c in ipairs(filtergc("table", { Keys = { "Modules", "Cache", "Invoked", "Services" } }, false)) do
            if type(c) == "table" and type(c.Modules) == "table" and type(c.Cache) == "table"
                and c.Cache.Player == LP and type(c.Modules.ODMG) == "table" then
                Host = c
                break
            end
        end
        if not Host then return end
        local beat, lastDump = 0, nil
        local function Flat(t, depth, seen)
            local parts = {}
            if type(t) ~= "table" then return tostring(t) end
            seen = seen or {}
            if seen[t] then return "<cycle>" end
            seen[t] = true
            local keys = {}
            for k in pairs(t) do keys[#keys + 1] = k end
            table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
            for _, k in ipairs(keys) do
                local v = t[k]
                local tv = type(v)
                if tv == "number" or tv == "string" or tv == "boolean" then
                    parts[#parts + 1] = tostring(k) .. "=" .. tostring(v)
                elseif tv == "table" and depth > 0 then
                    parts[#parts + 1] = tostring(k) .. "={" .. Flat(v, depth - 1, seen) .. "}"
                elseif tv == "table" then
                    parts[#parts + 1] = tostring(k) .. "={..}"
                elseif tv == "function" then
                    parts[#parts + 1] = tostring(k) .. "()"
                elseif tv == "userdata" or tv == "Instance" then
                    parts[#parts + 1] = tostring(k) .. "=<" .. typeof(v) .. ">"
                end
            end
            return table.concat(parts, "; ")
        end
        local function Dump()
            print("[SmoothHub][ActorDump] ---- begin ----")
            print("[SmoothHub][ActorDump] Loadout: " .. Flat(Host.Loadout, 2))
            print("[SmoothHub][ActorDump] Cache: " .. Flat(Host.Cache, 0))
            if type(Host.Modules) == "table" then
                local names = {}
                for k, v in pairs(Host.Modules) do names[#names + 1] = tostring(k) .. "(" .. typeof(v) .. ")" end
                table.sort(names)
                print("[SmoothHub][ActorDump] Modules: " .. table.concat(names, ", "))
                for _, k in ipairs({ "Spears", "Spear", "ThunderSpears", "ThunderSpear", "TS", "Weapons", "Weapon", "Combat", "Attacks" }) do
                    local m = Host.Modules[k]
                    if type(m) == "table" then print("[SmoothHub][ActorDump] Module " .. k .. ": " .. Flat(m, 0)) end
                end
            end
            local ODMG = Host.Modules and Host.Modules.ODMG
            if type(ODMG) == "table" then
                print("[SmoothHub][ActorDump] ODMG: " .. Flat(ODMG, 0))
                local ch = Host.Cache and Host.Cache.Character
                if ch and type(ODMG.Rig) == "function" then
                    local ok, rig = pcall(ODMG.Rig, Host, ch)
                    print("[SmoothHub][ActorDump] Rig(ok=" .. tostring(ok) .. "): " .. (ok and Flat(rig, 2) or tostring(rig)))
                end
            end
            print("[SmoothHub][ActorDump] ---- end ----")
        end
        while LP:GetAttribute("SH_ActorToken") == TOKEN do
            task.wait(0.2)
            local req = LP:GetAttribute("SH_DumpRequest")
            if req ~= nil and req ~= lastDump then
                lastDump = req
                pcall(Dump)
            end
            local loadout = Host.Loadout
            local supply = loadout and loadout.Supply
            local seg = supply and tonumber(supply.Segments)
            local rel = supply and tonumber(supply.Reloads)
            beat = beat + 1
            if type(supply) == "table" then
                local parts = {}
                for k, v in pairs(supply) do
                    local tv = type(v)
                    if tv == "number" or tv == "string" or tv == "boolean" then parts[#parts + 1] = tostring(k) .. "=" .. tostring(v) end
                end
                table.sort(parts)
                LP:SetAttribute("SH_SupplyDump", table.concat(parts, "; "))
            end
            LP:SetAttribute("SH_Segments", seg)
            LP:SetAttribute("SH_Reloads", rel)
            LP:SetAttribute("SH_Beat", beat)
        end
    ]==]
    local function Supported()
        return type(getactors) == "function" and type(run_on_actor) == "function" and type(filtergc) == "function"
    end
    local function Inject()
        local okA, actors = pcall(getactors)
        if not (okA and type(actors) == "table" and #actors > 0) then return false end
        token = tostring(os.clock()) .. "_" .. tostring(math.random(100000, 999999))
        LocalPlayer:SetAttribute("SH_ActorToken", token)
        for _, actor in ipairs(actors) do
            pcall(run_on_actor, actor, (CODE:gsub("__TOKEN__", function() return token end)))
        end
        return true
    end
    task.spawn(function()
        if not Supported() then
            print("[SmoothHub][Actor] executor ไม่รองรับ getactors/run_on_actor/filtergc -> ใช้วิธีเดิม")
            return
        end
        local wasLinked = false
        local lastTry = -999
        while Alive() do
            task.wait(0.5)
            if Fresh() then
                if not wasLinked then
                    wasLinked = true
                    print("[SmoothHub][Actor] เชื่อมกับระบบเกมสำเร็จ: Segments=" .. tostring(Get("SH_Segments")) .. " Reloads=" .. tostring(Get("SH_Reloads")))
                end
            else
                if wasLinked then
                    wasLinked = false
                    print("[SmoothHub][Actor] สัญญาณหลุด (ตัวละครเกิดใหม่?) -> เชื่อมใหม่")
                end
                local char = LocalPlayer.Character
                if char and os.clock() - lastTry >= 5 then
                    lastTry = os.clock()
                    Inject()
                end
            end
        end
    end)
    task.spawn(function()
        local last, lastAt = nil, 0
        while Alive() do
            task.wait(0.3)
            local dump = LocalPlayer:GetAttribute("SH_SupplyDump")
            local seg = tonumber(LocalPlayer:GetAttribute("SH_Segments"))
            if Fresh() and dump and dump ~= last and (seg == nil or seg <= 2) and os.clock() - lastAt >= 1 then
                last, lastAt = dump, os.clock()
                print("[SmoothHub][Supply] " .. dump .. " | farm=" .. tostring(Farm.Blades and Farm.Blades.Status))
            end
        end
    end)
    task.spawn(function()
        local n, last = 0, 0
        while Alive() do
            task.wait(0.5)
            if Fresh() and n < 6 and os.clock() - last >= 4 and ((Farm.BladesEmpty and Farm.BladesEmpty()) or n == 0) then
                n, last = n + 1, os.clock()
                LocalPlayer:SetAttribute("SH_DumpRequest", n)
            end
        end
    end)
    task.spawn(function()
        while Alive() do
            task.wait(0.25)
            pcall(function()
                LocalPlayer:SetAttribute("SH_AutoReload", (Cfg.AutoReload and Farm.CanUseHere()) and true or false)
            end)
        end
        pcall(function() LocalPlayer:SetAttribute("SH_ActorToken", nil) LocalPlayer:SetAttribute("SH_AutoReload", false) end)
    end)
end
do
    local RELOAD_WAIT = 1.5
    local RELOAD_RETRY = 3
    local remote = nil
    Farm.LastReload = nil
    local function BladeParts()
        local char = LocalPlayer.Character
        local rig = char and char:FindFirstChild("Rig_" .. LocalPlayer.Name)
        local list = {}
        for _, handName in ipairs({ "RightHand", "LeftHand" }) do
            local hand = rig and rig:FindFirstChild(handName)
            for _, d in ipairs(hand and hand:GetChildren() or {}) do
                if d.Name:match("^Blade_%d+$") then list[#list + 1] = d end
            end
        end
        return list
    end
    local function AllBroken()
        local parts = BladeParts()
        if #parts == 0 then return false end
        for _, p in ipairs(parts) do
            if not p:GetAttribute("Broken") then return false end
        end
        return true
    end
    Farm.BladesEmpty = function()
        if AllBroken() then return true end
        local seg = Farm.ActorSegments and Farm.ActorSegments()
        return seg ~= nil and seg <= 0
    end
    local BUSY_MAX = 8
    local emptyStart = nil
    task.spawn(function()
        local wasEmpty = false
        while Alive() do
            task.wait(0.1)
            local empty = Farm.BladesEmpty() == true
            if empty then emptyStart = emptyStart or os.clock() else emptyStart = nil end
            if wasEmpty and not empty then Farm.ReloadSettleUntil = os.clock() + 0.6 end
            wasEmpty = empty
        end
    end)
    function Farm.BladesEmptyFor() return emptyStart and (os.clock() - emptyStart) or 0 end
    function Farm.BladesBusy()
        if os.clock() < (Farm.ReloadSettleUntil or 0) then return true end
        return emptyStart ~= nil and os.clock() - emptyStart < BUSY_MAX
    end
    task.spawn(function()
        local emptySince, lastFire = nil, 0
        local rejects = 0
        while Alive() do
            task.wait(0.25)
            local spare = Farm.ActorReloads and Farm.ActorReloads()
            if not Farm.BladesEmpty() then rejects = 0 Farm.ReloadRejects = 0 end
            if Cfg.AutoReload and Farm.CanUseHere() and Farm.BladesEmpty() and (spare == nil or spare > 0) and rejects < 2 then
                emptySince = emptySince or os.clock()
                if os.clock() - emptySince >= RELOAD_WAIT and os.clock() - lastFire >= RELOAD_RETRY then
                    lastFire = os.clock()
                    if not remote or not remote.Parent then
                        local ok, r = pcall(function()
                            return game:GetService("ReplicatedStorage").Assets.Remotes:WaitForChild("GET", 5)
                        end)
                        remote = ok and r or nil
                    end
                    if remote then
                        local ok, res = pcall(function() return remote:InvokeServer("Blades", "Reload") end)
                        Farm.LastReload = ok and res or ("error: " .. tostring(res))
                        if ok and res then rejects = 0 else rejects = rejects + 1 end
                        Farm.ReloadRejects = rejects
                        print("[SmoothHub][Reload] fire | result=" .. tostring(Farm.LastReload)
                            .. " | Segments=" .. tostring(LocalPlayer:GetAttribute("SH_Segments"))
                            .. " Reloads=" .. tostring(LocalPlayer:GetAttribute("SH_Reloads")) .. " AllBroken=" .. tostring(AllBroken()))
                    end
                end
            else
                emptySince = nil
            end
        end
    end)
end
do
    local REFILL_PLACES = {
        [13379349730]     = { "Unclimbable", "Props", "HQ" },
        [14012874501]     = { "Unclimbable", "Props", "HQ" },
        [13904207646]     = { "Climbable", "_Walls", "Gate" },
        [14638336319]     = { "Unclimbable", "Camps", "Camp" },
        [15220308770]     = { "Climbable", "Utgard" },
        [17688739434]     = { "Unclimbable", "World", "Buildings", "Hanger" },
        [15824912319]     = { "Unclimbable", "Props", "HQ" },
        [126678335159530] = { "Unclimbable", "Reloads" },
    }
    local EMPTY_WAIT = 1.5
    local TRIES = 2
    local CHECK_WAIT = 3
    local COOLDOWN = 15
    local RETRY_AFTER_FAIL = 6
    local lastRefill = -999
    local function Log(...) print("[SmoothHub][Refill]", ...) end
    local Status = "Idle"
    Farm.RefillStatus = function() return Status end
    local stations = nil
    local function Collect(container)
        local list = {}
        for _, d in ipairs(container:GetDescendants()) do
            if d.Name == "Refill" then list[#list + 1] = d end
        end
        return list
    end
    local function PosOf(inst)
        local ok, pos = pcall(function()
            if inst:IsA("BasePart") then return inst.Position end
            if inst:IsA("Model") then return inst:GetPivot().Position end
            local part = inst:FindFirstChildWhichIsA("BasePart", true)
            return part and part.Position or nil
        end)
        return ok and pos or nil
    end
    local function NearestStation(root)
        local valid = stations and #stations > 0
        if valid then
            for _, st in ipairs(stations) do
                if not st.Parent then valid = false break end
            end
        end
        if not valid then
            stations = {}
            local uncl = workspace:FindFirstChild("Unclimbable")
            local obj = uncl and uncl:FindFirstChild("Objective")
            local waveFolder = obj and obj:FindFirstChild("Waves")
            if waveFolder then stations = Collect(waveFolder) end
            if #stations == 0 then
                local container = workspace
                local path = REFILL_PLACES[game.PlaceId]
                if path then
                    local cur = workspace
                    for _, name in ipairs(path) do cur = cur and cur:FindFirstChild(name) end
                    if cur then container = cur end
                end
                stations = Collect(container)
                if #stations == 0 and container ~= workspace then stations = Collect(workspace) end
            end
        end
        local best, bestDist = nil, math.huge
        for _, st in ipairs(stations) do
            local pos = PosOf(st)
            if pos then
                local d = (pos - root.Position).Magnitude
                if d < bestDist then best, bestDist = st, d end
            end
        end
        return best
    end
    local function Rig()
        local char = LocalPlayer.Character
        return char and char:FindFirstChild("Rig_" .. LocalPlayer.Name)
    end
    local function SpareLeft()
        local actorReloads = Farm.ActorReloads and Farm.ActorReloads()
        if actorReloads ~= nil then return actorReloads end
        local rig = Rig()
        local torso = rig and rig:FindFirstChild("LowerTorso")
        if not torso then return nil end
        local total, left = 0, 0
        for _, d in ipairs(torso:GetChildren()) do
            if d.Name:match("^Left_%d+$") then
                total = total + 1
                if not d:GetAttribute("Used") then left = left + 1 end
            end
        end
        if total == 0 then return nil end
        return left
    end
    Farm.BladeSpare = SpareLeft
    local function NeedBladeRaw()
        if not (Farm.BladesEmpty and Farm.BladesEmpty()) then return false end
        local sp = SpareLeft()
        if sp == 0 then return true end
        if sp == nil then
            return (Farm.ReloadRejects or 0) >= 2 or (Farm.BladesEmptyFor and Farm.BladesEmptyFor() or 0) >= 5
        end
        return false
    end
    local function NeedBlade() return Cfg.AutoRefillsBlade and NeedBladeRaw() end
    local function NeedThunderRaw()
        local n = Farm.SpearsLeft and Farm.SpearsLeft()
        if n ~= nil and n <= 0 then return true end
        return Farm.SpearStuck ~= nil and Farm.SpearStuck() == true
    end
    local function NeedThunder() return Cfg.AutoRefillsThunder and NeedThunderRaw() end
    local function RefillsLeft()
        local n = LocalPlayer:GetAttribute("Refills")
        if type(n) == "number" then return n end
        return nil
    end
    -- คืน true ถ้าเติมสำเร็จ
    local function DoRefill()
        local ok0, post = pcall(function()
            return game:GetService("ReplicatedStorage").Assets.Remotes:WaitForChild("POST", 5)
        end)
        if not ok0 or not post then Status = "POST remote not found" return false end

        local function PressPrompt(prompt)
            if type(fireproximityprompt) == "function" and pcall(fireproximityprompt, prompt) then return true end
            return pcall(function()
                prompt:InputHoldBegin()
                task.wait((prompt.HoldDuration or 0) + 0.15)
                prompt:InputHoldEnd()
            end)
        end

        local function PressRKey(prompt)
            local hold = (prompt and prompt.HoldDuration or 0) + 0.2
            local VIM = game:GetService("VirtualInputManager")
            pcall(function() VIM:SendKeyEvent(true, Enum.KeyCode.R, false, game) end)
            task.wait(hold)
            pcall(function() VIM:SendKeyEvent(false, Enum.KeyCode.R, false, game) end)
        end

        local function PromptOf(station)
            local p = station:FindFirstChildWhichIsA("ProximityPrompt", true)
            if not p and station.Parent then
                p = station.Parent:FindFirstChildWhichIsA("ProximityPrompt", true)
            end
            return p
        end

        local function PromptPos(prompt, station)
            local par = prompt and prompt.Parent
            if par and par:IsA("BasePart") then return par.Position end
            if par and par:IsA("Attachment") then return par.WorldPosition end
            return PosOf(station)
        end

        local REFILL_SPEED = 800
        local function TweenToPos(root, targetPos)
            local dist = (root.Position - targetPos).Magnitude
            local t = math.clamp(dist / REFILL_SPEED, 0.1, 6)
            local ok, tw = pcall(function()
                return game:GetService("TweenService"):Create(
                    root,
                    TweenInfo.new(t, Enum.EasingStyle.Linear),
                    { CFrame = CFrame.new(targetPos) }
                )
            end)
            if not ok or not tw then
                pcall(function() root.CFrame = CFrame.new(targetPos) end)
                return
            end
            local vel = game:GetService("RunService").Heartbeat:Connect(function()
                pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
            end)
            tw:Play()
            local t0 = os.clock()
            while os.clock() - t0 < t + 0.3 and tw.PlaybackState == Enum.PlaybackState.Playing and Alive() do
                task.wait()
            end
            pcall(function() tw:Cancel() end)
            vel:Disconnect()
        end

        local isMobile = game:GetService("UserInputService").TouchEnabled
        local refillsBefore = RefillsLeft()
        -- เติมสำเร็จ = ไม่ต้องเติมแล้ว หรือจำนวน Refills ของผู้เล่นลดลง (เซิร์ฟเวอร์รับคำสั่งแล้ว แม้การตรวจจับดาบยังไม่อัปเดต)
        local function Done()
            if not (NeedBlade() or NeedThunder()) then return true end
            local now = RefillsLeft()
            return refillsBefore ~= nil and now ~= nil and now < refillsBefore
        end
        local function WaitDone(sec)
            local t0 = os.clock()
            while os.clock() - t0 < sec do
                if Done() then return true end
                task.wait(0.2)
            end
            return Done()
        end

        for attempt = 1, TRIES do
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not (root and hum and hum.Health > 0) then break end

            local station = NearestStation(root)
            if not station then Status = "Refill station not found" break end

            Log(string.format("reason | spears=%s stuck=%s bladeNeed=%s refills=%s mobile=%s station=%s",
                tostring(Farm.SpearsLeft and Farm.SpearsLeft()), tostring(Farm.SpearStuck and Farm.SpearStuck()),
                tostring(NeedBladeRaw()), tostring(RefillsLeft()), tostring(isMobile), station:GetFullName()))

            -- ขั้น 1: ส่ง Remote ตรงๆ โดยไม่ขยับตัว (ใช้ทุกแพลตฟอร์ม รวมมือถือ)
            Status = ("Refilling (%d/%d) remote"):format(attempt, TRIES)
            pcall(function() post:FireServer("Attacks", "Reload", station) end)
            if WaitDone(2.5) then
                Status = "Refilled"
                Log("ok | remote")
                Farm.Refilling = false
                return true
            end

            -- ขั้น 2: ไม่สำเร็จ -> ไปที่สถานี กดปุ่ม/พรอมต์จริง แล้วยิง Remote ซ้ำ จากนั้นกลับที่เดิม
            Status = ("Refilling (%d/%d) at station"):format(attempt, TRIES)
            local prompt = PromptOf(station)
            local back = root.CFrame
            local pos = PromptPos(prompt, station)
            Farm.Refilling = true
            if pos then
                TweenToPos(root, pos + Vector3.new(0, 3, 0))
                task.wait(0.3)
            end
            if prompt then
                PressPrompt(prompt)
            else
                PressRKey(nil)
            end
            task.wait(0.4)
            pcall(function() post:FireServer("Attacks", "Reload", station) end)
            local done = WaitDone(CHECK_WAIT)
            local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if r then TweenToPos(r, back.Position) end
            Farm.Refilling = false
            if done then
                Status = "Refilled"
                Log("ok | at station | prompt=" .. tostring(prompt ~= nil))
                return true
            end
            Status = "Refill failed, retrying"
            Log(("failed attempt %d | prompt=%s refills=%s need=%s"):format(attempt, tostring(prompt ~= nil), tostring(RefillsLeft()), tostring(NeedBlade() or NeedThunder())))
        end

        Farm.Refilling = false
        return false
    end
    local WaveStatus = "Off"
    Farm.WaveRefillStatus = function() return WaveStatus end
    local WAVE_COOLDOWN = 10
    local lastWaveRefill = -999
    local function WaveFolder()
        local u = workspace:FindFirstChild("Unclimbable")
        local o = u and u:FindFirstChild("Objective")
        return o and o:FindFirstChild("Waves")
    end
    local function WaveNeed()
        if Cfg.AutoFarmThunder or Cfg.UseThunderSpears then return NeedThunderRaw() end
        return NeedBladeRaw()
    end
    local function PromptOf(station)
        local p = station:FindFirstChildWhichIsA("ProximityPrompt", true)
        if not p and station.Parent then p = station.Parent:FindFirstChildWhichIsA("ProximityPrompt", true) end
        return p
    end
    local function PromptPos(prompt, station)
        local par = prompt and prompt.Parent
        if par and par:IsA("BasePart") then return par.Position end
        if par and par:IsA("Attachment") then return par.WorldPosition end
        return PosOf(station)
    end
    local WAVE_SPEED = 1000
    local function TweenTo(root, cf)
        local dist = (root.Position - cf.Position).Magnitude
        local t = math.clamp(dist / WAVE_SPEED, 0.15, 8)
        local ok, tw = pcall(function()
            return game:GetService("TweenService"):Create(root, TweenInfo.new(t, Enum.EasingStyle.Linear), { CFrame = cf })
        end)
        if not ok or not tw then
            pcall(function() root.CFrame = cf end)
            return
        end
        local vel = game:GetService("RunService").Heartbeat:Connect(function()
            pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
        end)
        tw:Play()
        local t0 = os.clock()
        while os.clock() - t0 < t + 0.3 and tw.PlaybackState == Enum.PlaybackState.Playing and Alive() do
            task.wait()
        end
        pcall(function() tw:Cancel() end)
        vel:Disconnect()
    end
    local function PromptCount(prompt)
        if not prompt then return nil end
        local txt = tostring(prompt.ObjectText or "") .. " " .. tostring(prompt.ActionText or "")
        local n = txt:match("(%d+)%s*/%s*%d+")
        return n and tonumber(n) or nil
    end
    local function PressPrompt(prompt)
        if type(fireproximityprompt) == "function" then
            if pcall(fireproximityprompt, prompt) then return end
        end
        pcall(function()
            prompt:InputHoldBegin()
            task.wait((prompt.HoldDuration or 0) + 0.15)
            prompt:InputHoldEnd()
        end)
    end
    local function PressR(prompt)
        local hold = (prompt and prompt.HoldDuration or 0) + 0.2
        local VIM = game:GetService("VirtualInputManager")
        pcall(function() VIM:SendKeyEvent(true, Enum.KeyCode.R, false, game) end)
        task.wait(hold)
        pcall(function() VIM:SendKeyEvent(false, Enum.KeyCode.R, false, game) end)
    end
    local function DoWaveRefill()
        local folder = WaveFolder()
        if not folder then WaveStatus = "Not in wave mode" return false end
        local list = Collect(folder)
        local post = nil
        pcall(function() post = game:GetService("ReplicatedStorage").Assets.Remotes:FindFirstChild("POST") end)
        local success = false
        for attempt = 1, 3 do
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not (root and hum and hum.Health > 0) then break end
            local station, bestD = nil, math.huge
            for _, st in ipairs(list) do
                local pos = st.Parent and PosOf(st)
                if pos then
                    local d = (pos - root.Position).Magnitude
                    if d < bestD then station, bestD = st, d end
                end
            end
            if not station then WaveStatus = "Wave refill station not found" break end
            local prompt = PromptOf(station)
            local pos = PromptPos(prompt, station)
            if not pos then WaveStatus = "Refill position not found" break end
            WaveStatus = ("Going to refill (%d/3)"):format(attempt)
            local back = root.CFrame
            Farm.Refilling = true
            TweenTo(root, CFrame.new(pos + Vector3.new(0, 3, 0)))
            task.wait(0.2)
            WaveStatus = ("Refilling (%d/3)"):format(attempt)
            local before = PromptCount(prompt)
            Log(string.format("wave refill #%d via %s | prompt=%s Refills=%s | %s", attempt,
                attempt == 1 and "prompt" or (attempt == 2 and "key R" or "remote"),
                tostring(prompt ~= nil), tostring(LocalPlayer:GetAttribute("Refills")), station:GetFullName()))
            if attempt == 1 then
                if prompt then PressPrompt(prompt) else PressR(nil) end
            elseif attempt == 2 then
                PressR(prompt)
            elseif post then
                pcall(function() post:FireServer("Attacks", "Reload", station) end)
            end
            local t1 = os.clock()
            while os.clock() - t1 < 5 and WaveNeed() do task.wait(0.2) end
            local still = WaveNeed()
            local after = PromptCount(prompt)
            if still and before ~= nil and after ~= nil and after < before then
                task.wait(2)
                still = WaveNeed()
            end
            local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if r then TweenTo(r, back) end
            Farm.Refilling = false
            if not still then
                WaveStatus = "Refilled"
                success = true
                break
            end
            WaveStatus = "Refill failed, retrying"
        end
        Farm.Refilling = false
        return success
    end
    task.spawn(function()
        local since = nil
        local failStreak = 0      -- เติมไม่สำเร็จติดกันกี่ครั้ง (ล้มเกิน 3 ครั้ง = พักนานขึ้น ไม่บินวนไปหาสถานีจนฟาร์มหยุด)
        local npcBusySince = nil  -- กัน Farm.NpcBusy ค้างจนเติมไม่ได้อีกเลย
        while Alive() do
            task.wait(0.4)
            if Farm.NpcBusy then
                npcBusySince = npcBusySince or os.clock()
                if os.clock() - npcBusySince > 90 and Cfg.AutoRefillWave and SH.PlayOn() and WaveNeed() then
                    Log("wave refill: NpcBusy stuck on " .. tostring(Farm.NpcCurrent) .. " for 90s, releasing")
                    pcall(function() Farm.NpcRelease() end)
                    npcBusySince = nil
                end
            else
                npcBusySince = nil
            end
            -- pcall: ถ้าข้างในพัง 1 ครั้ง ลูปนี้ต้องไม่ตาย (เดิมไม่มี pcall = error ครั้งเดียวทำให้เติมไม่ทำงานอีกจนจบเกม และ Farm.Refilling อาจค้างเป็น true จนฟาร์มหยุดด้วย)
            local okLoop, errLoop = pcall(function()
                if not (Cfg.AutoRefillWave and SH.PlayOn()) then
                    WaveStatus = "Off"
                    since = nil
                    failStreak = 0
                elseif not Farm.CanUseHere() or not WaveFolder() then
                    WaveStatus = "Waiting for wave mode"
                    since = nil
                elseif WaveNeed() then
                    since = since or os.clock()
                    if os.clock() - since >= EMPTY_WAIT and os.clock() - lastWaveRefill >= WAVE_COOLDOWN and not Farm.NpcBusy then
                        local ok = DoWaveRefill()
                        if ok then
                            failStreak = 0
                            lastWaveRefill = os.clock()
                            since = nil
                        else
                            failStreak += 1
                            if failStreak >= 3 then
                                -- ล้มติดกัน 3 รอบ: พัก 30 วิ ค่อยลองใหม่ แทนที่จะวนไปสถานีทุก 3 วิ
                                lastWaveRefill = os.clock() - WAVE_COOLDOWN + 30
                                WaveStatus = ("Refill failed x%d (Refills=%s), retry in 30s"):format(failStreak, tostring(LocalPlayer:GetAttribute("Refills")))
                                Log("wave refill failed x" .. failStreak .. " Refills=" .. tostring(LocalPlayer:GetAttribute("Refills")))
                            else
                                lastWaveRefill = os.clock() - WAVE_COOLDOWN + 3
                            end
                            since = os.clock() - EMPTY_WAIT
                        end
                    end
                else
                    since = nil
                    failStreak = 0
                    if WaveStatus ~= "Refilled" then WaveStatus = "Ready" end
                end
            end)
            if not okLoop then
                Farm.Refilling = false
                WaveStatus = "Error, retrying"
                lastWaveRefill = os.clock() - WAVE_COOLDOWN + 3
                Log("wave refill error: " .. tostring(errLoop))
                task.wait(1)
            end
        end
    end)
    task.spawn(function()
        local lastLog = 0
        while Alive() do
            task.wait(1)
            if Cfg.AutoRefillsBlade and os.clock() - lastLog >= 3 then
                local empty = Farm.BladesEmpty and Farm.BladesEmpty()
                local spare = SpareLeft()
                if empty or spare == 0 then
                    lastLog = os.clock()
                    print(string.format("[SmoothHub][RefillCheck] empty=%s spare=%s need=%s refills=%s actorFresh=%s seg=%s rel=%s canUse=%s status=%s",
                        tostring(empty), tostring(spare), tostring(NeedBlade()), tostring(LocalPlayer:GetAttribute("Refills")),
                        tostring(Farm.ActorActive and Farm.ActorActive()), tostring(LocalPlayer:GetAttribute("SH_Segments")),
                        tostring(LocalPlayer:GetAttribute("SH_Reloads")), tostring(Farm.CanUseHere()), tostring(Status)))
                end
            end
        end
    end)
    task.spawn(function()
        local since = nil
        while Alive() do
            task.wait(0.4)
            if Farm.CanUseHere() and not (Cfg.AutoRefillWave and SH.PlayOn() and WaveFolder()) and (NeedBlade() or NeedThunder()) then
                since = since or os.clock()
                if os.clock() - since >= EMPTY_WAIT and os.clock() - lastRefill >= COOLDOWN then
                    local left = RefillsLeft()
                    if left ~= nil and left <= 0 then
                        Status = "No Refills left"
                        since = os.clock() + 30
                    else
                        local okRefill = DoRefill()
                        -- สำเร็จ: พัก COOLDOWN เต็ม | ล้มเหลว: ลองใหม่เร็วขึ้น (RETRY_AFTER_FAIL วินาที)
                        lastRefill = os.clock() - (okRefill and 0 or (COOLDOWN - RETRY_AFTER_FAIL))
                        since = nil
                    end
                end
            else
                since = nil
                if Status ~= "Idle" and not Farm.Refilling then Status = "Idle" end
            end
        end
    end)
end
do
    local LOBBY_PLACE_ID = 14916516914
    local CHECK_INTERVAL = 1.0
    local SCAN_INTERVAL = 2.0
    local CONFIRM_TIME = 1.5
    local GONE_TIME = 3.0
    local MAX_RETRY_TRIES = 4
    local RETRY_GAP = 3
    local MAX_LEAVE_TRIES = 2
    local LEAVE_GAP = 12
    local CALL_TIMEOUT = 8
    local function Status(text)
        if Farm.SetRetryStatus then Farm.SetRetryStatus(text) end
    end
    local function CanUseHere()
        return not IN_MENU and game.PlaceId ~= LOBBY_PLACE_ID
    end
    local function CleanText(o)
        local t = (o.Text or ""):gsub("<[^>]->", "")
        t = t:gsub("^%s+", ""):gsub("%s+$", "")
        return t
    end
    local function IsShownGui(obj)
        local cur = obj
        while cur and cur ~= PlayerGui do
            if cur:IsA("GuiObject") and not cur.Visible then return false end
            if cur:IsA("ScreenGui") and not cur.Enabled then return false end
            cur = cur.Parent
        end
        return obj:IsA("GuiObject") and obj.AbsoluteSize.X > 0 and obj.AbsoluteSize.Y > 0
    end
    local titleLabel, scanAt = nil, 0
    local function FindCompleteTitle()
        if titleLabel and titleLabel.Parent then
            return IsShownGui(titleLabel) and titleLabel or nil
        end
        titleLabel = nil
        if os.clock() - scanAt < SCAN_INTERVAL then return nil end
        scanAt = os.clock()
        local n = 0
        for _, d in ipairs(PlayerGui:GetDescendants()) do
            n += 1
            if n % 800 == 0 then task.wait() end
            if (d:IsA("TextLabel") or d:IsA("TextButton")) and CleanText(d):upper() == "MISSION COMPLETED" then
                titleLabel = d
                return IsShownGui(d) and d or nil
            end
        end
        return nil
    end
    Farm.CompleteScreenShown = function() return FindCompleteTitle() ~= nil end
    local function FindButtonText(title, pattern)
        local cur = title.Parent
        for _ = 1, 8 do
            if not cur or cur == PlayerGui then break end
            for _, d in ipairs(cur:GetDescendants()) do
                if (d:IsA("TextLabel") or d:IsA("TextButton")) and CleanText(d):upper():match(pattern) and IsShownGui(d) then
                    return d
                end
            end
            cur = cur.Parent
        end
        return nil
    end
    local function ClickableFor(label)
        if label:IsA("GuiButton") then return label end
        local cur = label.Parent
        for _ = 1, 3 do
            if not cur or cur == PlayerGui then break end
            if cur:IsA("GuiButton") then return cur end
            cur = cur.Parent
        end
        local c = label.AbsolutePosition + label.AbsoluteSize / 2
        local best, bestArea = nil, math.huge
        for _, d in ipairs(PlayerGui:GetDescendants()) do
            if d:IsA("GuiButton") and IsShownGui(d) then
                local pos, size = d.AbsolutePosition, d.AbsoluteSize
                if c.X >= pos.X and c.X <= pos.X + size.X and c.Y >= pos.Y and c.Y <= pos.Y + size.Y then
                    local area = size.X * size.Y
                    if area < bestArea then best, bestArea = d, area end
                end
            end
        end
        return best
    end
    -- กดปุ่ม Retry จริงบนหน้าจอ (หมุนวิธีกดทีละรอบ: signal -> เมาส์/ทัช -> คีย์ Enter)
    local function ClickRetry(label, attempt)
        local btn = ClickableFor(label)
        if not btn then return false, "clickable not found" end
        local method = (attempt - 1) % 3 + 1
        if method == 1 and type(firesignal) ~= "function" then method = 2 end
        if method == 1 then
            pcall(firesignal, btn.Activated)
            pcall(firesignal, btn.MouseButton1Click)
        elseif method == 2 then
            local gui = btn:FindFirstAncestorOfClass("ScreenGui")
            local inset = (gui and gui.IgnoreGuiInset) and Vector2.zero or GuiService:GetGuiInset()
            local pos = btn.AbsolutePosition + btn.AbsoluteSize / 2 + inset
            pcall(function()
                VirtualInputManager:SendMouseMoveEvent(pos.X, pos.Y, game)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
                task.wait(0.06)
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
            end)
        else
            pcall(function() GuiService.SelectedObject = btn end)
            task.wait(0.1)
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
            end)
            task.wait(0.1)
            pcall(function() GuiService.SelectedObject = nil end)
        end
        return true, "method " .. method
    end
    local postRemote = nil
    local function FireLeave()
        if not postRemote or not postRemote.Parent then
            local ok, r = pcall(function()
                return game:GetService("ReplicatedStorage").Assets.Remotes:WaitForChild("POST", 5)
            end)
            postRemote = ok and r or nil
        end
        if not postRemote then return false, "remote not found" end
        return pcall(function() postRemote:FireServer("Functions", "Teleport") end)
    end
    function Farm.RefreshRetry()
        if Farm.SetRetry then Farm.SetRetry(Cfg.RetryDone) end
    end
    function Farm.ResetRetry()
        Cfg.RetryDone = 0
        Save()
        Farm.RefreshRetry()
    end
    function Farm.OnAutoRetry(on)
        if not on and Cfg.RetryDone ~= 0 then Farm.ResetRetry() end
    end
    local function TurnOffOther(key)
        if Cfg[key] then
            Cfg[key] = false
            Save()
            local ctl = Farm.Toggles and Farm.Toggles[key]
            if ctl then pcall(function() ctl.Value = false end) end
        end
    end
    function Farm.OnAutoLeave(on)
        if on then TurnOffOther("AutoLeaveWhenRetryComplete") end
    end
    function Farm.OnAutoLeaveWhenRetryComplete(on)
        if on then TurnOffOther("AutoLeave") end
    end
    if not CanUseHere() and Cfg.RetryDone ~= 0 then
        Cfg.RetryDone = 0
        Save()
    end
    Farm.RefreshRetry()
    task.spawn(function()
        local seenSince, goneSince = nil, nil
        local tries, lastTry, counted = 0, 0, false
        local leaveTries, lastLeave = 0, 0
        local screenMode = nil
        local function ResetScreenState()
            seenSince, goneSince = nil, nil
            tries, lastTry, counted = 0, 0, false
            leaveTries, lastLeave = 0, 0
            screenMode = nil
        end
        local function DoLeave(title, why)
            screenMode = "leave"
            if leaveTries >= MAX_LEAVE_TRIES or (leaveTries > 0 and os.clock() - lastLeave < LEAVE_GAP) then
                Status("Leave sent - waiting for the game")
                return
            end
            if not FindButtonText(title, "^LEAVE") then
                Status("Leave button not found")
                return
            end
            leaveTries += 1
            lastLeave = os.clock()
            Status("Leaving... (" .. why .. ")")
            local ok, err = FireLeave()
            if Farm.Debug then SH.dbg("[SmoothHub] Leave fired:", ok, err) end
            if ok then
                Status("Leave sent (" .. why .. ")")
                if Cfg.RetryDone ~= 0 then Farm.ResetRetry() end
            else
                Status("Leave failed: " .. tostring(err))
            end
        end
        local function Progress(done)
            if Cfg.AutoLeaveWhenRetryComplete then
                return ("%d/%d"):format(done, Cfg.RetryAmount)
            end
            return tostring(done) .. " / endless"
        end
        local function DoRetry(title)
            if tries >= MAX_RETRY_TRIES or (tries > 0 and os.clock() - lastTry < RETRY_GAP) then
                Status("Retry sent - waiting for the game")
                return
            end
            local btn = FindButtonText(title, "^RETRY")
            if not btn then
                Status("Retry button not found")
                return
            end
            local have, need = CleanText(btn):match("(%d+)%s*/%s*(%d+)")
            have, need = tonumber(have), tonumber(need)
            if have and need and have >= need then
                Status("Retry vote already in")
                tries = MAX_RETRY_TRIES
                return
            end
            tries += 1
            lastTry = os.clock()
            Status("Clicking Retry... (" .. Progress(Cfg.RetryDone + (counted and 0 or 1)) .. ")")
            local ok, r = ClickRetry(btn, tries)
            if Farm.Debug then SH.dbg("[SmoothHub] Retry click:", ok, r) end
            if not ok then
                Status("Retry click failed: " .. tostring(r))
                return
            end
            -- ตรวจว่ากดติดไหม: ตัวเลขโหวตบนปุ่มต้องเพิ่ม (0/1 -> 1/1) หรือปุ่มหายไป
            task.wait(1)
            local after = FindButtonText(title, "^RETRY")
            local h2 = after and tonumber((CleanText(after):match("(%d+)%s*/%s*%d+")))
            local voted = (not after) or (h2 and have and h2 > have)
            if voted then
                tries = MAX_RETRY_TRIES
                if not counted then
                    counted = true
                    Cfg.RetryDone += 1
                    Save()
                    Farm.RefreshRetry()
                end
                Status("Retry clicked (" .. Progress(Cfg.RetryDone) .. ")")
            else
                Status("Click not registered - trying another method")
            end
        end
        while Alive() do
            task.wait(CHECK_INTERVAL)
            if not (Cfg.AutoRetry or Cfg.AutoLeave or Cfg.AutoLeaveWhenRetryComplete) then
                ResetScreenState()
                Status("Off")
            elseif not CanUseHere() then
                ResetScreenState()
                Status("Not available in the lobby / menu")
            else
                local title = FindCompleteTitle()
                if not title then
                    goneSince = goneSince or os.clock()
                    if os.clock() - goneSince >= GONE_TIME then ResetScreenState() end
                    if not seenSince then
                        if Cfg.AutoRetry then
                            Status("Waiting for the mission to finish (" .. Progress(Cfg.RetryDone) .. ")")
                        else
                            Status("Waiting for the mission to finish")
                        end
                    end
                else
                    goneSince = nil
                    seenSince = seenSince or os.clock()
                    if os.clock() - seenSince < CONFIRM_TIME then
                        Status("Mission completed - preparing")
                    elseif screenMode == "leave" or Cfg.AutoLeave then
                        DoLeave(title, "Auto Leave")
                    elseif Cfg.AutoRetry then
                        if Cfg.AutoLeaveWhenRetryComplete and Cfg.RetryDone >= Cfg.RetryAmount then
                            DoLeave(title, ("after %d matches"):format(Cfg.RetryAmount))
                        else
                            DoRetry(title)
                        end
                    else
                        Status("Auto Leave After X Matches needs Auto Retry")
                    end
                end
            end
        end
    end)
end
do
    -- ============================================================
    --  🛟 Fail Safe: ชนะติดกันครบ N ตา -> ตาถัดไป "ยืนเฉยๆ" ให้ไททันตีจนแพ้ แล้วรีเซ็ตสตรีค
    -- ============================================================
    local TICK = 0.5
    local COUNT_AFTER = 1.0   -- หน้า MISSION COMPLETED ต้องค้างอยู่นานเท่านี้ถึงนับเป็น 1 ชัยชนะ
    local GONE_AFTER = 3.0    -- หน้าสรุปต้องหายไปนานเท่านี้ถึงจะนับตาใหม่ได้
    local winSince, goneSince, winCounted = nil, nil, false
    local lastHum, diedConn = nil, nil
    Farm.FailSafeActive = false

    local function Armed()
        local at = Cfg.FailSafeAt or 0
        return Cfg.AutoFailSafe and at > 0 and (Cfg.Streak or 0) >= at
    end
    local function Say(text)
        if Farm.SetFailSafeStatus then Farm.SetFailSafeStatus(text) end
    end
    local function ResetStreak(why)
        Cfg.Streak = 0
        Save()
        Farm.RefreshStreak()
        Farm.FailSafeActive = false
        winCounted = false
        Say("Streak reset (" .. why .. ")")
        if Farm.Debug then SH.dbg("[SmoothHub] Fail Safe: streak reset -", why) end
    end
    local function DumpScreenTexts()
        -- ช่วยหาข้อความหน้าจอแพ้: ปริ้นข้อความที่เห็นอยู่ลง F9
        local out = {}
        for _, d in ipairs(PlayerGui:GetDescendants()) do
            if d:IsA("TextLabel") and d.Visible and d.AbsoluteSize.X > 0 then
                local t = tostring(d.Text or ""):gsub("<[^>]->", ""):gsub("^%s+", ""):gsub("%s+$", "")
                if #t >= 4 and #t <= 40 and t:upper() == t and t:match("%a%a%a") then out[#out + 1] = t end
            end
        end
        print("[SmoothHub][FailSafe] visible titles after death: " .. table.concat(out, " | "))
    end

    function Farm.OnFailSafeAt() Farm.RefreshStreak() end
    function Farm.OnAutoFailSafe(on)
        if not on then
            Farm.FailSafeActive = false
            Say("Off")
        end
    end

    local function HookDeath()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum == lastHum then return end
        if diedConn then pcall(function() diedConn:Disconnect() end) diedConn = nil end
        lastHum = hum
        if hum then
            diedConn = hum.Died:Connect(function()
                if Farm.FailSafeActive then
                    task.defer(DumpScreenTexts)
                    ResetStreak("lost on purpose")
                end
            end)
        end
    end

    task.spawn(function()
        while Alive() do
            task.wait(TICK)
            if not Cfg.AutoFailSafe or (Cfg.FailSafeAt or 0) <= 0 then
                Farm.FailSafeActive = false
                winSince, goneSince, winCounted = nil, nil, false
                Say(Cfg.AutoFailSafe and "Off (Fail Safe At = 0)" or "Off")
            elseif not Farm.CanUseHere() then
                Farm.FailSafeActive = false
                winSince, goneSince, winCounted = nil, nil, false
                Say("Waiting for a match")
            else
                HookDeath()
                local shown = Farm.CompleteScreenShown and Farm.CompleteScreenShown() or false
                if shown then
                    goneSince = nil
                    winSince = winSince or os.clock()
                    Farm.FailSafeActive = false
                    if not winCounted and os.clock() - winSince >= COUNT_AFTER then
                        winCounted = true
                        Cfg.Streak = (Cfg.Streak or 0) + 1
                        Save()
                        Farm.RefreshStreak()
                        if Farm.Debug then SH.dbg("[SmoothHub] Fail Safe: win counted, streak", Cfg.Streak) end
                    end
                    Say(("Win streak %d / %d"):format(Cfg.Streak or 0, Cfg.FailSafeAt))
                else
                    winSince = nil
                    goneSince = goneSince or os.clock()
                    if os.clock() - goneSince >= GONE_AFTER then winCounted = false end
                    local armed = Armed()
                    Farm.FailSafeActive = armed
                    if armed then
                        Say("LOSING ON PURPOSE - standing still, waiting for a titan")
                    else
                        Say(("Win streak %d / %d"):format(Cfg.Streak or 0, Cfg.FailSafeAt))
                    end
                end
            end
        end
        Farm.FailSafeActive = false
    end)
end
local AutoQuestTab = MainCategory:Tab({
    Title = "Auto Quest",
    Icon = Icon("scrollFill", "checklist"),
})
local AutoQuestSection = AutoQuestTab:PageSection({
    Title = "🛠️ Auto Quest [ Thunder Spear ]",
    Subtitle = "Core features and settings"
})
SH.Guard("auto-quest-thunder", function()
    local Form = AutoQuestSection:Form()
    local function AddEmptyToggle(title, subtitle, key)
        local row = Form:Row()
        row:Left():TitleStack({ Title = title, Subtitle = subtitle })
        UiSync.Link(row:Right():Toggle({
            Value = Cfg[key],
            ValueChanged = function(self, value)
                Cfg[key] = value and true or false
                Save()
                -- TODO: ยังไม่มีระบบทำงาน (ฟังก์ชันเปล่า)
            end
        }), Cfg, key)
    end
    AddEmptyToggle("Enable", nil, "AutoQuestThunder")
    AddEmptyToggle("Auto Quest [ Thunder Spear ] Round ( 1 )", "Auto-does Round 1: stand on the 3 watchtowers. Needs Prestige 1+ and Level 80+.", "AutoQuestThunderR1")
    AddEmptyToggle("Auto Quest [ Thunder Spear ] Round ( 2 )", "Auto-does Round 2: carry the 3 supply crates. Needs Prestige 1+ and Level 80+.", "AutoQuestThunderR2")
    AddEmptyToggle("Auto Quest [ Thunder Spear ] Round ( 3 )", "Auto-does Round 3: plays 3 games, then turns itself off. Needs Prestige 1+ and Level 80+.", "AutoQuestThunderR3")
    -- ===== Status: แต่ละรอบเรียก QS("ข้อความ", สี) เพื่อบอกว่ากำลังทำอะไร (สีเหลือง = กำลังทำ, "green" = จบงานรอบนั้น) =====
    local QDetail = { text = nil, color = "yellow", where = nil }
    local function QS(text, color)
        QDetail.text = text
        QDetail.color = color or "yellow"
        QDetail.where = Farm.CanUseHere() and "match" or "lobby"
    end

    -- ============================================================
    --  Round ( 1 ): ไปยืนในวงกระท่อม WatchTower_1 -> 2 -> 3 ให้สร้างเสร็จ
    --  แล้วปล่อยให้ฟาร์มไททันตามปกติ (คืนค่า Auto Farm เดิม)
    --  เดินทางด้วย Tween ความเร็ว 300
    -- ============================================================
    local RunService = game:GetService("RunService")
    local TWEEN_SPEED = 300
    local TOWER_COUNT = 3
    local STAND_UP = 3 -- ยกตัวขึ้นจากกลางวงเล็กน้อย

    local function R1On() return Alive() and Cfg.AutoQuestThunderR1 end
    local function MyRoot()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if root and hum and hum.Health > 0 then return root end
        return nil
    end
    local function SetFlag(key, value)
        Cfg[key] = value
        local ctl = Farm.Toggles and Farm.Toggles[key]
        if ctl then pcall(function() ctl.Value = value end) end
    end
    local function MoveTo(pos, on)
        on = on or R1On
        local root = MyRoot()
        if not root then return end
        pcall(function() LocalPlayer:RequestStreamAroundAsync(pos, 0.5) end)
        local cf = CFrame.new(pos) * root.CFrame.Rotation
        local t = math.max((root.Position - pos).Magnitude / TWEEN_SPEED, 0.1)
        local ok, tw = pcall(function()
            return game:GetService("TweenService"):Create(root, TweenInfo.new(t, Enum.EasingStyle.Linear), { CFrame = cf })
        end)
        if not ok or not tw then pcall(function() root.CFrame = cf end) return end
        local vel = RunService.Heartbeat:Connect(function()
            pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
        end)
        tw:Play()
        local t0 = os.clock()
        while os.clock() - t0 < t + 0.3 and tw.PlaybackState == Enum.PlaybackState.Playing and on() do task.wait() end
        pcall(function() tw:Cancel() end)
        vel:Disconnect()
        if on() then pcall(function() root.CFrame = cf end) end
    end
    local function TowerPos(model)
        local part = model.PrimaryPart
        local base = part and part.Position or model:GetPivot().Position
        return base + Vector3.new(0, STAND_UP, 0)
    end
    local function IsShown(d)
        local cur = d
        while cur and cur ~= PlayerGui do
            if cur:IsA("GuiObject") and not cur.Visible then return false end
            if cur:IsA("ScreenGui") and not cur.Enabled then return false end
            cur = cur.Parent
        end
        return true
    end
    -- กระท่อมที่ 3 เสร็จ = ขึ้นเควส Escort Supplies / แถบ Mortal Convoy
    local function EscortStarted()
        local ok, found = pcall(function()
            for _, d in ipairs(PlayerGui:GetDescendants()) do
                if d:IsA("TextLabel") and d.Text ~= "" then
                    local low = d.Text:lower()
                    if (low:find("escort supplies", 1, true) or low:find("mortal convoy", 1, true)) and IsShown(d) then
                        return true
                    end
                end
            end
            return false
        end)
        return ok and found
    end
    local lastScan, escort = -math.huge, false
    local function TowerDone(n, model)
        if not model.Parent then return true end
        if n < TOWER_COUNT then
            return workspace:FindFirstChild("WatchTower_" .. (n + 1)) ~= nil
        end
        if os.clock() - lastScan >= 1 then
            lastScan = os.clock()
            escort = EscortStarted()
        end
        return escort
    end
    local function Hold(n, model)
        local vel = RunService.Heartbeat:Connect(function()
            local root = MyRoot()
            if root then pcall(function() root.AssemblyLinearVelocity = Vector3.zero end) end
        end)
        lastScan, escort = -math.huge, false
        while R1On() and not TowerDone(n, model) do
            local root = MyRoot()
            if root and model.Parent then
                local target = TowerPos(model)
                local off = root.Position - target
                if Vector3.new(off.X, 0, off.Z).Magnitude > 12 or math.abs(off.Y) > 10 then MoveTo(target) end
            end
            task.wait(0.25)
        end
        vel:Disconnect()
    end
    local function RunRound1()
        -- ปิดฟาร์มระหว่างยืนสร้างกระท่อม (ไม่ให้บินไปไล่ไททัน) แล้วคืนค่าเดิมตอนจบ
        SH.QuestHold = true
        local was = { AutoFarm = Cfg.AutoFarm, AutoFarmThunder = Cfg.AutoFarmThunder, AutoClearWave = Cfg.AutoClearWave }
        for k, v in pairs(was) do if v then SetFlag(k, false) end end
        local completed = false
        local ok, err = pcall(function()
            for n = 1, TOWER_COUNT do
                local model
                while R1On() do
                    model = workspace:FindFirstChild("WatchTower_" .. n)
                    if model then break end
                    if not workspace:FindFirstChild("WatchTower_1") then return end -- แมพจบ/รีเซ็ตแล้ว
                    QS(("Waiting for tower %d/%d"):format(n, TOWER_COUNT))
                    task.wait(0.5)
                end
                if not (R1On() and model) then return end
                QS(("Tower %d/%d: moving"):format(n, TOWER_COUNT))
                MoveTo(TowerPos(model))
                QS(("Tower %d/%d: holding position"):format(n, TOWER_COUNT))
                Hold(n, model)
                if not R1On() then return end
            end
            completed = true
            QS("All towers done - escort started", "green")
        end)
        if not ok then SH.dbg("[SmoothHub][Quest R1]", err) end
        for k, v in pairs(was) do if v then SetFlag(k, true) end end
        SH.QuestHold = false
        return completed
    end
    task.spawn(function()
        while Alive() do
            task.wait(1)
            if Cfg.AutoQuestThunderR1 and Farm.CanUseHere() and workspace:FindFirstChild("WatchTower_1") then
                local ok, completed = pcall(RunRound1)
                if ok and completed then
                    -- รอจนแมพรีเซ็ต (WatchTower_1 หาย) หรือปิดสวิตช์ ก่อนเริ่มรอบใหม่
                    while R1On() and workspace:FindFirstChild("WatchTower_1") do task.wait(1) end
                end
            end
        end
    end)

    -- ============================================================
    --  Round ( 2 ): เก็บกล่อง ThunderSpear_Supplies1 -> 2 -> 3 ทีละกล่อง
    --  Tween ความเร็ว 300 ไปเก็บกล่อง -> กลับจุดเกิดไปวางกล่อง -> ครบ 3 กล่องแล้ว
    --  ปล่อยให้ฟาร์มไททันตามปกติ (คืนค่า Auto Farm) -> จบแมพแล้ว Auto Retry เล่นซ้ำ
    --  (ไม่ต้องป้องกันกล่อง ฟาร์มปกติอย่างเดียว)
    -- ============================================================
    local function R2On() return Alive() and Cfg.AutoQuestThunderR2 end
    local CRATE_COUNT = 3
    local CRATE_UP = 3
    local R2_DROP_POS = Vector3.new(92.71, 24.14, -306.95) -- พิกัดวางกล่อง (กำหนดเอง)
    local R2 = { spawnPos = nil, dropPos = nil, forcedRetry = false }
    SH.QuestR2 = R2

    local function CrateModel(n)
        return workspace:FindFirstChild("ThunderSpear_Supplies" .. n, true)
    end
    local function PosOfInst(inst)
        if not inst then return nil end
        if inst:IsA("BasePart") then return inst.Position end
        if inst:IsA("Attachment") then return inst.WorldPosition end
        if inst:IsA("Model") then
            local ok, cf = pcall(function() return inst:GetPivot() end)
            if ok and cf then return cf.Position end
        end
        local part = inst:FindFirstChildWhichIsA("BasePart", true)
        return part and part.Position or nil
    end
    local function PromptWorldPos(prompt)
        local par = prompt and prompt.Parent
        return PosOfInst(par)
    end
    local function PressPrompt(prompt)
        local done = false
        if type(fireproximityprompt) == "function" then
            done = pcall(fireproximityprompt, prompt)
        end
        if not done then
            pcall(function()
                prompt:InputHoldBegin()
                task.wait((prompt.HoldDuration or 0) + 0.15)
                prompt:InputHoldEnd()
            end)
        end
        -- สำรอง: กดคีย์ของ prompt เอง (ค่าเริ่มต้น E)
        local key = Enum.KeyCode.E
        pcall(function() if prompt.KeyboardKeyCode ~= Enum.KeyCode.Unknown then key = prompt.KeyboardKeyCode end end)
        local VIM = game:GetService("VirtualInputManager")
        pcall(function() VIM:SendKeyEvent(true, key, false, game) end)
        task.wait((prompt.HoldDuration or 0) + 0.2)
        pcall(function() VIM:SendKeyEvent(false, key, false, game) end)
    end
    local function CratePrompt(crate)
        if not crate then return nil end
        local p = crate:FindFirstChildWhichIsA("ProximityPrompt", true)
        if not p and crate.Parent then p = crate.Parent:FindFirstChildWhichIsA("ProximityPrompt", true) end
        return p
    end
    -- กล่องยังอยู่ใน workspace.Unclimbable ตอนแบก (Parent ไม่เปลี่ยน) จึงเช็คจาก
    -- 1) กล่องผูก (Weld/Motor6D) กับตัวละคร  2) กล่องย้ายออกจากที่เดิมและติดตัวเราอยู่
    local CARRY_DIST = 12
    local origPos = {}
    local function CrateOrig(n)
        if not origPos[n] then
            local p = PosOfInst(CrateModel(n))
            if p then origPos[n] = p end
        end
        return origPos[n]
    end
    local function AttachedToChar(crate, char)
        local function linked(d)
            if d:IsA("JointInstance") or d:IsA("WeldConstraint") then
                local p0, p1 = d.Part0, d.Part1
                if p0 and p1 then
                    return (p0:IsDescendantOf(crate) and p1:IsDescendantOf(char))
                        or (p1:IsDescendantOf(crate) and p0:IsDescendantOf(char))
                end
            end
            return false
        end
        for _, d in ipairs(crate:GetDescendants()) do if linked(d) then return true end end
        for _, d in ipairs(char:GetDescendants()) do if linked(d) then return true end end
        return false
    end
    local function Carrying(n)
        local char, root = LocalPlayer.Character, MyRoot()
        local crate = CrateModel(n)
        if not (char and root and crate and crate.Parent) then return false end
        if crate:IsDescendantOf(char) then return true end
        if AttachedToChar(crate, char) then return true end
        local pos, orig = PosOfInst(crate), origPos[n]
        if pos and orig and (pos - orig).Magnitude > 4 and (pos - root.Position).Magnitude <= CARRY_DIST then
            return true
        end
        return false
    end
    local function NearestDropPrompt(center, radius)
        local best, bestD = nil, radius
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("ProximityPrompt") and d.Enabled then
                local p = PromptWorldPos(d)
                if p then
                    local dist = (p - center).Magnitude
                    if dist < bestD then best, bestD = d, dist end
                end
            end
        end
        return best
    end

    local function PickUp(n)
        local crate = CrateModel(n)
        if not crate then return false end
        local pos = CrateOrig(n) or PosOfInst(crate)
        if not pos then return false end
        MoveTo(pos + Vector3.new(0, CRATE_UP, 0), R2On)
        for attempt = 1, 4 do
            if not R2On() then return false end
            if Carrying(n) then return true end
            crate = CrateModel(n)
            if not crate then return false end
            local prompt = CratePrompt(crate)
            if prompt then PressPrompt(prompt) end
            local t0 = os.clock()
            while R2On() and os.clock() - t0 < 2 do
                if Carrying(n) then return true end
                task.wait(0.15)
            end
            local root = MyRoot()
            local cp = PosOfInst(CrateModel(n))
            if root and cp and (root.Position - cp).Magnitude > 8 then
                MoveTo(cp + Vector3.new(0, CRATE_UP, 0), R2On)
            end
        end
        return false
    end

    -- ===== หาวงวางกล่อง (วงเรืองแสงสีเหลือง) อัตโนมัติ =====
    local function IsYellow(c) return c.R > 0.75 and c.G > 0.65 and c.B < 0.6 end
    local function NearCrateOrigin(p)
        for n = 1, CRATE_COUNT do
            local o = origPos[n]
            if o and (o - p).Magnitude < 25 then return true end
        end
        return false
    end
    local function ZonePosOfPart(part)
        -- ฐานของวง (วงสูงเป็นลำแสง) ยกขึ้นนิดหน่อยให้ยืนอยู่ในวง
        return part.Position - Vector3.new(0, part.Size.Y / 2, 0) + Vector3.new(0, CRATE_UP, 0)
    end
    local function FindDropZone()
        local char = LocalPlayer.Character
        -- 1) โมเดล Supplies_Circle: ส่วนที่ไม่ได้อยู่ตรงตำแหน่งกล่องเดิม = วงวางกล่อง
        local sc = workspace:FindFirstChild("Supplies_Circle", true)
        if sc then
            local parts = {}
            if sc:IsA("BasePart") then parts[1] = sc end
            for _, d in ipairs(sc:GetDescendants()) do if d:IsA("BasePart") then parts[#parts + 1] = d end end
            for _, part in ipairs(parts) do
                if not NearCrateOrigin(part.Position) then return ZonePosOfPart(part), "Supplies_Circle" end
            end
        end
        -- 2) เดาจากสี: พาร์ทใหญ่สีเหลืองที่มองเห็นได้ ไม่ใช่ตัวเรา/ไม่ใช่ที่กล่องเดิม
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("BasePart") and d.Transparency < 1 and (d.Size.X >= 15 or d.Size.Z >= 15)
                and IsYellow(d.Color) and not (char and d:IsDescendantOf(char)) and not NearCrateOrigin(d.Position) then
                return ZonePosOfPart(d), "yellow:" .. d:GetFullName()
            end
        end
        return nil
    end
    -- พิมพ์ผู้ต้องสงสัยลง F9 + คัดลอกลงคลิปบอร์ด เผื่อหาวงไม่เจอ
    function R2.Dump()
        local out = {}
        local sc = workspace:FindFirstChild("Supplies_Circle", true)
        out[#out + 1] = "Supplies_Circle: " .. (sc and sc:GetFullName() or "not found")
        if sc then
            for _, d in ipairs(sc:GetDescendants()) do
                if d:IsA("BasePart") then
                    out[#out + 1] = ("  %s [%s] pos=%s size=%s color=%s transp=%.2f"):format(d:GetFullName(), d.ClassName, tostring(d.Position), tostring(d.Size), tostring(d.Color), d.Transparency)
                end
            end
        end
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("BasePart") and d.Transparency < 1 and (d.Size.X >= 15 or d.Size.Z >= 15) and IsYellow(d.Color) then
                out[#out + 1] = ("yellow: %s pos=%s size=%s"):format(d:GetFullName(), tostring(d.Position), tostring(d.Size))
            end
        end
        local text = table.concat(out, "\n")
        print("[SmoothHub][R2 dump]\n" .. text)
        pcall(function() if setclipboard then setclipboard(text) end end)
        return text
    end

    -- วางสำเร็จ = ก้าวถอยออกจากวงแล้วกล่องไม่ตามตัวเรามา (หรือกล่องหายไป)
    local function CrateLeftBehind(n)
        local crate = CrateModel(n)
        if not (crate and crate.Parent) then return true end
        local root, cp = MyRoot(), PosOfInst(crate)
        if not (root and cp) then return false end
        return (cp - root.Position).Magnitude > CARRY_DIST + 3
    end
    local function DropAtSpawn(n)
        local target = R2_DROP_POS
        if not target then return false end
        for attempt = 1, 3 do
            if not R2On() then return false end
            MoveTo(target, R2On)
            local prompt = NearestDropPrompt(target, 40)
            if prompt then PressPrompt(prompt) end
            task.wait(1)
            -- ก้าวออกไป 30 studs ถ้ากล่องอยู่ที่เดิม = วางแล้ว
            MoveTo(target + Vector3.new(30, 0, 0), R2On)
            task.wait(0.3)
            if CrateLeftBehind(n) then return true end
        end
        return false
    end

    local function RunRound2()
        SH.QuestHold = true
        local was = { AutoFarm = Cfg.AutoFarm, AutoFarmThunder = Cfg.AutoFarmThunder, AutoClearWave = Cfg.AutoClearWave }
        for k, v in pairs(was) do if v then SetFlag(k, false) end end
        local completed = false
        local ok, err = pcall(function()
            if not R2.spawnPos then
                local root = MyRoot()
                if root then R2.spawnPos = root.Position end
            end
            for n = 1, CRATE_COUNT do CrateOrig(n) end
            for n = 1, CRATE_COUNT do
                if not R2On() then return end
                if CrateModel(n) then
                    QS(("Crate %d/%d: picking up"):format(n, CRATE_COUNT))
                    local picked = PickUp(n)
                    if not R2On() then return end
                    if picked then
                        QS(("Crate %d/%d: delivering"):format(n, CRATE_COUNT))
                        DropAtSpawn(n)
                    else
                        SH.say("Auto Quest Round (2): crate " .. n .. " pickup failed, skipping")
                    end
                end
            end
            completed = true
            QS("All crates delivered", "green")
        end)
        if not ok then SH.dbg("[SmoothHub][Quest R2]", err) end
        -- ฟาร์มปกติต่อ: คืนค่าเดิม ถ้าไม่มีอะไรเปิดอยู่เลยให้เปิด Auto Farm
        local anyOn = false
        for _, v in pairs(was) do if v then anyOn = true end end
        for k, v in pairs(was) do if v then SetFlag(k, true) end end
        if not anyOn and R2On() then SetFlag("AutoFarm", true) end
        SH.QuestHold = false
        return completed
    end

    task.spawn(function()
        while Alive() do
            task.wait(1)
            -- เล่นซ้ำอัตโนมัติเมื่อจบแมพ (เปิดเมื่อ Round 2 ทำงาน คืนค่าเดิมเมื่อปิด)
            if Cfg.AutoQuestThunderR2 then
                if not Cfg.AutoRetry then
                    R2.forcedRetry = true
                    SetFlag("AutoRetry", true)
                end
            elseif R2.forcedRetry then
                R2.forcedRetry = false
                SetFlag("AutoRetry", false)
            end
            if Cfg.AutoQuestThunderR2 and Farm.CanUseHere() then
                if CrateModel(1) then
                    local ok, completed = pcall(RunRound2)
                    if ok and completed then
                        -- รอจนแมพรีเซ็ต (กล่องหาย) ก่อนเริ่มรอบใหม่
                        while R2On() and CrateModel(1) do task.wait(1) end
                        R2.spawnPos, R2.dropPos = nil, nil
                        origPos = {}
                    end
                else
                    R2.spawnPos, R2.dropPos = nil, nil
                    origPos = {}
                    -- จดจุดเกิดไว้ตั้งแต่ก่อนกล่องโผล่ (ถ้ามี)
                    local root = MyRoot()
                    if root then R2.spawnPos = root.Position end
                end
            end
        end
    end)

    -- ============================================================
    --  Round ( 1 ) ในล็อบบี้: สร้างห้อง Outskirts ระดับสีแดง (Aberrant A- Grade)
    --  ไม่ปรับ Modifiers -> กด Start เองหลัง 5 วินาที -> เข้าแมพไปทำเควส
    --  เงื่อนไข: จุติ >= 1 และเลเวล >= 80
    -- ============================================================
    local LOBBY_PLACE_ID = 14916516914
    if game.PlaceId == LOBBY_PLACE_ID then
        local R1_MAP, R1_DIFF, R1_OBJECTIVE = "Outskirts", "Aberrant", "Skirmish"
        local R1_MIN_PRESTIGE, R1_MIN_LEVEL = 1, 80
        local R1_START_DELAY = 5
        local function LobbyInvoke(...)
            local remote = GetLobbyRemote()
            if not remote then return false, "remote not found" end
            local args = table.pack(...)
            local done, ok, result = false, false, nil
            task.spawn(function()
                ok, result = pcall(function() return remote:InvokeServer(table.unpack(args, 1, args.n)) end)
                done = true
            end)
            local t0 = os.clock()
            while not done and os.clock() - t0 < 8 do task.wait(0.1) end
            if not done then return false, "timeout" end
            return ok, result
        end
        local function MyRoom()
            local folder = ReplicatedStorage:FindFirstChild("Missions")
            if not folder then return nil end
            for _, room in ipairs(folder:GetChildren()) do
                local leader = room:FindFirstChild("Leader")
                if leader and leader:IsA("ValueBase") and leader.Value == LocalPlayer.Name then return room end
            end
            return nil
        end
        local function DiffOf(room)
            local okV, v = pcall(function() return room.Value end)
            if okV and type(v) == "string" then return (v:match("^%s*(%a+)") or ""):lower() end
            return nil
        end
        local function R1Ready()
            local level = tonumber(LocalPlayer:GetAttribute("Level"))
            local prestige = tonumber(LocalPlayer:GetAttribute("Prestige")) or 0
            return level ~= nil and level >= R1_MIN_LEVEL and prestige >= R1_MIN_PRESTIGE
        end
        task.spawn(function()
            local roomRef = nil
            local startAt, lastStart, lastCreate = nil, -math.huge, -math.huge
            local warned = false
            task.wait(4) -- รอให้ล็อบบี้โหลดก่อน
            while Alive() do
                task.wait(0.5)
                if not Cfg.AutoQuestThunderR1 or Cfg.AutoQuestThunderR2 or Cfg.AutoQuestThunderR3 then
                    startAt, warned = nil, false
                elseif not R1Ready() then
                    startAt = nil
                    if not warned then
                        warned = true
                        SH.say("Auto Quest Round (1): needs Prestige 1+ and Level 80+")
                    end
                elseif SH.Coord.Blocker(100) then
                    startAt = nil
                    QS("Waiting: " .. tostring(SH.Coord.last))
                else
                    warned = false
                    local room = MyRoom() or ((roomRef and roomRef.Parent) and roomRef or nil)
                    if room and (room.Name ~= R1_MAP or DiffOf(room) ~= R1_DIFF:lower()) then
                        -- มีห้องเดิมที่ไม่ใช่ Outskirts / Aberrant -> ออกก่อนแล้วสร้างใหม่
                        LobbyInvoke("S_Missions", "Leave")
                        roomRef, startAt = nil, nil
                        task.wait(0.8)
                    elseif not room then
                        if os.clock() - lastCreate >= 8 then
                            lastCreate = os.clock()
                            local ok, r = LobbyInvoke("S_Missions", "Create", {
                                Difficulty = R1_DIFF,
                                Type = "Missions",
                                Objective = R1_OBJECTIVE,
                                Name = R1_MAP,
                            })
                            if ok and r then
                                roomRef = (typeof(r) == "Instance") and r or nil
                                startAt = os.clock() + R1_START_DELAY
                                QS("Room created - starting soon")
                                SH.say("Auto Quest Round (1): room created (" .. R1_MAP .. " / " .. R1_DIFF .. "), starting in " .. R1_START_DELAY .. "s")
                            else
                                QS("Create room failed - retrying")
                                SH.say("Auto Quest Round (1): create failed - " .. tostring(r))
                            end
                        end
                    else
                        if not startAt then startAt = os.clock() + R1_START_DELAY end
                        if os.clock() >= startAt and os.clock() - lastStart >= 15 then
                            lastStart = os.clock()
                            local ok, r = LobbyInvoke("S_Missions", "Start")
                            SH.say(ok and "Auto Quest Round (1): start sent" or ("Auto Quest Round (1): start failed - " .. tostring(r)))
                            QS(ok and "Start sent - joining match" or "Start failed - retrying")
                        end
                    end
                end
            end
        end)
    end

    -- ============================================================
    --  Round ( 2 ) ในล็อบบี้: สร้างห้อง Forest ระดับสีแดง (Aberrant A- Grade)
    --  ไม่ปรับ Modifiers -> กด Start เองหลัง 5 วินาที -> เข้าแมพไปทำเควส
    --  เงื่อนไข: จุติ >= 1 และเลเวล >= 80
    -- ============================================================
    if game.PlaceId == 14916516914 then
        local R2_MAP, R2_DIFF, R2_OBJECTIVE = "Forest", "Aberrant", "Skirmish"
        local R2_MIN_PRESTIGE, R2_MIN_LEVEL = 1, 80
        local R2_START_DELAY = 5
        local function LobbyInvoke(...)
            local remote = GetLobbyRemote()
            if not remote then return false, "remote not found" end
            local args = table.pack(...)
            local done, ok, result = false, false, nil
            task.spawn(function()
                ok, result = pcall(function() return remote:InvokeServer(table.unpack(args, 1, args.n)) end)
                done = true
            end)
            local t0 = os.clock()
            while not done and os.clock() - t0 < 8 do task.wait(0.1) end
            if not done then return false, "timeout" end
            return ok, result
        end
        local function MyRoom()
            local folder = ReplicatedStorage:FindFirstChild("Missions")
            if not folder then return nil end
            for _, room in ipairs(folder:GetChildren()) do
                local leader = room:FindFirstChild("Leader")
                if leader and leader:IsA("ValueBase") and leader.Value == LocalPlayer.Name then return room end
            end
            return nil
        end
        local function DiffOf(room)
            local okV, v = pcall(function() return room.Value end)
            if okV and type(v) == "string" then return (v:match("^%s*(%a+)") or ""):lower() end
            return nil
        end
        local function R2Ready()
            local level = tonumber(LocalPlayer:GetAttribute("Level"))
            local prestige = tonumber(LocalPlayer:GetAttribute("Prestige")) or 0
            return level ~= nil and level >= R2_MIN_LEVEL and prestige >= R2_MIN_PRESTIGE
        end
        task.spawn(function()
            local roomRef = nil
            local startAt, lastStart, lastCreate = nil, -math.huge, -math.huge
            local warned = false
            task.wait(4) -- รอให้ล็อบบี้โหลดก่อน
            while Alive() do
                task.wait(0.5)
                if not Cfg.AutoQuestThunderR2 or Cfg.AutoQuestThunderR3 then
                    startAt, warned = nil, false
                elseif not R2Ready() then
                    startAt = nil
                    if not warned then
                        warned = true
                        SH.say("Auto Quest Round (2): needs Prestige 1+ and Level 80+")
                    end
                elseif SH.Coord.Blocker(100) then
                    startAt = nil
                    QS("Waiting: " .. tostring(SH.Coord.last))
                else
                    warned = false
                    local room = MyRoom() or ((roomRef and roomRef.Parent) and roomRef or nil)
                    if room and (room.Name ~= R2_MAP or DiffOf(room) ~= R2_DIFF:lower()) then
                        -- มีห้องเดิมที่ไม่ใช่ Forest / Aberrant -> ออกก่อนแล้วสร้างใหม่
                        LobbyInvoke("S_Missions", "Leave")
                        roomRef, startAt = nil, nil
                        task.wait(0.8)
                    elseif not room then
                        if os.clock() - lastCreate >= 8 then
                            lastCreate = os.clock()
                            local ok, r = LobbyInvoke("S_Missions", "Create", {
                                Difficulty = R2_DIFF,
                                Type = "Missions",
                                Objective = R2_OBJECTIVE,
                                Name = R2_MAP,
                            })
                            if ok and r then
                                roomRef = (typeof(r) == "Instance") and r or nil
                                startAt = os.clock() + R2_START_DELAY
                                QS("Room created - starting soon")
                                SH.say("Auto Quest Round (2): room created (" .. R2_MAP .. " / " .. R2_DIFF .. "), starting in " .. R2_START_DELAY .. "s")
                            else
                                QS("Create room failed - retrying")
                                SH.say("Auto Quest Round (2): create failed - " .. tostring(r))
                            end
                        end
                    else
                        if not startAt then startAt = os.clock() + R2_START_DELAY end
                        if os.clock() >= startAt and os.clock() - lastStart >= 15 then
                            lastStart = os.clock()
                            local ok, r = LobbyInvoke("S_Missions", "Start")
                            SH.say(ok and "Auto Quest Round (2): start sent" or ("Auto Quest Round (2): start failed - " .. tostring(r)))
                            QS(ok and "Start sent - joining match" or "Start failed - retrying")
                        end
                    end
                end
            end
        end)
    end

    -- ============================================================
    --  Round ( 3 ) ในล็อบบี้: สร้างห้อง Utgard ระดับสีแดง (Aberrant A- Grade) + Modifier Nightmare
    --  ปรับ Modifier "Nightmare" (ฝันร้าย) -> กด Start เองหลัง 5 วินาที -> เข้าแมพฟาร์ม 1 เกม
    --  เงื่อนไข: จุติ >= 1 และเลเวล >= 80
    -- ============================================================
    if game.PlaceId == 14916516914 then
        local R3_MAP, R3_DIFF, R3_OBJECTIVE = "Utgard", "Aberrant", "Skirmish"
        local R3_MODIFIER = "Nightmare"
        local R3_MIN_PRESTIGE, R3_MIN_LEVEL = 1, 80
        local R3_START_DELAY = 5
        local function LobbyInvoke(...)
            local remote = GetLobbyRemote()
            if not remote then return false, "remote not found" end
            local args = table.pack(...)
            local done, ok, result = false, false, nil
            task.spawn(function()
                ok, result = pcall(function() return remote:InvokeServer(table.unpack(args, 1, args.n)) end)
                done = true
            end)
            local t0 = os.clock()
            while not done and os.clock() - t0 < 8 do task.wait(0.1) end
            if not done then return false, "timeout" end
            return ok, result
        end
        local function MyRoom()
            local folder = ReplicatedStorage:FindFirstChild("Missions")
            if not folder then return nil end
            for _, room in ipairs(folder:GetChildren()) do
                local leader = room:FindFirstChild("Leader")
                if leader and leader:IsA("ValueBase") and leader.Value == LocalPlayer.Name then return room end
            end
            return nil
        end
        local function DiffOf(room)
            local okV, v = pcall(function() return room.Value end)
            if okV and type(v) == "string" then return (v:match("^%s*(%a+)") or ""):lower() end
            return nil
        end
        local function R3Ready()
            local level = tonumber(LocalPlayer:GetAttribute("Level"))
            local prestige = tonumber(LocalPlayer:GetAttribute("Prestige")) or 0
            return level ~= nil and level >= R3_MIN_LEVEL and prestige >= R3_MIN_PRESTIGE
        end
        task.spawn(function()
            local roomRef = nil
            local startAt, lastStart, lastCreate = nil, -math.huge, -math.huge
            local warned = false
            local modDone = false
            task.wait(4) -- รอให้ล็อบบี้โหลดก่อน
            while Alive() do
                task.wait(0.5)
                if not Cfg.AutoQuestThunderR3 then
                    startAt, warned, modDone = nil, false, false
                    if (Cfg.QuestR3Played or 0) ~= 0 then Cfg.QuestR3Played = 0 Save() end
                elseif not R3Ready() then
                    startAt, modDone = nil, false
                    if not warned then
                        warned = true
                        SH.say("Auto Quest Round (3): needs Prestige 1+ and Level 80+")
                    end
                elseif SH.Coord.Blocker(100) then
                    startAt = nil
                    QS("Waiting: " .. tostring(SH.Coord.last))
                else
                    warned = false
                    local room = MyRoom() or ((roomRef and roomRef.Parent) and roomRef or nil)
                    if room and (room.Name ~= R3_MAP or DiffOf(room) ~= R3_DIFF:lower() or not modDone) then
                        -- มีห้องเดิมที่ไม่ใช่ Utgard / Aberrant -> ออกก่อนแล้วสร้างใหม่
                        LobbyInvoke("S_Missions", "Leave")
                        roomRef, startAt, modDone = nil, nil, false
                        task.wait(0.8)
                    elseif not room then
                        if os.clock() - lastCreate >= 8 then
                            lastCreate = os.clock()
                            local ok, r = LobbyInvoke("S_Missions", "Create", {
                                Difficulty = R3_DIFF,
                                Type = "Missions",
                                Objective = R3_OBJECTIVE,
                                Name = R3_MAP,
                            })
                            if ok and r then
                                roomRef = (typeof(r) == "Instance") and r or nil
                                task.wait(0.8)
                                local okM, rM = LobbyInvoke("S_Missions", "Modify", R3_MODIFIER)
                                if okM then
                                    modDone = true
                                    startAt = os.clock() + R3_START_DELAY
                                    QS("Room created - starting soon")
                                    SH.say("Auto Quest Round (3): room created (" .. R3_MAP .. " / " .. R3_DIFF .. " / " .. R3_MODIFIER .. "), starting in " .. R3_START_DELAY .. "s")
                                else
                                    SH.say("Auto Quest Round (3): modifier failed - " .. tostring(rM))
                                end
                            else
                                QS("Create room failed - retrying")
                                SH.say("Auto Quest Round (3): create failed - " .. tostring(r))
                            end
                        end
                    else
                        if not startAt then startAt = os.clock() + R3_START_DELAY end
                        if os.clock() >= startAt and os.clock() - lastStart >= 15 then
                            lastStart = os.clock()
                            local ok, r = LobbyInvoke("S_Missions", "Start")
                            SH.say(ok and "Auto Quest Round (3): start sent" or ("Auto Quest Round (3): start failed - " .. tostring(r)))
                            QS(ok and "Start sent - joining match" or "Start failed - retrying")
                        end
                    end
                end
            end
        end)
    end

    -- ============================================================
    --  Round ( 3 ) ในเกม: ฟาร์มปกติ แล้วเล่นซ้ำจนครบ 3 ตา (นับต่อเนื่องข้ามการเข้าแมพด้วย Cfg.QuestR3Played)
    --  ระหว่างทำงานจะเปิด Auto Retry ให้ ครบ 3 ตาแล้วปิดสวิตช์ Round 3 เอง + คืนค่า Auto Retry เดิม
    -- ============================================================
    local R3_GAMES = 3
    local r3ForcedRetry = false
    task.spawn(function()
        local lastSpawn = nil
        while Alive() do
            task.wait(1)
            if Cfg.AutoQuestThunderR3 then
                if Farm.CanUseHere() then
                    -- เล่นซ้ำอัตโนมัติ (เปิดเมื่อ Round 3 ทำงาน)
                    if not Cfg.AutoRetry then
                        r3ForcedRetry = true
                        SetFlag("AutoRetry", true)
                    end
                    -- เริ่มตาใหม่ = ตัวละครเกิดใหม่ (ห่างจากตาก่อน > 90 วินาที) นับเป็น 1 ตา
                    if MyRoot() then
                        local sp = Farm.CharSpawnAt or 0
                        if lastSpawn == nil or sp - lastSpawn > 90 then
                            lastSpawn = sp
                            task.wait(3)
                            if not (Cfg.AutoFarm or Cfg.AutoFarmThunder or Cfg.AutoClearWave) then SetFlag("AutoFarm", true) end
                            Cfg.QuestR3Played = (Cfg.QuestR3Played or 0) + 1
                            SH.say("Auto Quest Round (3): game " .. Cfg.QuestR3Played .. "/" .. R3_GAMES)
                            if Cfg.QuestR3Played >= R3_GAMES then
                                -- ตาสุดท้าย: ปิด Round 3 (ฟาร์มตาที่ 3 จนจบ ไม่เล่นซ้ำต่อ)
                                Cfg.QuestR3Played = 0
                                Cfg.AutoQuestThunderR3 = false
                                SH.say("Auto Quest Round (3): last game, Round 3 switched off")
                                QS("Round 3 done (3/3 games)", "green")
                            end
                            Save()
                            pcall(UiSync.Refresh)
                        end
                    end
                end
            elseif r3ForcedRetry then
                r3ForcedRetry = false
                SetFlag("AutoRetry", false)
            end
        end
    end)

    -- ===== แถว Status ของ Auto Quest [ Thunder Spear ] =====
    -- สี: เหลือง = กำลังทำงาน | เขียว = จบงานรอบนั้น | สีปกติ = ปิดอยู่
    do
        local QUEST_MIN_LEVEL, QUEST_MIN_PRESTIGE = 80, 1
        local STATUS_YELLOW = Color3.fromRGB(255, 214, 10)
        local STATUS_GREEN = Color3.fromRGB(48, 209, 88)
        local statusRow = Form:Row()
        statusRow:Left():TitleStack({ Title = "Status" })
        local statusLabel = statusRow:Right():Label({ Text = "Off" })
        local statusDefault, lastText, lastColorKey, lastActive = nil, nil, nil, nil
        local function SetColor(key)
            if key == lastColorKey then return end
            local ok = pcall(function()
                local o = LabelObject(statusLabel)
                if not o then error("label not ready") end
                if not statusDefault then statusDefault = o.TextColor3 end
                if key == "yellow" then o.TextColor3 = STATUS_YELLOW
                elseif key == "green" then o.TextColor3 = STATUS_GREEN
                else o.TextColor3 = statusDefault end
            end)
            if ok then lastColorKey = key end
        end
        -- รอบที่ทำงานอยู่ (โค้ดล็อบบี้ให้ความสำคัญ Round 3 > 2 > 1)
        local function ActiveRound()
            if Cfg.AutoQuestThunderR3 then return 3 end
            if Cfg.AutoQuestThunderR2 then return 2 end
            if Cfg.AutoQuestThunderR1 then return 1 end
            return nil
        end
        task.spawn(function()
            while Alive() do
                task.wait(0.4)
                local text, color = "Off", "default"
                pcall(function()
                    local active = ActiveRound()
                    if active ~= lastActive then
                        if active then QDetail.text = nil end -- เปิดรอบใหม่ = ล้างสถานะเก่า
                        lastActive = active
                    end
                    if not active then
                        -- ปิดหมดแล้ว แต่ถ้าเพิ่งจบงาน (สีเขียว) ให้โชว์ค้างไว้
                        if QDetail.color == "green" and QDetail.text then text, color = QDetail.text, "green" end
                        return
                    end
                    local inMatch = Farm.CanUseHere()
                    local detail = nil
                    if QDetail.text and QDetail.where == (inMatch and "match" or "lobby") then detail = QDetail.text end
                    local played = Cfg.QuestR3Played or 0
                    if not detail then
                        if inMatch then
                            if active == 3 then detail = (played > 0) and ("Game %d/%d in progress"):format(played, R3_GAMES) or "Starting game 1"
                            elseif active == 2 then detail = "Waiting for supply crates"
                            else detail = "Waiting for watchtowers" end
                        else
                            local level = tonumber(LocalPlayer:GetAttribute("Level"))
                            local prestige = tonumber(LocalPlayer:GetAttribute("Prestige")) or 0
                            if not (level and level >= QUEST_MIN_LEVEL and prestige >= QUEST_MIN_PRESTIGE) then
                                detail = ("Needs Prestige %d+ and Level %d+ (you: Prestige %d, Level %s)"):format(QUEST_MIN_PRESTIGE, QUEST_MIN_LEVEL, prestige, tostring(level or "?"))
                            else
                                detail = "Setting up room"
                            end
                        end
                    end
                    text = ("Round %d | %s"):format(active, detail)
                    if active == 3 then text = text .. (" | Games %d/%d"):format(played, R3_GAMES) end
                    color = (QDetail.color == "green" and detail == QDetail.text) and "green" or "yellow"
                end)
                if text ~= lastText then
                    lastText = text
                    pcall(function() statusLabel.Text = text end)
                    lastColorKey = nil -- เปลี่ยนข้อความแล้ว ตั้งสีใหม่ทุกครั้ง
                end
                SetColor(color)
            end
        end)
    end
end)
local AutoSkillTab = MainCategory:Tab({
    Title = "Auto Skill",
    Icon = Icon("sparklesFill", "starFill", "boltFill"),
})
SH.Guard("auto-skill", function()
    local UIS = game:GetService("UserInputService")
    local MODES = { "Instant", "Hold" }
    local KEYS = { Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.Five }
    for i = 1, 5 do
        if not table.find(MODES, Cfg["AutoSkillMode" .. i]) then Cfg["AutoSkillMode" .. i] = "Instant" end
    end
    local SkillSection = AutoSkillTab:PageSection({
        Title = "🎯 Auto Skill",
        Subtitle = "Presses your skill slot keys (1-5) for you. Instant = tap, Hold = hold the key."
    })
    local SkillForm = SkillSection:Form()
    local StatusRow = SkillForm:Row()
    StatusRow:Left():TitleStack({ Title = "Skill Status", Subtitle = "Current action..." })
    local StatusLabel = StatusRow:Right():Label({ Text = "Off" })
    local lastStatus = nil
    local function SetStatus(text)
        if text == lastStatus then return end
        lastStatus = text
        pcall(function() StatusLabel.Text = tostring(text) end)
    end
    for i = 1, 5 do
        local toggleKey, modeKey = "AutoSkill" .. i, "AutoSkillMode" .. i
        local row = SkillForm:Row()
        row:Left():TitleStack({
            Title = "Skill Slot [ " .. i .. " ]",
            Subtitle = "Auto press key " .. i .. " - choose Instant (tap) or Hold."
        })
        local function ModeIndex() return table.find(MODES, Cfg[modeKey]) or 1 end
        local drop = row:Right():PullDownButton({
            Label = MODES[ModeIndex()],
            Options = MODES,
            Value = ModeIndex(),
            ValueChanged = function(self, index)
                if type(index) == "table" then index = index[1] end
                if type(index) ~= "number" or not MODES[index] then return end
                Cfg[modeKey] = MODES[index]
                self.Label = MODES[index]
                Save()
            end
        })
        UiSync.Add(function()
            local idx = ModeIndex()
            drop.Value = idx
            drop.Label = MODES[idx]
        end)
        local trow = SkillForm:Row()
        trow:Left():TitleStack({ Title = "Enable Slot [ " .. i .. " ]", Subtitle = "Turn auto press on for slot " .. i .. "." })
        UiSync.Link(trow:Right():Toggle({
            Value = Cfg[toggleKey],
            ValueChanged = function(self, value)
                Cfg[toggleKey] = value and true or false
                Save()
            end
        }), Cfg, toggleKey)
    end
    local function AddSlider(title, subtitle, key)
        local range = FARM_RANGES[key]
        local row = SkillForm:Row()
        local stack = row:Left():TitleStack({ Title = title(Cfg[key]), Subtitle = subtitle })
        UiSync.Link(row:Right():Slider({
            Minimum = range[1],
            Maximum = range[2],
            Value = Cfg[key],
            ValueChanged = function(self, value)
                local v = math.clamp(math.floor(value + 0.5), range[1], range[2])
                Cfg[key] = v
                pcall(function() stack.Title = title(v) end)
                Save()
            end
        }), Cfg, key, function(_, want) pcall(function() stack.Title = title(want) end) end)
    end
    AddSlider(function(v) return "Hold Time ( " .. v .. "s )" end, "How long the key is held in Hold mode.", "AutoSkillHoldTime")
    AddSlider(function(v) return "Press Delay ( " .. v .. "s )" end, "Wait before pressing the same slot again (match your skill cooldown).", "AutoSkillDelay")

    local function AnyOn()
        for i = 1, 5 do if Cfg["AutoSkill" .. i] then return true end end
        return false
    end
    local function CanPress()
        if not Farm.CanUseHere() then return false, "Not available in the lobby / menu" end
        if UIS:GetFocusedTextBox() then return false, "Typing in chat - paused" end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return false, "Waiting for your character" end
        if Farm.CompleteScreenShown and Farm.CompleteScreenShown() then return false, "Mission completed - paused" end
        return true
    end
    local function Press(i)
        local key = KEYS[i]
        if Cfg["AutoSkillMode" .. i] == "Hold" then
            pcall(function() VirtualInputManager:SendKeyEvent(true, key, false, game) end)
            local t0 = os.clock()
            while os.clock() - t0 < Cfg.AutoSkillHoldTime and Alive() and Cfg["AutoSkill" .. i] and CanPress() do
                task.wait(0.1)
            end
            pcall(function() VirtualInputManager:SendKeyEvent(false, key, false, game) end)
        else
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, key, false, game)
                task.wait(0.06)
                VirtualInputManager:SendKeyEvent(false, key, false, game)
            end)
        end
        if Farm.Debug then SH.dbg("[SmoothHub][Skill] pressed slot", i, Cfg["AutoSkillMode" .. i]) end
    end
    local nextAt = { 0, 0, 0, 0, 0 }
    task.spawn(function()
        while Alive() do
            task.wait(0.25)
            if not AnyOn() then
                SetStatus("Off")
            else
                local ok, why = CanPress()
                if not ok then
                    SetStatus(why)
                else
                    SetStatus("Waiting for next press...")
                    for i = 1, 5 do
                        if Cfg["AutoSkill" .. i] and os.clock() >= nextAt[i] then
                            SetStatus("Using slot " .. i .. " (" .. Cfg["AutoSkillMode" .. i] .. ")")
                            Press(i)
                            nextAt[i] = os.clock() + Cfg.AutoSkillDelay
                            task.wait(0.15)
                            if not CanPress() then break end
                        end
                    end
                end
            end
        end
        for i = 1, 5 do pcall(function() VirtualInputManager:SendKeyEvent(false, KEYS[i], false, game) end) end
    end)
end)
local LobbyCategory = Cascade.Components.Section(Window, {
    Title = "Lobby",
    Disclosure = false
})
local LobbyTab = LobbyCategory:Tab({
    Title = "Lobby",
    Icon = Icon("cubeFill", "shippingboxFill", "cube"),
})
do
    local ClaimSection = LobbyTab:PageSection({
        Title = "🎁 Auto Claim",
        Subtitle = "Claims rewards the game shows as ready. Open the Quests / Achievements page to refresh them."
    })
    local ClaimForm = ClaimSection:Form()
    local ClaimStatusRow = ClaimForm:Row()
    ClaimStatusRow:Left():TitleStack({ Title = "Claim Status", Subtitle = "Rewards claimed since the script started." })
    local ClaimStatusLabel = ClaimStatusRow:Right():Label({ Text = "Idle" })
    local function SetClaimStatus(text)
        pcall(function() ClaimStatusLabel.Text = tostring(text) end)
    end
    local function AddClaimToggle(title, subtitle, key)
        local row = ClaimForm:Row()
        row:Left():TitleStack({ Title = title, Subtitle = subtitle })
        UiSync.Link(row:Right():Toggle({
            Value = Cfg[key],
            ValueChanged = function(self, value)
                Cfg[key] = value and true or false
                Save()
            end
        }), Cfg, key)
    end
    AddClaimToggle("Auto Claim Main Quests", "Automatically claim the main quests.", "AutoClaimMain")
    AddClaimToggle("Auto Claim Side Quests", "Automatically claim the side quests.", "AutoClaimSide")
    AddClaimToggle("Auto Claim Achievements", "Automatically claim achievements.", "AutoClaimAchievements")
    AddClaimToggle("Auto Claim Weekly Quests", "Automatically claim the weekly quests.", "AutoClaimWeekly")
    AddClaimToggle("Auto Claim Daily Quests", "Automatically claim the daily quests.", "AutoClaimDaily")
    AddClaimToggle("Auto Open Pages", "When the game shows the red ! on the Achievements icon, open that page, claim, then close it (like a player).", "AutoOpenPages")
    local SCAN_INTERVAL = 5
    local CLAIM_RETRY = 300
    local CLAIM_GAP = 1.2
    local CLAIM_MAX_PER_RUN = 25
    local BLIND_DAILY_INTERVAL = 300
    local claimRemote = nil
    local function GetClaimRemote()
        if claimRemote and claimRemote.Parent then return claimRemote end
        claimRemote = GetLobbyRemote()
        return claimRemote
    end
    local QUEST_TOGGLE = {
        Main = "AutoClaimMain",
        Side = "AutoClaimSide",
        Weekly = "AutoClaimWeekly",
        Daily = "AutoClaimDaily",
    }
    local function Interface()
        return PlayerGui:FindFirstChild("Interface")
    end
    local function ScanQuestCards()
        local out = {}
        local quests = Interface() and Interface():FindFirstChild("Quests")
        if not quests then return out end
        for _, d in ipairs(quests:GetDescendants()) do
            if d.Name == "Button" and d:IsA("GuiObject") then
                local ok, info = pcall(function()
                    local claim = d.Parent
                    if not (claim and claim.Name == "Claim" and claim.Visible) then return nil end
                    local tag, category = d:GetAttribute("Tag"), d:GetAttribute("Category")
                    if tag == nil or category == nil then return nil end
                    return { tag = tostring(tag), category = tostring(category), inst = d }
                end)
                if ok and info then out[#out + 1] = info end
            end
        end
        return out
    end
    local function ScanAchievementItems()
        local out = {}
        local iface = Interface()
        local ach = iface and iface:FindFirstChild("Achievements")
        local list = ach and ach:FindFirstChild("List")
        list = list and list:FindFirstChild("Inner")
        if not list then return out end
        for _, item in ipairs(list:GetChildren()) do
            local ok, info = pcall(function()
                local id = tonumber(item.Name)
                if not id or id == 99 then return nil end
                local inner = item:FindFirstChild("Inner")
                local state = inner and inner:FindFirstChild("A_State")
                local title = state and state:FindFirstChild("Title")
                if state and state.Visible and title and title.Text == "CLAIM" then
                    return { id = id, inst = item }
                end
                return nil
            end)
            if ok and info then out[#out + 1] = info end
        end
        return out
    end
    local lastTry = setmetatable({}, { __mode = "k" })
    local function Due(inst)
        return os.clock() - (lastTry[inst] or -math.huge) >= CLAIM_RETRY
    end
    local function ClaimOne(inst, ...)
        lastTry[inst] = os.clock()
        local remote = GetClaimRemote()
        if not remote then return false end
        local args = table.pack(...)
        local ok, r1 = pcall(function()
            return remote:InvokeServer(table.unpack(args, 1, args.n))
        end)
        return ok and r1 ~= nil
    end
    local totals = { Main = 0, Side = 0, Weekly = 0, Daily = 0, Ach = 0 }
    local function RefreshClaimStatus()
        SetClaimStatus(("Main %d · Side %d · Weekly %d · Daily %d · Ach %d"):format(
            totals.Main, totals.Side, totals.Weekly, totals.Daily, totals.Ach))
    end
    local function RunScan()
        if not Interface() then SetClaimStatus("Waiting for the game UI...") return end
        local done, tried = 0, 0
        local wantQuests = Cfg.AutoClaimMain or Cfg.AutoClaimSide or Cfg.AutoClaimWeekly or Cfg.AutoClaimDaily
        if wantQuests then
            for _, c in ipairs(ScanQuestCards()) do
                local toggle = QUEST_TOGGLE[c.category]
                if toggle and Cfg[toggle] and Alive() and tried < CLAIM_MAX_PER_RUN and Due(c.inst) then
                    tried += 1
                    if ClaimOne(c.inst, "Functions", "Quest", c.tag, c.category) then
                        totals[c.category] += 1
                        done += 1
                    end
                    task.wait(CLAIM_GAP)
                end
            end
        end
        if Cfg.AutoClaimAchievements then
            for _, a in ipairs(ScanAchievementItems()) do
                if Cfg.AutoClaimAchievements and Alive() and tried < CLAIM_MAX_PER_RUN and Due(a.inst) then
                    tried += 1
                    if ClaimOne(a.inst, "S_Achievements", "Claim", a.id) then
                        totals.Ach += 1
                        done += 1
                    end
                    task.wait(CLAIM_GAP)
                end
            end
        end
        if done > 0 or tried > 0 then RefreshClaimStatus() end
    end
    local lastBlindDaily = -math.huge
    local function RunBlindDaily()
        if not Cfg.AutoClaimDaily then return end
        if os.clock() - lastBlindDaily < BLIND_DAILY_INTERVAL then return end
        lastBlindDaily = os.clock()
        local remote = GetClaimRemote()
        if not remote then return end
        for i = 1, 3 do
            if not (Alive() and Cfg.AutoClaimDaily) then return end
            local ok, r1 = pcall(function()
                return remote:InvokeServer("Functions", "Quest", "Daily " .. i, "Daily")
            end)
            if ok and r1 ~= nil then totals.Daily += 1 end
            task.wait(CLAIM_GAP)
        end
        RefreshClaimStatus()
    end
    local OPEN_COOLDOWN = 60
    local opening = false
    local lastAchOpen, lastQuestOpen = -math.huge, -math.huge
    local handledAch = {}
    local handledCards = {}
    local CARD_CATEGORY = { Q_1 = "Main", Q_2 = "Side" }
    local function WantQuests()
        return Cfg.AutoClaimMain or Cfg.AutoClaimSide or Cfg.AutoClaimWeekly or Cfg.AutoClaimDaily
    end
    local function OnScreen(obj)
        local cam = workspace.CurrentCamera
        if not cam then return true end
        local c = obj.AbsolutePosition + obj.AbsoluteSize / 2
        local v = cam.ViewportSize
        return c.X >= 0 and c.Y >= 0 and c.X <= v.X and c.Y <= v.Y
    end
    local function PageOpen(page)
        if not page then return false end
        local ok, res = pcall(function()
            if not IsShown(page) then return false end
            if page:IsA("CanvasGroup") and page.GroupTransparency >= 0.95 then return false end
            return OnScreen(page)
        end)
        return ok and res or false
    end
    local function AchPage()
        local iface = Interface()
        return iface and iface:FindFirstChild("Achievements")
    end
    local function QuestsPage()
        local iface = Interface()
        return iface and iface:FindFirstChild("Quests")
    end
    local function AchOpen() return PageOpen(AchPage()) end
    local function QuestsOpen() return PageOpen(QuestsPage()) end
    local function AchBadgeOn()
        local b = FindGui("Interface.Topbar.Main.Icons.Achievements.New")
        return b ~= nil and b:IsA("GuiObject") and b.Visible
    end
    local function QuestCategoryCards()
        local out = {}
        local q = QuestsPage()
        local main = q and q:FindFirstChild("Main")
        local cats = main and main:FindFirstChild("Quests")
        if not cats then return out end
        for _, c in ipairs(cats:GetChildren()) do
            if c:IsA("CanvasGroup") then
                local ok, info = pcall(function()
                    local inner = c:FindFirstChild("Inner")
                    local title = inner and inner:FindFirstChild("Title")
                    local flag = title and title:FindFirstChild("New")
                    return {
                        name = c.Name,
                        new = (flag ~= nil and flag:IsA("GuiObject") and flag.Visible) and true or false,
                        interact = inner and inner:FindFirstChild("Interact"),
                    }
                end)
                if ok and info then out[#out + 1] = info end
            end
        end
        return out
    end
    local function DetailKey()
        local q = QuestsPage()
        local main = q and q:FindFirstChild("Main")
        local d = main and main:FindFirstChild("Details")
        local p = d and d:FindFirstChild("Quests")
        local n, first = 0, nil
        if p then
            for _, k in ipairs(p:GetChildren()) do
                if k:IsA("CanvasGroup") then
                    n += 1
                    first = first or k
                end
            end
        end
        return n, first
    end
    local function QuestsCloseButton()
        local q = QuestsPage()
        local c = q and q:FindFirstChild("Close")
        if not c then return nil end
        if c:IsA("GuiButton") then return c end
        return c:FindFirstChildWhichIsA("GuiButton", true)
    end
    local function PressUntil(btn, doneFn, timeout)
        pcall(function() GuiService.SelectedObject = btn end)
        task.wait(0.15)
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
        end)
        local t0 = os.clock()
        local fired = false
        while os.clock() - t0 < (timeout or 3) do
            task.wait(0.25)
            if doneFn() then break end
            if not fired and os.clock() - t0 > 1.2 then
                fired = true
                pcall(function()
                    if type(firesignal) == "function" then
                        firesignal(btn.MouseButton1Click)
                        firesignal(btn.Activated)
                    end
                end)
            end
        end
        pcall(function()
            if GuiService.SelectedObject == btn then GuiService.SelectedObject = nil end
        end)
        return doneFn()
    end
    local function AchList()
        local ach = AchPage()
        local l = ach and ach:FindFirstChild("List")
        return l and l:FindFirstChild("Inner")
    end
    local function AchInCategoryView()
        local list = AchList()
        if not list then return false end
        for _, c in ipairs(list:GetChildren()) do
            if tonumber(c.Name) then return true end
        end
        return false
    end
    local function AchCategories()
        local out = {}
        local list = AchList()
        if not list then return out end
        for _, item in ipairs(list:GetChildren()) do
            if item:IsA("GuiObject") and not tonumber(item.Name) then
                local box = item:FindFirstChild("Inner")
                local icon = box and box:FindFirstChild("Icon")
                local nw = icon and icon:FindFirstChild("New")
                local interact = item:FindFirstChild("Interact")
                if box and icon and interact and interact:IsA("GuiButton") then
                    out[#out + 1] = {
                        name = item.Name,
                        new = (nw ~= nil and nw:IsA("GuiObject") and nw.Visible) and true or false,
                        interact = interact,
                    }
                end
            end
        end
        return out
    end
    local function AchBack(doneFn)
        local close = FindGui("Interface.Achievements.Top.Achievements_Close")
        if not (close and close:IsA("GuiButton")) then return false end
        PressUntil(close, doneFn, 3)
        return true
    end
    local function BackedOut() return (not AchOpen()) or (not AchInCategoryView()) end
    local function AutoOpenAchievements()
        if opening then return end
        if not (Cfg.AutoOpenPages and Cfg.AutoClaimAchievements) then return end
        if not AchBadgeOn() then handledAch = {} return end
        if AchOpen() and AchInCategoryView() then return end
        local todo = 0
        for _, c in ipairs(AchCategories()) do
            if c.new then
                if not handledAch[c.name] then todo += 1 end
            else
                handledAch[c.name] = nil
            end
        end
        if todo == 0 then return end
        if os.clock() - lastAchOpen < OPEN_COOLDOWN then return end
        local icon = FindGui("Interface.Topbar.Main.Icons.Achievements")
        if not (icon and icon:IsA("GuiButton") and IsShown(icon)) then return end
        opening = true
        lastAchOpen = os.clock()
        local ok, err = pcall(function()
            local wasOpen = AchOpen()
            SetClaimStatus("Achievement badge! Opening page...")
            local function EnsureOpen()
                if not AchOpen() then PressUntil(icon, AchOpen, 3) end
                local t0 = os.clock()
                while os.clock() - t0 < 3 and #AchCategories() == 0 and not AchInCategoryView() do task.wait(0.3) end
                return AchOpen()
            end
            if not EnsureOpen() then
                SetClaimStatus("Achievements page did not open")
                return
            end
            for _ = 1, 5 do
                if not (Alive() and Cfg.AutoOpenPages and Cfg.AutoClaimAchievements) then break end
                if AchInCategoryView() then
                    AchBack(BackedOut)
                    task.wait(0.4)
                end
                if not EnsureOpen() then break end
                local nextCat = nil
                for _, c in ipairs(AchCategories()) do
                    if c.new and not handledAch[c.name] then nextCat = c break end
                end
                if not nextCat then break end
                handledAch[nextCat.name] = true
                PressUntil(nextCat.interact, AchInCategoryView, 3)
                task.wait(0.6)
                RunScan()
                AchBack(BackedOut)
                task.wait(0.4)
            end
            if not wasOpen and AchOpen() then
                if AchInCategoryView() then
                    AchBack(BackedOut)
                    task.wait(0.4)
                end
                if AchOpen() then
                    AchBack(function() return not AchOpen() end)
                end
            end
        end)
        opening = false
        if not ok then SetClaimStatus("Auto open failed: " .. tostring(err)) end
    end
    local function AutoOpenQuests()
        if opening then return end
        if not (Cfg.AutoOpenPages and WantQuests()) then return end
        local todo = {}
        for _, c in ipairs(QuestCategoryCards()) do
            if c.new then
                local cat = CARD_CATEGORY[c.name]
                local wanted
                if cat then wanted = Cfg[QUEST_TOGGLE[cat]] else wanted = WantQuests() end
                if wanted and not handledCards[c.name] then todo[#todo + 1] = c end
            else
                handledCards[c.name] = nil
            end
        end
        if #todo == 0 then return end
        if os.clock() - lastQuestOpen < OPEN_COOLDOWN then return end
        local topBtn = FindGui("Interface.Topbar.Main.Categories.Quests.Interact")
        if not (topBtn and topBtn:IsA("GuiButton") and IsShown(topBtn)) then return end
        opening = true
        lastQuestOpen = os.clock()
        local ok, err = pcall(function()
            local wasOpen = QuestsOpen()
            SetClaimStatus("Quest badge! Opening page...")
            if not wasOpen then
                PressUntil(topBtn, QuestsOpen, 3)
            end
            if not QuestsOpen() then
                SetClaimStatus("Quests page did not open")
                return
            end
            task.wait(0.5)
            for _, c in ipairs(todo) do
                if not (Alive() and Cfg.AutoOpenPages) then break end
                handledCards[c.name] = true
                if c.interact and c.interact.Parent then
                    local n0, f0 = DetailKey()
                    PressUntil(c.interact, function()
                        local n1, f1 = DetailKey()
                        return n1 > 0 and (n1 ~= n0 or f1 ~= f0)
                    end, 3)
                    task.wait(0.6)
                    RunScan()
                end
            end
            if not wasOpen and QuestsOpen() then
                local close = QuestsCloseButton()
                if close then
                    PressUntil(close, function() return not QuestsOpen() end, 3)
                else
                    SetClaimStatus("Quests page left open (close button not found)")
                end
            end
        end)
        opening = false
        if not ok then SetClaimStatus("Auto open failed: " .. tostring(err)) end
    end
    task.spawn(function()
        while Alive() do
            pcall(RunScan)
            pcall(AutoOpenAchievements)
            pcall(AutoOpenQuests)
            pcall(RunBlindDaily)
            task.wait(SCAN_INTERVAL)
        end
    end)
    local DEV_MODE = SH.DEV
    if DEV_MODE then
    local DebugRow = ClaimForm:Row()
    DebugRow:Left():TitleStack({
        Title = "Copy Claim Debug",
        Subtitle = "Open the Quests page and click through its categories, then Achievements, then press Copy."
    })
    local DebugBtn = DebugRow:Right():Button({ Label = "Copy", Callback = function() end })
    BindButton(DebugBtn, function()
        local lines = {}
        local function add(s) lines[#lines + 1] = tostring(s) end
        local function childNames(inst, limit)
            local parts = {}
            if inst then
                for _, c in ipairs(inst:GetChildren()) do parts[#parts + 1] = c.Name .. ":" .. c.ClassName end
            end
            table.sort(parts)
            if limit and #parts > limit then
                local n = #parts
                parts = { table.unpack(parts, 1, limit) }
                parts[#parts + 1] = ("...(+%d)"):format(n - limit)
            end
            return table.concat(parts, ", ")
        end
        local iface = Interface()
        add("Interface found: " .. tostring(iface ~= nil))
        if iface then
            add("Interface children: " .. childNames(iface, 60))
            local q = iface:FindFirstChild("Quests")
            add("Interface.Quests found: " .. tostring(q ~= nil))
            if q then
                add("Quests children: " .. childNames(q, 30))
                local main = q:FindFirstChild("Main")
                add("Quests.Main children: " .. childNames(main, 30))
                local cats = main and main:FindFirstChild("Quests")
                if cats then
                    for _, c in ipairs(cats:GetChildren()) do
                        if c:IsA("CanvasGroup") then
                            local newFlag = "?"
                            pcall(function() newFlag = tostring(c.Inner.Title.New.Visible) end)
                            local interact = c:FindFirstChild("Inner") and c.Inner:FindFirstChild("Interact")
                            add(("  category card %s | New(claimable)=%s | Interact=%s"):format(
                                c.Name, newFlag, interact and interact.ClassName or "none"))
                        end
                    end
                end
                local details = main and main:FindFirstChild("Details")
                local cardsParent = details and details:FindFirstChild("Quests")
                local nCards = 0
                if cardsParent then
                    for _, c in ipairs(cardsParent:GetChildren()) do
                        if c:IsA("CanvasGroup") then nCards += 1 end
                    end
                end
                add("Quest cards currently built: " .. nCards)
                local found = ScanQuestCards()
                add("Claim buttons showing in Quests: " .. #found)
                for _, c in ipairs(found) do add(("  tag=%s category=%s"):format(c.tag, c.category)) end
            end
            local ach = iface:FindFirstChild("Achievements")
            add("Interface.Achievements found: " .. tostring(ach ~= nil))
            if ach then
                add("Achievements children: " .. childNames(ach, 30))
                local list = ach:FindFirstChild("List") and ach.List:FindFirstChild("Inner")
                add("Achievement items built: " .. (list and #list:GetChildren() or 0))
                local items = ScanAchievementItems()
                add("CLAIM items showing in Achievements: " .. #items)
                for i = 1, math.min(#items, 15) do add("  id " .. items[i].id) end
            end
            local newIcon = FindGui("Interface.Topbar.Main.Icons.Achievements.New")
            add("Topbar Achievements 'New' flag: " .. (newIcon and tostring(newIcon.Visible) or "n/a"))
            local topbar = iface:FindFirstChild("Topbar")
            if topbar then
                add("Topbar children: " .. childNames(topbar, 20))
                local mainBar = topbar:FindFirstChild("Main")
                add("Topbar.Main children: " .. childNames(mainBar, 40))
                local icons = mainBar and mainBar:FindFirstChild("Icons")
                add("Topbar.Main.Icons children: " .. childNames(icons, 40))
                for _, d in ipairs(topbar:GetDescendants()) do
                    if d.Name == "New" and d:IsA("GuiObject") then
                        add(("  badge %s | Visible=%s"):format(d:GetFullName():gsub("^.-Interface%.", ""), tostring(d.Visible)))
                    end
                end
            end
            local function tree(inst, depth, maxDepth, out, limit)
                if depth > maxDepth or #out >= limit then return end
                for _, c in ipairs(inst:GetChildren()) do
                    if #out >= limit then return end
                    out[#out + 1] = string.rep("  ", depth) .. c.Name .. ":" .. c.ClassName
                    tree(c, depth + 1, maxDepth, out, limit)
                end
            end
            if ach and ach:FindFirstChild("Top") then
                local out = {}
                tree(ach.Top, 1, 3, out, 60)
                add("Achievements.Top tree:")
                for _, l in ipairs(out) do add(l) end
            end
        end
        do
            local iface2 = Interface()
            if iface2 then
                add("Achievements page open (script's view): " .. tostring(AchOpen()))
                local ach2 = iface2:FindFirstChild("Achievements")
                if ach2 and ach2:IsA("CanvasGroup") then
                    add(("Achievements.Visible=%s GroupTransparency=%.2f"):format(tostring(ach2.Visible), ach2.GroupTransparency))
                end
                local topbar2 = iface2:FindFirstChild("Topbar")
                if topbar2 then
                    add("Topbar buttons:")
                    for _, d in ipairs(topbar2:GetDescendants()) do
                        if d:IsA("GuiButton") then
                            add(("  %s | %s | shown=%s"):format(d:GetFullName():gsub("^.-Interface%.", ""), d.ClassName, tostring(IsShown(d))))
                        end
                    end
                    local cats = topbar2:FindFirstChild("Main") and topbar2.Main:FindFirstChild("Categories")
                    if cats then
                        add("Topbar.Main.Categories tree:")
                        local out2 = {}
                        local function walk(inst, depth)
                            if depth > 3 or #out2 >= 60 then return end
                            for _, c in ipairs(inst:GetChildren()) do
                                if #out2 >= 60 then return end
                                out2[#out2 + 1] = string.rep("  ", depth) .. c.Name .. ":" .. c.ClassName
                                walk(c, depth + 1)
                            end
                        end
                        walk(cats, 1)
                        for _, l in ipairs(out2) do add(l) end
                    end
                end
                add("Visible 'New' badges in Interface:")
                local nShown = 0
                for _, d in ipairs(iface2:GetDescendants()) do
                    if d.Name == "New" and d:IsA("GuiObject") and d.Visible and nShown < 40 then
                        nShown += 1
                        add("  " .. d:GetFullName():gsub("^.-Interface%.", ""))
                    end
                end
                if nShown == 0 then add("  (none)") end
            end
        end
        do
            local iface3 = Interface()
            local ach3 = iface3 and iface3:FindFirstChild("Achievements")
            local list3 = ach3 and ach3:FindFirstChild("List")
            local inner3 = list3 and list3:FindFirstChild("Inner")
            if inner3 then
                add("Achievement items (name | A_State.Visible | A_State.Title | Icon.New):")
                local n = 0
                for _, item in ipairs(inner3:GetChildren()) do
                    if n >= 25 then break end
                    n += 1
                    local box = item:FindFirstChild("Inner")
                    local st = box and box:FindFirstChild("A_State")
                    local ttl = st and st:FindFirstChild("Title")
                    local icon = box and box:FindFirstChild("Icon")
                    local nw = icon and icon:FindFirstChild("New")
                    add(("  %s | state=%s | text=%s | new=%s"):format(
                        item.Name,
                        st and tostring(st.Visible) or "n/a",
                        ttl and tostring(ttl.Text) or "n/a",
                        nw and tostring(nw.Visible) or "n/a"))
                end
            end
            local q3 = iface3 and iface3:FindFirstChild("Quests")
            if q3 then
                add("Quests page open (script's view): " .. tostring(QuestsOpen()))
                add("Quests.Close tree:")
                local out3 = {}
                local function walk3(inst, depth)
                    if depth > 3 or #out3 >= 30 then return end
                    for _, c in ipairs(inst:GetChildren()) do
                        if #out3 >= 30 then return end
                        out3[#out3 + 1] = string.rep("  ", depth) .. c.Name .. ":" .. c.ClassName
                        walk3(c, depth + 1)
                    end
                end
                local closeF = q3:FindFirstChild("Close")
                if closeF then walk3(closeF, 1) end
                for _, l in ipairs(out3) do add(l) end
            end
        end
        pcall(function()
            local iface4 = Interface()
            local ach4 = iface4 and iface4:FindFirstChild("Achievements")
            if not ach4 then return end
            local top4 = ach4:FindFirstChild("Top")
            add("Achievements view (script's view): " .. (AchInCategoryView() and "inside a category" or "category list"))
            for _, nm in ipairs({ "Category", "Title" }) do
                local lbl = top4 and top4:FindFirstChild(nm)
                if lbl and lbl:IsA("TextLabel") then
                    add(("Achievements.Top.%s text: %s"):format(nm, lbl.Text))
                end
            end
            local lst4 = ach4:FindFirstChild("List")
            local list4 = lst4 and lst4:FindFirstChild("Inner")
            if not list4 then return end
            local shown = 0
            for _, item in ipairs(list4:GetChildren()) do
                local box = item:FindFirstChild("Inner")
                local icon = box and box:FindFirstChild("Icon")
                local nw = icon and icon:FindFirstChild("New")
                if nw and nw:IsA("GuiObject") and nw.Visible and shown < 2 then
                    shown += 1
                    add("Flagged achievement category tree: " .. item.Name)
                    local out4 = {}
                    local function walk4(inst, depth)
                        if depth > 3 or #out4 >= 40 then return end
                        for _, c in ipairs(inst:GetChildren()) do
                            if #out4 >= 40 then return end
                            out4[#out4 + 1] = string.rep("  ", depth) .. c.Name .. ":" .. c.ClassName
                                .. (c:IsA("GuiButton") and " [BUTTON]" or "")
                            walk4(c, depth + 1)
                        end
                    end
                    walk4(item, 1)
                    for _, l in ipairs(out4) do add(l) end
                end
            end
        end)
        local text = table.concat(lines, "\n")
        local copied = false
        if type(setclipboard) == "function" then copied = pcall(setclipboard, text)
        elseif type(toclipboard) == "function" then copied = pcall(toclipboard, text) end
        local saved = false
        if type(writefile) == "function" then saved = pcall(writefile, "SmoothHub_claimdebug.txt", text) end
        SetClaimStatus(copied and "Debug copied" or (saved and "Debug saved to file" or "Copy/save not supported"))
    end)
    end
end
do
    local BLADE_STATS = { "Blade_Durability", "ODM_Gas", "Crit_Damage", "ODM_Control", "ODM_Speed", "Crit_Chance", "ODM_Range", "ODM_Damage" }
    local THUNDER_STATS = { "Blast_Radius", "TS_Damage", "TS_Gas", "TS_Range", "TS_Control", "Crit_Chance", "Crit_Damage", "TS_Speed" }
    local UPGRADE_INTERVAL = 10
    local UPGRADE_GAP = 1.5
    local EQUIP_AFTER_SPAWN = 3
    local CALL_TIMEOUT = 8
    local EquipSection = LobbyTab:PageSection({
        Title = "⚔️ Equipment",
        Subtitle = "Automatically upgrade and equip your Blade, ODM gear and Thunder Spears."
    })
    local EquipForm = EquipSection:Form()
    local EquipStatusRow = EquipForm:Row()
    EquipStatusRow:Left():TitleStack({ Title = "Equipment Status", Subtitle = "Result of the last request." })
    local EquipStatusLabel = EquipStatusRow:Right():Label({ Text = "Idle" })
    local function SetEquipStatus(text)
        pcall(function() EquipStatusLabel.Text = tostring(text) end)
    end
    local equipRemote = nil
    local function GetEquipRemote()
        if equipRemote and equipRemote.Parent then return equipRemote end
        equipRemote = GetLobbyRemote()
        return equipRemote
    end
    local function Invoke(...)
        local remote = GetEquipRemote()
        if not remote then return false, "remote not found" end
        local args = table.pack(...)
        local done, ok, result = false, false, nil
        task.spawn(function()
            ok, result = pcall(function()
                return remote:InvokeServer(table.unpack(args, 1, args.n))
            end)
            done = true
        end)
        local t0 = os.clock()
        while not done and os.clock() - t0 < CALL_TIMEOUT do task.wait(0.1) end
        if not done then return false, "timeout" end
        return ok, result
    end
    local function UpgradeAll(statList, label)
        local ok, r = Invoke("S_Equipment", "Upgrade", table.clone(statList))
        SetEquipStatus(ok and (label .. " upgrade sent") or (label .. " upgrade failed: " .. tostring(r)))
        return ok
    end
    local function EquipWeapon(kind, label)
        local ok, r = Invoke("S_Equipment", "Weapon", kind)
        SetEquipStatus(ok and (label .. " equip sent") or (label .. " equip failed: " .. tostring(r)))
        return ok
    end
    local toggles = {}
    local function AddEquipToggle(title, subtitle, key, onChange)
        local row = EquipForm:Row()
        row:Left():TitleStack({ Title = title, Subtitle = subtitle })
        toggles[key] = UiSync.Link(row:Right():Toggle({
            Value = Cfg[key],
            ValueChanged = function(self, value)
                Cfg[key] = value and true or false
                Save()
                if onChange then onChange(Cfg[key]) end
            end
        }), Cfg, key)
    end
    local function TurnOff(key)
        if Cfg[key] then
            Cfg[key] = false
            Save()
            pcall(function() toggles[key].Value = false end)
        end
    end
    AddEquipToggle("Auto Upgrade Gear ( Blade )", "Automatically upgrade BLADE & ODM.", "AutoUpgradeBlade", nil)
    AddEquipToggle("Auto Upgrade Gear ( Thunder Spears )", "Automatically upgrade thunder spears.", "AutoUpgradeThunder", nil)
    AddEquipToggle("Auto Equip Blade", "Automatically equip blades.", "AutoEquipBlade", function(on)
        if on then
            TurnOff("AutoEquipThunder")
            task.spawn(EquipWeapon, "Blades", "Blade")
        end
    end)
    AddEquipToggle("Auto Equip Thunder Spears", "Automatically equip thunder spears.", "AutoEquipThunder", function(on)
        if on then
            TurnOff("AutoEquipBlade")
            task.spawn(EquipWeapon, "Spears", "Thunder Spears")
        end
    end)
    task.spawn(function()
        local lastBlade, lastThunder = 0, 0
        while Alive() do
            if Cfg.AutoUpgradeBlade and os.clock() - lastBlade >= UPGRADE_INTERVAL then
                lastBlade = os.clock()
                UpgradeAll(BLADE_STATS, "Blade")
                task.wait(UPGRADE_GAP)
            end
            if Alive() and Cfg.AutoUpgradeThunder and os.clock() - lastThunder >= UPGRADE_INTERVAL then
                lastThunder = os.clock()
                UpgradeAll(THUNDER_STATS, "Thunder Spears")
                task.wait(UPGRADE_GAP)
            end
            task.wait(1)
        end
    end)
    local spawnConn
    spawnConn = LocalPlayer.CharacterAdded:Connect(function()
        if not Alive() then spawnConn:Disconnect() return end
        task.delay(EQUIP_AFTER_SPAWN, function()
            if not Alive() then return end
            if Cfg.AutoEquipThunder then
                EquipWeapon("Spears", "Thunder Spears")
            elseif Cfg.AutoEquipBlade then
                EquipWeapon("Blades", "Blade")
            end
        end)
    end)
end
local ProgressionTab = LobbyCategory:Tab({
    Title = "Progression",
    Icon = Icon("chartBarFill", "chartBarXaxis", "chartLineUptrendXyaxis"),
})
do
    local BOOSTS = { "Luck", "Gold", "EXP" }
    local function ProgToggle(form, title, subtitle, key)
        local row = form:Row()
        row:Left():TitleStack({ Title = title, Subtitle = subtitle })
        UiSync.Link(row:Right():Toggle({
            Value = Cfg[key],
            ValueChanged = function(self, value)
                Cfg[key] = value and true or false
                Save()
            end
        }), Cfg, key)
    end
    local function ProgSlider(form, title, subtitle, key)
        local range = FARM_RANGES[key]
        local row = form:Row()
        local function titleFor(v) return title .. " ( " .. v .. " )" end
        local stack = row:Left():TitleStack({ Title = titleFor(Cfg[key]), Subtitle = subtitle })
        UiSync.Link(row:Right():Slider({
            Minimum = range[1],
            Maximum = range[2],
            Value = Cfg[key],
            ValueChanged = function(self, value)
                local v = math.clamp(math.floor(value + 0.5), range[1], range[2])
                Cfg[key] = v
                pcall(function() stack.Title = titleFor(v) end)
                Save()
            end
        }), Cfg, key, function(_, want)
            pcall(function() stack.Title = titleFor(want) end)
        end)
    end
    local function ProgPick(form, title, options, key)
        local row = form:Row()
        row:Left():TitleStack({ Title = title })
        local btn = row:Right():PullDownButton({
            Label = Cfg[key],
            Options = options,
            Value = table.find(options, Cfg[key]) or 1,
            ValueChanged = function(self, index)
                if options[index] then
                    Cfg[key] = options[index]
                    self.Label = options[index]
                    Save()
                end
            end
        })
        StyleDropdown(btn)
        UiSync.Add(function()
            local i = table.find(options, Cfg[key]) or 1
            btn.Value = i
            btn.Label = options[i]
        end)
    end
    local PrestigeSection = ProgressionTab:PageSection({
        Title = "👑 Prestige Section",
        Subtitle = "Automatically prestige and choose your boosts."
    })
    local PrestigeForm = PrestigeSection:Form()
    ProgToggle(PrestigeForm, "Auto Prestige", "Automatically prestige.", "AutoPrestige")
    for i = 1, 5 do
        ProgPick(PrestigeForm, "Prestige " .. i .. " Boost", BOOSTS, "PrestigeBoost" .. i)
    end
    ProgSlider(PrestigeForm, "Prestige Stop At", nil, "PrestigeStopAt")
    local PrestigeStatusRow = PrestigeForm:Row()
    local PrestigeStack = PrestigeStatusRow:Left():TitleStack({ Title = "Prestige Status", Subtitle = "Idle" })
    local MemorySection = ProgressionTab:PageSection({
        Title = "🧠 Memories Priority",
        Subtitle = "Set a priority for each memory (0 - 10)."
    })
    local MemoryForm = MemorySection:Form()
    for _, m in ipairs(SH.Memories) do
        ProgSlider(MemoryForm, m.Name, string.rep("★", m.Stars) .. "  " .. m.Desc, m.Key)
    end

    -- ===== Auto Prestige: กดผ่าน UI ตามขั้นตอนของเกม (ไม่ต้องรู้ Remote) =====
    -- ลำดับ: เปิด Equipment > Prestige -> กด PRESTIGE -> กด YES -> เลือกบัฟ (Luck/EXP/Gold) -> NEXT
    --        -> เลือกการ์ด Memory ตาม Memories Priority -> FINISH
    do
        local P = { Busy = false, Pending = false }
        Farm.Prestige = P
        SH.Coord.Register("Auto Prestige", 10, function() return P.Pending end, function() return P.Busy end, 240)
        local function Say(t) pcall(function() PrestigeStack.Subtitle = tostring(t) end) end
        local function Norm(x)
            x = tostring(x or ""):gsub("<[^>]->", ""):lower():gsub("[^%w]", "")
            return x
        end
        local function Path(...)
            local cur = PlayerGui
            for _, n in ipairs({ ... }) do
                cur = cur and cur:FindFirstChild(n)
            end
            return cur
        end
        local function HasText(btn, label)
            local want = Norm(label)
            if btn:IsA("TextButton") and Norm(btn.Text) == want then return true end
            for _, d in ipairs(btn:GetDescendants()) do
                if (d:IsA("TextLabel") or d:IsA("TextButton")) and Norm(d.Text) == want then return true end
            end
            return false
        end
        local function FindButton(label, extra)
            local n = 0
            for _, d in ipairs(PlayerGui:GetDescendants()) do
                n += 1
                if n % 1500 == 0 then task.wait() end
                if d:IsA("GuiButton") and IsShown(d) and HasText(d, label) and (not extra or extra(d)) then
                    return d
                end
            end
            return nil
        end
        local function FindLabel(normText)
            local n = 0
            for _, d in ipairs(PlayerGui:GetDescendants()) do
                n += 1
                if n % 1500 == 0 then task.wait() end
                if d:IsA("TextLabel") and IsShown(d) and Norm(d.Text) == normText then return d end
            end
            return nil
        end
        local function DialogMentions(btn, normText)
            local cur = btn.Parent
            for _ = 1, 5 do
                if not cur or cur == PlayerGui then break end
                for _, x in ipairs(cur:GetDescendants()) do
                    if x:IsA("TextLabel") and IsShown(x) and Norm(x.Text):find(normText, 1, true) then return true end
                end
                cur = cur.Parent
            end
            return false
        end

        -- วิธีกดปุ่ม (ลองทีละแบบ แล้วเช็กว่าหน้าจอเปลี่ยนจริงก่อนไปขั้นถัดไป)
        local METHODS = {
            function(b)
                if type(firesignal) ~= "function" then return false end
                return (pcall(firesignal, b.Activated))
            end,
            function(b)
                if type(firesignal) ~= "function" then return false end
                return (pcall(firesignal, b.MouseButton1Click))
            end,
            function(b)
                pcall(function() GuiService.SelectedObject = b end)
                task.wait(0.1)
                return (pcall(function()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                end))
            end,
            function(b)
                local gui = b:FindFirstAncestorOfClass("ScreenGui")
                local inset = (gui and gui.IgnoreGuiInset) and Vector2.zero or GuiService:GetGuiInset()
                local pos = b.AbsolutePosition + b.AbsoluteSize / 2 + inset
                return (pcall(function()
                    VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
                    task.wait(0.05)
                    VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
                end))
            end,
        }
        local function PressOnce(btn)
            for _, m in ipairs(METHODS) do
                if m(btn) then return true end
            end
            return false
        end
        local function ClickUntil(findFn, doneFn, timeout)
            local deadline = os.clock() + timeout
            local mi = 1
            while os.clock() < deadline and Alive() and Cfg.AutoPrestige do
                if doneFn() then return true end
                local btn = findFn()
                if btn then
                    METHODS[mi](btn)
                    local t = os.clock()
                    while os.clock() - t < 1.5 do
                        if doneFn() then return true end
                        task.wait(0.1)
                    end
                    mi = mi % #METHODS + 1
                else
                    task.wait(0.4)
                end
            end
            return doneFn()
        end

        -- หาปุ่มของการ์ดจากข้อความหัวการ์ด (ไต่ขึ้นไปหา parent ที่มีปุ่ม แต่ไม่กว้างจนครอบการ์ดอื่น)
        local function CardButton(label, others)
            local cur = label.Parent
            for _ = 1, 6 do
                if not cur or cur == PlayerGui then break end
                local descendants = cur:GetDescendants()
                for _, x in ipairs(descendants) do
                    if others[x] then return nil end
                end
                for _, x in ipairs(descendants) do
                    if x:IsA("GuiButton") and IsShown(x) then return x end
                end
                cur = cur.Parent
            end
            return nil
        end

        -- การ์ดทั้งใบ (ตัวใหญ่สุดที่ครอบป้ายนี้ โดยไม่ครอบการ์ดอื่น) ใช้คลิกด้วยเมาส์จำลองเมื่อในการ์ดไม่มีปุ่มจริง
        local function CardFrame(label, others)
            local best, cur = nil, label.Parent
            local cam = workspace.CurrentCamera
            local maxW = cam and cam.ViewportSize.X * 0.4 or math.huge
            for _ = 1, 6 do
                if not cur or cur == PlayerGui or not cur:IsA("GuiObject") then break end
                if cur.AbsoluteSize.X > maxW then break end
                local bad = false
                for _, x in ipairs(cur:GetDescendants()) do
                    if others[x] then bad = true break end
                end
                if bad then break end
                best = cur
                cur = cur.Parent
            end
            return best
        end
        local function DumpCard(card)
            local rows = {}
            for _, d in ipairs(card:GetDescendants()) do
                if #rows >= 30 then break end
                rows[#rows + 1] = d.ClassName .. ":" .. d.Name .. (d:IsA("GuiButton") and "[btn]" or "")
            end
            warn("[Smooth Hub] boost card " .. card:GetFullName() .. " -> " .. table.concat(rows, ", "))
        end
        local BOOST_LABEL = { Luck = "luckboost", Gold = "goldboost", EXP = "expboost" }
        local function BoostScreenShown()
            return FindLabel("luckboost") ~= nil
        end
        local function FinishShown()
            return FindButton("FINISH") ~= nil
        end
        local function YesButton()
            return FindButton("YES", function(b) return DialogMentions(b, "areyousureyouwanttoprestige") end)
        end

        local function MemoryCandidates()
            local byName = {}
            for _, m in ipairs(SH.Memories) do
                byName[Norm((m.Name:gsub("^%[.-%]%s*", "")))] = m
            end
            local list, n = {}, 0
            for _, d in ipairs(PlayerGui:GetDescendants()) do
                n += 1
                if n % 1500 == 0 then task.wait() end
                if d:IsA("TextLabel") and IsShown(d) then
                    local m = byName[Norm(d.Text)]
                    if m then
                        local full = d:GetFullName()
                        if not full:find(".Passives.", 1, true) and not full:find(".Storage.", 1, true) then
                            list[#list + 1] = { label = d, mem = m }
                        end
                    end
                end
            end
            return list
        end

        local function PrestigeCount() return tonumber(LocalPlayer:GetAttribute("Prestige")) or 0 end

        local function Eligible()
            local lbl = Path("Interface", "Equipment", "Prestige", "Progress", "Level")
            if not (lbl and lbl:IsA("TextLabel")) then return false, "ไม่พบหน้า Prestige" end
            local txt = lbl.Text
            if Norm(txt):find("maxlvl", 1, true) then return true end
            local cur, max = txt:match("(%d+)%s*/%s*(%d+)")
            cur = tonumber(LocalPlayer:GetAttribute("Level")) or tonumber(cur)
            max = tonumber(max)
            if cur and max and cur >= max then return true end
            return false, ("เลเวล %s / %s ยังไม่เต็ม"):format(tostring(cur), tostring(max))
        end

        -- stage: 1 เปิดหน้า/กดจุติ, 3 ตอบ YES, 4 เลือกบัฟ, 5 เลือกการ์ด + FINISH
        local function RunFlow(stage)
            P.Busy = true
            local before = PrestigeCount()
            local nextIndex = math.clamp(before + 1, 1, 5)
            local ok, where = pcall(function()
                if stage <= 1 then
                    Say("เปิดหน้า Prestige...")
                    local function PageFinder()
                        local eq = Path("Interface", "Equipment")
                        if not (eq and IsShown(eq)) then
                            return Path("Interface", "Topbar", "Main", "Categories", "Equipment", "Interact")
                        end
                        return Path("Interface", "Equipment", "Categories", "Prestige", "Main", "Interact")
                    end
                    local function PrestigeBtn()
                        local b = Path("Interface", "Equipment", "Prestige", "B_Prestige")
                        return (b and IsShown(b)) and b or nil
                    end
                    if not ClickUntil(PageFinder, function() return PrestigeBtn() ~= nil end, 12) then return "เปิดหน้า Prestige" end
                    Say("กดปุ่ม PRESTIGE...")
                    if not ClickUntil(PrestigeBtn, function() return YesButton() ~= nil end, 10) then return "ปุ่ม PRESTIGE" end
                end
                if stage <= 3 then
                    Say("กดยืนยัน YES...")
                    if not ClickUntil(YesButton, BoostScreenShown, 10) then return "ปุ่ม YES" end
                end
                if stage <= 4 then
                    local want = Cfg["PrestigeBoost" .. nextIndex] or "Luck"
                    Say(("เลือกบัฟ %s (จุติครั้งที่ %d)..."):format(want, nextIndex))
                    -- ต้องกดการ์ดที่เลือกเสมอ (รวม Luck ด้วย) แล้วเช็กว่าปุ่ม NEXT โผล่ ถ้ายังไม่โผล่ลองวิธีกดถัดไป
                    local lab = BOOST_LABEL[want] and FindLabel(BOOST_LABEL[want])
                    if lab then
                        local others = {}
                        for k, v in pairs(BOOST_LABEL) do
                            if k ~= want then
                                local o = FindLabel(v)
                                if o then others[o] = true end
                            end
                        end
                        for attempt = 1, 3 do
                            local btn = CardButton(lab, others)
                            local card = CardFrame(lab, others)
                            if attempt == 1 then
                                if card then METHODS[4](card) elseif btn then PressOnce(btn) end
                            elseif attempt == 2 then
                                if btn then PressOnce(btn) elseif card then METHODS[4](card) end
                            else
                                METHODS[4](lab)
                            end
                            local seen = false
                            local t = os.clock()
                            while os.clock() - t < 1.5 do
                                task.wait(0.3)
                                if FindButton("NEXT") then seen = true break end
                            end
                            if seen then break end
                            if attempt == 3 and card then DumpCard(card) end
                        end
                    else
                        Say("ไม่พบการ์ดบัฟ " .. tostring(want))
                    end
                    Say("กด NEXT...")
                    if not ClickUntil(function() return FindButton("NEXT") end, FinishShown, 10) then return "ปุ่ม NEXT" end
                end
                -- stage 5
                task.wait(0.8)
                local cands = MemoryCandidates()
                if #cands > 0 then
                    table.sort(cands, function(x, y)
                        local px, py = Cfg[x.mem.Key] or 5, Cfg[y.mem.Key] or 5
                        if px ~= py then return px > py end
                        if x.mem.Stars ~= y.mem.Stars then return x.mem.Stars > y.mem.Stars end
                        return x.label.AbsolutePosition.X < y.label.AbsolutePosition.X
                    end)
                    local best = cands[1]
                    Say("เลือกการ์ด " .. best.mem.Name .. " ...")
                    local others = {}
                    for i = 2, #cands do others[cands[i].label] = true end
                    local card = CardFrame(best.label, others)
                    if card then
                        METHODS[4](card)
                        task.wait(0.6)
                    else
                        local btn = CardButton(best.label, others)
                        if btn then PressOnce(btn) task.wait(0.6) end
                    end
                else
                    Say("ไม่พบการ์ด Memory - ใช้ตัวที่เลือกอยู่ตอนนี้")
                end
                Say("กด FINISH...")
                local function Finished() return not FinishShown() end
                if not ClickUntil(function() return FindButton("FINISH") end, Finished, 12) then return "ปุ่ม FINISH" end
                return nil
            end)
            P.Busy = false
            if not ok then
                Say("Error: " .. tostring(where))
                return false
            end
            if where then
                Say("ไม่สำเร็จที่: " .. where .. " (ลองใหม่ใน 30 วินาที)")
                return false
            end
            Say(("จุติสำเร็จ (ตอนนี้ Prestige %d)"):format(PrestigeCount()))
            return true
        end

        task.spawn(function()
            local cooldownUntil, tick = 0, 0
            while Alive() do
                task.wait(1)
                tick += 1
                if not Cfg.AutoPrestige then
                    P.Pending = false
                    if tick % 5 == 0 then Say("Off") end
                elseif not (IN_MENU or game.PlaceId == 14916516914) then
                    P.Pending = false
                    Say("ใช้ได้เฉพาะในล็อบบี้")
                elseif not P.Busy and os.clock() >= cooldownUntil then
                    local count = PrestigeCount()
                    if count >= (Cfg.PrestigeStopAt or 1) then
                        P.Pending = false
                        Say(("หยุดแล้ว: Prestige %d ถึงเป้าหมาย %d"):format(count, Cfg.PrestigeStopAt or 1))
                    else
                        local stage = nil
                        if tick % 5 == 0 then
                            -- เผื่อค้างอยู่กลางขั้นตอนจากรอบก่อน
                            if FinishShown() then stage = 5
                            elseif BoostScreenShown() then stage = 4
                            elseif YesButton() then stage = 3 end
                        end
                        if not stage then
                            local okLvl, why = Eligible()
                            if okLvl then stage = 1 else P.Pending = false Say(why or "รอเลเวลเต็ม") end
                        end
                        if stage then
                            P.Pending = true
                            local done = RunFlow(stage)
                            if done then P.Pending = false end
                            cooldownUntil = os.clock() + (done and 10 or 30)
                        end
                    end
                end
            end
        end)
    end
end
local SkillTreesTab = LobbyCategory:Tab({
    Title = "Skill Trees",
    Icon = Icon("bookPagesFill", "bookFill", "book"),
})
do
    local SKILL_INTERVAL = 10
    local SKILL_GAP = 1.5
    local SKILL_TIMEOUT = 8
    local SKILL_PATHS = {
        Left = {
            ["Regen VI"] = { "89", "88", "87", "86", "85", "84", "83", "82", "81", "80", "79", "78", "77", "76", "75", "154", "73", "72", "71", "70" },
            ["Injury III"] = { "98", "97", "96", "95", "94", "93", "92", "91", "90", "80", "79", "78", "77", "76", "75", "154", "73", "72", "71", "70" },
        },
        Middle = {
            ["Damage V"] = { "149", "148", "147", "146", "145", "144", "143", "142", "141", "140", "139", "138", "125", "124", "123", "122", "121", "120", "119", "118", "117", "116", "115", "114", "113" },
            ["Crit Damage V"] = { "137", "136", "135", "134", "133", "132", "131", "130", "129", "128", "127", "126", "125", "124", "123", "122", "121", "120", "119", "118", "117", "116", "115", "114", "113" },
        },
        Right = {
            ["Tank VIII"] = { "69", "68", "67", "66", "65", "64", "63", "62", "61", "60", "151", "58", "45", "44", "43", "42", "41", "150", "39", "38" },
            ["Health XI"] = { "57", "56", "55", "54", "53", "52", "51", "50", "49", "48", "47", "46", "45", "44", "43", "42", "41", "150", "39", "38" },
        },
    }
    local SkillSection = SkillTreesTab:PageSection({
        Title = "Skills",
        Subtitle = "Auto upgrade the skill tree."
    })
    local SkillForm = SkillSection:Form()
    local SkillStatusRow = SkillForm:Row()
    SkillStatusRow:Left():TitleStack({ Title = "Skill Status", Subtitle = "Result of the last request." })
    local SkillStatusLabel = SkillStatusRow:Right():Label({ Text = "Idle" })
    local function SetSkillStatus(text)
        pcall(function() SkillStatusLabel.Text = tostring(text) end)
    end
    local skillWake = false
    local skillRemote = nil
    local function GetSkillRemote()
        if skillRemote and skillRemote.Parent then return skillRemote end
        skillRemote = GetLobbyRemote()
        return skillRemote
    end
    local function SkillInvoke(...)
        local remote = GetSkillRemote()
        if not remote then return false, "remote not found" end
        local args = table.pack(...)
        local done, ok, result = false, false, nil
        task.spawn(function()
            ok, result = pcall(function()
                return remote:InvokeServer(table.unpack(args, 1, args.n))
            end)
            done = true
        end)
        local t0 = os.clock()
        while not done and os.clock() - t0 < SKILL_TIMEOUT do task.wait(0.1) end
        if not done then return false, "timeout" end
        return ok, result
    end
    local SKILL_LANES = {
        { Name = "Left",   On = "SkillLeft",   Pick = "SkillLeftPick",   Pri = "SkillLeftPriority" },
        { Name = "Middle", On = "SkillMiddle", Pick = "SkillMiddlePick", Pri = "SkillMiddlePriority" },
        { Name = "Right",  On = "SkillRight",  Pick = "SkillRightPick",  Pri = "SkillRightPriority" },
    }
    local function UpgradeSkills()
        local lanes = {}
        for i, lane in ipairs(SKILL_LANES) do
            if Cfg[lane.On] then
                lanes[#lanes + 1] = { lane = lane, order = i }
            end
        end
        if #lanes == 0 then
            SetSkillStatus("No path enabled")
            return
        end
        table.sort(lanes, function(a, b)
            local pa, pb = Cfg[a.lane.Pri], Cfg[b.lane.Pri]
            if pa ~= pb then return pa < pb end
            return a.order < b.order
        end)
        for _, entry in ipairs(lanes) do
            if not Alive() or not Cfg.AutoUpgradeSkills then return end
            local lane = entry.lane
            local pick = Cfg[lane.Pick]
            local ids = SKILL_PATHS[lane.Name] and SKILL_PATHS[lane.Name][pick]
            if not ids then
                SetSkillStatus(lane.Name .. " ( " .. tostring(pick) .. " ): not supported yet")
            else
                local ok, r = SkillInvoke("S_Equipment", "Unlock", table.clone(ids))
                SetSkillStatus(ok and (lane.Name .. " ( " .. pick .. " ) sent: " .. tostring(r))
                    or (lane.Name .. " ( " .. pick .. " ) failed: " .. tostring(r)))
                task.wait(SKILL_GAP)
            end
        end
    end
    task.spawn(function()
        local last = 0
        while Alive() do
            if Cfg.AutoUpgradeSkills and (skillWake or os.clock() - last >= SKILL_INTERVAL) then
                skillWake = false
                last = os.clock()
                UpgradeSkills()
            end
            task.wait(1)
        end
    end)
    local function SkillToggle(form, title, subtitle, key)
        local row = form:Row()
        row:Left():TitleStack({ Title = title, Subtitle = subtitle })
        UiSync.Link(row:Right():Toggle({
            Value = Cfg[key],
            ValueChanged = function(self, value)
                Cfg[key] = value and true or false
                Save()
                if value then skillWake = true end
            end
        }), Cfg, key)
    end
    local function SkillPick(form, title, options, key)
        local row = form:Row()
        row:Left():TitleStack({ Title = title })
        local btn = row:Right():PullDownButton({
            Label = Cfg[key],
            Options = options,
            Value = table.find(options, Cfg[key]) or 1,
            ValueChanged = function(self, index)
                if options[index] then
                    Cfg[key] = options[index]
                    self.Label = options[index]
                    Save()
                end
            end
        })
        StyleDropdown(btn)
        UiSync.Add(function()
            local i = table.find(options, Cfg[key]) or 1
            btn.Value = i
            btn.Label = options[i]
        end)
    end
    SkillToggle(SkillForm, "Auto Upgrade Skills", "Automatically upgrade skills tree.", "AutoUpgradeSkills")
    SkillToggle(SkillForm, "Left", "Upgrade the left path.", "SkillLeft")
    SkillPick(SkillForm, "Left Path", { "Regen VI", "Injury III" }, "SkillLeftPick")
    SkillToggle(SkillForm, "Middle", "Upgrade the middle path.", "SkillMiddle")
    SkillPick(SkillForm, "Middle Path", { "Damage V", "Crit Damage V" }, "SkillMiddlePick")
    SkillToggle(SkillForm, "Right", "Upgrade the right path.", "SkillRight")
    SkillPick(SkillForm, "Right Path", { "Tank VIII", "Health XI" }, "SkillRightPick")
    local PrioritySection = SkillTreesTab:PageSection({
        Title = "Upgrade Priority",
        Subtitle = "Adjust the upgrade priority to determine which path you want to upgrade first."
    })
    local PriorityForm = PrioritySection:Form()
    local function SkillPriority(title, key)
        local range = FARM_RANGES[key]
        local row = PriorityForm:Row()
        local function titleFor(v) return title .. " ( " .. v .. " )" end
        local stack = row:Left():TitleStack({ Title = titleFor(Cfg[key]) })
        UiSync.Link(row:Right():Slider({
            Minimum = range[1],
            Maximum = range[2],
            Value = Cfg[key],
            ValueChanged = function(self, value)
                local v = math.clamp(math.floor(value + 0.5), range[1], range[2])
                Cfg[key] = v
                pcall(function() stack.Title = titleFor(v) end)
                Save()
            end
        }), Cfg, key, function(_, want)
            pcall(function() stack.Title = titleFor(want) end)
        end)
    end
    SkillPriority("Left Priority", "SkillLeftPriority")
    SkillPriority("Middle Priority", "SkillMiddlePriority")
    SkillPriority("Right Priority", "SkillRightPriority")
end
local PerksTab = LobbyCategory:Tab({
    Title = "Perks",
    Icon = Icon("sparkles", "sparkle", "starFill"),
})
do
    local function PerkToggle(form, title, subtitle, key)
        local row = form:Row()
        row:Left():TitleStack({ Title = title, Subtitle = subtitle })
        UiSync.Link(row:Right():Toggle({
            Value = Cfg[key],
            ValueChanged = function(self, value)
                Cfg[key] = value and true or false
                Save()
            end
        }), Cfg, key)
    end
    local function PerkSlider(form, title, key)
        local range = FARM_RANGES[key]
        local row = form:Row()
        local function titleFor(v) return title .. " ( " .. v .. " )" end
        local stack = row:Left():TitleStack({ Title = titleFor(Cfg[key]) })
        UiSync.Link(row:Right():Slider({
            Minimum = range[1],
            Maximum = range[2],
            Value = Cfg[key],
            ValueChanged = function(self, value)
                local v = math.clamp(math.floor(value + 0.5), range[1], range[2])
                Cfg[key] = v
                pcall(function() stack.Title = titleFor(v) end)
                Save()
            end
        }), Cfg, key, function(_, want)
            pcall(function() stack.Title = titleFor(want) end)
        end)
    end
    local CraftSection = PerksTab:PageSection({
        Title = "🔨 Crafting",
        Subtitle = "Automatically craft perks."
    })
    local CraftForm = CraftSection:Form()
    PerkToggle(CraftForm, "Auto Craft Perks", "Automatically craft perks.", "AutoCraftPerks")
    PerkToggle(CraftForm, "Common → Rare", nil, "CraftCommonRare")
    PerkSlider(CraftForm, "Common → Rare Chance", "CraftChanceCommonRare")
    PerkToggle(CraftForm, "Rare → Epic", nil, "CraftRareEpic")
    PerkSlider(CraftForm, "Rare → Epic Chance", "CraftChanceRareEpic")
    PerkToggle(CraftForm, "Epic → Legendary", nil, "CraftEpicLegendary")
    PerkSlider(CraftForm, "Epic → Legendary Chance", "CraftChanceEpicLegendary")
    PerkToggle(CraftForm, "Legendary → Mythic", nil, "CraftLegendaryMythic")
    PerkSlider(CraftForm, "Legendary → Mythic Chance", "CraftChanceLegendaryMythic")
end
local GameModeCategory = Cascade.Components.Section(Window, {
    Title = "Game Mode",
    Disclosure = false
})
local MissionsTab = GameModeCategory:Tab({
    Title = "Missions",
    Icon = Icon("listClipboardFill", "clipboardFill", "checklist"),
})
local WaveModeTab = GameModeCategory:Tab({
    Title = "Wave Mode",
    Icon = Icon("waveformCircleFill", "waveform", "tornado"),
})
local RaidModeTab = GameModeCategory:Tab({
    Title = "Raid Mode",
    Icon = Icon("diamondFill", "shieldFill", "flameFill"),
})
local MISSION_OPTIONS    = { "Shiganshina", "Trost", "Outskirts", "Forest", "Utgard", "Docks", "Stohess", "Chapel" }
local OBJECTIVE_OPTIONS  = { "Skirmish" }
local DIFFICULTY_OPTIONS = { "Easy (E- Grade)", "Normal (E+ Grade)", "Hard (D+ Grade)", "Severe (B- Grade)", "Aberrant (A- Grade)" }
local MODIFIER_OPTIONS   = { "No Perks", "No Skills", "No Memories", "Nightmare", "Oddball", "Injury Prone", "Chronic Injuries", "Fog", "Glass Cannon", "Time Trial", "Boring", "Simple" }
do
    local MissionsSection = MissionsTab:PageSection({
        Title = "📜 Mission Settings",
        Subtitle = "Pick the mission, objective, difficulty and modifiers for your room."
    })
    local MissionForm = MissionsSection:Form()
    local AutoMissionSection = MissionsTab:PageSection({
        Title = "🤖 Auto Mission",
        Subtitle = "Create your room first, then turn on Auto Start."
    })
    local AutoMissionForm = AutoMissionSection:Form()
    local MissionStatusRow = MissionForm:Row()
    MissionStatusRow:Left():TitleStack({ Title = "Mission Status", Subtitle = "Current step and last result." })
    local MissionStatusLabel = MissionStatusRow:Right():Label({ Text = "Idle" })
    local STATUS_RED = Color3.fromRGB(255, 69, 58)
    local statusDefaultColor = nil
    pcall(function()
        local o = LabelObject(MissionStatusLabel)
        if o then statusDefaultColor = o.TextColor3 end
    end)
    local function SetMissionStatus(text, isError)
        pcall(function() MissionStatusLabel.Text = tostring(text) end)
        pcall(function()
            local o = LabelObject(MissionStatusLabel)
            if not o then return end
            if isError then
                o.TextColor3 = STATUS_RED
            elseif statusDefaultColor then
                o.TextColor3 = statusDefaultColor
            end
        end)
    end
    local missionToggles = {}
    local function SetMissionToggle(key, value)
        pcall(function() missionToggles[key].Value = value end)
    end
    local function ResetAutoCreate(reason, quiet)
        if not Cfg.AutoCreateMission then return end
        Cfg.AutoCreateMission = false
        Save()
        SetMissionToggle("AutoCreateMission", false)
        if not quiet and reason then SetMissionStatus("Auto Create off (" .. tostring(reason) .. ")") end
    end
    local missionRecreateAt = nil
    local function RequestRecreate()
        if Cfg.AutoCreateMission then missionRecreateAt = os.clock() + 1.5 end
    end
    local createdRoom = nil
    local function MyRoomObject()
        local folder = ReplicatedStorage:FindFirstChild("Missions")
        if not folder then return nil end
        for _, room in ipairs(folder:GetChildren()) do
            local leader = room:FindFirstChild("Leader")
            if leader and leader:IsA("ValueBase") and leader.Value == LocalPlayer.Name then
                return room
            end
        end
        return nil
    end
    local function HasRoom()
        if createdRoom and createdRoom.Parent ~= nil then return true end
        return MyRoomObject() ~= nil
    end
    local missionStacks = {}
    local function KeepValid(options, value, fallback)
        return table.find(options, value) and value or fallback
    end
    local function KeepValidList(options, list)
        local out, seen = {}, {}
        if type(list) == "table" then
            for _, name in ipairs(list) do
                if table.find(options, name) and not seen[name] then
                    seen[name] = true
                    out[#out + 1] = name
                end
            end
        end
        return out
    end
    Cfg.MissionSelect = KeepValid(MISSION_OPTIONS, Cfg.MissionSelect, MISSION_OPTIONS[1])
    Cfg.MissionObjective = KeepValid(OBJECTIVE_OPTIONS, Cfg.MissionObjective, OBJECTIVE_OPTIONS[1])
    Cfg.MissionLevel = KeepValid(DIFFICULTY_OPTIONS, Cfg.MissionLevel, DIFFICULTY_OPTIONS[1])
    Cfg.MissionModifiers = KeepValidList(MODIFIER_OPTIONS, Cfg.MissionModifiers)
    local function AddSingleSelect(title, subtitle, options, key)
        local row = MissionForm:Row()
        row:Left():TitleStack({ Title = title, Subtitle = subtitle })
        local btn = row:Right():PullDownButton({
            Label = Cfg[key],
            Options = options,
            Value = table.find(options, Cfg[key]) or 1,
            ValueChanged = function(self, index)
                if options[index] then
                    Cfg[key] = options[index]
                    self.Label = options[index]
                    Save()
                    RequestRecreate()
                end
            end
        })
        StyleDropdown(btn)
        UiSync.Add(function()
            local i = table.find(options, Cfg[key]) or 1
            btn.Value = i
            btn.Label = options[i]
        end)
    end
    local function AddMultiSelect(title, subtitle, options, key)
        local row = MissionForm:Row()
        row:Left():TitleStack({ Title = title, Subtitle = subtitle })
        local function apply(value)
            local indexes = type(value) == "table" and value or { value }
            local names = {}
            for _, index in ipairs(SettingsStore.ValidIndexes(indexes, #options)) do
                names[#names + 1] = options[index]
            end
            Cfg[key] = names
            Save()
            RequestRecreate()
        end
        local current = {}
        for i, name in ipairs(options) do
            if table.find(Cfg[key], name) then current[#current + 1] = i end
        end
        local ok, btn = pcall(function()
            return row:Right():PopUpButton({
                Options = options,
                Maximum = #options,
                Value = current,
                ValueChanged = function(self, value) apply(value) end
            })
        end)
        if not ok or not btn then
            btn = row:Right():PullDownButton({
                Label = Cfg[key][1] or "None",
                Options = options,
                Value = table.find(options, Cfg[key][1]) or 1,
                ValueChanged = function(self, index)
                    apply(index)
                    self.Label = options[index] or "None"
                end
            })
        end
        StyleDropdown(btn)
        UiSync.Add(function()
            if ok then
                local picked = {}
                for i, name in ipairs(options) do
                    if table.find(Cfg[key], name) then picked[#picked + 1] = i end
                end
                btn.Value = picked
            else
                local i = table.find(options, Cfg[key][1]) or 1
                btn.Value = i
                btn.Label = options[i]
            end
        end)
    end
    local function AddMissionToggle(title, subtitle, key, form, onChange)
        local row = (form or MissionForm):Row()
        missionStacks[key] = { stack = row:Left():TitleStack({ Title = title, Subtitle = subtitle }), text = subtitle }
        missionToggles[key] = UiSync.Link(row:Right():Toggle({
            Value = Cfg[key],
            ValueChanged = function(self, value)
                Cfg[key] = value and true or false
                Save()
                if onChange then onChange(Cfg[key]) end
            end
        }), Cfg, key)
    end
    local initializing = true
    local CreateRoomOnce
    AddSingleSelect("Select Mission", "Choose the mission.", MISSION_OPTIONS, "MissionSelect")
    AddSingleSelect("Select Objective", "Only Skirmish for now.", OBJECTIVE_OPTIONS, "MissionObjective")
    AddSingleSelect("Select Difficulty", "Difficulty used when creating the room.", DIFFICULTY_OPTIONS, "MissionLevel")
    AddMultiSelect("Select Modifiers", "Tick the Modifiers to apply after creating.", MODIFIER_OPTIONS, "MissionModifiers")
    AddMissionToggle("Auto Create Mission", "Keeps a room ready with these settings. Remembered next time.", "AutoCreateMission", AutoMissionForm, function(on)
        if on then SetMissionToggle("AutoCreateRaid", false) SetMissionToggle("AutoCreateWave", false) end
        if on and not initializing then missionRecreateAt = os.clock() SH.autoPaused = false end
    end)
    AddMissionToggle("Auto Start Missions", "Starts the mission in your room. Remembered next time.", "AutoStartMission", AutoMissionForm, function(on)
        if on then SetMissionToggle("AutoStartRaid", false) SetMissionToggle("AutoStartWave", false) end
    end)
    local MissionDelayRow = AutoMissionForm:Row()
    local delaySubtitle = "Seconds between starts (" .. MIN_DELAY .. " - " .. MAX_DELAY .. ")."
    missionStacks.JoinDelay = {
        stack = MissionDelayRow:Left():TitleStack({ Title = "Join Delay", Subtitle = delaySubtitle }),
        text = delaySubtitle,
    }
    local MissionDelayRight = MissionDelayRow:Right()
    local MissionDelayLabel = MissionDelayRight:Label({ Text = Cfg.MissionJoinDelay .. "s" })
    UiSync.Link(MissionDelayRight:Slider({
        Minimum = MIN_DELAY,
        Maximum = MAX_DELAY,
        Value = Cfg.MissionJoinDelay,
        ValueChanged = function(self, value)
            Cfg.MissionJoinDelay = ClampDelay(value)
            pcall(function() MissionDelayLabel.Text = Cfg.MissionJoinDelay .. "s" end)
            Save()
        end
    }), Cfg, "MissionJoinDelay", function(_, want)
        pcall(function() MissionDelayLabel.Text = want .. "s" end)
    end)
    local MissionCountRow = AutoMissionForm:Row()
    MissionCountRow:Left():TitleStack({ Title = "Next Mission", Subtitle = "Countdown to the next start." })
    local MissionCountLabel = MissionCountRow:Right():Label({ Text = "Off" })
    local lastCountText = nil
    local function SetMissionCountdown(text)
        if text == lastCountText then return end
        lastCountText = text
        pcall(function() MissionCountLabel.Text = text end)
    end
    local function RefreshRoomGate() return HasRoom() end
    local LOBBY_PLACE_ID = 14916516914
    local ON_LOBBY_PLACE = (game.PlaceId == LOBBY_PLACE_ID)
    local CALL_TIMEOUT = 8
    local START_GAP = 1.5
    local missionRemote = nil
    local function MissionInvoke(...)
        if not missionRemote or not missionRemote.Parent then
            missionRemote = GetLobbyRemote()
        end
        if not missionRemote then return false, "remote not found" end
        local remote = missionRemote
        local args = table.pack(...)
        local done, ok, result = false, false, nil
        task.spawn(function()
            ok, result = pcall(function()
                return remote:InvokeServer(table.unpack(args, 1, args.n))
            end)
            done = true
        end)
        local t0 = os.clock()
        while not done and os.clock() - t0 < CALL_TIMEOUT do task.wait(0.1) end
        if not done then return false, "timeout" end
        return ok, result
    end
    local missionBusy = false
    local MODIFY_GAP = 0.17
    local function LeaveRoom(silent)
        if not ON_LOBBY_PLACE then
            if not silent then SetMissionStatus("Not in the lobby place") end
            return false
        end
        local ok, r = MissionInvoke("S_Missions", "Leave")
        if not silent then
            SetMissionStatus(ok and "Leave sent" or ("Leave failed: " .. tostring(r)))
        end
        return ok
    end
    local function RoomServerDifficulty(room)
        if typeof(room) ~= "Instance" then return nil end
        local okV, value = pcall(function() return room.Value end)
        if okV and type(value) == "string" then return value end
        return nil
    end
    local function RoomMapName(room)
        if typeof(room) ~= "Instance" then return nil end
        local okN, name = pcall(function() return room.Name end)
        if okN and type(name) == "string" then return name end
        return nil
    end
    local function DifficultyKey(label)
        return (label or ""):match("^(%S+)") or "Easy"
    end
    local function NormKey(v)
        if type(v) ~= "string" then return nil end
        local w = v:match("^%s*(%a+)")
        return w and w:lower() or nil
    end
    local function BoostedMap()
        local function fromHolder(holder)
            local okA, attrs = pcall(function() return holder:GetAttributes() end)
            if not okA or type(attrs) ~= "table" then return nil end
            local name, left
            for k, v in pairs(attrs) do
                local lk = tostring(k):lower()
                if lk:find("boost") then
                    if type(v) == "string" and table.find(MISSION_OPTIONS, v) then name = v
                    elseif type(v) == "number" and (lk:find("time") or lk:find("left")) then left = v end
                end
            end
            return name, left
        end
        local name = workspace:GetAttribute("Boosted_Map")
        local left = workspace:GetAttribute("Boosted_Timer")
        if type(name) ~= "string" or not table.find(MISSION_OPTIONS, name) then
            name, left = nil, nil
            for _, holder in ipairs({ workspace, ReplicatedStorage, LocalPlayer }) do
                local n, l = fromHolder(holder)
                if n then name, left = n, l break end
            end
        end
        if not name then return nil end
        if type(left) == "number" and left <= 3 then return nil end
        return name, (type(left) == "number") and left or nil
    end
    local bestGradeCache = nil
    local BEST_CACHE_SECONDS = 600
    -- ⚔️ เช็กเกรดอุปกรณ์ (ดาบ/หอก) จากป้าย "UPGRADES [A- GRADE]" ในหน้า Equipment
    -- กฎ: ความยากที่เลือกได้ต้องมีตัวอักษรเกรด <= เกรดอุปกรณ์ (เช่น Hard = D+ ต้องมีอุปกรณ์เกรด D ขึ้นไป)
    local GRADE_RANK = { E = 1, D = 2, C = 3, B = 4, A = 5, S = 6 }
    local function GradeRankOf(text)
        if type(text) ~= "string" then return nil end
        local letter = text:upper():match("[%[%(]%s*([A-S])[%+%-]?%s*GRADE")
        return letter and GRADE_RANK[letter] or nil
    end
    local function ReadGearRank()
        local ok, text = pcall(function()
            return PlayerGui.Interface.Equipment.Categories.Upgrades.Main.Title.Text
        end)
        if not ok then return nil end
        return GradeRankOf(text), text
    end
    local function DifficultyCandidates()
        local list = {}
        for i = #DIFFICULTY_OPTIONS, 1, -1 do
            list[#list + 1] = DifficultyKey(DIFFICULTY_OPTIONS[i])
        end
        local gearRank = ReadGearRank()
        if gearRank then
            local allowed = {}
            for _, key in ipairs(list) do
                for _, opt in ipairs(DIFFICULTY_OPTIONS) do
                    if DifficultyKey(opt) == key then
                        local need = GradeRankOf(opt)
                        if not need or need <= gearRank then allowed[#allowed + 1] = key end
                    end
                end
            end
            if #allowed == 0 then allowed[1] = list[#list] end -- อย่างน้อยเหลือ Easy
            list = allowed
        end
        if bestGradeCache and os.clock() - bestGradeCache.at < BEST_CACHE_SECONDS then
            local start = table.find(list, bestGradeCache.key)
            if start then
                start = math.max(1, start - 1)
                local trimmed = {}
                for i = start, #list do trimmed[#trimmed + 1] = list[i] end
                return trimmed
            end
        end
        return list
    end
    CreateRoomOnce = function(oneShot)
        if not ON_LOBBY_PLACE then SetMissionStatus("Not in the lobby place") return false end
        if missionBusy then SetMissionStatus("Busy - turn Auto Create off and on again") return false end
        missionBusy = true
        local function Off()
            if oneShot or Cfg.AutoCreateMission then return false end
            SetMissionStatus("Stopped (Auto Create turned off)")
            missionBusy = false
            return true
        end
        local boosted = Cfg.AutoBoostMission and BoostedMap() or nil
        local maps = {}
        if boosted then maps[#maps + 1] = boosted end
        if boosted ~= Cfg.MissionSelect then maps[#maps + 1] = Cfg.MissionSelect end
        local bestMode = Cfg.AutoBestGrade
        local fixedKey = DifficultyKey(Cfg.MissionLevel)
        local mapName, difficulty, room = nil, nil, nil
        local failMsg = nil
        local trace, unverified = {}, false
        local known = {}
        for _, o in ipairs(DIFFICULTY_OPTIONS) do known[NormKey(o)] = true end
        for _, tryMap in ipairs(maps) do
            local keys = bestMode and DifficultyCandidates() or { fixedKey }
            local mapRejected = false
            for _, key in ipairs(keys) do
                SetMissionStatus(("Leaving old room... (%s)"):format(tryMap))
                LeaveRoom(true)
                task.wait(0.6)
                if Off() then return false end
                SetMissionStatus(("Creating %s (%s)%s%s..."):format(
                    tryMap, key, tryMap == boosted and " (boost)" or "", bestMode and " (best grade)" or ""))
                local ok, r = MissionInvoke("S_Missions", "Create", {
                    Difficulty = key,
                    Type = "Missions",
                    Objective = Cfg.MissionObjective,
                    Name = tryMap,
                })
                if not ok then
                    SetMissionStatus("Create failed: " .. tostring(r), true)
                    missionBusy = false
                    return false
                end
                if Off() then return false end
                if r == nil or r == false then
                    failMsg = "Create refused (no room returned)"
                    trace[#trace + 1] = key .. ":refused"
                    if not bestMode then
                        mapRejected = true
                        break
                    end
                    continue
                end
                local gotMap = RoomMapName(r)
                if gotMap and gotMap ~= tryMap then
                    failMsg = tryMap .. " is locked"
                    mapRejected = true
                    break
                end
                local gotKey = RoomServerDifficulty(r)
                local gotNorm, wantNorm = NormKey(gotKey), NormKey(key)
                trace[#trace + 1] = key .. ">" .. tostring(gotKey)
                if gotNorm == nil or not known[gotNorm] or gotNorm == wantNorm then
                    if gotNorm ~= nil and not known[gotNorm] then unverified = true end
                    mapName, difficulty, room = tryMap, key, r
                    break
                end
                if not bestMode then
                    LeaveRoom(true)
                    ResetAutoCreate(nil, true)
                    SetMissionStatus(Cfg.MissionLevel .. " is locked", true)
                    missionBusy = false
                    return false
                end
            end
            if room then break end
            if not mapRejected then failMsg = failMsg or "No playable difficulty found" end
        end
        if not room then
            LeaveRoom(true)
            local detail = (#trace > 0) and (" [" .. table.concat(trace, ", ") .. "]") or ""
            SetMissionStatus((failMsg or "Create refused (no room returned)") .. detail, true)
            missionBusy = false
            return false
        end
        createdRoom = (typeof(room) == "Instance") and room or createdRoom
        if bestMode then bestGradeCache = { key = difficulty, at = os.clock() } end
        local picked = {}
        for _, name in ipairs(MODIFIER_OPTIONS) do
            if table.find(Cfg.MissionModifiers, name) then picked[#picked + 1] = name end
        end
        for i, name in ipairs(picked) do
            SetMissionStatus(("Modifier %d/%d: %s"):format(i, #picked, name))
            local okM, rM = MissionInvoke("S_Missions", "Modify", name)
            if not okM then
                SetMissionStatus("Modify failed (" .. name .. "): " .. tostring(rM), true)
                missionBusy = false
                return false
            end
            task.wait(MODIFY_GAP)
            if Off() then return false end
        end
        SetMissionStatus(("Room created: %s%s / %s%s%s"):format(
            mapName, mapName == boosted and " (boost)" or "", difficulty, bestMode and " (best)" or "",
            unverified and " (unverified)" or ""))
        missionBusy = false
        return true
    end
    local function StartMission()
        if not ON_LOBBY_PLACE then SetMissionStatus("Not in the lobby place") return false end
        if missionBusy then return false end
        missionBusy = true
        SetMissionStatus("Starting mission...")
        local ok, r = MissionInvoke("S_Missions", "Start")
        SetMissionStatus(ok and "Start sent" or ("Start failed: " .. tostring(r)), not ok)
        missionBusy = false
        return ok
    end
    local MissionLeaveRow = AutoMissionForm:Row()
    MissionLeaveRow:Left():TitleStack({ Title = "Leave Room", Subtitle = "Leave the current mission room." })
    local MissionLeaveBtn = MissionLeaveRow:Right():Button({ Label = "Leave", Callback = function() end })
    BindButton(MissionLeaveBtn, function()
        ResetAutoCreate("left the room")
        SH.autoPaused = true
        task.spawn(function()
            local t0 = os.clock()
            while missionBusy and os.clock() - t0 < 10 do task.wait(0.1) end
            if missionBusy then SetMissionStatus("Busy - try again in a moment") return end
            LeaveRoom(false)
        end)
    end)
    task.spawn(function()
        local readyAt = os.clock() + 4
        local fails, nextTry = 0, 0
        while Alive() do
            task.wait(0.5)
            local now = os.clock()
            local bestOnly = (not Cfg.AutoCreateMission) and (Cfg.AutoBestGrade or Cfg.AutoBoostMission)
                and not Cfg.AutoCreateRaid and not Cfg.AutoStartRaid and not (Cfg.AutoCreateWave and SH.PlayOn()) and not (Cfg.AutoStartWave and SH.PlayOn()) and not SH.autoPaused
            if ON_LOBBY_PLACE and (Cfg.AutoCreateMission or bestOnly) and not missionBusy and now >= readyAt and not SH.Coord.Blocker(100) then
                local need = false
                if missionRecreateAt and now >= missionRecreateAt then
                    missionRecreateAt = nil
                    need = true
                elseif now >= nextTry and not HasRoom() then
                    need = true
                end
                if need then
                    if CreateRoomOnce(bestOnly) then
                        fails = 0
                        nextTry = os.clock() + 20
                    elseif Cfg.AutoCreateMission or bestOnly then
                        fails += 1
                        nextTry = os.clock() + 6
                        if fails >= 5 then
                            fails = 0
                            if Cfg.AutoCreateMission then ResetAutoCreate(nil, true) else SH.autoPaused = true end
                            SetMissionStatus("Auto Create stopped (failed 5 times)", true)
                        end
                    end
                end
            end
        end
    end)
    task.spawn(function()
        local lastFire = nil
        while Alive() do
            local hasRoom = HasRoom()
            if not ON_LOBBY_PLACE then
                lastFire = nil
                SetMissionCountdown("Wrong place")
            elseif not Cfg.AutoStartMission then
                lastFire = nil
                SetMissionCountdown("Off")
            elseif not hasRoom then
                lastFire = nil
                SetMissionCountdown("Waiting for room...")
            elseif SH.Coord.Blocker(100) then
                lastFire = nil
                SetMissionCountdown("Waiting: " .. tostring(SH.Coord.last))
            else
                local now = os.clock()
                local delay = ClampDelay(Cfg.MissionJoinDelay)
                if not lastFire then lastFire = now end
                local remaining = lastFire + delay - now
                if remaining <= 0 then
                    SetMissionCountdown("Starting now...")
                    StartMission()
                    lastFire = os.clock()
                else
                    SetMissionCountdown(("Next mission in %ds"):format(math.ceil(remaining)))
                end
            end
            task.wait(0.25)
        end
    end)
    local AdvMissionsSection = MissionsTab:PageSection({
        Title = "🚀 Advance Missions",
        Subtitle = "Auto-pick the best grade or boost mission."
    })
    local AdvMissionsForm = AdvMissionsSection:Form()
    local function OnAdvanceToggle(on)
        if initializing then return end
        SH.autoPaused = false
        bestGradeCache = nil
        if Cfg.AutoCreateMission then
            RequestRecreate()
        elseif on then
            task.spawn(function()
                local t0 = os.clock()
                while missionBusy and os.clock() - t0 < 10 do task.wait(0.1) end
                CreateRoomOnce(true)
            end)
        end
    end
    AddMissionToggle("Auto Select Best Grade", "Creates the highest difficulty you can play.", "AutoBestGrade", AdvMissionsForm, OnAdvanceToggle)
    AddMissionToggle("Auto Select Boost Mission", "Creates the map that has the reward boost now.", "AutoBoostMission", AdvMissionsForm, OnAdvanceToggle)
    local BoostInfoRow = AdvMissionsForm:Row()
    BoostInfoRow:Left():TitleStack({ Title = "Boost Now", Subtitle = "Map with the reward boost right now." })
    local BoostInfoLabel = BoostInfoRow:Right():Label({ Text = "-" })
    local BestInfoRow = AdvMissionsForm:Row()
    BestInfoRow:Left():TitleStack({ Title = "Best Grade Found", Subtitle = "Highest difficulty the last room got." })
    local BestInfoLabel = BestInfoRow:Right():Label({ Text = "-" })
    task.spawn(function()
        local lastB, lastG
        while Alive() do
            local m, left = BoostedMap()
            local b = "No boost"
            if m then
                b = m
                if left then b = ("%s (%d:%02d)"):format(m, math.floor(left / 60), math.floor(left % 60)) end
            end
            local g = bestGradeCache and bestGradeCache.key or "-"
            if b ~= lastB then lastB = b pcall(function() BoostInfoLabel.Text = b end) end
            if g ~= lastG then lastG = g pcall(function() BestInfoLabel.Text = g end) end
            task.wait(1)
        end
    end)
    pcall(function()
        workspace:GetAttributeChangedSignal("Boosted_Map"):Connect(function()
            if not Alive() or initializing or not Cfg.AutoBoostMission then return end
            RequestRecreate()
        end)
    end)
    if not canSave then
        SetMissionStatus("Can't save settings (executor has no file access)", true)
    elseif Cfg.AutoCreateMission or Cfg.AutoStartMission then
        if ON_LOBBY_PLACE then
            SetMissionStatus("Resuming your saved Auto switches...")
        else
            SetMissionStatus("Saved Auto switches will run in the lobby place")
        end
    end
    SH.Guard("block@5425", function()
    local RAIDS = {
        { name = "Attack Titan",   map = "Trost",       diffs = { "Hard", "Severe", "Aberrant" } },
        { name = "Armored Titan",  map = "Shiganshina", diffs = { "Hard", "Severe", "Aberrant" } },
        { name = "Female Titan",   map = "Stohess",     diffs = { "Hard", "Severe", "Aberrant" } },
        { name = "Colossal Titan", map = "Shiganshina", diffs = { "Aberrant" }, minimum = 3 },
    }
    local RAID_NAMES = {}
    for i, r in ipairs(RAIDS) do RAID_NAMES[i] = r.name end
    local RAID_DIFF_LABELS = { "Hard (C- Grade)", "Severe", "Aberrant (A Grade)" }
    local function RaidInfo(name)
        for _, r in ipairs(RAIDS) do if r.name == name then return r end end
        return RAIDS[1]
    end
    local function RaidDifficulty()
        local info = RaidInfo(Cfg.RaidSelect)
        if table.find(info.diffs, Cfg.RaidLevel) then return Cfg.RaidLevel end
        return info.diffs[#info.diffs]
    end
    Cfg.RaidSelect = KeepValid(RAID_NAMES, Cfg.RaidSelect, RAID_NAMES[1])
    Cfg.RaidModifiers = KeepValidList(MODIFIER_OPTIONS, Cfg.RaidModifiers)
    if not table.find({ "Hard", "Severe", "Aberrant" }, Cfg.RaidLevel) then Cfg.RaidLevel = "Hard" end
    local RaidSection = RaidModeTab:PageSection({
        Title = "⚔️ Raid Settings",
        Subtitle = "Raids start at Hard. Colossal Titan is Aberrant only."
    })
    local RaidForm = RaidSection:Form()
    local RaidAutoSection = RaidModeTab:PageSection({
        Title = "🤖 Auto Raid",
        Subtitle = "Create your raid room first, then turn on Auto Start."
    })
    local RaidAutoForm = RaidAutoSection:Form()
    local RaidStatusRow = RaidForm:Row()
    RaidStatusRow:Left():TitleStack({ Title = "Raid Status", Subtitle = "Current step and last result." })
    local RaidStatusLabel = RaidStatusRow:Right():Label({ Text = "Idle" })
    local raidDefaultColor = nil
    pcall(function()
        local o = LabelObject(RaidStatusLabel)
        if o then raidDefaultColor = o.TextColor3 end
    end)
    local function SetRaidStatus(text, isError)
        pcall(function() RaidStatusLabel.Text = tostring(text) end)
        pcall(function()
            local o = LabelObject(RaidStatusLabel)
            if not o then return end
            if isError then o.TextColor3 = STATUS_RED
            elseif raidDefaultColor then o.TextColor3 = raidDefaultColor end
        end)
    end
    local raidRecreateAt = nil
    local function RequestRaidRecreate()
        if Cfg.AutoCreateRaid then raidRecreateAt = os.clock() + 1.5 end
    end
    local function ResetAutoCreateRaid(quiet)
        if not Cfg.AutoCreateRaid then return end
        Cfg.AutoCreateRaid = false
        Save()
        SetMissionToggle("AutoCreateRaid", false)
    end
    local raidDiffNote
    local function AddRaidSelect(title, subtitle, options, getValue, setValue)
        local row = RaidForm:Row()
        row:Left():TitleStack({ Title = title, Subtitle = subtitle })
        local btn = row:Right():PullDownButton({
            Label = getValue(),
            Options = options,
            Value = table.find(options, getValue()) or 1,
            ValueChanged = function(self, index)
                if options[index] then
                    setValue(options[index])
                    self.Label = options[index]
                    Save()
                    RequestRaidRecreate()
                end
            end
        })
        StyleDropdown(btn)
        local function refresh()
            local i = table.find(options, getValue()) or 1
            pcall(function() btn.Value = i btn.Label = options[i] end)
        end
        UiSync.Add(refresh)
        return refresh
    end
    local refreshRaidLevel = function() end
    AddRaidSelect("Select Raid", "Choose the raid boss.", RAID_NAMES,
        function() return Cfg.RaidSelect end,
        function(v) Cfg.RaidSelect = v task.defer(function() refreshRaidLevel() end) end)
    local function RaidLevelLabel()
        for i, k in ipairs({ "Hard", "Severe", "Aberrant" }) do
            if k == RaidDifficulty() then return RAID_DIFF_LABELS[i] end
        end
        return RAID_DIFF_LABELS[1]
    end
    refreshRaidLevel = AddRaidSelect("Select Difficulty", "Colossal Titan always uses Aberrant.", RAID_DIFF_LABELS,
        RaidLevelLabel,
        function(v) Cfg.RaidLevel = v:match("^(%S+)") or "Hard" end)
    do
        local row = RaidForm:Row()
        row:Left():TitleStack({ Title = "Select Modifiers", Subtitle = "Tick the Modifiers to apply after creating." })
        local function apply(value)
            local indexes = type(value) == "table" and value or { value }
            local names = {}
            for _, index in ipairs(SettingsStore.ValidIndexes(indexes, #MODIFIER_OPTIONS)) do
                names[#names + 1] = MODIFIER_OPTIONS[index]
            end
            Cfg.RaidModifiers = names
            Save()
            RequestRaidRecreate()
        end
        local current = {}
        for i, name in ipairs(MODIFIER_OPTIONS) do
            if table.find(Cfg.RaidModifiers, name) then current[#current + 1] = i end
        end
        local ok, btn = pcall(function()
            return row:Right():PopUpButton({
                Options = MODIFIER_OPTIONS,
                Maximum = #MODIFIER_OPTIONS,
                Value = current,
                ValueChanged = function(self, value) apply(value) end
            })
        end)
        if not ok or not btn then
            btn = row:Right():PullDownButton({
                Label = Cfg.RaidModifiers[1] or "None",
                Options = MODIFIER_OPTIONS,
                Value = table.find(MODIFIER_OPTIONS, Cfg.RaidModifiers[1]) or 1,
                ValueChanged = function(self, index)
                    apply(index)
                    self.Label = MODIFIER_OPTIONS[index] or "None"
                end
            })
        end
        StyleDropdown(btn)
        UiSync.Add(function()
            if ok then
                local picked = {}
                for i, name in ipairs(MODIFIER_OPTIONS) do
                    if table.find(Cfg.RaidModifiers, name) then picked[#picked + 1] = i end
                end
                btn.Value = picked
            else
                local i = table.find(MODIFIER_OPTIONS, Cfg.RaidModifiers[1]) or 1
                btn.Value = i
                btn.Label = MODIFIER_OPTIONS[i]
            end
        end)
    end
    local function CreateRaidOnce(oneShot)
        if not ON_LOBBY_PLACE then SetRaidStatus("Not in the lobby place") return false end
        if missionBusy then SetRaidStatus("Busy - try again in a moment") return false end
        missionBusy = true
        local info = RaidInfo(Cfg.RaidSelect)
        local diff = RaidDifficulty()
        SetRaidStatus("Leaving old room...")
        LeaveRoom(true)
        task.wait(0.6)
        if not oneShot and not Cfg.AutoCreateRaid then
            SetRaidStatus("Stopped (Auto Create turned off)")
            missionBusy = false
            return false
        end
        SetRaidStatus(("Creating %s (%s)..."):format(info.name, diff))
        local args = { Difficulty = diff, Type = "Raids", Objective = info.name, Name = info.map }
        if info.minimum then args.Minimum = info.minimum end
        local ok, r = MissionInvoke("S_Missions", "Create", args)
        if not ok then
            SetRaidStatus("Create failed: " .. tostring(r), true)
            missionBusy = false
            return false
        end
        if r == nil or r == false then
            LeaveRoom(true)
            ResetAutoCreateRaid(true)
            SetRaidStatus("Create refused (locked or no room returned)", true)
            missionBusy = false
            return false
        end
        local got = RoomServerDifficulty(r)
        if got ~= nil and got ~= diff then
            LeaveRoom(true)
            ResetAutoCreateRaid(true)
            SetRaidStatus(("%s (%s) is locked"):format(info.name, diff), true)
            missionBusy = false
            return false
        end
        createdRoom = (typeof(r) == "Instance") and r or createdRoom
        local picked = {}
        for _, name in ipairs(MODIFIER_OPTIONS) do
            if table.find(Cfg.RaidModifiers, name) then picked[#picked + 1] = name end
        end
        for i, name in ipairs(picked) do
            SetRaidStatus(("Modifier %d/%d: %s"):format(i, #picked, name))
            local okM, rM = MissionInvoke("S_Missions", "Modify", name)
            if not okM then
                SetRaidStatus("Modify failed (" .. name .. "): " .. tostring(rM), true)
                missionBusy = false
                return false
            end
            task.wait(MODIFY_GAP)
            if not oneShot and not Cfg.AutoCreateRaid then
                SetRaidStatus("Stopped (Auto Create turned off)")
                missionBusy = false
                return false
            end
        end
        SetRaidStatus(("Room created: %s / %s"):format(info.name, diff))
        missionBusy = false
        return true
    end
    local function StartRaid()
        if not ON_LOBBY_PLACE then SetRaidStatus("Not in the lobby place") return false end
        if missionBusy then return false end
        missionBusy = true
        SetRaidStatus("Starting raid...")
        local ok, r = MissionInvoke("S_Missions", "Start")
        local note = ""
        if ok and type(r) == "string" and r ~= "" then note = " (" .. r .. ")" end
        local info = RaidInfo(Cfg.RaidSelect)
        if ok and info.minimum then note = note .. " | needs " .. info.minimum .. "+ players" end
        SetRaidStatus(ok and ("Start sent" .. note) or ("Start failed: " .. tostring(r)), not ok)
        missionBusy = false
        return ok
    end
    AddMissionToggle("Auto Create Raid", "Keeps a raid room ready with these settings. Remembered next time.", "AutoCreateRaid", RaidAutoForm, function(on)
        if on then SetMissionToggle("AutoCreateMission", false) SetMissionToggle("AutoCreateWave", false) end
        if on and not initializing then raidRecreateAt = os.clock() end
    end)
    AddMissionToggle("Auto Start Raid", "Starts the raid in your room. Remembered next time.", "AutoStartRaid", RaidAutoForm, function(on)
        if on then SetMissionToggle("AutoStartMission", false) SetMissionToggle("AutoStartWave", false) end
    end)
    local RaidDelayRow = RaidAutoForm:Row()
    RaidDelayRow:Left():TitleStack({ Title = "Join Delay", Subtitle = "Seconds between starts (" .. MIN_DELAY .. " - " .. MAX_DELAY .. ")." })
    local RaidDelayRight = RaidDelayRow:Right()
    local RaidDelayLabel = RaidDelayRight:Label({ Text = Cfg.RaidJoinDelay .. "s" })
    UiSync.Link(RaidDelayRight:Slider({
        Minimum = MIN_DELAY,
        Maximum = MAX_DELAY,
        Value = Cfg.RaidJoinDelay,
        ValueChanged = function(self, value)
            Cfg.RaidJoinDelay = ClampDelay(value)
            pcall(function() RaidDelayLabel.Text = Cfg.RaidJoinDelay .. "s" end)
            Save()
        end
    }), Cfg, "RaidJoinDelay", function(_, want)
        pcall(function() RaidDelayLabel.Text = want .. "s" end)
    end)
    local RaidCountRow = RaidAutoForm:Row()
    RaidCountRow:Left():TitleStack({ Title = "Next Raid", Subtitle = "Countdown to the next start." })
    local RaidCountLabel = RaidCountRow:Right():Label({ Text = "Off" })
    local lastRaidCount = nil
    local function SetRaidCountdown(text)
        if text == lastRaidCount then return end
        lastRaidCount = text
        pcall(function() RaidCountLabel.Text = text end)
    end
    local RaidLeaveRow = RaidAutoForm:Row()
    RaidLeaveRow:Left():TitleStack({ Title = "Leave Room", Subtitle = "Leave the current raid room." })
    local RaidLeaveBtn = RaidLeaveRow:Right():Button({ Label = "Leave", Callback = function() end })
    BindButton(RaidLeaveBtn, function()
        ResetAutoCreateRaid(true)
        task.spawn(function()
            local t0 = os.clock()
            while missionBusy and os.clock() - t0 < 10 do task.wait(0.1) end
            if missionBusy then SetRaidStatus("Busy - try again in a moment") return end
            local okL = LeaveRoom(true)
            SetRaidStatus(okL and "Leave sent" or "Leave failed", not okL)
        end)
    end)
    task.spawn(function()
        local readyAt = os.clock() + 4
        local fails, nextTry = 0, 0
        while Alive() do
            task.wait(0.5)
            local now = os.clock()
            if ON_LOBBY_PLACE and Cfg.AutoCreateRaid and not missionBusy and now >= readyAt and not SH.Coord.Blocker(100) then
                local need = false
                if raidRecreateAt and now >= raidRecreateAt then
                    raidRecreateAt = nil
                    need = true
                elseif now >= nextTry and not HasRoom() then
                    need = true
                end
                if need then
                    if CreateRaidOnce(false) then
                        fails = 0
                        nextTry = os.clock() + 20
                    elseif Cfg.AutoCreateRaid then
                        fails += 1
                        nextTry = os.clock() + 8
                        if fails >= 3 then
                            fails = 0
                            ResetAutoCreateRaid(true)
                            SetRaidStatus("Auto Create stopped (failed 3 times)", true)
                        end
                    end
                end
            end
        end
    end)
    task.spawn(function()
        local lastFire = nil
        while Alive() do
            local hasRoom = HasRoom()
            if not ON_LOBBY_PLACE then
                lastFire = nil
                SetRaidCountdown("Wrong place")
            elseif not Cfg.AutoStartRaid then
                lastFire = nil
                SetRaidCountdown("Off")
            elseif not hasRoom then
                lastFire = nil
                SetRaidCountdown("Waiting for room...")
            elseif SH.Coord.Blocker(100) then
                lastFire = nil
                SetRaidCountdown("Waiting: " .. tostring(SH.Coord.last))
            else
                local now = os.clock()
                local delay = ClampDelay(Cfg.RaidJoinDelay)
                if not lastFire then lastFire = now end
                local remaining = lastFire + delay - now
                if remaining <= 0 then
                    SetRaidCountdown("Starting now...")
                    StartRaid()
                    lastFire = os.clock()
                else
                    SetRaidCountdown(("Next raid in %ds"):format(math.ceil(remaining)))
                end
            end
            task.wait(0.25)
        end
    end)
    SH.Guard("block@5754", function()
        local ExtraForm = RaidModeTab:PageSection({
            Title = "🎁 Raid Extras",
            Subtitle = "Skip cutscenes and open the reward chest by pressing the real buttons."
        }):Form()
        AddMissionToggle("Auto Skip Cutscene", "Presses SKIP [E] on cutscenes once your character has loaded.", "AutoSkipCutscene", ExtraForm)
        do
            local row = ExtraForm:Row()
            row:Left():TitleStack({ Title = "Skip Cutscene Status", Subtitle = "What Auto Skip Cutscene is doing." })
            local label = row:Right():Label({ Text = "Off" })
            local last = nil
            function Farm.SetSkipStatus(text)
                text = tostring(text)
                if text == last then return end
                last = text
                pcall(function() label.Text = text end)
            end
        end
        AddMissionToggle("Auto Open Chest (Free)", "Presses OPEN on the Free chest when the chest screen shows.", "AutoOpenChestFree", ExtraForm)
        AddMissionToggle("Auto Open Chest (Premium)", "Presses OPEN on the Premium chest. Only turn on if you want to open it.", "AutoOpenChestPremium", ExtraForm)
        AddMissionToggle("Auto Finish Chest", "Presses FINISH after the chests you selected are opened.", "AutoFinishChest", ExtraForm)
        local chestLabel
        do
            local row = ExtraForm:Row()
            row:Left():TitleStack({ Title = "Chest Status", Subtitle = "What Auto Open Chest sees right now." })
            chestLabel = row:Right():Label({ Text = "Off" })
        end
        local lastChestText = nil
        local function SetChest(text)
            text = tostring(text)
            if text == lastChestText then return end
            lastChestText = text
            pcall(function() chestLabel.Text = text end)
        end
        local function PathOf(obj)
            local names, cur = {}, obj
            while cur and cur ~= PlayerGui and cur ~= game do
                table.insert(names, 1, cur.Name)
                cur = cur.Parent
            end
            return table.concat(names, ".")
        end
        local function ChestButtons()
            local found = {}
            for _, d in ipairs(PlayerGui:GetDescendants()) do
                if IsTextObj(d) and IsShown(d) and (function()
                    local t = TextOf(d)
                    return t == "OPEN" or t:match("^OPEN%s*%(%d+%)$") ~= nil
                end)() then
                    local btn = d
                    while btn and btn ~= PlayerGui and not btn:IsA("GuiButton") do btn = btn.Parent end
                    if btn and btn ~= PlayerGui then
                        local path = PathOf(btn):lower()
                        local kind = "Unknown"
                        if path:find("premium") then kind = "Premium" elseif path:find("free") then kind = "Free" end
                        local n = TextOf(d):match("%((%d+)%)")
                        found[#found + 1] = { btn = btn, kind = kind, path = PathOf(btn), empty = (n ~= nil and tonumber(n) == 0) }
                    end
                end
            end
            return found
        end
        local FinishButton
        if SH.DEV then
            local copyRow = ExtraForm:Row()
            copyRow:Left():TitleStack({ Title = "Copy Chest Debug", Subtitle = "Copies the OPEN buttons it can see (send this if a chest is not opened)." })
            local copyBtn = copyRow:Right():Button({ Label = "Copy", Callback = function() end })
            BindButton(copyBtn, function()
                local lines = {}
                for _, b in ipairs(ChestButtons()) do lines[#lines + 1] = b.kind .. " | " .. b.path end
                local fb = FinishButton and FinishButton()
                lines[#lines + 1] = fb and ("FINISH | " .. PathOf(fb)) or "FINISH | not visible"
                local text = table.concat(lines, "\n")
                pcall(function() setclipboard(text) end)
                SetChest(#lines > 0 and ("Copied " .. #lines .. " button(s)") or "No visible OPEN button")
            end)
        end
        FinishButton = function()
            for _, d in ipairs(PlayerGui:GetDescendants()) do
                if IsTextObj(d) and IsShown(d) and TextOf(d):match("^FINISH") then
                    local btn = d
                    while btn and btn ~= PlayerGui and not btn:IsA("GuiButton") do btn = btn.Parent end
                    if btn and btn ~= PlayerGui then return btn end
                end
            end
            return nil
        end
        task.spawn(function()
            local opened, lastPress = 0, {}
            local screenSince, lastAction = nil, 0
            local GAP = 5
            local FINISH_WAIT = 4
            while Alive() do
                task.wait(0.7)
                local wantFree, wantPremium, wantFinish = Cfg.AutoOpenChestFree, Cfg.AutoOpenChestPremium, Cfg.AutoFinishChest
                if not (wantFree or wantPremium) then
                    SetChest("Off")
                else
                    local all = ChestButtons()
                    local list, emptyCount = {}, 0
                    for _, b in ipairs(all) do
                        if b.empty then emptyCount += 1 else list[#list + 1] = b end
                    end
                    local pressable = false
                    for _, b in ipairs(list) do
                        if (b.kind == "Free" and wantFree) or (b.kind == "Premium" and wantPremium)
                            or (b.kind == "Unknown" and wantFree and wantPremium) then
                            pressable = true
                        end
                    end
                    if pressable then
                        for _, b in ipairs(list) do
                            local okKind = (b.kind == "Free" and wantFree) or (b.kind == "Premium" and wantPremium)
                                or (b.kind == "Unknown" and wantFree and wantPremium)
                            if okKind and os.clock() - (lastPress[b.kind] or 0) >= GAP then
                                lastPress[b.kind] = os.clock()
                                lastAction = os.clock()
                                SetChest("Opening " .. b.kind .. " chest...")
                                pcall(ActivateButton, b.btn)
                                opened += 1
                                break
                            end
                        end
                    else
                        local fin = FinishButton()
                        if fin and not screenSince then screenSince = os.clock() end
                        if not fin then
                            screenSince = nil
                            if #list == 0 and emptyCount > 0 then
                                SetChest("No keys left - nothing to open")
                            elseif #list == 0 then
                                SetChest(opened > 0 and ("Waiting for chest (opened " .. opened .. ")") or "Waiting for chest")
                            else
                                local unknown = false
                                for _, b in ipairs(list) do if b.kind == "Unknown" then unknown = true end end
                                SetChest(unknown and "OPEN found but can't tell Free / Premium (use Copy)" or "OPEN found (not selected)")
                            end
                        elseif not wantFinish then
                            SetChest(emptyCount > 0 and "No keys left - Auto Finish is off" or ("Chests done (opened %d) - Auto Finish is off"):format(opened))
                        elseif os.clock() - math.max(lastAction, screenSince or os.clock()) >= FINISH_WAIT then
                            SetChest("Finishing...")
                            lastAction = os.clock()
                            pcall(ActivateButton, fin)
                            task.wait(0.5)
                            if fin.Parent and IsShown(fin) then
                                pcall(function()
                                    local pos, size = fin.AbsolutePosition, fin.AbsoluteSize
                                    local inset = GuiService:GetGuiInset()
                                    local cx, cy = pos.X + size.X / 2, pos.Y + size.Y / 2 + inset.Y
                                    VirtualInputManager:SendMouseMoveEvent(cx, cy, game)
                                    VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, true, game, 1)
                                    task.wait(0.05)
                                    VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, false, game, 1)
                                end)
                            end
                        else
                            SetChest("Chests opened - finishing soon...")
                        end
                    end
                end
            end
        end)
    end)
    SH.Guard("block@5917", function()
        local SPAWN_WAIT = 2
        local GAP = 1.5
        local function SetSkip(text)
            if Farm.SetSkipStatus then Farm.SetSkipStatus(text) end
        end
        local function FindSkip()
            local seenText = false
            for _, d in ipairs(PlayerGui:GetDescendants()) do
                if IsTextObj(d) and IsShown(d) then
                    local t = TextOf(d):upper()
                    if t:match("^SKIP") and #t <= 14 then
                        seenText = true
                        local btn = d
                        while btn and btn ~= PlayerGui and not btn:IsA("GuiButton") do btn = btn.Parent end
                        if btn and btn ~= PlayerGui then return btn, true end
                    end
                end
            end
            return nil, seenText
        end
        local function PressE()
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            end)
        end
        task.spawn(function()
            local skipped, lastPress = 0, 0
            local lastChar, spawnedAt = nil, 0
            while Alive() do
                task.wait(0.4)
                if not Cfg.AutoSkipCutscene then
                    SetSkip("Off")
                    lastChar = nil
                elseif IN_MENU then
                    SetSkip("Not in a match")
                else
                    local char = LocalPlayer.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if not (hum and root and hum.Health > 0) then
                        lastChar = nil
                        SetSkip("Waiting for character")
                    else
                        if char ~= lastChar then lastChar, spawnedAt = char, os.clock() end
                        if os.clock() - spawnedAt < SPAWN_WAIT then
                            SetSkip("Character loading...")
                        else
                            local btn, seenText = FindSkip()
                            if (btn or seenText) and os.clock() - lastPress >= GAP then
                                lastPress = os.clock()
                                SetSkip("Skipping...")
                                if btn then pcall(ActivateButton, btn) end
                                local again = FindSkip()
                                if (not btn) or again then PressE() end
                                skipped += 1
                                SetSkip(("Skipped (%d)"):format(skipped))
                            elseif not (btn or seenText) then
                                SetSkip(skipped > 0 and ("Waiting for cutscene (skipped %d)"):format(skipped) or "Waiting for cutscene")
                            end
                        end
                    end
                end
            end
        end)
    end)
    SH.Guard("block@5985", function()
        local SHOOT_ARGS = { BarrelWood = 40, Base = 0 }
        local IMPACT_BURST = 30
        local Form = RaidModeTab:PageSection({
            Title = "🏰 Colossal Titan",
            Subtitle = "Shoots the wall cannon at the Colossal Titan's nape."
        }):Form()
        AddMissionToggle("Auto Cannon (Colossal Titan)", "Phase 1: mounts the wall cannon and shoots the Colossal Titan until the cutscene (Stall Bertholdt complete). Phase 2: the cannon stops so you can kill the Colossal.", "AutoCannon", Form, function() end)
        AddMissionToggle("Auto Defend (only Eren Thunder Spears)", "Phase 1: while the cannon shoots, Auto Farm also kills the titans that get close to Eren. Needs Auto Farm on.", "AutoDefendEren", Form, function() end)
        do
            local range = FARM_RANGES.DefendErenRadius
            local function titleFor(v) return "Defend Radius ( " .. v .. " )" end
            local row = Form:Row()
            local stack = row:Left():TitleStack({ Title = titleFor(Cfg.DefendErenRadius), Subtitle = "Titans closer than this to Eren (studs) are killed first." })
            UiSync.Link(row:Right():Slider({
                Minimum = range[1],
                Maximum = range[2],
                Value = Cfg.DefendErenRadius,
                ValueChanged = function(self, value)
                    local v = math.clamp(math.floor(value + 0.5), range[1], range[2])
                    Cfg.DefendErenRadius = v
                    pcall(function() stack.Title = titleFor(v) end)
                    Save()
                end
            }), Cfg, "DefendErenRadius", function(_, want)
                pcall(function() stack.Title = titleFor(want) end)
            end)
        end
        local defendLabel
        do
            local row = Form:Row()
            row:Left():TitleStack({ Title = "Auto Defend Status", Subtitle = "What Auto Defend is doing." })
            defendLabel = row:Right():Label({ Text = "Off" })
        end
        local lastDefendText = nil
        local function SetDefendStatus(text)
            text = tostring(text)
            if text == lastDefendText then return end
            lastDefendText = text
            pcall(function() defendLabel.Text = text end)
        end
        local statusLabel
        do
            local row = Form:Row()
            row:Left():TitleStack({ Title = "Cannon Status", Subtitle = "What Auto Cannon is doing." })
            statusLabel = row:Right():Label({ Text = "Off" })
        end
        local lastText = nil
        local function SetStatus(text)
            text = tostring(text)
            if text == lastText then return end
            lastText = text
            pcall(function() statusLabel.Text = text end)
        end
        local shots, impacts, events = 0, 0, 0
        local lastState, lastShoot = "-", "-"
        local function CannonModel()
            local climb = workspace:FindFirstChild("Climbable")
            for _, d in ipairs(climb and climb:GetDescendants() or {}) do
                if d.Name == "Cannons" and not d:IsA("BasePart") then
                    local m = d:FindFirstChildWhichIsA("Model")
                    if m then return m end
                end
            end
            return nil
        end
        local function ColossalAlive()
            local titans = workspace:FindFirstChild("Titans")
            local ct = titans and titans:FindFirstChild("Colossal_Titan")
            local hum = ct and ct:FindFirstChildOfClass("Humanoid")
            return (ct and hum and hum.Health > 0) and ct or nil
        end
        local function NapePos()
            local ct = ColossalAlive()
            if not ct then return nil end
            local hb = ct:FindFirstChild("Hitboxes")
            local hit = hb and hb:FindFirstChild("Hit")
            local nape = hit and hit:FindFirstChild("Nape")
            if nape and nape:IsA("BasePart") then return nape.Position end
            local fake = ct:FindFirstChild("Fake")
            local head = fake and fake:FindFirstChild("Head")
            return head and head:IsA("BasePart") and head.Position or nil
        end
        local function StallObjective()
            local o = ReplicatedStorage:FindFirstChild("Objectives")
            if not o then return nil end
            local names = { "Stall_Colossal_Titan", "Stall_Colossal", "Stall_Bertholdt", "Stall_Bertholdt_Titan" }
            for _, name in ipairs(names) do
                local obj = o:FindFirstChild(name)
                if obj then return obj end
            end
            return nil
        end
        local function StallProgress()
            local so = StallObjective()
            if not so then return nil, nil end
            return tonumber(so.Value) or 0, tonumber(so:GetAttribute("Requirement")) or 1
        end
        local function StallDone()
            local v, req = StallProgress()
            return v ~= nil and v >= req
        end
        local phase2Latched, sawStallObjective = false, false
        local function Phase2()
            if not ColossalAlive() then
                phase2Latched, sawStallObjective = false, false
                return false
            end
            if phase2Latched then return true end
            local objective = StallObjective()
            if objective then
                sawStallObjective = true
            elseif sawStallObjective then
                phase2Latched = true
            end
            if StallDone() then
                phase2Latched = true
            end
            return phase2Latched
        end
        local function Phase1()
            return Cfg.AutoCannon and Farm.CanUseHere() and ColossalAlive() ~= nil and not Phase2()
        end
        Farm.CannonFarmSmall = false
        Farm.ColossalPhase2 = Phase2
        Farm.ColossalPhase1 = Phase1
        local function PostRemote()
            local ok, r = pcall(function() return ReplicatedStorage.Assets.Remotes.POST end)
            return ok and r or nil
        end
        task.spawn(function()
            local calmSince = nil
            while Alive() do
                task.wait(0.25)
                local defend = false
                if not Cfg.AutoDefendEren then
                    SetDefendStatus("Off")
                    calmSince = nil
                elseif not (Cfg.AutoFarm or Cfg.AutoFarmThunder) then
                    SetDefendStatus("Turn on Auto Farm")
                    calmSince = nil
                elseif not (Cfg.AutoCannon and Phase1()) then
                    SetDefendStatus("Waiting for phase 1")
                    calmSince = nil
                else
                    local threats, eren = Farm.ErenThreats()
                    if not eren then
                        SetDefendStatus("Eren not found")
                    elseif threats > 0 then
                        defend = true
                        calmSince = nil
                        SetDefendStatus(("Defending Eren | %d titan(s) near"):format(threats))
                    else
                        calmSince = calmSince or os.clock()
                        if Farm.DefendErenActive and os.clock() - calmSince < 1.5 then defend = true end
                        SetDefendStatus("Eren is safe")
                    end
                end
                Farm.DefendErenActive = defend
                if defend then
                    Farm.PauseUntil = 0
                    Farm.MovePauseUntil = 0
                elseif Cfg.AutoCannon and Phase1() then
                    Farm.PauseUntil = os.clock() + 1.2
                    Farm.MovePauseUntil = os.clock() + 1.2
                elseif Farm.PauseUntil and Farm.PauseUntil > 0 then
                    Farm.PauseUntil = 0
                    Farm.MovePauseUntil = 0
                end
            end
        end)
        task.spawn(function()
            local conn, mounted = nil, nil
            local function Disconnect()
                if conn then pcall(function() conn:Disconnect() end) conn = nil end
            end
            while Alive() do
                task.wait(0.2)
                local ct = ColossalAlive()
                local want = Cfg.AutoCannon and Farm.CanUseHere() and ct ~= nil and not Phase2() and not Farm.DefendErenActive
                if not want then
                    if mounted or conn then
                        Disconnect()
                        local c = mounted
                        mounted = nil
                        if c then pcall(MissionInvoke, "Cannon", "State", c, false, nil) end
                    end
                    if not Cfg.AutoCannon then
                        SetStatus("Off")
                    elseif ct and Farm.DefendErenActive then
                        SetStatus("Cannon paused: defending Eren")
                    elseif ct and Phase2() then
                        SetStatus("Phase 2: cannon stopped - kill the Colossal")
                    else
                        SetStatus("Waiting for Colossal Titan")
                    end
                else
                    local cannon = CannonModel()
                    local post = PostRemote()
                    if not cannon then
                        SetStatus("No cannon found")
                    elseif not post then
                        SetStatus("POST remote not found")
                    else
                        if not conn then
                            conn = post.OnClientEvent:Connect(function(a1, a2, cannonObj)
                                if a1 ~= "Skills" or a2 ~= "Impact" then return end
                                if not Cfg.AutoCannon then return end
                                events += 1
                                local ref = cannonObj or workspace:FindFirstChild("Cannon")
                                if not ref then return end
                                for _ = 1, IMPACT_BURST do
                                    local pos = NapePos()
                                    if pos then
                                        pcall(function() post:FireServer("S_Skills", "Impact", ref, pos) end)
                                        impacts += 1
                                    end
                                end
                            end)
                        end
                        local okS, resS = MissionInvoke("Cannon", "State", cannon, true, nil)
                        lastState = ("ok=%s res=%s"):format(tostring(okS), type(resS) == "table" and "table" or tostring(resS))
                        mounted = cannon
                        task.wait(0.3)
                        for _ = 1, 3 do
                            local ok, res = MissionInvoke("Cannon", "Shoot", SHOOT_ARGS)
                            lastShoot = ("ok=%s res=%s"):format(tostring(ok), tostring(res))
                            if ok then shots += 1 break end
                            task.wait(0.1)
                        end
                        local v, req = StallProgress()
                        SetStatus(("Phase 1: shooting Colossal | stall %s/%s | shots %d | hits %d"):format(tostring(v), tostring(req), shots, events))
                        task.wait(1.8)
                    end
                end
            end
            Disconnect()
        end)
    end)
    end)
    SH.Guard("boss-check-ui", function()
        local Section = RaidModeTab:PageSection({
            Title = "🛰️ Boss Check",
            Subtitle = "Waits until the raid boss is fully spawned before Auto Farm starts, so you don't farm while the boss is still loading or frozen."
        })
        local Form = Section:Form()
        local Row = Form:Row()
        Row:Left():TitleStack({ Title = "Wait For Boss", Subtitle = "Auto Farm / Clear Wave pause while the boss is missing, still loading (no body/nape, anchored) or just spawned." })
        UiSync.Link(Row:Right():Toggle({
            Value = Cfg.WaitForBoss,
            ValueChanged = function(self, value)
                Cfg.WaitForBoss = value and true or false
                Save()
            end
        }), Cfg, "WaitForBoss")
        local range = FARM_RANGES.BossSettle
        local SRow = Form:Row()
        local SStack = SRow:Left():TitleStack({ Title = "Boss Settle Time ( " .. Cfg.BossSettle .. "s )", Subtitle = "How long the boss must stay fully loaded before farming starts. Also how long to wait for a boss to appear after you spawn." })
        UiSync.Link(SRow:Right():Slider({
            Minimum = range[1], Maximum = range[2], Value = Cfg.BossSettle,
            ValueChanged = function(self, value)
                local v = math.clamp(math.floor(value + 0.5), range[1], range[2])
                Cfg.BossSettle = v
                pcall(function() SStack.Title = "Boss Settle Time ( " .. v .. "s )" end)
                Save()
            end
        }), Cfg, "BossSettle", function(_, want)
            pcall(function() SStack.Title = "Boss Settle Time ( " .. want .. "s )" end)
        end)
        local StatusRow = Form:Row()
        StatusRow:Left():TitleStack({ Title = "Boss Status", Subtitle = "Spawned / loading / ready." })
        local StatusLabel = StatusRow:Right():Label({ Text = "Off" })
        task.spawn(function()
            local last = nil
            while Alive() do
                task.wait(0.5)
                local text = "Off"
                if Cfg.WaitForBoss then
                    pcall(Farm.BossBlock) -- อัปเดตสถานะแม้ Auto Farm ปิดอยู่
                    text = Farm.BossStatus or "Off"
                end
                if text ~= last then
                    last = text
                    pcall(function() StatusLabel.Text = tostring(text) end)
                end
            end
        end)
        local DumpRow = Form:Row()
        DumpRow:Left():TitleStack({ Title = "Boss Info", Subtitle = "Prints the boss state to the Console (F9). Use it while the boss looks stuck and send it to me." })
        DumpRow:Right():Button({ Label = "Print", Callback = function() pcall(Farm.BossDump) end })
    end)
    SH.Guard("auto-play", function()
        -- ▶️ Auto Play: สวิตช์เดียวเปิด/ปิดชุดฟังก์ชันหลักของโหมด Wave (วางไว้บนสุดของแท็บ)
        local PLAY_SET = {
            { key = "AutoCreateWave", name = "Create Wave" },
            { key = "AutoStartWave", name = "Start Waves" },
            { key = "AutoReady", name = "Ready" },
            { key = "AutoVoteSkip", name = "Vote Skip" },
            { key = "AutoClearWave", name = "Clear Wave" },
            { key = "AutoLootCrate", name = "Loot Crate" },
            { key = "AutoRefillWave", name = "Refill" },
        }
        local Section = WaveModeTab:PageSection({
            Title = "▶️ Auto Play",
            Subtitle = "Master switch. Wave features (Create, Start, Ready, Vote Skip, Clear Wave, Loot, Refill, Shop) only run while this is ON."
        })
        local Form = Section:Form()
        local Row = Form:Row()
        Row:Left():TitleStack({
            Title = "Auto Play",
            Subtitle = "Must be ON for Auto Create/Start Wave, Ready, Vote Skip, Clear Wave, Loot Crate, Refill and Shop to work. Turning it off pauses them all (your toggles stay as set)."
        })
        UiSync.Link(Row:Right():Toggle({
            Value = Cfg.AutoPlay,
            ValueChanged = function(self, value)
                Cfg.AutoPlay = value and true or false
                if Cfg.AutoPlay then
                    local anyOn = false
                    for _, item in ipairs(PLAY_SET) do if Cfg[item.key] then anyOn = true break end end
                    if not anyOn then for _, item in ipairs(PLAY_SET) do Cfg[item.key] = true end end
                end
                Save()
                UiSync.Refresh() -- ให้สวิตช์ของแต่ละตัวขยับตาม
                if Cfg.AutoClearWave then Farm.Fire("OnAutoClearWave", Cfg.AutoPlay) end -- เปิด Play = ปิด Auto Farm กันชนกัน
            end
        }), Cfg, "AutoPlay")
        local StatusRow = Form:Row()
        StatusRow:Left():TitleStack({ Title = "Auto Play Status", Subtitle = "Which parts are running." })
        local StatusLabel = StatusRow:Right():Label({ Text = "Off" })
        task.spawn(function()
            local last = nil
            while Alive() do
                task.wait(0.5)
                local on, off = 0, {}
                for _, item in ipairs(PLAY_SET) do
                    if Cfg[item.key] then on += 1 else off[#off + 1] = item.name end
                end
                local text
                if on == 0 then text = "Off"
                elseif #off == 0 then text = "All on (" .. on .. "/" .. #PLAY_SET .. ")"
                else text = on .. "/" .. #PLAY_SET .. " on (off: " .. table.concat(off, ", ") .. ")" end
                if text ~= last then
                    last = text
                    pcall(function() StatusLabel.Text = text end)
                end
            end
        end)
    end)
    SH.Guard("block@6225", function()
        local WAVE_MAPS = { "Trost" }
        local WAVE_DIFFS = { "Easy (E- Grade)" }
        Cfg.WaveSelect = KeepValid(WAVE_MAPS, Cfg.WaveSelect, WAVE_MAPS[1])
        Cfg.WaveLevel = KeepValid(WAVE_DIFFS, Cfg.WaveLevel, WAVE_DIFFS[1])
        local WaveSection = WaveModeTab:PageSection({
            Title = "🌊 Wave Settings",
            Subtitle = "Pick the map and difficulty, then turn on Auto Create Wave."
        })
        local WaveForm = WaveSection:Form()
        local WaveAutoSection = WaveModeTab:PageSection({
            Title = "🤖 Auto Wave",
            Subtitle = "Create your wave room first, then turn on Auto Start."
        })
        local WaveAutoForm = WaveAutoSection:Form()
        local WaveStatusRow = WaveForm:Row()
        WaveStatusRow:Left():TitleStack({ Title = "Wave Status", Subtitle = "Current step and last result." })
        local WaveStatusLabel = WaveStatusRow:Right():Label({ Text = "Idle" })
        local waveDefaultColor = nil
        pcall(function()
            local o = LabelObject(WaveStatusLabel)
            if o then waveDefaultColor = o.TextColor3 end
        end)
        local function SetWaveStatus(text, isError)
            pcall(function() WaveStatusLabel.Text = tostring(text) end)
            pcall(function()
                local o = LabelObject(WaveStatusLabel)
                if not o then return end
                if isError then o.TextColor3 = STATUS_RED
                elseif waveDefaultColor then o.TextColor3 = waveDefaultColor end
            end)
        end
        local waveRecreateAt = nil
        local function RequestWaveRecreate()
            if Cfg.AutoCreateWave then waveRecreateAt = os.clock() + 1.5 end
        end
        local function ResetAutoCreateWave()
            if not Cfg.AutoCreateWave then return end
            Cfg.AutoCreateWave = false
            Save()
            SetMissionToggle("AutoCreateWave", false)
        end
        local function AddWaveSelect(title, subtitle, options, key)
            local row = WaveForm:Row()
            row:Left():TitleStack({ Title = title, Subtitle = subtitle })
            local btn = row:Right():PullDownButton({
                Label = Cfg[key],
                Options = options,
                Value = table.find(options, Cfg[key]) or 1,
                ValueChanged = function(self, index)
                    if options[index] then
                        Cfg[key] = options[index]
                        self.Label = options[index]
                        Save()
                        RequestWaveRecreate()
                    end
                end
            })
            StyleDropdown(btn)
            UiSync.Add(function()
                local i = table.find(options, Cfg[key]) or 1
                pcall(function() btn.Value = i btn.Label = options[i] end)
            end)
        end
        AddWaveSelect("Select Map", "Choose the wave map.", WAVE_MAPS, "WaveSelect")
        AddWaveSelect("Select Difficulty", "Waves only has Easy for now.", WAVE_DIFFS, "WaveLevel")
        local function CreateWaveRoom(oneShot)
            if not ON_LOBBY_PLACE then SetWaveStatus("Not in the lobby place") return false end
            if missionBusy then SetWaveStatus("Busy - try again in a moment") return false end
            if oneShot and (Cfg.AutoCreateMission or Cfg.AutoCreateRaid) then
                SetWaveStatus("Turn off Auto Create Mission / Raid first", true)
                return false
            end
            missionBusy = true
            local map = Cfg.WaveSelect
            local diff = DifficultyKey(Cfg.WaveLevel)
            SetWaveStatus("Leaving old room...")
            LeaveRoom(true)
            task.wait(0.6)
            if not oneShot and not Cfg.AutoCreateWave then
                SetWaveStatus("Stopped (Auto Create turned off)")
                missionBusy = false
                return false
            end
            SetWaveStatus(("Creating Waves (%s / %s)..."):format(map, diff))
            local ok, r = MissionInvoke("S_Missions", "Create", { Difficulty = diff, Type = "Waves", Objective = "Waves", Name = map })
            if not ok then
                SetWaveStatus("Create failed: " .. tostring(r), true)
                missionBusy = false
                return false
            end
            if r == nil or r == false then
                LeaveRoom(true)
                ResetAutoCreateWave()
                SetWaveStatus("Create refused (locked or no room returned)", true)
                missionBusy = false
                return false
            end
            local got = RoomServerDifficulty(r)
            if got ~= nil and got ~= diff then
                LeaveRoom(true)
                ResetAutoCreateWave()
                SetWaveStatus(("Waves (%s) is locked"):format(diff), true)
                missionBusy = false
                return false
            end
            createdRoom = (typeof(r) == "Instance") and r or createdRoom
            SetWaveStatus(("Room created: Waves / %s / %s"):format(map, diff))
            missionBusy = false
            return true
        end
        local function StartWave()
            if not ON_LOBBY_PLACE then SetWaveStatus("Not in the lobby place") return false end
            if missionBusy then return false end
            missionBusy = true
            SetWaveStatus("Starting wave...")
            local ok, r = MissionInvoke("S_Missions", "Start")
            local note = ""
            if ok and type(r) == "string" and r ~= "" then note = " (" .. r .. ")" end
            SetWaveStatus(ok and ("Start sent" .. note) or ("Start failed: " .. tostring(r)), not ok)
            missionBusy = false
            return ok
        end
        AddMissionToggle("Auto Create Wave", "Keeps a wave room ready with these settings. Remembered next time.", "AutoCreateWave", WaveAutoForm, function(on)
            if on then SetMissionToggle("AutoCreateMission", false) SetMissionToggle("AutoCreateRaid", false) end
            if on and not initializing then waveRecreateAt = os.clock() end
        end)
        AddMissionToggle("Auto Start Waves", "Starts the wave in your room. Remembered next time.", "AutoStartWave", WaveAutoForm, function(on)
            if on then SetMissionToggle("AutoStartMission", false) SetMissionToggle("AutoStartRaid", false) end
        end)
        local WaveDelayRow = WaveAutoForm:Row()
        WaveDelayRow:Left():TitleStack({ Title = "Join Delay", Subtitle = "Seconds between starts (" .. MIN_DELAY .. " - " .. MAX_DELAY .. ")." })
        local WaveDelayRight = WaveDelayRow:Right()
        local WaveDelayLabel = WaveDelayRight:Label({ Text = Cfg.WaveJoinDelay .. "s" })
        UiSync.Link(WaveDelayRight:Slider({
            Minimum = MIN_DELAY,
            Maximum = MAX_DELAY,
            Value = Cfg.WaveJoinDelay,
            ValueChanged = function(self, value)
                Cfg.WaveJoinDelay = ClampDelay(value)
                pcall(function() WaveDelayLabel.Text = Cfg.WaveJoinDelay .. "s" end)
                Save()
            end
        }), Cfg, "WaveJoinDelay", function(_, want)
            pcall(function() WaveDelayLabel.Text = want .. "s" end)
        end)
        local WaveCountRow = WaveAutoForm:Row()
        WaveCountRow:Left():TitleStack({ Title = "Next Wave", Subtitle = "Countdown to the next start." })
        local WaveCountLabel = WaveCountRow:Right():Label({ Text = "Off" })
        local lastWaveCount = nil
        local function SetWaveCountdown(text)
            if text == lastWaveCount then return end
            lastWaveCount = text
            pcall(function() WaveCountLabel.Text = text end)
        end
        local WaveLeaveRow = WaveAutoForm:Row()
        WaveLeaveRow:Left():TitleStack({ Title = "Leave Room", Subtitle = "Leave the current wave room." })
        local WaveLeaveBtn = WaveLeaveRow:Right():Button({ Label = "Leave", Callback = function() end })
        BindButton(WaveLeaveBtn, function()
            ResetAutoCreateWave()
            task.spawn(function()
                local t0 = os.clock()
                while missionBusy and os.clock() - t0 < 10 do task.wait(0.1) end
                if missionBusy then SetWaveStatus("Busy - try again in a moment") return end
                local okL = LeaveRoom(true)
                SetWaveStatus(okL and "Leave sent" or "Leave failed", not okL)
            end)
        end)
        task.spawn(function()
            local readyAt = os.clock() + 4
            local fails, nextTry = 0, 0
            while Alive() do
                task.wait(0.5)
                local now = os.clock()
                if ON_LOBBY_PLACE and Cfg.AutoCreateWave and SH.PlayOn() and not missionBusy and now >= readyAt and not SH.Coord.Blocker(100) then
                    local need = false
                    if waveRecreateAt and now >= waveRecreateAt then
                        waveRecreateAt = nil
                        need = true
                    elseif now >= nextTry and not HasRoom() then
                        need = true
                    end
                    if need then
                        if CreateWaveRoom(false) then
                            fails = 0
                            nextTry = os.clock() + 20
                        elseif Cfg.AutoCreateWave then
                            fails += 1
                            nextTry = os.clock() + 8
                            if fails >= 3 then
                                fails = 0
                                ResetAutoCreateWave()
                                SetWaveStatus("Auto Create stopped (failed 3 times)", true)
                            end
                        end
                    end
                end
            end
        end)
        task.spawn(function()
            local lastFire = nil
            while Alive() do
                local hasRoom = HasRoom()
                if not ON_LOBBY_PLACE then
                    lastFire = nil
                    SetWaveCountdown("Wrong place")
                elseif not (Cfg.AutoStartWave and SH.PlayOn()) then
                    lastFire = nil
                    SetWaveCountdown("Off")
                elseif not hasRoom then
                    lastFire = nil
                    SetWaveCountdown("Waiting for room...")
                elseif SH.Coord.Blocker(100) then
                    lastFire = nil
                    SetWaveCountdown("Waiting: " .. tostring(SH.Coord.last))
                else
                    local now = os.clock()
                    local delay = ClampDelay(Cfg.WaveJoinDelay)
                    if not lastFire then lastFire = now end
                    local remaining = lastFire + delay - now
                    if remaining <= 0 then
                        SetWaveCountdown("Starting now...")
                        StartWave()
                        lastFire = os.clock()
                    else
                        SetWaveCountdown(("Next wave in %ds"):format(math.ceil(remaining)))
                    end
                end
                task.wait(0.25)
            end
        end)
    end)
    SH.Guard("block@6573", function()
        local RefillSection = WaveModeTab:PageSection({
            Title = "⛽ Auto Refill [ Wave ]",
            Subtitle = "Flies to the refill tank and presses R for you (mobile friendly)."
        })
        local RefillForm = RefillSection:Form()
        local ToggleRow = RefillForm:Row()
        ToggleRow:Left():TitleStack({ Title = "Auto Refill [ Wave ]", Subtitle = "When your blades / Thunder Spears run out, goes to the nearest tank, refills, then flies back." })
        UiSync.Link(ToggleRow:Right():Toggle({
            Value = Cfg.AutoRefillWave,
            ValueChanged = function(self, value)
                Cfg.AutoRefillWave = value and true or false
                Save()
            end
        }), Cfg, "AutoRefillWave")
        local StatusRow = RefillForm:Row()
        StatusRow:Left():TitleStack({ Title = "Refill Status", Subtitle = "Current action..." })
        local RefillStatusLabel = StatusRow:Right():Label({ Text = "Off" })
        task.spawn(function()
            local last = nil
            while Alive() do
                task.wait(0.5)
                local text = Farm.WaveRefillStatus and Farm.WaveRefillStatus() or "Off"
                if text ~= last then
                    last = text
                    pcall(function() RefillStatusLabel.Text = tostring(text) end)
                end
            end
        end)
    end)
    SH.Guard("block@6603", function()
        local ReadySection = WaveModeTab:PageSection({
            Title = "✅ Auto Ready",
            Subtitle = "Presses Ready for you when the vote to start appears."
        })
        local ReadyForm = ReadySection:Form()
        local ReadyRow = ReadyForm:Row()
        ReadyRow:Left():TitleStack({ Title = "Auto Ready", Subtitle = "Automatically presses Ready when the vote to start appears." })
        UiSync.Link(ReadyRow:Right():Toggle({
            Value = Cfg.AutoReady,
            ValueChanged = function(self, value)
                Cfg.AutoReady = value and true or false
                Save()
            end
        }), Cfg, "AutoReady")
        local SkipRow = ReadyForm:Row()
        SkipRow:Left():TitleStack({ Title = "Auto Vote Skip", Subtitle = "Automatically presses Ready on the vote to skip the wait between waves." })
        UiSync.Link(SkipRow:Right():Toggle({
            Value = Cfg.AutoVoteSkip,
            ValueChanged = function(self, value)
                Cfg.AutoVoteSkip = value and true or false
                Save()
            end
        }), Cfg, "AutoVoteSkip")
    end)
    SH.Guard("block@6628", function()
        local LeaveSection = WaveModeTab:PageSection({
            Title = "🚪 Leave At Wave",
            Subtitle = "Leave the match once enough waves are cleared."
        })
        local LeaveForm = LeaveSection:Form()
        local LeaveRow = LeaveForm:Row()
        LeaveRow:Left():TitleStack({ Title = "Leave At Wave", Subtitle = "Leave to the lobby when Waves Cleared reaches the number below." })
        UiSync.Link(LeaveRow:Right():Toggle({
            Value = Cfg.AutoLeaveAtWave,
            ValueChanged = function(self, value)
                Cfg.AutoLeaveAtWave = value and true or false
                Save()
            end
        }), Cfg, "AutoLeaveAtWave")
        local range = FARM_RANGES.LeaveAtWave
        local function titleFor(v) return "Leave After Waves Cleared ( " .. v .. " )" end
        local SliderRow = LeaveForm:Row()
        local stack = SliderRow:Left():TitleStack({ Title = titleFor(Cfg.LeaveAtWave), Subtitle = "Counts the Waves Cleared shown in the objectives." })
        UiSync.Link(SliderRow:Right():Slider({
            Minimum = range[1],
            Maximum = range[2],
            Value = Cfg.LeaveAtWave,
            ValueChanged = function(self, value)
                local v = math.clamp(math.floor(value + 0.5), range[1], range[2])
                Cfg.LeaveAtWave = v
                pcall(function() stack.Title = titleFor(v) end)
                Save()
            end
        }), Cfg, "LeaveAtWave", function(_, want)
            pcall(function() stack.Title = titleFor(want) end)
        end)
    end)
    SH.Guard("block@6454", function()
        local DROP_POS = Vector3.new(-745.373169, 6.16312218, 174.26799)
        local LOOT_HEIGHT = 150
        local MAX_CRATE_DIST = 5000
        local MAX_CRATE_UP = 600
        local MAX_CRATE_DOWN = 400
        local CRATE_COOLDOWN = 3
        local LootSection = WaveModeTab:PageSection({
            Title = "📦 Auto Loot Crate",
            Subtitle = "Auto loot your own crate (Crate_<your name>) with NoClip."
        })
        local LootForm = LootSection:Form()
        local ToggleRow = LootForm:Row()
        ToggleRow:Left():TitleStack({ Title = "Auto Loot Crate", Subtitle = "Automatically enables NoClip while looting." })
        UiSync.Link(ToggleRow:Right():Toggle({
            Value = Cfg.AutoLootCrate,
            ValueChanged = function(self, value)
                Cfg.AutoLootCrate = value and true or false
                Save()
            end
        }), Cfg, "AutoLootCrate")
        local StatusRow = LootForm:Row()
        StatusRow:Left():TitleStack({ Title = "Loot Status", Subtitle = "Current action..." })
        local LootStatusLabel = StatusRow:Right():Label({ Text = "Off" })
        local function SetLootStatus(text)
            pcall(function() LootStatusLabel.Text = tostring(text) end)
        end
        local function MyRoot()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then return root end
            return nil
        end
        local function FlyTo(targetPos, maxTime)
            local r0 = MyRoot()
            if r0 then
                local need = (targetPos - r0.Position).Magnitude / (Cfg.FlySpeed or 600) + 1
                if need > maxTime then maxTime = need end
                pcall(function() LocalPlayer:RequestStreamAroundAsync(targetPos, 0.5) end)
            end
            local elapsed = 0
            while elapsed < maxTime and Alive() do
                local dt = task.wait()
                elapsed = elapsed + dt
                local root = MyRoot()
                if not root then return end
                local diff = targetPos - root.Position
                local dist = diff.Magnitude
                if dist < 2 then break end
                local step = math.min((Cfg.FlySpeed or 600) * dt, dist)
                root.CFrame = CFrame.new(root.Position + diff.Unit * step)
                pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
            end
        end
        local function HeightOf(pos) return pos + Vector3.new(0, LOOT_HEIGHT, 0) end
        local function SetFarmFlag(key, value)
            Cfg[key] = value
            local ctl = Farm.Toggles and Farm.Toggles[key]
            if ctl then pcall(function() ctl.Value = value end) end
        end
        local function NearestCrate(root)
            local waves = workspace:FindFirstChild("Waves")
            local folder = waves and waves:FindFirstChild("Crates")
            if not folder then return nil end
            local best, bestDist = nil, MAX_CRATE_DIST
            -- เก็บเฉพาะกล่องของตัวเอง: ชื่อ Crate_<ชื่อผู้เล่น> (กันไปเก็บกล่องของเพื่อนในห้อง)
            local mine1 = ("crate_" .. LocalPlayer.Name):lower()
            local mine2 = ("crate_" .. LocalPlayer.DisplayName):lower()
            for _, crate in ipairs(folder:GetChildren()) do
              local cname = crate.Name:lower()
              if cname == mine1 or cname == mine2 then
                local hitbox = crate:FindFirstChild("Hitbox")
                if not hitbox and crate:IsA("BasePart") then hitbox = crate end
                if hitbox and hitbox:IsA("BasePart") then
                    local hp = hitbox.Position
                    local finite = hp.X == hp.X and hp.Y == hp.Y and hp.Z == hp.Z and math.abs(hp.Y) < 1e5
                    local dy = hp.Y - root.Position.Y
                    if finite and dy <= MAX_CRATE_UP and dy >= -MAX_CRATE_DOWN then
                        local d = (hp - root.Position).Magnitude
                        if d < bestDist then best, bestDist = hitbox, d end
                    end
                end
              end
            end
            return best
        end
        local function LootCycle(crate)
            local wasFarm, wasThunder, wasNoClip = Cfg.AutoFarm, Cfg.AutoFarmThunder, Cfg.NoClip
            SetFarmFlag("AutoFarm", false)
            SetFarmFlag("AutoFarmThunder", false)
            SetFarmFlag("NoClip", true)
            pcall(function()
                SetLootStatus("Looting crate (NoClip ON)...")
                local root = MyRoot()
                if not root then return end
                FlyTo(HeightOf(root.Position), 0.5)
                FlyTo(HeightOf(crate.Position), 1.5)
                FlyTo(crate.Position + Vector3.new(0, 3, 0), 0.5)
                task.wait(0.3)
                SetLootStatus("Returning to drop position...")
                root = MyRoot()
                if not root then return end
                FlyTo(HeightOf(root.Position), 0.5)
                FlyTo(HeightOf(DROP_POS), 1.5)
                FlyTo(DROP_POS, 0.5)
                task.wait(0.5)
            end)
            SetFarmFlag("NoClip", wasNoClip)
            if wasFarm then SetFarmFlag("AutoFarm", true) end
            if wasThunder then SetFarmFlag("AutoFarmThunder", true) end
            SetLootStatus((wasFarm or wasThunder) and "Returned. Resuming Auto Farm." or "Returned.")
        end
        task.spawn(function()
            local crateCooldown = 0
            local lootTries = setmetatable({}, { __mode = "k" })
            while Alive() do
                task.wait(0.5)
                if not (Cfg.AutoLootCrate and SH.PlayOn()) or not Farm.CanUseHere() then
                    Farm.CratePending = false
                    SetLootStatus("Off")
                else
                    local root = MyRoot()
                    local anyCrate = root and NearestCrate(root) or nil
                    if anyCrate and (lootTries[anyCrate] or 0) >= 3 then
                        if lootTries[anyCrate] == 3 then
                            lootTries[anyCrate] = 4
                            print("[SmoothHub][Loot] crate still there after 3 tries -> skipping it so Auto Farm keeps killing titans")
                        end
                        anyCrate = nil
                    end
                    Farm.CratePending = anyCrate ~= nil -- NPC ทุกตัวต้องหลีกทางให้การเก็บกล่อง
                    local crate = (anyCrate and os.clock() > crateCooldown) and anyCrate or nil
                    if crate and Farm.NpcBusy then
                        SetLootStatus("Crate ready. Waiting for the NPC visit to finish...")
                    elseif crate then
                        print(string.format("[SmoothHub][Loot] crate %s | dist=%.0f dy=%.0f", crate:GetFullName(), (crate.Position - root.Position).Magnitude, crate.Position.Y - root.Position.Y))
                        Farm.LootBusy = true
                        pcall(LootCycle, crate)
                        Farm.LootBusy = false
                        local tries = (lootTries[crate] or 0) + 1
                        lootTries[crate] = tries
                        crateCooldown = os.clock() + CRATE_COOLDOWN + (tries - 1) * 5 -- ถ้ากล่องยังอยู่ ให้เวลาฟาร์มไททันก่อนค่อยลองใหม่
                    elseif root then
                        SetLootStatus((Cfg.AutoFarm or Cfg.AutoFarmThunder) and "No crate. Attacking titan..." or "No crate. Waiting...")
                    end
                end
            end
        end)
    end)
    SH.Guard("auto-clear-wave-ui", function()
        local Section = WaveModeTab:PageSection({
            Title = "⚔️ Auto Clear Wave",
            Subtitle = "Stand still and kill titans in range - no flying to them. Turns Auto Farm [ Blades ] and [ TS ] off while it is on."
        })
        local Form = Section:Form()
        local Row = Form:Row()
        Row:Left():TitleStack({ Title = "Auto Clear Wave", Subtitle = "Same blade attacks as Auto Farm [ Blades ], but you stay where you are." })
        Farm.Toggles = Farm.Toggles or {}
        Farm.Toggles.AutoClearWave = UiSync.Link(Row:Right():Toggle({
            Value = Cfg.AutoClearWave,
            ValueChanged = function(self, value)
                Cfg.AutoClearWave = value and true or false
                Save()
                Farm.Fire("OnAutoClearWave", Cfg.AutoClearWave)
            end
        }), Cfg, "AutoClearWave")
        do
            local key = "ClearWaveRange"
            local range = FARM_RANGES[key]
            local function titleFor(v) return "Attack Range ( " .. v .. " studs )" end
            local row = Form:Row()
            local stack = row:Left():TitleStack({ Title = titleFor(Cfg[key]), Subtitle = "Only titans whose nape is within this distance of you are hit. Raise it if titans are not dying." })
            UiSync.Link(row:Right():Slider({
                Minimum = range[1], Maximum = range[2], Value = Cfg[key],
                ValueChanged = function(self, value)
                    local v = math.clamp(math.floor(value / 10 + 0.5) * 10, range[1], range[2])
                    Cfg[key] = v
                    pcall(function() stack.Title = titleFor(v) end)
                    Save()
                end
            }), Cfg, key, function(_, want)
                pcall(function() stack.Title = titleFor(want) end)
            end)
        end
        local StatusRow = Form:Row()
        StatusRow:Left():TitleStack({ Title = "Clear Status", Subtitle = "Current action..." })
        local StatusLabel = StatusRow:Right():Label({ Text = "Off" })
        task.spawn(function()
            local last = nil
            while Alive() do
                task.wait(0.5)
                local text = Farm.ClearWaveStatus or "Off"
                if text ~= last then
                    last = text
                    pcall(function() StatusLabel.Text = tostring(text) end)
                end
            end
        end)
        -- ถ้าเซฟไว้ว่าเปิดอยู่ ให้ปิด Auto Farm [ Blades ] / [ TS ] ที่ค้างอยู่ด้วย (กันชนกันตั้งแต่เริ่ม)
        if Cfg.AutoClearWave then Farm.Fire("OnAutoClearWave", true) end
    end)
    SH.Guard("wave-director", function()
        -- ============================================================
        --  🧭 Wave Routine (ตัวจัดคิวกลาง) — NPC ทุกตัวต้องต่อคิวผ่านตรงนี้
        --  ลำดับ: เก็บกล่อง/ฆ่าไททัน (หลัก) > Heal > Upgrade Character > Upgrade Blades > Shop > Blessings
        --  (รักษาก่อน, อัปเกรดก่อน, ของที่ไม่จำเป็นอย่างสุ่ม Blessing ใช้เงินที่เหลือทีหลัง)
        --  + เช็คทอง: ไม่บินไปหา NPC ถ้าทองน้อยกว่าที่ตั้งไว้ หรือทองยังไม่เพิ่มจากครั้งที่แล้วที่ซื้อไม่ได้
        -- ============================================================
        local PRIORITY = { Heal = 1, Character = 2, Blades = 3, Shop = 4, Blessing = 5 }
        local LABEL = { Heal = "Heal", Character = "Upgrade Character", Blades = "Upgrade Blades", Shop = "Shop", Blessing = "Blessings" }
        local queue, seq, nextFree = {}, 0, 0
        local failGold = {}
        local lastVisit = {}
        local REVISIT_GAP = { Blessing = 20 }
        local REVISIT_DEFAULT = 30 -- กันวิ่งไปหา NPC ตัวเดิมถี่ๆ ไม่ว่าจะนับเวฟพลาดหรือไม่
        function Farm.RevisitBlock(name)
            local lv = lastVisit[name]
            local gap = REVISIT_GAP[name] or REVISIT_DEFAULT
            if lv and os.clock() - lv < gap then
                return ("Cooling down (%ds)"):format(math.ceil(gap - (os.clock() - lv)))
            end
            return nil
        end
        Farm.NpcCurrent = nil

        local function ParseAmount(text)
            local num, suf = tostring(text):gsub(",", ""):match("^([%d%.]+)%s*([kKmMbB]?)$")
            local v = num and tonumber(num)
            if not v then return nil end
            suf = suf:lower()
            if suf == "k" then v = v * 1e3 elseif suf == "m" then v = v * 1e6 elseif suf == "b" then v = v * 1e9 end
            return v
        end
        -- ในแมพ Wave ไม่มี Topbar (ยืนยันจากไฟล์ดั้ม) ทองอยู่ที่ HUD.Main.Top.2.Gold.Title แทน
        local GOLD_PATHS = {
            "Interface.HUD.Main.Top.2.Gold.Title",
            "Interface.Topbar.Main.Currencies.Gold.Amount",
        }
        function Farm.ReadGold()
            for _, path in ipairs(GOLD_PATHS) do
                local ok, t = pcall(ReadGui, path)
                if ok and t then
                    local v = ParseAmount(t)
                    if v then return v end
                end
            end
            return nil
        end
        -- คืนข้อความเหตุผลถ้ายังไม่ควรไปหา NPC (nil = ไปได้)
        function Farm.GoldBlock(name)
            local cool = Farm.RevisitBlock(name)
            if cool then return cool end
            local gold = Farm.ReadGold()
            if gold == nil then return nil end -- อ่านทองไม่ได้ = ไม่ขวาง (ให้แต่ละตัวเช็คเองในหน้าต่าง)
            local f = failGold[name]
            if f and gold > f then failGold[name] = nil f = nil end
            if (Cfg.WaveMinGold or 0) > 0 and gold < Cfg.WaveMinGold then
                return ("Waiting for gold (%d / %d)"):format(gold, Cfg.WaveMinGold)
            end
            if f then return ("Not enough gold last time, waiting for more (have %d)"):format(gold) end
            return nil
        end
        function Farm.GoldFail(name)
            failGold[name] = Farm.ReadGold()
        end

        function Farm.NpcAcquire(name)
            seq += 1
            local ticket = { name = name, prio = PRIORITY[name] or 9, seq = seq }
            queue[#queue + 1] = ticket
            -- รอ 1.2 วิ ให้ฟีเจอร์อื่นที่ถึงรอบพร้อมกันเข้ามาต่อคิวก่อน แล้วค่อยเรียงตามลำดับความสำคัญ
            task.wait(1.2)
            local function myTurn()
                if Farm.NpcBusy or Farm.Refilling or Farm.LootBusy or Farm.CratePending or os.clock() < nextFree then return false end
                for _, t in ipairs(queue) do
                    if t ~= ticket and (t.prio < ticket.prio or (t.prio == ticket.prio and t.seq < ticket.seq)) then return false end
                end
                return true
            end
            while Alive() and not myTurn() do task.wait(0.25) end
            for i, t in ipairs(queue) do
                if t == ticket then table.remove(queue, i) break end
            end
            Farm.NpcBusy = true
            Farm.NpcCurrent = name
            return true
        end
        function Farm.NpcRelease()
            if Farm.NpcCurrent then lastVisit[Farm.NpcCurrent] = os.clock() end
            Farm.NpcBusy = false
            Farm.NpcCurrent = nil
            nextFree = os.clock() + 0.5 -- เว้นช่วงสั้นๆ ให้ตัวละครบินกลับที่เดิมก่อนคิวถัดไป
        end

        local Section = WaveModeTab:PageSection({
            Title = "🧭 Wave Routine",
            Subtitle = "Crate looting and killing titans come first. Heal, upgrades, shop and blessings take turns in between and check your gold."
        })
        local Form = Section:Form()
        local StatusRow = Form:Row()
        StatusRow:Left():TitleStack({ Title = "Routine Status", Subtitle = "Order: Heal > Upgrade Character > Upgrade Blades > Shop > Blessings." })
        local StatusLabel = StatusRow:Right():Label({ Text = "Idle" })
        local FarmRow = Form:Row()
        FarmRow:Left():TitleStack({ Title = "Farm Status", Subtitle = "What Auto Farm is doing right now, and why it is paused." })
        local FarmLabel = FarmRow:Right():Label({ Text = "?" })
        local GoldRow = Form:Row()
        GoldRow:Left():TitleStack({ Title = "Your Gold", Subtitle = "Read from the HUD." })
        local GoldLabel = GoldRow:Right():Label({ Text = "?" })
        do
            local key = "WaveMinGold"
            local range = FARM_RANGES[key]
            local step = 100
            local function titleFor(v) return "Min Gold To Visit NPC ( " .. (v == 0 and "off" or v) .. " )" end
            local row = Form:Row()
            local stack = row:Left():TitleStack({ Title = titleFor(Cfg[key]), Subtitle = "Don't fly to Youmii / Cole / Lulu / Orange / Roll unless you have at least this much gold (0 = off)." })
            UiSync.Link(row:Right():Slider({
                Minimum = range[1], Maximum = range[2], Value = Cfg[key],
                ValueChanged = function(self, value)
                    local v = math.clamp(math.floor(value / step + 0.5) * step, range[1], range[2])
                    Cfg[key] = v
                    pcall(function() stack.Title = titleFor(v) end)
                    Save()
                end
            }), Cfg, key, function(_, want)
                pcall(function() stack.Title = titleFor(want) end)
            end)
        end
        task.spawn(function()
            local lastS, lastG, lastF = nil, nil, nil
            while Alive() do
                task.wait(0.5)
                local ftext
                do
                    local B = Farm.Blades
                    if not (Cfg.AutoFarm or Cfg.AutoFarmThunder) then
                        ftext = (Farm.NpcBusy or Farm.LootBusy) and "Paused for a short trip" or "Auto Farm is OFF"
                    elseif Farm.LootBusy then ftext = "Paused: looting crate"
                    elseif Farm.NpcBusy then ftext = "Paused: NPC visit (" .. tostring(Farm.NpcCurrent) .. ")"
                    elseif Farm.Refilling then ftext = "Paused: refilling"
                    elseif Farm.FailSafeActive then ftext = "Paused: fail safe"
                    else ftext = tostring(B and B.Status or "?") end
                    local tf = workspace:FindFirstChild("Titans")
                    ftext = ftext .. " | titans: " .. (tf and #tf:GetChildren() or "no folder")
                end
                if ftext ~= lastF then lastF = ftext pcall(function() FarmLabel.Text = ftext end) end
                local text
                if Farm.LootBusy then
                    text = "Looting crate (top priority)"
                elseif Farm.NpcCurrent then
                    text = "Running: " .. (LABEL[Farm.NpcCurrent] or Farm.NpcCurrent)
                elseif Farm.Refilling then
                    text = "Refilling"
                elseif #queue > 0 then
                    local names = {}
                    local sorted = {}
                    for _, t in ipairs(queue) do sorted[#sorted + 1] = t end
                    table.sort(sorted, function(a, b) if a.prio ~= b.prio then return a.prio < b.prio end return a.seq < b.seq end)
                    for _, t in ipairs(sorted) do names[#names + 1] = LABEL[t.name] or t.name end
                    text = "Queue: " .. table.concat(names, " > ")
                else
                    text = "Idle"
                end
                local gold = Farm.ReadGold()
                local gtext = gold and tostring(math.floor(gold)):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "") or "?"
                if text ~= lastS then lastS = text pcall(function() StatusLabel.Text = text end) end
                if gtext ~= lastG then lastG = gtext pcall(function() GoldLabel.Text = gtext end) end
            end
        end)
    end)
    SH.Guard("auto-shop-orange", function()
        -- ============================================================
        --  🛒 Auto Shop [ Orange ]  (Wave Mode) — ใช้ระบบ "คลิก UI" ล้วน
        --  บินไปหา NPC Orange -> กด E -> กดปุ่ม [E] Market -> คลิกการ์ดสินค้าในร้านเอง
        -- ============================================================
        local ShopSection = WaveModeTab:PageSection({
            Title = "🛒 Auto Shop [ Orange ]",
            Subtitle = "Goes to Orange, opens the Market and clicks the cards for you (once every wave)."
        })
        local ShopForm = ShopSection:Form()
        local function AddShopToggle(title, subtitle, key)
            local row = ShopForm:Row()
            row:Left():TitleStack({ Title = title, Subtitle = subtitle })
            UiSync.Link(row:Right():Toggle({
                Value = Cfg[key],
                ValueChanged = function(self, value)
                    Cfg[key] = value and true or false
                    Save()
                end
            }), Cfg, key)
        end
        AddShopToggle("Auto Shop [ Orange ]", "Shops automatically at the start of every new wave (the market refreshes each wave).", "AutoShop")
        -- [NEW] ดรอปดาวเลือกได้หลายอัน: ค่าจริงยังเก็บเป็น boolean ใน Cfg (เซฟเก่า/ตรรกะซื้อเดิมใช้ต่อได้)
        local function AddShopMulti(title, subtitle, options, keys)
            local row = ShopForm:Row()
            row:Left():TitleStack({ Title = title, Subtitle = subtitle })
            local function selectedIndexes()
                local picked = {}
                for i, key in ipairs(keys) do
                    if Cfg[key] then picked[#picked + 1] = i end
                end
                return picked
            end
            local function apply(value)
                local indexes = type(value) == "table" and value or { value }
                local on = {}
                for _, index in ipairs(SettingsStore.ValidIndexes(indexes, #options)) do on[index] = true end
                for i, key in ipairs(keys) do Cfg[key] = on[i] == true end
                Save()
            end
            local ok, btn = pcall(function()
                return row:Right():PopUpButton({
                    Options = options,
                    Maximum = #options, -- ต้องกำหนดเกิน 1 ถึงจะติ๊กได้หลายอัน
                    Value = selectedIndexes(),
                    ValueChanged = function(self, value) apply(value) end
                })
            end)
            if not ok or not btn then
                -- ไลบรารีไม่รองรับติ๊กหลายอัน: ถอยไปเลือกทีละอัน
                local first = selectedIndexes()[1]
                btn = row:Right():PullDownButton({
                    Label = first and options[first] or "None",
                    Options = options,
                    Value = first or 1,
                    ValueChanged = function(self, index)
                        apply(index)
                        self.Label = options[index] or "None"
                    end
                })
            end
            StyleDropdown(btn)
            UiSync.Add(function()
                if ok then
                    pcall(function() btn.Value = selectedIndexes() end)
                else
                    local first = selectedIndexes()[1] or 1
                    pcall(function() btn.Value = first btn.Label = options[first] end)
                end
            end)
        end
        local STAR_OPTIONS = { "1 Star", "2 Stars", "3 Stars", "4 Stars", "5 Stars" }
        local function StarKeys(prefix)
            local keys = {}
            for i = 1, 5 do keys[i] = prefix .. i end
            return keys
        end
        AddShopMulti("Buy Categories", "Pick what to buy: Perks (tab 1), Artifacts (tab 2), Memories (tab 3), Crates.",
            { "Perks", "Artifacts", "Memories", "Crates" },
            { "ShopPerk", "ShopArtifact", "ShopMemory", "ShopCrates" })
        AddShopMulti("Perk Stars", "Which star levels to buy for Perks (Common = 1 star, Rare = 3 stars ...).",
            STAR_OPTIONS, StarKeys("ShopPerkStar"))
        AddShopMulti("Artifact Stars", "Which star levels to buy for Artifacts (Goggles, Journal, Glasses, Ring, Key ...).",
            STAR_OPTIONS, StarKeys("ShopArtifactStar"))
        AddShopMulti("Memory Stars", "Which star levels to buy for Memories (Swiftshot, Riposte, Guardian ...).",
            STAR_OPTIONS, StarKeys("ShopMemoryStar"))

        local PRIORITY_OPTIONS = { "Highest star first", "Cheapest first", "Most expensive first" }
        if not table.find(PRIORITY_OPTIONS, Cfg.ShopPriority) then Cfg.ShopPriority = PRIORITY_OPTIONS[1] end
        local PrioRow = ShopForm:Row()
        PrioRow:Left():TitleStack({ Title = "Buy Order", Subtitle = "Used when you cannot afford everything." })
        local PrioBtn = PrioRow:Right():PullDownButton({
            Label = Cfg.ShopPriority,
            Options = PRIORITY_OPTIONS,
            Value = table.find(PRIORITY_OPTIONS, Cfg.ShopPriority) or 1,
            ValueChanged = function(self, index)
                if PRIORITY_OPTIONS[index] then
                    Cfg.ShopPriority = PRIORITY_OPTIONS[index]
                    self.Label = PRIORITY_OPTIONS[index]
                    Save()
                end
            end
        })
        StyleDropdown(PrioBtn)
        UiSync.Add(function()
            local i = table.find(PRIORITY_OPTIONS, Cfg.ShopPriority) or 1
            pcall(function() PrioBtn.Value = i PrioBtn.Label = PRIORITY_OPTIONS[i] end)
        end)

        local function AddShopSlider(title, subtitle, key, step)
            local range = FARM_RANGES[key]
            local function titleFor(v) return title .. " ( " .. (v == 0 and "off" or v) .. " )" end
            local row = ShopForm:Row()
            local stack = row:Left():TitleStack({ Title = titleFor(Cfg[key]), Subtitle = subtitle })
            UiSync.Link(row:Right():Slider({
                Minimum = range[1], Maximum = range[2], Value = Cfg[key],
                ValueChanged = function(self, value)
                    local v = math.clamp(math.floor(value / step + 0.5) * step, range[1], range[2])
                    Cfg[key] = v
                    pcall(function() stack.Title = titleFor(v) end)
                    Save()
                end
            }), Cfg, key, function(_, want)
                pcall(function() stack.Title = titleFor(want) end)
            end)
        end
        AddShopSlider("Max Price", "Skip cards that cost more than this (0 = no limit).", "ShopMaxPrice", 50)
        AddShopSlider("Keep Coins", "Always leave at least this many coins unspent.", "ShopReserve", 50)

        local StatusRow = ShopForm:Row()
        StatusRow:Left():TitleStack({ Title = "Shop Status", Subtitle = "Current action..." })
        local ShopStatusLabel = StatusRow:Right():Label({ Text = "Off" })
        local lastStatus = nil
        local function SetStatus(text)
            if text == lastStatus then return end
            lastStatus = text
            pcall(function() ShopStatusLabel.Text = tostring(text) end)
        end

        -- ---------- helpers: อ่าน / คลิก UI ----------
        local function Clean(o)
            local t = tostring(o.Text or ""):gsub("<[^>]->", "")
            return (t:gsub("^%s+", ""):gsub("%s+$", ""))
        end
        local function Shown(obj)
            local cur = obj
            while cur and cur ~= PlayerGui do
                if cur:IsA("GuiObject") and not cur.Visible then return false end
                if cur:IsA("ScreenGui") and not cur.Enabled then return false end
                cur = cur.Parent
            end
            return obj:IsA("GuiObject") and obj.AbsoluteSize.X > 0 and obj.AbsoluteSize.Y > 0
        end
        local function IsText(d) return d:IsA("TextLabel") or d:IsA("TextButton") end
        local function CenterOf(o) return o.AbsolutePosition + o.AbsoluteSize / 2 end

        local function ClickObj(obj, attempt)
            attempt = attempt or 1
            local isBtn = obj:IsA("GuiButton")
            local method = (attempt - 1) % 3 + 1
            if method == 1 and (not isBtn or type(firesignal) ~= "function") then method = 2 end
            if method == 1 then
                pcall(firesignal, obj.Activated)
                pcall(firesignal, obj.MouseButton1Click)
            elseif method == 2 then
                local gui = obj:FindFirstAncestorOfClass("ScreenGui")
                local inset = (gui and gui.IgnoreGuiInset) and Vector2.zero or GuiService:GetGuiInset()
                local pos = CenterOf(obj) + inset
                pcall(function()
                    VirtualInputManager:SendMouseMoveEvent(pos.X, pos.Y, game)
                    task.wait(0.05)
                    VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
                    task.wait(0.06)
                    VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
                end)
            else
                if isBtn then
                    pcall(function() GuiService.SelectedObject = obj end)
                    task.wait(0.1)
                    pcall(function()
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                        task.wait(0.05)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                    end)
                    task.wait(0.1)
                    pcall(function() GuiService.SelectedObject = nil end)
                end
            end
        end
        local function ButtonFor(label)
            if label:IsA("GuiButton") then return label end
            local cur = label.Parent
            for _ = 1, 4 do
                if not cur or cur == PlayerGui then break end
                if cur:IsA("GuiButton") then return cur end
                cur = cur.Parent
            end
            return label
        end
        local function FindText(pred)
            for _, d in ipairs(PlayerGui:GetDescendants()) do
                if IsText(d) and Shown(d) and pred(Clean(d):lower()) then return d end
            end
            return nil
        end

        -- ---------- หา NPC / ร้าน ----------
        local function OrangeNpc()
            local w = workspace:FindFirstChild("Waves")
            local n = w and w:FindFirstChild("NPCs")
            return n and n:FindFirstChild("Orange")
        end
        local function NpcPos(npc)
            local ok, p = pcall(function()
                if npc:IsA("Model") then return npc:GetPivot().Position end
                if npc:IsA("BasePart") then return npc.Position end
                local part = npc:FindFirstChildWhichIsA("BasePart", true)
                return part and part.Position
            end)
            return ok and p or nil
        end
        local function MyRoot()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then return root end
            return nil
        end
        local function MoveTo(cf)
            local root = MyRoot()
            if not root then return end
            pcall(function() LocalPlayer:RequestStreamAroundAsync(cf.Position, 0.5) end)
            local dist = (root.Position - cf.Position).Magnitude
            local t = math.clamp(dist / 900, 0.15, 6)
            local ok, tw = pcall(function()
                return game:GetService("TweenService"):Create(root, TweenInfo.new(t, Enum.EasingStyle.Linear), { CFrame = cf })
            end)
            if not ok or not tw then pcall(function() root.CFrame = cf end) return end
            local vel = game:GetService("RunService").Heartbeat:Connect(function()
                pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
            end)
            tw:Play()
            local t0 = os.clock()
            while os.clock() - t0 < t + 0.3 and tw.PlaybackState == Enum.PlaybackState.Playing and Alive() do task.wait() end
            pcall(function() tw:Cancel() end)
            vel:Disconnect()
            pcall(function() root.CFrame = cf end)
        end
        local function TapKey(key, hold)
            pcall(function() VirtualInputManager:SendKeyEvent(true, key, false, game) end)
            task.wait(hold or 0.15)
            pcall(function() VirtualInputManager:SendKeyEvent(false, key, false, game) end)
        end

        local TITLES = { PERKS = 1, ARTIFACTS = 2, MEMORIES = 3, SHIFTING = 4, PERK = 1, ARTIFACT = 2, MEMORY = 3 }
        local function MarketLabel()
            return FindText(function(t) return t:match("^market changes every wave") ~= nil end)
        end
        local function ShopScope()
            local lbl = MarketLabel()
            return lbl and (lbl:FindFirstAncestorOfClass("ScreenGui") or PlayerGui) or nil, lbl
        end
        local function CurrentTitle(scope)
            for _, d in ipairs(scope:GetDescendants()) do
                if d:IsA("TextLabel") and Shown(d) then
                    local idx = TITLES[Clean(d):upper()]
                    if idx then return idx, d end
                end
            end
            return nil
        end
        local function FindTabs(scope)
            local _, title = CurrentTitle(scope)
            if not title then return {} end
            local ty = title.AbsolutePosition.Y
            local list = {}
            for _, d in ipairs(scope:GetDescendants()) do
                if d:IsA("GuiButton") and Shown(d) then
                    local s, p = d.AbsoluteSize, d.AbsolutePosition
                    if s.X >= 40 and s.X <= 160 and s.Y >= 40 and s.Y <= 160 and p.Y + s.Y / 2 < ty then
                        local dup = false
                        for _, e in ipairs(list) do
                            if math.abs(CenterOf(e).X - CenterOf(d).X) < 25 and math.abs(CenterOf(e).Y - CenterOf(d).Y) < 25 then dup = true break end
                        end
                        if not dup then list[#list + 1] = d end
                    end
                end
            end
            table.sort(list, function(a, b) return CenterOf(a).X < CenterOf(b).X end)
            return list
        end
        -- [FIX] แถวไอคอนแท็บ: เอาเฉพาะปุ่มที่เรียงอยู่แถวเดียวกันมากที่สุด (ตัดปุ่มแปลกปลอมที่ทำให้ลำดับเพี้ยน)
        local function TabRow(scope)
            local cam = workspace.CurrentCamera
            local vp = cam and cam.ViewportSize or Vector2.new(1920, 1080)
            local _, title = CurrentTitle(scope)
            local limit = title and title.AbsolutePosition.Y or vp.Y * 0.25
            local cands = {}
            for _, d in ipairs(scope:GetDescendants()) do
                if d:IsA("GuiButton") and Shown(d) then
                    local sz = d.AbsoluteSize
                    if sz.X >= 40 and sz.X <= 160 and sz.Y >= 40 and sz.Y <= 160 and CenterOf(d).Y < limit then
                        local dup = false
                        for _, e in ipairs(cands) do
                            if math.abs(CenterOf(e).X - CenterOf(d).X) < 25 and math.abs(CenterOf(e).Y - CenterOf(d).Y) < 25 then dup = true break end
                        end
                        if not dup then cands[#cands + 1] = d end
                    end
                end
            end
            local best = {}
            for _, a in ipairs(cands) do
                local group = {}
                for _, b in ipairs(cands) do
                    if math.abs(CenterOf(a).Y - CenterOf(b).Y) < 30 then group[#group + 1] = b end
                end
                if #group > #best then best = group end
            end
            table.sort(best, function(a, b) return CenterOf(a).X < CenterOf(b).X end)
            return best
        end
        -- แท็บที่เลือกอยู่ = ไอคอนที่ใหญ่กว่าเพื่อน (ใช้ตรวจเมื่ออ่านชื่อหัวข้อไม่ได้)
        local function SelectedTab(row)
            local bi, bw, second = nil, 0, 0
            for i, b in ipairs(row) do
                local w = b.AbsoluteSize.X
                if w > bw then second = bw bw = w bi = i elseif w > second then second = w end
            end
            if bi and bw - second >= 6 then return bi end
            return nil
        end
        -- true = อยู่แท็บนี้ / false = อยู่แท็บอื่น / nil = ตรวจไม่ได้
        local function AtTab(scope, idx)
            local cur = CurrentTitle(scope)
            if cur then return cur == idx end
            local sel = SelectedTab(TabRow(scope))
            if sel then return sel == idx end
            return nil
        end
        local function OpenTab(idx)
            -- ลอง: ปุ่มลำดับที่ idx (คลิก 2 วิธี) -> ปุ่มข้างเคียง (เผื่อมีปุ่มแปลกปลอมแทรกในแถว) -> วิธีกด Enter
            local plan = { { 0, 1 }, { 0, 2 }, { 1, 2 }, { -1, 2 }, { 1, 1 }, { -1, 1 }, { 0, 3 } }
            for _, step in ipairs(plan) do
                local scope = ShopScope()
                if not scope then return false end
                if AtTab(scope, idx) == true then return true end
                local row = TabRow(scope)
                local btn = row[idx + step[1]]
                if btn then ClickObj(btn, step[2]) end
                local t0 = os.clock()
                while os.clock() - t0 < 1.0 do
                    task.wait(0.1)
                    local sc = ShopScope()
                    if sc then
                        local at = AtTab(sc, idx)
                        if at == true or (at == nil and step[1] == 0 and btn) then task.wait(0.35) return true end
                    end
                end
            end
            return false
        end

        -- ---------- อ่านการ์ดสินค้า ----------
        local function ParseCount(text)
            local a, b = text:lower():gsub("o", "0"):match("^(%d+)%s*/%s*(%d+)$")
            if a then return tonumber(a), tonumber(b) end
            return nil
        end
        local function ParsePrice(text)
            local s = text:gsub("[,%.%s]", "")
            if s:match("^%d+$") then return tonumber(s) end
            return nil
        end
        local STAR_CHARS = { "★", "✦", "✧", "☆", "⭐", "✮", "✯" }
        local function CountStars(card, priceTop)
            for _, d in ipairs(card:GetDescendants()) do
                if d:IsA("TextLabel") and Shown(d) then
                    local total = 0
                    local txt = d.Text or ""
                    for _, ch in ipairs(STAR_CHARS) do total += select(2, txt:gsub(ch, "")) end
                    if total > 0 then return total end
                end
            end
            for _, d in ipairs(card:GetDescendants()) do
                if d:IsA("GuiObject") and Shown(d) and d.Name:lower():find("star") and not d.Name:lower():find("stars") then
                    -- ชื่อ Star1, Star2, ... (นับเฉพาะที่แสดงอยู่)
                end
            end
            local groups = {}
            local top = card.AbsolutePosition.Y + card.AbsoluteSize.Y * 0.55
            for _, d in ipairs(card:GetDescendants()) do
                if (d:IsA("ImageLabel") or d:IsA("ImageButton")) and Shown(d) then
                    local s, c = d.AbsoluteSize, CenterOf(d)
                    if s.X <= 40 and s.Y <= 40 and c.Y > top and c.Y < priceTop - 2 then
                        local key = math.floor(c.Y / 6)
                        groups[key] = (groups[key] or 0) + 1
                    end
                end
            end
            local best = 0
            for _, n in pairs(groups) do if n > best then best = n end end
            return best > 0 and best or nil
        end
        local function ReadCards(scope)
            local cards, seen = {}, {}
            for _, d in ipairs(scope:GetDescendants()) do
                if d:IsA("TextLabel") and Shown(d) and ParseCount(Clean(d)) then
                    local cur, card = d.Parent, nil
                    for _ = 1, 6 do
                        if not cur or cur == scope or cur == PlayerGui then break end
                        if cur:IsA("GuiObject") and cur.AbsoluteSize.Y > 150 and cur.AbsoluteSize.X < 600 then
                            local hasPrice = false
                            for _, x in ipairs(cur:GetDescendants()) do
                                if x:IsA("TextLabel") and x ~= d and Shown(x) and ParsePrice(Clean(x)) then hasPrice = true break end
                            end
                            if hasPrice then card = cur break end
                        end
                        cur = cur.Parent
                    end
                    if card and not seen[card] then
                        seen[card] = true
                        local info = { Obj = card, Count = nil, Max = nil, Sold = false }
                        info.Count, info.Max = ParseCount(Clean(d))
                        local nameLbl, nameY, priceLbl, priceY = nil, math.huge, nil, -math.huge
                        for _, x in ipairs(card:GetDescendants()) do
                            if x:IsA("TextLabel") and Shown(x) and x ~= d then
                                local t = Clean(x)
                                local up = t:upper()
                                if up == "SOLD" then info.Sold = true
                                elseif ParsePrice(t) then
                                    if x.AbsolutePosition.Y > priceY then priceLbl, priceY = x, x.AbsolutePosition.Y end
                                elseif t ~= "?" and t:match("%a%a") and x.AbsolutePosition.Y < nameY then
                                    nameLbl, nameY = x, x.AbsolutePosition.Y
                                end
                            end
                        end
                        info.Name = nameLbl and Clean(nameLbl):upper() or "?"
                        info.Price = priceLbl and ParsePrice(Clean(priceLbl)) or nil
                        info.PriceObj = priceLbl -- [FIX] ป้ายราคา = ปุ่มซื้อจริงของการ์ด
                        info.Stars = priceLbl and CountStars(card, priceLbl.AbsolutePosition.Y) or nil
                        info.IsCrate = info.Name:find("CRATE") ~= nil
                        if info.Price then cards[#cards + 1] = info end
                    end
                end
            end
            table.sort(cards, function(a, b)
                local pa, pb = CenterOf(a.Obj), CenterOf(b.Obj)
                if math.abs(pa.Y - pb.Y) > 30 then return pa.Y < pb.Y end
                return pa.X < pb.X
            end)
            return cards
        end
        local function ReadMoney(scope, cards)
            local best, bestY = nil, -math.huge
            for _, d in ipairs(scope:GetDescendants()) do
                if d:IsA("TextLabel") and Shown(d) then
                    local v = ParsePrice(Clean(d))
                    if v then
                        local inCard = false
                        for _, c in ipairs(cards) do
                            if d:IsDescendantOf(c.Obj) then inCard = true break end
                        end
                        if not inCard and d.AbsolutePosition.Y > bestY then best, bestY = v, d.AbsolutePosition.Y end
                    end
                end
            end
            return best
        end
        local function CardButton(card)
            if card:IsA("GuiButton") then return card end
            local best, area = nil, 0
            for _, d in ipairs(card:GetDescendants()) do
                if d:IsA("GuiButton") and Shown(d) then
                    local t = d:IsA("TextButton") and Clean(d) or ""
                    local a = d.AbsoluteSize.X * d.AbsoluteSize.Y
                    if t ~= "?" and a > card.AbsoluteSize.X * card.AbsoluteSize.Y * 0.35 and a > area then best, area = d, a end
                end
            end
            return best
        end
        local CONFIRM_WORDS = { confirm = true, yes = true, buy = true, purchase = true, ok = true, accept = true }
        local function TryConfirm(cards)
            local lbl = FindText(function(t) return CONFIRM_WORDS[t] == true end)
            if not lbl then return false end
            for _, c in ipairs(cards) do
                if lbl:IsDescendantOf(c.Obj) then return false end
            end
            ClickObj(ButtonFor(lbl), 1)
            return true
        end

        local SHOP_STAR_PREFIX = { "ShopPerkStar", "ShopArtifactStar", "ShopMemoryStar" } -- [NEW] ดาวแยกตามแท็บ 1/2/3
        local function Allowed(card, money, tabIdx)
            if card.Sold or not card.Count or card.Count <= 0 or not card.Price then return false end
            if card.IsCrate and not Cfg.ShopCrates then return false end
            if card.Stars and not card.IsCrate then
                local prefix = SHOP_STAR_PREFIX[tabIdx] or "ShopPerkStar"
                if Cfg[prefix .. math.min(card.Stars, 5)] == false then return false end
            end
            if Cfg.ShopMaxPrice > 0 and card.Price > Cfg.ShopMaxPrice then return false end
            if money and card.Price > money - Cfg.ShopReserve then return false end
            return true
        end
        local function Rank(list)
            local mode = Cfg.ShopPriority
            table.sort(list, function(a, b)
                if mode == "Cheapest first" then
                    if a.Price ~= b.Price then return a.Price < b.Price end
                elseif mode == "Most expensive first" then
                    if a.Price ~= b.Price then return a.Price > b.Price end
                else
                    local sa, sb = a.Stars or 0, b.Stars or 0
                    if sa ~= sb then return sa > sb end
                    if a.Price ~= b.Price then return a.Price < b.Price end
                end
                return false
            end)
        end

        local boughtTotal, spentTotal = 0, 0
        local function BuyCard(card, scope)
            local before = ReadCards(scope)
            local moneyBefore = ReadMoney(scope, before)
            local countBefore = card.Count
            local btn = CardButton(card.Obj)
            -- [FIX] การ์ดตลาดไม่มี GuiButton (ล็อกขึ้น btn=false) ปุ่มซื้อคือป้ายราคาสีทอง -> คลิกตรงป้ายราคา ไม่ใช่กลางการ์ด
            local priceBtn = (card.PriceObj and card.PriceObj.Parent) and ButtonFor(card.PriceObj) or nil
            for attempt = 1, 4 do
                if not Alive() then return false end
                local target = btn or priceBtn or card.Obj
                ClickObj(target, attempt)
                local t0 = os.clock()
                while os.clock() - t0 < 1.8 do
                    task.wait(0.2)
                    local sc = ShopScope()
                    if not sc then return false end
                    local now = ReadCards(sc)
                    TryConfirm(now)
                    for _, c in ipairs(now) do
                        if c.Name == card.Name and math.abs(CenterOf(c.Obj).X - CenterOf(card.Obj).X) < 20 and math.abs(CenterOf(c.Obj).Y - CenterOf(card.Obj).Y) < 20 then
                            if c.Sold or (c.Count and countBefore and c.Count < countBefore) then
                                return true
                            end
                        end
                    end
                    local m = ReadMoney(sc, now)
                    if m and moneyBefore and m < moneyBefore then return true end
                end
            end
            return false
        end

        local function ShopTabPass(idx, label)
            if not OpenTab(idx) then return false, 0 end
            local failed, bought = {}, 0
            for _ = 1, 40 do
                local scope = ShopScope()
                if not scope or not Alive() then break end
                local cards = ReadCards(scope)
                local money = ReadMoney(scope, cards)
                local list = {}
                if #cards == 0 then
                    SetStatus(label .. ": no cards read (press Scan, see F9)")
                    print(("[SmoothHub][Shop] %s: 0 cards read | title=%s"):format(label, tostring(CurrentTitle(scope))))
                end
                for _, c in ipairs(cards) do
                    local key = c.Name .. "@" .. math.floor(CenterOf(c.Obj).X / 10) .. "," .. math.floor(CenterOf(c.Obj).Y / 10)
                    c.Key = key
                    if not failed[key] and Allowed(c, money, idx) then list[#list + 1] = c end
                end
                if #list == 0 then break end
                Rank(list)
                local pick = list[1]
                SetStatus(("%s: buying %s (%s coins)"):format(label, pick.Name, tostring(pick.Price)))
                if BuyCard(pick, scope) then
                    bought += 1
                    boughtTotal += 1
                    spentTotal += pick.Price
                    task.wait(0.3)
                else
                    failed[pick.Key] = true
                end
            end
            return true, bought
        end

        -- ---------- เปิดร้าน / ปิดร้าน ----------
        local function CloseShop()
            for _ = 1, 3 do
                local scope = ShopScope()
                if not scope then return end
                local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
                local best, bestScore = nil, math.huge
                for _, d in ipairs(scope:GetDescendants()) do
                    if d:IsA("GuiButton") and Shown(d) then
                        local c = CenterOf(d)
                        local txt = d:IsA("TextButton") and Clean(d):upper() or ""
                        if txt == "X" or (c.Y < 120 and c.X > vp.X - 160 and d.AbsoluteSize.X < 120) then
                            local score = (vp.X - c.X) + c.Y
                            if score < bestScore then best, bestScore = d, score end
                        end
                    end
                end
                if best then ClickObj(best, 1) end
                task.wait(0.6)
                if not ShopScope() then break end
            end
            local bye = FindText(function(t) return t == "au revoir" or t == "goodbye" or t == "bye" end)
            if bye then ClickObj(ButtonFor(bye), 1) task.wait(0.3) end
        end
        local function OpenMarket()
            if ShopScope() then return true end
            local npc = OrangeNpc()
            local pos = npc and NpcPos(npc)
            if not pos then SetStatus("Orange not found (not in wave mode?)") return false end
            for attempt = 1, 3 do
                if not MyRoot() then return false end
                SetStatus(("Going to Orange (%d/3)"):format(attempt))
                MoveTo(CFrame.new(pos + Vector3.new(4, 2, 4), pos))
                task.wait(0.4)
                SetStatus("Talking to Orange (E)")
                local prompt = npc:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt and type(fireproximityprompt) == "function" and attempt ~= 2 then
                    pcall(fireproximityprompt, prompt)
                else
                    TapKey(Enum.KeyCode.E, (prompt and prompt.HoldDuration or 0) + 0.2)
                end
                local t0 = os.clock()
                local clicked = false
                while os.clock() - t0 < 4 do
                    task.wait(0.25)
                    if ShopScope() then return true end
                    local lbl = FindText(function(t) return t:match("^%[?e%]?%s*market$") ~= nil end)
                    if lbl and not clicked then
                        SetStatus("Clicking [E] Market")
                        ClickObj(ButtonFor(lbl), attempt)
                        clicked = true
                        t0 = os.clock() - 2
                    end
                end
            end
            SetStatus("Could not open the Market")
            return false
        end

        local shopping = false
        local function SetFlag(key, value)
            Cfg[key] = value
            local ctl = Farm.Toggles and Farm.Toggles[key]
            if ctl then pcall(function() ctl.Value = value end) end
        end
        local function RunShop()
            if shopping then return false end
            Farm.NpcAcquire("Shop") -- ต่อคิวตามลำดับความสำคัญ
            shopping = true
            local wasFarm, wasThunder = Cfg.AutoFarm, Cfg.AutoFarmThunder
            SetFlag("AutoFarm", false)
            SetFlag("AutoFarmThunder", false)
            local root0 = MyRoot()
            local back = root0 and root0.CFrame
            boughtTotal, spentTotal = 0, 0
            local ok, err = pcall(function()
                if not OpenMarket() then error("open failed", 0) end
                task.wait(0.5)
                local tabs = {}
                if Cfg.ShopPerk then tabs[#tabs + 1] = { 1, "Perks" } end
                if Cfg.ShopArtifact then tabs[#tabs + 1] = { 2, "Artifacts" } end
                if Cfg.ShopMemory then tabs[#tabs + 1] = { 3, "Memories" } end
                if #tabs == 0 then SetStatus("Nothing selected to buy") return end
                for _, t in ipairs(tabs) do
                    local opened = ShopTabPass(t[1], t[2])
                    if not opened then SetStatus("Could not open tab: " .. t[2]) end
                end
                SetStatus(("Done: bought %d item(s), spent %d coins"):format(boughtTotal, spentTotal))
            end)
            if not ok and err ~= "open failed" then
                SetStatus("Error: " .. tostring(err))
                warn("[Smooth Hub] Auto Shop error: " .. tostring(err))
            end
            pcall(CloseShop)
            local root = MyRoot()
            if root and back then MoveTo(back) end
            if wasFarm then SetFlag("AutoFarm", true) end
            if wasThunder then SetFlag("AutoFarmThunder", true) end
            shopping = false
            Farm.NpcRelease()
            return ok
        end

        -- ---------- ปุ่มช่วย ----------
        local NowRow = ShopForm:Row()
        NowRow:Left():TitleStack({ Title = "Shop Now", Subtitle = "Run one shopping round right now." })
        local NowBtn = NowRow:Right():Button({ Label = "Shop", Callback = function() end })
        BindButton(NowBtn, function()
            if not Farm.CanUseHere() then SetStatus("Not in a match") return end
            RunShop()
        end)
        if SH.DEV then -- ปุ่ม Debug: ซ่อนไว้ (เปิดได้โดยตั้ง SH.DEV = true)
        local DbgRow = ShopForm:Row()
        DbgRow:Left():TitleStack({ Title = "Scan Shop (Debug)", Subtitle = "With the Market open: prints every card (name, stars, price, stock) to the F9 console." })
        local DbgBtn = DbgRow:Right():Button({ Label = "Scan", Callback = function() end })
        BindButton(DbgBtn, function()
            local scope = ShopScope()
            if not scope then SetStatus("Open the Market first") return end
            local cards = ReadCards(scope)
            print(("[SmoothHub][Shop] tab=%s cards=%d money=%s tabs=%d"):format(tostring(CurrentTitle(scope)), #cards, tostring(ReadMoney(scope, cards)), #FindTabs(scope)))
            local row = TabRow(scope)
            local widths = {}
            for i, b in ipairs(row) do widths[i] = math.floor(b.AbsoluteSize.X) end
            print(("[SmoothHub][Shop] tabRow=%d widths=%s selected=%s title=%s"):format(#row, table.concat(widths, ","), tostring(SelectedTab(row)), tostring(CurrentTitle(scope))))
            for i, c in ipairs(cards) do
                print(("[SmoothHub][Shop] #%d %s | stars=%s | price=%s | stock=%s/%s | sold=%s | btn=%s | %s"):format(
                    i, c.Name, tostring(c.Stars), tostring(c.Price), tostring(c.Count), tostring(c.Max), tostring(c.Sold),
                    tostring(CardButton(c.Obj) ~= nil), c.Obj:GetFullName()))
            end
            SetStatus(("Scanned %d cards (see F9)"):format(#cards))
        end)
        end

        -- ---------- ลูปหลัก: ซื้อ 1 รอบต่อ 1 เวฟ ----------
        local waveLabel, scanAt, lastWaveKnown = nil, 0, nil
        local function WaveKey()
            if not (waveLabel and waveLabel.Parent) then
                waveLabel = nil
                if os.clock() - scanAt < 2 then return lastWaveKnown end
                scanAt = os.clock()
                for _, d in ipairs(PlayerGui:GetDescendants()) do
                    if IsText(d) and Clean(d):lower():match("^waves cleared%s*%[%d+%s*/%s*%d+%]") then waveLabel = d break end
                end
            end
            if not waveLabel then return lastWaveKnown end
            local a = Clean(waveLabel):match("%[(%d+)%s*/")
            local v = a and tonumber(a) or nil
            if v then lastWaveKnown = v end
            return v or lastWaveKnown
        end
        task.spawn(function()
            local doneWave, fails, nextTry = -1, 0, 0
            while Alive() do
                task.wait(1)
                if not (Cfg.AutoShop and SH.PlayOn()) then
                    if not shopping then SetStatus("Off") end
                    doneWave, fails = -1, 0
                elseif not Farm.CanUseHere() or not OrangeNpc() then
                    SetStatus("Waiting for wave mode")
                elseif Farm.FailSafeActive then
                    SetStatus("Paused (Fail Safe is losing on purpose)")
                elseif not shopping and not Farm.Refilling and os.clock() >= nextTry then
                    local wave = WaveKey() or 0
                    local goldWhy = wave ~= doneWave and Farm.GoldBlock("Shop")
                    if goldWhy then
                        SetStatus(("Wave %d: %s"):format(wave, goldWhy))
                    elseif wave ~= doneWave then
                        SetStatus(("Wave %d: shopping..."):format(wave))
                        local ok = RunShop()
                        if ok then
                            doneWave, fails = wave, 0
                        else
                            fails += 1
                            nextTry = os.clock() + 6
                            if fails >= 3 then doneWave, fails = wave, 0 end
                        end
                    else
                        SetStatus(("Wave %d done. Waiting for next wave"):format(wave))
                    end
                end
            end
        end)
    end)
    SH.Guard("auto-heal-injuries", function()
        -- ============================================================
        --  🩹 Auto Heal Injuries [ Youmii ]  (Wave Mode) — ใช้ระบบ "คลิก UI" เหมือน Auto Shop
        --  บินไปหา NPC Youmii -> กด E -> กดปุ่ม [E] Injuries -> กดปุ่ม Heal -> ปิดหน้าต่าง -> บินกลับ
        -- ============================================================
        local InjSection = WaveModeTab:PageSection({
            Title = "🩹 Auto Heal Injuries [ Youmii ]",
            Subtitle = "Goes to Youmii, opens Injuries and clicks Heal for you (once every wave)."
        })
        local InjForm = InjSection:Form()
        local ToggleRow = InjForm:Row()
        ToggleRow:Left():TitleStack({ Title = "Auto Heal Injuries", Subtitle = "Visits Youmii at the start of every new wave and heals broken arms / legs (needs enough gold)." })
        UiSync.Link(ToggleRow:Right():Toggle({
            Value = Cfg.AutoHealInjuries,
            ValueChanged = function(self, value)
                Cfg.AutoHealInjuries = value and true or false
                Save()
            end
        }), Cfg, "AutoHealInjuries")
        local StatusRow = InjForm:Row()
        StatusRow:Left():TitleStack({ Title = "Heal Status", Subtitle = "Current action..." })
        local InjStatusLabel = StatusRow:Right():Label({ Text = "Off" })
        local lastStatus = nil
        local function SetStatus(text)
            if text == lastStatus then return end
            lastStatus = text
            pcall(function() InjStatusLabel.Text = tostring(text) end)
        end

        -- ---------- helpers: อ่าน / คลิก UI (ชุดเดียวกับ Auto Shop) ----------
        local function Clean(o)
            local t = tostring(o.Text or ""):gsub("<[^>]->", "")
            return (t:gsub("^%s+", ""):gsub("%s+$", ""))
        end
        local function Shown(obj)
            local cur = obj
            while cur and cur ~= PlayerGui do
                if cur:IsA("GuiObject") and not cur.Visible then return false end
                if cur:IsA("ScreenGui") and not cur.Enabled then return false end
                cur = cur.Parent
            end
            return obj:IsA("GuiObject") and obj.AbsoluteSize.X > 0 and obj.AbsoluteSize.Y > 0
        end
        local function IsText(d) return d:IsA("TextLabel") or d:IsA("TextButton") end
        local function CenterOf(o) return o.AbsolutePosition + o.AbsoluteSize / 2 end
        local function ClickObj(obj, attempt)
            attempt = attempt or 1
            local isBtn = obj:IsA("GuiButton")
            local method = (attempt - 1) % 3 + 1
            if method == 1 and (not isBtn or type(firesignal) ~= "function") then method = 2 end
            if method == 1 then
                pcall(firesignal, obj.Activated)
                pcall(firesignal, obj.MouseButton1Click)
            elseif method == 2 then
                local gui = obj:FindFirstAncestorOfClass("ScreenGui")
                local inset = (gui and gui.IgnoreGuiInset) and Vector2.zero or GuiService:GetGuiInset()
                local pos = CenterOf(obj) + inset
                pcall(function()
                    VirtualInputManager:SendMouseMoveEvent(pos.X, pos.Y, game)
                    task.wait(0.05)
                    VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
                    task.wait(0.06)
                    VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
                end)
            else
                if isBtn then
                    pcall(function() GuiService.SelectedObject = obj end)
                    task.wait(0.1)
                    pcall(function()
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                        task.wait(0.05)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                    end)
                    task.wait(0.1)
                    pcall(function() GuiService.SelectedObject = nil end)
                end
            end
        end
        local function ButtonFor(label)
            if label:IsA("GuiButton") then return label end
            local cur = label.Parent
            for _ = 1, 4 do
                if not cur or cur == PlayerGui then break end
                if cur:IsA("GuiButton") then return cur end
                cur = cur.Parent
            end
            return label
        end
        local function FindText(pred)
            for _, d in ipairs(PlayerGui:GetDescendants()) do
                if IsText(d) and Shown(d) and pred(Clean(d):lower()) then return d end
            end
            return nil
        end

        -- ---------- หา NPC Youmii ----------
        local function YoumiiNpc()
            local w = workspace:FindFirstChild("Waves")
            local n = w and w:FindFirstChild("NPCs")
            return n and n:FindFirstChild("Youmii")
        end
        local function NpcPos(npc)
            local ok, p = pcall(function()
                if npc:IsA("Model") then return npc:GetPivot().Position end
                if npc:IsA("BasePart") then return npc.Position end
                local part = npc:FindFirstChildWhichIsA("BasePart", true)
                return part and part.Position
            end)
            return ok and p or nil
        end
        local function MyRoot()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then return root end
            return nil
        end
        local function MoveTo(cf)
            local root = MyRoot()
            if not root then return end
            pcall(function() LocalPlayer:RequestStreamAroundAsync(cf.Position, 0.5) end)
            local dist = (root.Position - cf.Position).Magnitude
            local t = math.clamp(dist / 900, 0.15, 6)
            local ok, tw = pcall(function()
                return game:GetService("TweenService"):Create(root, TweenInfo.new(t, Enum.EasingStyle.Linear), { CFrame = cf })
            end)
            if not ok or not tw then pcall(function() root.CFrame = cf end) return end
            local vel = game:GetService("RunService").Heartbeat:Connect(function()
                pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
            end)
            tw:Play()
            local t0 = os.clock()
            while os.clock() - t0 < t + 0.3 and tw.PlaybackState == Enum.PlaybackState.Playing and Alive() do task.wait() end
            pcall(function() tw:Cancel() end)
            vel:Disconnect()
            pcall(function() root.CFrame = cf end)
        end
        local function TapKey(key, hold)
            pcall(function() VirtualInputManager:SendKeyEvent(true, key, false, game) end)
            task.wait(hold or 0.15)
            pcall(function() VirtualInputManager:SendKeyEvent(false, key, false, game) end)
        end

        -- ---------- หน้าต่าง Injuries ----------
        -- หัวข้อของหน้าต่างคือข้อความ "INJURIES" เฉยๆ (ปุ่มในบทสนทนาเป็น "[E] Injuries" เลยไม่ชนกัน)
        local function PanelScope()
            local lbl = FindText(function(t) return t == "injuries" end)
            return lbl and (lbl:FindFirstAncestorOfClass("ScreenGui") or PlayerGui) or nil
        end
        local function NoInjuries()
            return FindText(function(t) return t:match("^no injuries") ~= nil end) ~= nil
        end
        local function CloseInjuries()
            for _ = 1, 3 do
                local scope = PanelScope()
                if not scope then break end
                local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
                local best, bestScore = nil, math.huge
                for _, d in ipairs(scope:GetDescendants()) do
                    if d:IsA("GuiButton") and Shown(d) then
                        local c = CenterOf(d)
                        local txt = d:IsA("TextButton") and Clean(d):upper() or ""
                        if txt == "X" or (c.Y < 120 and c.X > vp.X - 160 and d.AbsoluteSize.X < 120) then
                            local score = (vp.X - c.X) + c.Y
                            if score < bestScore then best, bestScore = d, score end
                        end
                    end
                end
                if best then ClickObj(best, 1) end
                task.wait(0.6)
                if not PanelScope() then break end
            end
            -- จบบทสนทนากับ NPC (ปุ่ม "Nah dw")
            local bye = FindText(function(t) return t:match("^nah") ~= nil or t == "goodbye" or t == "bye" end)
            if bye then ClickObj(ButtonFor(bye), 1) task.wait(0.3) end
        end
        local function OpenInjuries()
            if PanelScope() then return true end
            local npc = YoumiiNpc()
            local pos = npc and NpcPos(npc)
            if not pos then SetStatus("Youmii not found (not in wave mode?)") return false end
            for attempt = 1, 3 do
                if not MyRoot() then return false end
                SetStatus(("Going to Youmii (%d/3)"):format(attempt))
                MoveTo(CFrame.new(pos + Vector3.new(4, 2, 4), pos))
                task.wait(0.4)
                SetStatus("Talking to Youmii (E)")
                local prompt = npc:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt and type(fireproximityprompt) == "function" and attempt ~= 2 then
                    pcall(fireproximityprompt, prompt)
                else
                    TapKey(Enum.KeyCode.E, (prompt and prompt.HoldDuration or 0) + 0.2)
                end
                local t0 = os.clock()
                local clicked = false
                while os.clock() - t0 < 4 do
                    task.wait(0.25)
                    if PanelScope() then return true end
                    local lbl = FindText(function(t) return t:match("^%[?e%]?%s*injuries$") ~= nil end)
                    if lbl and not clicked then
                        SetStatus("Clicking [E] Injuries")
                        ClickObj(ButtonFor(lbl), attempt)
                        clicked = true
                        t0 = os.clock() - 2
                    end
                end
            end
            SetStatus("Could not open Injuries")
            return false
        end

        -- กดปุ่ม Heal ทีละปุ่มจนไม่เหลือ (หยุดเมื่อกดปุ่มเดิมซ้ำ 3 ครั้งแล้วไม่หาย = น่าจะเงินไม่พอ)
        local function HealAll()
            local healed, lastBtn, same = 0, nil, 0
            for _ = 1, 12 do
                if not PanelScope() then return healed, "closed" end
                if NoInjuries() then return healed, "none" end
                local lbl = FindText(function(t) return t:match("^heal") ~= nil end)
                if not lbl then return healed, "nobutton" end
                local btn = ButtonFor(lbl)
                if btn == lastBtn then same += 1 else same = 0 end
                if same >= 3 then return healed, "stuck" end
                lastBtn = btn
                if same == 0 then healed += 1 end
                SetStatus(("Healing... (%d)"):format(healed))
                ClickObj(btn, same + 1)
                task.wait(0.8)
            end
            return healed, "limit"
        end

        local healing = false
        local function SetFlag(key, value)
            Cfg[key] = value
            local ctl = Farm.Toggles and Farm.Toggles[key]
            if ctl then pcall(function() ctl.Value = value end) end
        end
        local function RunHeal()
            if healing then return false end
            Farm.NpcAcquire("Heal") -- ต่อคิวตามลำดับความสำคัญ
            healing = true
            local wasFarm, wasThunder = Cfg.AutoFarm, Cfg.AutoFarmThunder
            SetFlag("AutoFarm", false)
            SetFlag("AutoFarmThunder", false)
            local root0 = MyRoot()
            local back = root0 and root0.CFrame
            local ok, err = pcall(function()
                if not OpenInjuries() then error("open failed", 0) end
                task.wait(0.5)
                local n, why = HealAll()
                if why == "none" and n == 0 then SetStatus("No injuries")
                elseif why == "stuck" then SetStatus("Heal did not work (not enough gold?)") Farm.GoldFail("Heal")
                elseif why == "nobutton" and n == 0 then SetStatus("No Heal button found (press Scan and check F9)")
                else SetStatus(("Done: healed %d injury(ies)"):format(n)) end
            end)
            if not ok and err ~= "open failed" then
                SetStatus("Error: " .. tostring(err))
                warn("[Smooth Hub] Auto Heal error: " .. tostring(err))
            end
            pcall(CloseInjuries)
            local root = MyRoot()
            if root and back then MoveTo(back) end
            if wasFarm then SetFlag("AutoFarm", true) end
            if wasThunder then SetFlag("AutoFarmThunder", true) end
            healing = false
            Farm.NpcRelease()
            return ok
        end

        -- ---------- ปุ่มช่วย ----------
        local NowRow = InjForm:Row()
        NowRow:Left():TitleStack({ Title = "Heal Now", Subtitle = "Visit Youmii and heal right now." })
        local NowBtn = NowRow:Right():Button({ Label = "Heal", Callback = function() end })
        BindButton(NowBtn, function()
            if not Farm.CanUseHere() then SetStatus("Not in a match") return end
            RunHeal()
        end)
        if SH.DEV then -- ปุ่ม Debug: ซ่อนไว้ (เปิดได้โดยตั้ง SH.DEV = true)
        local DbgRow = InjForm:Row()
        DbgRow:Left():TitleStack({ Title = "Scan Injuries (Debug)", Subtitle = "With the Injuries window open: prints every visible text/button to the F9 console." })
        local DbgBtn = DbgRow:Right():Button({ Label = "Scan", Callback = function() end })
        BindButton(DbgBtn, function()
            local scope = PanelScope()
            if not scope then SetStatus("Open the Injuries window first") return end
            local n = 0
            for _, d in ipairs(scope:GetDescendants()) do
                if IsText(d) and Shown(d) then
                    n += 1
                    print(("[SmoothHub][Heal] %s | %q | %s"):format(d.ClassName, Clean(d), d:GetFullName()))
                end
            end
            SetStatus(("Scanned %d texts (see F9)"):format(n))
        end)
        end

        -- ---------- ลูปหลัก: เช็ค 1 รอบต่อ 1 เวฟ ----------
        local waveLabel, scanAt, lastWaveKnown = nil, 0, nil
        local function WaveKey()
            if not (waveLabel and waveLabel.Parent) then
                waveLabel = nil
                if os.clock() - scanAt < 2 then return lastWaveKnown end
                scanAt = os.clock()
                for _, d in ipairs(PlayerGui:GetDescendants()) do
                    if IsText(d) and Clean(d):lower():match("^waves cleared%s*%[%d+%s*/%s*%d+%]") then waveLabel = d break end
                end
            end
            if not waveLabel then return lastWaveKnown end
            local a = Clean(waveLabel):match("%[(%d+)%s*/")
            local v = a and tonumber(a) or nil
            if v then lastWaveKnown = v end
            return v or lastWaveKnown
        end
        task.spawn(function()
            local doneWave, fails, nextTry = -1, 0, 0
            while Alive() do
                task.wait(1)
                if not Cfg.AutoHealInjuries then
                    if not healing then SetStatus("Off") end
                    doneWave, fails = -1, 0
                elseif not Farm.CanUseHere() or not YoumiiNpc() then
                    SetStatus("Waiting for wave mode")
                elseif Farm.FailSafeActive then
                    SetStatus("Paused (Fail Safe is losing on purpose)")
                elseif not healing and not Farm.Refilling and os.clock() >= nextTry then
                    local wave = WaveKey() or 0
                    local goldWhy = wave ~= doneWave and Farm.GoldBlock("Heal")
                    if goldWhy then
                        SetStatus(("Wave %d: %s"):format(wave, goldWhy))
                    elseif wave ~= doneWave then
                        SetStatus(("Wave %d: checking injuries..."):format(wave))
                        local ok = RunHeal()
                        if ok then
                            doneWave, fails = wave, 0
                        else
                            fails += 1
                            nextTry = os.clock() + 6
                            if fails >= 3 then doneWave, fails = wave, 0 end
                        end
                    else
                        SetStatus(("Wave %d done. Waiting for next wave"):format(wave))
                    end
                end
            end
        end)
    end)
    SH.Guard("auto-upgrade-cole", function()
        -- ============================================================
        --  ⬆️ Auto Upgrade Character [ Cole ]  (Wave Mode) — ใช้ระบบ "คลิก UI" เหมือน Auto Shop
        --  บินไปหา NPC Cole -> กด E -> กดปุ่ม [E] Upgrade -> กดปุ่ม BUY ของการ์ดที่เลือกไว้ -> ปิดหน้าต่าง -> บินกลับ
        -- ============================================================
        local UpgSection = WaveModeTab:PageSection({
            Title = "⬆️ Auto Upgrade Character [ Cole ]",
            Subtitle = "Goes to Cole, opens Upgrades and buys the upgrades you picked (once every wave)."
        })
        local UpgForm = UpgSection:Form()
        local ToggleRow = UpgForm:Row()
        ToggleRow:Left():TitleStack({ Title = "Auto Upgrade Character", Subtitle = "Visits Cole at the start of every new wave and buys the selected upgrades while you have enough gold." })
        UiSync.Link(ToggleRow:Right():Toggle({
            Value = Cfg.AutoUpgradeChar,
            ValueChanged = function(self, value)
                Cfg.AutoUpgradeChar = value and true or false
                Save()
            end
        }), Cfg, "AutoUpgradeChar")

        -- การ์ดในหน้าต่าง Upgrades: ชื่อบนการ์ด (ตัวเล็ก) -> คีย์ใน Cfg
        local CARDS = {
            { name = "Max HP", title = "max hp", key = "UpgMaxHP" },
            { name = "Regen", title = "regen", key = "UpgRegen" },
            { name = "Replenish", title = "replenish", key = "UpgReplenish" },
            { name = "Refills", title = "refills", key = "UpgRefills" },
            { name = "Revive", title = "revive", key = "UpgRevive" },
        }
        local OPTIONS, KEYS = {}, {}
        for i, c in ipairs(CARDS) do OPTIONS[i] = c.name KEYS[i] = c.key end

        -- ดรอปดาวเลือกได้หลายอัน (ค่าจริงเก็บเป็น boolean ใน Cfg เหมือนของ Auto Shop)
        do
            local row = UpgForm:Row()
            row:Left():TitleStack({ Title = "Upgrades to Buy", Subtitle = "Pick which upgrades Cole should buy: Max HP, Regen, Replenish, Refills, Revive." })
            local function selectedIndexes()
                local picked = {}
                for i, key in ipairs(KEYS) do
                    if Cfg[key] then picked[#picked + 1] = i end
                end
                return picked
            end
            local function apply(value)
                local indexes = type(value) == "table" and value or { value }
                local on = {}
                for _, index in ipairs(SettingsStore.ValidIndexes(indexes, #OPTIONS)) do on[index] = true end
                for i, key in ipairs(KEYS) do Cfg[key] = on[i] == true end
                Save()
            end
            local ok, btn = pcall(function()
                return row:Right():PopUpButton({
                    Options = OPTIONS,
                    Maximum = #OPTIONS, -- ต้องกำหนดเกิน 1 ถึงจะติ๊กได้หลายอัน
                    Value = selectedIndexes(),
                    ValueChanged = function(self, value) apply(value) end
                })
            end)
            if not ok or not btn then
                -- ไลบรารีไม่รองรับติ๊กหลายอัน: ถอยไปเลือกทีละอัน
                local first = selectedIndexes()[1]
                btn = row:Right():PullDownButton({
                    Label = first and OPTIONS[first] or "None",
                    Options = OPTIONS,
                    Value = first or 1,
                    ValueChanged = function(self, index)
                        apply(index)
                        self.Label = OPTIONS[index] or "None"
                    end
                })
            end
            StyleDropdown(btn)
            UiSync.Add(function()
                if ok then
                    pcall(function() btn.Value = selectedIndexes() end)
                else
                    local first = selectedIndexes()[1] or 1
                    pcall(function() btn.Value = first btn.Label = OPTIONS[first] end)
                end
            end)
        end

        local StatusRow = UpgForm:Row()
        StatusRow:Left():TitleStack({ Title = "Upgrade Status", Subtitle = "Current action..." })
        local UpgStatusLabel = StatusRow:Right():Label({ Text = "Off" })
        local lastStatus = nil
        local function SetStatus(text)
            if text == lastStatus then return end
            lastStatus = text
            pcall(function() UpgStatusLabel.Text = tostring(text) end)
        end

        -- ---------- helpers: อ่าน / คลิก UI (ชุดเดียวกับ Auto Shop) ----------
        local function Clean(o)
            local t = tostring(o.Text or ""):gsub("<[^>]->", "")
            return (t:gsub("^%s+", ""):gsub("%s+$", ""))
        end
        local function Shown(obj)
            local cur = obj
            while cur and cur ~= PlayerGui do
                if cur:IsA("GuiObject") and not cur.Visible then return false end
                if cur:IsA("ScreenGui") and not cur.Enabled then return false end
                cur = cur.Parent
            end
            return obj:IsA("GuiObject") and obj.AbsoluteSize.X > 0 and obj.AbsoluteSize.Y > 0
        end
        local function IsText(d) return d:IsA("TextLabel") or d:IsA("TextButton") end
        local function CenterOf(o) return o.AbsolutePosition + o.AbsoluteSize / 2 end
        local function ClickObj(obj, attempt)
            attempt = attempt or 1
            local isBtn = obj:IsA("GuiButton")
            local method = (attempt - 1) % 3 + 1
            if method == 1 and (not isBtn or type(firesignal) ~= "function") then method = 2 end
            if method == 1 then
                pcall(firesignal, obj.Activated)
                pcall(firesignal, obj.MouseButton1Click)
            elseif method == 2 then
                local gui = obj:FindFirstAncestorOfClass("ScreenGui")
                local inset = (gui and gui.IgnoreGuiInset) and Vector2.zero or GuiService:GetGuiInset()
                local pos = CenterOf(obj) + inset
                pcall(function()
                    VirtualInputManager:SendMouseMoveEvent(pos.X, pos.Y, game)
                    task.wait(0.05)
                    VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
                    task.wait(0.06)
                    VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
                end)
            else
                if isBtn then
                    pcall(function() GuiService.SelectedObject = obj end)
                    task.wait(0.1)
                    pcall(function()
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                        task.wait(0.05)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                    end)
                    task.wait(0.1)
                    pcall(function() GuiService.SelectedObject = nil end)
                end
            end
        end
        local function ButtonFor(label)
            if label:IsA("GuiButton") then return label end
            local cur = label.Parent
            for _ = 1, 4 do
                if not cur or cur == PlayerGui then break end
                if cur:IsA("GuiButton") then return cur end
                cur = cur.Parent
            end
            return label
        end
        local function FindText(pred)
            for _, d in ipairs(PlayerGui:GetDescendants()) do
                if IsText(d) and Shown(d) and pred(Clean(d):lower()) then return d end
            end
            return nil
        end

        -- ---------- หา NPC Cole ----------
        local function ColeNpc()
            local w = workspace:FindFirstChild("Waves")
            local n = w and w:FindFirstChild("NPCs")
            return n and n:FindFirstChild("Cole")
        end
        local function NpcPos(npc)
            local ok, p = pcall(function()
                if npc:IsA("Model") then return npc:GetPivot().Position end
                if npc:IsA("BasePart") then return npc.Position end
                local part = npc:FindFirstChildWhichIsA("BasePart", true)
                return part and part.Position
            end)
            return ok and p or nil
        end
        local function MyRoot()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then return root end
            return nil
        end
        local function MoveTo(cf)
            local root = MyRoot()
            if not root then return end
            pcall(function() LocalPlayer:RequestStreamAroundAsync(cf.Position, 0.5) end)
            local dist = (root.Position - cf.Position).Magnitude
            local t = math.clamp(dist / 900, 0.15, 6)
            local ok, tw = pcall(function()
                return game:GetService("TweenService"):Create(root, TweenInfo.new(t, Enum.EasingStyle.Linear), { CFrame = cf })
            end)
            if not ok or not tw then pcall(function() root.CFrame = cf end) return end
            local vel = game:GetService("RunService").Heartbeat:Connect(function()
                pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
            end)
            tw:Play()
            local t0 = os.clock()
            while os.clock() - t0 < t + 0.3 and tw.PlaybackState == Enum.PlaybackState.Playing and Alive() do task.wait() end
            pcall(function() tw:Cancel() end)
            vel:Disconnect()
            pcall(function() root.CFrame = cf end)
        end
        local function TapKey(key, hold)
            pcall(function() VirtualInputManager:SendKeyEvent(true, key, false, game) end)
            task.wait(hold or 0.15)
            pcall(function() VirtualInputManager:SendKeyEvent(false, key, false, game) end)
        end

        -- ---------- หน้าต่าง Upgrades ----------
        -- หัวข้อหน้าต่างคือข้อความ "UPGRADES" เฉยๆ (ปุ่มในบทสนทนาเป็น "[E] Upgrade" เลยไม่ชนกัน)
        local function PanelScope()
            local lbl = FindText(function(t) return t == "upgrades" end)
            return lbl and (lbl:FindFirstAncestorOfClass("ScreenGui") or PlayerGui) or nil
        end
        -- หาข้อความชื่อการ์ด (เช่น "MAX HP") ในหน้าต่าง
        local function TitleFor(scope, card)
            for _, d in ipairs(scope:GetDescendants()) do
                if IsText(d) and Shown(d) and Clean(d):lower() == card.title then return d end
            end
            return nil
        end
        -- ปุ่ม "BUY (350)" / "MAX (497)" ของการ์ด = ปุ่มที่อยู่ใต้ชื่อการ์ดและอยู่คอลัมน์เดียวกันที่สุด
        local function BuyBtnFor(scope, titleLbl)
            local tc = CenterOf(titleLbl)
            local best, bestDx = nil, 150
            for _, d in ipairs(scope:GetDescendants()) do
                if IsText(d) and Shown(d) then
                    local t = Clean(d):lower()
                    if t:match("^buy%s*%(") or t:match("^max%s*%(") then
                        local c = CenterOf(d)
                        local dx = math.abs(c.X - tc.X)
                        if c.Y > tc.Y and dx < bestDx then best, bestDx = d, dx end
                    end
                end
            end
            return best
        end
        local function CloseUpgrades()
            for _ = 1, 3 do
                local scope = PanelScope()
                if not scope then break end
                local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
                local best, bestScore = nil, math.huge
                for _, d in ipairs(scope:GetDescendants()) do
                    if d:IsA("GuiButton") and Shown(d) then
                        local c = CenterOf(d)
                        local txt = d:IsA("TextButton") and Clean(d):upper() or ""
                        if txt == "X" or (c.Y < 120 and c.X > vp.X - 160 and d.AbsoluteSize.X < 120) then
                            local score = (vp.X - c.X) + c.Y
                            if score < bestScore then best, bestScore = d, score end
                        end
                    end
                end
                if best then ClickObj(best, 1) end
                task.wait(0.6)
                if not PanelScope() then break end
            end
            -- จบบทสนทนากับ NPC (ปุ่ม "Bye")
            local bye = FindText(function(t) return t == "bye" or t == "goodbye" end)
            if bye then ClickObj(ButtonFor(bye), 1) task.wait(0.3) end
        end
        local function OpenUpgrades()
            if PanelScope() then return true end
            local npc = ColeNpc()
            local pos = npc and NpcPos(npc)
            if not pos then SetStatus("Cole not found (not in wave mode?)") return false end
            for attempt = 1, 3 do
                if not MyRoot() then return false end
                SetStatus(("Going to Cole (%d/3)"):format(attempt))
                MoveTo(CFrame.new(pos + Vector3.new(4, 2, 4), pos))
                task.wait(0.4)
                SetStatus("Talking to Cole (E)")
                local prompt = npc:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt and type(fireproximityprompt) == "function" and attempt ~= 2 then
                    pcall(fireproximityprompt, prompt)
                else
                    TapKey(Enum.KeyCode.E, (prompt and prompt.HoldDuration or 0) + 0.2)
                end
                local t0 = os.clock()
                local clicked = false
                while os.clock() - t0 < 4 do
                    task.wait(0.25)
                    if PanelScope() then return true end
                    local lbl = FindText(function(t) return t:match("^%[?e%]?%s*upgrades?$") ~= nil end)
                    if lbl and not clicked then
                        SetStatus("Clicking [E] Upgrade")
                        ClickObj(ButtonFor(lbl), attempt)
                        clicked = true
                        t0 = os.clock() - 2
                    end
                end
            end
            SetStatus("Could not open Upgrades")
            return false
        end

        -- ซื้อการ์ดเดียวซ้ำๆ จนเต็ม (MAX) หรือเงินไม่พอ
        -- ถ้ากด BUY แล้วข้อความบนปุ่มไม่เปลี่ยนเลย = ซื้อไม่ได้ (เงินไม่พอ) -> ลองอีก 3 วิธีคลิกแล้วหยุด
        local function BuyCard(card)
            local bought, tries = 0, 0
            for _ = 1, 30 do
                local scope = PanelScope()
                if not scope then return bought, "closed" end
                local title = TitleFor(scope, card)
                if not title then return bought, "notfound" end
                local btn = BuyBtnFor(scope, title)
                if not btn then return bought, "nobutton" end
                local before = Clean(btn):lower()
                if before:match("^max") then return bought, "max" end
                SetStatus(("Buying %s %s"):format(card.name, before))
                ClickObj(ButtonFor(btn), tries + 1)
                task.wait(0.8)
                local scope2 = PanelScope()
                local title2 = scope2 and TitleFor(scope2, card)
                local btn2 = title2 and BuyBtnFor(scope2, title2)
                local after = btn2 and Clean(btn2):lower() or ""
                if after ~= before then
                    bought += 1
                    tries = 0
                else
                    tries += 1
                    if tries >= 3 then return bought, "gold" end
                end
            end
            return bought, "limit"
        end

        local upgrading = false
        local function SetFlag(key, value)
            Cfg[key] = value
            local ctl = Farm.Toggles and Farm.Toggles[key]
            if ctl then pcall(function() ctl.Value = value end) end
        end
        local function RunUpgrade()
            if upgrading then return false end
            Farm.NpcAcquire("Character") -- ต่อคิวตามลำดับความสำคัญ
            upgrading = true
            local wasFarm, wasThunder = Cfg.AutoFarm, Cfg.AutoFarmThunder
            SetFlag("AutoFarm", false)
            SetFlag("AutoFarmThunder", false)
            local root0 = MyRoot()
            local back = root0 and root0.CFrame
            local ok, err = pcall(function()
                local picked = {}
                for _, c in ipairs(CARDS) do
                    if Cfg[c.key] then picked[#picked + 1] = c end
                end
                if #picked == 0 then SetStatus("Nothing selected to upgrade") return end
                if not OpenUpgrades() then error("open failed", 0) end
                task.wait(0.5)
                local total, noGold = 0, {}
                for _, c in ipairs(picked) do
                    local n, why = BuyCard(c)
                    total += n
                    if why == "gold" then noGold[#noGold + 1] = c.name end
                    if why == "notfound" or why == "nobutton" then warn("[Smooth Hub] Auto Upgrade: could not find the card/button for " .. c.name .. " (" .. why .. ")") end
                end
                if #noGold > 0 then
                    Farm.GoldFail("Character")
                    SetStatus(("Bought %d. Not enough gold for: %s"):format(total, table.concat(noGold, ", ")))
                else
                    SetStatus(("Done: bought %d upgrade(s)"):format(total))
                end
            end)
            if not ok and err ~= "open failed" then
                SetStatus("Error: " .. tostring(err))
                warn("[Smooth Hub] Auto Upgrade error: " .. tostring(err))
            end
            pcall(CloseUpgrades)
            local root = MyRoot()
            if root and back then MoveTo(back) end
            if wasFarm then SetFlag("AutoFarm", true) end
            if wasThunder then SetFlag("AutoFarmThunder", true) end
            upgrading = false
            Farm.NpcRelease()
            return ok
        end

        -- ---------- ปุ่มช่วย ----------
        local NowRow = UpgForm:Row()
        NowRow:Left():TitleStack({ Title = "Upgrade Now", Subtitle = "Visit Cole and buy the selected upgrades right now." })
        local NowBtn = NowRow:Right():Button({ Label = "Upgrade", Callback = function() end })
        BindButton(NowBtn, function()
            if not Farm.CanUseHere() then SetStatus("Not in a match") return end
            RunUpgrade()
        end)
        if SH.DEV then -- ปุ่ม Debug: ซ่อนไว้ (เปิดได้โดยตั้ง SH.DEV = true)
        local DbgRow = UpgForm:Row()
        DbgRow:Left():TitleStack({ Title = "Scan Upgrades (Debug)", Subtitle = "With the Upgrades window open: prints every visible text/button to the F9 console." })
        local DbgBtn = DbgRow:Right():Button({ Label = "Scan", Callback = function() end })
        BindButton(DbgBtn, function()
            local scope = PanelScope()
            if not scope then SetStatus("Open the Upgrades window first") return end
            local n = 0
            for _, d in ipairs(scope:GetDescendants()) do
                if IsText(d) and Shown(d) then
                    n += 1
                    print(("[SmoothHub][Upgrade] %s | %q | %s"):format(d.ClassName, Clean(d), d:GetFullName()))
                end
            end
            SetStatus(("Scanned %d texts (see F9)"):format(n))
        end)
        end

        -- ---------- ลูปหลัก: ซื้อ 1 รอบต่อ 1 เวฟ ----------
        local waveLabel, scanAt, lastWaveKnown = nil, 0, nil
        local function WaveKey()
            if not (waveLabel and waveLabel.Parent) then
                waveLabel = nil
                if os.clock() - scanAt < 2 then return lastWaveKnown end
                scanAt = os.clock()
                for _, d in ipairs(PlayerGui:GetDescendants()) do
                    if IsText(d) and Clean(d):lower():match("^waves cleared%s*%[%d+%s*/%s*%d+%]") then waveLabel = d break end
                end
            end
            if not waveLabel then return lastWaveKnown end
            local a = Clean(waveLabel):match("%[(%d+)%s*/")
            local v = a and tonumber(a) or nil
            if v then lastWaveKnown = v end
            return v or lastWaveKnown
        end
        task.spawn(function()
            local doneWave, fails, nextTry = -1, 0, 0
            while Alive() do
                task.wait(1)
                if not Cfg.AutoUpgradeChar then
                    if not upgrading then SetStatus("Off") end
                    doneWave, fails = -1, 0
                elseif not Farm.CanUseHere() or not ColeNpc() then
                    SetStatus("Waiting for wave mode")
                elseif Farm.FailSafeActive then
                    SetStatus("Paused (Fail Safe is losing on purpose)")
                elseif not upgrading and not Farm.Refilling and os.clock() >= nextTry then
                    local wave = WaveKey() or 0
                    local goldWhy = wave ~= doneWave and Farm.GoldBlock("Character")
                    if goldWhy then
                        SetStatus(("Wave %d: %s"):format(wave, goldWhy))
                    elseif wave ~= doneWave then
                        SetStatus(("Wave %d: upgrading..."):format(wave))
                        local ok = RunUpgrade()
                        if ok then
                            doneWave, fails = wave, 0
                        else
                            fails += 1
                            nextTry = os.clock() + 6
                            if fails >= 3 then doneWave, fails = wave, 0 end
                        end
                    else
                        SetStatus(("Wave %d done. Waiting for next wave"):format(wave))
                    end
                end
            end
        end)
    end)
    SH.Guard("auto-upgrade-blades-lulu", function()
        -- ============================================================
        --  🗡️ Auto Upgrade [ Blades ] All  (Wave Mode) — ใช้ระบบ "คลิก UI" เหมือน Auto Shop
        --  บินไปหา NPC Lulu -> กด E -> กดปุ่ม [E] Equipment -> กดปุ่ม UPGRADE ALL -> ปิดหน้าต่าง -> บินกลับ
        -- ============================================================
        local BladeSection = WaveModeTab:PageSection({
            Title = "🗡️ Auto Upgrade [ Blades ] All",
            Subtitle = "Goes to Lulu, opens Equipment and presses UPGRADE ALL for you (once every wave)."
        })
        local BladeForm = BladeSection:Form()
        local ToggleRow = BladeForm:Row()
        ToggleRow:Left():TitleStack({ Title = "Auto Upgrade [ Blades ] All", Subtitle = "Visits Lulu at the start of every new wave and upgrades all your blade stats while you have enough gold." })
        UiSync.Link(ToggleRow:Right():Toggle({
            Value = Cfg.AutoUpgradeBlades,
            ValueChanged = function(self, value)
                Cfg.AutoUpgradeBlades = value and true or false
                Save()
            end
        }), Cfg, "AutoUpgradeBlades")
        local StatusRow = BladeForm:Row()
        StatusRow:Left():TitleStack({ Title = "Blade Upgrade Status", Subtitle = "Current action..." })
        local BladeStatusLabel = StatusRow:Right():Label({ Text = "Off" })
        local lastStatus = nil
        local function SetStatus(text)
            if text == lastStatus then return end
            lastStatus = text
            pcall(function() BladeStatusLabel.Text = tostring(text) end)
        end

        -- ---------- helpers: อ่าน / คลิก UI (ชุดเดียวกับ Auto Shop) ----------
        local function Clean(o)
            local t = tostring(o.Text or ""):gsub("<[^>]->", "")
            return (t:gsub("^%s+", ""):gsub("%s+$", ""))
        end
        local function Shown(obj)
            local cur = obj
            while cur and cur ~= PlayerGui do
                if cur:IsA("GuiObject") and not cur.Visible then return false end
                if cur:IsA("ScreenGui") and not cur.Enabled then return false end
                cur = cur.Parent
            end
            return obj:IsA("GuiObject") and obj.AbsoluteSize.X > 0 and obj.AbsoluteSize.Y > 0
        end
        local function IsText(d) return d:IsA("TextLabel") or d:IsA("TextButton") end
        local function CenterOf(o) return o.AbsolutePosition + o.AbsoluteSize / 2 end
        local function ClickObj(obj, attempt)
            attempt = attempt or 1
            local isBtn = obj:IsA("GuiButton")
            local method = (attempt - 1) % 3 + 1
            if method == 1 and (not isBtn or type(firesignal) ~= "function") then method = 2 end
            if method == 1 then
                pcall(firesignal, obj.Activated)
                pcall(firesignal, obj.MouseButton1Click)
            elseif method == 2 then
                local gui = obj:FindFirstAncestorOfClass("ScreenGui")
                local inset = (gui and gui.IgnoreGuiInset) and Vector2.zero or GuiService:GetGuiInset()
                local pos = CenterOf(obj) + inset
                pcall(function()
                    VirtualInputManager:SendMouseMoveEvent(pos.X, pos.Y, game)
                    task.wait(0.05)
                    VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
                    task.wait(0.06)
                    VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
                end)
            else
                if isBtn then
                    pcall(function() GuiService.SelectedObject = obj end)
                    task.wait(0.1)
                    pcall(function()
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                        task.wait(0.05)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                    end)
                    task.wait(0.1)
                    pcall(function() GuiService.SelectedObject = nil end)
                end
            end
        end
        local function ButtonFor(label)
            if label:IsA("GuiButton") then return label end
            local cur = label.Parent
            for _ = 1, 4 do
                if not cur or cur == PlayerGui then break end
                if cur:IsA("GuiButton") then return cur end
                cur = cur.Parent
            end
            return label
        end
        local function FindText(pred)
            for _, d in ipairs(PlayerGui:GetDescendants()) do
                if IsText(d) and Shown(d) and pred(Clean(d):lower()) then return d end
            end
            return nil
        end

        -- ---------- หา NPC Lulu ----------
        local function LuluNpc()
            local w = workspace:FindFirstChild("Waves")
            local n = w and w:FindFirstChild("NPCs")
            return n and n:FindFirstChild("Lulu")
        end
        local function NpcPos(npc)
            local ok, p = pcall(function()
                if npc:IsA("Model") then return npc:GetPivot().Position end
                if npc:IsA("BasePart") then return npc.Position end
                local part = npc:FindFirstChildWhichIsA("BasePart", true)
                return part and part.Position
            end)
            return ok and p or nil
        end
        local function MyRoot()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then return root end
            return nil
        end
        local function MoveTo(cf)
            local root = MyRoot()
            if not root then return end
            pcall(function() LocalPlayer:RequestStreamAroundAsync(cf.Position, 0.5) end)
            local dist = (root.Position - cf.Position).Magnitude
            local t = math.clamp(dist / 900, 0.15, 6)
            local ok, tw = pcall(function()
                return game:GetService("TweenService"):Create(root, TweenInfo.new(t, Enum.EasingStyle.Linear), { CFrame = cf })
            end)
            if not ok or not tw then pcall(function() root.CFrame = cf end) return end
            local vel = game:GetService("RunService").Heartbeat:Connect(function()
                pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
            end)
            tw:Play()
            local t0 = os.clock()
            while os.clock() - t0 < t + 0.3 and tw.PlaybackState == Enum.PlaybackState.Playing and Alive() do task.wait() end
            pcall(function() tw:Cancel() end)
            vel:Disconnect()
            pcall(function() root.CFrame = cf end)
        end
        local function TapKey(key, hold)
            pcall(function() VirtualInputManager:SendKeyEvent(true, key, false, game) end)
            task.wait(hold or 0.15)
            pcall(function() VirtualInputManager:SendKeyEvent(false, key, false, game) end)
        end

        -- ---------- หน้าต่าง Equipment ----------
        -- หน้าต่างนี้ไม่มีหัวข้อชัดเจน เลยใช้ปุ่ม "UPGRADE ALL" เป็นตัวบอกว่าหน้าต่างเปิดอยู่
        local function UpgradeAllLabel()
            return FindText(function(t) return t == "upgrade all" end)
        end
        local function PanelScope()
            local lbl = UpgradeAllLabel()
            return lbl and (lbl:FindFirstAncestorOfClass("ScreenGui") or PlayerGui) or nil
        end
        local function CloseEquipment()
            for _ = 1, 3 do
                local scope = PanelScope()
                if not scope then break end
                local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
                local best, bestScore = nil, math.huge
                for _, d in ipairs(scope:GetDescendants()) do
                    if d:IsA("GuiButton") and Shown(d) then
                        local c = CenterOf(d)
                        local txt = d:IsA("TextButton") and Clean(d):upper() or ""
                        if txt == "X" or (c.Y < 120 and c.X > vp.X - 160 and d.AbsoluteSize.X < 120) then
                            local score = (vp.X - c.X) + c.Y
                            if score < bestScore then best, bestScore = d, score end
                        end
                    end
                end
                if best then ClickObj(best, 1) end
                task.wait(0.6)
                if not PanelScope() then break end
            end
            -- จบบทสนทนากับ NPC (ปุ่ม "Bye")
            local bye = FindText(function(t) return t == "bye" or t == "goodbye" end)
            if bye then ClickObj(ButtonFor(bye), 1) task.wait(0.3) end
        end
        local function OpenEquipment()
            if PanelScope() then return true end
            local npc = LuluNpc()
            local pos = npc and NpcPos(npc)
            if not pos then SetStatus("Lulu not found (not in wave mode?)") return false end
            for attempt = 1, 3 do
                if not MyRoot() then return false end
                SetStatus(("Going to Lulu (%d/3)"):format(attempt))
                MoveTo(CFrame.new(pos + Vector3.new(4, 2, 4), pos))
                task.wait(0.4)
                SetStatus("Talking to Lulu (E)")
                local prompt = npc:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt and type(fireproximityprompt) == "function" and attempt ~= 2 then
                    pcall(fireproximityprompt, prompt)
                else
                    TapKey(Enum.KeyCode.E, (prompt and prompt.HoldDuration or 0) + 0.2)
                end
                local t0 = os.clock()
                local clicked = false
                while os.clock() - t0 < 4 do
                    task.wait(0.25)
                    if PanelScope() then return true end
                    local lbl = FindText(function(t) return t:match("^%[?e%]?%s*equipment$") ~= nil end)
                    if lbl and not clicked then
                        SetStatus("Clicking [E] Equipment")
                        ClickObj(ButtonFor(lbl), attempt)
                        clicked = true
                        t0 = os.clock() - 2
                    end
                end
            end
            SetStatus("Could not open Equipment")
            return false
        end

        local working = false
        local function SetFlag(key, value)
            Cfg[key] = value
            local ctl = Farm.Toggles and Farm.Toggles[key]
            if ctl then pcall(function() ctl.Value = value end) end
        end
        local function RunUpgrade()
            if working then return false end
            Farm.NpcAcquire("Blades") -- ต่อคิวตามลำดับความสำคัญ
            working = true
            local wasFarm, wasThunder = Cfg.AutoFarm, Cfg.AutoFarmThunder
            SetFlag("AutoFarm", false)
            SetFlag("AutoFarmThunder", false)
            local root0 = MyRoot()
            local back = root0 and root0.CFrame
            local ok, err = pcall(function()
                if not OpenEquipment() then error("open failed", 0) end
                task.wait(0.6)
                -- กด UPGRADE ALL 2 รอบ (รอบแรกคลิกแบบสัญญาณ รอบสองคลิกเมาส์ ถ้ารอบแรกติดอยู่แล้วรอบสองจะอัพส่วนที่เหลือต่อ)
                for attempt = 1, 2 do
                    local lbl = UpgradeAllLabel()
                    if not lbl then error("UPGRADE ALL button not found", 0) end
                    SetStatus(("Pressing UPGRADE ALL (%d/2)"):format(attempt))
                    ClickObj(ButtonFor(lbl), attempt)
                    task.wait(1)
                end
                SetStatus("Done: pressed UPGRADE ALL")
            end)
            if not ok and err ~= "open failed" then
                SetStatus("Error: " .. tostring(err))
                warn("[Smooth Hub] Auto Upgrade Blades error: " .. tostring(err))
            end
            pcall(CloseEquipment)
            local root = MyRoot()
            if root and back then MoveTo(back) end
            if wasFarm then SetFlag("AutoFarm", true) end
            if wasThunder then SetFlag("AutoFarmThunder", true) end
            working = false
            Farm.NpcRelease()
            return ok
        end

        -- ---------- ปุ่มช่วย ----------
        local NowRow = BladeForm:Row()
        NowRow:Left():TitleStack({ Title = "Upgrade Now", Subtitle = "Visit Lulu and press UPGRADE ALL right now." })
        local NowBtn = NowRow:Right():Button({ Label = "Upgrade", Callback = function() end })
        BindButton(NowBtn, function()
            if not Farm.CanUseHere() then SetStatus("Not in a match") return end
            RunUpgrade()
        end)
        if SH.DEV then -- ปุ่ม Debug: ซ่อนไว้ (เปิดได้โดยตั้ง SH.DEV = true)
        local DbgRow = BladeForm:Row()
        DbgRow:Left():TitleStack({ Title = "Scan Equipment (Debug)", Subtitle = "With the Equipment window open: prints every visible text/button to the F9 console." })
        local DbgBtn = DbgRow:Right():Button({ Label = "Scan", Callback = function() end })
        BindButton(DbgBtn, function()
            local scope = PanelScope()
            if not scope then SetStatus("Open the Equipment window first") return end
            local n = 0
            for _, d in ipairs(scope:GetDescendants()) do
                if IsText(d) and Shown(d) then
                    n += 1
                    print(("[SmoothHub][Blades] %s | %q | %s"):format(d.ClassName, Clean(d), d:GetFullName()))
                end
            end
            SetStatus(("Scanned %d texts (see F9)"):format(n))
        end)
        end

        -- ---------- ลูปหลัก: 1 รอบต่อ 1 เวฟ ----------
        local waveLabel, scanAt, lastWaveKnown = nil, 0, nil
        local function WaveKey()
            if not (waveLabel and waveLabel.Parent) then
                waveLabel = nil
                if os.clock() - scanAt < 2 then return lastWaveKnown end
                scanAt = os.clock()
                for _, d in ipairs(PlayerGui:GetDescendants()) do
                    if IsText(d) and Clean(d):lower():match("^waves cleared%s*%[%d+%s*/%s*%d+%]") then waveLabel = d break end
                end
            end
            if not waveLabel then return lastWaveKnown end
            local a = Clean(waveLabel):match("%[(%d+)%s*/")
            local v = a and tonumber(a) or nil
            if v then lastWaveKnown = v end
            return v or lastWaveKnown
        end
        task.spawn(function()
            local doneWave, fails, nextTry = -1, 0, 0
            while Alive() do
                task.wait(1)
                if not Cfg.AutoUpgradeBlades then
                    if not working then SetStatus("Off") end
                    doneWave, fails = -1, 0
                elseif not Farm.CanUseHere() or not LuluNpc() then
                    SetStatus("Waiting for wave mode")
                elseif Farm.FailSafeActive then
                    SetStatus("Paused (Fail Safe is losing on purpose)")
                elseif not working and not Farm.Refilling and os.clock() >= nextTry then
                    local wave = WaveKey() or 0
                    local goldWhy = wave ~= doneWave and Farm.GoldBlock("Blades")
                    if goldWhy then
                        SetStatus(("Wave %d: %s"):format(wave, goldWhy))
                    elseif wave ~= doneWave then
                        SetStatus(("Wave %d: upgrading blades..."):format(wave))
                        local ok = RunUpgrade()
                        if ok then
                            doneWave, fails = wave, 0
                        else
                            fails += 1
                            nextTry = os.clock() + 6
                            if fails >= 3 then doneWave, fails = wave, 0 end
                        end
                    else
                        SetStatus(("Wave %d done. Waiting for next wave"):format(wave))
                    end
                end
            end
        end)
    end)
    SH.Guard("auto-roll-blessings", function()
        -- ============================================================
        --  🎰 Auto Roll Blessings [ Roll ]  (Wave Mode) — ใช้ระบบ "คลิก UI" เหมือน Auto Shop
        --  Gold >= 2,000 -> บินไปหา NPC Roll -> กด E -> กดปุ่ม ROLL ซ้ำจน Gold ไม่พอ -> ปิดหน้าต่าง -> บินกลับ
        -- ============================================================
        local ROLL_MIN_GOLD = 2000   -- ราคา Roll ขั้นต่ำ (ถ้าปุ่มบอกราคาสูงกว่านี้ จะใช้ราคาบนปุ่มแทน)
        local MAX_ROLLS = 40         -- กันลูปไม่รู้จบใน 1 รอบที่เข้าไปหา NPC
        local SETTLE = 3.5           -- รอแอนิเมชันสล็อตหมุนจบหลังกด ROLL แต่ละครั้ง
        local RollSection = WaveModeTab:PageSection({
            Title = "🎰 Auto Roll Blessings [ Roll ]",
            Subtitle = "Goes to Roll and spins the Blessings machine whenever you have 2,000 gold or more."
        })
        local RollForm = RollSection:Form()
        local ToggleRow = RollForm:Row()
        ToggleRow:Left():TitleStack({ Title = "Auto Roll Blessings", Subtitle = "Rolls (2,000 gold each) while your gold is 2,000 or more, then flies back to your spot." })
        UiSync.Link(ToggleRow:Right():Toggle({
            Value = Cfg.AutoRollBlessing,
            ValueChanged = function(self, value)
                Cfg.AutoRollBlessing = value and true or false
                Save()
            end
        }), Cfg, "AutoRollBlessing")
        local StopRow = RollForm:Row()
        StopRow:Left():TitleStack({ Title = "Stop When 3 Cards Match", Subtitle = "Stops rolling (and turns Auto Roll off) as soon as the machine lands 3 matching cards and shows a reward." })
        UiSync.Link(StopRow:Right():Toggle({
            Value = Cfg.RollStopOnMatch,
            ValueChanged = function(self, value)
                Cfg.RollStopOnMatch = value and true or false
                Save()
            end
        }), Cfg, "RollStopOnMatch")
        local StatusRow = RollForm:Row()
        StatusRow:Left():TitleStack({ Title = "Roll Status", Subtitle = "Current action..." })
        local RollStatusLabel = StatusRow:Right():Label({ Text = "Off" })
        local lastStatus = nil
        local function SetStatus(text)
            if text == lastStatus then return end
            lastStatus = text
            pcall(function() RollStatusLabel.Text = tostring(text) end)
        end

        -- ---------- helpers: อ่าน / คลิก UI (ชุดเดียวกับ Auto Shop) ----------
        local function Clean(o)
            local t = tostring(o.Text or ""):gsub("<[^>]->", "")
            return (t:gsub("^%s+", ""):gsub("%s+$", ""))
        end
        local function Shown(obj)
            local cur = obj
            while cur and cur ~= PlayerGui do
                if cur:IsA("GuiObject") and not cur.Visible then return false end
                if cur:IsA("ScreenGui") and not cur.Enabled then return false end
                cur = cur.Parent
            end
            return obj:IsA("GuiObject") and obj.AbsoluteSize.X > 0 and obj.AbsoluteSize.Y > 0
        end
        local function IsText(d) return d:IsA("TextLabel") or d:IsA("TextButton") end
        local function CenterOf(o) return o.AbsolutePosition + o.AbsoluteSize / 2 end
        local function ClickObj(obj, attempt)
            attempt = attempt or 1
            local isBtn = obj:IsA("GuiButton")
            local method = (attempt - 1) % 3 + 1
            if method == 1 and (not isBtn or type(firesignal) ~= "function") then method = 2 end
            if method == 1 then
                pcall(firesignal, obj.Activated)
                pcall(firesignal, obj.MouseButton1Click)
            elseif method == 2 then
                local gui = obj:FindFirstAncestorOfClass("ScreenGui")
                local inset = (gui and gui.IgnoreGuiInset) and Vector2.zero or GuiService:GetGuiInset()
                local pos = CenterOf(obj) + inset
                pcall(function()
                    VirtualInputManager:SendMouseMoveEvent(pos.X, pos.Y, game)
                    task.wait(0.05)
                    VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
                    task.wait(0.06)
                    VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
                end)
            else
                if isBtn then
                    pcall(function() GuiService.SelectedObject = obj end)
                    task.wait(0.1)
                    pcall(function()
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                        task.wait(0.05)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                    end)
                    task.wait(0.1)
                    pcall(function() GuiService.SelectedObject = nil end)
                end
            end
        end
        local function ButtonFor(label)
            if label:IsA("GuiButton") then return label end
            local cur = label.Parent
            for _ = 1, 4 do
                if not cur or cur == PlayerGui then break end
                if cur:IsA("GuiButton") then return cur end
                cur = cur.Parent
            end
            return label
        end
        local function FindText(pred)
            for _, d in ipairs(PlayerGui:GetDescendants()) do
                if IsText(d) and Shown(d) and pred(Clean(d):lower()) then return d end
            end
            return nil
        end
        local function RollNpc()
            local w = workspace:FindFirstChild("Waves")
            local n = w and w:FindFirstChild("NPCs")
            return n and n:FindFirstChild("Roll")
        end
        local function NpcPos(npc)
            local ok, p = pcall(function()
                if npc:IsA("Model") then return npc:GetPivot().Position end
                if npc:IsA("BasePart") then return npc.Position end
                local part = npc:FindFirstChildWhichIsA("BasePart", true)
                return part and part.Position
            end)
            return ok and p or nil
        end
        local function MyRoot()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then return root end
            return nil
        end
        local function MoveTo(cf)
            local root = MyRoot()
            if not root then return end
            pcall(function() LocalPlayer:RequestStreamAroundAsync(cf.Position, 0.5) end)
            local dist = (root.Position - cf.Position).Magnitude
            local t = math.clamp(dist / 900, 0.15, 6)
            local ok, tw = pcall(function()
                return game:GetService("TweenService"):Create(root, TweenInfo.new(t, Enum.EasingStyle.Linear), { CFrame = cf })
            end)
            if not ok or not tw then pcall(function() root.CFrame = cf end) return end
            local vel = game:GetService("RunService").Heartbeat:Connect(function()
                pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
            end)
            tw:Play()
            local t0 = os.clock()
            while os.clock() - t0 < t + 0.3 and tw.PlaybackState == Enum.PlaybackState.Playing and Alive() do task.wait() end
            pcall(function() tw:Cancel() end)
            vel:Disconnect()
            pcall(function() root.CFrame = cf end)
        end
        local function TapKey(key, hold)
            pcall(function() VirtualInputManager:SendKeyEvent(true, key, false, game) end)
            task.wait(hold or 0.15)
            pcall(function() VirtualInputManager:SendKeyEvent(false, key, false, game) end)
        end

        -- ---------- อ่านตัวเลข Gold ----------
        -- รองรับ "523", "2,000", "12.5K", "1.2M"
        local function ParseAmount(text)
            local num, suf = tostring(text):match("^([%d,%.]+)%s*([kKmM]?)$")
            if not num then return nil end
            local v = tonumber((num:gsub(",", "")))
            if not v then return nil end
            suf = suf:lower()
            if suf == "k" then v = v * 1000 elseif suf == "m" then v = v * 1000000 end
            return v
        end
        local GOLD_HINTS = { "gold", "coin", "money", "currenc", "cash" }
        local function HintedName(d)
            local cur = d
            for _ = 1, 5 do
                if not cur or cur == PlayerGui then break end
                local n = cur.Name:lower()
                for _, h in ipairs(GOLD_HINTS) do
                    if n:find(h, 1, true) then return true end
                end
                cur = cur.Parent
            end
            return false
        end
        local goldCache = nil
        local function ReadGold(panel)
            if goldCache and goldCache.Parent and Shown(goldCache) then
                local v = ParseAmount(Clean(goldCache))
                if v then return v end
            end
            goldCache = nil
            -- 1) ป้ายตัวเลขที่ชื่อ/พ่อแม่มีคำว่า gold/coin/money (มีไอคอนเหรียญข้างๆ จะได้คะแนนเพิ่ม)
            local best, bestScore, bestV = nil, -1, nil
            for _, d in ipairs(PlayerGui:GetDescendants()) do
                if d:IsA("TextLabel") and Shown(d) and HintedName(d) then
                    local v = ParseAmount(Clean(d))
                    if v then
                        local score = 1
                        local par = d.Parent
                        if par and par:FindFirstChildWhichIsA("ImageLabel", true) then score = 2 end
                        if score > bestScore then best, bestScore, bestV = d, score, v end
                    end
                end
            end
            if best then goldCache = best return bestV end
            -- 2) สำรอง: ในหน้าต่าง Blessings ใช้ตัวเลขล้วนที่อยู่ต่ำสุดบนจอ (เหนือปุ่ม ROLL)
            if panel then
                local bestY, v2 = -math.huge, nil
                for _, d in ipairs(panel:GetDescendants()) do
                    if d:IsA("TextLabel") and Shown(d) then
                        local v = ParseAmount(Clean(d))
                        if v and d.AbsolutePosition.Y > bestY then bestY, v2 = d.AbsolutePosition.Y, v end
                    end
                end
                return v2
            end
            return nil
        end
        local function DumpNumbers()
            local n = 0
            for _, d in ipairs(PlayerGui:GetDescendants()) do
                if d:IsA("TextLabel") and Shown(d) and ParseAmount(Clean(d)) then
                    n += 1
                    if n <= 12 then print(("[SmoothHub][Roll] number label %q | %s"):format(Clean(d), d:GetFullName())) end
                end
            end
        end

        -- ---------- หน้าต่าง Blessings ----------
        local function RollButton()
            return FindText(function(t) return t:match("^roll%s*%(") ~= nil end)
        end
        local function RollingLabel()
            return FindText(function(t) return t:match("^rolling") ~= nil end)
        end
        local function RollPrice()
            local lbl = RollButton()
            local inner = lbl and Clean(lbl):match("%(([%d,%.]+%s*[kKmM]?)%)")
            if not inner then return nil end
            return ParseAmount((inner:gsub("%s", "")))
        end
        local function PanelRoot()
            local title = FindText(function(t) return t == "blessings" end)
            if not title then return nil end
            local cur = title.Parent
            for _ = 1, 8 do
                if not cur or cur == PlayerGui then break end
                for _, d in ipairs(cur:GetDescendants()) do
                    if IsText(d) and Clean(d):lower():match("^roll") then return cur end
                end
                cur = cur.Parent
            end
            return title:FindFirstAncestorOfClass("ScreenGui") or PlayerGui
        end
        local function ClosePanel()
            for attempt = 1, 5 do
                local root = PanelRoot()
                if not root then break end
                -- ถ้าได้แค่ ScreenGui ให้ไล่ขึ้นจากหัวข้อ BLESSINGS ไปหากรอบหน้าต่างจริง (กว้างพอ) เพื่อให้หามุมขวาบนของ "หน้าต่าง" ได้ถูก
                if not root:IsA("GuiObject") then
                    local title = FindText(function(t) return t == "blessings" end)
                    local cur = title
                    while cur and cur ~= PlayerGui do
                        if cur:IsA("GuiObject") and cur.AbsoluteSize.X >= 250 and cur.AbsoluteSize.Y >= 300 then root = cur break end
                        cur = cur.Parent
                    end
                end
                local best, bestScore = nil, math.huge
                local rp, rs
                if root:IsA("GuiObject") then
                    rp, rs = root.AbsolutePosition, root.AbsoluteSize
                else
                    rp = Vector2.zero
                    rs = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
                end
                for _, d in ipairs(root:GetDescendants()) do
                    if d:IsA("GuiButton") and Shown(d) then
                        local c = CenterOf(d)
                        local txt = d:IsA("TextButton") and Clean(d):upper() or ""
                        local nm = d.Name:lower()
                        local nameHit = nm:find("close", 1, true) or nm:find("exit", 1, true)
                        local topRight = c.X > rp.X + rs.X - 100 and c.Y < rp.Y + 100 and d.AbsoluteSize.X < 120
                        if nameHit or txt == "X" or topRight then
                            local score = (rp.X + rs.X - c.X) + (c.Y - rp.Y)
                            if nameHit then score = score - 10000 end
                            if score < bestScore then best, bestScore = d, score end
                        end
                    end
                end
                if best then
                    SetStatus("Closing the Blessings window (X)")
                    ClickObj(best, attempt) -- สลับวิธีคลิกทุกรอบ: firesignal > เมาส์เสมือน > ปุ่ม Enter
                end
                task.wait(0.6)
                if not PanelRoot() then break end
            end
        end
        local function OpenPanel()
            if PanelRoot() then return true end
            local npc = RollNpc()
            local pos = npc and NpcPos(npc)
            if not pos then SetStatus("Roll NPC not found (not in wave mode?)") return false end
            for attempt = 1, 3 do
                if not MyRoot() then return false end
                SetStatus(("Going to Roll (%d/3)"):format(attempt))
                MoveTo(CFrame.new(pos + Vector3.new(4, 2, 4), pos))
                task.wait(0.4)
                SetStatus("Pressing E on the machine")
                local prompt = npc:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt and type(fireproximityprompt) == "function" and attempt ~= 2 then
                    pcall(fireproximityprompt, prompt)
                else
                    TapKey(Enum.KeyCode.E, (prompt and prompt.HoldDuration or 0) + 0.2)
                end
                local t0 = os.clock()
                local clicked = false
                while os.clock() - t0 < 4 do
                    task.wait(0.25)
                    if PanelRoot() then return true end
                    -- ถ้าเกมมีบทสนทนาก่อน ให้กดปุ่ม "[E] ..." ของมัน
                    local lbl = FindText(function(t) return t:match("^%[?e%]?%s*roll") ~= nil or t:match("^%[?e%]?%s*blessing") ~= nil end)
                    if lbl and not clicked then
                        SetStatus("Clicking the dialogue button")
                        ClickObj(ButtonFor(lbl), attempt)
                        clicked = true
                        t0 = os.clock() - 2
                    end
                end
            end
            SetStatus("Could not open the Blessings window")
            return false
        end

        local rewardLbl = nil
        local function RewardState()
            if rewardLbl and rewardLbl.Parent then
                local t = Clean(rewardLbl)
                if t:lower():match("^no reward") then return "none" end
                if t ~= "" and Shown(rewardLbl) then return "reward", t end
                return nil
            end
            rewardLbl = nil
            local l = FindText(function(t) return t:match("^no reward") ~= nil end)
            if l then rewardLbl = l return "none" end
            return nil
        end
        -- กด ROLL ซ้ำ ๆ จนเหรียญต่ำกว่าราคา (ยืนยันว่ากดติดจากเหรียญที่ลดลง)
        local function RollLoop()
            local rolls, fails = 0, 0
            rewardLbl = nil
            for _ = 1, MAX_ROLLS do
                if not (Alive() and Cfg.AutoRollBlessing) then return rolls, "off" end
                local root = PanelRoot()
                if not root then return rolls, "closed" end
                local gold = ReadGold(root)
                if gold == nil then return rolls, "nogold" end
                local need = math.max(RollPrice() or 0, ROLL_MIN_GOLD)
                if gold < need then return rolls, "poor" end
                local lbl = RollButton()
                if not lbl then
                    local waited = 0
                    while waited < 10 and Alive() and Cfg.AutoRollBlessing and PanelRoot() and not RollButton() do
                        task.wait(0.5)
                        waited += 0.5
                    end
                    lbl = RollButton()
                    if not lbl then return rolls, (RollingLabel() and "stuck" or "nobutton") end
                    gold = ReadGold(PanelRoot()) or gold
                    if gold < need then return rolls, "poor" end
                end
                if Cfg.RollStopOnMatch then
                    local st, txt = RewardState()
                    if rolls > 0 and st == "reward" then
                        task.wait(0.8) -- เช็กซ้ำกันป้ายเปลี่ยนชั่วคราวระหว่างแอนิเมชัน
                        local st2, txt2 = RewardState()
                        if st2 == "reward" then
                            print("[SmoothHub][Roll] 3 cards matched, reward text: " .. tostring(txt2))
                            return rolls, "match"
                        end
                    end
                end
                SetStatus(("Rolling... #%d (gold %d)"):format(rolls + 1, gold))
                ClickObj(ButtonFor(lbl), fails + 1)
                local t0, spent = os.clock(), false
                while os.clock() - t0 < 4 do
                    task.wait(0.25)
                    local g = ReadGold(PanelRoot())
                    if g and g < gold then spent = true break end
                end
                if spent then
                    rolls += 1
                    fails = 0
                    task.wait(SETTLE)
                else
                    fails += 1
                    if fails >= 3 then return rolls, "stuck" end
                    task.wait(1)
                end
            end
            return rolls, "limit"
        end

        local rolling = false
        local function SetFlag(key, value)
            Cfg[key] = value
            local ctl = Farm.Toggles and Farm.Toggles[key]
            if ctl then pcall(function() ctl.Value = value end) end
        end
        local function RunRoll()
            if rolling then return false end
            Farm.NpcAcquire("Blessing") -- ต่อคิวตามลำดับความสำคัญ (ท้ายสุด ใช้ทองที่เหลือ)
            rolling = true
            local wasFarm, wasThunder = Cfg.AutoFarm, Cfg.AutoFarmThunder
            SetFlag("AutoFarm", false)
            SetFlag("AutoFarmThunder", false)
            local root0 = MyRoot()
            local back = root0 and root0.CFrame
            local rolls, why = 0, nil
            local ok, err = pcall(function()
                if not OpenPanel() then error("open failed", 0) end
                task.wait(0.6)
                rolls, why = RollLoop()
                if why == "match" then
                    SetStatus(("Done: 3 cards matched after %d roll(s). Auto Roll stopped."):format(rolls))
                    SetFlag("AutoRollBlessing", false)
                    Save()
                    pcall(UiSync.Refresh)
                elseif why == "poor" then SetStatus(("Done: rolled %d time(s), gold is below 2,000"):format(rolls))
                elseif why == "stuck" then SetStatus(("Stopped: ROLL did not respond (rolled %d)"):format(rolls))
                elseif why == "nogold" then SetStatus("Stopped: can't read your gold (see F9)")
                elseif why == "nobutton" then SetStatus("Stopped: ROLL button not found")
                else SetStatus(("Done: rolled %d time(s)"):format(rolls)) end
            end)
            if not ok and err ~= "open failed" then
                SetStatus("Error: " .. tostring(err))
                warn("[Smooth Hub] Auto Roll error: " .. tostring(err))
            end
            pcall(ClosePanel)
            local root = MyRoot()
            if root and back then MoveTo(back) end
            if wasFarm then SetFlag("AutoFarm", true) end
            if wasThunder then SetFlag("AutoFarmThunder", true) end
            rolling = false
            Farm.NpcRelease()
            return ok, rolls, why
        end

        -- ---------- ลูปหลัก: เช็ก Gold ทุก 1 วินาที ----------
        task.spawn(function()
            local fails, nextTry, lastDump = 0, 0, 0
            while Alive() do
                task.wait(1)
                if not Cfg.AutoRollBlessing then
                    if not rolling then SetStatus("Off") end
                    fails = 0
                elseif not Farm.CanUseHere() or not RollNpc() then
                    SetStatus("Waiting for wave mode")
                elseif Farm.FailSafeActive then
                    SetStatus("Paused (Fail Safe is losing on purpose)")
                elseif not rolling and not Farm.Refilling and os.clock() >= nextTry and not Farm.RevisitBlock("Blessing") then
                    local gold = ReadGold(nil)
                    if gold == nil then
                        SetStatus("Can't read your gold (see F9)")
                        if os.clock() - lastDump > 30 then
                            lastDump = os.clock()
                            DumpNumbers()
                        end
                    elseif gold < math.max(ROLL_MIN_GOLD, Cfg.WaveMinGold or 0) then
                        SetStatus(("Waiting for gold (%d / %d)"):format(gold, math.max(ROLL_MIN_GOLD, Cfg.WaveMinGold or 0)))
                    else
                        local ok, rolls, why = RunRoll()
                        if ok and ((rolls or 0) > 0 or why == "poor") then
                            fails = 0
                            nextTry = os.clock() + 3
                        else
                            fails += 1
                            nextTry = os.clock() + 8
                            if fails >= 3 then
                                fails = 0
                                nextTry = os.clock() + 60
                            end
                        end
                    end
                end
            end
        end)
    end)
    task.delay(2, function() initializing = false end)
end
do
    local SCAN_INTERVAL = 2.0
    local CHECK_INTERVAL = 0.5
    local PRESS_GAP = 3
    local MAX_PRESSES = 3
    local function CleanText(o)
        local t = (o.Text or ""):gsub("<[^>]->", "")
        t = t:gsub("^%s+", ""):gsub("%s+$", "")
        return t
    end
    local function IsShownGui(obj)
        local cur = obj
        while cur and cur ~= PlayerGui do
            if cur:IsA("GuiObject") and not cur.Visible then return false end
            if cur:IsA("ScreenGui") and not cur.Enabled then return false end
            cur = cur.Parent
        end
        return obj:IsA("GuiObject") and obj.AbsoluteSize.X > 0 and obj.AbsoluteSize.Y > 0
    end
    local function FindReadyLabel(title)
        local cur = title.Parent
        for _ = 1, 6 do
            if not cur or cur == PlayerGui then break end
            for _, d in ipairs(cur:GetDescendants()) do
                if (d:IsA("TextLabel") or d:IsA("TextButton")) and CleanText(d):upper() == "READY" and IsShownGui(d) then
                    return d
                end
            end
            cur = cur.Parent
        end
        return nil
    end
    local function FindCountLabel(title, ready)
        local box = title.Parent
        while box and box ~= PlayerGui and not ready:IsDescendantOf(box) do box = box.Parent end
        if not box or box == PlayerGui then return nil end
        for _, d in ipairs(box:GetDescendants()) do
            if d:IsA("TextLabel") and CleanText(d):match("^%d+%s*/%s*%d+$") and IsShownGui(d) then
                return d
            end
        end
        return nil
    end
    local function ClickableFor(label)
        if label:IsA("GuiButton") then return label end
        local cur = label.Parent
        for _ = 1, 3 do
            if not cur or cur == PlayerGui then break end
            if cur:IsA("GuiButton") then return cur end
            cur = cur.Parent
        end
        local c = label.AbsolutePosition + label.AbsoluteSize / 2
        local best, bestArea = nil, math.huge
        for _, d in ipairs(PlayerGui:GetDescendants()) do
            if d:IsA("GuiButton") and IsShownGui(d) then
                local pos, size = d.AbsolutePosition, d.AbsoluteSize
                if c.X >= pos.X and c.X <= pos.X + size.X and c.Y >= pos.Y and c.Y <= pos.Y + size.Y then
                    local area = size.X * size.Y
                    if area < bestArea then best, bestArea = d, area end
                end
            end
        end
        return best
    end
    local function Press(btn, attempt)
        local method = (attempt - 1) % 3 + 1
        if method == 1 and type(firesignal) ~= "function" then method = 2 end
        if method == 1 then
            pcall(firesignal, btn.Activated)
            pcall(firesignal, btn.MouseButton1Click)
        elseif method == 2 then
            local gui = btn:FindFirstAncestorOfClass("ScreenGui")
            local inset = (gui and gui.IgnoreGuiInset) and Vector2.zero or GuiService:GetGuiInset()
            local pos = btn.AbsolutePosition + btn.AbsoluteSize / 2 + inset
            pcall(function()
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
            end)
        else
            pcall(function() GuiService.SelectedObject = btn end)
            task.wait(0.1)
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
            end)
            task.wait(0.1)
            pcall(function() GuiService.SelectedObject = nil end)
        end
        SH.dbg("[SmoothHub] Auto Ready pressed, method", method)
    end
    local function StartVoter(titleText, cfgKey)
        local titleLabel, scanAt = nil, 0
        local function FindTitle()
            if titleLabel and titleLabel.Parent then
                return IsShownGui(titleLabel) and titleLabel or nil
            end
            titleLabel = nil
            if os.clock() - scanAt < SCAN_INTERVAL then return nil end
            scanAt = os.clock()
            local n = 0
            for _, d in ipairs(PlayerGui:GetDescendants()) do
                n += 1
                if n % 800 == 0 then task.wait() end
                if (d:IsA("TextLabel") or d:IsA("TextButton")) and CleanText(d):upper() == titleText then
                    titleLabel = d
                    return IsShownGui(d) and d or nil
                end
            end
            return nil
        end
        task.spawn(function()
            local presses, lastPress, countBefore, voted = 0, 0, nil, false
            local function Reset() presses, lastPress, countBefore, voted = 0, 0, nil, false end
            while Alive() do
                task.wait(CHECK_INTERVAL)
                if not (Cfg[cfgKey] and SH.PlayOn()) or not Farm.CanUseHere() then
                    Reset()
                else
                    local title = FindTitle()
                    if not title then
                        Reset()
                    else
                        local label = FindReadyLabel(title)
                        if label and not voted then
                            local countLabel = FindCountLabel(title, label)
                            local countText = countLabel and CleanText(countLabel) or nil
                            local a, b
                            if countText then a, b = countText:match("^(%d+)%s*/%s*(%d+)$") end
                            if a and b and tonumber(a) >= tonumber(b) then
                                voted = true
                            elseif presses > 0 and countText and countBefore and countText ~= countBefore then
                                voted = true
                            elseif os.clock() - lastPress >= PRESS_GAP and presses < (countText and MAX_PRESSES or 1) then
                                local btn = ClickableFor(label)
                                if btn then
                                    presses += 1
                                    lastPress = os.clock()
                                    countBefore = countText
                                    Press(btn, presses)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
    StartVoter("VOTE START", "AutoReady")
    StartVoter("VOTE SKIP", "AutoVoteSkip")
    local waveLabel, waveScanAt = nil, 0
    local function WavesCleared()
        if not (waveLabel and waveLabel.Parent) then
            waveLabel = nil
            if os.clock() - waveScanAt < SCAN_INTERVAL then return nil end
            waveScanAt = os.clock()
            local n = 0
            for _, d in ipairs(PlayerGui:GetDescendants()) do
                n += 1
                if n % 800 == 0 then task.wait() end
                if (d:IsA("TextLabel") or d:IsA("TextButton")) and CleanText(d):lower():match("^waves cleared%s*%[%d+%s*/%s*%d+%]") then
                    waveLabel = d
                    break
                end
            end
        end
        if not waveLabel or not IsShownGui(waveLabel) then return nil end
        local a = CleanText(waveLabel):match("%[(%d+)%s*/")
        return a and tonumber(a) or nil
    end
    local postRemote = nil
    local function LeaveMatch()
        if not postRemote or not postRemote.Parent then
            local ok, r = pcall(function()
                return game:GetService("ReplicatedStorage").Assets.Remotes:WaitForChild("POST", 5)
            end)
            postRemote = ok and r or nil
        end
        if not postRemote then return false end
        return (pcall(function() postRemote:FireServer("Functions", "Teleport") end))
    end
    task.spawn(function()
        local firedAt = nil
        while Alive() do
            task.wait(1)
            if not Cfg.AutoLeaveAtWave or not Farm.CanUseHere() then
                firedAt = nil
            else
                local cleared = WavesCleared()
                if not cleared then
                    firedAt = nil
                elseif cleared >= (Cfg.LeaveAtWave or 10) and (not firedAt or os.clock() - firedAt > 15) then
                    firedAt = os.clock()
                    SH.dbg("[SmoothHub] Leave At Wave: waves cleared", cleared)
                    LeaveMatch()
                end
            end
        end
    end)
end
local MiscCategory = Cascade.Components.Section(Window, {
    Title = "Misc",
    Disclosure = false
})
local WebhookTab = MiscCategory:Tab({
    Title = "Webhook",
    Icon = Icon("paperplaneFill", "paperplane", "bellFill"),
})
-- ============================================================
--  🔔 Smooth Hub | Webhook (Discord) - ส่งสรุปรางวัลทุกครั้งที่จบแมตช์
--
--  วิธีวาง:
--   1) ลบบล็อกเดิมที่เป็นหัวข้อว่างๆ นี้ทิ้ง (อยู่ใต้ local WebhookTab = ...):
--        WebhookTab:PageSection({
--            Title = "🔔 Webhook",
--            Subtitle = "Core features and settings"
--        })
--   2) วางไฟล์นี้ทั้งหมด "แทนที่" ตรงนั้น (ก่อนบรรทัด do local HOP_PLACE_ID = game.PlaceId)
--
--  การตั้งค่า (เปิด/ปิด, ลิงก์ Webhook, ยอดสะสม) เก็บในไฟล์แยก SmoothHub/<UserId>/Webhook.json
--  เลยไม่ปนกับ Config และไม่หายตอนเกมวาร์ปไปแมตช์ใหม่ (Auto Retry / Auto Execute)
-- ============================================================
SH.Guard("webhook", function()
    local HttpService = game:GetService("HttpService")
    local TAB = WebhookTab

    local FILE = "Webhook"
    local SEND_DELAY = 1.2      -- รอหลังเจอหน้า MISSION COMPLETED ก่อนอ่านตัวเลข (ส่งเร็วเพื่อไม่ให้ Retry วาร์ปไปก่อน)
    local SESSION_GAP = 600     -- ห่างกันเกินกี่วินาทีถึงเริ่มเซสชันใหม่ (ยอดสะสม/เวลาออนไลน์)

    local W = {
        Enabled = false,
        Url = "",
        SendResultTexts = true,
        Start = 0, LastSeen = 0, Matches = 0, Gold = 0, Gems = 0, Exp = 0,
        CurGold = 0, CurGems = 0, -- ยอด Gold/Gems ล่าสุดที่รู้ (เก็บไว้เพราะในแมตช์ไม่มี Topbar ให้อ่าน)
    }
    SettingsStore.Restore(W, SettingsStore.Load(FILE))

    local function NewSession()
        W.Start, W.LastSeen, W.Matches, W.Gold, W.Gems, W.Exp = os.time(), os.time(), 0, 0, 0, 0
    end
    if W.Start == 0 or os.time() - W.LastSeen > SESSION_GAP then NewSession() end
    local function SaveW()
        W.LastSeen = os.time()
        SettingsStore.Write(FILE, W)
    end

    local PREFIXES = {
        "^https://discord%.com/api/webhooks/",
        "^https://discordapp%.com/api/webhooks/",
        "^https://canary%.discord%.com/api/webhooks/",
        "^https://ptb%.discord%.com/api/webhooks/",
    }
    local function ValidUrl(url)
        url = tostring(url or "")
        for _, p in ipairs(PREFIXES) do
            if url:match(p) then return true end
        end
        return false
    end
    local function GetRequest()
        return (syn and syn.request) or http_request or request or (fluxus and fluxus.request)
    end

    local Status = function() end

    -- ---------- อ่านค่า ----------
    local function ParseNum(s)
        if s == nil then return nil end
        s = tostring(s):gsub(",", ""):gsub("%s", "")
        local n, suf = s:match("^([%d%.]+)([KkMmBb]?)$")
        if not n then return nil end
        n = tonumber(n)
        if not n then return nil end
        local mult = { k = 1e3, m = 1e6, b = 1e9 }
        return n * (mult[(suf or ""):lower()] or 1)
    end
    local function FieldText(key)
        for _, f in ipairs(FIELDS) do
            if f.key == key then return f.last end
        end
        return nil
    end
    local GOLD_PATHS = { "Interface.Topbar.Main.Currencies.Gold.Amount", "Interface.HUD.Main.Top.2.Gold.Title" }
    local GEM_PATHS = { "Interface.Topbar.Main.Currencies.Gems.Amount" }
    local function ReadLive(paths)
        for _, p in ipairs(paths) do
            local ok, t = pcall(ReadGui, p)
            local v = ok and ParseNum(t)
            if v and v > 0 then return v end
        end
        return nil
    end
    -- อ่านค่าจริงจากหน้าจอ (ถ้าอ่านได้ก็จำไว้) ถ้าอ่านไม่ได้ค่อยใช้ยอดที่จำไว้/ค่าจากแท็บ Account
    local function Snapshot()
        local gold, gems = ReadLive(GOLD_PATHS), ReadLive(GEM_PATHS)
        if gold then W.CurGold = gold
        elseif W.CurGold <= 0 then W.CurGold = ParseNum(FieldText("Gold")) or 0 end
        if gems then W.CurGems = gems
        elseif W.CurGems <= 0 then W.CurGems = ParseNum(FieldText("Gems")) or 0 end
        return { gold = gold, gems = gems }
    end
    local function Clock(sec)
        sec = math.max(0, math.floor(sec))
        return ("%02d:%02d:%02d"):format(math.floor(sec / 3600), math.floor(sec % 3600 / 60), sec % 60)
    end
    local function CleanText(o)
        local t = tostring(o.Text or ""):gsub("<[^>]->", "")
        return (t:gsub("^%s+", ""):gsub("%s+$", ""))
    end

    -- อ่านหน้าสรุปแมตช์ แล้วแยกเป็น "Stats" (ชื่อ: ค่า) และ "Obtained" (EXP / Gold / Gems / ไอเท็ม)
    local STAT_DEFS = {
        { "TIME TAKEN", "Time Taken" },
        { "DAMAGE DEALT", "Damage Dealt" },
        { "TITANS KILLED", "Titans Killed" },
        { "CRITICAL HITS", "Critical Hits" },
    }
    local function IsValueText(t)
        return t:match("^[%d,%.]+$") or t:match("^%d+:%d+$") or t:match("^[%d,%.]+[KkMmBb]$")
    end
    local GENERIC = { amount = true, quantity = true, count = true, title = true, label = true, frame = true,
        textlabel = true, text = true, value = true, stack = true, main = true, content = true, holder = true, item = true }
    -- [smooth] Raid support: the Raid result screen says "RAID COMPLETED" instead of "MISSION COMPLETED"
    local RESULT_TITLES = { ["MISSION COMPLETED"] = true, ["RAID COMPLETED"] = true }
    local rTitle, rScanAt = nil, 0
    local function ResultShown()
        if Farm.CompleteScreenShown and Farm.CompleteScreenShown() then return true end
        if rTitle and rTitle.Parent then return IsShown(rTitle) and true or false end
        rTitle = nil
        if os.clock() - rScanAt < 1 then return false end
        rScanAt = os.clock()
        local n = 0
        for _, d in ipairs(PlayerGui:GetDescendants()) do
            n += 1
            if n % 800 == 0 then task.wait() end
            if (d:IsA("TextLabel") or d:IsA("TextButton")) and RESULT_TITLES[CleanText(d):upper()] then
                rTitle = d
                return IsShown(d) and true or false
            end
        end
        return false
    end
    -- [smooth] Reward names: look at attributes, name values, sibling texts, frame / icon names (not just the frame name)
    local NAME_SKIP = { icon = true, image = true, img = true, slot = true, template = true, reward = true, rewards = true,
        obtained = true, itemframe = true, bg = true, background = true, border = true, glow = true, shadow = true,
        scrolling = true, scroll = true, list = true, grid = true, container = true, layout = true, rarity = true, star = true, stars = true }
    local function Pretty(n)
        n = tostring(n):gsub("_", " "):gsub("(%l)(%u)", "%1 %2"):gsub("%s+", " ")
        return (n:gsub("^%s+", ""):gsub("%s+$", ""))
    end
    local function GoodName(n)
        local l = tostring(n):lower():gsub("%d+$", "")
        if l == "" or GENERIC[l] or NAME_SKIP[l] then return false end
        if l:find("^ui") or l:find("layout") or l:find("padding") or l:find("corner") or l:find("stroke") or l:find("gradient") then return false end
        return true
    end
    local function ItemName(lbl, root)
        local a = lbl
        for _ = 1, 4 do
            if not a or a == root then break end
            for _, key in ipairs({ "ItemName", "DisplayName", "Name", "Title", "Item", "ItemId", "Id" }) do
                local v
                pcall(function() v = a:GetAttribute(key) end)
                if type(v) == "string" and v ~= "" then return Pretty(v) end
            end
            for _, c in ipairs(a:GetChildren()) do
                if c:IsA("StringValue") and c.Value ~= "" then
                    local cn = c.Name:lower()
                    if cn:find("name") or cn:find("item") or cn:find("title") then return Pretty(c.Value) end
                end
                if c:IsA("TextLabel") and c ~= lbl then
                    local t = CleanText(c)
                    if t ~= "" and #t <= 40 and not IsValueText(t) and not t:match("^[IVX]+$") then return t end
                end
            end
            if a ~= lbl and GoodName(a.Name) then return Pretty(a.Name) end
            if a ~= lbl then
                for _, c in ipairs(a:GetChildren()) do
                    if (c:IsA("ImageLabel") or c:IsA("ImageButton")) and GoodName(c.Name) then return Pretty(c.Name) end
                end
            end
            a = a.Parent
        end
        return nil
    end
    local function ReadResult()
        local title, n = nil, 0
        for _, d in ipairs(PlayerGui:GetDescendants()) do
            n += 1
            if n % 800 == 0 then task.wait() end
            if (d:IsA("TextLabel") or d:IsA("TextButton")) and RESULT_TITLES[CleanText(d):upper()] and IsShown(d) then
                title = d
                break
            end
        end
        if not title then return nil end
        local root = title
        for _ = 1, 4 do
            if root.Parent and root.Parent ~= PlayerGui then root = root.Parent end
        end

        local labels = {}
        for _, d in ipairs(root:GetDescendants()) do
            if d:IsA("TextLabel") and IsShown(d) then
                labels[#labels + 1] = { obj = d, text = CleanText(d) }
            end
        end

        -- Stats: หาป้ายชื่อ แล้วหาค่าที่อยู่แถวเดียวกัน
        local stats, used = {}, {}
        for _, def in ipairs(STAT_DEFS) do
            for _, e in ipairs(labels) do
                if e.text:upper() == def[1] then
                    local a = e.obj.Parent
                    for _ = 1, 3 do
                        if not a or a == root.Parent then break end
                        local found
                        for _, o in ipairs(a:GetDescendants()) do
                            if o ~= e.obj and o:IsA("TextLabel") and IsShown(o) and not used[o] and IsValueText(CleanText(o)) then
                                found = o
                                break
                            end
                        end
                        if found then
                            used[found] = true
                            stats[#stats + 1] = { name = def[2], text = CleanText(found) }
                            break
                        end
                        a = a.Parent
                    end
                    break
                end
            end
        end

        -- Obtained: ตัวเลข/เลขโรมันที่เหลือ คือจำนวนของรางวัลแต่ละช่อง
        local cands = {}
        for _, e in ipairs(labels) do
            if not used[e.obj] and (IsValueText(e.text) or e.text:match("^[IVX]+$")) then
                local names, best = {}, nil
                local a = e.obj
                for _ = 1, 4 do
                    if not a or a == root then break end
                    names[#names + 1] = a.Name:lower()
                    if not best and a ~= e.obj and not GENERIC[a.Name:lower()] then best = a.Name end
                    if a ~= e.obj then
                        for _, c in ipairs(a:GetChildren()) do
                            if c:IsA("ImageLabel") or c:IsA("ImageButton") then names[#names + 1] = c.Name:lower() end
                        end
                    end
                    a = a.Parent
                end
                local p = e.obj.AbsolutePosition
                local nm = ItemName(e.obj, root)
                if not nm and not (e.text:match("^[IVX]+$")) then
                    -- [smooth] could not find a name: print the path to F9 so it can be added
                    local path, q = {}, e.obj
                    for _ = 1, 5 do
                        if not q or q == root then break end
                        path[#path + 1] = q.ClassName .. ":" .. q.Name
                        q = q.Parent
                    end
                    print("[Smooth Hub] Reward name not found for '" .. e.text .. "': " .. table.concat(path, " < "))
                end
                cands[#cands + 1] = { text = e.text, names = table.concat(names, " "), best = best, name = nm, x = p.X, y = p.Y }
            end
        end
        table.sort(cands, function(a, b)
            if math.abs(a.y - b.y) > 20 then return a.y < b.y end
            return a.x < b.x
        end)

        local items, got = {}, {}
        for _, c in ipairs(cands) do
            local kind = "other"
            if c.names:find("gold") or c.names:find("coin") then kind = "gold"
            elseif c.names:find("exp") then kind = "exp"
            elseif c.names:find("gem") then kind = "gems" end
            if kind ~= "other" then got[kind] = true end
            items[#items + 1] = { kind = kind, name = c.name or (c.best and Pretty(c.best)) or "Item", text = c.text, num = ParseNum(c.text) }
        end
        -- ถ้าอ่านชื่อไม่ได้ ใช้ลำดับช่องตามหน้าจอจริง: ช่อง 1 = EXP, ช่อง 2 = Gold
        if not got.exp and not got.gold and #items >= 2 and items[1].num and items[2].num then
            items[1].kind, items[2].kind = "exp", "gold"
        end
        local raw, seenRaw = {}, {}
        for _, e in ipairs(labels) do
            local up = e.text:upper()
            if #e.text >= 1 and #e.text <= 40 and not seenRaw[e.text] and up ~= "MISSION COMPLETED" and up ~= "RAID COMPLETED" and up ~= "LEAVE"
                and up ~= "MODIFIERS" and up ~= "STATS" and up ~= "OBTAINED" and not up:match("^STARTING") then
                seenRaw[e.text] = true
                raw[#raw + 1] = e.text
            end
        end
        return { stats = stats, items = items, raw = raw }
    end

        -- ---------- สร้างข้อความ Discord ----------
    local function BuildEmbed(now, gain, res, isTest)
        gain = gain or {}
        local rewards = {}
        local function Add(g, name, total)
            if g and g > 0 then
                rewards[#rewards + 1] = ("+ %s %s (รอบที่ %d)"):format(Fmt(g), name, W.Matches)
                if total then rewards[#rewards + 1] = ("+ %s %s (สะสมทั้งหมด)"):format(Fmt(total), name) end
            end
        end
        Add(gain.gold, "Golds", W.Gold)
        Add(gain.gems, "Gems", W.Gems)
        Add(gain.exp, "EXP", W.Exp)
        if res then
            for _, it in ipairs(res.items) do
                if it.kind == "other" then
                    rewards[#rewards + 1] = ("+ %s %s (รอบที่ %d)"):format(it.name, it.text, W.Matches)
                end
            end
        end
        if #rewards == 0 then
            rewards[1] = isTest and "(ข้อความทดสอบ)" or "ไม่พบรางวัลในหน้าสรุปผล"
            rewards[2] = ("(รอบที่ %d)"):format(W.Matches)
        end

        local goldText = W.CurGold > 0 and Fmt(W.CurGold) or "N/A"
        local gemsText = W.CurGems > 0 and Fmt(W.CurGems) or "N/A"
        local desc = table.concat({
            "💰 `Golds  : " .. goldText .. "`",
            "💎 `Gems   : " .. gemsText .. "`",
            "⚡ `Level  : " .. (FieldText("Level") or "N/A") .. "`",
            "⏱️ `Online : " .. Clock(os.time() - W.Start) .. "`",
        }, "\n")

        local fields = {
            { name = "⭐ Rewards", value = "```diff\n" .. table.concat(rewards, "\n") .. "\n```", inline = false },
        }
        if W.SendResultTexts and res and #res.stats > 0 then
            local lines = {}
            for _, st in ipairs(res.stats) do
                lines[#lines + 1] = ("%-14s : %s"):format(st.name, st.text)
            end
            fields[#fields + 1] = { name = "📊 Stats", value = "```\n" .. table.concat(lines, "\n") .. "\n```", inline = false }
        end

        if W.SendResultTexts and res and #res.stats == 0 and #res.items == 0 and res.raw and #res.raw > 0 then
            fields[#fields + 1] = { name = "🧾 Result screen", value = "```\n" .. table.concat(res.raw, "\n"):sub(1, 900) .. "\n```", inline = false }
        end

        return {
            username = "Smooth Hub",
            embeds = { {
                title = "Username: " .. LocalPlayer.Name,
                description = desc,
                color = isTest and 0x5865F2 or 0x57F287,
                fields = fields,
                thumbnail = { url = ("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=150&height=150&format=png"):format(LocalPlayer.UserId) },
                footer = { text = "Smooth Hub | AOTR" .. (isTest and " | TEST" or "") },
                timestamp = DateTime.now():ToIsoDate(),
            } },
        }
    end

        local function PostJson(payload)
        local req = GetRequest()
        if not req then return false, "executor has no http request" end
        if not ValidUrl(W.Url) then return false, "invalid webhook link" end
        local ok, res = pcall(req, {
            Url = W.Url,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(payload),
        })
        if not ok then return false, tostring(res) end
        local code = type(res) == "table" and (res.StatusCode or res.Status) or nil
        if code and code >= 200 and code < 300 then return true, "HTTP " .. tostring(code) end
        return false, "HTTP " .. tostring(code)
    end

    -- ---------- ส่งผลหลังจบแมตช์ ----------
    local baseline = {}
    local sending = false
    local function SendMatch()
        if sending then return end
        sending = true
        -- อ่านทันทีที่เจอหน้าจอ (โหมด Raid หน้านี้หายเร็ว) แล้วรออีกนิดอ่านซ้ำ เลือกอันที่ได้ข้อมูลมากกว่า
        local res
        local function Count(r) return r and (#r.stats + #r.items) or -1 end
        pcall(function() res = ReadResult() end)
        task.wait(SEND_DELAY)
        local now = Snapshot()
        pcall(function()
            local r2 = ReadResult()
            if Count(r2) >= Count(res) and r2 then res = r2 end
        end)
        local gain = {}
        if res then
            for _, it in ipairs(res.items) do
                if it.num and (it.kind == "gold" or it.kind == "gems" or it.kind == "exp") then
                    gain[it.kind] = (gain[it.kind] or 0) + it.num
                end
            end
        end
        -- ถ้าหน้าสรุปไม่บอก Gold/Gems ใช้ส่วนต่างจาก HUD แทน
        if not gain.gold and baseline.gold and now.gold then gain.gold = now.gold - baseline.gold end
        if not gain.gems and baseline.gems and now.gems then gain.gems = now.gems - baseline.gems end
        W.Matches += 1
        if gain.gold and gain.gold > 0 then W.Gold += gain.gold end
        if gain.gems and gain.gems > 0 then W.Gems += gain.gems end
        if gain.exp and gain.exp > 0 then W.Exp += gain.exp end
        -- ยอดรวมปัจจุบัน: ถ้าอ่านจริงไม่ได้ ใช้ยอดที่จำไว้ + ที่ได้รอบนี้
        if not now.gold and gain.gold and gain.gold > 0 and W.CurGold > 0 then W.CurGold += gain.gold end
        if not now.gems and gain.gems and gain.gems > 0 and W.CurGems > 0 then W.CurGems += gain.gems end
        SaveW()

        local ok, msg = PostJson(BuildEmbed(now, gain, res, false))
        Status(ok and ("Sent (match " .. W.Matches .. ")") or ("Send failed: " .. tostring(msg)))
        baseline = { gold = now.gold, gems = now.gems }
        sending = false
    end

        task.spawn(function()
        local shownSince, goneSince, sent, lastSave = nil, nil, false, 0
        while Alive() do
            task.wait(0.3)
            if not W.Enabled or not Farm.CanUseHere() then
                shownSince, goneSince, sent = nil, nil, false
                baseline = {}
            else
                if os.clock() - lastSave >= 30 then lastSave = os.clock() SaveW() end
                local shown = ResultShown()
                if shown then
                    goneSince = nil
                    shownSince = shownSince or os.clock()
                    if not sent and os.clock() - shownSince >= 0.5 then
                        sent = true
                        task.spawn(SendMatch)
                    end
                else
                    shownSince = nil
                    goneSince = goneSince or os.clock()
                    if os.clock() - goneSince >= 3 then sent = false end
                    -- เก็บค่าตั้งต้นก่อนจบแมตช์ (เติมเฉพาะค่าที่ยังอ่านไม่ได้)
                    local snap = Snapshot()
                    if baseline.gold == nil then baseline.gold = snap.gold end
                    if baseline.gems == nil then baseline.gems = snap.gems end
                end
            end
        end
    end)

    -- ---------- UI ----------
    if not TAB then
        local cat = Cascade.Components.Section(Window, { Title = "Misc", Disclosure = false })
        TAB = cat:Tab({ Title = "Webhook", Icon = Icon("paperplaneFill", "bellFill", "boltFill") })
    end

    local Form = TAB:PageSection({
        Title = "🔔 Webhook",
        Subtitle = "Sends a reward summary to Discord every time a match ends (MISSION COMPLETED screen).",
    }):Form()

    local function SetStatus(text) if Status then Status(text) end end

    local onRow = Form:Row()
    onRow:Left():TitleStack({ Title = "Enable Webhook", Subtitle = "Post to Discord when a match ends. Needs a valid Webhook URL." })
    UiSync.Link(onRow:Right():Toggle({
        Value = W.Enabled,
        ValueChanged = function(self, value)
            W.Enabled = value and true or false
            SaveW()
            if W.Enabled and not ValidUrl(W.Url) then SetStatus("Set a valid Webhook URL first") end
        end
    }), W, "Enabled")

    local statusRow = Form:Row()
    statusRow:Left():TitleStack({ Title = "Webhook Status", Subtitle = "Result of the last send." })
    local statusLabel = statusRow:Right():Label({ Text = "Idle" })
    Status = function(text) pcall(function() statusLabel.Text = tostring(text) end) end

    local function SetUrl(text, save)
        W.Url = (tostring(text or ""):gsub("%s", ""))
        if save then SaveW() end
    end

    local urlRow = Form:Row()
    urlRow:Left():TitleStack({ Title = "Webhook URL", Subtitle = "Discord: Server Settings > Integrations > Webhooks > Copy URL. Keep it private." })
    local okField, field = pcall(function()
        return urlRow:Right():TextField({
            Placeholder = "https://discord.com/api/webhooks/...",
            Value = W.Url,
            TextChanged = function(self, text) SetUrl(text, false) end,
            ValueChanged = function(self, value) SetUrl(value, true) end,
        })
    end)
    if okField and field then
        pcall(function() UiSync.Link(field, W, "Url") end)
    end

    local testRow = Form:Row()
    testRow:Left():TitleStack({ Title = "Send Test", Subtitle = "Send one test message now." })
    local testBtn = testRow:Right():Button({ Label = "Test", Callback = function() end })
    BindButton(testBtn, function()
        pcall(function() -- ใช้ค่าที่เห็นในช่องตอนนี้ (กันกรณีค่าในช่องยังไม่ถูกซิงค์เข้า W.Url)
            if okField and field and type(field.Value) == "string" and ValidUrl(field.Value:gsub("%s", "")) then
                SetUrl(field.Value, false)
            end
        end)
        SaveW()
        Status("Sending...")
        local ok, msg = PostJson(BuildEmbed(Snapshot(), {}, nil, true))
        Status(ok and "Test sent" or ("Test failed: " .. tostring(msg)))
    end)
end)

do
local HOP_PLACE_ID = game.PlaceId
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local HubConfig = {
    InfiniteJump = false,
    AntiAFK = true,
    AutoRejoin = true,
    AntiAdmin = true,
    AutoExecute = false,
    CharacterRGB = false,
    EnableFPSLock = false,
    FPSLimit = 144,
    AutoDeleteMap = false,
    AutoHideMenu = false,
}
for key, value in pairs(HubConfig) do UiSync.Defaults.Hub[key] = value end
ConfigStore.BuildDefault(UiSync.Defaults.Hub)
SettingsStore.Restore(HubConfig, SavedData.Hub)
ConfigStore.ApplyHub(HubConfig, ConfigStore.AutoloadSnapshot())
if SH.LegacyHub then ConfigStore.ApplyHub(HubConfig, { Hub = SH.LegacyHub }) end
SH.say("Settings loaded.")
local AUTOEXEC_URL = "https://githubusercontent.smoothhubv1.workers.dev/raw/9949e6715b89f8c1d7b1/Attack-on-Titan-Revolution.lua"
UiSync.ReloadUrl = AUTOEXEC_URL
local queueTeleport = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
local AUTOEXEC_LOCK = "SmoothHub/AutoExec.lock"
local AUTOEXEC_LOG = "SmoothHub/AutoExec.log"
local function AutoExecLog(text)
    if not SH.DEV then return end
    pcall(function()
        if type(makefolder) == "function" and type(isfolder) == "function" and not isfolder("SmoothHub") then
            makefolder("SmoothHub")
        end
        local line = tostring(os.time()) .. " place=" .. tostring(game.PlaceId) .. " " .. text .. "\n"
        if type(appendfile) == "function" then
            appendfile(AUTOEXEC_LOG, line)
        elseif type(writefile) == "function" then
            writefile(AUTOEXEC_LOG, line)
        end
    end)
end
local function QueueAutoExecute()
    if type(queueTeleport) ~= "function" then
        AutoExecLog("queue_on_teleport not supported by this executor")
        return false
    end
    local AUTOEXEC_KEY_NOW = "SmoothHub-1293F5A9B3D92637A16077A0" -- คีย์สำรอง ใช้เมื่อไม่พบ script_key ของรอบนี้
    pcall(function()
        local cur = (getgenv and getgenv().script_key) or script_key
        if type(cur) == "string" and cur ~= "" then AUTOEXEC_KEY_NOW = cur end
    end)
    local payload = string.format([[
        local LOG = %q
        local LOCK = %q
        local function log(text)
            if true then return end
            pcall(function()
                if type(makefolder) == "function" and type(isfolder) == "function" and not isfolder("SmoothHub") then makefolder("SmoothHub") end
                local line = tostring(os.time()) .. " place=" .. tostring(game.PlaceId) .. " [queued] " .. text .. "\n"
                if type(appendfile) == "function" then appendfile(LOG, line)
                elseif type(writefile) == "function" then writefile(LOG, line) end
            end)
        end
        log("started")
        if not game:IsLoaded() then game.Loaded:Wait() end
        local Players = game:GetService("Players")
        while not Players.LocalPlayer do task.wait() end
        local run = true
        pcall(function()
            if type(isfile) == "function" and isfile(%q) then
                local data = game:GetService("HttpService"):JSONDecode(readfile(%q))
                if type(data) == "table" and type(data.Hub) == "table" and data.Hub.AutoExecute == false then run = false end
            end
        end)
        if not run then log("skipped (Auto Execute is off)") return end
        local jobId = tostring(game.JobId)
        pcall(function()
            if jobId ~= "" and type(isfile) == "function" and isfile(LOCK) then
                local id, t = tostring(readfile(LOCK)):match("^(.-)|(%%d+)$")
                if id == jobId and t and os.time() - tonumber(t) < 20 then run = false end
            end
        end)
        if not run then log("skipped (already started in this server)") return end
        pcall(function() writefile(LOCK, jobId .. "|" .. tostring(os.time())) end)
        local KEY = %q
        pcall(function() if getgenv then getgenv().script_key = KEY end end)
        script_key = KEY
        local src, err
        for i = 1, 5 do
            local ok, res = pcall(function() return game:HttpGet(%q) end)
            if ok and type(res) == "string" and #res > 0 then src = res break end
            err = res
            task.wait(1)
        end
        if not src then log("download failed: " .. tostring(err)) return end
        local fn, cerr = loadstring(src)
        if not fn then log("compile failed: " .. tostring(cerr)) return end
        local ok, rerr = pcall(fn)
        log(ok and "script started" or ("script error: " .. tostring(rerr)))
    ]], AUTOEXEC_LOG, AUTOEXEC_LOCK, SettingsStore.Path("AOTR"), SettingsStore.Path("AOTR"), AUTOEXEC_KEY_NOW, AUTOEXEC_URL)
    local ok, err = pcall(queueTeleport, payload)
    AutoExecLog(ok and "queued" or ("queue failed: " .. tostring(err)))
    return ok
end
local function ApplyAutoExecute(on)
    if on then
        SettingsStore.Flush("AOTR")
        QueueAutoExecute()
    elseif type(clear_teleport_queue) == "function" then
        pcall(clear_teleport_queue)
    end
end
if HubConfig.AutoExecute then QueueAutoExecute() end
if type(queueTeleport) == "function" then
    local lastQueuedAt = 0
    pcall(function()
        LocalPlayer.OnTeleport:Connect(function(state)
            if not Alive() or not HubConfig.AutoExecute then return end
            if os.clock() - lastQueuedAt < 5 then return end
            lastQueuedAt = os.clock()
            AutoExecLog("teleport started (" .. tostring(state) .. ") - re-queue")
            if type(clear_teleport_queue) == "function" then pcall(clear_teleport_queue) end
            QueueAutoExecute()
        end)
    end)
end
local function HopServer()
    pcall(function()
        local servers = {}
        local req = game:HttpGet("https://games.roblox.com/v1/games/" .. HOP_PLACE_ID .. "/servers/Public?sortOrder=Asc&limit=100")
        local body = HttpService:JSONDecode(req)
        if body and body.data then
            for _, sv in ipairs(body.data) do
                if type(sv) == "table" and sv.id ~= game.JobId and sv.playing < sv.maxPlayers then
                    table.insert(servers, sv.id)
                end
            end
        end
        if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(HOP_PLACE_ID, servers[math.random(1, #servers)], LocalPlayer)
        else
            TeleportService:Teleport(HOP_PLACE_ID, LocalPlayer)
        end
    end)
end
local SettingsCategory = Cascade.Components.Section(Window, {
    Title = "Settings\u{200B}",
    Disclosure = false
})
local AdvancedTab, ServerTab, SettingsTab, ConfigTab
do
AdvancedTab = SettingsCategory:Tab({
    Title = "Advanced",
    Icon = Icon("gearshapeFill", "gearshape")
})
local AdvSection = AdvancedTab:PageSection({
    Title = "⚙️ Advanced Settings",
    Subtitle = "Configure advanced player modifications and tools.",
})
local AdvForm = AdvSection:Form()
local function AddToggle(form, title, subtitle, key, onChange)
    local row = form:Row()
    row:Left():TitleStack({ Title = title, Subtitle = subtitle })
    UiSync.Link(row:Right():Toggle({
        Value = HubConfig[key],
        ValueChanged = function(self, value)
            HubConfig[key] = value and true or false
            if onChange then onChange(value) end
        end
    }), HubConfig, key)
end
AddToggle(AdvForm, "Infinite Jump", "Allow your character to jump infinitely in the air.", "InfiniteJump")
AddToggle(AdvForm, "Anti-AFK", "Prevent being kicked out of the game due to inactivity.", "AntiAFK")
AddToggle(AdvForm, "Auto Rejoin", "Automatically rejoin the game if disconnected or kicked.", "AutoRejoin")
AddToggle(AdvForm, "Anti Admin", "Automatically server hop if an admin joins the game.", "AntiAdmin")
AddToggle(AdvForm,
    "Auto Execute",
    type(queueTeleport) == "function" and "Run the script again after teleporting or rejoining a server."
        or "Not supported by your executor.",
    "AutoExecute",
    ApplyAutoExecute)
AddToggle(AdvForm, "Auto Hide Menu", "Hide the menu automatically when the script runs. Tap the logo button or press the hotkey to open it.", "AutoHideMenu")
local CharRGB = {}
do
    local RunService = game:GetService("RunService")
    local hl, conn = nil, nil
    local function Remove()
        if hl then pcall(function() hl:Destroy() end) hl = nil end
    end
    function CharRGB.Apply(on)
        if not on then Remove() end
    end
    conn = RunService.Heartbeat:Connect(function()
        if not Alive() then
            Remove()
            if conn then conn:Disconnect() conn = nil end
            return
        end
        local char = LocalPlayer.Character
        if not (HubConfig.CharacterRGB and char) then
            if hl then Remove() end
            return
        end
        if not (hl and hl.Parent and hl.Adornee == char) then
            Remove()
            local ok, obj = pcall(function()
                local h = Instance.new("Highlight")
                h.Name = "SmoothHubCharacterRGB"
                h.Adornee = char
                h.FillTransparency = 1
                h.OutlineTransparency = 0
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                h.Parent = char
                return h
            end)
            if ok then hl = obj end
        end
        if hl then hl.OutlineColor = Color3.fromHSV((os.clock() * 0.4) % 1, 1, 1) end
    end)
end
AddToggle(AdvForm, "Character [ RGB ]", "Rainbow outline around your character.", "CharacterRGB", CharRGB.Apply)
-- [smooth] runs immediately (no 1.5s wait) and never overrides a menu the user already opened/closed
if Alive() and not SH.MenuTouched then
    if HubConfig.AutoHideMenu then
        if not SH.MenuEarlyHidden then pcall(function() Window.Minimized = true end) end
    elseif SH.MenuEarlyHidden then
        pcall(function() Window.Minimized = false end) -- autoload config turned Auto Hide off
    end
end
local Fps = {}
Farm.Fps = Fps
do
    local RunService = game:GetService("RunService")
    local SOFT_MAX = 240
    local candidates = {
        setfpscap, set_fps_cap, setfps,
        syn and syn.set_fps_cap, fluxus and fluxus.set_fps_cap,
    }
    local names = { "setfpscap", "set_fps_cap", "setfps", "syn.set_fps_cap", "fluxus.set_fps_cap" }
    local native, nativeName = nil, nil
    for i = 1, 5 do
        if type(candidates[i]) == "function" then native, nativeName = candidates[i], names[i] break end
    end
    Fps.Native = nativeName
    local function DesiredOn() return HubConfig.EnableFPSLock and true or false end
    local function DesiredLimit() return math.clamp(math.floor(tonumber(HubConfig.FPSLimit) or 144), 1, 9999) end
    Fps.Mode = "off"
    Fps.Measured = 0
    local applied = { on = DesiredOn(), limit = DesiredLimit() }
    local softConn = nil
    local function StopSoft()
        if softConn then softConn:Disconnect() softConn = nil end
    end
    local function StartSoft(limit)
        StopSoft()
        local frameTime = 1 / limit
        local last = os.clock()
        local conn
        conn = RunService.RenderStepped:Connect(function()
            if not Alive() then conn:Disconnect() return end
            local target = last + frameTime
            while os.clock() < target do end
            last = os.clock()
        end)
        softConn = conn
    end
    function Fps.Apply()
        local on, limit = DesiredOn(), DesiredLimit()
        StopSoft()
        if on then
            if native then
                pcall(native, limit)
                Fps.Mode = "native"
            elseif limit >= 9999 then
                Fps.Mode = "off"
            elseif limit <= SOFT_MAX then
                StartSoft(limit)
                Fps.Mode = "software"
            else
                Fps.Mode = "unsupported"
            end
        else
            if native then pcall(native, 9999) end
            Fps.Mode = "off"
        end
        applied.on, applied.limit = on, limit
    end
    function Fps.Reassert()
        local on, limit = DesiredOn(), DesiredLimit()
        if on ~= applied.on or limit ~= applied.limit then
            Fps.Apply()
        elseif on and Fps.Mode == "native" then
            pcall(native, limit)
        end
    end
    local frames, lastT = 0, os.clock()
    local counter
    counter = RunService.RenderStepped:Connect(function()
        if not Alive() then counter:Disconnect() return end
        frames += 1
    end)
    task.spawn(function()
        while Alive() do
            task.wait(0.5)
            local now = os.clock()
            local dt = now - lastT
            if dt > 0 then Fps.Measured = frames / dt end
            frames, lastT = 0, now
            if Fps.OnUpdate then pcall(Fps.OnUpdate, Fps.Measured, Fps.Mode, Fps.Native) end
        end
    end)
    if DesiredOn() then Fps.Apply() end
end
local FpsSection = AdvancedTab:PageSection({
    Title = "🖥️ FPS",
    Subtitle = "Limit the frame rate of the game."
})
local FpsForm = FpsSection:Form()
AddToggle(FpsForm, "Enable FPS Lock", "Toggle frame rate limiting on or off.", "EnableFPSLock", function(value)
    Fps.Apply()
end)
local FpsMenuRow = FpsForm:Row()
FpsMenuRow:Left():TitleStack({
    Title = "FPS Limit Preset",
    Subtitle = "Choose target frame rate limit."
})
local fpsOptions = { "15 FPS", "30 FPS", "60 FPS", "120 FPS", "144 FPS", "240 FPS", "500 FPS", "1000 FPS", "9999 (Unlimited)" }
local fpsValues = { 15, 30, 60, 120, 144, 240, 500, 1000, 9999 }
local fpsDefaultIndex = table.find(fpsValues, HubConfig.FPSLimit) or 5
local FpsBtn = FpsMenuRow:Right():PullDownButton({
    Label = fpsOptions[fpsDefaultIndex],
    Options = fpsOptions,
    Value = fpsDefaultIndex,
    ValueChanged = function(self, index)
        local target = fpsValues[index]
        HubConfig.FPSLimit = target
        self.Label = fpsOptions[index]
        if HubConfig.EnableFPSLock then Fps.Apply() end
    end
})
StyleDropdown(FpsBtn)
UiSync.Add(function()
    local i = table.find(fpsValues, HubConfig.FPSLimit) or 5
    FpsBtn.Value = i
    FpsBtn.Label = fpsOptions[i]
end)
local FpsStatusRow = FpsForm:Row()
local FpsStatusStack = FpsStatusRow:Left():TitleStack({
    Title = "Current FPS ( -- )",
    Subtitle = "Measured live so you can see whether the lock is working."
})
Fps.OnUpdate = function(fps, mode, nativeName)
    local text
    if mode == "native" then
        text = "Locked at " .. tostring(HubConfig.FPSLimit) .. " FPS using " .. tostring(nativeName) .. "."
    elseif mode == "software" then
        text = "Locked at " .. tostring(HubConfig.FPSLimit) .. " FPS by the built-in limiter (your executor has no FPS cap function)."
    elseif mode == "unsupported" then
        text = "Can't lock above 240 FPS: your executor has no FPS cap function."
    else
        text = "Lock is off." .. (nativeName and (" Executor supports " .. nativeName .. ".") or " Executor has no FPS cap function (built-in limiter will be used up to 240 FPS).")
    end
    pcall(function()
        FpsStatusStack.Title = "Current FPS ( " .. tostring(math.floor(fps + 0.5)) .. " )"
        FpsStatusStack.Subtitle = text
    end)
end
local MapCleaner = {}
Farm.MapCleaner = MapCleaner
do
    local KEEP_ABOVE = 6
    local busy = false
    local function GroundY()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local titans = workspace:FindFirstChild("Titans")
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        local ignore = {}
        if char then ignore[#ignore + 1] = char end
        if titans then ignore[#ignore + 1] = titans end
        params.FilterDescendantsInstances = ignore
        local best = nil
        local function sample(pos)
            local hit = workspace:Raycast(pos, Vector3.new(0, -3000, 0), params)
            if hit and (not best or hit.Position.Y < best) then best = hit.Position.Y end
        end
        if root then sample(root.Position) end
        if titans then
            local n = 0
            for _, t in ipairs(titans:GetChildren()) do
                local r = t:FindFirstChild("HumanoidRootPart")
                if r then
                    sample(r.Position)
                    n += 1
                    if n >= 6 then break end
                end
            end
        end
        return best
    end
    function MapCleaner.Run()
        if busy then return false, "Already running..." end
        busy = true
        local okCall, ok, text = pcall(function()
            local groundY = GroundY()
            if not groundY then return false, "Can't find the ground - stand on the map first" end
            local limit = groundY + KEEP_ABOVE
            local roots = {}
            roots[workspace.Terrain] = true
            if workspace.CurrentCamera then roots[workspace.CurrentCamera] = true end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Character then roots[plr.Character] = true end
            end
            for _, name in ipairs({ "Titans", "Debris" }) do
                local f = workspace:FindFirstChild(name)
                if f then roots[f] = true end
            end
            local function Protected(node)
                if roots[node] then return true end
                local n = node.Name
                if n == "Refill" or n == "Spears" then return true end
                if node:IsA("SpawnLocation") or node:IsA("ProximityPrompt") or node:IsA("ClickDetector") or node:IsA("Humanoid") then return true end
                if node:IsA("Model") and node:FindFirstChildOfClass("Humanoid") then return true end
                return false
            end
            local visited, toDestroy = 0, {}
            local function Plan(node)
                visited += 1
                if visited % 1500 == 0 then task.wait() end
                if Protected(node) then return true end
                local keepSelf = false
                if node:IsA("BasePart") then
                    keepSelf = (node.Position.Y + node.Size.Y / 2) <= limit
                end
                local children = node:GetChildren()
                local flags, anyKept = {}, false
                for i, c in ipairs(children) do
                    local f = Plan(c)
                    flags[i] = f
                    if f then anyKept = true end
                end
                if not (keepSelf or anyKept) then return false end
                for i, c in ipairs(children) do
                    if not flags[i] then toDestroy[#toDestroy + 1] = c end
                end
                return true
            end
            for _, child in ipairs(workspace:GetChildren()) do
                if not Plan(child) then toDestroy[#toDestroy + 1] = child end
            end
            for i, inst in ipairs(toDestroy) do
                pcall(function() inst:Destroy() end)
                if i % 50 == 0 then task.wait() end
            end
            pcall(function()
                local lighting = game:GetService("Lighting")
                lighting.GlobalShadows = false
                for _, e in ipairs(lighting:GetChildren()) do
                    if e:IsA("PostEffect") then e.Enabled = false end
                end
            end)
            return true, ("Deleted %d map objects (scanned %d). Rejoin to get the map back."):format(#toDestroy, visited)
        end)
        busy = false
        if not okCall then return false, "Error: " .. tostring(ok) end
        return ok, text
    end
end
function Farm.DeleteMap()
    task.spawn(function()
        if MapCleaner.OnResult then MapCleaner.OnResult("Deleting the map...") end
        local _, text = MapCleaner.Run()
        if MapCleaner.OnResult then MapCleaner.OnResult(text or "") end
    end)
end
task.spawn(function()
    local since, lastDone = nil, 0
    while Alive() do
        task.wait(1)
        if HubConfig.AutoDeleteMap and Farm.CanUseHere and Farm.CanUseHere() then
            since = since or os.clock()
            if os.clock() - since >= 10 and os.clock() - lastDone >= 30 then
                lastDone = os.clock()
                Farm.DeleteMap()
            end
        else
            since = nil
        end
    end
end)
local DelMapRow = FpsForm:Row()
local DelMapStack = DelMapRow:Left():TitleStack({
    Title = "Delete Map",
    Subtitle = "Removes buildings, trees and walls on YOUR screen only, to cut lag. Rejoin to get the map back."
})
local DelMapRun
local DelMapBtn = DelMapRow:Right():Button({
    Label = "Delete",
    Callback = function() if DelMapRun then DelMapRun() end end
})
DelMapRun = BindButton(DelMapBtn, function() Farm.DeleteMap() end)
MapCleaner.OnResult = function(text)
    pcall(function() DelMapStack.Subtitle = text end)
end
AddToggle(FpsForm, "Auto Delete Map", "Deletes the map by itself every time you are in a mission.", "AutoDeleteMap")
end
do
ServerTab = SettingsCategory:Tab({
    Title = "Server",
    Icon = Icon("globe", "network")
})
local ServerInfoSection = ServerTab:PageSection({
    Title = "🌐 Server Information",
    Subtitle = "Display current server details and identifiers."
})
local ServerInfoForm = ServerInfoSection:Form()
local GameIdRow = ServerInfoForm:Row()
GameIdRow:Left():TitleStack({ Title = "GameId", Subtitle = "The unique ID of this game universe." })
GameIdRow:Right():Label({ Text = tostring(game.GameId) })
local PlaceIdRow = ServerInfoForm:Row()
PlaceIdRow:Left():TitleStack({ Title = "PlaceId", Subtitle = "The specific place ID of this server instance." })
PlaceIdRow:Right():Label({ Text = tostring(game.PlaceId) })
local ServerActionSection = ServerTab:PageSection({
    Title = "💾 Server Actions",
    Subtitle = "Quick tools to copy identifiers or switch servers."
})
local ServerActionForm = ServerActionSection:Form()
local function AddAction(form, title, subtitle, fn)
    local row = form:Row()
    row:Left():TitleStack({ Title = title, Subtitle = subtitle })
    local run
    local btn = row:Right():Button({
        Label = "Execute",
        Callback = function() if run then run() end end
    })
    run = BindButton(btn, fn)
end
AddAction(ServerActionForm, "Copy JobId", "Copy current JobId to clipboard for friends to join.", function()
    CopyText(tostring(game.JobId))
end)
AddAction(ServerActionForm, "Rejoin Server", "Go back to the main world (this map can't be rejoined directly).", function()
    pcall(function()
        if #Players:GetPlayers() <= 1 then
            LocalPlayer:Kick("\nRejoining...")
            task.wait()
        end
        TeleportService:Teleport(HOP_PLACE_ID, LocalPlayer)
    end)
end)
AddAction(ServerActionForm, "Server Hop", "Teleport to a different server to find a new one.", HopServer)
end
SettingsTab = SettingsCategory:Tab({
    Title = "Windows",
    Icon = Icon("macwindow", "sliderHorizontal3")
})
local ColorSection = SettingsTab:PageSection({
    Title = "🎨 Customs Color",
    Subtitle = "Customize the appearance and visual style of the interface."
})
local ColorForm = ColorSection:Form()
local ColorRow = ColorForm:Row()
ColorRow:Left():TitleStack({
    Title = "Theme Color",
    Subtitle = "The whole palette, not just light or dark."
})
local colorOptions = AccentOrder
local colorMaps = {}
for index, accentName in ipairs(colorOptions) do
    colorMaps[index] = Cascade.Accents[accentName]
end
local DEFAULT_ACCENT = ConfigStore.DEFAULT_LOOK.Theme
local FOLLOW_THEME = "Theme Default"
local CurrentThemeName = table.find(AccentOrder, SavedUi.Theme) and SavedUi.Theme or DEFAULT_ACCENT
local CurrentAccentName = (SavedUi.Accent == FOLLOW_THEME or table.find(AccentOrder, SavedUi.Accent)) and SavedUi.Accent or ConfigStore.DEFAULT_LOOK.Accent
local ACCENT_ONLY_KEYS = { "SwitchAccent", "Selection", "SelectionFocused", "Toggle", "Button" }
local function BuildFinalAccent()
    local base = Cascade.Accents[CurrentThemeName]
    if not base then return nil end
    if CurrentAccentName == FOLLOW_THEME then return base end
    local pick = Cascade.Accents[CurrentAccentName]
    if not pick then return base end
    local combined = { _id = "SmoothHubCustom" }
    for _, mode in ipairs({ "Dark", "Light" }) do
        local set = {}
        for key, value in pairs(base[mode] or {}) do
            set[key] = value
        end
        for _, key in ipairs(ACCENT_ONLY_KEYS) do
            if pick[mode] and pick[mode][key] ~= nil then
                set[key] = pick[mode][key]
            end
        end
        combined[mode] = set
    end
    Cascade.Accents.SmoothHubCustom = combined
    return combined
end
local function ApplyAppearance()
    local finalAccent = BuildFinalAccent()
    if not finalAccent then return end
    pcall(function() App.Accent = finalAccent end)
    pcall(function()
        if App.SetTheme then
            App:SetTheme(finalAccent)
        elseif Window.RefreshTheme then
            Window:RefreshTheme()
        end
    end)
    task.spawn(function()
        -- ไม่สลับ Maximized แล้ว (ทำให้หน้าต่างเต็มจอ/เลย์เอาต์เพี้ยน) | รีเฟรชธีมด้วยการเลือกแท็บใหม่แทน
        pcall(function() if Window.Maximized then Window.Maximized = false end end)
        for _, tab in ipairs({ CharTab, AccountTab, FarmTab, AutoQuestTab, AutoSkillTab, LobbyTab, ProgressionTab, SkillTreesTab, PerksTab, MissionsTab, WaveModeTab, RaidModeTab, WebhookTab, AdvancedTab, ServerTab, SettingsTab, ConfigTab, SH.CursorTab }) do
            if tab.Selected then
                tab.Selected = false
                task.wait()
                tab.Selected = true
                break
            end
        end
    end)
end
local ThemeColorBtn = ColorRow:Right():PullDownButton({
    Label = CurrentThemeName,
    Options = colorOptions,
    Value = table.find(colorOptions, CurrentThemeName) or 1,
    ValueChanged = function(self, index)
        if colorOptions[index] and colorMaps[index] then
            CurrentThemeName = colorOptions[index]
            self.Label = colorOptions[index]
            ApplyAppearance()
        end
    end
})
StyleDropdown(ThemeColorBtn)
local AccentRow = ColorForm:Row()
AccentRow:Left():TitleStack({
    Title = "Accent Color",
    Subtitle = "Only changes icons, switches and buttons. The background stays the same."
})
local accentOptions = { FOLLOW_THEME }
for _, accentName in ipairs(AccentOrder) do
    table.insert(accentOptions, accentName)
end
local AccentColorBtn = AccentRow:Right():PullDownButton({
    Label = CurrentAccentName,
    Options = accentOptions,
    Value = table.find(accentOptions, CurrentAccentName) or 1,
    ValueChanged = function(self, index)
        if accentOptions[index] then
            CurrentAccentName = accentOptions[index]
            self.Label = accentOptions[index]
            ApplyAppearance()
        end
    end
})
StyleDropdown(AccentColorBtn)
if CurrentAccentName ~= FOLLOW_THEME then
    ApplyAppearance()
end
local BlurSection = SettingsTab:PageSection({
    Title = "✨ Windows Effects",
    Subtitle = "Manage special visual styles for your script window."
})
local BlurForm = BlurSection:Form()
if type(SavedUi.UIBlur) == "boolean" then Window.UIBlur = SavedUi.UIBlur end
if type(SavedUi.Dropshadow) == "boolean" then Window.Dropshadow = SavedUi.Dropshadow end
local BlurRow = BlurForm:Row()
BlurRow:Left():TitleStack({
    Title = "Blur Effect",
    Subtitle = "Enable frosted glass blur effect behind the window."
})
UiSync.Blur = BlurRow:Right():Toggle({
    Value = Window.UIBlur,
    ValueChanged = function(self, value) Window.UIBlur = value end
})
local ShadowRow = BlurForm:Row()
ShadowRow:Left():TitleStack({
    Title = "Shadows Effect",
    Subtitle = "Enable smooth dropshadow around the script window."
})
UiSync.Shadow = ShadowRow:Right():Toggle({
    Value = Window.Dropshadow,
    ValueChanged = function(self, value) Window.Dropshadow = value end
})
local InputSection = SettingsTab:PageSection({
    Title = "⌨️ Input",
    Subtitle = "The shortcut that hides and shows the window."
})
local InputForm = InputSection:Form()
local HotkeyRow = InputForm:Row()
HotkeyRow:Left():TitleStack({
    Title = "Minimize Hotkey",
    Subtitle = "Press to hide or show the window."
})
local currentKeybind = Enum.KeyCode.LeftAlt
pcall(function() currentKeybind = Enum.KeyCode[ConfigStore.DEFAULT_LOOK.Keybind] or Enum.KeyCode.LeftAlt end)
if type(SavedUi.Keybind) == "string" then
    pcall(function()
        local savedKey = Enum.KeyCode[SavedUi.Keybind]
        if savedKey then currentKeybind = savedKey end
    end)
end
UiSync.Hotkey = HotkeyRow:Right():KeybindField({
    Value = currentKeybind,
    ValueChanged = function(self, newKey) currentKeybind = newKey end,
    BindPressed = function(self, key, inputComplete, gameProcessedEvent)
        if not inputComplete then return end
        -- ถ้าเกมจับปุ่มไปก่อน เมนูเดิมจะเปิดไม่ติด -> ให้สลับเมนูเสมอ ยกเว้นตอนกำลังพิมพ์อยู่ในช่องข้อความ
        local typing = false
        pcall(function() typing = game:GetService("UserInputService"):GetFocusedTextBox() ~= nil end)
        if gameProcessedEvent and typing then return end
        SH.MenuTouched = true
        Window.Minimized = not Window.Minimized
    end
})
task.spawn(function()
    local LOGO_URL = ""
    local LOGO_ASSET_ID = ""
    local LOGO_ON_PC = true
    local UIS = game:GetService("UserInputService")
    if not UIS.TouchEnabled and not LOGO_ON_PC then return end
    -- 🖼️ โลโก้ใหม่ฝังในสคริปต์ (base64) ไม่ต้องพึ่งลิงก์ภายนอก
    local B64_TOGGLE = [==[
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
]==]
    local function B64DecodeT(data)
        if data == "" then return "" end
        local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
        local lookup = {}
        for i = 1, 64 do lookup[chars:sub(i, i)] = i - 1 end
        data = data:gsub("[^%w%+/=]", "")
        local out, n = {}, 0
        for i = 1, #data, 4 do
            local a, b, c, d = data:sub(i, i), data:sub(i + 1, i + 1), data:sub(i + 2, i + 2), data:sub(i + 3, i + 3)
            local v = (lookup[a] or 0) * 262144 + (lookup[b] or 0) * 4096 + (lookup[c] or 0) * 64 + (lookup[d] or 0)
            n = n + 1
            out[n] = string.char(math.floor(v / 65536) % 256)
            if c ~= "=" and c ~= "" then n = n + 1 out[n] = string.char(math.floor(v / 256) % 256) end
            if d ~= "=" and d ~= "" then n = n + 1 out[n] = string.char(v % 256) end
        end
        return table.concat(out)
    end
    local logoImage = ""
    do
        local id = tostring(LOGO_ASSET_ID or ""):gsub("%s", "")
        if id ~= "" then
            logoImage = id:match("^%d+$") and ("rbxassetid://" .. id) or id
        elseif B64_TOGGLE ~= "" and type(writefile) == "function"
            and (type(getcustomasset) == "function" or type(getsynasset) == "function") then
            local okB, assetB = pcall(function()
                if type(makefolder) == "function" and type(isfolder) == "function" and not isfolder("SmoothHub") then
                    makefolder("SmoothHub")
                end
                local path = "SmoothHub/toggle_logo_v2.png"
                writefile(path, B64DecodeT(B64_TOGGLE))
                return (getcustomasset or getsynasset)(path)
            end)
            if okB and type(assetB) == "string" and assetB ~= "" then logoImage = assetB end
        end
        if logoImage == "" and tostring(LOGO_URL or "") ~= "" and type(writefile) == "function"
            and (type(getcustomasset) == "function" or type(getsynasset) == "function") then
            local file = "SmoothHub_logo.png"
            pcall(function()
                local data = game:HttpGet(LOGO_URL)
                if type(data) == "string" and #data > 100 then writefile(file, data) end
            end)
            local okAsset, asset = pcall(function() return (getcustomasset or getsynasset)(file) end)
            if okAsset and type(asset) == "string" and asset ~= "" then logoImage = asset end
        end
    end
    local parent = (type(gethui) == "function" and gethui()) or game:GetService("CoreGui")
    pcall(function()
        local old = parent:FindFirstChild("SmoothHubToggle")
        if old then old:Destroy() end
    end)
    local gui = Instance.new("ScreenGui")
    gui.Name = "SmoothHubToggle"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 999998
    local okParent = pcall(function() gui.Parent = parent end)
    if not okParent or not gui.Parent then gui.Parent = PlayerGui end
    local btn = Instance.new("ImageButton")
    btn.Name = "Toggle"
    btn.Size = UDim2.fromOffset(52, 52)
    btn.Position = UDim2.new(0, 14, 0.5, -26)
    btn.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
    btn.BackgroundTransparency = 0
    btn.AutoButtonColor = false
    btn.Image = logoImage
    btn.ScaleType = Enum.ScaleType.Crop
    btn.Parent = gui
    if logoImage == "" then
        local letter = Instance.new("TextLabel")
        letter.Size = UDim2.fromScale(1, 1)
        letter.BackgroundTransparency = 1
        letter.Text = "S"
        letter.TextColor3 = Color3.fromRGB(255, 255, 255)
        letter.Font = Enum.Font.GothamBold
        letter.TextSize = 24
        letter.Parent = btn
    end
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = btn
    -- ✨ ไอคอนมีชีวิต: สปริงนุ่ม ๆ ตอนเมาส์ชี้/กด/ลาก + ขอบเรืองแสง + เอียงตามเมาส์ + หายใจเบา ๆ + คลื่นตอนคลิก
    do
        local RunService = game:GetService("RunService")
        local TweenService = game:GetService("TweenService")
        local RED = Color3.fromRGB(255, 60, 70)
        local WHITE = Color3.fromRGB(255, 255, 255)

        local scaleObj = Instance.new("UIScale")
        scaleObj.Scale = 0
        scaleObj.Parent = btn

        -- สปริง: x = ค่าปัจจุบัน, v = ความเร็ว, t = เป้าหมาย, k = ความแข็ง, d = ความหน่วง (d ต่ำ = เด้งมาก)
        local function newSpring(x, k, d) return { x = x, v = 0, t = x, k = k, d = d } end
        local function stepSpring(s, dt)
            local f = -s.k * (s.x - s.t) - s.d * s.v
            s.v = s.v + f * dt
            s.x = s.x + s.v * dt
            return s.x
        end
        local sc = newSpring(0, 170, 15)   -- ขนาด (เด้งเข้าตอนเปิด)
        local rot = newSpring(0, 120, 13)  -- การเอียง
        local gl = newSpring(0, 160, 25)   -- ความเรืองแสง (ไม่เด้ง)

        local hover, pressed, lifted = false, false, false
        local mouseRel = 0
        local pressPos = nil
        local t0 = os.clock()
        local last = t0

        local conn
        conn = RunService.RenderStepped:Connect(function()
            if not Alive() or not gui.Parent then
                if conn then conn:Disconnect() end
                return
            end
            local now = os.clock()
            local dt = math.min(now - last, 1 / 30)
            last = now
            local t = now - t0

            sc.t = pressed and (lifted and 1.14 or 0.9) or (hover and 1.12 or 1)
            rot.t = (hover and not pressed) and (mouseRel * 10) or 0
            gl.t = (hover or pressed) and 1 or 0

            local s = stepSpring(sc, dt)
            local r = stepSpring(rot, dt)
            local g = math.clamp(stepSpring(gl, dt), 0, 1)

            local breathe = (1 - g) * 0.025 * math.sin(t * 1.8) -- หายใจเบา ๆ ตอนอยู่นิ่ง
            scaleObj.Scale = math.max(0, s + breathe)
            btn.Rotation = r
        end)
        sc.t = 1

        local function ripple()
            local ring = Instance.new("Frame")
            ring.AnchorPoint = Vector2.new(0.5, 0.5)
            ring.Position = UDim2.fromScale(0.5, 0.5)
            ring.Size = UDim2.fromScale(1, 1)
            ring.BackgroundTransparency = 1
            ring.BorderSizePixel = 0
            ring.Parent = btn
            local rc = Instance.new("UICorner")
            rc.CornerRadius = UDim.new(1, 0)
            rc.Parent = ring
            local rs = Instance.new("UIStroke")
            rs.Thickness = 1.5
            rs.Color = WHITE
            rs.Transparency = 0.55
            rs.Parent = ring
            local info = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            TweenService:Create(ring, info, { Size = UDim2.fromScale(1.9, 1.9) }):Play()
            TweenService:Create(rs, info, { Transparency = 1 }):Play()
            task.delay(0.65, function() pcall(function() ring:Destroy() end) end)
        end

        local function isPressInput(input)
            return input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1
        end
        btn.MouseEnter:Connect(function() hover = true end)
        btn.MouseLeave:Connect(function() hover = false end)
        btn.InputBegan:Connect(function(input)
            if isPressInput(input) then
                pressed, lifted = true, false
                pressPos = input.Position
            end
        end)
        btn.InputEnded:Connect(function(input)
            if isPressInput(input) and pressed then
                local wasLifted = lifted
                pressed, lifted = false, false
                if input.UserInputType == Enum.UserInputType.Touch then hover = false end
                if not wasLifted then ripple() end
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                if pressed and pressPos and (input.Position - pressPos).Magnitude > 8 then lifted = true end
                if hover and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local half = math.max(btn.AbsoluteSize.X / 2, 1)
                    local cx = btn.AbsolutePosition.X + btn.AbsoluteSize.X / 2
                    mouseRel = math.clamp((input.Position.X - cx) / half, -1, 1)
                end
            end
        end)
    end
    local dragging, moved, dragStart, startPos = false, false, nil, nil
    local function isPress(input)
        return input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1
    end
    btn.InputBegan:Connect(function(input)
        if isPress(input) then
            dragging, moved = true, false
            dragStart, startPos = input.Position, btn.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local d = input.Position - dragStart
            if d.Magnitude > 8 then moved = true end
            if moved then
                btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end
    end)
    btn.InputEnded:Connect(function(input)
        if isPress(input) and dragging then
            dragging = false
            if not moved then SH.MenuTouched = true; Window.Minimized = not Window.Minimized end
        end
    end)
    while Alive() and gui.Parent do task.wait(1) end
    pcall(function() gui:Destroy() end)
end)
-- ============================================================
--  🖱️ Smooth Hub | Cursor
--  เคอร์เซอร์เมาส์เสมือน: ใส่รูปเองได้ (ลิงก์ / ชื่อไฟล์ในโฟลเดอร์ / rbxassetid)
--  ไฟล์รูปวางที่ workspace/SmoothHub/Cursors/  (รองรับ PNG / JPG)
--  ตั้งค่าเก็บที่ SmoothHub/<UserId>/MouseCursor.json
-- ============================================================
SH.CursorTab = SettingsCategory:Tab({
    Title = "Cursor",
    Icon = Icon("cursorarrow", "cursorarrowRays", "cursorarrowClick", "boltFill"),
})
SH.Guard("mouse-cursor", function()
    local UIS = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local TAB = SH.CursorTab

    local FILE = "MouseCursor"
    local CURSOR_DIR = "SmoothHub/Cursors"
    local DEFAULT_IMAGE = "rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png"
    local MAX_BYTES = 4 * 1024 * 1024

    local C = {
        Enabled = false,   -- เปิดเคอร์เซอร์เสมือน
        MenuOnly = true,   -- แสดงเฉพาะตอนเมนูเปิดอยู่
        Unlock = true,     -- ปลดล็อกเมาส์ตอนเมนูเปิด (แก้ปัญหาเมาส์หาย/คลิกเมนูไม่ได้)
        Center = false,    -- ใช้จุดกลางรูปเป็นจุดคลิก (ปกติใช้มุมซ้ายบน)
        Size = 32,
        Source = "",       -- ลิงก์ / ชื่อไฟล์ / rbxassetid ล่าสุดที่ใช้
    }
    SettingsStore.Restore(C, SettingsStore.Load(FILE))
    C.Size = math.clamp(tonumber(C.Size) or 32, 12, 128)
    local function SaveC() SettingsStore.Write(FILE, C) end

    local Status = function() end
    local imageAsset = DEFAULT_IMAGE

    -- ---------- โหลดรูป ----------
    local function GetRequest()
        return (syn and syn.request) or http_request or request or (fluxus and fluxus.request)
    end
    local function ImageExt(body)
        if type(body) ~= "string" then return nil end
        if body:sub(1, 8) == "\137PNG\r\n\26\n" then return "png" end
        if body:sub(1, 3) == "\255\216\255" then return "jpg" end
        return nil
    end
    local function Hash(s)
        local h = 5381
        for i = 1, #s do h = (h * 33 + s:byte(i)) % 4294967296 end
        return string.format("%08x", h)
    end
    local function EnsureDir()
        pcall(function()
            if type(makefolder) == "function" and type(isfolder) == "function" then
                if not isfolder("SmoothHub") then makefolder("SmoothHub") end
                if not isfolder(CURSOR_DIR) then makefolder(CURSOR_DIR) end
            end
        end)
    end
    local function Resolve(text)
        text = tostring(text or ""):match("^%s*(.-)%s*$")
        if text == "" then return DEFAULT_IMAGE end
        if text:match("^%d+$") then return "rbxassetid://" .. text end
        if text:match("^rbxassetid://") or text:match("^rbxasset://") then return text end

        local toAsset = getcustomasset or getsynasset
        if type(toAsset) ~= "function" or type(writefile) ~= "function" or type(isfile) ~= "function" then
            return nil, "Executor doesn't support custom files (getcustomasset)"
        end

        if text:match("^https?://") then
            EnsureDir()
            local ok, body = pcall(function() return game:HttpGet(text) end)
            if not ok or type(body) ~= "string" or #body == 0 then
                body = nil
                local req = GetRequest()
                if req then
                    local ok2, res = pcall(req, { Url = text, Method = "GET" })
                    if ok2 and type(res) == "table" and type(res.Body) == "string" then body = res.Body end
                end
            end
            if type(body) ~= "string" or #body == 0 then return nil, "Download failed (check the link)" end
            if #body > MAX_BYTES then return nil, "Image too large (max 4 MB)" end
            local ext = ImageExt(body)
            if not ext then return nil, "Not a PNG/JPG image (.cur / .gif / .webp are not supported)" end
            local path = CURSOR_DIR .. "/url_" .. Hash(text) .. "." .. ext
            if not pcall(writefile, path, body) then return nil, "Could not save image to workspace" end
            local okA, asset = pcall(toAsset, path)
            if okA and asset then return asset end
            return nil, "getcustomasset failed"
        end

        for _, path in ipairs({ CURSOR_DIR .. "/" .. text, text }) do
            local okF, exists = pcall(isfile, path)
            if okF and exists then
                local okR, body = pcall(readfile, path)
                if not okR or not ImageExt(body) then return nil, "File is not a PNG/JPG image" end
                local okA, asset = pcall(toAsset, path)
                if okA and asset then return asset end
                return nil, "getcustomasset failed"
            end
        end
        return nil, "File not found: " .. CURSOR_DIR .. "/" .. text
    end

    -- ---------- เคอร์เซอร์เสมือน ----------
    local gui, cursorImg, modalBtn
    local function BuildGui()
        gui = Instance.new("ScreenGui")
        gui.Name = "SmoothHubCursor"
        gui.ResetOnSpawn = false
        gui.DisplayOrder = 2147483647
        gui.IgnoreGuiInset = true
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Enabled = false
        local parented = false
        for _, getParent in ipairs({
            function() return type(gethui) == "function" and gethui() or nil end,
            function() return game:GetService("CoreGui") end,
            function() return PlayerGui end,
        }) do
            local okP, parent = pcall(getParent)
            if okP and parent and pcall(function() gui.Parent = parent end) and gui.Parent then
                parented = true
                break
            end
        end
        if not parented then gui:Destroy() gui = nil return end

        modalBtn = Instance.new("TextButton") -- Modal = true จะปลดล็อกเมาส์ให้ขยับได้อิสระ
        modalBtn.Name = "Unlock"
        modalBtn.Text = ""
        modalBtn.BackgroundTransparency = 1
        modalBtn.Size = UDim2.fromOffset(0, 0)
        modalBtn.Modal = false
        modalBtn.Parent = gui

        cursorImg = Instance.new("ImageLabel")
        cursorImg.Name = "Cursor"
        cursorImg.BackgroundTransparency = 1
        cursorImg.BorderSizePixel = 0
        cursorImg.Active = false
        cursorImg.ZIndex = 1000
        cursorImg.Image = imageAsset
        cursorImg.Size = UDim2.fromOffset(C.Size, C.Size)
        pcall(function() cursorImg.Interactable = false end)
        cursorImg.Parent = gui
    end
    BuildGui()

    local origIcon = nil
    local function RestoreIcon()
        if origIcon ~= nil then
            pcall(function() UIS.MouseIconEnabled = origIcon end)
            origIcon = nil
        end
    end
    local function MenuOpen()
        local ok, minimized = pcall(function() return Window.Minimized end)
        return ok and not minimized
    end

    local conn, lastShow = nil, nil
    local function Teardown()
        if conn then conn:Disconnect() conn = nil end
        RestoreIcon()
        pcall(function() if gui then gui:Destroy() end end)
        gui, cursorImg, modalBtn = nil, nil, nil
    end
    local prevCleanup = _G.SmoothHubCleanup
    _G.SmoothHubCleanup = function()
        pcall(Teardown)
        if type(prevCleanup) == "function" then pcall(prevCleanup) end
    end

    local touchOnly = UIS.TouchEnabled and not UIS.MouseEnabled
    if gui and not touchOnly then
        conn = RunService.RenderStepped:Connect(function()
            if not Alive() then Teardown() return end
            local open = MenuOpen()
            -- show = วาดเคอร์เซอร์เสมือน (ต้องเปิด Custom Cursor) | wantModal = ปลดล็อกเมาส์ตอนเมนูเปิด (ไม่ต้องเปิด Custom Cursor)
            local show = (C.Enabled and (open or not C.MenuOnly)) and true or false
            local wantModal = (C.Unlock and open) and true or false
            local active = show or wantModal
            if active ~= lastShow then
                lastShow = active
                gui.Enabled = active
                if active then
                    if origIcon == nil then origIcon = UIS.MouseIconEnabled end
                else
                    modalBtn.Modal = false
                    RestoreIcon()
                end
            end
            if cursorImg.Visible ~= show then cursorImg.Visible = show end
            if not active then return end
            if modalBtn.Modal ~= wantModal then modalBtn.Modal = wantModal end
            if wantModal and UIS.MouseBehavior ~= Enum.MouseBehavior.Default then
                UIS.MouseBehavior = Enum.MouseBehavior.Default
            end
            if show then
                if UIS.MouseIconEnabled then UIS.MouseIconEnabled = false end
                local p = UIS:GetMouseLocation()
                local s = C.Size
                cursorImg.Size = UDim2.fromOffset(s, s)
                if C.Center then
                    cursorImg.Position = UDim2.fromOffset(p.X - s / 2, p.Y - s / 2)
                else
                    cursorImg.Position = UDim2.fromOffset(p.X, p.Y)
                end
            elseif not UIS.MouseIconEnabled then
                UIS.MouseIconEnabled = true -- ไม่ได้ใช้เคอร์เซอร์เสมือน: ให้เมาส์จริงโผล่ขึ้นมาในเมนู
            end
        end)
    end

    -- ---------- นำรูปไปใช้ ----------
    local busy = false
    local function Apply(text)
        if busy then return end
        busy = true
        Status("Loading...")
        local okR, asset, err = pcall(Resolve, text)
        if not okR then err, asset = asset, nil end
        busy = false
        if asset then
            imageAsset = asset
            if cursorImg then cursorImg.Image = asset end
            C.Source = tostring(text or "")
            SaveC()
            Status(C.Source == "" and "Using default cursor" or "Cursor applied")
            return true
        end
        Status("Failed: " .. tostring(err))
        return false
    end

    -- ---------- UI ----------
    local MainForm = TAB:PageSection({
        Title = "🖱️ Mouse cursor",
        Subtitle = "Virtual cursor you can see and click with, even when the game locks your mouse.",
    }):Form()

    local onRow = MainForm:Row()
    onRow:Left():TitleStack({ Title = "Custom Cursor", Subtitle = "Draw a virtual cursor on top of everything." })
    UiSync.Link(onRow:Right():Toggle({
        Value = C.Enabled,
        ValueChanged = function(self, value) C.Enabled = value and true or false SaveC() end
    }), C, "Enabled")

    local menuRow = MainForm:Row()
    menuRow:Left():TitleStack({ Title = "Only While Menu Is Open", Subtitle = "Hide the virtual cursor when the menu is closed." })
    UiSync.Link(menuRow:Right():Toggle({
        Value = C.MenuOnly,
        ValueChanged = function(self, value) C.MenuOnly = value and true or false SaveC() end
    }), C, "MenuOnly")

    local unlockRow = MainForm:Row()
    unlockRow:Left():TitleStack({ Title = "Unlock Mouse In Menu", Subtitle = "Free the mouse while the menu is open so you can click options." })
    UiSync.Link(unlockRow:Right():Toggle({
        Value = C.Unlock,
        ValueChanged = function(self, value) C.Unlock = value and true or false SaveC() end
    }), C, "Unlock")

    local centerRow = MainForm:Row()
    centerRow:Left():TitleStack({ Title = "Center Hotspot", Subtitle = "Click at the image center instead of its top-left corner." })
    UiSync.Link(centerRow:Right():Toggle({
        Value = C.Center,
        ValueChanged = function(self, value) C.Center = value and true or false SaveC() end
    }), C, "Center")

    local sizeRow = MainForm:Row()
    sizeRow:Left():TitleStack({ Title = "Cursor Size", Subtitle = "Size in pixels (12 - 128)." })
    local sizeRight = sizeRow:Right()
    local sizeLabel = sizeRight:Label({ Text = C.Size .. "px" })
    UiSync.Link(sizeRight:Slider({
        Minimum = 12,
        Maximum = 128,
        Value = C.Size,
        ValueChanged = function(self, value)
            C.Size = math.clamp(math.floor((tonumber(value) or 32) + 0.5), 12, 128)
            pcall(function() sizeLabel.Text = C.Size .. "px" end)
            SaveC()
        end
    }), C, "Size", function(_, want)
        pcall(function() sizeLabel.Text = want .. "px" end)
    end)

    local ImgForm = TAB:PageSection({
        Title = "🖼️ Cursor image",
        Subtitle = "Paste an image link, a file name, or a Roblox asset id. PNG / JPG only.",
    }):Form()

    local statusRow = ImgForm:Row()
    statusRow:Left():TitleStack({ Title = "Status", Subtitle = "Result of the last apply." })
    local statusLabel = statusRow:Right():Label({ Text = "Idle" })
    Status = function(text) pcall(function() statusLabel.Text = tostring(text) end) end

    local pending = C.Source
    local srcRow = ImgForm:Row()
    srcRow:Left():TitleStack({
        Title = "Image Source",
        Subtitle = "Link (https://...png), file in workspace/" .. CURSOR_DIR .. "/ (e.g. mycursor.png), or rbxassetid.",
    })
    local okField, field = pcall(function()
        return srcRow:Right():TextField({
            Placeholder = "https://.../cursor.png  |  mycursor.png  |  123456789",
            Value = C.Source,
            TextChanged = function(self, text) pending = tostring(text or "") end,
            ValueChanged = function(self, value) pending = tostring(value or "") end,
        })
    end)

    local applyRow = ImgForm:Row()
    applyRow:Left():TitleStack({ Title = "Apply Image", Subtitle = "Download / load the image and use it as the cursor." })
    local applyBtn = applyRow:Right():Button({ Label = "Apply", Callback = function() end })
    BindButton(applyBtn, function()
        if okField and field and type(field.Value) == "string" and field.Value ~= "" then pending = field.Value end
        Apply(pending)
    end)

    local resetRow = ImgForm:Row()
    resetRow:Left():TitleStack({ Title = "Reset Image", Subtitle = "Go back to the default Roblox arrow." })
    local resetBtn = resetRow:Right():Button({ Label = "Reset", Callback = function() end })
    BindButton(resetBtn, function()
        pending = ""
        if okField and field then pcall(function() field.Value = "" end) end
        Apply("")
    end)

    local folderRow = ImgForm:Row()
    folderRow:Left():TitleStack({ Title = "Image Folder", Subtitle = "Put your own PNG/JPG here, then type its file name above." })
    folderRow:Right():Label({ Text = "workspace/" .. CURSOR_DIR })

    if touchOnly then
        Status("Mobile/touch device: virtual cursor is PC only")
    elseif C.Source ~= "" then
        task.spawn(function() Apply(C.Source) end) -- โหลดรูปที่เคยตั้งไว้ตอนเปิดสคริปต์
    end
end)

-- ============================================================
--  🌐 Language | ภาษา | Idioma | Ngôn ngữ  (English / ไทย / Español / Tiếng Việt)
--  แปลเฉพาะหน้าต่างเมนู Smooth Hub (ไม่แตะ GUI ของเกม)
--  ตั้งค่าเก็บที่ SmoothHub/<UserId>/Language.json
-- ============================================================
SH.LangTab = SettingsCategory:Tab({
    Title = "Language",
    Icon = Icon("globe", "textformat", "character", "gearshapeFill"),
})
SH.Guard("language", function()
    local LANG_FILE = "Language"
    local LANG_OPTIONS = { "English (ENG)", "ไทย (Thai)", "Español (Spanish)", "Tiếng Việt (Vietnamese)" }
    local LANG_CODES = { "EN", "TH", "ES", "VI" }

    local DICTS = {
    TH = {
        ["Menu"] = "เมนู",
        ["Menu Lobby"] = "เมนูล็อบบี้",
        ["Status"] = "สถานะ",
        ["Account"] = "บัญชี",
        ["In-Game"] = "ในเกม",
        ["Lobby"] = "ล็อบบี้",
        ["Game Mode"] = "โหมดเกม",
        ["Misc"] = "อื่น ๆ",
        ["Auto Farm"] = "ฟาร์มอัตโนมัติ",
        ["Auto Quest"] = "เควสอัตโนมัติ",
        ["Auto Skill"] = "สกิลอัตโนมัติ",
        ["Progression"] = "ความก้าวหน้า",
        ["Skill Trees"] = "ต้นสกิล",
        ["Perks"] = "เพิร์ก",
        ["Missions"] = "ภารกิจ",
        ["Wave Mode"] = "โหมดเวฟ",
        ["Raid Mode"] = "โหมดเรด",
        ["Webhook"] = "เว็บฮุค",
        ["Advanced"] = "ขั้นสูง",
        ["Server"] = "เซิร์ฟเวอร์",
        ["Windows"] = "หน้าต่าง",
        ["Config"] = "คอนฟิก",
        ["Cursor"] = "เคอร์เซอร์",
        ["Language"] = "ภาษา",
        ["Settings\u{200B}"] = "ตั้งค่า\u{200B}",
        ["⌨️ Input"] = "⌨️ การป้อนข้อมูล",
        ["▶️ Auto Play"] = "▶️ เล่นอัตโนมัติ",
        ["⚔️ Auto Clear Wave"] = "⚔️ เคลียร์เวฟอัตโนมัติ",
        ["⚔️ Auto Farm"] = "⚔️ ฟาร์มอัตโนมัติ",
        ["⚔️ Equipment"] = "⚔️ อุปกรณ์",
        ["⚔️ Raid Settings"] = "⚔️ ตั้งค่าเรด",
        ["⚙️ Advanced Settings"] = "⚙️ ตั้งค่าขั้นสูง",
        ["⚙️ After the Match"] = "⚙️ หลังจบแมตช์",
        ["⚙️ Settings Roll"] = "⚙️ ตั้งค่าการสุ่ม",
        ["⛽ Auto Refill [ Wave ]"] = "⛽ เติมของอัตโนมัติ [ เวฟ ]",
        ["✅ Auto Ready"] = "✅ กดพร้อมอัตโนมัติ",
        ["✨ Windows Effects"] = "✨ เอฟเฟกต์หน้าต่าง",
        ["⬆️ Auto Upgrade Character [ Cole ]"] = "⬆️ อัปเกรดตัวละครอัตโนมัติ [ Cole ]",
        ["🌊 Wave Settings"] = "🌊 ตั้งค่าเวฟ",
        ["🌐 Server Information"] = "🌐 ข้อมูลเซิร์ฟเวอร์",
        ["🎁 Auto Claim"] = "🎁 รับรางวัลอัตโนมัติ",
        ["🎁 Raid Extras"] = "🎁 ส่วนเสริมเรด",
        ["🎨 Customs Color"] = "🎨 ปรับแต่งสี",
        ["🎭 Character Selection"] = "🎭 เลือกตัวละคร",
        ["🎯 Auto Skill"] = "🎯 สกิลอัตโนมัติ",
        ["🎰 Auto Roll Blessings [ Roll ]"] = "🎰 สุ่มพรอัตโนมัติ [ Roll ]",
        ["🎰 Roll Family"] = "🎰 สุ่มตระกูล",
        ["🏰 Colossal Titan"] = "🏰 ไททันยักษ์ (Colossal)",
        ["👑 Prestige Section"] = "👑 ส่วนเพรสทีจ",
        ["💾 Server Actions"] = "💾 คำสั่งเซิร์ฟเวอร์",
        ["📁 Configuration"] = "📁 การตั้งค่าคอนฟิก",
        ["📊 Account Overview"] = "📊 ภาพรวมบัญชี",
        ["📋 Status"] = "📋 สถานะ",
        ["📜 Mission Settings"] = "📜 ตั้งค่าภารกิจ",
        ["📜 Show Roll"] = "📜 แสดงผลการสุ่ม",
        ["📤 Share config"] = "📤 แชร์คอนฟิก",
        ["📦 Auto Loot Crate"] = "📦 เก็บกล่องอัตโนมัติ",
        ["🔔 Webhook"] = "🔔 เว็บฮุค",
        ["🔨 Crafting"] = "🔨 คราฟต์",
        ["🖥️ FPS"] = "🖥️ FPS",
        ["🖱️ Mouse cursor"] = "🖱️ เมาส์เคอร์เซอร์",
        ["🖼️ Cursor image"] = "🖼️ รูปเคอร์เซอร์",
        ["🗡️ Auto Upgrade [ Blades ] All"] = "🗡️ อัปเกรด [ ใบมีด ] ทั้งหมดอัตโนมัติ",
        ["🚀 Advance Missions"] = "🚀 ภารกิจขั้นสูง",
        ["🚪 Auto Join Lobby"] = "🚪 เข้าล็อบบี้อัตโนมัติ",
        ["🚪 Leave At Wave"] = "🚪 ออกเมื่อถึงเวฟ",
        ["🛒 Auto Shop [ Orange ]"] = "🛒 ช้อปอัตโนมัติ [ Orange ]",
        ["🛟 Safety"] = "🛟 ความปลอดภัย",
        ["🛠️ Auto Quest"] = "🛠️ เควสอัตโนมัติ",
        ["🛰️ Boss Check"] = "🛰️ ตรวจสอบบอส",
        ["🤖 Auto Mission"] = "🤖 ภารกิจอัตโนมัติ",
        ["🤖 Auto Raid"] = "🤖 เรดอัตโนมัติ",
        ["🤖 Auto Wave"] = "🤖 เวฟอัตโนมัติ",
        ["🧠 Memories Priority"] = "🧠 ลำดับความสำคัญของ Memories",
        ["🧭 Wave Routine"] = "🧭 รูทีนเวฟ",
        ["🩹 Auto Heal Injuries [ Youmii ]"] = "🩹 รักษาอาการบาดเจ็บอัตโนมัติ [ Youmii ]",
        ["Auto Farm [ Blades ]"] = "ฟาร์มอัตโนมัติ [ ใบมีด ]",
        ["Auto Farm [ Thunder Spears ]"] = "ฟาร์มอัตโนมัติ [ หอกสายฟ้า ]",
        ["Bypass Farm (No Shadow Ban)"] = "ฟาร์มแบบเลี่ยง (ไม่โดนแบนเงา)",
        ["Auto Reload"] = "รีโหลดอัตโนมัติ",
        ["Auto Refills [ Blade ]"] = "เติมของอัตโนมัติ [ ใบมีด ]",
        ["Auto Refills [ Thunder Spears ]"] = "เติมของอัตโนมัติ [ หอกสายฟ้า ]",
        ["Damage Multiplier ( x10 )"] = "ตัวคูณดาเมจ ( x10 )",
        ["Auto Retry"] = "ลองใหม่อัตโนมัติ",
        ["Auto Leave"] = "ออกอัตโนมัติ",
        ["Auto Leave After X Matches"] = "ออกอัตโนมัติหลัง X แมตช์",
        ["Auto Fail Safe"] = "ระบบกันสตรีคอัตโนมัติ",
        ["Auto Claim Main Quests"] = "รับเควสหลักอัตโนมัติ",
        ["Auto Claim Side Quests"] = "รับเควสรองอัตโนมัติ",
        ["Auto Claim Achievements"] = "รับความสำเร็จอัตโนมัติ",
        ["Auto Claim Weekly Quests"] = "รับเควสประจำสัปดาห์อัตโนมัติ",
        ["Auto Claim Daily Quests"] = "รับเควสประจำวันอัตโนมัติ",
        ["Auto Open Pages"] = "เปิดหน้าอัตโนมัติ",
        ["Auto Upgrade Gear ( Blade )"] = "อัปเกรดอุปกรณ์อัตโนมัติ ( ใบมีด )",
        ["Auto Upgrade Gear ( Thunder Spears )"] = "อัปเกรดอุปกรณ์อัตโนมัติ ( หอกสายฟ้า )",
        ["Auto Equip Blade"] = "สวมใบมีดอัตโนมัติ",
        ["Auto Equip Thunder Spears"] = "สวมหอกสายฟ้าอัตโนมัติ",
        ["Auto Prestige"] = "เพรสทีจอัตโนมัติ",
        ["Auto Upgrade Skills"] = "อัปเกรดสกิลอัตโนมัติ",
        ["Left"] = "ซ้าย",
        ["Middle"] = "กลาง",
        ["Right"] = "ขวา",
        ["Auto Craft Perks"] = "คราฟต์เพิร์กอัตโนมัติ",
        ["Auto Create Mission"] = "สร้างห้องภารกิจอัตโนมัติ",
        ["Auto Start Missions"] = "เริ่มภารกิจอัตโนมัติ",
        ["Auto Select Best Grade"] = "เลือกเกรดที่ดีที่สุดอัตโนมัติ",
        ["Auto Select Boost Mission"] = "เลือกภารกิจบูสต์อัตโนมัติ",
        ["Auto Create Raid"] = "สร้างห้องเรดอัตโนมัติ",
        ["Auto Start Raid"] = "เริ่มเรดอัตโนมัติ",
        ["Auto Skip Cutscene"] = "ข้ามคัตซีนอัตโนมัติ",
        ["Auto Open Chest (Free)"] = "เปิดหีบอัตโนมัติ (ฟรี)",
        ["Auto Open Chest (Premium)"] = "เปิดหีบอัตโนมัติ (พรีเมียม)",
        ["Auto Finish Chest"] = "จบหีบอัตโนมัติ",
        ["Auto Cannon (Colossal Titan)"] = "ปืนใหญ่อัตโนมัติ (Colossal Titan)",
        ["Auto Defend (only Eren Thunder Spears)"] = "ป้องกันอัตโนมัติ (เฉพาะ Eren หอกสายฟ้า)",
        ["Auto Create Wave"] = "สร้างห้องเวฟอัตโนมัติ",
        ["Auto Start Waves"] = "เริ่มเวฟอัตโนมัติ",
        ["Auto Shop [ Orange ]"] = "ช้อปอัตโนมัติ [ Orange ]",
        ["Infinite Jump"] = "กระโดดไม่จำกัด",
        ["Anti-AFK"] = "กันโดนเตะ AFK",
        ["Auto Rejoin"] = "เข้าเกมใหม่อัตโนมัติ",
        ["Anti Admin"] = "กันแอดมิน",
        ["Auto Execute"] = "รันสคริปต์อัตโนมัติ",
        ["Auto Hide Menu"] = "ซ่อนเมนูอัตโนมัติ",
        ["Enable FPS Lock"] = "เปิดล็อก FPS",
        ["Auto Delete Map"] = "ลบแมพอัตโนมัติ",
        ["Copy JobId"] = "คัดลอก JobId",
        ["Rejoin Server"] = "เข้าเซิร์ฟเวอร์ใหม่",
        ["Server Hop"] = "ย้ายเซิร์ฟเวอร์",
        ["Enter Save Config"] = "บันทึกคอนฟิกที่ใช้อยู่",
        ["Create config"] = "สร้างคอนฟิก",
        ["Load config"] = "โหลดคอนฟิก",
        ["Delete config"] = "ลบคอนฟิก",
        ["Refresh list"] = "รีเฟรชรายการ",
        ["Set as autoload"] = "ตั้งเป็นโหลดอัตโนมัติ",
        ["Reset autoload"] = "รีเซ็ตโหลดอัตโนมัติ",
        ["Reset to defaults"] = "รีเซ็ตเป็นค่าเริ่มต้น",
        ["Automatically completes missions with Blades."] = "ทำภารกิจให้จบอัตโนมัติด้วยใบมีด",
        ["Automatically completes missions with Thunder Spears."] = "ทำภารกิจให้จบอัตโนมัติด้วยหอกสายฟ้า",
        ["Reloads your blades when they run out."] = "รีโหลดใบมีดให้เมื่อใบมีดหมด",
        ["Refills at the station when your blades are out and no spare blades are left."] = "เติมของที่สถานีเมื่อใบมีดหมดและไม่มีใบมีดสำรองเหลือ",
        ["Refills at the station when your Thunder Spears run out."] = "เติมของที่สถานีเมื่อหอกสายฟ้าหมด",
        ["Deal 10x damage to Titans."] = "ใส่ดาเมจไททันเพิ่มเป็น 10 เท่า",
        ["Automatically Retry when completed."] = "ลองใหม่อัตโนมัติเมื่อจบแมตช์",
        ["Leave to the lobby right when the match ends."] = "ออกไปล็อบบี้ทันทีเมื่อแมตช์จบ",
        ["Retry up to the Retry Amount, then leave (needs Auto Retry). Not together with Auto Leave."] = "ลองใหม่ตามจำนวนที่ตั้งไว้ แล้วออก (ต้องเปิดลองใหม่อัตโนมัติ) ใช้พร้อมกับออกอัตโนมัติไม่ได้",
        ["Auto-jumps while farming so your gas gets used."] = "กระโดดอัตโนมัติขณะฟาร์ม เพื่อให้แก๊สถูกใช้",
        ["Matches to retry before leaving (used by Auto Leave After X Matches)."] = "จำนวนแมตช์ที่ลองใหม่ก่อนออก (ใช้กับออกอัตโนมัติหลัง X แมตช์)",
        ["When the win streak reaches the number above, the next match is lost on purpose: you stand still and let the titans kill you, then the streak resets."] = "เมื่อสตรีคชนะถึงตัวเลขด้านบน แมตช์ถัดไปจะตั้งใจแพ้: ยืนนิ่ง ๆ ให้ไททันฆ่า แล้วสตรีคจะรีเซ็ต",
        ["Automatically claim the main quests."] = "รับเควสหลักอัตโนมัติ",
        ["Automatically claim the side quests."] = "รับเควสรองอัตโนมัติ",
        ["Automatically claim achievements."] = "รับความสำเร็จอัตโนมัติ",
        ["Automatically claim the weekly quests."] = "รับเควสประจำสัปดาห์อัตโนมัติ",
        ["Automatically claim the daily quests."] = "รับเควสประจำวันอัตโนมัติ",
        ["When the game shows the red ! on the Achievements icon, open that page, claim, then close it (like a player)."] = "เมื่อเกมแสดงเครื่องหมาย ! สีแดงที่ไอคอนความสำเร็จ จะเปิดหน้านั้น กดรับ แล้วปิด (เหมือนผู้เล่น)",
        ["Automatically upgrade BLADE & ODM."] = "อัปเกรดใบมีดและ ODM อัตโนมัติ",
        ["Automatically upgrade thunder spears."] = "อัปเกรดหอกสายฟ้าอัตโนมัติ",
        ["Automatically equip blades."] = "สวมใบมีดอัตโนมัติ",
        ["Automatically equip thunder spears."] = "สวมหอกสายฟ้าอัตโนมัติ",
        ["Automatically prestige."] = "เพรสทีจอัตโนมัติ",
        ["Automatically upgrade skills tree."] = "อัปเกรดต้นสกิลอัตโนมัติ",
        ["Upgrade the left path."] = "อัปเกรดสายซ้าย",
        ["Upgrade the middle path."] = "อัปเกรดสายกลาง",
        ["Upgrade the right path."] = "อัปเกรดสายขวา",
        ["Automatically craft perks."] = "คราฟต์เพิร์กอัตโนมัติ",
        ["Keeps a room ready with these settings. Remembered next time."] = "เตรียมห้องไว้ตามค่าที่ตั้ง และจำค่าไว้ใช้ครั้งหน้า",
        ["Starts the mission in your room. Remembered next time."] = "เริ่มภารกิจในห้องของคุณ และจำค่าไว้ใช้ครั้งหน้า",
        ["Creates the highest difficulty you can play."] = "สร้างห้องความยากสูงสุดที่คุณเล่นได้",
        ["Creates the map that has the reward boost now."] = "สร้างห้องแมพที่มีบูสต์รางวัลอยู่ตอนนี้",
        ["Keeps a raid room ready with these settings. Remembered next time."] = "เตรียมห้องเรดไว้ตามค่าที่ตั้ง และจำค่าไว้ใช้ครั้งหน้า",
        ["Starts the raid in your room. Remembered next time."] = "เริ่มเรดในห้องของคุณ และจำค่าไว้ใช้ครั้งหน้า",
        ["Presses SKIP [E] on cutscenes once your character has loaded."] = "กด SKIP [E] ในคัตซีนเมื่อตัวละครโหลดเสร็จ",
        ["Presses OPEN on the Free chest when the chest screen shows."] = "กด OPEN ที่หีบฟรีเมื่อหน้าหีบขึ้น",
        ["Presses OPEN on the Premium chest. Only turn on if you want to open it."] = "กด OPEN ที่หีบพรีเมียม เปิดใช้เฉพาะเมื่อต้องการเปิดจริง ๆ",
        ["Presses FINISH after the chests you selected are opened."] = "กด FINISH หลังเปิดหีบที่เลือกครบแล้ว",
        ["Phase 1: mounts the wall cannon and shoots the Colossal Titan until the cutscene (Stall Bertholdt complete). Phase 2: the cannon stops so you can kill the Colossal."] = "เฟส 1: ขึ้นปืนใหญ่ประจำกำแพงและยิง Colossal Titan จนถึงคัตซีน (Stall Bertholdt สำเร็จ) เฟส 2: ปืนใหญ่หยุดยิงเพื่อให้คุณฆ่า Colossal",
        ["Phase 1: while the cannon shoots, Auto Farm also kills the titans that get close to Eren. Needs Auto Farm on."] = "เฟส 1: ขณะปืนใหญ่ยิง ฟาร์มอัตโนมัติจะฆ่าไททันที่เข้าใกล้ Eren ด้วย ต้องเปิดฟาร์มอัตโนมัติ",
        ["Keeps a wave room ready with these settings. Remembered next time."] = "เตรียมห้องเวฟไว้ตามค่าที่ตั้ง และจำค่าไว้ใช้ครั้งหน้า",
        ["Starts the wave in your room. Remembered next time."] = "เริ่มเวฟในห้องของคุณ และจำค่าไว้ใช้ครั้งหน้า",
        ["Shops automatically at the start of every new wave (the market refreshes each wave)."] = "ซื้อของอัตโนมัติเมื่อเริ่มทุกเวฟใหม่ (ตลาดรีเฟรชทุกเวฟ)",
        ["Allow your character to jump infinitely in the air."] = "ให้ตัวละครกระโดดกลางอากาศได้ไม่จำกัด",
        ["Prevent being kicked out of the game due to inactivity."] = "ป้องกันการถูกเตะออกจากเกมเพราะไม่ได้ขยับ",
        ["Automatically rejoin the game if disconnected or kicked."] = "เข้าเกมใหม่อัตโนมัติเมื่อหลุดหรือถูกเตะ",
        ["Automatically server hop if an admin joins the game."] = "ย้ายเซิร์ฟเวอร์อัตโนมัติเมื่อแอดมินเข้าเกม",
        ["Run the script again after teleporting or rejoining a server."] = "รันสคริปต์ซ้ำหลังเทเลพอร์ตหรือเข้าเซิร์ฟเวอร์ใหม่",
        ["Not supported by your executor."] = "executor ของคุณไม่รองรับ",
        ["Hide the menu automatically when the script runs. Tap the logo button or press the hotkey to open it."] = "ซ่อนเมนูอัตโนมัติเมื่อสคริปต์รัน แตะปุ่มโลโก้หรือกดปุ่มลัดเพื่อเปิด",
        ["Toggle frame rate limiting on or off."] = "เปิดหรือปิดการจำกัดเฟรมเรต",
        ["Deletes the map by itself every time you are in a mission."] = "ลบแมพเองทุกครั้งที่คุณอยู่ในภารกิจ",
        ["Copy current JobId to clipboard for friends to join."] = "คัดลอก JobId ปัจจุบันไปคลิปบอร์ดให้เพื่อนเข้าตาม",
        ["Go back to the main world (this map can't be rejoined directly)."] = "กลับไปโลกหลัก (แมพนี้เข้าซ้ำโดยตรงไม่ได้)",
        ["Teleport to a different server to find a new one."] = "เทเลพอร์ตไปเซิร์ฟเวอร์อื่นเพื่อหาเซิร์ฟเวอร์ใหม่",
        ["Save the current switches into the config in use."] = "บันทึกสวิตช์ปัจจุบันลงในคอนฟิกที่ใช้อยู่",
        ["Type a name, then press Create."] = "พิมพ์ชื่อ แล้วกดสร้าง",
        ["Save the current switches under the name above and start using it."] = "บันทึกสวิตช์ปัจจุบันภายใต้ชื่อด้านบนและเริ่มใช้งาน",
        ["Switch to the selected config and apply its switches."] = "สลับไปใช้คอนฟิกที่เลือกและใช้ค่าสวิตช์ของมัน",
        ["Delete the selected config."] = "ลบคอนฟิกที่เลือก",
        ["Reload the saved configs from file."] = "โหลดรายการคอนฟิกที่บันทึกไว้จากไฟล์ใหม่",
        ["Load the selected config automatically every time the script starts."] = "โหลดคอนฟิกที่เลือกอัตโนมัติทุกครั้งที่สคริปต์เริ่มทำงาน",
        ["Stop loading a config automatically."] = "เลิกโหลดคอนฟิกอัตโนมัติ",
        ["Set every switch, slider and the window look back to the default values (same as \"Smooth Hub | Default\"). Saved configs are NOT deleted."] = "ตั้งสวิตช์ สไลเดอร์ และหน้าตาหน้าต่างทั้งหมดกลับเป็นค่าเริ่มต้น (เหมือน \"Smooth Hub | Default\") คอนฟิกที่บันทึกไว้จะไม่ถูกลบ",
        ["Apply"] = "ใช้งาน",
        ["Apply Image"] = "ใช้รูปนี้",
        ["Boost Now"] = "บูสต์ตอนนี้",
        ["Copy"] = "คัดลอก",
        ["Delete"] = "ลบ",
        ["Execute"] = "สั่งทำงาน",
        ["Heal"] = "รักษา",
        ["Heal Now"] = "รักษาตอนนี้",
        ["Join"] = "เข้าร่วม",
        ["Join Now"] = "เข้าร่วมตอนนี้",
        ["Leave"] = "ออก",
        ["Leave Room"] = "ออกจากห้อง",
        ["Print"] = "พิมพ์",
        ["Refresh"] = "รีเฟรช",
        ["Reset"] = "รีเซ็ต",
        ["Reset Image"] = "รีเซ็ตรูป",
        ["Scan"] = "สแกน",
        ["Select"] = "เลือก",
        ["Select Now"] = "เลือกตอนนี้",
        ["Send Test"] = "ส่งทดสอบ",
        ["Shop"] = "ร้านค้า",
        ["Shop Now"] = "ช้อปตอนนี้",
        ["Test"] = "ทดสอบ",
        ["Upgrade"] = "อัปเกรด",
        ["Upgrade Now"] = "อัปเกรดตอนนี้",
        ["Copy Chest Debug"] = "คัดลอกดีบักหีบ",
        ["Copy Claim Debug"] = "คัดลอกดีบักการรับรางวัล",
        ["Scan Equipment (Debug)"] = "สแกนอุปกรณ์ (ดีบัก)",
        ["Scan Injuries (Debug)"] = "สแกนอาการบาดเจ็บ (ดีบัก)",
        ["Scan Shop (Debug)"] = "สแกนร้านค้า (ดีบัก)",
        ["Scan Upgrades (Debug)"] = "สแกนอัปเกรด (ดีบัก)",
        ["Delete Map"] = "ลบแมพ",
        ["Idle"] = "ว่าง",
        ["Ready"] = "พร้อม",
        ["Off"] = "ปิด",
        ["none"] = "ไม่มี",
        ["Hidden"] = "ซ่อนอยู่",
        ["No rolls yet."] = "ยังไม่มีการสุ่ม",
        ["Nothing rolled yet."] = "ยังไม่ได้สุ่มอะไร",
        ["Current action..."] = "การทำงานปัจจุบัน...",
        ["Accent Color"] = "สีเน้น",
        ["Theme Color"] = "สีธีม",
        ["Blur Effect"] = "เอฟเฟกต์เบลอ",
        ["Shadows Effect"] = "เอฟเฟกต์เงา",
        ["Minimize Hotkey"] = "ปุ่มลัดย่อหน้าต่าง",
        ["Auto Defend Status"] = "สถานะป้องกันอัตโนมัติ",
        ["Auto Play Status"] = "สถานะเล่นอัตโนมัติ",
        ["Best Grade Found"] = "เกรดที่ดีที่สุดที่พบ",
        ["Blade Upgrade Status"] = "สถานะอัปเกรดใบมีด",
        ["Boss Info"] = "ข้อมูลบอส",
        ["Boss Status"] = "สถานะบอส",
        ["Buy Order"] = "ลำดับการซื้อ",
        ["Cannon Status"] = "สถานะปืนใหญ่",
        ["Center Hotspot"] = "จุดคลิกตรงกลาง",
        ["Chest Status"] = "สถานะหีบ",
        ["Claim Status"] = "สถานะการรับรางวัล",
        ["Clear Status"] = "สถานะการเคลียร์",
        ["Config list"] = "รายการคอนฟิก",
        ["Config name"] = "ชื่อคอนฟิก",
        ["Cursor Size"] = "ขนาดเคอร์เซอร์",
        ["Custom Cursor"] = "เคอร์เซอร์กำหนดเอง",
        ["Enable Webhook"] = "เปิดใช้เว็บฮุค",
        ["Equipment Status"] = "สถานะอุปกรณ์",
        ["FPS Limit Preset"] = "พรีเซ็ตจำกัด FPS",
        ["Fail Safe Status"] = "สถานะกันสตรีค",
        ["Farm Status"] = "สถานะฟาร์ม",
        ["Heal Status"] = "สถานะการรักษา",
        ["Image Folder"] = "โฟลเดอร์รูป",
        ["Image Source"] = "แหล่งที่มาของรูป",
        ["Join Delay"] = "หน่วงเวลาเข้าร่วม",
        ["Keep Rarity"] = "เก็บความหายาก",
        ["Last Roll"] = "การสุ่มล่าสุด",
        ["Leave At Wave"] = "ออกเมื่อถึงเวฟ",
        ["List Size"] = "ขนาดรายการ",
        ["Loot Status"] = "สถานะการเก็บของ",
        ["Mission Status"] = "สถานะภารกิจ",
        ["Next Join"] = "การเข้าร่วมครั้งถัดไป",
        ["Next Mission"] = "ภารกิจถัดไป",
        ["Next Raid"] = "เรดถัดไป",
        ["Next Wave"] = "เวฟถัดไป",
        ["Only While Menu Is Open"] = "เฉพาะตอนเมนูเปิดอยู่",
        ["Raid Status"] = "สถานะเรด",
        ["Refill Status"] = "สถานะการเติมของ",
        ["Roll Status"] = "สถานะการสุ่ม",
        ["Rolled Families"] = "ตระกูลที่สุ่มได้",
        ["Routine Status"] = "สถานะรูทีน",
        ["Saved Rules"] = "กฎที่บันทึกไว้",
        ["Select Character"] = "เลือกตัวละคร",
        ["Select Modifiers"] = "เลือกตัวปรับแต่ง",
        ["Shop Status"] = "สถานะร้านค้า",
        ["Show Rolled Families"] = "แสดงตระกูลที่สุ่มได้",
        ["Skill Status"] = "สถานะสกิล",
        ["Skip Cutscene Status"] = "สถานะข้ามคัตซีน",
        ["Slot"] = "สล็อต",
        ["Spin Delay"] = "หน่วงเวลาสปิน",
        ["Spin Log"] = "ประวัติสปิน",
        ["Spin Status"] = "สถานะสปิน",
        ["Stop When 3 Cards Match"] = "หยุดเมื่อการ์ดตรงกัน 3 ใบ",
        ["Unlock Mouse In Menu"] = "ปลดล็อกเมาส์ในเมนู",
        ["Upgrade Priority"] = "ลำดับความสำคัญการอัปเกรด",
        ["Upgrade Status"] = "สถานะการอัปเกรด",
        ["Upgrades to Buy"] = "อัปเกรดที่จะซื้อ",
        ["Use Spin Delay"] = "ใช้หน่วงเวลาสปิน",
        ["Wait For Boss"] = "รอบอส",
        ["Wave Status"] = "สถานะเวฟ",
        ["Webhook Status"] = "สถานะเว็บฮุค",
        ["Webhook URL"] = "ลิงก์เว็บฮุค",
        ["When I Get A Keeper"] = "เมื่อได้ของที่ต้องการ",
        ["Your Gold"] = "ทองของคุณ",
        ["Auto Heal Injuries"] = "รักษาอาการบาดเจ็บอัตโนมัติ",
        ["Auto Join Lobby"] = "เข้าล็อบบี้อัตโนมัติ",
        ["Auto Loot Crate"] = "เก็บกล่องอัตโนมัติ",
        ["Auto Ready"] = "กดพร้อมอัตโนมัติ",
        ["Auto Refill [ Wave ]"] = "เติมของอัตโนมัติ [ เวฟ ]",
        ["Auto Roll Blessings"] = "สุ่มพรอัตโนมัติ",
        ["Auto Spin [ Lucky999+ ]"] = "สปินอัตโนมัติ [ Lucky999+ ]",
        ["Auto Upgrade Character"] = "อัปเกรดตัวละครอัตโนมัติ",
        ["Auto Upgrade [ Blades ] All"] = "อัปเกรด [ ใบมีด ] ทั้งหมดอัตโนมัติ",
        ["Auto Vote Skip"] = "โหวตข้ามอัตโนมัติ",
        ["Auto Clear Wave"] = "เคลียร์เวฟอัตโนมัติ",
        ["Auto Play"] = "เล่นอัตโนมัติ",
        ["Adjust the upgrade priority to determine which path you want to upgrade first."] = "ปรับลำดับความสำคัญเพื่อกำหนดว่าจะอัปเกรดสายไหนก่อน",
        ["Auto Farm / Clear Wave pause while the boss is missing, still loading (no body/nape, anchored) or just spawned."] = "ฟาร์ม/เคลียร์เวฟอัตโนมัติจะหยุดชั่วคราวเมื่อบอสยังไม่มา กำลังโหลด (ไม่มีตัว/ต้นคอ, ถูกตรึง) หรือเพิ่งเกิด",
        ["Auto loot your own crate (Crate_<your name>) with NoClip."] = "เก็บกล่องของตัวเอง (Crate_<ชื่อคุณ>) ด้วย NoClip อัตโนมัติ",
        ["Auto roll your family."] = "สุ่มตระกูลของคุณอัตโนมัติ",
        ["Auto upgrade the skill tree."] = "อัปเกรดต้นสกิลอัตโนมัติ",
        ["Auto-pick the best grade or boost mission."] = "เลือกเกรดที่ดีที่สุดหรือภารกิจบูสต์ให้อัตโนมัติ",
        ["Automatically enables NoClip while looting."] = "เปิด NoClip อัตโนมัติขณะเก็บของ",
        ["Automatically press SELECT on the chosen slot when the screen shows up."] = "กด SELECT ที่สล็อตที่เลือกอัตโนมัติเมื่อหน้าจอขึ้น",
        ["Automatically presses Ready on the vote to skip the wait between waves."] = "กดพร้อมในโหวตอัตโนมัติเพื่อข้ามการรอระหว่างเวฟ",
        ["Automatically presses Ready when the vote to start appears."] = "กดพร้อมอัตโนมัติเมื่อโหวตเริ่มปรากฏ",
        ["Automatically prestige and choose your boosts."] = "เพรสทีจและเลือกบูสต์ให้อัตโนมัติ",
        ["Automatically upgrade and equip your Blade, ODM gear and Thunder Spears."] = "อัปเกรดและสวมใบมีด อุปกรณ์ ODM และหอกสายฟ้าให้อัตโนมัติ",
        ["Choose a saved config."] = "เลือกคอนฟิกที่บันทึกไว้",
        ["Choose target frame rate limit."] = "เลือกค่าจำกัดเฟรมเรตเป้าหมาย",
        ["Choose which character slot to use (one at a time)."] = "เลือกสล็อตตัวละครที่จะใช้ (ทีละหนึ่ง)",
        ["Choose which families to keep."] = "เลือกตระกูลที่ต้องการเก็บ",
        ["Claims rewards the game shows as ready. Open the Quests / Achievements page to refresh them."] = "รับรางวัลที่เกมแสดงว่าพร้อมรับ เปิดหน้าเควสต์/ความสำเร็จเพื่อรีเฟรช",
        ["Click at the image center instead of its top-left corner."] = "คลิกที่กึ่งกลางรูปแทนมุมซ้ายบน",
        ["Configure advanced player modifications and tools."] = "ตั้งค่าการปรับแต่งผู้เล่นและเครื่องมือขั้นสูง",
        ["Copies the OPEN buttons it can see (send this if a chest is not opened)."] = "คัดลอกปุ่ม OPEN ที่มองเห็น (ส่งให้ผู้พัฒนาถ้าหีบไม่เปิด)",
        ["Copy all rolls to the clipboard."] = "คัดลอกผลการสุ่มทั้งหมดไปคลิปบอร์ด",
        ["Core features and settings"] = "ฟีเจอร์หลักและการตั้งค่า",
        ["Countdown to the next start."] = "นับถอยหลังถึงการเริ่มครั้งถัดไป",
        ["Countdown until the next join-lobby request."] = "นับถอยหลังถึงคำขอเข้าล็อบบี้ครั้งถัดไป",
        ["Counts the Waves Cleared shown in the objectives."] = "นับจำนวนเวฟที่เคลียร์ตามที่แสดงในเป้าหมาย",
        ["Counts wins while Auto Fail Safe is on."] = "นับจำนวนครั้งที่ชนะขณะเปิดระบบกันสตรีค",
        ["Crate looting and killing titans come first. Heal, upgrades, shop and blessings take turns in between and check your gold."] = "การเก็บกล่องและฆ่าไททันมาก่อน ส่วนรักษา อัปเกรด ร้านค้า และพรจะสลับทำตรงกลางและตรวจสอบทองของคุณ",
        ["Create your raid room first, then turn on Auto Start."] = "สร้างห้องเรดก่อน แล้วค่อยเปิดเริ่มอัตโนมัติ",
        ["Create your room first, then turn on Auto Start."] = "สร้างห้องก่อน แล้วค่อยเปิดเริ่มอัตโนมัติ",
        ["Create your wave room first, then turn on Auto Start."] = "สร้างห้องเวฟก่อน แล้วค่อยเปิดเริ่มอัตโนมัติ",
        ["Current step and last result."] = "ขั้นตอนปัจจุบันและผลลัพธ์ล่าสุด",
        ["Customize the appearance and visual style of the interface."] = "ปรับแต่งรูปลักษณ์และสไตล์ของหน้าจอ",
        ["Discord: Server Settings > Integrations > Webhooks > Copy URL. Keep it private."] = "Discord: Server Settings > Integrations > Webhooks > Copy URL เก็บเป็นความลับ",
        ["Display current server details and identifiers."] = "แสดงรายละเอียดและรหัสของเซิร์ฟเวอร์ปัจจุบัน",
        ["Don't fly to Youmii / Cole / Lulu / Orange / Roll unless you have at least this much gold (0 = off)."] = "ไม่บินไปหา Youmii / Cole / Lulu / Orange / Roll ถ้ามีทองน้อยกว่าค่านี้ (0 = ปิด)",
        ["Download / load the image and use it as the cursor."] = "ดาวน์โหลด/โหลดรูปแล้วใช้เป็นเคอร์เซอร์",
        ["Draw a virtual cursor on top of everything."] = "วาดเคอร์เซอร์เสมือนไว้เหนือทุกอย่าง",
        ["Enable frosted glass blur effect behind the window."] = "เปิดเอฟเฟกต์เบลอแบบกระจกฝ้าหลังหน้าต่าง",
        ["Enable smooth dropshadow around the script window."] = "เปิดเงาที่นุ่มนวลรอบหน้าต่างสคริปต์",
        ["Flies to the refill tank and presses R for you (mobile friendly)."] = "บินไปที่ถังเติมและกด R ให้ (รองรับมือถือ)",
        ["Free the mouse while the menu is open so you can click options."] = "ปล่อยเมาส์ขณะเมนูเปิดเพื่อให้คลิกตัวเลือกได้",
        ["Go back to the default Roblox arrow."] = "กลับไปใช้ลูกศร Roblox เริ่มต้น",
        ["Goes to Cole, opens Upgrades and buys the upgrades you picked (once every wave)."] = "ไปหา Cole เปิดหน้าอัปเกรด และซื้ออัปเกรดที่เลือก (ครั้งเดียวทุกเวฟ)",
        ["Goes to Lulu, opens Equipment and presses UPGRADE ALL for you (once every wave)."] = "ไปหา Lulu เปิดหน้าอุปกรณ์ และกด UPGRADE ALL ให้ (ครั้งเดียวทุกเวฟ)",
        ["Goes to Orange, opens the Market and clicks the cards for you (once every wave)."] = "ไปหา Orange เปิดตลาด และคลิกการ์ดให้ (ครั้งเดียวทุกเวฟ)",
        ["Goes to Roll and spins the Blessings machine whenever you have 2,000 gold or more."] = "ไปหา Roll และหมุนเครื่องสุ่มพรเมื่อมีทอง 2,000 ขึ้นไป",
        ["Goes to Youmii, opens Injuries and clicks Heal for you (once every wave)."] = "ไปหา Youmii เปิดหน้าอาการบาดเจ็บ และกดรักษาให้ (ครั้งเดียวทุกเวฟ)",
        ["Hidden. Turn on 'Show Rolled Families'."] = "ซ่อนอยู่ เปิด 'แสดงตระกูลที่สุ่มได้' เพื่อดู",
        ["Hide the virtual cursor when the menu is closed."] = "ซ่อนเคอร์เซอร์เสมือนเมื่อปิดเมนู",
        ["Highest difficulty the last room got."] = "ความยากสูงสุดที่ห้องล่าสุดได้",
        ["How long the boss must stay fully loaded before farming starts. Also how long to wait for a boss to appear after you spawn."] = "เวลาที่บอสต้องโหลดครบก่อนเริ่มฟาร์ม และเวลาที่รอบอสปรากฏหลังคุณเกิด",
        ["Keep missions from finishing too fast and break long win streaks"] = "ป้องกันภารกิจจบเร็วเกินไปจนสตรีคชนะยาวขาด",
        ["Keep this rarity or higher. Off = never stop for rarity."] = "เก็บความหายากนี้หรือสูงกว่า ปิด = ไม่หยุดตามความหายาก",
        ["Keeps pressing ROLL for you."] = "กด ROLL ซ้ำให้เรื่อย ๆ",
        ["Leave the current mission room."] = "ออกจากห้องภารกิจปัจจุบัน",
        ["Leave the current raid room."] = "ออกจากห้องเรดปัจจุบัน",
        ["Leave the current wave room."] = "ออกจากห้องเวฟปัจจุบัน",
        ["Leave the match once enough waves are cleared."] = "ออกจากแมตช์เมื่อเคลียร์เวฟครบตามกำหนด",
        ["Leave to the lobby when Waves Cleared reaches the number below."] = "ออกไปล็อบบี้เมื่อเวฟที่เคลียร์ถึงตัวเลขด้านล่าง",
        ["Limit the frame rate of the game."] = "จำกัดเฟรมเรตของเกม",
        ["Manage special visual styles for your script window."] = "จัดการสไตล์พิเศษของหน้าต่างสคริปต์",
        ["Map with the reward boost right now."] = "แมพที่มีบูสต์รางวัลอยู่ตอนนี้",
        ["Master switch. Wave features (Create, Start, Ready, Vote Skip, Clear Wave, Loot, Refill, Shop) only run while this is ON."] = "สวิตช์หลัก ฟีเจอร์โหมดเวฟ (สร้าง เริ่ม พร้อม โหวตข้าม เคลียร์เวฟ เก็บของ เติมของ ร้านค้า) จะทำงานเมื่อเปิดสวิตช์นี้เท่านั้น",
        ["Measured live so you can see whether the lock is working."] = "วัดสด ๆ เพื่อให้เห็นว่าการล็อกทำงานหรือไม่",
        ["Must be ON for Auto Create/Start Wave, Ready, Vote Skip, Clear Wave, Loot Crate, Refill and Shop to work. Turning it off pauses them all (your toggles stay as set)."] = "ต้องเปิดไว้เพื่อให้ สร้าง/เริ่มเวฟ พร้อม โหวตข้าม เคลียร์เวฟ เก็บกล่อง เติมของ และร้านค้า ทำงานได้ การปิดจะหยุดทั้งหมดชั่วคราว (สวิตช์ของคุณยังคงค่าเดิม)",
        ["On: wait after every roll. Off: go on as soon as the result shows."] = "เปิด: รอหลังสุ่มทุกครั้ง ปิด: ไปต่อทันทีที่ผลขึ้น",
        ["Only changes icons, switches and buttons. The background stays the same."] = "เปลี่ยนเฉพาะไอคอน สวิตช์ และปุ่ม พื้นหลังยังเหมือนเดิม",
        ["Only titans whose nape is within this distance of you are hit. Raise it if titans are not dying."] = "โจมตีเฉพาะไททันที่ต้นคออยู่ในระยะนี้ ถ้าไททันไม่ตายให้เพิ่มค่า",
        ["Open the Family page to see your current family live."] = "เปิดหน้า Family เพื่อดูตระกูลปัจจุบันของคุณแบบสด",
        ["Open the Quests page and click through its categories, then Achievements, then press Copy."] = "เปิดหน้าเควสต์ กดไล่ทุกหมวด จากนั้นเปิดความสำเร็จ แล้วกดคัดลอก",
        ["Order: Heal > Upgrade Character > Upgrade Blades > Shop > Blessings."] = "ลำดับ: รักษา > อัปเกรดตัวละคร > อัปเกรดใบมีด > ร้านค้า > พร",
        ["Paste an image link, a file name, or a Roblox asset id. PNG / JPG only."] = "วางลิงก์รูป ชื่อไฟล์ หรือ Roblox asset id รองรับเฉพาะ PNG / JPG",
        ["Pick one slot. The script presses its SELECT button for you."] = "เลือกหนึ่งสล็อต สคริปต์จะกดปุ่ม SELECT ให้",
        ["Pick the map and difficulty, then turn on Auto Create Wave."] = "เลือกแมพและความยาก แล้วเปิดสร้างห้องเวฟอัตโนมัติ",
        ["Pick the mission, objective, difficulty and modifiers for your room."] = "เลือกภารกิจ เป้าหมาย ความยาก และตัวปรับแต่งสำหรับห้องของคุณ",
        ["Pick which upgrades Cole should buy: Max HP, Regen, Replenish, Refills, Revive."] = "เลือกอัปเกรดที่ Cole จะซื้อ: Max HP, Regen, Replenish, Refills, Revive",
        ["Post to Discord when a match ends. Needs a valid Webhook URL."] = "ส่งไป Discord เมื่อแมตช์จบ ต้องมีลิงก์เว็บฮุคที่ถูกต้อง",
        ["Press SELECT on the chosen slot once."] = "กด SELECT ที่สล็อตที่เลือกหนึ่งครั้ง",
        ["Press to hide or show the window."] = "กดเพื่อซ่อนหรือแสดงหน้าต่าง",
        ["Presses Ready for you when the vote to start appears."] = "กดพร้อมให้เมื่อโหวตเริ่มปรากฏ",
        ["Presses your skill slot keys (1-5) for you. Instant = tap, Hold = hold the key."] = "กดปุ่มสล็อตสกิล (1-5) ให้ Instant = แตะ, Hold = กดค้าง",
        ["Prints the boss state to the Console (F9). Use it while the boss looks stuck and send it to me."] = "พิมพ์สถานะบอสลง Console (F9) ใช้ตอนบอสดูค้างแล้วส่งให้ผู้พัฒนา",
        ["Put your own PNG/JPG here, then type its file name above."] = "วางไฟล์ PNG/JPG ของคุณที่นี่ แล้วพิมพ์ชื่อไฟล์ด้านบน",
        ["Quick tools to copy identifiers or switch servers."] = "เครื่องมือด่วนสำหรับคัดลอกรหัสหรือสลับเซิร์ฟเวอร์",
        ["Raids start at Hard. Colossal Titan is Aberrant only."] = "เรดเริ่มที่ Hard ส่วน Colossal Titan มีเฉพาะ Aberrant",
        ["Read from the HUD."] = "อ่านจาก HUD",
        ["Read from your player data. N/A = this value was not found."] = "อ่านจากข้อมูลผู้เล่นของคุณ N/A = ไม่พบค่านี้",
        ["Recent rolls to show (5 - 100)."] = "จำนวนการสุ่มล่าสุดที่จะแสดง (5 - 100)",
        ["Removes buildings, trees and walls on YOUR screen only, to cut lag. Rejoin to get the map back."] = "ลบอาคาร ต้นไม้ และกำแพงเฉพาะบนหน้าจอของคุณ เพื่อลดแลค เข้าเกมใหม่เพื่อให้แมพกลับมา",
        ["Result of the last apply."] = "ผลลัพธ์ของการใช้งานล่าสุด",
        ["Result of the last request."] = "ผลลัพธ์ของคำขอล่าสุด",
        ["Result of the last send."] = "ผลลัพธ์ของการส่งล่าสุด",
        ["Rewards claimed since the script started."] = "รางวัลที่รับตั้งแต่สคริปต์เริ่มทำงาน",
        ["Rolls (2,000 gold each) while your gold is 2,000 or more, then flies back to your spot."] = "สุ่ม (ครั้งละ 2,000 ทอง) ขณะมีทอง 2,000 ขึ้นไป แล้วบินกลับที่เดิม",
        ["Run one shopping round right now."] = "ช้อปหนึ่งรอบตอนนี้",
        ["Same blade attacks as Auto Farm [ Blades ], but you stay where you are."] = "โจมตีด้วยใบมีดเหมือนฟาร์มอัตโนมัติ [ ใบมีด ] แต่คุณอยู่ที่เดิม",
        ["Save your settings under a name (e.g. FarmBoss)."] = "บันทึกการตั้งค่าของคุณภายใต้ชื่อหนึ่ง (เช่น FarmBoss)",
        ["Seconds to wait after each roll (0.5 - 10)."] = "วินาทีที่รอหลังสุ่มแต่ละครั้ง (0.5 - 10)",
        ["Send one test message now."] = "ส่งข้อความทดสอบหนึ่งข้อความตอนนี้",
        ["Send the join-lobby request every Join Delay seconds."] = "ส่งคำขอเข้าล็อบบี้ทุก ๆ ตามวินาทีของหน่วงเวลาเข้าร่วม",
        ["Send the join-lobby request once."] = "ส่งคำขอเข้าล็อบบี้หนึ่งครั้ง",
        ["Send your config to friends with a short code, or import one. Codes hold only your switches (no Webhook URL)."] = "ส่งคอนฟิกให้เพื่อนด้วยรหัสสั้น หรือนำเข้ารหัสของคนอื่น รหัสเก็บเฉพาะสวิตช์ของคุณ (ไม่รวมลิงก์เว็บฮุค)",
        ["Sends a reward summary to Discord every time a match ends (MISSION COMPLETED screen)."] = "ส่งสรุปรางวัลไป Discord ทุกครั้งที่แมตช์จบ (หน้าจอ MISSION COMPLETED)",
        ["Set a priority for each memory (0 - 10)."] = "ตั้งลำดับความสำคัญของแต่ละ memory (0 - 10)",
        ["Shoots the wall cannon at the Colossal Titan's nape."] = "ยิงปืนใหญ่ประจำกำแพงใส่ต้นคอ Colossal Titan",
        ["Show or hide the list."] = "แสดงหรือซ่อนรายการ",
        ["Size in pixels (12 - 128)."] = "ขนาดเป็นพิกเซล (12 - 128)",
        ["Skip cutscenes and open the reward chest by pressing the real buttons."] = "ข้ามคัตซีนและเปิดหีบรางวัลโดยกดปุ่มจริงในเกม",
        ["Spawned / loading / ready."] = "เกิดแล้ว / กำลังโหลด / พร้อม",
        ["Stand still and kill titans in range - no flying to them. Turns Auto Farm [ Blades ] and [ TS ] off while it is on."] = "ยืนนิ่งและฆ่าไททันในระยะ ไม่บินไปหา จะปิดฟาร์มอัตโนมัติ [ ใบมีด ] และ [ TS ] ขณะเปิดอยู่",
        ["Stop, store it and keep rolling, or ask me."] = "หยุด เก็บไว้แล้วสุ่มต่อ หรือถามฉัน",
        ["Stops rolling (and turns Auto Roll off) as soon as the machine lands 3 matching cards and shows a reward."] = "หยุดสุ่ม (และปิดสุ่มอัตโนมัติ) ทันทีที่เครื่องได้การ์ดตรงกัน 3 ใบและแสดงรางวัล",
        ["Tap a family to add / remove"] = "แตะตระกูลเพื่อเพิ่ม / ลบ",
        ["The essentials - turn these on and go"] = "ของจำเป็น เปิดแล้วเล่นได้เลย",
        ["The shortcut that hides and shows the window."] = "ปุ่มลัดที่ซ่อนและแสดงหน้าต่าง",
        ["The specific place ID of this server instance."] = "Place ID เฉพาะของเซิร์ฟเวอร์นี้",
        ["The unique ID of this game universe."] = "รหัสเฉพาะของจักรวาลเกมนี้",
        ["The whole palette, not just light or dark."] = "ทั้งชุดสี ไม่ใช่แค่โหมดสว่างหรือมืด",
        ["Tick the Modifiers to apply after creating."] = "ติ๊กตัวปรับแต่งที่จะใช้หลังสร้างห้อง",
        ["Titans closer than this to Eren (studs) are killed first."] = "ไททันที่อยู่ใกล้ Eren กว่าระยะนี้ (studs) จะถูกฆ่าก่อน",
        ["Used when you cannot afford everything."] = "ใช้เมื่อคุณมีเงินไม่พอซื้อทุกอย่าง",
        ["Virtual cursor you can see and click with, even when the game locks your mouse."] = "เคอร์เซอร์เสมือนที่มองเห็นและคลิกได้ แม้เกมจะล็อกเมาส์",
        ["Visit Cole and buy the selected upgrades right now."] = "ไปหา Cole และซื้ออัปเกรดที่เลือกตอนนี้",
        ["Visit Lulu and press UPGRADE ALL right now."] = "ไปหา Lulu และกด UPGRADE ALL ตอนนี้",
        ["Visit Youmii and heal right now."] = "ไปหา Youmii และรักษาตอนนี้",
        ["Visits Cole at the start of every new wave and buys the selected upgrades while you have enough gold."] = "ไปหา Cole เมื่อเริ่มทุกเวฟใหม่ และซื้ออัปเกรดที่เลือกตราบที่ทองพอ",
        ["Visits Lulu at the start of every new wave and upgrades all your blade stats while you have enough gold."] = "ไปหา Lulu เมื่อเริ่มทุกเวฟใหม่ และอัปเกรดสเตตัสใบมีดทั้งหมดตราบที่ทองพอ",
        ["Visits Youmii at the start of every new wave and heals broken arms / legs (needs enough gold)."] = "ไปหา Youmii เมื่อเริ่มทุกเวฟใหม่ และรักษาแขน/ขาที่หัก (ต้องมีทองพอ)",
        ["Waits until the raid boss is fully spawned before Auto Farm starts, so you don't farm while the boss is still loading or frozen."] = "รอจนบอสเรดเกิดครบก่อนเริ่มฟาร์มอัตโนมัติ เพื่อไม่ให้ฟาร์มตอนบอสยังโหลดหรือค้างอยู่",
        ["What Auto Cannon is doing."] = "ปืนใหญ่อัตโนมัติกำลังทำอะไร",
        ["What Auto Defend is doing."] = "ป้องกันอัตโนมัติกำลังทำอะไร",
        ["What Auto Farm is doing right now, and why it is paused."] = "ฟาร์มอัตโนมัติกำลังทำอะไรอยู่ และเหตุผลที่หยุดชั่วคราว",
        ["What Auto Open Chest sees right now."] = "สิ่งที่เปิดหีบอัตโนมัติมองเห็นตอนนี้",
        ["What Auto Skip Cutscene is doing."] = "ข้ามคัตซีนอัตโนมัติกำลังทำอะไร",
        ["What Auto Spin is doing now."] = "สปินอัตโนมัติกำลังทำอะไรอยู่",
        ["What the script is doing right now."] = "สคริปต์กำลังทำอะไรอยู่",
        ["What to do when a mission ends"] = "สิ่งที่จะทำเมื่อภารกิจจบ",
        ["When your blades / Thunder Spears run out, goes to the nearest tank, refills, then flies back."] = "เมื่อใบมีด/หอกสายฟ้าหมด จะไปที่ถังที่ใกล้ที่สุด เติมของ แล้วบินกลับ",
        ["Which parts are running."] = "ส่วนที่กำลังทำงานอยู่",
        ["With the Equipment window open: prints every visible text/button to the F9 console."] = "เมื่อเปิดหน้าอุปกรณ์: พิมพ์ข้อความ/ปุ่มที่มองเห็นทั้งหมดลงคอนโซล F9",
        ["With the Injuries window open: prints every visible text/button to the F9 console."] = "เมื่อเปิดหน้าอาการบาดเจ็บ: พิมพ์ข้อความ/ปุ่มที่มองเห็นทั้งหมดลงคอนโซล F9",
        ["With the Market open: prints every card (name, stars, price, stock) to the F9 console."] = "เมื่อเปิดตลาด: พิมพ์ทุกการ์ด (ชื่อ ดาว ราคา สต็อก) ลงคอนโซล F9",
        ["With the Upgrades window open: prints every visible text/button to the F9 console."] = "เมื่อเปิดหน้าอัปเกรด: พิมพ์ข้อความ/ปุ่มที่มองเห็นทั้งหมดลงคอนโซล F9",
        ["Your roll history."] = "ประวัติการสุ่มของคุณ",
        ["Smooth Hub - Auto Spin"] = "Smooth Hub - สปินอัตโนมัติ",
    },
    ES = {
        ["Menu"] = "Menú",
        ["Menu Lobby"] = "Menú Lobby",
        ["Status"] = "Estado",
        ["Account"] = "Cuenta",
        ["In-Game"] = "En Partida",
        ["Lobby"] = "Lobby",
        ["Game Mode"] = "Modo de Juego",
        ["Misc"] = "Varios",
        ["Auto Farm"] = "Auto Farmeo",
        ["Auto Quest"] = "Auto Misiones",
        ["Auto Skill"] = "Auto Habilidad",
        ["Progression"] = "Progresión",
        ["Skill Trees"] = "Árboles de Habilidad",
        ["Perks"] = "Ventajas",
        ["Missions"] = "Misiones",
        ["Wave Mode"] = "Modo Oleadas",
        ["Raid Mode"] = "Modo Raid",
        ["Advanced"] = "Avanzado",
        ["Server"] = "Servidor",
        ["Windows"] = "Ventana",
        ["Config"] = "Config",
        ["Cursor"] = "Cursor",
        ["Language"] = "Idioma",
        ["Settings\u{200B}"] = "Ajustes\u{200B}",
        ["⌨️ Input"] = "⌨️ Entrada",
        ["▶️ Auto Play"] = "▶️ Auto Jugar",
        ["⚔️ Auto Clear Wave"] = "⚔️ Auto Limpiar Oleada",
        ["⚔️ Auto Farm"] = "⚔️ Auto Farmeo",
        ["⚔️ Equipment"] = "⚔️ Equipo",
        ["⚔️ Raid Settings"] = "⚔️ Ajustes de Raid",
        ["⚙️ Advanced Settings"] = "⚙️ Ajustes Avanzados",
        ["⚙️ After the Match"] = "⚙️ Después de la Partida",
        ["⚙️ Settings Roll"] = "⚙️ Ajustes de Sorteo",
        ["⛽ Auto Refill [ Wave ]"] = "⛽ Auto Recarga [ Oleada ]",
        ["✅ Auto Ready"] = "✅ Auto Listo",
        ["✨ Windows Effects"] = "✨ Efectos de Ventana",
        ["⬆️ Auto Upgrade Character [ Cole ]"] = "⬆️ Auto Mejorar Personaje [ Cole ]",
        ["🌊 Wave Settings"] = "🌊 Ajustes de Oleada",
        ["🌐 Server Information"] = "🌐 Información del Servidor",
        ["🎁 Auto Claim"] = "🎁 Auto Reclamar",
        ["🎁 Raid Extras"] = "🎁 Extras de Raid",
        ["🎨 Customs Color"] = "🎨 Colores Personalizados",
        ["🎭 Character Selection"] = "🎭 Selección de Personaje",
        ["🎯 Auto Skill"] = "🎯 Auto Habilidad",
        ["🎰 Auto Roll Blessings [ Roll ]"] = "🎰 Auto Sorteo de Bendiciones [ Roll ]",
        ["🎰 Roll Family"] = "🎰 Sortear Familia",
        ["🏰 Colossal Titan"] = "🏰 Titán Colosal",
        ["👑 Prestige Section"] = "👑 Sección de Prestigio",
        ["💾 Server Actions"] = "💾 Acciones del Servidor",
        ["📁 Configuration"] = "📁 Configuración",
        ["📊 Account Overview"] = "📊 Resumen de la Cuenta",
        ["📋 Status"] = "📋 Estado",
        ["📜 Mission Settings"] = "📜 Ajustes de Misión",
        ["📜 Show Roll"] = "📜 Mostrar Sorteo",
        ["📤 Share config"] = "📤 Compartir config",
        ["📦 Auto Loot Crate"] = "📦 Auto Recoger Caja",
        ["🔔 Webhook"] = "🔔 Webhook",
        ["🔨 Crafting"] = "🔨 Fabricación",
        ["🖱️ Mouse cursor"] = "🖱️ Cursor del ratón",
        ["🖼️ Cursor image"] = "🖼️ Imagen del cursor",
        ["🗡️ Auto Upgrade [ Blades ] All"] = "🗡️ Auto Mejorar [ Espadas ] Todo",
        ["🚀 Advance Missions"] = "🚀 Misiones Avanzadas",
        ["🚪 Auto Join Lobby"] = "🚪 Auto Unirse al Lobby",
        ["🚪 Leave At Wave"] = "🚪 Salir en Oleada",
        ["🛒 Auto Shop [ Orange ]"] = "🛒 Auto Tienda [ Orange ]",
        ["🛟 Safety"] = "🛟 Seguridad",
        ["🛠️ Auto Quest"] = "🛠️ Auto Misiones",
        ["🛰️ Boss Check"] = "🛰️ Revisión del Jefe",
        ["🤖 Auto Mission"] = "🤖 Auto Misión",
        ["🤖 Auto Raid"] = "🤖 Auto Raid",
        ["🤖 Auto Wave"] = "🤖 Auto Oleada",
        ["🧠 Memories Priority"] = "🧠 Prioridad de Memories",
        ["🧭 Wave Routine"] = "🧭 Rutina de Oleada",
        ["🩹 Auto Heal Injuries [ Youmii ]"] = "🩹 Auto Curar Heridas [ Youmii ]",
        ["Auto Farm [ Blades ]"] = "Auto Farmeo [ Espadas ]",
        ["Auto Farm [ Thunder Spears ]"] = "Auto Farmeo [ Lanzas de Trueno ]",
        ["Bypass Farm (No Shadow Ban)"] = "Farmeo Bypass (Sin Shadow Ban)",
        ["Auto Reload"] = "Auto Recargar",
        ["Auto Refills [ Blade ]"] = "Auto Rellenar [ Espada ]",
        ["Auto Refills [ Thunder Spears ]"] = "Auto Rellenar [ Lanzas de Trueno ]",
        ["Damage Multiplier ( x10 )"] = "Multiplicador de Daño ( x10 )",
        ["Auto Retry"] = "Auto Reintentar",
        ["Auto Leave"] = "Auto Salir",
        ["Auto Leave After X Matches"] = "Auto Salir Tras X Partidas",
        ["Auto Fail Safe"] = "Auto Seguro de Racha",
        ["Auto Claim Main Quests"] = "Auto Reclamar Misiones Principales",
        ["Auto Claim Side Quests"] = "Auto Reclamar Misiones Secundarias",
        ["Auto Claim Achievements"] = "Auto Reclamar Logros",
        ["Auto Claim Weekly Quests"] = "Auto Reclamar Misiones Semanales",
        ["Auto Claim Daily Quests"] = "Auto Reclamar Misiones Diarias",
        ["Auto Open Pages"] = "Auto Abrir Páginas",
        ["Auto Upgrade Gear ( Blade )"] = "Auto Mejorar Equipo ( Espada )",
        ["Auto Upgrade Gear ( Thunder Spears )"] = "Auto Mejorar Equipo ( Lanzas de Trueno )",
        ["Auto Equip Blade"] = "Auto Equipar Espada",
        ["Auto Equip Thunder Spears"] = "Auto Equipar Lanzas de Trueno",
        ["Auto Prestige"] = "Auto Prestigio",
        ["Auto Upgrade Skills"] = "Auto Mejorar Habilidades",
        ["Left"] = "Izquierda",
        ["Middle"] = "Centro",
        ["Right"] = "Derecha",
        ["Auto Craft Perks"] = "Auto Fabricar Ventajas",
        ["Auto Create Mission"] = "Auto Crear Misión",
        ["Auto Start Missions"] = "Auto Iniciar Misiones",
        ["Auto Select Best Grade"] = "Auto Elegir Mejor Grado",
        ["Auto Select Boost Mission"] = "Auto Elegir Misión con Bonus",
        ["Auto Create Raid"] = "Auto Crear Raid",
        ["Auto Start Raid"] = "Auto Iniciar Raid",
        ["Auto Skip Cutscene"] = "Auto Saltar Escena",
        ["Auto Open Chest (Free)"] = "Auto Abrir Cofre (Gratis)",
        ["Auto Open Chest (Premium)"] = "Auto Abrir Cofre (Premium)",
        ["Auto Finish Chest"] = "Auto Terminar Cofre",
        ["Auto Cannon (Colossal Titan)"] = "Auto Cañón (Titán Colosal)",
        ["Auto Defend (only Eren Thunder Spears)"] = "Auto Defender (solo Eren Lanzas de Trueno)",
        ["Auto Create Wave"] = "Auto Crear Oleada",
        ["Auto Start Waves"] = "Auto Iniciar Oleadas",
        ["Auto Shop [ Orange ]"] = "Auto Tienda [ Orange ]",
        ["Infinite Jump"] = "Salto Infinito",
        ["Anti-AFK"] = "Anti-AFK",
        ["Auto Rejoin"] = "Auto Reconectar",
        ["Anti Admin"] = "Anti Admin",
        ["Auto Execute"] = "Auto Ejecutar",
        ["Auto Hide Menu"] = "Auto Ocultar Menú",
        ["Enable FPS Lock"] = "Activar Límite de FPS",
        ["Auto Delete Map"] = "Auto Borrar Mapa",
        ["Copy JobId"] = "Copiar JobId",
        ["Rejoin Server"] = "Reentrar al Servidor",
        ["Server Hop"] = "Cambiar de Servidor",
        ["Enter Save Config"] = "Guardar Config en Uso",
        ["Create config"] = "Crear config",
        ["Load config"] = "Cargar config",
        ["Delete config"] = "Borrar config",
        ["Refresh list"] = "Actualizar lista",
        ["Set as autoload"] = "Poner como autocarga",
        ["Reset autoload"] = "Quitar autocarga",
        ["Reset to defaults"] = "Restablecer valores",
        ["Automatically completes missions with Blades."] = "Completa misiones automáticamente con Espadas.",
        ["Automatically completes missions with Thunder Spears."] = "Completa misiones automáticamente con Lanzas de Trueno.",
        ["Reloads your blades when they run out."] = "Recarga tus espadas cuando se agotan.",
        ["Refills at the station when your blades are out and no spare blades are left."] = "Rellena en la estación cuando se acaban las espadas y no quedan de repuesto.",
        ["Refills at the station when your Thunder Spears run out."] = "Rellena en la estación cuando se acaban tus Lanzas de Trueno.",
        ["Deal 10x damage to Titans."] = "Haces 10 veces más daño a los Titanes.",
        ["Automatically Retry when completed."] = "Reintenta automáticamente al terminar.",
        ["Leave to the lobby right when the match ends."] = "Vuelve al lobby justo cuando termina la partida.",
        ["Retry up to the Retry Amount, then leave (needs Auto Retry). Not together with Auto Leave."] = "Reintenta hasta la cantidad indicada y luego sale (requiere Auto Reintentar). No usar junto con Auto Salir.",
        ["Auto-jumps while farming so your gas gets used."] = "Salta automáticamente mientras farmeas para gastar gas.",
        ["Matches to retry before leaving (used by Auto Leave After X Matches)."] = "Partidas a reintentar antes de salir (usado por Auto Salir Tras X Partidas).",
        ["When the win streak reaches the number above, the next match is lost on purpose: you stand still and let the titans kill you, then the streak resets."] = "Cuando la racha de victorias llega al número de arriba, la siguiente partida se pierde a propósito: te quedas quieto y los titanes te matan, y la racha se reinicia.",
        ["Automatically claim the main quests."] = "Reclama las misiones principales automáticamente.",
        ["Automatically claim the side quests."] = "Reclama las misiones secundarias automáticamente.",
        ["Automatically claim achievements."] = "Reclama los logros automáticamente.",
        ["Automatically claim the weekly quests."] = "Reclama las misiones semanales automáticamente.",
        ["Automatically claim the daily quests."] = "Reclama las misiones diarias automáticamente.",
        ["When the game shows the red ! on the Achievements icon, open that page, claim, then close it (like a player)."] = "Cuando el juego muestra el ! rojo en el icono de Logros, abre esa página, reclama y la cierra (como un jugador).",
        ["Automatically upgrade BLADE & ODM."] = "Mejora automáticamente ESPADA y ODM.",
        ["Automatically upgrade thunder spears."] = "Mejora automáticamente las lanzas de trueno.",
        ["Automatically equip blades."] = "Equipa las espadas automáticamente.",
        ["Automatically equip thunder spears."] = "Equipa las lanzas de trueno automáticamente.",
        ["Automatically prestige."] = "Hace prestigio automáticamente.",
        ["Automatically upgrade skills tree."] = "Mejora el árbol de habilidades automáticamente.",
        ["Upgrade the left path."] = "Mejora el camino izquierdo.",
        ["Upgrade the middle path."] = "Mejora el camino central.",
        ["Upgrade the right path."] = "Mejora el camino derecho.",
        ["Automatically craft perks."] = "Fabrica ventajas automáticamente.",
        ["Keeps a room ready with these settings. Remembered next time."] = "Mantiene una sala lista con estos ajustes. Se recuerda para la próxima vez.",
        ["Starts the mission in your room. Remembered next time."] = "Inicia la misión en tu sala. Se recuerda para la próxima vez.",
        ["Creates the highest difficulty you can play."] = "Crea la dificultad más alta que puedes jugar.",
        ["Creates the map that has the reward boost now."] = "Crea el mapa que tiene el bonus de recompensa ahora.",
        ["Keeps a raid room ready with these settings. Remembered next time."] = "Mantiene una sala de raid lista con estos ajustes. Se recuerda para la próxima vez.",
        ["Starts the raid in your room. Remembered next time."] = "Inicia la raid en tu sala. Se recuerda para la próxima vez.",
        ["Presses SKIP [E] on cutscenes once your character has loaded."] = "Pulsa SKIP [E] en las escenas cuando tu personaje haya cargado.",
        ["Presses OPEN on the Free chest when the chest screen shows."] = "Pulsa OPEN en el cofre gratis cuando aparece la pantalla de cofres.",
        ["Presses OPEN on the Premium chest. Only turn on if you want to open it."] = "Pulsa OPEN en el cofre Premium. Actívalo solo si quieres abrirlo.",
        ["Presses FINISH after the chests you selected are opened."] = "Pulsa FINISH después de abrir los cofres que elegiste.",
        ["Phase 1: mounts the wall cannon and shoots the Colossal Titan until the cutscene (Stall Bertholdt complete). Phase 2: the cannon stops so you can kill the Colossal."] = "Fase 1: sube al cañón de la muralla y dispara al Titán Colosal hasta la escena (Stall Bertholdt completado). Fase 2: el cañón se detiene para que mates al Colosal.",
        ["Phase 1: while the cannon shoots, Auto Farm also kills the titans that get close to Eren. Needs Auto Farm on."] = "Fase 1: mientras el cañón dispara, el Auto Farmeo también mata a los titanes que se acercan a Eren. Requiere Auto Farmeo activado.",
        ["Keeps a wave room ready with these settings. Remembered next time."] = "Mantiene una sala de oleadas lista con estos ajustes. Se recuerda para la próxima vez.",
        ["Starts the wave in your room. Remembered next time."] = "Inicia la oleada en tu sala. Se recuerda para la próxima vez.",
        ["Shops automatically at the start of every new wave (the market refreshes each wave)."] = "Compra automáticamente al inicio de cada oleada (el mercado se renueva cada oleada).",
        ["Allow your character to jump infinitely in the air."] = "Permite que tu personaje salte infinitamente en el aire.",
        ["Prevent being kicked out of the game due to inactivity."] = "Evita que te expulsen del juego por inactividad.",
        ["Automatically rejoin the game if disconnected or kicked."] = "Vuelve a entrar al juego automáticamente si te desconectan o expulsan.",
        ["Automatically server hop if an admin joins the game."] = "Cambia de servidor automáticamente si un admin entra al juego.",
        ["Run the script again after teleporting or rejoining a server."] = "Vuelve a ejecutar el script tras teletransportarte o reentrar a un servidor.",
        ["Not supported by your executor."] = "Tu executor no lo soporta.",
        ["Hide the menu automatically when the script runs. Tap the logo button or press the hotkey to open it."] = "Oculta el menú automáticamente al ejecutar el script. Toca el botón del logo o pulsa el atajo para abrirlo.",
        ["Toggle frame rate limiting on or off."] = "Activa o desactiva el límite de fotogramas.",
        ["Deletes the map by itself every time you are in a mission."] = "Borra el mapa solo cada vez que estás en una misión.",
        ["Copy current JobId to clipboard for friends to join."] = "Copia el JobId actual al portapapeles para que tus amigos se unan.",
        ["Go back to the main world (this map can't be rejoined directly)."] = "Vuelve al mundo principal (este mapa no se puede reentrar directamente).",
        ["Teleport to a different server to find a new one."] = "Teletranspórtate a otro servidor para encontrar uno nuevo.",
        ["Save the current switches into the config in use."] = "Guarda los interruptores actuales en la config en uso.",
        ["Type a name, then press Create."] = "Escribe un nombre y pulsa Crear.",
        ["Save the current switches under the name above and start using it."] = "Guarda los interruptores actuales con el nombre de arriba y empieza a usarla.",
        ["Switch to the selected config and apply its switches."] = "Cambia a la config seleccionada y aplica sus interruptores.",
        ["Delete the selected config."] = "Borra la config seleccionada.",
        ["Reload the saved configs from file."] = "Recarga las configs guardadas desde el archivo.",
        ["Load the selected config automatically every time the script starts."] = "Carga la config seleccionada automáticamente cada vez que inicia el script.",
        ["Stop loading a config automatically."] = "Deja de cargar una config automáticamente.",
        ["Set every switch, slider and the window look back to the default values (same as \"Smooth Hub | Default\"). Saved configs are NOT deleted."] = "Devuelve todos los interruptores, deslizadores y el aspecto de la ventana a sus valores por defecto (igual que \"Smooth Hub | Default\"). Las configs guardadas NO se borran.",
        ["Apply"] = "Aplicar",
        ["Apply Image"] = "Aplicar Imagen",
        ["Boost Now"] = "Activar Bonus Ahora",
        ["Copy"] = "Copiar",
        ["Delete"] = "Borrar",
        ["Execute"] = "Ejecutar",
        ["Heal"] = "Curar",
        ["Heal Now"] = "Curar Ahora",
        ["Join"] = "Unirse",
        ["Join Now"] = "Unirse Ahora",
        ["Leave"] = "Salir",
        ["Leave Room"] = "Salir de la Sala",
        ["Print"] = "Imprimir",
        ["Refresh"] = "Actualizar",
        ["Reset"] = "Restablecer",
        ["Reset Image"] = "Restablecer Imagen",
        ["Scan"] = "Escanear",
        ["Select"] = "Elegir",
        ["Select Now"] = "Elegir Ahora",
        ["Send Test"] = "Enviar Prueba",
        ["Shop"] = "Tienda",
        ["Shop Now"] = "Comprar Ahora",
        ["Test"] = "Probar",
        ["Upgrade"] = "Mejorar",
        ["Upgrade Now"] = "Mejorar Ahora",
        ["Copy Chest Debug"] = "Copiar Debug de Cofre",
        ["Copy Claim Debug"] = "Copiar Debug de Reclamo",
        ["Scan Equipment (Debug)"] = "Escanear Equipo (Debug)",
        ["Scan Injuries (Debug)"] = "Escanear Heridas (Debug)",
        ["Scan Shop (Debug)"] = "Escanear Tienda (Debug)",
        ["Scan Upgrades (Debug)"] = "Escanear Mejoras (Debug)",
        ["Delete Map"] = "Borrar Mapa",
        ["Idle"] = "Inactivo",
        ["Ready"] = "Listo",
        ["Off"] = "Apagado",
        ["none"] = "ninguno",
        ["Hidden"] = "Oculto",
        ["No rolls yet."] = "Aún no hay sorteos.",
        ["Nothing rolled yet."] = "Aún no se ha sorteado nada.",
        ["Current action..."] = "Acción actual...",
        ["Accent Color"] = "Color de Acento",
        ["Theme Color"] = "Color del Tema",
        ["Blur Effect"] = "Efecto de Desenfoque",
        ["Shadows Effect"] = "Efecto de Sombras",
        ["Minimize Hotkey"] = "Atajo para Minimizar",
        ["Auto Defend Status"] = "Estado de Auto Defensa",
        ["Auto Play Status"] = "Estado de Auto Jugar",
        ["Best Grade Found"] = "Mejor Grado Encontrado",
        ["Blade Upgrade Status"] = "Estado de Mejora de Espadas",
        ["Boss Info"] = "Info del Jefe",
        ["Boss Status"] = "Estado del Jefe",
        ["Buy Order"] = "Orden de Compra",
        ["Cannon Status"] = "Estado del Cañón",
        ["Center Hotspot"] = "Punto Activo al Centro",
        ["Chest Status"] = "Estado del Cofre",
        ["Claim Status"] = "Estado de Reclamo",
        ["Clear Status"] = "Estado de Limpieza",
        ["Config list"] = "Lista de configs",
        ["Config name"] = "Nombre de la config",
        ["Cursor Size"] = "Tamaño del Cursor",
        ["Custom Cursor"] = "Cursor Personalizado",
        ["Enable Webhook"] = "Activar Webhook",
        ["Equipment Status"] = "Estado del Equipo",
        ["FPS Limit Preset"] = "Preset de Límite de FPS",
        ["Fail Safe Status"] = "Estado del Seguro de Racha",
        ["Farm Status"] = "Estado del Farmeo",
        ["Heal Status"] = "Estado de Curación",
        ["Image Folder"] = "Carpeta de Imágenes",
        ["Image Source"] = "Origen de la Imagen",
        ["Join Delay"] = "Retraso para Unirse",
        ["Keep Rarity"] = "Conservar Rareza",
        ["Last Roll"] = "Último Sorteo",
        ["Leave At Wave"] = "Salir en la Oleada",
        ["List Size"] = "Tamaño de la Lista",
        ["Loot Status"] = "Estado de Recolección",
        ["Mission Status"] = "Estado de la Misión",
        ["Next Join"] = "Próxima Unión",
        ["Next Mission"] = "Próxima Misión",
        ["Next Raid"] = "Próxima Raid",
        ["Next Wave"] = "Próxima Oleada",
        ["Only While Menu Is Open"] = "Solo con el Menú Abierto",
        ["Raid Status"] = "Estado de la Raid",
        ["Refill Status"] = "Estado de Recarga",
        ["Roll Status"] = "Estado del Sorteo",
        ["Rolled Families"] = "Familias Sorteadas",
        ["Routine Status"] = "Estado de la Rutina",
        ["Saved Rules"] = "Reglas Guardadas",
        ["Select Character"] = "Elegir Personaje",
        ["Select Modifiers"] = "Elegir Modificadores",
        ["Shop Status"] = "Estado de la Tienda",
        ["Show Rolled Families"] = "Mostrar Familias Sorteadas",
        ["Skill Status"] = "Estado de Habilidades",
        ["Skip Cutscene Status"] = "Estado de Saltar Escena",
        ["Slot"] = "Ranura",
        ["Spin Delay"] = "Retraso de Giro",
        ["Spin Log"] = "Registro de Giros",
        ["Spin Status"] = "Estado de Giro",
        ["Stop When 3 Cards Match"] = "Parar con 3 Cartas Iguales",
        ["Unlock Mouse In Menu"] = "Liberar Ratón en el Menú",
        ["Upgrade Priority"] = "Prioridad de Mejora",
        ["Upgrade Status"] = "Estado de Mejora",
        ["Upgrades to Buy"] = "Mejoras a Comprar",
        ["Use Spin Delay"] = "Usar Retraso de Giro",
        ["Wait For Boss"] = "Esperar al Jefe",
        ["Wave Status"] = "Estado de la Oleada",
        ["Webhook Status"] = "Estado del Webhook",
        ["Webhook URL"] = "URL del Webhook",
        ["When I Get A Keeper"] = "Cuando Consiga Uno que Quiero",
        ["Your Gold"] = "Tu Oro",
        ["Auto Heal Injuries"] = "Auto Curar Heridas",
        ["Auto Join Lobby"] = "Auto Unirse al Lobby",
        ["Auto Loot Crate"] = "Auto Recoger Caja",
        ["Auto Ready"] = "Auto Listo",
        ["Auto Refill [ Wave ]"] = "Auto Recarga [ Oleada ]",
        ["Auto Roll Blessings"] = "Auto Sorteo de Bendiciones",
        ["Auto Spin [ Lucky999+ ]"] = "Auto Giro [ Lucky999+ ]",
        ["Auto Upgrade Character"] = "Auto Mejorar Personaje",
        ["Auto Upgrade [ Blades ] All"] = "Auto Mejorar [ Espadas ] Todo",
        ["Auto Vote Skip"] = "Auto Voto para Saltar",
        ["Auto Clear Wave"] = "Auto Limpiar Oleada",
        ["Auto Play"] = "Auto Jugar",
        ["Adjust the upgrade priority to determine which path you want to upgrade first."] = "Ajusta la prioridad de mejora para decidir qué camino mejorar primero.",
        ["Auto Farm / Clear Wave pause while the boss is missing, still loading (no body/nape, anchored) or just spawned."] = "Auto Farmeo / Limpiar Oleada se pausan mientras el jefe no está, sigue cargando (sin cuerpo/nuca, anclado) o acaba de aparecer.",
        ["Auto loot your own crate (Crate_<your name>) with NoClip."] = "Recoge tu propia caja (Crate_<tu nombre>) con NoClip automáticamente.",
        ["Auto roll your family."] = "Sortea tu familia automáticamente.",
        ["Auto upgrade the skill tree."] = "Mejora el árbol de habilidades automáticamente.",
        ["Auto-pick the best grade or boost mission."] = "Elige automáticamente el mejor grado o la misión con bonus.",
        ["Automatically enables NoClip while looting."] = "Activa NoClip automáticamente mientras recoges.",
        ["Automatically press SELECT on the chosen slot when the screen shows up."] = "Pulsa SELECT automáticamente en la ranura elegida cuando aparece la pantalla.",
        ["Automatically presses Ready on the vote to skip the wait between waves."] = "Pulsa Listo automáticamente en la votación para saltar la espera entre oleadas.",
        ["Automatically presses Ready when the vote to start appears."] = "Pulsa Listo automáticamente cuando aparece la votación para empezar.",
        ["Automatically prestige and choose your boosts."] = "Hace prestigio y elige tus bonus automáticamente.",
        ["Automatically upgrade and equip your Blade, ODM gear and Thunder Spears."] = "Mejora y equipa automáticamente tu Espada, equipo ODM y Lanzas de Trueno.",
        ["Choose a saved config."] = "Elige una config guardada.",
        ["Choose target frame rate limit."] = "Elige el límite de fotogramas objetivo.",
        ["Choose which character slot to use (one at a time)."] = "Elige qué ranura de personaje usar (una a la vez).",
        ["Choose which families to keep."] = "Elige qué familias conservar.",
        ["Claims rewards the game shows as ready. Open the Quests / Achievements page to refresh them."] = "Reclama las recompensas que el juego muestra como listas. Abre la página de Misiones / Logros para actualizarlas.",
        ["Click at the image center instead of its top-left corner."] = "Hace clic en el centro de la imagen en vez de en su esquina superior izquierda.",
        ["Configure advanced player modifications and tools."] = "Configura modificaciones y herramientas avanzadas del jugador.",
        ["Copies the OPEN buttons it can see (send this if a chest is not opened)."] = "Copia los botones OPEN que ve (envíalo si un cofre no se abre).",
        ["Copy all rolls to the clipboard."] = "Copia todos los sorteos al portapapeles.",
        ["Core features and settings"] = "Funciones y ajustes principales",
        ["Countdown to the next start."] = "Cuenta atrás hasta el próximo inicio.",
        ["Countdown until the next join-lobby request."] = "Cuenta atrás hasta la próxima solicitud de unirse al lobby.",
        ["Counts the Waves Cleared shown in the objectives."] = "Cuenta las Oleadas Superadas que se muestran en los objetivos.",
        ["Counts wins while Auto Fail Safe is on."] = "Cuenta las victorias mientras el Auto Seguro de Racha está activo.",
        ["Crate looting and killing titans come first. Heal, upgrades, shop and blessings take turns in between and check your gold."] = "Recoger cajas y matar titanes van primero. Curar, mejoras, tienda y bendiciones se turnan en medio y revisan tu oro.",
        ["Create your raid room first, then turn on Auto Start."] = "Crea primero tu sala de raid y luego activa Auto Iniciar.",
        ["Create your room first, then turn on Auto Start."] = "Crea primero tu sala y luego activa Auto Iniciar.",
        ["Create your wave room first, then turn on Auto Start."] = "Crea primero tu sala de oleadas y luego activa Auto Iniciar.",
        ["Current step and last result."] = "Paso actual y último resultado.",
        ["Customize the appearance and visual style of the interface."] = "Personaliza la apariencia y el estilo visual de la interfaz.",
        ["Discord: Server Settings > Integrations > Webhooks > Copy URL. Keep it private."] = "Discord: Server Settings > Integrations > Webhooks > Copy URL. Mantenlo en privado.",
        ["Display current server details and identifiers."] = "Muestra los detalles e identificadores del servidor actual.",
        ["Don't fly to Youmii / Cole / Lulu / Orange / Roll unless you have at least this much gold (0 = off)."] = "No vuela hacia Youmii / Cole / Lulu / Orange / Roll a menos que tengas al menos este oro (0 = desactivado).",
        ["Download / load the image and use it as the cursor."] = "Descarga / carga la imagen y la usa como cursor.",
        ["Draw a virtual cursor on top of everything."] = "Dibuja un cursor virtual sobre todo lo demás.",
        ["Enable frosted glass blur effect behind the window."] = "Activa un efecto de vidrio esmerilado detrás de la ventana.",
        ["Enable smooth dropshadow around the script window."] = "Activa una sombra suave alrededor de la ventana del script.",
        ["Flies to the refill tank and presses R for you (mobile friendly)."] = "Vuela al tanque de recarga y pulsa R por ti (apto para móvil).",
        ["Free the mouse while the menu is open so you can click options."] = "Libera el ratón mientras el menú está abierto para poder hacer clic en las opciones.",
        ["Go back to the default Roblox arrow."] = "Vuelve a la flecha por defecto de Roblox.",
        ["Goes to Cole, opens Upgrades and buys the upgrades you picked (once every wave)."] = "Va con Cole, abre Mejoras y compra las que elegiste (una vez por oleada).",
        ["Goes to Lulu, opens Equipment and presses UPGRADE ALL for you (once every wave)."] = "Va con Lulu, abre Equipo y pulsa UPGRADE ALL por ti (una vez por oleada).",
        ["Goes to Orange, opens the Market and clicks the cards for you (once every wave)."] = "Va con Orange, abre el Mercado y hace clic en las cartas por ti (una vez por oleada).",
        ["Goes to Roll and spins the Blessings machine whenever you have 2,000 gold or more."] = "Va con Roll y gira la máquina de Bendiciones cuando tengas 2,000 de oro o más.",
        ["Goes to Youmii, opens Injuries and clicks Heal for you (once every wave)."] = "Va con Youmii, abre Heridas y pulsa Curar por ti (una vez por oleada).",
        ["Hidden. Turn on 'Show Rolled Families'."] = "Oculto. Activa 'Mostrar Familias Sorteadas'.",
        ["Hide the virtual cursor when the menu is closed."] = "Oculta el cursor virtual cuando el menú está cerrado.",
        ["Highest difficulty the last room got."] = "Dificultad más alta que tuvo la última sala.",
        ["How long the boss must stay fully loaded before farming starts. Also how long to wait for a boss to appear after you spawn."] = "Cuánto debe estar el jefe totalmente cargado antes de empezar a farmear. También cuánto esperar a que aparezca un jefe tras reaparecer tú.",
        ["Keep missions from finishing too fast and break long win streaks"] = "Evita que las misiones terminen demasiado rápido y rompan rachas largas de victorias.",
        ["Keep this rarity or higher. Off = never stop for rarity."] = "Conserva esta rareza o superior. Apagado = nunca parar por rareza.",
        ["Keeps pressing ROLL for you."] = "Sigue pulsando ROLL por ti.",
        ["Leave the current mission room."] = "Sale de la sala de misión actual.",
        ["Leave the current raid room."] = "Sale de la sala de raid actual.",
        ["Leave the current wave room."] = "Sale de la sala de oleadas actual.",
        ["Leave the match once enough waves are cleared."] = "Sale de la partida cuando se hayan superado suficientes oleadas.",
        ["Leave to the lobby when Waves Cleared reaches the number below."] = "Vuelve al lobby cuando las Oleadas Superadas lleguen al número de abajo.",
        ["Limit the frame rate of the game."] = "Limita los fotogramas por segundo del juego.",
        ["Manage special visual styles for your script window."] = "Gestiona estilos visuales especiales para la ventana del script.",
        ["Map with the reward boost right now."] = "Mapa con el bonus de recompensa ahora mismo.",
        ["Master switch. Wave features (Create, Start, Ready, Vote Skip, Clear Wave, Loot, Refill, Shop) only run while this is ON."] = "Interruptor maestro. Las funciones de oleadas (Crear, Iniciar, Listo, Voto para Saltar, Limpiar Oleada, Recoger, Recargar, Tienda) solo funcionan mientras esté ACTIVADO.",
        ["Measured live so you can see whether the lock is working."] = "Se mide en vivo para que veas si el bloqueo funciona.",
        ["Must be ON for Auto Create/Start Wave, Ready, Vote Skip, Clear Wave, Loot Crate, Refill and Shop to work. Turning it off pauses them all (your toggles stay as set)."] = "Debe estar ACTIVADO para que funcionen Auto Crear/Iniciar Oleada, Listo, Voto para Saltar, Limpiar Oleada, Recoger Caja, Recarga y Tienda. Al apagarlo se pausan todas (tus interruptores se mantienen).",
        ["On: wait after every roll. Off: go on as soon as the result shows."] = "Activado: espera tras cada sorteo. Apagado: continúa en cuanto aparece el resultado.",
        ["Only changes icons, switches and buttons. The background stays the same."] = "Solo cambia iconos, interruptores y botones. El fondo se mantiene igual.",
        ["Only titans whose nape is within this distance of you are hit. Raise it if titans are not dying."] = "Solo se golpea a los titanes cuya nuca esté dentro de esta distancia. Súbela si los titanes no mueren.",
        ["Open the Family page to see your current family live."] = "Abre la página de Familia para ver tu familia actual en vivo.",
        ["Open the Quests page and click through its categories, then Achievements, then press Copy."] = "Abre la página de Misiones, recorre sus categorías, luego Logros, y pulsa Copiar.",
        ["Order: Heal > Upgrade Character > Upgrade Blades > Shop > Blessings."] = "Orden: Curar > Mejorar Personaje > Mejorar Espadas > Tienda > Bendiciones.",
        ["Paste an image link, a file name, or a Roblox asset id. PNG / JPG only."] = "Pega un enlace de imagen, un nombre de archivo o un asset id de Roblox. Solo PNG / JPG.",
        ["Pick one slot. The script presses its SELECT button for you."] = "Elige una ranura. El script pulsa su botón SELECT por ti.",
        ["Pick the map and difficulty, then turn on Auto Create Wave."] = "Elige el mapa y la dificultad, y luego activa Auto Crear Oleada.",
        ["Pick the mission, objective, difficulty and modifiers for your room."] = "Elige la misión, el objetivo, la dificultad y los modificadores de tu sala.",
        ["Pick which upgrades Cole should buy: Max HP, Regen, Replenish, Refills, Revive."] = "Elige qué mejoras debe comprar Cole: Max HP, Regen, Replenish, Refills, Revive.",
        ["Post to Discord when a match ends. Needs a valid Webhook URL."] = "Envía un mensaje a Discord cuando termina una partida. Requiere una URL de Webhook válida.",
        ["Press SELECT on the chosen slot once."] = "Pulsa SELECT en la ranura elegida una vez.",
        ["Press to hide or show the window."] = "Púlsalo para ocultar o mostrar la ventana.",
        ["Presses Ready for you when the vote to start appears."] = "Pulsa Listo por ti cuando aparece la votación para empezar.",
        ["Presses your skill slot keys (1-5) for you. Instant = tap, Hold = hold the key."] = "Pulsa por ti las teclas de tus ranuras de habilidad (1-5). Instant = toque, Hold = mantener la tecla.",
        ["Prints the boss state to the Console (F9). Use it while the boss looks stuck and send it to me."] = "Imprime el estado del jefe en la Consola (F9). Úsalo cuando el jefe parezca atascado y envíamelo.",
        ["Put your own PNG/JPG here, then type its file name above."] = "Pon aquí tu propio PNG/JPG y escribe su nombre de archivo arriba.",
        ["Quick tools to copy identifiers or switch servers."] = "Herramientas rápidas para copiar identificadores o cambiar de servidor.",
        ["Raids start at Hard. Colossal Titan is Aberrant only."] = "Las raids empiezan en Hard. El Titán Colosal es solo Aberrant.",
        ["Read from the HUD."] = "Se lee del HUD.",
        ["Read from your player data. N/A = this value was not found."] = "Se lee de los datos de tu jugador. N/A = no se encontró este valor.",
        ["Recent rolls to show (5 - 100)."] = "Sorteos recientes a mostrar (5 - 100).",
        ["Removes buildings, trees and walls on YOUR screen only, to cut lag. Rejoin to get the map back."] = "Quita edificios, árboles y muros solo en TU pantalla para reducir el lag. Reentra para recuperar el mapa.",
        ["Result of the last apply."] = "Resultado de la última aplicación.",
        ["Result of the last request."] = "Resultado de la última solicitud.",
        ["Result of the last send."] = "Resultado del último envío.",
        ["Rewards claimed since the script started."] = "Recompensas reclamadas desde que inició el script.",
        ["Rolls (2,000 gold each) while your gold is 2,000 or more, then flies back to your spot."] = "Sortea (2,000 de oro cada vez) mientras tengas 2,000 o más y luego vuela de vuelta a tu lugar.",
        ["Run one shopping round right now."] = "Hace una ronda de compras ahora mismo.",
        ["Same blade attacks as Auto Farm [ Blades ], but you stay where you are."] = "Mismos ataques con espadas que Auto Farmeo [ Espadas ], pero te quedas donde estás.",
        ["Save your settings under a name (e.g. FarmBoss)."] = "Guarda tus ajustes con un nombre (p. ej. FarmBoss).",
        ["Seconds to wait after each roll (0.5 - 10)."] = "Segundos de espera tras cada sorteo (0.5 - 10).",
        ["Send one test message now."] = "Envía un mensaje de prueba ahora.",
        ["Send the join-lobby request every Join Delay seconds."] = "Envía la solicitud de unirse al lobby cada tantos segundos como el Retraso para Unirse.",
        ["Send the join-lobby request once."] = "Envía la solicitud de unirse al lobby una vez.",
        ["Send your config to friends with a short code, or import one. Codes hold only your switches (no Webhook URL)."] = "Envía tu config a tus amigos con un código corto, o importa uno. Los códigos solo guardan tus interruptores (sin URL de Webhook).",
        ["Sends a reward summary to Discord every time a match ends (MISSION COMPLETED screen)."] = "Envía un resumen de recompensas a Discord cada vez que termina una partida (pantalla MISSION COMPLETED).",
        ["Set a priority for each memory (0 - 10)."] = "Define una prioridad para cada memory (0 - 10).",
        ["Shoots the wall cannon at the Colossal Titan's nape."] = "Dispara el cañón de la muralla a la nuca del Titán Colosal.",
        ["Show or hide the list."] = "Muestra u oculta la lista.",
        ["Size in pixels (12 - 128)."] = "Tamaño en píxeles (12 - 128).",
        ["Skip cutscenes and open the reward chest by pressing the real buttons."] = "Salta las escenas y abre el cofre de recompensa pulsando los botones reales.",
        ["Spawned / loading / ready."] = "Apareció / cargando / listo.",
        ["Stand still and kill titans in range - no flying to them. Turns Auto Farm [ Blades ] and [ TS ] off while it is on."] = "Quédate quieto y mata a los titanes en rango, sin volar hacia ellos. Apaga Auto Farmeo [ Espadas ] y [ TS ] mientras esté activo.",
        ["Stop, store it and keep rolling, or ask me."] = "Parar, guardarlo y seguir sorteando, o preguntarme.",
        ["Stops rolling (and turns Auto Roll off) as soon as the machine lands 3 matching cards and shows a reward."] = "Deja de sortear (y apaga el Auto Sorteo) en cuanto la máquina saca 3 cartas iguales y muestra una recompensa.",
        ["Tap a family to add / remove"] = "Toca una familia para añadir / quitar",
        ["The essentials - turn these on and go"] = "Lo esencial: actívalo y a jugar",
        ["The shortcut that hides and shows the window."] = "El atajo que oculta y muestra la ventana.",
        ["The specific place ID of this server instance."] = "El place ID específico de esta instancia del servidor.",
        ["The unique ID of this game universe."] = "El ID único de este universo de juego.",
        ["The whole palette, not just light or dark."] = "Toda la paleta, no solo claro u oscuro.",
        ["Tick the Modifiers to apply after creating."] = "Marca los Modificadores que se aplicarán tras crear la sala.",
        ["Titans closer than this to Eren (studs) are killed first."] = "Los titanes más cerca de Eren que esta distancia (studs) se matan primero.",
        ["Used when you cannot afford everything."] = "Se usa cuando no te alcanza para todo.",
        ["Virtual cursor you can see and click with, even when the game locks your mouse."] = "Cursor virtual que puedes ver y usar para hacer clic, incluso cuando el juego bloquea tu ratón.",
        ["Visit Cole and buy the selected upgrades right now."] = "Visita a Cole y compra las mejoras seleccionadas ahora mismo.",
        ["Visit Lulu and press UPGRADE ALL right now."] = "Visita a Lulu y pulsa UPGRADE ALL ahora mismo.",
        ["Visit Youmii and heal right now."] = "Visita a Youmii y cúrate ahora mismo.",
        ["Visits Cole at the start of every new wave and buys the selected upgrades while you have enough gold."] = "Visita a Cole al inicio de cada oleada y compra las mejoras seleccionadas mientras tengas oro suficiente.",
        ["Visits Lulu at the start of every new wave and upgrades all your blade stats while you have enough gold."] = "Visita a Lulu al inicio de cada oleada y mejora todas las estadísticas de tus espadas mientras tengas oro suficiente.",
        ["Visits Youmii at the start of every new wave and heals broken arms / legs (needs enough gold)."] = "Visita a Youmii al inicio de cada oleada y cura brazos / piernas rotos (requiere oro suficiente).",
        ["Waits until the raid boss is fully spawned before Auto Farm starts, so you don't farm while the boss is still loading or frozen."] = "Espera a que el jefe de la raid haya aparecido por completo antes de iniciar el Auto Farmeo, para no farmear mientras el jefe aún carga o está congelado.",
        ["What Auto Cannon is doing."] = "Lo que está haciendo el Auto Cañón.",
        ["What Auto Defend is doing."] = "Lo que está haciendo la Auto Defensa.",
        ["What Auto Farm is doing right now, and why it is paused."] = "Lo que está haciendo el Auto Farmeo ahora mismo y por qué está en pausa.",
        ["What Auto Open Chest sees right now."] = "Lo que ve el Auto Abrir Cofre ahora mismo.",
        ["What Auto Skip Cutscene is doing."] = "Lo que está haciendo el Auto Saltar Escena.",
        ["What Auto Spin is doing now."] = "Lo que está haciendo el Auto Giro ahora.",
        ["What the script is doing right now."] = "Lo que está haciendo el script ahora mismo.",
        ["What to do when a mission ends"] = "Qué hacer cuando termina una misión",
        ["When your blades / Thunder Spears run out, goes to the nearest tank, refills, then flies back."] = "Cuando se acaban tus espadas / Lanzas de Trueno, va al tanque más cercano, rellena y vuelve volando.",
        ["Which parts are running."] = "Qué partes están funcionando.",
        ["With the Equipment window open: prints every visible text/button to the F9 console."] = "Con la ventana de Equipo abierta: imprime todo texto/botón visible en la consola F9.",
        ["With the Injuries window open: prints every visible text/button to the F9 console."] = "Con la ventana de Heridas abierta: imprime todo texto/botón visible en la consola F9.",
        ["With the Market open: prints every card (name, stars, price, stock) to the F9 console."] = "Con el Mercado abierto: imprime cada carta (nombre, estrellas, precio, stock) en la consola F9.",
        ["With the Upgrades window open: prints every visible text/button to the F9 console."] = "Con la ventana de Mejoras abierta: imprime todo texto/botón visible en la consola F9.",
        ["Your roll history."] = "Tu historial de sorteos.",
        ["Smooth Hub - Auto Spin"] = "Smooth Hub - Auto Giro",
    },
    VI = {
        ["Menu"] = "Menu",
        ["Menu Lobby"] = "Menu Sảnh",
        ["Status"] = "Trạng thái",
        ["Account"] = "Tài khoản",
        ["In-Game"] = "Trong game",
        ["Lobby"] = "Sảnh",
        ["Game Mode"] = "Chế độ chơi",
        ["Misc"] = "Khác",
        ["Auto Farm"] = "Tự động farm",
        ["Auto Quest"] = "Nhiệm vụ tự động",
        ["Auto Skill"] = "Kỹ năng tự động",
        ["Progression"] = "Tiến trình",
        ["Skill Trees"] = "Cây kỹ năng",
        ["Perks"] = "Perk",
        ["Missions"] = "Nhiệm vụ",
        ["Wave Mode"] = "Chế độ Wave",
        ["Raid Mode"] = "Chế độ Raid",
        ["Webhook"] = "Webhook",
        ["Advanced"] = "Nâng cao",
        ["Server"] = "Máy chủ",
        ["Windows"] = "Cửa sổ",
        ["Config"] = "Cấu hình",
        ["Cursor"] = "Con trỏ",
        ["Language"] = "Ngôn ngữ",
        ["Settings\u{200B}"] = "Cài đặt\u{200B}",
        ["⌨️ Input"] = "⌨️ Nhập liệu",
        ["▶️ Auto Play"] = "▶️ Tự động chơi",
        ["⚔️ Auto Clear Wave"] = "⚔️ Tự động dọn Wave",
        ["⚔️ Auto Farm"] = "⚔️ Tự động farm",
        ["⚔️ Equipment"] = "⚔️ Trang bị",
        ["⚔️ Raid Settings"] = "⚔️ Cài đặt Raid",
        ["⚙️ Advanced Settings"] = "⚙️ Cài đặt nâng cao",
        ["⚙️ After the Match"] = "⚙️ Sau trận đấu",
        ["⚙️ Settings Roll"] = "⚙️ Cài đặt Roll",
        ["⛽ Auto Refill [ Wave ]"] = "⛽ Tự động nạp lại [ Wave ]",
        ["✅ Auto Ready"] = "✅ Tự động sẵn sàng",
        ["✨ Windows Effects"] = "✨ Hiệu ứng cửa sổ",
        ["⬆️ Auto Upgrade Character [ Cole ]"] = "⬆️ Tự động nâng cấp nhân vật [ Cole ]",
        ["🌊 Wave Settings"] = "🌊 Cài đặt Wave",
        ["🌐 Server Information"] = "🌐 Thông tin máy chủ",
        ["🎁 Auto Claim"] = "🎁 Tự động nhận thưởng",
        ["🎁 Raid Extras"] = "🎁 Phần thưởng Raid",
        ["🎨 Customs Color"] = "🎨 Màu tùy chỉnh",
        ["🎭 Character Selection"] = "🎭 Chọn nhân vật",
        ["🎯 Auto Skill"] = "🎯 Kỹ năng tự động",
        ["🎰 Auto Roll Blessings [ Roll ]"] = "🎰 Tự động Roll Blessing [ Roll ]",
        ["🎰 Roll Family"] = "🎰 Roll Family",
        ["🏰 Colossal Titan"] = "🏰 Colossal Titan",
        ["👑 Prestige Section"] = "👑 Mục Prestige",
        ["💾 Server Actions"] = "💾 Thao tác máy chủ",
        ["📁 Configuration"] = "📁 Cấu hình",
        ["📊 Account Overview"] = "📊 Tổng quan tài khoản",
        ["📋 Status"] = "📋 Trạng thái",
        ["📜 Mission Settings"] = "📜 Cài đặt nhiệm vụ",
        ["📜 Show Roll"] = "📜 Hiện lịch sử Roll",
        ["📤 Share config"] = "📤 Chia sẻ cấu hình",
        ["📦 Auto Loot Crate"] = "📦 Tự động nhặt Crate",
        ["🔔 Webhook"] = "🔔 Webhook",
        ["🔨 Crafting"] = "🔨 Chế tạo",
        ["🖥️ FPS"] = "🖥️ FPS",
        ["🖱️ Mouse cursor"] = "🖱️ Con trỏ chuột",
        ["🖼️ Cursor image"] = "🖼️ Hình con trỏ",
        ["🗡️ Auto Upgrade [ Blades ] All"] = "🗡️ Tự động nâng cấp [ Blades ] Tất cả",
        ["🚀 Advance Missions"] = "🚀 Nhiệm vụ nâng cao",
        ["🚪 Auto Join Lobby"] = "🚪 Tự động vào sảnh",
        ["🚪 Leave At Wave"] = "🚪 Rời ở Wave",
        ["🛒 Auto Shop [ Orange ]"] = "🛒 Tự động mua sắm [ Orange ]",
        ["🛟 Safety"] = "🛟 An toàn",
        ["🛠️ Auto Quest"] = "🛠️ Nhiệm vụ tự động",
        ["🛰️ Boss Check"] = "🛰️ Kiểm tra Boss",
        ["🤖 Auto Mission"] = "🤖 Tự động nhiệm vụ",
        ["🤖 Auto Raid"] = "🤖 Tự động Raid",
        ["🤖 Auto Wave"] = "🤖 Tự động Wave",
        ["🧠 Memories Priority"] = "🧠 Ưu tiên Memories",
        ["🧭 Wave Routine"] = "🧭 Quy trình Wave",
        ["🩹 Auto Heal Injuries [ Youmii ]"] = "🩹 Tự động chữa thương [ Youmii ]",
        ["Auto Farm [ Blades ]"] = "Tự động farm [ Blades ]",
        ["Auto Farm [ Thunder Spears ]"] = "Tự động farm [ Thunder Spears ]",
        ["Bypass Farm (No Shadow Ban)"] = "Farm vượt rào (không bị Shadow Ban)",
        ["Auto Reload"] = "Tự động nạp đạn",
        ["Auto Refills [ Blade ]"] = "Tự động nạp lại [ Blade ]",
        ["Auto Refills [ Thunder Spears ]"] = "Tự động nạp lại [ Thunder Spears ]",
        ["Damage Multiplier ( x10 )"] = "Nhân sát thương ( x10 )",
        ["Auto Retry"] = "Tự động thử lại",
        ["Auto Leave"] = "Tự động rời",
        ["Auto Leave After X Matches"] = "Tự động rời sau X trận",
        ["Auto Fail Safe"] = "Tự động Fail Safe",
        ["Auto Claim Main Quests"] = "Tự động nhận nhiệm vụ chính",
        ["Auto Claim Side Quests"] = "Tự động nhận nhiệm vụ phụ",
        ["Auto Claim Achievements"] = "Tự động nhận thành tựu",
        ["Auto Claim Weekly Quests"] = "Tự động nhận nhiệm vụ tuần",
        ["Auto Claim Daily Quests"] = "Tự động nhận nhiệm vụ ngày",
        ["Auto Open Pages"] = "Tự động mở trang",
        ["Auto Upgrade Gear ( Blade )"] = "Tự động nâng cấp trang bị ( Blade )",
        ["Auto Upgrade Gear ( Thunder Spears )"] = "Tự động nâng cấp trang bị ( Thunder Spears )",
        ["Auto Equip Blade"] = "Tự động trang bị Blade",
        ["Auto Equip Thunder Spears"] = "Tự động trang bị Thunder Spears",
        ["Auto Prestige"] = "Tự động Prestige",
        ["Auto Upgrade Skills"] = "Tự động nâng cấp kỹ năng",
        ["Left"] = "Trái",
        ["Middle"] = "Giữa",
        ["Right"] = "Phải",
        ["Auto Craft Perks"] = "Tự động chế tạo Perk",
        ["Auto Create Mission"] = "Tự động tạo nhiệm vụ",
        ["Auto Start Missions"] = "Tự động bắt đầu nhiệm vụ",
        ["Auto Select Best Grade"] = "Tự động chọn Grade tốt nhất",
        ["Auto Select Boost Mission"] = "Tự động chọn nhiệm vụ Boost",
        ["Auto Create Raid"] = "Tự động tạo Raid",
        ["Auto Start Raid"] = "Tự động bắt đầu Raid",
        ["Auto Skip Cutscene"] = "Tự động bỏ qua cutscene",
        ["Auto Open Chest (Free)"] = "Tự động mở rương (Miễn phí)",
        ["Auto Open Chest (Premium)"] = "Tự động mở rương (Premium)",
        ["Auto Finish Chest"] = "Tự động hoàn tất rương",
        ["Auto Cannon (Colossal Titan)"] = "Tự động dùng pháo (Colossal Titan)",
        ["Auto Defend (only Eren Thunder Spears)"] = "Tự động bảo vệ (chỉ Eren Thunder Spears)",
        ["Auto Create Wave"] = "Tự động tạo Wave",
        ["Auto Start Waves"] = "Tự động bắt đầu Wave",
        ["Auto Shop [ Orange ]"] = "Tự động mua sắm [ Orange ]",
        ["Infinite Jump"] = "Nhảy vô hạn",
        ["Anti-AFK"] = "Chống AFK",
        ["Auto Rejoin"] = "Tự động vào lại",
        ["Anti Admin"] = "Chống Admin",
        ["Auto Execute"] = "Tự động thực thi",
        ["Auto Hide Menu"] = "Tự động ẩn menu",
        ["Enable FPS Lock"] = "Bật khóa FPS",
        ["Auto Delete Map"] = "Tự động xóa bản đồ",
        ["Copy JobId"] = "Sao chép JobId",
        ["Rejoin Server"] = "Vào lại máy chủ",
        ["Server Hop"] = "Đổi máy chủ",
        ["Enter Save Config"] = "Nhập tên lưu cấu hình",
        ["Create config"] = "Tạo cấu hình",
        ["Load config"] = "Tải cấu hình",
        ["Delete config"] = "Xóa cấu hình",
        ["Refresh list"] = "Làm mới danh sách",
        ["Set as autoload"] = "Đặt làm tự tải",
        ["Reset autoload"] = "Đặt lại tự tải",
        ["Reset to defaults"] = "Đặt lại mặc định",
        ["Automatically completes missions with Blades."] = "Tự động hoàn thành nhiệm vụ bằng Blades.",
        ["Automatically completes missions with Thunder Spears."] = "Tự động hoàn thành nhiệm vụ bằng Thunder Spears.",
        ["Reloads your blades when they run out."] = "Tự động nạp kiếm khi hết.",
        ["Refills at the station when your blades are out and no spare blades are left."] = "Nạp lại tại trạm khi kiếm hết và không còn kiếm dự phòng.",
        ["Refills at the station when your Thunder Spears run out."] = "Nạp lại tại trạm khi Thunder Spears hết.",
        ["Deal 10x damage to Titans."] = "Gây sát thương gấp 10 lần lên Titan.",
        ["Automatically Retry when completed."] = "Tự động thử lại khi hoàn thành.",
        ["Leave to the lobby right when the match ends."] = "Rời về sảnh ngay khi trận đấu kết thúc.",
        ["Retry up to the Retry Amount, then leave (needs Auto Retry). Not together with Auto Leave."] = "Thử lại tối đa theo Số lần thử lại, rồi rời (cần bật Tự động thử lại). Không dùng cùng Tự động rời.",
        ["Auto-jumps while farming so your gas gets used."] = "Tự động nhảy khi farm để tiêu hao gas.",
        ["Matches to retry before leaving (used by Auto Leave After X Matches)."] = "Số trận thử lại trước khi rời (dùng cho Tự động rời sau X trận).",
        ["When the win streak reaches the number above, the next match is lost on purpose: you stand still and let the titans kill you, then the streak resets."] = "Khi chuỗi thắng đạt số ở trên, trận tiếp theo sẽ cố tình thua: bạn đứng yên để Titan giết, rồi chuỗi thắng được đặt lại.",
        ["Automatically claim the main quests."] = "Tự động nhận nhiệm vụ chính.",
        ["Automatically claim the side quests."] = "Tự động nhận nhiệm vụ phụ.",
        ["Automatically claim achievements."] = "Tự động nhận thành tựu.",
        ["Automatically claim the weekly quests."] = "Tự động nhận nhiệm vụ tuần.",
        ["Automatically claim the daily quests."] = "Tự động nhận nhiệm vụ ngày.",
        ["When the game shows the red ! on the Achievements icon, open that page, claim, then close it (like a player)."] = "Khi game hiện dấu ! đỏ trên biểu tượng Thành tựu, mở trang đó, nhận thưởng rồi đóng lại (như người chơi thật).",
        ["Automatically upgrade BLADE & ODM."] = "Tự động nâng cấp BLADE & ODM.",
        ["Automatically upgrade thunder spears."] = "Tự động nâng cấp thunder spears.",
        ["Automatically equip blades."] = "Tự động trang bị blades.",
        ["Automatically equip thunder spears."] = "Tự động trang bị thunder spears.",
        ["Automatically prestige."] = "Tự động Prestige.",
        ["Automatically upgrade skills tree."] = "Tự động nâng cấp cây kỹ năng.",
        ["Upgrade the left path."] = "Nâng cấp nhánh bên trái.",
        ["Upgrade the middle path."] = "Nâng cấp nhánh ở giữa.",
        ["Upgrade the right path."] = "Nâng cấp nhánh bên phải.",
        ["Automatically craft perks."] = "Tự động chế tạo perk.",
        ["Keeps a room ready with these settings. Remembered next time."] = "Luôn giữ một phòng sẵn sàng với các cài đặt này. Được ghi nhớ cho lần sau.",
        ["Starts the mission in your room. Remembered next time."] = "Bắt đầu nhiệm vụ trong phòng của bạn. Được ghi nhớ cho lần sau.",
        ["Creates the highest difficulty you can play."] = "Tạo độ khó cao nhất mà bạn có thể chơi.",
        ["Creates the map that has the reward boost now."] = "Tạo bản đồ đang có thưởng boost.",
        ["Keeps a raid room ready with these settings. Remembered next time."] = "Luôn giữ một phòng raid sẵn sàng với các cài đặt này. Được ghi nhớ cho lần sau.",
        ["Starts the raid in your room. Remembered next time."] = "Bắt đầu raid trong phòng của bạn. Được ghi nhớ cho lần sau.",
        ["Presses SKIP [E] on cutscenes once your character has loaded."] = "Nhấn SKIP [E] ở các cutscene khi nhân vật của bạn đã tải xong.",
        ["Presses OPEN on the Free chest when the chest screen shows."] = "Nhấn OPEN trên rương Miễn phí khi màn hình rương hiện ra.",
        ["Presses OPEN on the Premium chest. Only turn on if you want to open it."] = "Nhấn OPEN trên rương Premium. Chỉ bật nếu bạn muốn mở nó.",
        ["Presses FINISH after the chests you selected are opened."] = "Nhấn FINISH sau khi các rương bạn đã chọn được mở.",
        ["Phase 1: mounts the wall cannon and shoots the Colossal Titan until the cutscene (Stall Bertholdt complete). Phase 2: the cannon stops so you can kill the Colossal."] = "Giai đoạn 1: gắn lên pháo tường và bắn Colossal Titan cho đến cutscene (Stall Bertholdt hoàn thành). Giai đoạn 2: pháo dừng để bạn tiêu diệt Colossal.",
        ["Phase 1: while the cannon shoots, Auto Farm also kills the titans that get close to Eren. Needs Auto Farm on."] = "Giai đoạn 1: trong lúc pháo bắn, Tự động farm cũng tiêu diệt các Titan đến gần Eren. Cần bật Tự động farm.",
        ["Keeps a wave room ready with these settings. Remembered next time."] = "Luôn giữ một phòng wave sẵn sàng với các cài đặt này. Được ghi nhớ cho lần sau.",
        ["Starts the wave in your room. Remembered next time."] = "Bắt đầu wave trong phòng của bạn. Được ghi nhớ cho lần sau.",
        ["Shops automatically at the start of every new wave (the market refreshes each wave)."] = "Tự động mua sắm ở đầu mỗi wave mới (chợ được làm mới mỗi wave).",
        ["Allow your character to jump infinitely in the air."] = "Cho phép nhân vật của bạn nhảy vô hạn trên không.",
        ["Prevent being kicked out of the game due to inactivity."] = "Ngăn bị đá khỏi game do không hoạt động.",
        ["Automatically rejoin the game if disconnected or kicked."] = "Tự động vào lại game nếu bị mất kết nối hoặc bị đá.",
        ["Automatically server hop if an admin joins the game."] = "Tự động đổi máy chủ nếu có admin vào game.",
        ["Run the script again after teleporting or rejoining a server."] = "Chạy lại script sau khi dịch chuyển hoặc vào lại máy chủ.",
        ["Not supported by your executor."] = "Executor của bạn không hỗ trợ.",
        ["Hide the menu automatically when the script runs. Tap the logo button or press the hotkey to open it."] = "Tự động ẩn menu khi script chạy. Chạm nút logo hoặc nhấn phím tắt để mở.",
        ["Toggle frame rate limiting on or off."] = "Bật hoặc tắt giới hạn tốc độ khung hình.",
        ["Deletes the map by itself every time you are in a mission."] = "Tự xóa bản đồ mỗi khi bạn ở trong nhiệm vụ.",
        ["Copy current JobId to clipboard for friends to join."] = "Sao chép JobId hiện tại vào bộ nhớ tạm để bạn bè vào cùng.",
        ["Go back to the main world (this map can't be rejoined directly)."] = "Quay về thế giới chính (bản đồ này không thể vào lại trực tiếp).",
        ["Teleport to a different server to find a new one."] = "Dịch chuyển sang máy chủ khác để tìm máy chủ mới.",
        ["Save the current switches into the config in use."] = "Lưu các công tắc hiện tại vào cấu hình đang dùng.",
        ["Type a name, then press Create."] = "Nhập tên, rồi nhấn Tạo.",
        ["Save the current switches under the name above and start using it."] = "Lưu các công tắc hiện tại với tên ở trên và bắt đầu dùng nó.",
        ["Switch to the selected config and apply its switches."] = "Chuyển sang cấu hình đã chọn và áp dụng các công tắc của nó.",
        ["Delete the selected config."] = "Xóa cấu hình đã chọn.",
        ["Reload the saved configs from file."] = "Tải lại các cấu hình đã lưu từ tệp.",
        ["Load the selected config automatically every time the script starts."] = "Tự động tải cấu hình đã chọn mỗi khi script khởi động.",
        ["Stop loading a config automatically."] = "Ngừng tự động tải cấu hình.",
        ["Set every switch, slider and the window look back to the default values (same as \"Smooth Hub | Default\"). Saved configs are NOT deleted."] = "Đặt lại mọi công tắc, thanh trượt và giao diện cửa sổ về giá trị mặc định (giống \"Smooth Hub | Default\"). Các cấu hình đã lưu KHÔNG bị xóa.",
        ["Apply"] = "Áp dụng",
        ["Apply Image"] = "Áp dụng hình ảnh",
        ["Boost Now"] = "Boost ngay",
        ["Copy"] = "Sao chép",
        ["Delete"] = "Xóa",
        ["Execute"] = "Thực thi",
        ["Heal"] = "Chữa trị",
        ["Heal Now"] = "Chữa trị ngay",
        ["Join"] = "Vào",
        ["Join Now"] = "Vào ngay",
        ["Leave"] = "Rời",
        ["Leave Room"] = "Rời phòng",
        ["Print"] = "In",
        ["Refresh"] = "Làm mới",
        ["Reset"] = "Đặt lại",
        ["Reset Image"] = "Đặt lại hình ảnh",
        ["Scan"] = "Quét",
        ["Select"] = "Chọn",
        ["Select Now"] = "Chọn ngay",
        ["Send Test"] = "Gửi thử",
        ["Shop"] = "Mua sắm",
        ["Shop Now"] = "Mua sắm ngay",
        ["Test"] = "Thử",
        ["Upgrade"] = "Nâng cấp",
        ["Upgrade Now"] = "Nâng cấp ngay",
        ["Copy Chest Debug"] = "Sao chép Debug rương",
        ["Copy Claim Debug"] = "Sao chép Debug nhận thưởng",
        ["Scan Equipment (Debug)"] = "Quét trang bị (Debug)",
        ["Scan Injuries (Debug)"] = "Quét thương tích (Debug)",
        ["Scan Shop (Debug)"] = "Quét cửa hàng (Debug)",
        ["Scan Upgrades (Debug)"] = "Quét nâng cấp (Debug)",
        ["Delete Map"] = "Xóa bản đồ",
        ["Idle"] = "Rảnh",
        ["Ready"] = "Sẵn sàng",
        ["Off"] = "Tắt",
        ["none"] = "không",
        ["Hidden"] = "Đã ẩn",
        ["No rolls yet."] = "Chưa có lần roll nào.",
        ["Nothing rolled yet."] = "Chưa roll được gì.",
        ["Current action..."] = "Hành động hiện tại...",
        ["Accent Color"] = "Màu nhấn",
        ["Theme Color"] = "Màu giao diện",
        ["Blur Effect"] = "Hiệu ứng làm mờ",
        ["Shadows Effect"] = "Hiệu ứng đổ bóng",
        ["Minimize Hotkey"] = "Phím tắt thu nhỏ",
        ["Auto Defend Status"] = "Trạng thái Tự động bảo vệ",
        ["Auto Play Status"] = "Trạng thái Tự động chơi",
        ["Best Grade Found"] = "Grade tốt nhất tìm được",
        ["Blade Upgrade Status"] = "Trạng thái nâng cấp Blade",
        ["Boss Info"] = "Thông tin Boss",
        ["Boss Status"] = "Trạng thái Boss",
        ["Buy Order"] = "Thứ tự mua",
        ["Cannon Status"] = "Trạng thái pháo",
        ["Center Hotspot"] = "Tâm điểm",
        ["Chest Status"] = "Trạng thái rương",
        ["Claim Status"] = "Trạng thái nhận thưởng",
        ["Clear Status"] = "Trạng thái dọn dẹp",
        ["Config list"] = "Danh sách cấu hình",
        ["Config name"] = "Tên cấu hình",
        ["Cursor Size"] = "Kích thước con trỏ",
        ["Custom Cursor"] = "Con trỏ tùy chỉnh",
        ["Enable Webhook"] = "Bật Webhook",
        ["Equipment Status"] = "Trạng thái trang bị",
        ["FPS Limit Preset"] = "Mức giới hạn FPS",
        ["Fail Safe Status"] = "Trạng thái Fail Safe",
        ["Farm Status"] = "Trạng thái farm",
        ["Heal Status"] = "Trạng thái chữa trị",
        ["Image Folder"] = "Thư mục hình ảnh",
        ["Image Source"] = "Nguồn hình ảnh",
        ["Join Delay"] = "Độ trễ vào",
        ["Keep Rarity"] = "Giữ độ hiếm",
        ["Last Roll"] = "Lần roll gần nhất",
        ["Leave At Wave"] = "Rời ở Wave",
        ["List Size"] = "Kích thước danh sách",
        ["Loot Status"] = "Trạng thái nhặt đồ",
        ["Mission Status"] = "Trạng thái nhiệm vụ",
        ["Next Join"] = "Lần vào tiếp theo",
        ["Next Mission"] = "Nhiệm vụ tiếp theo",
        ["Next Raid"] = "Raid tiếp theo",
        ["Next Wave"] = "Wave tiếp theo",
        ["Only While Menu Is Open"] = "Chỉ khi menu đang mở",
        ["Raid Status"] = "Trạng thái Raid",
        ["Refill Status"] = "Trạng thái nạp lại",
        ["Roll Status"] = "Trạng thái Roll",
        ["Rolled Families"] = "Các Family đã roll",
        ["Routine Status"] = "Trạng thái quy trình",
        ["Saved Rules"] = "Quy tắc đã lưu",
        ["Select Character"] = "Chọn nhân vật",
        ["Select Modifiers"] = "Chọn Modifier",
        ["Shop Status"] = "Trạng thái mua sắm",
        ["Show Rolled Families"] = "Hiện các Family đã roll",
        ["Skill Status"] = "Trạng thái kỹ năng",
        ["Skip Cutscene Status"] = "Trạng thái bỏ qua cutscene",
        ["Slot"] = "Ô",
        ["Spin Delay"] = "Độ trễ Spin",
        ["Spin Log"] = "Nhật ký Spin",
        ["Spin Status"] = "Trạng thái Spin",
        ["Stop When 3 Cards Match"] = "Dừng khi 3 thẻ trùng nhau",
        ["Unlock Mouse In Menu"] = "Mở khóa chuột trong menu",
        ["Upgrade Priority"] = "Ưu tiên nâng cấp",
        ["Upgrade Status"] = "Trạng thái nâng cấp",
        ["Upgrades to Buy"] = "Nâng cấp cần mua",
        ["Use Spin Delay"] = "Dùng độ trễ Spin",
        ["Wait For Boss"] = "Chờ Boss",
        ["Wave Status"] = "Trạng thái Wave",
        ["Webhook Status"] = "Trạng thái Webhook",
        ["Webhook URL"] = "URL Webhook",
        ["When I Get A Keeper"] = "Khi tôi nhận được Keeper",
        ["Your Gold"] = "Vàng của bạn",
        ["Auto Heal Injuries"] = "Tự động chữa thương",
        ["Auto Join Lobby"] = "Tự động vào sảnh",
        ["Auto Loot Crate"] = "Tự động nhặt Crate",
        ["Auto Ready"] = "Tự động sẵn sàng",
        ["Auto Refill [ Wave ]"] = "Tự động nạp lại [ Wave ]",
        ["Auto Roll Blessings"] = "Tự động Roll Blessing",
        ["Auto Spin [ Lucky999+ ]"] = "Tự động Spin [ Lucky999+ ]",
        ["Auto Upgrade Character"] = "Tự động nâng cấp nhân vật",
        ["Auto Upgrade [ Blades ] All"] = "Tự động nâng cấp [ Blades ] Tất cả",
        ["Auto Vote Skip"] = "Tự động bỏ phiếu bỏ qua",
        ["Auto Clear Wave"] = "Tự động dọn Wave",
        ["Auto Play"] = "Tự động chơi",
        ["Adjust the upgrade priority to determine which path you want to upgrade first."] = "Điều chỉnh thứ tự ưu tiên nâng cấp để quyết định nhánh nào được nâng cấp trước.",
        ["Auto Farm / Clear Wave pause while the boss is missing, still loading (no body/nape, anchored) or just spawned."] = "Tự động farm / dọn Wave sẽ tạm dừng khi boss chưa xuất hiện, đang tải (chưa có thân/gáy, bị neo) hoặc vừa mới xuất hiện.",
        ["Auto loot your own crate (Crate_<your name>) with NoClip."] = "Tự động nhặt crate của riêng bạn (Crate_<tên của bạn>) bằng NoClip.",
        ["Auto roll your family."] = "Tự động roll family của bạn.",
        ["Auto upgrade the skill tree."] = "Tự động nâng cấp cây kỹ năng.",
        ["Auto-pick the best grade or boost mission."] = "Tự động chọn Grade tốt nhất hoặc nhiệm vụ boost.",
        ["Automatically enables NoClip while looting."] = "Tự động bật NoClip khi đang nhặt đồ.",
        ["Automatically press SELECT on the chosen slot when the screen shows up."] = "Tự động nhấn SELECT ở ô đã chọn khi màn hình hiện ra.",
        ["Automatically presses Ready on the vote to skip the wait between waves."] = "Tự động nhấn Sẵn sàng ở phiếu bỏ qua thời gian chờ giữa các wave.",
        ["Automatically presses Ready when the vote to start appears."] = "Tự động nhấn Sẵn sàng khi phiếu bắt đầu xuất hiện.",
        ["Automatically prestige and choose your boosts."] = "Tự động prestige và chọn các boost của bạn.",
        ["Automatically upgrade and equip your Blade, ODM gear and Thunder Spears."] = "Tự động nâng cấp và trang bị Blade, đồ ODM và Thunder Spears.",
        ["Choose a saved config."] = "Chọn một cấu hình đã lưu.",
        ["Choose target frame rate limit."] = "Chọn mức giới hạn tốc độ khung hình mục tiêu.",
        ["Choose which character slot to use (one at a time)."] = "Chọn ô nhân vật để dùng (mỗi lần một ô).",
        ["Choose which families to keep."] = "Chọn các family muốn giữ lại.",
        ["Claims rewards the game shows as ready. Open the Quests / Achievements page to refresh them."] = "Nhận các phần thưởng mà game báo là đã sẵn sàng. Mở trang Nhiệm vụ / Thành tựu để làm mới chúng.",
        ["Click at the image center instead of its top-left corner."] = "Nhấp vào tâm của hình ảnh thay vì góc trên bên trái.",
        ["Configure advanced player modifications and tools."] = "Cấu hình các tùy chỉnh và công cụ nâng cao cho người chơi.",
        ["Copies the OPEN buttons it can see (send this if a chest is not opened)."] = "Sao chép các nút OPEN mà nó nhìn thấy (gửi cái này nếu rương không mở được).",
        ["Copy all rolls to the clipboard."] = "Sao chép tất cả lần roll vào bộ nhớ tạm.",
        ["Core features and settings"] = "Tính năng và cài đặt cốt lõi",
        ["Countdown to the next start."] = "Đếm ngược đến lần bắt đầu tiếp theo.",
        ["Countdown until the next join-lobby request."] = "Đếm ngược đến lần gửi yêu cầu vào sảnh tiếp theo.",
        ["Counts the Waves Cleared shown in the objectives."] = "Đếm số Wave đã dọn hiển thị trong mục tiêu.",
        ["Counts wins while Auto Fail Safe is on."] = "Đếm số trận thắng khi Tự động Fail Safe đang bật.",
        ["Crate looting and killing titans come first. Heal, upgrades, shop and blessings take turns in between and check your gold."] = "Nhặt crate và tiêu diệt titan được ưu tiên trước. Chữa trị, nâng cấp, mua sắm và blessing lần lượt chen vào giữa và kiểm tra vàng của bạn.",
        ["Create your raid room first, then turn on Auto Start."] = "Hãy tạo phòng raid của bạn trước, rồi bật Tự động bắt đầu.",
        ["Create your room first, then turn on Auto Start."] = "Hãy tạo phòng của bạn trước, rồi bật Tự động bắt đầu.",
        ["Create your wave room first, then turn on Auto Start."] = "Hãy tạo phòng wave của bạn trước, rồi bật Tự động bắt đầu.",
        ["Current step and last result."] = "Bước hiện tại và kết quả gần nhất.",
        ["Customize the appearance and visual style of the interface."] = "Tùy chỉnh diện mạo và phong cách hình ảnh của giao diện.",
        ["Discord: Server Settings > Integrations > Webhooks > Copy URL. Keep it private."] = "Discord: Cài đặt máy chủ > Tích hợp > Webhooks > Sao chép URL. Hãy giữ kín.",
        ["Display current server details and identifiers."] = "Hiển thị thông tin và mã định danh của máy chủ hiện tại.",
        ["Don't fly to Youmii / Cole / Lulu / Orange / Roll unless you have at least this much gold (0 = off)."] = "Không bay đến Youmii / Cole / Lulu / Orange / Roll trừ khi bạn có ít nhất lượng vàng này (0 = tắt).",
        ["Download / load the image and use it as the cursor."] = "Tải / nạp hình ảnh và dùng nó làm con trỏ.",
        ["Draw a virtual cursor on top of everything."] = "Vẽ một con trỏ ảo lên trên mọi thứ.",
        ["Enable frosted glass blur effect behind the window."] = "Bật hiệu ứng làm mờ kính mờ phía sau cửa sổ.",
        ["Enable smooth dropshadow around the script window."] = "Bật hiệu ứng đổ bóng mượt quanh cửa sổ script.",
        ["Flies to the refill tank and presses R for you (mobile friendly)."] = "Bay đến bình nạp và nhấn R giúp bạn (thân thiện với di động).",
        ["Free the mouse while the menu is open so you can click options."] = "Giải phóng chuột khi menu đang mở để bạn có thể nhấp vào các tùy chọn.",
        ["Go back to the default Roblox arrow."] = "Quay về mũi tên mặc định của Roblox.",
        ["Goes to Cole, opens Upgrades and buys the upgrades you picked (once every wave)."] = "Đến chỗ Cole, mở Nâng cấp và mua các nâng cấp bạn đã chọn (một lần mỗi wave).",
        ["Goes to Lulu, opens Equipment and presses UPGRADE ALL for you (once every wave)."] = "Đến chỗ Lulu, mở Trang bị và nhấn UPGRADE ALL giúp bạn (một lần mỗi wave).",
        ["Goes to Orange, opens the Market and clicks the cards for you (once every wave)."] = "Đến chỗ Orange, mở Chợ và nhấp vào các thẻ giúp bạn (một lần mỗi wave).",
        ["Goes to Roll and spins the Blessings machine whenever you have 2,000 gold or more."] = "Đến chỗ Roll và quay máy Blessings mỗi khi bạn có từ 2,000 vàng trở lên.",
        ["Goes to Youmii, opens Injuries and clicks Heal for you (once every wave)."] = "Đến chỗ Youmii, mở Thương tích và nhấp Chữa trị giúp bạn (một lần mỗi wave).",
        ["Hidden. Turn on 'Show Rolled Families'."] = "Đã ẩn. Hãy bật 'Hiện các Family đã roll'.",
        ["Hide the virtual cursor when the menu is closed."] = "Ẩn con trỏ ảo khi menu đóng.",
        ["Highest difficulty the last room got."] = "Độ khó cao nhất mà phòng gần nhất đạt được.",
        ["How long the boss must stay fully loaded before farming starts. Also how long to wait for a boss to appear after you spawn."] = "Thời gian boss phải tải xong hoàn toàn trước khi bắt đầu farm. Cũng là thời gian chờ boss xuất hiện sau khi bạn spawn.",
        ["Keep missions from finishing too fast and break long win streaks"] = "Ngăn nhiệm vụ kết thúc quá nhanh và phá vỡ các chuỗi thắng dài",
        ["Keep this rarity or higher. Off = never stop for rarity."] = "Giữ độ hiếm này hoặc cao hơn. Tắt = không bao giờ dừng theo độ hiếm.",
        ["Keeps pressing ROLL for you."] = "Tiếp tục nhấn ROLL giúp bạn.",
        ["Leave the current mission room."] = "Rời phòng nhiệm vụ hiện tại.",
        ["Leave the current raid room."] = "Rời phòng raid hiện tại.",
        ["Leave the current wave room."] = "Rời phòng wave hiện tại.",
        ["Leave the match once enough waves are cleared."] = "Rời trận khi đã dọn đủ số wave.",
        ["Leave to the lobby when Waves Cleared reaches the number below."] = "Rời về sảnh khi số Wave đã dọn đạt con số bên dưới.",
        ["Limit the frame rate of the game."] = "Giới hạn tốc độ khung hình của game.",
        ["Manage special visual styles for your script window."] = "Quản lý các phong cách hình ảnh đặc biệt cho cửa sổ script của bạn.",
        ["Map with the reward boost right now."] = "Bản đồ đang có thưởng boost.",
        ["Master switch. Wave features (Create, Start, Ready, Vote Skip, Clear Wave, Loot, Refill, Shop) only run while this is ON."] = "Công tắc chính. Các tính năng Wave (Tạo, Bắt đầu, Sẵn sàng, Bỏ phiếu bỏ qua, Dọn Wave, Nhặt đồ, Nạp lại, Mua sắm) chỉ chạy khi công tắc này BẬT.",
        ["Measured live so you can see whether the lock is working."] = "Đo trực tiếp để bạn thấy khóa có hoạt động hay không.",
        ["Must be ON for Auto Create/Start Wave, Ready, Vote Skip, Clear Wave, Loot Crate, Refill and Shop to work. Turning it off pauses them all (your toggles stay as set)."] = "Phải BẬT thì Tự động tạo/bắt đầu Wave, Sẵn sàng, Bỏ phiếu bỏ qua, Dọn Wave, Nhặt Crate, Nạp lại và Mua sắm mới hoạt động. Tắt đi sẽ tạm dừng tất cả (các công tắc của bạn giữ nguyên).",
        ["On: wait after every roll. Off: go on as soon as the result shows."] = "Bật: chờ sau mỗi lần roll. Tắt: tiếp tục ngay khi kết quả hiện ra.",
        ["Only changes icons, switches and buttons. The background stays the same."] = "Chỉ thay đổi biểu tượng, công tắc và nút. Nền giữ nguyên.",
        ["Only titans whose nape is within this distance of you are hit. Raise it if titans are not dying."] = "Chỉ những titan có gáy nằm trong khoảng cách này so với bạn mới bị đánh. Hãy tăng lên nếu titan không chết.",
        ["Open the Family page to see your current family live."] = "Mở trang Family để xem family hiện tại của bạn trực tiếp.",
        ["Open the Quests page and click through its categories, then Achievements, then press Copy."] = "Mở trang Nhiệm vụ và nhấp qua các danh mục của nó, rồi đến Thành tựu, sau đó nhấn Sao chép.",
        ["Order: Heal > Upgrade Character > Upgrade Blades > Shop > Blessings."] = "Thứ tự: Chữa trị > Nâng cấp nhân vật > Nâng cấp Blades > Mua sắm > Blessings.",
        ["Paste an image link, a file name, or a Roblox asset id. PNG / JPG only."] = "Dán liên kết hình ảnh, tên tệp hoặc asset id của Roblox. Chỉ PNG / JPG.",
        ["Pick one slot. The script presses its SELECT button for you."] = "Chọn một ô. Script sẽ nhấn nút SELECT của ô đó giúp bạn.",
        ["Pick the map and difficulty, then turn on Auto Create Wave."] = "Chọn bản đồ và độ khó, rồi bật Tự động tạo Wave.",
        ["Pick the mission, objective, difficulty and modifiers for your room."] = "Chọn nhiệm vụ, mục tiêu, độ khó và modifier cho phòng của bạn.",
        ["Pick which upgrades Cole should buy: Max HP, Regen, Replenish, Refills, Revive."] = "Chọn các nâng cấp Cole sẽ mua: Max HP, Regen, Replenish, Refills, Revive.",
        ["Post to Discord when a match ends. Needs a valid Webhook URL."] = "Đăng lên Discord khi một trận kết thúc. Cần URL Webhook hợp lệ.",
        ["Press SELECT on the chosen slot once."] = "Nhấn SELECT ở ô đã chọn một lần.",
        ["Press to hide or show the window."] = "Nhấn để ẩn hoặc hiện cửa sổ.",
        ["Presses Ready for you when the vote to start appears."] = "Nhấn Sẵn sàng giúp bạn khi phiếu bắt đầu xuất hiện.",
        ["Presses your skill slot keys (1-5) for you. Instant = tap, Hold = hold the key."] = "Nhấn các phím ô kỹ năng (1-5) giúp bạn. Tức thì = chạm, Giữ = giữ phím.",
        ["Prints the boss state to the Console (F9). Use it while the boss looks stuck and send it to me."] = "In trạng thái boss ra Console (F9). Dùng khi boss có vẻ bị kẹt và hãy gửi nó cho tôi.",
        ["Put your own PNG/JPG here, then type its file name above."] = "Đặt tệp PNG/JPG của riêng bạn vào đây, rồi nhập tên tệp ở trên.",
        ["Quick tools to copy identifiers or switch servers."] = "Công cụ nhanh để sao chép mã định danh hoặc đổi máy chủ.",
        ["Raids start at Hard. Colossal Titan is Aberrant only."] = "Raid bắt đầu từ Hard. Colossal Titan chỉ có Aberrant.",
        ["Read from the HUD."] = "Đọc từ HUD.",
        ["Read from your player data. N/A = this value was not found."] = "Đọc từ dữ liệu người chơi của bạn. N/A = không tìm thấy giá trị này.",
        ["Recent rolls to show (5 - 100)."] = "Số lần roll gần đây cần hiển thị (5 - 100).",
        ["Removes buildings, trees and walls on YOUR screen only, to cut lag. Rejoin to get the map back."] = "Xóa nhà cửa, cây cối và tường chỉ trên màn hình CỦA BẠN để giảm lag. Vào lại để lấy lại bản đồ.",
        ["Result of the last apply."] = "Kết quả của lần áp dụng gần nhất.",
        ["Result of the last request."] = "Kết quả của yêu cầu gần nhất.",
        ["Result of the last send."] = "Kết quả của lần gửi gần nhất.",
        ["Rewards claimed since the script started."] = "Phần thưởng đã nhận kể từ khi script khởi động.",
        ["Rolls (2,000 gold each) while your gold is 2,000 or more, then flies back to your spot."] = "Roll (2,000 vàng mỗi lần) khi vàng của bạn từ 2,000 trở lên, rồi bay về vị trí của bạn.",
        ["Run one shopping round right now."] = "Chạy một vòng mua sắm ngay bây giờ.",
        ["Same blade attacks as Auto Farm [ Blades ], but you stay where you are."] = "Đòn đánh blade giống Tự động farm [ Blades ], nhưng bạn đứng yên tại chỗ.",
        ["Save your settings under a name (e.g. FarmBoss)."] = "Lưu cài đặt của bạn dưới một cái tên (ví dụ FarmBoss).",
        ["Seconds to wait after each roll (0.5 - 10)."] = "Số giây chờ sau mỗi lần roll (0.5 - 10).",
        ["Send one test message now."] = "Gửi một tin nhắn thử ngay bây giờ.",
        ["Send the join-lobby request every Join Delay seconds."] = "Gửi yêu cầu vào sảnh mỗi Độ trễ vào giây.",
        ["Send the join-lobby request once."] = "Gửi yêu cầu vào sảnh một lần.",
        ["Send your config to friends with a short code, or import one. Codes hold only your switches (no Webhook URL)."] = "Gửi cấu hình của bạn cho bạn bè bằng mã ngắn, hoặc nhập một mã. Mã chỉ chứa các công tắc của bạn (không có URL Webhook).",
        ["Sends a reward summary to Discord every time a match ends (MISSION COMPLETED screen)."] = "Gửi bản tóm tắt phần thưởng đến Discord mỗi khi một trận kết thúc (màn hình MISSION COMPLETED).",
        ["Set a priority for each memory (0 - 10)."] = "Đặt mức ưu tiên cho từng memory (0 - 10).",
        ["Shoots the wall cannon at the Colossal Titan's nape."] = "Bắn pháo tường vào gáy của Colossal Titan.",
        ["Show or hide the list."] = "Hiện hoặc ẩn danh sách.",
        ["Size in pixels (12 - 128)."] = "Kích thước tính bằng pixel (12 - 128).",
        ["Skip cutscenes and open the reward chest by pressing the real buttons."] = "Bỏ qua cutscene và mở rương thưởng bằng cách nhấn các nút thật.",
        ["Spawned / loading / ready."] = "Đã xuất hiện / đang tải / sẵn sàng.",
        ["Stand still and kill titans in range - no flying to them. Turns Auto Farm [ Blades ] and [ TS ] off while it is on."] = "Đứng yên và tiêu diệt titan trong tầm - không bay đến chúng. Tắt Tự động farm [ Blades ] và [ TS ] khi đang bật.",
        ["Stop, store it and keep rolling, or ask me."] = "Dừng, lưu lại và tiếp tục roll, hoặc hỏi tôi.",
        ["Stops rolling (and turns Auto Roll off) as soon as the machine lands 3 matching cards and shows a reward."] = "Ngừng roll (và tắt Tự động Roll) ngay khi máy ra 3 thẻ trùng nhau và hiện phần thưởng.",
        ["Tap a family to add / remove"] = "Chạm vào một family để thêm / xóa",
        ["The essentials - turn these on and go"] = "Những thứ thiết yếu - bật chúng lên và đi thôi",
        ["The shortcut that hides and shows the window."] = "Phím tắt để ẩn và hiện cửa sổ.",
        ["The specific place ID of this server instance."] = "ID địa điểm cụ thể của phiên bản máy chủ này.",
        ["The unique ID of this game universe."] = "ID duy nhất của vũ trụ game này.",
        ["The whole palette, not just light or dark."] = "Toàn bộ bảng màu, không chỉ sáng hay tối.",
        ["Tick the Modifiers to apply after creating."] = "Đánh dấu các Modifier sẽ áp dụng sau khi tạo.",
        ["Titans closer than this to Eren (studs) are killed first."] = "Titan ở gần Eren hơn khoảng cách này (studs) sẽ bị tiêu diệt trước.",
        ["Used when you cannot afford everything."] = "Dùng khi bạn không đủ khả năng mua tất cả.",
        ["Virtual cursor you can see and click with, even when the game locks your mouse."] = "Con trỏ ảo mà bạn có thể thấy và nhấp, ngay cả khi game khóa chuột của bạn.",
        ["Visit Cole and buy the selected upgrades right now."] = "Đến chỗ Cole và mua các nâng cấp đã chọn ngay bây giờ.",
        ["Visit Lulu and press UPGRADE ALL right now."] = "Đến chỗ Lulu và nhấn UPGRADE ALL ngay bây giờ.",
        ["Visit Youmii and heal right now."] = "Đến chỗ Youmii và chữa trị ngay bây giờ.",
        ["Visits Cole at the start of every new wave and buys the selected upgrades while you have enough gold."] = "Đến chỗ Cole ở đầu mỗi wave mới và mua các nâng cấp đã chọn khi bạn đủ vàng.",
        ["Visits Lulu at the start of every new wave and upgrades all your blade stats while you have enough gold."] = "Đến chỗ Lulu ở đầu mỗi wave mới và nâng cấp tất cả chỉ số blade của bạn khi bạn đủ vàng.",
        ["Visits Youmii at the start of every new wave and heals broken arms / legs (needs enough gold)."] = "Đến chỗ Youmii ở đầu mỗi wave mới và chữa tay / chân bị gãy (cần đủ vàng).",
        ["Waits until the raid boss is fully spawned before Auto Farm starts, so you don't farm while the boss is still loading or frozen."] = "Chờ đến khi boss raid xuất hiện hoàn toàn rồi mới bắt đầu Tự động farm, để bạn không farm khi boss còn đang tải hoặc bị đứng hình.",
        ["What Auto Cannon is doing."] = "Tự động dùng pháo đang làm gì.",
        ["What Auto Defend is doing."] = "Tự động bảo vệ đang làm gì.",
        ["What Auto Farm is doing right now, and why it is paused."] = "Tự động farm đang làm gì lúc này, và vì sao nó đang tạm dừng.",
        ["What Auto Open Chest sees right now."] = "Những gì Tự động mở rương đang nhìn thấy lúc này.",
        ["What Auto Skip Cutscene is doing."] = "Tự động bỏ qua cutscene đang làm gì.",
        ["What Auto Spin is doing now."] = "Tự động Spin đang làm gì lúc này.",
        ["What the script is doing right now."] = "Script đang làm gì lúc này.",
        ["What to do when a mission ends"] = "Việc cần làm khi một nhiệm vụ kết thúc",
        ["When your blades / Thunder Spears run out, goes to the nearest tank, refills, then flies back."] = "Khi blades / Thunder Spears hết, đi đến bình nạp gần nhất, nạp lại, rồi bay về.",
        ["Which parts are running."] = "Những phần nào đang chạy.",
        ["With the Equipment window open: prints every visible text/button to the F9 console."] = "Khi cửa sổ Trang bị đang mở: in mọi văn bản/nút nhìn thấy ra console F9.",
        ["With the Injuries window open: prints every visible text/button to the F9 console."] = "Khi cửa sổ Thương tích đang mở: in mọi văn bản/nút nhìn thấy ra console F9.",
        ["With the Market open: prints every card (name, stars, price, stock) to the F9 console."] = "Khi Chợ đang mở: in mọi thẻ (tên, sao, giá, tồn kho) ra console F9.",
        ["With the Upgrades window open: prints every visible text/button to the F9 console."] = "Khi cửa sổ Nâng cấp đang mở: in mọi văn bản/nút nhìn thấy ra console F9.",
        ["Your roll history."] = "Lịch sử roll của bạn.",
        ["Smooth Hub - Auto Spin"] = "Smooth Hub - Tự động Spin",
    },
    }
    local PREFIXES = {
    TH = {
        { "Retry Amount (", "จำนวนลองใหม่ (" },
        { "Boss Settle Time (", "เวลารอบอสนิ่ง (" },
        { "Current FPS (", "FPS ปัจจุบัน (" },
        { "Enable Slot [", "เปิดสล็อต [" },
        { "Skill Slot [", "สล็อตสกิล [" },
        { "Turn auto press on for slot ", "เปิดกดอัตโนมัติสำหรับสล็อต " },
        { "Auto press key ", "กดปุ่มอัตโนมัติ " },
        { "Seconds between requests (", "วินาทีระหว่างคำขอ (" },
        { "Seconds between starts (", "วินาทีระหว่างการเริ่ม (" },
        { "Repeatedly requests the lobby. Delay is ", "ส่งคำขอเข้าล็อบบี้ซ้ำ ๆ หน่วงเวลา " },
    },
    ES = {
        { "Retry Amount (", "Cantidad de Reintentos (" },
        { "Boss Settle Time (", "Tiempo de Espera del Jefe (" },
        { "Current FPS (", "FPS Actuales (" },
        { "Enable Slot [", "Activar Ranura [" },
        { "Skill Slot [", "Ranura de Habilidad [" },
        { "Turn auto press on for slot ", "Activar pulsación automática para la ranura " },
        { "Auto press key ", "Pulsar tecla automáticamente " },
        { "Seconds between requests (", "Segundos entre solicitudes (" },
        { "Seconds between starts (", "Segundos entre inicios (" },
        { "Repeatedly requests the lobby. Delay is ", "Solicita el lobby repetidamente. El retraso es " },
    },
    VI = {
        { "Retry Amount (", "Số lần thử lại (" },
        { "Boss Settle Time (", "Thời gian chờ Boss ổn định (" },
        { "Current FPS (", "FPS hiện tại (" },
        { "Enable Slot [", "Bật ô [" },
        { "Skill Slot [", "Ô kỹ năng [" },
        { "Turn auto press on for slot ", "Bật tự động nhấn cho ô " },
        { "Auto press key ", "Tự động nhấn phím " },
        { "Seconds between requests (", "Số giây giữa các yêu cầu (" },
        { "Seconds between starts (", "Số giây giữa các lần bắt đầu (" },
        { "Repeatedly requests the lobby. Delay is ", "Liên tục gửi yêu cầu vào sảnh. Độ trễ là " },
    },
    }
    local EXTRA = {
        TH = {
            ["Interface Language"] = "ภาษาของเมนู",
            ["Choose the language used by the Smooth Hub menu."] = "เลือกภาษาที่ใช้ในเมนู Smooth Hub",
            ["🌐 Language"] = "🌐 ภาษา",
            ["Switch the menu text between English, Thai, Spanish and Vietnamese. Game names and numbers stay as they are."] = "สลับข้อความในเมนูระหว่างอังกฤษ ไทย สเปน และเวียดนาม ชื่อในเกมและตัวเลขจะไม่เปลี่ยน",
            ["Current Language"] = "ภาษาปัจจุบัน",
            ["Saved automatically and restored next time."] = "บันทึกอัตโนมัติและกลับมาใช้ในครั้งหน้า",
        },
        ES = {
            ["Interface Language"] = "Idioma de la interfaz",
            ["Choose the language used by the Smooth Hub menu."] = "Elige el idioma que usa el menú de Smooth Hub.",
            ["🌐 Language"] = "🌐 Idioma",
            ["Switch the menu text between English, Thai, Spanish and Vietnamese. Game names and numbers stay as they are."] = "Cambia el texto del menú entre inglés, tailandés, español y vietnamita. Los nombres del juego y los números no cambian.",
            ["Current Language"] = "Idioma actual",
            ["Saved automatically and restored next time."] = "Se guarda automáticamente y se restaura la próxima vez.",
        },
        VI = {
            ["Interface Language"] = "Ngôn ngữ giao diện",
            ["Choose the language used by the Smooth Hub menu."] = "Chọn ngôn ngữ dùng cho menu Smooth Hub.",
            ["🌐 Language"] = "🌐 Ngôn ngữ",
            ["Switch the menu text between English, Thai, Spanish and Vietnamese. Game names and numbers stay as they are."] = "Chuyển văn bản menu giữa tiếng Anh, tiếng Thái, tiếng Tây Ban Nha và tiếng Việt. Tên trong game và các con số giữ nguyên.",
            ["Current Language"] = "Ngôn ngữ hiện tại",
            ["Saved automatically and restored next time."] = "Tự động lưu và khôi phục vào lần sau.",
        },
    }
    -- [smooth] Added translations for newer features (only fills keys that are still missing)
    local EXTRA_NEW = {
        TH = {
            ["Always Keep Families"] = "เก็บตระกูลเหล่านี้เสมอ",
            ["Always keep these, even below Keep Rarity."] = "เก็บตระกูลเหล่านี้เสมอ แม้จะต่ำกว่าความหายากที่ตั้งไว้",
            ["Keep"] = "เก็บ",
            ["Ask"] = "ถาม",
            ["Skip"] = "ข้าม",
            ["Always Ask Families"] = "ถามเสมอสำหรับตระกูลเหล่านี้",
            ["Ask me every time these roll."] = "ถามฉันทุกครั้งที่สุ่มได้ตระกูลเหล่านี้",
            ["Never Keep Families"] = "ไม่เก็บตระกูลเหล่านี้เด็ดขาด",
            ["Never keep these, even above Keep Rarity."] = "ไม่เก็บตระกูลเหล่านี้เด็ดขาด แม้จะสูงกว่าความหายากที่ตั้งไว้",
            ["🔄 Reload & Refill"] = "🔄 รีโหลดและเติมของ",
            ["Reload blades and refill supplies automatically"] = "รีโหลดใบมีดและเติมของให้อัตโนมัติ",
            ["Smart"] = "อัจฉริยะ",
            ["Blades"] = "ใบมีด",
            ["Thunder Spears"] = "หอกสายฟ้า",
            ["Enable [ Auto Farm ]"] = "เปิดใช้ [ ฟาร์มอัตโนมัติ ]",
            ["Turn Auto Farm on or off."] = "เปิดหรือปิดฟาร์มอัตโนมัติ",
            ["Select Equip"] = "เลือกอุปกรณ์",
            ["Blades, Thunder Spears, or Smart (switches automatically)."] = "ใบมีด หอกสายฟ้า หรืออัจฉริยะ (สลับให้อัตโนมัติ)",
            ["Enable [ Auto Refill ]"] = "เปิดใช้ [ เติมของอัตโนมัติ ]",
            ["Turn Auto Refill on or off."] = "เปิดหรือปิดเติมของอัตโนมัติ",
            ["Choose what to refill: Blade, Thunder Spears, or both."] = "เลือกสิ่งที่จะเติม: ใบมีด หอกสายฟ้า หรือทั้งสองอย่าง",
            ["Wait after spawning before farming. 0 = start right away."] = "รอหลังเกิดก่อนเริ่มฟาร์ม 0 = เริ่มทันที",
            ["How high you fly above the titan (150-500). Higher is safer."] = "ความสูงที่บินเหนือไททัน (150-500) ยิ่งสูงยิ่งปลอดภัย",
            ["A mission can't finish sooner than this. 0 = off."] = "ภารกิจจะจบเร็วกว่าค่านี้ไม่ได้ 0 = ปิด",
            ["Lose on purpose after this many wins in a row. 0 = never."] = "แพ้โดยตั้งใจหลังชนะติดกันครบตามจำนวนนี้ 0 = ไม่เคย",
            ["How long the key is held in Hold mode."] = "ระยะเวลาที่กดปุ่มค้างในโหมดกดค้าง",
            ["Wait before pressing the same slot again (match your skill cooldown)."] = "รอก่อนกดช่องเดิมอีกครั้ง (ให้ตรงกับคูลดาวน์สกิลของคุณ)",
            ["🛠️ Auto Quest [ Thunder Spear ]"] = "🛠️ เควสอัตโนมัติ [ หอกสายฟ้า ]",
            ["Enable"] = "เปิดใช้",
            ["Auto Quest [ Thunder Spear ] Round ( 1 )"] = "เควสอัตโนมัติ [ หอกสายฟ้า ] รอบ ( 1 )",
            ["Auto-does Round 1: stand on the 3 watchtowers. Needs Prestige 1+ and Level 80+."] = "ทำรอบ 1 ให้อัตโนมัติ: ยืนบนหอสังเกตการณ์ 3 แห่ง ต้องมีเพรสทีจ 1+ และเลเวล 80+",
            ["Auto Quest [ Thunder Spear ] Round ( 2 )"] = "เควสอัตโนมัติ [ หอกสายฟ้า ] รอบ ( 2 )",
            ["Auto-does Round 2: carry the 3 supply crates. Needs Prestige 1+ and Level 80+."] = "ทำรอบ 2 ให้อัตโนมัติ: ขนลังเสบียง 3 ลัง ต้องมีเพรสทีจ 1+ และเลเวล 80+",
            ["Auto Quest [ Thunder Spear ] Round ( 3 )"] = "เควสอัตโนมัติ [ หอกสายฟ้า ] รอบ ( 3 )",
            ["Auto-does Round 3: plays 3 games, then turns itself off. Needs Prestige 1+ and Level 80+."] = "ทำรอบ 3 ให้อัตโนมัติ: เล่น 3 เกม แล้วปิดตัวเอง ต้องมีเพรสทีจ 1+ และเลเวล 80+",
            ["Prestige Status"] = "สถานะเพรสทีจ",
            ["Skills"] = "สกิล",
            ["Select Mission"] = "เลือกภารกิจ",
            ["Choose the mission."] = "เลือกภารกิจ",
            ["Select Objective"] = "เลือกเป้าหมาย",
            ["Only Skirmish for now."] = "ตอนนี้มีเฉพาะ Skirmish",
            ["Select Difficulty"] = "เลือกความยาก",
            ["Difficulty used when creating the room."] = "ระดับความยากที่ใช้ตอนสร้างห้อง",
            ["Select Raid"] = "เลือกเรด",
            ["Choose the raid boss."] = "เลือกบอสเรด",
            ["Colossal Titan always uses Aberrant."] = "Colossal Titan ใช้ Aberrant เสมอ",
            ["Select Map"] = "เลือกแมป",
            ["Choose the wave map."] = "เลือกแมปเวฟ",
            ["Waves only has Easy for now."] = "ตอนนี้เวฟมีเฉพาะระดับ Easy",
            ["Buy Categories"] = "หมวดที่จะซื้อ",
            ["Pick what to buy: Perks (tab 1), Artifacts (tab 2), Memories (tab 3), Crates."] = "เลือกสิ่งที่จะซื้อ: เพิร์ก (แท็บ 1), อาร์ติแฟกต์ (แท็บ 2), เมมโมรี (แท็บ 3), ลัง",
            ["Perk Stars"] = "ดาวของเพิร์ก",
            ["Which star levels to buy for Perks (Common = 1 star, Rare = 3 stars ...)."] = "ระดับดาวของเพิร์กที่จะซื้อ (Common = 1 ดาว, Rare = 3 ดาว ...)",
            ["Artifact Stars"] = "ดาวของอาร์ติแฟกต์",
            ["Which star levels to buy for Artifacts (Goggles, Journal, Glasses, Ring, Key ...)."] = "ระดับดาวของอาร์ติแฟกต์ที่จะซื้อ (Goggles, Journal, Glasses, Ring, Key ...)",
            ["Memory Stars"] = "ดาวของเมมโมรี",
            ["Which star levels to buy for Memories (Swiftshot, Riposte, Guardian ...)."] = "ระดับดาวของเมมโมรีที่จะซื้อ (Swiftshot, Riposte, Guardian ...)",
            ["Highest star first"] = "ดาวสูงสุดก่อน",
            ["Cheapest first"] = "ถูกที่สุดก่อน",
            ["Most expensive first"] = "แพงที่สุดก่อน",
            ["Max Price"] = "ราคาสูงสุด",
            ["Skip cards that cost more than this (0 = no limit)."] = "ข้ามการ์ดที่ราคาสูงกว่านี้ (0 = ไม่จำกัด)",
            ["Keep Coins"] = "เก็บเหรียญไว้",
            ["Always leave at least this many coins unspent."] = "เหลือเหรียญไว้ไม่ใช้อย่างน้อยเท่านี้เสมอ",
            ["Character [ RGB ]"] = "ตัวละคร [ RGB ]",
            ["Rainbow outline around your character."] = "เส้นขอบสีรุ้งรอบตัวละครของคุณ",
            ["Result of the last action."] = "ผลของการกระทำล่าสุด",
            ["Config in use"] = "คอนฟิกที่ใช้อยู่",
            ["The config you picked or created. Your changes belong to this config."] = "คอนฟิกที่คุณเลือกหรือสร้าง การเปลี่ยนแปลงของคุณจะอยู่ในคอนฟิกนี้",
            ["Auto-save into config"] = "บันทึกลงคอนฟิกอัตโนมัติ",
            ["ON: every change is saved into the config in use by itself. OFF: only when you press Enter Save Config."] = "เปิด: ทุกการเปลี่ยนแปลงจะถูกบันทึกลงคอนฟิกที่ใช้อยู่เอง ปิด: บันทึกเมื่อกด Enter Save Config เท่านั้น",
            ["Current autoload config"] = "คอนฟิกที่โหลดอัตโนมัติตอนนี้",
            ["Loaded when the script starts."] = "โหลดเมื่อสคริปต์เริ่มทำงาน",
            ["Easy (E- Grade)"] = "ง่าย (เกรด E-)",
            ["Normal (E+ Grade)"] = "ปกติ (เกรด E+)",
            ["Hard (D+ Grade)"] = "ยาก (เกรด D+)",
            ["Hard (C- Grade)"] = "ยาก (เกรด C-)",
            ["Severe (B- Grade)"] = "รุนแรง (เกรด B-)",
            ["Aberrant (A- Grade)"] = "Aberrant (เกรด A-)",
            ["Aberrant (A Grade)"] = "Aberrant (เกรด A)",
            ["Severe"] = "รุนแรง",
            ["Common → Rare Chance"] = "โอกาส Common → Rare",
            ["Rare → Epic Chance"] = "โอกาส Rare → Epic",
            ["Epic → Legendary Chance"] = "โอกาส Epic → Legendary",
            ["Legendary → Mythic Chance"] = "โอกาส Legendary → Mythic",
            ["Left Path"] = "เส้นทางซ้าย",
            ["Middle Path"] = "เส้นทางกลาง",
            ["Right Path"] = "เส้นทางขวา",
            ["Share status"] = "สถานะการแชร์",
            ["Result of the last share / import."] = "ผลของการแชร์ / นำเข้าล่าสุด",
            ["Copy share code"] = "คัดลอกโค้ดแชร์",
            ["Copies the selected config (or your current switches if none is selected). Paste it in Discord."] = "คัดลอกคอนฟิกที่เลือก (หรือสวิตช์ปัจจุบันของคุณถ้าไม่ได้เลือก) แล้วนำไปวางใน Discord",
            ["Import code / link / file"] = "นำเข้าโค้ด / ลิงก์ / ไฟล์",
            ["Paste a share code, a getgenv().Configs text, a link to a .txt, or a file name from workspace/"] = "วางโค้ดแชร์ ข้อความ getgenv().Configs ลิงก์ไฟล์ .txt หรือชื่อไฟล์จาก workspace/",
            ["Import config"] = "นำเข้าคอนฟิก",
            ["Adds it to your Config list. Pick it in Config list and press Load to use it."] = "เพิ่มลงในรายการคอนฟิกของคุณ เลือกในรายการคอนฟิกแล้วกด Load เพื่อใช้งาน",
        },
        ES = {
            ["Always Keep Families"] = "Conservar siempre estas familias",
            ["Always keep these, even below Keep Rarity."] = "Conserva siempre estas, incluso por debajo de la rareza configurada.",
            ["Keep"] = "Conservar",
            ["Ask"] = "Preguntar",
            ["Skip"] = "Omitir",
            ["Always Ask Families"] = "Preguntar siempre por estas familias",
            ["Ask me every time these roll."] = "Pregúntame cada vez que salgan estas.",
            ["Never Keep Families"] = "No conservar nunca estas familias",
            ["Never keep these, even above Keep Rarity."] = "No conservar nunca estas, incluso por encima de la rareza configurada.",
            ["🔄 Reload & Refill"] = "🔄 Recargar y Rellenar",
            ["Reload blades and refill supplies automatically"] = "Recarga espadas y rellena suministros automáticamente",
            ["Smart"] = "Inteligente",
            ["Blades"] = "Espadas",
            ["Thunder Spears"] = "Lanzas de Trueno",
            ["Enable [ Auto Farm ]"] = "Activar [ Auto Farmeo ]",
            ["Turn Auto Farm on or off."] = "Activa o desactiva el Auto Farmeo.",
            ["Select Equip"] = "Seleccionar equipo",
            ["Blades, Thunder Spears, or Smart (switches automatically)."] = "Espadas, Lanzas de Trueno o Inteligente (cambia automáticamente).",
            ["Enable [ Auto Refill ]"] = "Activar [ Auto Recarga ]",
            ["Turn Auto Refill on or off."] = "Activa o desactiva la Auto Recarga.",
            ["Choose what to refill: Blade, Thunder Spears, or both."] = "Elige qué rellenar: Espada, Lanzas de Trueno o ambas.",
            ["Wait after spawning before farming. 0 = start right away."] = "Espera tras aparecer antes de farmear. 0 = empezar de inmediato.",
            ["How high you fly above the titan (150-500). Higher is safer."] = "Qué altura vuelas sobre el titán (150-500). Más alto es más seguro.",
            ["A mission can't finish sooner than this. 0 = off."] = "Una misión no puede terminar antes de este tiempo. 0 = desactivado.",
            ["Lose on purpose after this many wins in a row. 0 = never."] = "Pierde a propósito tras esta cantidad de victorias seguidas. 0 = nunca.",
            ["How long the key is held in Hold mode."] = "Cuánto tiempo se mantiene la tecla en modo Mantener.",
            ["Wait before pressing the same slot again (match your skill cooldown)."] = "Espera antes de volver a pulsar la misma ranura (ajústalo al enfriamiento de tu habilidad).",
            ["🛠️ Auto Quest [ Thunder Spear ]"] = "🛠️ Auto Misión [ Lanza de Trueno ]",
            ["Enable"] = "Activar",
            ["Auto Quest [ Thunder Spear ] Round ( 1 )"] = "Auto Misión [ Lanza de Trueno ] Ronda ( 1 )",
            ["Auto-does Round 1: stand on the 3 watchtowers. Needs Prestige 1+ and Level 80+."] = "Hace la Ronda 1 automáticamente: colócate en las 3 torres de vigilancia. Requiere Prestigio 1+ y Nivel 80+.",
            ["Auto Quest [ Thunder Spear ] Round ( 2 )"] = "Auto Misión [ Lanza de Trueno ] Ronda ( 2 )",
            ["Auto-does Round 2: carry the 3 supply crates. Needs Prestige 1+ and Level 80+."] = "Hace la Ronda 2 automáticamente: lleva las 3 cajas de suministros. Requiere Prestigio 1+ y Nivel 80+.",
            ["Auto Quest [ Thunder Spear ] Round ( 3 )"] = "Auto Misión [ Lanza de Trueno ] Ronda ( 3 )",
            ["Auto-does Round 3: plays 3 games, then turns itself off. Needs Prestige 1+ and Level 80+."] = "Hace la Ronda 3 automáticamente: juega 3 partidas y luego se desactiva. Requiere Prestigio 1+ y Nivel 80+.",
            ["Prestige Status"] = "Estado de Prestigio",
            ["Skills"] = "Habilidades",
            ["Select Mission"] = "Seleccionar misión",
            ["Choose the mission."] = "Elige la misión.",
            ["Select Objective"] = "Seleccionar objetivo",
            ["Only Skirmish for now."] = "Por ahora solo Skirmish.",
            ["Select Difficulty"] = "Seleccionar dificultad",
            ["Difficulty used when creating the room."] = "Dificultad usada al crear la sala.",
            ["Select Raid"] = "Seleccionar raid",
            ["Choose the raid boss."] = "Elige el jefe de la raid.",
            ["Colossal Titan always uses Aberrant."] = "El Titán Colosal siempre usa Aberrant.",
            ["Select Map"] = "Seleccionar mapa",
            ["Choose the wave map."] = "Elige el mapa de oleadas.",
            ["Waves only has Easy for now."] = "Las oleadas solo tienen Easy por ahora.",
            ["Buy Categories"] = "Categorías a comprar",
            ["Pick what to buy: Perks (tab 1), Artifacts (tab 2), Memories (tab 3), Crates."] = "Elige qué comprar: Ventajas (pestaña 1), Artefactos (pestaña 2), Recuerdos (pestaña 3), Cajas.",
            ["Perk Stars"] = "Estrellas de Ventajas",
            ["Which star levels to buy for Perks (Common = 1 star, Rare = 3 stars ...)."] = "Qué niveles de estrellas comprar para Ventajas (Common = 1 estrella, Rare = 3 estrellas ...).",
            ["Artifact Stars"] = "Estrellas de Artefactos",
            ["Which star levels to buy for Artifacts (Goggles, Journal, Glasses, Ring, Key ...)."] = "Qué niveles de estrellas comprar para Artefactos (Goggles, Journal, Glasses, Ring, Key ...).",
            ["Memory Stars"] = "Estrellas de Recuerdos",
            ["Which star levels to buy for Memories (Swiftshot, Riposte, Guardian ...)."] = "Qué niveles de estrellas comprar para Recuerdos (Swiftshot, Riposte, Guardian ...).",
            ["Highest star first"] = "Primero la de más estrellas",
            ["Cheapest first"] = "Primero la más barata",
            ["Most expensive first"] = "Primero la más cara",
            ["Max Price"] = "Precio máximo",
            ["Skip cards that cost more than this (0 = no limit)."] = "Omite cartas que cuesten más que esto (0 = sin límite).",
            ["Keep Coins"] = "Reservar monedas",
            ["Always leave at least this many coins unspent."] = "Deja siempre al menos esta cantidad de monedas sin gastar.",
            ["Character [ RGB ]"] = "Personaje [ RGB ]",
            ["Rainbow outline around your character."] = "Contorno arcoíris alrededor de tu personaje.",
            ["Result of the last action."] = "Resultado de la última acción.",
            ["Config in use"] = "Config en uso",
            ["The config you picked or created. Your changes belong to this config."] = "El config que elegiste o creaste. Tus cambios pertenecen a este config.",
            ["Auto-save into config"] = "Autoguardar en el config",
            ["ON: every change is saved into the config in use by itself. OFF: only when you press Enter Save Config."] = "ON: cada cambio se guarda solo en el config en uso. OFF: solo cuando pulsas Enter Save Config.",
            ["Current autoload config"] = "Config de carga automática actual",
            ["Loaded when the script starts."] = "Se carga cuando arranca el script.",
            ["Easy (E- Grade)"] = "Fácil (Grado E-)",
            ["Normal (E+ Grade)"] = "Normal (Grado E+)",
            ["Hard (D+ Grade)"] = "Difícil (Grado D+)",
            ["Hard (C- Grade)"] = "Difícil (Grado C-)",
            ["Severe (B- Grade)"] = "Severo (Grado B-)",
            ["Aberrant (A- Grade)"] = "Aberrant (Grado A-)",
            ["Aberrant (A Grade)"] = "Aberrant (Grado A)",
            ["Severe"] = "Severo",
            ["Common → Rare Chance"] = "Probabilidad Common → Rare",
            ["Rare → Epic Chance"] = "Probabilidad Rare → Epic",
            ["Epic → Legendary Chance"] = "Probabilidad Epic → Legendary",
            ["Legendary → Mythic Chance"] = "Probabilidad Legendary → Mythic",
            ["Left Path"] = "Camino izquierdo",
            ["Middle Path"] = "Camino central",
            ["Right Path"] = "Camino derecho",
            ["Share status"] = "Estado de compartir",
            ["Result of the last share / import."] = "Resultado del último compartir / importar.",
            ["Copy share code"] = "Copiar código para compartir",
            ["Copies the selected config (or your current switches if none is selected). Paste it in Discord."] = "Copia el config seleccionado (o tus interruptores actuales si no hay ninguno). Pégalo en Discord.",
            ["Import code / link / file"] = "Importar código / enlace / archivo",
            ["Paste a share code, a getgenv().Configs text, a link to a .txt, or a file name from workspace/"] = "Pega un código para compartir, un texto getgenv().Configs, un enlace a un .txt o un nombre de archivo de workspace/",
            ["Import config"] = "Importar config",
            ["Adds it to your Config list. Pick it in Config list and press Load to use it."] = "Lo añade a tu lista de configs. Elígelo en la lista de configs y pulsa Load para usarlo.",
        },
        VI = {
            ["Always Keep Families"] = "Luôn giữ các family này",
            ["Always keep these, even below Keep Rarity."] = "Luôn giữ những family này, kể cả khi thấp hơn độ hiếm đã đặt.",
            ["Keep"] = "Giữ",
            ["Ask"] = "Hỏi",
            ["Skip"] = "Bỏ qua",
            ["Always Ask Families"] = "Luôn hỏi với các family này",
            ["Ask me every time these roll."] = "Hỏi tôi mỗi khi roll ra những family này.",
            ["Never Keep Families"] = "Không bao giờ giữ các family này",
            ["Never keep these, even above Keep Rarity."] = "Không bao giờ giữ những family này, kể cả khi cao hơn độ hiếm đã đặt.",
            ["🔄 Reload & Refill"] = "🔄 Nạp kiếm & Nạp lại",
            ["Reload blades and refill supplies automatically"] = "Tự động nạp kiếm và nạp lại vật tư",
            ["Smart"] = "Thông minh",
            ["Blades"] = "Blades",
            ["Thunder Spears"] = "Thunder Spears",
            ["Enable [ Auto Farm ]"] = "Bật [ Tự động farm ]",
            ["Turn Auto Farm on or off."] = "Bật hoặc tắt Tự động farm.",
            ["Select Equip"] = "Chọn trang bị",
            ["Blades, Thunder Spears, or Smart (switches automatically)."] = "Blades, Thunder Spears hoặc Thông minh (tự động chuyển).",
            ["Enable [ Auto Refill ]"] = "Bật [ Tự động nạp lại ]",
            ["Turn Auto Refill on or off."] = "Bật hoặc tắt Tự động nạp lại.",
            ["Choose what to refill: Blade, Thunder Spears, or both."] = "Chọn thứ cần nạp lại: Blade, Thunder Spears hoặc cả hai.",
            ["Wait after spawning before farming. 0 = start right away."] = "Chờ sau khi xuất hiện rồi mới farm. 0 = bắt đầu ngay.",
            ["How high you fly above the titan (150-500). Higher is safer."] = "Độ cao bay trên titan (150-500). Càng cao càng an toàn.",
            ["A mission can't finish sooner than this. 0 = off."] = "Nhiệm vụ không thể kết thúc sớm hơn mức này. 0 = tắt.",
            ["Lose on purpose after this many wins in a row. 0 = never."] = "Cố tình thua sau khi thắng liên tiếp chừng này lần. 0 = không bao giờ.",
            ["How long the key is held in Hold mode."] = "Thời gian giữ phím trong chế độ Giữ.",
            ["Wait before pressing the same slot again (match your skill cooldown)."] = "Chờ trước khi nhấn lại cùng ô (khớp với thời gian hồi chiêu của bạn).",
            ["🛠️ Auto Quest [ Thunder Spear ]"] = "🛠️ Tự động nhiệm vụ [ Thunder Spear ]",
            ["Enable"] = "Bật",
            ["Auto Quest [ Thunder Spear ] Round ( 1 )"] = "Tự động nhiệm vụ [ Thunder Spear ] Vòng ( 1 )",
            ["Auto-does Round 1: stand on the 3 watchtowers. Needs Prestige 1+ and Level 80+."] = "Tự động làm Vòng 1: đứng trên 3 tháp canh. Cần Prestige 1+ và Cấp 80+.",
            ["Auto Quest [ Thunder Spear ] Round ( 2 )"] = "Tự động nhiệm vụ [ Thunder Spear ] Vòng ( 2 )",
            ["Auto-does Round 2: carry the 3 supply crates. Needs Prestige 1+ and Level 80+."] = "Tự động làm Vòng 2: khuân 3 thùng tiếp tế. Cần Prestige 1+ và Cấp 80+.",
            ["Auto Quest [ Thunder Spear ] Round ( 3 )"] = "Tự động nhiệm vụ [ Thunder Spear ] Vòng ( 3 )",
            ["Auto-does Round 3: plays 3 games, then turns itself off. Needs Prestige 1+ and Level 80+."] = "Tự động làm Vòng 3: chơi 3 ván rồi tự tắt. Cần Prestige 1+ và Cấp 80+.",
            ["Prestige Status"] = "Trạng thái Prestige",
            ["Skills"] = "Kỹ năng",
            ["Select Mission"] = "Chọn nhiệm vụ",
            ["Choose the mission."] = "Chọn nhiệm vụ.",
            ["Select Objective"] = "Chọn mục tiêu",
            ["Only Skirmish for now."] = "Hiện chỉ có Skirmish.",
            ["Select Difficulty"] = "Chọn độ khó",
            ["Difficulty used when creating the room."] = "Độ khó dùng khi tạo phòng.",
            ["Select Raid"] = "Chọn Raid",
            ["Choose the raid boss."] = "Chọn boss Raid.",
            ["Colossal Titan always uses Aberrant."] = "Colossal Titan luôn dùng Aberrant.",
            ["Select Map"] = "Chọn bản đồ",
            ["Choose the wave map."] = "Chọn bản đồ wave.",
            ["Waves only has Easy for now."] = "Wave hiện chỉ có Easy.",
            ["Buy Categories"] = "Danh mục cần mua",
            ["Pick what to buy: Perks (tab 1), Artifacts (tab 2), Memories (tab 3), Crates."] = "Chọn thứ cần mua: Perk (tab 1), Artifact (tab 2), Memory (tab 3), Thùng.",
            ["Perk Stars"] = "Sao của Perk",
            ["Which star levels to buy for Perks (Common = 1 star, Rare = 3 stars ...)."] = "Mức sao cần mua cho Perk (Common = 1 sao, Rare = 3 sao ...).",
            ["Artifact Stars"] = "Sao của Artifact",
            ["Which star levels to buy for Artifacts (Goggles, Journal, Glasses, Ring, Key ...)."] = "Mức sao cần mua cho Artifact (Goggles, Journal, Glasses, Ring, Key ...).",
            ["Memory Stars"] = "Sao của Memory",
            ["Which star levels to buy for Memories (Swiftshot, Riposte, Guardian ...)."] = "Mức sao cần mua cho Memory (Swiftshot, Riposte, Guardian ...).",
            ["Highest star first"] = "Sao cao nhất trước",
            ["Cheapest first"] = "Rẻ nhất trước",
            ["Most expensive first"] = "Đắt nhất trước",
            ["Max Price"] = "Giá tối đa",
            ["Skip cards that cost more than this (0 = no limit)."] = "Bỏ qua thẻ có giá cao hơn mức này (0 = không giới hạn).",
            ["Keep Coins"] = "Giữ lại xu",
            ["Always leave at least this many coins unspent."] = "Luôn chừa lại ít nhất chừng này xu chưa tiêu.",
            ["Character [ RGB ]"] = "Nhân vật [ RGB ]",
            ["Rainbow outline around your character."] = "Viền cầu vồng quanh nhân vật của bạn.",
            ["Result of the last action."] = "Kết quả của hành động gần nhất.",
            ["Config in use"] = "Cấu hình đang dùng",
            ["The config you picked or created. Your changes belong to this config."] = "Cấu hình bạn đã chọn hoặc tạo. Các thay đổi của bạn thuộc về cấu hình này.",
            ["Auto-save into config"] = "Tự động lưu vào cấu hình",
            ["ON: every change is saved into the config in use by itself. OFF: only when you press Enter Save Config."] = "BẬT: mọi thay đổi tự lưu vào cấu hình đang dùng. TẮT: chỉ khi bạn nhấn Enter Save Config.",
            ["Current autoload config"] = "Cấu hình tự tải hiện tại",
            ["Loaded when the script starts."] = "Được tải khi script khởi động.",
            ["Easy (E- Grade)"] = "Dễ (Hạng E-)",
            ["Normal (E+ Grade)"] = "Thường (Hạng E+)",
            ["Hard (D+ Grade)"] = "Khó (Hạng D+)",
            ["Hard (C- Grade)"] = "Khó (Hạng C-)",
            ["Severe (B- Grade)"] = "Nghiêm trọng (Hạng B-)",
            ["Aberrant (A- Grade)"] = "Aberrant (Hạng A-)",
            ["Aberrant (A Grade)"] = "Aberrant (Hạng A)",
            ["Severe"] = "Nghiêm trọng",
            ["Common → Rare Chance"] = "Tỷ lệ Common → Rare",
            ["Rare → Epic Chance"] = "Tỷ lệ Rare → Epic",
            ["Epic → Legendary Chance"] = "Tỷ lệ Epic → Legendary",
            ["Legendary → Mythic Chance"] = "Tỷ lệ Legendary → Mythic",
            ["Left Path"] = "Nhánh trái",
            ["Middle Path"] = "Nhánh giữa",
            ["Right Path"] = "Nhánh phải",
            ["Share status"] = "Trạng thái chia sẻ",
            ["Result of the last share / import."] = "Kết quả của lần chia sẻ / nhập gần nhất.",
            ["Copy share code"] = "Sao chép mã chia sẻ",
            ["Copies the selected config (or your current switches if none is selected). Paste it in Discord."] = "Sao chép cấu hình đã chọn (hoặc các công tắc hiện tại nếu chưa chọn). Dán vào Discord.",
            ["Import code / link / file"] = "Nhập mã / liên kết / tệp",
            ["Paste a share code, a getgenv().Configs text, a link to a .txt, or a file name from workspace/"] = "Dán mã chia sẻ, văn bản getgenv().Configs, liên kết tới tệp .txt hoặc tên tệp trong workspace/",
            ["Import config"] = "Nhập cấu hình",
            ["Adds it to your Config list. Pick it in Config list and press Load to use it."] = "Thêm vào danh sách cấu hình của bạn. Chọn trong danh sách cấu hình và nhấn Load để dùng.",
        },
    }
    local PREFIXES_NEW = {
        TH = {
            { "Set Start Farm (", "ตั้งเวลาเริ่มฟาร์ม (" },
            { "Fly Height (", "ความสูงการบิน (" },
            { "Current Retry (", "รีทรายปัจจุบัน (" },
            { "Safe Time (", "เวลาปลอดภัย (" },
            { "Fail Safe At [", "ระบบกันพลาดที่ [" },
            { "Current Streak (", "สตรีคปัจจุบัน (" },
            { "Hold Time (", "เวลากดค้าง (" },
            { "Press Delay (", "หน่วงเวลากด (" },
            { "Defend Radius (", "รัศมีป้องกัน (" },
            { "Leave After Waves Cleared (", "ออกหลังเคลียร์เวฟ (" },
            { "Attack Range (", "ระยะโจมตี (" },
            { "Min Gold To Visit NPC (", "ทองขั้นต่ำเพื่อไปหา NPC (" },
            { "Left Priority (", "ลำดับซ้าย (" },
            { "Middle Priority (", "ลำดับกลาง (" },
            { "Right Priority (", "ลำดับขวา (" },
        },
        ES = {
            { "Set Start Farm (", "Iniciar Farmeo tras (" },
            { "Fly Height (", "Altura de Vuelo (" },
            { "Current Retry (", "Reintento Actual (" },
            { "Safe Time (", "Tiempo Seguro (" },
            { "Fail Safe At [", "Seguro de Fallo en [" },
            { "Current Streak (", "Racha Actual (" },
            { "Hold Time (", "Tiempo de Mantener (" },
            { "Press Delay (", "Retraso de Pulsación (" },
            { "Defend Radius (", "Radio de Defensa (" },
            { "Leave After Waves Cleared (", "Salir tras Oleadas Superadas (" },
            { "Attack Range (", "Alcance de Ataque (" },
            { "Min Gold To Visit NPC (", "Oro Mínimo para Visitar NPC (" },
            { "Left Priority (", "Prioridad izquierda (" },
            { "Middle Priority (", "Prioridad central (" },
            { "Right Priority (", "Prioridad derecha (" },
        },
        VI = {
            { "Set Start Farm (", "Đặt thời gian bắt đầu farm (" },
            { "Fly Height (", "Độ cao bay (" },
            { "Current Retry (", "Số lần thử lại hiện tại (" },
            { "Safe Time (", "Thời gian an toàn (" },
            { "Fail Safe At [", "Fail Safe tại [" },
            { "Current Streak (", "Chuỗi hiện tại (" },
            { "Hold Time (", "Thời gian giữ (" },
            { "Press Delay (", "Độ trễ nhấn (" },
            { "Defend Radius (", "Bán kính phòng thủ (" },
            { "Leave After Waves Cleared (", "Rời sau khi dọn Wave (" },
            { "Attack Range (", "Tầm tấn công (" },
            { "Min Gold To Visit NPC (", "Vàng tối thiểu để gặp NPC (" },
            { "Left Priority (", "Ưu tiên trái (" },
            { "Middle Priority (", "Ưu tiên giữa (" },
            { "Right Priority (", "Ưu tiên phải (" },
        },
    }
    for code, extra in pairs(EXTRA_NEW) do
        for k, v in pairs(extra) do
            if DICTS[code][k] == nil then DICTS[code][k] = v end
        end
    end
    for code, list in pairs(PREFIXES_NEW) do
        PREFIXES[code] = PREFIXES[code] or {}
        for _, pr in ipairs(list) do table.insert(PREFIXES[code], pr) end
    end

    for code, extra in pairs(EXTRA) do
        for k, v in pairs(extra) do DICTS[code][k] = v end
    end

    local saved = SettingsStore.Load(LANG_FILE)
    local lang = "EN"
    if type(saved) == "table" and (saved.Lang == "TH" or saved.Lang == "ES" or saved.Lang == "VI") then lang = saved.Lang end
    local function LangIndex()
        for i, c in ipairs(LANG_CODES) do if c == lang then return i end end
        return 1
    end
    SH.Lang = lang
    function SH.GetLang() return lang end

    local function trim(s) return (s:match("^%s*(.-)%s*$")) end
    local function Translate(text)
        if type(text) ~= "string" or text == "" then return nil end
        if text:find("<", 1, true) then return nil end -- ข้อความ RichText ไม่แตะ
        local dict = DICTS[lang]
        if not dict then return nil end
        local hit = dict[text] or dict[trim(text)]
        if hit then return hit end
        for _, p in ipairs(PREFIXES[lang] or {}) do
            if text:sub(1, #p[1]) == p[1] then return p[2] .. text:sub(#p[1] + 1) end
        end
        return nil
    end

    local TRACK = setmetatable({}, { __mode = "k" }) -- label -> { orig, shown, conn }
    local applying = false
    local root, rootConn = nil, nil

    local function isTextObj(o)
        return o:IsA("TextLabel") or o:IsA("TextButton")
    end

    local function Refresh(o)
        local rec = TRACK[o]
        if not rec then return end
        local cur = o.Text
        if cur ~= rec.shown then rec.orig = cur end -- สคริปต์เปลี่ยนข้อความเอง (เช่น สถานะ) -> ถือเป็นต้นฉบับใหม่
        local target = rec.orig
        if lang ~= "EN" then target = Translate(rec.orig) or rec.orig end
        rec.shown = target
        if cur ~= target then
            applying = true
            pcall(function() o.Text = target end)
            applying = false
        end
    end

    local function Track(o)
        if TRACK[o] or not isTextObj(o) then return end
        local rec = { orig = o.Text, shown = o.Text }
        TRACK[o] = rec
        rec.conn = o:GetPropertyChangedSignal("Text"):Connect(function()
            if applying then return end
            Refresh(o)
        end)
        if lang ~= "EN" then Refresh(o) end
    end

    local function ApplyAll()
        local n = 0
        for o in pairs(TRACK) do
            if o.Parent then Refresh(o) end
            n += 1
            if n % 400 == 0 then task.wait() end
        end
    end

    local function FindRoot(seed)
        local r
        pcall(function()
            if seed and seed.__instance then r = seed.__instance:FindFirstAncestorOfClass("ScreenGui") end
        end)
        if not r then
            pcall(function() r = Window.__instance and Window.__instance:FindFirstAncestorOfClass("ScreenGui") end)
        end
        if not r then
            local parents = {}
            if type(gethui) == "function" then pcall(function() table.insert(parents, gethui()) end) end
            pcall(function() table.insert(parents, game:GetService("CoreGui")) end)
            for _, p in ipairs(parents) do
                for _, g in ipairs(p:GetChildren()) do
                    if g:IsA("ScreenGui") and (g.Name:find("Smooth Hub", 1, true) or g.Name:find("Cascade", 1, true)) and g.Name ~= "SmoothHubToggle" then
                        r = g
                        break
                    end
                end
                if r then break end
            end
        end
        return r
    end

    local function Attach(seed)
        local r = FindRoot(seed)
        if not r then
            warn("[Smooth Hub] Language: could not find the menu GUI, translation disabled")
            return
        end
        if r == root then return end
        if rootConn then rootConn:Disconnect() end
        root = r
        rootConn = root.DescendantAdded:Connect(function(d)
            if not Alive() then return end
            if isTextObj(d) then Track(d) end
        end)
        task.spawn(function()
            local n = 0
            for _, d in ipairs(root:GetDescendants()) do
                if isTextObj(d) then Track(d) end
                n += 1
                if n % 400 == 0 then task.wait() end
            end
        end)
    end

    local TAB = SH.LangTab
    local Section = TAB:PageSection({
        Title = "🌐 Language",
        Subtitle = "Switch the menu text between English, Thai, Spanish and Vietnamese. Game names and numbers stay as they are."
    })
    local Form = Section:Form()

    local Row = Form:Row()
    Row:Left():TitleStack({
        Title = "Interface Language",
        Subtitle = "Choose the language used by the Smooth Hub menu."
    })
    local LangBtn = Row:Right():PullDownButton({
        Label = LANG_OPTIONS[LangIndex()],
        Options = LANG_OPTIONS,
        Value = LangIndex(),
        ValueChanged = function(self, index)
            local code = LANG_CODES[index]
            if not code or code == lang then return end
            lang = code
            SH.Lang = code
            self.Label = LANG_OPTIONS[index]
            SettingsStore.Write(LANG_FILE, { Lang = code })
            if not root then Attach(self) end
            task.spawn(ApplyAll)
        end
    })
    pcall(StyleDropdown, LangBtn)

    local Row2 = Form:Row()
    Row2:Left():TitleStack({
        Title = "Current Language",
        Subtitle = "Saved automatically and restored next time."
    })
    Row2:Right():Label({ Text = "ENG / ไทย / ESP / VIE" })

    -- เริ่มติดตามหลังสร้างเมนูครบ (แท็บที่สร้างหลังบล็อกนี้จะถูกจับด้วย DescendantAdded)
    task.spawn(function()
        task.wait(0.5)
        if not Alive() then return end
        Attach(LangBtn)
        if lang ~= "EN" then
            task.wait(0.5)
            ApplyAll()
        end
    end)

    local oldCleanup = _G.SmoothHubCleanup
    _G.SmoothHubCleanup = function()
        pcall(function() if rootConn then rootConn:Disconnect() end end)
        pcall(function()
            lang = "EN"
            for o, rec in pairs(TRACK) do
                if rec.conn then rec.conn:Disconnect() end
                if o.Parent and o.Text ~= rec.orig then o.Text = rec.orig end
            end
        end)
        if type(oldCleanup) == "function" then pcall(oldCleanup) end
    end
end)

ConfigTab = SettingsCategory:Tab({
    Title = "Config",
    Icon = Icon("folderBadgeGearshape", "folderFill", "folder")
})
do
    local ConfigSection = ConfigTab:PageSection({
        Title = "📁 Configuration",
        Subtitle = "Save your settings under a name (e.g. FarmBoss)."
    })
    local ConfigForm = ConfigSection:Form()
    local typedName = ""
    local selectedName = nil
    local currentOptions = { "---" }
    local ListBtn
    local RefreshList
    local function AddRow(title, subtitle)
        local row = ConfigForm:Row()
        row:Left():TitleStack({ Title = title, Subtitle = subtitle })
        return row:Right()
    end
    local function AddButtonRow(title, subtitle, label, fn, state)
        local right = AddRow(title, subtitle)
        local props = { Label = label, Callback = function() end }
        if state then props.State = state end
        local ok, btn = pcall(function() return right:Button(props) end)
        if not ok then
            props.State = nil
            btn = right:Button(props)
        end
        BindButton(btn, fn)
        return btn
    end
    local StatusLabel = AddRow("Status", "Result of the last action."):Label({
        Text = canSave and "Ready" or "Can't save files"
    })
    local function SetCfgStatus(text)
        pcall(function() StatusLabel.Text = tostring(text) end)
    end
    local ActiveLabel, AutoloadLabel
    local function UpdateActiveLabel()
        pcall(function()
            local name = ConfigStore.Active()
            if not name then ActiveLabel.Text = "none" return end
            local dirty = ConfigStore.IsDirty(HubConfig)
            if ConfigStore.IsDefault(name) then
                ActiveLabel.Text = dirty and (name .. "  (modified)") or name
            else
                ActiveLabel.Text = dirty and (name .. "  (unsaved)") or name
            end
        end)
    end
    local function UpdateAutoloadLabel()
        pcall(function() AutoloadLabel.Text = ConfigStore.Autoload() or "none" end)
    end
    local function CleanName(text)
        local t = tostring(text or "")
        t = t:gsub('[%c/\\:*?"<>|]', "")
        t = t:gsub("^%s+", "")
        t = t:gsub("%s+$", "")
        if #t == 0 or not utf8.len(t) then return nil end
        if utf8.len(t) > 40 then t = t:sub(1, utf8.offset(t, 41) - 1) end
        return t
    end
    local function ApplyLook(ui)
        if type(ui) ~= "table" then return end
        local lookChanged = false
        if table.find(AccentOrder, ui.Theme) and ui.Theme ~= CurrentThemeName then
            CurrentThemeName = ui.Theme
            lookChanged = true
        end
        if (ui.Accent == FOLLOW_THEME or table.find(AccentOrder, ui.Accent)) and ui.Accent ~= CurrentAccentName then
            CurrentAccentName = ui.Accent
            lookChanged = true
        end
        pcall(function()
            local ti = table.find(colorOptions, CurrentThemeName) or 1
            ThemeColorBtn.Value = ti
            ThemeColorBtn.Label = colorOptions[ti]
        end)
        pcall(function()
            local ai = table.find(accentOptions, CurrentAccentName) or 1
            AccentColorBtn.Value = ai
            AccentColorBtn.Label = accentOptions[ai]
        end)
        if lookChanged then pcall(ApplyAppearance) end
        if type(ui.UIBlur) == "boolean" then
            pcall(function()
                Window.UIBlur = ui.UIBlur
                UiSync.Blur.Value = ui.UIBlur
            end)
        end
        if type(ui.Dropshadow) == "boolean" then
            pcall(function()
                Window.Dropshadow = ui.Dropshadow
                UiSync.Shadow.Value = ui.Dropshadow
            end)
        end
        if type(ui.Keybind) == "string" then
            pcall(function()
                local key = Enum.KeyCode[ui.Keybind]
                if key then
                    currentKeybind = key
                    UiSync.Hotkey.Value = key
                end
            end)
        end
    end
    ConfigStore.UIApplier = ApplyLook
    ConfigStore.GetUI = function()
        return {
            Theme = CurrentThemeName,
            Accent = CurrentAccentName,
            UIBlur = Window.UIBlur and true or false,
            Dropshadow = Window.Dropshadow and true or false,
            Keybind = currentKeybind and currentKeybind.Name or "LeftAlt",
        }
    end
    ActiveLabel = AddRow("Config in use", "The config you picked or created. Your changes belong to this config."):Label({ Text = "none" })
    local AutoSyncToggle = AddRow("Auto-save into config", "ON: every change is saved into the config in use by itself. OFF: only when you press Enter Save Config."):Toggle({
        Value = ConfigStore.AutoSync(),
        ValueChanged = function(self, value)
            value = value and true or false
            if value == ConfigStore.AutoSync() then return end
            ConfigStore.SetAutoSync(value)
            if value then ConfigStore.SyncActive(HubConfig) end
            UpdateActiveLabel()
            SetCfgStatus(value and "Auto-save is ON" or "Auto-save is OFF - use Enter Save Config")
        end
    })
    AddButtonRow("Enter Save Config", "Save the current switches into the config in use.", "Save", function()
        local name = ConfigStore.Active()
        if not name then SetCfgStatus("No config in use - Create or Load one first") return end
        if ConfigStore.IsDefault(name) then SetCfgStatus("Default config is read-only - Create your own config") return end
        if not canSave then SetCfgStatus("Executor can't save files") return end
        local ok = ConfigStore.SaveActive(HubConfig)
        UpdateActiveLabel()
        SetCfgStatus(ok and ("Saved to: " .. name) or "Save failed")
    end)
    AddRow("Config name", "Type a name, then press Create."):TextField({
        Placeholder = "Config name",
        Value = "",
        TextChanged = function(self, text) typedName = text end,
        ValueChanged = function(self, value) typedName = value end,
    })
    AddButtonRow("Create config", "Save the current switches under the name above and start using it.", "Create", function()
        local name = CleanName(typedName)
        if not name then SetCfgStatus("Type a config name first") return end
        if ConfigStore.Exists(name) then SetCfgStatus("That name already exists - pick another name") return end
        if not canSave then SetCfgStatus("Executor can't save files") return end
        ConfigStore.SyncActive(HubConfig)
        local ok = ConfigStore.Put(name, ConfigStore.Snapshot(HubConfig))
        if ok then ConfigStore.SetActive(name) end
        RefreshList(name)
        UpdateActiveLabel()
        SetCfgStatus(ok and ("Created: " .. name) or "Save failed")
    end)
    local ListRow = ConfigForm:Row()
    ListRow:Left():TitleStack({ Title = "Config list", Subtitle = "Choose a saved config." })
    ListBtn = ListRow:Right():PullDownButton({
        Label = "---",
        Options = currentOptions,
        Value = 1,
        ValueChanged = function(self, index)
            local name = currentOptions[index]
            selectedName = (index and index > 1) and name or nil
            self.Label = name or "---"
        end
    })
    StyleDropdown(ListBtn)
    RefreshList = function(keepName)
        local opts = { "---" }
        for _, n in ipairs(ConfigStore.Names()) do opts[#opts + 1] = n end
        currentOptions = opts
        local idx = (keepName and table.find(opts, keepName)) or 1
        selectedName = idx > 1 and opts[idx] or nil
        pcall(function()
            ListBtn.Options = opts
            ListBtn.Value = idx
            ListBtn.Label = opts[idx]
        end)
    end
    AddButtonRow("Load config", "Switch to the selected config and apply its switches.", "Load", function()
        if not selectedName then SetCfgStatus("Select a config first") return end
        local snap = ConfigStore.Get(selectedName)
        if not snap then SetCfgStatus("Config not found - press Refresh list") return end
        local dropped = ConfigStore.Active() ~= nil and not ConfigStore.AutoSync() and ConfigStore.IsDirty(HubConfig)
        ConfigStore.SyncActive(HubConfig)
        ConfigStore.SetActive(selectedName)
        ConfigStore.ApplyCfg(snap)
        ConfigStore.ApplyHub(HubConfig, snap)
        Save()
        UiSync.Refresh()
        ConfigStore.ApplyUI(snap)
        UpdateActiveLabel()
        SetCfgStatus("Loaded: " .. selectedName .. (dropped and "  (unsaved changes dropped)" or ""))
    end)
    AddButtonRow("Delete config", "Delete the selected config.", "Delete", function()
        if not selectedName then SetCfgStatus("Select a config first") return end
        local name = selectedName
        if ConfigStore.IsDefault(name) then SetCfgStatus("The default config can't be deleted") return end
        ConfigStore.Delete(name)
        RefreshList(nil)
        UpdateActiveLabel()
        UpdateAutoloadLabel()
        SetCfgStatus("Deleted: " .. name)
    end)
    AddButtonRow("Refresh list", "Reload the saved configs from file.", "Refresh", function()
        ConfigStore.Reload()
        RefreshList(selectedName)
        UpdateActiveLabel()
        UpdateAutoloadLabel()
        pcall(function() AutoSyncToggle.Value = ConfigStore.AutoSync() end)
        SetCfgStatus("List refreshed")
    end)
    AddButtonRow("Set as autoload", "Load the selected config automatically every time the script starts.", "Set", function()
        if not selectedName then SetCfgStatus("Select a config first") return end
        local ok = ConfigStore.SetAutoload(selectedName)
        UpdateAutoloadLabel()
        SetCfgStatus(ok and ("Autoload: " .. selectedName) or "Save failed")
    end)
    AddButtonRow("Reset autoload", "Stop loading a config automatically.", "Reset", function()
        ConfigStore.SetAutoload(nil)
        UpdateAutoloadLabel()
        SetCfgStatus("Autoload reset")
    end)
    AutoloadLabel = AddRow("Current autoload config", "Loaded when the script starts."):Label({ Text = "none" })
    -- ============================================================
    --  📤 Share config — แจกจ่ายคอนฟิกด้วย "โค้ดแชร์" (ก๊อปวางใน Discord ได้) หรือลิงก์/ไฟล์
    --  โค้ดเก็บเฉพาะค่าที่ต่างจากค่าเริ่มต้น จึงสั้น  ไม่มี Webhook URL / ข้อมูลส่วนตัวรวมอยู่ด้วย
    -- ============================================================
    SH.Guard("config-share", function()
        local PREFIX = "SHCFG1:"
        local SHARE_DIR = "SmoothHub/Share"
        local MAX_CODE = 300000
        local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
        local B64REV = {}
        for i = 1, #B64 do B64REV[B64:byte(i)] = i - 1 end

        local function b64enc(data)
            local out = {}
            for i = 1, #data, 3 do
                local a, b, c = data:byte(i, i + 2)
                local v = a * 65536 + (b or 0) * 256 + (c or 0)
                local c1 = bit32.rshift(v, 18) % 64
                local c2 = bit32.rshift(v, 12) % 64
                local c3 = bit32.rshift(v, 6) % 64
                local c4 = v % 64
                out[#out + 1] = B64:sub(c1 + 1, c1 + 1) .. B64:sub(c2 + 1, c2 + 1)
                    .. (b and B64:sub(c3 + 1, c3 + 1) or "=") .. (c and B64:sub(c4 + 1, c4 + 1) or "=")
            end
            return table.concat(out)
        end
        local function b64dec(s)
            s = (s:gsub("[^%w%+/=]", ""))
            local out = {}
            for i = 1, #s, 4 do
                local a, b, c, d = s:byte(i, i + 3)
                local va, vb = B64REV[a], B64REV[b or 0]
                if not va or not vb then return nil end
                local vc = (c and c ~= 61) and B64REV[c] or nil
                local vd = (d and d ~= 61) and B64REV[d] or nil
                local v = va * 262144 + vb * 4096 + (vc or 0) * 64 + (vd or 0)
                out[#out + 1] = string.char(bit32.rshift(v, 16) % 256)
                if vc then out[#out + 1] = string.char(bit32.rshift(v, 8) % 256) end
                if vd then out[#out + 1] = string.char(v % 256) end
            end
            return table.concat(out)
        end

        local function SameVal(x, y)
            if type(x) ~= type(y) then return false end
            if type(x) == "table" then
                if #x ~= #y then return false end
                for i = 1, #x do if x[i] ~= y[i] then return false end end
                return true
            end
            return x == y
        end
        local function Delta(cur, base)
            local out = {}
            base = base or {}
            for k, v in pairs(cur or {}) do
                if not SameVal(v, base[k]) then out[k] = v end
            end
            return out
        end
        local function CopyVal(v)
            if type(v) ~= "table" then return v end
            local o = {}
            for i, x in ipairs(v) do o[i] = x end
            return o
        end
        local function DefaultSnap()
            return ConfigStore.Get(ConfigStore.DEFAULT_NAME) or { Cfg = {}, Hub = {}, UI = {} }
        end
        local function CleanMap(src)
            local out = {}
            if type(src) ~= "table" then return out end
            for k, v in pairs(src) do
                if type(k) == "string" and #k <= 60 then
                    local t = type(v)
                    if t == "boolean" or (t == "number" and v == v and v > -1e12 and v < 1e12) or (t == "string" and #v <= 500) then
                        out[k] = v
                    elseif t == "table" and #v <= 50 then
                        local arr = {}
                        for _, item in ipairs(v) do
                            if type(item) == "string" and #item <= 100 then arr[#arr + 1] = item end
                        end
                        out[k] = arr
                    end
                end
            end
            return out
        end

        local function BuildCode(name)
            local snap = name and ConfigStore.Get(name)
            if not snap then
                snap = ConfigStore.Snapshot(HubConfig)
                name = ConfigStore.Active() or "Shared"
            end
            local def = DefaultSnap()
            local payload = {
                n = name,
                c = Delta(snap.Cfg, def.Cfg),
                h = Delta(snap.Hub, def.Hub),
                u = Delta(snap.UI, def.UI),
            }
            local ok, json = pcall(function() return HttpService:JSONEncode(payload) end)
            if not ok then return nil end
            return PREFIX .. b64enc(json), name
        end

        local function ReadSource(text)
            text = tostring(text or ""):match("^%s*(.-)%s*$")
            if text == "" then return nil, "Paste a share code, link or file name first" end
            if text:match("^https?://") then
                local ok, body = pcall(function() return game:HttpGet(text) end)
                if not ok or type(body) ~= "string" or body == "" then return nil, "Download failed (check the link)" end
                return body
            end
            if text:find(PREFIX, 1, true) then return text end
            if text:find("{", 1, true) and text:find("=", 1, true) then return text end -- คอนฟิกแบบ getgenv().Configs
            if type(isfile) == "function" and type(readfile) == "function" then
                for _, p in ipairs({ SHARE_DIR .. "/" .. text, SHARE_DIR .. "/" .. text .. ".txt", text }) do
                    local okF, ex = pcall(isfile, p)
                    if okF and ex then
                        local okR, body = pcall(readfile, p)
                        if okR and type(body) == "string" then return body end
                    end
                end
            end
            return nil, "Not a valid share code, link or file"
        end

        local function Decode(raw)
            raw = (tostring(raw):gsub("%s", ""))
            local i = raw:find(PREFIX, 1, true)
            if not i then return nil, "Not a Smooth Hub share code" end
            raw = raw:sub(i + #PREFIX)
            if #raw > MAX_CODE then return nil, "Code is too large" end
            local json = b64dec(raw)
            if not json or json == "" then return nil, "Code is damaged" end
            local ok, data = pcall(function() return HttpService:JSONDecode(json) end)
            if not ok or type(data) ~= "table" then return nil, "Code is damaged" end
            return data
        end

        local function Fit(delta, base, into)
            for k, v in pairs(CleanMap(delta)) do
                local b = base and base[k]
                if b ~= nil and type(b) == type(v) then into[k] = CopyVal(v) end
            end
        end

        local function ImportText(text)
            local raw, err = ReadSource(text)
            if not raw then return nil, err end
            local def = DefaultSnap()
            local snap = { Cfg = {}, Hub = {}, UI = {} }
            for k, v in pairs(def.Cfg or {}) do snap.Cfg[k] = CopyVal(v) end
            for k, v in pairs(def.Hub or {}) do snap.Hub[k] = v end
            for k, v in pairs(def.UI or {}) do snap.UI[k] = v end
            local base, summary
            if raw:find(PREFIX, 1, true) then
                local data, err2 = Decode(raw)
                if not data then return nil, err2 end
                Fit(data.c, def.Cfg, snap.Cfg)
                Fit(data.h, def.Hub, snap.Hub)
                Fit(data.u, def.UI, snap.UI)
                base = CleanName(type(data.n) == "string" and data.n or "") or "Shared"
            else
                -- คอนฟิกแบบ getgenv().Configs = { ... } (อ่านเป็นข้อความล้วน ไม่รันโค้ด)
                local tbl, perr = SH.Legacy.Parse(raw)
                if not tbl then return nil, perr end
                local res = SH.Legacy.Translate(tbl)
                if #res.applied == 0 then return nil, "No supported settings found in that config" end
                Fit(res.cfg, def.Cfg, snap.Cfg)
                Fit(res.hub, def.Hub, snap.Hub)
                base = "Imported Config"
                summary = SH.Legacy.Summary(res)
                if #res.skipped > 0 then SH.say("Not supported (skipped): " .. table.concat(res.skipped, ", ")) end
            end
            local name, n = base, 1
            while ConfigStore.Exists(name) do
                n = n + 1
                name = base .. " (" .. n .. ")"
            end
            local ok = ConfigStore.Put(name, snap)
            return name, nil, ok, summary
        end

        local hasClip = type(setclipboard) == "function" or type(toclipboard) == "function"
            or (syn and syn.write_clipboard ~= nil) or (Clipboard and Clipboard.set ~= nil)

        local ShareForm = ConfigTab:PageSection({
            Title = "📤 Share config",
            Subtitle = "Send your config to friends with a short code, or import one. Codes hold only your switches (no Webhook URL).",
        }):Form()
        local function Row2(title, subtitle)
            local row = ShareForm:Row()
            row:Left():TitleStack({ Title = title, Subtitle = subtitle })
            return row:Right()
        end
        local shareStatus = Row2("Share status", "Result of the last share / import."):Label({ Text = "Ready" })
        local function Say(text)
            SetCfgStatus(text)
            pcall(function() shareStatus.Text = tostring(text) end)
        end
        local function Btn2(title, subtitle, label, fn)
            local btn = Row2(title, subtitle):Button({ Label = label, Callback = function() end })
            BindButton(btn, fn)
            return btn
        end

        Btn2("Copy share code", "Copies the selected config (or your current switches if none is selected). Paste it in Discord.", "Copy", function()
            local code, name = BuildCode(selectedName)
            if not code then Say("Could not build the code") return end
            local savedFile = false
            if canSave and type(writefile) == "function" then
                pcall(function()
                    if type(makefolder) == "function" and type(isfolder) == "function" then
                        if not isfolder("SmoothHub") then makefolder("SmoothHub") end
                        if not isfolder(SHARE_DIR) then makefolder(SHARE_DIR) end
                    end
                    local fname = tostring(name):gsub("[^%w_%- ]", "_")
                    writefile(SHARE_DIR .. "/" .. fname .. ".txt", code)
                    savedFile = true
                end)
            end
            if hasClip then
                CopyText(code)
                Say("Copied \"" .. tostring(name) .. "\" (" .. #code .. " chars)" .. (#code > 1900 and " - too long for a normal Discord message, send as a .txt file" or ""))
            elseif savedFile then
                Say("No clipboard - saved to workspace/" .. SHARE_DIR .. "/")
            else
                Say("No clipboard and can't save files")
            end
        end)

        local pending = ""
        Row2("Import code / link / file", "Paste a share code, a getgenv().Configs text, a link to a .txt, or a file name from workspace/" .. SHARE_DIR .. "/"):TextField({
            Placeholder = "SHCFG1:...  |  getgenv().Configs = {...}  |  https://...  |  file.txt",
            Value = "",
            TextChanged = function(self, text) pending = tostring(text or "") end,
            ValueChanged = function(self, value) pending = tostring(value or "") end,
        })
        Btn2("Import config", "Adds it to your Config list. Pick it in Config list and press Load to use it.", "Import", function()
            Say("Importing...")
            local okR, name, err, saved, summary = pcall(ImportText, pending)
            if not okR then Say("Import failed") return end
            if not name then Say("Failed: " .. tostring(err)) return end
            RefreshList(name)
            UpdateActiveLabel()
            Say("Imported: " .. name .. (summary and (" (" .. summary .. ")") or "") .. (saved == false and " (not saved to file)" or "") .. " - press Load")
        end)
    end)

    UpdateAutoloadLabel()
    UpdateActiveLabel()
    RefreshList(ConfigStore.Active())
    task.spawn(function()
        while Alive() do
            if not ConfigStore.AutoSync() then UpdateActiveLabel() end
            task.wait(1)
        end
    end)
    function UiSync.ResetAll()
        ConfigStore.SyncActive(HubConfig)
        ConfigStore.SetActive(nil)
        UpdateActiveLabel()
        for key, value in pairs(UiSync.Defaults.Cfg) do
            if type(value) == "table" then
                local copy = {}
                for i, item in ipairs(value) do copy[i] = item end
                Cfg[key] = copy
            else
                Cfg[key] = value
            end
        end
        for key, value in pairs(UiSync.Defaults.Hub) do HubConfig[key] = value end
        Save()
        UiSync.Refresh()
        pcall(Farm.Fps.Apply)
        ApplyLook(ConfigStore.DEFAULT_LOOK)
    end
    local resetArmedAt = 0
    AddButtonRow("Reset to defaults", "Set every switch, slider and the window look back to the default values (same as \"Smooth Hub | Default\"). Saved configs are NOT deleted.", "Reset", function()
        if os.clock() - resetArmedAt > 5 then
            resetArmedAt = os.clock()
            SetCfgStatus("Press Reset again within 5s to confirm")
            return
        end
        resetArmedAt = 0
        UiSync.ResetAll()
        SetCfgStatus("Everything is back to the default values")
    end, "Destructive")
    SettingsStore.OnSaved = function()
        ConfigStore.SyncActive(HubConfig)
    end
end
SettingsStore.StartAutoSave("AOTR", function()
    return {
        Cfg = Cfg,
        Hub = HubConfig,
        UI = {
            Theme = CurrentThemeName,
            Accent = CurrentAccentName,
            UIBlur = Window.UIBlur,
            Dropshadow = Window.Dropshadow,
            Keybind = currentKeybind and currentKeybind.Name or "LeftAlt",
        },
    }
end)
saveHook = function()
    SettingsStore.Flush("AOTR")
    ConfigStore.SyncActive(HubConfig)
end
UserInputService.JumpRequest:Connect(function()
    if Alive() and HubConfig.InfiniteJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)
LocalPlayer.Idled:Connect(function()
    if Alive() and HubConfig.AntiAFK then
        pcall(function()
            local VirtualUser = game:GetService("VirtualUser")
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end
end)
pcall(function()
    local errorPrompt = game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui", true)
    if errorPrompt then
        errorPrompt.ChildAdded:Connect(function(child)
            if child.Name == "promptOverlay" then
                task.wait(1)
                if Alive() and HubConfig.AutoRejoin then
                    TeleportService:Teleport(HOP_PLACE_ID, LocalPlayer)
                end
            end
        end)
    end
end)
local function CheckAdmin(player)
    if player == LocalPlayer or not HubConfig.AntiAdmin then return end
    pcall(function()
        if player:GetRankInGroup(game.CreatorId) >= 250 or player.UserId == game.CreatorId then
            HopServer()
        end
    end)
end
Players.PlayerAdded:Connect(function(player) if Alive() then CheckAdmin(player) end end)
task.spawn(function()
    while Alive() do
        task.wait(3)
        if HubConfig.AntiAdmin then
            for _, player in ipairs(Players:GetPlayers()) do
                CheckAdmin(player)
            end
        end
    end
end)
task.spawn(function()
    while Alive() do
        pcall(Farm.Fps.Reassert)
        task.wait(1)
    end
end)
end
task.spawn(function()
    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")
    local parent = (type(gethui) == "function" and gethui()) or game:GetService("CoreGui")

    local B64_LOGO = [==[
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
]==]

    local function B64Decode(data)
        if data == "" then return "" end
        local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
        local lookup = {}
        for i = 1, 64 do lookup[chars:sub(i, i)] = i - 1 end
        data = data:gsub("[^%w%+/=]", "")
        local out, n = {}, 0
        for i = 1, #data, 4 do
            local a, b, c, d = data:sub(i, i), data:sub(i + 1, i + 1), data:sub(i + 2, i + 2), data:sub(i + 3, i + 3)
            local v = (lookup[a] or 0) * 262144 + (lookup[b] or 0) * 4096 + (lookup[c] or 0) * 64 + (lookup[d] or 0)
            n = n + 1
            out[n] = string.char(math.floor(v / 65536) % 256)
            if c ~= "=" and c ~= "" then n = n + 1 out[n] = string.char(math.floor(v / 256) % 256) end
            if d ~= "=" and d ~= "" then n = n + 1 out[n] = string.char(v % 256) end
        end
        return table.concat(out)
    end

    local function ResolveLogo()
        if B64_LOGO ~= "" and type(getcustomasset) == "function" and type(writefile) == "function" then
            local ok, asset = pcall(function()
                if type(makefolder) == "function" and type(isfolder) == "function" and not isfolder("SmoothHub") then
                    makefolder("SmoothHub")
                end
                local path = "SmoothHub/logo_smooth.png"
                writefile(path, B64Decode(B64_LOGO))
                return getcustomasset(path)
            end)
            if ok and asset then return asset end
        end
        return nil
    end

    local logoImage = ResolveLogo()
    pcall(function()
        local old = parent:FindFirstChild("SmoothHubIsland")
        if old then old:Destroy() end
    end)

    local gui = Instance.new("ScreenGui")
    gui.Name = "SmoothHubIsland"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 999999
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local okParent = pcall(function() gui.Parent = parent end)
    if not okParent or not gui.Parent then gui.Parent = PlayerGui end

    -- ============================================================
    --  🏝️ Smooth Hub | Dynamic Island loader
    --  ดำสนิท + ขอบแสงแดงวิ่งรอบ + เรืองแสงนุ่ม ๆ + ยืด/หดแบบสปริง
    -- ============================================================
    local RED_MAIN = Color3.fromHex("#FF1E3C")
    local RED_SOFT = Color3.fromHex("#FF4D66")
    local RED_GLOW = Color3.fromHex("#FF95A6")
    local RED_DEEP = Color3.fromHex("#8F0018")
    local GREEN = Color3.fromHex("#30D158")
    local WHITE = Color3.new(1, 1, 1)
    local MUTED = Color3.fromRGB(142, 142, 150)

    local W, H = 380, 122                  -- ขนาดตอนขยายเต็ม
    local TOP = 14                         -- ระยะห่างจากขอบบนจอ
    local SMALL_W, SMALL_H = 96, 28        -- เม็ดยา (ตอนเริ่ม/ตอนจบ)
    local COMPACT_W, COMPACT_H = 208, 40   -- แคปซูลเล็กตอนโหลดเสร็จ
    local R_FULL, R_COMPACT, R_SMALL = 40, 20, 14
    local LOAD_DUR = 2.6

    local function tw(obj, time, props, style, dir)
        local t = TweenService:Create(obj, TweenInfo.new(time, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
        t:Play()
        return t
    end

    local function round(obj, r)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, r)
        c.Parent = obj
        return c
    end

    local function KP(t, c) return ColorSequenceKeypoint.new(t, c) end
    local function NK(t, v) return NumberSequenceKeypoint.new(t, v) end

    -- ---------- โครงหลัก: holder (ขยับ/ยืดหด) > glow + pill ----------
    local holder = Instance.new("Frame")
    holder.Name = "Island"
    holder.AnchorPoint = Vector2.new(0.5, 0)
    holder.Position = UDim2.new(0.5, 0, 0, -SMALL_H - 30)
    holder.Size = UDim2.fromOffset(SMALL_W, SMALL_H)
    holder.BackgroundTransparency = 1
    holder.BorderSizePixel = 0
    holder.Parent = gui

    -- แสงเรืองรอบเกาะ 3 ชั้น (ซ้อนกันให้ไล่เฉดนุ่ม)
    local glows = {}
    for i, g in ipairs({ { 6, 0.90 }, { 14, 0.955 }, { 26, 0.98 } }) do
        local f = Instance.new("Frame")
        f.AnchorPoint = Vector2.new(0.5, 0.5)
        f.Position = UDim2.fromScale(0.5, 0.5)
        f.Size = UDim2.new(1, g[1] * 2, 1, g[1] * 2)
        f.BackgroundColor3 = RED_MAIN
        f.BackgroundTransparency = 1
        f.BorderSizePixel = 0
        f.ZIndex = 1
        f.Parent = holder
        glows[i] = { frame = f, spread = g[1], base = g[2], corner = round(f, R_SMALL + g[1]) }
    end

    local pill = Instance.new("Frame")
    pill.Name = "Pill"
    pill.Size = UDim2.fromScale(1, 1)
    pill.BackgroundColor3 = Color3.new(0, 0, 0)
    pill.BorderSizePixel = 0
    pill.ClipsDescendants = true
    pill.ZIndex = 2
    pill.Parent = holder
    local pillCorner = round(pill, R_SMALL)

    local pillGrad = Instance.new("UIGradient")
    pillGrad.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.fromRGB(22, 0, 7))
    pillGrad.Rotation = 90
    pillGrad.Parent = pill

    -- ขอบแสงแดงที่วิ่งวนรอบเกาะ (rim light)
    local rim = Instance.new("UIStroke")
    rim.Thickness = 1.4
    rim.Color = WHITE
    rim.Parent = pill
    local rimGrad = Instance.new("UIGradient")
    rimGrad.Color = ColorSequence.new({ KP(0, RED_DEEP), KP(0.5, RED_GLOW), KP(1, RED_DEEP) })
    rimGrad.Transparency = NumberSequence.new({ NK(0, 0.82), NK(0.3, 0.82), NK(0.5, 0.05), NK(0.7, 0.82), NK(1, 0.82) })
    rimGrad.Parent = rim

    -- ---------- กลุ่มเนื้อหา (ค่อย ๆ จางเข้า/ออกตอนเกาะยืดหด) ----------
    local function newGroup(name, w, h)
        local g = Instance.new("CanvasGroup")
        g.Name = name
        g.AnchorPoint = Vector2.new(0.5, 0.5)
        g.Position = UDim2.new(0.5, 0, 0.5, 8)
        g.Size = UDim2.fromOffset(w, h)
        g.BackgroundTransparency = 1
        g.BorderSizePixel = 0
        g.GroupTransparency = 1
        g.ZIndex = 3
        g.Parent = pill
        return g
    end
    local full = newGroup("Expanded", W, H)
    local compact = newGroup("Compact", COMPACT_W, COMPACT_H)

    local function makeLogo(par, size)
        local box = Instance.new("Frame")
        box.BackgroundTransparency = 1
        box.Size = UDim2.fromOffset(size, size)
        box.ZIndex = 4
        box.Parent = par
        if logoImage then
            local img = Instance.new("ImageLabel")
            img.BackgroundTransparency = 1
            img.Size = UDim2.fromScale(1, 1)
            img.Image = logoImage
            img.ScaleType = Enum.ScaleType.Fit
            img.ZIndex = 5
            img.Parent = box
            round(img, size)
        else
            local bg = Instance.new("Frame")
            bg.Size = UDim2.fromScale(1, 1)
            bg.BackgroundColor3 = RED_MAIN
            bg.BorderSizePixel = 0
            bg.ZIndex = 5
            bg.Parent = box
            round(bg, size)
            local g = Instance.new("UIGradient")
            g.Color = ColorSequence.new(RED_SOFT, RED_DEEP)
            g.Rotation = 45
            g.Parent = bg
            local letter = Instance.new("TextLabel")
            letter.BackgroundTransparency = 1
            letter.Size = UDim2.fromScale(1, 1)
            letter.Font = Enum.Font.GothamBlack
            letter.Text = "S"
            letter.TextSize = math.floor(size * 0.55)
            letter.TextColor3 = WHITE
            letter.ZIndex = 6
            letter.Parent = bg
        end
        return box
    end

    -- ---------- Expanded: โลโก้ + วงแหวนหมุน ----------
    local logo = makeLogo(full, 50)
    logo.Position = UDim2.fromOffset(22, 18)
    local logoScale = Instance.new("UIScale")
    logoScale.Scale = 0.6
    logoScale.Parent = logo

    local ring = Instance.new("Frame")
    ring.AnchorPoint = Vector2.new(0.5, 0.5)
    ring.Position = UDim2.fromScale(0.5, 0.5)
    ring.Size = UDim2.fromOffset(62, 62)
    ring.BackgroundTransparency = 1
    ring.BorderSizePixel = 0
    ring.ZIndex = 4
    ring.Parent = logo
    round(ring, 31)
    local ringStroke = Instance.new("UIStroke")
    ringStroke.Thickness = 2
    ringStroke.Color = WHITE
    ringStroke.Parent = ring
    local ringGrad = Instance.new("UIGradient")
    ringGrad.Color = ColorSequence.new({ KP(0, RED_DEEP), KP(1, RED_GLOW) })
    ringGrad.Transparency = NumberSequence.new({ NK(0, 1), NK(0.55, 1), NK(0.56, 0.9), NK(1, 0) })
    ringGrad.Parent = ringStroke

    -- ชื่อ + แสงวิ่งผ่านตัวอักษร (shimmer)
    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromOffset(88, 21)
    title.Size = UDim2.fromOffset(200, 22)
    title.Font = Enum.Font.GothamBold
    title.Text = "SMOOTH HUB"
    title.TextSize = 17
    title.TextColor3 = WHITE
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 5
    title.Parent = full
    local base = Color3.fromRGB(214, 214, 222)
    local titleGrad = Instance.new("UIGradient")
    titleGrad.Color = ColorSequence.new({
        KP(0, base), KP(0.42, base), KP(0.5, Color3.fromRGB(255, 205, 212)), KP(0.58, base), KP(1, base),
    })
    titleGrad.Parent = title

    local sub = Instance.new("TextLabel")
    sub.BackgroundTransparency = 1
    sub.Position = UDim2.fromOffset(88, 44)
    sub.Size = UDim2.fromOffset(220, 14)
    sub.Font = Enum.Font.GothamMedium
    sub.Text = "ATTACK ON TITAN REVOLUTION"
    sub.TextSize = 10
    sub.TextColor3 = MUTED
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.ZIndex = 5
    sub.Parent = full

    -- คลื่นเสียงด้านขวา
    local eqBox = Instance.new("Frame")
    eqBox.BackgroundTransparency = 1
    eqBox.Position = UDim2.fromOffset(W - 22 - 35, 29)
    eqBox.Size = UDim2.fromOffset(35, 28)
    eqBox.ZIndex = 5
    eqBox.Parent = full
    local bars = {}
    for i = 1, 5 do
        local bar = Instance.new("Frame")
        bar.AnchorPoint = Vector2.new(0.5, 0.5)
        bar.Position = UDim2.new(0, 3 + (i - 1) * 8, 0.5, 0)
        bar.Size = UDim2.fromOffset(3, 8)
        bar.BackgroundColor3 = RED_MAIN
        bar.BorderSizePixel = 0
        bar.ZIndex = 6
        bar.Parent = eqBox
        round(bar, 2)
        local bg = Instance.new("UIGradient")
        bg.Color = ColorSequence.new(RED_GLOW, RED_MAIN, RED_DEEP)
        bg.Rotation = 90
        bg.Parent = bar
        bars[i] = bar
    end

    -- สถานะ + เปอร์เซ็นต์
    local statusText = Instance.new("TextLabel")
    statusText.BackgroundTransparency = 1
    statusText.Position = UDim2.fromOffset(24, 80)
    statusText.Size = UDim2.fromOffset(W - 120, 14)
    statusText.Font = Enum.Font.GothamMedium
    statusText.Text = "Initializing..."
    statusText.TextSize = 11
    statusText.TextColor3 = Color3.fromRGB(235, 235, 240)
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.ZIndex = 5
    statusText.Parent = full

    local percentText = Instance.new("TextLabel")
    percentText.BackgroundTransparency = 1
    percentText.AnchorPoint = Vector2.new(1, 0)
    percentText.Position = UDim2.fromOffset(W - 24, 80)
    percentText.Size = UDim2.fromOffset(70, 14)
    percentText.Font = Enum.Font.GothamMedium
    percentText.Text = "0%"
    percentText.TextSize = 11
    percentText.TextColor3 = MUTED
    percentText.TextXAlignment = Enum.TextXAlignment.Right
    percentText.ZIndex = 5
    percentText.Parent = full

    -- แถบโหลดเรียวบาง + หัวแสง
    local track = Instance.new("Frame")
    track.Position = UDim2.fromOffset(24, 102)
    track.Size = UDim2.fromOffset(W - 48, 4)
    track.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
    track.BorderSizePixel = 0
    track.ZIndex = 5
    track.Parent = full
    round(track, 2)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale(0, 1)
    fill.BackgroundColor3 = RED_MAIN
    fill.BorderSizePixel = 0
    fill.ClipsDescendants = true
    fill.ZIndex = 6
    fill.Parent = track
    round(fill, 2)
    local fillGrad = Instance.new("UIGradient")
    fillGrad.Color = ColorSequence.new(RED_DEEP, RED_MAIN, RED_GLOW)
    fillGrad.Parent = fill

    local fillShine = Instance.new("Frame")
    fillShine.Size = UDim2.new(0.25, 0, 1, 0)
    fillShine.Position = UDim2.new(-0.3, 0, 0, 0)
    fillShine.BackgroundColor3 = WHITE
    fillShine.BackgroundTransparency = 0.55
    fillShine.BorderSizePixel = 0
    fillShine.ZIndex = 7
    fillShine.Parent = fill

    local spark = Instance.new("Frame")
    spark.AnchorPoint = Vector2.new(0.5, 0.5)
    spark.Size = UDim2.fromOffset(8, 8)
    spark.Position = UDim2.fromScale(0, 0.5)
    spark.BackgroundColor3 = WHITE
    spark.BorderSizePixel = 0
    spark.Visible = false
    spark.ZIndex = 8
    spark.Parent = track
    round(spark, 4)
    local sparkGlow = Instance.new("UIStroke")
    sparkGlow.Thickness = 3
    sparkGlow.Color = RED_GLOW
    sparkGlow.Transparency = 0.45
    sparkGlow.Parent = spark

    -- ---------- Compact: ใช้ตอนโหลดเสร็จ (โลโก้ + ชื่อ + เครื่องหมายถูก) ----------
    local cLogo = makeLogo(compact, 26)
    cLogo.Position = UDim2.fromOffset(9, 7)

    local cTitle = Instance.new("TextLabel")
    cTitle.BackgroundTransparency = 1
    cTitle.Position = UDim2.fromOffset(44, 0)
    cTitle.Size = UDim2.fromOffset(110, COMPACT_H)
    cTitle.Font = Enum.Font.GothamBold
    cTitle.Text = "SMOOTH HUB"
    cTitle.TextSize = 12
    cTitle.TextColor3 = Color3.fromRGB(235, 235, 240)
    cTitle.TextXAlignment = Enum.TextXAlignment.Left
    cTitle.TextYAlignment = Enum.TextYAlignment.Center
    cTitle.ZIndex = 5
    cTitle.Parent = compact

    local check = Instance.new("Frame")
    check.AnchorPoint = Vector2.new(0.5, 0.5)
    check.Position = UDim2.fromOffset(COMPACT_W - 14 - 10, COMPACT_H / 2)
    check.Size = UDim2.fromOffset(20, 20)
    check.BackgroundColor3 = GREEN
    check.BorderSizePixel = 0
    check.ZIndex = 5
    check.Parent = compact
    round(check, 10)
    local checkScale = Instance.new("UIScale")
    checkScale.Scale = 0
    checkScale.Parent = check
    local function stroke2(cx, cy, len, rot)
        local s = Instance.new("Frame")
        s.AnchorPoint = Vector2.new(0.5, 0.5)
        s.Position = UDim2.fromOffset(cx, cy)
        s.Size = UDim2.fromOffset(2, len)
        s.Rotation = rot
        s.BackgroundColor3 = WHITE
        s.BorderSizePixel = 0
        s.ZIndex = 6
        s.Parent = check
        round(s, 1)
    end
    stroke2(6.5, 11.5, 5, -45)
    stroke2(11, 9.5, 9, 43)

    -- ---------- Animation loop ----------
    local stages = {
        { 0, "Initializing..." },
        { 0.22, "Loading modules..." },
        { 0.6, "Connecting..." },
        { 0.88, "Finalizing..." },
    }
    local running = true
    local phase = "idle"
    local loadStart = 0
    local progress = 0
    local lastPct, lastStage = -1, ""
    local amp, ampTarget = 0.6, 1
    local glow, glowTarget = 0, 0
    local startTime = os.clock()
    local loopConn
    loopConn = RunService.RenderStepped:Connect(function(dt)
        if not running or not gui.Parent then
            if loopConn then loopConn:Disconnect() end
            return
        end
        local now = os.clock()
        local t = now - startTime
        rimGrad.Rotation = (t * 75) % 360
        ringGrad.Rotation = (t * 240) % 360
        titleGrad.Offset = Vector2.new(-1 + ((t % 2.6) / 2.6) * 2, 0)

        amp = amp + (ampTarget - amp) * math.min(1, dt * 5)
        for i, bar in ipairs(bars) do
            local h = 4 + 20 * amp * (0.5 + 0.5 * math.sin(t * 6 + i * 1.3))
            bar.Size = UDim2.fromOffset(3, h)
        end

        glow = glow + (glowTarget - glow) * math.min(1, dt * 4)
        local breathe = 0.85 + 0.15 * math.sin(t * 2.2)
        for _, g in ipairs(glows) do
            g.frame.BackgroundTransparency = 1 - (1 - g.base) * glow * breathe
        end

        if phase == "load" then
            local x = math.clamp((now - loadStart) / LOAD_DUR, 0, 1)
            progress = x * x * (3 - 2 * x)
            fill.Size = UDim2.fromScale(progress, 1)
            spark.Position = UDim2.new(progress, 0, 0.5, 0)
            spark.Visible = progress > 0.01 and progress < 0.99
            fillShine.Position = UDim2.new(((t % 1.3) / 1.3) * 1.4 - 0.3, 0, 0, 0)
            local pct = math.floor(progress * 100)
            if pct ~= lastPct then
                lastPct = pct
                percentText.Text = pct .. "%"
            end
            local label = stages[1][2]
            for _, s in ipairs(stages) do
                if progress >= s[1] then label = s[2] end
            end
            if label ~= lastStage then
                lastStage = label
                statusText.Text = label
            end
        end
    end)

    local function finish()
        running = false
        pcall(function() if loopConn then loopConn:Disconnect() end end)
        pcall(function() gui:Destroy() end)
    end

    local function morph(w, h, r, time, style, dir)
        tw(holder, time, { Size = UDim2.fromOffset(w, h) }, style, dir)
        tw(pillCorner, time, { CornerRadius = UDim.new(0, r) })
        for _, g in ipairs(glows) do
            tw(g.corner, time, { CornerRadius = UDim.new(0, r + g.spread) })
        end
    end

    local function step(sec)
        task.wait(sec)
        if not Alive() then
            finish()
            return false
        end
        return true
    end

    -- 1) เม็ดยาดำหล่นลงมาจากขอบบน
    glowTarget = 0.5
    tw(holder, 0.6, { Position = UDim2.new(0.5, 0, 0, TOP) })
    if not step(0.75) then return end

    -- 2) ยืดออกเป็นเกาะเต็ม (สปริงนิด ๆ) แล้วเนื้อหาค่อย ๆ จางเข้า
    glowTarget = 1
    morph(W, H, R_FULL, 0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    if not step(0.22) then return end
    tw(full, 0.45, { GroupTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0) })
    tw(logoScale, 0.6, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    if not step(0.35) then return end

    -- 3) โหลด
    phase = "load"
    loadStart = os.clock()
    if not step(LOAD_DUR + 0.1) then return end

    -- 4) เสร็จ: คลื่นเสียงนิ่ง ข้อความเป็น Ready สีเขียว
    phase = "done"
    fill.Size = UDim2.fromScale(1, 1)
    spark.Visible = false
    percentText.Text = "100%"
    statusText.Text = "Ready"
    statusText.TextColor3 = GREEN
    ampTarget = 0.2
    if not step(0.6) then return end

    -- 5) หดเป็นแคปซูลเล็ก โชว์โลโก้ + เครื่องหมายถูก
    tw(full, 0.25, { GroupTransparency = 1, Position = UDim2.new(0.5, 0, 0.5, -6) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    morph(COMPACT_W, COMPACT_H, R_COMPACT, 0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
    if not step(0.3) then return end
    tw(compact, 0.4, { GroupTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0) })
    tw(checkScale, 0.5, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    if not step(1.2) then return end

    -- 6) หดกลับเป็นเม็ดยา แล้วเลื่อนขึ้นหายไป
    tw(compact, 0.25, { GroupTransparency = 1 })
    morph(SMALL_W, SMALL_H, R_SMALL, 0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
    glowTarget = 0
    if not step(0.45) then return end
    tw(holder, 0.45, { Position = UDim2.new(0.5, 0, 0, -SMALL_H - 30) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    if not step(0.5) then return end
    finish()
end)
if SH.DEV then
    _G.SmoothHubFarm = SH.Farm
    _G.SmoothHubSpin = SH.Spin
end
SH.say("Loaded successfully (" .. (IN_MENU and "Lobby" or "In-game") .. ").")
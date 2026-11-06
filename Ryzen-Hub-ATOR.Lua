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
            game:GetService("Players").LocalPlayer:Kick("Script này chỉ hoạt động trong Attack on Titan Revolution.")
        end)
        return
    end
end

--// Dịch vụ & Biến toàn cục
local MENU_PLACE_ID = 13379208636
local LOBBY_PLACE_ID = 14916516914
local MIN_DELAY, MAX_DELAY = 5, 60

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local IN_MENU = (game.PlaceId == MENU_PLACE_ID)
local IN_LOBBY = (game.PlaceId == LOBBY_PLACE_ID)

--// Dọn dẹp phiên chạy cũ tránh trùng lặp
if type(_G.SmoothHubCleanup) == "function" then
    pcall(_G.SmoothHubCleanup)
end
local token = {}
_G.SmoothHubReplayToken = token
local function Alive()
    return _G.SmoothHubReplayToken == token
end

--// Bảng cấu hình mặc định
local Cfg = {
    Slot = 1,
    AutoSelect = false,
    AutoJoin = false,
    JoinDelay = 10,

    -- Auto Spin Family
    AutoSpin = false,
    SpinStopRarity = "Epic",
    SpinOnKeep = "Stop",
    SpinUseDelay = true,
    SpinDelay = 3,
    SpinFamilyRules = "",

    -- Auto Claim & Lobby
    AutoClaimMain = true,
    AutoClaimSide = true,
    AutoClaimAchievements = true,
    AutoClaimWeekly = true,
    AutoClaimDaily = true,
    AutoUpgradeBlade = false,
    AutoUpgradeThunder = false,
    AutoEquipBlade = false,
    AutoEquipThunder = false,

    -- Auto Farm
    FarmEnabled = false,
    FarmMode = "Smart", -- "Smart", "Blades", "Thunder Spears"
    AutoFarm = false,
    AutoFarmThunder = false,
    AutoFarmSmart = false,
    SafeFarm = false,
    DamageMultiplier = false,
    StartDelay = 4,
    FlyHeight = 230,
    FlySpeed = 600,
    AttackSpeed = 0,
    NoClip = true,
    HitAllParts = true,
    PartCooldown = 7,
    WaitForBoss = false,
    BossSettle = 5,
    ThunderTargets = 200,
    ThunderRange = 10000,

    -- Reload & Refill
    AutoReload = false,
    RefillEnabled = false,
    RefillPickBlade = true,
    RefillPickThunder = true,
    AutoRefillsBlade = false,
    AutoRefillsThunder = false,
    AutoRefillWave = false,

    -- Sau trận & Bảo vệ chuỗi
    AutoRetry = false,
    AutoLeave = false,
    AutoLeaveWhenRetryComplete = false,
    RetryAmount = 3,
    RetryDone = 0,
    SafeTime = 32,
    FailSafeAt = 20,
    AutoFailSafe = false,
    Streak = 0,

    -- Nhiệm vụ Thunder Spear
    AutoQuestThunderR1 = false,
    AutoQuestThunderR2 = false,
    AutoQuestThunderR3 = false,
    QuestR3Played = 0,

    -- Kỹ năng tự động
    AutoSkill1 = false, AutoSkill2 = false, AutoSkill3 = false, AutoSkill4 = false, AutoSkill5 = false,
    AutoSkillMode1 = "Instant", AutoSkillMode2 = "Instant", AutoSkillMode3 = "Instant", AutoSkillMode4 = "Instant", AutoSkillMode5 = "Instant",
    AutoSkillHoldTime = 3,
    AutoSkillDelay = 2,

    -- Nâng cấp kỹ năng & Chuyển sinh
    AutoUpgradeSkills = false,
    SkillLeft = false, SkillMiddle = false, SkillRight = false,
    SkillLeftPick = "Regen VI", SkillMiddlePick = "Damage V", SkillRightPick = "Tank VIII",
    SkillLeftPriority = 1, SkillMiddlePriority = 2, SkillRightPriority = 1,
    AutoPrestige = false,
    PrestigeStopAt = 3,

    -- Tạo phòng & Nhiệm vụ / Raid / Wave
    MissionSelect = "Shiganshina",
    MissionObjective = "Skirmish",
    MissionLevel = "Easy (E- Grade)",
    MissionModifiers = {},
    AutoBestGrade = false,
    AutoBoostMission = false,
    AutoCreateMission = false,
    AutoStartMission = false,
    MissionJoinDelay = 10,

    RaidSelect = "Attack Titan",
    RaidLevel = "Hard",
    AutoCreateRaid = false,
    AutoStartRaid = false,
    RaidJoinDelay = 10,

    WaveSelect = "Trost",
    WaveLevel = "Easy (E- Grade)",
    AutoCreateWave = false,
    AutoStartWave = false,
    WaveJoinDelay = 10,
    AutoLeaveAtWave = false,
    LeaveAtWave = 10,
}

--// Quản lý lưu trữ tệp cấu hình
local SAVE_DIR = "SmoothHub_WindUI"
local SAVE_PATH = SAVE_DIR .. "/AOTR_" .. tostring(LocalPlayer.UserId) .. ".json"
local canSave = type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"

local function LoadConfig()
    if not canSave then return end
    pcall(function()
        if isfile(SAVE_PATH) then
            local decoded = HttpService:JSONDecode(readfile(SAVE_PATH))
            if type(decoded) == "table" then
                for k, v in pairs(decoded) do
                    if Cfg[k] ~= nil and type(Cfg[k]) == type(v) then
                        Cfg[k] = v
                    end
                end
            end
        end
    end)
end

local saveQueued = false
local function Save()
    if not canSave or saveQueued then return end
    saveQueued = true
    task.delay(0.5, function()
        saveQueued = false
        pcall(function()
            if type(makefolder) == "function" and type(isfolder) == "function" and not isfolder(SAVE_DIR) then
                makefolder(SAVE_DIR)
            end
            writefile(SAVE_PATH, HttpService:JSONEncode(Cfg))
        end)
    end)
end

LoadConfig()

--// Tải thư viện WindUI
local okWind, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not okWind or type(WindUI) ~= "table" then
    warn("[AOTR WindUI] Lỗi khi tải thư viện WindUI. Vui lòng kiểm tra lại kết nối mạng!")
    return
end

local Window = WindUI:CreateWindow({
    Title = "Ryzen Hub | Attack On Titan Revolution",
    Icon = "sword",
    Author = "By Kaibeo",
    Folder = "Ryzen Hub",
    Size = UDim2.fromOffset(630, 470),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 195,
})

_G.SmoothHubCleanup = function()
    pcall(function()
        if Window and Window.Destroy then
            Window:Destroy()
        end
    end)
end

local function Notify(title, content, duration)
    pcall(function()
        WindUI:Notify({
            Title = title or "AOTR Hub",
            Content = tostring(content or ""),
            Duration = duration or 4,
            Icon = "bell",
        })
    end)
end

--// Tiện ích lấy Remote
local function GetLobbyRemote()
    local ok, remote = pcall(function()
        local assets = ReplicatedStorage:WaitForChild("Assets", 5)
        local remotes = assets and assets:WaitForChild("Remotes", 5)
        return remotes and remotes:WaitForChild("GET", 5)
    end)
    return ok and remote or nil
end

local function GetPostRemote()
    local ok, remote = pcall(function()
        local assets = ReplicatedStorage:WaitForChild("Assets", 5)
        local remotes = assets and assets:WaitForChild("Remotes", 5)
        return remotes and remotes:WaitForChild("POST", 5)
    end)
    return ok and remote or nil
end

local function CleanText(o)
    local t = (o and o.Text or ""):gsub("<[^>]->", "")
    return t:gsub("^%s+", ""):gsub("%s+$", "")
end

local function IsShown(obj)
    local cur = obj
    while cur and cur ~= PlayerGui do
        if cur:IsA("GuiObject") and not cur.Visible then return false end
        if cur:IsA("ScreenGui") and not cur.Enabled then return false end
        cur = cur.Parent
    end
    return obj and obj:IsA("GuiObject") and obj.AbsoluteSize.X > 0 and obj.AbsoluteSize.Y > 0
end

--// Điều phối tác vụ (Smart Coordinator)
local SH = { Coord = { jobs = {}, last = nil }, QuestHold = false }
function SH.Coord.Register(name, prio, pending, busy, giveUp)
    SH.Coord.jobs[name] = { prio = prio, pending = pending, busy = busy, giveUp = giveUp or 240, since = nil, seen = nil }
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
                -- Timeout
            elseif j.prio < askerPrio and not found then
                found = name
            end
        else
            j.since, j.seen = nil, nil
        end
    end
    SH.Coord.last = found
    return found
end

--// Quản lý trạng thái Farm
local Farm = {
    Blades = { Target = nil, Hits = 0, Status = "Idle" },
    Refilling = false,
    FailSafeActive = false,
    CharSpawnAt = os.clock(),
}

function Farm.CanUseHere()
    return not IN_MENU and not IN_LOBBY
end

local function ApplyFarmMode()
    if not Cfg.FarmEnabled then
        Cfg.AutoFarm = false
        Cfg.AutoFarmThunder = false
        Cfg.AutoFarmSmart = false
    else
        if Cfg.FarmMode == "Smart" then
            Cfg.AutoFarmSmart = true
            local char = LocalPlayer.Character
            local hasSpears = char and type(char:GetAttribute("Spears")) == "number"
            Cfg.AutoFarmThunder = hasSpears and true or false
            Cfg.AutoFarm = not Cfg.AutoFarmThunder
        elseif Cfg.FarmMode == "Blades" then
            Cfg.AutoFarmSmart = false
            Cfg.AutoFarm = true
            Cfg.AutoFarmThunder = false
        elseif Cfg.FarmMode == "Thunder Spears" then
            Cfg.AutoFarmSmart = false
            Cfg.AutoFarm = false
            Cfg.AutoFarmThunder = true
        end
    end
    Save()
end

local function SyncRefillConfig()
    Cfg.AutoRefillsBlade = (Cfg.RefillEnabled and Cfg.RefillPickBlade) and true or false
    Cfg.AutoRefillsThunder = (Cfg.RefillEnabled and Cfg.RefillPickThunder) and true or false
    Save()
end

ApplyFarmMode()
SyncRefillConfig()

--====================================================================
-- 1. TAB: ACCOUNT
--====================================================================
local AccountTab = Window:Tab({ Title = "Account", Icon = "user" })
local AccountPara = AccountTab:Paragraph({
    Title = "Account Overview",
    Desc = "Đang kiểm tra thông tin tài khoản..."
})

task.spawn(function()
    while Alive() do
        pcall(function()
            local lvl = LocalPlayer:GetAttribute("Level") or "N/A"
            local pres = LocalPlayer:GetAttribute("Prestige") or 0
            local gold = LocalPlayer:GetAttribute("Gold") or "N/A"
            local gems = LocalPlayer:GetAttribute("Gems") or "N/A"
            local shadow = (LocalPlayer:GetAttribute("Exploiter") or LocalPlayer:GetAttribute("Blacklisted")) and "Bị gắn cờ (Nguy cơ)" or "An toàn"
            AccountPara:SetDesc(string.format(
                "• Trạng thái tài khoản: %s\n• Level: %s | Prestige: %s\n• Vàng: %s | Đá quý: %s\n• Chuỗi thắng hiện tại: %d | Số lần Retry: %d",
                shadow, tostring(lvl), tostring(pres), tostring(gold), tostring(gems), Cfg.Streak or 0, Cfg.RetryDone or 0
            ))
        end)
        task.wait(2.5)
    end
end)

--====================================================================
-- 2. TAB: MENU LOBBY
--====================================================================
local MenuTab = Window:Tab({ Title = "Menu Lobby", Icon = "home" })
local MenuStatusPara = MenuTab:Paragraph({
    Title = "Trạng thái sảnh chờ",
    Desc = IN_MENU and "Đang ở sảnh chờ Menu" or "Không ở trong Menu"
})

local function SetMenuStatus(txt)
    pcall(function() MenuStatusPara:SetDesc(tostring(txt)) end)
end

local SLOT_LETTERS = { "A", "B", "C" }
local SlotOptions = { "Slot A", "Slot B", "Slot C" }

local function FindSlotButton(letter)
    local want = "SLOT " .. letter
    for _, d in ipairs(PlayerGui:GetDescendants()) do
        if (d:IsA("TextLabel") or d:IsA("TextButton")) and CleanText(d):upper() == want and IsShown(d) then
            local cur = d.Parent
            for _ = 1, 6 do
                if not cur or cur == PlayerGui then break end
                for _, sub in ipairs(cur:GetDescendants()) do
                    if (sub:IsA("TextLabel") or sub:IsA("TextButton")) and CleanText(sub):upper() == "SELECT" and IsShown(sub) then
                        local b = sub:IsA("GuiButton") and sub or sub:FindFirstAncestorWhichIsA("GuiButton")
                        if b then return b end
                    end
                end
                cur = cur.Parent
            end
        end
    end
    return nil
end

local function ActivateGuiButton(btn)
    if not btn then return end
    pcall(function() GuiService.SelectedObject = btn end)
    task.wait(0.12)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
    end)
    task.wait(0.5)
    pcall(function()
        if type(firesignal) == "function" then
            firesignal(btn.MouseButton1Click)
            firesignal(btn.Activated)
        end
    end)
    pcall(function()
        if GuiService.SelectedObject == btn then GuiService.SelectedObject = nil end
    end)
end

local selectingChar = false
local function SelectCharacter()
    if selectingChar or not IN_MENU then return false end
    selectingChar = true
    local letter = SLOT_LETTERS[Cfg.Slot] or "A"
    local btn = FindSlotButton(letter)
    local ok = false
    if btn then
        SetMenuStatus("Đang chọn Slot " .. letter .. "...")
        ActivateGuiButton(btn)
        SetMenuStatus("Đã chọn thành công Slot " .. letter)
        ok = true
    else
        SetMenuStatus("Không tìm thấy nút cho Slot " .. letter)
    end
    selectingChar = false
    return ok
end

local function JoinLobbyOnce()
    if not IN_MENU then return end
    task.spawn(function()
        local remote = GetLobbyRemote()
        if not remote then
            SetMenuStatus("Không tìm thấy Remote của sảnh")
            return
        end
        SetMenuStatus("Đang gửi yêu cầu chuyển vào sảnh...")
        local ok, err = pcall(function()
            return remote:InvokeServer("Functions", "Teleport", "Lobby", nil)
        end)
        SetMenuStatus(ok and "Yêu cầu dịch chuyển thành công" or ("Thất bại: " .. tostring(err)))
    end)
end

MenuTab:Dropdown({
    Title = "Chọn Slot nhân vật",
    Values = SlotOptions,
    Value = SlotOptions[Cfg.Slot] or "Slot A",
    Callback = function(val)
        Cfg.Slot = table.find(SlotOptions, val) or 1
        Save()
    end
})

MenuTab:Toggle({
    Title = "Auto Select Character",
    Desc = "Tự động bấm SELECT nhân vật đã chọn khi xuất hiện màn hình",
    Value = Cfg.AutoSelect,
    Callback = function(v)
        Cfg.AutoSelect = v
        Save()
    end
})

MenuTab:Button({
    Title = "Chọn nhân vật ngay",
    Callback = function()
        SelectCharacter()
    end
})

MenuTab:Toggle({
    Title = "Auto Join Lobby",
    Desc = "Tự động gửi yêu cầu vào sảnh chính theo chu kỳ",
    Value = Cfg.AutoJoin,
    Callback = function(v)
        Cfg.AutoJoin = v
        Save()
    end
})

MenuTab:Slider({
    Title = "Độ trễ vào sảnh (Giây)",
    Step = 1,
    Value = { Min = MIN_DELAY, Max = MAX_DELAY, Default = Cfg.JoinDelay },
    Callback = function(v)
        Cfg.JoinDelay = math.clamp(tonumber(v) or 10, MIN_DELAY, MAX_DELAY)
        Save()
    end
})

MenuTab:Button({
    Title = "Vào sảnh ngay lập tức",
    Callback = function()
        JoinLobbyOnce()
    end
})

task.spawn(function()
    local lastJoin = 0
    while Alive() do
        if IN_MENU then
            if Cfg.AutoSelect and not selectingChar then
                SelectCharacter()
            end
            if Cfg.AutoJoin and not SH.Coord.Blocker(100) then
                if os.clock() - lastJoin >= Cfg.JoinDelay then
                    lastJoin = os.clock()
                    JoinLobbyOnce()
                end
            end
        end
        task.wait(1)
    end
end)

--====================================================================
-- 3. TAB: AUTO FARM
--====================================================================
local FarmTab = Window:Tab({ Title = "Auto Farm", Icon = "zap" })

local FarmStatusPara = FarmTab:Paragraph({
    Title = "Trạng thái Farm",
    Desc = "Off"
})

FarmTab:Toggle({
    Title = "Kích hoạt Auto Farm",
    Desc = "Bật/Tắt luồng farm chính",
    Value = Cfg.FarmEnabled,
    Callback = function(v)
        Cfg.FarmEnabled = v
        ApplyFarmMode()
    end
})

FarmTab:Dropdown({
    Title = "Vũ khí sử dụng",
    Values = { "Smart", "Blades", "Thunder Spears" },
    Value = Cfg.FarmMode,
    Callback = function(val)
        Cfg.FarmMode = val
        ApplyFarmMode()
    end
})

FarmTab:Toggle({
    Title = "Bypass Farm (Chống Shadow Ban)",
    Desc = "Tự động nhảy ngắt quãng để tiêu thụ Gas hợp lệ",
    Value = Cfg.SafeFarm,
    Callback = function(v)
        Cfg.SafeFarm = v
        Save()
    end
})

FarmTab:Toggle({
    Title = "Nhân sát thương (x10 Damage)",
    Desc = "Gây x10 sát thương trực tiếp lên Titan và Boss",
    Value = Cfg.DamageMultiplier,
    Callback = function(v)
        Cfg.DamageMultiplier = v
        Save()
    end
})

FarmTab:Slider({
    Title = "Thời gian chờ bắt đầu farm (Giây)",
    Step = 1,
    Value = { Min = 0, Max = 60, Default = Cfg.StartDelay },
    Callback = function(v)
        Cfg.StartDelay = tonumber(v) or 4
        Save()
    end
})

    FarmTab:Slider({
        Title = "Độ cao bay (Fly Height)",
        Step = 5,
        Value = { Min = 70, Max = 500, Default = 70 },
        Callback = function(v)
            Cfg.FlyHeight = tonumber(v) or 70
            Save()
        end
    })

FarmTab:Slider({
    Title = "Tốc độ bay (Fly Speed)",
    Step = 20,
    Value = { Min = 600, Max = 2000, Default = Cfg.FlySpeed },
    Callback = function(v)
        Cfg.FlySpeed = tonumber(v) or 600
        Save()
    end
})

FarmTab:Toggle({
    Title = "Auto Reload",
    Desc = "Tự động thay lưỡi kiếm mới khi toàn bộ lưỡi bị gãy",
    Value = Cfg.AutoReload,
    Callback = function(v)
        Cfg.AutoReload = v
        Save()
    end
})

FarmTab:Toggle({
    Title = "Kích hoạt Auto Refill",
    Desc = "Tự động hồi phục trang bị tại các trạm tiếp tế",
    Value = Cfg.RefillEnabled,
    Callback = function(v)
        Cfg.RefillEnabled = v
        SyncRefillConfig()
    end
})

FarmTab:Toggle({
    Title = "Tiếp tế Lưỡi kiếm (Blades)",
    Value = Cfg.RefillPickBlade,
    Callback = function(v)
        Cfg.RefillPickBlade = v
        SyncRefillConfig()
    end
})

FarmTab:Toggle({
    Title = "Tiếp tế Thunder Spears",
    Value = Cfg.RefillPickThunder,
    Callback = function(v)
        Cfg.RefillPickThunder = v
        SyncRefillConfig()
    end
})

FarmTab:Toggle({
    Title = "Auto Retry",
    Desc = "Tự động bỏ phiếu chơi lại khi kết thúc màn",
    Value = Cfg.AutoRetry,
    Callback = function(v)
        Cfg.AutoRetry = v
        if not v then Cfg.RetryDone = 0 end
        Save()
    end
})

FarmTab:Toggle({
    Title = "Auto Leave",
    Desc = "Tự động về sảnh chờ ngay khi hoàn thành trận",
    Value = Cfg.AutoLeave,
    Callback = function(v)
        Cfg.AutoLeave = v
        if v then Cfg.AutoLeaveWhenRetryComplete = false end
        Save()
    end
})

FarmTab:Toggle({
    Title = "Auto Leave sau số trận quy định",
    Desc = "Tự động rời phòng khi đạt đủ số lượt Retry",
    Value = Cfg.AutoLeaveWhenRetryComplete,
    Callback = function(v)
        Cfg.AutoLeaveWhenRetryComplete = v
        if v then Cfg.AutoLeave = false end
        Save()
    end
})

FarmTab:Slider({
    Title = "Số lượt Retry tối đa",
    Step = 1,
    Value = { Min = 1, Max = 50, Default = Cfg.RetryAmount },
    Callback = function(v)
        Cfg.RetryAmount = tonumber(v) or 3
        Save()
    end
})

FarmTab:Slider({
    Title = "Safe Time (Giữ lại Titan cuối cùng)",
    Step = 1,
    Value = { Min = 0, Max = 300, Default = Cfg.SafeTime },
    Callback = function(v)
        Cfg.SafeTime = tonumber(v) or 32
        Save()
    end
})

FarmTab:Toggle({
    Title = "Auto Fail Safe",
    Desc = "Đứng yên chịu thua khi chuỗi thắng đạt giới hạn để tránh bị quét",
    Value = Cfg.AutoFailSafe,
    Callback = function(v)
        Cfg.AutoFailSafe = v
        if not v then Farm.FailSafeActive = false end
        Save()
    end
})

FarmTab:Slider({
    Title = "Ngưỡng chuỗi thắng kích hoạt Fail Safe",
    Step = 1,
    Value = { Min = 0, Max = 100, Default = Cfg.FailSafeAt },
    Callback = function(v)
        Cfg.FailSafeAt = tonumber(v) or 20
        Save()
    end
})

--// Logic thực thi Auto Farm & Tối ưu hàng đợi Remote
do
    local ATTACK_GAP = { [0] = 0.4, [1] = 0.8, [2] = 0.3, [3] = 0.2, [4] = 0.12, [5] = 0.08 }
    local OTHER_PARTS = { "Eyes", "LeftArm", "RightArm", "LeftLeg", "RightLeg" }
    local ARRIVE_DIST = 12
    local ORBIT_RADIUS = 14
    local ORBIT_SPEED = 1.6
    local ORBIT_BOB = 5
    local HIT_COUNT = 10
    local DAMAGE_MULT = 10
    local REMOTE_BUDGET = 150
    local NET_BATCH = 12
    local NET_QUEUE_MAX = 400

    local budgetStart, budgetUsed = os.clock(), 0
    local netQ, netHead, netTail = {}, 1, 0
    local PRIORITY = {}

    local function NetPending()
        return netTail - netHead + 1
    end
    local function NetPush(remote, ...)
        netTail = netTail + 1
        netQ[netTail] = { remote = remote, args = table.pack(...) }
    end

    RunService.Heartbeat:Connect(function()
        if not Alive() then return end
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

    local function Reps(nParts)
        local want = Cfg.DamageMultiplier and DAMAGE_MULT or 1
        if REMOTE_BUDGET <= 0 or want <= 1 then return want end
        local now = os.clock()
        if now - budgetStart >= 1 then budgetStart, budgetUsed = now, 0 end
        local n = math.max(nParts, 1)
        local reps = math.max(1, math.min(want, math.floor((REMOTE_BUDGET - budgetUsed) / n)))
        budgetUsed = budgetUsed + reps * n
        return reps
    end

    local function MyRoot()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if char and hum and root and hum.Health > 0 then return root, char end
        return nil
    end

    local function TitanAlive(titan)
        local hum = titan and titan.Parent and titan:FindFirstChildOfClass("Humanoid")
        return hum ~= nil and hum.Health > 0
    end

    local function HitParts(titan)
        local hb = titan and titan:FindFirstChild("Hitboxes")
        return hb and hb:FindFirstChild("Hit")
    end

    local function NapeOf(titan)
        local hit = HitParts(titan)
        local nape = hit and hit:FindFirstChild("Nape")
        return (nape and nape:IsA("BasePart")) and nape or nil
    end

    local function PickTitan(root)
        local folder = workspace:FindFirstChild("Titans")
        if not folder then return nil end
        local best, bestDist = nil, math.huge
        for _, t in ipairs(folder:GetChildren()) do
            if t:IsA("Model") and TitanAlive(t) then
                local nape = NapeOf(t)
                if nape then
                    local d = (nape.Position - root.Position).Magnitude
                    if d < bestDist then best, bestDist = t, d end
                end
            end
        end
        return best
    end

    local function Running()
        if not Cfg.FarmEnabled or not Farm.CanUseHere() then return false end
        if SH.QuestHold or Farm.Refilling or Farm.FailSafeActive then return false end
        return true
    end

    local SAFE = { start = os.clock(), zeroSince = nil, n = 0 }
    local function SafeLeft()
        local need = Cfg.SafeTime or 0
        if need <= 0 or not Farm.CanUseHere() then return 0 end
        return math.max(0, need - (os.clock() - SAFE.start))
    end

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
                    if t:IsA("Model") and TitanAlive(t) then n += 1 end
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
        if SafeLeft() <= 0 then return list end
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
                    count += 1
                    out[#out + 1] = part
                end
            end
        end
        return out
    end

    local function NapesAround(main, spear)
        local mainNape = NapeOf(main)
        if not mainNape then return {} end
        local cap = spear and 200 or HIT_COUNT
        local folder = workspace:FindFirstChild("Titans")
        local boss, bossNape = nil, nil
        if folder then
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
                if n then
                    others[#others + 1] = { part = n, d = (n.Position - mainNape.Position).Magnitude }
                end
            end
        end
        table.sort(others, function(a, b) return a.d < b.d end)
        local list = {}
        if boss then
            PRIORITY = { [bossNape] = true }
            list[1] = bossNape
            if main ~= boss then list[#list + 1] = mainNape end
        else
            PRIORITY = { [mainNape] = true }
            list[1] = mainNape
        end
        for i = 1, math.min(cap - #list, #others) do
            list[#list + 1] = others[i].part
        end
        return list
    end

    local function Slash(parts)
        local remote = GetPostRemote()
        if not remote or NetPending() > NET_QUEUE_MAX then return false end
        if typeof(parts) == "Instance" then parts = { parts } end
        local reps = Reps(#parts)
        NetPush(remote, "Attacks", "Slash", true)
        for _ = 1, reps do
            for _, part in ipairs(parts) do
                NetPush(remote, "Hitboxes", "Register", part, 143 + math.random() * 10, 0.26 + math.random() * 0.25)
            end
        end
        NetPush(remote, "Attacks", "Slash", false)
        Farm.Blades.Hits = Farm.Blades.Hits + #parts
        return true
    end

    local function SpearsLeft()
        local char = LocalPlayer.Character
        local n = char and char:GetAttribute("Spears")
        return type(n) == "number" and n or nil
    end
    Farm.SpearsLeft = SpearsLeft

    local lastSpearSide = 8
    local function FireSpear(parts)
        local get, post = GetLobbyRemote(), GetPostRemote()
        if not get or not post then return false end
        local left = SpearsLeft()
        if left ~= nil and left <= 0 then return false end
        lastSpearSide = (lastSpearSide == 8) and 7 or 8
        local id = tostring(math.clamp(left or lastSpearSide, 1, 8))
        task.spawn(function()
            pcall(function() get:InvokeServer("Spears", "S_Fire", id) end)
        end)
        task.wait(0.08)
        local reps = Reps(#parts)
        if NetPending() <= NET_QUEUE_MAX then
            for _ = 1, reps do
                for _, part in ipairs(parts) do
                    if part and part.Parent then
                        NetPush(post, "Spears", "S_Explode", part.Position, 0.10 + math.random() * 0.09)
                    end
                end
            end
        end
        return true
    end

    task.spawn(function()
        while Alive() do
            task.wait(1)
            if Cfg.FarmEnabled and Cfg.FarmMode == "Smart" and Farm.CanUseHere() then
                ApplyFarmMode()
            end
        end
    end)

    local lastChar, readyAt = nil, 0
    local orbitAngle = 0
    local lastPick = 0

    RunService.Heartbeat:Connect(function(dt)
        if not Alive() then return end
        orbitAngle = (orbitAngle + ORBIT_SPEED * dt) % (math.pi * 2)
        local root, char = MyRoot()
        if char ~= lastChar then
            lastChar = char
            Farm.CharSpawnAt = os.clock()
            readyAt = os.clock() + (Cfg.StartDelay or 0)
        end

        if not Running() then
            Farm.Blades.Target = nil
            Farm.Blades.Status = Cfg.FarmEnabled and "Paused" or "Idle"
            return
        end
        if not root then
            Farm.Blades.Target = nil
            Farm.Blades.Status = "Waiting for character"
            return
        end
        if os.clock() < readyAt then
            Farm.Blades.Status = "Start delay"
            return
        end
        if Cfg.AutoFarm and Farm.BladesBusy and Farm.BladesBusy() then
            Farm.Blades.Status = "Reloading"
            pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
            return
        end

        if Cfg.NoClip and char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
            end
        end

        if Farm.Blades.Target and not TitanAlive(Farm.Blades.Target) then
            Farm.Blades.Target = nil
        end
        if not Farm.Blades.Target and os.clock() - lastPick > 0.35 then
            lastPick = os.clock()
            Farm.Blades.Target = PickTitan(root)
        end

        local nape = Farm.Blades.Target and NapeOf(Farm.Blades.Target)
        if nape then
            local offset = Vector3.new(
                math.cos(orbitAngle) * ORBIT_RADIUS,
                math.max(Cfg.FlyHeight or 230, 70) + math.sin(orbitAngle * 2) * ORBIT_BOB,
                math.sin(orbitAngle * 2) * ORBIT_RADIUS
            )
            local goal = nape.Position + offset
            local diff = goal - root.Position
            local dist = diff.Magnitude
            pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
            if dist > 1 then
                local step = math.min((Cfg.FlySpeed or 600) * dt, dist)
                local newPos = root.Position + diff.Unit * step
                root.CFrame = CFrame.new(newPos)
            end
            Farm.Blades.Status = (dist <= ARRIVE_DIST) and "Attacking" or "Flying to titan"
        else
            Farm.Blades.Target = nil
            Farm.Blades.Status = "Searching for titans"
            pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
        end
    end)

    task.spawn(function()
        local partLast = setmetatable({}, { __mode = "k" })
        while Alive() do
            local gap = ATTACK_GAP[Cfg.AttackSpeed or 0] or 0.4
            task.wait(gap)
            local target = Farm.Blades.Target
            local root = MyRoot()
            if Running() and root and target and TitanAlive(target) then
                if Cfg.AutoFarm and not (Farm.BladesBusy and Farm.BladesBusy()) then
                    local safeList = SafeFilter(NapesAround(target, false))
                    if #safeList > 0 then
                        Slash(safeList)
                        if Cfg.HitAllParts and SafeLeft() <= 0 then
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
                elseif Cfg.AutoFarmThunder then
                    local safeList = SafeFilter(NapesAround(target, true))
                    if #safeList > 0 then
                        FireSpear(safeList)
                    end
                end
            end
        end
    end)

    task.spawn(function()
        while Alive() do
            if Cfg.SafeFarm and Running() and Farm.Blades.Target then
                pcall(function()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                end)
                task.wait(0.9)
                pcall(function()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                    task.wait(2.0)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                end)
            else
                task.wait(0.4)
            end
        end
    end)

    task.spawn(function()
        while Alive() do
            task.wait(0.5)
            pcall(function()
                if not Cfg.FarmEnabled then
                    FarmStatusPara:SetDesc("Off")
                    return
                end
                local folder = workspace:FindFirstChild("Titans")
                local left = 0
                if folder then
                    for _, t in ipairs(folder:GetChildren()) do
                        if t:IsA("Model") and TitanAlive(t) then left += 1 end
                    end
                end
                FarmStatusPara:SetDesc(string.format("%s | Vũ khí: %s | Titan còn lại: %d", tostring(Farm.Blades.Status), tostring(Cfg.FarmMode), left))
            end)
        end
    end)
end

--// Xử lý Thay lưỡi (Reload) & Tiếp tế (Refill)
do
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

    local function AllBladesBroken()
        local parts = BladeParts()
        if #parts == 0 then return false end
        for _, p in ipairs(parts) do
            if not p:GetAttribute("Broken") then return false end
        end
        return true
    end

    Farm.BladesEmpty = AllBladesBroken
    local emptyStart = nil

    function Farm.BladesBusy()
        return emptyStart ~= nil and (os.clock() - emptyStart < 5)
    end

    task.spawn(function()
        local lastReload = 0
        while Alive() do
            task.wait(0.3)
            local broken = AllBladesBroken()
            if broken then
                emptyStart = emptyStart or os.clock()
                if Cfg.AutoReload and Farm.CanUseHere() and os.clock() - lastReload >= 2.5 then
                    lastReload = os.clock()
                    local remote = GetLobbyRemote()
                    if remote then
                        pcall(function() remote:InvokeServer("Blades", "Reload") end)
                    end
                end
            else
                emptyStart = nil
            end
        end
    end)

    local function SpareBladesLeft()
        local char = LocalPlayer.Character
        local rig = char and char:FindFirstChild("Rig_" .. LocalPlayer.Name)
        local torso = rig and rig:FindFirstChild("LowerTorso")
        if not torso then return nil end
        local total, left = 0, 0
        for _, d in ipairs(torso:GetChildren()) do
            if d.Name:match("^Left_%d+$") then
                total += 1
                if not d:GetAttribute("Used") then left += 1 end
            end
        end
        return total > 0 and left or nil
    end

    local function NeedRefill()
        if Cfg.AutoRefillsBlade and AllBladesBroken() and (SpareBladesLeft() == 0) then
            return true
        end
        if Cfg.AutoRefillsThunder then
            local sp = Farm.SpearsLeft and Farm.SpearsLeft()
            if sp ~= nil and sp <= 0 then return true end
        end
        return false
    end

    local function FindNearestRefill(root)
        local best, bestDist = nil, math.huge
        for _, d in ipairs(workspace:GetDescendants()) do
            if d.Name == "Refill" then
                local pos = d:IsA("BasePart") and d.Position or (d:IsA("Model") and d:GetPivot().Position)
                if pos then
                    local dist = (pos - root.Position).Magnitude
                    if dist < bestDist then best, bestDist = d, dist end
                end
            end
        end
        return best
    end

    task.spawn(function()
        local lastRefillAt = 0
        while Alive() do
            task.wait(0.8)
            if Farm.CanUseHere() and NeedRefill() and os.clock() - lastRefillAt >= 10 then
                lastRefillAt = os.clock()
                local ok, err = pcall(function()
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    local post = GetPostRemote()
                    if not root or not post then return end
                    local station = FindNearestRefill(root)
                    if not station then return end

                    pcall(function() post:FireServer("Attacks", "Reload", station) end)
                    task.wait(1.5)
                    if not NeedRefill() then return end

                    Farm.Refilling = true
                    local oldCF = root.CFrame
                    local stPos = station:IsA("BasePart") and station.Position or station:GetPivot().Position
                    root.CFrame = CFrame.new(stPos + Vector3.new(0, 3, 0))
                    task.wait(0.4)
                    local prompt = station:FindFirstChildWhichIsA("ProximityPrompt", true)
                        or (station.Parent and station.Parent:FindFirstChildWhichIsA("ProximityPrompt", true))
                    if prompt and type(fireproximityprompt) == "function" then
                        pcall(fireproximityprompt, prompt)
                    end
                    pcall(function() post:FireServer("Attacks", "Reload", station) end)
                    task.wait(1.0)
                    if root and root.Parent then
                        root.CFrame = oldCF
                    end
                end)
                Farm.Refilling = false
                if not ok then warn("[AOTR WindUI] Lỗi tiếp tế:", err) end
            end
        end
    end)
end

--// Xử lý Retry, Rời phòng & Fail Safe
do
    local function FindCompleteTitle()
        for _, d in ipairs(PlayerGui:GetDescendants()) do
            if (d:IsA("TextLabel") or d:IsA("TextButton")) and CleanText(d):upper() == "MISSION COMPLETED" and IsShown(d) then
                return d
            end
        end
        return nil
    end
    Farm.CompleteScreenShown = function() return FindCompleteTitle() ~= nil end

    local function FindActionBtn(title, pattern)
        local cur = title and title.Parent
        for _ = 1, 8 do
            if not cur or cur == PlayerGui then break end
            for _, d in ipairs(cur:GetDescendants()) do
                if (d:IsA("TextLabel") or d:IsA("TextButton")) and CleanText(d):upper():match(pattern) and IsShown(d) then
                    return d:IsA("GuiButton") and d or d:FindFirstAncestorWhichIsA("GuiButton")
                end
            end
            cur = cur.Parent
        end
        return nil
    end

    task.spawn(function()
        local countedThisMatch = false
        while Alive() do
            task.wait(1.2)
            if Farm.CanUseHere() then
                local title = FindCompleteTitle()
                if title then
                    if not countedThisMatch then
                        countedThisMatch = true
                        Cfg.Streak = (Cfg.Streak or 0) + 1
                        Cfg.RetryDone = (Cfg.RetryDone or 0) + 1
                        Save()
                    end
                    Farm.FailSafeActive = false
                    local shouldLeave = Cfg.AutoLeave or (Cfg.AutoLeaveWhenRetryComplete and Cfg.RetryDone >= Cfg.RetryAmount)
                    if shouldLeave then
                        local post = GetPostRemote()
                        if post then
                            Cfg.RetryDone = 0
                            Save()
                            pcall(function() post:FireServer("Functions", "Teleport") end)
                        end
                    elseif Cfg.AutoRetry then
                        local rBtn = FindActionBtn(title, "^RETRY")
                        if rBtn then ActivateGuiButton(rBtn) end
                    end
                else
                    countedThisMatch = false
                    if Cfg.AutoFailSafe and (Cfg.FailSafeAt or 0) > 0 and (Cfg.Streak or 0) >= Cfg.FailSafeAt then
                        Farm.FailSafeActive = true
                    else
                        Farm.FailSafeActive = false
                    end
                end
            end
        end
    end)
end

--====================================================================
-- 4. TAB: AUTO QUEST [ THUNDER SPEAR ]
--====================================================================
local QuestTab = Window:Tab({ Title = "Auto Quest", Icon = "compass" })
local QuestStatusPara = QuestTab:Paragraph({
    Title = "Trạng thái nhiệm vụ",
    Desc = "Off"
})

local function SetQuestStatus(txt)
    pcall(function() QuestStatusPara:SetDesc(tostring(txt)) end)
end

QuestTab:Toggle({
    Title = "Round 1: Giữ 3 chòi canh (Outskirts)",
    Desc = "Yêu cầu Prestige 1+ & Level 80+. Tạo phòng Outskirts (Aberrant) và đứng giữ 3 chòi",
    Value = Cfg.AutoQuestThunderR1,
    Callback = function(v)
        Cfg.AutoQuestThunderR1 = v
        Save()
    end
})

QuestTab:Toggle({
    Title = "Round 2: Vác 3 thùng tiếp tế (Forest)",
    Desc = "Yêu cầu Prestige 1+ & Level 80+. Tạo phòng Forest (Aberrant) và mang 3 thùng về điểm tập kết",
    Value = Cfg.AutoQuestThunderR2,
    Callback = function(v)
        Cfg.AutoQuestThunderR2 = v
        Save()
    end
})

QuestTab:Toggle({
    Title = "Round 3: Chơi 3 ván Nightmare (Utgard)",
    Desc = "Yêu cầu Prestige 1+ & Level 80+. Tạo phòng Utgard (Aberrant + Nightmare) và hoàn thành 3 ván",
    Value = Cfg.AutoQuestThunderR3,
    Callback = function(v)
        Cfg.AutoQuestThunderR3 = v
        Save()
    end
})

do
    local TWEEN_SPEED = 300
    local R2_DROP_POS = Vector3.new(92.71, 24.14, -306.95)

    local function MoveToPos(pos, checkFn)
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        pcall(function() LocalPlayer:RequestStreamAroundAsync(pos, 0.5) end)
        local cf = CFrame.new(pos) * root.CFrame.Rotation
        local t = math.max((root.Position - pos).Magnitude / TWEEN_SPEED, 0.1)
        local ok, tw = pcall(function()
            return TweenService:Create(root, TweenInfo.new(t, Enum.EasingStyle.Linear), { CFrame = cf })
        end)
        if not ok or not tw then
            pcall(function() root.CFrame = cf end)
            return
        end
        local vel = RunService.Heartbeat:Connect(function()
            pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
        end)
        tw:Play()
        local t0 = os.clock()
        while os.clock() - t0 < t + 0.3 and tw.PlaybackState == Enum.PlaybackState.Playing and Alive() and checkFn() do
            task.wait()
        end
        pcall(function() tw:Cancel() end)
        vel:Disconnect()
    end

    task.spawn(function()
        while Alive() do
            task.wait(1)
            if Farm.CanUseHere() then
                -- Round 1
                if Cfg.AutoQuestThunderR1 and workspace:FindFirstChild("WatchTower_1") then
                    SH.QuestHold = true
                    local ok, err = pcall(function()
                        for n = 1, 3 do
                            if not (Alive() and Cfg.AutoQuestThunderR1) then break end
                            local model = workspace:FindFirstChild("WatchTower_" .. n)
                            if model then
                                local pos = (model.PrimaryPart and model.PrimaryPart.Position or model:GetPivot().Position) + Vector3.new(0, 3, 0)
                                SetQuestStatus("Round 1: Di chuyển tới WatchTower " .. n .. "/3")
                                MoveToPos(pos, function() return Cfg.AutoQuestThunderR1 end)
                                SetQuestStatus("Round 1: Đứng giữ WatchTower " .. n .. "/3")
                                while Alive() and Cfg.AutoQuestThunderR1 and model.Parent do
                                    if n < 3 and workspace:FindFirstChild("WatchTower_" .. (n + 1)) then break end
                                    task.wait(0.5)
                                end
                            end
                        end
                        SetQuestStatus("Round 1: Hoàn tất chòi canh - Chuyển sang Farm")
                    end)
                    SH.QuestHold = false
                    if not ok then warn("[AOTR WindUI] Lỗi Quest R1:", err) end
                    while Alive() and Cfg.AutoQuestThunderR1 and workspace:FindFirstChild("WatchTower_1") do
                        task.wait(1.5)
                    end
                end

                -- Round 2
                if Cfg.AutoQuestThunderR2 and workspace:FindFirstChild("ThunderSpear_Supplies1", true) then
                    SH.QuestHold = true
                    local ok, err = pcall(function()
                        for n = 1, 3 do
                            if not (Alive() and Cfg.AutoQuestThunderR2) then break end
                            local crate = workspace:FindFirstChild("ThunderSpear_Supplies" .. n, true)
                            if crate then
                                local cPos = crate:IsA("BasePart") and crate.Position or crate:GetPivot().Position
                                SetQuestStatus("Round 2: Thu thập thùng tiếp tế " .. n .. "/3")
                                MoveToPos(cPos + Vector3.new(0, 3, 0), function() return Cfg.AutoQuestThunderR2 end)
                                task.wait(0.3)
                                local prompt = crate:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if prompt and type(fireproximityprompt) == "function" then
                                    pcall(fireproximityprompt, prompt)
                                end
                                task.wait(0.6)
                                SetQuestStatus("Round 2: Mang thùng " .. n .. "/3 về điểm tập kết")
                                MoveToPos(R2_DROP_POS, function() return Cfg.AutoQuestThunderR2 end)
                                task.wait(0.8)
                            end
                        end
                        SetQuestStatus("Round 2: Hoàn tất vận chuyển - Chuyển sang Farm")
                    end)
                    SH.QuestHold = false
                    if not ok then warn("[AOTR WindUI] Lỗi Quest R2:", err) end
                    while Alive() and Cfg.AutoQuestThunderR2 and workspace:FindFirstChild("ThunderSpear_Supplies1", true) do
                        task.wait(1.5)
                    end
                end
            end
        end
    end)
end

--====================================================================
-- 5. TAB: AUTO SKILL
--====================================================================
local SkillTab = Window:Tab({ Title = "Auto Skill", Icon = "sparkles" })
local KEY_CODES = { Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.Five }

for i = 1, 5 do
    local tKey = "AutoSkill" .. i
    local mKey = "AutoSkillMode" .. i
    SkillTab:Toggle({
        Title = "Kích hoạt Skill Slot [ " .. i .. " ]",
        Value = Cfg[tKey],
        Callback = function(v)
            Cfg[tKey] = v
            Save()
        end
    })
    SkillTab:Dropdown({
        Title = "Chế độ bấm Slot [ " .. i .. " ]",
        Values = { "Instant", "Hold" },
        Value = Cfg[mKey] or "Instant",
        Callback = function(val)
            Cfg[mKey] = val
            Save()
        end
    })
end

SkillTab:Slider({
    Title = "Thời gian giữ phím (Giây)",
    Step = 1,
    Value = { Min = 1, Max = 10, Default = Cfg.AutoSkillHoldTime },
    Callback = function(v)
        Cfg.AutoSkillHoldTime = tonumber(v) or 3
        Save()
    end
})

SkillTab:Slider({
    Title = "Thời gian hồi giữa các lần bấm (Giây)",
    Step = 1,
    Value = { Min = 1, Max = 30, Default = Cfg.AutoSkillDelay },
    Callback = function(v)
        Cfg.AutoSkillDelay = tonumber(v) or 2
        Save()
    end
})

task.spawn(function()
    local nextSkillAt = { 0, 0, 0, 0, 0 }
    while Alive() do
        task.wait(0.25)
        if Farm.CanUseHere() and not UserInputService:GetFocusedTextBox() and not Farm.CompleteScreenShown() then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                for i = 1, 5 do
                    if Cfg["AutoSkill" .. i] and os.clock() >= nextSkillAt[i] then
                        local key = KEY_CODES[i]
                        if Cfg["AutoSkillMode" .. i] == "Hold" then
                            pcall(function() VirtualInputManager:SendKeyEvent(true, key, false, game) end)
                            task.wait(Cfg.AutoSkillHoldTime or 3)
                            pcall(function() VirtualInputManager:SendKeyEvent(false, key, false, game) end)
                        else
                            pcall(function()
                                VirtualInputManager:SendKeyEvent(true, key, false, game)
                                task.wait(0.06)
                                VirtualInputManager:SendKeyEvent(false, key, false, game)
                            end)
                        end
                        nextSkillAt[i] = os.clock() + (Cfg.AutoSkillDelay or 2)
                    end
                end
            end
        end
    end
end)

--====================================================================
-- 6. TAB: LOBBY & GEAR
--====================================================================
local LobbyTab = Window:Tab({ Title = "Lobby & Gear", Icon = "shield" })

LobbyTab:Toggle({
    Title = "Tự động nhận nhiệm vụ ngày",
    Value = Cfg.AutoClaimDaily,
    Callback = function(v) Cfg.AutoClaimDaily = v Save() end
})

LobbyTab:Toggle({
    Title = "Auto Upgrade Gear (Blades & ODM)",
    Value = Cfg.AutoUpgradeBlade,
    Callback = function(v) Cfg.AutoUpgradeBlade = v Save() end
})

LobbyTab:Toggle({
    Title = "Auto Upgrade Gear (Thunder Spears)",
    Value = Cfg.AutoUpgradeThunder,
    Callback = function(v) Cfg.AutoUpgradeThunder = v Save() end
})

LobbyTab:Toggle({
    Title = "Auto Equip Blades",
    Value = Cfg.AutoEquipBlade,
    Callback = function(v)
        Cfg.AutoEquipBlade = v
        if v then
            Cfg.AutoEquipThunder = false
            local r = GetLobbyRemote()
            if r then pcall(function() r:InvokeServer("S_Equipment", "Weapon", "Blades") end) end
        end
        Save()
    end
})

LobbyTab:Toggle({
    Title = "Auto Equip Thunder Spears",
    Value = Cfg.AutoEquipThunder,
    Callback = function(v)
        Cfg.AutoEquipThunder = v
        if v then
            Cfg.AutoEquipBlade = false
            local r = GetLobbyRemote()
            if r then pcall(function() r:InvokeServer("S_Equipment", "Weapon", "Spears") end) end
        end
        Save()
    end
})

do
    local BLADE_STATS = { "Blade_Durability", "ODM_Gas", "Crit_Damage", "ODM_Control", "ODM_Speed", "Crit_Chance", "ODM_Range", "ODM_Damage" }
    local THUNDER_STATS = { "Blast_Radius", "TS_Damage", "TS_Gas", "TS_Range", "TS_Control", "Crit_Chance", "Crit_Damage", "TS_Speed" }

    task.spawn(function()
        while Alive() do
            task.wait(10)
            local r = GetLobbyRemote()
            if r then
                if Cfg.AutoUpgradeBlade then
                    pcall(function() r:InvokeServer("S_Equipment", "Upgrade", table.clone(BLADE_STATS)) end)
                    task.wait(1.5)
                end
                if Cfg.AutoUpgradeThunder then
                    pcall(function() r:InvokeServer("S_Equipment", "Upgrade", table.clone(THUNDER_STATS)) end)
                end
            end
        end
    end)
end

--====================================================================
-- 7. TAB: MISSIONS
--====================================================================
local MissionTab = Window:Tab({ Title = "Missions", Icon = "map" })

local MISSION_OPTIONS    = { "Shiganshina", "Trost", "Outskirts", "Forest", "Utgard", "Docks", "Stohess", "Chapel" }
local DIFFICULTY_OPTIONS = { "Easy (E- Grade)", "Normal (E+ Grade)", "Hard (D+ Grade)", "Severe (B- Grade)", "Aberrant (A- Grade)" }
local MODIFIER_OPTIONS   = { "No Perks", "No Skills", "No Memories", "Nightmare", "Oddball", "Injury Prone", "Chronic Injuries", "Fog", "Glass Cannon", "Time Trial", "Boring", "Simple" }

local MissionStatusPara = MissionTab:Paragraph({
    Title = "Trạng thái tạo phòng",
    Desc = "Sẵn sàng"
})

local function SetMissionStatus(txt)
    pcall(function() MissionStatusPara:SetDesc(tostring(txt)) end)
end

MissionTab:Dropdown({
    Title = "Chọn bản đồ (Mission)",
    Values = MISSION_OPTIONS,
    Value = Cfg.MissionSelect,
    Callback = function(v)
        Cfg.MissionSelect = v
        Save()
    end
})

MissionTab:Dropdown({
    Title = "Chọn độ khó (Difficulty)",
    Values = DIFFICULTY_OPTIONS,
    Value = Cfg.MissionLevel,
    Callback = function(v)
        Cfg.MissionLevel = v
        Save()
    end
})

MissionTab:Dropdown({
    Title = "Chọn Modifiers",
    Values = MODIFIER_OPTIONS,
    Multi = true,
    Default = Cfg.MissionModifiers,
    Callback = function(vals)
        if type(vals) == "table" then
            local list = {}
            for k, v in pairs(vals) do
                if type(k) == "number" and type(v) == "string" then
                    list[#list + 1] = v
                elseif v == true and type(k) == "string" then
                    list[#list + 1] = k
                end
            end
            Cfg.MissionModifiers = list
            Save()
        end
    end
})

MissionTab:Toggle({
    Title = "Auto Create Mission",
    Desc = "Tự động tạo phòng theo cấu hình khi ở sảnh chính",
    Value = Cfg.AutoCreateMission,
    Callback = function(v)
        Cfg.AutoCreateMission = v
        if v then Cfg.AutoCreateRaid = false Cfg.AutoCreateWave = false end
        Save()
    end
})

MissionTab:Toggle({
    Title = "Auto Start Mission",
    Desc = "Tự động bắt đầu trận đấu khi phòng đã được tạo xong",
    Value = Cfg.AutoStartMission,
    Callback = function(v)
        Cfg.AutoStartMission = v
        if v then Cfg.AutoStartRaid = false Cfg.AutoStartWave = false end
        Save()
    end
})

MissionTab:Slider({
    Title = "Độ trễ bắt đầu màn (Giây)",
    Step = 1,
    Value = { Min = MIN_DELAY, Max = MAX_DELAY, Default = Cfg.MissionJoinDelay },
    Callback = function(v)
        Cfg.MissionJoinDelay = math.clamp(tonumber(v) or 10, MIN_DELAY, MAX_DELAY)
        Save()
    end
})

MissionTab:Button({
    Title = "Rời khỏi phòng hiện tại (Leave Room)",
    Callback = function()
        local r = GetLobbyRemote()
        if r then
            local ok = pcall(function() r:InvokeServer("S_Missions", "Leave") end)
            SetMissionStatus(ok and "Đã rời khỏi phòng" or "Rời phòng thất bại")
        end
    end
})

do
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

    local function DifficultyKey(label)
        return (label or ""):match("^(%S+)") or "Easy"
    end

    task.spawn(function()
        local startReadyAt = nil
        while Alive() do
            task.wait(1)
            if IN_LOBBY and not SH.Coord.Blocker(100) then
                local r = GetLobbyRemote()
                local room = MyRoomObject()
                if Cfg.AutoCreateMission and not room and r then
                    local diffKey = DifficultyKey(Cfg.MissionLevel)
                    SetMissionStatus("Đang tạo phòng: " .. Cfg.MissionSelect .. " (" .. diffKey .. ")")
                    local ok, res = pcall(function()
                        return r:InvokeServer("S_Missions", "Create", {
                            Difficulty = diffKey,
                            Type = "Missions",
                            Objective = Cfg.MissionObjective or "Skirmish",
                            Name = Cfg.MissionSelect,
                        })
                    end)
                    if ok and res then
                        task.wait(0.6)
                        for _, mod in ipairs(Cfg.MissionModifiers or {}) do
                            pcall(function() r:InvokeServer("S_Missions", "Modify", mod) end)
                            task.wait(0.2)
                        end
                        startReadyAt = os.clock() + (Cfg.MissionJoinDelay or 10)
                        SetMissionStatus("Tạo phòng thành công!")
                    else
                        SetMissionStatus("Tạo phòng thất bại, đang thử lại...")
                        task.wait(4)
                    end
                elseif room and Cfg.AutoStartMission and r then
                    startReadyAt = startReadyAt or (os.clock() + (Cfg.MissionJoinDelay or 10))
                    local rem = math.ceil(startReadyAt - os.clock())
                    if rem <= 0 then
                        SetMissionStatus("Đang kích hoạt bắt đầu màn chơi...")
                        pcall(function() r:InvokeServer("S_Missions", "Start") end)
                        startReadyAt = os.clock() + 10
                    else
                        SetMissionStatus("Bắt đầu trận sau " .. rem .. "s...")
                    end
                else
                    startReadyAt = nil
                end
            end
        end
    end)
end

--====================================================================
-- 8. TAB: SPIN FAMILY
--====================================================================
local SpinTab = Window:Tab({ Title = "Spin Family", Icon = "refresh-cw" })

local STOP_OPTIONS = { "Rare", "Epic", "Legendary", "Mythic", "Off" }
local KEEP_OPTIONS = { "Stop", "Store" }

local SpinStatusPara = SpinTab:Paragraph({
    Title = "Trạng thái Roll Family",
    Desc = "Off"
})

SpinTab:Toggle({
    Title = "Auto Spin [ Lucky999+ ]",
    Desc = "Tự động quay Family trong màn hình Customize (Menu)",
    Value = Cfg.AutoSpin,
    Callback = function(v)
        Cfg.AutoSpin = v
        Save()
    end
})

SpinTab:Dropdown({
    Title = "Dừng khi ra độ hiếm (Keep Rarity)",
    Values = STOP_OPTIONS,
    Value = Cfg.SpinStopRarity or "Epic",
    Callback = function(v)
        Cfg.SpinStopRarity = v
        Save()
    end
})

SpinTab:Dropdown({
    Title = "Hành động khi trúng Tộc hiếm",
    Values = KEEP_OPTIONS,
    Value = Cfg.SpinOnKeep or "Stop",
    Callback = function(v)
        Cfg.SpinOnKeep = v
        Save()
    end
})

SpinTab:Slider({
    Title = "Spin Delay (Giây chờ mỗi lần quay)",
    Step = 1,
    Value = { Min = 1, Max = 10, Default = math.floor(Cfg.SpinDelay or 3) },
    Callback = function(v)
        Cfg.SpinDelay = tonumber(v) or 3
        Save()
    end
})

do
    local RANK = { COMMON = 1, UNCOMMON = 2, RARE = 3, EPIC = 4, LEGENDARY = 5, MYTHIC = 6, SECRET = 7, EXCLUSIVE = 8 }

    local function ReadCurrentFamily()
        for _, d in ipairs(PlayerGui:GetDescendants()) do
            if (d:IsA("TextLabel") or d:IsA("TextButton")) and IsShown(d) then
                local name, rarity = CleanText(d):upper():match("^(.-)%s*%((%a+)%)$")
                if name and RANK[rarity] then
                    return name, rarity
                end
            end
        end
        return nil, nil
    end

    local function FindRollButton()
        for _, d in ipairs(PlayerGui:GetDescendants()) do
            if (d:IsA("TextLabel") or d:IsA("TextButton")) and CleanText(d):upper():match("^ROLL") and IsShown(d) then
                return d:IsA("GuiButton") and d or d:FindFirstAncestorWhichIsA("GuiButton"), d
            end
        end
        return nil, nil
    end

    task.spawn(function()
        while Alive() do
            task.wait(0.5)
            if Cfg.AutoSpin and IN_MENU then
                local btn = FindRollButton()
                if not btn then
                    pcall(function() SpinStatusPara:SetDesc("Vui lòng mở trang Family để bắt đầu quay!") end)
                else
                    local name, rarity = ReadCurrentFamily()
                    if name and rarity then
                        local stopRank = Cfg.SpinStopRarity == "Off" and math.huge or (RANK[Cfg.SpinStopRarity:upper()] or 4)
                        local curRank = RANK[rarity] or 0
                        if curRank >= stopRank then
                            if Cfg.SpinOnKeep == "Store" then
                                local r = GetLobbyRemote()
                                if r then pcall(function() r:InvokeServer("Family", "Store") end) end
                                pcall(function() SpinStatusPara:SetDesc("Đã cất giữ: " .. name .. " (" .. rarity .. ")") end)
                                task.wait(1.5)
                            else
                                Cfg.AutoSpin = false
                                Save()
                                pcall(function() SpinStatusPara:SetDesc("Đã dừng! Quay trúng: " .. name .. " (" .. rarity .. ")") end)
                            end
                        else
                            pcall(function() SpinStatusPara:SetDesc("Đang quay... Hiện tại: " .. name .. " (" .. rarity .. ")") end)
                            ActivateGuiButton(btn)
                            task.wait(Cfg.SpinDelay or 3)
                        end
                    end
                end
            end
        end
    end)
end

--====================================================================
-- 9. TAB: SKILLS & PRESTIGE
--====================================================================
local ProgTab = Window:Tab({ Title = "Skills & Prestige", Icon = "trending-up" })

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

ProgTab:Toggle({
    Title = "Auto Upgrade Skill Trees",
    Desc = "Tự động mở khóa các nhánh kỹ năng đã bật bên dưới",
    Value = Cfg.AutoUpgradeSkills,
    Callback = function(v) Cfg.AutoUpgradeSkills = v Save() end
})

ProgTab:Toggle({
    Title = "Nâng nhánh Trái (Left Path)",
    Value = Cfg.SkillLeft,
    Callback = function(v) Cfg.SkillLeft = v Save() end
})

ProgTab:Dropdown({
    Title = "Chọn hướng nhánh Trái",
    Values = { "Regen VI", "Injury III" },
    Value = Cfg.SkillLeftPick or "Regen VI",
    Callback = function(v) Cfg.SkillLeftPick = v Save() end
})

ProgTab:Toggle({
    Title = "Nâng nhánh Giữa (Middle Path)",
    Value = Cfg.SkillMiddle,
    Callback = function(v) Cfg.SkillMiddle = v Save() end
})

ProgTab:Dropdown({
    Title = "Chọn hướng nhánh Giữa",
    Values = { "Damage V", "Crit Damage V" },
    Value = Cfg.SkillMiddlePick or "Damage V",
    Callback = function(v) Cfg.SkillMiddlePick = v Save() end
})

ProgTab:Toggle({
    Title = "Nâng nhánh Phải (Right Path)",
    Value = Cfg.SkillRight,
    Callback = function(v) Cfg.SkillRight = v Save() end
})

ProgTab:Dropdown({
    Title = "Chọn hướng nhánh Phải",
    Values = { "Tank VIII", "Health XI" },
    Value = Cfg.SkillRightPick or "Tank VIII",
    Callback = function(v) Cfg.SkillRightPick = v Save() end
})

ProgTab:Toggle({
    Title = "Auto Prestige (Tự động chuyển sinh)",
    Desc = "Tự động Prestige ở sảnh khi đạt cấp độ tối đa",
    Value = Cfg.AutoPrestige,
    Callback = function(v) Cfg.AutoPrestige = v Save() end
})

ProgTab:Slider({
    Title = "Dừng Prestige ở cấp (Stop At)",
    Step = 1,
    Value = { Min = 1, Max = 5, Default = Cfg.PrestigeStopAt or 3 },
    Callback = function(v) Cfg.PrestigeStopAt = tonumber(v) or 3 Save() end
})

task.spawn(function()
    while Alive() do
        task.wait(10)
        if Cfg.AutoUpgradeSkills then
            local r = GetLobbyRemote()
            if r then
                if Cfg.SkillLeft and SKILL_PATHS.Left[Cfg.SkillLeftPick] then
                    pcall(function() r:InvokeServer("S_Equipment", "Unlock", table.clone(SKILL_PATHS.Left[Cfg.SkillLeftPick])) end)
                    task.wait(1.5)
                end
                if Cfg.SkillMiddle and SKILL_PATHS.Middle[Cfg.SkillMiddlePick] then
                    pcall(function() r:InvokeServer("S_Equipment", "Unlock", table.clone(SKILL_PATHS.Middle[Cfg.SkillMiddlePick])) end)
                    task.wait(1.5)
                end
                if Cfg.SkillRight and SKILL_PATHS.Right[Cfg.SkillRightPick] then
                    pcall(function() r:InvokeServer("S_Equipment", "Unlock", table.clone(SKILL_PATHS.Right[Cfg.SkillRightPick])) end)
                end
            end
        end
    end
end)

--====================================================================
-- 10. TAB: RAID & WAVE MODE
--====================================================================
local ModeTab = Window:Tab({ Title = "Raid & Wave", Icon = "flame" })

local RAID_BOSSES = { "Attack Titan", "Female Titan", "Armored Titan", "Colossal Titan" }
local RAID_DIFFS  = { "Hard", "Severe", "Aberrant" }
local WAVE_MAPS   = { "Trost", "Shiganshina", "Outskirts", "Forest", "Utgard" }

local ModeStatusPara = ModeTab:Paragraph({
    Title = "Trạng thái Raid / Wave",
    Desc = "Sẵn sàng"
})

local function SetModeStatus(txt)
    pcall(function() ModeStatusPara:SetDesc(tostring(txt)) end)
end

ModeTab:Dropdown({
    Title = "Chọn Raid Boss",
    Values = RAID_BOSSES,
    Value = Cfg.RaidSelect or "Attack Titan",
    Callback = function(v) Cfg.RaidSelect = v Save() end
})

ModeTab:Dropdown({
    Title = "Độ khó Raid",
    Values = RAID_DIFFS,
    Value = Cfg.RaidLevel or "Hard",
    Callback = function(v) Cfg.RaidLevel = v Save() end
})

ModeTab:Toggle({
    Title = "Auto Create Raid",
    Value = Cfg.AutoCreateRaid or false,
    Callback = function(v)
        Cfg.AutoCreateRaid = v
        if v then Cfg.AutoCreateMission = false Cfg.AutoCreateWave = false end
        Save()
    end
})

ModeTab:Toggle({
    Title = "Auto Start Raid",
    Value = Cfg.AutoStartRaid or false,
    Callback = function(v)
        Cfg.AutoStartRaid = v
        if v then Cfg.AutoStartMission = false Cfg.AutoStartWave = false end
        Save()
    end
})

ModeTab:Toggle({
    Title = "Wait For Boss Spawn",
    Desc = "Đợi Boss tải xong Hitbox rồi mới bay vào đánh",
    Value = Cfg.WaitForBoss or false,
    Callback = function(v) Cfg.WaitForBoss = v Save() end
})

ModeTab:Dropdown({
    Title = "Chọn Bản Đồ Wave",
    Values = WAVE_MAPS,
    Value = Cfg.WaveSelect or "Trost",
    Callback = function(v) Cfg.WaveSelect = v Save() end
})

ModeTab:Toggle({
    Title = "Auto Create Wave",
    Value = Cfg.AutoCreateWave or false,
    Callback = function(v)
        Cfg.AutoCreateWave = v
        if v then Cfg.AutoCreateMission = false Cfg.AutoCreateRaid = false end
        Save()
    end
})

ModeTab:Toggle({
    Title = "Auto Start Wave",
    Value = Cfg.AutoStartWave or false,
    Callback = function(v)
        Cfg.AutoStartWave = v
        if v then Cfg.AutoStartMission = false Cfg.AutoStartRaid = false end
        Save()
    end
})

ModeTab:Toggle({
    Title = "Auto Leave At Wave",
    Value = Cfg.AutoLeaveAtWave or false,
    Callback = function(v) Cfg.AutoLeaveAtWave = v Save() end
})

ModeTab:Slider({
    Title = "Mốc Wave tự thoát",
    Step = 1,
    Value = { Min = 1, Max = 50, Default = Cfg.LeaveAtWave or 10 },
    Callback = function(v) Cfg.LeaveAtWave = tonumber(v) or 10 Save() end
})

do
    local function MyRoom()
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

    task.spawn(function()
        while Alive() do
            task.wait(1.2)
            if IN_LOBBY and not SH.Coord.Blocker(100) then
                local r = GetLobbyRemote()
                local room = MyRoom()
                if r then
                    if Cfg.AutoCreateRaid and not room then
                        SetModeStatus("Đang tạo phòng Raid: " .. tostring(Cfg.RaidSelect))
                        local ok, res = pcall(function()
                            return r:InvokeServer("S_Missions", "Create", {
                                Difficulty = Cfg.RaidLevel or "Hard",
                                Type = "Raids",
                                Objective = "Raid",
                                Name = Cfg.RaidSelect or "Attack Titan",
                            })
                        end)
                        if ok and res then
                            SetModeStatus("Đã tạo phòng Raid thành công!")
                            task.wait(Cfg.RaidJoinDelay or 10)
                            if Cfg.AutoStartRaid then
                                pcall(function() r:InvokeServer("S_Missions", "Start") end)
                            end
                        end
                    elseif Cfg.AutoCreateWave and not room then
                        local diffKey = ((Cfg.WaveLevel or "Easy"):match("^(%S+)")) or "Easy"
                        SetModeStatus("Đang tạo phòng Wave: " .. tostring(Cfg.WaveSelect))
                        local ok, res = pcall(function()
                            return r:InvokeServer("S_Missions", "Create", {
                                Difficulty = diffKey,
                                Type = "Waves",
                                Objective = "Wave",
                                Name = Cfg.WaveSelect or "Trost",
                            })
                        end)
                        if ok and res then
                            SetModeStatus("Đã tạo phòng Wave thành công!")
                            task.wait(Cfg.WaveJoinDelay or 10)
                            if Cfg.AutoStartWave then
                                pcall(function() r:InvokeServer("S_Missions", "Start") end)
                            end
                        end
                    end
                end
            elseif Farm.CanUseHere() and Cfg.AutoLeaveAtWave then
                local waveNum = tonumber(workspace:GetAttribute("Wave")) or tonumber(LocalPlayer:GetAttribute("Wave"))
                if waveNum and waveNum >= (Cfg.LeaveAtWave or 10) then
                    local post = GetPostRemote()
                    if post then
                        SetModeStatus("Đã đạt Wave " .. waveNum .. " - Đang thoát về Lobby...")
                        pcall(function() post:FireServer("Functions", "Teleport") end)
                        task.wait(8)
                    end
                end
            end
        end
    end)
end
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    -- Đảm bảo Cfg và các cấu hình mặc định tồn tại để tránh lỗi nil value
    _G.Cfg = _G.Cfg or {
        DamageMultiplier = true,
        AttackSpeed = 2,
        AutoFarm = true,
        HitboxExpander = true,
        ExpansionSize = Vector3.new(500, 500, 500), -- Kích thước Hitbox siêu lớn
        FlyHeightOffset = 200 -- Độ cao bay cao hơn Titan 200 đơn vị
    }
    local Cfg = _G.Cfg

    -- Hàm kiểm tra trạng thái sống an toàn
    local function IsAlive()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        return hum and hum.Health > 0
    end

    local ATTACK_GAP = { [0] = 0.3, [1] = 0.6, [2] = 0.2, [3] = 0.15, [4] = 0.1, [5] = 0.05 }
    local ARRIVE_DIST = 12
    local ATTACK_BEFORE_ARRIVE = true
    local ORBIT_ON = true
    local ORBIT_RADIUS = 14
    local ORBIT_SPEED = 1.6
    local ORBIT_BOB = 5
    local HIT_COUNT = 20
    local DAMAGE_MULT = 10
    local OTHER_MULT = 10
    local PRIORITY = {}

    local MultState = { full = DAMAGE_MULT, other = OTHER_MULT }
    local function Mult() return Cfg.DamageMultiplier and MultState.full or 1 end
    local function OtherMult() return Cfg.DamageMultiplier and math.min(MultState.other, MultState.full) or 1 end

    -- Khởi tạo bảng Farm và trạng thái an toàn
    _G.Farm = _G.Farm or {}
    _G.Farm.Blades = _G.Farm.Blades or { Target = nil, Hits = 0, Status = "Idle" }
    local B = _G.Farm.Blades

    local post = nil
    local function Post()
        if not post or not post.Parent then
            local ok, r = pcall(function()
                return game:GetService("ReplicatedStorage"):WaitForChild("Assets", 5):WaitForChild("Remotes", 5):WaitForChild("POST", 5)
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
        local hb = titan and titan:FindFirstChild("Hitboxes")
        return hb and hb:FindFirstChild("Hit")
    end

    -- Hàm xử lý mở rộng Hitbox Nape để chém mượt mà từ trên cao xuống
    local function NapeOf(titan)
        local hit = HitParts(titan)
        local nape = hit and hit:FindFirstChild("Nape")
        if nape and nape:IsA("BasePart") then 
            if Cfg.HitboxExpander then
                nape.Size = Cfg.ExpansionSize
                nape.Transparency = 0.9 
                nape.CanCollide = false
            end
            return nape 
        end
        return nil
    end

    local function TitanAlive(titan)
        local hum = titan and titan.Parent and titan:FindFirstChildOfClass("Humanoid")
        return hum ~= nil and hum.Health > 0
    end

    local function NapesAround(main)
        local mainNape = NapeOf(main)
        if not mainNape then return {} end
        local cap = HIT_COUNT
        local folder = workspace:FindFirstChild("Titans")

        local others = {}
        for _, t in ipairs(folder and folder:GetChildren() or {}) do
            if t ~= main and t:IsA("Model") and TitanAlive(t) then
                local n = NapeOf(t)
                if n then
                    others[#others + 1] = { part = n, d = (n.Position - mainNape.Position).Magnitude }
                end
            end
        end
        table.sort(others, function(a, b) return a.d < b.d end)

        local list = {}
        PRIORITY = { [mainNape] = true }
        list[1] = mainNape
        for i = 1, math.min(cap - 1, #others) do
            list[#list + 1] = others[i].part
        end
        return list
    end

    local REMOTE_BUDGET = 300
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

    local NET_BATCH = 20
    local NET_QUEUE_MAX = 600
    local netQ, netHead, netTail = {}, 1, 0
    local function NetPending() return netTail - netHead + 1 end
    
    local function NetPush(remote, ...)
        if NetPending() >= NET_QUEUE_MAX then return end 
        netTail = netTail + 1
        netQ[netTail] = { remote = remote, args = table.pack(...) }
    end

    RunService.Heartbeat:Connect(function()
        local sent = 0
        while netHead <= netTail and sent < NET_BATCH do
            local it = netQ[netHead]
            netQ[netHead] = nil
            netHead = netHead + 1
            sent = sent + 1
            if it and it.remote and it.remote.Parent then
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
            for _, part in ipairs(parts) do
                if PRIORITY[part] or r <= OtherMult() then
                    NetPush(remote, "Hitboxes", "Register", part, 143 + math.random() * 10, 0.26 + math.random() * 0.25)
                end
            end
        end
        NetPush(remote, "Attacks", "Slash", false)
        B.Hits = B.Hits + #parts
        return true
    end

    -- Luồng tự động quét, bay cao hơn Titan 200 đơn vị và chém tự động liên tục
    task.spawn(function()
        while true do
            if IsAlive() then
                local speedIdx = Cfg.AttackSpeed or 2
                local gap = ATTACK_GAP[speedIdx] or 0.2
                task.wait(gap)
                
                local target = B.Target
                local root, char = MyRoot()
                
                if Cfg.AutoFarm and root then
                    if not target or not TitanAlive(target) then
                        local folder = workspace:FindFirstChild("Titans")
                        local closestTitan, minDist = nil, math.huge
                        for _, t in ipairs(folder and folder:GetChildren() or {}) do
                            if t:IsA("Model") and TitanAlive(t) then
                                local nape = NapeOf(t)
                                if nape then
                                    local dist = (root.Position - nape.Position).Magnitude
                                    if dist < minDist then
                                        minDist = dist
                                        closestTitan = t
                                    end
                                end
                            end
                        end
                        if closestTitan then
                            B.Target = closestTitan
                            target = closestTitan
                        end
                    end

                    if target and TitanAlive(target) then
                        local nape = NapeOf(target)
                        if nape then
                            -- Tự động điều chỉnh vị trí nhân vật bay cao hơn đỉnh của Titan (hoặc Nape) 200 đơn vị
                            local targetPos = nape.Position + Vector3.new(0, Cfg.FlyHeightOffset or 200, 0)
                            local hrp = char:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                -- Giữ khoảng cách bay ổn định phía trên
                                hrp.CFrame = CFrame.new(targetPos) * CFrame.Angles(0, math.rad(tick() * 50 % 360), 0) * CFrame.new(0, 0, 10)
                            end

                            local safeList = NapesAround(target)
                            if #safeList > 0 then
                                Slash(safeList)
                            end
                        end
                    end
                end
            else
                task.wait(1) 
            end
        end
    end)

    -- Cấu hình Slider độ cao offset so với Titan
    if FarmTab and type(FarmTab.Slider) == "function" then
        FarmTab:Slider({
            Title = "Bay cao hơn Titan (Offset Height)",
            Step = 10,
            Value = { Min = 50, Max = 400, Default = Cfg.FlyHeightOffset or 200 },
            Callback = function(v)
                Cfg.FlyHeightOffset = tonumber(v) or 200
                if typeof(Save) == "function" then Save() end
            end
        })
    end

Notify("Ryzen Hub - Loading successful", 5)
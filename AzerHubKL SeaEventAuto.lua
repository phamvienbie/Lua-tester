-- AutoCheckBoss.lua
-- Tự động kiểm tra Boss trong SeaEvents.lua có xuất hiện trong Workspace hay không.
-- Đặt cùng chỗ với SeaEvents.lua (ModuleScript) và sửa đường dẫn require bên dưới cho đúng.

-- ===== TỰ CHẠY KHI EXECUTE =====
if not game:IsLoaded() then game.Loaded:Wait() end

-- Chống chạy trùng nếu execute nhiều lần
local env = (getgenv and getgenv()) or _G
if env.AutoCheckBossRunning then
    warn("[AutoCheckBoss] Đã chạy rồi, bỏ qua lần execute này.")
    return
end
env.AutoCheckBossRunning = true

-- Tự tìm SeaEvents ở nhiều nơi: cạnh script, trong game, hoặc file trong workspace của executor
local function LoadSeaEvents()
    if script and script.Parent then
        local m = script.Parent:FindFirstChild("SeaEvents")
        if m then
            local ok, r = pcall(require, m)
            if ok then return r end
        end
    end
    for _, inst in ipairs(game:GetDescendants()) do
        if inst:IsA("ModuleScript") and inst.Name == "SeaEvents" then
            local ok, r = pcall(require, inst)
            if ok then return r end
        end
    end
    if readfile and loadstring then
        for _, path in ipairs({ "SeaEvents.lua", "SeaEvents" }) do
            local ok, src = pcall(readfile, path)
            if ok and src then
                local fn = loadstring(src)
                if fn then return fn() end
            end
        end
    end
    error("[AutoCheckBoss] Không tìm thấy SeaEvents.lua (đặt cạnh script, hoặc lưu vào thư mục workspace của executor).")
end

local SeaEvents = LoadSeaEvents()

-- ===== LOAD UI (KingLegacyUI) =====
-- UI đọc dữ liệu qua getgenv().SeaEvents nên gán trước khi load để dùng chung 1 nguồn dữ liệu
env.SeaEvents = SeaEvents
task.spawn(function()
    local ok, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/phamvienbie/Lua-tester/refs/heads/main/KingLegacyUI%20(3).lua"))()
    end)
    if not ok then
        warn("[AutoCheckBoss] Load UI lỗi: " .. tostring(err))
    end
end)

local Config = {
    CurrentSea = nil,       -- nil = tự nhận theo PlaceId; hoặc đặt tay 2 / 3
    CheckInterval = 3,      -- giây giữa mỗi lần quét
    OnlyBoss = true,        -- true: chỉ check Type có chữ "Boss"; false: check tất cả event
    AutoFly = true,         -- true: tự bay tới boss khi nó spawn
    FlySpeed = 150,         -- tốc độ bay (studs/giây), thấp hơn = ít bị phát hiện hơn
    HeightOffset = 30,      -- bay lơ lửng phía trên boss bao nhiêu studs
    AutoLock = true,        -- true: nhân vật luôn quay mặt về phía boss
    LockCamera = false,     -- true: camera cũng khoá nhìn vào boss

    -- ===== AUTO ĐÁNH =====
    AutoM1 = true,          -- true: tự đánh thường (M1)
    AutoSkill = true,       -- true: tự xài skill Z X C V
    AttackRange = 80,       -- chỉ đánh khi cách boss <= số studs này
    Weapons = { "Sword", "Blox Fruit" }, -- thứ tự đổi vũ khí (ToolTip): Sword, Blox Fruit, Melee, Gun
    WeaponTime = 2,         -- giây giữ mỗi vũ khí trước khi đổi sang cái kế
    SkillKeys = { Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V },
    SkillDelay = 0.25,      -- giây giữa mỗi phím skill

    -- ===== HOP SERVER =====
    AutoHop = true,         -- true: tự đổi server khi không có boss
    HopDelay = 15,          -- giây không thấy boss trước khi hop (nên >= 10 để quét kịp)
    HopMaxPlayers = 10,     -- chỉ vào server có số người <= số này (server vắng = ít người tranh boss)
    HopRetryDelay = 5,      -- giây chờ rồi thử lại nếu hop thất bại
    QueueScript = nil,      -- dán lệnh loadstring của script này vào đây để tự chạy lại sau khi hop,
                            -- ví dụ: 'loadstring(game:HttpGet("https://.../AutoCheckBoss.lua"))()'
                            -- (hoặc để script trong thư mục autoexec của executor)
}

local RunService = game:GetService("RunService")

local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = game:GetService("Players").LocalPlayer
if not LocalPlayer.Character then LocalPlayer.CharacterAdded:Wait() end
local currentTween

-- PlaceId của Blox Fruits (đổi nếu game của bạn khác)
local SEA_BY_PLACE = {
    [4442272183] = 2,
    [7449423635] = 3,
}

local function GetCurrentSea()
    return Config.CurrentSea or SEA_BY_PLACE[game.PlaceId]
end

local function IsBoss(eventData)
    return string.find(eventData.Type, "Boss") ~= nil
end

local function IsAlive(inst)
    if not inst or not inst.Parent then return false end
    local hum = inst:FindFirstChildOfClass("Humanoid")
    return hum == nil or hum.Health > 0
end

local function Notify(text)
    print("[AutoCheckBoss] " .. text)
end
Notify("Đã khởi động: Auto Check Boss + Fly + Lock + M1 + Skill ZXCV")

local active = {} -- [WorkspaceName] = Instance đang xuất hiện

local function GetTargetPart(inst)
    if inst:IsA("BasePart") then return inst end
    if inst:IsA("Model") then
        return inst.PrimaryPart
            or inst:FindFirstChild("HumanoidRootPart")
            or inst:FindFirstChildWhichIsA("BasePart", true)
    end
end

local function StopFly()
    if currentTween then
        currentTween:Cancel()
        currentTween = nil
    end
end

local function FlyTo(inst)
    local char = LocalPlayer and LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local part = GetTargetPart(inst)
    if not hrp or not part then return end

    local destPos = part.Position + Vector3.new(0, Config.HeightOffset, 0)
    -- quay mặt về phía boss (giữ thẳng đứng, không cúi/ngửa)
    local dest = CFrame.lookAt(destPos, Vector3.new(part.Position.X, destPos.Y, part.Position.Z))
    local dist = (hrp.Position - dest.Position).Magnitude
    if dist < 5 then return end

    StopFly()
    currentTween = TweenService:Create(
        hrp,
        TweenInfo.new(dist / Config.FlySpeed, Enum.EasingStyle.Linear),
        { CFrame = dest }
    )
    currentTween:Play()
end

local function GetNearestActive()
    local char = LocalPlayer and LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local best, bestDist
    for _, inst in pairs(active) do
        local part = GetTargetPart(inst)
        if part then
            local d = (hrp.Position - part.Position).Magnitude
            if not bestDist or d < bestDist then
                best, bestDist = inst, d
            end
        end
    end
    return best
end

local function Scan(list)
    for _, ev in ipairs(list) do
        if not Config.OnlyBoss or IsBoss(ev) then
            local found = workspace:FindFirstChild(ev.WorkspaceName, true)
            local alive = IsAlive(found)

            if alive and not active[ev.WorkspaceName] then
                active[ev.WorkspaceName] = found
                Notify(("%s ĐÃ XUẤT HIỆN | Drops: %s"):format(ev.Name, table.concat(ev.Drops, ", ")))
            elseif not alive and active[ev.WorkspaceName] then
                active[ev.WorkspaceName] = nil
                Notify(ev.Name .. " đã biến mất / bị hạ")
            end
        end
    end
end

-- Auto Lock: mỗi frame quay mặt nhân vật (và camera nếu bật) về phía boss
RunService.RenderStepped:Connect(function()
    if not Config.AutoLock then return end

    local target = GetNearestActive()
    local part = target and GetTargetPart(target)
    local char = LocalPlayer and LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not part or not hrp then return end

    -- Khi đang tween thì hướng đã được xử lý trong FlyTo, tránh giành quyền với tween
    local tweening = currentTween and currentTween.PlaybackState == Enum.PlaybackState.Playing
    if not tweening then
        local look = Vector3.new(part.Position.X, hrp.Position.Y, part.Position.Z)
        if (look - hrp.Position).Magnitude > 0.1 then
            hrp.CFrame = CFrame.lookAt(hrp.Position, look)
        end
    end

    if Config.LockCamera then
        local cam = workspace.CurrentCamera
        if cam then
            cam.CFrame = CFrame.lookAt(cam.CFrame.Position, part.Position)
        end
    end
end)

task.spawn(function()
    while true do
        local sea = GetCurrentSea()
        local list = (sea == 2 and SeaEvents.Sea2) or (sea == 3 and SeaEvents.Sea3)
        if list then
            Scan(list)
            if Config.AutoFly then
                local target = GetNearestActive()
                if target then
                    FlyTo(target)
                else
                    StopFly()
                end
            end
        end
        task.wait(Config.CheckInterval)
    end
end)

-- ===== AUTO M1 + SKILL (Kiếm & Fruit) =====
local function GetTool(tip)
    local char = LocalPlayer.Character
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    for _, container in ipairs({ char, bp }) do
        if container then
            for _, t in ipairs(container:GetChildren()) do
                if t:IsA("Tool") and t.ToolTip == tip then
                    return t
                end
            end
        end
    end
end

local function EquipWeapon(tip)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local tool = GetTool(tip)
    if not hum or not tool then return nil end
    if tool.Parent ~= char then
        hum:EquipTool(tool)
    end
    return tool
end

local function PressKey(key)
    VirtualInputManager:SendKeyEvent(true, key, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, key, false, game)
end

local function ClickM1()
    VirtualUser:CaptureController()
    VirtualUser:Button1Down(Vector2.new(1280, 672))
    task.wait(0.05)
    VirtualUser:Button1Up(Vector2.new(1280, 672))
end

local function InRange(target)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local part = target and GetTargetPart(target)
    if not hrp or not part then return false end
    return (hrp.Position - part.Position).Magnitude <= Config.AttackRange
end

task.spawn(function()
    while true do
        local target = GetNearestActive()
        if target and InRange(target) and (Config.AutoM1 or Config.AutoSkill) then
            for _, tip in ipairs(Config.Weapons) do
                if not IsAlive(target) then break end
                if EquipWeapon(tip) then
                    local untilT = tick() + Config.WeaponTime
                    while tick() < untilT and IsAlive(target) and InRange(target) do
                        if Config.AutoM1 then
                            ClickM1()
                        end
                        if Config.AutoSkill then
                            for _, key in ipairs(Config.SkillKeys) do
                                PressKey(key)
                                task.wait(Config.SkillDelay)
                            end
                        end
                        task.wait()
                    end
                end
            end
        else
            task.wait(0.2)
        end
    end
end)

-- ===== HOP SERVER KHI KHÔNG CÓ BOSS =====
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VISITED_FILE = "AutoCheckBoss_Visited.json"
local hopping = false

local function LoadVisited()
    local list = {}
    if isfile and readfile and isfile(VISITED_FILE) then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(VISITED_FILE))
        end)
        if ok and type(data) == "table" then
            -- chỉ nhớ server trong 30 phút gần nhất
            for id, t in pairs(data) do
                if os.time() - t < 1800 then list[id] = t end
            end
        end
    end
    list[game.JobId] = os.time()
    return list
end

local visited = LoadVisited()

local function SaveVisited()
    if writefile then
        pcall(writefile, VISITED_FILE, HttpService:JSONEncode(visited))
    end
end
SaveVisited()

local function FindServer()
    local cursor = ""
    for _ = 1, 5 do -- tối đa 5 trang x 100 server
        local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s")
            :format(game.PlaceId, cursor ~= "" and ("&cursor=" .. cursor) or "")
        local ok, body = pcall(function() return game:HttpGet(url) end)
        if not ok then return nil, "rate" end
        local ok2, data = pcall(function() return HttpService:JSONDecode(body) end)
        if not ok2 or type(data) ~= "table" or not data.data then return nil, "rate" end

        local candidates = {}
        for _, sv in ipairs(data.data) do
            if sv.id ~= game.JobId
                and not visited[sv.id]
                and sv.playing and sv.maxPlayers
                and sv.playing <= Config.HopMaxPlayers
                and sv.playing < sv.maxPlayers then
                table.insert(candidates, sv.id)
            end
        end
        if #candidates > 0 then
            return candidates[math.random(1, #candidates)]
        end
        if not data.nextPageCursor then break end
        cursor = data.nextPageCursor
    end
    return nil, "none"
end

TeleportService.TeleportInitFailed:Connect(function(_, result, msg)
    Notify("Hop thất bại: " .. tostring(result) .. " " .. tostring(msg))
    hopping = false
end)

local function HopServer()
    if hopping then return end
    hopping = true

    local id, reason = FindServer()
    if not id then
        Notify(reason == "rate" and "API bị giới hạn, thử lại sau..." or "Không tìm thấy server phù hợp, thử lại sau...")
        task.wait(Config.HopRetryDelay)
        hopping = false
        return
    end

    visited[id] = os.time()
    SaveVisited()

    if Config.QueueScript and queue_on_teleport then
        pcall(queue_on_teleport, Config.QueueScript)
    end

    Notify("Không có boss -> đang hop sang server " .. id)
    local ok, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, id, LocalPlayer)
    end)
    if not ok then
        Notify("Teleport lỗi: " .. tostring(err))
        task.wait(Config.HopRetryDelay)
        hopping = false
    end
    -- nếu teleport thành công thì client sẽ bị chuyển server, hopping giữ nguyên true
end

task.spawn(function()
    local noBossSince = tick()
    while true do
        task.wait(1)
        if Config.AutoHop and GetCurrentSea() then
            if next(active) ~= nil then
                noBossSince = tick()        -- có boss: reset bộ đếm
            elseif not hopping and tick() - noBossSince >= Config.HopDelay then
                HopServer()
                noBossSince = tick()        -- tính lại để không spam khi hop thất bại
            end
        else
            noBossSince = tick()
        end
    end
end)

-- Hàm dùng ngoài file: trả về danh sách boss đang có
return {
    GetActive = function()
        local result = {}
        for name, inst in pairs(active) do
            if IsAlive(inst) then
                result[name] = inst
            end
        end
        return result
    end,
}

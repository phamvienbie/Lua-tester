--[[
    Ryzen Config V4.6 - Beta Tester
    Giao diện Roblox (Lua): đen + xanh RGB, Dynamic Island, toggle kiểu iOS
    Chỉ là UI, không có chức năng. Muốn gắn chức năng thì thay hàm none trong các addToggle
]]

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")
local Stats        = game:GetService("Stats")
local lp           = Players.LocalPlayer

---------------------------------------------------------------- GUI gốc
local NAME = "RyzenConfigV46"
local host = (gethui and gethui()) or nil
if not host then
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    host = ok and cg or lp:WaitForChild("PlayerGui")
end
if host:FindFirstChild(NAME) then host[NAME]:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = NAME
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = host

---------------------------------------------------------------- Theme
local BG    = Color3.fromRGB(4, 7, 14)
local CARD  = Color3.fromRGB(10, 17, 32)
local LINE  = Color3.fromRGB(18, 48, 80)
local TEXT  = Color3.fromRGB(232, 241, 255)
local MUTE  = Color3.fromRGB(127, 147, 179)
local BLUE  = Color3.fromRGB(0, 150, 255)
local CYAN  = Color3.fromRGB(0, 225, 255)
local GREEN = Color3.fromRGB(34, 230, 160)

local RGB = ColorSequence.new({
    ColorSequenceKeypoint.new(0,    Color3.fromRGB(0, 87, 255)),
    ColorSequenceKeypoint.new(0.35, Color3.fromRGB(0, 225, 255)),
    ColorSequenceKeypoint.new(0.7,  Color3.fromRGB(110, 90, 255)),
    ColorSequenceKeypoint.new(1,    Color3.fromRGB(0, 87, 255)),
})

---------------------------------------------------------------- Helper
local spinners = {}

local function mk(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    o.Parent = parent
    return o
end

local function corner(o, r)
    return mk("UICorner", { CornerRadius = UDim.new(0, r) }, o)
end

local function rgbStroke(o, th)
    local s = mk("UIStroke", {
        Thickness = th,
        Color = Color3.new(1, 1, 1),
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, o)
    local g = mk("UIGradient", { Color = RGB }, s)
    table.insert(spinners, g)
    return s, g
end

local function text(parent, str, size, pos, sz, color, font, align)
    return mk("TextLabel", {
        BackgroundTransparency = 1,
        Text = str,
        TextSize = size,
        Position = pos,
        Size = sz,
        TextColor3 = color or TEXT,
        Font = font or Enum.Font.GothamMedium,
        TextXAlignment = align or Enum.TextXAlignment.Left,
    }, parent)
end

local function tween(o, t, props, style)
    TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end

---------------------------------------------------------------- Dynamic Island
local island = mk("Frame", {
    Name = "Island",
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 8),
    Size = UDim2.fromOffset(120, 32),
    BackgroundColor3 = Color3.new(0, 0, 0),
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 50,
}, gui)
corner(island, 16).CornerRadius = UDim.new(1, 0)
rgbStroke(island, 1.2)

local islandDot = mk("Frame", {
    AnchorPoint = Vector2.new(0, 0.5),
    Position = UDim2.new(0, 12, 0.5, 0),
    Size = UDim2.fromOffset(8, 8),
    BackgroundColor3 = CYAN,
    BorderSizePixel = 0,
    ZIndex = 51,
}, island)
corner(islandDot, 4).CornerRadius = UDim.new(1, 0)

local islandLabel = text(island, "Ryzen V4.6", 13, UDim2.new(0, 28, 0, 0), UDim2.new(1, -40, 1, 0),
    TEXT, Enum.Font.GothamBold)
islandLabel.ZIndex = 51
islandLabel.TextTruncate = Enum.TextTruncate.AtEnd

local islandToken = 0
local function notify(msg)
    islandToken += 1
    local my = islandToken
    islandLabel.Text = msg
    tween(island, 0.5, { Size = UDim2.fromOffset(300, 54) }, Enum.EasingStyle.Back)
    tween(islandDot, 0.3, { Size = UDim2.fromOffset(12, 12) })
    task.delay(2.4, function()
        if my ~= islandToken then return end
        tween(island, 0.4, { Size = UDim2.fromOffset(120, 32) })
        tween(islandDot, 0.3, { Size = UDim2.fromOffset(8, 8) })
        islandLabel.Text = "Ryzen V4.6"
    end)
end

---------------------------------------------------------------- Khung chính
local main = mk("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(460, 498),
    BackgroundColor3 = BG,
    BorderSizePixel = 0,
    ClipsDescendants = true,
}, gui)
corner(main, 20)
rgbStroke(main, 2)

-- nền hiệu ứng: 2 quầng sáng xanh trôi chậm
local glowA = mk("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.15, 0.1),
    Size = UDim2.fromOffset(300, 300), BackgroundColor3 = Color3.fromRGB(0, 90, 255),
    BackgroundTransparency = 0.82, BorderSizePixel = 0,
}, main)
corner(glowA, 150)
local glowB = mk("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.9, 0.85),
    Size = UDim2.fromOffset(260, 260), BackgroundColor3 = Color3.fromRGB(0, 210, 255),
    BackgroundTransparency = 0.86, BorderSizePixel = 0,
}, main)
corner(glowB, 130)

---------------------------------------------------------------- Header
local header = mk("Frame", {
    Size = UDim2.fromOffset(460, 90), BackgroundTransparency = 1,
}, main)

-- avatar vuông bo góc + viền RGB xoay
local avFrame = mk("Frame", {
    Position = UDim2.fromOffset(14, 13), Size = UDim2.fromOffset(66, 66),
    BackgroundColor3 = CARD, BorderSizePixel = 0,
}, header)
corner(avFrame, 16)
rgbStroke(avFrame, 2.5)

local avImg = mk("ImageLabel", {
    Position = UDim2.fromOffset(3, 3), Size = UDim2.new(1, -6, 1, -6),
    BackgroundColor3 = Color3.fromRGB(8, 20, 40), BorderSizePixel = 0, Image = "",
}, avFrame)
corner(avImg, 13)
task.spawn(function()
    local ok, img = pcall(function()
        return Players:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    end)
    if ok then avImg.Image = img end
end)

local online = mk("Frame", {
    AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, 4, 1, 4),
    Size = UDim2.fromOffset(16, 16), BackgroundColor3 = GREEN, BorderSizePixel = 0, ZIndex = 5,
}, avFrame)
corner(online, 8)
mk("UIStroke", { Thickness = 3, Color = BG }, online)

-- tên chữ RGB xanh biển
local title = text(header, "Ryzen Config V4.6 - Beta Tester", 19, UDim2.fromOffset(94, 16), UDim2.fromOffset(250, 26),
    Color3.new(1, 1, 1), Enum.Font.GothamBlack)
local titleGrad = mk("UIGradient", { Color = RGB }, title)
local sub = text(header, lp.DisplayName .. "  •  Đang hoạt động", 13, UDim2.fromOffset(94, 46), UDim2.fromOffset(250, 18), MUTE)

-- nút chuông
local bell = mk("TextButton", {
    Position = UDim2.fromOffset(358, 22), Size = UDim2.fromOffset(40, 40),
    BackgroundColor3 = CARD, Text = "🔔", TextSize = 18, AutoButtonColor = false,
}, header)
corner(bell, 12)
mk("UIStroke", { Thickness = 1, Color = LINE }, bell)
local badge = mk("TextLabel", {
    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -2, 0, 2),
    Size = UDim2.fromOffset(18, 18), BackgroundColor3 = Color3.fromRGB(255, 59, 92),
    Text = "3", TextColor3 = Color3.new(1, 1, 1), TextSize = 11, Font = Enum.Font.GothamBold, ZIndex = 6,
}, bell)
corner(badge, 9)

-- nút thu nhỏ
local mini = mk("TextButton", {
    Position = UDim2.fromOffset(406, 22), Size = UDim2.fromOffset(40, 40),
    BackgroundColor3 = CARD, Text = "–", TextSize = 22, TextColor3 = CYAN,
    Font = Enum.Font.GothamBold, AutoButtonColor = false,
}, header)
corner(mini, 12)
mk("UIStroke", { Thickness = 1, Color = LINE }, mini)

---------------------------------------------------------------- Ô chỉ số (Level / Ping / FPS)
local function statCard(x, label)
    local c = mk("Frame", {
        Position = UDim2.fromOffset(x, 98), Size = UDim2.fromOffset(138, 56),
        BackgroundColor3 = CARD, BorderSizePixel = 0,
    }, main)
    corner(c, 14)
    mk("UIStroke", { Thickness = 1, Color = LINE }, c)
    text(c, label, 12, UDim2.fromOffset(0, 6), UDim2.new(1, 0, 0, 14), MUTE, Enum.Font.Gotham, Enum.TextXAlignment.Center)
    return text(c, "--", 22, UDim2.fromOffset(0, 22), UDim2.new(1, 0, 0, 28), CYAN, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
end
local lvlVal  = statCard(14,  "Level")
local pingVal = statCard(161, "Ping (ms)")
local fpsVal  = statCard(308, "FPS")

---------------------------------------------------------------- Biểu đồ FPS
local graph = mk("Frame", {
    Position = UDim2.fromOffset(14, 162), Size = UDim2.fromOffset(432, 112),
    BackgroundColor3 = CARD, BorderSizePixel = 0,
}, main)
corner(graph, 14)
mk("UIStroke", { Thickness = 1, Color = LINE }, graph)
text(graph, "Biểu đồ FPS", 14, UDim2.fromOffset(12, 8), UDim2.fromOffset(150, 18), Color3.fromRGB(143, 208, 255), Enum.Font.GothamBold)
local fpsBig = text(graph, "0", 22, UDim2.new(1, -112, 0, 4), UDim2.fromOffset(100, 26), CYAN, Enum.Font.GothamBlack, Enum.TextXAlignment.Right)

local N = 32
local barArea = mk("Frame", {
    Position = UDim2.fromOffset(12, 36), Size = UDim2.new(1, -24, 1, -46), BackgroundTransparency = 1,
}, graph)
local bars, history = {}, {}
for i = 1, N do
    history[i] = 60
    local b = mk("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new((i - 1) / N, 1, 1, 0),
        Size = UDim2.new(1 / N, -2, 0.4, 0),
        BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
    }, barArea)
    corner(b, 3)
    mk("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new(CYAN, Color3.fromRGB(0, 70, 255)),
    }, b)
    bars[i] = b
end

---------------------------------------------------------------- Chọn Sea
local selectedSea = 1
local seaBtns = {}
for i = 1, 3 do
    local b = mk("TextButton", {
        Position = UDim2.fromOffset(14 + (i - 1) * 147, 282), Size = UDim2.fromOffset(138, 42),
        BackgroundColor3 = CARD, Text = "Sea " .. i, TextSize = 16, TextColor3 = TEXT,
        Font = Enum.Font.GothamBold, AutoButtonColor = false,
    }, main)
    corner(b, 12)
    local st = mk("UIStroke", { Thickness = 1.5, Color = LINE }, b)
    seaBtns[i] = { btn = b, stroke = st }
    b.Activated:Connect(function()
        selectedSea = i
        for j, s in ipairs(seaBtns) do
            local on = (j == i)
            tween(s.btn, 0.25, { BackgroundColor3 = on and Color3.fromRGB(8, 32, 63) or CARD })
            tween(s.stroke, 0.25, { Color = on and CYAN or LINE })
            s.btn.TextColor3 = on and CYAN or TEXT
        end
        notify("Đã chọn Sea " .. i)
        -- CODE CỦA BẠN: chạy khi đổi Sea (dùng biến selectedSea)
    end)
end
-- Nhận diện Sea hiện tại theo PlaceId
local World1 = game.PlaceId == 2753915549 or game.PlaceId == 85211729168715
local World2 = game.PlaceId == 4442272183 or game.PlaceId == 79091703265657
local World3 = game.PlaceId == 7449423635 or game.PlaceId == 100117331123089

local currentSea = (World1 and 1) or (World2 and 2) or (World3 and 3) or 1
selectedSea = currentSea
for j, s in ipairs(seaBtns) do
    local on = (j == currentSea)
    s.btn.BackgroundColor3 = on and Color3.fromRGB(8, 32, 63) or CARD
    s.stroke.Color = on and CYAN or LINE
    s.btn.TextColor3 = on and CYAN or TEXT
end
seaBtns[currentSea].btn.Text = "Sea " .. currentSea .. " ●"
sub.Text = lp.DisplayName .. "  •  Đang ở Sea " .. currentSea

---------------------------------------------------------------- Toggle kiểu iOS
local function addToggle(name, x, y, callback)
    local card = mk("Frame", {
        Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(212, 38),
        BackgroundColor3 = CARD, BorderSizePixel = 0,
    }, main)
    corner(card, 12)
    mk("UIStroke", { Thickness = 1, Color = LINE }, card)
    text(card, name, 14, UDim2.fromOffset(12, 0), UDim2.new(1, -70, 1, 0), TEXT, Enum.Font.GothamMedium)

    local sw = mk("Frame", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(44, 24), BackgroundColor3 = Color3.fromRGB(40, 48, 66), BorderSizePixel = 0,
    }, card)
    corner(sw, 12)
    local knob = mk("Frame", {
        Position = UDim2.fromOffset(2, 2), Size = UDim2.fromOffset(20, 20),
        BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
    }, sw)
    corner(knob, 10)

    local hit = mk("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "" }, card)
    local on = false
    hit.Activated:Connect(function()
        on = not on
        tween(sw, 0.25, { BackgroundColor3 = on and BLUE or Color3.fromRGB(40, 48, 66) })
        tween(knob, 0.3, { Position = on and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2) }, Enum.EasingStyle.Back)
        notify(name .. "  •  " .. (on and "BẬT" or "TẮT"))
        task.spawn(callback, on)
    end)
end

---------------------------------------------------------------- Nút gạt (chỉ là UI, không có chức năng)
local function none() end

addToggle("Auto Farm",   14,  332, none)
addToggle("Auto Skill",  234, 332, none)
addToggle("FPS Boost",   14,  374, none)
addToggle("Anti AFK",    234, 374, none)
addToggle("Fullbright",  14,  416, none)
addToggle("Auto Stats",  234, 416, none)

---------------------------------------------------------------- Dòng thông báo chạy ngang
local tick = mk("Frame", {
    Position = UDim2.fromOffset(14, 460), Size = UDim2.fromOffset(432, 28),
    BackgroundColor3 = CARD, BorderSizePixel = 0, ClipsDescendants = true,
}, main)
corner(tick, 10)
mk("UIStroke", { Thickness = 1, Color = LINE }, tick)
local marquee = text(tick,
    "★ Chào mừng đến Ryzen Config V4.6 Beta   •   Cấu hình mới giúp FPS ổn định hơn   •   Báo lỗi cho nhóm Beta Tester để nhận bản cập nhật sớm   •   Chúc bạn chơi vui!",
    14, UDim2.fromOffset(432, 0), UDim2.fromOffset(900, 28), Color3.fromRGB(111, 196, 255), Enum.Font.GothamMedium)
marquee.TextWrapped = false
local mx = 432

---------------------------------------------------------------- Danh sách thông báo (bấm chuông)
local panel = mk("Frame", {
    Position = UDim2.fromOffset(14, 70), Size = UDim2.fromOffset(432, 132),
    BackgroundColor3 = Color3.fromRGB(6, 12, 24), BorderSizePixel = 0, Visible = false, ZIndex = 20,
}, main)
corner(panel, 14)
rgbStroke(panel, 1.5)
mk("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, panel)
mk("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, panel)
for _, msg in ipairs({
    "Cấu hình V4.6 đã cập nhật  •  Vừa xong",
    "Sea 2 đã tối ưu xong  •  5 phút trước",
    "Ping ổn định dưới 30ms  •  12 phút trước",
}) do
    local n = text(panel, "  " .. msg, 13, UDim2.new(), UDim2.new(1, 0, 0, 34), Color3.fromRGB(207, 227, 255))
    n.BackgroundTransparency = 0
    n.BackgroundColor3 = Color3.fromRGB(11, 24, 48)
    n.ZIndex = 21
    corner(n, 10)
end

bell.Activated:Connect(function()
    panel.Visible = not panel.Visible
    if panel.Visible then badge.Visible = false end
end)

---------------------------------------------------------------- Thu nhỏ / mở rộng
local minimized = false
mini.Activated:Connect(function()
    minimized = not minimized
    panel.Visible = false
    tween(main, 0.4, { Size = UDim2.fromOffset(460, minimized and 90 or 498) }, Enum.EasingStyle.Back)
    mini.Text = minimized and "+" or "–"
end)

-- RightControl: ẩn / hiện toàn bộ giao diện
UIS.InputBegan:Connect(function(i, gp)
    if not gp and i.KeyCode == Enum.KeyCode.RightControl then
        main.Visible = not main.Visible
    end
end)

---------------------------------------------------------------- Kéo di chuyển (kéo ở phần header)
local dragging, dragStart, startPos
header.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging, dragStart, startPos = true, i.Position, main.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

---------------------------------------------------------------- Dữ liệu FPS / Ping / Level
local frames, acc = 0, 0
RunService.RenderStepped:Connect(function(dt)
    frames += 1
    acc += dt
    if acc >= 0.5 then
        local fps = math.floor(frames / acc + 0.5)
        frames, acc = 0, 0
        table.remove(history, 1)
        table.insert(history, fps)
        fpsVal.Text, fpsBig.Text = tostring(fps), tostring(fps)
        for i, b in ipairs(bars) do
            local h = math.clamp(history[i] / 144, 0.05, 1)
            tween(b, 0.4, { Size = UDim2.new(1 / N, -2, h, 0) })
        end
    end
end)

task.spawn(function()
    while gui.Parent do
        local ok, ping = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
        pingVal.Text = ok and tostring(math.floor(ping)) or "--"
        local ls = lp:FindFirstChild("leaderstats")
        local lv = ls and (ls:FindFirstChild("Level") or ls:FindFirstChild("Lvl"))
        lvlVal.Text = lv and tostring(lv.Value) or "1"
        task.wait(1)
    end
end)

---------------------------------------------------------------- Hiệu ứng RGB (viền, chữ, nền, chữ chạy)
local t = 0
RunService.Heartbeat:Connect(function(dt)
    t += dt
    for _, g in ipairs(spinners) do g.Rotation = (t * 80) % 360 end
    titleGrad.Offset = Vector2.new(math.sin(t * 1.4) * 0.6, 0)
    glowA.Position = UDim2.fromScale(0.15 + math.sin(t * 0.5) * 0.08, 0.1 + math.cos(t * 0.4) * 0.06)
    glowB.Position = UDim2.fromScale(0.9 + math.cos(t * 0.45) * 0.08, 0.85 + math.sin(t * 0.5) * 0.06)
    mx -= 70 * dt
    if mx < -marquee.TextBounds.X then mx = 432 end
    marquee.Position = UDim2.fromOffset(mx, 0)
end)

task.delay(0.6, function() notify("Ryzen Config V4.6 đã sẵn sàng") end)

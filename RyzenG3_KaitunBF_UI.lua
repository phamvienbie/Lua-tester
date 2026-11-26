--// Ryzen G3 - KaitunBF | UI (Black & White)
--// Loading + Notify bên phải + Status + Info + Dynamic Island (Ping/FPS/CPU, Farm toggle) + Snow

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

--================ CONFIG ================--
local Config = {
    Title = "Ryzen G3 - KaitunBF",
    Tag = "Kaitun Config Banana",
    UpdateDelay = 2,
    ReportEvery = 300, -- giây: gửi thông báo báo cáo Farm định kỳ
}

--================ GUI PARENT ================--
local function getParent()
    local ok, ui = pcall(function()
        return (gethui and gethui()) or game:GetService("CoreGui")
    end)
    if ok and ui then return ui end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local old = getParent():FindFirstChild("RyzenG3_KaitunBF")
if old then old:Destroy() end

local Gui = Instance.new("ScreenGui")
Gui.Name = "RyzenG3_KaitunBF"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = getParent()

--================ THEME ================--
local C = {
    BG = Color3.fromRGB(10, 10, 10),
    Panel = Color3.fromRGB(20, 20, 20),
    Stroke = Color3.fromRGB(55, 55, 55),
    White = Color3.fromRGB(255, 255, 255),
    Gray = Color3.fromRGB(150, 150, 150),
    Off = Color3.fromRGB(70, 70, 70),
    Green = Color3.fromRGB(70, 220, 110),
    Red = Color3.fromRGB(235, 70, 70),
}

local function corner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = obj
    return c
end

local function stroke(obj, color, t)
    local s = Instance.new("UIStroke")
    s.Color = color or C.Stroke
    s.Thickness = t or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = obj
    return s
end

local function label(parent, text, size, color, font, xAlign)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextSize = size or 14
    l.TextColor3 = color or C.White
    l.Font = font or Enum.Font.GothamMedium
    l.TextXAlignment = xAlign or Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

local function tween(obj, t, props, style, dir)
    local tw = TweenService:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

local function formatNumber(n)
    n = tonumber(n) or 0
    local s = tostring(math.floor(n))
    local formatted = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    return (formatted:gsub("^,", ""))
end

--================ ICON TỰ VẼ (bằng Frame, không dùng asset) ================--
local function part(parent, o)
    local f = Instance.new("Frame")
    f.AnchorPoint = Vector2.new(0.5, 0.5)
    f.Position = UDim2.new(0.5, o.x or 0, 0.5, o.y or 0)
    f.Size = UDim2.new(0, o.w, 0, o.h)
    f.Rotation = o.rot or 0
    f.BorderSizePixel = 0
    f.BackgroundColor3 = o.fill or C.White
    if o.outline then
        f.BackgroundTransparency = o.fill and 0 or 1
        stroke(f, C.White, o.t or 1.5)
    end
    if o.r then corner(f, o.r) end
    f.Parent = parent
    return f
end

local ICONS = {
    guitar = { {x=-3,y=3,w=10,h=10,r=5}, {x=3,y=-3,w=3,h=12,rot=45}, {x=7,y=-7,w=6,h=3,rot=45} },
    cdk = { {w=2,h=18,rot=45,r=1}, {w=2,h=18,rot=-45,r=1}, {x=-4,y=4,w=7,h=2,rot=45}, {x=4,y=4,w=7,h=2,rot=-45} },
    yama = { {w=3,h=18,rot=45,r=1}, {x=-4,y=4,w=8,h=2,rot=45} },
    tushita = { {w=4,h=18,rot=45,r=2,outline=true,t=1.3}, {x=-4,y=4,w=8,h=2,rot=45} },
    hat = { {x=0,y=-2,w=14,h=10,r=6}, {x=0,y=4,w=19,h=3,r=2}, {x=5,y=-7,w=2,h=6,rot=30,r=1} },
    mirror = { {w=13,h=17,r=3,outline=true}, {x=-1,y=-1,w=2,h=9,rot=35,r=1} },
    lever = { {x=0,y=6,w=14,h=4,r=2}, {x=3,y=0,w=2,h=13,rot=30,r=1}, {x=6,y=-7,w=6,h=6,r=3} },
    beli = { {w=16,h=16,r=8,outline=true}, {w=6,h=6,r=3} },
    level = { {x=-5,y=4,w=4,h=6,r=1}, {x=0,y=2,w=4,h=10,r=1}, {x=5,y=0,w=4,h=14,r=1} },
    fragment = { {w=11,h=11,rot=45,outline=true,r=1}, {w=4,h=4,rot=45} },
}

local function drawIcon(parent, kind, fillColor)
    local holder = Instance.new("Frame")
    holder.BackgroundTransparency = 1
    holder.Size = UDim2.new(0, 20, 0, 20)
    holder.Parent = parent
    if kind == "copy" then
        part(holder, {x=-2,y=-2,w=10,h=12,r=2,outline=true,t=1.3})
        part(holder, {x=2,y=2,w=10,h=12,r=2,outline=true,t=1.3,fill=fillColor or C.BG})
    else
        for _, o in ipairs(ICONS[kind] or {}) do part(holder, o) end
    end
    return holder
end

local function setIconColor(holder, color)
    for _, f in ipairs(holder:GetChildren()) do
        if f:IsA("Frame") then
            local st = f:FindFirstChildOfClass("UIStroke")
            if st then
                tween(st, 0.3, { Color = color })
            else
                tween(f, 0.3, { BackgroundColor3 = color })
            end
        end
    end
end

--================ HIỆU ỨNG TUYẾT ================--
local function makeSnow(parent, w, h, count, radius, isActive)
    local layer = Instance.new("CanvasGroup")
    layer.Name = "Snow"
    layer.BackgroundTransparency = 1
    layer.Size = UDim2.new(1, 0, 1, 0)
    layer.ZIndex = 30
    layer.Parent = parent
    corner(layer, radius or 12)

    local flakes = {}
    for i = 1, count do
        local big = (i % 4 == 0) -- 1/4 là bông tuyết 6 cánh, còn lại là hạt tuyết
        local size = big and math.random(9, 13) or math.random(2, 4)

        local f = Instance.new("Frame")
        f.BackgroundTransparency = 1
        f.BorderSizePixel = 0
        f.Size = UDim2.fromOffset(size, size)
        f.ZIndex = 30
        f.Parent = layer

        if big then
            for k = 0, 2 do
                local bar = Instance.new("Frame")
                bar.AnchorPoint = Vector2.new(0.5, 0.5)
                bar.Position = UDim2.new(0.5, 0, 0.5, 0)
                bar.Size = UDim2.new(0, 1, 1, 0)
                bar.Rotation = k * 60
                bar.BorderSizePixel = 0
                bar.BackgroundColor3 = C.White
                bar.BackgroundTransparency = 0.35
                bar.ZIndex = 30
                bar.Parent = f
            end
        else
            f.BackgroundColor3 = C.White
            f.BackgroundTransparency = 0.3 + math.random() * 0.4
            corner(f, size)
        end

        table.insert(flakes, {
            f = f,
            x = math.random(0, w),
            y = math.random(-20, h),
            vy = big and math.random(14, 28) or math.random(22, 55),
            amp = math.random(4, 14),
            freq = 0.6 + math.random() * 1.2,
            phase = math.random() * 6.28,
            spin = big and (math.random(-40, 40)) or nil,
        })
    end

    local conn
    conn = RunService.Heartbeat:Connect(function(dt)
        if not layer.Parent then conn:Disconnect() return end
        if isActive and not isActive() then return end
        dt = math.min(dt, 0.1)
        local t = os.clock()
        for _, d in ipairs(flakes) do
            d.y = d.y + d.vy * dt
            if d.y > h + 14 then
                d.y = -14
                d.x = math.random(0, w)
            end
            d.f.Position = UDim2.fromOffset(d.x + math.sin(t * d.freq + d.phase) * d.amp, d.y)
            if d.spin then d.f.Rotation = (d.f.Rotation + d.spin * dt) % 360 end
        end
    end)
    return layer
end

--================ LOG HUB ================--
local Logs = {}
local function Log(msg)
    table.insert(Logs, string.format("[%s] %s", os.date("%H:%M:%S"), msg))
    if #Logs > 300 then table.remove(Logs, 1) end
end

local function copyToClipboard(text)
    local fn = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set)
    if not fn then return false end
    return (pcall(fn, text))
end

--================ NOTIFY (hiện bên phải) ================--
local NotifyHolder = Instance.new("Frame")
NotifyHolder.BackgroundTransparency = 1
NotifyHolder.Size = UDim2.new(0, 230, 1, -20)
NotifyHolder.Position = UDim2.new(1, -10, 0, 10)
NotifyHolder.AnchorPoint = Vector2.new(1, 0)
NotifyHolder.ZIndex = 50
NotifyHolder.Parent = Gui

local NLayout = Instance.new("UIListLayout")
NLayout.Padding = UDim.new(0, 6)
NLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NLayout.SortOrder = Enum.SortOrder.LayoutOrder
NLayout.Parent = NotifyHolder

local function Notify(title, text, duration, color)
    duration = duration or 3

    local slot = Instance.new("Frame")
    slot.BackgroundTransparency = 1
    slot.Size = UDim2.new(1, 0, 0, 44)
    slot.Parent = NotifyHolder

    local box = Instance.new("Frame")
    box.Size = UDim2.new(1, 0, 1, 0)
    box.Position = UDim2.new(1.3, 0, 0, 0) -- ngoài màn hình bên phải
    box.BackgroundColor3 = C.BG
    box.Parent = slot
    corner(box, 8)
    stroke(box, color or C.White, 1)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 1, -14)
    bar.Position = UDim2.new(0, 7, 0, 7)
    bar.BackgroundColor3 = color or C.White
    bar.BorderSizePixel = 0
    bar.Parent = box
    corner(bar, 2)

    local t = label(box, title, 12, C.White, Enum.Font.GothamBold)
    t.Position = UDim2.new(0, 18, 0, 5)
    t.Size = UDim2.new(1, -24, 0, 16)

    local d = label(box, text, 11, C.Gray, Enum.Font.Gotham)
    d.Position = UDim2.new(0, 18, 0, 21)
    d.Size = UDim2.new(1, -24, 0, 16)
    d.TextTruncate = Enum.TextTruncate.AtEnd
    t.TextTruncate = Enum.TextTruncate.AtEnd

    tween(box, 0.45, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Back)

    task.delay(duration, function()
        tween(box, 0.4, { Position = UDim2.new(1.3, 0, 0, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In).Completed:Wait()
        slot:Destroy()
    end)
end

--================ MAIN UI ================--
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 650, 0, 320)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Color3.new(1, 1, 1)
Main.Visible = false
Main.Parent = Gui
corner(Main, 12)

local MainBG = Instance.new("UIGradient")
MainBG.Color = ColorSequence.new(Color3.fromRGB(24, 24, 24), Color3.fromRGB(5, 5, 5))
MainBG.Rotation = 90
MainBG.Parent = Main

-- viền sáng chạy vòng quanh
local MainStroke = stroke(Main, C.White, 1.5)
local MainGrad = Instance.new("UIGradient")
MainGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 45)),
    ColorSequenceKeypoint.new(0.5, C.White),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 45, 45)),
})
MainGrad.Parent = MainStroke

local Scale = Instance.new("UIScale")
Scale.Scale = 0.9
Scale.Parent = Main

makeSnow(Main, 650, 320, 34, 12, function() return Main.Visible end)

-- Kéo UI
do
    local dragging, dragStart, startPos
    Main.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, i.Position, Main.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 62)
Header.BackgroundTransparency = 1
Header.Parent = Main

-- Hàng tiêu đề: Tên Hub + Tag (tự co giãn, không đè nhau)
local TitleRow = Instance.new("Frame")
TitleRow.BackgroundTransparency = 1
TitleRow.Position = UDim2.new(0, 18, 0, 8)
TitleRow.Size = UDim2.new(0, 0, 0, 26)
TitleRow.AutomaticSize = Enum.AutomaticSize.X
TitleRow.Parent = Header

local TRLayout = Instance.new("UIListLayout")
TRLayout.FillDirection = Enum.FillDirection.Horizontal
TRLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TRLayout.SortOrder = Enum.SortOrder.LayoutOrder
TRLayout.Padding = UDim.new(0, 10)
TRLayout.Parent = TitleRow

local TitleLbl = label(TitleRow, Config.Title, 20, C.White, Enum.Font.GothamBold)
TitleLbl.LayoutOrder = 1
TitleLbl.AutomaticSize = Enum.AutomaticSize.X
TitleLbl.Size = UDim2.new(0, 0, 0, 24)

local TitleGrad = Instance.new("UIGradient")
TitleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 150, 150)),
    ColorSequenceKeypoint.new(0.5, C.White),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 150)),
})
TitleGrad.Parent = TitleLbl

local shimmerConn
shimmerConn = RunService.Heartbeat:Connect(function()
    if not Gui.Parent then shimmerConn:Disconnect() return end
    if not Main.Visible then return end
    local t = os.clock()
    MainGrad.Rotation = (t * 50) % 360
    TitleGrad.Offset = Vector2.new(math.sin(t * 1.5) * 0.7, 0)
end)

local Tag = Instance.new("Frame")
Tag.LayoutOrder = 2
Tag.BackgroundColor3 = C.White
Tag.AutomaticSize = Enum.AutomaticSize.X
Tag.Size = UDim2.new(0, 0, 0, 18)
Tag.Parent = TitleRow
corner(Tag, 9)

local TagPad = Instance.new("UIPadding")
TagPad.PaddingLeft = UDim.new(0, 10)
TagPad.PaddingRight = UDim.new(0, 10)
TagPad.Parent = Tag

local TagLbl = label(Tag, Config.Tag, 10, C.BG, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
TagLbl.AutomaticSize = Enum.AutomaticSize.X
TagLbl.Size = UDim2.new(0, 0, 1, 0)

-- Welcome
local Welcome = label(Header, "Welcome to  " .. LocalPlayer.Name, 13, C.Gray, Enum.Font.Gotham)
Welcome.Position = UDim2.new(0, 18, 0, 37)
Welcome.Size = UDim2.new(0.6, 0, 0, 16)

-- Avatar nhỏ góc phải
local AvatarFrame = Instance.new("Frame")
AvatarFrame.Size = UDim2.new(0, 38, 0, 38)
AvatarFrame.Position = UDim2.new(1, -90, 0, 12)
AvatarFrame.BackgroundColor3 = C.Panel
AvatarFrame.Parent = Header
corner(AvatarFrame, 19)
stroke(AvatarFrame, C.White, 1.5)

local Avatar = Instance.new("ImageLabel")
Avatar.Size = UDim2.new(1, 0, 1, 0)
Avatar.BackgroundTransparency = 1
Avatar.Parent = AvatarFrame
corner(Avatar, 19)

task.spawn(function()
    local ok, img = pcall(function()
        return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    end)
    if ok then Avatar.Image = img end
end)

-- Nút đóng UI
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = ""
CloseBtn.AutoButtonColor = false
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -46, 0, 16)
CloseBtn.BackgroundColor3 = C.Panel
CloseBtn.Parent = Header
corner(CloseBtn, 8)
local CloseStroke = stroke(CloseBtn, C.Stroke, 1)
part(CloseBtn, { w = 2, h = 14, rot = 45, r = 1 })
part(CloseBtn, { w = 2, h = 14, rot = -45, r = 1 })
CloseBtn.MouseEnter:Connect(function()
    tween(CloseBtn, 0.2, { BackgroundColor3 = C.Red })
    tween(CloseStroke, 0.2, { Color = C.Red })
end)
CloseBtn.MouseLeave:Connect(function()
    tween(CloseBtn, 0.2, { BackgroundColor3 = C.Panel })
    tween(CloseStroke, 0.2, { Color = C.Stroke })
end)

-- Nút Copy Log Hub
local CopyBtn = Instance.new("TextButton")
CopyBtn.Text = ""
CopyBtn.AutoButtonColor = false
CopyBtn.Size = UDim2.new(0, 104, 0, 26)
CopyBtn.Position = UDim2.new(1, -208, 0, 18)
CopyBtn.BackgroundColor3 = C.White
CopyBtn.Parent = Header
corner(CopyBtn, 8)

local CopyIcon = drawIcon(CopyBtn, "copy", C.White)
CopyIcon.Position = UDim2.new(0, 6, 0.5, -10)
setIconColor(CopyIcon, C.BG)

local CopyLbl = label(CopyBtn, "Copy Log", 11, C.BG, Enum.Font.GothamBold)
CopyLbl.Position = UDim2.new(0, 30, 0, 0)
CopyLbl.Size = UDim2.new(1, -34, 1, 0)

CopyBtn.MouseEnter:Connect(function() tween(CopyBtn, 0.2, { BackgroundColor3 = Color3.fromRGB(205, 205, 205) }) end)
CopyBtn.MouseLeave:Connect(function() tween(CopyBtn, 0.2, { BackgroundColor3 = C.White }) end)

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, -36, 0, 1)
Divider.Position = UDim2.new(0, 18, 0, 62)
Divider.BackgroundColor3 = C.Stroke
Divider.BorderSizePixel = 0
Divider.Parent = Main
local DivGrad = Instance.new("UIGradient")
DivGrad.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) })
DivGrad.Color = ColorSequence.new(C.White)
DivGrad.Parent = Divider

-- Panel helper
local function makePanel(titleText, pos, size)
    local p = Instance.new("Frame")
    p.Position = pos
    p.Size = size
    p.BackgroundColor3 = Color3.new(1, 1, 1)
    p.Parent = Main
    corner(p, 10)
    local pg = Instance.new("UIGradient")
    pg.Color = ColorSequence.new(Color3.fromRGB(30, 30, 30), Color3.fromRGB(14, 14, 14))
    pg.Rotation = 90
    pg.Parent = p
    stroke(p, C.Stroke, 1)

    local t = label(p, titleText, 13, C.White, Enum.Font.GothamBold)
    t.Position = UDim2.new(0, 14, 0, 10)
    t.Size = UDim2.new(1, -28, 0, 16)
    return p
end

--================ STATUS PANEL ================--
local StatusPanel = makePanel("STATUS", UDim2.new(0, 18, 0, 76), UDim2.new(0.58, -24, 1, -94))

local StatusList = Instance.new("Frame")
StatusList.BackgroundTransparency = 1
StatusList.Position = UDim2.new(0, 12, 0, 34)
StatusList.Size = UDim2.new(1, -24, 1, -42)
StatusList.Parent = StatusPanel

local SLayout = Instance.new("UIGridLayout")
SLayout.CellSize = UDim2.new(0.5, -4, 0, 28)
SLayout.CellPadding = UDim2.new(0, 8, 0, 6)
SLayout.SortOrder = Enum.SortOrder.LayoutOrder
SLayout.Parent = StatusList

local StatusItems = {
    { Key = "SoulGuitar",   Name = "Soul Guitar",        Icon = "guitar" },
    { Key = "CDK",          Name = "Cursed Dual Katana", Icon = "cdk" },
    { Key = "Yama",         Name = "Yama",               Icon = "yama" },
    { Key = "Tushita",      Name = "Tushita",            Icon = "tushita" },
    { Key = "RipIndra",     Name = "Rip_Indra Hat",      Icon = "hat" },
    { Key = "MirrorFractal",Name = "Mirror Fractal",     Icon = "mirror" },
    { Key = "PullLever",    Name = "Pull Lever",         Icon = "lever" },
}

local StatusRows = {}
for i, item in ipairs(StatusItems) do
    local row = Instance.new("Frame")
    row.LayoutOrder = i
    row.BackgroundColor3 = C.BG
    row.Parent = StatusList
    corner(row, 6)
    local rowStroke = stroke(row, C.Stroke, 1)

    local icon = drawIcon(row, item.Icon)
    icon.Position = UDim2.new(0, 6, 0.5, -10)
    setIconColor(icon, C.Off)

    local name = label(row, item.Name, 10, C.Gray, Enum.Font.GothamMedium)
    name.Position = UDim2.new(0, 29, 0, 0)
    name.Size = UDim2.new(1, -54, 1, 0)
    name.TextTruncate = Enum.TextTruncate.AtEnd

    -- Badge: tick xanh (có) / X đỏ (không có)
    local badge = Instance.new("Frame")
    badge.BackgroundTransparency = 1
    badge.Size = UDim2.new(0, 16, 0, 16)
    badge.Position = UDim2.new(1, -22, 0.5, -8)
    badge.Parent = row
    local badgeScale = Instance.new("UIScale")
    badgeScale.Scale = 0
    badgeScale.Parent = badge

    local checkH = Instance.new("Frame")
    checkH.BackgroundTransparency = 1
    checkH.Size = UDim2.new(1, 0, 1, 0)
    checkH.Visible = false
    checkH.Parent = badge
    part(checkH, { x = -3, y = 1, w = 2, h = 6, rot = -45, r = 1, fill = C.Green })
    part(checkH, { x = 3, y = -1, w = 2, h = 11, rot = 45, r = 1, fill = C.Green })

    local crossH = Instance.new("Frame")
    crossH.BackgroundTransparency = 1
    crossH.Size = UDim2.new(1, 0, 1, 0)
    crossH.Visible = false
    crossH.Parent = badge
    part(crossH, { w = 2, h = 12, rot = 45, r = 1, fill = C.Red })
    part(crossH, { w = 2, h = 12, rot = -45, r = 1, fill = C.Red })

    StatusRows[item.Key] = { Icon = icon, Name = name, Label = item.Name, Check = checkH, Cross = crossH, BadgeScale = badgeScale, Row = row, RowStroke = rowStroke }
end

local StatusState = {}
local function setStatus(key, state)
    local r = StatusRows[key]
    if not r then return end
    state = state and true or false
    if StatusState[key] == nil then
        Log(r.Label .. ": " .. (state and "YES" or "NO"))
    elseif StatusState[key] ~= state then
        Log(r.Label .. " changed -> " .. (state and "YES" or "NO"))
        Notify(state and "Item Obtained" or "Item Lost", r.Label, 3.5, state and C.Green or C.Red)
    end
    local changed = (StatusState[key] ~= state)
    StatusState[key] = state
    r.Check.Visible = state
    tween(r.RowStroke, 0.4, { Color = state and Color3.fromRGB(45, 130, 75) or C.Stroke })
    tween(r.Row, 0.4, { BackgroundColor3 = state and Color3.fromRGB(14, 24, 17) or C.BG })
    r.Cross.Visible = not state
    if changed then
        r.BadgeScale.Scale = 0.2
        tween(r.BadgeScale, 0.4, { Scale = 1 }, Enum.EasingStyle.Back)
    end
    setIconColor(r.Icon, state and C.White or C.Off)
    tween(r.Name, 0.3, { TextColor3 = state and C.White or C.Gray })
end

--================ INFO PANEL ================--
local InfoPanel = makePanel("INFO", UDim2.new(0.58, 0, 0, 76), UDim2.new(0.42, -18, 1, -94))

local InfoValues = {}
local function infoRow(order, title, iconKind)
    local row = Instance.new("Frame")
    row.Position = UDim2.new(0, 12, 0, 34 + (order - 1) * 54)
    row.Size = UDim2.new(1, -24, 0, 46)
    row.BackgroundColor3 = C.BG
    row.Parent = InfoPanel
    corner(row, 8)
    stroke(row, C.Stroke, 1)

    local t = label(row, title, 11, C.Gray, Enum.Font.Gotham)
    t.Position = UDim2.new(0, 12, 0, 5)
    t.Size = UDim2.new(1, -24, 0, 14)

    local v = label(row, "0", 18, C.White, Enum.Font.GothamBold)
    v.Position = UDim2.new(0, 12, 0, 20)
    v.Size = UDim2.new(1, -24, 0, 22)

    local ic = drawIcon(row, iconKind)
    ic.Position = UDim2.new(1, -32, 0.5, -10)
    return v
end

InfoValues.Beli = infoRow(1, "Beli", "beli")
InfoValues.Level = infoRow(2, "Level", "level")
InfoValues.Fragments = infoRow(3, "Fragments (Điểm F)", "fragment")

--================ DATA ================--
local function getData(name)
    local data = LocalPlayer:FindFirstChild("Data")
    local v = data and data:FindFirstChild(name)
    return v and v.Value or 0
end

local function getInventory()
    local ok, inv = pcall(function()
        return ReplicatedStorage.Remotes.CommF_:InvokeServer("getInventory")
    end)
    return ok and type(inv) == "table" and inv or {}
end

local function hasItem(inv, keyword)
    keyword = keyword:lower()
    for _, it in pairs(inv) do
        if type(it) == "table" and it.Name and tostring(it.Name):lower():find(keyword, 1, true) then
            return true
        end
    end
    -- check Backpack / Character
    local function scan(container)
        if not container then return false end
        for _, tool in ipairs(container:GetChildren()) do
            if tool.Name:lower():find(keyword, 1, true) then return true end
        end
        return false
    end
    return scan(LocalPlayer:FindFirstChild("Backpack")) or scan(LocalPlayer.Character)
end

local function updateAll()
    InfoValues.Beli.Text = formatNumber(getData("Beli"))
    InfoValues.Level.Text = tostring(getData("Level"))
    InfoValues.Fragments.Text = formatNumber(getData("Fragments"))

    local inv = getInventory()
    setStatus("SoulGuitar", hasItem(inv, "Soul Guitar"))
    setStatus("CDK", hasItem(inv, "Cursed Dual Katana"))
    setStatus("Yama", hasItem(inv, "Yama"))
    setStatus("Tushita", hasItem(inv, "Tushita"))
    setStatus("RipIndra", hasItem(inv, "Indra"))
    setStatus("MirrorFractal", hasItem(inv, "Mirror Fractal"))

    local ok, lever = pcall(function()
        return ReplicatedStorage.Remotes.CommF_:InvokeServer("CheckTempleDoor")
    end)
    setStatus("PullLever", ok and lever == true)
end

local function buildLog()
    local lines = {
        "=== " .. Config.Title .. " | Log Hub ===",
        "User: " .. LocalPlayer.Name .. " (" .. LocalPlayer.UserId .. ")",
        "Time: " .. os.date("%Y-%m-%d %H:%M:%S"),
        "",
        "Level: " .. tostring(getData("Level")),
        "Beli: " .. formatNumber(getData("Beli")),
        "Fragments: " .. formatNumber(getData("Fragments")),
        "",
        "-- Status --",
    }
    for _, it in ipairs(StatusItems) do
        table.insert(lines, it.Name .. ": " .. (StatusState[it.Key] and "YES" or "NO"))
    end
    table.insert(lines, "")
    table.insert(lines, "-- Log --")
    for _, l in ipairs(Logs) do table.insert(lines, l) end
    return table.concat(lines, "\n")
end

CopyBtn.MouseButton1Click:Connect(function()
    if copyToClipboard(buildLog()) then
        CopyLbl.Text = "Copied!"
        Notify("Log Hub", "Log copied to clipboard", 2.5)
        Log("Log copied")
    else
        CopyLbl.Text = "No clipboard"
        Notify("Log Hub", "Executor không hỗ trợ clipboard", 3)
    end
    task.delay(1.5, function() CopyLbl.Text = "Copy Log" end)
end)

--================ DYNAMIC ISLAND ================--
--// Ping / FPS / CPU + Status farm + nút bật tắt (Farm & UI)
--// API cho script farm:
--//   getgenv().RyzenG3.SetStatus("Farming")   -- chữ ngắn trên đảo
--//   getgenv().RyzenG3.SetTask("Đang farm Cursed Captain")
--//   getgenv().RyzenG3.OnToggle = function(state) ... end
--//   getgenv().RyzenG3.IsEnabled()  /  getgenv().RyzenG3_FarmEnabled
local Stats = game:GetService("Stats")
local Env = (getgenv and getgenv()) or _G

local Island = {
    Enabled = true,
    Expanded = false,
    Status = "Farming",
    Task = "Idle",
    OnToggle = nil,
}
local sessionStart = os.clock()

local COMPACT_W, COMPACT_H = 300, 34
local EXPAND_W, EXPAND_H = 320, 144
local GRAY_HEX = "#969696"

local Root = Instance.new("Frame")
Root.Name = "DynamicIsland"
Root.AnchorPoint = Vector2.new(0.5, 0)
Root.Position = UDim2.new(0.5, 0, 0, 10)
Root.Size = UDim2.new(0, 34, 0, 34)
Root.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Root.ClipsDescendants = true
Root.Visible = false
Root.ZIndex = 60
Root.Parent = Gui
local RootCorner = corner(Root, 17)
local RootStroke = stroke(Root, C.White, 1)
RootStroke.Transparency = 0.7

-- Thanh compact (luôn hiển thị)
local Bar = Instance.new("Frame")
Bar.AnchorPoint = Vector2.new(0.5, 0)
Bar.Position = UDim2.new(0.5, 0, 0, 0)
Bar.Size = UDim2.new(0, COMPACT_W, 0, COMPACT_H)
Bar.BackgroundTransparency = 1
Bar.ZIndex = 61
Bar.Parent = Root

local Dot = Instance.new("Frame")
Dot.Size = UDim2.new(0, 8, 0, 8)
Dot.Position = UDim2.new(0, 14, 0.5, -4)
Dot.BackgroundColor3 = C.White
Dot.BorderSizePixel = 0
Dot.ZIndex = 62
Dot.Parent = Bar
corner(Dot, 4)

local StatusLbl = label(Bar, "Farming", 11, C.White, Enum.Font.GothamBold)
StatusLbl.Position = UDim2.new(0, 28, 0, 0)
StatusLbl.Size = UDim2.new(0, 66, 1, 0)
StatusLbl.TextTruncate = Enum.TextTruncate.AtEnd
StatusLbl.ZIndex = 62

local StatLbl = label(Bar, "", 11, C.White, Enum.Font.GothamMedium, Enum.TextXAlignment.Right)
StatLbl.RichText = true
StatLbl.Position = UDim2.new(0, 98, 0, 0)
StatLbl.Size = UDim2.new(1, -110, 1, 0)
StatLbl.ZIndex = 62

-- Vùng bấm để mở rộng / thu gọn
local Hit = Instance.new("TextButton")
Hit.Text = ""
Hit.AutoButtonColor = false
Hit.BackgroundTransparency = 1
Hit.Size = UDim2.new(1, 0, 0, COMPACT_H)
Hit.ZIndex = 70
Hit.Parent = Root

-- Phần mở rộng
local Expanded = Instance.new("CanvasGroup")
Expanded.BackgroundTransparency = 1
Expanded.GroupTransparency = 1
Expanded.Visible = false
Expanded.Position = UDim2.new(0, 0, 0, COMPACT_H)
Expanded.Size = UDim2.new(0, EXPAND_W, 0, EXPAND_H - COMPACT_H)
Expanded.ZIndex = 61
Expanded.Parent = Root

local XDiv = Instance.new("Frame")
XDiv.Position = UDim2.new(0, 14, 0, 0)
XDiv.Size = UDim2.new(1, -28, 0, 1)
XDiv.BackgroundColor3 = C.Stroke
XDiv.BorderSizePixel = 0
XDiv.Parent = Expanded

local function richLine(y, color)
    local l = label(Expanded, "", 11, color or C.Gray, Enum.Font.Gotham)
    l.RichText = true
    l.Position = UDim2.new(0, 16, 0, y)
    l.Size = UDim2.new(1, -32, 0, 16)
    l.TextTruncate = Enum.TextTruncate.AtEnd
    return l
end

local TaskLbl = richLine(9, C.White)
local InfoLbl = richLine(28)
local TimeLbl = richLine(46)

local function makeBtn(pos, size)
    local b = Instance.new("TextButton")
    b.AutoButtonColor = false
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.Position = pos
    b.Size = size
    b.BackgroundColor3 = C.White
    b.TextColor3 = C.BG
    b.Parent = Expanded
    corner(b, 16)
    stroke(b, C.White, 1)
    return b
end

local function paintBtn(b, active, text)
    b.Text = text
    tween(b, 0.25, {
        BackgroundColor3 = active and C.White or Color3.fromRGB(0, 0, 0),
        TextColor3 = active and C.BG or C.White,
    })
end

local FarmBtn = makeBtn(UDim2.new(0, 14, 0, 72), UDim2.new(0.5, -19, 0, 32))
local UIBtn = makeBtn(UDim2.new(0.5, 5, 0, 72), UDim2.new(0.5, -19, 0, 32))

--// ---------- Hiện / ẩn UI chính ----------
local UIVisible = false
local uiToken = 0
local function setUIVisible(v)
    UIVisible = v and true or false
    uiToken = uiToken + 1
    local my = uiToken
    if UIVisible then
        Main.Visible = true
        tween(Scale, 0.4, { Scale = 1 }, Enum.EasingStyle.Back)
    else
        tween(Scale, 0.25, { Scale = 0.85 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In).Completed:Connect(function()
            if my == uiToken and not UIVisible then Main.Visible = false end
        end)
    end
    paintBtn(UIBtn, false, UIVisible and "HIDE UI" or "SHOW UI")
end

CloseBtn.MouseButton1Click:Connect(function()
    setUIVisible(false)
    Notify("Ryzen G3", "UI đã ẩn - bấm vào island > SHOW UI để mở lại", 3.5)
end)

--// ---------- Hiệu ứng ----------
local pulse
local function refreshBar()
    local on = Island.Enabled
    StatusLbl.Text = on and Island.Status or "Paused"
    if pulse then pulse:Cancel() pulse = nil end
    if on then
        Dot.BackgroundColor3 = C.White
        Dot.BackgroundTransparency = 0
        pulse = TweenService:Create(Dot, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { BackgroundTransparency = 0.7 })
        pulse:Play()
    else
        Dot.BackgroundColor3 = C.Off
        Dot.BackgroundTransparency = 0
    end
    paintBtn(FarmBtn, on, on and "FARM: ON" or "FARM: OFF")
end

local function bump()
    if Island.Expanded or not Root.Visible then return end
    tween(Root, 0.18, { Size = UDim2.new(0, COMPACT_W + 16, 0, COMPACT_H + 4) }, Enum.EasingStyle.Quad).Completed:Connect(function()
        if not Island.Expanded then
            tween(Root, 0.35, { Size = UDim2.new(0, COMPACT_W, 0, COMPACT_H) }, Enum.EasingStyle.Back)
        end
    end)
end

local collapseToken = 0
local function setExpanded(v)
    Island.Expanded = v and true or false
    collapseToken = collapseToken + 1
    local my = collapseToken

    tween(Root, 0.5, { Size = UDim2.new(0, v and EXPAND_W or COMPACT_W, 0, v and EXPAND_H or COMPACT_H) }, Enum.EasingStyle.Back)
    tween(RootCorner, 0.5, { CornerRadius = UDim.new(0, v and 24 or 17) })

    if v then
        Expanded.Visible = true
        tween(Expanded, 0.35, { GroupTransparency = 0 })
        task.delay(8, function() -- tự thu gọn nếu không thao tác
            if my == collapseToken and Island.Expanded then Island.SetExpanded(false) end
        end)
    else
        tween(Expanded, 0.2, { GroupTransparency = 1 }).Completed:Connect(function()
            if not Island.Expanded then Expanded.Visible = false end
        end)
    end
end

--// ---------- Cập nhật số liệu ----------
local function fmtTime(s)
    s = math.floor(s)
    return string.format("%02d:%02d:%02d", math.floor(s / 3600), math.floor((s % 3600) / 60), s % 60)
end

local function getPing()
    local ok, v = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
    if ok and v then return math.floor(v) end
    local ok2, p = pcall(function() return LocalPlayer:GetNetworkPing() * 1000 end)
    return ok2 and math.floor(p) or 0
end

-- Roblox không có CPU% thật -> ước lượng theo CPU time mỗi frame / ngân sách 60 FPS (16.67ms)
local cpuSmooth
local function getCpu()
    local ms
    pcall(function() ms = Stats.PerformanceStats.CPU:GetValue() end)
    if not ms then pcall(function() ms = Stats.HeartbeatTimeMs end) end
    if not ms then return nil end
    local pct = math.clamp(ms / (1000 / 60) * 100, 0, 100)
    cpuSmooth = cpuSmooth and (cpuSmooth * 0.6 + pct * 0.4) or pct
    return math.floor(cpuSmooth + 0.5)
end

local function unit(n, u)
    return string.format('<b>%s</b><font color="%s">%s</font>', tostring(n), GRAY_HEX, u)
end

local frames, acc = 0, 0
RunService.Heartbeat:Connect(function(dt)
    frames = frames + 1
    acc = acc + dt
end)

local function refreshStats()
    local fps = math.floor(frames / math.max(acc, 0.001) + 0.5)
    frames, acc = 0, 0
    local cpu = getCpu()
    StatLbl.Text = unit(getPing(), "ms") .. "   " .. unit(fps, "fps") .. "   " .. unit(cpu or "--", cpu and "%cpu" or " cpu")

    if Island.Expanded then
        local done = 0
        for _, it in ipairs(StatusItems) do
            if StatusState[it.Key] then done = done + 1 end
        end
        TaskLbl.Text = string.format('<font color="%s">Task  </font>%s', GRAY_HEX, Island.Task)
        InfoLbl.Text = string.format('Lv <b>%s</b>   ·   <b>%s</b> Beli   ·   <b>%s</b> F',
            tostring(getData("Level")), formatNumber(getData("Beli")), formatNumber(getData("Fragments")))
        TimeLbl.Text = string.format('Items <b>%d/%d</b>   ·   Time <b>%s</b>', done, #StatusItems, fmtTime(os.clock() - sessionStart))
    end
end

local lastReport = os.clock()
task.spawn(function()
    while Gui.Parent do
        task.wait(0.5)
        pcall(refreshStats)
        if Island.Enabled and Config.ReportEvery and os.clock() - lastReport >= Config.ReportEvery then
            lastReport = os.clock()
            local done = 0
            for _, it in ipairs(StatusItems) do
                if StatusState[it.Key] then done = done + 1 end
            end
            Notify("Farm Report", string.format("Lv %s | %s Beli | %d/%d items",
                tostring(getData("Level")), formatNumber(getData("Beli")), done, #StatusItems), 4)
        end
    end
end)

--// ---------- API ----------
function Island.SetEnabled(state, silent)
    state = state and true or false
    local changed = Island.Enabled ~= state
    Island.Enabled = state
    Env.RyzenG3_FarmEnabled = state
    refreshBar()
    if not changed then return end
    Log("Farm " .. (state and "ON" or "OFF"))
    if not silent then Notify("Farm Status", state and "Farm đã BẬT" or "Farm đã TẮT", 2.5, state and C.Green or C.Red) end
    bump()
    if type(Island.OnToggle) == "function" then
        task.spawn(function() pcall(Island.OnToggle, state) end)
    end
end

function Island.Toggle() Island.SetEnabled(not Island.Enabled) end
function Island.IsEnabled() return Island.Enabled end

function Island.SetStatus(text, silent)
    text = tostring(text or "")
    local changed = text ~= Island.Status
    Island.Status = text
    refreshBar()
    if changed then
        Log("Status: " .. text)
        if not silent and Island.Enabled then Notify("Farm Status", text, 2.5, C.Green) end
        bump()
    end
end

local lastTaskNotify = 0
function Island.SetTask(text, silent)
    text = tostring(text or "Idle")
    if text == Island.Task then return end
    Island.Task = text
    Log("Task: " .. text)
    if not silent and os.clock() - lastTaskNotify > 3 then
        lastTaskNotify = os.clock()
        Notify("Farm Task", text, 3)
    end
    if Island.Expanded then pcall(refreshStats) end
end

function Island.SetExpanded(v) setExpanded(v) end

function Island.Show()
    Root.Visible = true
    Root.Size = UDim2.new(0, 34, 0, 34)
    tween(Root, 0.7, { Size = UDim2.new(0, COMPACT_W, 0, COMPACT_H) }, Enum.EasingStyle.Back)
end

Hit.MouseButton1Click:Connect(function() setExpanded(not Island.Expanded) end)
FarmBtn.MouseButton1Click:Connect(function()
    Island.Toggle()
    collapseToken = collapseToken + 1 -- reset đếm giờ tự thu gọn
    local my = collapseToken
    task.delay(8, function()
        if my == collapseToken and Island.Expanded then setExpanded(false) end
    end)
end)
UIBtn.MouseButton1Click:Connect(function() setUIVisible(not UIVisible) end)

Env.RyzenG3_FarmEnabled = Island.Enabled
pcall(function() Env.RyzenG3 = Island end)
refreshBar()
paintBtn(UIBtn, false, "HIDE UI")

--================ LOADING SCREEN ================--
local Loading = Instance.new("Frame")
Loading.Size = UDim2.new(0, 360, 0, 120)
Loading.Position = UDim2.new(0.5, 0, 0.5, 0)
Loading.AnchorPoint = Vector2.new(0.5, 0.5)
Loading.BackgroundColor3 = C.BG
Loading.Parent = Gui
corner(Loading, 12)
stroke(Loading, C.White, 1)
makeSnow(Loading, 360, 120, 18, 12)

local LTitle = label(Loading, Config.Title, 18, C.White, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
LTitle.Position = UDim2.new(0, 0, 0, 16)
LTitle.Size = UDim2.new(1, 0, 0, 24)

local LStatus = label(Loading, "Initializing...", 12, C.Gray, Enum.Font.Gotham, Enum.TextXAlignment.Center)
LStatus.Position = UDim2.new(0, 0, 0, 50)
LStatus.Size = UDim2.new(1, 0, 0, 16)

local BarBG = Instance.new("Frame")
BarBG.Size = UDim2.new(1, -48, 0, 6)
BarBG.Position = UDim2.new(0, 24, 0, 82)
BarBG.BackgroundColor3 = C.Panel
BarBG.Parent = Loading
corner(BarBG, 3)

local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = C.White
BarFill.BorderSizePixel = 0
BarFill.Parent = BarBG
corner(BarFill, 3)

local Percent = label(Loading, "0%", 11, C.White, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
Percent.Position = UDim2.new(0, 0, 0, 94)
Percent.Size = UDim2.new(1, 0, 0, 16)

local steps = {
    { "Checking game...", 0.18 },
    { "Loading player data...", 0.40 },
    { "Loading inventory...", 0.65 },
    { "Building interface...", 0.88 },
    { "Done!", 1 },
}

task.spawn(function()
    if not game:IsLoaded() then game.Loaded:Wait() end

    for _, s in ipairs(steps) do
        LStatus.Text = s[1]
        Log(s[1])
        tween(BarFill, 0.5, { Size = UDim2.new(s[2], 0, 1, 0) })
        Percent.Text = math.floor(s[2] * 100) .. "%"
        task.wait(0.55)
    end

    task.wait(0.2)
    tween(Loading, 0.3, { Size = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Back, Enum.EasingDirection.In).Completed:Wait()
    Loading:Destroy()

    setUIVisible(true)
    Island.Show()

    Log("Script loaded successfully")
    Notify("Ryzen G3 - KaitunBF", "Script loaded successfully", 3.5)
    pcall(updateAll)

    -- vòng lặp cập nhật
    while Gui.Parent do
        task.wait(Config.UpdateDelay)
        pcall(updateAll)
    end
end)

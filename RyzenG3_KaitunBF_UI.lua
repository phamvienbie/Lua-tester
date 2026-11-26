--// Ryzen G3 - KaitunBF | UI (Black & White)
--// Loading + Notify bên phải + Status + Info

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

local function Notify(title, text, duration)
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
    stroke(box, C.White, 1)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 1, -14)
    bar.Position = UDim2.new(0, 7, 0, 7)
    bar.BackgroundColor3 = C.White
    bar.BorderSizePixel = 0
    bar.Parent = box
    corner(bar, 2)

    local t = label(box, title, 12, C.White, Enum.Font.GothamBold)
    t.Position = UDim2.new(0, 18, 0, 5)
    t.Size = UDim2.new(1, -24, 0, 16)

    local d = label(box, text, 11, C.Gray, Enum.Font.Gotham)
    d.Position = UDim2.new(0, 18, 0, 21)
    d.Size = UDim2.new(1, -24, 0, 16)

    tween(box, 0.45, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Back)

    task.delay(duration, function()
        tween(box, 0.4, { Position = UDim2.new(1.3, 0, 0, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In).Completed:Wait()
        slot:Destroy()
    end)
end

--================ MAIN UI ================--
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 600, 0, 320)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = C.BG
Main.Visible = false
Main.Parent = Gui
corner(Main, 12)
stroke(Main, C.Stroke, 1)

local Scale = Instance.new("UIScale")
Scale.Scale = 0.9
Scale.Parent = Main

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

local TitleLbl = label(Header, Config.Title, 20, C.White, Enum.Font.GothamBold)
TitleLbl.Position = UDim2.new(0, 18, 0, 10)
TitleLbl.Size = UDim2.new(0, 230, 0, 24)

-- Tag nhỏ kế bên tên
local Tag = Instance.new("Frame")
Tag.BackgroundColor3 = C.White
Tag.Position = UDim2.new(0, 0, 0, 14)
Tag.Size = UDim2.new(0, 120, 0, 18)
Tag.Parent = Header
corner(Tag, 9)

local TagLbl = label(Tag, Config.Tag, 10, C.BG, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
TagLbl.Size = UDim2.new(1, 0, 1, 0)

task.defer(function()
    local w = TitleLbl.TextBounds.X
    TitleLbl.Size = UDim2.new(0, w + 4, 0, 24)
    Tag.Position = UDim2.new(0, 18 + w + 12, 0, 13)
end)

-- Welcome
local Welcome = label(Header, "Welcome to  " .. LocalPlayer.Name, 13, C.Gray, Enum.Font.Gotham)
Welcome.Position = UDim2.new(0, 18, 0, 37)
Welcome.Size = UDim2.new(0.6, 0, 0, 16)

-- Avatar nhỏ góc phải
local AvatarFrame = Instance.new("Frame")
AvatarFrame.Size = UDim2.new(0, 38, 0, 38)
AvatarFrame.Position = UDim2.new(1, -52, 0, 12)
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

-- Nút Copy Log Hub
local CopyBtn = Instance.new("TextButton")
CopyBtn.Text = ""
CopyBtn.AutoButtonColor = false
CopyBtn.Size = UDim2.new(0, 104, 0, 26)
CopyBtn.Position = UDim2.new(1, -170, 0, 18)
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

-- Panel helper
local function makePanel(titleText, pos, size)
    local p = Instance.new("Frame")
    p.Position = pos
    p.Size = size
    p.BackgroundColor3 = C.Panel
    p.Parent = Main
    corner(p, 10)
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
    stroke(row, C.Stroke, 1)

    local icon = drawIcon(row, item.Icon)
    icon.Position = UDim2.new(0, 6, 0.5, -10)
    setIconColor(icon, C.Off)

    local name = label(row, item.Name, 11, C.Gray, Enum.Font.GothamMedium)
    name.Position = UDim2.new(0, 31, 0, 0)
    name.Size = UDim2.new(1, -34, 1, 0)
    name.TextTruncate = Enum.TextTruncate.AtEnd

    StatusRows[item.Key] = { Icon = icon, Name = name, Label = item.Name }
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
    end
    StatusState[key] = state
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

--================ LOADING SCREEN ================--
local Loading = Instance.new("Frame")
Loading.Size = UDim2.new(0, 360, 0, 120)
Loading.Position = UDim2.new(0.5, 0, 0.5, 0)
Loading.AnchorPoint = Vector2.new(0.5, 0.5)
Loading.BackgroundColor3 = C.BG
Loading.Parent = Gui
corner(Loading, 12)
stroke(Loading, C.White, 1)

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

    Main.Visible = true
    tween(Scale, 0.4, { Scale = 1 }, Enum.EasingStyle.Back)

    Log("Script loaded successfully")
    Notify("Ryzen G3 - KaitunBF", "Script loaded successfully", 3.5)
    pcall(updateAll)

    -- vòng lặp cập nhật
    while Gui.Parent do
        task.wait(Config.UpdateDelay)
        pcall(updateAll)
    end
end)

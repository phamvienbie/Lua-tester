--[[
    King Legacy UI - Dynamic Island + Menu (Đen / Đỏ)
    - Island ở giữa trên cùng: avatar, tên, Beli, Gems, số boss đang spawn
    - Bấm Island hoặc phím RightControl -> mở menu, Island tự đóng
    - Đóng menu (nút X / RightControl) -> Island tự mở lại
    - Menu: thông tin người chơi + trạng thái boss (xanh = đã spawn, đỏ = chưa)
    - Đọc dữ liệu từ file SeaEvents
]]

----------------------------------------------------------------
-- LOAD FILE SEA EVENT
----------------------------------------------------------------
local SeaEvents
do
    -- 1) nếu đã nạp sẵn:  getgenv().SeaEvents = loadstring(...)()
    local ok, genv = pcall(function() return getgenv and getgenv().SeaEvents end)
    if ok and genv then
        SeaEvents = genv
    end
    -- 2) đọc từ workspace folder của executor: SeaEvents.lua
    if not SeaEvents and readfile and isfile and isfile("SeaEvents.lua") then
        local f = loadstring(readfile("SeaEvents.lua"))
        if f then SeaEvents = f() end
    end
    -- 3) ModuleScript đặt cạnh script này (nếu chạy dạng LocalScript)
    if not SeaEvents and script and script.Parent then
        local m = script.Parent:FindFirstChild("SeaEvents")
        if m and m:IsA("ModuleScript") then SeaEvents = require(m) end
    end
    -- 4) Không tìm thấy file ngoài -> dùng dữ liệu nhúng sẵn (copy từ file Sea Event)
    if not SeaEvents then
        SeaEvents = {
            Sea2 = {
                {Name = "Sea King", WorkspaceName = "SeaKing", Type = "Boss"},
                {Name = "Hydra", WorkspaceName = "Hydra", Type = "Boss"},
                {Name = "Ghost Ship", WorkspaceName = "GhostShip", Type = "Ship / Boss"},
                {Name = "Ship Raid (Pirate / Marine Ship)", WorkspaceName = "PirateShip", Type = "Ship"},
                {Name = "Skull Island", WorkspaceName = "SkullIsland", Type = "Island Event"},
                {Name = "Treasure Island", WorkspaceName = "TreasureIsland", Type = "Island Event"},
            },
            Sea3 = {
                {Name = "Sea King", WorkspaceName = "SeaKing", Type = "Boss"},
                {Name = "Hydra", WorkspaceName = "Hydra", Type = "Boss"},
                {Name = "Ghost Ship", WorkspaceName = "GhostShip", Type = "Ship / Boss"},
                {Name = "Kraken", WorkspaceName = "Kraken", Type = "Boss"},
                {Name = "Deep Sea Monster / Abyssal Beast", WorkspaceName = "DeepSeaMonster", Type = "Boss"},
                {Name = "Drakenfyr / Sea Dragon", WorkspaceName = "SeaDragon", Type = "Boss"},
                {Name = "Ship Raid (Armada / Ghost Fleet)", WorkspaceName = "ArmadaShip", Type = "Ship"},
                {Name = "Mirage / Mystery Island", WorkspaceName = "MysteryIsland", Type = "Island Event"},
                {Name = "Whirlpool", WorkspaceName = "Whirlpool", Type = "Portal / Event"},
            },
        }
        warn("[KingLegacyUI] Không thấy SeaEvents.lua, dùng dữ liệu nhúng sẵn")
    end
end

----------------------------------------------------------------
-- SERVICES
----------------------------------------------------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

----------------------------------------------------------------
-- CONFIG
----------------------------------------------------------------
local TOGGLE_KEY = Enum.KeyCode.RightControl
local SCAN_INTERVAL = 1.5

local COLORS = {
    Black = Color3.fromRGB(10, 10, 12),
    Panel = Color3.fromRGB(20, 20, 24),
    Row = Color3.fromRGB(28, 28, 33),
    Red = Color3.fromRGB(220, 30, 45),
    DarkRed = Color3.fromRGB(120, 15, 25),
    Text = Color3.fromRGB(240, 240, 240),
    Sub = Color3.fromRGB(150, 150, 158),
    Green = Color3.fromRGB(46, 220, 110),
    Off = Color3.fromRGB(235, 50, 60),
}

-- PlaceId các Sea (chỉnh lại nếu game cập nhật)
local SEA_PLACES = {
    [4520749081] = 1,
    [6381829480] = 2,
    [15759515082] = 3,
}

local function detectSea()
    return SEA_PLACES[game.PlaceId] or 2
end

----------------------------------------------------------------
-- HELPERS
----------------------------------------------------------------
local function fmt(n)
    n = tonumber(n) or 0
    local s = tostring(math.floor(n))
    local k
    repeat
        s, k = s:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
    until k == 0
    return s
end

local function findValue(names)
    for _, inst in ipairs(player:GetDescendants()) do
        if inst:IsA("ValueBase") then
            for _, n in ipairs(names) do
                if inst.Name:lower() == n:lower() then
                    return inst
                end
            end
        end
    end
end

local function tween(obj, t, props, style, dir)
    local tw = TweenService:Create(
        obj,
        TweenInfo.new(t, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
        props
    )
    tw:Play()
    return tw
end

local function new(class, props, children)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    for _, c in ipairs(children or {}) do c.Parent = o end
    return o
end

local function corner(r) return new("UICorner", {CornerRadius = r}) end
local function stroke(color, th, tr)
    return new("UIStroke", {Color = color, Thickness = th or 1, Transparency = tr or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
end

----------------------------------------------------------------
-- GUI ROOT
----------------------------------------------------------------
local parent
do
    local ok, h = pcall(function() return gethui and gethui() end)
    if ok and h then
        parent = h
    else
        local ok2, cg = pcall(function() return game:GetService("CoreGui") end)
        parent = (ok2 and cg) or player:WaitForChild("PlayerGui")
    end
end

local old = parent:FindFirstChild("KingLegacyUI")
if old then old:Destroy() end

local gui = new("ScreenGui", {
    Name = "KingLegacyUI",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    DisplayOrder = 999,
})
gui.Parent = parent

----------------------------------------------------------------
-- DYNAMIC ISLAND
----------------------------------------------------------------
local ISLAND_SIZE = UDim2.fromOffset(330, 40)
local ISLAND_POS = UDim2.new(0.5, 0, 0, 12)

local island = new("TextButton", {
    Name = "Island",
    AnchorPoint = Vector2.new(0.5, 0),
    Position = ISLAND_POS,
    Size = ISLAND_SIZE,
    BackgroundColor3 = COLORS.Black,
    Text = "",
    AutoButtonColor = false,
    ClipsDescendants = true,
}, {
    corner(UDim.new(1, 0)),
    stroke(COLORS.Red, 1.5, 0.15),
})
island.Parent = gui

local islandContent = new("CanvasGroup", {
    Name = "Content",
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
})
islandContent.Parent = island

local avatarSmall = new("ImageLabel", {
    Name = "Avatar",
    Position = UDim2.fromOffset(6, 6),
    Size = UDim2.fromOffset(28, 28),
    BackgroundColor3 = COLORS.Panel,
    Image = "",
}, {corner(UDim.new(1, 0)), stroke(COLORS.Red, 1)})
avatarSmall.Parent = islandContent

local islandName = new("TextLabel", {
    Position = UDim2.fromOffset(40, 0),
    Size = UDim2.new(0, 100, 1, 0),
    BackgroundTransparency = 1,
    Text = player.DisplayName,
    TextColor3 = COLORS.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
})
islandName.Parent = islandContent

local islandBeli = new("TextLabel", {
    Position = UDim2.fromOffset(142, 0),
    Size = UDim2.fromOffset(78, 40),
    BackgroundTransparency = 1,
    Text = "0",
    RichText = true,
    TextColor3 = COLORS.Text,
    Font = Enum.Font.GothamMedium,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
})
islandBeli.Parent = islandContent

local islandGems = new("TextLabel", {
    Position = UDim2.fromOffset(222, 0),
    Size = UDim2.fromOffset(58, 40),
    BackgroundTransparency = 1,
    Text = "0",
    RichText = true,
    TextColor3 = COLORS.Text,
    Font = Enum.Font.GothamMedium,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
})
islandGems.Parent = islandContent

local islandDot = new("Frame", {
    AnchorPoint = Vector2.new(0, 0.5),
    Position = UDim2.new(0, 288, 0.5, 0),
    Size = UDim2.fromOffset(10, 10),
    BackgroundColor3 = COLORS.Off,
}, {corner(UDim.new(1, 0))})
islandDot.Parent = islandContent

local islandCount = new("TextLabel", {
    Position = UDim2.fromOffset(302, 0),
    Size = UDim2.fromOffset(24, 40),
    BackgroundTransparency = 1,
    Text = "0",
    TextColor3 = COLORS.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
})
islandCount.Parent = islandContent

----------------------------------------------------------------
-- MENU
----------------------------------------------------------------
local MENU_SIZE = UDim2.fromOffset(520, 360)

local menu = new("CanvasGroup", {
    Name = "Menu",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = MENU_SIZE,
    BackgroundColor3 = COLORS.Black,
    GroupTransparency = 1,
    Visible = false,
}, {
    corner(UDim.new(0, 18)),
    stroke(COLORS.Red, 2, 0),
})
menu.Parent = gui

local menuScale = new("UIScale", {Scale = 0.85})
menuScale.Parent = menu

-- Co menu cho vừa màn hình nhỏ / điện thoại
local function fitScale()
    local cam = workspace.CurrentCamera
    if not cam then return 1 end
    local v = cam.ViewportSize
    return math.min(1, (v.X - 20) / 520, (v.Y - 20) / 360)
end
local baseScale = fitScale()

-- Header
local header = new("Frame", {
    Size = UDim2.new(1, 0, 0, 46),
    BackgroundColor3 = COLORS.DarkRed,
    BorderSizePixel = 0,
}, {
    new("UIGradient", {
        Color = ColorSequence.new(COLORS.Red, COLORS.Black),
        Rotation = 0,
        Transparency = NumberSequence.new(0.1, 0.6),
    }),
})
header.Parent = menu

new("TextLabel", {
    Position = UDim2.fromOffset(16, 0),
    Size = UDim2.new(1, -70, 1, 0),
    BackgroundTransparency = 1,
    Text = "KING LEGACY  •  SEA EVENT",
    TextColor3 = COLORS.Text,
    Font = Enum.Font.GothamBlack,
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left,
}).Parent = header

local closeBtn = new("TextButton", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -10, 0.5, 0),
    Size = UDim2.fromOffset(30, 30),
    BackgroundColor3 = COLORS.Black,
    Text = "X",
    TextColor3 = COLORS.Red,
    Font = Enum.Font.GothamBlack,
    TextSize = 15,
    AutoButtonColor = false,
}, {corner(UDim.new(1, 0)), stroke(COLORS.Red, 1.5)})
closeBtn.Parent = header

closeBtn.MouseEnter:Connect(function()
    tween(closeBtn, 0.15, {BackgroundColor3 = COLORS.Red, TextColor3 = COLORS.Text})
end)
closeBtn.MouseLeave:Connect(function()
    tween(closeBtn, 0.15, {BackgroundColor3 = COLORS.Black, TextColor3 = COLORS.Red})
end)

-- Profile card
local profile = new("Frame", {
    Position = UDim2.fromOffset(14, 58),
    Size = UDim2.new(1, -28, 0, 78),
    BackgroundColor3 = COLORS.Panel,
}, {corner(UDim.new(0, 12)), stroke(COLORS.DarkRed, 1)})
profile.Parent = menu

local avatarBig = new("ImageLabel", {
    Position = UDim2.fromOffset(10, 9),
    Size = UDim2.fromOffset(60, 60),
    BackgroundColor3 = COLORS.Black,
    Image = "",
}, {corner(UDim.new(1, 0)), stroke(COLORS.Red, 2)})
avatarBig.Parent = profile

new("TextLabel", {
    Position = UDim2.fromOffset(82, 10),
    Size = UDim2.new(0.5, -82, 0, 24),
    BackgroundTransparency = 1,
    Text = player.DisplayName,
    TextColor3 = COLORS.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 17,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
}).Parent = profile

new("TextLabel", {
    Position = UDim2.fromOffset(82, 34),
    Size = UDim2.new(0.5, -82, 0, 18),
    BackgroundTransparency = 1,
    Text = "@" .. player.Name,
    TextColor3 = COLORS.Sub,
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
}).Parent = profile

local seaLabel = new("TextLabel", {
    Position = UDim2.fromOffset(82, 52),
    Size = UDim2.new(0.5, -82, 0, 18),
    BackgroundTransparency = 1,
    Text = "Sea " .. detectSea(),
    TextColor3 = COLORS.Red,
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
})
seaLabel.Parent = profile

local function statBox(posY, title)
    local box = new("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -10, 0, posY),
        Size = UDim2.fromOffset(150, 30),
        BackgroundColor3 = COLORS.Black,
    }, {corner(UDim.new(0, 8)), stroke(COLORS.DarkRed, 1)})
    box.Parent = profile
    new("TextLabel", {
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(0, 46, 1, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = COLORS.Red,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }).Parent = box
    local val = new("TextLabel", {
        Position = UDim2.fromOffset(56, 0),
        Size = UDim2.new(1, -64, 1, 0),
        BackgroundTransparency = 1,
        Text = "0",
        TextColor3 = COLORS.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Right,
    })
    val.Parent = box
    return val
end

local beliVal = statBox(8, "BELI")
local gemVal = statBox(40, "GEMS")

-- Boss status section
local bossTitle = new("TextLabel", {
    Position = UDim2.fromOffset(18, 144),
    Size = UDim2.fromOffset(200, 22),
    BackgroundTransparency = 1,
    Text = "TRẠNG THÁI BOSS",
    TextColor3 = COLORS.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
})
bossTitle.Parent = menu

-- Tab Sea 2 / Sea 3
local tabs = {}
local scanNow = true
local selectedSea = detectSea()
if selectedSea < 2 then selectedSea = 2 end

local function makeTab(sea, offsetX)
    local b = new("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, offsetX, 0, 142),
        Size = UDim2.fromOffset(64, 24),
        BackgroundColor3 = COLORS.Black,
        Text = "Sea " .. sea,
        TextColor3 = COLORS.Sub,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        AutoButtonColor = false,
    }, {corner(UDim.new(1, 0)), stroke(COLORS.DarkRed, 1)})
    b.Parent = menu
    tabs[sea] = b
    return b
end
makeTab(3, -14)
makeTab(2, -84)

local list = new("ScrollingFrame", {
    Position = UDim2.fromOffset(14, 172),
    Size = UDim2.new(1, -28, 1, -184),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = COLORS.Red,
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, {
    new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}),
})
list.Parent = menu

----------------------------------------------------------------
-- BOSS ROWS
----------------------------------------------------------------
local rows = {} -- [sea] = { {dot=, status=, data=} ... }

local function buildRows(sea)
    for _, r in ipairs(list:GetChildren()) do
        if r:IsA("Frame") then r:Destroy() end
    end
    rows = {}
    local data = SeaEvents["Sea" .. sea] or {}
    for i, ev in ipairs(data) do
        local row = new("Frame", {
            LayoutOrder = i,
            Size = UDim2.new(1, -6, 0, 40),
            BackgroundColor3 = COLORS.Row,
        }, {corner(UDim.new(0, 10))})
        row.Parent = list

        local dot = new("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 12, 0.5, 0),
            Size = UDim2.fromOffset(12, 12),
            BackgroundColor3 = COLORS.Off,
        }, {corner(UDim.new(1, 0))})
        dot.Parent = row

        new("TextLabel", {
            Position = UDim2.fromOffset(34, 3),
            Size = UDim2.new(1, -150, 0, 20),
            BackgroundTransparency = 1,
            Text = ev.Name,
            TextColor3 = COLORS.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }).Parent = row

        new("TextLabel", {
            Position = UDim2.fromOffset(34, 21),
            Size = UDim2.new(1, -150, 0, 16),
            BackgroundTransparency = 1,
            Text = ev.Type or "",
            TextColor3 = COLORS.Sub,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        }).Parent = row

        local status = new("TextLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -12, 0.5, 0),
            Size = UDim2.fromOffset(100, 24),
            BackgroundColor3 = COLORS.Black,
            Text = "CHƯA SPAWN",
            TextColor3 = COLORS.Off,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
        }, {corner(UDim.new(1, 0))})
        status.Parent = row

        table.insert(rows, {dot = dot, status = status, data = ev})
    end
end

local function setTabs()
    for sea, b in pairs(tabs) do
        local on = sea == selectedSea
        tween(b, 0.2, {
            BackgroundColor3 = on and COLORS.Red or COLORS.Black,
            TextColor3 = on and COLORS.Text or COLORS.Sub,
        })
    end
end

for sea, b in pairs(tabs) do
    b.MouseButton1Click:Connect(function()
        selectedSea = sea
        setTabs()
        buildRows(sea)
        scanNow = true
    end)
end

----------------------------------------------------------------
-- SCAN / UPDATE
----------------------------------------------------------------
local function isSpawned(ev)
    local found = workspace:FindFirstChild(ev.WorkspaceName, true)
    if not found then return false end
    local hum = found:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health <= 0 then return false end
    return true
end

local function applyRow(r, on)
    local col = on and COLORS.Green or COLORS.Off
    r.dot.BackgroundColor3 = col
    r.status.TextColor3 = col
    r.status.Text = on and "ĐÃ SPAWN" or "CHƯA SPAWN"
end

local beliObj, gemObj

local function updateStats()
    beliObj = (beliObj and beliObj.Parent) and beliObj or findValue({"Beli", "Money", "Cash"})
    gemObj = (gemObj and gemObj.Parent) and gemObj or findValue({"Gems", "Gem"})
    local b = beliObj and beliObj.Value or 0
    local g = gemObj and gemObj.Value or 0
    beliVal.Text = fmt(b)
    gemVal.Text = fmt(g)
    islandBeli.Text = '<font color="#DC1E2D">B</font> ' .. fmt(b)
    islandGems.Text = '<font color="#DC1E2D">G</font> ' .. fmt(g)
end

local function updateBosses()
    -- menu: chỉ hiển thị Sea đang chọn
    for _, r in ipairs(rows) do
        applyRow(r, isSpawned(r.data))
    end
    -- island: đếm theo Sea hiện tại của người chơi
    local sea = detectSea()
    if sea < 2 then sea = 2 end
    local data = SeaEvents["Sea" .. sea] or {}
    local active = 0
    for _, ev in ipairs(data) do
        if isSpawned(ev) then active = active + 1 end
    end
    islandCount.Text = tostring(active)
    islandDot.BackgroundColor3 = active > 0 and COLORS.Green or COLORS.Off
end

task.spawn(function()
    local acc = SCAN_INTERVAL
    while gui.Parent do
        local dt = task.wait(0.25)
        acc = acc + dt
        if acc >= SCAN_INTERVAL or scanNow then
            acc = 0
            scanNow = false
            pcall(updateStats)
            pcall(updateBosses)
        end
    end
end)

----------------------------------------------------------------
-- AVATAR
----------------------------------------------------------------
task.spawn(function()
    local ok, img = pcall(function()
        return Players:GetUserThumbnailAsync(
            player.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size150x150
        )
    end)
    if ok and img then
        avatarSmall.Image = img
        avatarBig.Image = img
    end
end)

----------------------------------------------------------------
-- OPEN / CLOSE (Island <-> Menu)
----------------------------------------------------------------
local isOpen = false
local busy = false

local function openMenu()
    if isOpen or busy then return end
    busy, isOpen = true, true
    baseScale = fitScale()

    -- 1) Island đóng (thu lại rồi trượt lên)
    tween(islandContent, 0.15, {GroupTransparency = 1})
    tween(island, 0.35, {
        Size = UDim2.fromOffset(40, 40),
        Position = UDim2.new(0.5, 0, 0, -50),
    }, Enum.EasingStyle.Back, Enum.EasingDirection.In)

    -- 2) Menu mở
    menu.Visible = true
    menuScale.Scale = 0.85 * baseScale
    tween(menu, 0.35, {GroupTransparency = 0})
    tween(menuScale, 0.4, {Scale = baseScale}, Enum.EasingStyle.Back)

    task.delay(0.4, function()
        island.Visible = false
        busy = false
    end)
end

local function closeMenu()
    if not isOpen or busy then return end
    busy, isOpen = true, false

    -- 1) Menu đóng
    tween(menu, 0.25, {GroupTransparency = 1})
    tween(menuScale, 0.25, {Scale = 0.85 * baseScale}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

    -- 2) Island mở (bung từ trên xuống)
    island.Visible = true
    island.Size = UDim2.fromOffset(40, 40)
    island.Position = UDim2.new(0.5, 0, 0, -50)
    islandContent.GroupTransparency = 1
    task.delay(0.15, function()
        tween(island, 0.5, {Size = ISLAND_SIZE, Position = ISLAND_POS}, Enum.EasingStyle.Back)
        tween(islandContent, 0.35, {GroupTransparency = 0})
    end)

    task.delay(0.3, function()
        menu.Visible = false
        busy = false
    end)
end

local function toggle()
    if isOpen then closeMenu() else openMenu() end
end

island.MouseButton1Click:Connect(openMenu)
closeBtn.MouseButton1Click:Connect(closeMenu)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == TOGGLE_KEY then toggle() end
end)

-- Hiệu ứng hover island
island.MouseEnter:Connect(function()
    if not isOpen then tween(island, 0.2, {Size = UDim2.fromOffset(342, 42)}) end
end)
island.MouseLeave:Connect(function()
    if not isOpen then tween(island, 0.2, {Size = ISLAND_SIZE}) end
end)

-- Khởi tạo
buildRows(selectedSea)
setTabs()
updateStats()
updateBosses()

-- Island xuất hiện lúc đầu
island.Size = UDim2.fromOffset(40, 40)
island.Position = UDim2.new(0.5, 0, 0, -50)
islandContent.GroupTransparency = 1
task.delay(0.2, function()
    tween(island, 0.6, {Size = ISLAND_SIZE, Position = ISLAND_POS}, Enum.EasingStyle.Back)
    tween(islandContent, 0.4, {GroupTransparency = 0})
end)

return gui

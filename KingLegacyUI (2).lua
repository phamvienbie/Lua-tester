--[[
    King Legacy UI v2 - Dynamic Island + Menu (Đen / Đỏ)
    - Island: viền sáng chạy vòng, avatar có vòng xoay, chấm LIVE nhấp nháy, số tăng mượt
    - Menu: nền mờ + blur, hạt lửa bay, header lướt sáng, tab trượt, thanh tiến độ boss
    - Boss row: icon theo loại, trượt vào lần lượt, flash khi spawn, viền xanh khi đã spawn
    - Bấm Island / RightControl -> mở menu | X / RightControl / bấm ngoài -> đóng
    - Đọc dữ liệu từ file SeaEvents
]]

----------------------------------------------------------------
-- LOAD FILE SEA EVENT
----------------------------------------------------------------
local SeaEvents
do
    local ok, genv = pcall(function() return getgenv and getgenv().SeaEvents end)
    if ok and genv then
        SeaEvents = genv
    end
    if not SeaEvents and readfile and isfile and isfile("SeaEvents.lua") then
        local f = loadstring(readfile("SeaEvents.lua"))
        if f then SeaEvents = f() end
    end
    if not SeaEvents and script and script.Parent then
        local m = script.Parent:FindFirstChild("SeaEvents")
        if m and m:IsA("ModuleScript") then SeaEvents = require(m) end
    end
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
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer

----------------------------------------------------------------
-- CONFIG
----------------------------------------------------------------
local TOGGLE_KEY = Enum.KeyCode.RightControl
local SCAN_INTERVAL = 1.5
local MENU_W, MENU_H = 540, 400

local COLORS = {
    Black = Color3.fromRGB(10, 10, 12),
    Dark = Color3.fromRGB(16, 16, 20),
    Panel = Color3.fromRGB(22, 22, 27),
    Row = Color3.fromRGB(26, 26, 32),
    Red = Color3.fromRGB(220, 30, 45),
    BrightRed = Color3.fromRGB(255, 70, 85),
    DarkRed = Color3.fromRGB(120, 15, 25),
    Text = Color3.fromRGB(240, 240, 240),
    Sub = Color3.fromRGB(150, 150, 158),
    Green = Color3.fromRGB(46, 220, 110),
    GreenDark = Color3.fromRGB(16, 54, 34),
    Off = Color3.fromRGB(235, 50, 60),
    OffDark = Color3.fromRGB(46, 16, 20),
    Line = Color3.fromRGB(42, 42, 50),
    Gold = Color3.fromRGB(255, 200, 60),
    Cyan = Color3.fromRGB(90, 200, 255),
}

local TYPE_STYLE = {
    {key = "boss", letter = "B", color = Color3.fromRGB(235, 50, 60)},
    {key = "ship", letter = "S", color = Color3.fromRGB(255, 150, 60)},
    {key = "island", letter = "I", color = Color3.fromRGB(80, 170, 255)},
    {key = "portal", letter = "P", color = Color3.fromRGB(170, 110, 255)},
}

local function styleFor(typeStr)
    local t = (typeStr or ""):lower()
    for _, s in ipairs(TYPE_STYLE) do
        if t:find(s.key, 1, true) then return s end
    end
    return {letter = "?", color = COLORS.Red}
end

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

-- gradient xoay (dùng cho viền chạy vòng)
local spinners = {}
local function spinGradient(speed, color)
    local g = new("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, color or COLORS.BrightRed),
            ColorSequenceKeypoint.new(0.5, COLORS.DarkRed),
            ColorSequenceKeypoint.new(1, color or COLORS.BrightRed),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.5, 0.85),
            NumberSequenceKeypoint.new(1, 0),
        }),
    })
    table.insert(spinners, {g = g, speed = speed})
    return g
end

local function stroke(color, th, tr, spinSpeed)
    local s = new("UIStroke", {
        Color = color,
        Thickness = th or 1,
        Transparency = tr or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
    if spinSpeed then
        spinGradient(spinSpeed).Parent = s
    end
    return s
end

local function vGradient(c1, c2, rot)
    return new("UIGradient", {Color = ColorSequence.new(c1, c2), Rotation = rot or 90})
end

-- số tăng/giảm mượt
local numTokens = {}
local function animateNumber(lbl, from, to, formatFn, dur)
    numTokens[lbl] = (numTokens[lbl] or 0) + 1
    local my = numTokens[lbl]
    dur = dur or 0.7
    task.spawn(function()
        local t0 = os.clock()
        while true do
            if numTokens[lbl] ~= my or not lbl.Parent then return end
            local a = math.clamp((os.clock() - t0) / dur, 0, 1)
            local e = 1 - (1 - a) ^ 3
            lbl.Text = formatFn(from + (to - from) * e)
            if a >= 1 then return end
            RunService.RenderStepped:Wait()
        end
    end)
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

local blur
pcall(function()
    local o = Lighting:FindFirstChild("KingLegacyBlur")
    if o then o:Destroy() end
    blur = Instance.new("BlurEffect")
    blur.Name = "KingLegacyBlur"
    blur.Size = 0
    blur.Parent = Lighting
end)

local gui = new("ScreenGui", {
    Name = "KingLegacyUI",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    DisplayOrder = 999,
})
gui.Parent = parent

gui.Destroying:Connect(function()
    if blur then pcall(function() blur:Destroy() end) end
end)

-- xoay gradient viền
RunService.Heartbeat:Connect(function(dt)
    if not gui.Parent then return end
    for _, s in ipairs(spinners) do
        if s.g.Parent then
            s.g.Rotation = (s.g.Rotation + s.speed * dt) % 360
        end
    end
end)

-- lớp tối phía sau menu (bấm ra ngoài để đóng)
local overlay = new("TextButton", {
    Name = "Overlay",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.new(0, 0, 0),
    BackgroundTransparency = 1,
    Text = "",
    AutoButtonColor = false,
    Visible = false,
    ZIndex = 1,
})
overlay.Parent = gui

----------------------------------------------------------------
-- DYNAMIC ISLAND
----------------------------------------------------------------
local ISLAND_SIZE = UDim2.fromOffset(330, 40)
local ISLAND_POS = UDim2.new(0.5, 0, 0, 12)

local islandStroke = stroke(COLORS.Red, 1.6, 0, 120)

local island = new("TextButton", {
    Name = "Island",
    AnchorPoint = Vector2.new(0.5, 0),
    Position = ISLAND_POS,
    Size = ISLAND_SIZE,
    BackgroundColor3 = COLORS.Black,
    Text = "",
    AutoButtonColor = false,
    ClipsDescendants = true,
    ZIndex = 3,
}, {
    corner(UDim.new(1, 0)),
    islandStroke,
    vGradient(Color3.fromRGB(24, 24, 29), Color3.fromRGB(6, 6, 8), 90),
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
}, {corner(UDim.new(1, 0)), stroke(COLORS.Red, 1.5, 0, 200)})
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

local function islandStat(x, w)
    local l = new("TextLabel", {
        Position = UDim2.fromOffset(x, 0),
        Size = UDim2.fromOffset(w, 40),
        BackgroundTransparency = 1,
        Text = "0",
        RichText = true,
        TextColor3 = COLORS.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    l.Parent = islandContent
    return l
end
local islandBeli = islandStat(142, 78)
local islandGems = islandStat(222, 58)

-- chấm LIVE + vòng sóng
local islandRing = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0, 293, 0.5, 0),
    Size = UDim2.fromOffset(10, 10),
    BackgroundTransparency = 1,
}, {corner(UDim.new(1, 0))})
local islandRingStroke = stroke(COLORS.Off, 1.5, 0.2)
islandRingStroke.Parent = islandRing
islandRing.Parent = islandContent

local islandDot = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0, 293, 0.5, 0),
    Size = UDim2.fromOffset(10, 10),
    BackgroundColor3 = COLORS.Off,
}, {corner(UDim.new(1, 0))})
islandDot.Parent = islandContent

do
    local info = TweenInfo.new(1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1)
    TweenService:Create(islandRing, info, {Size = UDim2.fromOffset(26, 26)}):Play()
    TweenService:Create(islandRingStroke, info, {Transparency = 1}):Play()
end

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
local menuStroke = stroke(COLORS.Red, 2, 0, 90)

local menu = new("CanvasGroup", {
    Name = "Menu",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(MENU_W, MENU_H),
    BackgroundColor3 = COLORS.Black,
    GroupTransparency = 1,
    Visible = false,
    ZIndex = 2,
}, {
    corner(UDim.new(0, 18)),
    menuStroke,
    vGradient(Color3.fromRGB(20, 20, 25), Color3.fromRGB(7, 7, 9), 90),
})
menu.Parent = gui

local menuScale = new("UIScale", {Scale = 0.85})
menuScale.Parent = menu

local function fitScale()
    local cam = workspace.CurrentCamera
    if not cam then return 1 end
    local v = cam.ViewportSize
    return math.min(1, (v.X - 20) / MENU_W, (v.Y - 20) / MENU_H)
end
local baseScale = fitScale()

-- Lớp hiệu ứng (hạt lửa) nằm dưới nội dung
local fx = new("Frame", {
    Name = "Fx",
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    ClipsDescendants = true,
    ZIndex = 0,
})
fx.Parent = menu

-- Header
local header = new("Frame", {
    Size = UDim2.new(1, 0, 0, 52),
    BackgroundColor3 = COLORS.DarkRed,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 3,
}, {
    new("UIGradient", {
        Color = ColorSequence.new(COLORS.Red, COLORS.Black),
        Rotation = 0,
        Transparency = NumberSequence.new(0.1, 0.65),
    }),
})
header.Parent = menu

-- đường kẻ sáng dưới header
new("Frame", {
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.fromScale(0, 1),
    Size = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = COLORS.BrightRed,
    BackgroundTransparency = 0.45,
    BorderSizePixel = 0,
}).Parent = header

-- vệt sáng quét qua header
local shimmer = new("Frame", {
    Position = UDim2.new(0, -100, 0, -30),
    Size = UDim2.fromOffset(60, 130),
    Rotation = 20,
    BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0,
}, {
    new("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0.86),
            NumberSequenceKeypoint.new(1, 1),
        }),
    }),
})
shimmer.Parent = header

-- logo kim cương
local logo = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromOffset(30, 26),
    Size = UDim2.fromOffset(18, 18),
    Rotation = 45,
    BackgroundColor3 = COLORS.Red,
}, {
    corner(UDim.new(0, 4)),
    vGradient(COLORS.BrightRed, COLORS.DarkRed, 45),
    stroke(Color3.fromRGB(255, 190, 195), 1, 0.4),
})
logo.Parent = header

new("TextLabel", {
    Position = UDim2.fromOffset(52, 7),
    Size = UDim2.new(1, -110, 0, 24),
    BackgroundTransparency = 1,
    Text = "KING LEGACY",
    TextColor3 = COLORS.Text,
    Font = Enum.Font.GothamBlack,
    TextSize = 17,
    TextXAlignment = Enum.TextXAlignment.Left,
}).Parent = header

new("TextLabel", {
    Position = UDim2.fromOffset(52, 29),
    Size = UDim2.new(1, -110, 0, 16),
    BackgroundTransparency = 1,
    Text = "SEA EVENT TRACKER",
    TextColor3 = Color3.fromRGB(255, 160, 168),
    Font = Enum.Font.GothamMedium,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
}).Parent = header

local closeBtn = new("TextButton", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -12, 0.5, 0),
    Size = UDim2.fromOffset(30, 30),
    BackgroundColor3 = COLORS.Black,
    Text = "X",
    TextColor3 = COLORS.Red,
    Font = Enum.Font.GothamBlack,
    TextSize = 15,
    AutoButtonColor = false,
    ZIndex = 4,
}, {corner(UDim.new(1, 0)), stroke(COLORS.Red, 1.5)})
closeBtn.Parent = header

closeBtn.MouseEnter:Connect(function()
    tween(closeBtn, 0.2, {BackgroundColor3 = COLORS.Red, TextColor3 = COLORS.Text, Rotation = 90})
end)
closeBtn.MouseLeave:Connect(function()
    tween(closeBtn, 0.2, {BackgroundColor3 = COLORS.Black, TextColor3 = COLORS.Red, Rotation = 0})
end)

-- Profile card
local profile = new("Frame", {
    Position = UDim2.fromOffset(14, 62),
    Size = UDim2.new(1, -28, 0, 84),
    BackgroundColor3 = COLORS.Panel,
    BackgroundTransparency = 0.05,
    ZIndex = 2,
}, {
    corner(UDim.new(0, 14)),
    stroke(COLORS.DarkRed, 1),
    new("UIGradient", {
        Color = ColorSequence.new(Color3.fromRGB(42, 20, 26), Color3.fromRGB(20, 20, 25)),
        Rotation = 0,
    }),
})
profile.Parent = menu

local avatarBig = new("ImageLabel", {
    Position = UDim2.fromOffset(10, 10),
    Size = UDim2.fromOffset(64, 64),
    BackgroundColor3 = COLORS.Black,
    Image = "",
}, {corner(UDim.new(1, 0)), stroke(COLORS.Red, 2.5, 0, 160)})
avatarBig.Parent = profile

new("TextLabel", {
    Position = UDim2.fromOffset(88, 10),
    Size = UDim2.new(0.5, -88, 0, 24),
    BackgroundTransparency = 1,
    Text = player.DisplayName,
    TextColor3 = COLORS.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 17,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
}).Parent = profile

new("TextLabel", {
    Position = UDim2.fromOffset(88, 33),
    Size = UDim2.new(0.5, -88, 0, 16),
    BackgroundTransparency = 1,
    Text = "@" .. player.Name,
    TextColor3 = COLORS.Sub,
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
}).Parent = profile

local seaBadge = new("Frame", {
    Position = UDim2.fromOffset(88, 54),
    Size = UDim2.fromOffset(62, 20),
    BackgroundColor3 = COLORS.DarkRed,
}, {corner(UDim.new(1, 0)), stroke(COLORS.Red, 1, 0.3), vGradient(COLORS.Red, COLORS.DarkRed, 90)})
seaBadge.Parent = profile

local seaLabel = new("TextLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Text = "SEA " .. detectSea(),
    TextColor3 = COLORS.Text,
    Font = Enum.Font.GothamBlack,
    TextSize = 11,
})
seaLabel.Parent = seaBadge

local function statBox(posY, title, accent)
    local box = new("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -12, 0, posY),
        Size = UDim2.fromOffset(176, 30),
        BackgroundColor3 = COLORS.Black,
    }, {
        corner(UDim.new(0, 9)),
        stroke(COLORS.Line, 1),
    })
    box.Parent = profile
    -- thanh màu bên trái
    new("Frame", {
        Position = UDim2.fromOffset(0, 5),
        Size = UDim2.new(0, 3, 1, -10),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
    }, {corner(UDim.new(1, 0))}).Parent = box
    new("TextLabel", {
        Position = UDim2.fromOffset(14, 0),
        Size = UDim2.new(0, 46, 1, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = accent,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }).Parent = box
    local val = new("TextLabel", {
        Position = UDim2.fromOffset(60, 0),
        Size = UDim2.new(1, -70, 1, 0),
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

local beliVal = statBox(10, "BELI", COLORS.Gold)
local gemVal = statBox(44, "GEMS", COLORS.Cyan)

-- Boss section
local bossTitle = new("TextLabel", {
    Position = UDim2.fromOffset(18, 156),
    Size = UDim2.fromOffset(140, 26),
    BackgroundTransparency = 1,
    Text = "TRẠNG THÁI BOSS",
    TextColor3 = COLORS.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 2,
})
bossTitle.Parent = menu

local countLabel = new("TextLabel", {
    Position = UDim2.fromOffset(150, 156),
    Size = UDim2.fromOffset(120, 26),
    BackgroundTransparency = 1,
    Text = "0 / 0",
    TextColor3 = COLORS.Sub,
    Font = Enum.Font.GothamMedium,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 2,
})
countLabel.Parent = menu

-- Tabs (có thanh trượt)
local tabs = {}
local scanNow = true
local selectedSea = detectSea()
if selectedSea < 2 then selectedSea = 2 end

local tabHolder = new("Frame", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -14, 0, 156),
    Size = UDim2.fromOffset(150, 26),
    BackgroundColor3 = COLORS.Black,
    ZIndex = 2,
}, {corner(UDim.new(1, 0)), stroke(COLORS.DarkRed, 1)})
tabHolder.Parent = menu

local TAB_POS = {
    [2] = UDim2.new(0, 2, 0, 2),
    [3] = UDim2.new(0.5, 0, 0, 2),
}

local tabIndicator = new("Frame", {
    Position = TAB_POS[selectedSea],
    Size = UDim2.new(0.5, -2, 1, -4),
    BackgroundColor3 = COLORS.Red,
    ZIndex = 2,
}, {corner(UDim.new(1, 0)), vGradient(COLORS.BrightRed, COLORS.DarkRed, 90)})
tabIndicator.Parent = tabHolder

local function makeTab(sea, xScale)
    local b = new("TextButton", {
        Position = UDim2.fromScale(xScale, 0),
        Size = UDim2.fromScale(0.5, 1),
        BackgroundTransparency = 1,
        Text = "Sea " .. sea,
        TextColor3 = COLORS.Sub,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        AutoButtonColor = false,
        ZIndex = 3,
    })
    b.Parent = tabHolder
    tabs[sea] = b
    return b
end
makeTab(2, 0)
makeTab(3, 0.5)

-- Thanh tiến độ boss
local progressTrack = new("Frame", {
    Position = UDim2.fromOffset(18, 187),
    Size = UDim2.new(1, -36, 0, 4),
    BackgroundColor3 = COLORS.Line,
    BorderSizePixel = 0,
    ZIndex = 2,
}, {corner(UDim.new(1, 0))})
progressTrack.Parent = menu

local progressFill = new("Frame", {
    Size = UDim2.fromScale(0, 1),
    BackgroundColor3 = COLORS.Green,
    BorderSizePixel = 0,
    ZIndex = 2,
}, {
    corner(UDim.new(1, 0)),
    new("UIGradient", {Color = ColorSequence.new(Color3.fromRGB(30, 170, 90), Color3.fromRGB(120, 255, 170))}),
})
progressFill.Parent = progressTrack

local list = new("ScrollingFrame", {
    Position = UDim2.fromOffset(14, 200),
    Size = UDim2.new(1, -28, 1, -212),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = COLORS.Red,
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ZIndex = 2,
}, {
    new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}),
})
list.Parent = menu

----------------------------------------------------------------
-- BOSS ROWS
----------------------------------------------------------------
local rows = {}

local function buildRows(sea)
    for _, r in ipairs(list:GetChildren()) do
        if r:IsA("Frame") then r:Destroy() end
    end
    rows = {}
    local data = SeaEvents["Sea" .. sea] or {}
    for i, ev in ipairs(data) do
        local st = styleFor(ev.Type)

        local holder = new("Frame", {
            LayoutOrder = i,
            Size = UDim2.new(1, -6, 0, 46),
            BackgroundTransparency = 1,
        })
        holder.Parent = list

        local cardStroke = stroke(COLORS.Line, 1.2)
        local card = new("CanvasGroup", {
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromOffset(30, 0),
            BackgroundColor3 = COLORS.Row,
            GroupTransparency = 1,
        }, {corner(UDim.new(0, 12)), cardStroke})
        card.Parent = holder

        -- flash khi trạng thái đổi
        local flash = new("Frame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = COLORS.Green,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
        })
        flash.Parent = card

        -- icon theo loại
        local icon = new("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 9, 0.5, 0),
            Size = UDim2.fromOffset(30, 30),
            BackgroundColor3 = st.color,
        }, {
            corner(UDim.new(0, 9)),
            vGradient(st.color, st.color:Lerp(Color3.new(0, 0, 0), 0.55), 60),
            stroke(st.color:Lerp(Color3.new(1, 1, 1), 0.4), 1, 0.5),
        })
        icon.Parent = card
        new("TextLabel", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = st.letter,
            TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.GothamBlack,
            TextSize = 15,
        }).Parent = icon

        new("TextLabel", {
            Position = UDim2.fromOffset(50, 4),
            Size = UDim2.new(1, -176, 0, 20),
            BackgroundTransparency = 1,
            Text = ev.Name,
            TextColor3 = COLORS.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }).Parent = card

        new("TextLabel", {
            Position = UDim2.fromOffset(50, 24),
            Size = UDim2.new(1, -176, 0, 16),
            BackgroundTransparency = 1,
            Text = ev.Type or "",
            TextColor3 = COLORS.Sub,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        }).Parent = card

        -- pill trạng thái
        local pill = new("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -10, 0.5, 0),
            Size = UDim2.fromOffset(108, 26),
            BackgroundColor3 = COLORS.OffDark,
        }, {corner(UDim.new(1, 0))})
        pill.Parent = card

        local ring = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromOffset(15, 13),
            Size = UDim2.fromOffset(8, 8),
            BackgroundTransparency = 1,
            Visible = false,
        }, {corner(UDim.new(1, 0))})
        local ringStroke = stroke(COLORS.Green, 1.5, 0.2)
        ringStroke.Parent = ring
        ring.Parent = pill
        do
            local info = TweenInfo.new(1.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1)
            TweenService:Create(ring, info, {Size = UDim2.fromOffset(20, 20)}):Play()
            TweenService:Create(ringStroke, info, {Transparency = 1}):Play()
        end

        local dot = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromOffset(15, 13),
            Size = UDim2.fromOffset(8, 8),
            BackgroundColor3 = COLORS.Off,
        }, {corner(UDim.new(1, 0))})
        dot.Parent = pill

        local status = new("TextLabel", {
            Position = UDim2.fromOffset(26, 0),
            Size = UDim2.new(1, -32, 1, 0),
            BackgroundTransparency = 1,
            Text = "CHƯA SPAWN",
            TextColor3 = COLORS.Off,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
        })
        status.Parent = pill

        -- hover
        card.MouseEnter:Connect(function()
            tween(card, 0.15, {BackgroundColor3 = Color3.fromRGB(36, 36, 44)})
        end)
        card.MouseLeave:Connect(function()
            tween(card, 0.2, {BackgroundColor3 = COLORS.Row})
        end)

        -- xuất hiện lần lượt
        task.delay(0.05 + i * 0.05, function()
            if card.Parent then
                tween(card, 0.45, {Position = UDim2.fromOffset(0, 0), GroupTransparency = 0})
            end
        end)

        table.insert(rows, {
            dot = dot, ring = ring, ringStroke = ringStroke,
            status = status, pill = pill,
            card = card, cardStroke = cardStroke, flash = flash,
            data = ev, on = nil,
        })
    end
end

local function setTabs(animate)
    for sea, b in pairs(tabs) do
        local on = sea == selectedSea
        tween(b, 0.25, {TextColor3 = on and COLORS.Text or COLORS.Sub})
    end
    if TAB_POS[selectedSea] then
        tween(tabIndicator, animate and 0.35 or 0, {Position = TAB_POS[selectedSea]}, Enum.EasingStyle.Back)
    end
end

for sea, b in pairs(tabs) do
    b.MouseButton1Click:Connect(function()
        if selectedSea == sea then return end
        selectedSea = sea
        setTabs(true)
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
    if r.on == on then return end
    local initial = r.on == nil
    r.on = on

    local col = on and COLORS.Green or COLORS.Off
    tween(r.dot, 0.3, {BackgroundColor3 = col})
    tween(r.status, 0.3, {TextColor3 = col})
    tween(r.pill, 0.3, {BackgroundColor3 = on and COLORS.GreenDark or COLORS.OffDark})
    tween(r.cardStroke, 0.3, {Color = on and Color3.fromRGB(34, 130, 80) or COLORS.Line})
    r.status.Text = on and "ĐÃ SPAWN" or "CHƯA SPAWN"
    r.ring.Visible = on

    if not initial then
        r.flash.BackgroundColor3 = col
        r.flash.BackgroundTransparency = 0.6
        tween(r.flash, 0.8, {BackgroundTransparency = 1})
    end
end

local beliObj, gemObj
local shownBeli, shownGems = nil, nil

local function updateStats()
    beliObj = (beliObj and beliObj.Parent) and beliObj or findValue({"Beli", "Money", "Cash"})
    gemObj = (gemObj and gemObj.Parent) and gemObj or findValue({"Gems", "Gem"})
    local b = beliObj and beliObj.Value or 0
    local g = gemObj and gemObj.Value or 0

    if b ~= shownBeli then
        local from = shownBeli or 0
        shownBeli = b
        animateNumber(beliVal, from, b, fmt)
        animateNumber(islandBeli, from, b, function(v)
            return '<font color="#FFC83C">B</font> ' .. fmt(v)
        end)
    end
    if g ~= shownGems then
        local from = shownGems or 0
        shownGems = g
        animateNumber(gemVal, from, g, fmt)
        animateNumber(islandGems, from, g, function(v)
            return '<font color="#5AC8FF">G</font> ' .. fmt(v)
        end)
    end
end

local lastActiveIsland = nil

local function updateBosses()
    local activeMenu = 0
    for _, r in ipairs(rows) do
        local on = isSpawned(r.data)
        applyRow(r, on)
        if on then activeMenu = activeMenu + 1 end
    end

    -- đếm + thanh tiến độ của Sea đang xem
    local total = #rows
    countLabel.Text = activeMenu .. " / " .. total .. " đang spawn"
    countLabel.TextColor3 = activeMenu > 0 and COLORS.Green or COLORS.Sub
    tween(progressFill, 0.5, {Size = UDim2.fromScale(total > 0 and activeMenu / total or 0, 1)})

    -- island: đếm theo Sea hiện tại của người chơi
    local sea = detectSea()
    if sea < 2 then sea = 2 end
    local data = SeaEvents["Sea" .. sea] or {}
    local active = 0
    for _, ev in ipairs(data) do
        if isSpawned(ev) then active = active + 1 end
    end
    islandCount.Text = tostring(active)
    local col = active > 0 and COLORS.Green or COLORS.Off
    tween(islandDot, 0.3, {BackgroundColor3 = col})
    islandRingStroke.Color = col

    -- nảy nhẹ island khi số boss đổi
    if lastActiveIsland ~= nil and lastActiveIsland ~= active and island.Visible then
        tween(islandCount, 0.12, {TextSize = 17})
        task.delay(0.12, function()
            tween(islandCount, 0.3, {TextSize = 12}, Enum.EasingStyle.Back)
        end)
    end
    lastActiveIsland = active
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
-- HIỆU ỨNG NỀN MENU (hạt lửa + vệt sáng header)
----------------------------------------------------------------
for i = 1, 16 do
    local size = math.random(2, 4)
    local ember = new("Frame", {
        Size = UDim2.fromOffset(size, size),
        BackgroundColor3 = (i % 3 == 0) and COLORS.BrightRed or COLORS.Red,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 0,
    }, {corner(UDim.new(1, 0))})
    ember.Parent = fx

    task.spawn(function()
        task.wait(math.random() * 3)
        while gui.Parent do
            if not menu.Visible then
                task.wait(0.5)
            else
                local x = math.random()
                local dur = math.random(40, 75) / 10
                ember.Position = UDim2.new(x, 0, 1, 8)
                ember.BackgroundTransparency = 0.55
                tween(ember, dur, {
                    Position = UDim2.new(math.clamp(x + (math.random() - 0.5) * 0.15, 0, 1), 0, 0, -10),
                    BackgroundTransparency = 1,
                }, Enum.EasingStyle.Linear)
                task.wait(dur)
            end
        end
    end)
end

task.spawn(function()
    while gui.Parent do
        if menu.Visible then
            shimmer.Position = UDim2.new(0, -100, 0, -30)
            tween(shimmer, 1.3, {Position = UDim2.new(1, 40, 0, -30)}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(4.5)
        else
            task.wait(0.5)
        end
    end
end)

----------------------------------------------------------------
-- OPEN / CLOSE (Island <-> Menu)
----------------------------------------------------------------
local isOpen = false
local busy = false

local function setBackdrop(on)
    if on then
        overlay.Visible = true
        tween(overlay, 0.4, {BackgroundTransparency = 0.55})
        if blur then tween(blur, 0.4, {Size = 12}) end
    else
        tween(overlay, 0.3, {BackgroundTransparency = 1})
        if blur then tween(blur, 0.3, {Size = 0}) end
        task.delay(0.3, function()
            if not isOpen then overlay.Visible = false end
        end)
    end
end

local function openMenu()
    if isOpen or busy then return end
    busy, isOpen = true, true
    baseScale = fitScale()

    -- 1) Island thu lại rồi trượt lên
    tween(islandContent, 0.15, {GroupTransparency = 1})
    tween(island, 0.35, {
        Size = UDim2.fromOffset(40, 40),
        Position = UDim2.new(0.5, 0, 0, -50),
    }, Enum.EasingStyle.Back, Enum.EasingDirection.In)

    -- 2) Nền tối + blur, menu bung ra
    setBackdrop(true)
    menu.Visible = true
    menuScale.Scale = 0.8 * baseScale
    menu.Rotation = -2
    tween(menu, 0.35, {GroupTransparency = 0})
    tween(menuScale, 0.5, {Scale = baseScale}, Enum.EasingStyle.Back)
    tween(menu, 0.5, {Rotation = 0}, Enum.EasingStyle.Back)

    -- 3) Chạy lại hiệu ứng danh sách + thanh tiến độ
    progressFill.Size = UDim2.fromScale(0, 1)
    buildRows(selectedSea)
    setTabs(false)
    scanNow = true

    task.delay(0.4, function()
        island.Visible = false
        busy = false
    end)
end

local function closeMenu()
    if not isOpen or busy then return end
    busy, isOpen = true, false

    setBackdrop(false)
    tween(menu, 0.25, {GroupTransparency = 1})
    tween(menuScale, 0.25, {Scale = 0.85 * baseScale}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

    -- Island bung từ trên xuống
    island.Visible = true
    island.Size = UDim2.fromOffset(40, 40)
    island.Position = UDim2.new(0.5, 0, 0, -50)
    islandContent.GroupTransparency = 1
    task.delay(0.15, function()
        tween(island, 0.55, {Size = ISLAND_SIZE, Position = ISLAND_POS}, Enum.EasingStyle.Back)
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
overlay.MouseButton1Click:Connect(closeMenu)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == TOGGLE_KEY then toggle() end
end)

-- Hiệu ứng hover / nhấn island
island.MouseEnter:Connect(function()
    if not isOpen then
        tween(island, 0.25, {Size = UDim2.fromOffset(344, 43)}, Enum.EasingStyle.Back)
        tween(islandStroke, 0.25, {Thickness = 2.4})
    end
end)
island.MouseLeave:Connect(function()
    if not isOpen then
        tween(island, 0.25, {Size = ISLAND_SIZE})
        tween(islandStroke, 0.25, {Thickness = 1.6})
    end
end)
island.MouseButton1Down:Connect(function()
    if not isOpen then tween(island, 0.1, {Size = UDim2.fromOffset(318, 37)}) end
end)

-- Khởi tạo
buildRows(selectedSea)
setTabs(false)
updateStats()
updateBosses()
for _, r in ipairs(rows) do
    -- menu đang ẩn: hiện ngay không chờ
    r.card.Position = UDim2.fromOffset(0, 0)
    r.card.GroupTransparency = 0
end

-- Island xuất hiện lúc đầu
island.Size = UDim2.fromOffset(40, 40)
island.Position = UDim2.new(0.5, 0, 0, -50)
islandContent.GroupTransparency = 1
task.delay(0.2, function()
    tween(island, 0.7, {Size = ISLAND_SIZE, Position = ISLAND_POS}, Enum.EasingStyle.Back)
    tween(islandContent, 0.5, {GroupTransparency = 0})
end)

return gui

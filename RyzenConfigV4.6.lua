--[[
	RYZEN CONFIG V4.6  |  Dynamic Island HUD  |  by Kaibeo  |  LocalScript
	Place in: StarterPlayer > StarterPlayerScripts (or StarterGui)

	Features
	- Loading effect inside the main UI (CPU chip, circuit traces, electric arcs, code rain, boot terminal)
	- The UI is OPEN by default (CFG.StartOpen)
	- Dynamic Island pill on the RIGHT side of the screen -> tap to expand a wide (landscape) panel
	- Profile (display name, username, ID, avatar) + Sea 1 / 2 / 3 detection by PlaceId
	- Player stats: Level, Beli, Fragments (Blox Fruits: player.Data.*)
	- Session time + Global time with region selector (UTC, ICT, JST, SGT, EST/EDT, PST/PDT)
	- Live FPS + Ping counters with mini bar charts
	- Load notification toast + scrolling marquee banner
	- The island itself is the ONLY toggle (no extra function buttons)
]]

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")
local Workspace = game:GetService("Workspace")
local TextService = game:GetService("TextService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = Workspace.CurrentCamera or Workspace:GetPropertyChangedSignal("CurrentCamera"):Wait()
camera = Workspace.CurrentCamera

--// SEA DETECTION (by PlaceId)
local World1 = game.PlaceId == 2753915549 or game.PlaceId == 85211729168715
local World2 = game.PlaceId == 4442272183 or game.PlaceId == 79091703265657
local World3 = game.PlaceId == 7449423635 or game.PlaceId == 100117331123089

local seaText = "UNKNOWN"
if World1 then
	seaText = "SEA 1"
elseif World2 then
	seaText = "SEA 2"
elseif World3 then
	seaText = "SEA 3"
end

--// CONFIG
local CFG = {
	Name = "Ryzen Config V4.6",
	Credit = "Kaibeo",
	-- Vietnamese alternative: "Cảm ơn bạn đã sử dụng config banana by Kaibeo"
	MarqueeText = "Thank you for using Banana Config by Kaibeo",
	MarqueeSpeed = 55, -- pixels per second
	NotifyDuration = 4, -- seconds the load toast stays visible

	LoadingScreen = true, -- loading effect shown INSIDE the main UI (not full-screen)
	StartOpen = true, -- the UI starts expanded (open) and stays open after loading

	-- Island placement (right side of the screen)
	CollapsedSize = Vector2.new(290, 42),
	ExpandedSize = Vector2.new(780, 372),
	HeaderHeight = 42,
	MarginRight = 16, -- pixels from the right edge
	PositionY = 0.5, -- 0 = top, 0.5 = middle, 1 = bottom (screen fraction)

	SampleInterval = 0.25, -- seconds between chart samples
	HistoryLength = 48, -- bars per chart
}

--// THEME
local THEME = {
	Background = Color3.fromRGB(4, 5, 8),
	Card = Color3.fromRGB(12, 15, 21),
	CardAlt = Color3.fromRGB(20, 26, 35),
	Cyan = Color3.fromRGB(0, 229, 255),
	Sky = Color3.fromRGB(135, 206, 250),
	White = Color3.fromRGB(240, 248, 255),
	Muted = Color3.fromRGB(128, 150, 168),
	Warn = Color3.fromRGB(255, 196, 72),
	Bad = Color3.fromRGB(255, 82, 96),
	Beli = Color3.fromRGB(80, 255, 170),
	Fragment = Color3.fromRGB(205, 130, 255),
}

local BORDER_COLORS = ColorSequence.new({
	ColorSequenceKeypoint.new(0, THEME.Cyan),
	ColorSequenceKeypoint.new(0.35, THEME.Sky),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(235, 252, 255)),
	ColorSequenceKeypoint.new(0.65, THEME.Sky),
	ColorSequenceKeypoint.new(1, THEME.Cyan),
})
-- Bright "comet" on one side, faint on the other -> looks like a running light when rotated
local BORDER_TRANSPARENCY = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.75),
	NumberSequenceKeypoint.new(0.5, 0),
	NumberSequenceKeypoint.new(1, 0.75),
})

--// HELPERS
local function create(class, props, parent)
	local inst = Instance.new(class)
	for k, v in pairs(props) do
		inst[k] = v
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

local function corner(parent, radius)
	return create("UICorner", { CornerRadius = UDim.new(0, radius) }, parent)
end

local function stroke(parent, color, thickness, transparency)
	return create("UIStroke", {
		Color = color,
		Thickness = thickness,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, parent)
end

local function label(parent, props)
	local l = create("TextLabel", {
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		TextColor3 = THEME.White,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Text = "",
	})
	for k, v in pairs(props) do
		l[k] = v
	end
	l.Parent = parent
	return l
end

local function rgbTag(c)
	return string.format("rgb(%d,%d,%d)", math.floor(c.R * 255), math.floor(c.G * 255), math.floor(c.B * 255))
end

local function formatDuration(seconds)
	local h = math.floor(seconds / 3600)
	local m = math.floor((seconds % 3600) / 60)
	local s = math.floor(seconds % 60)
	return string.format("%02d:%02d:%02d", h, m, s)
end

local function formatNumber(n) -- 1234567 -> "1,234,567"
	if typeof(n) ~= "number" then
		return "N/A"
	end
	local s = tostring(math.floor(n + 0.5))
	local out, count = "", 0
	for i = #s, 1, -1 do
		out = s:sub(i, i) .. out
		count += 1
		if count % 3 == 0 and i > 1 then
			out = "," .. out
		end
	end
	return out
end

--// TIME ZONE LOGIC
local REGIONS = {
	{ id = "UTC", place = "Universal", offset = 0 },
	{ id = "ICT", place = "Vietnam", offset = 7 },
	{ id = "JST", place = "Japan", offset = 9 },
	{ id = "SGT", place = "Singapore", offset = 8 },
	{ id = "EST", dstId = "EDT", place = "New York", offset = -5, usDST = true },
	{ id = "PST", dstId = "PDT", place = "Los Angeles", offset = -8, usDST = true },
}

local function dayOfWeek(y, m, d) -- 0 = Sunday
	local t = { 0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4 }
	if m < 3 then
		y -= 1
	end
	return (y + y // 4 - y // 100 + y // 400 + t[m] + d) % 7
end

local function nthSunday(year, month, n)
	local first = (7 - dayOfWeek(year, month, 1)) % 7 + 1
	return first + (n - 1) * 7
end

-- US daylight saving: 2nd Sunday of March -> 1st Sunday of November
local function isUSDST(utc, stdOffset)
	local d = os.date("!*t", utc + stdOffset * 3600)
	if d.month < 3 or d.month > 11 then
		return false
	end
	if d.month > 3 and d.month < 11 then
		return true
	end
	if d.month == 3 then
		local s = nthSunday(d.year, 3, 2)
		return d.day > s or (d.day == s and d.hour >= 2)
	end
	local e = nthSunday(d.year, 11, 1)
	return d.day < e or (d.day == e and d.hour < 1)
end

local function getRegionTime(region)
	local utc = os.time()
	local offset, abbr = region.offset, region.id
	if region.usDST and isUSDST(utc, region.offset) then
		offset += 1
		abbr = region.dstId
	end
	local t = utc + offset * 3600
	local sign = offset >= 0 and "+" or "-"
	local clock = os.date("!%H:%M:%S", t)
	local date = os.date("!%a, %d %b", t) .. "  •  UTC" .. sign .. math.abs(offset)
	return clock, date, abbr
end

--// ROOT GUI
for _, name in ipairs({ "RyzenConfigUI", "RyzenConfigLoading" }) do
	local old = playerGui:FindFirstChild(name)
	if old then
		old:Destroy()
	end
end

local gui = create("ScreenGui", {
	Name = "RyzenConfigUI",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	DisplayOrder = 100,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

local animatedGradients = {} -- gradients rotated every frame

local function neonGradient(strokeInst)
	local g = create("UIGradient", {
		Color = BORDER_COLORS,
		Transparency = BORDER_TRANSPARENCY,
	}, strokeInst)
	table.insert(animatedGradients, g)
	return g
end

--// ISLAND WRAPPER (anchored to the right edge; this is what gets resized)
local island = create("Frame", {
	Name = "Island",
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -CFG.MarginRight, CFG.PositionY, 0),
	Size = UDim2.fromOffset(CFG.CollapsedSize.X, CFG.CollapsedSize.Y),
	BackgroundTransparency = 1,
}, gui)
create("UISizeConstraint", { MinSize = Vector2.new(150, 36), MaxSize = Vector2.new(920, 700) }, island)
local uiScale = create("UIScale", { Scale = 1 }, island)

-- Outer glow (soft thick stroke behind the body)
local glow = create("Frame", {
	Name = "Glow",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.new(1, 10, 1, 10),
	BackgroundTransparency = 1,
	ZIndex = 0,
}, island)
local glowCorner = corner(glow, 26)
local glowStroke = stroke(glow, Color3.new(1, 1, 1), 6, 0.8)
neonGradient(glowStroke)

-- Body
local body = create("Frame", {
	Name = "Body",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = THEME.Background,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	ZIndex = 1,
}, island)
local bodyCorner = corner(body, CFG.CollapsedSize.Y / 2)
local bodyStroke = stroke(body, Color3.new(1, 1, 1), 2.2, 0)
neonGradient(bodyStroke)

-- Inner glow (subtle cyan tint from the top and bottom edges)
local innerGlow = create("Frame", {
	Name = "InnerGlow",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = THEME.Cyan,
	BorderSizePixel = 0,
	ZIndex = 1,
}, body)
corner(innerGlow, 30)
create("UIGradient", {
	Rotation = 90,
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.86),
		NumberSequenceKeypoint.new(0.4, 1),
		NumberSequenceKeypoint.new(0.75, 1),
		NumberSequenceKeypoint.new(1, 0.9),
	}),
}, innerGlow)

--// HEADER (always visible: collapsed pill content)
local header = create("Frame", {
	Name = "Header",
	Size = UDim2.new(1, 0, 0, CFG.HeaderHeight),
	BackgroundTransparency = 1,
	ZIndex = 2,
}, body)

local dot = create("Frame", {
	Position = UDim2.fromOffset(16, (CFG.HeaderHeight - 8) / 2),
	Size = UDim2.fromOffset(8, 8),
	BackgroundColor3 = THEME.Cyan,
	BorderSizePixel = 0,
}, header)
corner(dot, 4)

label(header, {
	Name = "SeaHeader",
	Text = seaText,
	TextColor3 = THEME.Cyan,
	TextSize = 12,
	Position = UDim2.fromOffset(32, 0),
	Size = UDim2.fromOffset(90, CFG.HeaderHeight),
})

local fpsHeader = label(header, {
	Name = "FpsHeader",
	RichText = true,
	TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Center,
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.fromScale(0.5, 0),
	Size = UDim2.fromOffset(90, CFG.HeaderHeight),
})

local pingHeader = label(header, {
	Name = "PingHeader",
	RichText = true,
	TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Right,
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -18, 0, 0),
	Size = UDim2.fromOffset(80, CFG.HeaderHeight),
})

-- The island IS the toggle
local toggleButton = create("TextButton", {
	Name = "ToggleButton",
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Text = "",
	AutoButtonColor = false,
	ZIndex = 5,
}, header)

--// PANEL (expanded content, landscape layout)
local PANEL_TOP = CFG.HeaderHeight + 8
local panel = create("CanvasGroup", {
	Name = "Panel",
	Position = UDim2.fromOffset(0, PANEL_TOP),
	Size = UDim2.new(1, 0, 1, -PANEL_TOP),
	BackgroundTransparency = 1,
	GroupTransparency = 1,
	Visible = false,
	ZIndex = 2,
}, body)
create("UIPadding", {
	PaddingLeft = UDim.new(0, 14),
	PaddingRight = UDim.new(0, 14),
	PaddingBottom = UDim.new(0, 14),
}, panel)

local function makeCard(position, size)
	local c = create("Frame", {
		Position = position,
		Size = size,
		BackgroundColor3 = THEME.Card,
		BorderSizePixel = 0,
	}, panel)
	corner(c, 14)
	stroke(c, THEME.Cyan, 1, 0.78)
	return c
end

-- Layout grid (panel inner width = 752): col1 x=0 (232) | col2 x=240 (232) | col3 x=480 (272)
local COL1, COL2, COL3 = 0, 240, 480
local MAIN_Y = 26

--// TITLE ROW
label(panel, {
	Text = string.upper(CFG.Name),
	Font = Enum.Font.Michroma,
	TextSize = 12,
	TextColor3 = THEME.Cyan,
	Position = UDim2.fromOffset(4, 0),
	Size = UDim2.new(0.7, 0, 0, 20),
})
label(panel, {
	Text = "by " .. CFG.Credit,
	Font = Enum.Font.GothamMedium,
	TextSize = 11,
	TextColor3 = THEME.Muted,
	TextXAlignment = Enum.TextXAlignment.Right,
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -4, 0, 0),
	Size = UDim2.new(0.3, 0, 0, 20),
})

--// COLUMN 1: PROFILE + PLAYER STATS
local profileCard = makeCard(UDim2.fromOffset(COL1, MAIN_Y), UDim2.fromOffset(232, 100))

local avatar = create("ImageLabel", {
	Name = "Avatar",
	Position = UDim2.fromOffset(12, 14),
	Size = UDim2.fromOffset(72, 72),
	BackgroundColor3 = THEME.CardAlt,
	BorderSizePixel = 0,
	Image = "",
}, profileCard)
corner(avatar, 36)
create("UIAspectRatioConstraint", { AspectRatio = 1 }, avatar)
neonGradient(stroke(avatar, Color3.new(1, 1, 1), 2, 0))

label(profileCard, {
	Text = player.DisplayName,
	TextSize = 17,
	TextTruncate = Enum.TextTruncate.AtEnd,
	Position = UDim2.fromOffset(96, 14),
	Size = UDim2.new(1, -106, 0, 22),
})
label(profileCard, {
	Text = "@" .. player.Name,
	Font = Enum.Font.GothamMedium,
	TextSize = 12,
	TextColor3 = THEME.Sky,
	TextTruncate = Enum.TextTruncate.AtEnd,
	Position = UDim2.fromOffset(96, 38),
	Size = UDim2.new(1, -106, 0, 16),
})
label(profileCard, {
	Text = "ID: " .. player.UserId,
	Font = Enum.Font.GothamMedium,
	TextSize = 10,
	TextColor3 = THEME.Muted,
	Position = UDim2.fromOffset(96, 55),
	Size = UDim2.new(1, -106, 0, 14),
})
local seaBadge = create("Frame", {
	Position = UDim2.fromOffset(96, 72),
	Size = UDim2.fromOffset(76, 18),
	BackgroundColor3 = THEME.CardAlt,
	BorderSizePixel = 0,
}, profileCard)
corner(seaBadge, 9)
stroke(seaBadge, THEME.Cyan, 1, 0.3)
label(seaBadge, {
	Text = seaText,
	TextSize = 11,
	TextColor3 = THEME.Cyan,
	TextXAlignment = Enum.TextXAlignment.Center,
	Size = UDim2.fromScale(1, 1),
})

-- Load avatar thumbnail without blocking the UI
task.spawn(function()
	local ok, content = pcall(function()
		return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
	end)
	if ok and content then
		avatar.Image = content
	end
end)

-- Player stats card: Level / Beli / Fragments
local statsCard = makeCard(UDim2.fromOffset(COL1, MAIN_Y + 108), UDim2.fromOffset(232, 142))
label(statsCard, {
	Text = "PLAYER STATS",
	TextSize = 11,
	TextColor3 = THEME.Muted,
	Position = UDim2.fromOffset(12, 8),
	Size = UDim2.new(1, -24, 0, 16),
})

local function statRow(index, tag, name, color)
	local y = 28 + (index - 1) * 37
	local icon = create("Frame", {
		Position = UDim2.fromOffset(12, y + 2),
		Size = UDim2.fromOffset(28, 28),
		BackgroundColor3 = THEME.CardAlt,
		BorderSizePixel = 0,
	}, statsCard)
	corner(icon, 9)
	stroke(icon, color, 1.2, 0.35)
	label(icon, {
		Text = tag,
		TextSize = 11,
		TextColor3 = color,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 1),
	})
	label(statsCard, {
		Text = name,
		Font = Enum.Font.GothamMedium,
		TextSize = 10,
		TextColor3 = THEME.Muted,
		Position = UDim2.fromOffset(48, y),
		Size = UDim2.new(1, -60, 0, 12),
	})
	return label(statsCard, {
		Text = "--",
		TextSize = 16,
		Position = UDim2.fromOffset(48, y + 11),
		Size = UDim2.new(1, -60, 0, 20),
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
end

local levelValue = statRow(1, "LV", "LEVEL", THEME.Cyan)
local beliValue = statRow(2, "$", "BELI", THEME.Beli)
local fragmentValue = statRow(3, "F", "FRAGMENTS", THEME.Fragment)

--// COLUMN 2: SESSION TIME + GLOBAL TIME
local sessionCard = makeCard(UDim2.fromOffset(COL2, MAIN_Y), UDim2.fromOffset(232, 100))
label(sessionCard, {
	Text = "SESSION TIME",
	TextSize = 11,
	TextColor3 = THEME.Muted,
	Position = UDim2.fromOffset(12, 8),
	Size = UDim2.new(1, -24, 0, 16),
})
local sessionValue = label(sessionCard, {
	Text = "00:00:00",
	TextSize = 28,
	TextColor3 = THEME.Cyan,
	Position = UDim2.fromOffset(12, 26),
	Size = UDim2.new(1, -24, 0, 34),
})
label(sessionCard, {
	Text = "Since you joined",
	Font = Enum.Font.GothamMedium,
	TextSize = 11,
	TextColor3 = THEME.Muted,
	Position = UDim2.fromOffset(12, 64),
	Size = UDim2.new(1, -24, 0, 14),
})
local playersLabel = label(sessionCard, {
	Text = "",
	Font = Enum.Font.GothamMedium,
	TextSize = 11,
	TextColor3 = THEME.Sky,
	Position = UDim2.fromOffset(12, 80),
	Size = UDim2.new(1, -24, 0, 14),
})

local globalCard = makeCard(UDim2.fromOffset(COL2, MAIN_Y + 108), UDim2.fromOffset(232, 142))
label(globalCard, {
	Text = "GLOBAL TIME",
	TextSize = 11,
	TextColor3 = THEME.Muted,
	Position = UDim2.fromOffset(12, 8),
	Size = UDim2.new(1, -24, 0, 16),
})
local globalValue = label(globalCard, {
	Text = "00:00:00",
	TextSize = 28,
	Position = UDim2.fromOffset(12, 26),
	Size = UDim2.new(1, -24, 0, 34),
})
local globalDate = label(globalCard, {
	Text = "",
	Font = Enum.Font.GothamMedium,
	TextSize = 11,
	TextColor3 = THEME.Muted,
	TextTruncate = Enum.TextTruncate.AtEnd,
	Position = UDim2.fromOffset(12, 62),
	Size = UDim2.new(1, -24, 0, 14),
})
local regionButton = create("TextButton", {
	Position = UDim2.fromOffset(12, 88),
	Size = UDim2.new(1, -24, 0, 28),
	BackgroundColor3 = THEME.CardAlt,
	AutoButtonColor = false,
	Font = Enum.Font.GothamBold,
	TextSize = 12,
	TextColor3 = THEME.Cyan,
	Text = "",
	BorderSizePixel = 0,
}, globalCard)
corner(regionButton, 9)
stroke(regionButton, THEME.Cyan, 1, 0.6)
label(globalCard, {
	Text = "Tap to change region",
	Font = Enum.Font.GothamMedium,
	TextSize = 10,
	TextColor3 = THEME.Muted,
	TextXAlignment = Enum.TextXAlignment.Center,
	Position = UDim2.fromOffset(12, 120),
	Size = UDim2.new(1, -24, 0, 14),
})

--// COLUMN 3: FPS + PING CHARTS
local function makeChart(opts)
	local N = CFG.HistoryLength
	local frame = makeCard(opts.position, UDim2.fromOffset(272, 121))

	label(frame, {
		Text = opts.title,
		TextSize = 11,
		TextColor3 = THEME.Muted,
		Position = UDim2.fromOffset(12, 8),
		Size = UDim2.new(0.6, 0, 0, 16),
	})
	local valueLabel = label(frame, {
		RichText = true,
		TextSize = 20,
		TextXAlignment = Enum.TextXAlignment.Right,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 4),
		Size = UDim2.new(0.5, 0, 0, 24),
	})

	local area = create("Frame", {
		Position = UDim2.fromOffset(12, 32),
		Size = UDim2.new(1, -24, 0, 62),
		BackgroundColor3 = Color3.fromRGB(7, 9, 13),
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, frame)
	corner(area, 8)

	for _, y in ipairs({ 0.33, 0.66 }) do -- faint grid lines
		create("Frame", {
			Position = UDim2.fromScale(0, y),
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = THEME.Sky,
			BackgroundTransparency = 0.92,
			BorderSizePixel = 0,
		}, area)
	end

	local barsHolder = create("Frame", {
		Position = UDim2.fromOffset(4, 4),
		Size = UDim2.new(1, -8, 1, -8),
		BackgroundTransparency = 1,
	}, area)

	local bars, history = {}, {}
	for i = 1, N do
		local bar = create("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new((i - 1) / N, 0, 1, 0),
			Size = UDim2.new(1 / N, -1, 0, 0),
			BackgroundColor3 = THEME.Cyan,
			BorderSizePixel = 0,
			Visible = false,
		}, barsHolder)
		corner(bar, 2)
		bars[i] = bar
		history[i] = -1 -- -1 = no data yet
	end

	local statsLabel = label(frame, {
		Text = "",
		Font = Enum.Font.GothamMedium,
		TextSize = 11,
		TextColor3 = THEME.Muted,
		Position = UDim2.fromOffset(12, 100),
		Size = UDim2.new(1, -24, 0, 16),
	})

	local function colorFor(v)
		if opts.higherIsBetter then
			return v >= opts.good and THEME.Cyan or (v >= opts.warn and THEME.Warn or THEME.Bad)
		end
		return v <= opts.good and THEME.Cyan or (v <= opts.warn and THEME.Warn or THEME.Bad)
	end

	local chart = {}

	function chart.push(value)
		table.remove(history, 1)
		table.insert(history, value)

		local peak = opts.minTop
		for _, v in ipairs(history) do
			if v >= 0 and v * 1.15 > peak then
				peak = v * 1.15
			end
		end

		local sum, count, mn, mx = 0, 0, math.huge, 0
		for i, v in ipairs(history) do
			local bar = bars[i]
			if v >= 0 then
				bar.Visible = true
				bar.Size = UDim2.new(1 / N, -1, math.clamp(v / peak, 0.04, 1), 0)
				bar.BackgroundColor3 = colorFor(v)
				sum += v
				count += 1
				mn = math.min(mn, v)
				mx = math.max(mx, v)
			else
				bar.Visible = false
			end
		end

		local c = colorFor(value)
		valueLabel.Text = string.format(
			'<font color="%s">%d</font> <font size="12" color="%s">%s</font>',
			rgbTag(c), math.floor(value + 0.5), rgbTag(THEME.Muted), opts.unit
		)
		statsLabel.Text = string.format(
			"MIN %d  •  AVG %d  •  MAX %d",
			math.floor(mn + 0.5), math.floor(sum / count + 0.5), math.floor(mx + 0.5)
		)
		return c
	end

	return chart
end

local fpsChart = makeChart({
	position = UDim2.fromOffset(COL3, MAIN_Y),
	title = "FRAMES PER SECOND",
	unit = "FPS",
	minTop = 60,
	good = 50,
	warn = 30,
	higherIsBetter = true,
})

local pingChart = makeChart({
	position = UDim2.fromOffset(COL3, MAIN_Y + 129),
	title = "NETWORK LATENCY",
	unit = "ms",
	minTop = 100,
	good = 100,
	warn = 200,
	higherIsBetter = false,
})

--// MARQUEE (scrolling thank-you banner at the bottom of the panel)
local marqueeStrip = create("CanvasGroup", {
	Name = "Marquee",
	Position = UDim2.fromOffset(0, 284),
	Size = UDim2.new(1, 0, 0, 24),
	BackgroundColor3 = THEME.Card,
	BorderSizePixel = 0,
}, panel)
corner(marqueeStrip, 12)
stroke(marqueeStrip, THEME.Cyan, 1, 0.78)
create("UIGradient", { -- fades the text out at both edges
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.9),
		NumberSequenceKeypoint.new(0.08, 0),
		NumberSequenceKeypoint.new(0.92, 0),
		NumberSequenceKeypoint.new(1, 0.9),
	}),
}, marqueeStrip)

local marqueeUnit = "     " .. CFG.MarqueeText .. "     •     " .. CFG.Name .. "     •"
local okSize, marqueeBounds = pcall(function()
	return TextService:GetTextSize(marqueeUnit, 12, Enum.Font.GothamBold, Vector2.new(10000, 24))
end)
local marqueeWidth = math.max(okSize and marqueeBounds.X or (#marqueeUnit * 7.5), 120) + 40 -- +40 = safety gap
local marqueeLabels = {}
for i = 1, math.ceil(760 / marqueeWidth) + 1 do -- enough copies for a seamless loop
	marqueeLabels[i] = label(marqueeStrip, {
		Text = marqueeUnit,
		TextSize = 12,
		TextColor3 = THEME.Sky,
		Position = UDim2.fromOffset((i - 1) * marqueeWidth, 0),
		Size = UDim2.fromOffset(marqueeWidth, 24),
	})
end
local marqueeOffset = 0

--// REGION SELECTOR (overlay that replaces the Global Time card while open)
local selectedRegion = REGIONS[2] -- default: ICT / Vietnam
local dropdownOpen = false

local dropdown = create("CanvasGroup", {
	Name = "RegionDropdown",
	Position = globalCard.Position,
	Size = globalCard.Size,
	BackgroundColor3 = Color3.fromRGB(8, 11, 16),
	BorderSizePixel = 0,
	GroupTransparency = 1,
	Visible = false,
	ZIndex = 20,
}, panel)
corner(dropdown, 14)
stroke(dropdown, THEME.Cyan, 1.5, 0.2)
label(dropdown, {
	Text = "SELECT REGION",
	TextSize = 11,
	TextColor3 = THEME.Cyan,
	Position = UDim2.fromOffset(12, 8),
	Size = UDim2.new(1, -24, 0, 16),
	ZIndex = 21,
})
local grid = create("Frame", {
	Position = UDim2.fromOffset(10, 30),
	Size = UDim2.new(1, -20, 1, -40),
	BackgroundTransparency = 1,
	ZIndex = 21,
}, dropdown)
create("UIGridLayout", {
	CellSize = UDim2.new(0.5, -3, 0, 30),
	CellPadding = UDim2.fromOffset(6, 6),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, grid)

local regionButtons = {}

local function refreshRegionButtonText()
	local _, _, abbr = getRegionTime(selectedRegion)
	regionButton.Text = abbr .. " · " .. selectedRegion.place .. "  ▾"
end

local function setDropdown(open)
	dropdownOpen = open
	if open then
		dropdown.Visible = true
	end
	local tween = TweenService:Create(dropdown, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {
		GroupTransparency = open and 0 or 1,
	})
	tween:Play()
	if not open then
		tween.Completed:Connect(function()
			if not dropdownOpen then
				dropdown.Visible = false
			end
		end)
	end
end

local function refreshRegionHighlights()
	for r, entry in pairs(regionButtons) do
		local selected = r == selectedRegion
		entry.button.TextColor3 = selected and THEME.Cyan or THEME.White
		entry.stroke.Transparency = selected and 0.1 or 0.85
	end
end

for i, region in ipairs(REGIONS) do
	local btn = create("TextButton", {
		LayoutOrder = i,
		BackgroundColor3 = THEME.CardAlt,
		AutoButtonColor = false,
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = THEME.White,
		Text = region.id .. " · " .. region.place,
		BorderSizePixel = 0,
		ZIndex = 22,
	}, grid)
	corner(btn, 8)
	regionButtons[region] = { button = btn, stroke = stroke(btn, THEME.Cyan, 1, 0.85) }

	btn.Activated:Connect(function()
		selectedRegion = region
		refreshRegionHighlights()
		refreshRegionButtonText()
		setDropdown(false)
	end)
end
refreshRegionHighlights()

regionButton.Activated:Connect(function()
	setDropdown(true)
end)

--// RESPONSIVE SCALE
local expanded = false

local function targetScale(isExpanded)
	if not isExpanded then
		return 1
	end
	local vp = camera.ViewportSize
	local fit = math.min(
		(vp.X - 24 - CFG.MarginRight) / CFG.ExpandedSize.X,
		(vp.Y - 24) / CFG.ExpandedSize.Y
	)
	return math.clamp(fit, 0.45, 1.25)
end

camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	uiScale.Scale = targetScale(expanded)
end)

--// EXPAND / COLLAPSE ANIMATION
local toggleToken = 0

local function setExpanded(state)
	expanded = state
	toggleToken += 1
	local token = toggleToken

	if not state and dropdownOpen then
		setDropdown(false)
	end

	local size = state and CFG.ExpandedSize or CFG.CollapsedSize
	local sizeInfo = state
		and TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		or TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)

	TweenService:Create(island, sizeInfo, { Size = UDim2.fromOffset(size.X, size.Y) }):Play()
	TweenService:Create(uiScale, TweenInfo.new(0.45, Enum.EasingStyle.Quint), { Scale = targetScale(state) }):Play()
	TweenService:Create(bodyCorner, sizeInfo, { CornerRadius = UDim.new(0, state and 30 or CFG.CollapsedSize.Y / 2) }):Play()
	TweenService:Create(glowCorner, sizeInfo, { CornerRadius = UDim.new(0, state and 35 or CFG.CollapsedSize.Y / 2 + 5) }):Play()

	if state then
		panel.Visible = true
		TweenService:Create(
			panel,
			TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.15),
			{ GroupTransparency = 0 }
		):Play()
	else
		local fade = TweenService:Create(panel, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { GroupTransparency = 1 })
		fade:Play()
		fade.Completed:Connect(function()
			if toggleToken == token and not expanded then
				panel.Visible = false
			end
		end)
	end
end

toggleButton.Activated:Connect(function()
	setExpanded(not expanded)
end)

-- Small hover "breathing" effect on the collapsed pill (grows to the left)
toggleButton.MouseEnter:Connect(function()
	if not expanded then
		TweenService:Create(island, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
			Size = UDim2.fromOffset(CFG.CollapsedSize.X + 14, CFG.CollapsedSize.Y + 2),
		}):Play()
	end
end)
toggleButton.MouseLeave:Connect(function()
	if not expanded then
		TweenService:Create(island, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
			Size = UDim2.fromOffset(CFG.CollapsedSize.X, CFG.CollapsedSize.Y),
		}):Play()
	end
end)

--// DATA SOURCES
local function getPing()
	local ok, value = pcall(function()
		return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
	end)
	if ok and typeof(value) == "number" then
		return value
	end
	local ok2, p = pcall(function()
		return player:GetNetworkPing() * 2000
	end)
	return ok2 and p or 0
end

-- Blox Fruits stores stats in player.Data (Level, Beli, Fragments)
local function readStat(name)
	local data = player:FindFirstChild("Data")
	local obj = data and data:FindFirstChild(name)
	if obj and obj:IsA("ValueBase") then
		return obj.Value
	end
	return nil
end

--// LOAD NOTIFICATION (Dynamic Island style toast, slides out under the pill)
local function notify(title, text, duration)
	local width = math.min(320, camera.ViewportSize.X - 20)
	local vpSize = camera.ViewportSize
	local half = (expanded and CFG.ExpandedSize.Y or CFG.CollapsedSize.Y) / 2 * uiScale.Scale
	local centerY = vpSize.Y * CFG.PositionY
	local anchor, position
	if centerY + half + 12 + 52 <= vpSize.Y then -- room below the island
		anchor, position = Vector2.new(1, 0), UDim2.new(1, -CFG.MarginRight, CFG.PositionY, half + 12)
	elseif centerY - half - 12 - 52 >= 0 then -- room above
		anchor, position = Vector2.new(1, 1), UDim2.new(1, -CFG.MarginRight, CFG.PositionY, -(half + 12))
	else -- small screens: top center
		anchor, position = Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 12)
	end
	local toast = create("CanvasGroup", {
		Name = "Notify",
		AnchorPoint = anchor,
		Position = position,
		Size = UDim2.fromOffset(40, 10),
		GroupTransparency = 1,
		BackgroundColor3 = THEME.Background,
		BorderSizePixel = 0,
		ZIndex = 50,
	}, gui)
	corner(toast, 26)
	local toastGradient = neonGradient(stroke(toast, Color3.new(1, 1, 1), 2, 0))

	local icon = create("Frame", {
		Position = UDim2.fromOffset(12, 12),
		Size = UDim2.fromOffset(28, 28),
		BackgroundColor3 = THEME.CardAlt,
		BorderSizePixel = 0,
	}, toast)
	corner(icon, 14)
	stroke(icon, THEME.Cyan, 1.5, 0.2)
	label(icon, {
		Text = "✓",
		TextSize = 15,
		TextColor3 = THEME.Cyan,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 1),
	})
	label(toast, {
		Text = title,
		TextSize = 14,
		Position = UDim2.fromOffset(52, 8),
		Size = UDim2.new(1, -64, 0, 18),
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
	label(toast, {
		Text = text,
		Font = Enum.Font.GothamMedium,
		TextSize = 11,
		TextColor3 = THEME.Muted,
		Position = UDim2.fromOffset(52, 26),
		Size = UDim2.new(1, -64, 0, 16),
		TextTruncate = Enum.TextTruncate.AtEnd,
	})

	TweenService:Create(toast, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(width, 52),
		GroupTransparency = 0,
	}):Play()

	task.delay(duration, function()
		local out = TweenService:Create(toast, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
			Size = UDim2.fromOffset(40, 10),
			GroupTransparency = 1,
		})
		out:Play()
		out.Completed:Wait()
		local idx = table.find(animatedGradients, toastGradient)
		if idx then
			table.remove(animatedGradients, idx)
		end
		toast:Destroy()
	end)
end

--// INLINE LOADING (shown INSIDE the main UI, no full-screen cover)
-- Electromagnetic / computer-tech theme: CPU chip with mechanical R, circuit traces with data pulses,
-- electric arcs, EM field rings, orbiting electrons, code rain, boot terminal, segmented progress bar.
local function runInlineLoading(onFinished)
	local WHITE = Color3.new(1, 1, 1)
	local rng = Random.new()
	local startClock = os.clock()
	local W, H = CFG.ExpandedSize.X, CFG.ExpandedSize.Y
	local CX, CY = 190, 186 -- chip center inside the overlay

	local function V(x, y)
		return Vector2.new(x, y)
	end

	-- Overlay covering the island body (blocks clicks while loading)
	local overlay = create("CanvasGroup", {
		Name = "Loading",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		GroupTransparency = 1,
		Active = true,
		ZIndex = 50,
	}, body)
	corner(overlay, 30)
	create("UIGradient", {
		Rotation = 90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(2, 4, 8)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 18, 28)),
		}),
	}, overlay)

	-- Shared helpers ------------------------------------------------
	local function newSegment(parent, thickness, color, transparency)
		return create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(0, thickness),
			BackgroundColor3 = color,
			BackgroundTransparency = transparency,
			BorderSizePixel = 0,
		}, parent)
	end
	local function placeSegment(f, x1, y1, x2, y2)
		local dx, dy = x2 - x1, y2 - y1
		f.Position = UDim2.fromOffset((x1 + x2) / 2, (y1 + y2) / 2)
		f.Size = UDim2.fromOffset(math.sqrt(dx * dx + dy * dy), f.Size.Y.Offset)
		f.Rotation = math.deg(math.atan2(dy, dx))
	end

	----------------------------------------------------------------
	-- CODE RAIN (left half only, so it never sits behind the text)
	----------------------------------------------------------------
	local RAIN_CHARS = { "0", "1", "0", "1", "A", "B", "C", "D", "E", "F", "7", "3", "9", "<", ">", "/", "{", "}", "=", "+", "#" }
	local function randomColumn()
		local parts = table.create(16)
		for k = 1, 16 do
			parts[k] = RAIN_CHARS[rng:NextInteger(1, #RAIN_CHARS)]
		end
		return table.concat(parts, "\n")
	end
	local rain = {}
	for i = 1, 12 do
		local l = label(overlay, {
			Text = randomColumn(),
			Font = Enum.Font.Code,
			TextSize = 13,
			TextColor3 = (i % 4 == 0) and WHITE or THEME.Cyan,
			TextTransparency = 0.6,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Top,
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromOffset(16 + (i - 1) * 31, -240),
			Size = UDim2.fromOffset(18, 240),
		})
		create("UIGradient", {
			Rotation = 90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.7, 0.6),
				NumberSequenceKeypoint.new(1, 0.1),
			}),
		}, l)
		rain[i] = {
			label = l,
			x = 16 + (i - 1) * 31,
			speed = rng:NextNumber(40, 110),
			phase = rng:NextNumber(0, H + 240),
			timer = rng:NextNumber(0, 0.2),
			interval = rng:NextNumber(0.08, 0.22),
		}
	end

	----------------------------------------------------------------
	-- CIRCUIT BOARD centered on the chip
	----------------------------------------------------------------
	local board = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(CX, CY),
		Size = UDim2.fromOffset(0, 0),
		BackgroundTransparency = 1,
	}, overlay)

	-- EM field rings (upper half only; max diameter keeps them left of the text)
	local fieldRings = {}
	for i = 1, 3 do
		local f = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.fromOffset(110, 110),
			BackgroundTransparency = 1,
		}, board)
		corner(f, 1000)
		local st = stroke(f, THEME.Cyan, 1.5, 0.6)
		create("UIGradient", {
			Rotation = 90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.3),
				NumberSequenceKeypoint.new(0.6, 0.8),
				NumberSequenceKeypoint.new(0.8, 1),
				NumberSequenceKeypoint.new(1, 1),
			}),
		}, st)
		fieldRings[i] = { frame = f, stroke = st }
	end

	-- Traces (long ones go left / up / down, right side only has short stubs)
	local PATHS = {
		{ V(-61, -40), V(-120, -40), V(-150, -70), V(-190, -70) },
		{ V(-61, -13.6), V(-190, -13.6) },
		{ V(-61, 13.6), V(-190, 13.6) },
		{ V(-61, 40), V(-120, 40), V(-150, 70), V(-190, 70) },
		{ V(-36, -61), V(-36, -110), V(-70, -140), V(-70, -186) },
		{ V(0, -61), V(0, -186) },
		{ V(36, -61), V(36, -110), V(70, -140), V(70, -186) },
		{ V(-36, 61), V(-36, 110), V(-70, 140), V(-70, 186) },
		{ V(0, 61), V(0, 186) },
		{ V(36, 61), V(36, 110), V(70, 140), V(70, 186) },
		{ V(61, -40), V(110, -40), V(130, -60) },
		{ V(61, -13.6), V(120, -13.6) },
		{ V(61, 13.6), V(120, 13.6) },
		{ V(61, 40), V(110, 40), V(130, 60) },
	}

	local pathInfo, traceFrames = {}, {}
	for k, pts in ipairs(PATHS) do
		local lens, total, frames = {}, 0, {}
		for i = 1, #pts - 1 do
			lens[i] = (pts[i + 1] - pts[i]).Magnitude
			total += lens[i]
			local seg = newSegment(board, 2, THEME.Cyan, 1)
			placeSegment(seg, pts[i].X, pts[i].Y, pts[i + 1].X, pts[i + 1].Y)
			table.insert(frames, seg)
		end
		for i = 2, #pts do -- junction / end nodes
			local big = i == #pts
			local n = create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromOffset(pts[i].X, pts[i].Y),
				Size = UDim2.fromOffset(big and 7 or 4, big and 7 or 4),
				BackgroundColor3 = THEME.Cyan,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			}, board)
			corner(n, 4)
			table.insert(frames, n)
		end
		traceFrames[k] = frames
		pathInfo[k] = { pts = pts, lens = lens, total = total }
	end

	local function pointAt(info, d)
		d = math.clamp(d, 0, info.total)
		for i, l in ipairs(info.lens) do
			if d <= l then
				return info.pts[i]:Lerp(info.pts[i + 1], l > 0 and d / l or 0)
			end
			d -= l
		end
		return info.pts[#info.pts]
	end

	-- Data pulses flowing toward the chip
	local pulses = {}
	for _, info in ipairs(pathInfo) do
		local pl = { info = info, speed = rng:NextNumber(90, 140), phase = rng:NextNumber(0, info.total), dots = {} }
		for k = 1, 3 do
			local size = k == 1 and 5 or (k == 2 and 4 or 3)
			local d = create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromOffset(size, size),
				BackgroundColor3 = k == 1 and WHITE or THEME.Cyan,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			}, board)
			corner(d, 3)
			if k == 1 then
				stroke(d, THEME.Cyan, 3, 0.55)
			end
			pl.dots[k] = d
		end
		table.insert(pulses, pl)
	end
	local pulseTransparency = { 0.05, 0.35, 0.6 }

	-- Tesla coil nodes with EM pulse rings
	local coils = {}
	for _, pos in ipairs({ V(-140, -100), V(-140, 100), V(125, -105), V(125, 105) }) do
		local node = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(pos.X, pos.Y),
			Size = UDim2.fromOffset(18, 18),
			BackgroundColor3 = Color3.fromRGB(6, 12, 18),
			BorderSizePixel = 0,
		}, board)
		corner(node, 9)
		stroke(node, THEME.Cyan, 2, 0.15)
		local nodeCore = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(6, 6),
			BackgroundColor3 = WHITE,
			BorderSizePixel = 0,
		}, node)
		corner(nodeCore, 3)
		local rings = {}
		for k = 1, 2 do
			local r = create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromOffset(pos.X, pos.Y),
				Size = UDim2.fromOffset(18, 18),
				BackgroundTransparency = 1,
			}, board)
			corner(r, 1000)
			rings[k] = { frame = r, stroke = stroke(r, THEME.Cyan, 1.5, 1) }
		end
		table.insert(coils, { pos = pos, core = nodeCore, rings = rings })
	end

	-- Electric arcs: coil node <-> chip
	local ARC_SEGMENTS = 9
	local arcs = {}
	for _, c in ipairs(coils) do
		local arc = {
			from = c.pos,
			to = V(c.pos.X > 0 and 52 or -52, c.pos.Y < 0 and -34 or 34),
			glow = {},
			core = {},
			on = false,
			offAt = 0,
			nextUpdate = 0,
		}
		for i = 1, ARC_SEGMENTS do
			arc.glow[i] = newSegment(board, 5, THEME.Cyan, 1)
			arc.core[i] = newSegment(board, 1.6, WHITE, 1)
		end
		table.insert(arcs, arc)
	end
	local function setArcVisible(arc, on)
		for i = 1, ARC_SEGMENTS do
			arc.glow[i].BackgroundTransparency = on and 0.72 or 1
			arc.core[i].BackgroundTransparency = on and 0 or 1
		end
	end
	local function regenArc(arc, strength)
		local dir = arc.to - arc.from
		local normal = V(-dir.Y, dir.X).Unit
		local pts = {}
		for i = 0, ARC_SEGMENTS do
			local f = i / ARC_SEGMENTS
			local env = math.sin(f * math.pi)
			local off = (rng:NextNumber() - 0.5) * 2 * 10 * env * (0.5 + strength)
			pts[i + 1] = arc.from:Lerp(arc.to, f) + normal * off
		end
		for i = 1, ARC_SEGMENTS do
			placeSegment(arc.glow[i], pts[i].X, pts[i].Y, pts[i + 1].X, pts[i + 1].Y)
			placeSegment(arc.core[i], pts[i].X, pts[i].Y, pts[i + 1].X, pts[i + 1].Y)
		end
	end
	local chipFlash = 0
	local forceArcsUntil = 0

	----------------------------------------------------------------
	-- CHIP EMBLEM (scaled 0.8) with mechanical cyber R
	----------------------------------------------------------------
	local emblem = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(CX, CY),
		Size = UDim2.fromOffset(200, 200),
		BackgroundTransparency = 1,
	}, overlay)
	local emblemScale = create("UIScale", { Scale = 0 }, emblem)
	local EMBLEM_SCALE = 0.8

	local glowLayers = {}
	for i = 1, 8 do
		local d = 100 + i * 16
		local c = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(100, 100),
			Size = UDim2.fromOffset(d, d),
			BackgroundColor3 = THEME.Cyan,
			BackgroundTransparency = 0.97,
			BorderSizePixel = 0,
		}, emblem)
		corner(c, d / 2)
		glowLayers[i] = c
	end

	local function pin(x, y, w, h)
		local f = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(100 + x, 100 + y),
			Size = UDim2.fromOffset(w, h),
			BackgroundColor3 = THEME.Cyan,
			BackgroundTransparency = 0.25,
			BorderSizePixel = 0,
		}, emblem)
		corner(f, 1)
	end
	for _, x in ipairs({ -45, 0, 45 }) do
		pin(x, -70, 4, 12)
		pin(x, 70, 4, 12)
	end
	for _, y in ipairs({ -50, -17, 17, 50 }) do
		pin(-70, y, 12, 4)
		pin(70, y, 12, 4)
	end

	local chip = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(100, 100),
		Size = UDim2.fromOffset(128, 128),
		BackgroundColor3 = Color3.fromRGB(6, 12, 18),
		BorderSizePixel = 0,
	}, emblem)
	corner(chip, 12)
	local chipStroke = stroke(chip, WHITE, 2.5, 0)
	local chipGradient = create("UIGradient", { Color = BORDER_COLORS, Transparency = BORDER_TRANSPARENCY }, chipStroke)

	for _, c in ipairs({ V(9, 9), V(119, 9), V(9, 119), V(119, 119) }) do -- corner screws
		local s = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(c.X, c.Y),
			Size = UDim2.fromOffset(5, 5),
			BackgroundColor3 = Color3.fromRGB(14, 26, 36),
			BorderSizePixel = 0,
		}, chip)
		corner(s, 3)
		stroke(s, THEME.Cyan, 1, 0.4)
	end

	local die = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(64, 60),
		Size = UDim2.fromOffset(100, 100),
		BackgroundColor3 = Color3.fromRGB(8, 18, 26),
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, chip)
	corner(die, 8)
	stroke(die, THEME.Cyan, 1, 0.55)
	for _, f in ipairs({ 0.25, 0.5, 0.75 }) do
		create("Frame", {
			Position = UDim2.fromScale(0, f),
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = THEME.Cyan,
			BackgroundTransparency = 0.9,
			BorderSizePixel = 0,
		}, die)
		create("Frame", {
			Position = UDim2.fromScale(f, 0),
			Size = UDim2.new(0, 1, 1, 0),
			BackgroundColor3 = THEME.Cyan,
			BackgroundTransparency = 0.9,
			BorderSizePixel = 0,
		}, die)
	end
	label(chip, {
		Text = "RZN-4.6",
		Font = Enum.Font.Code,
		TextSize = 9,
		TextColor3 = THEME.Muted,
		TextXAlignment = Enum.TextXAlignment.Center,
		Position = UDim2.fromOffset(0, 112),
		Size = UDim2.fromOffset(128, 12),
	})

	-- Mechanical cyber "R"
	local rHolder = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(64, 80),
		BackgroundTransparency = 1,
	}, die)
	create("UIScale", { Scale = 0.8 }, rHolder)

	local rGradients = {}
	local function strip(x1, y1, x2, y2, thickness)
		local dx, dy = x2 - x1, y2 - y1
		local len = math.sqrt(dx * dx + dy * dy)
		local f = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset((x1 + x2) / 2, (y1 + y2) / 2),
			Size = UDim2.fromOffset(len + thickness * 0.6, thickness),
			Rotation = math.deg(math.atan2(dy, dx)),
			BackgroundColor3 = THEME.Cyan,
			BackgroundTransparency = 0.82,
			BorderSizePixel = 0,
		}, rHolder)
		corner(f, 2)
		local st = stroke(f, WHITE, 1.5, 0)
		table.insert(rGradients, create("UIGradient", { Color = BORDER_COLORS, Transparency = BORDER_TRANSPARENCY }, st))
		create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, -8, 0, 1),
			BackgroundColor3 = THEME.Cyan,
			BackgroundTransparency = 0.3,
			BorderSizePixel = 0,
		}, f)
	end
	local function rivet(x, y)
		local r = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(x, y),
			Size = UDim2.fromOffset(7, 7),
			BackgroundColor3 = WHITE,
			BorderSizePixel = 0,
		}, rHolder)
		corner(r, 4)
		stroke(r, THEME.Cyan, 1.5, 0.2)
	end
	local T = 9
	strip(5, 4, 5, 76, T)
	strip(5, 4, 40, 4, T)
	strip(40, 4, 56, 20, T)
	strip(56, 20, 56, 34, T)
	strip(56, 34, 42, 48, T)
	strip(42, 48, 5, 48, T)
	strip(26, 48, 58, 76, T)
	rivet(5, 4)
	rivet(56, 20)
	rivet(42, 48)
	rivet(58, 76)
	rivet(5, 76)

	-- Electrons orbiting the chip
	local orbits = {
		{ a = 118, b = 40, tilt = math.rad(35), speed = 1.9, phase = 0 },
		{ a = 118, b = 40, tilt = math.rad(-35), speed = -1.5, phase = 2.2 },
		{ a = 96, b = 34, tilt = math.rad(90), speed = 1.3, phase = 4.1 },
	}
	for _, o in ipairs(orbits) do
		o.dots = {}
		for k = 1, 5 do
			local size = k == 1 and 8 or (7 - k)
			local d = create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromOffset(size, size),
				BackgroundColor3 = k == 1 and WHITE or THEME.Cyan,
				BackgroundTransparency = k == 1 and 0 or (0.1 + k * 0.15),
				BorderSizePixel = 0,
			}, emblem)
			corner(d, size / 2)
			if k == 1 then
				stroke(d, THEME.Cyan, 3, 0.5)
			end
			o.dots[k] = d
		end
	end

	----------------------------------------------------------------
	-- RIGHT SIDE: title, boot terminal, status, segmented bar
	----------------------------------------------------------------
	local TITLE = "RYZEN CONFIG"
	local titleRow = create("Frame", {
		Position = UDim2.fromOffset(402, 56),
		Size = UDim2.fromOffset(350, 40),
		BackgroundTransparency = 1,
	}, overlay)
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, titleRow)

	local letters, letterLive = {}, {}
	for i = 1, #TITLE do
		local ch = TITLE:sub(i, i)
		local isSpace = ch == " "
		local holder = create("Frame", {
			LayoutOrder = i,
			Size = UDim2.fromOffset(isSpace and 16 or 0, 40),
			AutomaticSize = isSpace and Enum.AutomaticSize.None or Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
		}, titleRow)
		letters[i] = label(holder, {
			Text = isSpace and "" or ch,
			Font = Enum.Font.Michroma,
			TextSize = 26,
			TextColor3 = THEME.Cyan,
			TextStrokeColor3 = THEME.Cyan,
			TextStrokeTransparency = 1,
			TextTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 40),
			Position = UDim2.fromOffset(0, 22),
		})
	end

	local info = create("CanvasGroup", {
		Position = UDim2.fromOffset(402, 100),
		Size = UDim2.fromOffset(350, 230),
		BackgroundTransparency = 1,
		GroupTransparency = 1,
	}, overlay)

	label(info, {
		Text = "V4.6   •   BY " .. string.upper(CFG.Credit),
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		TextColor3 = THEME.Muted,
		Size = UDim2.fromOffset(350, 16),
	})

	local logLabel = label(info, {
		Text = "",
		Font = Enum.Font.Code,
		TextSize = 11,
		RichText = true,
		TextColor3 = THEME.Sky,
		TextYAlignment = Enum.TextYAlignment.Top,
		Position = UDim2.fromOffset(0, 30),
		Size = UDim2.fromOffset(350, 84),
	})

	local statusLabel = label(info, {
		Text = "",
		Font = Enum.Font.Code,
		TextSize = 12,
		TextColor3 = THEME.Sky,
		Position = UDim2.fromOffset(0, 128),
		Size = UDim2.fromOffset(240, 18),
	})
	local percentLabel = label(info, {
		Text = "0",
		Font = Enum.Font.GothamBlack,
		TextSize = 24,
		TextColor3 = THEME.Cyan,
		RichText = true,
		TextXAlignment = Enum.TextXAlignment.Right,
		Position = UDim2.fromOffset(250, 118),
		Size = UDim2.fromOffset(100, 32),
	})

	local SEGMENTS = 25
	local barHolder = create("Frame", {
		Position = UDim2.fromOffset(0, 158),
		Size = UDim2.fromOffset(346, 8),
		BackgroundTransparency = 1,
	}, info)
	local segments = {}
	for j = 1, SEGMENTS do
		local seg = create("Frame", {
			Position = UDim2.fromOffset((j - 1) * 14, 0),
			Size = UDim2.fromOffset(10, 8),
			BackgroundColor3 = Color3.fromRGB(22, 32, 44),
			BorderSizePixel = 0,
		}, barHolder)
		corner(seg, 2)
		segments[j] = seg
	end

	local metricsLine = label(info, {
		Text = "",
		Font = Enum.Font.Code,
		TextSize = 10,
		TextColor3 = THEME.Muted,
		Position = UDim2.fromOffset(0, 178),
		Size = UDim2.fromOffset(350, 14),
	})

	-- HUD corner brackets
	local hudBrackets = {}
	local function bracket(ax, ay)
		local mx = ax == 1 and -14 or 14
		local my = ay == 1 and -14 or 14
		for _, sz in ipairs({ Vector2.new(24, 2), Vector2.new(2, 24) }) do
			table.insert(hudBrackets, create("Frame", {
				AnchorPoint = Vector2.new(ax, ay),
				Position = UDim2.new(ax, mx, ay, my),
				Size = UDim2.fromOffset(sz.X, sz.Y),
				BackgroundColor3 = THEME.Cyan,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			}, overlay))
		end
	end
	bracket(0, 0)
	bracket(1, 0)
	bracket(0, 1)
	bracket(1, 1)

	local progressValue = create("NumberValue", { Value = 0 }, overlay)

	local flashFrame = create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(190, 245, 255),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 10,
	}, overlay)

	----------------------------------------------------------------
	-- HELPERS: burst, typewriter status, boot log
	----------------------------------------------------------------
	local function burst(color, diameter)
		local r = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(CX, CY),
			Size = UDim2.fromOffset(80, 80),
			BackgroundTransparency = 1,
			ZIndex = 5,
		}, overlay)
		corner(r, 1000)
		local st = stroke(r, color, 3, 0.15)
		local tw = TweenService:Create(r, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Size = UDim2.fromOffset(diameter, diameter),
		})
		TweenService:Create(st, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1,
			Thickness = 0.5,
		}):Play()
		tw:Play()
		tw.Completed:Connect(function()
			r:Destroy()
		end)
	end

	local statusToken = 0
	local function setStatus(text)
		statusToken += 1
		local token = statusToken
		statusLabel.Text = text
		statusLabel.MaxVisibleGraphemes = 0
		task.spawn(function()
			for i = 1, #text do
				if statusToken ~= token then
					return
				end
				statusLabel.MaxVisibleGraphemes = i
				task.wait(0.018)
			end
			statusLabel.MaxVisibleGraphemes = -1
		end)
	end

	local logLines = {}
	local OK_TAG = string.format('<font color="%s">OK</font>', rgbTag(Color3.fromRGB(0, 255, 170)))
	local function pushLog(text)
		table.insert(logLines, string.format(
			'<font color="%s">[%5.2f]</font> %s %s',
			rgbTag(THEME.Muted), os.clock() - startClock, text, OK_TAG
		))
		if #logLines > 5 then
			table.remove(logLines, 1)
		end
		logLabel.Text = table.concat(logLines, "\n")
	end
	local function logBatch(lines)
		task.spawn(function()
			for _, line in ipairs(lines) do
				pushLog(line)
				task.wait(0.14)
			end
		end)
	end

	----------------------------------------------------------------
	-- PER-FRAME ANIMATION
	----------------------------------------------------------------
	local running = true
	local pulsesOn = false
	local titleWaveOn = false
	local fpsSmooth, metricTimer = 60, 0

	local loaderConn = RunService.RenderStepped:Connect(function(dt)
		local t = os.clock() - startClock
		local p = progressValue.Value
		local pulse = (math.sin(t * 2.2) + 1) / 2

		-- code rain
		for _, c in ipairs(rain) do
			c.label.Position = UDim2.fromOffset(c.x, ((c.phase + t * c.speed) % (H + 240)) - 240)
			c.timer -= dt
			if c.timer <= 0 then
				c.timer = c.interval
				c.label.Text = randomColumn()
			end
		end

		-- EM field rings
		for i, r in ipairs(fieldRings) do
			local q = (t * 0.32 + (i - 1) / #fieldRings) % 1
			local d = 110 + q * 270
			r.frame.Size = UDim2.fromOffset(d, d)
			r.stroke.Transparency = 0.2 + 0.8 * q
		end

		-- data pulses
		if pulsesOn then
			for _, pl in ipairs(pulses) do
				local inf = pl.info
				local d = inf.total - ((t * pl.speed + pl.phase) % (inf.total + 50))
				for k, dot in ipairs(pl.dots) do
					local pt = pointAt(inf, d + (k - 1) * 8)
					dot.Position = UDim2.fromOffset(pt.X, pt.Y)
				end
			end
		end

		-- coil rings
		for _, c in ipairs(coils) do
			for k, r in ipairs(c.rings) do
				local q = (t * 0.9 + (k - 1) * 0.5) % 1
				local d = 18 + q * 56
				r.frame.Size = UDim2.fromOffset(d, d)
				r.stroke.Transparency = 0.3 + 0.7 * q
			end
			c.core.BackgroundTransparency = 0.5 * (1 - pulse)
		end

		-- electric arcs (more frequent as loading progresses)
		local forced = t < forceArcsUntil
		for _, arc in ipairs(arcs) do
			if arc.on then
				if t >= arc.offAt and not forced then
					arc.on = false
					setArcVisible(arc, false)
				elseif t >= arc.nextUpdate then
					arc.nextUpdate = t + 0.045
					regenArc(arc, forced and 1 or p)
				end
			elseif forced or rng:NextNumber() < (0.4 + 2.4 * p) * dt then
				arc.on = true
				arc.offAt = t + rng:NextNumber(0.1, 0.35)
				arc.nextUpdate = 0
				setArcVisible(arc, true)
				chipFlash = math.min(1.5, chipFlash + 0.5)
			end
		end

		-- chip glow
		chipFlash = math.max(0, chipFlash - dt * 4)
		chipGradient.Rotation = (t * 120) % 360
		chipStroke.Thickness = 2.2 + pulse * 0.5 + chipFlash * 2
		for i, g in ipairs(glowLayers) do
			g.BackgroundTransparency = 0.975 - 0.012 * pulse - 0.012 * chipFlash - 0.001 * i
		end

		-- cyber R + glitch
		for _, rg in ipairs(rGradients) do
			rg.Rotation = (t * 160) % 360
		end
		if t % 3.6 < 0.14 then
			rHolder.Position = UDim2.new(0.5, rng:NextInteger(-3, 3), 0.5, rng:NextInteger(-2, 2))
		else
			rHolder.Position = UDim2.fromScale(0.5, 0.5)
		end

		-- electrons
		for _, o in ipairs(orbits) do
			local sign = o.speed >= 0 and 1 or -1
			local ct, st = math.cos(o.tilt), math.sin(o.tilt)
			for k, d in ipairs(o.dots) do
				local ang = o.phase + t * o.speed - sign * (k - 1) * 0.16
				local x, y = o.a * math.cos(ang), o.b * math.sin(ang)
				d.Position = UDim2.fromOffset(100 + x * ct - y * st, 100 + x * st + y * ct)
			end
		end

		-- title brightness wave
		if titleWaveOn then
			for i, l in ipairs(letters) do
				if letterLive[i] then
					local k = (math.sin(t * 3.2 - i * 0.5) + 1) / 2
					l.TextColor3 = THEME.Cyan:Lerp(WHITE, k * 0.85)
					l.TextStrokeTransparency = 0.92 - 0.25 * k
				end
			end
		end

		-- HUD brackets breathe
		local bt = 0.55 - 0.25 * pulse
		for _, b in ipairs(hudBrackets) do
			if b.BackgroundTransparency < 0.95 then
				b.BackgroundTransparency = bt
			end
		end

		-- segmented progress bar
		local lit = math.floor(p * SEGMENTS + 0.0001)
		for j = 1, SEGMENTS do
			local seg = segments[j]
			if j <= lit then
				local k = math.max(0, math.sin(t * 6 - j * 0.45))
				seg.BackgroundColor3 = THEME.Cyan:Lerp(THEME.Sky, j / SEGMENTS):Lerp(WHITE, k * 0.55)
				seg.BackgroundTransparency = 0
			elseif j == lit + 1 and p < 1 then
				seg.BackgroundColor3 = THEME.Cyan
				seg.BackgroundTransparency = 0.3 + 0.45 * ((math.sin(t * 10) + 1) / 2)
			else
				seg.BackgroundColor3 = Color3.fromRGB(22, 32, 44)
				seg.BackgroundTransparency = 0
			end
		end
		percentLabel.Text = string.format(
			'%d<font size="13" color="%s">%%</font>',
			math.floor(p * 100 + 0.5), rgbTag(THEME.Muted)
		)

		-- compact system metrics line
		fpsSmooth += (1 / math.max(dt, 1e-4) - fpsSmooth) * 0.1
		metricTimer += dt
		if metricTimer > 0.15 then
			metricTimer = 0
			metricsLine.Text = string.format(
				"CPU %d%%   MEM %d%%   NET %d%%   FPS %d",
				math.clamp(math.floor(25 + 55 * p + rng:NextNumber(-10, 10)), 0, 100),
				math.clamp(math.floor(28 + 35 * p + rng:NextNumber(-4, 4)), 0, 100),
				math.clamp(math.floor(20 + 45 * p + rng:NextNumber(-12, 12)), 0, 100),
				math.floor(fpsSmooth + 0.5)
			)
		end
	end)

	----------------------------------------------------------------
	-- INTRO (waits until the island has finished expanding)
	----------------------------------------------------------------
	task.wait(0.45)
	TweenService:Create(overlay, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { GroupTransparency = 0 }):Play()
	for _, b in ipairs(hudBrackets) do
		TweenService:Create(b, TweenInfo.new(0.6), { BackgroundTransparency = 0.4 }):Play()
	end
	task.wait(0.15)

	TweenService:Create(emblemScale, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = EMBLEM_SCALE }):Play()
	burst(THEME.Cyan, 420)
	chipFlash = 1.2
	for k, frames in ipairs(traceFrames) do -- traces light up one after another
		task.delay(0.1 + k * 0.05, function()
			for _, f in ipairs(frames) do
				TweenService:Create(f, TweenInfo.new(0.45), { BackgroundTransparency = 0.7 }):Play()
			end
		end)
	end
	task.delay(0.9, function()
		for _, pl in ipairs(pulses) do
			for k, dot in ipairs(pl.dots) do
				TweenService:Create(dot, TweenInfo.new(0.4), { BackgroundTransparency = pulseTransparency[k] }):Play()
			end
		end
		pulsesOn = true
	end)
	task.wait(0.35)

	titleWaveOn = true
	for i, l in ipairs(letters) do
		task.delay((i - 1) * 0.045, function()
			letterLive[i] = true
			TweenService:Create(l, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Position = UDim2.fromOffset(0, 0),
				TextTransparency = 0,
			}):Play()
		end)
	end
	task.wait(0.55)
	TweenService:Create(info, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { GroupTransparency = 0 }):Play()
	task.wait(0.3)

	----------------------------------------------------------------
	-- LOADING STAGES (the first two also wait for real data)
	----------------------------------------------------------------
	local stages = {
		{ 0.16, "> initializing modules...", 0.5 },
		{ 0.40, "> loading player profile...", 0.6 },
		{ 0.62, "> detecting sea & server...", 0.6 },
		{ 0.84, "> syncing network & performance...", 0.6 },
		{ 1.00, "> ready.", 0.5 },
	}
	for i, stage in ipairs(stages) do
		setStatus(stage[2])

		if i == 1 then
			logBatch({ "boot: ryzen-kernel 4.6.0", "cpu: 8 cores online", "mem: heap allocated" })
			local t0 = os.clock()
			while not game:IsLoaded() and os.clock() - t0 < 10 do
				task.wait(0.1)
			end
		elseif i == 2 then
			logBatch({ "auth: " .. player.Name, "profile: avatar cache warmed", "data: stats service linked" })
			if seaText ~= "UNKNOWN" then
				player:WaitForChild("Data", 8) -- Blox Fruits stats folder
			end
		elseif i == 3 then
			logBatch({ "world: " .. seaText, "scan: map segments indexed", "net: route resolved" })
		elseif i == 4 then
			logBatch({
				string.format("net: ping %d ms", math.floor(getPing() + 0.5)),
				string.format("gfx: %d fps", math.floor(fpsSmooth + 0.5)),
				"ui: mounting island module",
			})
		else
			logBatch({ "all modules loaded", "state: READY" })
		end

		local tween = TweenService:Create(progressValue, TweenInfo.new(stage[3], Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Value = stage[1],
		})
		tween:Play()
		tween.Completed:Wait()
		if i < #stages then
			burst(THEME.Sky, 300)
		end
		task.wait(0.08)
	end
	statusLabel.TextColor3 = THEME.Cyan

	----------------------------------------------------------------
	-- EXIT: final discharge -> flash -> overlay fades away revealing the dashboard
	----------------------------------------------------------------
	task.wait(0.25)
	forceArcsUntil = os.clock() - startClock + 0.6
	chipFlash = 1.5
	burst(WHITE, 700)
	task.wait(0.25)
	TweenService:Create(flashFrame, TweenInfo.new(0.1), { BackgroundTransparency = 0.5 }):Play()
	task.wait(0.12)
	TweenService:Create(flashFrame, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
	TweenService:Create(emblemScale, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = EMBLEM_SCALE * 1.2 }):Play()
	TweenService:Create(overlay, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { GroupTransparency = 1 }):Play()
	task.delay(0.3, onFinished)
	task.wait(0.65)
	running = false

	loaderConn:Disconnect()
	overlay:Destroy()
end

--// MAIN LOOP
local joinTime = os.time()
local frames, accum = 0, 0

refreshRegionButtonText()

local mainConnection = RunService.RenderStepped:Connect(function(dt)
	-- Neon border animation (rotating gradient + pulsing glow)
	local t = os.clock()
	local rotation = (t * 70) % 360
	for _, g in ipairs(animatedGradients) do
		g.Rotation = rotation
	end
	local pulse = (math.sin(t * 2.6) + 1) / 2 -- 0..1
	bodyStroke.Thickness = 2 + pulse * 0.8
	glowStroke.Thickness = 5 + pulse * 3
	glowStroke.Transparency = 0.86 - pulse * 0.1
	dot.BackgroundTransparency = pulse * 0.6

	-- Scrolling marquee (only while the panel is open)
	if panel.Visible then
		marqueeOffset -= CFG.MarqueeSpeed * dt
		if marqueeOffset <= -marqueeWidth then
			marqueeOffset += marqueeWidth
		end
		for i, l in ipairs(marqueeLabels) do
			l.Position = UDim2.fromOffset(marqueeOffset + (i - 1) * marqueeWidth, 0)
		end
	end

	-- FPS / ping / stats sampling
	frames += 1
	accum += dt
	if accum >= CFG.SampleInterval then
		local fps = frames / accum
		frames, accum = 0, 0
		local ping = getPing()

		local fpsColor = fpsChart.push(fps)
		local pingColor = pingChart.push(ping)

		fpsHeader.Text = string.format(
			'<font color="%s">%d</font> <font color="%s">FPS</font>',
			rgbTag(fpsColor), math.floor(fps + 0.5), rgbTag(THEME.Muted)
		)
		pingHeader.Text = string.format(
			'<font color="%s">%d</font> <font color="%s">ms</font>',
			rgbTag(pingColor), math.floor(ping + 0.5), rgbTag(THEME.Muted)
		)

		-- Level / Beli / Fragments
		local level = readStat("Level")
		local beli = readStat("Beli")
		local fragments = readStat("Fragments")
		levelValue.Text = level and ("Lv. " .. formatNumber(level)) or "N/A"
		beliValue.Text = beli and ("$" .. formatNumber(beli)) or "N/A"
		fragmentValue.Text = fragments and formatNumber(fragments) or "N/A"

		-- Clocks + server info
		sessionValue.Text = formatDuration(os.time() - joinTime)
		playersLabel.Text = string.format("Players: %d / %d", #Players:GetPlayers(), Players.MaxPlayers)
		local clock, date = getRegionTime(selectedRegion)
		globalValue.Text = clock
		globalDate.Text = date
		refreshRegionButtonText()
	end
end)

gui.Destroying:Connect(function()
	mainConnection:Disconnect()
end)

--// START: island opens -> loading plays inside it -> dashboard revealed -> notification
local function onLoaded()
	if not CFG.StartOpen then
		setExpanded(false)
	end
	task.delay(CFG.StartOpen and 0.4 or 0.9, function()
		notify(CFG.Name, "Loaded successfully  •  " .. seaText .. "  •  by " .. CFG.Credit, CFG.NotifyDuration)
	end)
end

island.Size = UDim2.fromOffset(46, CFG.CollapsedSize.Y) -- pill grows into the open panel
setExpanded(true) -- UI is open by default
if CFG.LoadingScreen then
	task.spawn(runInlineLoading, onLoaded)
else
	onLoaded()
end

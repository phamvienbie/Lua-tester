--[[
	RYZEN CONFIG V4.6  |  Dynamic Island HUD  |  by Kaibeo  |  LocalScript
	Place in: StarterPlayer > StarterPlayerScripts (or StarterGui)

	Features
	- Dynamic Island pill (top center) that expands / collapses with smooth tweens
	- Profile: display name, username, user id, avatar thumbnail
	- Session time + Global time with region selector (UTC, ICT, JST, SGT, EST/EDT, PST/PDT)
	- Live FPS counter + bar chart
	- Live Ping counter + bar chart
	- Sea 1 / 2 / 3 detection by PlaceId
	- Animated neon cyan / sky-blue gradient border (rotating + pulsing glow)
	- Load notification (Dynamic Island style toast) + scrolling marquee banner
	- The island itself is the ONLY toggle (no extra function buttons)
]]

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")
local Workspace = game:GetService("Workspace")
local TextService = game:GetService("TextService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

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
	CollapsedSize = Vector2.new(250, 40),
	ExpandedSize = Vector2.new(380, 540),
	HeaderHeight = 40,
	TopOffset = 10,
	SampleInterval = 0.25, -- seconds between chart samples
	HistoryLength = 40, -- bars per chart

	Name = "Ryzen Config V4.6",
	Credit = "Kaibeo",
	-- Scrolling banner text (Vietnamese alternative: "Cảm ơn bạn đã sử dụng config banana by Kaibeo")
	MarqueeText = "Thank you for using Banana Config by Kaibeo",
	MarqueeSpeed = 45, -- pixels per second
	NotifyDuration = 4, -- seconds the load toast stays visible
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
local old = playerGui:FindFirstChild("RyzenConfigUI")
if old then
	old:Destroy()
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

--// ISLAND WRAPPER (this is what gets resized)
local island = create("Frame", {
	Name = "Island",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, CFG.TopOffset),
	Size = UDim2.fromOffset(CFG.CollapsedSize.X, CFG.CollapsedSize.Y),
	BackgroundTransparency = 1,
}, gui)
create("UISizeConstraint", { MinSize = Vector2.new(150, 36), MaxSize = Vector2.new(430, 640) }, island)
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
local glowCorner = corner(glow, 25)
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
local bodyCorner = corner(body, 20)
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
	Position = UDim2.fromOffset(14, 16),
	Size = UDim2.fromOffset(8, 8),
	BackgroundColor3 = THEME.Cyan,
	BorderSizePixel = 0,
}, header)
corner(dot, 4)

label(header, {
	Name = "SeaHeader",
	Text = seaText,
	TextColor3 = THEME.Cyan,
	TextSize = 13,
	Position = UDim2.fromOffset(30, 0),
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
	Position = UDim2.new(1, -16, 0, 0),
	Size = UDim2.fromOffset(80, CFG.HeaderHeight),
})

local toggleButton = create("TextButton", {
	Name = "ToggleButton",
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Text = "",
	AutoButtonColor = false,
	ZIndex = 5,
}, header)

--// PANEL (expanded content)
local panel = create("CanvasGroup", {
	Name = "Panel",
	Position = UDim2.fromOffset(0, CFG.HeaderHeight + 8),
	Size = UDim2.new(1, 0, 1, -(CFG.HeaderHeight + 8)),
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

--// TITLE ROW
label(panel, {
	Text = string.upper(CFG.Name),
	TextSize = 13,
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

--// PROFILE CARD
local profileCard = makeCard(UDim2.fromOffset(0, 26), UDim2.new(1, 0, 0, 84))

local avatar = create("ImageLabel", {
	Name = "Avatar",
	Position = UDim2.fromOffset(10, 10),
	Size = UDim2.fromOffset(64, 64),
	BackgroundColor3 = THEME.CardAlt,
	BorderSizePixel = 0,
	Image = "",
}, profileCard)
corner(avatar, 32)
create("UIAspectRatioConstraint", { AspectRatio = 1 }, avatar)
neonGradient(stroke(avatar, Color3.new(1, 1, 1), 2, 0))

label(profileCard, {
	Text = player.DisplayName,
	TextSize = 18,
	TextTruncate = Enum.TextTruncate.AtEnd,
	Position = UDim2.fromOffset(86, 12),
	Size = UDim2.new(1, -170, 0, 24),
})
label(profileCard, {
	Text = "@" .. player.Name,
	Font = Enum.Font.GothamMedium,
	TextSize = 13,
	TextColor3 = THEME.Sky,
	TextTruncate = Enum.TextTruncate.AtEnd,
	Position = UDim2.fromOffset(86, 36),
	Size = UDim2.new(1, -170, 0, 18),
})
label(profileCard, {
	Text = "ID: " .. player.UserId,
	Font = Enum.Font.GothamMedium,
	TextSize = 11,
	TextColor3 = THEME.Muted,
	Position = UDim2.fromOffset(86, 55),
	Size = UDim2.new(1, -170, 0, 16),
})

local seaBadge = create("Frame", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -12, 0, 12),
	Size = UDim2.fromOffset(72, 24),
	BackgroundColor3 = THEME.CardAlt,
	BorderSizePixel = 0,
}, profileCard)
corner(seaBadge, 12)
stroke(seaBadge, THEME.Cyan, 1, 0.3)
label(seaBadge, {
	Text = seaText,
	TextSize = 12,
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

--// TIME CARDS
local sessionCard = makeCard(UDim2.fromOffset(0, 118), UDim2.new(0.5, -4, 0, 100))
label(sessionCard, {
	Text = "SESSION TIME",
	TextSize = 11,
	TextColor3 = THEME.Muted,
	Position = UDim2.fromOffset(12, 8),
	Size = UDim2.new(1, -24, 0, 16),
})
local sessionValue = label(sessionCard, {
	Text = "00:00:00",
	TextSize = 24,
	TextColor3 = THEME.Cyan,
	Position = UDim2.fromOffset(12, 28),
	Size = UDim2.new(1, -24, 0, 30),
})
label(sessionCard, {
	Text = "Since you joined",
	Font = Enum.Font.GothamMedium,
	TextSize = 11,
	TextColor3 = THEME.Muted,
	Position = UDim2.fromOffset(12, 60),
	Size = UDim2.new(1, -24, 0, 16),
})

local globalCard = makeCard(UDim2.new(0.5, 4, 0, 118), UDim2.new(0.5, -4, 0, 100))
label(globalCard, {
	Text = "GLOBAL TIME",
	TextSize = 11,
	TextColor3 = THEME.Muted,
	Position = UDim2.fromOffset(12, 8),
	Size = UDim2.new(1, -24, 0, 16),
})
local globalValue = label(globalCard, {
	Text = "00:00:00",
	TextSize = 24,
	TextColor3 = THEME.White,
	Position = UDim2.fromOffset(12, 28),
	Size = UDim2.new(1, -24, 0, 30),
})
local globalDate = label(globalCard, {
	Text = "",
	Font = Enum.Font.GothamMedium,
	TextSize = 10,
	TextColor3 = THEME.Muted,
	TextTruncate = Enum.TextTruncate.AtEnd,
	Position = UDim2.fromOffset(12, 56),
	Size = UDim2.new(1, -24, 0, 14),
})
local regionButton = create("TextButton", {
	Position = UDim2.fromOffset(12, 74),
	Size = UDim2.new(1, -24, 0, 20),
	BackgroundColor3 = THEME.CardAlt,
	AutoButtonColor = false,
	Font = Enum.Font.GothamBold,
	TextSize = 11,
	TextColor3 = THEME.Cyan,
	Text = "",
	BorderSizePixel = 0,
}, globalCard)
corner(regionButton, 8)
stroke(regionButton, THEME.Cyan, 1, 0.6)

--// FPS + PING CHARTS
local function makeChart(opts)
	local N = CFG.HistoryLength
	local frame = makeCard(opts.position, UDim2.new(1, 0, 0, 104))

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
		Size = UDim2.new(1, -24, 0, 50),
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
		Position = UDim2.fromOffset(12, 86),
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
	position = UDim2.fromOffset(0, 226),
	title = "FRAMES PER SECOND",
	unit = "FPS",
	minTop = 60,
	good = 50,
	warn = 30,
	higherIsBetter = true,
})

local pingChart = makeChart({
	position = UDim2.fromOffset(0, 338),
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
	Position = UDim2.fromOffset(0, 450),
	Size = UDim2.new(1, 0, 0, 24),
	BackgroundColor3 = THEME.Card,
	BorderSizePixel = 0,
}, panel)
corner(marqueeStrip, 12)
stroke(marqueeStrip, THEME.Cyan, 1, 0.78)
create("UIGradient", { -- fades the text out at both edges
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.9),
		NumberSequenceKeypoint.new(0.1, 0),
		NumberSequenceKeypoint.new(0.9, 0),
		NumberSequenceKeypoint.new(1, 0.9),
	}),
}, marqueeStrip)

local marqueeUnit = "     " .. CFG.MarqueeText .. "     •     " .. CFG.Name .. "     •"
local okSize, marqueeBounds = pcall(function()
	return TextService:GetTextSize(marqueeUnit, 12, Enum.Font.GothamBold, Vector2.new(10000, 24))
end)
local marqueeWidth = math.max(okSize and marqueeBounds.X or (#marqueeUnit * 7.5), 120)
local marqueeLabels = {}
for i = 1, math.ceil(360 / marqueeWidth) + 1 do -- enough copies for a seamless loop
	marqueeLabels[i] = label(marqueeStrip, {
		Text = marqueeUnit,
		TextSize = 12,
		TextColor3 = THEME.Sky,
		Position = UDim2.fromOffset((i - 1) * marqueeWidth, 0),
		Size = UDim2.fromOffset(marqueeWidth, 24),
	})
end
local marqueeOffset = 0

--// REGION DROPDOWN
local selectedRegion = REGIONS[2] -- default: ICT / Vietnam
local dropdownOpen = false
local DROPDOWN_HEIGHT = #REGIONS * 24 + 8

local dropdown = create("Frame", {
	Name = "RegionDropdown",
	Position = UDim2.new(0.5, 4, 0, 118 + 98),
	Size = UDim2.new(0.5, -4, 0, 0),
	BackgroundColor3 = Color3.fromRGB(8, 11, 16),
	BorderSizePixel = 0,
	ClipsDescendants = true,
	Visible = false,
	ZIndex = 20,
}, panel)
corner(dropdown, 10)
stroke(dropdown, THEME.Cyan, 1.2, 0.3)
create("UIPadding", {
	PaddingTop = UDim.new(0, 4),
	PaddingBottom = UDim.new(0, 4),
	PaddingLeft = UDim.new(0, 4),
	PaddingRight = UDim.new(0, 4),
}, dropdown)
create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, dropdown)

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
	local tween = TweenService:Create(
		dropdown,
		TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{ Size = UDim2.new(0.5, -4, 0, open and DROPDOWN_HEIGHT or 0) }
	)
	tween:Play()
	if not open then
		tween.Completed:Connect(function()
			if not dropdownOpen then
				dropdown.Visible = false
			end
		end)
	end
end

for i, region in ipairs(REGIONS) do
	local btn = create("TextButton", {
		LayoutOrder = i,
		Size = UDim2.new(1, 0, 0, 22),
		BackgroundColor3 = THEME.CardAlt,
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Font = Enum.Font.GothamMedium,
		TextSize = 11,
		TextColor3 = THEME.White,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "  " .. region.id .. " · " .. region.place,
		BorderSizePixel = 0,
		ZIndex = 21,
	}, dropdown)
	corner(btn, 6)
	regionButtons[region] = btn

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundTransparency = 0 }):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundTransparency = 1 }):Play()
	end)
	btn.Activated:Connect(function()
		selectedRegion = region
		for r, b in pairs(regionButtons) do
			b.TextColor3 = (r == selectedRegion) and THEME.Cyan or THEME.White
		end
		refreshRegionButtonText()
		setDropdown(false)
	end)
end
regionButtons[selectedRegion].TextColor3 = THEME.Cyan

regionButton.Activated:Connect(function()
	setDropdown(not dropdownOpen)
end)

--// RESPONSIVE SCALE
local camera = Workspace.CurrentCamera
local expanded = false

local function targetScale(isExpanded)
	if not isExpanded then
		return 1
	end
	local vp = camera.ViewportSize
	local fit = math.min(
		(vp.X - 16) / CFG.ExpandedSize.X,
		(vp.Y - 24) / (CFG.ExpandedSize.Y + CFG.TopOffset)
	)
	return math.clamp(fit, 0.5, 1.1)
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
		and TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		or TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)

	TweenService:Create(island, sizeInfo, { Size = UDim2.fromOffset(size.X, size.Y) }):Play()
	TweenService:Create(uiScale, TweenInfo.new(0.45, Enum.EasingStyle.Quint), { Scale = targetScale(state) }):Play()
	TweenService:Create(bodyCorner, sizeInfo, { CornerRadius = UDim.new(0, state and 30 or 20) }):Play()
	TweenService:Create(glowCorner, sizeInfo, { CornerRadius = UDim.new(0, state and 35 or 25) }):Play()

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

-- Small hover "breathing" effect on the collapsed pill
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

--// NETWORK PING
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

--// LOAD NOTIFICATION (Dynamic Island style toast)
local function notify(title, text, duration)
	local width = math.min(300, camera.ViewportSize.X - 20)
	local toast = create("CanvasGroup", {
		Name = "Notify",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, CFG.TopOffset + CFG.CollapsedSize.Y + 10),
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

--// MAIN LOOP
local joinTime = os.time()
local frames, accum = 0, 0

refreshRegionButtonText()

-- Intro: pill grows into place, then the load notification slides out below it
island.Size = UDim2.fromOffset(46, CFG.CollapsedSize.Y)
TweenService:Create(island, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
	Size = UDim2.fromOffset(CFG.CollapsedSize.X, CFG.CollapsedSize.Y),
}):Play()
task.delay(0.8, function()
	notify(CFG.Name, "Loaded successfully  •  " .. seaText .. "  •  by " .. CFG.Credit, CFG.NotifyDuration)
end)

local connection = RunService.RenderStepped:Connect(function(dt)
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

	-- FPS / ping sampling
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

		-- Clocks
		sessionValue.Text = formatDuration(os.time() - joinTime)
		local clock, date = getRegionTime(selectedRegion)
		globalValue.Text = clock
		globalDate.Text = date
		refreshRegionButtonText()
	end
end)

gui.Destroying:Connect(function()
	connection:Disconnect()
end)

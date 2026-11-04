-- Ryzen X - V4.5 [ Beta ] | UI ngang Đen/Đỏ + RGB
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local VirtualUser = game:GetService("VirtualUser")

local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera
local startTime = os.time()

local parent = (gethui and gethui()) or game:GetService("CoreGui")
if parent:FindFirstChild("RyzenX") then parent.RyzenX:Destroy() end

local BG = Color3.fromRGB(9, 9, 11)
local PANEL = Color3.fromRGB(16, 16, 20)
local CARD = Color3.fromRGB(22, 22, 27)
local CARD_HOVER = Color3.fromRGB(34, 24, 29)
local OFF = Color3.fromRGB(52, 52, 60)
local RED = Color3.fromRGB(255, 35, 55)
local DARKRED = Color3.fromRGB(70, 10, 18)
local EDGE = Color3.fromRGB(60, 18, 26)
local WHITE = Color3.new(1, 1, 1)
local GRAY = Color3.fromRGB(150, 150, 162)
local GOOD, MID = Color3.fromRGB(90, 255, 140), Color3.fromRGB(255, 200, 60)

local World1 = game.PlaceId == 2753915549 or game.PlaceId == 85211729168715
local World2 = game.PlaceId == 4442272183 or game.PlaceId == 79091703265657
local World3 = game.PlaceId == 7449423635 or game.PlaceId == 100117331123089
local SEA_NAME = World1 and "Sea 1" or World2 and "Sea 2" or World3 and "Sea 3" or "Unknown"

-- Gắn code của bạn vào các giá trị này (vd: while Settings.AutoFarm do ... end)
local Settings = { AutoFarm = false, AutoBounty = false, AutoRaid = false, ESP = false, AutoChest = false, FastAttack = false }
local rgbMode, rgbSpeed, antiAfk = false, 1, true
local grads = {}

---------------------------------------------------------------- helpers
local function new(class, props)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	return o
end
local function tween(o, t, props, style, dir)
	return TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
end
local function corner(p, r) return new("UICorner", { CornerRadius = UDim.new(0, r), Parent = p }) end
local function stroke(p, t)
	local s = new("UIStroke", { Color = WHITE, Thickness = t or 1.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = p })
	table.insert(grads, new("UIGradient", { Parent = s }))
	return s
end
local function label(p, text, size, color, font, pos, sz, align)
	return new("TextLabel", {
		Text = text, TextSize = size, TextColor3 = color or WHITE, Font = font or Enum.Font.GothamMedium,
		BackgroundTransparency = 1, Position = pos or UDim2.new(), Size = sz or UDim2.fromScale(1, 1),
		TextXAlignment = align or Enum.TextXAlignment.Left, Parent = p,
	})
end
local function isPress(i) return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch end
local function isMove(i) return i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch end

local function drag(handle, target, scaleObj)
	local st = { moved = false }
	local dragging, startIn, startPos
	handle.InputBegan:Connect(function(i)
		if isPress(i) then
			dragging, startIn, startPos, st.moved = true, i.Position, target.Position, false
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and isMove(i) then
			local d = (i.Position - startIn) / (scaleObj and scaleObj.Scale or 1)
			if d.Magnitude > 4 then st.moved = true end
			target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
	return st
end

---------------------------------------------------------------- root
local gui = new("ScreenGui", { Name = "RyzenX", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = parent })

local main = new("Frame", {
	Size = UDim2.fromOffset(660, 400), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
	BackgroundColor3 = BG, ClipsDescendants = true, Parent = gui,
})
corner(main, 16) stroke(main, 2.5)
new("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(14, 14, 18), Color3.fromRGB(32, 6, 12)), Rotation = 45, Parent = main })
local scale = new("UIScale", { Scale = 0, Parent = main })

-- particles nền
local fx = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ClipsDescendants = true, Parent = main })
for _ = 1, 22 do
	local s = math.random(2, 4)
	local d = new("Frame", { Size = UDim2.fromOffset(s, s), BackgroundColor3 = RED, BackgroundTransparency = 1, BorderSizePixel = 0, Parent = fx })
	corner(d, s)
	task.spawn(function()
		task.wait(math.random() * 4)
		while d.Parent do
			local x = math.random()
			d.Position = UDim2.new(x, 0, 1, 0)
			d.BackgroundTransparency = 0.75
			local t = tween(d, math.random(40, 90) / 10, { Position = UDim2.new(x, 0, 0, -10), BackgroundTransparency = 1 }, Enum.EasingStyle.Linear)
			t:Play()
			t.Completed:Wait()
		end
	end)
end

-- toast
local function notify(text)
	local f = new("Frame", { Size = UDim2.fromOffset(230, 40), AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, 250, 1, -20), BackgroundColor3 = BG, Parent = gui })
	corner(f, 10)
	new("UIStroke", { Color = RED, Thickness = 1.5, Parent = f })
	label(f, text, 13, WHITE, Enum.Font.GothamMedium, UDim2.fromOffset(14, 0), UDim2.new(1, -20, 1, 0))
	tween(f, 0.4, { Position = UDim2.new(1, -20, 1, -20) }, Enum.EasingStyle.Back):Play()
	task.delay(2.2, function()
		local t = tween(f, 0.3, { Position = UDim2.new(1, 250, 1, -20) })
		t:Play() t.Completed:Wait() f:Destroy()
	end)
end

---------------------------------------------------------------- header
local header = new("Frame", { Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1, Parent = main })
local title = label(header, "Ryzen X - V4.5 [ Beta ]", 17, RED, Enum.Font.GothamBlack, UDim2.fromOffset(18, 0), UDim2.new(1, -100, 1, 0))
local function headBtn(txt, x)
	local b = new("TextButton", {
		Text = txt, TextSize = 15, Font = Enum.Font.GothamBold, TextColor3 = WHITE, BackgroundColor3 = CARD,
		Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, x, 0.5, -14), AutoButtonColor = false, Parent = header,
	})
	corner(b, 8)
	b.MouseEnter:Connect(function() tween(b, 0.15, { BackgroundColor3 = RED }):Play() end)
	b.MouseLeave:Connect(function() tween(b, 0.15, { BackgroundColor3 = CARD }):Play() end)
	return b
end
local hideBtn, closeBtn = headBtn("—", -72), headBtn("X", -38)
drag(header, main, scale)

local shine = new("Frame", { Size = UDim2.new(1, 0, 0, 2), Position = UDim2.fromOffset(0, 44), BackgroundColor3 = RED, BorderSizePixel = 0, Parent = main })
local shineG = new("UIGradient", {
	Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) }),
	Parent = shine,
})

---------------------------------------------------------------- sidebar
local side = new("Frame", { Size = UDim2.fromOffset(190, 354), Position = UDim2.fromOffset(0, 46), BackgroundColor3 = PANEL, BackgroundTransparency = 0.35, BorderSizePixel = 0, Parent = main })

local ring = new("Frame", { Size = UDim2.fromOffset(86, 86), Position = UDim2.fromOffset(52, 14), BackgroundTransparency = 1, Parent = side })
corner(ring, 43) stroke(ring, 3)
local av = new("ImageLabel", { Size = UDim2.fromOffset(72, 72), Position = UDim2.fromOffset(7, 7), BackgroundColor3 = BG, Image = "", Parent = ring })
corner(av, 36)
task.spawn(function()
	local ok, img = pcall(Players.GetUserThumbnailAsync, Players, lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
	if ok then av.Image = img end
end)
label(side, lp.DisplayName, 16, WHITE, Enum.Font.GothamBold, UDim2.fromOffset(0, 108), UDim2.new(1, 0, 0, 20), Enum.TextXAlignment.Center)
label(side, "@" .. lp.Name, 12, GRAY, Enum.Font.Gotham, UDim2.fromOffset(0, 128), UDim2.new(1, 0, 0, 16), Enum.TextXAlignment.Center)
new("Frame", { Size = UDim2.new(1, -40, 0, 1), Position = UDim2.fromOffset(20, 152), BackgroundColor3 = EDGE, BorderSizePixel = 0, Parent = side })
label(side, "Ryzen X • Beta", 11, GRAY, Enum.Font.Gotham, UDim2.fromOffset(0, 328), UDim2.new(1, 0, 0, 16), Enum.TextXAlignment.Center)

local indicator = new("Frame", { Size = UDim2.fromOffset(4, 26), Position = UDim2.fromOffset(8, 170), BackgroundColor3 = RED, BorderSizePixel = 0, Parent = side })
corner(indicator, 2)

---------------------------------------------------------------- pages / tabs
local pagesF = new("Frame", { Size = UDim2.fromOffset(450, 334), Position = UDim2.fromOffset(200, 56), BackgroundTransparency = 1, Parent = main })
local pages, tabs, cur = {}, {}, 0
local function newPage()
	local p = new("CanvasGroup", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, Parent = pagesF })
	table.insert(pages, p)
	return p
end
local function switchTab(i)
	if i == cur then return end
	cur = i
	for k, p in ipairs(pages) do
		p.Visible = (k == i)
		tween(tabs[k].btn, 0.2, { BackgroundTransparency = k == i and 0.4 or 1 }):Play()
		tween(tabs[k].txt, 0.2, { TextColor3 = k == i and WHITE or GRAY }):Play()
	end
	local p = pages[i]
	p.GroupTransparency, p.Position = 1, UDim2.fromOffset(0, 18)
	tween(p, 0.35, { GroupTransparency = 0, Position = UDim2.new() }, Enum.EasingStyle.Quint):Play()
	tween(indicator, 0.3, { Position = UDim2.fromOffset(8, 170 + (i - 1) * 44) }, Enum.EasingStyle.Back):Play()
end
for i, name in ipairs({ "Thông tin", "Chức năng", "Cài đặt" }) do
	local b = new("TextButton", {
		Text = "", Size = UDim2.fromOffset(160, 38), Position = UDim2.fromOffset(22, 164 + (i - 1) * 44),
		BackgroundColor3 = DARKRED, BackgroundTransparency = 1, AutoButtonColor = false, Parent = side,
	})
	corner(b, 10)
	local t = label(b, name, 14, GRAY, Enum.Font.GothamBold, UDim2.fromOffset(16, 0), UDim2.new(1, -16, 1, 0))
	tabs[i] = { btn = b, txt = t }
	b.MouseEnter:Connect(function() if cur ~= i then tween(b, 0.15, { BackgroundTransparency = 0.75 }):Play() end end)
	b.MouseLeave:Connect(function() if cur ~= i then tween(b, 0.15, { BackgroundTransparency = 1 }):Play() end end)
	b.MouseButton1Click:Connect(function() switchTab(i) end)
end

---------------------------------------------------------------- components
local function baseCard(p)
	local f = new("Frame", { BackgroundColor3 = CARD, BackgroundTransparency = 0.1, Parent = p })
	corner(f, 10)
	local st = new("UIStroke", { Color = EDGE, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = f })
	f.MouseEnter:Connect(function()
		tween(f, 0.2, { BackgroundColor3 = CARD_HOVER }):Play()
		tween(st, 0.2, { Color = RED }):Play()
	end)
	f.MouseLeave:Connect(function()
		tween(f, 0.2, { BackgroundColor3 = CARD }):Play()
		tween(st, 0.2, { Color = EDGE }):Play()
	end)
	return f
end

local function addToggle(p, text, default, cb)
	local row = baseCard(p)
	row.Size = UDim2.new(1, 0, 0, 46)
	label(row, text, 14, WHITE, Enum.Font.GothamMedium, UDim2.fromOffset(14, 0), UDim2.new(1, -76, 1, 0))
	local sw = new("TextButton", {
		Text = "", Size = UDim2.fromOffset(46, 24), Position = UDim2.new(1, -58, 0.5, -12),
		BackgroundColor3 = OFF, AutoButtonColor = false, Parent = row,
	})
	corner(sw, 12)
	local knob = new("Frame", { Size = UDim2.fromOffset(18, 18), Position = UDim2.new(0, 3, 0.5, -9), BackgroundColor3 = WHITE, Parent = sw })
	corner(knob, 9)
	local state = default
	local function render(anim)
		local t = anim and 0.25 or 0
		tween(sw, t, { BackgroundColor3 = state and RED or OFF }):Play()
		tween(knob, t, { Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9) }, Enum.EasingStyle.Back):Play()
	end
	sw.MouseButton1Click:Connect(function()
		state = not state
		render(true)
		task.spawn(cb, state)
		notify(text .. ": " .. (state and "ON" or "OFF"))
	end)
	render(false)
	if default then task.spawn(cb, true) end
end

local function addSlider(p, text, min, max, default, cb)
	local row = baseCard(p)
	row.Size = UDim2.new(1, 0, 0, 58)
	label(row, text, 14, WHITE, Enum.Font.GothamMedium, UDim2.fromOffset(14, 6), UDim2.new(0.6, 0, 0, 20))
	local val = label(row, "", 13, RED, Enum.Font.GothamBold, UDim2.new(0.5, 0, 0, 6), UDim2.new(0.5, -14, 0, 20), Enum.TextXAlignment.Right)
	local track = new("Frame", { Size = UDim2.new(1, -28, 0, 6), Position = UDim2.fromOffset(14, 40), BackgroundColor3 = OFF, Parent = row })
	corner(track, 3)
	local fill = new("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = RED, Parent = track })
	corner(fill, 3)
	local knob = new("Frame", { Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), BackgroundColor3 = WHITE, Parent = track })
	corner(knob, 7)
	local function set(r)
		r = math.clamp(r, 0, 1)
		fill.Size = UDim2.fromScale(r, 1)
		knob.Position = UDim2.fromScale(r, 0.5)
		local v = math.floor((min + (max - min) * r) * 10 + 0.5) / 10
		val.Text = v .. "x"
		cb(v)
	end
	set((default - min) / (max - min))
	local dragging = false
	local function upd(x) set((x - track.AbsolutePosition.X) / track.AbsoluteSize.X) end
	row.InputBegan:Connect(function(i) if isPress(i) then dragging = true upd(i.Position.X) end end)
	UIS.InputEnded:Connect(function(i) if isPress(i) then dragging = false end end)
	UIS.InputChanged:Connect(function(i) if dragging and isMove(i) then upd(i.Position.X) end end)
end

---------------------------------------------------------------- page 1: thông tin
local info = newPage()
local grid = new("Frame", { Size = UDim2.new(1, 0, 0, 132), BackgroundTransparency = 1, Parent = info })
new("UIGridLayout", { CellSize = UDim2.new(1 / 3, -6, 0, 62), CellPadding = UDim2.fromOffset(8, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = grid })
local function statCard(name, order)
	local c = baseCard(grid)
	c.LayoutOrder = order
	label(c, name, 12, GRAY, Enum.Font.Gotham, UDim2.fromOffset(12, 8), UDim2.new(1, -12, 0, 16))
	return label(c, "--", 18, RED, Enum.Font.GothamBold, UDim2.fromOffset(12, 28), UDim2.new(1, -12, 0, 26))
end
local timeL, fpsL, pingL = statCard("Thời gian chơi", 1), statCard("FPS", 2), statCard("Ping", 3)
local seaL, plrL, ramL = statCard("Sea", 4), statCard("Người chơi", 5), statCard("RAM", 6)
seaL.Text = SEA_NAME

local graph = baseCard(info)
graph.Position, graph.Size = UDim2.fromOffset(0, 140), UDim2.new(1, 0, 0, 190)
label(graph, "FPS • lịch sử", 13, GRAY, Enum.Font.GothamMedium, UDim2.fromOffset(14, 8), UDim2.new(0.5, 0, 0, 18))
local avgL = label(graph, "AVG --", 13, RED, Enum.Font.GothamBold, UDim2.new(0.5, 0, 0, 8), UDim2.new(0.5, -14, 0, 18), Enum.TextXAlignment.Right)
local barsF = new("Frame", { Size = UDim2.new(1, -28, 1, -44), Position = UDim2.fromOffset(14, 32), BackgroundTransparency = 1, Parent = graph })
local N, bars, hist = 40, {}, {}
for i = 1, N do
	hist[i] = 0
	local b = new("Frame", {
		AnchorPoint = Vector2.new(0, 1), Position = UDim2.new((i - 1) / N, 1, 1, 0),
		Size = UDim2.new(1 / N, -2, 0.04, 0), BackgroundColor3 = RED, BorderSizePixel = 0, Parent = barsF,
	})
	corner(b, 2)
	new("UIGradient", { Color = ColorSequence.new(RED, DARKRED), Rotation = 90, Parent = b })
	bars[i] = b
end

---------------------------------------------------------------- page 2: chức năng
local funcs = newPage()
local fg = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = funcs })
new("UIGridLayout", { CellSize = UDim2.new(0.5, -4, 0, 46), CellPadding = UDim2.fromOffset(8, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = fg })
for _, f in ipairs({
	{ "Auto Farm Level", "AutoFarm" }, { "Auto Bounty", "AutoBounty" }, { "Auto Raid", "AutoRaid" },
	{ "ESP Player", "ESP" }, { "Auto Chest", "AutoChest" }, { "Fast Attack", "FastAttack" },
}) do
	addToggle(fg, f[1], false, function(v) Settings[f[2]] = v end)
end

---------------------------------------------------------------- page 3: cài đặt
local sett = newPage()
local sl = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = sett })
new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = sl })
addToggle(sl, "RGB Mode", false, function(v) rgbMode = v end)
addToggle(sl, "Hiệu ứng hạt nền", true, function(v) fx.Visible = v end)
addToggle(sl, "Anti AFK", true, function(v) antiAfk = v end)
addSlider(sl, "Tốc độ viền", 0.2, 3, 1, function(v) rgbSpeed = v end)
label(sl, "RightShift: ẩn / hiện UI", 12, GRAY, Enum.Font.Gotham, UDim2.new(), UDim2.new(1, 0, 0, 20), Enum.TextXAlignment.Center)

lp.Idled:Connect(function()
	if antiAfk then
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
	end
end)

---------------------------------------------------------------- nút tròn + mở/đóng
local fab = new("TextButton", {
	Text = "R", TextSize = 22, Font = Enum.Font.GothamBlack, TextColor3 = RED, BackgroundColor3 = BG,
	Size = UDim2.fromOffset(48, 48), Position = UDim2.new(0, 16, 0.5, -24), AutoButtonColor = false, Parent = gui,
})
corner(fab, 24) stroke(fab, 2)
local fabScale = new("UIScale", { Parent = fab })
local fabDrag = drag(fab, fab)

local open = true
local function fitScale()
	local v = cam.ViewportSize
	return math.min(1, v.X / 700, v.Y / 440)
end
local function setOpen(v)
	open = v
	if v then main.Visible = true end
	local t = tween(scale, 0.4, { Scale = v and fitScale() or 0 }, v and Enum.EasingStyle.Back or Enum.EasingStyle.Quad, v and Enum.EasingDirection.Out or Enum.EasingDirection.In)
	t:Play()
	if not v then t.Completed:Once(function() if not open then main.Visible = false end end) end
end
hideBtn.MouseButton1Click:Connect(function() setOpen(false) end)
fab.MouseButton1Click:Connect(function() if not fabDrag.moved then setOpen(not open) end end)
UIS.InputBegan:Connect(function(i, gp)
	if not gp and i.KeyCode == Enum.KeyCode.RightShift then setOpen(not open) end
end)
cam:GetPropertyChangedSignal("ViewportSize"):Connect(function() if open then scale.Scale = fitScale() end end)

---------------------------------------------------------------- loop
local frames, last, hue, shineOff, clock = 0, os.clock(), 0, -1, 0
local conn
conn = RunService.RenderStepped:Connect(function(dt)
	frames += 1
	clock += dt
	local now = os.clock()

	if now - last >= 0.25 then
		local fps = math.floor(frames / (now - last))
		frames, last = 0, now

		fpsL.Text, fpsL.TextColor3 = tostring(fps), fps >= 50 and GOOD or fps >= 30 and MID or RED
		local ok, ping = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
		if ok then
			ping = math.floor(ping)
			pingL.Text, pingL.TextColor3 = ping .. " ms", ping <= 100 and GOOD or ping <= 200 and MID or RED
		end
		local s = os.time() - startTime
		timeL.Text = string.format("%02d:%02d:%02d", s // 3600, s % 3600 // 60, s % 60)
		plrL.Text = #Players:GetPlayers() .. "/" .. Players.MaxPlayers
		ramL.Text = math.floor(Stats:GetTotalMemoryUsageMb()) .. " MB"

		table.remove(hist, 1)
		table.insert(hist, fps)
		local sum, cnt = 0, 0
		for i = 1, N do
			if hist[i] > 0 then sum += hist[i] cnt += 1 end
			tween(bars[i], 0.2, { Size = UDim2.new(1 / N, -2, math.clamp(hist[i] / 120, 0.04, 1), 0) }):Play()
		end
		avgL.Text = "AVG " .. (cnt > 0 and math.floor(sum / cnt) or "--")
	end

	-- viền / RGB
	hue = (hue + dt * 0.25 * rgbSpeed) % 1
	local seq = rgbMode and ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromHSV(hue, 1, 1)),
		ColorSequenceKeypoint.new(0.5, Color3.fromHSV((hue + 0.33) % 1, 1, 1)),
		ColorSequenceKeypoint.new(1, Color3.fromHSV((hue + 0.66) % 1, 1, 1)),
	}) or ColorSequence.new({
		ColorSequenceKeypoint.new(0, RED),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 0, 4)),
		ColorSequenceKeypoint.new(1, RED),
	})
	for _, g in ipairs(grads) do
		g.Color = seq
		g.Rotation = (g.Rotation + dt * 120 * rgbSpeed) % 360
	end
	local accent = rgbMode and Color3.fromHSV(hue, 1, 1) or RED
	title.TextColor3, indicator.BackgroundColor3, shine.BackgroundColor3, fab.TextColor3 = accent, accent, accent, accent

	-- thanh sáng chạy dưới header + nút R "thở"
	shineOff = shineOff + dt * 0.8
	if shineOff > 1 then shineOff = -1 end
	shineG.Offset = Vector2.new(shineOff, 0)
	fabScale.Scale = 1 + 0.06 * math.sin(clock * 3)
end)

closeBtn.MouseButton1Click:Connect(function()
	setOpen(false)
	task.wait(0.45)
	conn:Disconnect()
	gui:Destroy()
end)

switchTab(1)
setOpen(true)
notify("Ryzen X V4.5 [ Beta ] đã tải")

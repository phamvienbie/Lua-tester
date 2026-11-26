-- LocalScript: đặt vào StarterPlayer > StarterPlayerScripts
-- HubUI v2: gradient + Dynamic Island + thanh tiêu đề trắng kiểu Windows + icon tự vẽ (không dùng ký tự Unicode/asset)
-- Phím RightCtrl để ẩn/hiện

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

--------------------------------------------------------------------- THEME
local function RGB(r, g, b) return Color3.fromRGB(r, g, b) end

local C = {
	White   = Color3.new(1, 1, 1),
	Bg1     = RGB(18, 18, 30),
	Bg2     = RGB(9, 9, 15),
	Panel1  = RGB(26, 26, 42),
	Panel2  = RGB(17, 17, 28),
	Item    = RGB(31, 31, 48),
	ItemHov = RGB(40, 40, 62),
	Stroke  = RGB(62, 62, 90),
	Text    = RGB(245, 246, 250),
	Sub     = RGB(140, 144, 168),
	Off     = RGB(42, 42, 60),
	Knob    = RGB(205, 208, 224),
	-- gradient chủ đạo (đổi 2 màu này là đổi cả giao diện)
	A1      = RGB(139, 92, 246),
	A2      = RGB(56, 189, 248),
	-- thanh tiêu đề trắng
	BarBg1  = RGB(252, 252, 254),
	BarBg2  = RGB(232, 235, 245),
	BarText = RGB(26, 26, 38),
	BarSub  = RGB(112, 118, 138),
	-- trạng thái
	Ok1 = RGB(52, 211, 153),  Ok2 = RGB(16, 185, 129),
	Er1 = RGB(251, 113, 133), Er2 = RGB(239, 68, 68),
}

local ISLAND_TOP = 12                     -- cách mép trên màn hình (tăng nếu bị tai thỏ che)
local IDLE = Vector2.new(170, 40)         -- kích thước đảo khi thu gọn
local NOTI = Vector2.new(312, 68)         -- kích thước đảo khi hiện thông báo

--------------------------------------------------------------------- HELPERS
local function new(class, props, children)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	for _, c in ipairs(children or {}) do c.Parent = o end
	return o
end
local function corner(r) return new("UICorner", {CornerRadius = UDim.new(0, r)}) end
local function pill() return new("UICorner", {CornerRadius = UDim.new(1, 0)}) end
local function stroke(col, t)
	return new("UIStroke", {Color = col or C.Stroke, Thickness = t or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
end
local function pad(p)
	return new("UIPadding", {PaddingTop = UDim.new(0, p), PaddingBottom = UDim.new(0, p), PaddingLeft = UDim.new(0, p), PaddingRight = UDim.new(0, p)})
end
local function list(gap)
	return new("UIListLayout", {Padding = UDim.new(0, gap or 6), SortOrder = Enum.SortOrder.LayoutOrder})
end
local function label(text, size, color, bold)
	return new("TextLabel", {
		BackgroundTransparency = 1, Text = text, TextSize = size or 13,
		TextColor3 = color or C.Text, TextXAlignment = Enum.TextXAlignment.Left,
		Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
end
local function tw(o, props, t, style, dir)
	local tween = TweenService:Create(o, TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
	tween:Play()
	return tween
end

-- Gradient có thể xoay liên tục (dùng 1 vòng lặp Heartbeat chung)
local Animated = setmetatable({}, {__mode = "k"})
local function grad(parent, c1, c2, rot, spin)
	local g = new("UIGradient", {Color = ColorSequence.new(c1, c2), Rotation = rot or 0, Parent = parent})
	if spin then Animated[g] = spin end
	return g
end
local function loopGrad(parent, spin)
	local g = new("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, C.A1), ColorSequenceKeypoint.new(0.5, C.A2), ColorSequenceKeypoint.new(1, C.A1),
		}), Parent = parent,
	})
	Animated[g] = spin
	return g
end

--------------------------------------------------------------------- ICON TỰ VẼ (Frame + xoay, không cần ảnh/font)
local Draw = {
	check   = function(S) S(.22,.52,.42,.72,.13); S(.42,.72,.78,.30,.13) end,
	cross   = function(S) S(.26,.26,.74,.74,.13); S(.74,.26,.26,.74,.13) end,
	minus   = function(S) S(.18,.5,.82,.5,.09) end,
	square  = function(S, D, R, Q) Q(.5,.5,.62,1.2) end,
	restore = function(S, D, R, Q) Q(.43,.57,.5,1.2); Q(.57,.43,.5,1.2) end,
	chevron = function(S) S(.24,.38,.5,.64,.13); S(.5,.64,.76,.38,.13) end,
	home    = function(S)
		S(.14,.5,.5,.18,.11); S(.5,.18,.86,.5,.11)
		S(.27,.45,.27,.82,.11); S(.73,.45,.73,.82,.11); S(.27,.82,.73,.82,.11)
	end,
	gear    = function(S, D, R)
		R(.5,.5,.5,2)
		for i = 0, 7 do
			local a = math.rad(i * 45)
			S(.5 + math.cos(a) * .27, .5 + math.sin(a) * .27, .5 + math.cos(a) * .4, .5 + math.sin(a) * .4, .13)
		end
		R(.5,.5,.18,1.5)
	end,
	sword   = function(S, D)
		S(.24,.76,.78,.22,.13); S(.27,.5,.5,.73,.11); D(.2,.8,.15)
	end,
	target  = function(S, D, R) R(.5,.5,.8,2); R(.5,.5,.42,2); D(.5,.5,.14) end,
	layers  = function(S)
		S(.5,.18,.86,.38,.1); S(.86,.38,.5,.58,.1); S(.5,.58,.14,.38,.1); S(.14,.38,.5,.18,.1)
		S(.14,.6,.5,.8,.1); S(.5,.8,.86,.6,.1)
	end,
	flag    = function(S)
		S(.26,.16,.26,.86,.11); S(.26,.2,.78,.2,.1); S(.78,.2,.78,.52,.1); S(.26,.52,.78,.52,.1)
	end,
	info    = function(S, D, R) R(.5,.5,.84,2); D(.5,.31,.12); S(.5,.46,.5,.72,.12) end,
	bolt    = function(S) S(.62,.1,.32,.54,.13); S(.32,.54,.66,.46,.13); S(.66,.46,.38,.9,.13) end,
}

local function Icon(name, parent, size, col)
	col = col or C.Text
	local root = new("Frame", {Name = "Icon_" .. name, Size = UDim2.fromOffset(size, size), BackgroundTransparency = 1, Parent = parent})
	local parts = {}
	local function S(x1, y1, x2, y2, t) -- đoạn thẳng bo tròn 2 đầu
		local dx, dy = x2 - x1, y2 - y1
		local f = new("Frame", {
			AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale((x1 + x2) / 2, (y1 + y2) / 2),
			Size = UDim2.fromScale(math.sqrt(dx * dx + dy * dy) + t, t), Rotation = math.deg(math.atan2(dy, dx)),
			BackgroundColor3 = col, BorderSizePixel = 0, Parent = root,
		}, {pill()})
		parts[#parts + 1] = {f, "f"}
	end
	local function D(cx, cy, d) -- chấm tròn đặc
		local f = new("Frame", {
			AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(cx, cy), Size = UDim2.fromScale(d, d),
			BackgroundColor3 = col, BorderSizePixel = 0, Parent = root,
		}, {pill()})
		parts[#parts + 1] = {f, "f"}
	end
	local function R(cx, cy, d, th) -- vòng tròn rỗng
		local f = new("Frame", {
			AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(cx, cy), Size = UDim2.fromScale(d, d),
			BackgroundTransparency = 1, BorderSizePixel = 0, Parent = root,
		}, {pill()})
		local s = new("UIStroke", {Color = col, Thickness = th, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = f})
		parts[#parts + 1] = {s, "s"}
	end
	local function Q(cx, cy, w, th) -- hình vuông rỗng
		local f = new("Frame", {
			AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(cx, cy), Size = UDim2.fromScale(w, w),
			BackgroundTransparency = 1, BorderSizePixel = 0, Parent = root,
		}, {corner(2)})
		local s = new("UIStroke", {Color = col, Thickness = th, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = f})
		parts[#parts + 1] = {s, "s"}
	end

	local fn = Draw[name]
	if fn then fn(S, D, R, Q) end

	local api = {Root = root}
	function api.SetColor(c)
		for _, p in ipairs(parts) do
			if p[2] == "f" then p[1].BackgroundColor3 = c else p[1].Color = c end
		end
	end
	return api
end

--------------------------------------------------------------------- SWITCH (dùng chung cho TOÀN BỘ UI: đảo, toggle, ...)
-- Bật = nền gradient + núm trắng có dấu tích tự vẽ bung ra; tắt = nền tối + núm xám
local function CreateSwitch(parent, default, callback, W, H, noHit)
	W, H = W or 48, H or 26
	local PAD = 3
	local K = H - PAD * 2
	local enabled = default and true or false

	local track = new("Frame", {
		Name = "Track", Size = UDim2.fromOffset(W, H), BackgroundColor3 = C.Off, BorderSizePixel = 0, Parent = parent,
	}, {pill()})
	local st = stroke(C.Stroke, 1); st.Parent = track
	local fill = new("Frame", {
		Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.White, BackgroundTransparency = 1, BorderSizePixel = 0, Parent = track,
	}, {pill()})
	grad(fill, C.A1, C.A2, 0)

	local knob = new("Frame", {
		Name = "Knob", Size = UDim2.fromOffset(K, K), AnchorPoint = Vector2.new(0, .5),
		BackgroundColor3 = C.Knob, BorderSizePixel = 0, ZIndex = 2, Parent = track,
	}, {pill()})
	local isz = math.floor(K * 0.72)
	local ic = Icon("check", knob, isz, C.A1)
	ic.Root.AnchorPoint = Vector2.new(.5, .5); ic.Root.Position = UDim2.fromScale(.5, .5); ic.Root.ZIndex = 3
	local sc = new("UIScale", {Scale = 0.01, Parent = ic.Root})

	local function xFor(on) return on and (W - K - PAD) or PAD end
	local function apply(anim)
		local on = enabled
		local x = xFor(on)
		if not anim then
			knob.Position = UDim2.new(0, x, .5, 0)
			knob.BackgroundColor3 = on and C.White or C.Knob
			fill.BackgroundTransparency = on and 0 or 1
			st.Transparency = on and 1 or 0
			sc.Scale = on and 1 or 0.01
			return
		end
		tw(knob, {Position = UDim2.new(0, x, .5, 0), BackgroundColor3 = on and C.White or C.Knob}, .42, Enum.EasingStyle.Back)
		tw(fill, {BackgroundTransparency = on and 0 or 1}, .3, Enum.EasingStyle.Sine)
		tw(st, {Transparency = on and 1 or 0}, .3, Enum.EasingStyle.Sine)
		tw(sc, {Scale = on and 1 or 0.01}, .38, on and Enum.EasingStyle.Back or Enum.EasingStyle.Quint)
		-- hiệu ứng núm giãn ra khi trượt
		tw(knob, {Size = UDim2.fromOffset(K + 6, K)}, .12, Enum.EasingStyle.Quad)
		task.delay(.12, function()
			if knob.Parent then tw(knob, {Size = UDim2.fromOffset(K, K)}, .3, Enum.EasingStyle.Back) end
		end)
	end
	apply(false)

	local api = {Track = track}
	function api.Set(v, silent)
		enabled = v and true or false
		apply(true)
		if not silent and callback then task.spawn(callback, enabled) end
	end
	function api.Get() return enabled end

	if not noHit then
		local hit = new("TextButton", {
			Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 6, Parent = track,
		})
		hit.Activated:Connect(function() api.Set(not enabled) end)
	end
	return api
end

--------------------------------------------------------------------- LIB
local UI = {}
UI.__index = UI

local KIND = {
	success = {C.Ok1, C.Ok2, "check"},
	error   = {C.Er1, C.Er2, "cross"},
	info    = {C.A1,  C.A2,  "info"},
}

function UI.new(cfg)
	cfg = cfg or {}
	local self = setmetatable({
		Tabs = {}, Current = nil, Open = false, Maximized = false,
		_token = 0, _vis = 0, _pending = {}, _holding = false, _wasMin = false, _imode = "idle",
	}, UI)

	local gui = new("ScreenGui", {
		Name = "HubUI", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 999,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	gui.Parent = lp:WaitForChild("PlayerGui")
	self.Gui = gui

	local hb = RunService.Heartbeat:Connect(function(dt)
		for g, speed in pairs(Animated) do
			if g.Parent then g.Rotation = (g.Rotation + speed * dt) % 360 else Animated[g] = nil end
		end
	end)
	gui.Destroying:Connect(function() hb:Disconnect() end)

	local cam = workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
	local NORMAL = Vector2.new(math.min(600, vp.X - 30), math.min(412, vp.Y - 90))

	---------------------------------------------------------------- MAIN WINDOW
	local main = new("Frame", {
		Name = "Main", AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
		Size = UDim2.fromOffset(NORMAL.X, NORMAL.Y), BackgroundTransparency = 1, Visible = false, Parent = gui,
	})
	local scale = new("UIScale", {Parent = main})
	local body = new("CanvasGroup", {
		Name = "Body", Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.White, BorderSizePixel = 0, Parent = main,
	}, {corner(14)})
	grad(body, C.Bg1, C.Bg2, 90)
	-- lớp ánh màu gradient nhẹ phủ nền
	local tint = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.White, BorderSizePixel = 0, Parent = body})
	new("UIGradient", {
		Color = ColorSequence.new(C.A1, C.A2), Rotation = 35,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.86), NumberSequenceKeypoint.new(0.5, 1), NumberSequenceKeypoint.new(1, 0.92),
		}), Parent = tint,
	})
	-- viền gradient xoay
	local rim = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 10, Parent = main}, {corner(14)})
	local rimStroke = new("UIStroke", {Thickness = 1.5, Color = C.White, Transparency = .25, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = rim})
	loopGrad(rimStroke, 45)

	self.Main, self._scale, self._body, self._rimStroke, self._pos = main, scale, body, rimStroke, main.Position

	---------------------------------------------------------------- THANH TIÊU ĐỀ TRẮNG (kiểu Windows)
	local bar = new("Frame", {Name = "TitleBar", Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = C.White, BorderSizePixel = 0, ZIndex = 2, Parent = body})
	grad(bar, C.BarBg1, C.BarBg2, 90)
	new("Frame", {
		Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = RGB(0, 0, 0),
		BackgroundTransparency = .88, BorderSizePixel = 0, ZIndex = 3, Parent = bar,
	})
	local logo = new("Frame", {Size = UDim2.fromOffset(24, 24), Position = UDim2.fromOffset(12, 7), BackgroundColor3 = C.White, ZIndex = 3, Parent = bar}, {corner(7)})
	grad(logo, C.A1, C.A2, 45)
	local li = Icon("bolt", logo, 16, C.White); li.Root.Position = UDim2.fromOffset(4, 4); li.Root.ZIndex = 4

	local tl = new("Frame", {
		Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, Position = UDim2.fromOffset(44, 0),
		BackgroundTransparency = 1, ZIndex = 3, Parent = bar,
	}, {new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder})})
	local title = label(cfg.Title or "Hub", 13, C.BarText, true)
	title.AutomaticSize = Enum.AutomaticSize.X; title.Size = UDim2.new(0, 0, 1, 0); title.ZIndex = 3; title.Parent = tl
	local sub = label(cfg.Subtitle or "", 11, C.BarSub)
	sub.AutomaticSize = Enum.AutomaticSize.X; sub.Size = UDim2.new(0, 0, 1, 0); sub.ZIndex = 3; sub.Parent = tl

	-- 3 nút điều khiển: thu nhỏ / phóng to / đóng (đóng hover đỏ như Windows)
	local function control(order, iconName, isClose, onClick)
		local b = new("TextButton", {
			Size = UDim2.fromOffset(46, 38), Position = UDim2.new(1, -46 * (4 - order), 0, 0),
			BackgroundColor3 = isClose and RGB(232, 17, 35) or RGB(0, 0, 0), BackgroundTransparency = 1,
			AutoButtonColor = false, Text = "", ZIndex = 4, Parent = bar,
		})
		local ico
		local ctl = {}
		local function mk(n)
			if ico then ico.Root:Destroy() end
			ico = Icon(n, b, 14, C.BarText)
			ico.Root.AnchorPoint = Vector2.new(.5, .5); ico.Root.Position = UDim2.fromScale(.5, .5); ico.Root.ZIndex = 5
		end
		mk(iconName)
		b.MouseEnter:Connect(function()
			tw(b, {BackgroundTransparency = isClose and 0 or .9}, .12)
			if isClose then ico.SetColor(C.White) end
		end)
		b.MouseLeave:Connect(function()
			tw(b, {BackgroundTransparency = 1}, .12)
			ico.SetColor(C.BarText)
		end)
		b.MouseButton1Click:Connect(onClick)
		function ctl.SetIcon(n) mk(n) end
		return ctl
	end
	control(1, "minus", false, function() self:SetVisible(false, "min") end)
	self._maxCtl = control(2, "square", false, function() self:ToggleMax() end)
	control(3, "cross", true, function() self:SetVisible(false) end)

	-- Kéo cửa sổ
	local dragging, dragStart, startPos
	bar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging, dragStart, startPos = true, i.Position, main.Position
			i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - dragStart
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			self._pos = main.Position
		end
	end)

	---------------------------------------------------------------- THANH TAB
	local tabBar = new("ScrollingFrame", {
		Size = UDim2.new(1, -24, 0, 42), Position = UDim2.fromOffset(12, 48),
		BackgroundColor3 = C.White, BorderSizePixel = 0, ScrollBarThickness = 0,
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.X,
		ScrollingDirection = Enum.ScrollingDirection.X, Parent = body,
	}, {
		corner(11),
		new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), VerticalAlignment = Enum.VerticalAlignment.Center}),
		new("UIPadding", {PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5)}),
	})
	grad(tabBar, C.Panel1, C.Panel2, 90)
	local ts = stroke(C.Stroke, 1); ts.Transparency = .45; ts.Parent = tabBar
	self.TabBar = tabBar

	self.Content = new("Frame", {
		Size = UDim2.new(1, -24, 1, -132), Position = UDim2.fromOffset(12, 98),
		BackgroundTransparency = 1, ClipsDescendants = true, Parent = body,
	})

	-- Footer
	local dot = new("Frame", {Size = UDim2.fromOffset(7, 7), Position = UDim2.new(0, 16, 1, -19), BackgroundColor3 = C.Ok1, BorderSizePixel = 0, Parent = body}, {pill()})
	local foot = label(lp.Name, 11, C.Sub)
	foot.Position = UDim2.new(0, 30, 1, -26); foot.Size = UDim2.new(0.5, 0, 0, 20); foot.Parent = body
	local keycap = new("Frame", {
		Size = UDim2.fromOffset(74, 20), Position = UDim2.new(1, -88, 1, -26), BackgroundColor3 = C.Item, Parent = body,
	}, {corner(6)})
	local ks = stroke(C.Stroke, 1); ks.Transparency = .3; ks.Parent = keycap
	local key = label("Right Ctrl", 10, C.Sub); key.TextXAlignment = Enum.TextXAlignment.Center
	key.Size = UDim2.fromScale(1, 1); key.Parent = keycap

	---------------------------------------------------------------- DYNAMIC ISLAND
	local isl = new("Frame", {
		Name = "Island", AnchorPoint = Vector2.new(.5, 0), Position = UDim2.new(.5, 0, 0, ISLAND_TOP),
		Size = UDim2.fromOffset(IDLE.X, IDLE.Y), BackgroundTransparency = 1, ZIndex = 20, Parent = gui,
	})
	local islCorner = corner(IDLE.Y / 2); islCorner.Parent = isl
	local islStroke = new("UIStroke", {Thickness = 1.2, Color = C.White, Transparency = .45, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = isl})
	loopGrad(islStroke, 70)

	local islBody = new("CanvasGroup", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = RGB(0, 0, 0), BorderSizePixel = 0, Parent = isl})
	local bodyCorner = corner(IDLE.Y / 2); bodyCorner.Parent = islBody

	-- lớp thu gọn: logo + tên + switch
	local idleG = new("CanvasGroup", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = islBody})
	local idleC = new("Frame", {
		AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(IDLE.X, IDLE.Y),
		BackgroundTransparency = 1, Parent = idleG,
	})
	local ilogo = new("Frame", {Size = UDim2.fromOffset(24, 24), Position = UDim2.fromOffset(10, 8), BackgroundColor3 = C.White, Parent = idleC}, {corner(8)})
	grad(ilogo, C.A1, C.A2, 45, 90)
	local ili = Icon("bolt", ilogo, 16, C.White); ili.Root.Position = UDim2.fromOffset(4, 4)
	local itxt = label("Menu", 13, C.Text, true); itxt.Position = UDim2.fromOffset(42, 0); itxt.Size = UDim2.new(0, 60, 1, 0); itxt.Parent = idleC
	self.Switch = CreateSwitch(idleC, false, function(v) self:SetVisible(v) end, 44, 24, true)
	self.Switch.Track.Position = UDim2.new(1, -54, .5, -12)

	-- lớp thông báo: huy hiệu gradient + tiêu đề + nội dung
	local notiG = new("CanvasGroup", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, GroupTransparency = 1, Parent = islBody})
	local notiC = new("Frame", {
		AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(NOTI.X, NOTI.Y),
		BackgroundTransparency = 1, Parent = notiG,
	})
	local badge = new("Frame", {Size = UDim2.fromOffset(40, 40), Position = UDim2.fromOffset(14, 14), BackgroundColor3 = C.White, Parent = notiC}, {pill()})
	local badgeGrad = grad(badge, C.A1, C.A2, 45)
	local nTitle = label("", 13, C.Text, true); nTitle.Position = UDim2.fromOffset(66, 14); nTitle.Size = UDim2.new(1, -80, 0, 18); nTitle.Parent = notiC
	local nText = label("", 11, C.Sub); nText.Position = UDim2.fromOffset(66, 35); nText.Size = UDim2.new(1, -80, 0, 18); nText.Parent = notiC

	-- nút bấm phủ lên đảo
	local islHit = new("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 25, Parent = isl})

	self._isl, self._islCorner, self._bodyCorner, self._idleG, self._notiG = isl, islCorner, bodyCorner, idleG, notiG
	self._badge, self._badgeGrad, self._nTitle, self._nText = badge, badgeGrad, nTitle, nText

	islHit.MouseButton1Click:Connect(function()
		if self._imode == "idle" then
			self.Switch.Set(not self.Switch.Get())
		elseif not self._holding then
			self._token = self._token + 1
			self:_collapse()
		end
	end)
	islHit.MouseEnter:Connect(function()
		if self._imode == "idle" then tw(isl, {Size = UDim2.fromOffset(IDLE.X + 10, IDLE.Y + 3)}, .25, Enum.EasingStyle.Back) end
	end)
	islHit.MouseLeave:Connect(function()
		if self._imode == "idle" then tw(isl, {Size = UDim2.fromOffset(IDLE.X, IDLE.Y)}, .25, Enum.EasingStyle.Back) end
	end)

	UIS.InputBegan:Connect(function(i, gp)
		if not gp and i.KeyCode == Enum.KeyCode.RightControl then self.Switch.Set(not self.Switch.Get()) end
	end)

	return self
end

--------------------------------------------------------------------- ĐẢO: chuyển trạng thái
function UI:_mode(m)
	self._imode = m
	local sz = (m == "idle") and IDLE or NOTI
	local r = (m == "idle") and (IDLE.Y / 2) or 30
	tw(self._isl, {Size = UDim2.fromOffset(sz.X, sz.Y)}, .55, Enum.EasingStyle.Back)
	tw(self._islCorner, {CornerRadius = UDim.new(0, r)}, .4)
	tw(self._bodyCorner, {CornerRadius = UDim.new(0, r)}, .4)
	tw(self._idleG, {GroupTransparency = (m == "idle") and 0 or 1}, .25)
	tw(self._notiG, {GroupTransparency = (m == "noti") and 0 or 1}, .3)
end

function UI:_setContent(kind, title, text, loading)
	local k = KIND[kind] or KIND.info
	for _, c in ipairs(self._badge:GetChildren()) do
		if c:IsA("Frame") or c:IsA("UIScale") then c:Destroy() end
	end
	self._badgeGrad.Color = ColorSequence.new(k[1], k[2])
	self._nTitle.Text, self._nText.Text = title, text

	if loading then
		-- vòng xoay tự vẽ
		local spin = new("Frame", {
			AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(22, 22),
			BackgroundTransparency = 1, Parent = self._badge,
		}, {pill()})
		local st = new("UIStroke", {Color = C.White, Thickness = 2.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = spin})
		local g = new("UIGradient", {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.7, 1), NumberSequenceKeypoint.new(1, 1),
			}), Parent = st,
		})
		Animated[g] = 420
	else
		local ic = Icon(k[3], self._badge, 22, C.White)
		ic.Root.AnchorPoint = Vector2.new(.5, .5); ic.Root.Position = UDim2.fromScale(.5, .5)
		local s = new("UIScale", {Scale = 0.2, Parent = ic.Root})
		tw(s, {Scale = 1}, .45, Enum.EasingStyle.Back)
	end
	-- nháy nhẹ khi đổi nội dung
	self._notiG.GroupTransparency = 0.6
	tw(self._notiG, {GroupTransparency = 0}, .25)
end

function UI:_present(d)
	self._token = self._token + 1
	local tok = self._token
	self:_setContent(d.Kind or "info", d.Title or "", d.Text or "", d.Loading)
	self:_mode("noti")
	if not d.Hold then
		task.delay(d.Duration or 3, function()
			if self._token == tok then self:_collapse() end
		end)
	end
end

function UI:_collapse()
	local nxt = table.remove(self._pending, 1)
	if nxt then self:_present(nxt) else self:_mode("idle") end
end

--------------------------------------------------------------------- NOTIFY (hiện ngay trong Dynamic Island)
function UI:Notify(o)
	local kind = o.Kind
	if not kind then
		kind = (o.Icon == "✓" and "success") or (o.Icon == "✕" and "error") or "info"
	end
	local d = {Kind = kind, Title = o.Title or "Notice", Text = o.Text or "", Duration = o.Duration or 3}
	if self._holding then table.insert(self._pending, d) else self:_present(d) end
end

-- Thông báo loading -> :Success() / :Fail()
function UI:Loading(title, text)
	self._holding = true
	self:_present({Kind = "info", Title = title, Text = text, Loading = true, Hold = true})
	local obj = {}
	local function fin(kind, nt, nd, dur)
		self._holding = false
		self:_present({Kind = kind, Title = nt, Text = nd, Duration = dur or 3})
	end
	function obj:Success(nt, nd, dur) fin("success", nt, nd, dur) end
	function obj:Fail(nt, nd, dur) fin("error", nt, nd, dur) end
	return obj
end

--------------------------------------------------------------------- MỞ / ĐÓNG / PHÓNG TO
function UI:SetVisible(v, how, silent)
	v = v and true or false
	if self.Switch.Get() ~= v then self.Switch.Set(v, true) end
	if self.Open == v then return end
	self.Open = v
	self._vis = self._vis + 1
	local tok = self._vis
	local main, scale, body, rim = self.Main, self._scale, self._body, self._rimStroke
	local islandPos = UDim2.new(.5, 0, 0, ISLAND_TOP + 22)

	if v then
		main.Visible = true
		if self._wasMin then
			main.Position = islandPos; scale.Scale = .15
		else
			main.Position = self._pos; scale.Scale = .9
		end
		body.GroupTransparency = 1; rim.Transparency = 1
		tw(main, {Position = self._pos}, .55, Enum.EasingStyle.Quint)
		tw(scale, {Scale = 1}, .55, Enum.EasingStyle.Back)
		tw(body, {GroupTransparency = 0}, .3)
		tw(rim, {Transparency = .25}, .4)
		self._wasMin = false
	else
		if how == "min" then
			self._wasMin = true
			tw(main, {Position = islandPos}, .45, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			tw(scale, {Scale = .15}, .45, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		else
			self._wasMin = false
			tw(scale, {Scale = .92}, .28)
		end
		tw(body, {GroupTransparency = 1}, .3)
		local t = tw(rim, {Transparency = 1}, .3)
		t.Completed:Connect(function()
			if self._vis == tok and not self.Open then main.Visible = false end
		end)
	end

	if not silent then
		if v then
			self:Notify({Kind = "success", Title = "Đã mở giao diện", Text = "Nhấn Right Ctrl để ẩn/hiện", Duration = 1.5})
		else
			self:Notify({Kind = "info", Title = "Đã ẩn giao diện", Text = "Bấm vào đảo hoặc Right Ctrl để mở", Duration = 1.5})
		end
	end
end

function UI:ToggleMax()
	self.Maximized = not self.Maximized
	local cam = workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
	local main = self.Main
	if self.Maximized then
		self._preMaxPos = self._pos
		local target = Vector2.new(math.min(vp.X - 40, 900), math.min(vp.Y - 110, 600))
		self._pos = UDim2.new(.5, 0, .5, 28)
		tw(main, {Size = UDim2.fromOffset(target.X, target.Y), Position = self._pos}, .5, Enum.EasingStyle.Quint)
	else
		self._pos = self._preMaxPos or UDim2.fromScale(.5, .5)
		local w = math.min(600, vp.X - 30); local h = math.min(412, vp.Y - 90)
		tw(main, {Size = UDim2.fromOffset(w, h), Position = self._pos}, .5, Enum.EasingStyle.Quint)
	end
	self._maxCtl.SetIcon(self.Maximized and "restore" or "square")
end

--------------------------------------------------------------------- TAB
function UI:AddTab(name, icon)
	local tab = {Window = self, Name = name}

	local btn = new("TextButton", {
		Size = UDim2.new(0, 0, 0, 32), AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = C.White, BackgroundTransparency = 1, AutoButtonColor = false,
		Text = "", Parent = self.TabBar,
	}, {
		corner(9),
		new("UIPadding", {PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)}),
		new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 7), VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder}),
	})
	grad(btn, C.A1, C.A2, 0)
	local ic
	if icon and Draw[icon] then
		ic = Icon(icon, btn, 16, C.Sub); ic.Root.LayoutOrder = 1
	end
	local txt = label(name, 12, C.Sub, true)
	txt.Size = UDim2.new(0, 0, 1, 0); txt.AutomaticSize = Enum.AutomaticSize.X; txt.LayoutOrder = 2; txt.Parent = btn
	tab.Button, tab.Text, tab.Icon = btn, txt, ic

	btn.MouseEnter:Connect(function()
		if self.Current ~= tab then tw(btn, {BackgroundTransparency = .82}, .15) end
	end)
	btn.MouseLeave:Connect(function()
		if self.Current ~= tab then tw(btn, {BackgroundTransparency = 1}, .15) end
	end)

	local page = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, Parent = self.Content})
	local function column(x)
		return new("ScrollingFrame", {
			Size = UDim2.new(0.5, -5, 1, 0), Position = UDim2.new(x, x == 0 and 0 or 5, 0, 0),
			BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = C.A1,
			CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = page,
		}, {list(10)})
	end
	tab.Page = page
	tab.Columns = {column(0), column(0.5)}

	btn.MouseButton1Click:Connect(function() self:Select(tab) end)
	table.insert(self.Tabs, tab)
	if not self.Current then self:Select(tab) end

	setmetatable(tab, {__index = function(_, k) return UI.TabMethods[k] end})
	return tab
end

function UI:Select(tab)
	local prev = self.Current
	for _, t in ipairs(self.Tabs) do
		local on = (t == tab)
		tw(t.Button, {BackgroundTransparency = on and 0 or 1}, .2)
		tw(t.Text, {TextColor3 = on and C.White or C.Sub}, .2)
		if t.Icon then t.Icon.SetColor(on and C.White or C.Sub) end
		if on then
			if prev ~= tab then
				t.Page.Position = UDim2.fromOffset(0, 14)
				t.Page.Visible = true
				tw(t.Page, {Position = UDim2.fromOffset(0, 0)}, .35, Enum.EasingStyle.Quint)
			end
		else
			t.Page.Visible = false
		end
	end
	self.Current = tab
end

--------------------------------------------------------------------- SECTION
UI.TabMethods = {}

function UI.TabMethods.AddSection(tab, name, col)
	local sec = {}
	local box = new("Frame", {
		Size = UDim2.new(1, -2, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = C.White, Parent = tab.Columns[col or 1],
	}, {corner(12), pad(10), list(7)})
	grad(box, C.Panel1, C.Panel2, 90)
	local bs = stroke(C.Stroke, 1); bs.Transparency = .4; bs.Parent = box

	local head = new("Frame", {Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Parent = box})
	local barAcc = new("Frame", {Size = UDim2.fromOffset(4, 14), Position = UDim2.fromOffset(0, 4), BackgroundColor3 = C.White, BorderSizePixel = 0, Parent = head}, {pill()})
	grad(barAcc, C.A1, C.A2, 90)
	local hl = label(name, 12, C.Text, true); hl.Position = UDim2.fromOffset(12, 0); hl.Size = UDim2.new(1, -12, 1, 0); hl.Parent = head
	sec.Box = box

	-- TOGGLE: dùng đúng switch đồng bộ với Dynamic Island
	function sec:AddToggle(o)
		local row = new("TextButton", {
			Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = C.Item, AutoButtonColor = false, Text = "", Parent = box,
		}, {corner(9)})
		local rs = stroke(C.Stroke, 1); rs.Transparency = .5; rs.Parent = row
		local t = label(o.Name, 12, C.Text); t.Position = UDim2.fromOffset(12, 0); t.Size = UDim2.new(1, -70, 1, 0); t.Parent = row

		local sw = CreateSwitch(row, o.Default, nil, 46, 24, true)
		sw.Track.AnchorPoint = Vector2.new(1, .5); sw.Track.Position = UDim2.new(1, -10, .5, 0)

		local function tint(on, anim)
			local props = {Color = on and C.A1 or C.Stroke, Transparency = on and .1 or .5}
			if anim then tw(rs, props, .25) else rs.Color = props.Color; rs.Transparency = props.Transparency end
		end
		tint(sw.Get(), false)

		local api = {}
		function api:Set(v, silent)
			sw.Set(v, true); tint(sw.Get(), true)
			if not silent and o.Callback then task.spawn(o.Callback, sw.Get()) end
		end
		function api:Get() return sw.Get() end
		row.MouseButton1Click:Connect(function() api:Set(not sw.Get()) end)
		row.MouseEnter:Connect(function() tw(row, {BackgroundColor3 = C.ItemHov}, .15) end)
		row.MouseLeave:Connect(function() tw(row, {BackgroundColor3 = C.Item}, .15) end)
		return api
	end

	-- DROPDOWN
	function sec:AddDropdown(o)
		local cur = o.Default or "None"
		local options = o.Options or {}
		local wrap = new("Frame", {
			Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = box,
		}, {list(5)})
		local lab = label(o.Name, 11, C.Sub); lab.Size = UDim2.new(1, 0, 0, 16); lab.Parent = wrap
		local hd = new("TextButton", {
			Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = C.Item, AutoButtonColor = false, Text = "", Parent = wrap,
		}, {corner(9)})
		local hs = stroke(C.Stroke, 1); hs.Transparency = .5; hs.Parent = hd
		local val = label(cur, 12, C.Sub); val.Position = UDim2.fromOffset(12, 0); val.Size = UDim2.new(1, -40, 1, 0); val.Parent = hd
		local arrow = Icon("chevron", hd, 14, C.Sub)
		arrow.Root.AnchorPoint = Vector2.new(.5, .5); arrow.Root.Position = UDim2.new(1, -18, .5, 0)

		local n = #options
		local fullH = n * 26 + math.max(n - 1, 0) * 2 + 8
		local opts = new("Frame", {
			Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = C.Item, ClipsDescendants = true, Visible = false, Parent = wrap,
		}, {corner(9), pad(4), list(2)})
		local os_ = stroke(C.Stroke, 1); os_.Transparency = .5; os_.Parent = opts

		local isOpen = false
		local buttons = {}
		local function setOpen(v)
			isOpen = v
			tw(arrow.Root, {Rotation = v and 180 or 0}, .3, Enum.EasingStyle.Back)
			tw(hs, {Color = v and C.A1 or C.Stroke, Transparency = v and .1 or .5}, .2)
			if v then
				opts.Visible = true
				tw(opts, {Size = UDim2.new(1, 0, 0, fullH)}, .3, Enum.EasingStyle.Quint)
			else
				local t = tw(opts, {Size = UDim2.new(1, 0, 0, 0)}, .22, Enum.EasingStyle.Quint)
				t.Completed:Connect(function() if not isOpen then opts.Visible = false end end)
			end
		end

		for _, name in ipairs(options) do
			local b = new("TextButton", {
				Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = C.A1, BackgroundTransparency = 1,
				Text = name, TextColor3 = C.Text, TextSize = 12, Font = Enum.Font.Gotham, AutoButtonColor = false, Parent = opts,
			}, {corner(6)})
			buttons[name] = b
			b.MouseEnter:Connect(function() tw(b, {BackgroundTransparency = .8}, .12) end)
			b.MouseLeave:Connect(function() tw(b, {BackgroundTransparency = 1}, .12) end)
			b.MouseButton1Click:Connect(function()
				cur = name; val.Text = name; val.TextColor3 = C.Text
				for nm, bb in pairs(buttons) do bb.TextColor3 = (nm == name) and C.A2 or C.Text end
				setOpen(false)
				if o.Callback then task.spawn(o.Callback, name) end
			end)
		end
		hd.MouseButton1Click:Connect(function() setOpen(not isOpen) end)
		hd.MouseEnter:Connect(function() tw(hd, {BackgroundColor3 = C.ItemHov}, .15) end)
		hd.MouseLeave:Connect(function() tw(hd, {BackgroundColor3 = C.Item}, .15) end)
		return {Get = function() return cur end}
	end

	-- NÚT BẤM (gradient + hiệu ứng nhấn)
	function sec:AddButton(o)
		local b = new("TextButton", {
			Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = C.White, Text = "", AutoButtonColor = false, Parent = box,
		}, {corner(9)})
		local g = grad(b, C.A1, C.A2, 0)
		local sc = new("UIScale", {Parent = b})
		local tl = label(o.Name, 12, C.White, true); tl.TextXAlignment = Enum.TextXAlignment.Center
		tl.Size = UDim2.fromScale(1, 1); tl.Parent = b
		b.MouseEnter:Connect(function() tw(g, {Rotation = 25}, .3) end)
		b.MouseLeave:Connect(function() tw(g, {Rotation = 0}, .3); tw(sc, {Scale = 1}, .2) end)
		b.MouseButton1Down:Connect(function() tw(sc, {Scale = .96}, .1) end)
		b.MouseButton1Up:Connect(function() tw(sc, {Scale = 1}, .25, Enum.EasingStyle.Back) end)
		b.MouseButton1Click:Connect(function() if o.Callback then task.spawn(o.Callback) end end)
	end

	-- Ô thống kê
	function sec:AddStat(name, value)
		local f = new("Frame", {Size = UDim2.new(1, 0, 0, 54), BackgroundColor3 = C.Item, Parent = box}, {corner(9), pad(10)})
		local fs = stroke(C.Stroke, 1); fs.Transparency = .5; fs.Parent = f
		local a = label(name, 10, C.Sub); a.Size = UDim2.new(1, 0, 0, 14); a.Parent = f
		local b = label(value, 13, C.Text, true); b.Position = UDim2.fromOffset(0, 20); b.Size = UDim2.new(1, 0, 0, 16); b.Parent = f
		return function(v) b.Text = v end
	end

	return sec
end

--------------------------------------------------------------------- DEMO
local win = UI.new({Title = "Ryzen Hub", Subtitle = "Blox Fruits"})
local loading = win:Loading("Loading...", "Đang tải giao diện")

-- callback mẫu: báo notify khi bật/tắt
local function tg(name)
	return function(v) win:Notify({Title = name, Text = v and "Enabled" or "Disabled", Kind = v and "success" or "error", Duration = 2}) end
end

-- Home
local home = win:AddTab("Home", "home")
local s1 = home:AddSection("Server Stats", 1)
s1:AddStat("Place Id", tostring(game.PlaceId))
local setSession = s1:AddStat("Session Time", "0 Second(s)")
local s2 = home:AddSection("Local Stats", 2)
s2:AddStat("Moon Status", "Phase 6/8")
s2:AddStat("Mystic Island", "N/A")

local t0 = os.time()
task.spawn(function()
	while win.Gui.Parent do
		setSession(("%d Second(s)"):format(os.time() - t0))
		task.wait(1)
	end
end)

-- Farm Settings
local fs = win:AddTab("Farm Settings", "gear")
local fsMain = fs:AddSection("Settings", 1)
fsMain:AddToggle({Name = "Fast Attack", Callback = tg("Fast Attack")})
fsMain:AddToggle({Name = "Bring Mob", Default = true, Callback = tg("Bring Mob")})

-- Farm
local farm = win:AddTab("Farm", "sword")
local mainSec = farm:AddSection("Main", 1)
mainSec:AddToggle({Name = "Auto Farm Level", Default = true, Callback = tg("Auto Farm Level")})

local boss = farm:AddSection("Boss", 1)
boss:AddDropdown({Name = "Select Boss", Options = {"Boss A", "Boss B", "Boss C"}, Callback = function(v) print("Boss:", v) end})
boss:AddToggle({Name = "Auto Farm Boss", Callback = tg("Auto Farm Boss")})
boss:AddToggle({Name = "Auto Accept Boss Quest", Callback = tg("Auto Accept Boss Quest")})

local fish = farm:AddSection("Fishing", 2)
fish:AddDropdown({Name = "Select Bait", Options = {"Basic", "Good", "Epic"}, Callback = function(v) print("Bait:", v) end})
fish:AddToggle({Name = "Auto Buy Bait", Callback = tg("Auto Buy Bait")})
fish:AddToggle({Name = "Auto Sell Fish", Callback = tg("Auto Sell Fish")})
fish:AddToggle({Name = "Auto Fishing", Callback = tg("Auto Fishing")})
fish:AddButton({Name = "Test Notify", Callback = function()
	win:Notify({Title = "Test", Text = "Dynamic Island hoạt động bình thường", Duration = 3})
end})

for n, ic in pairs({["Bosses & Events"] = "target", ["Multi Farm"] = "layers", ["Quests"] = "flag"}) do
	local t = win:AddTab(n, ic)
	t:AddSection(n, 1):AddToggle({Name = "Demo " .. n, Callback = tg(n)})
end

win:Select(farm)

-- Giả lập thời gian tải rồi báo thành công + hiện UI (silent = không hiện toast đè lên thông báo Loaded)
task.wait(1.8)
loading:Success("Loaded successfully", "Giao diện đã sẵn sàng", 3)
win:SetVisible(true, nil, true)

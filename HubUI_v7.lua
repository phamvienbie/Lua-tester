-- LocalScript: đặt vào StarterPlayer > StarterPlayerScripts
-- Ryzen Hub v6 — Monochrome (đen/trắng) + Dynamic Island (tên + sóng nhạc) + notify Loading / Loaded successfully
-- Phím RightCtrl (PC) hoặc chạm vào đảo (mobile) để ẩn/hiện

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

--------------------------------------------------------------------- THEME
local function RGB(r, g, b) return Color3.fromRGB(r, g, b) end

local C = {
	White   = RGB(255, 255, 255),
	Black   = RGB(0, 0, 0),
	Bg1     = RGB(17, 17, 17),
	Bg2     = RGB(8, 8, 8),
	Panel1  = RGB(23, 23, 23),
	Panel2  = RGB(15, 15, 15),
	Item    = RGB(27, 27, 27),
	ItemHov = RGB(36, 36, 36),
	Stroke  = RGB(48, 48, 48),
	Text    = RGB(243, 243, 243),
	Sub     = RGB(128, 128, 128),
	Off     = RGB(36, 36, 36),
	Knob    = RGB(118, 118, 118),
	-- thanh tiêu đề trắng
	BarBg1  = RGB(22, 22, 22),
	BarBg2  = RGB(12, 12, 12),
	BarText = RGB(243, 243, 243),
	BarSub  = RGB(128, 128, 128),
}

-- FONT (đổi ở đây là đổi toàn bộ giao diện)
local function font(name, weight, fallback)
	local ok, f = pcall(function() return Font.fromName(name, weight) end)
	if ok and f then return f end
	return Font.fromEnum(fallback)
end
local F = {
	Brand = font("Michroma", Enum.FontWeight.Regular, Enum.Font.Michroma),      -- chữ "RYZEN HUB"
	Reg   = font("Montserrat", Enum.FontWeight.Medium, Enum.Font.Gotham),
	Bold  = font("Montserrat", Enum.FontWeight.Bold, Enum.Font.GothamBold),
}

local ISLAND_TOP = 12                    -- cách mép trên màn hình
local IDLE = Vector2.new(176, 40)        -- đảo thu gọn
local NOTI = Vector2.new(300, 62)        -- đảo khi có thông báo
local TOP = ISLAND_TOP + IDLE.Y + 8      -- vị trí đỉnh cửa sổ
local NORMAL = Vector2.new(560, 330)     -- kích thước cửa sổ (tự co lại trên màn hình nhỏ)

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
local function label(text, size, color, face)
	return new("TextLabel", {
		BackgroundTransparency = 1, Text = text, TextSize = size or 13,
		TextColor3 = color or C.Text, TextXAlignment = Enum.TextXAlignment.Left,
		FontFace = face or F.Reg, TextTruncate = Enum.TextTruncate.AtEnd,
	})
end

-- tween: tự huỷ tween cũ cùng thuộc tính (tránh kẹt trạng thái khi bấm nhanh)
local Active = setmetatable({}, {__mode = "k"})
local function tw(o, props, t, style, dir)
	local act = Active[o]
	if not act then act = {}; Active[o] = act end
	for k in pairs(props) do
		if act[k] then act[k]:Cancel() end
	end
	local tween = TweenService:Create(o, TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
	for k in pairs(props) do act[k] = tween end
	tween:Play()
	return tween
end

-- Gradient xoay liên tục (1 vòng Heartbeat chung)
local Spin = setmetatable({}, {__mode = "k"})
local function grad(parent, c1, c2, rot)
	return new("UIGradient", {Color = ColorSequence.new(c1, c2), Rotation = rot or 0, Parent = parent})
end
-- vệt sáng trắng chạy quanh viền
local function shine(strokeObj, speed, base)
	base = base or 0.82
	local g = new("UIGradient", {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, base), NumberSequenceKeypoint.new(0.35, base),
			NumberSequenceKeypoint.new(0.5, 0.05),
			NumberSequenceKeypoint.new(0.65, base), NumberSequenceKeypoint.new(1, base),
		}), Parent = strokeObj,
	})
	Spin[g] = speed
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
			if p[2] == "f" then tw(p[1], {BackgroundColor3 = c}, .18) else tw(p[1], {Color = c}, .18) end
		end
	end
	return api
end

--------------------------------------------------------------------- ẢNH: asset id / rbxassetid / URL
-- Nhận: 123456 | "123456" | "rbxassetid://123456" | "https://.../logo.png" (URL cần executor có writefile + getcustomasset)
local ImgCache = {}
local function resolveAsset(src, cb)
	if type(src) == "number" then return cb("rbxassetid://" .. src) end
	if type(src) ~= "string" or src == "" then return cb(nil) end
	if src:match("^%d+$") then return cb("rbxassetid://" .. src) end
	if src:match("^rbxasset") then return cb(src) end
	if not src:match("^https?://") then return cb(nil) end
	if ImgCache[src] then return cb(ImgCache[src]) end
	task.spawn(function()
		local ok, res = pcall(function()
			local getAsset = getcustomasset or getsynasset
			assert(getAsset and writefile, "executor does not support custom assets")
			local req = request or http_request or (syn and syn.request)
			local data
			if req then
				local r = req({Url = src, Method = "GET"})
				data = r and r.Body
			else
				data = game:HttpGet(src)
			end
			assert(data and #data > 0, "empty response")
			local h = 5381
			for i = 1, #src do h = (h * 33 + src:byte(i)) % 4294967296 end
			local file = "ryzenhub_" .. h .. ".png"
			writefile(file, data)
			return getAsset(file)
		end)
		if ok and res then ImgCache[src] = res; cb(res) else warn("[RyzenHub] cannot load image:", src, res); cb(nil) end
	end)
end

-- icon: tên icon có sẵn (home, gear, sword...) hoặc ảnh (id / URL)
local function AnyIcon(spec, parent, size, col)
	if type(spec) == "string" and Draw[spec] then return Icon(spec, parent, size, col) end
	local img = new("ImageLabel", {
		Size = UDim2.fromOffset(size, size), BackgroundTransparency = 1, ImageColor3 = col or C.Text,
		ScaleType = Enum.ScaleType.Fit, Parent = parent,
	})
	resolveAsset(spec, function(a) if a and img.Parent then img.Image = a end end)
	local api = {Root = img}
	function api.SetColor(c) tw(img, {ImageColor3 = c}, .18) end
	return api
end

local function keyOf(k)
	if typeof(k) == "EnumItem" then return k end
	if type(k) == "string" then
		local ok, v = pcall(function() return Enum.KeyCode[k] end)
		if ok and v then return v end
	end
	return Enum.KeyCode.RightControl
end
local function keyName(k) return (k.Name:gsub("(%l)(%u)", "%1 %2"):gsub("Control", "Ctrl")) end

--------------------------------------------------------------------- CHECKBOX
-- Ô vuông bo nhẹ. Tắt: nền tối + viền. Bật: nền trắng + dấu ✓ (chữ, không vẽ)
local function CreateSwitch(parent, default, S)
	S = S or 20
	local enabled = default and true or false

	local track = new("Frame", {
		Name = "Track", Size = UDim2.fromOffset(S, S), BackgroundColor3 = C.Off, BorderSizePixel = 0, Parent = parent,
	}, {corner(5)})
	local st = stroke(C.Stroke, 1); st.Parent = track
	local mark = new("TextLabel", {
		BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "✓", TextColor3 = C.White,
		Font = Enum.Font.SourceSansBold, TextSize = S - 3, TextTransparency = 1, ZIndex = 2, Parent = track,
	})
	local sc = new("UIScale", {Scale = 0.3, Parent = mark})

	local function apply(anim)
		local on = enabled
		if not anim then
			st.Color = on and C.White or C.Stroke
			mark.TextTransparency = on and 0 or 1
			sc.Scale = on and 1 or 0.3
			return
		end
		tw(st, {Color = on and C.White or C.Stroke}, .2, Enum.EasingStyle.Sine)
		tw(mark, {TextTransparency = on and 0 or 1}, .2, Enum.EasingStyle.Sine)
		tw(sc, {Scale = on and 1 or 0.3}, .3, on and Enum.EasingStyle.Back or Enum.EasingStyle.Quint)
	end
	apply(false)

	local api = {Track = track}
	function api.Set(v) enabled = v and true or false; apply(true) end
	function api.Get() return enabled end
	return api
end

--------------------------------------------------------------------- LIB
local UI = {}
UI.__index = UI

local KIND_ICON = {success = "check", error = "cross", info = "info"}

local function viewport()
	local cam = workspace.CurrentCamera
	return cam and cam.ViewportSize or Vector2.new(1280, 720)
end
local function fitScale()
	local vp = viewport()
	return math.clamp(math.min((vp.X - 16) / NORMAL.X, (vp.Y - TOP - 8) / NORMAL.Y, 1), .5, 1)
end

function UI.new(cfg)
	cfg = cfg or {}
	local self = setmetatable({
		Tabs = {}, Current = nil, Open = false, Maximized = false,
		_token = 0, _vis = 0, _pending = {}, _holding = false, _wasMin = false,
		_imode = "idle", _dotTok = 0, _amp = 0.6, _fit = fitScale(), _waves = {},
	}, UI)

	local brand = string.upper(cfg.Title or "Hub")
	self._key = keyOf(cfg.Key)

	local gui = new("ScreenGui", {
		Name = "HubUI", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 999,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	gui.Parent = lp:WaitForChild("PlayerGui")
	self.Gui = gui

	-- vòng lặp chung: xoay gradient + sóng nhạc
	local clock = 0
	local hb = RunService.Heartbeat:Connect(function(dt)
		clock += dt
		for g, speed in pairs(Spin) do
			if g.Parent then g.Rotation = (g.Rotation + speed * dt) % 360 else Spin[g] = nil end
		end
		if self._imode == "idle" then
			self._amp += ((self.Open and 1 or 0.6) - self._amp) * math.min(1, dt * 4)
			for _, w in ipairs(self._waves) do
				local v = (math.sin(clock * w.s + w.p) + math.sin(clock * w.s * 0.47 + w.p * 1.9)) * 0.25 + 0.5
				w.f.Size = UDim2.fromOffset(3, w.min + (w.max - w.min) * v * self._amp)
			end
		end
	end)
	gui.Destroying:Connect(function() hb:Disconnect() end)

	---------------------------------------------------------------- MAIN WINDOW
	local main = new("Frame", {
		Name = "Main", AnchorPoint = Vector2.new(.5, 0), Position = UDim2.new(.5, 0, 0, TOP),
		Size = UDim2.fromOffset(NORMAL.X, NORMAL.Y), BackgroundTransparency = 1, Visible = false, Parent = gui,
	})
	local scale = new("UIScale", {Scale = self._fit, Parent = main})

	-- CanvasGroup KHÔNG được gắn UIGradient (sẽ nhuộm đen cả các con) -> nền gradient nằm trong 1 Frame riêng
	local body = new("CanvasGroup", {
		Name = "Body", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = main,
	}, {corner(5)})
	local bg = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.White, BorderSizePixel = 0, Parent = body})
	grad(bg, C.Bg1, C.Bg2, 90)
	local sheen = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.White, BorderSizePixel = 0, Parent = body})
	new("UIGradient", {
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.94), NumberSequenceKeypoint.new(0.45, 1), NumberSequenceKeypoint.new(1, 1),
		}), Parent = sheen,
	})

	-- viền: vệt sáng trắng chạy quanh
	local rim = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 10, Parent = main}, {corner(5)})
	local rimStroke = new("UIStroke", {Thickness = 1.2, Color = C.White, Transparency = 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = rim})
	shine(rimStroke, 50, 0.86)

	self.Main, self._scale, self._body, self._rimStroke, self._pos = main, scale, body, rimStroke, main.Position

	---------------------------------------------------------------- THANH TIÊU ĐỀ TRẮNG (kiểu Windows)
	local bar = new("Frame", {Name = "TitleBar", Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = C.White, BorderSizePixel = 0, ZIndex = 2, Parent = body})
	grad(bar, C.BarBg1, C.BarBg2, 90)
	new("Frame", {
		Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = C.White,
		BackgroundTransparency = .9, BorderSizePixel = 0, ZIndex = 3, Parent = bar,
	})
	local logo = new("Frame", {Size = UDim2.fromOffset(22, 22), Position = UDim2.fromOffset(11, 10), BackgroundColor3 = C.ItemHov, BorderSizePixel = 0, ZIndex = 3, Parent = bar}, {corner(5)})
	local li = Icon("bolt", logo, 12, C.White); li.Root.Position = UDim2.fromOffset(5, 5); li.Root.ZIndex = 4
	local logoImg = new("ImageLabel", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Fit, ZIndex = 4, Visible = false, Parent = logo}, {corner(5)})
	self._logo, self._logoImg, self._logoIcon = logo, logoImg, li

	local tl = new("Frame", {
		Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, Position = UDim2.fromOffset(42, 0),
		BackgroundTransparency = 1, ZIndex = 3, Parent = bar,
	}, {new("UIListLayout", {FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 1), VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder})})
	local title = label(brand, 11, C.BarText, F.Brand)
	title.AutomaticSize = Enum.AutomaticSize.X; title.Size = UDim2.new(0, 0, 0, 14); title.ZIndex = 3; title.LayoutOrder = 1; title.Parent = tl
	local sub = label(cfg.Subtitle or "", 10, C.BarSub)
	sub.AutomaticSize = Enum.AutomaticSize.X; sub.Size = UDim2.new(0, 0, 0, 12); sub.ZIndex = 3; sub.LayoutOrder = 2
	sub.Visible = (cfg.Subtitle or "") ~= ""; sub.Parent = tl
	self._title, self._sub = title, sub

	-- 3 nút: thu nhỏ / phóng to / đóng
	local function control(order, iconName, isClose, onClick)
		local b = new("TextButton", {
			Size = UDim2.fromOffset(40, 42), Position = UDim2.new(1, -40 * (4 - order), 0, 0),
			BackgroundColor3 = C.White, BackgroundTransparency = 1,
			AutoButtonColor = false, Text = "", ZIndex = 4, Parent = bar,
		})
		local ico
		local ctl = {}
		local function mk(n)
			if ico then ico.Root:Destroy() end
			ico = Icon(n, b, 12, C.BarText)
			ico.Root.AnchorPoint = Vector2.new(.5, .5); ico.Root.Position = UDim2.fromScale(.5, .5); ico.Root.ZIndex = 5
		end
		mk(iconName)
		b.MouseEnter:Connect(function()
			tw(b, {BackgroundTransparency = isClose and 0 or .9}, .15)
			if isClose then ico.SetColor(C.Black) end
		end)
		b.MouseLeave:Connect(function()
			tw(b, {BackgroundTransparency = 1}, .15)
			ico.SetColor(C.BarText)
		end)
		b.MouseButton1Click:Connect(onClick)
		function ctl.SetIcon(n) mk(n) end
		return ctl
	end
	control(1, "minus", false, function() self:SetVisible(false, "min") end)
	self._maxCtl = control(2, "square", false, function() self:ToggleMax() end)
	control(3, "cross", true, function() self:SetVisible(false) end)

	-- kéo cửa sổ (chuột + cảm ứng)
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
		Size = UDim2.new(1, -20, 0, 36), Position = UDim2.fromOffset(10, 52),
		BackgroundColor3 = C.White, BorderSizePixel = 0, ScrollBarThickness = 0,
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.X,
		ScrollingDirection = Enum.ScrollingDirection.X, Parent = body,
	}, {
		corner(6),
		new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), VerticalAlignment = Enum.VerticalAlignment.Center}),
		new("UIPadding", {PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4)}),
	})
	grad(tabBar, C.Panel1, C.Panel2, 90)
	local ts = stroke(C.Stroke, 1); ts.Transparency = .3; ts.Parent = tabBar
	self.TabBar = tabBar

	self.Content = new("Frame", {
		Size = UDim2.new(1, -20, 1, -124), Position = UDim2.fromOffset(10, 96),
		BackgroundTransparency = 1, ClipsDescendants = true, Parent = body,
	})

	-- Footer
	new("Frame", {Size = UDim2.fromOffset(5, 5), Position = UDim2.new(0, 14, 1, -17), BackgroundColor3 = C.White, BorderSizePixel = 0, Parent = body}, {pill()})
	local foot = label(cfg.Footer or lp.DisplayName, 10, C.Sub)
	self._foot = foot
	foot.Position = UDim2.new(0, 26, 1, -24); foot.Size = UDim2.new(0.5, 0, 0, 20); foot.Parent = body
	if UIS.KeyboardEnabled then
		local keycap = new("Frame", {
			Size = UDim2.fromOffset(68, 18), Position = UDim2.new(1, -80, 1, -23), BackgroundColor3 = C.Item, BorderSizePixel = 0, Parent = body,
		}, {corner(5)})
		local ks = stroke(C.Stroke, 1); ks.Parent = keycap
		local key = label(keyName(self._key), 9, C.Sub); key.TextXAlignment = Enum.TextXAlignment.Center
		self._keyLabel = key
		key.Size = UDim2.fromScale(1, 1); key.Parent = keycap
	end

	---------------------------------------------------------------- DYNAMIC ISLAND (tên + sóng nhạc)
	local isl = new("Frame", {
		Name = "Island", AnchorPoint = Vector2.new(.5, 0), Position = UDim2.new(.5, 0, 0, ISLAND_TOP),
		Size = UDim2.fromOffset(IDLE.X, IDLE.Y), BackgroundTransparency = 1, ZIndex = 20, Parent = gui,
	})
	local islCorner = corner(IDLE.Y / 2); islCorner.Parent = isl
	local islStroke = new("UIStroke", {Thickness = 1.2, Color = C.White, Transparency = 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = isl})
	shine(islStroke, 80, 0.8)

	local islBody = new("CanvasGroup", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.Black, BorderSizePixel = 0, Parent = isl})
	local bodyCorner = corner(IDLE.Y / 2); bodyCorner.Parent = islBody

	-- lớp thu gọn: TÊN + SÓNG NHẠC kế bên
	local idleG = new("CanvasGroup", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = islBody})
	local idleC = new("Frame", {
		AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(IDLE.X, IDLE.Y),
		BackgroundTransparency = 1, Parent = idleG,
	}, {new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 11), SortOrder = Enum.SortOrder.LayoutOrder,
	})})
	local itxt = label(brand, 11, C.White, F.Brand)
	itxt.AutomaticSize = Enum.AutomaticSize.X; itxt.Size = UDim2.new(0, 0, 1, 0); itxt.LayoutOrder = 1; itxt.Parent = idleC
	self._itxt = itxt

	local waveBox = new("Frame", {Size = UDim2.fromOffset(27, 20), BackgroundTransparency = 1, LayoutOrder = 2, Parent = idleC})
	local phases = {0, 1.7, 3.1, 4.4, 5.6}
	local speeds = {5.2, 6.6, 4.4, 7.1, 5.8}
	for n = 1, 5 do
		local f = new("Frame", {
			AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromOffset((n - 1) * 6 + 1.5, 10),
			Size = UDim2.fromOffset(3, 4), BackgroundColor3 = C.White, BorderSizePixel = 0, Parent = waveBox,
		}, {pill()})
		self._waves[n] = {f = f, p = phases[n], s = speeds[n], min = 4, max = 18}
	end

	-- lớp thông báo: huy hiệu trắng + tiêu đề + nội dung
	local notiG = new("CanvasGroup", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, GroupTransparency = 1, Parent = islBody})
	local notiC = new("Frame", {
		AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(NOTI.X, NOTI.Y),
		BackgroundTransparency = 1, Parent = notiG,
	})
	local badge = new("Frame", {Size = UDim2.fromOffset(38, 38), Position = UDim2.fromOffset(13, 12), BackgroundColor3 = C.White, BorderSizePixel = 0, Parent = notiC}, {pill()})
	local nTitle = label("", 13, C.White, F.Bold); nTitle.Position = UDim2.fromOffset(62, 11); nTitle.Size = UDim2.new(1, -76, 0, 20); nTitle.Parent = notiC
	local nText = label("", 11, C.Sub); nText.Position = UDim2.fromOffset(62, 32); nText.Size = UDim2.new(1, -76, 0, 18); nText.Parent = notiC

	local islHit = new("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 25, Parent = isl})

	self._isl, self._islCorner, self._bodyCorner, self._idleG, self._notiG = isl, islCorner, bodyCorner, idleG, notiG
	self._badge, self._nTitle, self._nText = badge, nTitle, nText

	islHit.Activated:Connect(function()
		if self._imode == "idle" then
			self:SetVisible(not self.Open)
		elseif not self._holding then
			self._token += 1
			self:_collapse()
		end
	end)
	islHit.MouseEnter:Connect(function()
		if self._imode == "idle" then tw(isl, {Size = UDim2.fromOffset(IDLE.X + 10, IDLE.Y + 3)}, .3, Enum.EasingStyle.Back) end
	end)
	islHit.MouseLeave:Connect(function()
		if self._imode == "idle" then tw(isl, {Size = UDim2.fromOffset(IDLE.X, IDLE.Y)}, .3, Enum.EasingStyle.Back) end
	end)

	UIS.InputBegan:Connect(function(i, gp)
		if not gp and self._key and i.KeyCode == self._key then self:SetVisible(not self.Open) end
	end)

	-- co giãn theo màn hình
	local cam = workspace.CurrentCamera
	if cam then
		cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			self._fit = fitScale()
			if self.Open then tw(scale, {Scale = self._fit}, .3) end
		end)
	end

	if cfg.Logo then self:SetLogo(cfg.Logo) end
	return self
end

--------------------------------------------------------------------- ĐẢO: chuyển trạng thái
function UI:_mode(m)
	self._imode = m
	local sz = (m == "idle") and IDLE or NOTI
	local r = (m == "idle") and (IDLE.Y / 2) or 31
	tw(self._isl, {Size = UDim2.fromOffset(sz.X, sz.Y)}, .55, Enum.EasingStyle.Back)
	tw(self._islCorner, {CornerRadius = UDim.new(0, r)}, .4)
	tw(self._bodyCorner, {CornerRadius = UDim.new(0, r)}, .4)
	tw(self._idleG, {GroupTransparency = (m == "idle") and 0 or 1}, .25)
	tw(self._notiG, {GroupTransparency = (m == "noti") and 0 or 1}, .3)
end

function UI:_setContent(kind, title, text, loading)
	self._dotTok += 1
	for _, c in ipairs(self._badge:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end

	if loading then
		-- vòng xoay tự vẽ (đen trên nền trắng)
		local spin = new("Frame", {
			AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(22, 22),
			BackgroundTransparency = 1, Parent = self._badge,
		}, {pill()})
		local st = new("UIStroke", {Color = C.Black, Thickness = 2.6, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = spin})
		local g = new("UIGradient", {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.45, 0.15),
				NumberSequenceKeypoint.new(0.62, 1), NumberSequenceKeypoint.new(1, 1),
			}), Parent = st,
		})
		Spin[g] = 420

		-- "Loading" + dấu chấm chạy
		local base = (title:gsub("%.+$", ""))
		local dt = self._dotTok
		self._nTitle.Text = base
		task.spawn(function()
			local n = 0
			while self._dotTok == dt and self._imode == "noti" and self._nTitle.Parent do
				n = n % 3 + 1
				self._nTitle.Text = base .. string.rep(".", n)
				task.wait(.35)
			end
		end)
	else
		self._nTitle.Text = title
		local ic = Icon(KIND_ICON[kind] or "info", self._badge, 22, C.Black)
		ic.Root.AnchorPoint = Vector2.new(.5, .5); ic.Root.Position = UDim2.fromScale(.5, .5)
		local s = new("UIScale", {Scale = 0.2, Parent = ic.Root})
		tw(s, {Scale = 1}, .5, Enum.EasingStyle.Back)
		-- huy hiệu "nảy" nhẹ
		local bs = self._badge:FindFirstChildOfClass("UIScale") or new("UIScale", {Parent = self._badge})
		bs.Scale = 0.8
		tw(bs, {Scale = 1}, .5, Enum.EasingStyle.Back)
	end
	self._nText.Text = text

	-- chữ trượt lên + hiện dần
	self._nTitle.Position = UDim2.fromOffset(62, 17); self._nTitle.TextTransparency = 1
	self._nText.Position = UDim2.fromOffset(62, 38); self._nText.TextTransparency = 1
	tw(self._nTitle, {Position = UDim2.fromOffset(62, 11), TextTransparency = 0}, .4)
	task.delay(.06, function()
		tw(self._nText, {Position = UDim2.fromOffset(62, 32), TextTransparency = 0}, .4)
	end)
end

function UI:_present(d)
	self._token += 1
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
	if nxt then
		self:_present(nxt)
	else
		self._dotTok += 1
		self:_mode("idle")
	end
end

--------------------------------------------------------------------- NOTIFY (hiện ngay trong Dynamic Island)
-- Kind: "success" | "error" | "info"
function UI:Notify(o)
	local d = {Kind = o.Kind or "info", Title = o.Title or "Notice", Text = o.Text or "", Duration = o.Duration or 3}
	if self._holding then table.insert(self._pending, d) else self:_present(d) end
end

-- Loading -> :Success() / :Fail()
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
	if self.Open == v then return end
	self.Open = v
	self._vis += 1
	local tok = self._vis
	local main, scale, body, rim = self.Main, self._scale, self._body, self._rimStroke
	local fit = self._fit
	local islandPos = UDim2.new(.5, 0, 0, ISLAND_TOP + 6)

	if v then
		main.Visible = true
		if self._wasMin then
			main.Position = islandPos; scale.Scale = fit * .12
		else
			main.Position = self._pos; scale.Scale = fit * .92
		end
		body.GroupTransparency = 1; rim.Transparency = 1
		tw(main, {Position = self._pos}, .55, Enum.EasingStyle.Quint)
		tw(scale, {Scale = fit}, .55, Enum.EasingStyle.Back)
		tw(body, {GroupTransparency = 0}, .3)
		tw(rim, {Transparency = 0}, .4)
		self._wasMin = false
	else
		if how == "min" then
			self._wasMin = true
			tw(main, {Position = islandPos}, .45, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			tw(scale, {Scale = fit * .12}, .45, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		else
			self._wasMin = false
			tw(scale, {Scale = fit * .94}, .28)
		end
		tw(body, {GroupTransparency = 1}, .3)
		local t = tw(rim, {Transparency = 1}, .3)
		t.Completed:Connect(function()
			if self._vis == tok and not self.Open then main.Visible = false end
		end)
	end

	if not silent then
		if v then
			self:Notify({Kind = "success", Title = "Interface opened", Text = "Press " .. keyName(self._key) .. " or tap the island to hide", Duration = 1.6})
		else
			self:Notify({Kind = "info", Title = "Interface hidden", Text = "Press " .. keyName(self._key) .. " or tap the island to open", Duration = 1.6})
		end
	end
end

function UI:ToggleMax()
	self.Maximized = not self.Maximized
	local vp = viewport()
	local main = self.Main
	if self.Maximized then
		self._preMaxPos = self._pos
		local w = math.min(840, (vp.X - 16) / self._fit)
		local h = math.max(NORMAL.Y, (vp.Y - TOP - 8) / self._fit)
		self._pos = UDim2.new(.5, 0, 0, TOP)
		tw(main, {Size = UDim2.fromOffset(w, h), Position = self._pos}, .5, Enum.EasingStyle.Quint)
	else
		self._pos = self._preMaxPos or UDim2.new(.5, 0, 0, TOP)
		tw(main, {Size = UDim2.fromOffset(NORMAL.X, NORMAL.Y), Position = self._pos}, .5, Enum.EasingStyle.Quint)
	end
	self._maxCtl.SetIcon(self.Maximized and "restore" or "square")
end

--------------------------------------------------------------------- CHỈNH TỪ BÊN NGOÀI
function UI:SetTitle(t)
	t = string.upper(tostring(t or ""))
	self._title.Text = t; self._itxt.Text = t
end
function UI:SetSubtitle(t)
	t = tostring(t or "")
	self._sub.Text = t; self._sub.Visible = t ~= ""
end
function UI:SetLogo(src) -- id / rbxassetid / URL; nil = icon mặc định
	self._logoTok = (self._logoTok or 0) + 1
	local tok = self._logoTok
	local function fallback()
		self._logoImg.Visible = false; self._logoIcon.Root.Visible = true; self._logo.BackgroundTransparency = 0
	end
	if not src or src == "" then return fallback() end
	resolveAsset(src, function(a)
		if self._logoTok ~= tok or not self._logoImg.Parent then return end
		if not a then return fallback() end
		self._logoImg.Image = a; self._logoImg.Visible = true
		self._logoIcon.Root.Visible = false; self._logo.BackgroundTransparency = 1
	end)
end
function UI:SetFooter(t) self._foot.Text = tostring(t or "") end
function UI:SetKey(k)
	self._key = keyOf(k)
	if self._keyLabel then self._keyLabel.Text = keyName(self._key) end
end
function UI:Destroy() self.Gui:Destroy() end

--------------------------------------------------------------------- TAB
-- AddTab("Home", "home")  hoặc  AddTab({Name = "Home", Icon = "rbxassetid://123" | "https://.../i.png"})
function UI:AddTab(name, icon)
	if type(name) == "table" then name, icon = name.Name or name.Title or "Tab", name.Icon end
	local tab = {Window = self, Name = name}

	local btn = new("TextButton", {
		Size = UDim2.new(0, 0, 0, 28), AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = RGB(46, 46, 46), BackgroundTransparency = 1, BorderSizePixel = 0, AutoButtonColor = false,
		Text = "", Parent = self.TabBar,
	}, {
		corner(4),
		new("UIPadding", {PaddingLeft = UDim.new(0, 11), PaddingRight = UDim.new(0, 11)}),
		new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder}),
	})
	local ic
	if icon and icon ~= "" then
		ic = AnyIcon(icon, btn, 14, C.Sub); ic.Root.LayoutOrder = 1
	end
	local txt = label(name, 11, C.Sub, F.Bold)
	txt.Size = UDim2.new(0, 0, 1, 0); txt.AutomaticSize = Enum.AutomaticSize.X; txt.LayoutOrder = 2; txt.Parent = btn
	tab.Button, tab.Text, tab.Icon = btn, txt, ic

	btn.MouseEnter:Connect(function()
		if self.Current ~= tab then tw(btn, {BackgroundTransparency = .5}, .15) end
	end)
	btn.MouseLeave:Connect(function()
		if self.Current ~= tab then tw(btn, {BackgroundTransparency = 1}, .15) end
	end)

	local page = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, Parent = self.Content})
	local function column(x)
		return new("ScrollingFrame", {
			Size = UDim2.new(0.5, -5, 1, 0), Position = UDim2.new(x, x == 0 and 0 or 5, 0, 0),
			BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = C.Sub,
			CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = page,
		}, {list(8)})
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
		tw(t.Button, {BackgroundTransparency = on and 0 or 1}, .22)
		tw(t.Text, {TextColor3 = on and C.White or C.Sub}, .22)
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

function UI.TabMethods.SetName(tab, n) tab.Name = n; tab.Text.Text = n end
function UI.TabMethods.SetIcon(tab, spec)
	if tab.Icon then tab.Icon.Root:Destroy(); tab.Icon = nil end
	if spec and spec ~= "" then
		tab.Icon = AnyIcon(spec, tab.Button, 14, tab.Window.Current == tab and C.White or C.Sub)
		tab.Icon.Root.LayoutOrder = 1
	end
end

function UI.TabMethods.AddSection(tab, name, col)
	local sec = {}
	local order = 0
	local function nextOrder() order += 1; return order end

	local box = new("Frame", {
		Size = UDim2.new(1, -2, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = C.White, BorderSizePixel = 0, Parent = tab.Columns[col or 1],
	}, {corner(6), pad(9), list(6)})
	grad(box, C.Panel1, C.Panel2, 90)
	local bs = stroke(C.Stroke, 1); bs.Transparency = .2; bs.Parent = box

	local head = new("Frame", {Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, LayoutOrder = 0, Parent = box})
	new("Frame", {Size = UDim2.fromOffset(5, 5), Position = UDim2.fromOffset(1, 7), BackgroundColor3 = C.White, BorderSizePixel = 0, Parent = head}, {pill()})
	local hl = label(string.upper(name), 10, C.Text, F.Bold); hl.Position = UDim2.fromOffset(14, 0); hl.Size = UDim2.new(1, -14, 1, 0); hl.Parent = head
	sec.Box = box
	function sec:SetName(n) hl.Text = string.upper(tostring(n)) end

	-- TOGGLE
	function sec:AddToggle(o)
		local row = new("TextButton", {
			Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = C.Item, BorderSizePixel = 0, AutoButtonColor = false, Text = "",
			LayoutOrder = nextOrder(), Parent = box,
		}, {corner(5)})
		local rs = stroke(C.Stroke, 1); rs.Parent = row
		local t = label(o.Name, 11, C.Text); t.Position = UDim2.fromOffset(12, 0); t.Size = UDim2.new(1, -50, 1, 0); t.Parent = row

		local sw = CreateSwitch(row, o.Default, 20)
		sw.Track.AnchorPoint = Vector2.new(1, .5); sw.Track.Position = UDim2.new(1, -12, .5, 0)

		local function tint(on, anim)
			local props = {Color = on and C.White or C.Stroke, Transparency = on and .65 or 0}
			if anim then tw(rs, props, .25) else rs.Color = props.Color; rs.Transparency = props.Transparency end
		end
		tint(sw.Get(), false)

		local api = {}
		function api:Set(v, silent)
			sw.Set(v); tint(sw.Get(), true)
			if not silent and o.Callback then task.spawn(o.Callback, sw.Get()) end
		end
		function api:Get() return sw.Get() end
		function api:SetName(n) t.Text = tostring(n) end
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
			Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
			LayoutOrder = nextOrder(), Parent = box,
		}, {list(4)})
		local lab = label(o.Name, 10, C.Sub); lab.Size = UDim2.new(1, 0, 0, 14); lab.LayoutOrder = 1; lab.Parent = wrap
		local hd = new("TextButton", {
			Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = C.Item, BorderSizePixel = 0, AutoButtonColor = false, Text = "",
			LayoutOrder = 2, Parent = wrap,
		}, {corner(5)})
		local hs = stroke(C.Stroke, 1); hs.Parent = hd
		local val = label(cur, 11, C.Sub); val.Position = UDim2.fromOffset(12, 0); val.Size = UDim2.new(1, -40, 1, 0); val.Parent = hd
		local arrow = Icon("chevron", hd, 12, C.Sub)
		arrow.Root.AnchorPoint = Vector2.new(.5, .5); arrow.Root.Position = UDim2.new(1, -18, .5, 0)

		local n = #options
		local fullH = n * 26 + math.max(n - 1, 0) * 2 + 8
		local opts = new("Frame", {
			Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = C.Item, BorderSizePixel = 0, ClipsDescendants = true, Visible = false,
			LayoutOrder = 3, Parent = wrap,
		}, {corner(5), pad(4), list(2)})
		local os_ = stroke(C.Stroke, 1); os_.Parent = opts

		local isOpen = false
		local buttons = {}
		local function setOpen(v)
			isOpen = v
			tw(arrow.Root, {Rotation = v and 180 or 0}, .3, Enum.EasingStyle.Back)
			tw(hs, {Color = v and C.White or C.Stroke, Transparency = v and .65 or 0}, .2)
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
				Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = C.White, BackgroundTransparency = 1, BorderSizePixel = 0,
				Text = name, TextColor3 = C.Sub, TextSize = 11, FontFace = F.Reg, AutoButtonColor = false, Parent = opts,
			}, {corner(5)})
			buttons[name] = b
			b.MouseEnter:Connect(function() tw(b, {BackgroundTransparency = .92}, .12) end)
			b.MouseLeave:Connect(function() tw(b, {BackgroundTransparency = 1}, .12) end)
			b.MouseButton1Click:Connect(function()
				cur = name; val.Text = name; tw(val, {TextColor3 = C.Text}, .2)
				for nm, bb in pairs(buttons) do tw(bb, {TextColor3 = (nm == name) and C.White or C.Sub}, .15) end
				setOpen(false)
				if o.Callback then task.spawn(o.Callback, name) end
			end)
		end
		hd.MouseButton1Click:Connect(function() setOpen(not isOpen) end)
		hd.MouseEnter:Connect(function() tw(hd, {BackgroundColor3 = C.ItemHov}, .15) end)
		hd.MouseLeave:Connect(function() tw(hd, {BackgroundColor3 = C.Item}, .15) end)
		return {Get = function() return cur end}
	end

	-- NÚT BẤM (trắng, chữ đen)
	function sec:AddButton(o)
		local b = new("TextButton", {
			Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = C.Item, BorderSizePixel = 0, Text = "", AutoButtonColor = false,
			LayoutOrder = nextOrder(), Parent = box,
		}, {corner(5)})
		local sc = new("UIScale", {Parent = b})
		local bst = stroke(C.Stroke, 1); bst.Parent = b
		local tl = label(o.Name, 11, C.White, F.Bold); tl.TextXAlignment = Enum.TextXAlignment.Center
		tl.Size = UDim2.fromScale(1, 1); tl.Parent = b
		b.MouseEnter:Connect(function() tw(b, {BackgroundColor3 = C.ItemHov}, .2) end)
		b.MouseLeave:Connect(function() tw(b, {BackgroundColor3 = C.Item}, .2); tw(sc, {Scale = 1}, .2) end)
		b.MouseButton1Down:Connect(function() tw(sc, {Scale = .96}, .1) end)
		b.MouseButton1Up:Connect(function() tw(sc, {Scale = 1}, .3, Enum.EasingStyle.Back) end)
		b.MouseButton1Click:Connect(function() if o.Callback then task.spawn(o.Callback) end end)
		return {SetName = function(_, n) tl.Text = tostring(n) end}
	end

	-- Ô thống kê
	function sec:AddStat(name, value) -- hoặc AddStat({Name = "...", Value = "..."})
		if type(name) == "table" then name, value = name.Name, name.Value end
		name, value = tostring(name or ""), tostring(value or "")
		local f = new("Frame", {Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = C.Item, BorderSizePixel = 0, LayoutOrder = nextOrder(), Parent = box}, {corner(5), pad(9)})
		local fs = stroke(C.Stroke, 1); fs.Parent = f
		local a = label(name, 10, C.Sub); a.Size = UDim2.new(1, 0, 0, 13); a.Parent = f
		local b = label(value, 12, C.Text, F.Bold); b.Position = UDim2.fromOffset(0, 17); b.Size = UDim2.new(1, 0, 0, 16); b.Parent = f
		local api = setmetatable({}, {__call = function(_, v) b.Text = tostring(v) end}) -- stat(v) vẫn dùng được
		function api:SetValue(v) b.Text = tostring(v) end
		function api:SetName(n) a.Text = tostring(n) end
		function api:Get() return b.Text end
		function api:SetVisible(v) f.Visible = v and true or false end
		return api
	end

	return sec
end

--------------------------------------------------------------------- DEMO
-- Cấu hình giao diện (chỉnh tại đây hoặc gọi win:SetTitle / SetSubtitle / SetLogo / SetKey / SetFooter sau khi tạo)
local win = UI.new({
	Title    = "Ryzen Hub",
	Subtitle = "Blox Fruits",
	Logo     = nil,                          -- 123456 | "rbxassetid://123456" | "https://.../logo.png" | nil = icon tia sét
	Key      = Enum.KeyCode.RightControl,    -- phím ẩn/hiện
	Footer   = nil,                          -- nil = tên người chơi
})
local loading = win:Loading("Loading", "Preparing interface")

local function tg(name)
	return function(v) win:Notify({Title = name, Text = v and "Enabled" or "Disabled", Kind = v and "success" or "error", Duration = 2}) end
end

-- Home
local home = win:AddTab("Home", "home")
local s1 = home:AddSection("Server Stats", 1)
s1:AddStat("Place Id", tostring(game.PlaceId))
local setSession = s1:AddStat("Session Time", "0 Second(s)")
-- stat là object: setSession:SetName("...") / setSession:SetValue("...") / setSession("...")
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
	win:Notify({Title = "Test", Text = "Dynamic Island is working", Kind = "info", Duration = 3})
end})

for _, d in ipairs({{"Bosses & Events", "target"}, {"Multi Farm", "layers"}, {"Quests", "flag"}}) do
	local t = win:AddTab(d[1], d[2])
	t:AddSection(d[1], 1):AddToggle({Name = "Demo " .. d[1], Callback = tg(d[1])})
end

win:Select(farm)

-- Giả lập thời gian tải -> "Loaded successfully" -> mở UI (silent = không đè lên thông báo)
task.wait(1.8)
loading:Success("Loaded successfully", "Interface is ready", 2.5)
win:SetVisible(true, nil, true)

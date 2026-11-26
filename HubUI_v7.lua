-- THƯ VIỆN (không có demo). Dùng: local UI = loadstring(game:HttpGet("<url của file này>"))()
-- Ryzen Hub v8 (căn chỉnh lại UI cho màn hình ngang/điện thoại) — Monochrome (đen/trắng) + Dynamic Island (tên + sóng nhạc) + notify Loading / Loaded successfully
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
local NORMAL = Vector2.new(560, 330)     -- kích thước TỐI THIỂU của cửa sổ (đơn vị UI, trước khi scale)
local MINSIZE = Vector2.new(340, 240)     -- cỡ nhỏ nhất khi kéo thu nhỏ bằng góc dưới phải
local MAXW, MAXH = 720, 380              -- kích thước tối đa khi màn hình rộng
local FOOT = 28                          -- chiều cao thanh footer
local COMPACT = UIS.TouchEnabled and not UIS.KeyboardEnabled  -- mobile: tab nhỏ gọn hơn

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

--------------------------------------------------------------------- ICON DỰ PHÒNG (tự vẽ, chỉ dùng khi Lucide chưa tải được)
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
	grip    = function(S, D) D(.82,.82,.16); D(.82,.52,.16); D(.52,.82,.16) end,
}

local function DrawIcon(name, parent, size, col)
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

--------------------------------------------------------------------- ICON LUCIDE (https://lucide.dev)
-- Dùng: Icon("house"), AddTab("Home", "house"), "lucide:swords" ... (tên đúng như trên lucide.dev)
-- Tên cũ vẫn chạy nhờ bảng đổi tên bên dưới (home -> house, gear -> settings ...)
-- Tự tải thư viện icon Lucide lúc chạy (cần HttpGet). Muốn dùng module riêng: getgenv().LucideIcons = <module có .Icon(name)>
local LUCIDE_ALIAS = {
	home = "house", gear = "settings", sword = "swords", bolt = "zap", cross = "x", chevron = "chevron-down",
	target = "crosshair", restore = "copy", minus = "minus", square = "square", check = "check", info = "info",
	layers = "layers", flag = "flag",
}
local DRAW_FALLBACK = { -- tên Lucide -> icon dự phòng
	zap = "bolt", x = "cross", ["chevron-down"] = "chevron", copy = "restore", house = "home",
	settings = "gear", swords = "sword", crosshair = "target", ["move-diagonal-2"] = "grip",
}
local LUCIDE_SOURCES = {
	"https://raw.githubusercontent.com/Footagesus/Icons/main/Main.lua",
}
local LucideLib, LucideState, LucideWait, LucideCache = nil, "idle", {}, {}

local function lucideInit()
	if LucideState ~= "idle" then return end
	LucideState = "loading"
	task.spawn(function()
		local env = (getgenv and getgenv()) or _G
		local lib = type(env.LucideIcons) == "table" and env.LucideIcons or nil
		if not lib then
			for _, url in ipairs(LUCIDE_SOURCES) do
				local ok, res = pcall(function() return loadstring(game:HttpGet(url))() end)
				if ok and type(res) == "table" and res.Icon then lib = res break end
			end
		end
		if lib and lib.SetIconsType then pcall(lib.SetIconsType, "lucide") end
		LucideLib = lib
		LucideState = lib and "ready" or "failed"
		if not lib then warn("[RyzenHub] cannot load Lucide icons, using fallback icons") end
		for _, cb in ipairs(LucideWait) do task.defer(cb) end
		LucideWait = {}
	end)
end

local function lucideWhenReady(cb)
	if LucideState == "ready" or LucideState == "failed" then return cb() end
	table.insert(LucideWait, cb)
	lucideInit()
end

local function lucideLookup(name)
	if LucideState ~= "ready" then return nil end
	name = tostring(name):gsub("^lucide:", "")
	name = LUCIDE_ALIAS[name] or name
	local c = LucideCache[name]
	if c ~= nil then return c or nil end
	local ok, a, b = pcall(function() return LucideLib.Icon(name, "lucide") end)
	local data
	if ok and type(a) == "table" then
		local meta = type(a[2]) == "table" and a[2] or a
		local img = a[1] or a.Image or a.Id
		if type(img) == "number" then img = "rbxassetid://" .. img end
		if type(img) == "string" and img ~= "" then
			data = {Image = img, Pos = meta.ImageRectPosition or meta.ImageRectOffset, Size = meta.ImageRectSize}
		end
	elseif ok and type(a) == "string" and typeof(b) == "table" then
		data = {Image = a, Pos = b.ImageRectPosition or b.ImageRectOffset, Size = b.ImageRectSize}
	end
	LucideCache[name] = data or false
	if not data then warn("[RyzenHub] Lucide icon not found:", name) end
	return data
end

local function Icon(name, parent, size, col)
	col = col or C.Text
	local root = new("Frame", {Name = "Icon_" .. name, Size = UDim2.fromOffset(size, size), BackgroundTransparency = 1, Parent = parent})
	local img = new("ImageLabel", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ImageColor3 = col,
		ScaleType = Enum.ScaleType.Fit, Visible = false, Parent = root,
	})
	local fb, cur = nil, col
	lucideWhenReady(function()
		if not root.Parent then return end
		local d = lucideLookup(name)
		if d then
			img.Image = d.Image
			if d.Pos then img.ImageRectOffset = d.Pos end
			if d.Size then img.ImageRectSize = d.Size end
			img.Visible = true
		else
			local key = DRAW_FALLBACK[name] or name
			if Draw[key] then fb = DrawIcon(key, root, size, cur) end
		end
	end)
	local api = {Root = root}
	function api.SetColor(c)
		cur = c
		tw(img, {ImageColor3 = c}, .18)
		if fb then fb.SetColor(c) end
	end
	return api
end
lucideInit()

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

-- icon: tên Lucide (house, settings, swords... xem lucide.dev) hoặc ảnh (id / URL)
local function AnyIcon(spec, parent, size, col)
	if type(spec) == "string" and spec ~= "" and not spec:match("^%d+$") and not spec:match("^rbxasset") and not spec:match("^https?://") then
		return Icon(spec, parent, size, col)
	end
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

local KIND_ICON = {success = "check", error = "x", info = "info"}

local function viewport()
	local cam = workspace.CurrentCamera
	return cam and cam.ViewportSize or Vector2.new(1280, 720)
end
-- Scale theo CHIỀU CAO màn hình, phần chiều ngang dư thì nới rộng cửa sổ (không để thừa khoảng trống / không cắt tab)
local function layout()
	local vp = viewport()
	local availH = vp.Y - TOP - 8
	local s = math.clamp(math.min(availH / NORMAL.Y, (vp.X - 16) / NORMAL.X, 1), .5, 1)
	local w = math.clamp((vp.X - 16) / s, NORMAL.X, MAXW)
	local h = math.clamp(availH / s, NORMAL.Y, MAXH)
	return s, Vector2.new(w, h)
end

function UI.new(cfg)
	cfg = cfg or {}
	local self = setmetatable({
		Tabs = {}, Current = nil, Open = false, Maximized = false,
		_token = 0, _vis = 0, _pending = {}, _holding = false, _wasMin = false,
		_imode = "idle", _dotTok = 0, _amp = 0.6, _waves = {},
	}, UI)

	self._fit, self._size = layout()
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
		Size = UDim2.fromOffset(self._size.X, self._size.Y), BackgroundTransparency = 1, Visible = false, Parent = gui,
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
	local li = Icon("zap", logo, 12, C.White); li.Root.Position = UDim2.fromOffset(5, 5); li.Root.ZIndex = 4
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
	control(3, "x", true, function() self:SetVisible(false) end)

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

	local rsState

	---------------------------------------------------------------- GÓC KÉO ĐỔI KÍCH THƯỚC (dưới phải)
	local gsz = COMPACT and 36 or 26
	local grip = new("Frame", {
		Name = "ResizeGrip", AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -2, 1, -2),
		Size = UDim2.fromOffset(gsz, gsz), BackgroundTransparency = 1, Active = true, ZIndex = 20, Parent = body,
	})
	local gi = Icon("move-diagonal-2", grip, 12, C.Sub)
	gi.Root.AnchorPoint = Vector2.new(1, 1); gi.Root.Position = UDim2.new(1, -5, 1, -5); gi.Root.ZIndex = 21
	self._grip = grip
	grip.MouseEnter:Connect(function() if not rsState then gi.SetColor(C.White) end end)
	grip.MouseLeave:Connect(function() if not rsState then gi.SetColor(C.Sub) end end)
	grip.InputBegan:Connect(function(i)
		if self.Maximized then return end
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			rsState = {
				p = i.Position, size = Vector2.new(main.Size.X.Offset, main.Size.Y.Offset), pos = main.Position,
				left = main.AbsolutePosition.X, top = main.AbsolutePosition.Y,
			}
			gi.SetColor(C.White)
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then rsState = nil; gi.SetColor(C.Sub) end
			end)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if not rsState then return end
		if i.UserInputType ~= Enum.UserInputType.MouseMovement and i.UserInputType ~= Enum.UserInputType.Touch then return end
		local fit, vp, st = self._fit, viewport(), rsState
		local d = i.Position - st.p
		local maxW = math.max(MINSIZE.X, (vp.X - 8 - st.left) / fit)
		local maxH = math.max(MINSIZE.Y, (vp.Y - 8 - st.top) / fit)
		local w = math.clamp(st.size.X + d.X / fit, MINSIZE.X, maxW)
		local h = math.clamp(st.size.Y + d.Y / fit, MINSIZE.Y, maxH)
		local a = Active[main]; if a and a.Size then a.Size:Cancel() end
		-- main neo giữa theo chiều ngang -> dịch tâm nửa phần nở thêm để mép trái đứng yên
		main.Size = UDim2.fromOffset(w, h)
		main.Position = UDim2.new(st.pos.X.Scale, st.pos.X.Offset + (w - st.size.X) * fit / 2, st.pos.Y.Scale, st.pos.Y.Offset)
		self._pos = main.Position
		self._size = Vector2.new(w, h); self._userSize = self._size
	end)
	main:GetPropertyChangedSignal("Size"):Connect(function() self:_relayout() end)

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

	-- mờ 2 mép khi còn tab bị che (báo hiệu có thể vuốt)
	local function edge(right)
		local f = new("Frame", {
			Size = UDim2.fromOffset(26, 36), AnchorPoint = Vector2.new(right and 1 or 0, 0),
			Position = right and UDim2.new(1, -10, 0, 52) or UDim2.fromOffset(10, 52),
			BackgroundColor3 = C.Panel2, BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 3, Parent = body,
		}, {corner(6)})
		new("UIGradient", {
			Transparency = NumberSequence.new(right and 1 or 0, right and 0 or 1), Parent = f,
		})
		return f
	end
	local edgeL, edgeR = edge(false), edge(true)
	local function updEdges()
		local k = tabBar.AbsoluteSize.Y / 36
		if k <= 0 then return end
		local maxX = math.max(0, (tabBar.AbsoluteCanvasSize.X - tabBar.AbsoluteSize.X) / k)
		local x = tabBar.CanvasPosition.X
		tw(edgeL, {BackgroundTransparency = x > 3 and 0 or 1}, .15)
		tw(edgeR, {BackgroundTransparency = x < maxX - 3 and 0 or 1}, .15)
	end
	tabBar:GetPropertyChangedSignal("CanvasPosition"):Connect(updEdges)
	tabBar:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(updEdges)
	tabBar:GetPropertyChangedSignal("AbsoluteSize"):Connect(updEdges)

	self.Content = new("Frame", {
		Size = UDim2.new(1, -20, 1, -(96 + FOOT + 4)), Position = UDim2.fromOffset(10, 96),
		BackgroundTransparency = 1, ClipsDescendants = true, Parent = body,
	})

	-- Footer: thanh riêng, tách khỏi nội dung, căn giữa theo chiều dọc
	local footBar = new("Frame", {
		Name = "Footer", Size = UDim2.new(1, 0, 0, FOOT), Position = UDim2.new(0, 0, 1, -FOOT),
		BackgroundColor3 = C.Black, BackgroundTransparency = .4, BorderSizePixel = 0, ZIndex = 2, Parent = body,
	})
	new("Frame", {Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = C.White, BackgroundTransparency = .92, BorderSizePixel = 0, ZIndex = 3, Parent = footBar})
	new("Frame", {
		AnchorPoint = Vector2.new(0, .5), Size = UDim2.fromOffset(5, 5), Position = UDim2.new(0, 14, .5, 0),
		BackgroundColor3 = C.White, BorderSizePixel = 0, ZIndex = 3, Parent = footBar,
	}, {pill()})
	local foot = label(cfg.Footer or lp.DisplayName, 10, C.Sub)
	self._foot = foot
	foot.AnchorPoint = Vector2.new(0, .5); foot.Position = UDim2.new(0, 26, .5, 0); foot.Size = UDim2.new(1, -(26 + (UIS.KeyboardEnabled and 118 or 40)), 1, 0)
	foot.ZIndex = 3; foot.Parent = footBar
	if UIS.KeyboardEnabled then
		local keycap = new("Frame", {
			AnchorPoint = Vector2.new(1, .5), Size = UDim2.fromOffset(68, 18), Position = UDim2.new(1, -34, .5, 0),
			BackgroundColor3 = C.Item, BorderSizePixel = 0, ZIndex = 3, Parent = footBar,
		}, {corner(5)})
		local ks = stroke(C.Stroke, 1); ks.Parent = keycap
		local key = label(keyName(self._key), 9, C.Sub); key.TextXAlignment = Enum.TextXAlignment.Center
		self._keyLabel = key
		key.Size = UDim2.fromScale(1, 1); key.ZIndex = 4; key.Parent = keycap
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
			self._fit, self._size = layout()
			if self._userSize then
				local vp = viewport()
				self._size = Vector2.new(
					math.clamp(self._userSize.X, MINSIZE.X, math.max(MINSIZE.X, (vp.X - 16) / self._fit)),
					math.clamp(self._userSize.Y, MINSIZE.Y, math.max(MINSIZE.Y, (vp.Y - TOP - 8) / self._fit)))
			end
			if self.Open then tw(scale, {Scale = self._fit}, .3) end
			local sz = self.Maximized and self:_maxSize() or self._size
			tw(self.Main, {Size = UDim2.fromOffset(sz.X, sz.Y)}, .3)
		end)
	end

	self:_relayout()
	if cfg.Logo then self:SetLogo(cfg.Logo) end
	return self
end

--------------------------------------------------------------------- TỰ CĂN CHỈNH THEO CỠ CỬA SỔ
-- Hẹp (< 470): gộp 2 cột thành 1 cột cuộn; rộng: trả về 2 cột. Cửa sổ quá hẹp thì ẩn subtitle.
function UI:_arrange(tab)
	local single = self._single
	local c1, c2 = tab.Columns[1], tab.Columns[2]
	c1.Size = single and UDim2.new(1, 0, 1, 0) or UDim2.new(0.5, -5, 1, 0)
	c2.Visible = not single
	for i, s in ipairs(tab._secs or {}) do
		s.box.LayoutOrder = (single and s.col == 2) and (1000 + i) or i
		s.box.Parent = (single or s.col ~= 2) and c1 or c2
	end
end

function UI:_relayout()
	local w = self.Main.Size.X.Offset
	local single = w < 470
	if self._single ~= single then
		self._single = single
		for _, tab in ipairs(self.Tabs) do self:_arrange(tab) end
	end
	if self._sub then self._sub.Visible = self._sub.Text ~= "" and w >= 420 end
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

function UI:_maxSize()
	local vp = viewport()
	local w = math.max(self._size.X, math.min(900, (vp.X - 16) / self._fit))
	local h = math.max(self._size.Y, (vp.Y - TOP - 8) / self._fit)
	return Vector2.new(w, h)
end

function UI:ToggleMax()
	self.Maximized = not self.Maximized
	local main = self.Main
	if self.Maximized then
		self._preMaxPos = self._pos
		local sz = self:_maxSize()
		self._pos = UDim2.new(.5, 0, 0, TOP)
		tw(main, {Size = UDim2.fromOffset(sz.X, sz.Y), Position = self._pos}, .5, Enum.EasingStyle.Quint)
	else
		self._pos = self._preMaxPos or UDim2.new(.5, 0, 0, TOP)
		tw(main, {Size = UDim2.fromOffset(self._size.X, self._size.Y), Position = self._pos}, .5, Enum.EasingStyle.Quint)
	end
	self._maxCtl.SetIcon(self.Maximized and "copy" or "square")
	self._grip.Visible = not self.Maximized
end

--------------------------------------------------------------------- CHỈNH TỪ BÊN NGOÀI
function UI:SetTitle(t)
	t = string.upper(tostring(t or ""))
	self._title.Text = t; self._itxt.Text = t
end
function UI:SetSubtitle(t)
	t = tostring(t or "")
	self._sub.Text = t; self:_relayout()
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
-- AddTab("Home", "house")  hoặc  AddTab({Name = "Home", Icon = "rbxassetid://123" | "https://.../i.png"})
function UI:AddTab(name, icon)
	if type(name) == "table" then name, icon = name.Name or name.Title or "Tab", name.Icon end
	local tab = {Window = self, Name = name}

	local btn = new("TextButton", {
		Size = UDim2.new(0, 0, 0, 28), AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = RGB(46, 46, 46), BackgroundTransparency = 1, BorderSizePixel = 0, AutoButtonColor = false,
		Text = "", Parent = self.TabBar,
	}, {
		corner(4),
		new("UIPadding", {PaddingLeft = UDim.new(0, COMPACT and 9 or 11), PaddingRight = UDim.new(0, COMPACT and 9 or 11)}),
		new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, COMPACT and 5 or 6), VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder}),
	})
	local ic
	if icon and icon ~= "" then
		ic = AnyIcon(icon, btn, COMPACT and 13 or 14, C.Sub); ic.Root.LayoutOrder = 1
	end
	local txt = label(name, COMPACT and 10 or 11, C.Sub, F.Bold)
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
			ScrollBarImageTransparency = .4, VerticalScrollBarInset = Enum.ScrollBarInset.None,
			CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = page,
		}, {
			list(8),
			-- 1px đệm 3 phía để viền (stroke) không bị cắt; đệm dưới để mục cuối không dính mép
			new("UIPadding", {PaddingTop = UDim.new(0, 1), PaddingLeft = UDim.new(0, 1), PaddingRight = UDim.new(0, 1), PaddingBottom = UDim.new(0, 8)}),
		})
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
	self:_reveal(tab)
end

-- cuộn thanh tab để tab đang chọn nằm giữa (không bị che)
function UI:_reveal(tab)
	local bar, b = self.TabBar, tab.Button
	task.defer(function()
		if not (bar.Parent and b.Parent) then return end
		local k = bar.AbsoluteSize.Y / 36
		if k <= 0 then return end
		local left = (b.AbsolutePosition.X - bar.AbsolutePosition.X) / k + bar.CanvasPosition.X
		local w, view = b.AbsoluteSize.X / k, bar.AbsoluteSize.X / k
		local maxX = math.max(0, bar.AbsoluteCanvasSize.X / k - view)
		tw(bar, {CanvasPosition = Vector2.new(math.clamp(left - (view - w) / 2, 0, maxX), 0)}, .3)
	end)
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
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = C.White, BorderSizePixel = 0, Parent = tab.Columns[col or 1],
	}, {corner(6), pad(9), list(6)})
	grad(box, C.Panel1, C.Panel2, 90)
	local bs = stroke(C.Stroke, 1); bs.Transparency = .2; bs.Parent = box

	local head = new("Frame", {Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, LayoutOrder = 0, Parent = box})
	new("Frame", {Size = UDim2.fromOffset(5, 5), Position = UDim2.fromOffset(1, 7), BackgroundColor3 = C.White, BorderSizePixel = 0, Parent = head}, {pill()})
	local hl = label(string.upper(name), 10, C.Text, F.Bold); hl.Position = UDim2.fromOffset(14, 0); hl.Size = UDim2.new(1, -14, 1, 0); hl.Parent = head
	sec.Box = box
	tab._secs = tab._secs or {}
	table.insert(tab._secs, {box = box, col = col or 1})
	if tab.Window._single then tab.Window:_arrange(tab) end
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
		local arrow = Icon("chevron-down", hd, 12, C.Sub)
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

return UI

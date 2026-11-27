-- Ryzen Hub UI v9 — tab ngang + 2 cột card (theo giao diện Ryzen Hub), API kiểu WindUI
-- Icon: toàn bộ dùng Lucide (lucide.dev) thật, tải qua module Footagesus/Icons (không còn icon tự vẽ).
-- Dùng: local UI = loadstring(game:HttpGet("<url của file này>"))()
-- Xem ví dụ ở cuối file (phần EXAMPLE, đang để comment)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local lp = Players.LocalPlayer

--------------------------------------------------------------------- THEME (đen/trắng)
local function RGB(r, g, b) return Color3.fromRGB(r, g, b) end

local C = {
	White   = RGB(255, 255, 255),
	Black   = RGB(0, 0, 0),
	Bg1     = RGB(19, 19, 19),
	Bg2     = RGB(14, 14, 14),
	Panel   = RGB(23, 23, 23),
	Item    = RGB(29, 29, 29),
	ItemHov = RGB(39, 39, 39),
	Field   = RGB(29, 29, 29),
	Stroke  = RGB(47, 47, 47),
	Stroke2 = RGB(64, 64, 64),
	Text    = RGB(240, 240, 240),
	Sub     = RGB(128, 128, 128),
	Off     = RGB(42, 42, 42),
	Knob    = RGB(120, 120, 120),
	Checked = RGB(228, 228, 228),
}

local function font(name, weight, fallback)
	local ok, f = pcall(function() return Font.fromName(name, weight) end)
	if ok and f then return f end
	return Font.fromEnum(fallback)
end
local F = {
	Brand = font("Michroma", Enum.FontWeight.Regular, Enum.Font.Michroma),
	Reg   = font("Montserrat", Enum.FontWeight.Medium, Enum.Font.Gotham),
	Semi  = font("Montserrat", Enum.FontWeight.SemiBold, Enum.Font.GothamMedium),
	Bold  = font("Montserrat", Enum.FontWeight.Bold, Enum.Font.GothamBold),
}

--------------------------------------------------------------------- KÍCH THƯỚC (đơn vị UI, trước khi scale)
local ISL_TOP   = 8                          -- đảo cách mép trên
local IDLE      = Vector2.new(138, 30)       -- đảo thu gọn
local NOTI      = Vector2.new(258, 52)       -- đảo khi có thông báo
local TOP       = ISL_TOP + IDLE.Y + 6       -- đỉnh cửa sổ
local TITLE_H   = 38                         -- thanh tiêu đề
local TABBAR_H  = 34                         -- thanh tab ngang
local FOOT_H    = 24                         -- thanh chân (tên người chơi)
local DEF_SIZE  = Vector2.new(580, 300)      -- cỡ mặc định
local MIN_SIZE  = Vector2.new(340, 220)
local COMPACT   = UIS.TouchEnabled and not UIS.KeyboardEnabled

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
local function padding(t, r, b, l)
	return new("UIPadding", {
		PaddingTop = UDim.new(0, t), PaddingRight = UDim.new(0, r or t),
		PaddingBottom = UDim.new(0, b or t), PaddingLeft = UDim.new(0, l or r or t),
	})
end
local function list(gap, dir)
	return new("UIListLayout", {
		Padding = UDim.new(0, gap or 6), SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = dir or Enum.FillDirection.Vertical,
	})
end
local function label(text, size, color, face)
	return new("TextLabel", {
		BackgroundTransparency = 1, Text = text, TextSize = size or 11,
		TextColor3 = color or C.Text, TextXAlignment = Enum.TextXAlignment.Left,
		FontFace = face or F.Reg, TextTruncate = Enum.TextTruncate.AtEnd,
	})
end
-- nhãn tự xuống dòng + tự cao
local function wrapLabel(text, size, color, face)
	local l = label(text, size, color, face)
	l.TextWrapped = true
	l.TextTruncate = Enum.TextTruncate.None
	l.TextYAlignment = Enum.TextYAlignment.Top
	l.AutomaticSize = Enum.AutomaticSize.Y
	l.Size = UDim2.new(1, 0, 0, 0)
	return l
end

-- tween: tự huỷ tween cũ cùng thuộc tính
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

local function fire(cb, ...)
	if type(cb) ~= "function" then return end
	local args = table.pack(...)
	task.spawn(function()
		local ok, err = pcall(cb, table.unpack(args, 1, args.n))
		if not ok then warn("[RyzenHub] callback error: " .. tostring(err)) end
	end)
end

local function grad(parent, c1, c2, rot)
	return new("UIGradient", {Color = ColorSequence.new(c1, c2), Rotation = rot or 0, Parent = parent})
end

-- vệt sáng trắng chạy quanh viền (1 vòng Heartbeat chung) — chỉ dùng cho đảo
local Spin = setmetatable({}, {__mode = "k"})
local function shine(strokeObj, speed, base)
	base = base or 0.85
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

--------------------------------------------------------------------- ICON LUCIDE (https://lucide.dev)
-- Tên icon đúng như trên lucide.dev: "house", "settings", "swords", "target", "layers", "flag", "zap"...
-- Cũng nhận "lucide:tên", asset id (123456 / "rbxassetid://...") hoặc URL ảnh.
-- Muốn dùng module riêng: getgenv().LucideIcons = <module có .Icon(name, "lucide")>
local LUCIDE_SOURCES = {
	"https://raw.githubusercontent.com/Footagesus/Icons/main/Main.lua",
	"https://cdn.jsdelivr.net/gh/Footagesus/Icons@main/Main.lua",
}
-- Tải text: thử game:HttpGet, lỗi thì thử request()/http_request() (một số executor mobile chỉ chạy được cái này)
local function fetchText(url)
	local ok, res = pcall(function() return game:HttpGet(url) end)
	if ok and type(res) == "string" and #res > 0 then return res end
	local req = request or http_request or (syn and syn.request) or (http and http.request)
	if req then
		local ok2, r = pcall(req, {Url = url, Method = "GET"})
		if ok2 and type(r) == "table" and type(r.Body) == "string" and #r.Body > 0 then return r.Body end
	end
	return nil
end
-- tên cũ/mới của cùng một icon trong Lucide (home -> house, ...)
local ALIAS = {
	house = {"home"}, home = {"house"}, settings = {"cog", "settings-2"}, cog = {"settings"},
	swords = {"sword"}, target = {"crosshair", "circle-dot"}, layers = {"layers-2", "layers-3"},
	flag = {"flag-triangle-right"}, ["map-pin"] = {"map-pinned", "pin"}, zap = {"bolt"},
	x = {"close"}, ["triangle-alert"] = {"alert-triangle"}, ["trash-2"] = {"trash"},
	["folder-open"] = {"folder"}, loader = {"loader-2"},
}

local LucideLib, LucideState, LucideWait, LucideCache = nil, "idle", {}, {}
local lucideFails = 0

local function lucideInit()
	if LucideState ~= "idle" then return end
	LucideState = "loading"
	task.spawn(function()
		local env = (getgenv and getgenv()) or _G
		local lib = type(env.LucideIcons) == "table" and env.LucideIcons or nil
		local lastErr
		for attempt = 1, 3 do
			if lib then break end
			for _, url in ipairs(LUCIDE_SOURCES) do
				local src = fetchText(url)
				if src then
					local fn, cerr = loadstring(src)
					if fn then
						local ok, res = pcall(fn)
						if ok and type(res) == "table" and res.Icon then lib = res break end
						lastErr = ok and "module không có hàm Icon" or tostring(res)
					else
						lastErr = tostring(cerr)
					end
				else
					lastErr = "không tải được " .. url
				end
			end
			if not lib and attempt < 3 then task.wait(.6) end
		end
		if lib and lib.SetIconsType then pcall(lib.SetIconsType, "lucide") end
		LucideLib = lib
		LucideState = lib and "ready" or "failed"
		if not lib then warn("[RyzenHub] cannot load Lucide icons (" .. tostring(lastErr) .. "), dùng icon vẽ sẵn") end
		for _, cb in ipairs(LucideWait) do task.defer(cb) end
		LucideWait = {}
	end)
end

local function lucideWhenReady(cb)
	if LucideState == "ready" or LucideState == "failed" then return cb() end
	table.insert(LucideWait, cb)
	lucideInit()
end

local function toV2(v)
	if typeof(v) == "Vector2" then return v end
	if type(v) == "table" then
		local x, y = v.X or v.x or v[1], v.Y or v.y or v[2]
		if type(x) == "number" and type(y) == "number" then return Vector2.new(x, y) end
	end
	return nil
end

-- Lấy {Image, Pos, Size} từ kết quả của LucideLib.Icon (nhận nhiều dạng trả về)
local function parseIcon(a, b)
	local img, pos, siz
	if type(a) == "table" then
		local meta = type(a[2]) == "table" and a[2] or a
		img = a[1] or a.Image or a.Id or meta.Image or meta.Id
		pos = toV2(meta.ImageRectPosition or meta.ImageRectOffset)
		siz = toV2(meta.ImageRectSize)
	elseif (type(a) == "string" or type(a) == "number") and type(b) == "table" then
		img = a
		pos = toV2(b.ImageRectPosition or b.ImageRectOffset)
		siz = toV2(b.ImageRectSize)
	end
	-- Image là số thứ tự spritesheet -> tra bảng Spritesheets của module để lấy rbxassetid
	if (type(img) == "number" or (type(img) == "string" and img:match("^%d+$"))) and LucideLib then
		local sp = type(LucideLib.Spritesheets) == "table" and LucideLib.Spritesheets[tostring(img)]
		if sp then img = sp end
	end
	if type(img) == "number" then img = "rbxassetid://" .. img end
	if type(img) == "string" and img:match("^%d+$") then img = "rbxassetid://" .. img end
	if type(img) ~= "string" or img == "" then return nil end
	if not (pos and siz) or siz.X <= 0 or siz.Y <= 0 then return nil end
	return {Image = img, Pos = pos, Size = siz}
end

local function dumpShape(v, depth)
	if type(v) ~= "table" or depth > 1 then return tostring(v) end
	local out = {}
	for k, x in pairs(v) do out[#out + 1] = tostring(k) .. "=" .. dumpShape(x, depth + 1) end
	return "{" .. table.concat(out, ", ") .. "}"
end

local lucideDumped = false
local function lucideLookup(name)
	if LucideState ~= "ready" then return nil end
	local c = LucideCache[name]
	if c ~= nil then return c or nil end
	local cands = {name}
	for _, al in ipairs(ALIAS[name] or {}) do cands[#cands + 1] = al end
	local data, shape
	for _, cand in ipairs(cands) do
		for _, f in ipairs({
			function() return LucideLib.Icon(cand, "lucide") end,
			function() return LucideLib.Icon("lucide:" .. cand) end,
			function() return LucideLib.Icon(cand) end,
			function() -- tra thẳng trong bảng dữ liệu của module
				local t = LucideLib.Icons
				if type(t) ~= "table" then return nil end
				return (type(t.lucide) == "table" and t.lucide[cand]) or t[cand]
			end,
		}) do
			local ok, a, b = pcall(f)
			if not ok then
				shape = "error: " .. tostring(a)
			elseif a ~= nil then
				shape = typeof(a) .. " " .. dumpShape(a, 0) .. (b ~= nil and (" | " .. dumpShape(b, 0)) or "")
				data = parseIcon(a, b)
			end
			if data then break end
		end
		if data then break end
	end
	LucideCache[name] = data or false
	if not data and lucideFails < 3 then
		lucideFails = lucideFails + 1
		warn("[RyzenHub] Lucide icon not found: " .. name .. " -> " .. tostring(shape or "module trả về nil"))
		if not lucideDumped then
			lucideDumped = true
			local keys = {}
			for k, v in pairs(LucideLib) do keys[#keys + 1] = tostring(k) .. ":" .. typeof(v) end
			warn("[RyzenHub] Lucide module keys: " .. table.concat(keys, ", "))
		end
	end
	return data
end

-- Icon vẽ bằng Frame (không phụ thuộc font/mạng) — dùng khi Lucide không tải được
local function drawFallback(name, root, s, col)
	local parts = {}
	local th = math.max(1.5, s * .13)
	local function bar(cx, cy, len, rot)
		local f = new("Frame", {
			AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromOffset(cx, cy), Size = UDim2.fromOffset(len, th),
			Rotation = rot, BackgroundColor3 = col, BorderSizePixel = 0, Parent = root,
		}, {corner(2)})
		parts[#parts + 1] = {f, "BackgroundColor3"}
	end
	local function box(x, y, w, h, r)
		local f = new("Frame", {
			Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = root,
		}, {corner(r or 2)})
		local st = new("UIStroke", {Thickness = math.max(1.2, s * .1), Color = col, Parent = f})
		parts[#parts + 1] = {st, "Color"}
	end
	local w = .22 * s
	local L = w * 1.414 * 1.15
	if name == "check" then
		bar(.31 * s, .62 * s, .33 * s, 42)
		bar(.62 * s, .51 * s, .64 * s, -46)
	elseif name == "x" then
		bar(.5 * s, .5 * s, .85 * s, 45); bar(.5 * s, .5 * s, .85 * s, -45)
	elseif name == "minus" then
		bar(.5 * s, .5 * s, .7 * s, 0)
	elseif name == "square" then
		box(.18 * s, .18 * s, .64 * s, .64 * s)
	elseif name == "copy" then
		box(.14 * s, .14 * s, .5 * s, .5 * s); box(.36 * s, .36 * s, .5 * s, .5 * s)
	elseif name == "chevron-down" then
		bar(.5 * s - w / 2, .5 * s, L, 45); bar(.5 * s + w / 2, .5 * s, L, -45)
	elseif name == "chevron-up" then
		bar(.5 * s - w / 2, .5 * s, L, -45); bar(.5 * s + w / 2, .5 * s, L, 45)
	elseif name == "chevron-right" then
		bar(.5 * s, .5 * s - w / 2, L, 45); bar(.5 * s, .5 * s + w / 2, L, -45)
	elseif name == "move-diagonal-2" then
		bar(.78 * s, .78 * s, .28 * s, -45); bar(.55 * s, .55 * s, .6 * s, -45)
	elseif name == "house" or name == "home" then
		bar(.32 * s, .36 * s, .5 * s, -40); bar(.68 * s, .36 * s, .5 * s, 40)
		box(.24 * s, .46 * s, .52 * s, .42 * s)
	elseif name == "settings" or name == "cog" then
		bar(.5 * s, .5 * s, .96 * s, 0); bar(.5 * s, .5 * s, .96 * s, 90)
		bar(.5 * s, .5 * s, .9 * s, 45); bar(.5 * s, .5 * s, .9 * s, -45)
		local g = new("Frame", {
			AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(s * .6, s * .6),
			BackgroundColor3 = C.Bg2, BorderSizePixel = 0, Parent = root,
		}, {corner(99)})
		local gs = new("UIStroke", {Thickness = math.max(1.2, s * .1), Color = col, Parent = g})
		parts[#parts + 1] = {gs, "Color"}
	elseif name == "swords" or name == "sword" then
		bar(.5 * s, .5 * s, .95 * s, 45); bar(.5 * s, .5 * s, .95 * s, -45)
		bar(.3 * s, .7 * s, .3 * s, 45); bar(.7 * s, .7 * s, .3 * s, -45)
	elseif name == "target" or name == "crosshair" then
		box(.1 * s, .1 * s, .8 * s, .8 * s, 99)
		if name == "target" then
			box(.3 * s, .3 * s, .4 * s, .4 * s, 99)
		else
			bar(.5 * s, .5 * s, 1 * s, 0); bar(.5 * s, .5 * s, 1 * s, 90)
		end
		local d = new("Frame", {
			AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(s * .16, s * .16),
			BackgroundColor3 = col, BorderSizePixel = 0, Parent = root,
		}, {corner(99)})
		parts[#parts + 1] = {d, "BackgroundColor3"}
	elseif name == "layers" then
		bar(.32 * s, .28 * s, L, -45); bar(.68 * s, .28 * s, L, 45)
		bar(.32 * s, .28 * s, L, 45); bar(.68 * s, .28 * s, L, -45)
		bar(.5 * s - w / 2, .55 * s, L, 45); bar(.5 * s + w / 2, .55 * s, L, -45)
		bar(.5 * s - w / 2, .78 * s, L, 45); bar(.5 * s + w / 2, .78 * s, L, -45)
	elseif name == "flag" then
		bar(.22 * s, .5 * s, .8 * s, 90)
		box(.26 * s, .12 * s, .56 * s, .38 * s, 1)
	elseif name == "zap" then
		bar(.46 * s, .325 * s, .55 * s, -54); bar(.54 * s, .675 * s, .55 * s, -54)
		bar(.5 * s, .5 * s, .4 * s, 0)
	elseif name == "eye" then
		box(.04 * s, .24 * s, .92 * s, .52 * s, 99)
		local d = new("Frame", {
			AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(s * .22, s * .22),
			BackgroundColor3 = col, BorderSizePixel = 0, Parent = root,
		}, {corner(99)})
		parts[#parts + 1] = {d, "BackgroundColor3"}
	elseif name == "bell" then
		box(.22 * s, .12 * s, .56 * s, .56 * s, 99)
		bar(.5 * s, .72 * s, .76 * s, 0)
		local d = new("Frame", {
			AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .88), Size = UDim2.fromOffset(s * .2, s * .2),
			BackgroundColor3 = col, BorderSizePixel = 0, Parent = root,
		}, {corner(99)})
		parts[#parts + 1] = {d, "BackgroundColor3"}
	elseif name == "info" then
		box(.08 * s, .08 * s, .84 * s, .84 * s, 99)
		local t = new("TextLabel", {
			Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "i", TextColor3 = col,
			TextSize = math.max(8, s * .6), Font = Enum.Font.GothamBold, Parent = root,
		})
		parts[#parts + 1] = {t, "TextColor3"}
	else -- icon chưa có: chấm tròn nhỏ để bố cục không bị lệch
		local d = new("Frame", {
			AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(s * .32, s * .32),
			BackgroundColor3 = col, BorderSizePixel = 0, Parent = root,
		}, {corner(99)})
		parts[#parts + 1] = {d, "BackgroundColor3"}
	end
	return parts
end

-- Icon(name, parent, size, color) -> {Root = Frame, SetColor = fn, Destroy = fn}
local function Icon(name, parent, size, col)
	col = col or C.Text
	name = (tostring(name):gsub("^lucide:", ""))
	local root = new("Frame", {
		Name = "Icon_" .. name, Size = UDim2.fromOffset(size, size), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = parent,
	})
	local img = new("ImageLabel", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Fit,
		ImageColor3 = col, Visible = false, Parent = root,
	})
	local parts, cur = nil, col
	lucideWhenReady(function()
		if not root.Parent then return end
		local d = lucideLookup(name)
		if d then
			img.Image = d.Image
			img.ImageRectOffset = d.Pos
			img.ImageRectSize = d.Size
			img.Visible = true
		else
			parts = drawFallback(name, root, size, cur)
		end
	end)
	local api = {Root = root}
	function api.SetColor(c)
		cur = c
		tw(img, {ImageColor3 = c}, .18)
		if parts then for _, pr in ipairs(parts) do tw(pr[1], {[pr[2]] = c}, .18) end end
	end
	function api.Destroy() root:Destroy() end
	return api
end
lucideInit()

--------------------------------------------------------------------- ẢNH: asset id / rbxassetid / URL
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
		if ok and res then ImgCache[src] = res; cb(res) else warn("[RyzenHub] cannot load image: " .. tostring(src)); cb(nil) end
	end)
end

-- spec: tên Lucide hoặc ảnh (id / URL)
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
	function api.Destroy() img:Destroy() end
	return api
end

local function keyOf(k)
	if typeof(k) == "EnumItem" then return k end
	if type(k) == "string" then
		local ok, v = pcall(function() return Enum.KeyCode[k] end)
		if ok and v then return v end
	end
	return nil
end
local function keyName(k) return (k.Name:gsub("(%l)(%u)", "%1 %2"):gsub("Control", "Ctrl")) end

local function viewport()
	local cam = workspace.CurrentCamera
	return cam and cam.ViewportSize or Vector2.new(1280, 720)
end

-- scale theo màn hình (không bao giờ > 1) rồi nhân với Scale người dùng
local function fitScale(size, userScale)
	local vp = viewport()
	local s = math.min((vp.Y - TOP - 8) / size.Y, (vp.X - 16) / size.X, 1)
	return math.clamp(s, .45, 1) * (userScale or 1)
end

--------------------------------------------------------------------- MODULE
local UI = {}
local Window = {}
Window.__index = Window
local Elements = {}      -- Toggle, Button, Slider, ... (dùng chung cho Tab và Section)
local TabC = {}
TabC.__index = TabC
local SectionC = {}
SectionC.__index = SectionC

local KIND_ICON = {success = "check", error = "x", info = "info"}

--------------------------------------------------------------------- DÒNG (row) DÙNG CHUNG CHO MỌI ELEMENT
local function T(o) return tostring(o.Title or o.Name or "") end
local function D(o) return o.Desc or o.Description end

-- clickable: row là TextButton; stacked: có thêm hàng điều khiển bên dưới (dropdown/input/slider)
-- plain: không có khung (nhãn xám nhỏ + ô điều khiển ngay trong card), dùng cho dropdown/input/slider
local function makeRow(self, o, rightW, stacked, clickable, plain)
	self._order = self._order + 1
	if self._top and self._holder == self._top then self._top.Visible = true end
	local row = new(clickable and "TextButton" or "Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = C.Item,
		BackgroundTransparency = plain and 1 or 0, BorderSizePixel = 0, LayoutOrder = self._order, Parent = self._holder,
	}, plain and {} or {corner(7), padding(9, 12)})
	if clickable then row.AutoButtonColor = false; row.Text = "" end
	local rs = stroke(C.Stroke, 1); rs.Parent = row; rs.Enabled = not plain
	if stacked then
		new("UIListLayout", {Padding = UDim.new(0, plain and 5 or 7), SortOrder = Enum.SortOrder.LayoutOrder, Parent = row})
	end
	local head = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
		LayoutOrder = 1, Parent = row,
	})
	local tb = new("Frame", {
		Size = UDim2.new(1, rightW and -(rightW + 8) or 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1, Parent = head,
	}, {list(1)})
	local title = wrapLabel(T(o), plain and 10 or 11, plain and C.Sub or C.Text, F.Reg); title.LayoutOrder = 1; title.Parent = tb
	local desc = wrapLabel(D(o) or "", 10, C.Sub, F.Reg); desc.LayoutOrder = 2; desc.Parent = tb
	desc.Visible = D(o) ~= nil and D(o) ~= ""
	title.Visible = T(o) ~= ""
	head.Visible = title.Visible or desc.Visible
	return {Row = row, Head = head, Title = title, Desc = desc, Stroke = rs, Plain = plain}
end

-- API chung: SetTitle / SetDesc / Lock / Unlock / SetVisible / Destroy + đăng ký Flag
local function finish(self, o, r, api, onDestroy)
	api.Locked = false
	function api:SetTitle(t) r.Title.Text = tostring(t); r.Title.Visible = tostring(t) ~= ""; r.Head.Visible = r.Title.Visible or r.Desc.Visible end
	function api:SetDesc(t) t = tostring(t or ""); r.Desc.Text = t; r.Desc.Visible = t ~= ""; r.Head.Visible = r.Title.Visible or r.Desc.Visible end
	function api:SetVisible(v) r.Row.Visible = v and true or false end
	function api:Lock()
		self.Locked = true
		if not r.Plain then tw(r.Row, {BackgroundTransparency = .5}, .15) end
		tw(r.Title, {TextTransparency = .5}, .15)
	end
	function api:Unlock()
		self.Locked = false
		if not r.Plain then tw(r.Row, {BackgroundTransparency = 0}, .15) end
		tw(r.Title, {TextTransparency = 0}, .15)
	end
	function api:Destroy()
		if onDestroy then onDestroy() end
		if o.Flag and self._flagOwner and self._flagOwner.Flags[o.Flag] == self then self._flagOwner.Flags[o.Flag] = nil end
		r.Row:Destroy()
	end
	api.Row = r.Row
	if o.Flag then
		self._win.Flags[o.Flag] = api
		api._flagOwner = self._win
	end
	if o.Locked then api:Lock() end
	return api
end

local function hoverRow(r, extra)
	local row = r.Row
	row.MouseEnter:Connect(function() tw(row, {BackgroundColor3 = C.ItemHov}, .15) end)
	row.MouseLeave:Connect(function() tw(row, {BackgroundColor3 = C.Item}, .15); if extra then extra() end end)
end

--------------------------------------------------------------------- TOGGLE
-- Tab:Toggle({Title = "Auto Farm", Desc = "...", Value = false, Type = "Checkbox"(mặc định)|"Switch", Flag = "AutoFarm", Callback = function(v) end})
function Elements:Toggle(o)
	o = o or {}
	local v = o.Value
	if v == nil then v = o.Default end
	local state = v and true or false
	local checkbox = tostring(o.Type or "Checkbox"):lower() ~= "switch"
	local r = makeRow(self, o, checkbox and 22 or 34, false, true)
	local row = r.Row

	local track, knob, mark, markScale
	if checkbox then
		track = new("Frame", {
			AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, 0, .5, 0), Size = UDim2.fromOffset(22, 22),
			BackgroundColor3 = C.Off, BorderSizePixel = 0, Parent = row,
		}, {corner(6)})
		mark = Icon("check", track, 14, C.White)
		mark.Root.AnchorPoint = Vector2.new(.5, .5); mark.Root.Position = UDim2.fromScale(.5, .5)
		mark.Root.Visible = state
		markScale = new("UIScale", {Scale = 1, Parent = mark.Root})
	else
		track = new("Frame", {
			AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, 0, .5, 0), Size = UDim2.fromOffset(32, 18),
			BackgroundColor3 = C.Off, BorderSizePixel = 0, Parent = row,
		}, {pill()})
		knob = new("Frame", {
			AnchorPoint = Vector2.new(0, .5), Position = UDim2.new(0, 3, .5, 0), Size = UDim2.fromOffset(12, 12),
			BackgroundColor3 = C.Knob, BorderSizePixel = 0, Parent = track,
		}, {pill()})
	end
	local ts = stroke(checkbox and C.Stroke2 or C.Stroke, 1); ts.Parent = track

	local function apply(anim)
		local t = anim and .22 or 0
		local function set(o2, p) if anim then tw(o2, p, t) else for k, val in pairs(p) do o2[k] = val end end end
		set(r.Stroke, {Color = state and C.Checked or C.Stroke})
		if checkbox then
			set(track, {BackgroundColor3 = state and RGB(16, 16, 16) or C.Off})
			set(ts, {Color = state and C.Checked or C.Stroke2})
			mark.Root.Visible = state
			if state and anim then
				markScale.Scale = .4
				tw(markScale, {Scale = 1}, .28, Enum.EasingStyle.Back)
			end
		else
			set(track, {BackgroundColor3 = state and C.White or C.Off})
			set(ts, {Color = state and C.White or C.Stroke})
			set(knob, {BackgroundColor3 = state and C.Black or C.Knob})
			if anim then tw(knob, {Position = UDim2.new(0, state and 17 or 3, .5, 0)}, .25, Enum.EasingStyle.Back)
			else knob.Position = UDim2.new(0, state and 17 or 3, .5, 0) end
		end
	end
	apply(false)

	local api = {}
	function api:Set(val, silent)
		state = val and true or false
		apply(true)
		if not silent then fire(o.Callback, state) end
	end
	function api:Get() return state end
	row.MouseButton1Click:Connect(function() if not api.Locked then api:Set(not state) end end)
	hoverRow(r)
	return finish(self, o, r, api)
end

--------------------------------------------------------------------- BUTTON
-- Tab:Button({Title = "Teleport", Desc = "...", Icon = "map-pin", Callback = function() end})
function Elements:Button(o)
	o = o or {}
	local r = makeRow(self, o, 18, false, true)
	local row = r.Row
	local sc = new("UIScale", {Parent = row})
	local ic = Icon(o.Icon or "chevron-right", row, 14, C.Sub)
	ic.Root.AnchorPoint = Vector2.new(1, .5); ic.Root.Position = UDim2.new(1, 0, .5, 0)
	local api = {}
	function api:Click() fire(o.Callback) end
	row.MouseButton1Click:Connect(function() if not api.Locked then fire(o.Callback) end end)
	row.MouseEnter:Connect(function() ic.SetColor(C.White) end)
	row.MouseLeave:Connect(function() ic.SetColor(C.Sub); tw(sc, {Scale = 1}, .2) end)
	row.MouseButton1Down:Connect(function() tw(sc, {Scale = .98}, .08) end)
	row.MouseButton1Up:Connect(function() tw(sc, {Scale = 1}, .25, Enum.EasingStyle.Back) end)
	hoverRow(r)
	return finish(self, o, r, api)
end

--------------------------------------------------------------------- SLIDER
-- Tab:Slider({Title = "Speed", Step = 1, Value = {Min = 0, Max = 100, Default = 50}, Callback = function(v) end})
function Elements:Slider(o)
	o = o or {}
	local vc = type(o.Value) == "table" and o.Value or {}
	local min = vc.Min or o.Min or 0
	local max = vc.Max or o.Max or 100
	local step = o.Step or vc.Step or 1
	local val = math.clamp(vc.Default or o.Default or (type(o.Value) == "number" and o.Value) or min, min, max)
	local dec = tostring(step):match("%.(%d+)")
	dec = dec and #dec or 0
	local function fmt(x) return string.format("%." .. dec .. "f", x) end

	local r = makeRow(self, o, 46, true, false, true)
	local row = r.Row
	local valLbl = label(fmt(val), 10, C.Text, F.Semi)
	valLbl.AnchorPoint = Vector2.new(1, 0); valLbl.Position = UDim2.new(1, 0, 0, 0)
	valLbl.Size = UDim2.fromOffset(44, 14); valLbl.TextXAlignment = Enum.TextXAlignment.Right; valLbl.Parent = r.Head
	r.Head.Visible = true

	local hold = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
		LayoutOrder = 2, Parent = row,
	})
	local track = new("Frame", {
		AnchorPoint = Vector2.new(0, .5), Position = UDim2.new(0, 0, .5, 0), Size = UDim2.new(1, 0, 0, 4),
		BackgroundColor3 = C.Off, BorderSizePixel = 0, Parent = hold,
	}, {pill()})
	local fill = new("Frame", {Size = UDim2.fromScale(0, 1), BackgroundColor3 = C.White, BorderSizePixel = 0, Parent = track}, {pill()})
	local knob = new("Frame", {
		AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(0, .5), Size = UDim2.fromOffset(12, 12),
		BackgroundColor3 = C.White, BorderSizePixel = 0, Parent = track,
	}, {pill()})
	local ks = stroke(C.Panel, 2); ks.Parent = knob

	local function frac() return max > min and (val - min) / (max - min) or 0 end
	local function render(anim)
		local f = frac()
		valLbl.Text = fmt(val)
		if anim then
			tw(fill, {Size = UDim2.fromScale(f, 1)}, .1)
			tw(knob, {Position = UDim2.fromScale(f, .5)}, .1)
		else
			fill.Size = UDim2.fromScale(f, 1); knob.Position = UDim2.fromScale(f, .5)
		end
	end
	render(false)

	local api = {}
	function api:Set(v, silent)
		v = tonumber(v) or min
		v = min + math.floor((v - min) / step + .5) * step
		v = math.clamp(tonumber(fmt(v)) or v, min, max)
		if v == val then return end
		val = v
		render(true)
		if not silent then fire(o.Callback, val) end
	end
	function api:Get() return val end

	local dragging = false
	local function fromX(x)
		local w = track.AbsoluteSize.X
		if w <= 0 then return end
		local f = math.clamp((x - track.AbsolutePosition.X) / w, 0, 1)
		api:Set(min + f * (max - min))
	end
	local page = self._page
	local function stop()
		dragging = false
		tw(knob, {Size = UDim2.fromOffset(12, 12)}, .15)
		if page then page.ScrollingEnabled = true end
	end
	hold.InputBegan:Connect(function(i)
		if api.Locked then return end
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			if page then page.ScrollingEnabled = false end
			tw(knob, {Size = UDim2.fromOffset(15, 15)}, .15)
			fromX(i.Position.X)
			i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End and dragging then stop() end end)
		end
	end)
	local c1 = UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			fromX(i.Position.X)
		end
	end)
	local c2 = UIS.InputEnded:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then stop() end
	end)
	self._win:_track(c1); self._win:_track(c2)
	return finish(self, o, r, api, function() c1:Disconnect(); c2:Disconnect() end)
end

--------------------------------------------------------------------- DROPDOWN
-- Tab:Dropdown({Title = "Select Boss", Values = {"A","B"}, Value = "A", Multi = false, Placeholder = "None", Callback = function(v) end})
function Elements:Dropdown(o)
	o = o or {}
	local values = o.Values or o.Options or {}
	local multi = o.Multi and true or false
	local sel = {}               -- tập đã chọn: sel[name] = true
	local function setInitial(v)
		sel = {}
		if type(v) == "table" then
			for _, n in ipairs(v) do sel[tostring(n)] = true end
		elseif v ~= nil then
			sel[tostring(v)] = true
		end
	end
	setInitial(o.Value ~= nil and o.Value or o.Default)

	local r = makeRow(self, o, nil, true, false, true)
	local row = r.Row
	local hd = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = C.Field, BorderSizePixel = 0, AutoButtonColor = false, Text = "",
		LayoutOrder = 2, Parent = row,
	}, {corner(7)})
	local hs = stroke(C.Stroke, 1); hs.Parent = hd
	local val = label("", 11, C.Text)
	val.Position = UDim2.fromOffset(12, 0); val.Size = UDim2.new(1, -34, 1, 0); val.Parent = hd
	local arrow = Icon("chevron-down", hd, 12, C.Sub)
	arrow.Root.AnchorPoint = Vector2.new(.5, .5); arrow.Root.Position = UDim2.new(1, -16, .5, 0)

	local opts = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = C.Field, BorderSizePixel = 0, ClipsDescendants = true, Visible = false,
		LayoutOrder = 3, Parent = row,
	}, {corner(7)})
	local os_ = stroke(C.Stroke, 1); os_.Parent = opts
	local scroll = new("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2,
		ScrollBarImageColor3 = C.Sub, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = opts,
	}, {list(2), padding(3)})

	local isOpen, buttons = false, {}
	local function summary()
		local out = {}
		for _, n in ipairs(values) do if sel[tostring(n)] then out[#out + 1] = tostring(n) end end
		if #out == 0 then return o.Placeholder or "None", false end
		return table.concat(out, ", "), true
	end
	local function refreshVisual(anim)
		local text, has = summary()
		val.Text = text
		tw(val, {TextColor3 = has and C.Text or C.Sub}, anim and .15 or 0)
		for name, b in pairs(buttons) do
			local on = sel[name] == true
			tw(b.btn, {TextColor3 = on and C.White or C.Sub, BackgroundTransparency = on and .9 or 1}, anim and .15 or 0)
			b.check.Root.Visible = on
		end
	end
	local function fullH()
		local n = #values
		return math.min(n * 26 + math.max(n - 1, 0) * 2 + 6, 124)
	end
	local function setOpen(v)
		isOpen = v
		tw(arrow.Root, {Rotation = v and 180 or 0}, .25, Enum.EasingStyle.Back)
		tw(hs, {Color = v and C.Checked or C.Stroke}, .2)
		if v then
			opts.Visible = true
			tw(opts, {Size = UDim2.new(1, 0, 0, fullH())}, .25)
		else
			local t = tw(opts, {Size = UDim2.new(1, 0, 0, 0)}, .2)
			t.Completed:Connect(function() if not isOpen then opts.Visible = false end end)
		end
	end

	local api = {}
	local function emit()
		if multi then
			local out = {}
			for _, n in ipairs(values) do if sel[tostring(n)] then out[#out + 1] = tostring(n) end end
			fire(o.Callback, out)
		else
			local cur
			for _, n in ipairs(values) do if sel[tostring(n)] then cur = tostring(n) end end
			fire(o.Callback, cur)
		end
	end
	local function build()
		for _, b in pairs(buttons) do b.btn:Destroy() end
		buttons = {}
		for i, nm in ipairs(values) do
			local name = tostring(nm)
			local b = new("TextButton", {
				Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = C.White, BackgroundTransparency = 1, BorderSizePixel = 0,
				Text = name, TextColor3 = C.Sub, TextSize = 11, FontFace = F.Reg, TextXAlignment = Enum.TextXAlignment.Left,
				AutoButtonColor = false, LayoutOrder = i, Parent = scroll,
			}, {corner(5), padding(0, 26, 0, 9)})
			local ck = Icon("check", b, 12, C.White)
			ck.Root.AnchorPoint = Vector2.new(1, .5); ck.Root.Position = UDim2.new(1, 18, .5, 0); ck.Root.Visible = false
			buttons[name] = {btn = b, check = ck}
			b.MouseEnter:Connect(function() if not sel[name] then tw(b, {BackgroundTransparency = .94}, .1) end end)
			b.MouseLeave:Connect(function() if not sel[name] then tw(b, {BackgroundTransparency = 1}, .1) end end)
			b.MouseButton1Click:Connect(function()
				if api.Locked then return end
				if multi then
					sel[name] = (not sel[name]) or nil
				else
					sel = {[name] = true}
					setOpen(false)
				end
				refreshVisual(true)
				emit()
			end)
		end
		refreshVisual(false)
	end
	build()

	function api:Set(v, silent)
		setInitial(v)
		refreshVisual(true)
		if not silent then emit() end
	end
	function api:Get()
		if multi then
			local out = {}
			for _, n in ipairs(values) do if sel[tostring(n)] then out[#out + 1] = tostring(n) end end
			return out
		end
		for _, n in ipairs(values) do if sel[tostring(n)] then return tostring(n) end end
		return nil
	end
	function api:Refresh(newValues)
		values = newValues or {}
		local keep = {}
		for _, n in ipairs(values) do if sel[tostring(n)] then keep[tostring(n)] = true end end
		sel = keep
		build()
		if isOpen then tw(opts, {Size = UDim2.new(1, 0, 0, fullH())}, .2) end
	end
	function api:Open() setOpen(true) end
	function api:Close() setOpen(false) end
	hd.MouseButton1Click:Connect(function() if not api.Locked then setOpen(not isOpen) end end)
	hd.MouseEnter:Connect(function() tw(hd, {BackgroundColor3 = C.ItemHov}, .15) end)
	hd.MouseLeave:Connect(function() tw(hd, {BackgroundColor3 = C.Field}, .15) end)
	return finish(self, o, r, api)
end

--------------------------------------------------------------------- INPUT
-- Tab:Input({Title = "Webhook", Placeholder = "...", Value = "", Numeric = false, Callback = function(text) end})
function Elements:Input(o)
	o = o or {}
	local r = makeRow(self, o, nil, true, false, true)
	local box = new("TextBox", {
		Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = C.Field, BorderSizePixel = 0, LayoutOrder = 2,
		Text = tostring(o.Value or o.Default or ""), PlaceholderText = o.Placeholder or "Type here...",
		PlaceholderColor3 = C.Sub, TextColor3 = C.Text, TextSize = 11, FontFace = F.Reg,
		TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, ClipsDescendants = true, Parent = r.Row,
	}, {corner(7), padding(0, 12, 0, 12)})
	local bs = stroke(C.Stroke, 1); bs.Parent = box
	box.Focused:Connect(function() tw(bs, {Color = C.Checked}, .15) end)
	local api = {}
	local function clean(t)
		if o.Numeric then t = t:gsub("[^%d%.%-]", "") end
		return t
	end
	box.FocusLost:Connect(function()
		tw(bs, {Color = C.Stroke}, .15)
		local t = clean(box.Text)
		box.Text = t
		if not api.Locked then fire(o.Callback, t) end
	end)
	function api:Set(v, silent)
		box.Text = clean(tostring(v or ""))
		if not silent then fire(o.Callback, box.Text) end
	end
	function api:Get() return box.Text end
	return finish(self, o, r, api)
end

--------------------------------------------------------------------- KEYBIND
-- Tab:Keybind({Title = "Fly", Value = "F", Callback = function(key) end})  -- Callback chạy khi BẤM phím đó
function Elements:Keybind(o)
	o = o or {}
	local key = keyOf(o.Value or o.Default)
	local listening = false
	local r = makeRow(self, o, 70, false, true)
	local row = r.Row
	local chip = new("TextLabel", {
		AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, 0, .5, 0), Size = UDim2.fromOffset(0, 22),
		AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = C.Field, BorderSizePixel = 0,
		Text = key and keyName(key) or "None", TextColor3 = C.Sub, TextSize = 10, FontFace = F.Semi, Parent = row,
	}, {corner(6), padding(0, 9, 0, 9)})
	new("UISizeConstraint", {MinSize = Vector2.new(36, 22), Parent = chip})
	local cs = stroke(C.Stroke, 1); cs.Parent = chip

	local api = {}
	local function show()
		chip.Text = listening and "..." or (key and keyName(key) or "None")
		tw(chip, {TextColor3 = listening and C.White or C.Sub}, .15)
		tw(cs, {Color = listening and C.Checked or C.Stroke}, .15)
	end
	function api:Set(v, silent)
		key = keyOf(v) or key
		listening = false
		show()
		if not silent and o.OnChange then fire(o.OnChange, key and key.Name) end
	end
	function api:Get() return key and key.Name or nil end
	row.MouseButton1Click:Connect(function()
		if api.Locked then return end
		listening = not listening
		show()
	end)
	local conn = UIS.InputBegan:Connect(function(i, gp)
		if listening then
			if i.UserInputType == Enum.UserInputType.Keyboard then
				if i.KeyCode ~= Enum.KeyCode.Escape then key = i.KeyCode
				end
				listening = false
				show()
				if o.OnChange and key then fire(o.OnChange, key.Name) end
			end
		elseif not gp and key and i.KeyCode == key and not api.Locked then
			fire(o.Callback, key.Name)
		end
	end)
	self._win:_track(conn)
	hoverRow(r)
	return finish(self, o, r, api, function() conn:Disconnect() end)
end

--------------------------------------------------------------------- PARAGRAPH / DIVIDER
function Elements:Paragraph(o)
	o = o or {}
	local r = makeRow(self, o, nil, false, false)
	local api = {}
	return finish(self, o, r, api)
end

function Elements:Divider()
	self._order = self._order + 1
	if self._top and self._holder == self._top then self._top.Visible = true end
	local d = new("Frame", {
		Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = C.Stroke, BackgroundTransparency = .3, BorderSizePixel = 0,
		LayoutOrder = self._order, Parent = self._holder,
	})
	return {Destroy = function() d:Destroy() end}
end

--------------------------------------------------------------------- SECTION
-- Trên Tab: card có chấm + tiêu đề IN HOA, xếp vào cột trái/phải (xen kẽ, hoặc chọn bằng Side = "Left"|"Right")
-- Trong Section: nhóm con (không khung)
-- local s = Tab:Section({Title = "Main", Side = "Left", Collapsible = false}); s:Toggle({...})
function Elements:Section(o)
	if type(o) == "string" then o = {Title = o} end
	o = o or {}
	local card = self._cols ~= nil
	local parent, order
	if card then
		local side = tostring(o.Side or o.Column or ""):lower()
		local idx
		if side == "left" or side == "l" or side == "1" then idx = 1
		elseif side == "right" or side == "r" or side == "2" then idx = 2
		else
			self._secN = self._secN + 1
			idx = (self._secN - 1) % 2 + 1
		end
		self._colOrder[idx] = self._colOrder[idx] + 1
		parent, order = self._cols[idx], self._colOrder[idx]
	else
		self._order = self._order + 1
		parent, order = self._holder, self._order
	end

	local box = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = C.Panel,
		BackgroundTransparency = card and 0 or 1, BorderSizePixel = 0, LayoutOrder = order, Parent = parent,
	}, card and {corner(9), padding(10), list(8)} or {list(6)})
	if card then
		local bs = stroke(C.Stroke, 1); bs.Parent = box
	end

	local collapsible = o.Collapsible == true
	local head = new(collapsible and "TextButton" or "Frame", {
		Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, LayoutOrder = 1, Parent = box,
	})
	if collapsible then head.Text = ""; head.AutoButtonColor = false end
	new("Frame", {
		AnchorPoint = Vector2.new(0, .5), Position = UDim2.new(0, 1, .5, 0), Size = UDim2.fromOffset(5, 5),
		BackgroundColor3 = C.White, BorderSizePixel = 0, Parent = head,
	}, {pill()})
	local hl = label(string.upper(T(o)), 10, C.Text, F.Bold)
	hl.Position = UDim2.fromOffset(14, 0); hl.Size = UDim2.new(1, -30, 1, 0); hl.Parent = head
	head.Visible = T(o) ~= ""
	local arrow
	if collapsible then
		arrow = Icon("chevron-down", head, 12, C.Sub)
		arrow.Root.AnchorPoint = Vector2.new(1, .5); arrow.Root.Position = UDim2.new(1, -1, .5, 0)
	end

	local content = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 2, Parent = box,
	}, {list(6)})

	local sec = setmetatable({_win = self._win, _page = self._page, _holder = content, _order = 0}, SectionC)
	local opened = o.Opened ~= false
	local function apply(anim)
		content.Visible = opened
		if arrow then
			if anim then tw(arrow.Root, {Rotation = opened and 0 or -90}, .2)
			else arrow.Root.Rotation = opened and 0 or -90 end
		end
	end
	apply(false)
	function sec:Open() opened = true; apply(true) end
	function sec:Close() opened = false; apply(true) end
	function sec:Collapse() opened = not opened; apply(true) end
	function sec:SetTitle(t) hl.Text = string.upper(tostring(t)); head.Visible = tostring(t) ~= "" end
	function sec:Destroy() box:Destroy() end
	if collapsible then
		head.MouseButton1Click:Connect(function() opened = not opened; apply(true) end)
	end
	return sec
end
-- gộp Elements vào Tab và Section
for k, v in pairs(Elements) do
	TabC[k] = v
	SectionC[k] = v
end

--------------------------------------------------------------------- WINDOW
function Window:_track(conn) table.insert(self._conns, conn); return conn end

function UI:CreateWindow(cfg)
	cfg = cfg or {}
	-- chờ Lucide tải xong (tối đa 4s) để icon hiện ngay, không bị "nhảy"
	local t0 = os.clock()
	lucideInit()
	while LucideState == "loading" and os.clock() - t0 < 4 do task.wait() end

	local self = setmetatable({
		Tabs = {}, Flags = {}, Current = nil, Open = false, Maximized = false,
		Folder = tostring(cfg.Folder or "RyzenHub"), _conns = {},
		_token = 0, _vis = 0, _pending = {}, _holding = false, _wasMin = false,
		_imode = "idle", _dotTok = 0, _amp = 0.6, _waves = {}, _userScale = cfg.Scale or 1,
		_notifyState = cfg.StateNotify ~= false,
	}, Window)

	local sz = cfg.Size
	if typeof(sz) == "UDim2" then sz = Vector2.new(sz.X.Offset, sz.Y.Offset) end
	if typeof(sz) ~= "Vector2" then sz = DEF_SIZE end
	self._size = Vector2.new(math.max(sz.X, MIN_SIZE.X), math.max(sz.Y, MIN_SIZE.Y))
	self._fit = fitScale(self._size, self._userScale)
	self._key = keyOf(cfg.ToggleKey or cfg.Key) or Enum.KeyCode.RightControl
	local brand = string.upper(tostring(cfg.Title or "Hub"))

	local pg = lp:WaitForChild("PlayerGui")
	local old = pg:FindFirstChild("HubUI")
	if old then old:Destroy() end
	local gui = new("ScreenGui", {
		Name = "HubUI", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 999,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	gui.Parent = pg
	self.Gui = gui
	UI._active = self

	-- vòng lặp chung: xoay gradient + sóng nhạc
	local clock = 0
	self:_track(RunService.Heartbeat:Connect(function(dt)
		clock = clock + dt
		for g, speed in pairs(Spin) do
			if g.Parent then g.Rotation = (g.Rotation + speed * dt) % 360 else Spin[g] = nil end
		end
		if self._imode == "idle" then
			self._amp = self._amp + ((self.Open and 1 or 0.6) - self._amp) * math.min(1, dt * 4)
			for _, w in ipairs(self._waves) do
				local v = (math.sin(clock * w.s + w.p) + math.sin(clock * w.s * 0.47 + w.p * 1.9)) * 0.25 + 0.5
				w.f.Size = UDim2.fromOffset(3, w.min + (w.max - w.min) * v * self._amp)
			end
		end
	end))
	gui.Destroying:Connect(function()
		for _, c in ipairs(self._conns) do pcall(function() c:Disconnect() end) end
		if UI._active == self then UI._active = nil end
	end)

	local footH = (cfg.User == false) and 0 or FOOT_H
	local TABBAR_Y = TITLE_H + 8
	local CONTENT_Y = TABBAR_Y + TABBAR_H + 8

	---------------------------------------------------------------- CỬA SỔ CHÍNH
	local main = new("Frame", {
		Name = "Main", AnchorPoint = Vector2.new(.5, 0), Position = UDim2.new(.5, 0, 0, TOP),
		Size = UDim2.fromOffset(self._size.X, self._size.Y), BackgroundTransparency = 1, Visible = false, Parent = gui,
	})
	local scale = new("UIScale", {Scale = self._fit, Parent = main})

	local body = new("CanvasGroup", {
		Name = "Body", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = main,
	}, {corner(9)})
	local bg = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.White, BorderSizePixel = 0, Parent = body})
	grad(bg, C.Bg1, C.Bg2, 90)

	-- viền ngoài mảnh, tĩnh (như ảnh)
	local rim = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 10, Parent = main}, {corner(9)})
	local rimStroke = new("UIStroke", {Thickness = 1.2, Color = C.Stroke2, Transparency = 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = rim})

	self.Main, self._scale, self._body, self._rimStroke, self._pos = main, scale, body, rimStroke, main.Position

	---------------------------------------------------------------- THANH TIÊU ĐỀ
	local bar = new("Frame", {Name = "TitleBar", Size = UDim2.new(1, 0, 0, TITLE_H), BackgroundColor3 = C.Panel, BorderSizePixel = 0, ZIndex = 3, Parent = body})
	new("Frame", {
		Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = C.Stroke,
		BorderSizePixel = 0, ZIndex = 4, Parent = bar,
	})
	local logo = new("Frame", {
		Size = UDim2.fromOffset(26, 26), Position = UDim2.fromOffset(12, (TITLE_H - 26) / 2), BackgroundColor3 = C.Item,
		BorderSizePixel = 0, ZIndex = 4, Parent = bar,
	}, {corner(7)})
	local lgs = stroke(C.Stroke2, 1); lgs.Parent = logo
	self._logo = logo

	local tl = new("Frame", {
		Size = UDim2.new(1, -140, 1, 0), Position = UDim2.fromOffset(48, 0), BackgroundTransparency = 1, ZIndex = 4, Parent = bar,
	}, {new("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 2),
		VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
	})})
	local title = label(brand, 10, C.Text, F.Brand)
	title.Size = UDim2.new(1, 0, 0, 13); title.ZIndex = 4; title.LayoutOrder = 1; title.Parent = tl
	local sub = label(tostring(cfg.Author or cfg.Subtitle or ""), 9.5, C.Sub)
	sub.Size = UDim2.new(1, 0, 0, 11); sub.ZIndex = 4; sub.LayoutOrder = 2
	sub.Visible = sub.Text ~= ""; sub.Parent = tl
	self._title, self._sub = title, sub

	local function control(order, iconName, isClose, onClick)
		local b = new("TextButton", {
			AnchorPoint = Vector2.new(1, .5), Size = UDim2.fromOffset(26, 26),
			Position = UDim2.new(1, -(10 + 30 * (3 - order)), .5, 0),
			BackgroundColor3 = C.White, BackgroundTransparency = 1, AutoButtonColor = false, Text = "", ZIndex = 5, Parent = bar,
		}, {corner(6)})
		local ico
		local ctl = {}
		local function mk(n)
			if ico then ico.Destroy() end
			ico = Icon(n, b, 13, C.Text)
			ico.Root.AnchorPoint = Vector2.new(.5, .5); ico.Root.Position = UDim2.fromScale(.5, .5); ico.Root.ZIndex = 6
		end
		mk(iconName)
		b.MouseEnter:Connect(function()
			tw(b, {BackgroundTransparency = isClose and 0 or .9}, .15)
			if isClose then ico.SetColor(C.Black) end
		end)
		b.MouseLeave:Connect(function()
			tw(b, {BackgroundTransparency = 1}, .15)
			ico.SetColor(C.Text)
		end)
		b.MouseButton1Click:Connect(onClick)
		function ctl.SetIcon(n) mk(n) end
		return ctl
	end
	control(1, "minus", false, function() self:SetVisible(false, "min") end)
	self._maxCtl = control(2, "square", false, function() self:ToggleMax() end)
	control(3, "x", true, function() self:SetVisible(false); if self._onClose then fire(self._onClose) end end)

	-- kéo cửa sổ
	-- chỉ theo đúng ngón tay/chuột đang kéo thanh tiêu đề (không bị ngón khác như joystick làm lệch), và không cho kéo ra khỏi màn hình
	local dragging, dragInput, dragStart, startPos
	bar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging, dragInput, dragStart, startPos = true, i, i.Position, main.Position
			i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)
		end
	end)
	self:_track(UIS.InputChanged:Connect(function(i)
		if not dragging then return end
		local same = (i == dragInput) or (dragInput.UserInputType == Enum.UserInputType.MouseButton1 and i.UserInputType == Enum.UserInputType.MouseMovement)
		if not same then return end
		local vp = viewport()
		local d = i.Position - dragStart
		local cx = math.clamp(vp.X * startPos.X.Scale + startPos.X.Offset + d.X, 60, vp.X - 60)
		local oy = math.clamp(startPos.Y.Offset + d.Y, 0, vp.Y - 40)
		main.Position = UDim2.new(startPos.X.Scale, cx - vp.X * startPos.X.Scale, startPos.Y.Scale, oy)
		self._pos = main.Position
	end))

	---------------------------------------------------------------- THANH TAB NGANG (cuộn ngang được)
	local tabBox = new("Frame", {
		Name = "TabBar", Position = UDim2.fromOffset(10, TABBAR_Y), Size = UDim2.new(1, -20, 0, TABBAR_H),
		BackgroundColor3 = C.Panel, BorderSizePixel = 0, ZIndex = 2, Parent = body,
	}, {corner(9)})
	local tbs = stroke(C.Stroke, 1); tbs.Parent = tabBox
	local tabList = new("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0,
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.X,
		ScrollingDirection = Enum.ScrollingDirection.X, ClipsDescendants = true, ZIndex = 3, Parent = tabBox,
	}, {
		new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder}),
		new("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4)}),
	})
	tabList.InputChanged:Connect(function(i) -- lăn chuột = cuộn ngang
		if i.UserInputType == Enum.UserInputType.MouseWheel then
			tabList.CanvasPosition = Vector2.new(math.max(0, tabList.CanvasPosition.X - i.Position.Z * 48), 0)
		end
	end)
	self.TabList, self._tabBox = tabList, tabBox

	---------------------------------------------------------------- KHU NỘI DUNG
	self.Content = new("Frame", {
		Name = "Content", Size = UDim2.new(1, 0, 1, -(CONTENT_Y + footH)), Position = UDim2.fromOffset(0, CONTENT_Y),
		BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 2, Parent = body,
	})

	---------------------------------------------------------------- THANH CHÂN (chấm + tên người chơi)
	local prof = new("Frame", {
		Name = "Footer", Size = UDim2.new(1, 0, 0, math.max(footH, 1)), Position = UDim2.new(0, 0, 1, -math.max(footH, 1)),
		BackgroundColor3 = C.Panel, BorderSizePixel = 0, ZIndex = 3, Parent = body,
	})
	new("Frame", {Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = C.Stroke, BorderSizePixel = 0, ZIndex = 4, Parent = prof})
	new("Frame", {
		AnchorPoint = Vector2.new(0, .5), Position = UDim2.new(0, 14, .5, 0), Size = UDim2.fromOffset(5, 5),
		BackgroundColor3 = C.White, BorderSizePixel = 0, ZIndex = 4, Parent = prof,
	}, {pill()})
	local pn = label(tostring(cfg.Footer or lp.Name), 9.5, C.Sub)
	pn.Position = UDim2.fromOffset(27, 0); pn.Size = UDim2.new(1, -80, 1, 0); pn.ZIndex = 4; pn.Parent = prof
	self._foot, self._profile = pn, prof
	prof.Visible = footH > 0

	---------------------------------------------------------------- GÓC ĐỔI KÍCH THƯỚC
	local rsState
	local gsz = COMPACT and 30 or 22
	local grip = new("Frame", {
		Name = "ResizeGrip", AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -1, 1, -1),
		Size = UDim2.fromOffset(gsz, gsz), BackgroundTransparency = 1, Active = true, ZIndex = 20, Parent = body,
	})
	local gi = Icon("move-diagonal-2", grip, 11, C.Sub)
	gi.Root.AnchorPoint = Vector2.new(1, 1); gi.Root.Position = UDim2.new(1, -5, 1, -5); gi.Root.ZIndex = 21
	self._grip = grip
	grip.Visible = cfg.Resizable ~= false
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
	self:_track(UIS.InputChanged:Connect(function(i)
		if not rsState then return end
		if i.UserInputType ~= Enum.UserInputType.MouseMovement and i.UserInputType ~= Enum.UserInputType.Touch then return end
		local fit, vp, st = self._fit, viewport(), rsState
		local d = i.Position - st.p
		local maxW = math.max(MIN_SIZE.X, (vp.X - 8 - st.left) / fit)
		local maxH = math.max(MIN_SIZE.Y, (vp.Y - 8 - st.top) / fit)
		local w = math.clamp(st.size.X + d.X / fit, MIN_SIZE.X, maxW)
		local h = math.clamp(st.size.Y + d.Y / fit, MIN_SIZE.Y, maxH)
		local a = Active[main]; if a and a.Size then a.Size:Cancel() end
		main.Size = UDim2.fromOffset(w, h)
		main.Position = UDim2.new(st.pos.X.Scale, st.pos.X.Offset + (w - st.size.X) * fit / 2, st.pos.Y.Scale, st.pos.Y.Offset)
		self._pos = main.Position
		self._size = Vector2.new(w, h); self._userSize = self._size
	end))
	main:GetPropertyChangedSignal("Size"):Connect(function() self:_relayout() end)

	---------------------------------------------------------------- DYNAMIC ISLAND (tên + sóng nhạc + thông báo)
	local isl = new("Frame", {
		Name = "Island", AnchorPoint = Vector2.new(.5, 0), Position = UDim2.new(.5, 0, 0, ISL_TOP),
		Size = UDim2.fromOffset(IDLE.X, IDLE.Y), BackgroundTransparency = 1, ZIndex = 20, Parent = gui,
	})
	local islCorner = corner(IDLE.Y / 2); islCorner.Parent = isl
	local islStroke = new("UIStroke", {Thickness = 1.2, Color = C.White, Transparency = 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = isl})
	shine(islStroke, 80, 0.82)

	local islBody = new("CanvasGroup", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.Black, BorderSizePixel = 0, Parent = isl})
	local bodyCorner = corner(IDLE.Y / 2); bodyCorner.Parent = islBody

	local idleG = new("CanvasGroup", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = islBody})
	local idleC = new("Frame", {
		AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(IDLE.X, IDLE.Y),
		BackgroundTransparency = 1, Parent = idleG,
	}, {new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder,
	})})
	local itxt = label(brand, 10, C.White, F.Brand)
	itxt.AutomaticSize = Enum.AutomaticSize.X; itxt.Size = UDim2.new(0, 0, 1, 0); itxt.LayoutOrder = 1; itxt.Parent = idleC
	self._itxt = itxt

	local waveBox = new("Frame", {Size = UDim2.fromOffset(24, 16), BackgroundTransparency = 1, LayoutOrder = 2, Parent = idleC})
	local phases = {0, 1.7, 3.1, 4.4, 5.6}
	local speeds = {5.2, 6.6, 4.4, 7.1, 5.8}
	for n = 1, 5 do
		local f = new("Frame", {
			AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromOffset((n - 1) * 5.5 + 1.5, 8),
			Size = UDim2.fromOffset(3, 3), BackgroundColor3 = C.White, BorderSizePixel = 0, Parent = waveBox,
		}, {pill()})
		self._waves[n] = {f = f, p = phases[n], s = speeds[n], min = 3, max = 14}
	end

	local notiG = new("CanvasGroup", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, GroupTransparency = 1, Parent = islBody})
	local notiC = new("Frame", {
		AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(NOTI.X, NOTI.Y),
		BackgroundTransparency = 1, Parent = notiG,
	})
	local badge = new("Frame", {Size = UDim2.fromOffset(32, 32), Position = UDim2.fromOffset(10, 10), BackgroundColor3 = C.White, BorderSizePixel = 0, Parent = notiC}, {pill()})
	local nTitle = label("", 12, C.White, F.Bold); nTitle.Position = UDim2.fromOffset(54, 8); nTitle.Size = UDim2.new(1, -66, 0, 18); nTitle.Parent = notiC
	local nText = label("", 10, C.Sub); nText.Position = UDim2.fromOffset(54, 27); nText.Size = UDim2.new(1, -66, 0, 16); nText.Parent = notiC

	local islHit = new("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 25, Parent = isl})

	self._isl, self._islCorner, self._bodyCorner, self._idleG, self._notiG = isl, islCorner, bodyCorner, idleG, notiG
	self._badge, self._nTitle, self._nText = badge, nTitle, nText

	islHit.Activated:Connect(function()
		if self._imode == "idle" then
			self:SetVisible(not self.Open)
		elseif not self._holding then
			self._token = self._token + 1
			self:_collapse()
		end
	end)
	islHit.MouseEnter:Connect(function()
		if self._imode == "idle" then tw(isl, {Size = UDim2.fromOffset(IDLE.X + 8, IDLE.Y + 2)}, .3, Enum.EasingStyle.Back) end
	end)
	islHit.MouseLeave:Connect(function()
		if self._imode == "idle" then tw(isl, {Size = UDim2.fromOffset(IDLE.X, IDLE.Y)}, .3, Enum.EasingStyle.Back) end
	end)

	self:_track(UIS.InputBegan:Connect(function(i, gp)
		if not gp and self._key and i.KeyCode == self._key then self:SetVisible(not self.Open) end
	end))

	-- co giãn theo màn hình
	local cam = workspace.CurrentCamera
	if cam then
		self:_track(cam:GetPropertyChangedSignal("ViewportSize"):Connect(function() self:_refit() end))
	end

	self:SetIcon(cfg.Icon or cfg.Logo or "zap")
	self:_relayout()
	self._onClose = cfg.OnClose

	if cfg.Hidden ~= true then
		task.defer(function() if not self.Open then self:SetVisible(true, nil, true) end end)
	end
	return self
end

--------------------------------------------------------------------- LAYOUT
function Window:_relayout()
	local w = self.Main.Size.X.Offset
	if self._sub then self._sub.Visible = self._sub.Text ~= "" and w >= 360 end
end

function Window:_refit()
	self._fit = fitScale(self._size, self._userScale)
	if self._userSize then
		local vp = viewport()
		self._size = Vector2.new(
			math.clamp(self._userSize.X, MIN_SIZE.X, math.max(MIN_SIZE.X, (vp.X - 16) / self._fit)),
			math.clamp(self._userSize.Y, MIN_SIZE.Y, math.max(MIN_SIZE.Y, (vp.Y - TOP - 8) / self._fit)))
	end
	if self.Open then tw(self._scale, {Scale = self._fit}, .3) end
	local sz = self.Maximized and self:_maxSize() or self._size
	tw(self.Main, {Size = UDim2.fromOffset(sz.X, sz.Y)}, .3)
end

--------------------------------------------------------------------- ĐẢO: chuyển trạng thái / nội dung
function Window:_mode(m)
	self._imode = m
	local s = (m == "idle") and IDLE or NOTI
	local r = (m == "idle") and (IDLE.Y / 2) or 26
	tw(self._isl, {Size = UDim2.fromOffset(s.X, s.Y)}, .55, Enum.EasingStyle.Back)
	tw(self._islCorner, {CornerRadius = UDim.new(0, r)}, .4)
	tw(self._bodyCorner, {CornerRadius = UDim.new(0, r)}, .4)
	tw(self._idleG, {GroupTransparency = (m == "idle") and 0 or 1}, .25)
	tw(self._notiG, {GroupTransparency = (m == "noti") and 0 or 1}, .3)
end

function Window:_setContent(d)
	self._dotTok = self._dotTok + 1
	for _, c in ipairs(self._badge:GetChildren()) do
		if c:IsA("Frame") or c:IsA("ImageLabel") then c:Destroy() end
	end

	if d.Loading then
		local spin = new("Frame", {
			AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(19, 19),
			BackgroundTransparency = 1, Parent = self._badge,
		}, {pill()})
		local st = new("UIStroke", {Color = C.Black, Thickness = 2.4, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = spin})
		local g = new("UIGradient", {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.45, 0.15),
				NumberSequenceKeypoint.new(0.62, 1), NumberSequenceKeypoint.new(1, 1),
			}), Parent = st,
		})
		Spin[g] = 420

		local base = (tostring(d.Title):gsub("%.+$", ""))
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
		self._nTitle.Text = tostring(d.Title)
		local ic = AnyIcon(d.Icon or KIND_ICON[d.Kind] or "info", self._badge, 18, C.Black)
		ic.Root.AnchorPoint = Vector2.new(.5, .5); ic.Root.Position = UDim2.fromScale(.5, .5)
		local s = new("UIScale", {Scale = 0.2, Parent = ic.Root})
		tw(s, {Scale = 1}, .5, Enum.EasingStyle.Back)
		local bs = self._badge:FindFirstChildOfClass("UIScale") or new("UIScale", {Parent = self._badge})
		bs.Scale = 0.8
		tw(bs, {Scale = 1}, .5, Enum.EasingStyle.Back)
	end
	self._nText.Text = tostring(d.Text or "")

	self._nTitle.Position = UDim2.fromOffset(54, 14); self._nTitle.TextTransparency = 1
	self._nText.Position = UDim2.fromOffset(54, 33); self._nText.TextTransparency = 1
	tw(self._nTitle, {Position = UDim2.fromOffset(54, 8), TextTransparency = 0}, .4)
	task.delay(.06, function()
		tw(self._nText, {Position = UDim2.fromOffset(54, 27), TextTransparency = 0}, .4)
	end)
end

function Window:_present(d)
	self._token = self._token + 1
	local tok = self._token
	self:_setContent(d)
	self:_mode("noti")
	if not d.Hold then
		task.delay(d.Duration or 3, function()
			if self._token == tok then self:_collapse() end
		end)
	end
end

function Window:_collapse()
	local nxt = table.remove(self._pending, 1)
	if nxt then
		self:_present(nxt)
	else
		self._dotTok = self._dotTok + 1
		self:_mode("idle")
	end
end

-- Window:Notify({Title = "...", Content = "...", Duration = 3, Icon = "bell", Kind = "success"|"error"|"info"})
function Window:Notify(o)
	o = o or {}
	local d = {
		Kind = o.Kind or "info", Title = o.Title or "Notice", Text = o.Content or o.Text or o.Desc or "",
		Duration = o.Duration or 3, Icon = o.Icon,
	}
	if self._holding then table.insert(self._pending, d) else self:_present(d) end
end
-- UI:Notify(...) dùng cửa sổ đang hoạt động (giống WindUI:Notify)
function UI:Notify(o)
	if UI._active then UI._active:Notify(o) end
end

-- local l = Window:Loading("Loading", "Please wait"); ... l:Success("Loaded", "Done") / l:Fail("Error", "...")
function Window:Loading(title, text)
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
function UI:Loading(title, text)
	if UI._active then return UI._active:Loading(title, text) end
	return {Success = function() end, Fail = function() end}
end

--------------------------------------------------------------------- MỞ / ĐÓNG / PHÓNG TO
function Window:SetVisible(v, how, silent)
	v = v and true or false
	if self.Open == v then return end
	self.Open = v
	self._vis = self._vis + 1
	local tok = self._vis
	local main, scale, body, rim = self.Main, self._scale, self._body, self._rimStroke
	local fit = self._fit
	local islandPos = UDim2.new(.5, 0, 0, ISL_TOP + 6)

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

	if not silent and self._notifyState then
		if v then
			self:Notify({Kind = "success", Title = "Interface opened", Text = "Press " .. keyName(self._key) .. " or tap the island to hide", Duration = 1.6})
		else
			self:Notify({Kind = "info", Title = "Interface hidden", Text = "Press " .. keyName(self._key) .. " or tap the island to open", Duration = 1.6})
		end
	end
end
function Window:Open() self:SetVisible(true) end
function Window:Close() self:SetVisible(false) end
function Window:Toggle() self:SetVisible(not self.Open) end

function Window:_maxSize()
	local vp = viewport()
	local w = math.max(self._size.X, math.min(820, (vp.X - 16) / self._fit))
	local h = math.max(self._size.Y, (vp.Y - TOP - 8) / self._fit)
	return Vector2.new(w, h)
end

function Window:ToggleMax()
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
function Window:SetTitle(t)
	t = string.upper(tostring(t or ""))
	self._title.Text = t; self._itxt.Text = t
end
function Window:SetAuthor(t)
	t = tostring(t or "")
	self._sub.Text = t; self:_relayout()
end
function Window:SetIcon(spec) -- tên Lucide hoặc id / rbxassetid / URL
	if self._logoIcon then self._logoIcon.Destroy(); self._logoIcon = nil end
	if not spec or spec == "" then return end
	local ic = AnyIcon(spec, self._logo, 15, C.White)
	ic.Root.AnchorPoint = Vector2.new(.5, .5); ic.Root.Position = UDim2.fromScale(.5, .5); ic.Root.ZIndex = 5
	self._logoIcon = ic
end
function Window:SetFooter(t) self._foot.Text = tostring(t or "") end
function Window:SetToggleKey(k) self._key = keyOf(k) or self._key end
function Window:SetScale(n)
	self._userScale = math.clamp(tonumber(n) or 1, .5, 1.5)
	self:_refit()
end
function Window:Center() -- đưa cửa sổ về giữa màn hình
	self._pos = UDim2.new(.5, 0, 0, TOP)
	tw(self.Main, {Position = self._pos}, .3)
end
function Window:OnClose(fn) self._onClose = fn end
function Window:Destroy() self.Gui:Destroy() end

--------------------------------------------------------------------- CONFIG (lưu / nạp giá trị các element có Flag)
function Window:SaveConfig(name)
	name = tostring(name or "default")
	if not (writefile and makefolder and isfolder) then return false end
	local data = {}
	for flag, el in pairs(self.Flags) do
		local ok, v = pcall(function() return el:Get() end)
		if ok and v ~= nil then data[flag] = v end
	end
	local ok = pcall(function()
		if not isfolder(self.Folder) then makefolder(self.Folder) end
		writefile(self.Folder .. "/" .. name .. ".json", HttpService:JSONEncode(data))
	end)
	return ok
end
function Window:LoadConfig(name)
	name = tostring(name or "default")
	if not (readfile and isfile) then return false end
	local path = self.Folder .. "/" .. name .. ".json"
	if not isfile(path) then return false end
	local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
	if not ok or type(data) ~= "table" then return false end
	for flag, v in pairs(data) do
		local el = self.Flags[flag]
		if el then pcall(function() el:Set(v) end) end
	end
	return true
end

--------------------------------------------------------------------- THANH TAB: Divider / Section (nhóm tab) / Tab
-- vạch dọc ngăn cách giữa các nhóm tab
function Window:Divider()
	local holder = new("Frame", {
		Size = UDim2.fromOffset(9, 26), BackgroundTransparency = 1, LayoutOrder = #self.TabList:GetChildren(), Parent = self.TabList,
	})
	new("Frame", {
		AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(1, 14),
		BackgroundColor3 = C.Stroke2, BorderSizePixel = 0, Parent = holder,
	})
end

function Window:_newTab(parent, cfg)
	if type(cfg) == "string" then cfg = {Title = cfg} end
	cfg = cfg or {}
	local name = tostring(cfg.Title or cfg.Name or "Tab")
	local tab = setmetatable({Window = self, Name = name, _win = self, _order = 0, _secN = 0, _colOrder = {0, 0}}, TabC)

	local btn = new("TextButton", {
		Size = UDim2.fromOffset(0, 26), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = C.ItemHov,
		BackgroundTransparency = 1, BorderSizePixel = 0, AutoButtonColor = false, Text = "",
		LayoutOrder = #parent:GetChildren(), Parent = parent,
	}, {corner(7)})
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 7), VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder, Parent = btn,
	})
	new("UIPadding", {PaddingLeft = UDim.new(0, 11), PaddingRight = UDim.new(0, 12), Parent = btn})
	local ic
	if cfg.Icon and cfg.Icon ~= "" then
		ic = AnyIcon(cfg.Icon, btn, 14, C.Sub); ic.Root.LayoutOrder = 1
	end
	local txt = label(name, 10.5, C.Sub, F.Semi)
	txt.AutomaticSize = Enum.AutomaticSize.X; txt.Size = UDim2.new(0, 0, 1, 0); txt.TextTruncate = Enum.TextTruncate.None
	txt.LayoutOrder = 2; txt.Parent = btn
	tab.Button, tab.Text, tab.Icon = btn, txt, ic

	btn.MouseEnter:Connect(function() if self.Current ~= tab then tw(btn, {BackgroundTransparency = .6}, .15) end end)
	btn.MouseLeave:Connect(function() if self.Current ~= tab then tw(btn, {BackgroundTransparency = 1}, .15) end end)

	-- trang nội dung: [Top: element thêm thẳng vào Tab, full rộng] + [2 cột chứa các Section]
	local page = new("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false,
		ScrollBarThickness = 2, ScrollBarImageColor3 = C.Sub, ScrollBarImageTransparency = .4,
		VerticalScrollBarInset = Enum.ScrollBarInset.None,
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = self.Content,
	}, {list(8), new("UIPadding", {PaddingTop = UDim.new(0, 0), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 14)})})
	local top = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Visible = false,
		LayoutOrder = 1, Parent = page,
	}, {list(6)})
	local colsF = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 2, Parent = page,
	}, {new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Top,
	})})
	local function col(n)
		return new("Frame", {
			Size = UDim2.new(.5, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
			LayoutOrder = n, Parent = colsF,
		}, {list(8)})
	end
	tab._cols = {col(1), col(2)}
	tab.Page, tab._page, tab._holder, tab._top = page, page, top, top

	btn.MouseButton1Click:Connect(function() self:Select(tab) end)
	table.insert(self.Tabs, tab)
	if not self.Current then self:Select(tab) end
	return tab
end

-- Window:Tab({Title = "Main", Icon = "house"})
function Window:Tab(cfg) return self:_newTab(self.TabList, cfg) end

-- Window:Section({Title = "Combat"}) -> section:Tab({...})  (nhóm tab: thêm vạch ngăn trên thanh tab)
function Window:Section(cfg)
	if type(cfg) == "string" then cfg = {Title = cfg} end
	local win = self
	if #self.Tabs > 0 then self:Divider() end
	local sec = {}
	function sec:Tab(c) return win:_newTab(win.TabList, c) end
	function sec:Open() end
	function sec:Close() end
	return sec
end

-- Window:SelectTab(1)  hoặc  Window:SelectTab(tab)
function Window:SelectTab(t)
	if type(t) == "number" then t = self.Tabs[t] end
	if t then self:Select(t) end
end

function Window:Select(tab)
	local prev = self.Current
	for _, t in ipairs(self.Tabs) do
		local on = (t == tab)
		tw(t.Button, {BackgroundTransparency = on and 0 or 1}, .22)
		tw(t.Text, {TextColor3 = on and C.White or C.Sub}, .22)
		if t.Icon then t.Icon.SetColor(on and C.White or C.Sub) end
		if on then
			if prev ~= tab then
				t.Page.CanvasPosition = Vector2.new(0, 0) -- luôn bắt đầu từ đầu trang, thấy đủ tiêu đề card
				t.Page.Position = UDim2.fromOffset(0, 12)
				t.Page.Visible = true
				tw(t.Page, {Position = UDim2.fromOffset(0, 0)}, .35)
			end
		else
			t.Page.Visible = false
		end
	end
	self.Current = tab
	if tab and tab.Button.Parent then -- cuộn thanh tab để tab đang chọn luôn nằm trong tầm nhìn
		task.defer(function()
			local tl = self.TabList
			local b = tab.Button
			if not (b.Parent and tl.Parent) then return end
			local left = b.AbsolutePosition.X - tl.AbsolutePosition.X + tl.CanvasPosition.X
			local right = left + b.AbsoluteSize.X
			local view = tl.AbsoluteSize.X
			local cp = tl.CanvasPosition.X
			if left < cp then cp = left - 6 elseif right > cp + view then cp = right - view + 6 end
			tw(tl, {CanvasPosition = Vector2.new(math.max(0, cp), 0)}, .25)
		end)
	end
end

function TabC:Select() self.Window:Select(self) end
function TabC:SetTitle(n) self.Name = tostring(n); self.Text.Text = tostring(n) end
function TabC:SetIcon(spec)
	if self.Icon then self.Icon.Destroy(); self.Icon = nil end
	if spec and spec ~= "" then
		self.Icon = AnyIcon(spec, self.Button, 14, self.Window.Current == self and C.White or C.Sub)
		self.Icon.Root.LayoutOrder = 1
	end
end

--------------------------------------------------------------------- EXAMPLE (bỏ comment để thử)
--[[
local UI = loadstring(game:HttpGet("URL_CUA_FILE_NAY"))()

local Window = UI:CreateWindow({
	Title = "Ryzen Hub",
	Author = "Blox Fruits",       -- dòng nhỏ dưới tên
	Icon = "zap",                 -- tên Lucide hoặc asset id / URL
	Folder = "RyzenHub",          -- thư mục lưu config
	Footer = nil,                 -- chữ ở thanh chân (mặc định: tên người chơi)
	Size = UDim2.fromOffset(580, 300),
	Scale = 1,                    -- nhỏ/to hơn: 0.85, 1, 1.1 ...
	ToggleKey = Enum.KeyCode.RightControl,
})

-- Tab nằm ngang trên thanh tab (cuộn ngang nếu nhiều)
local Home  = Window:Tab({Title = "Home", Icon = "house"})
local FS    = Window:Tab({Title = "Farm Settings", Icon = "settings"})
local Farm  = Window:Tab({Title = "Farm", Icon = "swords"})
local Boss  = Window:Tab({Title = "Bosses & Events", Icon = "target"})
local Multi = Window:Tab({Title = "Multi Farm", Icon = "layers"})
local Quest = Window:Tab({Title = "Quests", Icon = "flag"})

-- Section = card có chấm + tiêu đề; tự xếp xen kẽ trái/phải hoặc chọn Side
local Main = Farm:Section({Title = "Main", Side = "Left"})
Main:Toggle({Title = "Auto Farm Level", Value = true, Flag = "AutoFarm", Callback = function(v) print(v) end})

local BossS = Farm:Section({Title = "Boss", Side = "Left"})
BossS:Dropdown({Title = "Select Boss", Values = {"Gorilla King", "Bobby"}, Callback = function(v) print(v) end})
BossS:Toggle({Title = "Auto Farm Boss", Callback = function(v) print(v) end})

local Fish = Farm:Section({Title = "Fishing", Side = "Right"})
Fish:Dropdown({Title = "Select Bait", Values = {"Basic", "Good"}})
Fish:Toggle({Title = "Auto Buy Bait"})
Fish:Toggle({Title = "Auto Sell Fish"})
Fish:Toggle({Title = "Auto Fishing"})
-- Fish:Slider / :Input / :Keybind / :Button / :Paragraph dùng như cũ

-- Toggle dạng công tắc: Type = "Switch" (mặc định là ô vuông Checkbox)

UI:Notify({Title = "Ryzen Hub", Content = "Loaded successfully", Icon = "check", Duration = 3})
-- local l = UI:Loading("Loading", "Please wait"); task.wait(2); l:Success("Loaded", "Ready")
]]

return UI

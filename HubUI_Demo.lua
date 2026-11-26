-- LocalScript: đặt vào StarterPlayer > StarterPlayerScripts
-- UI kiểu Hub: thanh tab trên, 2 cột section, toggle = ô vuông bo góc (bật = có dấu tích)
-- Phím RightCtrl để ẩn/hiện

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

--------------------------------------------------------------------- THEME
local C = {
	Bg      = Color3.fromRGB(0, 0, 0),
	Panel   = Color3.fromRGB(10, 10, 10),
	Item    = Color3.fromRGB(20, 20, 20),
	Stroke  = Color3.fromRGB(55, 55, 55),
	Text    = Color3.fromRGB(255, 255, 255),
	Sub     = Color3.fromRGB(150, 150, 150),
	Accent  = Color3.fromRGB(255, 255, 255),
	Off     = Color3.fromRGB(30, 30, 30),
	OnText  = Color3.fromRGB(0, 0, 0), -- màu chữ/dấu tích trên nền trắng
}

local function new(class, props, children)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	for _, c in ipairs(children or {}) do c.Parent = o end
	return o
end
local function corner(r) return new("UICorner", {CornerRadius = UDim.new(0, r)}) end
local function stroke(col, t)
	return new("UIStroke", {Color = col or C.Stroke, Thickness = t or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
end
local function pad(p) 
	return new("UIPadding", {PaddingTop = UDim.new(0,p), PaddingBottom = UDim.new(0,p), PaddingLeft = UDim.new(0,p), PaddingRight = UDim.new(0,p)})
end
local function list(gap)
	return new("UIListLayout", {Padding = UDim.new(0, gap or 6), SortOrder = Enum.SortOrder.LayoutOrder})
end
local function label(text, size, color, bold)
	return new("TextLabel", {
		BackgroundTransparency = 1, Text = text, TextSize = size or 13,
		TextColor3 = color or C.Text, TextXAlignment = Enum.TextXAlignment.Left,
		Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
	})
end

--------------------------------------------------------------------- SWITCH (pill, trượt)
local TRACK_W, TRACK_H, KNOB_SIZE, PADDING = 56, 28, 24, 2
local MOVE_TIME, COLOR_TIME = 0.35, 0.35

local function pill() return new("UICorner", {CornerRadius = UDim.new(1, 0)}) end

local function CreateSwitch(parent, default, callback)
	local enabled = default and true or false
	local track = new("Frame", {
		Name = "Track", Size = UDim2.fromOffset(TRACK_W, TRACK_H),
		BackgroundColor3 = C.Off, BorderSizePixel = 0, Parent = parent,
	}, {pill(), stroke(C.Stroke, 1)})
	local knob = new("Frame", {
		Name = "Knob", Size = UDim2.fromOffset(KNOB_SIZE, KNOB_SIZE),
		AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = C.Accent,
		BorderSizePixel = 0, ZIndex = 2, Parent = track,
	}, {pill()})
	local hit = new("TextButton", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "",
		AutoButtonColor = false, ZIndex = 5, Parent = track,
	})

	local api = {Track = track}
	local kt, ct

	local function targets()
		return enabled and (TRACK_W - KNOB_SIZE - PADDING) or PADDING,
			enabled and C.Accent or C.Off,
			enabled and C.OnText or C.Accent
	end
	local x, tc, kc = targets()
	knob.Position = UDim2.new(0, x, 0.5, 0); track.BackgroundColor3 = tc; knob.BackgroundColor3 = kc

	function api.Set(v, silent)
		enabled = v and true or false
		if kt then kt:Cancel() end
		if ct then ct:Cancel() end
		local x, tc, kc = targets()
		kt = TweenService:Create(knob, TweenInfo.new(MOVE_TIME, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{Position = UDim2.new(0, x, 0.5, 0), BackgroundColor3 = kc})
		ct = TweenService:Create(track, TweenInfo.new(COLOR_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{BackgroundColor3 = tc})
		kt:Play(); ct:Play()
		if not silent and callback then task.spawn(callback, enabled) end
	end
	function api.Get() return enabled end

	hit.Activated:Connect(function() api.Set(not enabled) end)
	return api
end

--------------------------------------------------------------------- LIB
local UI = {}
UI.__index = UI

function UI.new(cfg)
	local self = setmetatable({Tabs = {}, Current = nil}, UI)

	local gui = new("ScreenGui", {Name = "HubUI", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 999})
	gui.Parent = lp:WaitForChild("PlayerGui")
	self.Gui = gui

	local main = new("Frame", {
		Visible = false, Size = UDim2.fromOffset(580, 390), Position = UDim2.new(0.5, -290, 0.5, -195),
		BackgroundColor3 = C.Bg, Parent = gui,
	}, {corner(12), stroke()})
	self.Main = main

	-- Title bar
	local bar = new("Frame", {Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1, Parent = main})
	local title = label(cfg.Title or "Hub", 14, C.Text, true)
	title.Position = UDim2.fromOffset(16, 0); title.Size = UDim2.new(0, 120, 1, 0); title.Parent = bar
	title.AutomaticSize = Enum.AutomaticSize.X
	local sub = label(cfg.Subtitle or "", 11, C.Sub)
	sub.Position = UDim2.new(0, 16 + title.TextBounds.X + 10, 0, 0); sub.Size = UDim2.new(0, 100, 1, 0); sub.Parent = bar
	title:GetPropertyChangedSignal("TextBounds"):Connect(function()
		sub.Position = UDim2.new(0, 16 + title.TextBounds.X + 10, 0, 0)
	end)

	local close = new("TextButton", {
		Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, -38, 0, 7), BackgroundTransparency = 1,
		Text = "✕", TextColor3 = C.Sub, TextSize = 14, Font = Enum.Font.GothamBold, Parent = bar,
	})
	close.MouseButton1Click:Connect(function() self:SetVisible(false) end)

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
		end
	end)

	-- Thanh tab
	local tabBar = new("ScrollingFrame", {
		Size = UDim2.new(1, -24, 0, 40), Position = UDim2.fromOffset(12, 46),
		BackgroundColor3 = C.Panel, BorderSizePixel = 0, ScrollBarThickness = 0,
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.X,
		ScrollingDirection = Enum.ScrollingDirection.X, Parent = main,
	}, {
		corner(10), stroke(),
		new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), VerticalAlignment = Enum.VerticalAlignment.Center}),
		new("UIPadding", {PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5)}),
	})
	self.TabBar = tabBar

	-- Vùng nội dung
	self.Content = new("Frame", {
		Size = UDim2.new(1, -24, 1, -102), Position = UDim2.fromOffset(12, 94),
		BackgroundTransparency = 1, ClipsDescendants = true, Parent = main,
	})

	-- Footer
	local foot = label(lp.Name, 11, C.Sub)
	foot.Position = UDim2.new(0, 16, 1, -22); foot.Size = UDim2.new(0.5, 0, 0, 18); foot.Parent = main
	local key = label("Right Ctrl", 10, C.Sub); key.TextXAlignment = Enum.TextXAlignment.Right
	key.Position = UDim2.new(1, -96, 1, -22); key.Size = UDim2.new(0, 80, 0, 18); key.Parent = main

	UIS.InputBegan:Connect(function(i, gp)
		if not gp and i.KeyCode == Enum.KeyCode.RightControl then self:SetVisible(not main.Visible) end
	end)

	-- Nút bật/tắt UI (switch trượt) góc trên trái
	local sw = new("Frame", {
		Size = UDim2.fromOffset(120, 44), Position = UDim2.fromOffset(16, 16),
		BackgroundColor3 = C.Bg, Parent = gui,
	}, {corner(12), stroke()})
	local sl = label("Menu", 13, C.Text, true)
	sl.Position = UDim2.fromOffset(14, 0); sl.Size = UDim2.new(0, 40, 1, 0); sl.Parent = sw
	self.Switch = CreateSwitch(sw, false, function(v) self:SetVisible(v, true) end)
	self.Switch.Track.Position = UDim2.new(1, -(TRACK_W + 10), 0.5, -TRACK_H / 2)

	-- Vùng chứa notify (góc dưới phải)
	self.NotifyHolder = new("Frame", {
		Size = UDim2.fromOffset(280, 400), AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -16, 1, -16), BackgroundTransparency = 1, Parent = gui,
	}, {new("UIListLayout", {
		Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
	})})

	return self
end

function UI:SetVisible(v, fromSwitch)
	self.Main.Visible = v
	if not fromSwitch then self.Switch.Set(v, true) end
end

--------------------------------------------------------------------- NOTIFY (cùng theme)
function UI:_card(title, text, icon)
	local wrap = new("Frame", {Size = UDim2.new(1, 0, 0, 60), BackgroundTransparency = 1, Parent = self.NotifyHolder})
	local card = new("Frame", {
		Size = UDim2.fromScale(1, 1), Position = UDim2.new(1, 300, 0, 0),
		BackgroundColor3 = C.Bg, Parent = wrap,
	}, {corner(10), stroke()})
	local ic = new("TextLabel", {
		Size = UDim2.fromOffset(44, 60), BackgroundTransparency = 1, Text = icon,
		TextColor3 = C.Text, TextSize = 22, Font = Enum.Font.GothamBold, Parent = card,
	})
	local t = label(title, 13, C.Text, true)
	t.Position = UDim2.fromOffset(46, 10); t.Size = UDim2.new(1, -56, 0, 18); t.Parent = card
	local d = label(text, 11, C.Sub)
	d.Position = UDim2.fromOffset(46, 30); d.Size = UDim2.new(1, -56, 0, 18); d.Parent = card
	TweenService:Create(card, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{Position = UDim2.new(0, 0, 0, 0)}):Play()
	return wrap, card, ic, t, d
end

local function dismiss(wrap, card, delay)
	task.delay(delay, function()
		if not card.Parent then return end
		local tw = TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
			{Position = UDim2.new(1, 300, 0, 0)})
		tw:Play(); tw.Completed:Wait(); wrap:Destroy()
	end)
end

-- Thông báo thường
function UI:Notify(o)
	local wrap, card = self:_card(o.Title or "Notice", o.Text or "", o.Icon or "i")
	dismiss(wrap, card, o.Duration or 3)
end

-- Thông báo loading -> :Success() / :Fail()
function UI:Loading(title, text)
	local wrap, card, ic, t, d = self:_card(title, text, "")
	local spin = new("Frame", {
		Size = UDim2.fromOffset(20, 20), Position = UDim2.fromOffset(12, 20),
		BackgroundTransparency = 1, Parent = card,
	}, {pill()})
	local st = stroke(C.Text, 2); st.Parent = spin
	local g = new("UIGradient", {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.75, 1), NumberSequenceKeypoint.new(1, 1),
		}), Parent = st,
	})
	local conn = RunService.RenderStepped:Connect(function(dt) g.Rotation = (g.Rotation + 360 * dt) % 360 end)

	local obj = {}
	local function finish(icon, nt, nd, dur)
		conn:Disconnect(); spin:Destroy()
		ic.Text = icon; t.Text = nt; d.Text = nd
		dismiss(wrap, card, dur or 3)
	end
	function obj:Success(nt, nd, dur) finish("✓", nt, nd, dur) end
	function obj:Fail(nt, nd, dur) finish("✕", nt, nd, dur) end
	return obj
end

function UI:AddTab(name, icon)
	local tab = {Window = self, Name = name}

	local btn = new("TextButton", {
		Size = UDim2.new(0, 0, 0, 30), AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = C.Item, BackgroundTransparency = 1, AutoButtonColor = false,
		Text = "", Parent = self.TabBar,
	}, {corner(8), new("UIPadding", {PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)})})
	local txt = label((icon and (icon .. "  ") or "") .. name, 12, C.Sub)
	txt.Size = UDim2.new(0, 0, 1, 0); txt.AutomaticSize = Enum.AutomaticSize.X; txt.Parent = btn
	tab.Button, tab.Text = btn, txt

	-- Trang: 2 cột
	local page = new("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, Parent = self.Content})
	local function column(x)
		return new("ScrollingFrame", {
			Size = UDim2.new(0.5, -4, 1, 0), Position = UDim2.new(x, x == 0 and 0 or 4, 0, 0),
			BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2,
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
	for _, t in ipairs(self.Tabs) do
		local on = (t == tab)
		t.Page.Visible = on
		TweenService:Create(t.Button, TweenInfo.new(0.15), {BackgroundTransparency = on and 0 or 1}):Play()
		t.Text.TextColor3 = on and C.Text or C.Sub
	end
	self.Current = tab
end

--------------------------------------------------------------------- TAB / SECTION
UI.TabMethods = {}

function UI.TabMethods.AddSection(tab, name, col)
	local sec = {}
	local box = new("Frame", {
		Size = UDim2.new(1, -2, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = C.Panel, Parent = tab.Columns[col or 1],
	}, {corner(10), stroke(), pad(10), list(6)})
	local head = label(name, 12, C.Text, true); head.Size = UDim2.new(1, 0, 0, 20); head.Parent = box
	sec.Box = box

	-- TOGGLE: ô vuông bo góc, bật = tích
	function sec:AddToggle(o)
		local state = o.Default or false
		local row = new("TextButton", {
			Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = C.Item, AutoButtonColor = false,
			Text = "", Parent = box,
		}, {corner(8), stroke()})
		local t = label(o.Name, 12, C.Text); t.Position = UDim2.fromOffset(12, 0); t.Size = UDim2.new(1, -50, 1, 0); t.Parent = row

		local cb = new("Frame", {
			Size = UDim2.fromOffset(22, 22), Position = UDim2.new(1, -34, 0.5, -11),
			BackgroundColor3 = C.Off, Parent = row,
		}, {corner(6)})
		local cbStroke = stroke(C.Stroke, 1); cbStroke.Parent = cb
		local tick = new("TextLabel", {
			Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "✓",
			TextColor3 = C.OnText, TextSize = 16, Font = Enum.Font.GothamBold,
			TextTransparency = 1, Parent = cb,
		})

		local api = {}
		local function render()
			TweenService:Create(cb, TweenInfo.new(0.15), {BackgroundColor3 = state and C.Accent or C.Off}):Play()
			TweenService:Create(tick, TweenInfo.new(0.15), {TextTransparency = state and 0 or 1}):Play()
			cbStroke.Color = state and C.Accent or C.Stroke
		end
		function api:Set(v, silent)
			state = v and true or false; render()
			if not silent and o.Callback then task.spawn(o.Callback, state) end
		end
		function api:Get() return state end
		row.MouseButton1Click:Connect(function() api:Set(not state) end)
		render()
		return api
	end

	-- DROPDOWN
	function sec:AddDropdown(o)
		local cur = o.Default or "None"
		local wrap = new("Frame", {
			Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1, Parent = box,
		}, {list(4)})
		local lab = label(o.Name, 11, C.Sub); lab.Size = UDim2.new(1, 0, 0, 16); lab.Parent = wrap
		local head = new("TextButton", {
			Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = C.Item, AutoButtonColor = false,
			Text = "", Parent = wrap,
		}, {corner(8), stroke()})
		local val = label(cur, 12, C.Sub); val.Position = UDim2.fromOffset(12, 0); val.Size = UDim2.new(1, -36, 1, 0); val.Parent = head
		local arrow = new("TextLabel", {
			Size = UDim2.fromOffset(24, 32), Position = UDim2.new(1, -28, 0, 0), BackgroundTransparency = 1,
			Text = "▾", TextColor3 = C.Sub, TextSize = 14, Font = Enum.Font.GothamBold, Parent = head,
		})
		local opts = new("Frame", {
			Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = C.Item, Visible = false, Parent = wrap,
		}, {corner(8), stroke(), pad(4), list(2)})

		for _, name in ipairs(o.Options or {}) do
			local b = new("TextButton", {
				Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, Text = name,
				TextColor3 = C.Text, TextSize = 12, Font = Enum.Font.Gotham, Parent = opts,
			}, {corner(6)})
			b.MouseEnter:Connect(function() b.BackgroundTransparency = 0.85; b.BackgroundColor3 = C.Accent end)
			b.MouseLeave:Connect(function() b.BackgroundTransparency = 1 end)
			b.MouseButton1Click:Connect(function()
				cur = name; val.Text = name; val.TextColor3 = C.Text
				opts.Visible = false; arrow.Text = "▾"
				if o.Callback then task.spawn(o.Callback, name) end
			end)
		end
		head.MouseButton1Click:Connect(function()
			opts.Visible = not opts.Visible
			arrow.Text = opts.Visible and "▴" or "▾"
		end)
		return {Get = function() return cur end}
	end

	-- NÚT BẤM
	function sec:AddButton(o)
		local b = new("TextButton", {
			Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = C.Accent, Text = o.Name,
			TextColor3 = C.OnText, TextSize = 12, Font = Enum.Font.GothamBold,
			AutoButtonColor = true, Parent = box,
		}, {corner(8)})
		b.MouseButton1Click:Connect(function() if o.Callback then task.spawn(o.Callback) end end)
	end

	-- Ô thống kê (như màn Home)
	function sec:AddStat(name, value)
		local f = new("Frame", {Size = UDim2.new(1, 0, 0, 52), BackgroundColor3 = C.Item, Parent = box}, {corner(8), stroke(), pad(10)})
		local a = label(name, 10, C.Sub); a.Size = UDim2.new(1, 0, 0, 14); a.Parent = f
		local b = label(value, 12, C.Text); b.Position = UDim2.fromOffset(0, 20); b.Size = UDim2.new(1, 0, 0, 16); b.Parent = f
		return function(v) b.Text = v end
	end

	return sec
end

--------------------------------------------------------------------- DEMO
local win = UI.new({Title = "Ryzen Hub", Subtitle = "Blox Fruits"})
local loading = win:Loading("Loading...", "Đang tải giao diện")

-- callback mẫu: báo notify khi bật/tắt
local function tg(name)
	return function(v) win:Notify({Title = name, Text = v and "Enabled" or "Disabled", Icon = v and "✓" or "✕", Duration = 2}) end
end

-- Home
local home = win:AddTab("Home", "⌂")
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
local fs = win:AddTab("Farm Settings", "≡")
local fsMain = fs:AddSection("Settings", 1)
fsMain:AddToggle({Name = "Fast Attack", Callback = tg("Fast Attack")})
fsMain:AddToggle({Name = "Bring Mob", Default = true, Callback = tg("Bring Mob")})

-- Farm
local farm = win:AddTab("Farm", "⚔")
local main = farm:AddSection("Main", 1)
main:AddToggle({Name = "Auto Farm Level", Default = true, Callback = tg("Auto Farm Level")})

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
	win:Notify({Title = "Test", Text = "Notify hoạt động bình thường", Duration = 3})
end})

for _, n in ipairs({"Bosses & Events", "Multi Farm", "Quests"}) do
	local t = win:AddTab(n)
	t:AddSection(n, 1):AddToggle({Name = "Demo " .. n, Callback = tg(n)})
end

win:Select(farm)

-- Giả lập thời gian tải rồi báo thành công + hiện UI
task.wait(1.8)
loading:Success("Loaded successfully", "Giao diện đã sẵn sàng", 3)
win:SetVisible(true)

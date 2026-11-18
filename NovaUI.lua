--[[
    NOVA UI LIBRARY  |  Roblox Luau
    - Giao dien ngang, den / trang
    - Header chia doi: Logo (trang) | Ten (den)
    - Tab: them / xoa bang code
    - Toggle: o vuong bo goc, bat thi hien dau tich
    - Notify: goc duoi ben phai MAN HINH (ngoai UI)
    - Nut bat/tat UI: vuong bo goc, keo di duoc
    - Keo UI bang header, keo to/nho bang 4 goc
    - Phim tat: RightShift
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Library = {}

---------------------------------------------------------------------
-- THEME
---------------------------------------------------------------------
local Theme = {
	Black = Color3.fromRGB(10, 10, 10),
	Sidebar = Color3.fromRGB(18, 18, 18),
	Content = Color3.fromRGB(13, 13, 13),
	Item = Color3.fromRGB(28, 28, 28),
	ItemHover = Color3.fromRGB(38, 38, 38),
	Stroke = Color3.fromRGB(55, 55, 55),
	White = Color3.fromRGB(255, 255, 255),
	Gray = Color3.fromRGB(150, 150, 150),
}

---------------------------------------------------------------------
-- HELPERS
---------------------------------------------------------------------
local function Create(class, props, children)
	local obj = Instance.new(class)
	local parent
	for k, v in pairs(props or {}) do
		if k == "Parent" then
			parent = v
		else
			obj[k] = v
		end
	end
	for _, c in ipairs(children or {}) do
		c.Parent = obj
	end
	if parent then
		obj.Parent = parent
	end
	return obj
end

local function Tween(obj, time, props, style, dir)
	local t = TweenService:Create(
		obj,
		TweenInfo.new(time, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
		props
	)
	t:Play()
	return t
end

local function Corner(obj, r)
	return Create("UICorner", { CornerRadius = UDim.new(0, r), Parent = obj })
end

local function Stroke(obj, color, thickness)
	return Create("UIStroke", {
		Color = color or Theme.Stroke,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = obj,
	})
end

local function Mount(gui)
	local ok = pcall(function()
		if gethui then
			gui.Parent = gethui()
		else
			gui.Parent = CoreGui
		end
	end)
	if not ok or not gui.Parent then
		gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	end
end

local function IsPointer(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
end

local function IsMove(input)
	return input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
end

-- Keo doi tuong. onClick chi chay khi nhan ma khong keo.
local function MakeDraggable(handle, target, onClick)
	local dragging, moved = false, false
	local startMouse, startPos

	handle.InputBegan:Connect(function(input)
		if IsPointer(input) then
			dragging, moved = true, false
			startMouse = input.Position
			startPos = target.Position
			local conn
			conn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					conn:Disconnect()
					if not moved and onClick then
						onClick()
					end
				end
			end)
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and IsMove(input) then
			local d = input.Position - startMouse
			if d.Magnitude > 5 then
				moved = true
			end
			if moved then
				target.Position = UDim2.new(
					startPos.X.Scale, startPos.X.Offset + d.X,
					startPos.Y.Scale, startPos.Y.Offset + d.Y
				)
			end
		end
	end)
end

---------------------------------------------------------------------
-- NOTIFY (goc duoi ben phai man hinh, nam ngoai UI chinh)
---------------------------------------------------------------------
local NotifyGui, NotifyHolder
local notifyOrder = 0

local function EnsureNotify()
	if NotifyGui and NotifyGui.Parent then
		return
	end
	NotifyGui = Create("ScreenGui", {
		Name = "NovaNotify",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 200,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	Mount(NotifyGui)
	NotifyHolder = Create("Frame", {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -16, 1, -16),
		Size = UDim2.fromOffset(280, 500),
		BackgroundTransparency = 1,
		Parent = NotifyGui,
	})
	Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Parent = NotifyHolder,
	})
end

local NotifyIcons = { Info = "i", Success = "OK", Warning = "!", Error = "x" }

function Library:Notify(o)
	o = o or {}
	EnsureNotify()
	notifyOrder += 1
	local duration = o.Duration or 4

	local wrap = Create("Frame", {
		Size = UDim2.fromOffset(280, 72),
		BackgroundTransparency = 1,
		LayoutOrder = notifyOrder,
		Parent = NotifyHolder,
	})
	local card = Create("Frame", {
		Position = UDim2.new(1, 60, 0, 0),
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Black,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = wrap,
	})
	Corner(card, 10)
	Stroke(card, Theme.White, 1)

	local icon = Create("Frame", {
		Position = UDim2.fromOffset(12, 14),
		Size = UDim2.fromOffset(36, 36),
		BackgroundColor3 = Theme.White,
		BorderSizePixel = 0,
		Parent = card,
	})
	Corner(icon, 9)
	Create("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = NotifyIcons[o.Type or "Info"] or "i",
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		TextColor3 = Theme.Black,
		Parent = icon,
	})
	Create("TextLabel", {
		Position = UDim2.fromOffset(60, 10),
		Size = UDim2.new(1, -72, 0, 18),
		BackgroundTransparency = 1,
		Text = o.Title or "Notification",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Theme.White,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card,
	})
	Create("TextLabel", {
		Position = UDim2.fromOffset(60, 29),
		Size = UDim2.new(1, -72, 0, 34),
		BackgroundTransparency = 1,
		Text = o.Content or "",
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = Theme.Gray,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = card,
	})
	local bar = Create("Frame", {
		Position = UDim2.new(0, 0, 1, -3),
		Size = UDim2.new(1, 0, 0, 3),
		BackgroundColor3 = Theme.White,
		BorderSizePixel = 0,
		Parent = card,
	})
	local clickArea = Create("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		Parent = card,
	})

	local closed = false
	local function close()
		if closed then return end
		closed = true
		Tween(card, 0.35, { Position = UDim2.new(1, 60, 0, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		task.wait(0.35)
		Tween(wrap, 0.25, { Size = UDim2.fromOffset(280, 0) })
		task.wait(0.25)
		wrap:Destroy()
	end

	clickArea.MouseButton1Click:Connect(function()
		task.spawn(close)
	end)

	Tween(card, 0.5, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Back)
	Tween(bar, duration, { Size = UDim2.new(0, 0, 0, 3) }, Enum.EasingStyle.Linear)
	task.delay(duration, function()
		task.spawn(close)
	end)
end

---------------------------------------------------------------------
-- WINDOW
---------------------------------------------------------------------
function Library:CreateWindow(cfg)
	cfg = cfg or {}
	local Name = cfg.Name or "NOVA HUB"
	local Logo = cfg.Logo or string.sub(Name, 1, 1)
	local Subtitle = cfg.Subtitle or ""
	local StartSize = cfg.Size or Vector2.new(520, 330)
	local ToggleKey = cfg.ToggleKey or Enum.KeyCode.RightShift
	local MinSize, MaxSize = Vector2.new(420, 260), Vector2.new(900, 620)

	-- don dep UI cu
	pcall(function()
		local p = gethui and gethui() or CoreGui
		local old = p:FindFirstChild("NovaUI")
		if old then old:Destroy() end
	end)

	local Window = { Tabs = {}, Current = nil, Visible = false }

	local Screen = Create("ScreenGui", {
		Name = "NovaUI",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 100,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	Mount(Screen)

	-- MAIN -----------------------------------------------------------
	local Main = Create("CanvasGroup", {
		Name = "Main",
		Position = UDim2.new(0.5, -StartSize.X / 2, 0.5, -StartSize.Y / 2),
		Size = UDim2.fromOffset(StartSize.X, StartSize.Y),
		BackgroundColor3 = Theme.Black,
		BorderSizePixel = 0,
		Visible = false,
		GroupTransparency = 1,
		Parent = Screen,
	})
	Corner(Main, 12)
	Stroke(Main, Theme.Stroke, 1)

	-- HEADER (chia doi: logo trang | ten den) -------------------------
	local Header = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundColor3 = Theme.Black,
		BorderSizePixel = 0,
		Parent = Main,
	})
	local LogoBox = Create("Frame", {
		Size = UDim2.fromOffset(46, 42),
		BackgroundColor3 = Theme.White,
		BorderSizePixel = 0,
		Parent = Header,
	})
	if tostring(Logo):find("rbxassetid") or tonumber(Logo) then
		local id = tonumber(Logo) and ("rbxassetid://" .. Logo) or Logo
		Create("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(26, 26),
			BackgroundTransparency = 1,
			Image = id,
			ImageColor3 = Theme.Black,
			Parent = LogoBox,
		})
	else
		Create("TextLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = tostring(Logo),
			Font = Enum.Font.GothamBlack,
			TextSize = 22,
			TextColor3 = Theme.Black,
			Parent = LogoBox,
		})
	end
	Create("TextLabel", {
		Position = UDim2.fromOffset(60, 0),
		Size = UDim2.new(1, -120, 1, 0),
		BackgroundTransparency = 1,
		Text = Name .. (Subtitle ~= "" and ("  <font color='rgb(150,150,150)' size='11'>" .. Subtitle .. "</font>") or ""),
		RichText = true,
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		TextColor3 = Theme.White,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = Header,
	})
	Create("Frame", { -- duong ke duoi header
		Position = UDim2.new(0, 0, 1, -1),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Theme.White,
		BackgroundTransparency = 0.85,
		BorderSizePixel = 0,
		Parent = Header,
	})

	local CloseBtn = Create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(26, 26),
		BackgroundColor3 = Theme.Item,
		AutoButtonColor = false,
		Text = "-",
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		TextColor3 = Theme.White,
		Parent = Header,
	})
	Corner(CloseBtn, 7)
	CloseBtn.MouseEnter:Connect(function()
		Tween(CloseBtn, 0.2, { BackgroundColor3 = Theme.White, TextColor3 = Theme.Black })
	end)
	CloseBtn.MouseLeave:Connect(function()
		Tween(CloseBtn, 0.2, { BackgroundColor3 = Theme.Item, TextColor3 = Theme.White })
	end)

	-- BODY -----------------------------------------------------------
	local Body = Create("Frame", {
		Position = UDim2.fromOffset(0, 42),
		Size = UDim2.new(1, 0, 1, -42),
		BackgroundTransparency = 1,
		Parent = Main,
	})
	local Sidebar = Create("Frame", {
		Size = UDim2.new(0, 130, 1, 0),
		BackgroundColor3 = Theme.Sidebar,
		BorderSizePixel = 0,
		Parent = Body,
	})
	Create("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0, 1, 1, 0),
		BackgroundColor3 = Theme.White,
		BackgroundTransparency = 0.9,
		BorderSizePixel = 0,
		Parent = Sidebar,
	})
	local TabList = Create("ScrollingFrame", {
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, -1, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = Sidebar,
	})
	Create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = TabList })
	Create("UIPadding", {
		PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
		Parent = TabList,
	})

	local Content = Create("Frame", {
		Position = UDim2.fromOffset(130, 0),
		Size = UDim2.new(1, -130, 1, 0),
		BackgroundColor3 = Theme.Content,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = Body,
	})

	-- DRAG WINDOW ----------------------------------------------------
	MakeDraggable(Header, Main)

	-- RESIZE O 4 GOC -------------------------------------------------
	local function MakeResize(handle, sx, sy)
		local resizing = false
		local sm, sSize, sPos
		handle.InputBegan:Connect(function(input)
			if IsPointer(input) then
				resizing = true
				sm = input.Position
				sSize = Main.AbsoluteSize
				sPos = Main.AbsolutePosition
				local conn
				conn = input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						resizing = false
						conn:Disconnect()
					end
				end)
			end
		end)
		UIS.InputChanged:Connect(function(input)
			if resizing and IsMove(input) then
				local d = input.Position - sm
				local w = math.clamp(sSize.X + sx * d.X, MinSize.X, MaxSize.X)
				local h = math.clamp(sSize.Y + sy * d.Y, MinSize.Y, MaxSize.Y)
				local px = sx < 0 and (sPos.X + (sSize.X - w)) or sPos.X
				local py = sy < 0 and (sPos.Y + (sSize.Y - h)) or sPos.Y
				Main.Size = UDim2.fromOffset(w, h)
				Main.Position = UDim2.fromOffset(px, py)
			end
		end)
	end

	local corners = {
		{ Vector2.new(0, 0), Vector2.new(0, 0), -1, -1 },
		{ Vector2.new(1, 0), Vector2.new(1, 0), 1, -1 },
		{ Vector2.new(0, 1), Vector2.new(0, 1), -1, 1 },
		{ Vector2.new(1, 1), Vector2.new(1, 1), 1, 1 },
	}
	for _, c in ipairs(corners) do
		local h = Create("Frame", {
			AnchorPoint = c[1],
			Position = UDim2.fromScale(c[2].X, c[2].Y),
			Size = UDim2.fromOffset(20, 20),
			BackgroundTransparency = 1,
			Active = true,
			ZIndex = 50,
			Parent = Main,
		})
		MakeResize(h, c[3], c[4])
	end
	-- dau hieu keo to o goc duoi phai
	Create("TextLabel", {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -3, 1, -1),
		Size = UDim2.fromOffset(14, 14),
		BackgroundTransparency = 1,
		Text = "◢",
		TextSize = 10,
		Font = Enum.Font.Gotham,
		TextColor3 = Theme.Gray,
		TextTransparency = 0.5,
		ZIndex = 49,
		Parent = Main,
	})

	-- SHOW / HIDE ----------------------------------------------------
	local busy = false
	function Window:SetVisible(state)
		if busy or state == self.Visible then return end
		busy = true
		self.Visible = state
		local target = Main.Position
		if state then
			Main.Visible = true
			Main.GroupTransparency = 1
			Main.Position = UDim2.new(target.X.Scale, target.X.Offset, target.Y.Scale, target.Y.Offset + 24)
			Tween(Main, 0.45, { Position = target, GroupTransparency = 0 }, Enum.EasingStyle.Back)
			task.delay(0.45, function() busy = false end)
		else
			Tween(Main, 0.3, {
				Position = UDim2.new(target.X.Scale, target.X.Offset, target.Y.Scale, target.Y.Offset + 24),
				GroupTransparency = 1,
			}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			task.delay(0.3, function()
				Main.Visible = false
				Main.Position = target
				busy = false
			end)
		end
	end
	function Window:Toggle()
		self:SetVisible(not self.Visible)
	end
	function Window:Notify(o)
		Library:Notify(o)
	end
	function Window:Destroy()
		Screen:Destroy()
	end

	CloseBtn.MouseButton1Click:Connect(function() Window:SetVisible(false) end)
	UIS.InputBegan:Connect(function(input, gp)
		if not gp and input.KeyCode == ToggleKey then
			Window:Toggle()
		end
	end)

	-- NUT BAT/TAT UI (vuong bo goc, keo duoc) --------------------------
	local Opener = Create("TextButton", {
		Name = "Opener",
		Position = UDim2.new(0, 20, 0.5, -23),
		Size = UDim2.fromOffset(46, 46),
		BackgroundColor3 = Theme.Black,
		AutoButtonColor = false,
		Text = "",
		Parent = Screen,
	})
	Corner(Opener, 12)
	local openerStroke = Stroke(Opener, Theme.White, 2)
	local openerIcon
	if tostring(Logo):find("rbxassetid") or tonumber(Logo) then
		openerIcon = Create("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(26, 26), BackgroundTransparency = 1,
			Image = tonumber(Logo) and ("rbxassetid://" .. Logo) or Logo,
			Parent = Opener,
		})
	else
		openerIcon = Create("TextLabel", {
			Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
			Text = tostring(Logo), Font = Enum.Font.GothamBlack, TextSize = 22,
			TextColor3 = Theme.White, Parent = Opener,
		})
	end
	Opener.MouseEnter:Connect(function()
		Tween(Opener, 0.2, { Size = UDim2.fromOffset(50, 50) }, Enum.EasingStyle.Back)
	end)
	Opener.MouseLeave:Connect(function()
		Tween(Opener, 0.2, { Size = UDim2.fromOffset(46, 46) })
	end)
	MakeDraggable(Opener, Opener, function()
		Tween(Opener, 0.1, { Size = UDim2.fromOffset(40, 40) })
		task.delay(0.1, function()
			Tween(Opener, 0.25, { Size = UDim2.fromOffset(46, 46) }, Enum.EasingStyle.Back)
		end)
		Window:Toggle()
	end)

	-----------------------------------------------------------------
	-- TAB SYSTEM
	-----------------------------------------------------------------
	local function Activate(tab)
		Tween(tab.Button, 0.25, { BackgroundTransparency = 0 })
		Tween(tab.Label, 0.25, { TextColor3 = Theme.Black })
		tab.Page.Visible = true
		tab.Page.Position = UDim2.fromOffset(0, 14)
		Tween(tab.Page, 0.35, { Position = UDim2.fromOffset(0, 0) })
	end
	local function Deactivate(tab)
		Tween(tab.Button, 0.25, { BackgroundTransparency = 1 })
		Tween(tab.Label, 0.25, { TextColor3 = Theme.Gray })
		tab.Page.Visible = false
	end
	local function Select(tab)
		if Window.Current == tab then return end
		if Window.Current then Deactivate(Window.Current) end
		Window.Current = tab
		Activate(tab)
	end

	local tabOrder = 0

	function Window:AddTab(name)
		tabOrder += 1
		local Tab = { Name = name }

		local btn = Create("TextButton", {
			Size = UDim2.new(1, 0, 0, 34),
			BackgroundColor3 = Theme.White,
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			Text = "",
			ClipsDescendants = true,
			LayoutOrder = tabOrder,
			Parent = TabList,
		})
		Corner(btn, 8)
		local label = Create("TextLabel", {
			Position = UDim2.fromOffset(12, 0),
			Size = UDim2.new(1, -16, 1, 0),
			BackgroundTransparency = 1,
			Text = name,
			Font = Enum.Font.GothamMedium,
			TextSize = 13,
			TextColor3 = Theme.Gray,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = btn,
		})
		btn.MouseEnter:Connect(function()
			if Window.Current ~= Tab then Tween(label, 0.2, { TextColor3 = Theme.White }) end
		end)
		btn.MouseLeave:Connect(function()
			if Window.Current ~= Tab then Tween(label, 0.2, { TextColor3 = Theme.Gray }) end
		end)

		local page = Create("ScrollingFrame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = Theme.White,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = false,
			Parent = Content,
		})
		Create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = page })
		Create("UIPadding", {
			PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 12), PaddingBottom = UDim.new(0, 10),
			Parent = page,
		})

		Tab.Button, Tab.Label, Tab.Page = btn, label, page
		table.insert(Window.Tabs, Tab)
		btn.MouseButton1Click:Connect(function() Select(Tab) end)

		-- hieu ung xuat hien
		btn.Size = UDim2.new(1, 0, 0, 0)
		Tween(btn, 0.35, { Size = UDim2.new(1, 0, 0, 34) }, Enum.EasingStyle.Back)

		if not Window.Current then Select(Tab) end

		-- xoa tab
		function Tab:Destroy()
			local idx = table.find(Window.Tabs, Tab)
			if idx then table.remove(Window.Tabs, idx) end
			local wasCurrent = Window.Current == Tab
			if wasCurrent then Window.Current = nil end
			page:Destroy()
			Tween(btn, 0.25, { Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1 })
			task.delay(0.26, function() btn:Destroy() end)
			if wasCurrent and Window.Tabs[1] then
				Select(Window.Tabs[math.clamp(idx or 1, 1, #Window.Tabs)])
			end
		end

		---------------------------------------------------------------
		-- ELEMENTS
		---------------------------------------------------------------
		local function MakeRow(height)
			local row = Create("Frame", {
				Size = UDim2.new(1, 0, 0, height),
				BackgroundColor3 = Theme.Item,
				BorderSizePixel = 0,
				Parent = page,
			})
			Corner(row, 8)
			Stroke(row, Theme.Stroke, 1)
			return row
		end
		local function Hover(row, btnObj)
			btnObj.MouseEnter:Connect(function() Tween(row, 0.2, { BackgroundColor3 = Theme.ItemHover }) end)
			btnObj.MouseLeave:Connect(function() Tween(row, 0.2, { BackgroundColor3 = Theme.Item }) end)
		end
		local function RowLabel(row, text, w)
			return Create("TextLabel", {
				Position = UDim2.fromOffset(12, 0),
				Size = UDim2.new(1, w or -24, 1, 0),
				BackgroundTransparency = 1,
				Text = text,
				Font = Enum.Font.GothamMedium,
				TextSize = 13,
				TextColor3 = Theme.White,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = row,
			})
		end

		function Tab:AddSection(text)
			return Create("TextLabel", {
				Size = UDim2.new(1, 0, 0, 20),
				BackgroundTransparency = 1,
				Text = string.upper(text),
				Font = Enum.Font.GothamBold,
				TextSize = 11,
				TextColor3 = Theme.Gray,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = page,
			})
		end

		function Tab:AddLabel(text)
			local row = MakeRow(34)
			local l = RowLabel(row, text)
			l.TextColor3 = Theme.Gray
			return { Set = function(_, t) l.Text = t end }
		end

		function Tab:AddButton(o)
			o = o or {}
			local row = MakeRow(38)
			local label = RowLabel(row, o.Name or "Button")
			label.Size = UDim2.new(1, -24, 1, 0)
			local b = Create("TextButton", {
				Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", Parent = row,
			})
			Hover(row, b)
			b.MouseButton1Click:Connect(function()
				Tween(row, 0.08, { BackgroundColor3 = Theme.White })
				Tween(label, 0.08, { TextColor3 = Theme.Black })
				task.delay(0.12, function()
					Tween(row, 0.3, { BackgroundColor3 = Theme.Item })
					Tween(label, 0.3, { TextColor3 = Theme.White })
				end)
				if o.Callback then task.spawn(pcall, o.Callback) end
			end)
		end

		function Tab:AddToggle(o)
			o = o or {}
			local state = false
			local row = MakeRow(38)
			RowLabel(row, o.Name or "Toggle", -56)

			local box = Create("Frame", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -10, 0.5, 0),
				Size = UDim2.fromOffset(24, 24),
				BackgroundColor3 = Theme.Black,
				BorderSizePixel = 0,
				Parent = row,
			})
			Corner(box, 7)
			Stroke(box, Theme.White, 1.5)

			local check = Create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(16, 16),
				BackgroundTransparency = 1,
				Parent = box,
			})
			local scale = Create("UIScale", { Scale = 0, Parent = check })
			-- dau tich ve bang 2 thanh xoay
			local arm1 = Create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromOffset(4.75, 9.75),
				Size = UDim2.fromOffset(2.5, 5.5),
				Rotation = -45,
				BackgroundColor3 = Theme.Black,
				BorderSizePixel = 0,
				Parent = check,
			})
			local arm2 = Create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromOffset(9.75, 8),
				Size = UDim2.fromOffset(2.5, 10.5),
				Rotation = 45,
				BackgroundColor3 = Theme.Black,
				BorderSizePixel = 0,
				Parent = check,
			})
			Corner(arm1, 1)
			Corner(arm2, 1)

			local function Set(v, silent, instant)
				state = v and true or false
				if instant then
					box.BackgroundColor3 = state and Theme.White or Theme.Black
					scale.Scale = state and 1 or 0
				else
					Tween(box, 0.25, { BackgroundColor3 = state and Theme.White or Theme.Black })
					Tween(scale, state and 0.4 or 0.2, { Scale = state and 1 or 0 },
						state and Enum.EasingStyle.Back or Enum.EasingStyle.Quint)
				end
				if not silent and o.Callback then
					task.spawn(pcall, o.Callback, state)
				end
			end

			local b = Create("TextButton", {
				Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", Parent = row,
			})
			Hover(row, b)
			b.MouseButton1Click:Connect(function() Set(not state) end)

			Set(o.Default or false, true, true)
			return {
				Set = function(_, v) Set(v) end,
				Get = function() return state end,
			}
		end

		function Tab:AddSlider(o)
			o = o or {}
			local min, max = o.Min or 0, o.Max or 100
			local inc = o.Increment or 1
			local value = o.Default or min

			local row = MakeRow(54)
			local label = RowLabel(row, o.Name or "Slider")
			label.Size = UDim2.new(1, -80, 0, 30)
			local valLabel = Create("TextLabel", {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -12, 0, 0),
				Size = UDim2.fromOffset(60, 30),
				BackgroundTransparency = 1,
				Text = tostring(value),
				Font = Enum.Font.GothamBold,
				TextSize = 13,
				TextColor3 = Theme.White,
				TextXAlignment = Enum.TextXAlignment.Right,
				Parent = row,
			})
			local track = Create("Frame", {
				Position = UDim2.new(0, 12, 1, -18),
				Size = UDim2.new(1, -24, 0, 6),
				BackgroundColor3 = Theme.Black,
				BorderSizePixel = 0,
				Parent = row,
			})
			Corner(track, 3)
			local fill = Create("Frame", {
				Size = UDim2.fromScale(0, 1),
				BackgroundColor3 = Theme.White,
				BorderSizePixel = 0,
				Parent = track,
			})
			Corner(fill, 3)
			local knob = Create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(1, 0.5),
				Size = UDim2.fromOffset(12, 12),
				BackgroundColor3 = Theme.White,
				BorderSizePixel = 0,
				Parent = fill,
			})
			Corner(knob, 6)

			local function SetValue(v, silent)
				v = math.clamp(v, min, max)
				v = math.floor((v - min) / inc + 0.5) * inc + min
				v = math.floor(v * 1000 + 0.5) / 1000
				value = v
				local a = (max == min) and 0 or (v - min) / (max - min)
				Tween(fill, 0.1, { Size = UDim2.fromScale(a, 1) })
				valLabel.Text = tostring(v)
				if not silent and o.Callback then
					task.spawn(pcall, o.Callback, v)
				end
			end

			local hit = Create("TextButton", {
				Position = UDim2.new(0, 6, 1, -28),
				Size = UDim2.new(1, -12, 0, 26),
				BackgroundTransparency = 1,
				Text = "",
				Parent = row,
			})
			local dragging = false
			local function Update(x)
				local a = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
				SetValue(min + a * (max - min))
			end
			hit.InputBegan:Connect(function(input)
				if IsPointer(input) then
					dragging = true
					Update(input.Position.X)
				end
			end)
			UIS.InputChanged:Connect(function(input)
				if dragging and IsMove(input) then Update(input.Position.X) end
			end)
			UIS.InputEnded:Connect(function(input)
				if IsPointer(input) then dragging = false end
			end)

			SetValue(value, true)
			return { Set = function(_, v) SetValue(v) end, Get = function() return value end }
		end

		return Tab
	end

	function Window:RemoveTab(name)
		for _, t in ipairs(self.Tabs) do
			if t.Name == name then
				t:Destroy()
				return true
			end
		end
		return false
	end

	Window:SetVisible(true)
	return Window
end

---------------------------------------------------------------------
-- DEMO (xoa phan nay neu chi muon dung thu vien)
---------------------------------------------------------------------
local Window = Library:CreateWindow({
	Name = "NOVA HUB",
	Logo = "N",
	Subtitle = "v1.0",
})

local Home = Window:AddTab("Home")
Home:AddSection("Thong tin")
Home:AddLabel("Xin chao, " .. Players.LocalPlayer.Name)
Home:AddButton({
	Name = "Test Notify",
	Callback = function()
		Window:Notify({ Title = "Nova Hub", Content = "Day la thong bao o goc duoi ben phai man hinh.", Type = "Info", Duration = 4 })
	end,
})

local Farm = Window:AddTab("Farm")
Farm:AddSection("Auto")
Farm:AddToggle({
	Name = "Auto Farm",
	Default = false,
	Callback = function(v)
		Window:Notify({ Title = "Auto Farm", Content = v and "Da BAT chuc nang" or "Da TAT chuc nang", Type = v and "Success" or "Warning", Duration = 3 })
	end,
})
Farm:AddToggle({ Name = "Auto Collect", Callback = function(v) print("Auto Collect:", v) end })
Farm:AddSlider({ Name = "Farm Speed", Min = 1, Max = 100, Default = 25, Callback = function(v) print("Speed:", v) end })

local Settings = Window:AddTab("Settings")
Settings:AddSection("Quan ly tab")
local extra, count = {}, 0
Settings:AddButton({
	Name = "Them tab moi",
	Callback = function()
		count += 1
		local t = Window:AddTab("Tab " .. count)
		t:AddLabel("Day la Tab " .. count)
		table.insert(extra, t)
		Window:Notify({ Title = "Tab", Content = "Da them Tab " .. count, Type = "Success" })
	end,
})
Settings:AddButton({
	Name = "Xoa tab vua them",
	Callback = function()
		local t = table.remove(extra)
		if t then
			t:Destroy()
			Window:Notify({ Title = "Tab", Content = "Da xoa tab", Type = "Warning" })
		else
			Window:Notify({ Title = "Tab", Content = "Khong co tab nao de xoa", Type = "Error" })
		end
	end,
})
Settings:AddButton({
	Name = "Dong UI hoan toan",
	Callback = function() Window:Destroy() end,
})

Window:Notify({ Title = "NOVA HUB", Content = "Load thanh cong! Nhan RightShift de an/hien UI.", Type = "Success", Duration = 5 })

return Library

-- Ryzen X - V4.5 [ Beta ] | Blox Fruits info + toggles | Đen/Đỏ + RGB
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local VirtualUser = game:GetService("VirtualUser")

local lp = Players.LocalPlayer
local startTime = os.time()

local parent = (gethui and gethui()) or game:GetService("CoreGui")
if parent:FindFirstChild("KaiUI") then parent.KaiUI:Destroy() end

local BG, CARD, OFF = Color3.fromRGB(10, 10, 12), Color3.fromRGB(22, 22, 26), Color3.fromRGB(50, 50, 56)
local RED = Color3.fromRGB(255, 35, 55)
local WHITE = Color3.new(1, 1, 1)

local SEAS = { [2753915549] = "Sea 1", [4442272183] = "Sea 2", [7449423635] = "Sea 3" }

local grads = {}
local rgbMode = false

local function new(class, props)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	return o
end
local function corner(p, r) return new("UICorner", { CornerRadius = UDim.new(0, r), Parent = p }) end
local function stroke(p, t)
	local s = new("UIStroke", { Color = WHITE, Thickness = t or 1.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = p })
	table.insert(grads, new("UIGradient", { Parent = s }))
end
local function label(p, text, size, color, font, pos, sz, align)
	return new("TextLabel", {
		Text = text, TextSize = size, TextColor3 = color or WHITE, Font = font or Enum.Font.GothamMedium,
		BackgroundTransparency = 1, Position = pos or UDim2.new(), Size = sz or UDim2.new(1, 0, 1, 0),
		TextXAlignment = align or Enum.TextXAlignment.Left, Parent = p,
	})
end

local function drag(handle, target)
	local st = { moved = false }
	local dragging, startIn, startPos
	handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging, startIn, startPos, st.moved = true, i.Position, target.Position, false
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - startIn
			if d.Magnitude > 5 then st.moved = true end
			target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
	return st
end

-- GUI
local gui = new("ScreenGui", { Name = "KaiUI", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = parent })

local main = new("Frame", {
	Size = UDim2.fromOffset(340, 430), Position = UDim2.new(0.5, -170, 0.5, -215),
	BackgroundColor3 = BG, ClipsDescendants = true, Parent = gui,
})
corner(main, 14) stroke(main, 2)
local scale = new("UIScale", { Scale = 1, Parent = main })

-- Header
local header = new("Frame", { Size = UDim2.new(1, 0, 0, 42), BackgroundTransparency = 1, Parent = main })
local title = label(header, "Ryzen X - V4.5 [ Beta ]", 16, RED, Enum.Font.GothamBold, UDim2.fromOffset(14, 0), UDim2.new(1, -60, 1, 0))
local hide = new("TextButton", {
	Text = "—", TextSize = 18, Font = Enum.Font.GothamBold, TextColor3 = WHITE, BackgroundColor3 = CARD,
	Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -38, 0.5, -14), AutoButtonColor = false, Parent = header,
})
corner(hide, 8)
drag(header, main)

local content = new("ScrollingFrame", {
	Size = UDim2.new(1, -20, 1, -52), Position = UDim2.fromOffset(10, 46), BackgroundTransparency = 1,
	BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = RED,
	AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), Parent = main,
})
new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = content })

-- Profile card
local prof = new("Frame", { Size = UDim2.new(1, 0, 0, 82), BackgroundColor3 = CARD, LayoutOrder = 1, Parent = content })
corner(prof, 10)
local av = new("ImageLabel", {
	Size = UDim2.fromOffset(60, 60), Position = UDim2.fromOffset(11, 11), BackgroundColor3 = BG,
	Image = "", Parent = prof,
})
corner(av, 30) stroke(av, 2)
task.spawn(function()
	local ok, img = pcall(Players.GetUserThumbnailAsync, Players, lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
	if ok then av.Image = img end
end)
label(prof, lp.DisplayName, 17, WHITE, Enum.Font.GothamBold, UDim2.fromOffset(82, 16), UDim2.new(1, -90, 0, 22))
label(prof, "@" .. lp.Name, 13, Color3.fromRGB(160, 160, 170), Enum.Font.Gotham, UDim2.fromOffset(82, 40), UDim2.new(1, -90, 0, 18))

-- Stats grid
local grid = new("Frame", { Size = UDim2.new(1, 0, 0, 112), BackgroundTransparency = 1, LayoutOrder = 2, Parent = content })
new("UIGridLayout", {
	CellSize = UDim2.new(0.5, -4, 0, 52), CellPadding = UDim2.fromOffset(8, 8),
	SortOrder = Enum.SortOrder.LayoutOrder, Parent = grid,
})
local function statCard(name, order)
	local c = new("Frame", { BackgroundColor3 = CARD, LayoutOrder = order, Parent = grid })
	corner(c, 10)
	label(c, name, 12, Color3.fromRGB(150, 150, 160), Enum.Font.Gotham, UDim2.fromOffset(10, 6), UDim2.new(1, -10, 0, 16))
	return label(c, "--", 17, RED, Enum.Font.GothamBold, UDim2.fromOffset(10, 24), UDim2.new(1, -10, 0, 22)), c
end
local timeL = statCard("Thời gian", 1)
local seaL = statCard("Sea", 2)
local fpsL, fpsCard = statCard("FPS", 3)
local pingL, pingCard = statCard("Ping", 4)
seaL.Text = SEAS[game.PlaceId] or "Unknown"

-- Toggles
local toggles = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 3, Parent = content })
new("UIListLayout", { Padding = UDim.new(0, 8), Parent = toggles })

local function addToggle(text, default, callback)
	local row = new("Frame", { Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = CARD, Parent = toggles })
	corner(row, 10)
	label(row, text, 14, WHITE, Enum.Font.GothamMedium, UDim2.fromOffset(12, 0), UDim2.new(1, -70, 1, 0))
	local sw = new("TextButton", {
		Text = "", Size = UDim2.fromOffset(44, 22), Position = UDim2.new(1, -54, 0.5, -11),
		BackgroundColor3 = OFF, AutoButtonColor = false, Parent = row,
	})
	corner(sw, 11)
	local knob = new("Frame", { Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = WHITE, Parent = sw })
	corner(knob, 8)
	local state = default
	local function render(anim)
		local info = TweenInfo.new(anim and 0.2 or 0, Enum.EasingStyle.Quad)
		TweenService:Create(sw, info, { BackgroundColor3 = state and RED or OFF }):Play()
		TweenService:Create(knob, info, { Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8) }):Play()
	end
	sw.MouseButton1Click:Connect(function()
		state = not state
		render(true)
		task.spawn(callback, state)
	end)
	render(false)
	if default then task.spawn(callback, true) end
end

addToggle("RGB Mode", false, function(v) rgbMode = v end)
addToggle("Hiện FPS / Ping", true, function(v) fpsCard.Visible = v pingCard.Visible = v end)
local afk = false
addToggle("Anti AFK", true, function(v) afk = v end)
lp.Idled:Connect(function()
	if afk then
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
	end
end)
-- Thêm toggle của bạn: addToggle("Tên", false, function(state) ... end)

-- Nút tròn bật/tắt UI
local fab = new("TextButton", {
	Text = "R", TextSize = 20, Font = Enum.Font.GothamBlack, TextColor3 = RED, BackgroundColor3 = BG,
	Size = UDim2.fromOffset(46, 46), Position = UDim2.new(0, 16, 0.5, -23), AutoButtonColor = false, Parent = gui,
})
corner(fab, 23) stroke(fab, 2)
local fabDrag = drag(fab, fab)

local open = true
local function setOpen(v)
	open = v
	if v then main.Visible = true end
	local t = TweenService:Create(scale, TweenInfo.new(0.25, Enum.EasingStyle.Back, v and Enum.EasingDirection.Out or Enum.EasingDirection.In), { Scale = v and 1 or 0 })
	t:Play()
	if not v then t.Completed:Once(function() if not open then main.Visible = false end end) end
end
hide.MouseButton1Click:Connect(function() setOpen(false) end)
fab.MouseButton1Click:Connect(function() if not fabDrag.moved then setOpen(not open) end end)
scale.Scale = 0
setOpen(true)

-- Update loop
local frames, last = 0, os.clock()
local hue = 0
RunService.RenderStepped:Connect(function(dt)
	frames += 1
	local now = os.clock()
	if now - last >= 0.5 then
		fpsL.Text = tostring(math.floor(frames / (now - last)))
		frames, last = 0, now
		local ok, ping = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
		pingL.Text = ok and (math.floor(ping) .. " ms") or "--"
		local s = os.time() - startTime
		timeL.Text = string.format("%02d:%02d:%02d", s // 3600, s % 3600 // 60, s % 60)
	end

	hue = (hue + dt * 0.25) % 1
	local seq
	if rgbMode then
		seq = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHSV(hue, 1, 1)),
			ColorSequenceKeypoint.new(0.5, Color3.fromHSV((hue + 0.33) % 1, 1, 1)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV((hue + 0.66) % 1, 1, 1)),
		})
	else
		seq = ColorSequence.new({
			ColorSequenceKeypoint.new(0, RED),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 0, 4)),
			ColorSequenceKeypoint.new(1, RED),
		})
	end
	for _, g in ipairs(grads) do
		g.Color = seq
		g.Rotation = (g.Rotation + dt * 120) % 360
	end
	title.TextColor3 = rgbMode and Color3.fromHSV(hue, 1, 1) or RED
end)

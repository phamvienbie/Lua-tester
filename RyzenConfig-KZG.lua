repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer 

local CORRECT_KEY = "RyzenConfigX3D"

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KeySystemGui"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 180)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "RYZENX - KEY SYSTEM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(0.85, 0, 0, 40)
TextBox.Position = UDim2.new(0.075, 0, 0, 50)
TextBox.PlaceholderText = "Nhập Key vào đây..."
TextBox.Text = ""
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TextBox.TextSize = 14
TextBox.Font = Enum.Font.SourceSans
TextBox.Parent = MainFrame

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 6)
BoxCorner.Parent = TextBox

local CheckButton = Instance.new("TextButton")
CheckButton.Size = UDim2.new(0.85, 0, 0, 40)
CheckButton.Position = UDim2.new(0.075, 0, 0, 105)
CheckButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
CheckButton.Text = "KIỂM TRA & XÁC THỰC KEY"
CheckButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CheckButton.TextSize = 14
CheckButton.Font = Enum.Font.SourceSansBold
CheckButton.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = CheckButton

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 0, 150)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = ""
StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
StatusLabel.TextSize = 13
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.Parent = MainFrame

-- Xử lý kiểm tra Key
local keyPassed = false

CheckButton.MouseButton1Click:Connect(function()
    local enteredKey = TextBox.Text
    if enteredKey == CORRECT_KEY then
        StatusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
        StatusLabel.Text = "Key chính xác! Đang khởi động script..."
        keyPassed = true
        task.wait(0.8)
        ScreenGui:Destroy()
    else
        StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        StatusLabel.Text = "Key sai! Vui lòng nhập lại."
    end
end)

-- Chờ người dùng nhập đúng key mới cho chạy tiếp phần sau
repeat task.wait(0.5) until keyPassed == true

--------------------------------------------------------------------------------
-- 🚀 SAU KHI CHECK KEY XONG -> KHỞI ĐỘNG SCRIPT & BRING MOB
--------------------------------------------------------------------------------

getgenv().Key = CORRECT_KEY
getgenv().__BANANA_SCRIPT_ROUTE = "kaigod"

-- Cấu hình Bring Mob nâng cao
getgenv().BringMob = true
getgenv().BringDistance = 500       -- Tầm quét gom quái (500 studs)
getgenv().SafeDistance = 22         -- Khoảng cách an toàn tránh quái đánh trúng
getgenv().LockMobName = true        -- Chỉ gom quái cùng tên để tránh kéo nhầm Boss

-- Luồng xử lý Bring Mob ngầm
task.spawn(function()
    local RunService = game:GetService("RunService")
    local Enemies = workspace:WaitForChild("Enemies")

    -- Mở rộng Network Ownership liên tục
    task.spawn(function()
        while task.wait(0.5) do
            if getgenv().BringMob then
                pcall(function()
                    if sethiddenproperty then
                        sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
                        sethiddenproperty(LocalPlayer, "MaxSimulationRadius", math.huge)
                    end
                end)
            end
        end
    end)

    -- Khóa vật lý quái (chống văng, chống hồi máu)
    local function lockMobPhysics(root, hum)
        if not root:FindFirstChild("BringVelocity") then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "BringVelocity"
            bv.Velocity = Vector3.zero
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.Parent = root
        end

        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        root.CanCollide = false

        hum.WalkSpeed = 0
        hum.JumpPower = 0
        hum.AutoRotate = false

        if hum:FindFirstChild("Animator") then
            hum.Animator:Destroy()
        end
        hum:ChangeState(11)
    end

    RunService.Heartbeat:Connect(function()
        if not getgenv().BringMob then return end

        pcall(function()
            local char = LocalPlayer.Character
            local playerRoot = char and char:FindFirstChild("HumanoidRootPart")
            if not playerRoot then return end

            local maxDist = getgenv().BringDistance or 500
            local safeDist = getgenv().SafeDistance or 22

            local anchorMob = nil
            local shortestDist = maxDist

            -- Tìm quái gần nhất làm tâm điểm
            for _, mob in ipairs(Enemies:GetChildren()) do
                local hum = mob:FindFirstChildOfClass("Humanoid")
                local root = mob:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 then
                    local dist = (root.Position - playerRoot.Position).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        anchorMob = mob
                    end
                end
            end

            if not anchorMob then return end
            local targetName = anchorMob.Name
            local anchorPos = anchorMob.HumanoidRootPart.Position

            -- Giữ khoảng cách an toàn so với người chơi
            local flatPlayerPos = Vector3.new(playerRoot.Position.X, anchorPos.Y, playerRoot.Position.Z)
            local diff = anchorPos - flatPlayerPos
            local currentDist = diff.Magnitude

            if currentDist < safeDist then
                local pushDir = currentDist > 0.1 and diff.Unit or playerRoot.CFrame.LookVector
                anchorPos = flatPlayerPos + (pushDir * safeDist)
            end

            local finalAnchorCFrame = CFrame.new(anchorPos)

            -- Kéo toàn bộ quái trong 500 studs về điểm định vị
            for _, mob in ipairs(Enemies:GetChildren()) do
                if not getgenv().LockMobName or mob.Name == targetName then
                    local hum = mob:FindFirstChildOfClass("Humanoid")
                    local root = mob:FindFirstChild("HumanoidRootPart")
                    if hum and root and hum.Health > 0 then
                        local dist = (root.Position - anchorPos).Magnitude
                        if dist <= maxDist then
                            root.CFrame = finalAnchorCFrame
                            lockMobPhysics(root, hum)
                        end
                    end
                end
            end
        end)
    end)
end)

return loadstring(game:HttpGet("https://banana-hub.xyz/loader/banana.lua"))()
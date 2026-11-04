repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer 

-- Cấu hình Key tự động check ngầm
getgenv().RyzenConfigKey = "RyzenConfigX3D"
local CORRECT_KEY = "RyzenConfigX3D"

-- Kiểm tra Key ngầm ngay lập tức
if getgenv().RyzenConfigKey ~= CORRECT_KEY then
    warn("[RyzenX] Key không chính xác! Vui lòng kiểm tra lại RyzenConfigKey.")
    return -- Dừng hẳn, không load script nếu sai key
end

--------------------------------------------------------------------------------
-- 🚀 SAU KHI CHECK KEY THÀNH CÔNG -> KHỞI ĐỘNG SCRIPT & BRING MOB
--------------------------------------------------------------------------------
-- Cấu hình Bring Mob nâng cao
getgenv().BringMob = true
getgenv().BringDistance = 500       -- Tầm quét gom quái (500 studs)
getgenv().SafeDistance = 22         -- Khoảng cách an toàn tránh quái đánh trúng
getgenv().LockMobName = true        -- Chỉ gom quái cùng tên để tránh kéo nhầm Boss

-- Luồng xử lý Bring Mob ngầm
task.spawn(function()
    local RunService = game:GetService("RunService")
    local LocalPlayer = game.Players.LocalPlayer
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

-- Tải Banana Hub gốc
return loadstring(game:HttpGet("https://banana-hub.xyz/loader/banana.lua"))()

local genv = (getgenv and getgenv()) or _G
if genv.__KaitunStop then pcall(genv.__KaitunStop) end
genv.__KaitunRunning = true
if not game:IsLoaded() then game.Loaded:Wait() end
do  -- đợi màn hình loading của Blox Fruits tắt (tối đa 60s)
    local lp = game:GetService("Players").LocalPlayer
    local pg = lp and lp:WaitForChild("PlayerGui", 30)
    local t0 = tick()
    while pg and pg:FindFirstChild("LoadingScreen") and tick() - t0 < 60 do task.wait(0.5) end
end

--// ===================== CẤU HÌNH =====================
local Config = {

    -- Farm level
    AutoFarm = true,
    AutoQuest = true,
    BringMob = true,
    BringDistance = 250,
    Team = "Pirates",
    AutoRedeemCode = true,
    RedeemTimeout = 60,
    SelectWeapon = "Melee",
    AutoHaki = true,
    FarmHeight = 12,
    TweenSpeed = 170,
    MaxTweenSpeed = 220,
    SafeHealthPercent = 25,

    -- Chỉ số
    AutoStats = true,
    StatCaps = { Melee = 2650, Defense = 2650, Sword = 1500, ["Demon Fruit"] = 1300 },

    -- Trái ác quỷ
    AutoRandomFruit = true,
    RandomDelay = 10,
    BeliReserve = 0,
    AutoStoreFruit = true,

    -- Mua đồ / kỹ năng
    AutoBuyAbilities = true,
    AutoBuyShop = true,
    AutoCollectDrops = true,

    -- Chuyển Sea (thử nghiệm - xem ghi chú cuối file)
    AutoUnlockSea = true,
    BartiloMinLevel = 850,
    AutoPullLever = true,
    LeverMinLevel = 2550,
    HopForMirage = false,
    AutoRaceV2 = true,
    AutoSubmerged = true,
    SubmergedMinLevel = 2600,

    -- Raid
    AutoRaid = true,
    RaidMinLevel = 1100,
    SelectChip = "Flame",
    AutoBuyChipBeli = true,
    AutoTradeTrashFruit = false,
    KillAuraRaid = true,

    -- Boss ưu tiên: Dough King > rip_indra > Darkbeard
    AutoBoss = true,
    BossHeight = 14,

    -- Quest vật phẩm Sea 3 (khôi phục từ bản gốc): Yama / Tushita / CDK / Godhuman / SanguineArt
    AutoQuestItems = true,
    TargetQuestItem = "CDK",
    QuestItemMinLevel = 1500,
    QuestItemRunSeconds = 240,
    QuestItemRestSeconds = 300,

    -- Auto Saber (Sea 1, khôi phục từ bản gốc)
    AutoSaberQuest = true,
    SaberMinLevel = 200,
    SaberRunSeconds = 240,
    SaberRestSeconds = 240,

    -- Auto gạt cần khi có Mirror Fractal + Valkyrie Helmet (khôi phục từ bản gốc)
    AutoLever = true,
    LeverRunSeconds = 90,
    LeverRestSeconds = 600,

    DynamicQuests = true,

    -- Giảm lag
    FpsCap = 60,
    BlackScreen = false,
    RemoveSFX = true,
    FixLag = true,
    NoSkillGFX = true,
    XRay = true,
    NoFog = true,
    MapTransparency = 1,
    SeaTransparency = 1,
    HideOtherPlayers = true,

    Debug = false,
}
if type(genv.KaitunConfig) == "table" then
    for k, v in pairs(genv.KaitunConfig) do Config[k] = v end
end
if type(Config.StatCaps) == "table" and Config.StatCaps["Blox Fruit"] then
    Config.StatCaps["Demon Fruit"] = Config.StatCaps["Blox Fruit"]
    Config.StatCaps["Blox Fruit"] = nil
end
genv.KaitunConfig = Config

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- CẤU HÌNH FAST ATTACK TỐC ĐỘ CAO & ỔN ĐỊNH
-- ==========================================
_G.FastAttackHook = true
_G.AttackDelay = 0.055
_G.AttackRange = 65
_G.MaxBatchTargets = 8
_G.AutoBuso = true

local CachedRemotes = {
	RegAttack = nil,
	RegHit = nil,
	CommF = nil,
	LastScan = 0
}

local function refreshRemotes(force)
	local now = os.clock()
	if not force and (now - CachedRemotes.LastScan) < 3 then
		return
	end
	CachedRemotes.LastScan = now

	pcall(function()
		local remotes = ReplicatedStorage:FindFirstChild("Remotes")
		if remotes and not CachedRemotes.CommF then
			CachedRemotes.CommF = remotes:FindFirstChild("CommF_")
		end

		local modules = ReplicatedStorage:FindFirstChild("Modules")
		local net = modules and modules:FindFirstChild("Net")
		if net then
			CachedRemotes.RegAttack = net:FindFirstChild("RE/RegisterAttack")
			CachedRemotes.RegHit = net:FindFirstChild("RE/RegisterHit")
		end
	end)
end

refreshRemotes(true)

local function findFastTargetPart(hrp, range)
	local enemies = workspace:FindFirstChild("Enemies")
	if not enemies then return nil end

	local bestPart = nil
	local bestDistSq = range * range

	for _, mob in ipairs(enemies:GetChildren()) do
		local hum = mob:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health > 0 then
			local part = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Head")
			if part then
				local diff = part.Position - hrp.Position
				local distSq = diff.X * diff.X + diff.Y * diff.Y + diff.Z * diff.Z
				if distSq <= bestDistSq then
					bestDistSq = distSq
					bestPart = part
				end
			end
		end
	end

	return bestPart
end

local function getBatchTargets(hrp, range, maxCount)
	local enemies = workspace:FindFirstChild("Enemies")
	if not enemies then return {} end

	local list = {}
	local maxDistSq = range * range

	for _, mob in ipairs(enemies:GetChildren()) do
		local hum = mob:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health > 0 then
			local part = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Head")
			if part then
				local diff = part.Position - hrp.Position
				local distSq = diff.X * diff.X + diff.Y * diff.Y + diff.Z * diff.Z
				if distSq <= maxDistSq then
					table.insert(list, { mob = mob, part = part, distSq = distSq })
				end
			end
		end
	end

	if #list > 1 then
		table.sort(list, function(a, b)
			return a.distSq < b.distSq
		end)
	end

	if #list > maxCount then
		local trimmed = {}
		for i = 1, maxCount do
			trimmed[i] = list[i]
		end
		return trimmed
	end

	return list
end

if not getgenv().HiruFastAttackHookedV3 then
	getgenv().HiruFastAttackHookedV3 = true

	pcall(function()
		local mt = getrawmetatable(game)
		if mt and hookmetamethod then
			local oldNamecall = mt.__namecall
			setreadonly(mt, false)

			mt.__namecall = newcclosure(function(self, ...)
				if _G.FastAttackHook and not checkcaller() then
					local method = getnamecallmethod()
					if method == "FireServer" and tostring(self) == "RE/RegisterHit" then
						local args = { ... }
						local char = LocalPlayer.Character
						local hrp = char and char:FindFirstChild("HumanoidRootPart")
						if hrp then
							local range = tonumber(_G.AttackRange) or 65
							local targets = getBatchTargets(hrp, range, tonumber(_G.MaxBatchTargets) or 8)
							if #targets > 0 then
								args[1] = targets[1].part
								local extra = {}
								for i = 2, #targets do
									extra[i - 1] = { targets[i].mob, targets[i].part }
								end
								args[2] = extra
								return oldNamecall(self, unpack(args))
							end
						end
					end
				end

				return oldNamecall(self, ...)
			end)

			setreadonly(mt, true)
		end
	end)
end

local lastBusoTime = 0
local function checkBuso(char)
	if not _G.AutoBuso then return end
	local now = os.clock()
	if (now - lastBusoTime) < 2 then return end
	lastBusoTime = now

	if char and not char:FindFirstChild("HasBuso") and CachedRemotes.CommF then
		pcall(function()
			CachedRemotes.CommF:InvokeServer("Buso")
		end)
	end
end

local function getEquippedTool(char)
	for _, child in ipairs(char:GetChildren()) do
		if child:IsA("Tool") then
			return child
		end
	end
	return nil
end

local isAttacking = false

task.spawn(function()
	while true do
		local delayTime = tonumber(_G.AttackDelay) or 0.055
		if delayTime < 0.04 then
			delayTime = 0.04
		end
		task.wait(delayTime)

		if not _G.FastAttackHook or isAttacking then
			continue
		end

		isAttacking = true
		pcall(function()
			local char = LocalPlayer.Character
			if not char then return end

			local hrp = char:FindFirstChild("HumanoidRootPart")
			local hum = char:FindFirstChildOfClass("Humanoid")
			if not hrp or not hum or hum.Health <= 0 then return end

			local tool = getEquippedTool(char)
			if not tool then return end

			refreshRemotes(false)

			local range = tonumber(_G.AttackRange) or 65
			local maxBatch = tonumber(_G.MaxBatchTargets) or 8
			local targets = getBatchTargets(hrp, range, maxBatch)
			if #targets == 0 then return end

			checkBuso(char)

			pcall(function()
				tool:Activate()
			end)

			local regAttack = CachedRemotes.RegAttack
			local regHit = CachedRemotes.RegHit

			if regAttack and regAttack:IsA("RemoteEvent") then
				pcall(function()
					regAttack:FireServer(0)
				end)
			end

			if regHit and regHit:IsA("RemoteEvent") then
				local primary = targets[1].part
				local extra = {}
				for i = 2, #targets do
					extra[i - 1] = { targets[i].mob, targets[i].part }
				end
				pcall(function()
					regHit:FireServer(primary, extra)
				end)
			end
		end)
		isAttacking = false
	end
end)

--// ===================== SERVICES =====================
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")

local CommF_ = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

local fireTouch = firetouchinterest
local fireClick = fireclickdetector
local setHidden = sethiddenproperty

--// ===================== TRẠNG THÁI / TIỆN ÍCH CHUNG =====================
local Running = true
local Connections = {}
local State = { Busy = false, Task = "Khởi động", Healing = false, HealPos = nil }
local Cleanups = {}

local function Connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(Connections, c)
    return c
end

local function Loop(interval, fn, name)
    task.spawn(function()
        while Running do
            local ok, err = pcall(fn)
            if not ok and Config.Debug then warn("[Kaitun:" .. tostring(name) .. "]", err) end
            task.wait(interval)
        end
    end)
end

local function Invoke(...)
    local args = table.pack(...)
    local ok, res = pcall(function()
        return CommF_:InvokeServer(table.unpack(args, 1, args.n))
    end)
    if ok then return res end
    return nil
end

local CacheStore = {}
local function Cached(key, ttl, fn)
    local e = CacheStore[key]
    if e and tick() - e.t < ttl then return e.v end
    local v = fn()
    CacheStore[key] = { t = tick(), v = v }
    return v
end

if not LocalPlayer.Team then
    Invoke("SetTeam", Config.Team)
    for _ = 1, 40 do
        if LocalPlayer.Team then break end
        task.wait(0.5)
    end
end
local Data = LocalPlayer:WaitForChild("Data", 60)
assert(Data, "[Kaitun] Không tìm thấy LocalPlayer.Data")
Data:WaitForChild("Level", 30)

local function Level() return Data.Level.Value end
local function Beli() return Data.Beli.Value end
local function Fragments() return Data.Fragments.Value end

local function SeaOfLevel(lv) return lv < 700 and 1 or (lv < 1500 and 2 or 3) end
local PlaceId = game.PlaceId
local Sea = (PlaceId == 2753915549 and 1) or (PlaceId == 4442272183 and 2) or (PlaceId == 7449423635 and 3) or 0
if Sea == 0 then
    Sea = SeaOfLevel(Level())
    warn("[Kaitun] PlaceId lạ, đoán Sea theo level: " .. Sea)
end

local function GetChar()
    local c = LocalPlayer.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if hrp and hum and hum.Health > 0 then return c, hrp, hum end
    return nil
end

local function SetStatus(text) State.Task = text end

--// ===================== REDEEM CODE =====================
if Config.AutoRedeemCode and not genv.__KaitunRedeemed then
    genv.__KaitunRedeemed = true
    local Codes = Config.RedeemCodes or {
        "Sub2OfficialNoobie", "SUB2GAMERROBOT_EXP1", "Sub2Fer999", "Enyu_is_Pro",
        "Magicbus", "JCWK", "Starcodeheo", "Bluxxy", "THEGREATACE",
        "SUB2NOOBMASTER123", "Sub2Daigrock", "Axiore", "TantaiGaming",
        "StrawHatMaine", "Sub2CaptainMaui", "kittgaming", "KittGaming",
        "SUB2GAMERROBOT_RESET1", "Sub2UncleKizaru", "Kitt_Reset",
        "Bignews", "fudd10_v2", "Fudd10", "Chandler"
    }

    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local redeem = remotes and remotes:FindFirstChild("Redeem")
    if redeem then
        SetStatus("Redeem code")
        local deadline = tick() + (tonumber(Config.RedeemTimeout) or 60)
        for _, code in ipairs(Codes) do
            if tick() >= deadline then break end
            local done = false
            task.spawn(function()
                pcall(function() return redeem:InvokeServer(code) end)
                done = true
            end)
            local t0 = tick()
            while not done and tick() - t0 < 4 and tick() < deadline do task.wait(0.1) end
            task.wait(0.25)
        end
    end
end

--// ===================== DI CHUYỂN =====================
local CurrentTween, TweenGoal

local function StopTween()
    if CurrentTween then
        pcall(function() CurrentTween:Cancel() end)
        CurrentTween, TweenGoal = nil, nil
    end
end

local function Near(cf, radius)
    local _, hrp = GetChar()
    return hrp ~= nil and (hrp.Position - cf.Position).Magnitude <= (radius or 10)
end

local function MoveTo(cf, snap)
    local _, hrp = GetChar()
    if not hrp then return false end
    snap = snap or 8
    local dist = (cf.Position - hrp.Position).Magnitude
    if dist <= snap then
        StopTween()
        hrp.CFrame = cf
        return true
    end
    if CurrentTween and TweenGoal
        and CurrentTween.PlaybackState == Enum.PlaybackState.Playing
        and (TweenGoal.Position - cf.Position).Magnitude < 4 then
        return false
    end
    StopTween()
    TweenGoal = cf
    local speed = math.clamp(tonumber(Config.TweenSpeed) or 170, 60, tonumber(Config.MaxTweenSpeed) or 220)
    CurrentTween = TweenService:Create(hrp,
        TweenInfo.new(math.max(0.05, dist / speed), Enum.EasingStyle.Linear),
        { CFrame = cf })
    CurrentTween:Play()
    return false
end

Connect(RunService.Stepped, function()
    local c, hrp = GetChar()
    if not c then return end
    local hover = hrp:FindFirstChild("KaitunHover")
    if State.Busy then
        for _, p in ipairs(c:GetChildren()) do
            if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
        end
        if not hover then
            hover = Instance.new("BodyVelocity")
            hover.Name = "KaitunHover"
            hover.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            hover.Velocity = Vector3.zero
            hover.Parent = hrp
        end
        hrp.AssemblyAngularVelocity = Vector3.zero
    elseif hover then
        hover:Destroy()
    end
end)

--// ===================== CHIẾN ĐẤU =====================
local Combat = { AttackUntil = 0, LastBuso = 0, LastClick = 0 }

local MeleePriority = {
    "Godhuman", "Sanguine Art", "Dragon Talon", "Electric Claw", "Death Step",
    "Sharkman Karate", "Superhuman", "Dragon Claw", "Electro", "Dark Step",
    "Black Leg", "Fishman Karate", "Water Kung Fu", "Combat",
}

local function PickWeapon(tooltip)
    local best, bestRank
    local function consider(tool)
        if tool:IsA("Tool") and (tool.ToolTip == tooltip or (tooltip == "Melee" and tool.ToolTip == "")) then
            local rank = 100
            if tooltip == "Melee" then
                for i, n in ipairs(MeleePriority) do
                    if tool.Name == n then rank = i break end
                end
            end
            if not best or rank < bestRank then best, bestRank = tool, rank end
        end
    end
    local c = LocalPlayer.Character
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if c then for _, t in ipairs(c:GetChildren()) do consider(t) end end
    if bp then for _, t in ipairs(bp:GetChildren()) do consider(t) end end
    return best
end

function Combat.Equip()
    local c, _, hum = GetChar()
    if not c then return end
    if Config.AutoHaki and not c:FindFirstChild("HasBuso") and tick() - Combat.LastBuso > 3 then
        Combat.LastBuso = tick()
        task.spawn(Invoke, "Buso")
    end
    local want = PickWeapon(Config.SelectWeapon)
    if want and want.Parent ~= c then
        pcall(function() hum:EquipTool(want) end)
    end
end

function Combat.Hit()
    Combat.AttackUntil = tick() + 0.5
    if tick() - Combat.LastClick > 0.12 then
        Combat.LastClick = tick()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.new(640, 360))
            task.wait(0.03)
            VirtualUser:Button1Up(Vector2.new(640, 360))
        end)
    end
end

function Combat.Fight(targetHRP, height)
    local _, hrp = GetChar()
    if not hrp then return end
    Combat.Equip()
    height = height or Config.FarmHeight
    local goal = CFrame.new(targetHRP.Position + Vector3.new(0, height, 0))
    MoveTo(goal, 12)
    if (hrp.Position - targetHRP.Position).Magnitude <= height + 40 then
        Combat.Hit()
    end
end

Connect(LocalPlayer.Idled, function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

--// ===================== QUÁI =====================
local function EnemiesFolder() return Workspace:FindFirstChild("Enemies") end

local function Alive(model)
    local hum = model:FindFirstChildOfClass("Humanoid")
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if hum and hrp and hum.Health > 0 then return hum, hrp end
end

-- Tìm quái theo tên chính xác HOẶC khớp tên linh hoạt (ví dụ "Bandit" hoặc "Bandits")
local function NearestEnemy(name, exact)
    local _, hrp = GetChar()
    if not hrp then return nil end

    local best, bestDist
    local lname = name and name:lower()
    local roots = {}
    if EnemiesFolder() then table.insert(roots, EnemiesFolder()) end

    for _, folder in ipairs(roots) do
        for _, m in ipairs(folder:GetChildren()) do
            if m:IsA("Model") and not Players:GetPlayerFromCharacter(m) then
                local mname = m.Name:lower()
                local ok = false
                if not name then
                    ok = true
                elseif exact then
                    ok = (m.Name == name) or (mname == lname) or (mname == lname .. "s")
                else
                    ok = mname:find(lname, 1, true) ~= nil
                end

                if ok then
                    local _, mh = Alive(m)
                    if mh then
                        local d = (mh.Position - hrp.Position).Magnitude
                        if not bestDist or d < bestDist then best, bestDist = m, d end
                    end
                end
            end
        end
    end

    -- Nếu chưa thấy trong Enemies, kiểm tra thêm các model quái trong Workspace có Humanoid và trùng tên
    if not best and name then
        for _, m in ipairs(Workspace:GetChildren()) do
            if m:IsA("Model") and m.Parent ~= EnemiesFolder() and not Players:GetPlayerFromCharacter(m) then
                local mname = m.Name:lower()
                if mname == lname or mname:find(lname, 1, true) then
                    local _, mh = Alive(m)
                    if mh then
                        local d = (mh.Position - hrp.Position).Magnitude
                        if not bestDist or d < bestDist then best, bestDist = m, d end
                    end
                end
            end
        end
    end

    return best
end

--// ---- Gom quái (Bring Mob) ----
local Bring = { Name = nil, Center = nil, Until = 0, Pulled = setmetatable({}, { __mode = "k" }) }

function Bring.Set(name, cf)
    if not Config.BringMob then return end
    Bring.Name, Bring.Center, Bring.Until = name, cf, tick() + 0.6
end

local function ReleaseMob(mob)
    local hrp = mob:FindFirstChild("HumanoidRootPart")
    local bp = hrp and hrp:FindFirstChild("KaitunBringPos")
    if bp then bp:Destroy() end
    Bring.Pulled[mob] = nil
end

local function ReleaseAll()
    for mob in pairs(Bring.Pulled) do ReleaseMob(mob) end
end
table.insert(Cleanups, ReleaseAll)

Connect(RunService.Stepped, function()
    if not Config.BringMob or tick() > Bring.Until or not Bring.Center then
        if next(Bring.Pulled) then ReleaseAll() end
        return
    end
    if setHidden then
        pcall(function()
            setHidden(LocalPlayer, "SimulationRadius", math.huge)
            setHidden(LocalPlayer, "MaxSimulationRadius", math.huge)
        end)
    end
    local folder = EnemiesFolder()
    if not folder then return end
    local center = Bring.Center
    local targetLower = Bring.Name and Bring.Name:lower()
    for _, mob in ipairs(folder:GetChildren()) do
        local matchName = (not Bring.Name) or (mob.Name == Bring.Name) or (targetLower and mob.Name:lower():find(targetLower, 1, true))
        if matchName then
            local hum, hrp = Alive(mob)
            if hum then
                if (hrp.Position - center.Position).Magnitude <= Config.BringDistance then
                    for _, p in ipairs(mob:GetChildren()) do
                        if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
                    end
                    hum.WalkSpeed = 0
                    hum.JumpPower = 0
                    hum:ChangeState(Enum.HumanoidStateType.Physics)
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                    local bp = hrp:FindFirstChild("KaitunBringPos")
                    if not bp then
                        bp = Instance.new("BodyPosition")
                        bp.Name = "KaitunBringPos"
                        bp.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                        bp.P, bp.D = 15000, 1000
                        bp.Parent = hrp
                    end
                    bp.Position = center.Position
                    hrp.CFrame = CFrame.new(center.Position)
                    Bring.Pulled[mob] = true
                elseif Bring.Pulled[mob] then
                    ReleaseMob(mob)
                end
            end
        end
    end
end)

-- Tìm điểm spawn thực tế của quái nếu có trong _WorldOrigin.EnemySpawns
local function FindSpawnNear(mobName, fallbackCF)
    local wo = Workspace:FindFirstChild("_WorldOrigin")
    local sp = wo and wo:FindFirstChild("EnemySpawns")
    local _, hrp = GetChar()
    if sp and hrp and mobName then
        local lm = mobName:lower()
        local bestPos, bestDist
        for _, obj in ipairs(sp:GetChildren()) do
            if obj.Name:lower():find(lm, 1, true) then
                local pos = obj:IsA("BasePart") and obj.Position or (obj:IsA("Model") and obj:GetPivot().Position)
                if pos then
                    local d = (pos - hrp.Position).Magnitude
                    if not bestDist or d < bestDist then
                        bestDist, bestPos = d, pos
                    end
                end
            end
        end
        if bestPos then return CFrame.new(bestPos) end
    end
    return fallbackCF
end

local function Hunt(name, spawnCF, opt)
    opt = opt or {}
    local height = opt.height or Config.FarmHeight
    local mob = NearestEnemy(name, opt.exact)
    if mob then
        local _, mh = Alive(mob)
        if mh then
            if opt.bring then Bring.Set(name, mh.CFrame) end
            Combat.Fight(mh, height)
            return true
        end
    end
    Combat.Equip()
    local actualSpawn = FindSpawnNear(name, spawnCF)
    MoveTo(actualSpawn * CFrame.new(0, height, 0), 12)
    return false
end

--// ===================== BẢNG QUEST =====================
local QuestData = {
    -- ================= SEA 1 (1 - 700) =================
    {Min = 1, Max = 9, Quest = "BanditQuest1", LevelQ = 1, Mob = "Bandit", CFrameQ = CFrame.new(1059, 15, 1550), CFrameM = CFrame.new(1145, 17, 1634)},
    {Min = 10, Max = 14, Quest = "JungleQuest", LevelQ = 1, Mob = "Monkey", CFrameQ = CFrame.new(-1598, 35, 153), CFrameM = CFrame.new(-1448, 67, 11)},
    {Min = 15, Max = 29, Quest = "JungleQuest", LevelQ = 2, Mob = "Gorilla", CFrameQ = CFrame.new(-1598, 35, 153), CFrameM = CFrame.new(-1129, 40, -525)},
    {Min = 30, Max = 39, Quest = "BuggyQuest1", LevelQ = 1, Mob = "Pirate", CFrameQ = CFrame.new(-1141, 4, 3831), CFrameM = CFrame.new(-1103, 13, 3896)},
    {Min = 40, Max = 59, Quest = "BuggyQuest1", LevelQ = 2, Mob = "Brute", CFrameQ = CFrame.new(-1141, 4, 3831), CFrameM = CFrame.new(-1140, 14, 4322)},
    {Min = 60, Max = 74, Quest = "DesertQuest", LevelQ = 1, Mob = "Desert Bandit", CFrameQ = CFrame.new(894, 5, 4392), CFrameM = CFrame.new(924, 6, 4481)},
    {Min = 75, Max = 89, Quest = "DesertQuest", LevelQ = 2, Mob = "Desert Officer", CFrameQ = CFrame.new(894, 5, 4392), CFrameM = CFrame.new(1608, 8, 4371)},
    {Min = 90, Max = 99, Quest = "SnowQuest", LevelQ = 1, Mob = "Snow Bandit", CFrameQ = CFrame.new(1389, 88, -1298), CFrameM = CFrame.new(1354, 87, -1393)},
    {Min = 100, Max = 119, Quest = "SnowQuest", LevelQ = 2, Mob = "Snowman", CFrameQ = CFrame.new(1389, 88, -1298), CFrameM = CFrame.new(1201, 144, -1550)},
    {Min = 120, Max = 149, Quest = "MarineQuest2", LevelQ = 1, Mob = "Chief Petty Officer", CFrameQ = CFrame.new(-5039, 27, 4324), CFrameM = CFrame.new(-4881, 22, 4273)},
    {Min = 150, Max = 174, Quest = "SkyQuest", LevelQ = 1, Mob = "Sky Bandit", CFrameQ = CFrame.new(-4839, 717, -2619), CFrameM = CFrame.new(-4953, 295, -2899)},
    {Min = 175, Max = 189, Quest = "SkyQuest", LevelQ = 2, Mob = "Dark Master", CFrameQ = CFrame.new(-4839, 717, -2619), CFrameM = CFrame.new(-5259, 391, -2229)},
    {Min = 190, Max = 209, Quest = "PrisonerQuest", LevelQ = 1, Mob = "Prisoner", CFrameQ = CFrame.new(5308, 1, 475), CFrameM = CFrame.new(5098, -0.3, 474)},
    {Min = 210, Max = 249, Quest = "PrisonerQuest", LevelQ = 2, Mob = "Dangerous Prisoner", CFrameQ = CFrame.new(5308, 1, 475), CFrameM = CFrame.new(5654, 15, 866)},
    {Min = 250, Max = 274, Quest = "ColosseumQuest", LevelQ = 1, Mob = "Toga Warrior", CFrameQ = CFrame.new(-1580, 6, -2986), CFrameM = CFrame.new(-1820, 51, -2740)},
    {Min = 275, Max = 299, Quest = "ColosseumQuest", LevelQ = 2, Mob = "Gladiator", CFrameQ = CFrame.new(-1580, 6, -2986), CFrameM = CFrame.new(-1292, 56, -3339)},
    {Min = 300, Max = 324, Quest = "MagmaQuest", LevelQ = 1, Mob = "Military Soldier", CFrameQ = CFrame.new(-5313, 10, 8515), CFrameM = CFrame.new(-5411, 11, 8454)},
    {Min = 325, Max = 374, Quest = "MagmaQuest", LevelQ = 2, Mob = "Military Spy", CFrameQ = CFrame.new(-5313, 10, 8515), CFrameM = CFrame.new(-5802, 86, 8828)},
    {Min = 375, Max = 399, Quest = "FishmanQuest", LevelQ = 1, Mob = "Fishman Warrior", CFrameQ = CFrame.new(61122, 18, 1569), CFrameM = CFrame.new(60878, 18, 1543)},
    {Min = 400, Max = 449, Quest = "FishmanQuest", LevelQ = 2, Mob = "Fishman Commando", CFrameQ = CFrame.new(61122, 18, 1569), CFrameM = CFrame.new(61922, 18, 1493)},
    {Min = 450, Max = 474, Quest = "SkyExp1Quest", LevelQ = 1, Mob = "God's Guard", CFrameQ = CFrame.new(-4721, 843, -1949), CFrameM = CFrame.new(-4710, 845, -1927)},
    {Min = 475, Max = 524, Quest = "SkyExp1Quest", LevelQ = 2, Mob = "Shanda", CFrameQ = CFrame.new(-7859, 5544, -381), CFrameM = CFrame.new(-7678, 5566, -497)},
    {Min = 525, Max = 549, Quest = "SkyExp2Quest", LevelQ = 1, Mob = "Royal Squad", CFrameQ = CFrame.new(-7906, 5634, -1411), CFrameM = CFrame.new(-7624, 5658, -1467)},
    {Min = 550, Max = 624, Quest = "SkyExp2Quest", LevelQ = 2, Mob = "Royal Soldier", CFrameQ = CFrame.new(-7906, 5634, -1411), CFrameM = CFrame.new(-7836, 5645, -1790)},
    {Min = 625, Max = 649, Quest = "FountainQuest", LevelQ = 1, Mob = "Galley Pirate", CFrameQ = CFrame.new(5259, 37, 4050), CFrameM = CFrame.new(5551, 78, 3930)},
    {Min = 650, Max = 699, Quest = "FountainQuest", LevelQ = 2, Mob = "Galley Captain", CFrameQ = CFrame.new(5259, 37, 4050), CFrameM = CFrame.new(5441, 42, 4950)},

    -- ================= SEA 2 (700 - 1500) =================
    {Min = 700, Max = 724, Quest = "Area1Quest", LevelQ = 1, Mob = "Raider", CFrameQ = CFrame.new(-429, 71, 1836), CFrameM = CFrame.new(-728, 52, 2345)},
    {Min = 725, Max = 774, Quest = "Area1Quest", LevelQ = 2, Mob = "Mercenary", CFrameQ = CFrame.new(-429, 71, 1836), CFrameM = CFrame.new(-1004, 80, 1424)},
    {Min = 775, Max = 799, Quest = "Area2Quest", LevelQ = 1, Mob = "Swan Pirate", CFrameQ = CFrame.new(638, 73, 918), CFrameM = CFrame.new(1068, 137, 1322)},
    {Min = 800, Max = 874, Quest = "Area2Quest", LevelQ = 2, Mob = "Factory Staff", CFrameQ = CFrame.new(632, 73, 918), CFrameM = CFrame.new(73, 81, -27)},
    {Min = 875, Max = 899, Quest = "MarineQuest3", LevelQ = 1, Mob = "Marine Lieutenant", CFrameQ = CFrame.new(-2440, 73, -3216), CFrameM = CFrame.new(-2821, 75, -3070)},
    {Min = 900, Max = 949, Quest = "MarineQuest3", LevelQ = 2, Mob = "Marine Captain", CFrameQ = CFrame.new(-2440, 73, -3216), CFrameM = CFrame.new(-1861, 80, -3254)},
    {Min = 950, Max = 974, Quest = "ZombieQuest", LevelQ = 1, Mob = "Zombie", CFrameQ = CFrame.new(-5497, 47, -795), CFrameM = CFrame.new(-5657, 78, -928)},
    {Min = 975, Max = 999, Quest = "ZombieQuest", LevelQ = 2, Mob = "Vampire", CFrameQ = CFrame.new(-5497, 47, -795), CFrameM = CFrame.new(-6037, 32, -1340)},
    {Min = 1000, Max = 1049, Quest = "SnowMountainQuest", LevelQ = 1, Mob = "Snow Trooper", CFrameQ = CFrame.new(609, 400, -5372), CFrameM = CFrame.new(549, 427, -5563)},
    {Min = 1050, Max = 1099, Quest = "SnowMountainQuest", LevelQ = 2, Mob = "Winter Warrior", CFrameQ = CFrame.new(609, 400, -5372), CFrameM = CFrame.new(1142, 475, -5199)},
    {Min = 1100, Max = 1124, Quest = "IceSideQuest", LevelQ = 1, Mob = "Lab Subordinate", CFrameQ = CFrame.new(-6064, 15, -4902), CFrameM = CFrame.new(-5707, 15, -4513)},
    {Min = 1125, Max = 1174, Quest = "IceSideQuest", LevelQ = 2, Mob = "Horned Warrior", CFrameQ = CFrame.new(-6064, 15, -4902), CFrameM = CFrame.new(-6341, 15, -5723)},
    {Min = 1175, Max = 1199, Quest = "FireSideQuest", LevelQ = 1, Mob = "Magma Ninja", CFrameQ = CFrame.new(-5428, 15, -5299), CFrameM = CFrame.new(-5449, 76, -5808)},
    {Min = 1200, Max = 1249, Quest = "FireSideQuest", LevelQ = 2, Mob = "Lava Pirate", CFrameQ = CFrame.new(-5428, 15, -5299), CFrameM = CFrame.new(-5213, 49, -4701)},
    {Min = 1250, Max = 1274, Quest = "ShipQuest1", LevelQ = 1, Mob = "Ship Deckhand", CFrameQ = CFrame.new(1037, 125, 32911), CFrameM = CFrame.new(1212, 150, 33059)},
    {Min = 1275, Max = 1299, Quest = "ShipQuest1", LevelQ = 2, Mob = "Ship Engineer", CFrameQ = CFrame.new(1037, 125, 32911), CFrameM = CFrame.new(919, 43, 32779)},
    {Min = 1300, Max = 1324, Quest = "ShipQuest2", LevelQ = 1, Mob = "Ship Steward", CFrameQ = CFrame.new(968, 125, 33244), CFrameM = CFrame.new(919, 129, 33436)},
    {Min = 1325, Max = 1349, Quest = "ShipQuest2", LevelQ = 2, Mob = "Ship Officer", CFrameQ = CFrame.new(968, 125, 33244), CFrameM = CFrame.new(1036, 181, 33315)},
    {Min = 1350, Max = 1374, Quest = "FrostQuest", LevelQ = 1, Mob = "Arctic Warrior", CFrameQ = CFrame.new(5667, 26, -6486), CFrameM = CFrame.new(5966, 62, -6179)},
    {Min = 1375, Max = 1424, Quest = "FrostQuest", LevelQ = 2, Mob = "Snow Lurker", CFrameQ = CFrame.new(5667, 26, -6486), CFrameM = CFrame.new(5407, 69, -6880)},
    {Min = 1425, Max = 1449, Quest = "ForgottenQuest", LevelQ = 1, Mob = "Sea Soldier", CFrameQ = CFrame.new(-3054, 235, -10142), CFrameM = CFrame.new(-3028, 64, -9775)},
    {Min = 1450, Max = 1499, Quest = "ForgottenQuest", LevelQ = 2, Mob = "Water Fighter", CFrameQ = CFrame.new(-3054, 235, -10142), CFrameM = CFrame.new(-3352, 285, -10534)},

    -- ================= SEA 3 (1500 - 2800) =================
    {Min = 1500, Max = 1524, Quest = "PiratePortQuest", LevelQ = 1, Mob = "Pirate Millionaire", CFrameQ = CFrame.new(-290, 42, 5581), CFrameM = CFrame.new(-245, 47, 5584)},
    {Min = 1525, Max = 1574, Quest = "PiratePortQuest", LevelQ = 2, Mob = "Pistol Billionaire", CFrameQ = CFrame.new(-290, 42, 5581), CFrameM = CFrame.new(-187, 86, 6013)},
    {Min = 1575, Max = 1599, Quest = "AmazonQuest", LevelQ = 1, Mob = "Dragon Crew Warrior", CFrameQ = CFrame.new(5832, 51, -1101), CFrameM = CFrame.new(6141, 51, -1340)},
    {Min = 1600, Max = 1624, Quest = "AmazonQuest", LevelQ = 2, Mob = "Dragon Crew Archer", CFrameQ = CFrame.new(5833, 51, -1103), CFrameM = CFrame.new(6616, 441, 446)},
    {Min = 1625, Max = 1649, Quest = "AmazonQuest2", LevelQ = 1, Mob = "Female Islander", CFrameQ = CFrame.new(5446, 601, 749), CFrameM = CFrame.new(4685, 735, 815)},
    {Min = 1650, Max = 1699, Quest = "AmazonQuest2", LevelQ = 2, Mob = "Giant Islander", CFrameQ = CFrame.new(5446, 601, 749), CFrameM = CFrame.new(4729, 590, -36)},
    {Min = 1700, Max = 1724, Quest = "MarineTreeIsland", LevelQ = 1, Mob = "Marine Commodore", CFrameQ = CFrame.new(2180, 27, -6741), CFrameM = CFrame.new(2286, 73, -7159)},
    {Min = 1725, Max = 1774, Quest = "MarineTreeIsland", LevelQ = 2, Mob = "Marine Rear Admiral", CFrameQ = CFrame.new(2179, 28, -6740), CFrameM = CFrame.new(3656, 160, -7001)},
    {Min = 1775, Max = 1799, Quest = "DeepForestIsland3", LevelQ = 1, Mob = "Fishman Raider", CFrameQ = CFrame.new(-10581, 330, -8761), CFrameM = CFrame.new(-10407, 331, -8368)},
    {Min = 1800, Max = 1824, Quest = "DeepForestIsland3", LevelQ = 2, Mob = "Fishman Captain", CFrameQ = CFrame.new(-10581, 330, -8761), CFrameM = CFrame.new(-10994, 352, -9002)},
    {Min = 1825, Max = 1849, Quest = "DeepForestIsland", LevelQ = 1, Mob = "Forest Pirate", CFrameQ = CFrame.new(-13234, 331, -7625), CFrameM = CFrame.new(-13274, 332, -7769)},
    {Min = 1850, Max = 1899, Quest = "DeepForestIsland", LevelQ = 2, Mob = "Mythological Pirate", CFrameQ = CFrame.new(-13234, 331, -7625), CFrameM = CFrame.new(-13680, 501, -6991)},
    {Min = 1900, Max = 1924, Quest = "DeepForestIsland2", LevelQ = 1, Mob = "Jungle Pirate", CFrameQ = CFrame.new(-12680, 389, -9902), CFrameM = CFrame.new(-12256, 331, -10485)},
    {Min = 1925, Max = 1974, Quest = "DeepForestIsland2", LevelQ = 2, Mob = "Musketeer Pirate", CFrameQ = CFrame.new(-12680, 389, -9902), CFrameM = CFrame.new(-13457, 391, -9859)},
    {Min = 1975, Max = 1999, Quest = "HauntedQuest1", LevelQ = 1, Mob = "Reborn Skeleton", CFrameQ = CFrame.new(-9479, 141, 5566), CFrameM = CFrame.new(-8763, 165, 6159)},
    {Min = 2000, Max = 2024, Quest = "HauntedQuest1", LevelQ = 2, Mob = "Living Zombie", CFrameQ = CFrame.new(-9479, 141, 5566), CFrameM = CFrame.new(-10144, 138, 5838)},
    {Min = 2025, Max = 2049, Quest = "HauntedQuest2", LevelQ = 1, Mob = "Demonic Soul", CFrameQ = CFrame.new(-9516, 172, 6078), CFrameM = CFrame.new(-9505, 172, 6158)},
    {Min = 2050, Max = 2074, Quest = "HauntedQuest2", LevelQ = 2, Mob = "Posessed Mummy", CFrameQ = CFrame.new(-9516, 172, 6078), CFrameM = CFrame.new(-9582, 6, 6205)},
    {Min = 2075, Max = 2099, Quest = "NutsIslandQuest", LevelQ = 1, Mob = "Peanut Scout", CFrameQ = CFrame.new(-2104, 38, -10194), CFrameM = CFrame.new(-2143, 47, -10029)},
    {Min = 2100, Max = 2124, Quest = "NutsIslandQuest", LevelQ = 2, Mob = "Peanut President", CFrameQ = CFrame.new(-2104, 38, -10194), CFrameM = CFrame.new(-1859, 38, -10422)},
    {Min = 2125, Max = 2149, Quest = "IceCreamIslandQuest", LevelQ = 1, Mob = "Ice Cream Chef", CFrameQ = CFrame.new(-820, 65, -10965), CFrameM = CFrame.new(-872, 65, -10919)},
    {Min = 2150, Max = 2199, Quest = "IceCreamIslandQuest", LevelQ = 2, Mob = "Ice Cream Commander", CFrameQ = CFrame.new(-820, 65, -10965), CFrameM = CFrame.new(-558, 112, -11290)},
    {Min = 2200, Max = 2224, Quest = "CakeQuest1", LevelQ = 1, Mob = "Cookie Crafter", CFrameQ = CFrame.new(-2021, 37, -12028), CFrameM = CFrame.new(-2374, 37, -12125)},
    {Min = 2225, Max = 2249, Quest = "CakeQuest1", LevelQ = 2, Mob = "Cake Guard", CFrameQ = CFrame.new(-2021, 37, -12028), CFrameM = CFrame.new(-1598, 43, -12244)},
    {Min = 2250, Max = 2274, Quest = "CakeQuest2", LevelQ = 1, Mob = "Baking Staff", CFrameQ = CFrame.new(-1927, 37, -12842), CFrameM = CFrame.new(-1887, 77, -12998)},
    {Min = 2275, Max = 2299, Quest = "CakeQuest2", LevelQ = 2, Mob = "Head Baker", CFrameQ = CFrame.new(-1927, 37, -12842), CFrameM = CFrame.new(-2216, 82, -12869)},
    {Min = 2300, Max = 2324, Quest = "ChocQuest1", LevelQ = 1, Mob = "Cocoa Warrior", CFrameQ = CFrame.new(233, 29, -12201), CFrameM = CFrame.new(-21, 80, -12352)},
    {Min = 2325, Max = 2349, Quest = "ChocQuest1", LevelQ = 2, Mob = "Chocolate Bar Battler", CFrameQ = CFrame.new(233, 29, -12201), CFrameM = CFrame.new(582, 77, -12463)},
    {Min = 2350, Max = 2374, Quest = "ChocQuest2", LevelQ = 1, Mob = "Sweet Thief", CFrameQ = CFrame.new(150, 30, -12774), CFrameM = CFrame.new(165, 76, -12600)},
    {Min = 2375, Max = 2399, Quest = "ChocQuest2", LevelQ = 2, Mob = "Candy Rebel", CFrameQ = CFrame.new(150, 30, -12774), CFrameM = CFrame.new(134, 77, -12876)},
    {Min = 2400, Max = 2424, Quest = "CandyQuest1", LevelQ = 1, Mob = "Candy Pirate", CFrameQ = CFrame.new(-1150, 20, -14446), CFrameM = CFrame.new(-1310, 26, -14562)},
    {Min = 2425, Max = 2449, Quest = "CandyQuest1", LevelQ = 2, Mob = "Snow Demon", CFrameQ = CFrame.new(-1150, 20, -14446), CFrameM = CFrame.new(-880, 71, -14538)},
    {Min = 2450, Max = 2474, Quest = "TikiQuest1", LevelQ = 1, Mob = "Isle Outlaw", CFrameQ = CFrame.new(-16547, 61, -173), CFrameM = CFrame.new(-16442, 116, -264)},
    {Min = 2475, Max = 2499, Quest = "TikiQuest1", LevelQ = 2, Mob = "Island Boy", CFrameQ = CFrame.new(-16547, 61, -173), CFrameM = CFrame.new(-16901, 84, -192)},
    {Min = 2500, Max = 2524, Quest = "TikiQuest2", LevelQ = 1, Mob = "Sun-kissed Warrior", CFrameQ = CFrame.new(-16539, 55, 1051), CFrameM = CFrame.new(-16349, 92, 1123)},
    {Min = 2525, Max = 2549, Quest = "TikiQuest2", LevelQ = 2, Mob = "Isle Champion", CFrameQ = CFrame.new(-16539, 55, 1051), CFrameM = CFrame.new(-16347, 92, 1122)},
    {Min = 2550, Max = 2574, Quest = "TikiQuest3", LevelQ = 1, Mob = "Serpent Hunter", CFrameQ = CFrame.new(-16661, 105, 1576), CFrameM = CFrame.new(-16521, 106, 1488)},
    {Min = 2575, Max = 2599, Quest = "TikiQuest3", LevelQ = 2, Mob = "Skull Slayer", CFrameQ = CFrame.new(-16661, 105, 1576), CFrameM = CFrame.new(-16855, 122, 1478)},
}

local QuestBySea = { {}, {}, {} }
for _, e in ipairs(QuestData) do
    local s = SeaOfLevel(e.Min)
    table.insert(QuestBySea[s], e)
end
for _, list in ipairs(QuestBySea) do
    table.sort(list, function(a, b) return a.Min < b.Min end)
end

local Dyn = {}
pcall(function()
    Dyn.Quests = require(ReplicatedStorage:WaitForChild("Quests", 5))
    Dyn.NPCList = require(ReplicatedStorage:WaitForChild("GuideModule", 5)).Data.NPCList
end)
local QuestBlacklist = { BartiloQuest = true, CitizenQuest = true, ImpelQuest = true }

local function PosOf(o)
    if typeof(o) ~= "Instance" then return nil end
    if o:IsA("BasePart") then return o.Position end
    if o:IsA("Model") then return o:GetPivot().Position end
end

local function MobSpawn(mob, near)
    local wo = Workspace:FindFirstChild("_WorldOrigin")
    local sp = wo and wo:FindFirstChild("EnemySpawns")
    if not sp then return nil end
    local lm, best, bd = mob:lower()
    for _, p in ipairs(sp:GetChildren()) do
        if p.Name:lower():find(lm, 1, true) then
            local pos = PosOf(p)
            if pos then
                local d = near and (pos - near).Magnitude or 0
                if not bd or d < bd then best, bd = pos, d end
            end
        end
    end
    return best
end

local function BestQuest(lvl, accept)
    local bestId, bestList, bestReq = nil, nil, -1
    for id, list in pairs(Dyn.Quests or {}) do
        local first = type(list) == "table" and list[1]
        local req = first and first.LevelReq
        if req and req <= lvl and req > bestReq and type(first.Task) == "table" then
            local mob = next(first.Task)
            if mob ~= nil and accept(tostring(id), tostring(mob)) then bestId, bestList, bestReq = tostring(id), list, req end
        end
    end
    return bestId, bestList
end

local function QuestIndex(list, lvl)
    local idx
    for i, e in ipairs(list) do
        local single = false
        for _, n in pairs(e.Task or {}) do if n == 1 then single = true end end
        if not single and (e.LevelReq or 0) <= lvl then idx = i end
    end
    return idx
end

local function ResolveDynamic()
    if not (Dyn.Quests and Dyn.NPCList) then return nil end
    local lvl = math.max(1, Level())
    local _, hrp = GetChar()
    local near = hrp and hrp.Position
    local starter = lvl < 10 and ((LocalPlayer.Team and LocalPlayer.Team.Name == "Marines") and "trainee" or "bandit")
    local bestId, bestList = BestQuest(lvl, function(id, mob)
        if QuestBlacklist[id] or id:find("^Submerged") then return false end
        if starter and not mob:lower():find(starter, 1, true) then return false end
        for _, s in ipairs(QuestBySea[Sea]) do if s.Quest == id then return true end end
        return MobSpawn(mob, near) ~= nil
    end)
    if not bestId then return nil end

    local idx = QuestIndex(bestList, lvl)
    if not idx then return nil end
    local e = bestList[idx]
    local mob = tostring(next(e.Task))

    local static
    for _, s in ipairs(QuestBySea[Sea]) do
        if s.Quest == bestId and s.LevelQ == idx then static = s break end
    end

    local mpos = MobSpawn(mob, near)
    local qcf
    if mpos then
        local bd
        for k, v in pairs(Dyn.NPCList) do
            if type(v) == "table" and v.Levels and table.find(v.Levels, e.LevelReq) then
                local p = PosOf(k)
                if p then
                    local d = (p - mpos).Magnitude
                    if not bd or d < bd then bd, qcf = d, CFrame.new(p) end
                end
            end
        end
    end
    qcf = qcf or (static and static.CFrameQ)
    local mcf = mpos and CFrame.new(mpos) or (static and static.CFrameM)
    if not (qcf and mcf) then return nil end
    return { Quest = bestId, LevelQ = idx, Mob = mob, CFrameQ = qcf, CFrameM = mcf }
end

local function GetQuestEntry()
    if Config.DynamicQuests then
        local ok, d = pcall(Cached, "dynq" .. tostring(Level()), 5, ResolveDynamic)
        if ok and d then return d end
    end
    local list = QuestBySea[Sea]
    local lvl, pick = Level(), list[1]
    for _, e in ipairs(list) do
        if lvl >= e.Min then pick = e end
    end
    return pick
end

local function QuestMatches(title, mob)
    title, mob = title:lower(), mob:lower()
    local forms = { mob, mob .. "s", mob .. "es" }
    if mob:sub(-1) == "y" then table.insert(forms, mob:sub(1, -2) .. "ies") end
    if mob:sub(-3) == "man" then table.insert(forms, mob:sub(1, -4) .. "men") end
    for _, f in ipairs(forms) do
        if title:find(f, 1, true) then return true end
    end
    return false
end

local function QuestUI()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local main = pg and pg:FindFirstChild("Main")
    return main and main:FindFirstChild("Quest")
end

-- Kiểm tra nhiệm vụ đang hoạt động qua cả UI và QuestGui mới của Blox Fruits
local function QuestVisible()
    local q = QuestUI()
    if q and q.Visible then
        local container = q:FindFirstChild("Container")
        if not container or not container:IsA("GuiObject") or container.Visible then
            return true
        end
    end
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        for _, guiName in ipairs({ "QuestGui", "QuestFrame" }) do
            local g = pg:FindFirstChild(guiName)
            if g and g:IsA("ScreenGui") and g.Enabled then
                return true
            end
        end
    end
    return false
end

local function QuestTitle()
    local q = QuestUI()
    local c = q and q:FindFirstChild("Container")
    local t = c and c:FindFirstChild("QuestTitle")
    local tt = t and t:FindFirstChild("Title")
    if tt and tt.Text and tt.Text ~= "" then return tt.Text end

    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local qg = pg and pg:FindFirstChild("QuestGui")
    if qg then
        for _, obj in ipairs(qg:GetDescendants()) do
            if obj:IsA("TextLabel") and obj.Text:find("Defeat", 1, true) then
                return obj.Text
            end
        end
    end
    return ""
end

local function Throttle(key, seconds)
    local k, now = "T:" .. key, tick()
    if (CacheStore[k] or 0) + seconds > now then return false end
    CacheStore[k] = now
    return true
end

local function HasTool(name)
    local c, bp = LocalPlayer.Character, LocalPlayer:FindFirstChild("Backpack")
    return (c and c:FindFirstChild(name) ~= nil) or (bp and bp:FindFirstChild(name) ~= nil) or false
end

local function RawInventory()
    return Cached("inventory_raw", 8, function() return Invoke("getInventory") end)
end

local function Inventory()
    return Cached("inventory", 8, function()
        local set = {}
        local inv = RawInventory()
        if type(inv) == "table" then
            for _, it in pairs(inv) do
                if type(it) == "table" and it.Name then set[it.Name] = true
                elseif type(it) == "string" then set[it] = true end
            end
        end
        return set
    end)
end

local function Owns(...)
    local inv = Inventory()
    for _, n in ipairs({ ... }) do
        if HasTool(n) or inv[n] then return true end
    end
    return false
end

--// ===================== BỘ ĐIỀU PHỐI TÁC VỤ =====================
local Tasks = {}
local function AddTask(name, enabled, step)
    table.insert(Tasks, { Name = name, Enabled = enabled, Step = step })
end

--// ---- 1. Boss ưu tiên ----
do
    local BossList = {
        { "dough king" },
        { "rip_indra", "rip indra" },
        { "darkbeard", "dark beard" },
    }
    local cache = { boss = nil, t = 0 }

    local function Priority(name)
        local lower = name:lower()
        for i, kws in ipairs(BossList) do
            for _, kw in ipairs(kws) do
                if lower:find(kw, 1, true) then return i end
            end
        end
    end

    local function FindBoss()
        if tick() - cache.t < 0.5 then
            if cache.boss and cache.boss.Parent and Alive(cache.boss) then return cache.boss end
            if not cache.boss then return nil end
        end
        cache.t, cache.boss = tick(), nil
        local bestP = math.huge
        for _, container in ipairs({ EnemiesFolder(), Workspace }) do
            if container then
                for _, obj in ipairs(container:GetChildren()) do
                    if obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj) and Alive(obj) then
                        local p = Priority(obj.Name)
                        if p and p < bestP then bestP, cache.boss = p, obj end
                    end
                end
            end
        end
        return cache.boss
    end

    AddTask("Boss", function() return Config.AutoBoss end, function()
        local boss = FindBoss()
        if not boss then return false end
        local _, bh = Alive(boss)
        if not bh then return false end
        SetStatus("Boss: " .. boss.Name)
        Combat.Fight(bh, Config.BossHeight)
        return true
    end)
end

--// ---- 1b. Race V4 ----
do
    local Temple = { AuraAt = 0 }
    local TEMPLE_CF = CFrame.new(28286.35546875, 14896.5078125, 102.62469482422)
    local PRE_CF = CFrame.new(3028, 2281, -7325)

    local function DoorOpen()
        return Cached("door", 5, function() return Invoke("CheckTempleDoor") == true end)
    end

    local function MirageIsland()
        local wo = Workspace:FindFirstChild("_WorldOrigin")
        local loc = wo and wo:FindFirstChild("Locations")
        return loc and loc:FindFirstChild("Mirage Island")
    end

    local function MirageGear()
        local map = Workspace:FindFirstChild("Map")
        local mi = map and map:FindFirstChild("MysticIsland")
        if not mi then return nil end
        for _, p in ipairs(mi:GetChildren()) do
            if p:IsA("MeshPart") and p.MeshId == "rbxassetid://10153114969" then return p end
        end
    end

    local function IsNight()
        local t = Lighting.ClockTime
        return t >= 16 or t < 5
    end

    local function Aura()
        if tick() - Temple.AuraAt < 15 then return end
        Temple.AuraAt = tick()
        pcall(function()
            local util = require(ReplicatedStorage:WaitForChild("Util"))
            local fx = require(ReplicatedStorage.Effect.Container.RaceAura)
            fx({
                Character = LocalPlayer.Character, Index = 1, Duration = 15,
                Timestamp = util.MasterClock:GetTime(), Race = "Fishman", NoSound = true,
            })
        end)
    end

    local function Hop()
        pcall(function()
            local sb = ReplicatedStorage:FindFirstChild("__ServerBrowser")
            if not sb then return end
            for page = 1, 5 do
                local servers = sb:InvokeServer(page)
                if type(servers) == "table" then
                    for jobId, info in pairs(servers) do
                        if jobId ~= game.JobId and type(info) == "table" and (info.Count or 99) < 11 then
                            sb:InvokeServer("teleport", jobId)
                            return
                        end
                    end
                end
            end
        end)
    end

    AddTask("TempleLever", function()
        return Config.AutoPullLever and Sea == 3 and Level() >= Config.LeverMinLevel
    end, function(c, hrp, hum)
        if DoorOpen() then
            hum.AutoRotate = true
            return false
        end
        hum.AutoRotate = true

        local prog = Cached("v4prog", 2, function() return Invoke("RaceV4Progress", "Check") end)
        if prog ~= 4 then
            SetStatus("V4: tiến độ " .. tostring(prog))
            if prog == 1 then
                if Throttle("v4begin", 3) then
                    Invoke("RaceV4Progress", "Begin")
                    CacheStore.v4prog = nil
                end
            elseif prog == 2 then
                if (hrp.Position - TEMPLE_CF.Position).Magnitude > 15 then
                    if Throttle("v4tp", 2) then Invoke("RaceV4Progress", "Teleport") end
                    MoveTo(PRE_CF)
                else
                    SetStatus("V4: đang ở Temple of Time (bước 2)")
                end
            else
                if Throttle("v4cont", 3) then
                    Invoke("RaceV4Progress", "Continue")
                    CacheStore.v4prog = nil
                end
            end
            return true
        end

        local mirage = MirageIsland()
        if not mirage then
            SetStatus("V4: chờ Mirage Island")
            if Config.HopForMirage and Throttle("hop", 20) then Hop() end
            return false
        end

        local gear = MirageGear()
        if gear and gear.Transparency == 0 then
            SetStatus("V4: nhặt bánh răng xanh")
            MoveTo(gear.CFrame)
            return true
        end

        local top = mirage:GetPivot() * CFrame.new(0, 350, 0)
        if not Near(top, 25) then
            SetStatus("V4: bay lên Mirage Island")
            MoveTo(top)
            return true
        end
        StopTween()

        if IsNight() then
            SetStatus("V4: nhìn trăng + kích hoạt aura")
            local cam = Workspace.CurrentCamera
            local target = cam.CFrame.Position + Lighting:GetMoonDirection() * 100
            cam.CFrame = CFrame.lookAt(cam.CFrame.Position, target)
            hum.AutoRotate = false
            hrp.CFrame = CFrame.lookAt(hrp.Position, target)
            hum.Sit = false
            Aura()
        else
            SetStatus("V4: chờ trời tối")
        end
        return true
    end)
end

--// ---- 2. Mở khóa Sea ----
do
    local function Enabled()
        return Config.AutoUnlockSea and ((Sea == 1 and Level() >= 700) or (Sea == 2 and Level() >= Config.BartiloMinLevel))
    end

    local function KillOrGoto(name, spawnCF)
        Hunt(name, spawnCF, { exact = false, height = Config.FarmHeight + 2 })
    end

    AddTask("SeaUnlock", Enabled, function()
        if Sea == 1 then
            local p = Cached("dressrosa", 2, function() return Invoke("DressrosaQuestProgress") end)
            if p == 2 then
                SetStatus("Chuyển sang Sea 2")
                if Throttle("traveld", 5) then Invoke("TravelDressrosa") end
                return true
            elseif p == 0 then
                SetStatus("Sea 2: nhận quest Detective")
                local cf = CFrame.new(4850, 5, 718)
                if not Near(cf, 12) then MoveTo(cf)
                else
                    StopTween()
                    if Throttle("detective", 3) then
                        Invoke("DressrosaQuestProgress", "Detective")
                        CacheStore.dressrosa = nil
                    end
                end
                return true
            elseif p == 1 then
                SetStatus("Sea 2: đánh Ice Admiral")
                KillOrGoto("Ice Admiral", CFrame.new(1347, 37, -1325))
                return true
            end
            return false
        elseif Sea == 2 then
            if Level() >= 1500 then
                local z = Cached("zq", 2, function() return Invoke("ZQuestProgress", "Check") end)
                if z == 1 then
                    SetStatus("Chuyển sang Sea 3")
                    if Throttle("travelz", 5) then Invoke("TravelZou") end
                    return true
                end
            end
            local b = Cached("bq", 2, function() return Invoke("BartiloQuestProgress") end)
            if b == 0 then
                SetStatus("Sea 3: quest Bartilo (Swan Pirate)")
                if not QuestVisible() then
                    local cf = CFrame.new(-456, 73, 299)
                    if not Near(cf, 12) then MoveTo(cf)
                    else
                        StopTween()
                        if Throttle("bartilo", 2) then Invoke("StartQuest", "BartiloQuest", 1) end
                    end
                else
                    KillOrGoto("Swan Pirate", CFrame.new(1068, 137, 1322))
                end
                return true
            elseif b == 1 then
                SetStatus("Sea 3: đánh Jeremy")
                KillOrGoto("Jeremy", CFrame.new(2165, 448, 745))
                return true
            end
            return false
        end
        return false
    end)
end

--// ---- 3. Raid ----
do
    local Raid = { Island = 1, Empty = nil }
    local pads = { [2] = CFrame.new(-6438, 250, -4501), [3] = CFrame.new(-5057, 314, -2991) }

    local function InRaid()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local main = pg and pg:FindFirstChild("Main")
        local hud = main and main:FindFirstChild("TopHUDList")
        local t = hud and hud:FindFirstChild("RaidTimer")
        return t ~= nil and t.Visible == true
    end

    local function AcquireChip()
        if not Throttle("chip", 30) then return end
        if Config.AutoBuyChipBeli and Beli() >= 100000 then
            Invoke("RaidsNpc", "Select", Config.SelectChip)
        end
        if HasTool("Microchip") or not Config.AutoTradeTrashFruit then return end
        local inv = RawInventory()
        if type(inv) ~= "table" then return end
        for _, it in pairs(inv) do
            if type(it) == "table" and it.Type == "Blox Fruit" and it.Value and it.Value < 1000000 then
                Invoke("LoadFruit", it.Name)
                task.wait(0.3)
                Invoke("RaidsNpc", "Select", Config.SelectChip)
                break
            end
        end
    end

    local function StartRaid()
        local pad = pads[Sea]
        if not pad then return end
        if not Near(pad, 15) then MoveTo(pad) return end
        StopTween()
        if not Throttle("startraid", 5) then return end
        pcall(function()
            local map = Workspace:FindFirstChild("Map")
            local root = Sea == 2 and map and map:FindFirstChild("CircleIsland")
                or (map and map:FindFirstChild("Boat Castle"))
            local btn = root and root.RaidSummon2.Button.Main
            if btn and btn:FindFirstChild("ClickDetector") and fireClick then
                fireClick(btn.ClickDetector)
            end
        end)
    end

    local function Enabled()
        return Config.AutoRaid and Sea >= 2 and Level() >= Config.RaidMinLevel
    end

    AddTask("Raid", Enabled, function()
        local _, hrp = GetChar()
        if InRaid() then
            local mob = NearestEnemy(nil)
            if mob then
                Raid.Empty = nil
                local _, mh = Alive(mob)
                SetStatus("Raid: " .. mob.Name)
                if Config.KillAuraRaid then Bring.Set(nil, mh.CFrame) end
                Combat.Fight(mh, Config.FarmHeight)
            else
                local locations = Workspace:FindFirstChild("_WorldOrigin")
                locations = locations and locations:FindFirstChild("Locations")
                local island = locations and locations:FindFirstChild("Island " .. Raid.Island)
                if island then
                    local cf = island:GetPivot() * CFrame.new(0, 60, 0)
                    SetStatus("Raid: tới đảo " .. Raid.Island)
                    if Near(cf, 60) then
                        Raid.Empty = Raid.Empty or tick()
                        if tick() - Raid.Empty > 4 then
                            Raid.Island = math.min(Raid.Island + 1, 5)
                            Raid.Empty = nil
                        end
                    else
                        Raid.Empty = nil
                        MoveTo(cf)
                    end
                end
            end
            return true
        end
        Raid.Island, Raid.Empty = 1, nil
        if not HasTool("Microchip") then
            AcquireChip()
            if not HasTool("Microchip") then return false end
        end
        SetStatus("Raid: bắt đầu")
        StartRaid()
        return true
    end)
end

--// ---- 3b. Nâng tộc V2 ----
do
    local function Evolved()
        local r = Data:FindFirstChild("Race")
        return r ~= nil and r:FindFirstChild("Evolved") ~= nil
    end
    local function HasFlower(n) return HasTool("Flower " .. n) or HasTool("Flower" .. n) end

    AddTask("RaceV2", function()
        return Config.AutoRaceV2 and Sea == 2 and Level() >= 850 and not Evolved()
    end, function()
        local f1, f2, f3 = HasFlower(1), HasFlower(2), HasFlower(3)
        if not (f1 or f2 or f3) then
            if Beli() < 500000 then return false end
            if Throttle("alch1", 30) then Invoke("Alchemist", "1") end
        end
        if f1 and f2 and f3 then
            SetStatus("Race V2: nộp hoa")
            if Throttle("alch23", 5) then
                Invoke("Alchemist", "2")
                Invoke("Alchemist", "3")
            end
            return false
        end
        local name, spawn
        if not f2 then name, spawn = "Swan Pirate", CFrame.new(1068, 137, 1322)
        elseif not f3 then name, spawn = "Zombie", CFrame.new(-5657, 78, -928) end
        if not name then return false end
        SetStatus("Race V2: farm hoa từ " .. name)
        Hunt(name, spawn, { bring = true })
        return true
    end)
end

--// ---- 3c. Submerged Island ----
do
    local WORKER_CF = CFrame.new(-16269.41, 23.98, 1371.66)
    local SUB_CENTER = Vector3.new(11256, -2138, 9888)
    local S = { Key = nil, Mob = nil, Last = 0, Fails = 0, Until = 0 }

    local function InSub(pos) return (pos - SUB_CENTER).Magnitude < 4200 end

    local function NpcCF(name)
        for _, root in ipairs({ Workspace:FindFirstChild("NPCs"), ReplicatedStorage:FindFirstChild("NPCs") }) do
            local p = PosOf(root and root:FindFirstChild(name, true))
            if p then return CFrame.new(p) end
        end
    end

    AddTask("Submerged", function()
        return Config.AutoSubmerged and Sea == 3 and Level() >= Config.SubmergedMinLevel and tick() > S.Until
    end, function(c, hrp)
        local lvl = Level()
        local id, list = BestQuest(lvl, function(k) return k:find("^Submerged") ~= nil end)
        local idx = id and QuestIndex(list, lvl)
        if not idx then return false end
        local mob = tostring(next(list[idx].Task))
        local key = id .. ":" .. idx

        if not InSub(hrp.Position) then
            SetStatus("Submerged: đi tàu ngầm")
            if not Near(WORKER_CF, 8) then MoveTo(WORKER_CF) return true end
            StopTween()
            if Throttle("subtravel", 5) then
                S.Fails = S.Fails + 1
                if S.Fails > 4 then
                    S.Fails, S.Until = 0, tick() + 120
                    return false
                end
                local m = ReplicatedStorage:FindFirstChild("Modules")
                local net = m and m:FindFirstChild("Net")
                local rf = net and net:FindFirstChild("RF/SubmarineWorkerSpeak")
                if rf then pcall(function() rf:InvokeServer("TravelToSubmergedIsland") end) end
                Invoke("SetLastSpawnPoint", "SubmergedIsland")
            end
            return true
        end
        S.Fails = 0

        if QuestVisible() then
            if S.Key then
                mob = S.Mob
            elseif not QuestMatches(QuestTitle(), mob) then
                if Throttle("subabandon", 2) then Invoke("AbandonQuest") end
                return true
            else
                S.Key, S.Mob = key, mob
            end
        else
            if S.Key and tick() - S.Last > 2 then S.Key = nil end
            SetStatus("Submerged: nhận quest " .. mob)
            local cf = NpcCF("Submerged Quest Giver " .. (id:match("%d+$") or "1"))
            if not cf then MoveTo(CFrame.new(SUB_CENTER)) return true end
            if not Near(cf, 12) then MoveTo(cf) return true end
            StopTween()
            if Throttle("substart", 1.5) then
                Invoke("StartQuest", id, idx)
                S.Key, S.Mob, S.Last = key, mob, tick()
            end
            return true
        end

        SetStatus("Submerged: farm " .. mob .. " (Lv " .. tostring(lvl) .. ")")
        local sp = MobSpawn(mob, hrp.Position)
        Hunt(mob, CFrame.new(sp or SUB_CENTER), { bring = true })
        return true
    end)
end

--// ---- 3d. Tác vụ phụ ----
do
    local function MakeBudget(runKey, restKey)
        local B = { Start = nil, Until = 0 }
        function B.Ready() return tick() >= B.Until end
        function B.Track(busy)
            if busy then
                B.Start = B.Start or tick()
                if tick() - B.Start > (Config[runKey] or 240) then
                    B.Start, B.Until = nil, tick() + (Config[restKey] or 300)
                end
            else
                B.Start = nil
            end
            return busy
        end
        return B
    end

    local function FindByKeywords(keywords, inWorkspace)
        local roots = { EnemiesFolder() }
        if inWorkspace then table.insert(roots, Workspace) end
        for _, root in ipairs(roots) do
            for _, m in ipairs(root:GetChildren()) do
                if m:IsA("Model") and not Players:GetPlayerFromCharacter(m) then
                    local lower = m.Name:lower()
                    for _, kw in ipairs(keywords) do
                        if lower:find(kw, 1, true) then
                            local hum, hrp = Alive(m)
                            if hum then return m, hrp end
                        end
                    end
                end
            end
        end
    end

    local function HasKeyword(keywords)
        local function scan(cont)
            if not cont then return false end
            for _, it in ipairs(cont:GetChildren()) do
                local l = it.Name:lower()
                for _, kw in ipairs(keywords) do
                    if l:find(kw, 1, true) then return true end
                end
            end
            return false
        end
        if scan(LocalPlayer:FindFirstChild("Backpack")) or scan(LocalPlayer.Character) then return true end
        for name in pairs(Inventory()) do
            local l = tostring(name):lower()
            for _, kw in ipairs(keywords) do
                if l:find(kw, 1, true) then return true end
            end
        end
        return false
    end

    local function ToolKw(keywords, equip)
        local c, _, hum = GetChar()
        if not c then return nil end
        for _, cont in ipairs({ c, LocalPlayer:FindFirstChild("Backpack") }) do
            if cont then
                for _, t in ipairs(cont:GetChildren()) do
                    if t:IsA("Tool") then
                        local l = t.Name:lower()
                        for _, kw in ipairs(keywords) do
                            if l:find(kw, 1, true) then
                                if equip and t.Parent ~= c then hum:EquipTool(t) end
                                return t
                            end
                        end
                    end
                end
            end
        end
    end

    local function InteractNearby(radius)
        local _, hrp = GetChar()
        if not hrp then return end
        local ok, parts = pcall(function() return Workspace:GetPartBoundsInRadius(hrp.Position, radius or 22) end)
        if not ok or type(parts) ~= "table" then return end
        for _, part in ipairs(parts) do
            local pp = part:FindFirstChildWhichIsA("ProximityPrompt")
            if pp then
                pcall(function()
                    pp.HoldDuration = 0
                    if fireproximityprompt then fireproximityprompt(pp) end
                end)
            end
            local cd = part:FindFirstChildWhichIsA("ClickDetector")
            if cd and fireClick then pcall(fireClick, cd) end
        end
    end

    local function GoAndDo(cf, key, interval, fn)
        if not Near(cf, 12) then MoveTo(cf) return end
        StopTween()
        if Throttle(key, interval) then fn() end
    end

    do
        local B = MakeBudget("LeverRunSeconds", "LeverRestSeconds")
        local L = { Targets = {}, ScanAt = 0, Index = 1 }

        local function Ready()
            return HasKeyword({ "mirror fractal", "mảnh gương" }) and HasKeyword({ "valkyrie helmet", "rip_indra", "mũ rip" })
        end

        local function Scan()
            if tick() - L.ScanAt < 15 then return L.Targets end
            L.ScanAt = tick()
            local list = {}
            for _, d in ipairs(Workspace:GetDescendants()) do
                if d:IsA("ClickDetector") or d:IsA("ProximityPrompt") then
                    local par = d.Parent
                    local pn = par and par.Name:lower() or ""
                    local gn = (par and par.Parent) and par.Parent.Name:lower() or ""
                    local pt = d:IsA("ProximityPrompt") and (d.ActionText .. " " .. d.ObjectText):lower() or ""
                    if pn:find("lever") or pn:find("switch") or pn:find("button")
                        or gn:find("lever") or gn:find("temple")
                        or pt:find("lever") or pt:find("pull") or pt:find("gạt") then
                        local part = par and (par:IsA("BasePart") and par or par:FindFirstChildWhichIsA("BasePart", true))
                        if part then table.insert(list, { det = d, part = part }) end
                    end
                end
            end
            L.Targets = list
            return list
        end

        AddTask("MirrorLever", function()
            return Config.AutoLever and B.Ready() and Cached("leverready", 3, Ready)
        end, function()
            if Throttle("leverremote", 10) then
                task.spawn(function()
                    Invoke("Candles")
                    Invoke("ActivateLever")
                    Invoke("PullLever")
                    Invoke("TempleOfTime", "Lever")
                end)
            end
            local targets = Scan()
            local t = targets[L.Index]
            if not t then
                L.Index, L.ScanAt = 1, 0
                B.Until = tick() + (Config.LeverRestSeconds or 600)
                return false
            end
            if not (t.part and t.part.Parent) then
                L.Index = L.Index + 1
                return true
            end
            SetStatus("Gạt cần: " .. t.part.Name)
            local goal = t.part.CFrame * CFrame.new(0, 3, 2)
            if not Near(goal, 8) then MoveTo(goal) return B.Track(true) end
            StopTween()
            if Throttle("leverfire", 0.6) then
                if t.det:IsA("ClickDetector") then
                    if fireClick then pcall(fireClick, t.det) end
                else
                    pcall(function()
                        t.det.HoldDuration = 0
                        if fireproximityprompt then fireproximityprompt(t.det) end
                    end)
                end
                L.Index = L.Index + 1
            end
            return B.Track(true)
        end)
    end

    do
        local B = MakeBudget("QuestItemRunSeconds", "QuestItemRestSeconds")
        local YAMA_CF     = CFrame.new(5226, 20, 725)
        local TUSHITA_CF  = CFrame.new(-10751, 417, -9366)
        local ALTAR_CF    = CFrame.new(-12356, 603, -6551)
        local GODHUMAN_CF = CFrame.new(-13781, 332, -9875)
        local SANGUINE_CF = CFrame.new(-16514, 105, 1545)

        local function Yama()
            if Owns("Yama") then return false end
            SetStatus("Quest item: Yama")
            GoAndDo(YAMA_CF, "q_yama", 2, function() Invoke("LoadItem", "Yama") end)
            return true
        end

        local function Tushita()
            if Owns("Tushita") then return false end
            SetStatus("Quest item: Tushita")
            local _, lh = FindByKeywords({ "longma" })
            if lh then Combat.Fight(lh, 16) return true end
            GoAndDo(TUSHITA_CF, "q_tushita", 2, function() Invoke("TushitaProgress") end)
            return true
        end

        local function CDK()
            if Owns("Cursed Dual Katana") then return false end
            if not Owns("Yama") then return Yama() end
            if not Owns("Tushita") then return Tushita() end
            SetStatus("Quest item: CDK")
            local _, ch = FindByKeywords({ "cursed", "soul" })
            if ch then Combat.Fight(ch, 16) return true end
            Cached("cdkprog", 10, function() return Invoke("CDKQuest", "Progress") end)
            GoAndDo(ALTAR_CF, "q_cdk", 3, function() Invoke("CDKQuest", "StartTrial") end)
            return true
        end

        local function HighMelee(style)
            local owned = (style == "SanguineArt") and Owns("Sanguine Art", "SanguineArt") or Owns(style)
            if owned then return false end
            if Beli() < 5000000 or Fragments() < 5000 then return false end
            SetStatus("Quest item: " .. style)
            if style == "Godhuman" then
                GoAndDo(GODHUMAN_CF, "q_god", 3, function() Invoke("BuyGodhuman") end)
            else
                GoAndDo(SANGUINE_CF, "q_sang", 3, function() Invoke("BuySanguineArt") end)
            end
            return true
        end

        local Handlers = {
            CDK = CDK, Tushita = Tushita, Yama = Yama,
            Godhuman = function() return HighMelee("Godhuman") end,
            SanguineArt = function() return HighMelee("SanguineArt") end,
        }

        AddTask("QuestItem", function()
            return Config.AutoQuestItems and Sea == 3 and Level() >= (Config.QuestItemMinLevel or 1500)
                and B.Ready() and Handlers[Config.TargetQuestItem] ~= nil
        end, function()
            return B.Track(Handlers[Config.TargetQuestItem]())
        end)
    end

    do
        local B = MakeBudget("SaberRunSeconds", "SaberRestSeconds")
        local Loc = {
            JungleHole     = CFrame.new(-1612, 20, 145),
            DesertRedHouse = CFrame.new(1090, 18, 4345),
            FrozenCave     = CFrame.new(1345, 87, -1325),
            SickMan        = CFrame.new(1455, 88, -1210),
            RichMan        = CFrame.new(-905, 16, 4065),
            SaberDoor      = CFrame.new(-1424, 30, -28),
        }
        local S = { Stage = nil, CaveAt = nil, MobSeen = false, RichAt = nil }

        AddTask("Saber", function()
            return Config.AutoSaberQuest and Sea == 1 and Level() >= (Config.SaberMinLevel or 200)
                and B.Ready() and not Cached("hassaber", 10, function() return HasKeyword({ "saber" }) end)
        end, function()
            if Throttle("saberprosg", 10) then
                task.spawn(function() Invoke("ProSG", 1) Invoke("ProSG", 2) end)
            end

            if ToolKw({ "relic", "thánh tích" }, true) then
                SetStatus("Saber: cửa Saber Expert")
                local _, bh = FindByKeywords({ "saber expert", "shanks" }, true)
                if bh then Combat.Fight(bh, 14) return B.Track(true) end
                if not Near(Loc.SaberDoor, 10) then MoveTo(Loc.SaberDoor) return B.Track(true) end
                StopTween()
                if Throttle("saberint", 0.7) then InteractNearby(22) end
                return B.Track(true)
            end

            if ToolKw({ "cup", "cốc" }, true) then
                if S.Stage ~= "sick" then
                    SetStatus("Saber: hứng nước hang Frozen")
                    if not Near(Loc.FrozenCave, 10) then MoveTo(Loc.FrozenCave) return B.Track(true) end
                    StopTween()
                    S.CaveAt = S.CaveAt or tick()
                    if Throttle("saberint", 1) then InteractNearby(22) end
                    if tick() - S.CaveAt > 2 then S.Stage, S.CaveAt = "sick", nil end
                    return B.Track(true)
                end
                SetStatus("Saber: đưa cốc cho Sick Man")
                if not Near(Loc.SickMan, 10) then MoveTo(Loc.SickMan) return B.Track(true) end
                StopTween()
                if Throttle("sabersick", 2) then
                    task.spawn(Invoke, "ProSG", 3)
                    InteractNearby(22)
                end
                return B.Track(true)
            end
            S.Stage, S.CaveAt = nil, nil

            if ToolKw({ "torch", "đuốc" }, true) then
                SetStatus("Saber: đốt rèm nhà đỏ Desert")
                if not Near(Loc.DesertRedHouse, 10) then MoveTo(Loc.DesertRedHouse) return B.Track(true) end
                StopTween()
                if Throttle("saberint", 0.8) then InteractNearby(22) end
                return B.Track(true)
            end

            local _, mh = FindByKeywords({ "mob leader" }, true)
            if mh then
                SetStatus("Saber: đánh Mob Leader")
                S.MobSeen, S.RichAt = true, nil
                Combat.Fight(mh, 14)
                return B.Track(true)
            end
            if S.MobSeen then
                SetStatus("Saber: gặp Rich Man")
                if not Near(Loc.RichMan, 10) then MoveTo(Loc.RichMan) return B.Track(true) end
                StopTween()
                S.RichAt = S.RichAt or tick()
                if Throttle("saberrich", 2) then
                    task.spawn(Invoke, "ProSG", 4)
                    InteractNearby(22)
                end
                if tick() - S.RichAt > 8 then S.MobSeen, S.RichAt = false, nil end
                return B.Track(true)
            end

            SetStatus("Saber: Jungle")
            if not Near(Loc.JungleHole, 10) then MoveTo(Loc.JungleHole) return B.Track(true) end
            StopTween()
            if Throttle("saberint", 1) then InteractNearby(22) end
            return B.Track(true)
        end)
    end
end

--// ---- 4. Farm level (FIX NHẬN NV XONG BAY ĐI ĐÁNH QUÁI NGAY) ----
do
    local Farm = {
        ActiveEntry = nil,
        LastStart = 0,
        WaitingQuest = false,
    }

    local function QuestProgress()
        local n, m = QuestTitle():match("%((%d+)%s*/%s*(%d+)%)")
        if n and m then return tonumber(n), tonumber(m) end
    end

    AddTask("Farm", function() return Config.AutoFarm end, function()
        local Q = GetQuestEntry()
        local target = Q

        if Config.AutoQuest then
            local now = tick()
            local visible = QuestVisible()

            if visible then
                Farm.WaitingQuest = false

                local n, m = QuestProgress()
                if n and m and n >= m then
                    SetStatus("Đang hoàn thành nhiệm vụ...")
                    return true
                end

                if Farm.ActiveEntry then
                    target = Farm.ActiveEntry
                elseif QuestMatches(QuestTitle(), Q.Mob) then
                    Farm.ActiveEntry = Q
                    target = Q
                else
                    if Throttle("abandon", 2) then
                        Invoke("AbandonQuest")
                    end
                    return true
                end
            else
                -- Nếu đã bấm nhận nhiệm vụ thành công và đã qua 0.4s (đủ để server xử lý quest), chuyển ngay sang đánh quái thay vì đứng chờ 3.5s
                if Farm.WaitingQuest and (now - Farm.LastStart) < 0.4 then
                    SetStatus("Đang nhận nhiệm vụ " .. Q.Mob .. "...")
                    return true
                end

                if not Farm.WaitingQuest then
                    Farm.ActiveEntry = nil
                    SetStatus("Đi nhận quest: " .. Q.Mob)
                    if not Near(Q.CFrameQ, 12) then
                        MoveTo(Q.CFrameQ)
                        return true
                    end

                    StopTween()
                    if Throttle("startquest", 1.5) then
                        Farm.LastStart = tick()
                        Farm.WaitingQuest = true
                        Farm.ActiveEntry = Q
                        Invoke("StartQuest", Q.Quest, Q.LevelQ)
                    end
                    return true
                else
                    -- Sau 0.4s gửi StartQuest: hết chờ, cho phép bay đi farm quái luôn (kể cả khi UI Quest chưa kịp hiện)
                    Farm.WaitingQuest = false
                    target = Farm.ActiveEntry or Q
                end
            end
        end

        SetStatus("Farm " .. target.Mob .. " (Lv " .. tostring(Level()) .. ")")
        Hunt(target.Mob, target.CFrameM, { exact = false, bring = true, height = Config.FarmHeight })
        return true
    end)
end

--// ---- Vòng lặp điều phối ----
Loop(0.1, function()
    local c, hrp, hum = GetChar()
    if not c then
        State.Busy = false
        return
    end

    if Config.SafeHealthPercent and Config.SafeHealthPercent > 0 then
        local pct = hum.Health / math.max(1, hum.MaxHealth) * 100
        if State.Healing and pct >= 85 then
            State.Healing, State.HealPos = false, nil
        elseif not State.Healing and pct < Config.SafeHealthPercent then
            State.Healing = true
            State.HealPos = hrp.CFrame + Vector3.new(0, 300, 0)
        end
        if State.Healing then
            State.Busy = true
            SetStatus("Hồi máu")
            MoveTo(State.HealPos)
            return
        end
    end

    for _, t in ipairs(Tasks) do
        local okE, enabled = pcall(t.Enabled)
        if okE and enabled then
            local ok, busy = pcall(t.Step, c, hrp, hum)
            if not ok and Config.Debug then warn("[Kaitun:" .. t.Name .. "]", busy) end
            if ok and busy then
                State.Busy = true
                return
            end
        end
    end
    State.Busy = false
    SetStatus("Rảnh")
    StopTween()
end, "arbiter")

--// ===================== CÁC VÒNG LẶP NỀN =====================
do
    local function GetStat(name)
        local s = Data:FindFirstChild("Stats")
        local st = s and s:FindFirstChild(name)
        local lv = st and st:FindFirstChild("Level")
        return lv and lv.Value or 0
    end
    local function Need(stat) return math.max(0, (Config.StatCaps[stat] or 0) - GetStat(stat)) end
    local function Balanced(a, b)
        local na, nb = Need(a), Need(b)
        if na > 0 and nb > 0 then
            if GetStat(a) <= GetStat(b) then return a, na end
            return b, nb
        elseif na > 0 then return a, na
        elseif nb > 0 then return b, nb end
    end

    Loop(0.5, function()
        if not Config.AutoStats then return end
        local pts = Data:FindFirstChild("Points")
        local points = pts and pts.Value or 0
        if points <= 0 then return end
        local stat, need
        if Level() >= 1500 then stat, need = Balanced("Sword", "Demon Fruit") end
        if not stat then stat, need = Balanced("Melee", "Defense") end
        if stat then Invoke("AddPoint", stat, math.min(points, need, 25)) end
    end, "stats")
end

do
    Loop(Config.RandomDelay, function()
        if Config.AutoRandomFruit and Level() >= 50 and Beli() >= 25000 + Config.BeliReserve then
            Invoke("Cousin", "Buy")
        end
    end, "randomfruit")

    Loop(3, function()
        if not Config.AutoStoreFruit then return end
        local containers = { LocalPlayer:FindFirstChild("Backpack"), LocalPlayer.Character }
        for _, cont in ipairs(containers) do
            if cont then
                for _, tool in ipairs(cont:GetChildren()) do
                    if tool:IsA("Tool") and tool.Name:find("Fruit") then
                        local base = tool.Name:gsub(" Fruit", "")
                        local fname = tool:GetAttribute("OriginalName") or (base .. "-" .. base)
                        Invoke("StoreFruit", fname, tool)
                        task.wait(0.2)
                    end
                end
            end
        end
    end, "storefruit")
end

do
    local Abilities = {
        { Name = "Geppo", Remote = { "BuyHaki", "Geppo" }, Beli = 10000 },
        { Name = "Buso",  Remote = { "BuyHaki", "Buso" },  Beli = 25000 },
        { Name = "Soru",  Remote = { "BuyHaki", "Soru" },  Beli = 100000 },
        { Name = "Ken",   Remote = { "KenTalk", "Buy" },   Beli = 750000, MinLevel = 300 },
    }

    local ShopData = {
        [1] = {
            Items = {
                { "Katana", 1000 }, { "Cutlass", 1000 }, { "Dual Katana", 12000 }, { "Iron Mace", 25000 },
                { "Triple Katana", 60000 }, { "Pipe", 100000 }, { "Dual-Headed Blade", 400000 },
                { "Soul Cane", 750000 }, { "Bisento", 1200000 },
                { "Slingshot", 5000 }, { "Musket", 8000 }, { "Flintlock", 10500 },
                { "Refined Slingshot", 30000 }, { "Refined Flintlock", 65000 },
                { "Black Cape", 50000 }, { "Swordsman Hat", 150000 }, { "Tomoe Ring", 500000 },
            },
            Styles = {
                { Names = { "Dark Step", "Black Leg" }, Remote = { "BuyBlackLeg" }, Beli = 150000, Frag = 0 },
                { Names = { "Electro" }, Remote = { "BuyElectro" }, Beli = 500000, Frag = 0 },
                { Names = { "Water Kung Fu", "Fishman Karate" }, Remote = { "BuyFishmanKarate" }, Beli = 750000, Frag = 0 },
            },
        },
        [2] = {
            Items = {
                { "Midnight Blade", 0, { Ecto = 100 } }, { "Bizarre Rifle", 0, { Ecto = 250 } },
                { "Ghoul Mask", 0, { Ecto = 50 } }, { "Kabucha", 0, { Frag = 1500 } },
            },
            Styles = {
                { Names = { "Dragon Claw", "Dragon Breath" }, Remote = { "BlackbeardReward", "DragonClaw", "2" }, Beli = 0, Frag = 1500 },
                { Names = { "Superhuman" }, Remote = { "BuySuperhuman" }, Beli = 3000000, Frag = 0 },
                { Names = { "Death Step" }, Remote = { "BuyDeathStep" }, Beli = 2500000, Frag = 5000 },
                { Names = { "Sharkman Karate" }, Remote = { "BuySharkmanKarate" }, Beli = 2500000, Frag = 5000 },
            },
        },
        [3] = {
            Items = {
                { "Serpent Bow", 0, {} }, { "Soul Guitar", 0, {} },
            },
            Styles = {
                { Names = { "Electric Claw" }, Remote = { "BuyElectricClaw" }, Beli = 3000000, Frag = 5000 },
                { Names = { "Dragon Talon" }, Remote = { "BuyDragonTalon" }, Beli = 3000000, Frag = 5000 },
                { Names = { "Godhuman" }, Remote = { "BuyGodhuman" }, Beli = 5000000, Frag = 5000 },
                { Names = { "Sanguine Art" }, Remote = { "BuySanguineArt" }, Beli = 5000000, Frag = 5000 },
            },
        },
    }

    Loop(8, function()
        if Config.AutoBuyAbilities then
            for _, a in ipairs(Abilities) do
                if Beli() >= a.Beli and Level() >= (a.MinLevel or 0) and Throttle("ab" .. a.Name, 180) then
                    Invoke(table.unpack(a.Remote))
                end
            end
        end
        if Config.AutoBuyShop then
            local pool = ShopData[Sea]
            if not pool then return end
            for _, s in ipairs(pool.Styles) do
                if not Owns(table.unpack(s.Names)) and Beli() >= s.Beli and Fragments() >= s.Frag
                    and Throttle("style" .. s.Names[1], 60) then
                    Invoke(table.unpack(s.Remote))
                end
            end
            for _, it in ipairs(pool.Items) do
                local name, cost, opt = it[1], it[2], it[3] or {}
                if not Owns(name) and Throttle("item" .. name, 60) then
                    if cost > 0 then
                        if Beli() >= cost then Invoke("BuyItem", name) task.wait(0.2) end
                    elseif opt.Frag then
                        if Fragments() >= opt.Frag then Invoke("BuyItem", name) task.wait(0.2) end
                    elseif opt.Ecto then
                        Invoke("Ectoplasm", "Buy", name)
                        task.wait(0.2)
                    end
                end
            end
        end
    end, "shop")
end

Loop(1.5, function()
    if not Config.AutoCollectDrops or not fireTouch then return end
    local _, hrp = GetChar()
    if not hrp then return end
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Tool") and obj.Name:find("Fruit") and obj:FindFirstChild("Handle") then
            fireTouch(hrp, obj.Handle, 0)
            task.wait()
            fireTouch(hrp, obj.Handle, 1)
        elseif Sea == 2 and obj:IsA("BasePart") and (obj.Name == "Flower1" or obj.Name == "Flower2" or obj.Name == "Flower3")
            and (obj.Position - hrp.Position).Magnitude <= 600 then
            fireTouch(hrp, obj, 0)
            task.wait()
            fireTouch(hrp, obj, 1)
        end
    end
end, "drops")

--// ===================== GIẢM LAG / X-RAY / NO FOG =====================
task.spawn(pcall, function()
    local function IsLiving(part)
        local char = LocalPlayer.Character
        if char and part:IsDescendantOf(char) then return true end
        local p = part.Parent
        return p ~= nil and (p:FindFirstChildOfClass("Humanoid") ~= nil
            or (p.Parent ~= nil and p.Parent:FindFirstChildOfClass("Humanoid") ~= nil))
    end

    local function ApplyLighting()
        if not Config.NoFog then return end
        Lighting.FogStart, Lighting.FogEnd = 1e9, 1e9
        pcall(function() Lighting.GlobalShadows = false end)
        pcall(function() Lighting.EnvironmentDiffuseScale = 0 end)
        pcall(function() Lighting.EnvironmentSpecularScale = 0 end)
        for _, child in ipairs(Lighting:GetChildren()) do
            pcall(function()
                if child:IsA("Atmosphere") then
                    child.Density, child.Haze, child.Glare, child.Offset = 0, 0, 0, 0
                elseif child:IsA("PostEffect") then
                    child.Enabled = false
                end
            end)
        end
    end

    local function CleanGFX(obj)
        if Config.RemoveSFX and obj:IsA("Sound") then obj.Volume = 0 return end
        if not Config.NoSkillGFX then return end
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire")
            or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Explosion") or obj:IsA("Highlight") then
            obj:Destroy()
        elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
            obj.Enabled = false
        elseif (obj:IsA("Decal") or obj:IsA("Texture")) and obj.Name ~= "face" and not IsLiving(obj) then
            obj.Transparency = 1
        end
    end

    local function IsEffectPart(obj)
        local wo = Workspace:FindFirstChild("_WorldOrigin")
        if not wo or not obj:IsDescendantOf(wo) then return false end
        if obj:FindFirstAncestor("EnemySpawns") or obj:FindFirstAncestor("Locations") then return false end
        return true
    end

    local function HideOther(obj)
        if not Config.HideOtherPlayers then return end
        if not (obj:IsA("BasePart") or obj:IsA("Accessory") or obj:IsA("Clothing")
            or obj:IsA("ShirtGraphic") or obj:IsA("CharacterMesh") or obj:IsA("Decal")) then return end
        local model = obj:FindFirstAncestorOfClass("Model")
        local plr = model and Players:GetPlayerFromCharacter(model)
        if plr and plr ~= LocalPlayer then
            if obj:IsA("BasePart") then
                obj.Transparency = 1
                obj.CastShadow = false
            elseif obj:IsA("Decal") then
                obj.Transparency = 1
            else
                obj:Destroy()
            end
        end
    end

    local function ApplyPart(obj)
        if not obj:IsA("BasePart") then return end
        if Config.FixLag then
            obj.CastShadow = false
            if obj:IsA("MeshPart") then obj.RenderFidelity = Enum.RenderFidelity.Performance end
        end
        if Config.XRay and not IsLiving(obj) then
            local n = obj.Name:lower()
            if obj.Material == Enum.Material.Water or n == "sea" or n == "ocean" or n:find("water", 1, true) then
                obj.Transparency = Config.SeaTransparency
                obj.Reflectance = 0
            elseif IsEffectPart(obj) then
                obj.Transparency = 1
                obj.Reflectance = 0
            elseif obj.Anchored then
                obj.Transparency = math.max(obj.Transparency, Config.MapTransparency)
                obj.Reflectance = 0
                obj.Material = Enum.Material.SmoothPlastic
            end
        end
    end

    local function Process(obj)
        CleanGFX(obj)
        HideOther(obj)
        ApplyPart(obj)
    end

    local function ApplyTerrain()
        if not Config.FixLag then return end
        local t = Workspace.Terrain
        t.WaterWaveSize, t.WaterWaveSpeed, t.WaterReflectance = 0, 0, 0
        t.WaterTransparency = Config.SeaTransparency
        if setHidden then pcall(setHidden, t, "Decoration", false) end
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
    end

    if setfpscap and (Config.FpsCap or 0) > 0 then pcall(setfpscap, Config.FpsCap) end
    if Config.BlackScreen then
        pcall(function() RunService:Set3dRenderingEnabled(false) end)
        table.insert(Cleanups, function() pcall(function() RunService:Set3dRenderingEnabled(true) end) end)
    end

    if Config.FixLag or Config.NoSkillGFX or Config.XRay or Config.NoFog or Config.RemoveSFX then
        pcall(ApplyLighting)
        pcall(ApplyTerrain)

        task.spawn(function()
            local n = 0
            for _, d in ipairs(Workspace:GetDescendants()) do
                if not Running then return end
                pcall(Process, d)
                n = n + 1
                if n % 300 == 0 then task.wait() end
            end
            for _, d in ipairs(Lighting:GetDescendants()) do pcall(CleanGFX, d) end
        end)

        Connect(Workspace.DescendantAdded, function(d) task.defer(pcall, Process, d) end)
        Connect(Lighting.DescendantAdded, function(d) task.defer(pcall, CleanGFX, d) end)
        Connect(Lighting:GetPropertyChangedSignal("FogEnd"), function()
            if Config.NoFog and Lighting.FogEnd < 1e8 then Lighting.FogStart, Lighting.FogEnd = 1e9, 1e9 end
        end)
        Loop(3, ApplyLighting, "lighting")
    end
end)

--// ===================== DỪNG SCRIPT =====================
local function Stop()
    Running = false
    genv.__KaitunRunning = false
    for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
    for _, f in ipairs(Cleanups) do pcall(f) end
    StopTween()
    local _, hrp = GetChar()
    local h = hrp and hrp:FindFirstChild("KaitunHover")
    if h then h:Destroy() end
end
genv.__KaitunStop = Stop

print("[Kaitun] Đã chạy | Sea " .. Sea .. " | Level " .. tostring(Level()))

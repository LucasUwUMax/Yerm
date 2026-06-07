local redzlib = loadstring(game:HttpGet("https://raw.githubusercontent.com/minhdepzai-v/LibraryRobloc/refs/heads/main/RedzLibrary.lua"))()

local Window = redzlib:MakeWindow({
  Title = "Cherry Hub",
  SubTitle = "v3.5 - Ghost Update ",
  SaveFolder = "CherryMM2"
})

Window:AddMinimizeButton({
    Button = { Image = "rbxassetid://78702423919944", BackgroundTransparency = 0 },
    Corner = { CornerRadius = UDim.new(35, 1) },
})

local lp = game.Players.LocalPlayer
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- CONFIGURACOES GLOBAIS
local ESP_ENABLED           = false
local HITBOX_ENABLED        = false
local KILLAURA_ENABLED      = false
local COIN_ENABLED          = false
local FARM_SPEED            = 60
local HITBOX_SIZE           = 10
local KILLAURA_RADIUS       = 10
local SILENT_AIM_ENABLED    = false
local AIMBOT_ENABLED        = false
local ESP_ASSASSINO_ENABLED = false

local selectedPlayer   = nil
local viewEnabled      = false
local flingTargetLoop  = false
local playerEspEnabled = false
local orbitTargetLoop  = false

-- =============================================
-- SISTEMA DE DETECÇÃO AVANÇADA (ROLES)
-- =============================================
local function getPlayerRole(p)
    if not p then return "Inocente" end
    
    local k = p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
    local g = p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Revolver") or p.Character:FindFirstChild("Revolver")
    
    if k then return "Assassino" end
    if g then return "Xerife" end
    
    if p:FindFirstChild("slotFolder") and p.slotFolder:FindFirstChild("Knife") then return "Assassino" end
    if p:FindFirstChild("slotFolder") and (p.slotFolder:FindFirstChild("Gun") or p.slotFolder:FindFirstChild("Revolver")) then return "Xerife" end
    
    return "Inocente"
end

-- =============================================
-- SISTEMA DE ESP MELHORADO
-- =============================================
local function removeESP(p)
    if not p or not p.Character then return end
    if p.Character:FindFirstChild("CherryHighlight") then p.Character.CherryHighlight:Destroy() end
    if p.Character:FindFirstChild("CherryESPBill") then p.Character.CherryESPBill:Destroy() end
end

local function applyESP(p, color, label)
    if not p or not p.Character then return end
    local hrp  = p.Character:FindFirstChild("HumanoidRootPart")
    local head = p.Character:FindFirstChild("Head")
    if not hrp or not head then return end

    local existing = p.Character:FindFirstChild("CherryHighlight")
    if existing then
        existing.FillColor = color
    else
        local h = Instance.new("Highlight")
        h.Name                = "CherryHighlight"
        h.FillColor           = color
        h.OutlineColor        = Color3.new(1, 1, 1)
        h.FillTransparency    = 0.3
        h.OutlineTransparency = 0
        h.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent              = p.Character
    end

    local myHRP = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    local dist  = myHRP and math.floor((myHRP.Position - hrp.Position).Magnitude) or 0

    local bill = p.Character:FindFirstChild("CherryESPBill")
    if not bill then
        bill              = Instance.new("BillboardGui")
        bill.Name         = "CherryESPBill"
        bill.Adornee      = head
        bill.AlwaysOnTop  = true
        bill.Size         = UDim2.new(0, 140, 0, 55)
        bill.StudsOffset  = Vector3.new(0, 2.8, 0)
        bill.ResetOnSpawn = false
        bill.Parent       = p.Character

        local frame = Instance.new("Frame")
        frame.BackgroundTransparency = 1
        frame.Size   = UDim2.new(1, 0, 1, 0)
        frame.Parent = bill

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name                  = "NameLabel"
        nameLabel.BackgroundTransparency = 1
        nameLabel.Size                  = UDim2.new(1, 0, 0.5, 0)
        nameLabel.Font                  = Enum.Font.GothamBold
        nameLabel.TextSize              = 14
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextColor3            = color
        nameLabel.Text                  = p.Name
        nameLabel.Parent                = frame

        local infoLabel = Instance.new("TextLabel")
        infoLabel.Name                  = "InfoLabel"
        infoLabel.BackgroundTransparency = 1
        infoLabel.Size                  = UDim2.new(1, 0, 0.5, 0)
        infoLabel.Position              = UDim2.new(0, 0, 0.5, 0)
        infoLabel.Font                  = Enum.Font.Gotham
        infoLabel.TextSize              = 12
        infoLabel.TextStrokeTransparency = 0
        infoLabel.TextColor3            = Color3.new(1, 1, 1)
        infoLabel.Text                  = label .. " | " .. dist .. "m"
        infoLabel.Parent                = frame
    else
        local frame = bill:FindFirstChildOfClass("Frame")
        if frame then
            local info  = frame:FindFirstChild("InfoLabel")
            local nameL = frame:FindFirstChild("NameLabel")
            if info  then info.Text        = label .. " | " .. dist .. "m" end
            if nameL then nameL.TextColor3 = color end
        end
    end
end

task.spawn(function()
    while task.wait(0.25) do
        for _, p in pairs(Players:GetPlayers()) do
            if p == lp or not p.Character then continue end

            local role = getPlayerRole(p)

            if ESP_ENABLED then
                if role == "Assassino" then
                    applyESP(p, Color3.fromRGB(255, 50, 50), "Assassino")
                elseif role == "Xerife" then
                    applyESP(p, Color3.fromRGB(50, 150, 255), "Xerife")
                else
                    removeESP(p)
                end
            elseif ESP_ASSASSINO_ENABLED then
                if role == "Xerife" then
                    applyESP(p, Color3.fromRGB(50, 150, 255), "Xerife")
                elseif role == "Inocente" then
                    applyESP(p, Color3.fromRGB(180, 180, 180), "Inocente")
                else
                    removeESP(p)
                end
            elseif playerEspEnabled and p == selectedPlayer then
                applyESP(p, Color3.fromRGB(255, 255, 0), "Alvo")
            else
                removeESP(p)
            end
        end
    end
end)

-- =============================================
-- SISTEMAS DE FLING E ORBIT
-- =============================================
local function executeFling(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local myChar = lp.Character
    local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    local tHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not tHRP then return end

    local savedPos = myHRP.CFrame
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1, 1, 1) * math.huge
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent   = myHRP

    local bav = Instance.new("BodyAngularVelocity")
    bav.MaxTorque       = Vector3.new(1, 1, 1) * math.huge
    bav.AngularVelocity = Vector3.new(9e8, 9e8, 9e8)
    bav.Parent          = myHRP

    local angle     = 0
    local startTime = tick()

    repeat
        tHRP = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not tHRP then break end
        angle = angle + 180
        local vel  = tHRP.Velocity
        local pred = vel * 0.35
        myHRP.CFrame = CFrame.new(tHRP.Position + pred) * CFrame.Angles(math.rad(angle), math.rad(angle * 0.5), 0)
        bv.Velocity = Vector3.new(9e8, 9e8, 9e8)
        task.wait()
    until tick() > startTime + 2.5 or not targetPlayer.Parent

    bv:Destroy()
    bav:Destroy()
    myHRP.CFrame = savedPos
end

local function executeGhostFling(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local myChar = lp.Character
    local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    local tHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not tHRP then return end

    local savedCFrame = myHRP.CFrame
    local ghostPart = Instance.new("Part", workspace)
    ghostPart.Anchored = true
    ghostPart.Size = Vector3.new(4, 1, 4)
    ghostPart.CFrame = savedCFrame * CFrame.new(0, -3, 0)
    ghostPart.Transparency = 1

    myHRP.CFrame = ghostPart.CFrame * CFrame.new(0, 3, 0)
    task.wait(0.05)

    local bv = Instance.new("BodyVelocity", myHRP)
    bv.MaxForce = Vector3.new(1, 1, 1) * math.huge
    local bav = Instance.new("BodyAngularVelocity", myHRP)
    bav.MaxTorque = Vector3.new(1, 1, 1) * math.huge
    bav.AngularVelocity = Vector3.new(9e9, 9e9, 9e9)

    local startTime = tick()
    repeat
        tHRP = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not tHRP then break end
        myHRP.CFrame = CFrame.new(tHRP.Position + (tHRP.Velocity * 0.45))
        bv.Velocity = Vector3.new(9e9, 9e9, 9e9)
        task.wait()
    until tick() > startTime + 3 or not targetPlayer.Parent

    ghostPart:Destroy()
    bv:Destroy()
    bav:Destroy()
    myHRP.CFrame = savedCFrame
end

local function executeOrbitFling(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local myChar = lp.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    local tHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not tHRP then return end

    local savedCFrame = myHRP.CFrame
    local bv = Instance.new("BodyVelocity", myHRP)
    bv.MaxForce = Vector3.new(1, 1, 1) * math.huge
    
    local bav = Instance.new("BodyAngularVelocity", myHRP)
    bav.MaxTorque = Vector3.new(1, 1, 1) * math.huge
    bav.AngularVelocity = Vector3.new(0, 9e9, 0)

    local startTime = tick()
    local r = 4
    local rot = 0

    while tick() - startTime < 3 and targetPlayer.Parent and tHRP do
        rot = rot + 0.2
        local offset = Vector3.new(math.sin(rot) * r, 0, math.cos(rot) * r)
        myHRP.CFrame = CFrame.new(tHRP.Position + offset)
        bv.Velocity = tHRP.Velocity + Vector3.new(0, 2, 0)
        RunService.Heartbeat:Wait()
        tHRP = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    end

    bv:Destroy()
    bav:Destroy()
    myHRP.CFrame = savedCFrame
end

-- =============================================
-- SISTEMAS AUXILIARES
-- =============================================
local autoGrabConn = nil
local AUTO_GRAB_ENABLED = false
local function startAutoGrab()
    if autoGrabConn then autoGrabConn:Disconnect() end
    autoGrabConn = RunService.Heartbeat:Connect(function()
        if not AUTO_GRAB_ENABLED then return end
        local myChar = lp.Character
        local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        if myChar:FindFirstChild("Gun") or myChar:FindFirstChild("Revolver") or lp.Backpack:FindFirstChild("Gun") or lp.Backpack:FindFirstChild("Revolver") then return end

        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Tool") and (obj.Name:lower():find("gun") or obj.Name:lower():find("revolver")) then
                if obj.Parent == workspace then
                    myHRP.CFrame = obj:GetPivot()
                    task.wait(0.2)
                    break
                end
            end
        end
    end)
end

local function getMurder()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and getPlayerRole(p) == "Assassino" then return p end
    end
    return nil
end

local function getXerife()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and getPlayerRole(p) == "Xerife" then return p end
    end
    return nil
end

local function roubarArma()
    local xerife = getXerife()
    if not xerife then return end
    executeFling(xerife)
    task.wait(1)
    local myHRP = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") and (obj.Name == "Gun" or obj.Name == "Revolver") then
            if obj.Parent == workspace then
                myHRP.CFrame = obj:GetPivot()
                task.wait(0.3)
                break
            end
        end
    end
end

-- =============================================
-- COIN FARM SYSTEM
-- =============================================
local coinCollected = {}
local isTweening    = false

local function findCoins()
    local c     = {}
    local names = {"MainCoin", "CoinVisual", "Coin", "Coin_Server"}
    for _, o in ipairs(workspace:GetDescendants()) do
        if o:IsA("BasePart") and table.find(names, o.Name) then
            if o.Parent and not coinCollected[o:GetDebugId()] then table.insert(c, o) end
        end
    end
    return c
end

local function safeTeleport(target)
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not target.Parent then return end
    isTweening   = true
    local dist   = (hrp.Position - target.Position).Magnitude
    local time   = dist / FARM_SPEED
    local tween  = TweenService:Create(hrp, TweenInfo.new(time, Enum.EasingStyle.Linear), {
        CFrame = CFrame.new(target.Position + Vector3.new(0, 1, 0))
    })
    tween:Play()
    tween.Completed:Connect(function()
        coinCollected[target:GetDebugId()] = true
        isTweening = false
    end)
    repeat task.wait() until not isTweening
end

local function startCoinFarm()
    coinCollected = {}
    task.spawn(function()
        while COIN_ENABLED do
            if not isTweening and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                local coins = findCoins()
                if #coins > 0 then
                    table.sort(coins, function(a, b)
                        return (lp.Character.HumanoidRootPart.Position - a.Position).Magnitude < (lp.Character.HumanoidRootPart.Position - b.Position).Magnitude
                    end)
                    safeTeleport(coins[1])
                end
            end
            task.wait(0.1)
        end
    end)
end

-- =============================================
-- COMBAT SYSTEM (HITBOX)
-- =============================================
local function applyHitbox()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            if r then
                r.Size         = Vector3.new(HITBOX_SIZE, HITBOX_SIZE, HITBOX_SIZE)
                r.Transparency = 0.7
                r.CanCollide   = false
            end
        end
    end
end

local hitboxConn = nil
local function startHitbox()
    if hitboxConn then hitboxConn:Disconnect() end
    hitboxConn = RunService.Heartbeat:Connect(function()
        if HITBOX_ENABLED then applyHitbox() end
    end)
end

local function stopHitbox()
    HITBOX_ENABLED = false
    if hitboxConn then hitboxConn:Disconnect() hitboxConn = nil end
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            p.Character.HumanoidRootPart.Size        = Vector3.new(2, 2, 1)
            p.Character.HumanoidRootPart.Transparency = 0
        end
    end
end

local killAuraConn = nil
local function startKillAura()
    if killAuraConn then killAuraConn:Disconnect() end
    killAuraConn = RunService.Heartbeat:Connect(function()
        if not KILLAURA_ENABLED then return end
        local c   = lp.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local k = c:FindFirstChild("Knife") or lp.Backpack:FindFirstChild("Knife")
        if not k then return end
        if k.Parent == lp.Backpack then c.Humanoid:EquipTool(k) end
        local h = k:FindFirstChild("Handle")
        if not h then return end
        local cl, cd = nil, KILLAURA_RADIUS
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= lp and p.Character and p.Character.Humanoid.Health > 0 then
                local d = (hrp.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if d < cd then cd = d; cl = p end
            end
        end
        if cl then h.CFrame = cl.Character.HumanoidRootPart.CFrame end
    end)
end

-- =============================================
-- MIRA AJUSTADA: RAYCAST VISIBILITY + AUTO FIRE
-- =============================================
local function isPlayerVisible(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return false end
    local head = targetPlayer.Character:FindFirstChild("Head")
    local cam = workspace.CurrentCamera
    if not head or not cam then return false end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {lp.Character, cam}
    
    local origin = cam.CFrame.Position
    local direction = (head.Position - origin)
    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    
    if raycastResult then
        return raycastResult.Instance:IsDescendantOf(targetPlayer.Character)
    end
    return true
end

local function autoShootMurder()
    local murder = getMurder()
    if not murder or not murder.Character then return end
    local myChar = lp.Character
    if not myChar then return end
    local gun = myChar:FindFirstChild("Gun") or lp.Backpack:FindFirstChild("Gun") or myChar:FindFirstChild("Revolver") or lp.Backpack:FindFirstChild("Revolver")
    if not gun then return end
    
    if gun.Parent == lp.Backpack then
        myChar.Humanoid:EquipTool(gun)
        task.wait(0.1)
    end

    local targetPos = murder.Character.HumanoidRootPart.Position
    if gun:FindFirstChild("KnifeServer") and gun.KnifeServer:FindFirstChild("ShootGun") then
        gun.KnifeServer.ShootGun:InvokeServer({
            ["TargetCFrame"] = CFrame.new(targetPos),
            ["HitPart"] = murder.Character.HumanoidRootPart,
            ["HitPosition"] = targetPos
        })
    end
end

local silentAimConn = nil
local function startSilentAim()
    if silentAimConn then silentAimConn:Disconnect() end
    silentAimConn = RunService.RenderStepped:Connect(function()
        if not SILENT_AIM_ENABLED then return end
        local murder = getMurder()
        if murder and isPlayerVisible(murder) then
            autoShootMurder()
            task.wait(0.5)
        end
    end)
end

local aimbotConn = nil
local function startAimbot()
    if aimbotConn then aimbotConn:Disconnect() end
    aimbotConn = RunService.RenderStepped:Connect(function()
        if not AIMBOT_ENABLED then return end
        local murder = getMurder()
        if not murder or not murder.Character then return end
        local head = murder.Character:FindFirstChild("Head")
        if not head then return end
        workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, head.Position)
    end)
end

-- =============================================
-- GERENCIADOR DE NOMES (DROPDOWNS DINÂMICOS)
-- =============================================
local function getPlayerNames()
    local n = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp then table.insert(n, p.Name) end
    end
    return n
end

RunService.RenderStepped:Connect(function()
    if viewEnabled and selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("Humanoid") then
        workspace.CurrentCamera.CameraSubject = selectedPlayer.Character.Humanoid
    else
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then
            workspace.CurrentCamera.CameraSubject = lp.Character.Humanoid
        end
    end
end)

-- =============================================
-- UI TABS
-- =============================================
local T1 = Window:MakeTab({"Home", ""})
local T2 = Window:MakeTab({"Inocente", ""})
local T3 = Window:MakeTab({"Assassino", ""})
local T4 = Window:MakeTab({"Xerife", ""})
local T5 = Window:MakeTab({"Troll", ""})
local T6 = Window:MakeTab({"Misc", ""})

T1:AddParagraph({"Cherry Hub v3.5", "Ghost Update: Modificações e correções de Dropdowns aplicadas."})

-- ABA INOCENTE
T2:AddSection({"Combate"})
T2:AddToggle({Name="ESP Dinâmico (Cargos)", Default=false, Callback=function(v)
    ESP_ENABLED = v
    if not v then for _, p in pairs(Players:GetPlayers()) do removeESP(p) end end
end})
T2:AddButton({"Roubar Arma do Xerife", function() roubarArma() end})
T2:AddButton({"Fling Murder", function()
    local t = getMurder()
    if t then executeFling(t) end
end})

T2:AddSection({"Auto Grab"})
T2:AddToggle({Name="Auto Grab Gun", Default=false, Callback=function(v)
    AUTO_GRAB_ENABLED = v
    if v then startAutoGrab() else if autoGrabConn then autoGrabConn:Disconnect() autoGrabConn = nil end end
end})

T2:AddSection({"Farm de Moedas"})
T2:AddToggle({Name="Ativar Auto Farm", Default=false, Callback=function(v) COIN_ENABLED = v; if v then startCoinFarm() end end})
T2:AddSlider({Name="Velocidade do Farm", Min=10, Max=200, Default=60, Callback=function(v) FARM_SPEED=v end})

-- ABA ASSASSINO
T3:AddSection({"ESP Assassino"})
T3:AddToggle({Name="ESP (Inocentes e Xerife)", Default=false, Callback=function(v)
    ESP_ASSASSINO_ENABLED = v
    if not v then for _, p in pairs(Players:GetPlayers()) do removeESP(p) end end
end})
T3:AddSection({"Hitbox"})
T3:AddSlider({Name="Tamanho da Hitbox", Min=1, Max=50, Default=10, Callback=function(v) HITBOX_SIZE=v end})
T3:AddToggle({Name="Ativar Hitbox", Default=false, Callback=function(v) if v then startHitbox() else stopHitbox() end end})
T3:AddSection({"Kill Aura"})
T3:AddToggle({Name="Ativar Kill Aura", Default=false, Callback=function(v) KILLAURA_ENABLED = v; if v then startKillAura() end end})

-- ABA XERIFE
T4:AddSection({"Mira"})
T4:AddToggle({Name="Silent Aim Avançado (Auto Visibilidade)", Default=false, Callback=function(v)
    SILENT_AIM_ENABLED = v
    if v then startSilentAim() else if silentAimConn then silentAimConn:Disconnect() silentAimConn = nil end end
end})
T4:AddToggle({Name="Aimbot Murder", Default=false, Callback=function(v)
    AIMBOT_ENABLED = v
    if v then startAimbot() else if aimbotConn then aimbotConn:Disconnect() aimbotConn = nil end end
end})
T4:AddButton({"Auto Atirar no Murder", function() autoShootMurder() end})

-- ABA TROLL E DROPDOWNS ATUALIZADOS
T5:AddSection({"Selecionar Alvo"})
local pDropdown = T5:AddDropdown({
    Name     = "Escolher Player",
    Options  = getPlayerNames(),
    Default  = "",
    Callback = function(v) selectedPlayer = Players:FindFirstChild(v) end
})

local function atualizarDropdowns()
    local novosNomes = getPlayerNames()
    pDropdown:SetOptions(novosNomes)
end
Players.PlayerAdded:Connect(atualizarDropdowns)
Players.PlayerRemoving:Connect(atualizarDropdowns)

T5:AddSection({"Acoes no Alvo"})
T5:AddToggle({Name="Fling Alvo Infinito", Default=false, Callback=function(v)
    flingTargetLoop = v
    task.spawn(function()
        while flingTargetLoop do
            if selectedPlayer then executeFling(selectedPlayer) end
            task.wait(0.3)
        end
    end)
end})
T5:AddToggle({Name="Orbit Fling Alvo", Default=false, Callback=function(v)
    orbitTargetLoop = v
    task.spawn(function()
        while orbitTargetLoop do
            if selectedPlayer then executeOrbitFling(selectedPlayer) end
            task.wait(0.3)
        end
    end)
end})

T5:AddSection({"Caos Total"})
T5:AddButton({"Fling All Players", function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then executeFling(p) task.wait(0.1) end
    end
end})
T5:AddButton({"Orbit Fling All", function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then executeOrbitFling(p) task.wait(0.1) end
    end
end})
T5:AddButton({"Orbit Fling Murder", function()
    local murder = getMurder()
    if murder then executeOrbitFling(murder) end
end})
T5:AddButton({"Orbit Fling Xerife", function()
    local xerife = getXerife()
    if xerife then executeOrbitFling(xerife) end
end})
T5:AddButton({"GhostFling Murder", function()
    local murder = getMurder()
    if murder then executeGhostFling(murder) end
end})
T5:AddButton({"GhostFling Xerife", function()
    local xerife = getXerife()
    if xerife then executeGhostFling(xerife) end
end})

-- ABA MISC
T6:AddSection({"Movimentacao"})
T6:AddSlider({Name="Velocidade", Min=16, Max=150, Default=16, Callback=function(v) if lp.Character then lp.Character.Humanoid.WalkSpeed = v end end})
T6:AddSlider({Name="Pulo", Min=50, Max=300, Default=50, Callback=function(v) if lp.Character then lp.Character.Humanoid.JumpPower = v end end})

Window:SelectTab(T1)

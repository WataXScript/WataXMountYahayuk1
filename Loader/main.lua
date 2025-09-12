

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer


local hrp = nil
local function refreshHRP(char)
    if not char then char = player.Character or player.CharacterAdded:Wait() end
    hrp = char:WaitForChild("HumanoidRootPart")
end
if player.Character then refreshHRP(player.Character) end
player.CharacterAdded:Connect(refreshHRP)


local replayURLs = {
    ["Router1"] = "https://raw.githubusercontent.com/username/repo/branch/Router1.lua",
    ["Router2"] = "https://raw.githubusercontent.com/username/repo/branch/Router2.lua",
    ["Router3"] = "https://raw.githubusercontent.com/username/repo/branch/Router3.lua",
}


local function loadReplay(url)
    local success, result = pcall(function()
        return HttpService:GetAsync(url)
    end)
    if success then
        local replay = loadstring(result)()
        print("✅ Replay berhasil load, frames:", #replay)
        return replay
    else
        warn("❌ Gagal load replay:", result)
        return {}
    end
end

-- Load semua route
local routes = {}
for name, url in pairs(replayURLs) do
    local replay = loadReplay(url)
    if #replay > 0 then
        table.insert(routes, {name, replay})
    end
end

-- Playback settings
local frameTime = 1/30
local playbackRate = 1.0
local isRunning = false

-- Bantu functions
local function getNearestRoute()
    local nearestIdx, dist = 1, math.huge
    if hrp then
        local pos = hrp.Position
        for i,data in ipairs(routes) do
            for _,cf in ipairs(data[2]) do
                local d = (cf.Position - pos).Magnitude
                if d < dist then
                    dist = d
                    nearestIdx = i
                end
            end
        end
    end
    return nearestIdx
end

local function getNearestFrameIndex(frames)
    local startIdx, dist = 1, math.huge
    if hrp then
        local pos = hrp.Position
        for i,cf in ipairs(frames) do
            local d = (cf.Position - pos).Magnitude
            if d < dist then
                dist = d
                startIdx = i
            end
        end
    end
    if startIdx >= #frames then
        startIdx = math.max(1, #frames - 1)
    end
    return startIdx
end

local function lerpCF(fromCF, toCF)
    local duration = frameTime / math.max(0.05, playbackRate)
    local t = 0
    while t < duration do
        if not isRunning then break end
        local dt = task.wait()
        t += dt
        local alpha = math.min(t / duration, 1)
        if hrp and hrp.Parent and hrp:IsDescendantOf(workspace) then
            hrp.CFrame = fromCF:Lerp(toCF, alpha)
        end
    end
end


local function runRouteOnce()
    if #routes == 0 then return end
    if not hrp then refreshHRP() end
    isRunning = true
    local idx = getNearestRoute()
    print("▶ Start CP:", routes[idx][1])
    local frames = routes[idx][2]
    if #frames < 2 then isRunning = false return end
    local startIdx = getNearestFrameIndex(frames)
    for i = startIdx, #frames - 1 do
        if not isRunning then break end
        lerpCF(frames[i], frames[i+1])
    end
    isRunning = false
end

local function runAllRoutes()
    if #routes == 0 then return end
    if not hrp then refreshHRP() end
    isRunning = true
    local idx = getNearestRoute()
    print("⏩ Start To End dari:", routes[idx][1])
    for r = idx, #routes do
        if not isRunning then break end
        local frames = routes[r][2]
        if #frames < 2 then continue end
        local startIdx = getNearestFrameIndex(frames)
        for i = startIdx, #frames - 1 do
            if not isRunning then break end
            lerpCF(frames[i], frames[i+1])
        end
    end
    isRunning = false
end

local function stopRoute()
    if isRunning then print("⏹ Stop ditekan") end
    isRunning = false
end


local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WataXReplay"
screenGui.ResetOnSpawn = false
screenGui.Parent = game.CoreGui

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0,280,0,180)
frame.Position = UDim2.new(0.5,-140,0.5,-90)
frame.BackgroundColor3 = Color3.fromRGB(35,35,40)
frame.Active = true
frame.Draggable = true
frame.BackgroundTransparency = 0.05
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)


local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,32)
title.Text = "WataX Menu"
title.BackgroundColor3 = Color3.fromRGB(55,55,65)
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
Instance.new("UICorner", title).CornerRadius = UDim.new(0,12)


local startCP = Instance.new("TextButton", frame)
startCP.Size = UDim2.new(0.5,-7,0,42)
startCP.Position = UDim2.new(0,5,0,44)
startCP.Text = "Start CP"
startCP.BackgroundColor3 = Color3.fromRGB(60,200,80)
startCP.TextColor3 = Color3.fromRGB(255,255,255)
startCP.Font = Enum.Font.GothamBold
startCP.TextScaled = true
Instance.new("UICorner", startCP).CornerRadius = UDim.new(0,10)
startCP.MouseButton1Click:Connect(runRouteOnce)

local stopBtn = Instance.new("TextButton", frame)
stopBtn.Size = UDim2.new(0.5,-7,0,42)
stopBtn.Position = UDim2.new(0.5,2,0,44)
stopBtn.Text = "Stop"
stopBtn.BackgroundColor3 = Color3.fromRGB(220,70,70)
stopBtn.TextColor3 = Color3.fromRGB(255,255,255)
stopBtn.Font = Enum.Font.GothamBold
stopBtn.TextScaled = true
Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0,10)
stopBtn.MouseButton1Click:Connect(stopRoute)

local startAll = Instance.new("TextButton", frame)
startAll.Size = UDim2.new(1,-10,0,42)
startAll.Position = UDim2.new(0,5,0,96)
startAll.Text = "Start To End"
startAll.BackgroundColor3 = Color3.fromRGB(70,120,220)
startAll.TextColor3 = Color3.fromRGB(255,255,255)
startAll.Font = Enum.Font.GothamBold
startAll.TextScaled = true
Instance.new("UICorner", startAll).CornerRadius = UDim.new(0,10)
startAll.MouseButton1Click:Connect(runAllRoutes)


local miniBtn = Instance.new("TextButton", frame)
miniBtn.Size = UDim2.new(0,30,0,30)
miniBtn.Position = UDim2.new(1,-30,0,0)
miniBtn.Text = "—"
miniBtn.BackgroundColor3 = Color3.fromRGB(80,80,200)
miniBtn.TextColor3 = Color3.fromRGB(255,255,255)
miniBtn.Font = Enum.Font.GothamBold
miniBtn.TextScaled = true
Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(0,8)

local bubbleBtn = Instance.new("TextButton", screenGui)
bubbleBtn.Size = UDim2.new(0,80,0,46)
bubbleBtn.Position = UDim2.new(0,20,0.7,0)
bubbleBtn.Text = "WataX"
bubbleBtn.BackgroundColor3 = Color3.fromRGB(0,140,220)
bubbleBtn.TextColor3 = Color3.fromRGB(255,255,255)
bubbleBtn.Font = Enum.Font.GothamBold
bubbleBtn.TextScaled = true
bubbleBtn.Visible = false
bubbleBtn.Active = true
bubbleBtn.Draggable = true
Instance.new("UICorner", bubbleBtn).CornerRadius = UDim.new(0,14)

miniBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
    bubbleBtn.Visible = true
end)
bubbleBtn.MouseButton1Click:Connect(function()
    frame.Visible = true
    bubbleBtn.Visible = false
end)


local speedRow = Instance.new("Frame", frame)
speedRow.Size = UDim2.new(0,160,0,30)
speedRow.AnchorPoint = Vector2.new(0,1)
speedRow.Position = UDim2.new(0,110,1,-5)
speedRow.BackgroundTransparency = 1

local speedValue = Instance.new("TextLabel", speedRow)
speedValue.Size = UDim2.new(0,60,1,0)
speedValue.Position = UDim2.new(0,0,0,0)
speedValue.BackgroundTransparency = 1
speedValue.TextColor3 = Color3.fromRGB(220,220,220)
speedValue.Font = Enum.Font.GothamBold
speedValue.TextScaled = true
speedValue.Text = string.format("%.2fx", playbackRate)

local speedDown = Instance.new("TextButton", speedRow)
speedDown.Size = UDim2.new(0,40,1,0)
speedDown.Position = UDim2.new(0,65,0,0)
speedDown.Text = "–"
speedDown.BackgroundColor3 = Color3.fromRGB(60,60,100)
speedDown.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", speedDown).CornerRadius = UDim.new(0,8)

local speedUp = Instance.new("TextButton", speedRow)
speedUp.Size = UDim2.new(0,40,1,0)
speedUp.Position = UDim2.new(0,110,0,0)
speedUp.Text = "+"
speedUp.BackgroundColor3 = Color3.fromRGB(60,60,100)
speedUp.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", speedUp).CornerRadius = UDim.new(0,8)

speedDown.MouseButton1Click:Connect(function()
    playbackRate = math.max(0.25, playbackRate - 0.25)
    speedValue.Text = string.format("%.2fx", playbackRate)
end)
speedUp.MouseButton1Click:Connect(function()
    playbackRate = math.min(3, playbackRate + 0.25)
    speedValue.Text = string.format("%.2fx", playbackRate)
end)

local discordBtn = Instance.new("TextButton", frame)
discordBtn.Size = UDim2.new(0,100,0,30)
discordBtn.AnchorPoint = Vector2.new(0,1)
discordBtn.Position = UDim2.new(0,5,1,-5)
discordBtn.Text = "Discord"
discordBtn.BackgroundColor3 = Color3.fromRGB(90,90,220)
discordBtn.TextColor3 = Color3.fromRGB(255,255,255)
discordBtn.Font = Enum.Font.GothamBold
discordBtn.TextScaled = true
Instance.new("UICorner", discordBtn).CornerRadius = UDim.new(0,8)
discordBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard("https://discord.gg/tfNqRQsqHK")
    end
end)
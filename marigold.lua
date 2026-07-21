local ReplicatedStorage = game:GetService("ReplicatedStorage") 
local Workspace = game:GetService("Workspace") 
local Players = game:GetService("Players") 
local ProximityPromptService = game:GetService("ProximityPromptService") 
local LocalPlayer = Players.LocalPlayer 
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Create Window 
local Window = WindUI:CreateWindow({ 
Title = "Marigold", 
Icon = "umbrella", 
Author = "brought to you by @sean", 
Folder = "WindUI", 
Size = UDim2.fromOffset(620, 440), 
Transparent = true, 
Theme = "Amber", 
SideBarWidth = 200, 
HasOutline = false, 
ToggleOutline = false, 
})

-- Add Version Badge next to the Title 
Window:Tag({ 
Title = "v1.0", 
Color = Color3.fromRGB(255, 170, 0) 
})

-- Info Tab 
local InfoTab = Window:Tab({ 
Title = "Info", 
Icon = "info", 
})

InfoTab:Paragraph({ 
Title = "Information", 
Desc = "Welcome to Marigold, a script made for Animal Hospital: Anomaly! The script is still quite early in development, so expect bugs and broken features.", 
})

InfoTab:Paragraph({ 
Title = "Status", 
Desc = "Earliest release build of Marigold! Contains main functions.", 
})

-- Main Tab 
local MainTab = Window:Tab({ 
Title = "Main", 
Icon = "house" 
})

-- Visuals Tab 
local VisualsTab = Window:Tab({ 
Title = "Visuals", 
Icon = "eye" 
})

-- Automation Tab 
local AutomationTab = Window:Tab({ 
Title = "Automation", 
Icon = "refresh-cw" 
})

-- functions 
MainTab:Button({ 
Title = "Infinite Sanity & No Anomalies", 
Desc = "Vulnerability that allows you to have infinite sanity and prevents anomalies from spawning.", 
Callback = function() 
local Value = true -- Triggering the condition 
if Value then 
local args = {[1] = 0/0, [2] = "Test", n = 2} 
local net = ReplicatedStorage:WaitForChild("Util"):WaitForChild("Net") 
local remote = net:FindFirstChild("RE/PlayerLostSanity") 
if remote then 
remote:FireServer(unpack(args, 1, args.n or #args)) 
end 
end 
end 
})

-- Proximity Prompt Logic State 
local instantPromptsActive = false 
local originalHoldDurations = {}

local function applyInstantPrompt(prompt) 
if not originalHoldDurations[prompt] then 
originalHoldDurations[prompt] = prompt.HoldDuration 
end 
prompt.HoldDuration = 0 
end

local function restorePromptDuration(prompt) 
if originalHoldDurations[prompt] ~= nil then 
prompt.HoldDuration = originalHoldDurations[prompt] 
end 
end

ProximityPromptService.PromptShown:Connect(function(prompt) 
if instantPromptsActive then 
applyInstantPrompt(prompt) 
end 
end)

MainTab:Toggle({ 
Title = "Instant Proximity Prompts", 
Desc = "Removes the hold time for Proximity Prompts.", 
Default = false, 
Callback = function(Value) 
instantPromptsActive = Value 
if Value then 
for _, descendant in ipairs(Workspace:GetDescendants()) do 
if descendant:IsA("ProximityPrompt") then 
applyInstantPrompt(descendant) 
end 
end 
else 
for prompt, _ in pairs(originalHoldDurations) do 
if prompt and prompt.Parent then 
restorePromptDuration(prompt) 
end 
end 
end 
end 
})

-- Helper function to check if the player is holding an item 
local function isHoldingItem() 
local character = LocalPlayer.Character 
if not character then return false end 
for _, child in ipairs(character:GetChildren()) do 
if child:IsA("Tool") then 
return true 
end 
end 
end

---

-- VISUALS: ESP IMPLEMENTATIONS

---

local patientEspHighlights = {} 
local patientEspBillboards = {} 
local anomalyEspHighlights = {} 
local anomalyEspBillboards = {} 
local playerEspHighlights = {} 
local playerEspBillboards = {}

-- Special NPC Name Lookup Table 
local specialNpcs = { 
["Doctor"] = true, 
["Ron from Accounting"] = true, 
["Ratthew"] = true, 
["Liz"] = true 
}

-- 1. Patient ESP Toggle 
local patientEspEnabled = false 
VisualsTab:Toggle({ 
Title = "Patient ESP", 
Desc = "Highlights Patients, Visitors & Skinwalkers.", 
Default = false, 
Callback = function(state) 
patientEspEnabled = state

if not patientEspEnabled then 
for _, hl in pairs(patientEspHighlights) do if hl then hl:Destroy() end end 
for _, bb in pairs(patientEspBillboards) do if bb then bb:Destroy() end end 
patientEspHighlights = {} 
patientEspBillboards = {} 
else 
task.spawn(function() 
while patientEspEnabled do 
local npcsFolder = Workspace:FindFirstChild("NPCs") 
if npcsFolder then 
local activeNpcs = {}

            for _, npc in ipairs(npcsFolder:GetChildren()) do
                if npc:IsA("Model") and npc.Name ~= "Hider" then
                    activeNpcs[npc] = true
                    
                    local isSkinwalker = npc:GetAttribute("Skinwalker") or (npc.Name == "TallMonster")
                    local isSpecial = specialNpcs[npc.Name] == true
                    local isVisitor = npc:GetAttribute("isVisitor")
                    
                    local labelText = npc.Name
                    local fillColor, outlineColor
                    
                    if isVisitor then
                        labelText = labelText .. "\n(Visitor)"
                        fillColor = Color3.fromRGB(0, 120, 255) -- Blue
                        outlineColor = Color3.fromRGB(255, 255, 255)
                    elseif isSpecial then
                        labelText = labelText .. "\n(Special NPC)"
                        fillColor = Color3.fromRGB(170, 0, 255) -- Purple
                        outlineColor = Color3.fromRGB(255, 255, 255)
                    elseif isSkinwalker then
                        labelText = labelText .. "\n(Anomaly)"
                        fillColor = Color3.fromRGB(255, 0, 0) -- Red
                        outlineColor = Color3.fromRGB(255, 255, 255)
                    else
                        labelText = labelText .. "\n(Patient)"
                        fillColor = Color3.fromRGB(0, 255, 0) -- Green
                        outlineColor = Color3.fromRGB(255, 255, 255)
                    end
                    
                    if not patientEspHighlights[npc] then
                        local hl = Instance.new("Highlight")
                        hl.Adornee = npc
                        hl.FillColor = fillColor
                        hl.OutlineColor = outlineColor
                        hl.FillTransparency = 0.5
                        hl.OutlineTransparency = 0
                        hl.Parent = npc
                        patientEspHighlights[npc] = hl
                    end
                    
                    if not patientEspBillboards[npc] then
                        local bb = Instance.new("BillboardGui")
                        bb.Adornee = npc.PrimaryPart or npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChildWhichIsA("BasePart")
                        bb.Size = UDim2.new(0, 200, 0, 60)
                        bb.StudsOffset = Vector3.new(0, 0, 0)
                        bb.AlwaysOnTop = true
                        
                        local textLabel = Instance.new("TextLabel")
                        textLabel.Size = UDim2.new(1, 0, 1, 0)
                        textLabel.BackgroundTransparency = 1
                        textLabel.TextColor3 = fillColor
                        textLabel.TextStrokeTransparency = 0
                        textLabel.TextSize = 14
                        textLabel.Font = Enum.Font.SourceSansBold
                        textLabel.Parent = bb
                        
                        bb.Parent = npc
                        patientEspBillboards[npc] = bb
                    end
                    
                    local bb = patientEspBillboards[npc]
                    local hl = patientEspHighlights[npc]
                    if bb and bb:FindFirstChild("TextLabel") then
                        bb.TextLabel.Text = labelText
                        bb.TextLabel.TextColor3 = fillColor
                    end
                    if hl then
                        hl.FillColor = fillColor
                        hl.OutlineColor = outlineColor
                    end
                end
            end
            
            for npc, hl in pairs(patientEspHighlights) do
                if not activeNpcs[npc] or not npc.Parent then
                    if hl then hl:Destroy() end
                    if patientEspBillboards[npc] then patientEspBillboards[npc]:Destroy() end
                    patientEspHighlights[npc] = nil
                    patientEspBillboards[npc] = nil
                end
            end
        end
        task.wait(1)
    end
end)
end 
end 
})

-- 2. Anomaly ESP Toggle (Strictly targets Hiders or explicitly flagged Skinwalkers) 
local anomalyEspEnabled = false 
VisualsTab:Toggle({ 
Title = "Anomaly ESP", 
Desc = "Highlights Hiders and confirmed Skinwalkers only.", 
Default = false, 
Callback = function(state) 
anomalyEspEnabled = state

if not anomalyEspEnabled then 
for _, hl in pairs(anomalyEspHighlights) do if hl then hl:Destroy() end end 
for _, bb in pairs(anomalyEspBillboards) do if bb then bb:Destroy() end end 
anomalyEspHighlights = {} 
anomalyEspBillboards = {} 
else 
task.spawn(function() 
while anomalyEspEnabled do 
local npcsFolder = Workspace:FindFirstChild("NPCs") 
if npcsFolder then 
local activeAnomalies = {}

            for _, npc in ipairs(npcsFolder:GetChildren()) do
                if npc:IsA("Model") then
                    local isHider = (npc.Name == "Hider")
                    local isSkinwalker = npc:GetAttribute("Skinwalker") or (npc.Name == "TallMonster")
                    
                    -- Strictly look for true anomalies instead of guessing via missing attributes
                    local isTrueAnomaly = isHider or isSkinwalker
                    
                    if isTrueAnomaly then
                        activeAnomalies[npc] = true
                        
                        local labelText = npc.Name .. "\n(Anomaly)"
                        local fillColor = Color3.fromRGB(255, 0, 0) -- Red
                        local outlineColor = Color3.fromRGB(255, 255, 255)
                        
                        if not anomalyEspHighlights[npc] then
                            local hl = Instance.new("Highlight")
                            hl.Adornee = npc
                            hl.FillColor = fillColor
                            hl.OutlineColor = outlineColor
                            hl.FillTransparency = 0.5
                            hl.OutlineTransparency = 0
                            hl.Parent = npc
                            anomalyEspHighlights[npc] = hl
                        end
                        
                        if not anomalyEspBillboards[npc] then
                            local bb = Instance.new("BillboardGui")
                            bb.Adornee = npc.PrimaryPart or npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChildWhichIsA("BasePart")
                            bb.Size = UDim2.new(0, 200, 0, 60)
                            bb.StudsOffset = Vector3.new(0, 0, 0)
                            bb.AlwaysOnTop = true
                            
                            local textLabel = Instance.new("TextLabel")
                            textLabel.Size = UDim2.new(1, 0, 1, 0)
                            textLabel.BackgroundTransparency = 1
                            textLabel.TextColor3 = fillColor
                            textLabel.TextStrokeTransparency = 0
                            textLabel.TextSize = 14
                            textLabel.Font = Enum.Font.SourceSansBold
                            textLabel.Parent = bb
                            
                            bb.Parent = npc
                            anomalyEspBillboards[npc] = bb
                        end
                        
                        local bb = anomalyEspBillboards[npc]
                        local hl = anomalyEspHighlights[npc]
                        if bb and bb:FindFirstChild("TextLabel") then
                            bb.TextLabel.Text = labelText
                            bb.TextLabel.TextColor3 = fillColor
                        end
                        if hl then
                            hl.FillColor = fillColor
                            hl.OutlineColor = outlineColor
                        end
                    end
                end
            end
            
            for npc, hl in pairs(anomalyEspHighlights) do
                if not activeAnomalies[npc] or not npc.Parent then
                    if hl then hl:Destroy() end
                    if anomalyEspBillboards[npc] then anomalyEspBillboards[npc]:Destroy() end
                    anomalyEspHighlights[npc] = nil
                    anomalyEspBillboards[npc] = nil
                end
            end
        end
        task.wait(1)
    end
end)
end 
end 
})

-- 3. Player ESP Toggle 
local playerEspEnabled = false 
VisualsTab:Toggle({ 
Title = "Player ESP", 
Desc = "Highlights players.", 
Default = false, 
Callback = function(state) 
playerEspEnabled = state

if not playerEspEnabled then 
for _, hl in pairs(playerEspHighlights) do if hl then hl:Destroy() end end 
for _, bb in pairs(playerEspBillboards) do if bb then bb:Destroy() end end 
playerEspHighlights = {} 
playerEspBillboards = {} 
else 
task.spawn(function() 
while playerEspEnabled do 
local activePlayers = {}

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local char = player.Character
                activePlayers[char] = true
                
                if not playerEspHighlights[char] then
                    local hl = Instance.new("Highlight")
                    hl.Adornee = char
                    hl.FillColor = Color3.fromRGB(0, 0, 0)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.4
                    hl.OutlineTransparency = 0
                    hl.Parent = char
                    playerEspHighlights[char] = hl
                end
                
                if not playerEspBillboards[char] then
                    local bb = Instance.new("BillboardGui")
                    bb.Adornee = char.PrimaryPart or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart")
                    bb.Size = UDim2.new(0, 200, 0, 60)
                    bb.StudsOffset = Vector3.new(0, 0, 0)
                    bb.AlwaysOnTop = true
                    
                    local textLabel = Instance.new("TextLabel")
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    textLabel.TextStrokeTransparency = 0
                    textLabel.TextSize = 14
                    textLabel.Font = Enum.Font.SourceSansBold
                    textLabel.Text = player.Name .. "\n(Player)"
                    textLabel.Parent = bb
                    
                    bb.Parent = char
                    playerEspBillboards[char] = bb
                end
            end
        end
        
        for char, hl in pairs(playerEspHighlights) do
            if not activePlayers[char] or not char.Parent then
                if hl then hl:Destroy() end
                if playerEspBillboards[char] then playerEspBillboards[char]:Destroy() end
                playerEspHighlights[char] = nil
                playerEspBillboards[char] = nil
            end
        end
        
        task.wait(1)
    end
end)
end 
end 
})

---

-- AUTOMATION TABS & LOGIC

---

-- Auto Check-In Patients Toggle (Automation Tab) 
local autoCheckInEnabled = false

AutomationTab:Toggle({ 
Title = "Auto Check-In Patients", 
Desc = "Automatically checks in patients.", 
Default = false, 
Callback = function(state) 
autoCheckInEnabled = state

if autoCheckInEnabled then 
task.spawn(function() 
while autoCheckInEnabled do 
local checkInPaths = { 
Workspace:FindFirstChild("Misc") and Workspace.Misc:FindFirstChild("CheckIn") and Workspace.Misc.CheckIn:FindFirstChild("Camera") and Workspace.Misc.CheckIn.Camera:FindFirstChild("PP"), 
Workspace:FindFirstChild("Misc") and Workspace.Misc:FindFirstChild("CheckIn") and Workspace.Misc.CheckIn:FindFirstChild("Form") and Workspace.Misc.CheckIn.Form:FindFirstChild("PP"), 
Workspace:FindFirstChild("Misc") and Workspace.Misc:FindFirstChild("CheckIn") and Workspace.Misc.CheckIn:FindFirstChild("Computer") and Workspace.Misc.CheckIn.Computer:FindFirstChild("PP"), 
Workspace:FindFirstChild("Misc") and Workspace.Misc:FindFirstChild("CheckIn") and Workspace.Misc.CheckIn:FindFirstChild("Printer") and Workspace.Misc.CheckIn.Printer:FindFirstChild("PP"), 
Workspace:FindFirstChild("Misc") and Workspace.Misc:FindFirstChild("CheckIn") and Workspace.Misc.CheckIn:FindFirstChild("PrintedBadge") and Workspace.Misc.CheckIn.PrintedBadge:FindFirstChild("PP") 
}

        for _, promptObj in ipairs(checkInPaths) do
            if promptObj and promptObj:IsA("ProximityPrompt") and promptObj.Enabled then
                if promptObj.ActionText ~= "Ask to leave" and promptObj.ObjectText ~= "Ask to leave" then
                    fireproximityprompt(promptObj)
                end
            end
        end

        local npcsFolder = Workspace:FindFirstChild("NPCs")
        if npcsFolder then
            for _, npc in ipairs(npcsFolder:GetChildren()) do
                local promptObj = npc:FindFirstChild("PP")
                if promptObj and promptObj:IsA("ProximityPrompt") and promptObj.Enabled then
                    if promptObj.ActionText ~= "Ask to leave" and promptObj.ObjectText ~= "Ask to leave" then
                        fireproximityprompt(promptObj)
                    end
                end
            end
        end

        task.wait(0.1)
    end
end)
end 
end 
})

-- Auto Patient Results Toggle (Automation Tab) 
local autoPatientResultsEnabled = false

AutomationTab:Toggle({ 
Title = "Auto Patient Results", 
Desc = "Automatically triggers the computers’ prompt in medical rooms, skipping the DNA analysis.", 
Default = false, 
Callback = function(state) 
autoPatientResultsEnabled = state

if autoPatientResultsEnabled then 
task.spawn(function() 
while autoPatientResultsEnabled do 
-- Medical Room Monitors (Rooms 1-5) 
local medicalPrompts = { 
Workspace:FindFirstChild("Rooms") and Workspace.Rooms:FindFirstChild("Medical") and Workspace.Rooms.Medical:FindFirstChild("Room1") and Workspace.Rooms.Medical.Room1:FindFirstChild("Minigame") and Workspace.Rooms.Medical.Room1.Minigame:FindFirstChild("Monitor") and Workspace.Rooms.Medical.Room1.Minigame.Monitor:FindFirstChild("PP2"), 
Workspace:FindFirstChild("Rooms") and Workspace.Rooms:FindFirstChild("Medical") and Workspace.Rooms.Medical:FindFirstChild("Room2") and Workspace.Rooms.Medical.Room2:FindFirstChild("Minigame") and Workspace.Rooms.Medical.Room2.Minigame:FindFirstChild("Monitor") and Workspace.Rooms.Medical.Room2.Minigame.Monitor:FindFirstChild("PP2"), 
Workspace:FindFirstChild("Rooms") and Workspace.Rooms:FindFirstChild("Medical") and Workspace.Rooms.Medical:FindFirstChild("Room3") and Workspace.Rooms.Medical.Room3:FindFirstChild("Minigame") and Workspace.Rooms.Medical.Room3.Minigame:FindFirstChild("Monitor") and Workspace.Rooms.Medical.Room3.Minigame.Monitor:FindFirstChild("PP2"), 
Workspace:FindFirstChild("Rooms") and Workspace.Rooms:FindFirstChild("Medical") and Workspace.Rooms.Medical:FindFirstChild("Room4") and Workspace.Rooms.Medical.Room4:FindFirstChild("Minigame") and Workspace.Rooms.Medical.Room4.Minigame:FindFirstChild("Monitor") and Workspace.Rooms.Medical.Room4.Minigame.Monitor:FindFirstChild("PP2"), 
Workspace:FindFirstChild("Rooms") and Workspace.Rooms:FindFirstChild("Medical") and Workspace.Rooms.Medical:FindFirstChild("Room5") and Workspace.Rooms.Medical.Room5:FindFirstChild("Minigame") and Workspace.Rooms.Medical.Room5.Minigame:FindFirstChild("Monitor") and Workspace.Rooms.Medical.Room5.Minigame.Monitor:FindFirstChild("PP2") 
}

        local triggeredMedical = {}
        for i = 1, #medicalPrompts do
            triggeredMedical[i] = 0
        end

        local medCheckStart = tick()
        while autoPatientResultsEnabled and (tick() - medCheckStart < 1) do
            local allDone = true
            for i, promptObj in ipairs(medicalPrompts) do
                if triggeredMedical[i] < 2 then
                    allDone = false
                    if promptObj and promptObj:IsA("ProximityPrompt") then
                        fireproximityprompt(promptObj)
                        triggeredMedical[i] = triggeredMedical[i] + 1
                    end
                end
            end
            if allDone then break end
            task.wait(0.1)
        end

        -- Emergency Room Prompts
        local emergencyPrompts = {
            Workspace:FindFirstChild("Rooms") and Workspace.Rooms:FindFirstChild("Emergency") and Workspace.Rooms.Emergency:FindFirstChild("Room6") and Workspace.Rooms.Emergency.Room6:FindFirstChild("Minigame") and Workspace.Rooms.Emergency.Room6.Minigame:FindFirstChild("Monitor") and Workspace.Rooms.Emergency.Room6.Minigame.Monitor:FindFirstChild("PP2"),
            Workspace:FindFirstChild("Rooms") and Workspace.Rooms:FindFirstChild("Emergency") and Workspace.Rooms.Emergency:FindFirstChild("Room6") and Workspace.Rooms.Emergency.Room6:FindFirstChild("Minigame") and Workspace.Rooms.Emergency.Room6.Minigame:FindFirstChild("Printer") and Workspace.Rooms.Emergency.Room6.Minigame.Printer:FindFirstChild("PP2"),
            Workspace:FindFirstChild("Rooms") and Workspace.Rooms:FindFirstChild("Emergency") and Workspace.Rooms.Emergency:FindFirstChild("Room7") and Workspace.Rooms.Emergency.Room7:FindFirstChild("Minigame") and Workspace.Rooms.Emergency.Room7.Minigame:FindFirstChild("Monitor") and Workspace.Rooms.Emergency.Room7.Minigame.Monitor:FindFirstChild("PP2"),
            Workspace:FindFirstChild("Rooms") and Workspace.Rooms:FindFirstChild("Emergency") and Workspace.Rooms.Emergency:FindFirstChild("Room7") and Workspace.Rooms.Emergency.Room7:FindFirstChild("Minigame") and Workspace.Rooms.Emergency.Room7.Minigame:FindFirstChild("Printer") and Workspace.Rooms.Emergency.Room7.Minigame.Printer:FindFirstChild("PP2")
        }

        local triggerCounts = {0, 0, 0, 0}
        local emCheckStart = tick()
        while autoPatientResultsEnabled and (tick() - emCheckStart < 1) do
            local emergencyDone = true
            for i, promptObj in ipairs(emergencyPrompts) do
                if triggerCounts[i] < 2 then
                    emergencyDone = false
                    if promptObj and promptObj:IsA("ProximityPrompt") then
                        fireproximityprompt(promptObj)
                        triggerCounts[i] = triggerCounts[i] + 1.0
                    end
                end
            end
            if emergencyDone then break end
            task.wait(0.1)
        end

        -- Bed Prompts (Apply Treatment)
        local bedPrompts = {
            Workspace:FindFirstChild("Rooms") and Workspace.Rooms:FindFirstChild("Medical") and Workspace.Rooms.Medical:FindFirstChild("Room1") and Workspace.Rooms.Medical.Room1:FindFirstChild("Minigame") and Workspace.Rooms.Medical.Room1.Minigame:FindFirstChild("Bed") and Workspace.Rooms.Medical.Room1.Minigame.Bed:FindFirstChild("InBed") and Workspace.Rooms.Medical.Room1.Minigame.Bed.InBed:FindFirstChild("PP"),
            Workspace:FindFirstChild("Rooms") and Workspace.Rooms:FindFirstChild("Medical") and Workspace.Rooms.Medical:FindFirstChild("Room2") and Workspace.Rooms.Medical.Room2:FindFirstChild("Minigame") and Workspace.Rooms.Medical.Room2.Minigame.Bed:FindFirstChild("InBed") and Workspace.Rooms.Medical.Room2.Minigame.Bed.InBed:FindFirstChild("PP"),
            Workspace:FindFirstChild("Rooms") and Workspace.Rooms:FindFirstChild("Medical") and Workspace.Rooms.Medical:FindFirstChild("Room3") and Workspace.Rooms.Medical.Room3:FindFirstChild("Minigame") and Workspace.Rooms.Medical.Room3.Minigame.Bed:FindFirstChild("InBed") and Workspace.Rooms.Medical.Room3.Minigame.Bed.InBed:FindFirstChild("PP"),
            Workspace:FindFirstChild("Rooms") and Workspace.Rooms:FindFirstChild("Medical") and Workspace.Rooms.Medical:FindFirstChild("Room4") and Workspace.Rooms.Medical.Room4:FindFirstChild("Minigame") and Workspace.Rooms.Medical.Room4.Minigame.Bed:FindFirstChild("InBed") and Workspace.Rooms.Medical.Room4.Minigame.Bed.InBed:FindFirstChild("PP"),
            Workspace:FindFirstChild("Rooms") and Workspace.Rooms:FindFirstChild("Medical") and Workspace.Rooms.Medical:FindFirstChild("Room5") and Workspace.Rooms.Medical.Room5:FindFirstChild("Minigame") and Workspace.Rooms.Medical.Room5.Minigame.Bed:FindFirstChild("InBed") and Workspace.Rooms.Medical.Room5.Minigame.Bed.InBed:FindFirstChild("PP"),
            Workspace:FindFirstChild("Rooms") and Workspace.Rooms:FindFirstChild("Emergency") and Workspace.Rooms.Emergency:FindFirstChild("Room7") and Workspace.Rooms.Emergency.Room7:FindFirstChild("Minigame") and Workspace.Rooms.Emergency.Room7.Minigame.Bed:FindFirstChild("InBed") and Workspace.Rooms.Emergency.Room7.Minigame.Bed.InBed:FindFirstChild("PP")
        }

        if isHoldingItem() then
            for _, promptObj in ipairs(bedPrompts) do
                if promptObj and promptObj:IsA("ProximityPrompt") then
                    fireproximityprompt(promptObj)
                    task.wait(0.1)
                end
            end
        end

        task.wait(0.2)
    end
end)
end 
end 
})

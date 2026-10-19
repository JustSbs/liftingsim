--// CONFIG

local CONFIG = {

    --// TELEPORT + ANTI AFK KICK
    TELEPORT_POSITION = Vector3.new(14992, -55, 938),
    TELEPORT_INTERVAL = 0.1,
    JUMP_INTERVAL = 5,
    MOVEMENT_INTERVAL = 2,

    --// BUY, SELL
    SELL_INTERVAL = 1800,

    BUY_INTERVAL = 15,
    BUY_CATEGORY = "Income_Item",
    BUY_ITEM = "1ST SUPREME CLASS",
    BUY_ID = 136,

    --// UI
    TITLE = "Gud script - By @justsbsxd",
    SUBTITLE = "Lifting Sim",

    --// SETTINGS
    SETTINGS_FILE = "LiftingSimSbs.txt",
    WEBHOOK = "https://discord.com/api/webhooks/1557771666656854078/K4UIB4GDdL4dlgBHt0sDCrIeMlkYHuePt5idqvxVroCgo5_-p8JVZOiZy8DPLbAYtg0z",
}

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

--// WEBHOOK

local request = http_request or request

if request then
    pcall(request, {
        Url = CONFIG.WEBHOOK,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode({ content = "script executed" }),
    })
end

--// CLOSE PREVIOUS UI (EXECUTING MULTIPLE REPLACES OLD UI + STOPS ITS LOOPS)

local env = getgenv and getgenv() or _G

if env.GudScriptWindow then
    pcall(function()
        env.GudScriptWindow:Unload()
    end)
    env.GudScriptWindow = nil
end

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()


--// SETTINGS FILE (RAYFIELD CONFIGS = OFF)

local settings = { teleport = false, autoSell = false, autoBuy = false }

local function saveSettings()
    if not writefile then return end

    local lines = {}
    for key, value in pairs(settings) do
        lines[#lines + 1] = key .. "=" .. tostring(value)
    end

    pcall(writefile, CONFIG.SETTINGS_FILE, table.concat(lines, "\n"))
end

if isfile and readfile and isfile(CONFIG.SETTINGS_FILE) then
    local ok, content = pcall(readfile, CONFIG.SETTINGS_FILE)

    if ok and content then
        for key, value in content:gmatch("([^=\r\n]+)=([^\r\n]*)") do
            key = key:match("^%s*(.-)%s*$")
            value = value:match("^%s*(.-)%s*$")

            if settings[key] ~= nil then
                settings[key] = (value == "true")
            end
        end
    end
else
    saveSettings()
end

--// UI

local window = Rayfield:CreateWindow({
    name = CONFIG.TITLE,
    subtitle = CONFIG.SUBTITLE,
})

env.GudScriptWindow = window

local tab = window:CreateTab({ name = "Main" })

local function addToggle(name, key)
    tab:CreateToggle({
        name = name,
        value = settings[key],
        forgetState = true,
        callback = function(value)
            if settings[key] ~= value then
                settings[key] = value
                saveSettings()
            end
        end,
    })
end

addToggle("Teleport", "teleport")
addToggle("Auto Sell", "autoSell")
addToggle("Auto Buy", "autoBuy")

tab:CreateButton({
    name = "Close UI",
    callback = function()
        window:Unload()
        env.GudScriptWindow = nil
    end,
})

--// LOOPS

local function every(interval, settingKey, action)
    task.spawn(function()
        while not window.unloaded do
            if settings[settingKey] then
                pcall(action)
            end
            task.wait(interval)
        end
    end)
end

local function getRoot()
    local character = player.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local character = player.Character
    return character and character:FindFirstChildOfClass("Humanoid")
end

local direction = 1

every(CONFIG.TELEPORT_INTERVAL, "teleport", function()
    local root = getRoot()
    if root then
        root.CFrame = CFrame.new(CONFIG.TELEPORT_POSITION)
    end
end)

every(CONFIG.JUMP_INTERVAL, "teleport", function()
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.Jump = true
    end
end)

every(CONFIG.MOVEMENT_INTERVAL, "teleport", function()
    local humanoid = getHumanoid()
    if humanoid then
        humanoid:Move(Vector3.new(direction, 0, 0), false)
        direction = -direction
    end
end)

every(CONFIG.SELL_INTERVAL, "autoSell", function()
    ReplicatedStorage.RemoteEvent:FireServer({ "SellMuscle" })
end)

every(CONFIG.BUY_INTERVAL, "autoBuy", function()
    ReplicatedStorage.RemoteEvent:FireServer({ "BuyItem", CONFIG.BUY_CATEGORY, CONFIG.BUY_ITEM, CONFIG.BUY_ID })
end)

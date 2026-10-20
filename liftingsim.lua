
--// CONFIG

local CONFIG = {
    --// TELEPORT + ANTI AFK KICK
    TELEPORT_POSITION = Vector3.new(33513, -58, 933),
    TELEPORT_INTERVAL = 0.1,
    JUMP_INTERVAL = 5,
    MOVEMENT_INTERVAL = 2,

    --// BUY, SELL, LIFT
    SELL_INTERVAL = 1800,
    LIFT_INTERVAL = 0.15,
    LIFTBUY_INTERVAL = 15,
    LIFTBUY_CATEGORY = "Income_Item",
    LIFTBUY_ITEM = "4TH SUPREME CLASS",
    LIFTBUY_ID = 138,

    STAGEBUY_INTERVAL = 15,
    STAGEBUY_CATEGORY = "Rebirth_Item",
    STAGEBUY_ITEM = "Rebirth30",
    STAGEBUY_ID = 30,

    --// UI
    TITLE = "Gud script - By @justsbsxd",
    SUBTITLE = "Lifting Sim",

    --// SETTINGS
    SETTINGS_FILE = "LiftingSimSbs.txt",
    WEBHOOK = ""
}

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

--// CLOSE PREVIOUS UI

local env = getgenv and getgenv() or _G

if env.GudScriptWindow then
    pcall(function()
        env.GudScriptWindow:Unload()
    end)
    env.GudScriptWindow = nil
end

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

--// SETTINGS

local settings = {
    teleport = false,
    autoSell = false,
    autoBuy = false,
    autoLift = false,
    autoStage = false,
    webhookEnabled = true,
    webhookMuscle = true,
    webhookCoins = true,
    webhookMulti = true,
    webhookUrl = CONFIG.WEBHOOK
}

local delays = {
    autoSell = CONFIG.SELL_INTERVAL,
    autoBuy = CONFIG.LIFTBUY_INTERVAL,
    autoLift = CONFIG.LIFT_INTERVAL,
    autoStage = CONFIG.STAGEBUY_INTERVAL,
}

local function saveSettings()
    if not writefile then return end

    local lines = {}

    for key, value in pairs(settings) do
        lines[#lines + 1] = key .. "=" .. tostring(value)
    end

    for key, value in pairs(delays) do
        lines[#lines + 1] = "delay_" .. key .. "=" .. tostring(value)
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
                if type(settings[key]) == "boolean" then
                    settings[key] = value == "true"
                else
                    settings[key] = value
                end
            elseif key:sub(1, 6) == "delay_" and delays[key:sub(7)] ~= nil then
                delays[key:sub(7)] = tonumber(value) or delays[key:sub(7)]
            end
        end
    end
else
    saveSettings()
end

--// WEBHOOK

local function sendWebhook()
    local requestFunction = http_request or request

    if not requestFunction or not settings.webhookUrl or settings.webhookUrl == "" then
        return
    end

    local success, result = pcall(function()
        local gui = player:WaitForChild("PlayerGui"):WaitForChild("Main_Gui")
        local dataMenu = gui:WaitForChild("DataMenu_Frame")

        local muscle = dataMenu:WaitForChild("Muscle"):WaitForChild("Status")
        local coins = dataMenu:WaitForChild("Cash"):WaitForChild("Status")
        local multiplier = gui:WaitForChild("RiskyMuscleMulti_Txt")

        local fields = {}

        if settings.webhookMuscle then
            fields[#fields + 1] = {
                name = "Muscle",
                value = tostring(muscle.Text),
                inline = true
            }
        end

        if settings.webhookCoins then
            fields[#fields + 1] = {
                name = "Coins",
                value = tostring(coins.Text),
                inline = true
            }
        end

        if settings.webhookMulti then
            fields[#fields + 1] = {
                name = "Multi",
                value = tostring(multiplier.Text):match("x%s*[%d%.]+") or tostring(multiplier.Text),
                inline = true
            }
        end

        if #fields == 0 then
            return
        end

        requestFunction({
            Url = settings.webhookUrl,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode({
                embeds = {{
                    title = "Current Stats",
                    fields = fields,
                    footer = {
                        text = "Gud script - By @justsbsxd"
                    }
                }}
            })
        })
    end)

    if not success then
        warn("Webhook failed:", result)
    end
end

--// UI

local window = Rayfield:CreateWindow({
    name = CONFIG.TITLE,
    subtitle = CONFIG.SUBTITLE,
})

env.GudScriptWindow = window

local tab = window:CreateTab({ name = "Main" })
local autoTab = window:CreateTab({ name = "Auto" })
local webhookTab = window:CreateTab({ name = "Webhook" })

local function addToggle(targetTab, name, key)
    targetTab:CreateToggle({
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

tab:CreateDivider({ name = "Toggles" })

addToggle(tab, "Teleport", "teleport")

tab:CreateButton({
    name = "Close UI",
    callback = function()
        window:Unload()
        env.GudScriptWindow = nil
    end,
})

autoTab:CreateDivider({ name = "Toggles" })

addToggle(autoTab, "Auto Sell", "autoSell")
addToggle(autoTab, "Auto Buy", "autoBuy")
addToggle(autoTab, "Auto Lift", "autoLift")
addToggle(autoTab, "Auto Stage", "autoStage")

autoTab:CreateDivider({ name = "Delays" })

local function addDelay(name, key)
    autoTab:CreateInput({
        name = name,
        placeholder = tostring(delays[key]),
        value = tostring(delays[key]),
        callback = function(value)
            local number = tonumber(value)

            if number and number > 0 then
                delays[key] = number
                saveSettings()
            end
        end,
    })
end

addDelay("Auto Sell Delay", "autoSell")
addDelay("Auto Buy Delay", "autoBuy")
addDelay("Auto Lift Delay", "autoLift")
addDelay("Auto Stage Delay", "autoStage")

--// WEBHOOK TAB

webhookTab:CreateDivider({ name = "Configuration" })

webhookTab:CreateInput({
    name = "Webhook URL",
    placeholder = "Enter Discord webhook URL",
    value = settings.webhookUrl,
    callback = function(value)
        settings.webhookUrl = value
        saveSettings()
    end,
})

webhookTab:CreateDivider({ name = "Options" })

addToggle(webhookTab, "Send Webhook", "webhookEnabled")
addToggle(webhookTab, "Muscle", "webhookMuscle")
addToggle(webhookTab, "Coins", "webhookCoins")
addToggle(webhookTab, "Multi", "webhookMulti")

webhookTab:CreateButton({
    name = "Send Test Webhook",
    callback = function()
        if settings.webhookEnabled then
            task.spawn(sendWebhook)
        end
    end,
})

if settings.webhookEnabled then
    task.spawn(sendWebhook)
end

--// LOOPS

local function every(interval, settingKey, action)
    task.spawn(function()
        while not window.unloaded do
            if settings[settingKey] then
                pcall(action)
            end

            task.wait(type(interval) == "function" and interval() or interval)
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

every(function() return delays.autoSell end, "autoSell", function()
    ReplicatedStorage.RemoteEvent:FireServer({ "SellMuscle" })
end)

every(function() return delays.autoBuy end, "autoBuy", function()
    ReplicatedStorage.RemoteEvent:FireServer({
        "BuyItem",
        CONFIG.LIFTBUY_CATEGORY,
        CONFIG.LIFTBUY_ITEM,
        CONFIG.LIFTBUY_ID
    })
end)

every(function() return delays.autoLift end, "autoLift", function()
    ReplicatedStorage.RemoteEvent:FireServer({ "GainMuscle" })
end)

every(function() return delays.autoStage end, "autoStage", function()
    ReplicatedStorage.RemoteEvent:FireServer({
        "BuyItem",
        CONFIG.STAGEBUY_CATEGORY,
        CONFIG.STAGEBUY_ITEM,
        CONFIG.STAGEBUY_ID
    })
end)

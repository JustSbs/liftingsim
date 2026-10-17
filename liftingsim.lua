local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

--// CONFIG

local TELEPORT_INTERVAL = 0.1
local JUMP_INTERVAL = 5
local MOVEMENT_INTERVAL = 2
local SELL_INTERVAL = 1800
local BUY_INTERVAL = 15

local TELEPORT_POSITION = Vector3.new(14992, -55, 938)

--// FILE SETTINGS

local SETTINGS_FILE = "LiftingSimSbs.txt"

local defaultSettings = {
    teleport = false,
    autoSell = false,
    autoBuy = false,
    minimized = false,

    positionX = 0,
    positionY = 0,

    miniPositionX = 30,
    miniPositionY = 300
}

local settings = {}

for key, value in pairs(defaultSettings) do
    settings[key] = value
end

--// Save Settings

local function saveSettings()
    if not writefile then
        return
    end

    local content = table.concat({
        "teleport=" .. tostring(settings.teleport),
        "autoSell=" .. tostring(settings.autoSell),
        "autoBuy=" .. tostring(settings.autoBuy),
        "minimized=" .. tostring(settings.minimized),
        "positionX=" .. tostring(settings.positionX),
        "positionY=" .. tostring(settings.positionY),
        "miniPositionX=" .. tostring(settings.miniPositionX),
        "miniPositionY=" .. tostring(settings.miniPositionY)
    }, "\n")

    pcall(function()
        writefile(SETTINGS_FILE, content)
    end)
end

--// Load Settings

local function loadSettings()
    if not isfile or not readfile then
        return
    end

    if not isfile(SETTINGS_FILE) then
        saveSettings()
        return
    end

    local success, content = pcall(readfile, SETTINGS_FILE)

    if not success or not content then
        return
    end

    for line in content:gmatch("[^\r\n]+") do
        local key, value = line:match("^([^=]+)=(.*)$")

        if key and value then
            key = key:gsub("^%s+", ""):gsub("%s+$", "")
            value = value:gsub("^%s+", ""):gsub("%s+$", "")

            if defaultSettings[key] ~= nil then
                if type(defaultSettings[key]) == "boolean" then
                    if value == "true" then
                        settings[key] = true
                    elseif value == "false" then
                        settings[key] = false
                    end
                elseif type(defaultSettings[key]) == "number" then
                    local number = tonumber(value)

                    if number then
                        settings[key] = number
                    end
                else
                    settings[key] = value
                end
            end
        end
    end
end

--// Change Setting + Immediately Save

local function setSetting(key, value)
    if settings[key] ~= value then
        settings[key] = value
        saveSettings()
    end
end

loadSettings()

--// GUI

local playerGui = player:WaitForChild("PlayerGui")
local oldGui = playerGui:FindFirstChild("GudScriptUI")

if oldGui then
    oldGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GudScriptUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = player:WaitForChild("PlayerGui")

--// Main

local Main = Instance.new("Frame")
Main.Name = "Main"

local camera = workspace.CurrentCamera
local viewport = camera and camera.ViewportSize or Vector2.new(800, 600)
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local mainWidth = math.min(390, math.max(280, viewport.X - 24))
local mainHeight = math.min(290, math.max(240, viewport.Y - 40))

Main.Size = UDim2.fromOffset(mainWidth, mainHeight)

local function clampToViewport(x, y, width, height)
    local currentCamera = workspace.CurrentCamera
    local view = currentCamera and currentCamera.ViewportSize or Vector2.new(800, 600)
    return math.clamp(x, 8, math.max(8, view.X - width - 8)),
           math.clamp(y, 8, math.max(8, view.Y - height - 8))
end

local defaultX = math.max(8, (viewport.X - mainWidth) / 2)
local defaultY = math.max(8, (viewport.Y - mainHeight) / 2)
local savedX = isMobile and defaultX or (settings.positionX or defaultX)
local savedY = isMobile and defaultY or (settings.positionY or defaultY)
savedX, savedY = clampToViewport(savedX, savedY, mainWidth, mainHeight)
Main.Position = UDim2.fromOffset(savedX, savedY)

Main.BackgroundColor3 = Color3.fromRGB(15, 15, 19)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(55, 55, 65)
MainStroke.Thickness = 1
MainStroke.Transparency = 0.25
MainStroke.Parent = Main

--// Shadow

local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.Position = UDim2.new(0.5, 0, 0.5, 7)
Shadow.Size = UDim2.new(1, 35, 1, 35)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://6014261993"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.45
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
Shadow.ZIndex = 0
Shadow.Parent = Main

Main.ZIndex = 2

--// Header

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 58)
Header.BackgroundTransparency = 1
Header.Parent = Main
Header.ZIndex = 3

local Title = Instance.new("TextLabel")
Title.Position = UDim2.new(0, 14, 0, 9)
Title.Size = UDim2.new(1, -105, 0, 25)
Title.BackgroundTransparency = 1
Title.Text = "Gud script - By @justsbsxd"
Title.TextColor3 = Color3.fromRGB(245, 245, 250)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header
Title.ZIndex = 4

local Line = Instance.new("Frame")
Line.Position = UDim2.new(0, 20, 1, -1)
Line.Size = UDim2.new(1, -40, 0, 1)
Line.BackgroundColor3 = Color3.fromRGB(45, 45, 53)
Line.BorderSizePixel = 0
Line.Parent = Header
Line.ZIndex = 4

--// Close

local Close = Instance.new("TextButton")
Close.Position = UDim2.new(1, -45, 0, 12)
Close.Size = UDim2.new(0, 30, 0, 30)
Close.BackgroundColor3 = Color3.fromRGB(30, 30, 37)
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(180, 180, 190)
Close.TextSize = 20
Close.Font = Enum.Font.GothamMedium
Close.AutoButtonColor = false
Close.Parent = Header
Close.ZIndex = 5

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = Close

Close.MouseEnter:Connect(function()
    TweenService:Create(
        Close,
        TweenInfo.new(0.15),
        {
            BackgroundColor3 = Color3.fromRGB(190, 55, 65),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }
    ):Play()
end)

Close.MouseLeave:Connect(function()
    TweenService:Create(
        Close,
        TweenInfo.new(0.15),
        {
            BackgroundColor3 = Color3.fromRGB(30, 30, 37),
            TextColor3 = Color3.fromRGB(180, 180, 190)
        }
    ):Play()
end)

Close.MouseButton1Click:Connect(function()
    settings.positionX = Main.AbsolutePosition.X
    settings.positionY = Main.AbsolutePosition.Y

    saveSettings()

    TweenService:Create(
        Main,
        TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
        {
            Size = UDim2.new(0, 390, 0, 0)
        }
    ):Play()

    task.wait(0.2)

    ScreenGui:Destroy()
end)

--// Minimize Button

local Minimize = Instance.new("TextButton")
Minimize.Position = UDim2.new(1, -82, 0, 12)
Minimize.Size = UDim2.new(0, 30, 0, 30)
Minimize.BackgroundColor3 = Color3.fromRGB(30, 30, 37)
Minimize.Text = "−"
Minimize.TextColor3 = Color3.fromRGB(180, 180, 190)
Minimize.TextSize = 18
Minimize.Font = Enum.Font.GothamMedium
Minimize.AutoButtonColor = false
Minimize.Parent = Header
Minimize.ZIndex = 5

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = Minimize

--// Mini Button

local MiniButton = Instance.new("TextButton")
MiniButton.Name = "MiniButton"
MiniButton.Size = UDim2.new(0, 50, 0, 50)

local miniDefaultX = math.max(8, math.min(30, viewport.X - 58))
local miniDefaultY = math.max(8, math.min(300, viewport.Y - 58))
local miniX = isMobile and miniDefaultX or (settings.miniPositionX or miniDefaultX)
local miniY = isMobile and miniDefaultY or (settings.miniPositionY or miniDefaultY)
miniX, miniY = clampToViewport(miniX, miniY, 50, 50)
MiniButton.Position = UDim2.fromOffset(miniX, miniY)

MiniButton.BackgroundColor3 = Color3.fromRGB(15, 15, 19)
MiniButton.BorderSizePixel = 0
MiniButton.Text = "S"
MiniButton.TextColor3 = Color3.fromRGB(245, 245, 250)
MiniButton.TextSize = 20
MiniButton.Font = Enum.Font.GothamBold
MiniButton.Visible = false
MiniButton.AutoButtonColor = false
MiniButton.Parent = ScreenGui
MiniButton.ZIndex = 20

local MiniCorner = Instance.new("UICorner")
MiniCorner.CornerRadius = UDim.new(0, 12)
MiniCorner.Parent = MiniButton

local MiniStroke = Instance.new("UIStroke")
MiniStroke.Color = Color3.fromRGB(55, 55, 65)
MiniStroke.Thickness = 1
MiniStroke.Transparency = 0.1
MiniStroke.Parent = MiniButton

--// Mini Button Hover

MiniButton.MouseEnter:Connect(function()
    TweenService:Create(
        MiniButton,
        TweenInfo.new(0.15),
        {
            BackgroundColor3 = Color3.fromRGB(30, 30, 38)
        }
    ):Play()
end)

MiniButton.MouseLeave:Connect(function()
    TweenService:Create(
        MiniButton,
        TweenInfo.new(0.15),
        {
            BackgroundColor3 = Color3.fromRGB(15, 15, 19)
        }
    ):Play()
end)

--// Content

local Content = Instance.new("Frame")
Content.Position = UDim2.new(0, 15, 0, 68)
Content.Size = UDim2.new(1, -30, 1, -83)
Content.BackgroundTransparency = 1
Content.Parent = Main
Content.ZIndex = 3
Content.ClipsDescendants = true

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 10)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Content

local ContentPadding = Instance.new("UIPadding")
ContentPadding.PaddingBottom = UDim.new(0, 4)
ContentPadding.Parent = Content

--// Toggle Creator

local function createToggle(text, defaultValue, callback)
    local Button = Instance.new("TextButton")

    Button.Size = UDim2.new(1, 0, 0, 52)
    Button.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    Button.BorderSizePixel = 0
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.Parent = Content
    Button.ZIndex = 4

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Button

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(40, 40, 48)
    Stroke.Thickness = 1
    Stroke.Transparency = 0.2
    Stroke.Parent = Button

    local Label = Instance.new("TextLabel")
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.Size = UDim2.new(1, -80, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(225, 225, 230)
    Label.TextSize = 14
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Button
    Label.ZIndex = 5

    local Switch = Instance.new("Frame")
    Switch.Position = UDim2.new(1, -58, 0.5, -11)
    Switch.Size = UDim2.new(0, 42, 0, 22)
    Switch.BackgroundColor3 = Color3.fromRGB(42, 42, 50)
    Switch.BorderSizePixel = 0
    Switch.Parent = Button
    Switch.ZIndex = 5

    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = Switch

    local Circle = Instance.new("Frame")
    Circle.Position = UDim2.new(0, 3, 0.5, -8)
    Circle.Size = UDim2.new(0, 16, 0, 16)
    Circle.BackgroundColor3 = Color3.fromRGB(170, 170, 180)
    Circle.BorderSizePixel = 0
    Circle.Parent = Switch
    Circle.ZIndex = 6

    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = Circle

    local enabled = defaultValue

    local function update(animated)
        local switchColor
        local circleColor
        local circlePosition

        if enabled then
            switchColor = Color3.fromRGB(75, 115, 255)
            circleColor = Color3.fromRGB(255, 255, 255)
            circlePosition = UDim2.new(1, -19, 0.5, -8)
        else
            switchColor = Color3.fromRGB(42, 42, 50)
            circleColor = Color3.fromRGB(170, 170, 180)
            circlePosition = UDim2.new(0, 3, 0.5, -8)
        end

        local info = TweenInfo.new(
            animated and 0.18 or 0,
            Enum.EasingStyle.Quart,
            Enum.EasingDirection.Out
        )

        TweenService:Create(
            Switch,
            info,
            {
                BackgroundColor3 = switchColor
            }
        ):Play()

        TweenService:Create(
            Circle,
            info,
            {
                Position = circlePosition,
                BackgroundColor3 = circleColor
            }
        ):Play()
    end

    Button.MouseEnter:Connect(function()
        TweenService:Create(
            Button,
            TweenInfo.new(0.15),
            {
                BackgroundColor3 = Color3.fromRGB(27, 27, 34)
            }
        ):Play()
    end)

    Button.MouseLeave:Connect(function()
        TweenService:Create(
            Button,
            TweenInfo.new(0.15),
            {
                BackgroundColor3 = Color3.fromRGB(22, 22, 28)
            }
        ):Play()
    end)

    Button.MouseButton1Click:Connect(function()
        enabled = not enabled

        update(true)
        callback(enabled)
    end)

    update(false)

    return {
        set = function(value)
            enabled = value
            update(true)
        end,

        get = function()
            return enabled
        end
    }
end

--// Toggles

local TeleportToggle = createToggle(
    "Teleport",
    settings.teleport,
    function(value)
        setSetting("teleport", value)
    end
)

local SellToggle = createToggle(
    "Auto Sell",
    settings.autoSell,
    function(value)
        setSetting("autoSell", value)
    end
)

local AutoBuyToggle = createToggle(
    "Auto Buy (1ST SUPREME CLASS)",
    settings.autoBuy,
    function(value)
        setSetting("autoBuy", value)
    end
)

--// Main GUI Dragging (mouse + touch)

local dragging = false
local dragInput
local dragStart
local startPos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragInput = input
        dragStart = input.Position
        startPos = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart
        local x, y = clampToViewport(
            startPos.X.Offset + delta.X,
            startPos.Y.Offset + delta.Y,
            Main.AbsoluteSize.X,
            Main.AbsoluteSize.Y
        )
        Main.Position = UDim2.fromOffset(x, y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if dragging and (
        input == dragInput
        or input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        dragging = false
        dragInput = nil
        if not isMobile then
            settings.positionX = Main.AbsolutePosition.X
            settings.positionY = Main.AbsolutePosition.Y
            saveSettings()
        end
    end
end)

--// Mini Button Dragging (mouse + touch)

local miniDragging = false
local miniDragInput
local miniDragStart
local miniStartPos

MiniButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        miniDragging = true
        miniDragInput = input
        miniDragStart = input.Position
        miniStartPos = MiniButton.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if miniDragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - miniDragStart
        local x, y = clampToViewport(
            miniStartPos.X.Offset + delta.X,
            miniStartPos.Y.Offset + delta.Y,
            MiniButton.AbsoluteSize.X,
            MiniButton.AbsoluteSize.Y
        )
        MiniButton.Position = UDim2.fromOffset(x, y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if miniDragging and (
        input == miniDragInput
        or input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        miniDragging = false
        miniDragInput = nil
        if not isMobile then
            settings.miniPositionX = MiniButton.AbsolutePosition.X
            settings.miniPositionY = MiniButton.AbsolutePosition.Y
            saveSettings()
        end
    end
end)

--// Minimize

Minimize.MouseButton1Click:Connect(function()
    if not isMobile then
        settings.positionX = Main.AbsolutePosition.X
        settings.positionY = Main.AbsolutePosition.Y
    end

    setSetting("minimized", true)

    Main.Visible = false
    MiniButton.Visible = true
end)

--// Restore From Mini Button

MiniButton.MouseButton1Click:Connect(function()
    setSetting("minimized", false)

    Main.Visible = true
    MiniButton.Visible = false
end)

--// Apply Saved Minimized State

if settings.minimized then
    Main.Visible = false
    MiniButton.Visible = true
end

--// Teleport Loop

task.spawn(function()
    while ScreenGui.Parent do
        if settings.teleport then
            local character = player.Character

            if character then
                local root = character:FindFirstChild("HumanoidRootPart")

                if root then
                    root.CFrame = CFrame.new(TELEPORT_POSITION)
                end
            end
        end

        task.wait(TELEPORT_INTERVAL)
    end
end)

--// Jump Loop

task.spawn(function()
    while ScreenGui.Parent do
        if settings.teleport then
            local character = player.Character

            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")

                if humanoid then
                    humanoid.Jump = true
                end
            end
        end

        task.wait(JUMP_INTERVAL)
    end
end)

--// Movement Loop

task.spawn(function()
    local direction = 1

    while ScreenGui.Parent do
        if settings.teleport then
            local character = player.Character

            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")

                if humanoid then
                    humanoid:Move(
                        Vector3.new(direction, 0, 0),
                        false
                    )

                    direction = -direction
                end
            end
        end

        task.wait(MOVEMENT_INTERVAL)
    end
end)

--// Auto Sell

task.spawn(function()
    while ScreenGui.Parent do
        if settings.autoSell then
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").RemoteEvent

                Event:FireServer({
                    "SellMuscle"
                })
            end)
        end

        task.wait(SELL_INTERVAL)
    end
end)

--// Auto Buy

task.spawn(function()
    while ScreenGui.Parent do
        if settings.autoBuy then
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").RemoteEvent

                Event:FireServer({
                    "BuyItem",
                    "Income_Item",
                    "1ST SUPREME CLASS",
                    136
                })
            end)
        end

        task.wait(BUY_INTERVAL)
    end
end)

--// Save When Leaving

Players.PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == player then
        if not isMobile then
            settings.positionX = Main.AbsolutePosition.X
            settings.positionY = Main.AbsolutePosition.Y
            settings.miniPositionX = MiniButton.AbsolutePosition.X
            settings.miniPositionY = MiniButton.AbsolutePosition.Y
        end

        saveSettings()
    end
end)

--// Initial Save

saveSettings()

local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local ConfigPath = "ZuperMing/Config/"

if not isfolder("ZuperMing") then makefolder("ZuperMing") end
if not isfolder("ZuperMing/Config") then makefolder("ZuperMing/Config") end

local ConfigData = {}
local Elements = {}
local CURRENT_VERSION = nil

-- [[ UTILITIES ]] --
local function SaveConfig(name)
    local fileName = ConfigPath .. (name or "Default") .. ".json"
    if writefile then
        ConfigData._version = CURRENT_VERSION
        writefile(fileName, HttpService:JSONEncode(ConfigData))
    end
end

local function LoadConfigFromFile(name)
    local fileName = ConfigPath .. (name or "Default") .. ".json"
    if isfile and isfile(fileName) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(fileName))
        end)
        if success and type(result) == "table" then
            ConfigData = result
            return true
        end
    end
    return false
end

local Icons = {
    info = "rbxassetid://10723415903",
    main = "rbxassetid://10723407389",
    auto = "rbxassetid://10734923214",
    shop = "rbxassetid://10734952479",
    teleport = "rbxassetid://10734886004",
    event = "rbxassetid://10709789505",
    webhook = "rbxassetid://10709775560",
    peformance = "rbxassetid://10734963400",
    misc = "rbxassetid://10734972862",
    config = "rbxassetid://10734950309",
}

local viewport = workspace.CurrentCamera.ViewportSize

local function isMobileDevice()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled
end

local isMobile = isMobileDevice()

local function safeSize(pxWidth, pxHeight)
    local scaleX = pxWidth / viewport.X
    local scaleY = pxHeight / viewport.Y
    if isMobile then
        if scaleX > 0.5 then scaleX = 0.5 end
        if scaleY > 0.3 then scaleY = 0.3 end
    end
    return UDim2.new(scaleX, 0, scaleY, 0)
end

-- [[ OPTIMIZED DRAGGING (NO TWEEN) ]] --
local function MakeDraggable(topbarobject, object)
    local Dragging, DragInput, DragStart, StartPosition

    local function UpdatePos(input)
        local Delta = input.Position - DragStart
        local pos = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )
        object.Position = pos
    end

    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    topbarobject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            UpdatePos(input)
        end
    end)
end

local function CircleClick(Button, X, Y)
    task.spawn(function()
        Button.ClipsDescendants = true
        local Circle = Instance.new("ImageLabel")
        Circle.Image = "rbxassetid://266543268"
        Circle.ImageColor3 = Color3.fromRGB(80, 80, 80)
        Circle.ImageTransparency = 0.8999999761581421
        Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Circle.BackgroundTransparency = 1
        Circle.ZIndex = 10
        Circle.Name = "Circle"
        Circle.Parent = Button

        local NewX = X - Circle.AbsolutePosition.X
        local NewY = Y - Circle.AbsolutePosition.Y
        Circle.Position = UDim2.new(0, NewX, 0, NewY)
        
        local Size = 0
        if Button.AbsoluteSize.X > Button.AbsoluteSize.Y then
            Size = Button.AbsoluteSize.X * 1.5
        elseif Button.AbsoluteSize.X < Button.AbsoluteSize.Y then
            Size = Button.AbsoluteSize.Y * 1.5
        elseif Button.AbsoluteSize.X == Button.AbsoluteSize.Y then
            Size = Button.AbsoluteSize.X * 1.5
        end

        local Time = 0.5
        Circle:TweenSizeAndPosition(UDim2.new(0, Size, 0, Size), UDim2.new(0.5, -Size / 2, 0.5, -Size / 2), "Out", "Quad", Time, false, nil)
        
        for i = 1, 10 do
            Circle.ImageTransparency = Circle.ImageTransparency + 0.01
            task.wait(Time / 10)
        end
        Circle:Destroy()
    end)
end

local ZuperMing = {}

function ZuperMing:MakeNotify(NotifyConfig)
    local NotifyConfig = NotifyConfig or {}
    NotifyConfig.Title = NotifyConfig.Title or "ZuperMing"
    NotifyConfig.Description = NotifyConfig.Description or "Notification"
    NotifyConfig.Content = NotifyConfig.Content or "Content"
    NotifyConfig.Color = NotifyConfig.Color or Color3.fromRGB(55, 70, 255)
    NotifyConfig.Time = NotifyConfig.Time or 0.5
    NotifyConfig.Delay = NotifyConfig.Delay or 5
    
    local NotifyFunction = {}
    
    task.spawn(function()
        if not CoreGui:FindFirstChild("NotifyGui") then
            local NotifyGui = Instance.new("ScreenGui");
            NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            NotifyGui.Name = "NotifyGui"
            NotifyGui.Parent = CoreGui
        end

        if not CoreGui.NotifyGui:FindFirstChild("NotifyLayout") then
            local NotifyLayout = Instance.new("Frame");
            NotifyLayout.AnchorPoint = Vector2.new(1, 1)
            NotifyLayout.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            NotifyLayout.BackgroundTransparency = 1
            NotifyLayout.Position = UDim2.new(1, -30, 1, -30)
            NotifyLayout.Size = UDim2.new(0, 350, 1, 0)
            NotifyLayout.Name = "NotifyLayout"
            NotifyLayout.Parent = CoreGui.NotifyGui
            
            local Count = 0
            CoreGui.NotifyGui.NotifyLayout.ChildRemoved:Connect(function()
                Count = 0
                for i, v in CoreGui.NotifyGui.NotifyLayout:GetChildren() do
                    TweenService:Create(
                        v,
                        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                        { Position = UDim2.new(0, 0, 1, -((v.Size.Y.Offset + 12) * Count)) }
                    ):Play()
                    Count = Count + 1
                end
            end)
        end

        local NotifyPosHeigh = 0
        for i, v in CoreGui.NotifyGui.NotifyLayout:GetChildren() do
            NotifyPosHeigh = -(v.Position.Y.Offset) + v.Size.Y.Offset + 12
        end

        local CalculationWidth = 280 
        local ContentBounds = TextService:GetTextSize(
            NotifyConfig.Content,
            15, 
            Enum.Font.GothamBold,
            Vector2.new(CalculationWidth, 9999) 
        )
        
        local TextHeight = ContentBounds.Y
        local HeaderHeight = 36
        local BottomPadding = 15
        local TotalFrameHeight = HeaderHeight + TextHeight + BottomPadding
        
        if TotalFrameHeight < 65 then TotalFrameHeight = 65 end

        local NotifyFrame = Instance.new("Frame");
        local NotifyFrameReal = Instance.new("Frame");
        local UICorner = Instance.new("UICorner");
        local Top = Instance.new("Frame");
        local TextLabel = Instance.new("TextLabel"); 
        local TextLabel1 = Instance.new("TextLabel"); 
        local Close = Instance.new("TextButton");
        local ImageLabel = Instance.new("ImageLabel");
        local TextLabel2 = Instance.new("TextLabel"); 

        NotifyFrame.Name = "NotifyFrame"
        NotifyFrame.BackgroundTransparency = 1
        NotifyFrame.Size = UDim2.new(1, 0, 0, TotalFrameHeight)
        NotifyFrame.Parent = CoreGui.NotifyGui.NotifyLayout
        NotifyFrame.AnchorPoint = Vector2.new(0, 1)
        NotifyFrame.Position = UDim2.new(0, 0, 1, -(NotifyPosHeigh))

        NotifyFrameReal.Name = "NotifyFrameReal"
        NotifyFrameReal.BackgroundColor3 = Color3.fromRGB(29, 30, 35)
        NotifyFrameReal.BorderSizePixel = 0
        NotifyFrameReal.Position = UDim2.new(0, 400, 0, 0)
        NotifyFrameReal.Size = UDim2.new(1, 0, 1, 0)
        NotifyFrameReal.Parent = NotifyFrame

        UICorner.Parent = NotifyFrameReal
        UICorner.CornerRadius = UDim.new(0, 8)

        Top.Name = "Top"
        Top.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Top.BackgroundTransparency = 1
        Top.Size = UDim2.new(1, 0, 0, HeaderHeight)
        Top.Parent = NotifyFrameReal

        TextLabel.Font = Enum.Font.GothamBold
        TextLabel.Text = NotifyConfig.Title
        TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.TextSize = 14
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.BackgroundTransparency = 1
        TextLabel.AutomaticSize = Enum.AutomaticSize.X
        TextLabel.Size = UDim2.new(0, 0, 1, 0)
        TextLabel.Position = UDim2.new(0, 10, 0, 0)
        TextLabel.Parent = Top

        TextLabel1.Font = Enum.Font.GothamBold
        TextLabel1.Text = NotifyConfig.Description
        TextLabel1.TextColor3 = NotifyConfig.Color
        TextLabel1.TextSize = 14
        TextLabel1.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel1.BackgroundTransparency = 1
        TextLabel1.AutomaticSize = Enum.AutomaticSize.X
        TextLabel1.Size = UDim2.new(0, 0, 1, 0)
        TextLabel1.Parent = Top
        
        task.defer(function()
             TextLabel1.Position = UDim2.new(0, TextLabel.AbsoluteSize.X + 15, 0, 0)
        end)

        Close.Name = "Close"
        Close.Text = ""
        Close.BackgroundTransparency = 1
        Close.AnchorPoint = Vector2.new(1, 0.5)
        Close.Position = UDim2.new(1, -5, 0.5, 0)
        Close.Size = UDim2.new(0, 25, 0, 25)
        Close.Parent = Top

        ImageLabel.Image = "rbxassetid://9886659671"
        ImageLabel.BackgroundTransparency = 1
        ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
        ImageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
        ImageLabel.Size = UDim2.new(0.6, 0, 0.6, 0)
        ImageLabel.Parent = Close

        TextLabel2.Name = "Content"
        TextLabel2.Font = Enum.Font.GothamBold
        TextLabel2.Text = NotifyConfig.Content
        TextLabel2.TextColor3 = Color3.fromRGB(180, 180, 180)
        TextLabel2.TextSize = 15
        TextLabel2.BackgroundTransparency = 1
        TextLabel2.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel2.TextYAlignment = Enum.TextYAlignment.Top
        TextLabel2.TextWrapped = true
        TextLabel2.AutomaticSize = Enum.AutomaticSize.Y 
        TextLabel2.Position = UDim2.new(0, 10, 0, HeaderHeight)
        TextLabel2.Size = UDim2.new(1, -20, 0, 0) 
        TextLabel2.Parent = NotifyFrameReal

        local waitbruh = false
        function NotifyFunction:Close()
            if waitbruh then return false end
            waitbruh = true
            TweenService:Create(
                NotifyFrameReal,
                TweenInfo.new(tonumber(NotifyConfig.Time), Enum.EasingStyle.Back, Enum.EasingDirection.In),
                { Position = UDim2.new(0, 400, 0, 0) }
            ):Play()
            task.wait(tonumber(NotifyConfig.Time) / 1.2)
            NotifyFrame:Destroy()
        end

        Close.Activated:Connect(function()
            NotifyFunction:Close()
        end)

        TweenService:Create(
            NotifyFrameReal,
            TweenInfo.new(tonumber(NotifyConfig.Time), Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { Position = UDim2.new(0, 0, 0, 0) }
        ):Play()

        task.wait(tonumber(NotifyConfig.Delay))
        NotifyFunction:Close()
    end)
    
    return NotifyFunction
end

function ZuperMing:Window(GuiConfig)
    GuiConfig = GuiConfig or {}
    GuiConfig.Title = GuiConfig.Title or "ZuperMing Premium"
    GuiConfig.Footer = GuiConfig.Footer or "Version 1.37"
    GuiConfig.Color = GuiConfig.Color or Color3.fromRGB(50, 100, 255)
    GuiConfig["Tab Width"] = GuiConfig["Tab Width"] or 120
    GuiConfig.Icon = GuiConfig.Icon or "rbxassetid://104396282819940" 

    local GuiFunc = {}

    local ZuperMingb = Instance.new("ScreenGui");
    local Main = Instance.new("Frame"); -- [[ DIRECT PARENT, NO DROP SHADOW ]]
    local UICorner = Instance.new("UICorner");
    local Top = Instance.new("Frame");
    local TextLabel = Instance.new("TextLabel");
    local UICorner1 = Instance.new("UICorner");
    local TextLabel1 = Instance.new("TextLabel");
    local Close = Instance.new("TextButton");
    local ImageLabel1 = Instance.new("ImageLabel");
    local Min = Instance.new("TextButton");
    local ImageLabel2 = Instance.new("ImageLabel");
    local LayersTab = Instance.new("Frame");
    local UICorner2 = Instance.new("UICorner");
    local DecideFrame = Instance.new("Frame");
    local Layers = Instance.new("Frame");
    local UICorner6 = Instance.new("UICorner");
    local NameTab = Instance.new("TextLabel");
    local LayersReal = Instance.new("Frame");
    local LayersFolder = Instance.new("Folder");
    local LayersPageLayout = Instance.new("UIPageLayout");
    local MainStroke = Instance.new("UIStroke");

    ZuperMingb.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ZuperMingb.Name = "ZuperMingb"
    ZuperMingb.ResetOnSpawn = false
    ZuperMingb.Parent = game:GetService("CoreGui")

    -- [[ MAIN FRAME (Was inside DropShadow before) ]]
    Main.Name = "Main"
    Main.Parent = ZuperMingb
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Main.BackgroundTransparency = 0.1
    Main.BorderSizePixel = 0
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    if isMobile then
        Main.Size = safeSize(470, 270)
    else
        Main.Size = safeSize(640, 400)
    end

    local BackgroundImage = Instance.new("ImageLabel")
    BackgroundImage.Name = "BackgroundImage"
    BackgroundImage.Parent = Main
    BackgroundImage.Image = "rbxassetid://104396282819940"
    BackgroundImage.ScaleType = Enum.ScaleType.Fit
    BackgroundImage.BackgroundTransparency = 1
    BackgroundImage.ImageTransparency = 0.9 
    BackgroundImage.AnchorPoint = Vector2.new(0.5, 0.5)
    BackgroundImage.Position = UDim2.new(0.55, 0, 0.5, 0)
    BackgroundImage.Size = UDim2.new(0.8, 0, 0.8, 0)
    BackgroundImage.ZIndex = 0

    MainStroke.Thickness = 3
    MainStroke.Color = Color3.fromRGB(120, 10, 30)
    MainStroke.Transparency = 0
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MainStroke.Parent = Main

    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = Main

    Top.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Top.BackgroundTransparency = 0.9990000128746033
    Top.BorderSizePixel = 0
    Top.Size = UDim2.new(1, 0, 0, 38)
    Top.Name = "Top"
    Top.Parent = Main
    
    local LogoIcon = Instance.new("ImageLabel")
    LogoIcon.Name = "LogoIcon"
    LogoIcon.Parent = Top
    LogoIcon.BackgroundTransparency = 1
    LogoIcon.Position = UDim2.new(0, 10, 0.5, 2)
    LogoIcon.AnchorPoint = Vector2.new(0, 0.5)
    LogoIcon.Size = UDim2.new(0, 30, 0, 30)
    LogoIcon.Image = "rbxassetid://104396282819940"
    LogoIcon.ScaleType = Enum.ScaleType.Fit
    LogoIcon.ImageTransparency = 0
    LogoIcon.ZIndex = 10

    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.Text = GuiConfig.Title
    TextLabel.TextColor3 = GuiConfig.Color
    TextLabel.TextSize = 15
    TextLabel.TextXAlignment = Enum.TextXAlignment.Center
    TextLabel.BackgroundTransparency = 1
    TextLabel.BorderSizePixel = 0
    TextLabel.Size = UDim2.new(0.5, 0, 0, 18)
    TextLabel.Position = UDim2.new(0.5, 0, 0, 2)
    TextLabel.AnchorPoint = Vector2.new(0.5, 0)
    TextLabel.Parent = Top

    UICorner1.Parent = Top

    TextLabel1.Font = Enum.Font.GothamBold
    TextLabel1.Text = GuiConfig.Footer
    TextLabel1.TextColor3 = Color3.fromRGB(180, 180, 190)
    TextLabel1.TextSize = 11
    TextLabel1.TextXAlignment = Enum.TextXAlignment.Center
    TextLabel1.BackgroundTransparency = 1
    TextLabel1.BorderSizePixel = 0
    TextLabel1.Size = UDim2.new(0.5, 0, 0, 14)
    TextLabel1.Position = UDim2.new(0.5, 0, 0, 21)
    TextLabel1.AnchorPoint = Vector2.new(0.5, 0)
    TextLabel1.Parent = Top

    Close.Font = Enum.Font.SourceSans
    Close.Text = ""
    Close.TextColor3 = Color3.fromRGB(0, 0, 0)
    Close.TextSize = 14
    Close.AnchorPoint = Vector2.new(1, 0.5)
    Close.BackgroundTransparency = 1
    Close.BorderSizePixel = 0
    Close.Position = UDim2.new(1, -8, 0.5, 0)
    Close.Size = UDim2.new(0, 25, 0, 25)
    Close.Name = "Close"
    Close.Parent = Top

    ImageLabel1.Image = "rbxassetid://9886659671"
    ImageLabel1.AnchorPoint = Vector2.new(0.5, 0.5)
    ImageLabel1.BackgroundTransparency = 1
    ImageLabel1.BorderSizePixel = 0
    ImageLabel1.Position = UDim2.new(0.49, 0, 0.5, 0)
    ImageLabel1.Size = UDim2.new(1, -8, 1, -8)
    ImageLabel1.Parent = Close

    Min.Font = Enum.Font.SourceSans
    Min.Text = ""
    Min.TextColor3 = Color3.fromRGB(0, 0, 0)
    Min.TextSize = 14
    Min.AnchorPoint = Vector2.new(1, 0.5)
    Min.BackgroundTransparency = 1
    Min.BorderSizePixel = 0
    Min.Position = UDim2.new(1, -38, 0.5, 0)
    Min.Size = UDim2.new(0, 25, 0, 25)
    Min.Name = "Min"
    Min.Parent = Top

    ImageLabel2.Image = "rbxassetid://9886659276"
    ImageLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
    ImageLabel2.BackgroundTransparency = 1
    ImageLabel2.ImageTransparency = 0.2
    ImageLabel2.BorderSizePixel = 0
    ImageLabel2.Position = UDim2.new(0.5, 0, 0.5, 0)
    ImageLabel2.Size = UDim2.new(1, -9, 1, -9)
    ImageLabel2.Parent = Min

    LayersTab.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    LayersTab.BackgroundTransparency = 0.95
    LayersTab.BorderSizePixel = 0
    LayersTab.Position = UDim2.new(0, 9, 0, 50)
    LayersTab.Size = UDim2.new(0, GuiConfig["Tab Width"], 1, -59)
    LayersTab.Name = "LayersTab"
    LayersTab.Parent = Main

    UICorner2.CornerRadius = UDim.new(0, 2)
    UICorner2.Parent = LayersTab
    
    local TabSeparator = Instance.new("Frame")
    TabSeparator.Name = "TabSeparator"
    TabSeparator.Parent = Main
    TabSeparator.BackgroundColor3 = Color3.fromRGB(120, 10, 30)
    TabSeparator.BorderSizePixel = 0
    TabSeparator.Position = UDim2.new(0, GuiConfig["Tab Width"] + 16, 0, 38)
    TabSeparator.Size = UDim2.new(0, 2, 1, -38)
    TabSeparator.ZIndex = 5

    DecideFrame.AnchorPoint = Vector2.new(0.5, 0)
    DecideFrame.BackgroundColor3 = Color3.fromRGB(120, 10, 30)
    DecideFrame.BackgroundTransparency = 0
    DecideFrame.BorderSizePixel = 0
    DecideFrame.Position = UDim2.new(0.5, 0, 0, 38)
    DecideFrame.Size = UDim2.new(1, 0, 0, 2)
    DecideFrame.Name = "DecideFrame"
    DecideFrame.Parent = Main

    Layers.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    Layers.BackgroundTransparency = 0.7
    Layers.BorderSizePixel = 0
    Layers.Position = UDim2.new(0, GuiConfig["Tab Width"] + 18, 0, 50)
    Layers.Size = UDim2.new(1, -(GuiConfig["Tab Width"] + 9 + 18), 1, -59)
    Layers.Name = "Layers"
    Layers.Parent = Main

    UICorner6.CornerRadius = UDim.new(0, 2)
    UICorner6.Parent = Layers

    NameTab.Font = Enum.Font.GothamBold
    NameTab.Text = ""
    NameTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameTab.TextSize = 24
    NameTab.TextWrapped = true
    NameTab.TextXAlignment = Enum.TextXAlignment.Left
    NameTab.BackgroundTransparency = 1
    NameTab.BorderSizePixel = 0
    NameTab.Size = UDim2.new(1, 0, 0, 30)
    NameTab.Name = "NameTab"
    NameTab.Parent = Layers

    LayersReal.AnchorPoint = Vector2.new(0, 1)
    LayersReal.BackgroundTransparency = 1
    LayersReal.BorderSizePixel = 0
    LayersReal.ClipsDescendants = true
    LayersReal.Position = UDim2.new(0, 0, 1, 0)
    LayersReal.Size = UDim2.new(1, 0, 1, -33)
    LayersReal.Name = "LayersReal"
    LayersReal.Parent = Layers

    LayersFolder.Name = "LayersFolder"
    LayersFolder.Parent = LayersReal

    LayersPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    LayersPageLayout.Name = "LayersPageLayout"
    LayersPageLayout.Parent = LayersFolder
    LayersPageLayout.TweenTime = 0.5
    LayersPageLayout.EasingDirection = Enum.EasingDirection.InOut
    LayersPageLayout.EasingStyle = Enum.EasingStyle.Quad

    local ScrollTab = Instance.new("ScrollingFrame");
    local UIListLayout = Instance.new("UIListLayout");

    -- [[ OPTIMIZATION 2: AUTOMATIC CANVAS SIZE ]] --
    ScrollTab.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollTab.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollTab.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
    ScrollTab.ScrollBarThickness = 0
    ScrollTab.Active = true
    ScrollTab.BackgroundTransparency = 1
    ScrollTab.BorderSizePixel = 0
    ScrollTab.Size = UDim2.new(1, 0, 1, 0)
    ScrollTab.Name = "ScrollTab"
    ScrollTab.Parent = LayersTab

    UIListLayout.Padding = UDim.new(0, 3)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = ScrollTab

    -- [[ OPTIMIZATION 4: HELPER UNTUK NATIVE CONFIRM ]] --
    local function CreateDialog(HostParent, TitleText, MsgText, OnYes)
        local Overlay = Instance.new("Frame")
        Overlay.Size = UDim2.new(1, 0, 1, 0)
        Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Overlay.BackgroundTransparency = 0.3
        Overlay.ZIndex = 50
        Overlay.Parent = HostParent

        local Dialog = Instance.new("Frame")
        Dialog.Size = UDim2.new(0, 300, 0, 150)
        Dialog.Position = UDim2.new(0.5, -150, 0.5, -75)
        Dialog.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Dialog.BorderSizePixel = 0
        Dialog.ZIndex = 51
        Dialog.Parent = Overlay
        Instance.new("UICorner", Dialog).CornerRadius = UDim.new(0, 8)

        -- REMOVED GLOW FOR PERFORMANCE --

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, 0, 0, 40)
        Title.Position = UDim2.new(0, 0, 0, 4)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.GothamBold
        Title.Text = TitleText or "Confirmation"
        Title.TextSize = 22
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.ZIndex = 52
        Title.Parent = Dialog

        local Message = Instance.new("TextLabel")
        Message.Size = UDim2.new(1, -20, 0, 60)
        Message.Position = UDim2.new(0, 10, 0, 30)
        Message.BackgroundTransparency = 1
        Message.Font = Enum.Font.Gotham
        Message.Text = MsgText or "Are you sure you want to proceed?"
        Message.TextSize = 14
        Message.TextColor3 = Color3.fromRGB(200, 200, 200)
        Message.TextWrapped = true
        Message.ZIndex = 52
        Message.Parent = Dialog

        local Yes = Instance.new("TextButton")
        Yes.Size = UDim2.new(0.45, -10, 0, 35)
        Yes.Position = UDim2.new(0.05, 0, 1, -55)
        Yes.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Yes.BackgroundTransparency = 0.935
        Yes.Text = "Yes"
        Yes.Font = Enum.Font.GothamBold
        Yes.TextSize = 15
        Yes.TextColor3 = Color3.fromRGB(255, 255, 255)
        Yes.TextTransparency = 0.3
        Yes.ZIndex = 52
        Yes.Parent = Dialog
        Instance.new("UICorner", Yes).CornerRadius = UDim.new(0, 6)

        local Cancel = Instance.new("TextButton")
        Cancel.Size = UDim2.new(0.45, -10, 0, 35)
        Cancel.Position = UDim2.new(0.5, 10, 1, -55)
        Cancel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Cancel.BackgroundTransparency = 0.935
        Cancel.Text = "Cancel"
        Cancel.Font = Enum.Font.GothamBold
        Cancel.TextSize = 15
        Cancel.TextColor3 = Color3.fromRGB(255, 255, 255)
        Cancel.TextTransparency = 0.3
        Cancel.ZIndex = 52
        Cancel.Parent = Dialog
        Instance.new("UICorner", Cancel).CornerRadius = UDim.new(0, 6)

        Yes.MouseButton1Click:Connect(function()
            Overlay:Destroy()
            if OnYes then OnYes() end
        end)

        Cancel.MouseButton1Click:Connect(function()
            Overlay:Destroy()
        end)
    end

    function GuiFunc:DestroyGui()
        if CoreGui:FindFirstChild("ZuperMingb") then
            ZuperMingb:Destroy()
        end
    end

    local MinimizeIcon = Instance.new("ImageButton")
    MinimizeIcon.Name = "MinimizeIcon"
    MinimizeIcon.Parent = ZuperMingb
    MinimizeIcon.AnchorPoint = Vector2.new(0.5, 0)
    MinimizeIcon.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    MinimizeIcon.BorderSizePixel = 0
    MinimizeIcon.Position = UDim2.new(0.5, 0, 0, 20)
    MinimizeIcon.Size = UDim2.new(0, 60, 0, 60)
    MinimizeIcon.Image = GuiConfig.Icon
    MinimizeIcon.ImageTransparency = 0
    MinimizeIcon.ScaleType = Enum.ScaleType.Fit
    MinimizeIcon.Visible = false
    MinimizeIcon.ZIndex = 100
    
    local MinimizeIconCorner = Instance.new("UICorner")
    MinimizeIconCorner.CornerRadius = UDim.new(0, 12)
    MinimizeIconCorner.Parent = MinimizeIcon
    
    local MinimizeIconStroke = Instance.new("UIStroke")
    MinimizeIconStroke.Color = GuiConfig.Color
    MinimizeIconStroke.Thickness = 2
    MinimizeIconStroke.Transparency = 0
    MinimizeIconStroke.Parent = MinimizeIcon

    Min.Activated:Connect(function()
        CircleClick(Min, Mouse.X, Mouse.Y)
        Main.Visible = false
        MinimizeIcon.Visible = true
    end)
    
    MinimizeIcon.Activated:Connect(function()
        MinimizeIcon.Visible = false
        Main.Visible = true
    end)
    
    -- FIXED: Make draggable optimized
    local draggingIcon = false
    local dragStartIcon, startPosIcon
    
    MinimizeIcon.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingIcon = true
            dragStartIcon = input.Position
            startPosIcon = MinimizeIcon.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    draggingIcon = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if draggingIcon and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStartIcon
            MinimizeIcon.Position = UDim2.new(
                startPosIcon.X.Scale,
                startPosIcon.X.Offset + delta.X,
                startPosIcon.Y.Scale,
                startPosIcon.Y.Offset + delta.Y
            )
        end
    end)
    
    Close.Activated:Connect(function()
        CircleClick(Close, Mouse.X, Mouse.Y)
        CreateDialog(Main, "ZuperMing Window", "Do you want to close this window?", function()
            if ZuperMingb then ZuperMingb:Destroy() end
            if game.CoreGui:FindFirstChild("ToggleUIButton") then
                game.CoreGui.ToggleUIButton:Destroy()
            end
        end)
    end)

    local ToggleKey = Enum.KeyCode.F3
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == ToggleKey then
            if Main then
                Main.Visible = not Main.Visible
            end
        end
    end)

    function GuiFunc:ToggleUI()
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Parent = game:GetService("CoreGui")
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.Name = "ToggleUIButton"

        local MainButton = Instance.new("ImageLabel")
        MainButton.Parent = ScreenGui
        MainButton.Size = UDim2.new(0, 40, 0, 40)
        MainButton.Position = UDim2.new(0, 20, 0, 100)
        MainButton.BackgroundTransparency = 1
        MainButton.Image = "rbxassetid://" .. (GuiConfig.Image or "137808493980662")
        MainButton.ScaleType = Enum.ScaleType.Fit

        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 6)
        UICorner.Parent = MainButton

        local Button = Instance.new("TextButton")
        Button.Parent = MainButton
        Button.Size = UDim2.new(1, 0, 1, 0)
        Button.BackgroundTransparency = 1
        Button.Text = ""

        Button.MouseButton1Click:Connect(function()
            if Main then
                Main.Visible = not Main.Visible
                ScreenGui.Enabled = not Main.Visible
            end
        end)

        ScreenGui.Enabled = not Main.Visible

        local dragging = false
        local dragStart, startPos

        local function update(input)
            local delta = input.Position - dragStart
            MainButton.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end

        Button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = MainButton.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                update(input)
            end
        end)
    end

    GuiFunc:ToggleUI()

    MakeDraggable(Top, Main) -- FIXED TARGET

    local MoreBlur = Instance.new("Frame");
    local UICorner28 = Instance.new("UICorner");
    local ConnectButton = Instance.new("TextButton");

    MoreBlur.AnchorPoint = Vector2.new(1, 1)
    MoreBlur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MoreBlur.BackgroundTransparency = 0.999
    MoreBlur.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MoreBlur.BorderSizePixel = 0
    MoreBlur.ClipsDescendants = true
    MoreBlur.Position = UDim2.new(1, 8, 1, 8)
    MoreBlur.Size = UDim2.new(1, 154, 1, 54)
    MoreBlur.Visible = false
    MoreBlur.Name = "MoreBlur"
    MoreBlur.Parent = Layers

    -- REMOVED SHADOW HOLDER 1 --

    UICorner28.Parent = MoreBlur

    ConnectButton.Font = Enum.Font.SourceSans
    ConnectButton.Text = ""
    ConnectButton.BackgroundTransparency = 0.999
    ConnectButton.Size = UDim2.new(1, 0, 1, 0)
    ConnectButton.Parent = MoreBlur

    local DropdownSelect = Instance.new("Frame");
    local UICorner36 = Instance.new("UICorner");
    local UIStroke14 = Instance.new("UIStroke");
    local DropdownSelectReal = Instance.new("Frame");
    local DropdownFolder = Instance.new("Folder");
    local DropPageLayout = Instance.new("UIPageLayout");

    DropdownSelect.AnchorPoint = Vector2.new(1, 0.5)
    DropdownSelect.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    DropdownSelect.BorderSizePixel = 0
    DropdownSelect.LayoutOrder = 1
    DropdownSelect.Position = UDim2.new(1, 172, 0.5, 0)
    DropdownSelect.Size = UDim2.new(0, 160, 1, -16)
    DropdownSelect.Name = "DropdownSelect"
    DropdownSelect.ClipsDescendants = true
    DropdownSelect.Parent = MoreBlur

    ConnectButton.Activated:Connect(function()
        if MoreBlur.Visible then
            TweenService:Create(MoreBlur, TweenInfo.new(0.3), { BackgroundTransparency = 0.999 }):Play()
            TweenService:Create(DropdownSelect, TweenInfo.new(0.3), { Position = UDim2.new(1, 172, 0.5, 0) }):Play()
            task.wait(0.3)
            MoreBlur.Visible = false
        end
    end)
    UICorner36.CornerRadius = UDim.new(0, 3)
    UICorner36.Parent = DropdownSelect

    UIStroke14.Color = Color3.fromRGB(189, 162, 241)
    UIStroke14.Thickness = 2.5
    UIStroke14.Transparency = 0.8
    UIStroke14.Parent = DropdownSelect

    DropdownSelectReal.AnchorPoint = Vector2.new(0.5, 0.5)
    DropdownSelectReal.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    DropdownSelectReal.BackgroundTransparency = 0.7
    DropdownSelectReal.BorderSizePixel = 0
    DropdownSelectReal.LayoutOrder = 1
    DropdownSelectReal.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropdownSelectReal.Size = UDim2.new(1, 1, 1, 1)
    DropdownSelectReal.Name = "DropdownSelectReal"
    DropdownSelectReal.Parent = DropdownSelect

    DropdownFolder.Name = "DropdownFolder"
    DropdownFolder.Parent = DropdownSelectReal

    DropPageLayout.EasingDirection = Enum.EasingDirection.InOut
    DropPageLayout.EasingStyle = Enum.EasingStyle.Quad
    DropPageLayout.TweenTime = 0.01
    DropPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    DropPageLayout.FillDirection = Enum.FillDirection.Vertical
    DropPageLayout.Archivable = false
    DropPageLayout.Name = "DropPageLayout"
    DropPageLayout.Parent = DropdownFolder

    -- [[ KODE YANG HILANG (MULAI) ]] --
    local DropdownContainer = Instance.new("Frame")
    DropdownContainer.Size = UDim2.new(1, 0, 1, 0)
    DropdownContainer.BackgroundTransparency = 1
    DropdownContainer.Parent = DropdownFolder

    local SearchBox = Instance.new("TextBox")
    SearchBox.PlaceholderText = "Search"
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.Text = ""
    SearchBox.TextSize = 14
    SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SearchBox.BackgroundTransparency = 0.9
    SearchBox.BorderSizePixel = 0
    SearchBox.Size = UDim2.new(1, 0, 0, 25)
    SearchBox.Position = UDim2.new(0, 0, 0, 0)
    SearchBox.ClearTextOnFocus = false
    SearchBox.Name = "SearchBox"
    SearchBox.Parent = DropdownContainer

    local ScrollSelect = Instance.new("ScrollingFrame")
    ScrollSelect.Size = UDim2.new(1, 0, 1, -30)
    ScrollSelect.Position = UDim2.new(0, 0, 0, 30)
    ScrollSelect.ScrollBarImageTransparency = 1
    ScrollSelect.BorderSizePixel = 0
    ScrollSelect.BackgroundTransparency = 1
    ScrollSelect.ScrollBarThickness = 0
    ScrollSelect.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollSelect.AutomaticCanvasSize = Enum.AutomaticSize.Y -- Optimasi
    ScrollSelect.Name = "ScrollSelect"
    ScrollSelect.Parent = DropdownContainer

    local UIListLayout4 = Instance.new("UIListLayout")
    UIListLayout4.Padding = UDim.new(0, 3)
    UIListLayout4.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout4.Parent = ScrollSelect

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(SearchBox.Text)
        for _, option in pairs(ScrollSelect:GetChildren()) do
            if option.Name == "Option" and option:FindFirstChild("OptionText") then
                local text = string.lower(option.OptionText.Text)
                option.Visible = query == "" or string.find(text, query, 1, true)
            end
        end
    end)
    -- [[ KODE YANG HILANG (SELESAI) ]] --
    
    local Tabs = {}
    local CountTab = 0
    local CountDropdown = 0
    function Tabs:AddTab(TabConfig)
        local TabConfig = TabConfig or {}
        TabConfig.Name = TabConfig.Name or "Tab"
        TabConfig.Icon = TabConfig.Icon or ""

        local ScrolLayers = Instance.new("ScrollingFrame");
        local UIListLayout1 = Instance.new("UIListLayout");

        -- [[ OPTIMIZED: Auto Canvas Size ]]
        ScrolLayers.AutomaticCanvasSize = Enum.AutomaticSize.Y
        ScrolLayers.CanvasSize = UDim2.new(0, 0, 0, 0)
        ScrolLayers.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
        ScrolLayers.ScrollBarThickness = 0
        ScrolLayers.Active = true
        ScrolLayers.LayoutOrder = CountTab
        ScrolLayers.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ScrolLayers.BackgroundTransparency = 1
        ScrolLayers.BorderSizePixel = 0
        ScrolLayers.Size = UDim2.new(1, 0, 1, 0)
        ScrolLayers.Name = "ScrolLayers"
        ScrolLayers.Parent = LayersFolder

        UIListLayout1.Padding = UDim.new(0, 3)
        UIListLayout1.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout1.Parent = ScrolLayers

        local Tab = Instance.new("Frame");
        local UICorner3 = Instance.new("UICorner");
        local TabButton = Instance.new("TextButton");
        local TabName = Instance.new("TextLabel")
        local FeatureImg = Instance.new("ImageLabel");
        local UIStroke2 = Instance.new("UIStroke");
        local UICorner4 = Instance.new("UICorner");

        Tab.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
        if CountTab == 0 then
            Tab.BackgroundTransparency = 0.85
        else
            Tab.BackgroundTransparency = 0.98
        end
        Tab.BorderSizePixel = 0
        Tab.LayoutOrder = CountTab
        Tab.Size = UDim2.new(1, 0, 0, 30)
        Tab.Name = "Tab"
        Tab.Parent = ScrollTab
        
        local TabBorderStroke = Instance.new("UIStroke")
        TabBorderStroke.Name = "TabBorder"
        TabBorderStroke.Thickness = 1.5
        TabBorderStroke.Transparency = 1
        TabBorderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        TabBorderStroke.Parent = Tab
        
        local TabBorderGradient = Instance.new("UIGradient")
        TabBorderGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 10, 30)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 160, 255))
        })
        TabBorderGradient.Rotation = 90
        TabBorderGradient.Parent = TabBorderStroke

        UICorner3.CornerRadius = UDim.new(0, 6)
        UICorner3.Parent = Tab

        TabButton.Font = Enum.Font.GothamBold
        TabButton.Text = ""
        TabButton.BackgroundTransparency = 0.999
        TabButton.Size = UDim2.new(1, 0, 1, 0)
        TabButton.Name = "TabButton"
        TabButton.Parent = Tab

        TabName.Font = Enum.Font.GothamBold
        TabName.Text = "| " .. tostring(TabConfig.Name)
        TabName.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabName.TextSize = 15
        TabName.TextXAlignment = Enum.TextXAlignment.Left
        TabName.BackgroundTransparency = 1
        TabName.Size = UDim2.new(1, 0, 1, 0)
        TabName.Position = UDim2.new(0, 30, 0, 0)
        TabName.Name = "TabName"
        TabName.Parent = Tab

        FeatureImg.BackgroundTransparency = 1
        FeatureImg.Position = UDim2.new(0, 9, 0, 7)
        FeatureImg.Size = UDim2.new(0, 16, 0, 16)
        FeatureImg.Name = "FeatureImg"
        FeatureImg.Parent = Tab
        
        if CountTab == 0 then
            LayersPageLayout:JumpToIndex(0)
            NameTab.Text = TabConfig.Name
            NameTab.Position = UDim2.new(0, 10, 0, 0)
            local ChooseFrame = Instance.new("Frame");
            ChooseFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ChooseFrame.BorderSizePixel = 0
            ChooseFrame.Position = UDim2.new(0, 2, 0, 4)
            ChooseFrame.Size = UDim2.new(0, 3, 0, 20)
            ChooseFrame.Name = "ChooseFrame"
            ChooseFrame.Parent = Tab
            
            local TabGradient = Instance.new("UIGradient")
            TabGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 180, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 50, 80))
            })
            TabGradient.Rotation = 90
            TabGradient.Parent = ChooseFrame

            UIStroke2.Color = GuiConfig.Color
            UIStroke2.Thickness = 0
            UIStroke2.Parent = ChooseFrame

            UICorner4.Parent = ChooseFrame
        end

        if TabConfig.Icon ~= "" then
            if Icons[TabConfig.Icon] then
                FeatureImg.Image = Icons[TabConfig.Icon]
            else
                FeatureImg.Image = TabConfig.Icon
            end
        end

        TabButton.Activated:Connect(function()
            CircleClick(TabButton, Mouse.X, Mouse.Y)
            local FrameChoose
            for a, s in ScrollTab:GetChildren() do
                for i, v in s:GetChildren() do
                    if v.Name == "ChooseFrame" then
                        FrameChoose = v
                        break
                    end
                end
            end
            if FrameChoose ~= nil and Tab.LayoutOrder ~= LayersPageLayout.CurrentPage.LayoutOrder then
                for _, TabFrame in ScrollTab:GetChildren() do
                    if TabFrame.Name == "Tab" then
                        TweenService:Create(
                            TabFrame,
                            TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
                            { BackgroundTransparency = 0.999 }
                        ):Play()
                    end
                end
                TweenService:Create(
                    Tab,
                    TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
                    { BackgroundTransparency = 0.92 }
                ):Play()
                TweenService:Create(
                    FrameChoose,
                    TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                    { Position = UDim2.new(0, 2, 0, 4 + (33 * Tab.LayoutOrder)) }
                ):Play()
                LayersPageLayout:JumpToIndex(Tab.LayoutOrder)
                task.wait(0.05)
                NameTab.Text = TabConfig.Name
                TweenService:Create(FrameChoose, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), { Size = UDim2.new(0, 1, 0, 2) }):Play()
                task.wait(0.2)
                TweenService:Create(FrameChoose, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), { Size = UDim2.new(0, 3, 0, 20) }):Play()
            end
        end)
        
        --// Section
        local Sections = {}
        local CountSection = 0
        function Sections:AddSection(Title, AlwaysOpen)
            local Title = Title or "Title"
            local Section = Instance.new("Frame");
            local SectionDecideFrame = Instance.new("Frame");
            local UICorner1 = Instance.new("UICorner");
            local UIGradient = Instance.new("UIGradient");

            Section.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Section.BackgroundTransparency = 0.999 
            Section.BorderSizePixel = 0
            Section.LayoutOrder = CountSection
            Section.ClipsDescendants = true
            
            -- [[ OPTIMIZATION 3: AUTOMATIC SIZE FOR SECTION ]] --
            Section.Size = UDim2.new(1, 0, 0, 38)
            Section.AutomaticSize = Enum.AutomaticSize.Y 
            
            Section.Name = "Section"
            Section.Parent = ScrolLayers

            local SectionReal = Instance.new("Frame");
            local UICorner = Instance.new("UICorner");
            local SectionButton = Instance.new("TextButton");
            local FeatureFrame = Instance.new("Frame");
            local FeatureImg = Instance.new("ImageLabel");
            local SectionTitle = Instance.new("TextLabel");

            SectionReal.AnchorPoint = Vector2.new(0.5, 0)
            SectionReal.BackgroundColor3 = Color3.fromRGB(30, 30, 35) 
            SectionReal.BackgroundTransparency = 0.95
            SectionReal.BorderSizePixel = 0
            SectionReal.Position = UDim2.new(0.5, 0, 0, 0)
            SectionReal.Size = UDim2.new(1, -2, 0, 30)
            SectionReal.Name = "SectionReal"
            SectionReal.Parent = Section

            UICorner.CornerRadius = UDim.new(0, 6)
            UICorner.Parent = SectionReal

            SectionButton.Text = ""
            SectionButton.BackgroundTransparency = 1
            SectionButton.Size = UDim2.new(1, 0, 1, 0)
            SectionButton.Parent = SectionReal

            FeatureFrame.AnchorPoint = Vector2.new(1, 0.5)
            FeatureFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            FeatureFrame.BackgroundTransparency = 1
            FeatureFrame.Position = UDim2.new(1, -5, 0.5, 0)
            FeatureFrame.Size = UDim2.new(0, 20, 0, 20)
            FeatureFrame.Parent = SectionReal

            FeatureImg.Image = "rbxassetid://16851841101"
            FeatureImg.AnchorPoint = Vector2.new(0.5, 0.5)
            FeatureImg.BackgroundTransparency = 1
            FeatureImg.Position = UDim2.new(0.5, 0, 0.5, 0)
            FeatureImg.Rotation = -90
            FeatureImg.Size = UDim2.new(1, 6, 1, 6)
            FeatureImg.Parent = FeatureFrame

            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.Text = Title
            SectionTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
            SectionTitle.TextSize = 15
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Position = UDim2.new(0, 10, 0.5, 0)
            SectionTitle.Size = UDim2.new(1, -50, 0, 13)
            SectionTitle.AnchorPoint = Vector2.new(0, 0.5)
            SectionTitle.Parent = SectionReal

            SectionDecideFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SectionDecideFrame.AnchorPoint = Vector2.new(0.5, 0)
            SectionDecideFrame.BorderSizePixel = 0
            SectionDecideFrame.Position = UDim2.new(0.5, 0, 0, 33)
            SectionDecideFrame.Size = UDim2.new(0, 0, 0, 2)
            SectionDecideFrame.Name = "SectionDecideFrame"
            SectionDecideFrame.Parent = Section

            UICorner1.Parent = SectionDecideFrame

            UIGradient.Color = ColorSequence.new {
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 50, 80)),
                    ColorSequenceKeypoint.new(0.5, GuiConfig.Color),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 50, 80))
            }
            UIGradient.Parent = SectionDecideFrame

            --// Section Add
            local SectionAdd = Instance.new("Frame");
            local UICorner8 = Instance.new("UICorner");
            local UIListLayout2 = Instance.new("UIListLayout");

            SectionAdd.AnchorPoint = Vector2.new(0.5, 0)
            SectionAdd.BackgroundTransparency = 1
            SectionAdd.LayoutOrder = 1
            SectionAdd.Position = UDim2.new(0.5, 0, 0, 38)
            SectionAdd.Size = UDim2.new(1, 0, 0, 0)
            -- [[ OPTIMIZATION: AutomaticSize ]] --
            SectionAdd.AutomaticSize = Enum.AutomaticSize.Y
            
            SectionAdd.Name = "SectionAdd"
            SectionAdd.Parent = Section

            UICorner8.CornerRadius = UDim.new(0, 2)
            UICorner8.Parent = SectionAdd

            UIListLayout2.Padding = UDim.new(0, 3)
            UIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout2.Parent = SectionAdd

            local OpenSection = false

            if AlwaysOpen == true then
                SectionButton:Destroy()
                FeatureFrame:Destroy()
                OpenSection = true
                SectionAdd.Visible = true
                SectionDecideFrame.Size = UDim2.new(1, 0, 0, 2)
            elseif AlwaysOpen == false then
                OpenSection = false
                SectionAdd.Visible = false
            else
                OpenSection = true
                SectionAdd.Visible = true
                FeatureImg.Rotation = 0
                SectionDecideFrame.Size = UDim2.new(1, 0, 0, 2)
            end

            if AlwaysOpen ~= true then
                SectionButton.Activated:Connect(function()
                    CircleClick(SectionButton, Mouse.X, Mouse.Y)
                    
                    OpenSection = not OpenSection
                    SectionAdd.Visible = OpenSection
                    
                    if OpenSection then
                        TweenService:Create(FeatureImg, TweenInfo.new(0.2), { Rotation = 0 }):Play()
                        TweenService:Create(SectionDecideFrame, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, 2) }):Play()
                    else
                        TweenService:Create(FeatureImg, TweenInfo.new(0.2), { Rotation = -90 }):Play()
                        TweenService:Create(SectionDecideFrame, TweenInfo.new(0.2), { Size = UDim2.new(0, 0, 0, 2) }):Play()
                    end
                end)
            end

            local Items = {}
            local CountItem = 0

            function Items:AddParagraph(ParagraphConfig)
                local ParagraphConfig = ParagraphConfig or {}
                ParagraphConfig.Title = ParagraphConfig.Title or "Title"
                ParagraphConfig.Content = ParagraphConfig.Content or "Content"
                
                local Paragraph = Instance.new("Frame")
                local UICorner14 = Instance.new("UICorner")
                local ParagraphTitle = Instance.new("TextLabel")
                local ParagraphContent = Instance.new("TextLabel")

                Paragraph.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Paragraph.BackgroundTransparency = 0.935
                Paragraph.LayoutOrder = CountItem
                Paragraph.Name = "Paragraph"
                Paragraph.Parent = SectionAdd
                Paragraph.AutomaticSize = Enum.AutomaticSize.Y 

                UICorner14.CornerRadius = UDim.new(0, 4)
                UICorner14.Parent = Paragraph

                ParagraphTitle.Font = Enum.Font.GothamBold
                ParagraphTitle.Text = ParagraphConfig.Title
                ParagraphTitle.TextColor3 = Color3.fromRGB(231, 231, 231)
                ParagraphTitle.TextSize = 15
                ParagraphTitle.TextXAlignment = Enum.TextXAlignment.Left
                ParagraphTitle.BackgroundTransparency = 1
                ParagraphTitle.Position = UDim2.new(0, 10, 0, 10)
                ParagraphTitle.Size = UDim2.new(1, -16, 0, 13)
                ParagraphTitle.Parent = Paragraph

                ParagraphContent.Font = Enum.Font.Gotham
                ParagraphContent.Text = ParagraphConfig.Content
                ParagraphContent.TextColor3 = Color3.fromRGB(255, 255, 255)
                ParagraphContent.TextSize = 14
                ParagraphContent.TextXAlignment = Enum.TextXAlignment.Left
                ParagraphContent.BackgroundTransparency = 1
                ParagraphContent.Position = UDim2.new(0, 10, 0, 25)
                ParagraphContent.TextWrapped = true
                ParagraphContent.AutomaticSize = Enum.AutomaticSize.Y
                ParagraphContent.Size = UDim2.new(1, -20, 0, 0)
                ParagraphContent.Parent = Paragraph
                
                local pad = Instance.new("Frame", Paragraph)
                pad.BackgroundTransparency = 1
                pad.LayoutOrder = 100
                pad.Size = UDim2.new(1,0,0,5)
                pad.Position = UDim2.new(0,0,1,0)

                CountItem = CountItem + 1
                return {SetContent = function(self, v) ParagraphContent.Text = v end}
            end

            function Items:AddButton(ButtonConfig)
                ButtonConfig = ButtonConfig or {}
                ButtonConfig.Title = ButtonConfig.Title or "Confirm"
                ButtonConfig.Callback = ButtonConfig.Callback or function() end
                ButtonConfig.Confirm = ButtonConfig.Confirm or false
                ButtonConfig.ConfirmText = ButtonConfig.ConfirmText or "Are you sure you want to do this?"

                local Button = Instance.new("Frame")
                Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Button.BackgroundTransparency = 0.935
                Button.Size = UDim2.new(1, 0, 0, 40)
                Button.LayoutOrder = CountItem
                Button.Parent = SectionAdd
                local UICorner = Instance.new("UICorner")
                UICorner.CornerRadius = UDim.new(0, 4)
                UICorner.Parent = Button
                local MainButton = Instance.new("TextButton")
                MainButton.Font = Enum.Font.GothamBold
                MainButton.Text = ButtonConfig.Title
                MainButton.TextSize = 14
                MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                MainButton.TextTransparency = 0.3
                MainButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                MainButton.BackgroundTransparency = 0.935
                MainButton.Size = UDim2.new(1, -12, 1, -10)
                MainButton.Position = UDim2.new(0, 6, 0, 5)
                MainButton.Parent = Button
                local mainCorner = Instance.new("UICorner")
                mainCorner.CornerRadius = UDim.new(0, 4)
                mainCorner.Parent = MainButton

                MainButton.MouseButton1Click:Connect(function()
                    if ButtonConfig.Confirm then
                        CreateDialog(Main, "Confirmation", ButtonConfig.ConfirmText, ButtonConfig.Callback)
                    else
                        ButtonConfig.Callback()
                    end
                end)

                CountItem = CountItem + 1
            end

            function Items:AddToggle(ToggleConfig)
                local ToggleConfig = ToggleConfig or {}
                ToggleConfig.Title = ToggleConfig.Title or "Title"
                ToggleConfig.Content = ToggleConfig.Content or ""
                ToggleConfig.Default = ToggleConfig.Default or false
                ToggleConfig.Callback = ToggleConfig.Callback or function() end

                local configKey = "Toggle_" .. ToggleConfig.Title
                if ConfigData[configKey] ~= nil then ToggleConfig.Default = ConfigData[configKey] end

                local ToggleFunc = { Value = ToggleConfig.Default }
                local Toggle = Instance.new("Frame")
                local UICorner20 = Instance.new("UICorner")
                local ToggleTitle = Instance.new("TextLabel")
                local ToggleContent = Instance.new("TextLabel")
                local ToggleButton = Instance.new("TextButton")
                local FeatureFrame2 = Instance.new("Frame")
                local UICorner22 = Instance.new("UICorner")
                local UIStroke8 = Instance.new("UIStroke")
                local ToggleCircle = Instance.new("Frame")
                local UICorner23 = Instance.new("UICorner")

                Toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Toggle.BackgroundTransparency = 0.935
                Toggle.LayoutOrder = CountItem
                Toggle.Name = "Toggle"
                Toggle.Parent = SectionAdd
                Toggle.AutomaticSize = Enum.AutomaticSize.Y
                Toggle.Size = UDim2.new(1,0,0,46)

                UICorner20.CornerRadius = UDim.new(0, 4)
                UICorner20.Parent = Toggle

                ToggleTitle.Font = Enum.Font.GothamBold
                ToggleTitle.Text = ToggleConfig.Title
                ToggleTitle.TextSize = 15
                ToggleTitle.TextColor3 = Color3.fromRGB(231, 231, 231)
                ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
                ToggleTitle.BackgroundTransparency = 1
                ToggleTitle.Position = UDim2.new(0, 10, 0, 10)
                ToggleTitle.Size = UDim2.new(1, -100, 0, 13)
                ToggleTitle.Parent = Toggle

                ToggleContent.Font = Enum.Font.GothamBold
                ToggleContent.Text = ToggleConfig.Content
                ToggleContent.TextColor3 = Color3.fromRGB(255, 255, 255)
                ToggleContent.TextSize = 14
                ToggleContent.TextTransparency = 0.6
                ToggleContent.TextXAlignment = Enum.TextXAlignment.Left
                ToggleContent.BackgroundTransparency = 1
                ToggleContent.Size = UDim2.new(1, -100, 0, 0)
                ToggleContent.AutomaticSize = Enum.AutomaticSize.Y
                ToggleContent.TextWrapped = true
                ToggleContent.Position = UDim2.new(0, 10, 0, 25)
                ToggleContent.Parent = Toggle
                
                local pad = Instance.new("Frame", Toggle)
                pad.BackgroundTransparency = 1
                pad.Size = UDim2.new(1,0,0,5)
                pad.Position = UDim2.new(0,0,1,0)

                ToggleButton.Font = Enum.Font.SourceSans
                ToggleButton.Text = ""
                ToggleButton.BackgroundTransparency = 1
                ToggleButton.Size = UDim2.new(1, 0, 1, 0)
                ToggleButton.Parent = Toggle

                FeatureFrame2.AnchorPoint = Vector2.new(1, 0)
                FeatureFrame2.BackgroundTransparency = 0.92
                FeatureFrame2.Position = UDim2.new(1, -15, 0, 15) -- Fixed position relative to top
                FeatureFrame2.Size = UDim2.new(0, 30, 0, 15)
                FeatureFrame2.Parent = Toggle

                UICorner22.Parent = FeatureFrame2
                UIStroke8.Color = Color3.fromRGB(255, 255, 255)
                UIStroke8.Thickness = 2
                UIStroke8.Transparency = 0.9
                UIStroke8.Parent = FeatureFrame2

                ToggleCircle.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
                ToggleCircle.Size = UDim2.new(0, 14, 0, 14)
                ToggleCircle.Parent = FeatureFrame2
                UICorner23.CornerRadius = UDim.new(0, 15)
                UICorner23.Parent = ToggleCircle

                ToggleButton.Activated:Connect(function()
                    ToggleFunc.Value = not ToggleFunc.Value
                    ToggleFunc:Set(ToggleFunc.Value)
                end)

                function ToggleFunc:Set(Value)
                    ToggleFunc.Value = Value
                    ConfigData[configKey] = Value
                    if Value then
                        TweenService:Create(ToggleTitle, TweenInfo.new(0.2), { TextColor3 = GuiConfig.Color }):Play()
                        TweenService:Create(ToggleCircle, TweenInfo.new(0.2), { Position = UDim2.new(0, 15, 0, 0) }):Play()
                        TweenService:Create(UIStroke8, TweenInfo.new(0.2), { Color = GuiConfig.Color, Transparency = 0 }):Play()
                        TweenService:Create(FeatureFrame2, TweenInfo.new(0.2), { BackgroundColor3 = GuiConfig.Color, BackgroundTransparency = 0 }):Play()
                    else
                        TweenService:Create(ToggleTitle, TweenInfo.new(0.2), { TextColor3 = Color3.fromRGB(230, 230, 230) }):Play()
                        TweenService:Create(ToggleCircle, TweenInfo.new(0.2), { Position = UDim2.new(0, 0, 0, 0) }):Play()
                        TweenService:Create(UIStroke8, TweenInfo.new(0.2), { Color = Color3.fromRGB(255, 255, 255), Transparency = 0.9 }):Play()
                        TweenService:Create(FeatureFrame2, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.92 }):Play()
                    end
                    task.spawn(function()
                        if typeof(ToggleConfig.Callback) == "function" then
                            pcall(function() ToggleConfig.Callback(Value) end)
                        end
                    end)
                end
                ToggleFunc:Set(ToggleFunc.Value)
                CountItem = CountItem + 1
                Elements[configKey] = ToggleFunc
                return ToggleFunc
            end

            function Items:AddSlider(SliderConfig)
                 local SliderConfig = SliderConfig or {}
                 SliderConfig.Title = SliderConfig.Title or "Slider"
                 SliderConfig.Default = SliderConfig.Default or 50
                 local configKey = "Slider_" .. SliderConfig.Title
                 if ConfigData[configKey] ~= nil then SliderConfig.Default = ConfigData[configKey] end
                 
                 local SliderFunc = {Value = SliderConfig.Default}
                 local Slider = Instance.new("Frame")
                 Slider.BackgroundColor3 = Color3.fromRGB(255,255,255)
                 Slider.BackgroundTransparency = 0.935
                 Slider.Size = UDim2.new(1,0,0,60)
                 Slider.Parent = SectionAdd
                 
                 local UICorner = Instance.new("UICorner", Slider)
                 local Title = Instance.new("TextLabel", Slider)
                 Title.Text = SliderConfig.Title
                 Title.Font = Enum.Font.GothamBold
                 Title.TextSize = 15
                 Title.TextColor3 = Color3.new(1,1,1)
                 Title.BackgroundTransparency = 1
                 Title.Position = UDim2.new(0,10,0,10)
                 Title.Size = UDim2.new(1,-20,0,15)
                 
                 CountItem = CountItem + 1
                 return SliderFunc
            end
            
            function Items:AddInput(InputConfig)
                local InputConfig = InputConfig or {}
                local configKey = "Input_" .. (InputConfig.Title or "Input")
                local InputFunc = {Value = InputConfig.Default or ""}
                
                local Input = Instance.new("Frame")
                Input.Size = UDim2.new(1,0,0,46)
                Input.BackgroundTransparency = 0.935
                Input.BackgroundColor3 = Color3.new(1,1,1)
                Input.Parent = SectionAdd
                Instance.new("UICorner", Input).CornerRadius = UDim.new(0,4)
                
                local Title = Instance.new("TextLabel", Input)
                Title.Text = InputConfig.Title or "Input"
                Title.Font = Enum.Font.GothamBold
                Title.TextColor3 = Color3.new(1,1,1)
                Title.BackgroundTransparency = 1
                Title.Position = UDim2.new(0,10,0,0)
                Title.Size = UDim2.new(1,-20,1,0)
                Title.TextXAlignment = Enum.TextXAlignment.Left
                
                local TextBox = Instance.new("TextBox", Input)
                TextBox.Size = UDim2.new(0,100,0,30)
                TextBox.Position = UDim2.new(1,-110, 0.5, -15)
                TextBox.Font = Enum.Font.Gotham
                TextBox.Text = InputFunc.Value
                
                TextBox.FocusLost:Connect(function()
                    InputFunc.Value = TextBox.Text
                    ConfigData[configKey] = TextBox.Text
                    if InputConfig.Callback then InputConfig.Callback(TextBox.Text) end
                end)
                
                CountItem = CountItem + 1
                return InputFunc
            end

            function Items:AddDropdown(DropdownConfig)
                local DropdownConfig = DropdownConfig or {}
                DropdownConfig.Title = DropdownConfig.Title or "Dropdown"
                DropdownConfig.Options = DropdownConfig.Options or {}
                
                local DropdownFunc = { Value = DropdownConfig.Default }
                
                local Dropdown = Instance.new("Frame")
                Dropdown.BackgroundTransparency = 0.935
                Dropdown.BackgroundColor3 = Color3.fromRGB(255,255,255)
                Dropdown.Size = UDim2.new(1,0,0,46)
                Dropdown.Parent = SectionAdd
                Instance.new("UICorner", Dropdown)
                
                local Title = Instance.new("TextLabel", Dropdown)
                Title.Text = DropdownConfig.Title
                Title.Font = Enum.Font.GothamBold
                Title.TextColor3 = Color3.new(1,1,1)
                Title.BackgroundTransparency = 1
                Title.Position = UDim2.new(0,10,0,0)
                Title.Size = UDim2.new(1,-20,1,0)
                Title.TextXAlignment = Enum.TextXAlignment.Left
                
                local Button = Instance.new("TextButton", Dropdown)
                Button.Size = UDim2.new(1,0,1,0)
                Button.BackgroundTransparency = 1
                Button.Text = ""
                
                Button.MouseButton1Click:Connect(function()
                    if not MoreBlur.Visible then
                        MoreBlur.Visible = true
                        DropPageLayout:JumpToIndex(1)
                        TweenService:Create(MoreBlur, TweenInfo.new(0.3), {BackgroundTransparency = 0.8}):Play()
                        TweenService:Create(DropdownSelect, TweenInfo.new(0.3), {Position = UDim2.new(1, -172, 0.5, 0)}):Play()
                        
                        for _, v in pairs(ScrollSelect:GetChildren()) do
                            if v:IsA("Frame") then v:Destroy() end
                        end
                        ScrollSelect.CanvasSize = UDim2.new(0,0,0,0)
                        
                        for _, opt in pairs(DropdownConfig.Options) do
                            local btn = Instance.new("TextButton")
                            btn.Parent = ScrollSelect
                            btn.Size = UDim2.new(1,0,0,30)
                            btn.Text = opt
                            btn.Font = Enum.Font.Gotham
                            btn.TextColor3 = Color3.new(1,1,1)
                            btn.BackgroundTransparency = 1
                            btn.MouseButton1Click:Connect(function()
                                DropdownConfig.Callback(opt)
                            end)
                        end
                    end
                end)
                
                ScrollSelect.AutomaticCanvasSize = Enum.AutomaticSize.Y
                
                CountItem = CountItem + 1
                return DropdownFunc
            end

            CountSection = CountSection + 1
            return Items
        end

        CountTab = CountTab + 1
        local safeName = TabConfig.Name:gsub("%s+", "_")
        return Sections
    end

    return Tabs
end

return ZuperMing

-- local Window = ZuperMing:Window()

-- Window:AddTab({
--     Name = "player",
--     Icon = "player",
-- }):AddSection("hello", 'close'):AddButton({
--     Title = "Copy Link Discord",
--     Callback = function()
--         ZuperMing:MakeNotify({
--             Description = "Discord Link Copied!",
--             Content = "abcdefghijklmnopqrstuvwyzabcdefghijklmn",
--             Duration = 5
--         })
--         setclipboard("https://discord.gg/zuperminghub")
--     end
-- })

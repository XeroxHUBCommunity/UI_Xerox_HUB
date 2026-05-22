pcall(function() game:GetService("CoreGui"):FindFirstChild("ArsenalHub"):Remove() end)

-- ════════════════════════════════════════════════════════════
--  📦 Services
-- ════════════════════════════════════════════════════════════
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")

local function tw(obj, props, t, style, dir)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.18,
            style or Enum.EasingStyle.Quad,
            dir   or Enum.EasingDirection.Out
        ), props):Play()
end

-- ════════════════════════════════════════════════════════════
--  🎨 THEMES
-- ════════════════════════════════════════════════════════════
local THEMES = {
    { name="Fire",    ac=Color3.fromHex"ff5f32", dk=Color3.fromHex"5a2110", bg=Color3.fromHex"0e0e10", pn=Color3.fromHex"141418", sb=Color3.fromHex"111114", cd=Color3.fromHex"1c1c21", su=Color3.fromHex"787890", br=Color3.fromHex"282830", sl=Color3.fromHex"26263a" },
    { name="Cyan",    ac=Color3.fromHex"00d4ff", dk=Color3.fromHex"003d4d", bg=Color3.fromHex"090d10", pn=Color3.fromHex"0e1418", sb=Color3.fromHex"0b1014", cd=Color3.fromHex"131c21", su=Color3.fromHex"6a8090", br=Color3.fromHex"1a2830", sl=Color3.fromHex"162030" },
    { name="Rose",    ac=Color3.fromHex"ff4d8f", dk=Color3.fromHex"5c0f2a", bg=Color3.fromHex"100a0d", pn=Color3.fromHex"180d12", sb=Color3.fromHex"130a0f", cd=Color3.fromHex"1f1118", su=Color3.fromHex"906070", br=Color3.fromHex"301020", sl=Color3.fromHex"28101a" },
    { name="Emerald", ac=Color3.fromHex"00e887", dk=Color3.fromHex"004d2a", bg=Color3.fromHex"08100d", pn=Color3.fromHex"0d1510", sb=Color3.fromHex"0a120e", cd=Color3.fromHex"111d16", su=Color3.fromHex"5a8070", br=Color3.fromHex"1a2820", sl=Color3.fromHex"152218" },
    { name="Violet",  ac=Color3.fromHex"9b6dff", dk=Color3.fromHex"2e1a66", bg=Color3.fromHex"0c0b12", pn=Color3.fromHex"121018", sb=Color3.fromHex"0f0d15", cd=Color3.fromHex"1a1826", su=Color3.fromHex"7868a0", br=Color3.fromHex"262234", sl=Color3.fromHex"201d30" },
    { name="Gold",    ac=Color3.fromHex"ffb800", dk=Color3.fromHex"4d3600", bg=Color3.fromHex"100f08", pn=Color3.fromHex"18160a", sb=Color3.fromHex"14120a", cd=Color3.fromHex"201d0e", su=Color3.fromHex"908050", br=Color3.fromHex"302a10", sl=Color3.fromHex"282210" },
    { name="Ice",     ac=Color3.fromHex"6ec6ff", dk=Color3.fromHex"0d2d45", bg=Color3.fromHex"080c12", pn=Color3.fromHex"0d1018", sb=Color3.fromHex"0a0e15", cd=Color3.fromHex"111620", su=Color3.fromHex"607080", br=Color3.fromHex"182030", sl=Color3.fromHex"142030" },
}

local TH = THEMES[1]
local WT = Color3.fromRGB(225, 225, 232)

-- ════════════════════════════════════════════════════════════
--  🔧 GLOBAL COLOR STATE TRACKING
-- ════════════════════════════════════════════════════════════
local CurrentColor = Color3.fromRGB(255, 80, 50)

local function setCurrentColor(newColor, source)
    if newColor ~= CurrentColor then
        CurrentColor = newColor
        -- if source then
        --     print("[Color Debug] CurrentColor changed to:", color3ToHex(newColor), "from:", source)
        -- end
    end
end

-- ════════════════════════════════════════════════════════════
--  🔧 Color Utilities
-- ════════════════════════════════════════════════════════════
local function hexToColor3(hex)
    hex = hex:gsub("^#", "")
    if #hex ~= 6 then return nil end
    local r = tonumber(hex:sub(1,2), 16)
    local g = tonumber(hex:sub(3,4), 16)
    local b = tonumber(hex:sub(5,6), 16)
    if not (r and g and b) then return nil end
    return Color3.fromRGB(r, g, b)
end

local function color3ToHex(c)
    return string.format("%02X%02X%02X",
        math.round(c.R * 255),
        math.round(c.G * 255),
        math.round(c.B * 255))
end

local function rgbStringToColor3(s)
    local r,g,b = s:match("(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
    r,g,b = tonumber(r), tonumber(g), tonumber(b)
    if not (r and g and b) then return nil end
    return Color3.fromRGB(math.clamp(r,0,255), math.clamp(g,0,255), math.clamp(b,0,255))
end

local function color3ToRgbString(c)
    return math.round(c.R*255)..","..math.round(c.G*255)..","..math.round(c.B*255)
end

local function hsvToColor3(h, s, v) return Color3.fromHSV(h, s, v) end
local function color3ToHsv(c) return Color3.toHSV(c) end

-- ════════════════════════════════════════════════════════════
--  🔔 THEME REGISTRY
-- ════════════════════════════════════════════════════════════
local _themeListeners = {}

local function onThemeChange(fn)
    table.insert(_themeListeners, fn)
end

local function fireThemeChange()
    for _, fn in ipairs(_themeListeners) do
        pcall(fn, TH)
    end
end

-- ════════════════════════════════════════════════════════════
--  🔵 Page Transition System
-- ════════════════════════════════════════════════════════════
local function pageOut(pageFrame, done)
    if not pageFrame then if done then done() end return end
    local ov = pageFrame:FindFirstChild("__FadeOverlay")
    if not ov then
        ov = Instance.new("Frame")
        ov.Name             = "__FadeOverlay"
        ov.Parent           = pageFrame
        ov.BackgroundColor3 = pageFrame.BackgroundColor3
        ov.BorderSizePixel  = 0
        ov.Size             = UDim2.new(1,0,1,0)
        ov.ZIndex           = 500
        ov.BackgroundTransparency = 1
    end
    ov.BackgroundColor3 = TH.pn
    tw(ov, {BackgroundTransparency = 0}, 0.16, Enum.EasingStyle.Sine)
    task.delay(0.18, function()
        if done then done() end
    end)
end

local function pageIn(pageFrame)
    if not pageFrame then return end
    local ov = pageFrame:FindFirstChild("__FadeOverlay")
    if not ov then return end
    task.delay(0.04, function()
        tw(ov, {BackgroundTransparency = 1}, 0.22, Enum.EasingStyle.Sine)
        task.delay(0.24, function()
            if ov and ov.Parent then ov:Destroy() end
        end)
    end)
end

-- ════════════════════════════════════════════════════════════
--  📱 Library
-- ════════════════════════════════════════════════════════════
local Library = {}

function Library:Window(windowTitle, SizeUI)

    local ui = Instance.new("ScreenGui")
    ui.Name           = "ArsenalHub"
    ui.Parent         = game:GetService("CoreGui")
    ui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ui.ResetOnSpawn   = false
    ui.DisplayOrder   = 999

    -- ── Responsive sizing ─────────────────────────────────────
    local vp       = workspace.CurrentCamera.ViewportSize
    local isMobile = vp.X < 600
    local _winW    = isMobile and math.floor(vp.X - 16)
                     or ((SizeUI and SizeUI.X.Offset) or 560)
    local _winH    = isMobile and math.floor(vp.Y * 0.78)
                     or ((SizeUI and SizeUI.Y.Offset) or 340)

    local Win = Instance.new("Frame")
    Win.Name             = "Win"
    Win.Parent           = ui
    Win.BackgroundColor3 = TH.bg
    Win.BorderSizePixel  = 0
    Win.Position         = UDim2.new(0.5, -math.floor(_winW/2), 0.5, -math.floor(_winH/2))
    Win.Size             = UDim2.new(0, _winW, 0, _winH)
    Win.Active           = true
    Win.Draggable        = false   -- ปิด built-in ใช้ระบบใหม่แทน
    Win.ClipsDescendants = true

    local WinStroke = Instance.new("UIStroke")
    WinStroke.Parent    = Win
    WinStroke.Color     = TH.br
    WinStroke.Thickness = 1.5

    local Shadow = Instance.new("ImageLabel")
    Shadow.Parent                 = Win
    Shadow.AnchorPoint            = Vector2.new(0.5,0.5)
    Shadow.BackgroundTransparency = 1
    Shadow.Position               = UDim2.new(0.5,0,0.5,0)
    Shadow.Size                   = UDim2.new(1,70,1,70)
    Shadow.ZIndex                 = 0
    Shadow.Image                  = "rbxassetid://5554236805"
    Shadow.ImageColor3            = Color3.new(0,0,0)
    Shadow.ImageTransparency      = 0.4
    Shadow.ScaleType              = Enum.ScaleType.Slice
    Shadow.SliceCenter            = Rect.new(23,23,277,277)

    local TBar = Instance.new("Frame")
    TBar.Name             = "TBar"
    TBar.Parent           = Win
    TBar.BackgroundColor3 = TH.pn
    TBar.BorderSizePixel  = 0
    TBar.Size             = UDim2.new(1,0,0,44)
    TBar.ZIndex           = 3

    local TBarLine = Instance.new("Frame")
    TBarLine.Parent           = TBar
    TBarLine.AnchorPoint      = Vector2.new(0,1)
    TBarLine.BackgroundColor3 = TH.br
    TBarLine.BorderSizePixel  = 0
    TBarLine.Position         = UDim2.new(0,0,1,0)
    TBarLine.Size             = UDim2.new(1,0,0,1)

    local AcDot = Instance.new("Frame")
    AcDot.Parent           = TBar
    AcDot.AnchorPoint      = Vector2.new(0,0.5)
    AcDot.BackgroundColor3 = TH.ac
    AcDot.BorderSizePixel  = 0
    AcDot.Position         = UDim2.new(0,14,0.5,0)
    AcDot.Size             = UDim2.new(0,9,0,9)
    local _adc = Instance.new("UICorner"); _adc.CornerRadius = UDim.new(1,0); _adc.Parent = AcDot

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Parent               = TBar
    TitleLbl.AnchorPoint          = Vector2.new(0,0.5)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Position             = UDim2.new(0,28,0.5,0)
    TitleLbl.Size                 = UDim2.new(1,-120,0,20)
    TitleLbl.Font                 = Enum.Font.GothamBold
    TitleLbl.Text                 = windowTitle or "Arsenal Hub"
    TitleLbl.TextColor3           = WT
    TitleLbl.TextSize             = 14
    TitleLbl.TextXAlignment       = Enum.TextXAlignment.Left

    local VerBadge = Instance.new("TextLabel")
    VerBadge.Parent           = TBar
    VerBadge.AnchorPoint      = Vector2.new(1,0.5)
    VerBadge.BackgroundColor3 = TH.dk
    VerBadge.BorderSizePixel  = 0
    VerBadge.Position         = UDim2.new(1,-14,0.5,0)
    VerBadge.Size             = UDim2.new(0,44,0,20)
    VerBadge.Font             = Enum.Font.GothamBold
    VerBadge.Text             = "UI v 2.1"
    VerBadge.TextColor3       = TH.ac
    VerBadge.TextSize         = 9
    local _vbc = Instance.new("UICorner"); _vbc.CornerRadius = UDim.new(0,6); _vbc.Parent = VerBadge

    local Sidebar = Instance.new("Frame")
    Sidebar.Name             = "Sidebar"
    Sidebar.Parent           = Win
    Sidebar.BackgroundColor3 = TH.sb
    Sidebar.BorderSizePixel  = 0
    Sidebar.Position         = UDim2.new(0,0,0,45)
    Sidebar.Size             = UDim2.new(0,104,1,-45)
    Sidebar.ClipsDescendants = false

    local SbLine = Instance.new("Frame")
    SbLine.Parent           = Sidebar
    SbLine.AnchorPoint      = Vector2.new(1,0)
    SbLine.BackgroundColor3 = TH.br
    SbLine.BorderSizePixel  = 0
    SbLine.Position         = UDim2.new(1,0,0,0)
    SbLine.Size             = UDim2.new(0,1,1,0)

    local TabListFrame = Instance.new("ScrollingFrame")
    TabListFrame.Name                   = "TabListFrame"
    TabListFrame.Parent                 = Sidebar
    TabListFrame.BackgroundTransparency = 1
    TabListFrame.Size                   = UDim2.new(1,0,1,-52)
    TabListFrame.ClipsDescendants       = true
    TabListFrame.ScrollBarThickness     = 0
    TabListFrame.ScrollingEnabled       = true
    TabListFrame.CanvasSize             = UDim2.new(0,0,0,0)

    local TLFLayout = Instance.new("UIListLayout")
    TLFLayout.Parent              = TabListFrame
    TLFLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TLFLayout.SortOrder           = Enum.SortOrder.LayoutOrder
    TLFLayout.Padding             = UDim.new(0,2)

    TLFLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabListFrame.CanvasSize = UDim2.new(0,0,0, TLFLayout.AbsoluteContentSize.Y + 16)
    end)

    local TLFPad = Instance.new("UIPadding")
    TLFPad.Parent     = TabListFrame
    TLFPad.PaddingTop = UDim.new(0,8)

    local Indic = Instance.new("Frame")
    Indic.Name             = "Indic"
    Indic.Parent           = Sidebar
    Indic.BackgroundColor3 = TH.ac
    Indic.BorderSizePixel  = 0
    Indic.Position         = UDim2.new(0,0,0,0)
    Indic.Size             = UDim2.new(0,3,0,28)
    Indic.ZIndex           = 1
    local _ic = Instance.new("UICorner"); _ic.CornerRadius = UDim.new(0,2); _ic.Parent = Indic

    local PlayerCard = Instance.new("Frame")
    PlayerCard.Name             = "PlayerCard"
    PlayerCard.Parent           = Sidebar
    PlayerCard.AnchorPoint      = Vector2.new(0,1)
    PlayerCard.BackgroundColor3 = TH.pn
    PlayerCard.BorderSizePixel  = 0
    PlayerCard.Position         = UDim2.new(0,0,1,0)
    PlayerCard.Size             = UDim2.new(1,0,0,52)

    local PcLine = Instance.new("Frame")
    PcLine.Parent           = PlayerCard
    PcLine.BackgroundColor3 = TH.br
    PcLine.BorderSizePixel  = 0
    PcLine.Size             = UDim2.new(1,0,0,1)

    local PlayerName = Instance.new("TextLabel")
    PlayerName.Parent               = PlayerCard
    PlayerName.BackgroundTransparency = 1
    PlayerName.AnchorPoint          = Vector2.new(0.5,0.5)
    PlayerName.Position             = UDim2.new(0.5,0,0.4,0)
    PlayerName.Size                 = UDim2.new(1,-8,0,16)
    PlayerName.Font                 = Enum.Font.GothamBold
    PlayerName.Text                 = Players.LocalPlayer.Name
    PlayerName.TextColor3           = WT
    PlayerName.TextSize             = 10
    PlayerName.TextTruncate         = Enum.TextTruncate.AtEnd

    local OnlineLbl = Instance.new("TextLabel")
    OnlineLbl.Parent               = PlayerCard
    OnlineLbl.BackgroundTransparency = 1
    OnlineLbl.AnchorPoint          = Vector2.new(0.5,0.5)
    OnlineLbl.Position             = UDim2.new(0.5,0,0.72,0)
    OnlineLbl.Size                 = UDim2.new(1,-8,0,14)
    OnlineLbl.Font                 = Enum.Font.Gotham
    OnlineLbl.Text                 = "● online"
    OnlineLbl.TextColor3           = Color3.fromRGB(72,210,120)
    OnlineLbl.TextSize             = 9

    local ContentArea = Instance.new("Frame")
    ContentArea.Name             = "ContentArea"
    ContentArea.Parent           = Win
    ContentArea.BackgroundColor3 = TH.pn
    ContentArea.BorderSizePixel  = 0
    ContentArea.Position         = UDim2.new(0,101,0,45)
    ContentArea.Size             = UDim2.new(1.04,-105,1,-45)
    ContentArea.ClipsDescendants = true

    local PageList = Instance.new("Frame")
    PageList.Name                   = "PageList"
    PageList.Parent                 = ContentArea
    PageList.BackgroundTransparency = 1
    PageList.BorderSizePixel        = 0
    PageList.Size                   = UDim2.new(1,0,1,0)

    local UIPageLayout = Instance.new("UIPageLayout")
    UIPageLayout.Parent                  = PageList
    UIPageLayout.SortOrder               = Enum.SortOrder.LayoutOrder
    UIPageLayout.EasingDirection         = Enum.EasingDirection.InOut
    UIPageLayout.EasingStyle             = Enum.EasingStyle.Sine
    UIPageLayout.FillDirection           = Enum.FillDirection.Vertical
    UIPageLayout.Padding                 = UDim.new(0,15)
    UIPageLayout.TweenTime               = 0.30
    UIPageLayout.GamepadInputEnabled     = false
    UIPageLayout.ScrollWheelInputEnabled = false
    UIPageLayout.TouchInputEnabled       = false

    local ResizeBtn = Instance.new("ImageButton")
    ResizeBtn.Name                   = "Resize"
    ResizeBtn.Parent                 = Win
    ResizeBtn.AnchorPoint            = Vector2.new(1,1)
    ResizeBtn.BackgroundTransparency = 1
    ResizeBtn.Position               = UDim2.new(1,0,1,0)
    ResizeBtn.Size                   = UDim2.new(0,20,0,20)
    ResizeBtn.ZIndex                 = 20
    ResizeBtn.Image                  = "rbxassetid://132603703878244"
    ResizeBtn.ImageColor3            = TH.su
    ResizeBtn.AutoButtonColor        = false
    ResizeBtn.Rotation               = 90

    ResizeBtn.MouseEnter:Connect(function() tw(ResizeBtn,{ImageColor3=TH.ac},0.15) end)
    ResizeBtn.MouseLeave:Connect(function() tw(ResizeBtn,{ImageColor3=TH.su},0.15) end)

    -- ── Resize handle (PC + Mobile) ───────────────────────────
    do
        local minW, minH = 280, 260
        local resizing = false
        local startMX, startMY, startW, startH = 0, 0, 0, 0

        local function onResizeStart(pos)
            resizing = true
            startMX  = pos.X
            startMY  = pos.Y
            startW   = Win.Size.X.Offset
            startH   = Win.Size.Y.Offset
        end
        local function onResizeMove(pos)
            if not resizing then return end
            local nw = math.max(minW, startW + (pos.X - startMX))
            local nh = math.max(minH, startH + (pos.Y - startMY))
            Win.Size = UDim2.new(0, nw, 0, nh)
        end
        local function onResizeEnd()
            resizing = false
        end

        ResizeBtn.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
                onResizeStart(inp.Position)
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement
            or inp.UserInputType == Enum.UserInputType.Touch then
                onResizeMove(inp.Position)
            end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
                onResizeEnd()
            end
        end)
    end

    -- ── Drag window (PC + Mobile) via TBar ───────────────────
    do
        local dragging = false
        local dragStartPos, winStartPos

        TBar.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
                dragging     = true
                dragStartPos = inp.Position
                winStartPos  = Win.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if not dragging then return end
            if inp.UserInputType == Enum.UserInputType.MouseMovement
            or inp.UserInputType == Enum.UserInputType.Touch then
                local d = inp.Position - dragStartPos
                Win.Position = UDim2.new(
                    winStartPos.X.Scale, winStartPos.X.Offset + d.X,
                    winStartPos.Y.Scale, winStartPos.Y.Offset + d.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    onThemeChange(function(t)
        tw(Win,         {BackgroundColor3 = t.bg}, 0.22)
        tw(WinStroke,   {Color = t.br},             0.22)
        tw(TBar,        {BackgroundColor3 = t.pn},  0.22)
        tw(TBarLine,    {BackgroundColor3 = t.br},  0.22)
        tw(AcDot,       {BackgroundColor3 = t.ac},  0.22)
        tw(VerBadge,    {BackgroundColor3 = t.dk, TextColor3 = t.ac}, 0.22)
        tw(Sidebar,     {BackgroundColor3 = t.sb},  0.22)
        tw(SbLine,      {BackgroundColor3 = t.br},  0.22)
        tw(Indic,       {BackgroundColor3 = t.ac},  0.22)
        tw(PlayerCard,  {BackgroundColor3 = t.pn},  0.22)
        tw(PcLine,      {BackgroundColor3 = t.br},  0.22)
        tw(ContentArea, {BackgroundColor3 = t.pn},  0.22)
        ResizeBtn.ImageColor3 = t.su
    end)

    -- ════════════════════════════════════════════════════════════
    --  🎬 OPEN / COLLAPSE ANIMATION  (RCtrl toggle)
    --
    --  เปิดครั้งแรก:
    --    ① สี่เหลี่ยมเล็ก (Pill) ลอยขึ้นจากล่างจอ
    --    ② ขยายออกจนเท่า Win (แต่โล่ง เห็นแค่ outline + bg สี)
    --    ③ fade-in ทีละส่วน: TBar → Sidebar → ContentArea
    --
    --  RCtrl → collapse: content fade-out → Win หด → Pill ลง
    --  RCtrl อีกครั้ง / กด Pill → expand กลับ
    -- ════════════════════════════════════════════════════════════

    -- ขนาดเป้าหมาย (ใช้ _winW/_winH ที่คำนวณไว้แล้ว)
    local _targetW  = _winW
    local _targetH  = _winH
    local _targetPX  = 0.5
    local _targetPXO = -math.floor(_targetW / 2)
    local _targetPY  = 0.5
    local _targetPYO = -math.floor(_targetH / 2)

    -- ซ่อน Win ตอนเริ่ม (จะแสดงหลัง animation)
    Win.Visible = false

    -- รายการ content ที่ fade-in ทีละส่วน
    local _parts = { TBar, Sidebar, ContentArea }

    -- ── Pill ─────────────────────────────────────────────────
    local Pill = Instance.new("Frame")
    Pill.Name             = "ArsenalPill"
    Pill.Parent           = ui
    Pill.BackgroundColor3 = TH.bg
    Pill.BorderSizePixel  = 0
    Pill.AnchorPoint      = Vector2.new(0.5, 0.5)
    Pill.Position         = UDim2.new(0.5, 0, 1, 80)   -- ใต้จอก่อน
    Pill.Size             = UDim2.new(0, 160, 0, 34)
    Pill.ZIndex           = 200
    Pill.Visible          = false
    local _pillC = Instance.new("UICorner"); _pillC.CornerRadius = UDim.new(0,17); _pillC.Parent = Pill
    local PillStroke = Instance.new("UIStroke")
    PillStroke.Parent = Pill; PillStroke.Color = TH.ac; PillStroke.Thickness = 1.5

    -- dot accent
    local PillDot = Instance.new("Frame")
    PillDot.Parent = Pill; PillDot.AnchorPoint = Vector2.new(0,0.5)
    PillDot.BackgroundColor3 = TH.ac; PillDot.BorderSizePixel = 0
    PillDot.Position = UDim2.new(0,11,0.5,0); PillDot.Size = UDim2.new(0,7,0,7)
    local _dC = Instance.new("UICorner"); _dC.CornerRadius = UDim.new(1,0); _dC.Parent = PillDot

    -- ชื่อ UI
    local PillLbl = Instance.new("TextLabel")
    PillLbl.Parent = Pill; PillLbl.BackgroundTransparency = 1
    PillLbl.Position = UDim2.new(0,24,0,0); PillLbl.Size = UDim2.new(1,-50,1,0)
    PillLbl.Font = Enum.Font.GothamBold
    PillLbl.Text = windowTitle or "Arsenal Hub"
    PillLbl.TextColor3 = WT; PillLbl.TextSize = 11
    PillLbl.TextXAlignment = Enum.TextXAlignment.Left

    -- hint expand
    local PillHint = Instance.new("TextLabel")
    PillHint.Parent = Pill; PillHint.BackgroundTransparency = 1
    PillHint.AnchorPoint = Vector2.new(1,0.5)
    PillHint.Position = UDim2.new(1,-8,0.5,0); PillHint.Size = UDim2.new(0,20,0,20)
    PillHint.Font = Enum.Font.GothamBold; PillHint.Text = "▲"
    PillHint.TextColor3 = TH.su; PillHint.TextSize = 9

    -- clickable area
    local PillBtn = Instance.new("TextButton")
    PillBtn.Parent = Pill; PillBtn.BackgroundTransparency = 1
    PillBtn.Size = UDim2.new(1,0,1,0); PillBtn.Text = ""; PillBtn.ZIndex = 210

    onThemeChange(function(t)
        tw(Pill,    {BackgroundColor3 = t.bg}, 0.22)
        PillStroke.Color = t.ac
        PillDot.BackgroundColor3 = t.ac
        PillHint.TextColor3 = t.su
    end)

    -- ── state ─────────────────────────────────────────────────
    local _collapsed = false
    local _busy      = false
    local _savedPos  = Win.Position   -- จำตำแหน่ง win ก่อน collapse

    -- ── helper: ซ่อน / แสดง content ─────────────────────────
    local function hideContent()
        for _, f in ipairs(_parts) do
            f.BackgroundTransparency = 1
            f.Visible = false
        end
    end

    local function fadeInContent()
        -- TBar
        task.delay(0.05, function()
            TBar.Visible = true
            tw(TBar, {BackgroundTransparency = 0}, 0.20, Enum.EasingStyle.Sine)
        end)
        -- Sidebar
        task.delay(0.18, function()
            Sidebar.Visible = true
            tw(Sidebar, {BackgroundTransparency = 0}, 0.22, Enum.EasingStyle.Sine)
        end)
        -- ContentArea
        task.delay(0.30, function()
            ContentArea.Visible = true
            tw(ContentArea, {BackgroundTransparency = 0}, 0.24, Enum.EasingStyle.Sine)
            task.delay(0.26, function() _busy = false end)
        end)
    end

    -- ── OPEN (ครั้งแรก) ──────────────────────────────────────
    local function playOpenAnim()
        if _busy then return end
        _busy = true
        hideContent()

        -- ① Pill โผล่จากล่างจอ
        Pill.Visible = true
        Pill.Size    = UDim2.new(0, 160, 0, 34)
        Pill.Position = UDim2.new(0.5, 0, 1, 80)
        Pill.BackgroundTransparency = 0
        PillStroke.Transparency = 0

        -- เลื่อน pill ขึ้นหยุดเหนือก้นจอ (0.32s, Back)
        tw(Pill, {Position = UDim2.new(0.5, 0, 1, -22)},
            0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

        task.delay(0.40, function()
            -- ② ขยาย pill → ขนาด Win (outline โล่ง)
            tw(Pill, {
                Position = UDim2.new(_targetPX, _targetPXO, _targetPY, _targetPYO),
                Size     = UDim2.new(0, _targetW, 0, _targetH),
            }, 0.42, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

            task.delay(0.46, function()
                -- ③ แสดง Win โล่ง แล้วซ่อน Pill
                Win.Position = UDim2.new(_targetPX, _targetPXO, _targetPY, _targetPYO)
                Win.Size     = UDim2.new(0, _targetW, 0, _targetH)
                Win.BackgroundTransparency = 0
                Win.Visible  = true
                Pill.Visible = false

                -- ④ fade-in content ทีละส่วน
                fadeInContent()
            end)
        end)
    end

    -- ── COLLAPSE ─────────────────────────────────────────────
    local function collapseWindow()
        if _busy or _collapsed then return end
        _busy      = true
        _collapsed = true
        _savedPos  = Win.Position

        -- fade-out content (0.14s)
        for _, f in ipairs(_parts) do
            tw(f, {BackgroundTransparency = 1}, 0.14, Enum.EasingStyle.Sine)
        end
        tw(Win, {BackgroundTransparency = 1}, 0.14, Enum.EasingStyle.Sine)

        task.delay(0.17, function()
            Win.Visible = false
            hideContent()

            -- แสดง pill ตรงกลาง win เดิม แล้วหด
            local absX = Win.AbsolutePosition.X + Win.AbsoluteSize.X / 2
            local absY = Win.AbsolutePosition.Y + Win.AbsoluteSize.Y / 2
            Pill.AnchorPoint = Vector2.new(0.5, 0.5)
            Pill.Position = UDim2.new(0, absX, 0, absY)
            Pill.Size     = UDim2.new(0, _targetW, 0, _targetH)
            Pill.BackgroundTransparency = 1
            PillStroke.Transparency = 1
            PillHint.Text = "▲"
            Pill.Visible  = true

            -- หด → pill เล็ก พร้อม fade-in
            tw(Pill, {
                Size                   = UDim2.new(0, 160, 0, 34),
                BackgroundTransparency = 0,
            }, 0.34, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            tw(PillStroke, {Transparency = 0}, 0.34, Enum.EasingStyle.Sine)

            -- เลื่อนลงก้นจอ
            tw(Pill, {Position = UDim2.new(0.5, 0, 1, -22)},
                0.40, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

            task.delay(0.42, function() _busy = false end)
        end)
    end

    -- ── EXPAND ───────────────────────────────────────────────
    local function expandWindow()
        if _busy or not _collapsed then return end
        _busy      = true
        _collapsed = false
        PillHint.Text = "▼"

        -- ขยาย pill → ขนาด win (กลับตำแหน่งเดิม)
        local tx = _savedPos.X.Scale
        local txO = _savedPos.X.Offset
        local ty  = _savedPos.Y.Scale
        local tyO = _savedPos.Y.Offset

        tw(Pill, {
            Position = UDim2.new(tx, txO, ty, tyO),
            Size     = UDim2.new(0, _targetW, 0, _targetH),
        }, 0.40, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

        task.delay(0.44, function()
            -- แสดง Win โล่ง ซ่อน Pill
            Win.Position = _savedPos
            Win.Size     = UDim2.new(0, _targetW, 0, _targetH)
            Win.BackgroundTransparency = 0
            Win.Visible  = true
            Pill.Visible = false

            -- fade-in content ทีละส่วน
            hideContent()
            fadeInContent()
        end)
    end

    -- Pill click + Touch → expand
    PillBtn.InputBegan:Connect(function(inp)
        if (inp.UserInputType == Enum.UserInputType.MouseButton1
        or  inp.UserInputType == Enum.UserInputType.Touch)
        and _collapsed and not _busy then
            expandWindow()
        end
    end)

    -- RCtrl toggle (PC)
    UserInputService.InputBegan:Connect(function(inp, gpe)
        if gpe then return end
        if inp.KeyCode == Enum.KeyCode.RightControl then
            if _collapsed then expandWindow() else collapseWindow() end
        end
    end)

    -- Double-tap TBar toggle (มือถือ)
    if isMobile then
        local _lastTap = 0
        TBar.InputBegan:Connect(function(inp)
            if inp.UserInputType ~= Enum.UserInputType.Touch then return end
            local now = tick()
            if now - _lastTap < 0.35 then
                if _collapsed then expandWindow() else collapseWindow() end
            end
            _lastTap = now
        end)
    end

    -- เรียก open animation หลัง 1 frame
    task.defer(function()
        task.wait(0.08)
        playOpenAnim()
    end)

    -- ════════════════════════════════════════════════
    --  Tab system
    -- ════════════════════════════════════════════════
-- ════════════════════════════════════════════════
--  Tab system  (แทนที่ของเดิมทั้งหมด)
-- ════════════════════════════════════════════════
local allTabBtns  = {}
local allPages    = {}
local currentIdx  = 0
local currentPage = nil
local transitioning = false
local Tabs = {}

-- ── ลบ PageList + UIPageLayout ออก ────────────────
-- (ไม่ต้องสร้าง PageList / UIPageLayout เลย)

-- ── moveIndic ──────────────────────────────────────
-- คำนวณจาก AbsolutePosition จริงๆ เหมือน HTML
local BTN_H = 52
local BTN_G = 2
local PAD_T = 8

local function moveIndic(idx)
    if idx == 0 then return end
    local btn = allTabBtns[idx] and allTabBtns[idx].btn
    if not btn then return end

    -- AbsolutePosition ของ btn รวม scroll offset ไปแล้ว
    -- เราต้องการ position relative to Sidebar ไม่ใช่ TabListFrame
    local sbAbs  = Sidebar.AbsolutePosition
    local btnAbs = btn.AbsolutePosition
    local btnH   = btn.AbsoluteSize.Y

    local h2  = math.floor(btnH * 0.55)
    local top = math.floor((btnAbs.Y - sbAbs.Y) + (btnH - h2) / 2)

    tw(Indic, {Size     = UDim2.new(0, 3, 0, h2)},   0.12, Enum.EasingStyle.Quad)
    tw(Indic, {Position = UDim2.new(0, 0, 0, top)},  0.28, Enum.EasingStyle.Quint)
end

TabListFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
    if currentIdx == 0 then return end
    local btn = allTabBtns[currentIdx] and allTabBtns[currentIdx].btn
    if not btn then return end

    local sbAbs  = Sidebar.AbsolutePosition
    local btnAbs = btn.AbsolutePosition
    local btnH   = btn.AbsoluteSize.Y
    local h2     = math.floor(btnH * 0.55)
    local top    = math.floor((btnAbs.Y - sbAbs.Y) + (btnH - h2) / 2)

    -- ตามทันที ไม่ tween
    Indic.Size     = UDim2.new(0, 3, 0, h2)
    Indic.Position = UDim2.new(0, 0, 0, top)
end)

-- ── switchToPane ───────────────────────────────────
-- เหมือน HTML: slide ขึ้น/ลง + opacity
local DUR = 0.15

local function resetPage(p)
    p.Visible = false
    p.Position = UDim2.new(0,0,0,0)
    p.BackgroundTransparency = 0
    p.CanvasPosition = Vector2.new(0,0)
end

local function animOut(p, dirY, done)
    -- slide ออก + fade
    tw(p, {Position = UDim2.new(0,0,0, dirY * -10)}, DUR, Enum.EasingStyle.Quad)
    tw(p, {BackgroundTransparency = 1},               DUR, Enum.EasingStyle.Quad)
    task.delay(DUR, function()
        resetPage(p)
        if done then done() end
    end)
end

local function animIn(p, dirY)
    p.Position = UDim2.new(0,0,0, dirY * 10)
    p.BackgroundTransparency = 1
    p.Visible = true
    tw(p, {Position = UDim2.new(0,0,0,0)}, DUR, Enum.EasingStyle.Quad)
    tw(p, {BackgroundTransparency = 0},     DUR, Enum.EasingStyle.Quad)
    task.delay(DUR + 0.02, function()
        transitioning = false
    end)
end


local function switchToPane(newIdx, newPage)
    if newIdx == currentIdx then return end

    if transitioning then
        if currentPage then resetPage(currentPage) end
        newPage.Position             = UDim2.new(0,0,0,0)
        newPage.BackgroundTransparency = 0
        newPage.Visible              = true
        currentIdx  = newIdx
        currentPage = newPage
        return
    end
    transitioning = true

    -- dir = 1 กดลง (tab ถัดไป), dir = -1 กดขึ้น (tab ก่อนหน้า)
    local dir     = newIdx > currentIdx and 1 or -1
    local oldPage = currentPage
    currentPage   = newPage
    currentIdx    = newIdx

    if not oldPage then
        newPage.Position             = UDim2.new(0,0,0,0)
        newPage.BackgroundTransparency = 0
        newPage.Visible              = true
        transitioning = false
        return
    end

    local overlay = Instance.new("Frame")
    overlay.Name                   = "FadeOverlay"
    overlay.Parent                 = ContentArea
    overlay.BackgroundColor3       = TH.pn
    overlay.BackgroundTransparency = 1
    overlay.BorderSizePixel        = 0
    overlay.Size                   = UDim2.new(1,0,1,0)
    overlay.Position               = UDim2.new(0,0,0, dir * -20)
    overlay.ZIndex                 = 100

    tw(overlay, {Position = UDim2.new(0,0,0,0)}, 0.14, Enum.EasingStyle.Sine)
    tw(overlay, {BackgroundTransparency = 0},     0.14, Enum.EasingStyle.Sine)

    task.delay(0.16, function()
        animOut(oldPage, dir, function()
            resetPage(oldPage)
            animIn(newPage, dir)
            tw(overlay, {Position = UDim2.new(0,0,0, dir * 20)}, 0.18, Enum.EasingStyle.Sine)
            tw(overlay, {BackgroundTransparency = 1},             0.18, Enum.EasingStyle.Sine)
            task.delay(0.20, function()
                overlay:Destroy()
                transitioning = false
            end)
        end)
    end)
end
    -- ════════════════════════════════════════════════
    --  Tab builder
    -- ════════════════════════════════════════════════

function Tabs:Tab(tabName, tabIcon)

    local TabBtn = Instance.new("TextButton")
    TabBtn.Name                   =  tabName
    TabBtn.Parent                 = TabListFrame
    TabBtn.BackgroundColor3       = WT
    TabBtn.BackgroundTransparency = 1
    TabBtn.BorderSizePixel        = 0
    TabBtn.Size                   = UDim2.new(1,0,0,50)
    TabBtn.AutoButtonColor        = false
    TabBtn.Text                   = ""
    TabBtn.ZIndex                 = 2
    
    local _tbc = Instance.new("UICorner")
    _tbc.CornerRadius = UDim.new(0,7); _tbc.Parent = TabBtn
-- เพิ่มหลัง TIcon

    local TLbl = Instance.new("TextLabel")
    TLbl.Name                   = "TLbl"
    TLbl.Parent                 = TabBtn
    TLbl.BackgroundTransparency = 1
    TLbl.AnchorPoint            = Vector2.new(0.5, 1)
    TLbl.Position               = UDim2.new(0.5, 0, 1, -6)
    TLbl.Size                   = UDim2.new(1, -4, 0, 11)
    TLbl.Font                   = Enum.Font.GothamSemibold
    TLbl.Text                   = tabName
    TLbl.TextColor3             = TH.su
    TLbl.TextSize               = 10
    TLbl.TextTruncate           = Enum.TextTruncate.AtEnd
    TLbl.ZIndex                 = 3

    local TIcon = Instance.new("ImageLabel")
    TIcon.Name                   = "TIcon"
    TIcon.Parent                 = TabBtn
    TIcon.BackgroundTransparency = 1
    TIcon.AnchorPoint            = Vector2.new(0.5,0)
    TIcon.Position               = UDim2.new(0.5,0,0,8)
    TIcon.Size                   = UDim2.new(0,20,0,20)
    TIcon.ScaleType              = Enum.ScaleType.Fit
    TIcon.Image                  = "rbxassetid://" .. tabIcon
    TIcon.ImageColor3            = TH.su
    TIcon.ZIndex                 = 3

    -- hover
TabBtn.MouseEnter:Connect(function()
    if not (allTabBtns[currentIdx] and allTabBtns[currentIdx].btn == TabBtn) then
        tw(TabBtn, {BackgroundColor3 = TH.dk, BackgroundTransparency = 0.6}, 0.15)
        tw(TIcon,  {ImageColor3 = WT}, 0.15)
        tw(TLbl,   {TextColor3 = WT}, 0.15)
    end
end)

TabBtn.MouseLeave:Connect(function()
    if not (allTabBtns[currentIdx] and allTabBtns[currentIdx].btn == TabBtn) then
        tw(TabBtn, {BackgroundTransparency = 1}, 0.15)
        tw(TIcon,  {ImageColor3 = TH.su}, 0.15)
        tw(TLbl,   {TextColor3 = TH.su}, 0.15)
    end
end)


    -- ── Page ── parent ตรงไป ContentArea (ไม่ผ่าน PageList)
    local Page = Instance.new("ScrollingFrame")
    Page.Name                    = "Page_" .. tabName
    Page.Parent                  = ContentArea   -- ← ContentArea โดยตรง
    Page.BackgroundColor3        = TH.pn
    Page.BackgroundTransparency  = 0
    Page.BorderSizePixel         = 0
    Page.Position                = UDim2.new(0,0,0,0)
    Page.Size                    = UDim2.new(1,0,1,0)
    Page.Visible                 = false          -- ← ซ่อนไว้ก่อน
    Page.Active                  = true
    Page.ScrollBarThickness      = 3
    Page.ScrollBarImageColor3    = TH.ac
    Page.CanvasSize              = UDim2.new(0,0,0,0)

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Parent              = Page
    PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    PageLayout.SortOrder           = Enum.SortOrder.LayoutOrder
    PageLayout.Padding             = UDim.new(0,4)

    local PagePad = Instance.new("UIPadding")
    PagePad.Parent        = Page
    PagePad.PaddingTop    = UDim.new(0,10)
    PagePad.PaddingLeft   = UDim.new(0,14)
    PagePad.PaddingRight  = UDim.new(0,14)
    PagePad.PaddingBottom = UDim.new(0,20)

    PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0,0,0, PageLayout.AbsoluteContentSize.Y + 32)
    end)
    onThemeChange(function(t)
        tw(Page, {BackgroundColor3 = t.pn}, 0.22)
        tw(TabBtn, {BackgroundColor3 = t.dk}, 0.15)
    end)
    local myIdx = #allTabBtns + 1
    table.insert(allTabBtns, {
        btn    = TabBtn,
        icon   = TIcon,
        lbl    = TLbl,           -- ← เพิ่ม
        isActive = function() return currentIdx == myIdx end
    })
    table.insert(allPages, Page)

    -- ── activate ───────────────────────────────────────
        local function activate()
            for _, t in ipairs(allTabBtns) do
                tw(t.btn,  {BackgroundTransparency = 1}, 0.15)
                tw(t.icon, {ImageColor3 = TH.su}, 0.15)
                tw(t.lbl,  {TextColor3 = TH.su}, 0.15)  -- ← เพิ่ม
            end
            tw(TabBtn, {BackgroundColor3 = TH.dk, BackgroundTransparency = 0}, 0.15)
            tw(TIcon,  {ImageColor3 = WT}, 0.15)
            tw(TLbl,   {TextColor3 = WT}, 0.15)           -- ← เพิ่ม

            task.defer(function() moveIndic(myIdx) end)
            switchToPane(myIdx, Page)
        end

    TabBtn.MouseButton1Click:Connect(activate)

    -- auto-select tab แรก
    if myIdx == 1 then
        task.defer(function() activate() end)
    end

    -- Element Builders ...
        -- ════════════════════════════════════════════════
        --  Element Builders
        -- ════════════════════════════════════════════════
        local TabFunctions = {}

        -- Section
        function TabFunctions:Section(text)
            local Sec = Instance.new("TextLabel")
            Sec.Name               = "Section"
            Sec.Parent             = Page
            Sec.BackgroundTransparency = 1
            Sec.BorderSizePixel    = 0
            Sec.Size               = UDim2.new(1,-28,0,20)
            Sec.Font               = Enum.Font.GothamBold
            Sec.Text               = (text or "Section"):upper()
            Sec.TextColor3         = TH.ac
            Sec.TextSize           = 9
            Sec.TextXAlignment     = Enum.TextXAlignment.Left
            local _sp = Instance.new("UIPadding"); _sp.Parent = Sec; _sp.PaddingTop = UDim.new(0,8)
            local SecLine = Instance.new("Frame")
            SecLine.Parent           = Sec
            SecLine.AnchorPoint      = Vector2.new(0,1)
            SecLine.BackgroundColor3 = TH.br
            SecLine.BorderSizePixel  = 0
            SecLine.Position         = UDim2.new(0,0,1,0)
            SecLine.Size             = UDim2.new(1,0,0,1)
            onThemeChange(function(t)
                tw(Sec,     {TextColor3 = t.ac}, 0.22)
                tw(SecLine, {BackgroundColor3 = t.br}, 0.22)
            end)
        end

        -- Toggle
        function TabFunctions:Toggle(label, on, callback)
            local d = 0.5
            callback = callback or function() end
            on = on == true
            local Row = Instance.new("Frame")
            Row.Name             = "Toggle"
            Row.Parent           = Page
            Row.BackgroundTransparency = 1
            Row.BorderSizePixel  = 0
            Row.Size             = UDim2.new(1,-28,0,30)

            local Lb = Instance.new("TextLabel")
            Lb.Parent               = Row
            Lb.BackgroundTransparency = 1
            Lb.Position             = UDim2.new(0,4,0,0)
            Lb.Size                 = UDim2.new(1,-50,1,0)
            Lb.Font                 = Enum.Font.Gotham
            Lb.Text                 = label or "Toggle"
            Lb.TextColor3           = WT
            Lb.TextSize             = 11
            Lb.TextXAlignment       = Enum.TextXAlignment.Left

            local Track = Instance.new("TextButton")
            Track.Parent           = Row
            Track.AnchorPoint      = Vector2.new(1,0.5)
            Track.BackgroundColor3 = on and TH.ac or TH.sl
            Track.BorderSizePixel  = 0
            Track.Position         = UDim2.new(1,0,0.5,0)
            Track.Size             = UDim2.new(0,40,0,20)
            Track.AutoButtonColor  = false
            Track.Text             = ""
                                    onThemeChange(function(t)
                            tw(Track, {BackgroundColor3 = on and t.ac or t.sl}, 0.22)
                        end)
            local _trc = Instance.new("UICorner"); _trc.CornerRadius = UDim.new(1,0); _trc.Parent = Track

            local Knob = Instance.new("Frame")
            Knob.Parent           = Track
            Knob.BackgroundColor3 = Color3.new(1,1,1)
            Knob.BorderSizePixel  = 0
            Knob.AnchorPoint      = Vector2.new(0,0.5)
            Knob.Position         = on and UDim2.new(0,22,0.5,0) or UDim2.new(0,2,0.5,0)
            Knob.Size             = UDim2.new(0,16,0,16)
            local _kc = Instance.new("UICorner"); _kc.CornerRadius = UDim.new(1,0); _kc.Parent = Knob

            local toggled = on
            Track.MouseButton1Down:Connect(function()
                tw(Track, {Size = UDim2.new(0,38,0,18)}, 0.08, Enum.EasingStyle.Sine)
                if not toggled then
                    tw(Knob, {Size = UDim2.new(0, 22, 0, 16)}, 0.10, Enum.EasingStyle.Sine)
                else
                    tw(Knob, {Position = UDim2.new(0, 16, 0.5, 0)}, 0.10, Enum.EasingStyle.Sine)
                    tw(Knob, {Size = UDim2.new(0, 22, 0, 16)}, 0.10, Enum.EasingStyle.Sine)
                end
            end)

            Track.MouseButton1Click:Connect(function()
                toggled = not toggled
                tw(Track, {Size = UDim2.new(0,40,0,20)}, 0.12, Enum.EasingStyle.Sine)
                tw(Track, {BackgroundColor3 = toggled and TH.ac or TH.sl}, 0.17)
                tw(Knob, {Size = UDim2.new(0, 16, 0, 16)}, 0.10, Enum.EasingStyle.Sine)
                if toggled then
                    tw(Knob, {Position = UDim2.new(0, 22, 0.5, 0)}, 0.17, Enum.EasingStyle.Sine)
                else
                    tw(Knob, {Position = UDim2.new(0, 2, 0.5, 0)}, 0.17, Enum.EasingStyle.Sine)
                end
                callback(toggled)
            end)
        end
function TabFunctions:ToggleButton(text, de, callback)

    local togdoc = { boolen = false }

    -- FIX: ขนาดให้เต็ม row เหมือน Toggle ปกติ
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = "ToggleFrame"
    ToggleFrame.Parent = Page
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Size = UDim2.new(1, -28, 0, 30)  -- FIX: เต็ม row

    -- FIX: ปุ่มหลักครอบพื้นที่ทั้ง row
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Parent = ToggleFrame
    ToggleButton.BackgroundTransparency = 1
    ToggleButton.Position = UDim2.new(0, 0, 0, 0)
    ToggleButton.Size = UDim2.new(1, 0, 1, 0)  -- FIX: เต็ม frame
    ToggleButton.Text = ""
    ToggleButton.BorderSizePixel = 0
    ToggleButton.AutoButtonColor = false
    ToggleButton.ClipsDescendants = false  -- FIX: อย่า clip ไม่งั้นลูกหาย

    -- Label ซ้าย
    local TextLabelToggle = Instance.new("TextLabel")
    TextLabelToggle.Parent = ToggleButton
    TextLabelToggle.BackgroundTransparency = 1
    TextLabelToggle.Position = UDim2.new(0, 4, 0, 0)
    TextLabelToggle.Size = UDim2.new(1, -50, 1, 0)
    TextLabelToggle.Font = Enum.Font.Gotham
    TextLabelToggle.Text = text or "Toggle"
    TextLabelToggle.TextColor3 = WT
    TextLabelToggle.TextSize = 11
    TextLabelToggle.TextXAlignment = Enum.TextXAlignment.Left

    local resizetext2 = Instance.new("UITextSizeConstraint", TextLabelToggle)
    resizetext2.MaxTextSize = 11

    -- FIX: กล่อง toggle อยู่ขวาสุด — parent ตรงที่ ToggleFrame ไม่ใช่ Button
    local ToggleBox = Instance.new("ImageButton")
    ToggleBox.Parent = ToggleFrame  -- FIX: parent = ToggleFrame
    ToggleBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    ToggleBox.BorderSizePixel = 0
    ToggleBox.AnchorPoint = Vector2.new(1, 0.5)  -- FIX: anchor ขวา
    ToggleBox.Position = UDim2.new(1, 0, 0.5, 0)  -- FIX: position ขวาสุด
    ToggleBox.Size = UDim2.new(0, 19, 0, 19)
    ToggleBox.AutoButtonColor = false
    ToggleBox.Image = ""

    local UIStroke_Toggle = Instance.new("UIStroke")
    UIStroke_Toggle.Parent = ToggleBox
    UIStroke_Toggle.Color = TH.ac
    UIStroke_Toggle.Thickness = 1

    Instance.new("UICorner", ToggleBox).CornerRadius = UDim.new(0, 4)

    -- indicator dot ตรงกลาง ToggleBox
    local Indicator = Instance.new("Frame")
    Indicator.Name = "ToggleIndicator"
    Indicator.Parent = ToggleBox
    Indicator.BackgroundColor3 = TH.ac
    Indicator.BorderSizePixel = 0
    Indicator.AnchorPoint = Vector2.new(0.5, 0.5)
    Indicator.Position = UDim2.new(0.49, 0, 0.49, 0)
    Indicator.Size = UDim2.new(0, 0, 0, 0)  -- hidden ตอนแรก

    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(0, 2)
    Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 4)

    -- theme
    onThemeChange(function(t)
        UIStroke_Toggle.Color = t.ac
         Indicator.BackgroundColor3 = t.ac
        if togdoc.boolen then
            Indicator.BackgroundColor3 = t.ac
        end
    end)

    local function doToggle()
        togdoc.boolen = not togdoc.boolen
        if togdoc.boolen then
            tw(Indicator, {Size = UDim2.new(0, 15, 0, 15)}, 0.17, Enum.EasingStyle.Sine)
        else
            tw(Indicator, {Size = UDim2.new(0, 0, 0, 0)}, 0.17, Enum.EasingStyle.Sine)
        end
        pcall(callback, togdoc.boolen)
    end

    ToggleBox.MouseButton1Click:Connect(doToggle)
    ToggleButton.MouseButton1Click:Connect(doToggle)

    if de == true then
        task.wait(0.1)
        doToggle()
    end
end

        -- ════════════════════════════════════════════════════════════
        --  FIXED SLIDER — Horizontally Aligned (Label | Value | Slider)
        -- ════════════════════════════════════════════════════════════
        function TabFunctions:Slider(label, mn, mx, val, callback)
            callback = callback or function() end
            local pct = math.clamp((val - mn) / (mx - mn), 0, 1)
            local dragging = false
            local UserInputService = game:GetService("UserInputService")

            local Wrap = Instance.new("Frame")
            Wrap.Name             = "Slider"
            Wrap.Parent           = Page
            Wrap.BackgroundTransparency = 1
            Wrap.BorderSizePixel  = 0
            Wrap.Size             = UDim2.new(1, -28, 0, 28)

            local WrapLayout = Instance.new("UIListLayout")
            WrapLayout.Parent              = Wrap
            WrapLayout.FillDirection       = Enum.FillDirection.Horizontal
            WrapLayout.SortOrder           = Enum.SortOrder.LayoutOrder
            WrapLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
            WrapLayout.Padding             = UDim.new(0, 8)

            local SLLb = Instance.new("TextLabel")
            SLLb.Parent               = Wrap
            SLLb.BackgroundTransparency = 1
            SLLb.Size                 = UDim2.new(0, 80, 0, 18)
            SLLb.LayoutOrder          = 1
            SLLb.Font                 = Enum.Font.Gotham
            SLLb.Text                 = label or "Slider"
            SLLb.TextColor3           = WT
            SLLb.TextSize             = 11
            SLLb.TextXAlignment       = Enum.TextXAlignment.Left
            SLLb.TextYAlignment       = Enum.TextYAlignment.Center

            -- Value display — TextBox พิมพ์ตัวเลขได้
            local curVal = math.round(val)
            local SLVal = Instance.new("TextBox")
            SLVal.Parent               = Wrap
            SLVal.BackgroundTransparency = 1
            SLVal.Size                 = UDim2.new(0, 36, 0, 18)
            SLVal.LayoutOrder          = 3
            SLVal.Font                 = Enum.Font.GothamBold
            SLVal.Text                 = tostring(curVal)
            SLVal.TextColor3           = TH.ac
            SLVal.TextSize             = 11
            SLVal.TextXAlignment       = Enum.TextXAlignment.Right
            SLVal.TextYAlignment       = Enum.TextYAlignment.Center
            SLVal.ClearTextOnFocus     = false

            -- Reset button (image)
            local ResetBtn = Instance.new("ImageButton")
            ResetBtn.Name = "ResetBtn"
            ResetBtn.Parent = Wrap
            ResetBtn.BackgroundTransparency = 1
            ResetBtn.BorderSizePixel = 0
            ResetBtn.Size = UDim2.new(0, 20, 0, 20)
            ResetBtn.LayoutOrder = 4
            ResetBtn.AutoButtonColor = false
            ResetBtn.Image = "rbxassetid://127886082324245" -- ใส่ asset id ที่ต้องการ
            ResetBtn.ImageColor3 = TH.su
            ResetBtn.ZIndex = 6

            local TrackWrap = Instance.new("Frame")
            TrackWrap.Parent               = Wrap
            TrackWrap.BackgroundTransparency = 1
            TrackWrap.Size                 = UDim2.new(1, -150, 0, 18)
            TrackWrap.LayoutOrder          = 2

            local SLTrack = Instance.new("TextButton")
            SLTrack.Parent           = TrackWrap
            SLTrack.AnchorPoint      = Vector2.new(0, 0.5)
            SLTrack.BackgroundColor3 = TH.sl
            SLTrack.BorderSizePixel  = 0
            SLTrack.Position         = UDim2.new(0, 0, 0.5, 0)
            SLTrack.Size             = UDim2.new(1, 0, 0, 5)
            SLTrack.AutoButtonColor  = false
            SLTrack.Text             = ""
            local _stc = Instance.new("UICorner"); _stc.CornerRadius = UDim.new(1, 0); _stc.Parent = SLTrack

            local SLFill = Instance.new("Frame")
            SLFill.Parent           = SLTrack
            SLFill.BackgroundColor3 = TH.ac
            SLFill.BorderSizePixel  = 0
            SLFill.Size             = UDim2.new(pct, 0, 1, 0)
            local _sfc = Instance.new("UICorner"); _sfc.CornerRadius = UDim.new(1, 0); _sfc.Parent = SLFill

            -- SLKnob as ImageButton (single element, no extra child button)
            local SLKnob = Instance.new("ImageButton")
            SLKnob.Parent           = SLTrack
            SLKnob.AnchorPoint      = Vector2.new(0.5, 0.5)
            SLKnob.BackgroundTransparency = 0
            SLKnob.Position         = UDim2.new(pct, 0, 0.5, 0) -- use pct, not fixed 0.5
            SLKnob.Size             = UDim2.new(0, 14, 0, 18)
            SLKnob.ZIndex           = 2
            SLKnob.AutoButtonColor  = false
            SLKnob.ScaleType        = Enum.ScaleType.Fit
            SLKnob.Image            = "rbxassetid://90932274644195"
            SLKnob.ImageColor3 = Color3.fromRGB(35, 35, 35)
            SLKnob.Active = true
            SLKnob.BackgroundColor3 = TH.ac

            local _skc = Instance.new("UICorner"); _skc.CornerRadius = UDim.new(0, 3); _skc.Parent = SLKnob
            local KnobStroke = Instance.new("UIStroke")
            KnobStroke.Parent    = SLKnob
            KnobStroke.Color     = TH.ac
            KnobStroke.Thickness = 2

            SLTrack.MouseEnter:Connect(function()
                if not dragging then tw(SLKnob, {Size = UDim2.new(0, 15, 0, 20)}, 0.12, Enum.EasingStyle.Sine) end
            end)
            SLTrack.MouseLeave:Connect(function()
                if not dragging then tw(SLKnob, {Size = UDim2.new(0, 14, 0, 18)}, 0.12, Enum.EasingStyle.Sine) end
            end)

            -- applyVal: tween fill & knob position, animate number, call callback
            local numAnimHandle
            local function stopNumAnim(handle) if handle and type(handle) == "table" then handle.stop = true end end
        local function applyVal(v, instant)
            v = math.clamp(math.round(v), mn, mx)
            local rel = (mx == mn) and 0 or (v - mn) / (mx - mn)

            if instant then
                -- 🔥 ตอนลาก = อัปเดตทันที (ไม่ tween)
                SLFill.Size = UDim2.new(rel, 0, 1, 0)
                SLKnob.Position = UDim2.new(rel, 0, 0.5, 0)
                SLVal.Text = tostring(v)

                curVal = v
                callback(v)
            else
                -- ✨ ตอนปล่อย = ค่อย tween ให้สวย
                tw(SLFill, {Size = UDim2.new(rel, 0, 1, 0)}, 0.15)
                tw(SLKnob, {Position = UDim2.new(rel, 0, 0.5, 0)}, 0.15)

                SLVal.Text = tostring(v)
                curVal = v
                callback(v)
            end
        end
            local function doSlide(inputX)
                local rel = math.clamp((inputX - SLTrack.AbsolutePosition.X) / SLTrack.AbsoluteSize.X, 0, 1)
                applyVal(mn + (mx - mn) * rel)
            end

            -- Dragging: support clicks on both track and knob (mouse + touch)
            local function startDrag(startX)
                dragging = true
                tw(SLKnob, {Size = UDim2.new(0, 15, 0, 20)}, 0.1)
                doSlide(startX)
            end
            local function stopDrag()
                dragging = false
                tw(SLKnob, {Size = UDim2.new(0, 14, 0, 18)}, 0.12, Enum.EasingStyle.Sine)
            end

            SLTrack.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    startDrag(inp.Position.X)
                end
            end)
            SLTrack.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    stopDrag()
                end
            end)

            SLKnob.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    startDrag(inp.Position.X)
                end
            end)
            SLKnob.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    stopDrag()
                end
            end)

            UserInputService.InputChanged:Connect(function(inp)
                if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                    local pos = inp.Position
                    if pos then doSlide(pos.X) end
                end
            end)

            -- SLVal filtering + apply on focus lost
            SLVal:GetPropertyChangedSignal("Text"):Connect(function()
                local filtered = SLVal.Text:gsub("[^%d%-]", "")
                if filtered ~= SLVal.Text then SLVal.Text = filtered end
            end)
            SLVal.FocusLost:Connect(function()
                local n = tonumber(SLVal.Text)
                if n then applyVal(n) else SLVal.Text = tostring(curVal) end
            end)

            -- Reset handlers (use ImageColor3)
            ResetBtn.MouseEnter:Connect(function() tw(ResetBtn, {ImageColor3 = TH.ac}, 0.12) end)
            ResetBtn.MouseLeave:Connect(function() tw(ResetBtn, {ImageColor3 = TH.su}, 0.12) end)
            ResetBtn.MouseButton1Click:Connect(function()
                applyVal(val) -- กลับไปค่าเริ่มต้น param val
                tw(ResetBtn, {ImageColor3 = TH.ac}, 0.08)
                task.delay(0.3, function() tw(ResetBtn, {ImageColor3 = TH.su}, 0.2) end)
            end)

            onThemeChange(function(t)
                tw(SLLb,       {TextColor3 = t.su}, 0.22)
                tw(SLVal,      {TextColor3 = t.ac}, 0.22)
                tw(ResetBtn,   {ImageColor3 = t.su}, 0.22)
                tw(SLTrack,    {BackgroundColor3 = t.sl}, 0.22)
                tw(SLFill,     {BackgroundColor3 = t.ac}, 0.22)
                tw(KnobStroke, {Color = t.ac}, 0.22)
                tw(SLKnob, {ImageColor3 = t.su}, 0.22)
                            SLKnob.BackgroundColor3 = t.ac

            end)

            -- init UI to starting value
            applyVal(curVal)
        end
        -- Button
function TabFunctions:Button(label, callback)
    callback = callback or function() end

    -- Outer wrapper สำหรับ clip ripple
    local BtnWrap = Instance.new("Frame")
    BtnWrap.Name             = "ButtonWrap"
    BtnWrap.Parent           = Page
    BtnWrap.BackgroundTransparency = 1
    BtnWrap.BorderSizePixel  = 0
    BtnWrap.Size             = UDim2.new(1,-28,0,28)
    BtnWrap.ClipsDescendants = true

    local Btn = Instance.new("TextButton")
    Btn.Name             = "Button"
    Btn.Parent           = BtnWrap
    Btn.BackgroundColor3 = TH.cd       -- สีพื้นหลังปกติ (เข้มกว่าเดิม)
    Btn.BorderSizePixel  = 0
    Btn.Size             = UDim2.new(1,0,1,0)
    Btn.AutoButtonColor  = false
    Btn.Font             = Enum.Font.GothamBold
    Btn.Text             = label or "Button"
    Btn.TextColor3       = TH.ac
    Btn.TextSize         = 11
    Btn.ZIndex           = 2
    local _bc = Instance.new("UICorner"); _bc.CornerRadius = UDim.new(0,7); _bc.Parent = Btn

    -- Stroke (border) ที่ animate ได้
    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Parent      = Btn
    BtnStroke.Color       = TH.br
    BtnStroke.Thickness   = 1
    BtnStroke.Transparency = 0

    -- Shimmer layer — เส้นแสงวิ่งจากซ้ายไปขวาตอน hover
    local Shimmer = Instance.new("Frame")
    Shimmer.Parent               = Btn
    Shimmer.BackgroundColor3     = Color3.new(1,1,1)
    Shimmer.BackgroundTransparency = 1
    Shimmer.BorderSizePixel      = 0
    Shimmer.Position             = UDim2.new(-0.3,0,0,0)
    Shimmer.Size                 = UDim2.new(0.3,0,1,0)
    Shimmer.ZIndex               = 3
    Shimmer.Rotation             = 15
    local _shc = Instance.new("UICorner"); _shc.CornerRadius = UDim.new(0,7); _shc.Parent = Shimmer

    -- Glow dot — จุดสีใต้ปุ่มตอน press
    local Glow = Instance.new("Frame")
    Glow.Parent               = Btn
    Glow.AnchorPoint          = Vector2.new(0.5,0.5)
    Glow.BackgroundColor3     = TH.ac
    Glow.BackgroundTransparency = 1
    Glow.BorderSizePixel      = 0
    Glow.Position             = UDim2.new(0.5,0,0.5,0)
    Glow.Size                 = UDim2.new(0,0,0,0)
    Glow.ZIndex               = 1
    local _gwc = Instance.new("UICorner"); _gwc.CornerRadius = UDim.new(1,0); _gwc.Parent = Glow

    -- ── ฟังก์ชัน shimmer วิ่งครั้งเดียว ────────────────────
    local function playShimmer()
        Shimmer.BackgroundTransparency = 0.72
        Shimmer.Position = UDim2.new(-0.35,0,0,0)
        tw(Shimmer, {Position = UDim2.new(1.1,0,0,0), BackgroundTransparency = 0.88}, 0.52, Enum.EasingStyle.Sine)
        task.delay(0.54, function()
            Shimmer.BackgroundTransparency = 1
            Shimmer.Position = UDim2.new(-0.35,0,0,0)
        end)
    end

    -- ── ฟังก์ชัน ripple expand จากจุดกด ───────────────────
    local function playRipple()
        Glow.BackgroundTransparency = 0.55
        Glow.Size = UDim2.new(0,0,0,0)
        tw(Glow, {
            Size                 = UDim2.new(2,0,4,0),
            BackgroundTransparency = 1,
        }, 0.45, Enum.EasingStyle.Quad)
    end

    local hovered = false

    -- ── Hover Enter ──────────────────────────────────────
    Btn.MouseEnter:Connect(function()
        hovered = true
        -- border สว่างขึ้น
        tw(BtnStroke, {Color = TH.ac, Thickness = 1.5}, 0.18, Enum.EasingStyle.Sine)
        -- ข้อความขยับขึ้นเล็กน้อย (letter-spacing เทียบเท่าไม่มีใน Roblox ใช้ offset แทน)
        tw(Btn, {TextColor3 = WT, BackgroundColor3 = TH.dk}, 0.18, Enum.EasingStyle.Sine)
        -- shimmer วิ่งผ่าน
        playShimmer()
    end)

    -- ── Hover Leave ──────────────────────────────────────
    Btn.MouseLeave:Connect(function()
        hovered = false
        tw(BtnStroke, {Color = TH.br, Thickness = 1}, 0.22, Enum.EasingStyle.Sine)
        tw(Btn, {TextColor3 = TH.ac, BackgroundColor3 = TH.cd}, 0.22, Enum.EasingStyle.Sine)
    end)

    -- ── Press Down — squish + ripple ──────────────────────
    Btn.MouseButton1Down:Connect(function()
        -- squish กดลง
        tw(BtnWrap, {Size = UDim2.new(1,-28,0,24)}, 0.09, Enum.EasingStyle.Sine)
        tw(Btn, {BackgroundColor3 = TH.ac}, 0.09, Enum.EasingStyle.Sine)
        tw(Btn, {TextColor3 = Color3.new(1,1,1)}, 0.09)
        BtnStroke.Color = TH.ac
        playRipple()
    end)

    -- ── Click Release — spring กลับ ───────────────────────
    Btn.MouseButton1Click:Connect(function()
        -- spring กระเด้งกลับ
        tw(BtnWrap, {Size = UDim2.new(1,-28,0,30)}, 0.08, Enum.EasingStyle.Back)
        task.delay(0.08, function()
            tw(BtnWrap, {Size = UDim2.new(1,-28,0,28)}, 0.14, Enum.EasingStyle.Bounce)
        end)
        -- กลับสีหลัง hover
        if hovered then
            tw(Btn, {BackgroundColor3 = TH.dk, TextColor3 = WT}, 0.18)
            tw(BtnStroke, {Color = TH.ac, Thickness = 1.5}, 0.18)
        else
            tw(Btn, {BackgroundColor3 = TH.cd, TextColor3 = TH.ac}, 0.18)
            tw(BtnStroke, {Color = TH.br, Thickness = 1}, 0.18)
        end
        callback()
    end)

    -- ── Theme Registry ───────────────────────────────────
    onThemeChange(function(t)
        if not hovered then
            tw(Btn,      {BackgroundColor3 = t.cd, TextColor3 = t.ac}, 0.22)
            BtnStroke.Color = t.br
        end
        Glow.BackgroundColor3 = t.ac
    end)
end

        -- Keybind
        function TabFunctions:Keybind(name, keyPreset, callback)
            callback = callback or function() end
            local key = (keyPreset and keyPreset.Name) or "E"

            local Row = Instance.new("Frame")
            Row.Name             = "Keybind"
            Row.Parent           = Page
            Row.BackgroundTransparency = 1
            Row.BorderSizePixel  = 0
            Row.Size             = UDim2.new(1,-28,0,30)

            local Lb = Instance.new("TextLabel")
            Lb.Parent               = Row
            Lb.BackgroundTransparency = 1
            Lb.Position             = UDim2.new(0,4,0,0)
            Lb.Size                 = UDim2.new(1,-54,1,0)
            Lb.Font                 = Enum.Font.Gotham
            Lb.Text                 = name or "Keybind"
            Lb.TextColor3           = WT
            Lb.TextSize             = 11
            Lb.TextXAlignment       = Enum.TextXAlignment.Left

            local Badge = Instance.new("TextButton")
            Badge.Parent           = Row
            Badge.AnchorPoint      = Vector2.new(1,0.5)
            Badge.BackgroundColor3 = TH.sl
            Badge.BorderSizePixel  = 0
            Badge.Position         = UDim2.new(1,0,0.5,0)
            Badge.Size             = UDim2.new(0,44,0,20)
            Badge.AutoButtonColor  = false
            Badge.Font             = Enum.Font.GothamBold
            Badge.Text             = key
            Badge.TextColor3       = WT
            Badge.TextSize         = 11
            local _bdc = Instance.new("UICorner"); _bdc.CornerRadius = UDim.new(0,4); _bdc.Parent = Badge

            local binding = false
            Badge.MouseButton1Click:Connect(function()
                if binding then return end
                binding = true
                Badge.Text = "..."
                Badge.TextColor3 = TH.su
                local conn
                conn = UserInputService.InputBegan:Connect(function(inp, gpe)
                    if gpe then return end
                    if inp.KeyCode ~= Enum.KeyCode.Unknown then
                        key = inp.KeyCode.Name
                        Badge.Text = key
                        Badge.TextColor3 = WT
                        binding = false
                        conn:Disconnect()
                    end
                end)
            end)

            UserInputService.InputBegan:Connect(function(inp, gpe)
                if not gpe and inp.KeyCode.Name == key then callback(key) end
            end)

            onThemeChange(function(t)
                tw(Badge, {BackgroundColor3 = t.sl}, 0.22)
            end)
        end
-- Single Dropdown (ปรับให้ selected ไม่ถูก override โดยธีม)
function TabFunctions:Single(label, opts, default, callback)
    opts     = opts or {}
    callback = callback or function() end
    local curSel = default or opts[1]
    local open   = false

    local Wrap = Instance.new("Frame")
    Wrap.Name             = "Single"
    Wrap.Parent           = Page
    Wrap.BackgroundTransparency = 1
    Wrap.BorderSizePixel  = 0
    Wrap.Size             = UDim2.new(1,-29,0,20+35)
    Wrap.ClipsDescendants = true

    local DLb = Instance.new("TextLabel")
    DLb.Parent               = Wrap
    DLb.BackgroundTransparency = 1
    DLb.Position             = UDim2.new(0,2,0,3)
    DLb.Size                 = UDim2.new(1,0,0,14)
    DLb.Font                 = Enum.Font.Gotham
    DLb.Text                 = label or "Single"
    DLb.TextColor3           = WT
    DLb.TextSize             = 10
    DLb.TextXAlignment       = Enum.TextXAlignment.Left

    local DBtn = Instance.new("Frame")
    DBtn.Name             = "DBtn"
    DBtn.Parent           = Wrap
    DBtn.BackgroundColor3 = TH.cd
    DBtn.BorderSizePixel  = 0
    DBtn.Position         = UDim2.new(0,1,0,18)
    DBtn.Size             = UDim2.new(0.99,0,0,30)
    DBtn.AutomaticSize    = Enum.AutomaticSize.Y
    local _dbc = Instance.new("UICorner"); _dbc.CornerRadius = UDim.new(0,6); _dbc.Parent = DBtn
    local DBtnStroke = Instance.new("UIStroke")
    DBtnStroke.Parent    = DBtn
    DBtnStroke.Color     = TH.br
    DBtnStroke.Thickness = 1
            onThemeChange(function(t)
                tw(DBtnStroke, {Color = open and t.ac or t.br}, 0.22)
            end)    local TagsFrame = Instance.new("Frame")
    TagsFrame.Parent               = DBtn
    TagsFrame.BackgroundTransparency = 1
    TagsFrame.Position             = UDim2.new(0,8,0,5)
    TagsFrame.Size                 = UDim2.new(1,-30,0,20)
    TagsFrame.AutomaticSize        = Enum.AutomaticSize.Y
    local TagsLayout = Instance.new("UIListLayout")
    TagsLayout.Parent              = TagsFrame
    TagsLayout.FillDirection       = Enum.FillDirection.Horizontal
    TagsLayout.SortOrder           = Enum.SortOrder.LayoutOrder
    TagsLayout.Padding             = UDim.new(0,3)
    TagsLayout.Wraps               = true
    TagsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

    local DArrow = Instance.new("ImageLabel")
    DArrow.Parent             = DBtn
    DArrow.AnchorPoint        = Vector2.new(0.5,0.5)
    DArrow.Position           = UDim2.new(1,-16,0.5,0)
    DArrow.Size               = UDim2.new(0,16,0,16)
    DArrow.Image              = "rbxassetid://71063555855798"
    DArrow.Rotation           = 0
    DArrow.BackgroundTransparency = 1

    local optEls = {}

    local function clearAll()
        for _, el in ipairs(optEls) do
            el.selected = false
            tw(el.radio, {BackgroundColor3 = TH.sl}, 0.13)
            el.radioStroke.Color     = TH.br
            el.radioDot.TextTransparency = 1
            tw(el.otx, {TextColor3 = TH.su}, 0.12)
            el.btn.BackgroundTransparency = 1
            el.xbtn.Visible          = false
        end
    end

    local DList = Instance.new("Frame")
    DList.Name             = "DList"
    DList.Parent           = Wrap
    DList.BackgroundColor3 = TH.cd
    DList.BorderSizePixel  = 0
    DList.Position         = UDim2.new(0,1,0,19+30+2)
    DList.Size             = UDim2.new(1,0,0,0)
    DList.ClipsDescendants = true
    local _dlc = Instance.new("UICorner"); _dlc.CornerRadius = UDim.new(0,6); _dlc.Parent = DList
    local DListStroke = Instance.new("UIStroke")
    DListStroke.Parent       = DList
    DListStroke.Color        = TH.br
    DListStroke.Thickness    = 1
    DListStroke.Transparency = 1
    onThemeChange(function(t)
        tw(DListStroke, {BackgroundColor3 = t.br}, 0.22)
    end)
    local DListLayout = Instance.new("UIListLayout")
    DListLayout.Parent    = DList
    DListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function closeDropdown()
        open = false
        DBtnStroke.Color     = TH.br
        tw(DArrow, {Rotation = 0}, 0.2)
        DListStroke.Transparency = 1
        DList:TweenSize(UDim2.new(1,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
        Wrap:TweenSize(UDim2.new(1,-29,0,20+35), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
    end

    local function rft()
        for _, c in ipairs(TagsFrame:GetChildren()) do
            if not c:IsA("UIListLayout") then c:Destroy() end
        end
        if curSel and curSel ~= "" then
            local TW = Instance.new("Frame")
            TW.Parent           = TagsFrame
            TW.BackgroundColor3 = TH.dk
            TW.BorderSizePixel  = 0
            TW.AutomaticSize    = Enum.AutomaticSize.X
            TW.Size             = UDim2.new(0,0,0,18)
            local _twc = Instance.new("UICorner"); _twc.CornerRadius = UDim.new(0,4); _twc.Parent = TW
            local _twl = Instance.new("UIListLayout")
            _twl.Parent            = TW
            _twl.FillDirection     = Enum.FillDirection.Horizontal
            _twl.SortOrder         = Enum.SortOrder.LayoutOrder
            _twl.VerticalAlignment = Enum.VerticalAlignment.Center
            _twl.Padding           = UDim.new(0,2)
            local TagTx = Instance.new("TextLabel")
            TagTx.Parent               = TW
            TagTx.LayoutOrder          = 1
            TagTx.BackgroundTransparency = 1
            TagTx.AutomaticSize        = Enum.AutomaticSize.X
            TagTx.Size                 = UDim2.new(0,0,1,0)
            TagTx.Font                 = Enum.Font.GothamBold
            TagTx.Text                 = " "..curSel
            TagTx.TextColor3           = TH.ac
            TagTx.TextSize             = 10
            local Pad = Instance.new("Frame")
            Pad.Parent               = TW
            Pad.LayoutOrder          = 3
            Pad.BackgroundTransparency = 1
            Pad.Size                 = UDim2.new(0,3,1,0)
            onThemeChange(function(t)
                tw(TW, {BackgroundColor3 = t.dk}, 0.22)
                tw(TagTx, {TextColor3 = t.ac}, 0.22)
            end)
        else
            local E = Instance.new("TextLabel")
            E.Parent               = TagsFrame
            E.BackgroundTransparency = 1
            E.Size                 = UDim2.new(0,0,0,18)
            E.Font                 = Enum.Font.Gotham
            E.Text                 = "    —"
            E.TextColor3           = TH.su
            E.TextSize             = 11
        end
    end

    rft()

    local DBtnClick = Instance.new("TextButton")
    DBtnClick.Parent               = DBtn
    DBtnClick.BackgroundTransparency = 1
    DBtnClick.BorderSizePixel      = 0
    DBtnClick.Size                 = UDim2.new(1,0,1,0)
    DBtnClick.Text                 = ""
    DBtnClick.AutoButtonColor      = false
    DBtnClick.ZIndex               = 5

    local fh = #opts * 28 + 6

    for _, opt in ipairs(opts) do
        local Item = Instance.new("TextButton")
        Item.Parent                 = DList
        Item.BackgroundColor3       = TH.ac
        Item.BackgroundTransparency = opt == curSel and 0.88 or 1
        Item.BorderSizePixel        = 0
        Item.Size                   = UDim2.new(1,0,0,28)
        Item.AutoButtonColor        = false
        Item.Text                   = ""
        local _ic2 = Instance.new("UICorner"); _ic2.CornerRadius = UDim.new(0,5); _ic2.Parent = Item
                        onThemeChange(function(t)
                            tw(Item, {BackgroundColor3 = t.ac}, 0.22)
                        end)
        local Radio = Instance.new("Frame")
        Radio.Parent           = Item
        Radio.AnchorPoint      = Vector2.new(0,0.5)
        Radio.BackgroundColor3 = opt == curSel and TH.ac or TH.sl
        Radio.BorderSizePixel  = 0
        Radio.Position         = UDim2.new(0,10,0.5,0)
        Radio.Size             = UDim2.new(0,13,0,13)
        local _rac = Instance.new("UICorner"); _rac.CornerRadius = UDim.new(0,3); _rac.Parent = Radio
        local RadioStroke = Instance.new("UIStroke")
        RadioStroke.Parent    = Radio
        RadioStroke.Color     = opt == curSel and TH.ac or TH.br
        RadioStroke.Thickness = 1.5
        local RadioDot = Instance.new("TextLabel")
        RadioDot.Parent               = Radio
        RadioDot.BackgroundTransparency = 1
        RadioDot.Size                 = UDim2.new(1,0,1,0)
        RadioDot.Font                 = Enum.Font.GothamBold
        RadioDot.Text                 = "✓"
        RadioDot.TextColor3           = Color3.new(1,1,1)
        RadioDot.TextSize             = 9
        RadioDot.TextTransparency     = opt == curSel and 0 or 1

        local OTx = Instance.new("TextLabel")
        OTx.Parent               = Item
        OTx.BackgroundTransparency = 1
        OTx.Position             = UDim2.new(0,30,0,0)
        OTx.Size                 = UDim2.new(1,-56,1,0)
        OTx.Font                 = Enum.Font.Gotham
        OTx.Text                 = opt
        OTx.TextColor3           = opt == curSel and WT or TH.su
        OTx.TextSize             = 11
        OTx.TextXAlignment       = Enum.TextXAlignment.Left

        local XBtn = Instance.new("ImageButton")
        XBtn.Parent               = Item
        XBtn.BackgroundTransparency = 1
        XBtn.BorderSizePixel      = 0
        XBtn.AnchorPoint          = Vector2.new(1,0.5)
        XBtn.Position             = UDim2.new(1,-6,0.5,0)
        XBtn.Size                 = UDim2.new(0,18,0,18)
        XBtn.Image                = "rbxassetid://107560529463028"
        XBtn.ImageColor3          = TH.su
        XBtn.AutoButtonColor      = false
        XBtn.ZIndex               = 10
        XBtn.Visible              = opt == curSel

        XBtn.MouseEnter:Connect(function() XBtn.ImageColor3 = Color3.fromRGB(240,60,60) end)
        XBtn.MouseLeave:Connect(function() XBtn.ImageColor3 = TH.su end)
        XBtn.MouseButton1Click:Connect(function()
            curSel = ""
            clearAll()
            rft()
            callback("")
        end)

        -- เก็บ element และสถานะ selected
        local el = {
            btn = Item,
            radio = Radio,
            radioStroke = RadioStroke,
            radioDot = RadioDot,
            otx = OTx,
            xbtn = XBtn,
            selected = (opt == curSel)
        }
        table.insert(optEls, el)

        -- event handlers (ใช้ el เพื่อให้สถานะถูกต้อง)
        Item.MouseEnter:Connect(function()
            if not el.selected then tw(Item,{BackgroundTransparency=0.94},0.12) end
        end)
        Item.MouseLeave:Connect(function()
            if not el.selected then tw(Item,{BackgroundTransparency=1},0.12) end
        end)
        Item.MouseButton1Click:Connect(function()
            clearAll()
            curSel = opt
            -- ตั้งสถานะเป็น selected สำหรับ el นี้
            el.selected = true

            tw(el.radio, {BackgroundColor3 = TH.ac}, 0.13)
            el.radioStroke.Color        = TH.ac
            el.radioDot.TextTransparency = 0
            tw(el.otx,  {TextColor3 = WT}, 0.12)
            el.btn.BackgroundTransparency = 0.88
            el.xbtn.Visible             = true
            rft()
            callback(opt)
            closeDropdown()
        end)
    end

    DBtnClick.MouseButton1Click:Connect(function()
        open = not open
        tw(DArrow, {Rotation = open and 180 or 0}, 0.2)
        DBtnStroke.Color         = open and TH.ac or TH.br
        DListStroke.Transparency = open and 0 or 1
        if open then
            Wrap:TweenSize(UDim2.new(1,-29,0,20+35+2+fh), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
            DList:TweenSize(UDim2.new(0.99,0,0,fh), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
        else
            DList:TweenSize(UDim2.new(0.99,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
            Wrap:TweenSize(UDim2.new(1,-29,0,20+35), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
        end
    end)

    onThemeChange(function(t)
        tw(DLb,   {TextColor3 = t.su},       0.22)
        tw(DBtn,  {BackgroundColor3 = t.cd},  0.22)
        tw(DList, {BackgroundColor3 = t.cd},  0.22)
        DBtnStroke.Color  = open and t.ac or t.br
        DListStroke.Color = t.br
        for _, el in ipairs(optEls) do
            if el.selected then
                -- ถ้า selected ให้คงสี selected (ac / WT)
                tw(el.radio, {BackgroundColor3 = t.ac}, 0.22)
                el.radioStroke.Color = t.ac
                tw(el.otx, {TextColor3 = WT}, 0.22)
            else
                -- ถ้าไม่ selected ให้ใช้สีปกติของธีม
                tw(el.radio, {BackgroundColor3 = t.sl}, 0.22)
                el.radioStroke.Color = t.br
                tw(el.otx, {TextColor3 = t.su}, 0.22)
            end
        end
    end)
end

        -- Multi Dropdown
        function TabFunctions:Multi(label, opts, defaults, callback)
            opts     = opts or {}
            defaults = defaults or {}
            callback = callback or function() end
            local selected = {}
            for _, v in ipairs(defaults) do selected[v] = true end
            local open = false

            local Wrap = Instance.new("Frame")
            Wrap.Name             = "Multi"
            Wrap.Parent           = Page
            Wrap.BackgroundTransparency = 1
            Wrap.BorderSizePixel  = 0
            Wrap.Size             = UDim2.new(1,-29,0,20+35)
            Wrap.ClipsDescendants = true

            local DLb = Instance.new("TextLabel")
            DLb.Parent               = Wrap
            DLb.BackgroundTransparency = 1
            DLb.Position             = UDim2.new(0,2,0,3)
            DLb.Size                 = UDim2.new(1,0,0,14)
            DLb.Font                 = Enum.Font.Gotham
            DLb.Text                 = label or "Multi"
            DLb.TextColor3           = WT
            DLb.TextSize             = 10
            DLb.TextXAlignment       = Enum.TextXAlignment.Left

            local DBtn = Instance.new("Frame")
            DBtn.Parent           = Wrap
            DBtn.BackgroundColor3 = TH.cd
            DBtn.BorderSizePixel  = 0
            DBtn.Position         = UDim2.new(0,1,0,18)
            DBtn.Size             = UDim2.new(0.99,0,0,30)
            DBtn.AutomaticSize    = Enum.AutomaticSize.Y
            local _dbc2 = Instance.new("UICorner"); _dbc2.CornerRadius = UDim.new(0,6); _dbc2.Parent = DBtn
            local DBtnStroke2 = Instance.new("UIStroke")
            DBtnStroke2.Parent    = DBtn
            DBtnStroke2.Color     = TH.br
            DBtnStroke2.Thickness = 1
            onThemeChange(function(t)
                tw(DBtnStroke2, {Color = open and t.ac or t.br}, 0.22)
            end)
            local TagsFrame2 = Instance.new("Frame")
            TagsFrame2.Parent               = DBtn
            TagsFrame2.BackgroundTransparency = 1
            TagsFrame2.Position             = UDim2.new(0,8,0,5)
            TagsFrame2.Size                 = UDim2.new(1,-30,0,20)
            TagsFrame2.AutomaticSize        = Enum.AutomaticSize.Y
            local TFL2 = Instance.new("UIListLayout")
            TFL2.Parent              = TagsFrame2
            TFL2.FillDirection       = Enum.FillDirection.Horizontal
            TFL2.SortOrder           = Enum.SortOrder.LayoutOrder
            TFL2.Padding             = UDim.new(0,3)
            TFL2.Wraps               = true
            TFL2.HorizontalAlignment = Enum.HorizontalAlignment.Left

            local DArrow2 = Instance.new("ImageLabel")
            DArrow2.Parent             = DBtn
            DArrow2.AnchorPoint        = Vector2.new(0.5,0.5)
            DArrow2.Position           = UDim2.new(1,-16,0.5,0)
            DArrow2.Size               = UDim2.new(0,16,0,16)
            DArrow2.Image              = "rbxassetid://71063555855798"
            DArrow2.BackgroundTransparency = 1

            local DList2 = Instance.new("Frame")
            DList2.Parent           = Wrap
            DList2.BackgroundColor3 = TH.cd
            DList2.BorderSizePixel  = 0
            DList2.Position         = UDim2.new(0,1,0,19+30+2)
            DList2.Size             = UDim2.new(1,0,0,0)
            DList2.ClipsDescendants = true
            local _dlc2 = Instance.new("UICorner"); _dlc2.CornerRadius = UDim.new(0,6); _dlc2.Parent = DList2
            local DListStroke2 = Instance.new("UIStroke")
            DListStroke2.Parent       = DList2
            DListStroke2.Color        = TH.br
            DListStroke2.Thickness    = 1
            DListStroke2.Transparency = 1

            local DListLayout2 = Instance.new("UIListLayout")
            DListLayout2.Parent    = DList2
            DListLayout2.SortOrder = Enum.SortOrder.LayoutOrder

            local chkEls = {}

            local function fireCallback()
                local t = {}
                for k in pairs(selected) do t[#t+1] = k end
                callback(t)
            end

            local function rebuildTags()
                for _, c in ipairs(TagsFrame2:GetChildren()) do
                    if not c:IsA("UIListLayout") then c:Destroy() end
                end
                local any = false
                for _, opt in ipairs(opts) do
                    if selected[opt] then
                        any = true
                        local TW = Instance.new("Frame")
                        TW.Parent           = TagsFrame2
                        TW.BackgroundColor3 = TH.dk
                        TW.BorderSizePixel  = 0
                        TW.AutomaticSize    = Enum.AutomaticSize.X
                        TW.Size             = UDim2.new(0,0,0,18)


                        local _twc = Instance.new("UICorner"); _twc.CornerRadius = UDim.new(0,4); _twc.Parent = TW
                        local _twl = Instance.new("UIListLayout")
                        _twl.Parent            = TW
                        _twl.FillDirection     = Enum.FillDirection.Horizontal
                        _twl.SortOrder         = Enum.SortOrder.LayoutOrder
                        _twl.VerticalAlignment = Enum.VerticalAlignment.Center
                        _twl.Padding           = UDim.new(0,2)
                        local TagTx = Instance.new("TextLabel")
                        TagTx.Parent               = TW
                        TagTx.LayoutOrder          = 1
                        TagTx.BackgroundTransparency = 1
                        TagTx.AutomaticSize        = Enum.AutomaticSize.X
                        TagTx.Size                 = UDim2.new(0,0,1,0)
                        TagTx.Font                 = Enum.Font.GothamBold
                        TagTx.Text                 = " "..opt
                        TagTx.TextColor3           = TH.ac
                        TagTx.TextSize             = 10
                        onThemeChange(function(t)
                            tw(TW, {BackgroundColor3 = t.dk}, 0.22)
                            tw(TagTx, {TextColor3 = t.ac}, 0.22)
                        end)
                        local Pad = Instance.new("Frame")

                        Pad.Parent               = TW
                        Pad.LayoutOrder          = 3
                        Pad.BackgroundTransparency = 1
                        Pad.Size                 = UDim2.new(0,3,1,0)
                    end
                end
                if not any then
                    local E = Instance.new("TextLabel")
                    E.Parent               = TagsFrame2
                    E.BackgroundTransparency = 1
                    E.Size                 = UDim2.new(0,0,0,18)
                    E.Font                 = Enum.Font.Gotham
                    E.Text                 = "    —"
                    E.TextColor3           = TH.su
                    E.TextSize             = 11
                end
            end

            rebuildTags()

            local DBtnClick2 = Instance.new("TextButton")
            DBtnClick2.Parent               = DBtn
            DBtnClick2.BackgroundTransparency = 1
            DBtnClick2.BorderSizePixel      = 0
            DBtnClick2.Size                 = UDim2.new(1,0,1,0)
            DBtnClick2.Text                 = ""
            DBtnClick2.AutoButtonColor      = false
            DBtnClick2.ZIndex               = 5

            local fh2 = #opts * 28 + 6

            for _, opt in ipairs(opts) do
                local Item = Instance.new("TextButton")
                Item.Parent                 = DList2
                Item.BackgroundColor3       = TH.ac
                Item.BackgroundTransparency = selected[opt] and 0.88 or 1
                Item.BorderSizePixel        = 0
                Item.Size                   = UDim2.new(1,0,0,28)
                Item.AutoButtonColor        = false
                Item.Text                   = ""

                local _ic3 = Instance.new("UICorner"); _ic3.CornerRadius = UDim.new(0,5); _ic3.Parent = Item

                local ChkBox = Instance.new("Frame")
                ChkBox.Parent           = Item
                ChkBox.AnchorPoint      = Vector2.new(0,0.5)
                ChkBox.BackgroundColor3 = selected[opt] and TH.ac or TH.sl
                ChkBox.BorderSizePixel  = 0
                ChkBox.Position         = UDim2.new(0,10,0.5,0)
                ChkBox.Size             = UDim2.new(0,13,0,13)

                local _cbc = Instance.new("UICorner"); _cbc.CornerRadius = UDim.new(0,3); _cbc.Parent = ChkBox
                local ChkStroke = Instance.new("UIStroke")
                ChkStroke.Parent    = ChkBox
                ChkStroke.Color     = selected[opt] and TH.ac or TH.br
                ChkStroke.Thickness = 1.5

                local ChkDot = Instance.new("TextLabel")
                ChkDot.Parent               = ChkBox
                ChkDot.BackgroundTransparency = 1
                ChkDot.Size                 = UDim2.new(1,0,1,0)
                ChkDot.Font                 = Enum.Font.GothamBold
                ChkDot.Text                 = "✓"
                ChkDot.TextColor3           = Color3.new(1,1,1)
                ChkDot.TextSize             = 9
                ChkDot.TextTransparency     = selected[opt] and 0 or 1
                        onThemeChange(function(t)
                            tw(Item, {BackgroundColor3 = t.dk}, 0.22)
                            tw(ChkBox, {BackgroundColor3 = selected[opt] and t.ac or t.sl}, 0.22)
                            tw(ChkStroke, {Color = selected[opt] and t.ac or t.br}, 0.22)
                        end)
                local OTx = Instance.new("TextLabel")
                OTx.Parent               = Item
                OTx.BackgroundTransparency = 1
                OTx.Position             = UDim2.new(0,30,0,0)
                OTx.Size                 = UDim2.new(1,-36,1,0)
                OTx.Font                 = Enum.Font.Gotham
                OTx.Text                 = opt
                OTx.TextColor3           = selected[opt] and WT or TH.su
                OTx.TextSize             = 11
                OTx.TextXAlignment       = Enum.TextXAlignment.Left

                table.insert(chkEls, {box=ChkBox, stroke=ChkStroke, dot=ChkDot, otx=OTx, opt=opt})

                Item.MouseEnter:Connect(function()
                    if not selected[opt] then tw(Item,{BackgroundTransparency=0.94},0.12) end
                end)
                Item.MouseLeave:Connect(function()
                    if not selected[opt] then tw(Item,{BackgroundTransparency=1},0.12) end
                end)

                Item.MouseButton1Click:Connect(function()
                    selected[opt] = not selected[opt]
                    local on2 = selected[opt]
                    tw(ChkBox, {BackgroundColor3 = on2 and TH.ac or TH.sl}, 0.13)
                    ChkStroke.Color         = on2 and TH.ac or TH.br
                    ChkDot.TextTransparency = on2 and 0 or 1
                    tw(OTx, {TextColor3 = on2 and WT or TH.su}, 0.12)
                    Item.BackgroundTransparency = on2 and 0.88 or 1
                    rebuildTags()
                    fireCallback()
                end)
            end

            local q = 0.99
            DBtnClick2.MouseButton1Click:Connect(function()
                open = not open
                tw(DArrow2, {Rotation = open and 180 or 0}, 0.2)
                DBtnStroke2.Color        = open and TH.ac or TH.br
                DListStroke2.Transparency = open and 0 or 1
                if open then
                    Wrap:TweenSize(UDim2.new(1,-29,0,20+35+2+fh2), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
                    DList2:TweenSize(UDim2.new(q,0,0,fh2), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
                else
                    DList2:TweenSize(UDim2.new(q,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
                    Wrap:TweenSize(UDim2.new(1,-29,0,20+35), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
                end
            end)

            onThemeChange(function(t)
                tw(DLb,   {TextColor3 = t.su},      0.22)
                tw(DBtn,  {BackgroundColor3 = t.cd}, 0.22)
                tw(DList2,{BackgroundColor3 = t.cd}, 0.22)
                tw(Item, {BackgroundColor3 = t.ac}, 0.22)
                DBtnStroke2.Color  = open and t.ac or t.br
                DListStroke2.Color = t.br
                for _, el in ipairs(chkEls) do
                    local on2 = selected[el.opt]
                    tw(el.box, {BackgroundColor3 = on2 and t.ac or t.sl}, 0.22)
                    el.stroke.Color = on2 and t.ac or t.br
                end
            end)
        end

        -- ════════════════════════════════════════════════════════════
        --  FIXED ColorPicker — with CurrentColor, tween, debug prints
        -- ════════════════════════════════════════════════════════════
        function TabFunctions:ColorPicker(label, initColor, callback)
            callback  = callback or function() end
            initColor = initColor or Color3.fromRGB(255,80,50)

            -- Track current color in a dedicated variable
            local CurrentColor = initColor
            local h, s, v = color3ToHsv(initColor)
            local pickerOpen = false

            local Row = Instance.new("Frame")
            Row.Name             = "ColorPicker"
            Row.Parent           = Page
            Row.BackgroundTransparency = 1
            Row.BorderSizePixel  = 0
            Row.Size             = UDim2.new(1,-28,0,30)
            Row.ClipsDescendants = true

            local RowLb = Instance.new("TextLabel")
            RowLb.Parent               = Row
            RowLb.BackgroundTransparency = 1
            RowLb.Position             = UDim2.new(0,4,0,0)
            RowLb.Size                 = UDim2.new(1,-70,1,0)
            RowLb.Font                 = Enum.Font.Gotham
            RowLb.Text                 = label or "Color"
            RowLb.TextColor3           = WT
            RowLb.TextSize             = 11
            RowLb.TextXAlignment       = Enum.TextXAlignment.Left

            local Swatch = Instance.new("TextButton")
            Swatch.Parent           = Row
            Swatch.AnchorPoint      = Vector2.new(1,0.5)
            Swatch.BackgroundColor3 = CurrentColor
            Swatch.BorderSizePixel  = 0
            Swatch.Position         = UDim2.new(1,0,0.5,0)
            Swatch.Size             = UDim2.new(0,56,0,22)
            Swatch.AutoButtonColor  = false
            Swatch.Text             = ""
            local _swc = Instance.new("UICorner"); _swc.CornerRadius = UDim.new(0,5); _swc.Parent = Swatch
            local SwStroke = Instance.new("UIStroke")
            SwStroke.Parent    = Swatch
            SwStroke.Color     = TH.br
            SwStroke.Thickness = 1

            local SwHex = Instance.new("TextLabel")
            SwHex.Parent               = Swatch
            SwHex.BackgroundTransparency = 1
            SwHex.Size                 = UDim2.new(1,0,1,0)
            SwHex.Font                 = Enum.Font.GothamBold
            SwHex.Text                 = "#"..color3ToHex(CurrentColor)
            SwHex.TextColor3           = Color3.new(1,1,1)
            SwHex.TextSize             = 8
            SwHex.TextStrokeTransparency = 0.4

            local Panel = Instance.new("Frame")
            Panel.Name             = "CPPanel"
            Panel.Parent           = Row
            Panel.BackgroundColor3 = TH.cd
            Panel.BorderSizePixel  = 0
            Panel.Position         = UDim2.new(0,0,1,4)
            Panel.Size             = UDim2.new(1,0,0,0)
            Panel.ClipsDescendants = true
            local _pc = Instance.new("UICorner"); _pc.CornerRadius = UDim.new(0,8); _pc.Parent = Panel
            local PanelStroke = Instance.new("UIStroke")
            PanelStroke.Parent    = Panel
            PanelStroke.Color     = TH.br
            PanelStroke.Thickness = 1

            local PANEL_H = 228

            local GradOuter = Instance.new("Frame")
            GradOuter.Parent           = Panel
            GradOuter.BackgroundColor3 = hsvToColor3(h,1,1)
            GradOuter.BorderSizePixel  = 0
            GradOuter.Position         = UDim2.new(0,10,0,10)
            GradOuter.Size             = UDim2.new(1,-20,0,110)
            local _goc = Instance.new("UICorner"); _goc.CornerRadius = UDim.new(0,6); _goc.Parent = GradOuter

            local GradS = Instance.new("Frame")
            GradS.Parent           = GradOuter
            GradS.BackgroundColor3 = Color3.new(1,1,1)
            GradS.BorderSizePixel  = 0
            GradS.Size             = UDim2.new(1,0,1,0)
            local _gsg = Instance.new("UIGradient")
            _gsg.Color    = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), ColorSequenceKeypoint.new(1, Color3.new(1,1,1,0))})
            _gsg.Rotation = 0
            _gsg.Parent   = GradS
            local _gsc = Instance.new("UICorner"); _gsc.CornerRadius = UDim.new(0,6); _gsc.Parent = GradS

            local GradV = Instance.new("Frame")
            GradV.Parent           = GradS
            GradV.BackgroundColor3 = Color3.new(0,0,0)
            GradV.BorderSizePixel  = 0
            GradV.Size             = UDim2.new(1,0,1,0)
            local _gvg = Instance.new("UIGradient")
            _gvg.Color    = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0,0,0,0)), ColorSequenceKeypoint.new(1, Color3.new(0,0,0))})
            _gvg.Rotation = 90
            _gvg.Parent   = GradV
            local _gvc = Instance.new("UICorner"); _gvc.CornerRadius = UDim.new(0,6); _gvc.Parent = GradV

            local PCursor = Instance.new("Frame")
            PCursor.Parent           = GradOuter
            PCursor.AnchorPoint      = Vector2.new(0.5,0.5)
            PCursor.BackgroundColor3 = Color3.new(1,1,1)
            PCursor.BorderSizePixel  = 0
            PCursor.Position         = UDim2.new(s, 0, 1-v, 0)
            PCursor.Size             = UDim2.new(0,12,0,12)
            PCursor.ZIndex           = 5
            local _pcc = Instance.new("UICorner"); _pcc.CornerRadius = UDim.new(1,0); _pcc.Parent = PCursor
            local PCursorStroke = Instance.new("UIStroke")
            PCursorStroke.Parent    = PCursor
            PCursorStroke.Color     = Color3.new(0,0,0)
            PCursorStroke.Thickness = 1.5

            -- updateAll with tween animation and debug prints
            local function updateCore()
                local prevColor = CurrentColor
                CurrentColor = hsvToColor3(h,s,v)
                GradOuter.BackgroundColor3 = hsvToColor3(h,1,1)
                PCursor.Position           = UDim2.new(s,0,1-v,0)

                -- Smooth tween for swatch color change
                tw(Swatch, {BackgroundColor3 = CurrentColor}, 0.15)
                SwHex.Text = "#"..color3ToHex(CurrentColor)

                -- Debug print when color actually changes
                -- if prevColor ~= CurrentColor then
                --     print("[ColorPicker] Color changed:", color3ToHex(prevColor), "→", color3ToHex(CurrentColor),
                --           "| HSV:", string.format("%.2f,%.2f,%.2f", h, s, v))
                -- end

                callback(CurrentColor)
            end

            local gradDragging = false
            local GradBtn = Instance.new("TextButton")
            GradBtn.Parent               = GradOuter
            GradBtn.BackgroundTransparency = 1
            GradBtn.Size                 = UDim2.new(1,0,1,0)
            GradBtn.Text                 = ""
            GradBtn.ZIndex               = 6

            local function handleGradInput(inputPos)
                local ap  = GradOuter.AbsolutePosition
                local asz = GradOuter.AbsoluteSize
                s = math.clamp((inputPos.X - ap.X) / asz.X, 0, 1)
                v = math.clamp(1 - (inputPos.Y - ap.Y) / asz.Y, 0, 1)
                updateCore()
            end

            GradBtn.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    gradDragging = true; handleGradInput(inp.Position)
                end
            end)
            GradBtn.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then gradDragging = false end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if gradDragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                    handleGradInput(inp.Position)
                end
            end)

            local HueLabel = Instance.new("TextLabel")
            HueLabel.Parent               = Panel
            HueLabel.BackgroundTransparency = 1
            HueLabel.Position             = UDim2.new(0,10,0,128)
            HueLabel.Size                 = UDim2.new(0.5,0,0,14)
            HueLabel.Font                 = Enum.Font.Gotham
            HueLabel.Text                 = "Hue"
            HueLabel.TextColor3           = TH.su
            HueLabel.TextSize             = 9
            HueLabel.TextXAlignment       = Enum.TextXAlignment.Left

            local HueTrack = Instance.new("TextButton")
            HueTrack.Parent           = Panel
            HueTrack.BackgroundColor3 = Color3.new(1,1,1)
            HueTrack.BorderSizePixel  = 0
            HueTrack.Position         = UDim2.new(0,10,0,144)
            HueTrack.Size             = UDim2.new(1,-20,0,10)
            HueTrack.AutoButtonColor  = false
            HueTrack.Text             = ""
            local _htc = Instance.new("UICorner"); _htc.CornerRadius = UDim.new(1,0); _htc.Parent = HueTrack
            local HueGrad = Instance.new("UIGradient")
            HueGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,    Color3.fromRGB(255,0,0)),
                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
                ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0,255,255)),
                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
                ColorSequenceKeypoint.new(1,    Color3.fromRGB(255,0,0)),
            })
            HueGrad.Parent = HueTrack

            local HueKnob = Instance.new("Frame")
            HueKnob.Parent           = HueTrack
            HueKnob.AnchorPoint      = Vector2.new(0.5,0.5)
            HueKnob.BackgroundColor3 = Color3.new(1,1,1)
            HueKnob.BorderSizePixel  = 0
            HueKnob.Position         = UDim2.new(h,0,0.5,0)
            HueKnob.Size             = UDim2.new(0,14,0,14)
            HueKnob.ZIndex           = 2
            local _hkc = Instance.new("UICorner"); _hkc.CornerRadius = UDim.new(1,0); _hkc.Parent = HueKnob
            local HueKnobStroke = Instance.new("UIStroke")
            HueKnobStroke.Parent    = HueKnob
            HueKnobStroke.Color     = TH.br
            HueKnobStroke.Thickness = 1.5

            local hueDrag = false
            local function handleHue(inputX)
                local ap  = HueTrack.AbsolutePosition
                local asz = HueTrack.AbsoluteSize
                h = math.clamp((inputX - ap.X) / asz.X, 0, 1)
                HueKnob.Position = UDim2.new(h,0,0.5,0)
                updateCore()
            end
            HueTrack.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then hueDrag=true; handleHue(inp.Position.X) end
            end)
            HueTrack.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then hueDrag=false end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if hueDrag and inp.UserInputType == Enum.UserInputType.MouseMovement then handleHue(inp.Position.X) end
            end)

            local HexLabel = Instance.new("TextLabel")
            HexLabel.Parent               = Panel
            HexLabel.BackgroundTransparency = 1
            HexLabel.Position             = UDim2.new(0,10,0,162)
            HexLabel.Size                 = UDim2.new(0.5,0,0,14)
            HexLabel.Font                 = Enum.Font.Gotham
            HexLabel.Text                 = "HEX"
            HexLabel.TextColor3           = TH.su
            HexLabel.TextSize             = 9
            HexLabel.TextXAlignment       = Enum.TextXAlignment.Left

            local HexBox = Instance.new("TextBox")
            HexBox.Parent               = Panel
            HexBox.BackgroundColor3     = TH.bg
            HexBox.BorderSizePixel      = 0
            HexBox.Position             = UDim2.new(0,10,0,178)
            HexBox.Size                 = UDim2.new(0.47,-2,0,22)
            HexBox.Font                 = Enum.Font.GothamBold
            HexBox.Text                 = "#"..color3ToHex(CurrentColor)
            HexBox.TextColor3           = WT
            HexBox.TextSize             = 10
            HexBox.PlaceholderText      = "#RRGGBB"
            HexBox.ClearTextOnFocus     = false
            local _hbc = Instance.new("UICorner"); _hbc.CornerRadius = UDim.new(0,5); _hbc.Parent = HexBox
            local HexStroke = Instance.new("UIStroke")
            HexStroke.Parent    = HexBox
            HexStroke.Color     = TH.br
            HexStroke.Thickness = 1

            HexBox.FocusLost:Connect(function()
                local c = hexToColor3(HexBox.Text)
                if c then
                    h, s, v = color3ToHsv(c)
                    HueKnob.Position = UDim2.new(h,0,0.5,0)
                    updateCore()
                    HexStroke.Color = TH.br
                else
                    HexStroke.Color = Color3.fromRGB(240,60,60)
                end
            end)

            local RgbLabel = Instance.new("TextLabel")
            RgbLabel.Parent               = Panel
            RgbLabel.BackgroundTransparency = 1
            RgbLabel.Position             = UDim2.new(0.5,2,0,162)
            RgbLabel.Size                 = UDim2.new(0.5,-12,0,14)
            RgbLabel.Font                 = Enum.Font.Gotham
            RgbLabel.Text                 = "RGB"
            RgbLabel.TextColor3           = TH.su
            RgbLabel.TextSize             = 9
            RgbLabel.TextXAlignment       = Enum.TextXAlignment.Left

            local RgbBox = Instance.new("TextBox")
            RgbBox.Parent               = Panel
            RgbBox.BackgroundColor3     = TH.bg
            RgbBox.BorderSizePixel      = 0
            RgbBox.Position             = UDim2.new(0.5,2,0,178)
            RgbBox.Size                 = UDim2.new(0.5,-12,0,22)
            RgbBox.Font                 = Enum.Font.GothamBold
            RgbBox.Text                 = color3ToRgbString(CurrentColor)
            RgbBox.TextColor3           = WT
            RgbBox.TextSize             = 10
            RgbBox.PlaceholderText      = "R,G,B"
            RgbBox.ClearTextOnFocus     = false
            local _rbc = Instance.new("UICorner"); _rbc.CornerRadius = UDim.new(0,5); _rbc.Parent = RgbBox
            local RgbStroke = Instance.new("UIStroke")
            RgbStroke.Parent    = RgbBox
            RgbStroke.Color     = TH.br
            RgbStroke.Thickness = 1

            RgbBox.FocusLost:Connect(function()
                local c = rgbStringToColor3(RgbBox.Text)
                if c then
                    h, s, v = color3ToHsv(c)
                    HueKnob.Position = UDim2.new(h,0,0.5,0)
                    updateCore()
                    RgbStroke.Color = TH.br
                else
                    RgbStroke.Color = Color3.fromRGB(240,60,60)
                end
            end)

            -- updateAll wrapper that also syncs text boxes
            local function updateAll()
                updateCore()
                if not HexBox:IsFocused() then HexBox.Text = "#"..color3ToHex(CurrentColor) end
                if not RgbBox:IsFocused() then RgbBox.Text = color3ToRgbString(CurrentColor) end
            end

            Swatch.MouseButton1Click:Connect(function()
                pickerOpen = not pickerOpen
                if pickerOpen then
                    Row:TweenSize(UDim2.new(1,-28,0,30+PANEL_H+8), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.28, true)
                    Panel:TweenSize(UDim2.new(1,0,0,PANEL_H), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.28, true)
                else
                    Row:TweenSize(UDim2.new(1,-28,0,30), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.24, true)
                    Panel:TweenSize(UDim2.new(1,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.24, true)
                end
                -- Visual highlight: stroke color changes when picker is open
                tw(SwStroke, {Color = pickerOpen and TH.ac or TH.br}, 0.14)
                -- print("[ColorPicker] Picker ", pickerOpen and "opened" or "closed",
                --       "| CurrentColor:", color3ToHex(CurrentColor))
            end)

            onThemeChange(function(t)
                tw(RowLb,   {TextColor3 = t.su},        0.22)
                tw(Panel,   {BackgroundColor3 = t.cd}, 0.22)
                tw(HexBox,  {BackgroundColor3 = t.bg}, 0.22)
                tw(RgbBox,  {BackgroundColor3 = t.bg}, 0.22)
                tw(HueLabel,{TextColor3 = t.su}, 0.22)
                tw(HexLabel,{TextColor3 = t.su}, 0.22)
                tw(RgbLabel,{TextColor3 = t.su}, 0.22)
                SwStroke.Color    = pickerOpen and t.ac or t.br
                PanelStroke.Color = t.br
                HexStroke.Color   = t.br
                RgbStroke.Color   = t.br
                HueKnobStroke.Color = t.br
            end)

            -- Initial call to set everything up
            updateAll()
            --print("[ColorPicker] Initialized with color:", color3ToHex(CurrentColor))
        end

        -- ════════════════════════════════════════════════════════════
        --  FIXED ColorCustomizer — with CurrentColor, tween, highlight
        -- ════════════════════════════════════════════════════════════
        function TabFunctions:ColorCustomizer(title, colorDefs, callback)
            colorDefs = colorDefs or {}
            callback  = callback or function() end

            -- State
            local colors     = {}
            local editMode   = false
            local selIdx     = -1     -- -1 = no selection
            local rowEls     = {}     -- { row, swatch, hexLbl, checkIcon }
            local pickerOpen = false
            local CurrentColor = nil  -- tracks the actively selected color

            for i, def in ipairs(colorDefs) do
                colors[i] = def.color or Color3.fromRGB(255,255,255)
            end

            -- Outer wrapper
            local PREVIEW_H = 48
            local ROW_H     = 34
            local PICKER_H  = 236
            local BASE_H    = PREVIEW_H

            local Outer = Instance.new("Frame")
            Outer.Name             = "ColorCustomizer"
            Outer.Parent           = Page
            Outer.BackgroundTransparency = 1
            Outer.BorderSizePixel  = 0
            Outer.Size             = UDim2.new(1,-28,0,BASE_H)
            Outer.ClipsDescendants = true

            -- Title bar with Edit button
            local TitleBar = Instance.new("Frame")
            TitleBar.Parent           = Outer
            TitleBar.BackgroundTransparency = 1
            TitleBar.BorderSizePixel  = 0
            TitleBar.Size             = UDim2.new(1,0,0,20)

            local TitleTx = Instance.new("TextLabel")
            TitleTx.Parent               = TitleBar
            TitleTx.BackgroundTransparency = 1
            TitleTx.Position             = UDim2.new(0,2,0,0)
            TitleTx.Size                 = UDim2.new(1,-52,1,0)
            TitleTx.Font                 = Enum.Font.GothamBold
            TitleTx.Text                 = (title or "Custom Colors"):upper()
            TitleTx.TextColor3           = TH.ac
            TitleTx.TextSize             = 9
            TitleTx.TextXAlignment       = Enum.TextXAlignment.Left

            local TitleLine = Instance.new("Frame")
            TitleLine.Parent           = TitleBar
            TitleLine.AnchorPoint      = Vector2.new(0,1)
            TitleLine.BackgroundColor3 = TH.br
            TitleLine.BorderSizePixel  = 0
            TitleLine.Position         = UDim2.new(0,0,1,0)
            TitleLine.Size             = UDim2.new(1,0,0,1)

            local EditBtn = Instance.new("TextButton")
            EditBtn.Parent           = TitleBar
            EditBtn.AnchorPoint      = Vector2.new(1,0.5)
            EditBtn.BackgroundColor3 = TH.sl
            EditBtn.BorderSizePixel  = 0
            EditBtn.Position         = UDim2.new(1,0,0.5,0)
            EditBtn.Size             = UDim2.new(0,44,0,16)
            EditBtn.AutoButtonColor  = false
            EditBtn.Font             = Enum.Font.GothamBold
            EditBtn.Text             = "Edit"
            EditBtn.TextColor3       = TH.su
            EditBtn.TextSize         = 9
            local _ebc = Instance.new("UICorner"); _ebc.CornerRadius = UDim.new(0,4); _ebc.Parent = EditBtn

            -- Preview row
            local PreviewRow = Instance.new("Frame")
            PreviewRow.Parent           = Outer
            PreviewRow.BackgroundTransparency = 1
            PreviewRow.BorderSizePixel  = 0
            PreviewRow.Position         = UDim2.new(0,0,0,22)
            PreviewRow.Size             = UDim2.new(1,0,0,PREVIEW_H - 22)

            local PreviewLayout = Instance.new("UIListLayout")
            PreviewLayout.Parent        = PreviewRow
            PreviewLayout.FillDirection = Enum.FillDirection.Horizontal
            PreviewLayout.SortOrder     = Enum.SortOrder.LayoutOrder
            PreviewLayout.Padding       = UDim.new(0,6)

            local previewChips = {}

            for i, def in ipairs(colorDefs) do
                local ChipWrap = Instance.new("Frame")
                ChipWrap.Parent           = PreviewRow
                ChipWrap.BackgroundTransparency = 1
                ChipWrap.BorderSizePixel  = 0
                ChipWrap.Size             = UDim2.new(0,0,1,0)
                ChipWrap.AutomaticSize    = Enum.AutomaticSize.X
                local _cwl = Instance.new("UIListLayout")
                _cwl.Parent            = ChipWrap
                _cwl.FillDirection     = Enum.FillDirection.Vertical
                _cwl.HorizontalAlignment = Enum.HorizontalAlignment.Center
                _cwl.Padding           = UDim.new(0,2)

                local Chip = Instance.new("Frame")
                Chip.Parent           = ChipWrap
                Chip.BackgroundColor3 = colors[i]
                Chip.BorderSizePixel  = 0
                Chip.Size             = UDim2.new(0,28,0,16)
                local _chc = Instance.new("UICorner"); _chc.CornerRadius = UDim.new(0,4); _chc.Parent = Chip
                local ChipStroke = Instance.new("UIStroke")
                ChipStroke.Parent    = Chip
                ChipStroke.Color     = TH.br
                ChipStroke.Thickness = 1

                local ChipLbl = Instance.new("TextLabel")
                ChipLbl.Parent               = ChipWrap
                ChipLbl.BackgroundTransparency = 1
                ChipLbl.Size                 = UDim2.new(0,36,0,10)
                ChipLbl.Font                 = Enum.Font.Gotham
                ChipLbl.Text                 = def.label or ("C"..i)
                ChipLbl.TextColor3           = TH.su
                ChipLbl.TextSize             = 7
                ChipLbl.TextTruncate         = Enum.TextTruncate.AtEnd

                previewChips[i] = { chip=Chip, stroke=ChipStroke, lbl=ChipLbl }
            end

            -- Edit list (hidden initially)
            local EditList = Instance.new("Frame")
            EditList.Parent           = Outer
            EditList.BackgroundColor3 = TH.cd
            EditList.BorderSizePixel  = 0
            EditList.Position         = UDim2.new(0,0,0,PREVIEW_H + 4)
            EditList.Size             = UDim2.new(1,0,0,0)
            EditList.ClipsDescendants = true
            local _elc = Instance.new("UICorner"); _elc.CornerRadius = UDim.new(0,6); _elc.Parent = EditList
            local EditListStroke = Instance.new("UIStroke")
            EditListStroke.Parent    = EditList
            EditListStroke.Color     = TH.br
            EditListStroke.Thickness = 1

            local EditListLayout = Instance.new("UIListLayout")
            EditListLayout.Parent    = EditList
            EditListLayout.SortOrder = Enum.SortOrder.LayoutOrder

            local listH = #colorDefs * ROW_H + 4

            -- Create color rows
            for i, def in ipairs(colorDefs) do
                local CRow = Instance.new("TextButton")
                CRow.Parent                 = EditList
                CRow.BackgroundColor3       = TH.ac
                CRow.BackgroundTransparency = 1
                CRow.BorderSizePixel        = 0
                CRow.Size                   = UDim2.new(1,0,0,ROW_H)
                CRow.AutoButtonColor        = false
                CRow.Text                   = ""
                local _crc = Instance.new("UICorner"); _crc.CornerRadius = UDim.new(0,5); _crc.Parent = CRow

                -- Swatch in row
                local RSwatch = Instance.new("Frame")
                RSwatch.Parent           = CRow
                RSwatch.AnchorPoint      = Vector2.new(0,0.5)
                RSwatch.BackgroundColor3 = colors[i]
                RSwatch.BorderSizePixel  = 0
                RSwatch.Position         = UDim2.new(0,10,0.5,0)
                RSwatch.Size             = UDim2.new(0,20,0,20)
                local _rsc = Instance.new("UICorner"); _rsc.CornerRadius = UDim.new(0,4); _rsc.Parent = RSwatch
                local RSwatchStroke = Instance.new("UIStroke")
                RSwatchStroke.Parent    = RSwatch
                RSwatchStroke.Color     = TH.br
                RSwatchStroke.Thickness = 1

                -- Label
                local RLbl = Instance.new("TextLabel")
                RLbl.Parent               = CRow
                RLbl.BackgroundTransparency = 1
                RLbl.Position             = UDim2.new(0,38,0,0)
                RLbl.Size                 = UDim2.new(1,-110,1,0)
                RLbl.Font                 = Enum.Font.Gotham
                RLbl.Text                 = def.label or ("Color "..i)
                RLbl.TextColor3           = WT
                RLbl.TextSize             = 11
                RLbl.TextXAlignment       = Enum.TextXAlignment.Left

                -- Hex label
                local RHex = Instance.new("TextLabel")
                RHex.Parent               = CRow
                RHex.AnchorPoint          = Vector2.new(1,0.5)
                RHex.BackgroundTransparency = 1
                RHex.Position             = UDim2.new(1,-28,0.5,0)
                RHex.Size                 = UDim2.new(0,56,0,14)
                RHex.Font                 = Enum.Font.GothamBold
                RHex.Text                 = "#"..color3ToHex(colors[i])
                RHex.TextColor3           = TH.su
                RHex.TextSize             = 8
                RHex.TextXAlignment       = Enum.TextXAlignment.Right

                -- Checkmark icon (shows when selected)
                local ChkIco = Instance.new("TextLabel")
                ChkIco.Parent               = CRow
                ChkIco.AnchorPoint          = Vector2.new(1,0.5)
                ChkIco.BackgroundTransparency = 1
                ChkIco.Position             = UDim2.new(1,-6,0.5,0)
                ChkIco.Size                 = UDim2.new(0,18,0,18)
                ChkIco.Font                 = Enum.Font.GothamBold
                ChkIco.Text                 = "›"
                ChkIco.TextColor3           = TH.ac
                ChkIco.TextSize             = 16
                ChkIco.TextTransparency     = 1

                -- Selection indicator ring (new visual highlight)
                local SelRing = Instance.new("UIStroke")
                SelRing.Parent    = RSwatch
                SelRing.Color     = TH.ac
                SelRing.Thickness = 2
                SelRing.Transparency = 1  -- hidden by default

                -- Hover effects
                CRow.MouseEnter:Connect(function()
                    if selIdx ~= i then tw(CRow, {BackgroundTransparency=0.92}, 0.12) end
                end)
                CRow.MouseLeave:Connect(function()
                    if selIdx ~= i then tw(CRow, {BackgroundTransparency=1}, 0.12) end
                end)

                rowEls[i] = {
                    row        = CRow,
                    swatch     = RSwatch,
                    swStroke   = RSwatchStroke,
                    hexLbl     = RHex,
                    checkIco   = ChkIco,
                    selRing    = SelRing,
                }

                -- Click row → select color + open picker
                CRow.MouseButton1Click:Connect(function()
                    -- Deselect all rows
                    for j, el in ipairs(rowEls) do
                        el.checkIco.TextTransparency = 1
                        tw(el.selRing, {Transparency = 1}, 0.14)
                        el.swatch.BackgroundColor3 = colors[j]  -- reset swatch to actual color
                        if j ~= i then
                            tw(el.row, {BackgroundTransparency=1}, 0.14)
                        end
                    end

                    if selIdx == i then
                        -- Click same row → close picker
                        selIdx = -1
                        CurrentColor = nil
                        tw(CRow, {BackgroundTransparency=1}, 0.14)
                        closePicker()
                       -- print("[ColorCustomizer] Deselected row", i, "— closing picker")
                    else
                        selIdx = i
                        CurrentColor = colors[i]
                        CRow.BackgroundColor3       = TH.dk
                        tw(CRow, {BackgroundTransparency=0}, 0.15)
                        ChkIco.TextTransparency = 0
                        tw(SelRing, {Transparency = 0}, 0.15)
                        openPickerFor(i)
                        -- print("[ColorCustomizer] Selected row", i,
                        --       "| Label:", def.label or ("Color "..i),
                        --       "| CurrentColor:", color3ToHex(CurrentColor))
                    end
                end)
            end

            -- Picker Panel (hidden below edit list)
            local PickerPanel = Instance.new("Frame")
            PickerPanel.Name             = "PickerPanel"
            PickerPanel.Parent           = Outer
            PickerPanel.BackgroundColor3 = TH.cd
            PickerPanel.BorderSizePixel  = 0
            PickerPanel.Position         = UDim2.new(0,0,0, PREVIEW_H + 4 + listH + 4)
            PickerPanel.Size             = UDim2.new(1,0,0,0)
            PickerPanel.ClipsDescendants = true
            local _ppc = Instance.new("UICorner"); _ppc.CornerRadius = UDim.new(0,8); _ppc.Parent = PickerPanel
            local PickerStroke = Instance.new("UIStroke")
            PickerStroke.Parent    = PickerPanel
            PickerStroke.Color     = TH.br
            PickerStroke.Thickness = 1

            -- Picker internals
            local ph, ps, pv = 0, 1, 1
            local pDragging = false
            local pHueDrag  = false

            local GradOuter2 = Instance.new("Frame")
            GradOuter2.Parent           = PickerPanel
            GradOuter2.BackgroundColor3 = hsvToColor3(ph,1,1)
            GradOuter2.BorderSizePixel  = 0
            GradOuter2.Position         = UDim2.new(0,10,0,10)
            GradOuter2.Size             = UDim2.new(1,-20,0,100)
            local _go2c = Instance.new("UICorner"); _go2c.CornerRadius = UDim.new(0,6); _go2c.Parent = GradOuter2

            local GS2 = Instance.new("Frame")
            GS2.Parent           = GradOuter2
            GS2.BackgroundColor3 = Color3.new(1,1,1)
            GS2.BorderSizePixel  = 0
            GS2.Size             = UDim2.new(1,0,1,0)
            local _gs2g = Instance.new("UIGradient")
            _gs2g.Color    = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.new(1,1,1,0))})
            _gs2g.Parent   = GS2
            local _gs2c = Instance.new("UICorner"); _gs2c.CornerRadius = UDim.new(0,6); _gs2c.Parent = GS2

            local GV2 = Instance.new("Frame")
            GV2.Parent           = GS2
            GV2.BackgroundColor3 = Color3.new(0,0,0)
            GV2.BorderSizePixel  = 0
            GV2.Size             = UDim2.new(1,0,1,0)
            local _gv2g = Instance.new("UIGradient")
            _gv2g.Color    = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0,0,0,0)),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))})
            _gv2g.Rotation = 90
            _gv2g.Parent   = GV2
            local _gv2c = Instance.new("UICorner"); _gv2c.CornerRadius = UDim.new(0,6); _gv2c.Parent = GV2

            local PC2 = Instance.new("Frame")
            PC2.Parent           = GradOuter2
            PC2.AnchorPoint      = Vector2.new(0.5,0.5)
            PC2.BackgroundColor3 = Color3.new(1,1,1)
            PC2.BorderSizePixel  = 0
            PC2.Position         = UDim2.new(ps,0,1-pv,0)
            PC2.Size             = UDim2.new(0,12,0,12)
            PC2.ZIndex           = 5
            local _pc2c = Instance.new("UICorner"); _pc2c.CornerRadius = UDim.new(1,0); _pc2c.Parent = PC2
            local PC2Stroke = Instance.new("UIStroke"); PC2Stroke.Parent=PC2; PC2Stroke.Color=Color3.new(0,0,0); PC2Stroke.Thickness=1.5

            local GBtn2 = Instance.new("TextButton")
            GBtn2.Parent               = GradOuter2
            GBtn2.BackgroundTransparency = 1
            GBtn2.Size                 = UDim2.new(1,0,1,0)
            GBtn2.Text                 = ""
            GBtn2.ZIndex               = 6

            -- Hue track
            local HT2 = Instance.new("TextButton")
            HT2.Parent           = PickerPanel
            HT2.BackgroundColor3 = Color3.new(1,1,1)
            HT2.BorderSizePixel  = 0
            HT2.Position         = UDim2.new(0,10,0,118)
            HT2.Size             = UDim2.new(1,-20,0,10)
            HT2.AutoButtonColor  = false
            HT2.Text             = ""
            local _ht2c = Instance.new("UICorner"); _ht2c.CornerRadius = UDim.new(1,0); _ht2c.Parent = HT2
            local HG2 = Instance.new("UIGradient")
            HG2.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,    Color3.fromRGB(255,0,0)),
                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
                ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0,255,255)),
                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
                ColorSequenceKeypoint.new(1,    Color3.fromRGB(255,0,0)),
            })
            HG2.Parent = HT2

            local HK2 = Instance.new("Frame")
            HK2.Parent           = HT2
            HK2.AnchorPoint      = Vector2.new(0.5,0.5)
            HK2.BackgroundColor3 = Color3.new(1,1,1)
            HK2.BorderSizePixel  = 0
            HK2.Position         = UDim2.new(ph,0,0.5,0)
            HK2.Size             = UDim2.new(0,14,0,14)
            HK2.ZIndex           = 2
            local _hk2c = Instance.new("UICorner"); _hk2c.CornerRadius = UDim.new(1,0); _hk2c.Parent = HK2
            local HK2Stroke = Instance.new("UIStroke"); HK2Stroke.Parent=HK2; HK2Stroke.Color=TH.br; HK2Stroke.Thickness=1.5

            -- Hex + RGB boxes
            local HexLbl2 = Instance.new("TextLabel")
            HexLbl2.Parent               = PickerPanel
            HexLbl2.BackgroundTransparency = 1
            HexLbl2.Position             = UDim2.new(0,10,0,136)
            HexLbl2.Size                 = UDim2.new(0.5,0,0,12)
            HexLbl2.Font                 = Enum.Font.Gotham
            HexLbl2.Text                 = "HEX"
            HexLbl2.TextColor3           = TH.su
            HexLbl2.TextSize             = 9
            HexLbl2.TextXAlignment       = Enum.TextXAlignment.Left

            local RgbLbl2 = Instance.new("TextLabel")
            RgbLbl2.Parent               = PickerPanel
            RgbLbl2.BackgroundTransparency = 1
            RgbLbl2.Position             = UDim2.new(0.5,2,0,136)
            RgbLbl2.Size                 = UDim2.new(0.5,-12,0,12)
            RgbLbl2.Font                 = Enum.Font.Gotham
            RgbLbl2.Text                 = "RGB"
            RgbLbl2.TextColor3           = TH.su
            RgbLbl2.TextSize             = 9
            RgbLbl2.TextXAlignment       = Enum.TextXAlignment.Left

            local HexBox2 = Instance.new("TextBox")
            HexBox2.Parent               = PickerPanel
            HexBox2.BackgroundColor3     = TH.bg
            HexBox2.BorderSizePixel      = 0
            HexBox2.Position             = UDim2.new(0,10,0,150)
            HexBox2.Size                 = UDim2.new(0.47,-2,0,22)
            HexBox2.Font                 = Enum.Font.GothamBold
            HexBox2.Text                 = "#FFFFFF"
            HexBox2.TextColor3           = WT
            HexBox2.TextSize             = 10
            HexBox2.PlaceholderText      = "#RRGGBB"
            HexBox2.ClearTextOnFocus     = false
            local _hb2c = Instance.new("UICorner"); _hb2c.CornerRadius = UDim.new(0,5); _hb2c.Parent = HexBox2
            local HexStroke2 = Instance.new("UIStroke"); HexStroke2.Parent=HexBox2; HexStroke2.Color=TH.br; HexStroke2.Thickness=1

            local RgbBox2 = Instance.new("TextBox")
            RgbBox2.Parent               = PickerPanel
            RgbBox2.BackgroundColor3     = TH.bg
            RgbBox2.BorderSizePixel      = 0
            RgbBox2.Position             = UDim2.new(0.5,2,0,150)
            RgbBox2.Size                 = UDim2.new(0.5,-12,0,22)
            RgbBox2.Font                 = Enum.Font.GothamBold
            RgbBox2.Text                 = "255,255,255"
            RgbBox2.TextColor3           = WT
            RgbBox2.TextSize             = 10
            RgbBox2.PlaceholderText      = "R,G,B"
            RgbBox2.ClearTextOnFocus     = false
            local _rb2c = Instance.new("UICorner"); _rb2c.CornerRadius = UDim.new(0,5); _rb2c.Parent = RgbBox2
            local RgbStroke2 = Instance.new("UIStroke"); RgbStroke2.Parent=RgbBox2; RgbStroke2.Color=TH.br; RgbStroke2.Thickness=1

            -- Helper: update picker UI + colors array + preview with tween animation
            local function syncPickerDisplay()
                local newColor = hsvToColor3(ph, ps, pv)
                CurrentColor = newColor
                GradOuter2.BackgroundColor3 = hsvToColor3(ph,1,1)
                PC2.Position = UDim2.new(ps,0,1-pv,0)
                HK2.Position = UDim2.new(ph,0,0.5,0)
                if not HexBox2:IsFocused() then HexBox2.Text = "#"..color3ToHex(newColor) end
                if not RgbBox2:IsFocused() then RgbBox2.Text = color3ToRgbString(newColor) end

                if selIdx >= 1 then
                    local prevColor = colors[selIdx]
                    colors[selIdx] = newColor

                    -- Tween animation for preview chip
                    if previewChips[selIdx] then
                        tw(previewChips[selIdx].chip, {BackgroundColor3 = newColor}, 0.15)
                        -- Visual highlight: pulse stroke on color change
                        tw(previewChips[selIdx].stroke, {Color = TH.ac, Thickness = 2}, 0.1)
                        task.delay(0.2, function()
                            if previewChips[selIdx] then
                                tw(previewChips[selIdx].stroke, {Color = TH.br, Thickness = 1}, 0.15)
                            end
                        end)
                    end

                    -- Tween animation for row swatch
                    if rowEls[selIdx] then
                        tw(rowEls[selIdx].swatch, {BackgroundColor3 = newColor}, 0.15)
                        rowEls[selIdx].hexLbl.Text = "#"..color3ToHex(newColor)
                        -- Keep selection ring visible while picker is open
                        tw(rowEls[selIdx].selRing, {Transparency = 0}, 0.1)
                    end

                    -- Debug print when color actually changes
                    -- if prevColor ~= newColor then
                    --     print("[ColorCustomizer] Row", selIdx, "color changed:",
                    --           color3ToHex(prevColor), "→", color3ToHex(newColor))
                    -- end

                    callback(selIdx, newColor, colors)
                end
            end

            -- Helper: open picker for color at index i
            function openPickerFor(i)
                ph, ps, pv = color3ToHsv(colors[i])
                CurrentColor = colors[i]
                syncPickerDisplay()
                pickerOpen = true
                local totalH = PREVIEW_H + 4 + listH + 4 + PICKER_H + 4
                Outer:TweenSize(UDim2.new(1,-28,0,totalH), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.28, true)
                PickerPanel:TweenSize(UDim2.new(1,0,0,PICKER_H), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.28, true)
                PickerStroke.Color = TH.ac

            end

            -- Helper: close picker
            function closePicker()
                pickerOpen = false
                CurrentColor = nil
                local totalH = PREVIEW_H + 4 + listH + 4
                Outer:TweenSize(UDim2.new(1,-28,0,totalH), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.24, true)
                PickerPanel:TweenSize(UDim2.new(1,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.24, true)
                PickerStroke.Color = TH.br
                -- Hide all selection rings
                for _, el in ipairs(rowEls) do
                    tw(el.selRing, {Transparency = 1}, 0.14)
                end
            end

            -- SV drag
            GBtn2.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    pDragging = true
                    local ap  = GradOuter2.AbsolutePosition
                    local asz = GradOuter2.AbsoluteSize
                    ps = math.clamp((inp.Position.X - ap.X) / asz.X, 0, 1)
                    pv = math.clamp(1 - (inp.Position.Y - ap.Y) / asz.Y, 0, 1)
                    syncPickerDisplay()
                end
            end)
            GBtn2.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then pDragging = false end
            end)

            -- Hue drag
            HT2.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    pHueDrag = true
                    local ap  = HT2.AbsolutePosition
                    local asz = HT2.AbsoluteSize
                    ph = math.clamp((inp.Position.X - ap.X) / asz.X, 0, 0.9999)
                    syncPickerDisplay()
                end
            end)
            HT2.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then pHueDrag = false end
            end)

            UserInputService.InputChanged:Connect(function(inp)
                if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
                if pDragging then
                    local ap  = GradOuter2.AbsolutePosition
                    local asz = GradOuter2.AbsoluteSize
                    ps = math.clamp((inp.Position.X - ap.X) / asz.X, 0, 1)
                    pv = math.clamp(1 - (inp.Position.Y - ap.Y) / asz.Y, 0, 1)
                    syncPickerDisplay()
                elseif pHueDrag then
                    local ap  = HT2.AbsolutePosition
                    local asz = HT2.AbsoluteSize
                    ph = math.clamp((inp.Position.X - ap.X) / asz.X, 0, 0.9999)
                    syncPickerDisplay()
                end
            end)

            -- Hex box
            HexBox2.FocusLost:Connect(function()
                local c = hexToColor3(HexBox2.Text)
                if c then
                    ph, ps, pv = color3ToHsv(c)
                    syncPickerDisplay()
                    HexStroke2.Color = TH.br
                else
                    HexStroke2.Color = Color3.fromRGB(240,60,60)
                end
            end)

            -- RGB box
            RgbBox2.FocusLost:Connect(function()
                local c = rgbStringToColor3(RgbBox2.Text)
                if c then
                    ph, ps, pv = color3ToHsv(c)
                    syncPickerDisplay()
                    RgbStroke2.Color = TH.br
                else
                    RgbStroke2.Color = Color3.fromRGB(240,60,60)
                end
            end)

            -- Edit button
            EditBtn.MouseEnter:Connect(function()
                tw(EditBtn, {BackgroundColor3 = TH.dk, TextColor3 = TH.ac}, 0.14)
            end)
            EditBtn.MouseLeave:Connect(function()
                if not editMode then tw(EditBtn, {BackgroundColor3 = TH.sl, TextColor3 = TH.su}, 0.14) end
            end)
            EditBtn.MouseButton1Down:Connect(function()
                tw(EditBtn, {Size = UDim2.new(0,42,0,15)}, 0.08, Enum.EasingStyle.Sine)
            end)
            EditBtn.MouseButton1Click:Connect(function()
                tw(EditBtn, {Size = UDim2.new(0,44,0,16)}, 0.12, Enum.EasingStyle.Back)
                editMode = not editMode
                if editMode then
                    EditBtn.Text = "Done"
                    tw(EditBtn, {BackgroundColor3=TH.dk, TextColor3=TH.ac}, 0.14)
                    local h2 = PREVIEW_H + 4 + listH + 4
                    Outer:TweenSize(UDim2.new(1,-28,0,h2), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.28, true)
                    EditList:TweenSize(UDim2.new(1,0,0,listH), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.28, true)
                    EditListStroke.Transparency = 0
                else
                    EditBtn.Text = "Edit"
                    tw(EditBtn, {BackgroundColor3=TH.sl, TextColor3=TH.su}, 0.14)
                    selIdx = -1
                    CurrentColor = nil
                    for _, el in ipairs(rowEls) do
                        tw(el.row, {BackgroundTransparency=1}, 0.14)
                        el.checkIco.TextTransparency = 1
                        tw(el.selRing, {Transparency = 1}, 0.14)
                    end
                    Outer:TweenSize(UDim2.new(1,-28,0,PREVIEW_H), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.24, true)
                    EditList:TweenSize(UDim2.new(1,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.24, true)
                    PickerPanel:TweenSize(UDim2.new(1,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.24, true)
                    EditListStroke.Transparency = 1
                    pickerOpen = false
                end
            end)

            -- Theme registry
            onThemeChange(function(t)
                tw(TitleTx,  {TextColor3 = t.ac},  0.22)
                tw(TitleLine,{BackgroundColor3=t.br}, 0.22)
                if not editMode then
                    tw(EditBtn, {BackgroundColor3=t.sl, TextColor3=t.su}, 0.22)
                else
                    tw(EditBtn, {BackgroundColor3=t.dk, TextColor3=t.ac}, 0.22)
                end
                tw(EditList,    {BackgroundColor3=t.cd}, 0.22)
                tw(PickerPanel, {BackgroundColor3=t.cd}, 0.22)
                tw(HexBox2,     {BackgroundColor3=t.bg}, 0.22)
                tw(RgbBox2,     {BackgroundColor3=t.bg}, 0.22)
                tw(HexLbl2,     {TextColor3=t.su}, 0.22)
                tw(RgbLbl2,     {TextColor3=t.su}, 0.22)
                EditListStroke.Color = t.br
                HK2Stroke.Color      = t.br
                HexStroke2.Color     = t.br
                RgbStroke2.Color     = t.br
                PickerStroke.Color   = pickerOpen and t.ac or t.br
                for i, el in ipairs(rowEls) do
                    tw(el.swStroke, {Color=t.br}, 0.22)
                    tw(el.hexLbl,   {TextColor3=t.su}, 0.22)
                    tw(el.checkIco, {TextColor3=t.ac}, 0.22)
                    -- Update selRing color to match new theme accent
                    el.selRing.Color = t.ac
                end
                for i, pc in ipairs(previewChips) do
                    tw(pc.stroke, {Color=t.br}, 0.22)
                    tw(pc.lbl,    {TextColor3=t.su}, 0.22)
                end
            end)

            print("[ColorCustomizer] Initialized with", #colorDefs, "color slots")
        end

        -- ════════════════════════════════════════════════════════════
        --  Theme Selector
        -- ════════════════════════════════════════════════════════════
        function TabFunctions:ThemeSelector()

            -- ── slot keys ทั้งหมดของ theme ──
            local SLOT_KEYS = {"ac","dk","bg","pn","sb","cd","su","br","sl"}
            local SLOT_LABELS = {
                ac="Accent", dk="Dark Button", bg="Background",
                pn="Panel", sb="Sidebar", cd="Card",
                su="Subtle Text", br="Border", sl="Slot Off",
            }

            -- ── บันทึก custom themes ลงใน _G (อยู่ข้าม script reload) ──
            if not _G._ArsenalCustomThemes then _G._ArsenalCustomThemes = {} end
            local savedThemes = _G._ArsenalCustomThemes  -- reference ตรง

            -- ── Preset grid ──────────────────────────────────────────
            TabFunctions.Section(self, "เลือกธีม")

            local GridWrap = Instance.new("Frame")
            GridWrap.Name             = "ThemeGrid"
            GridWrap.Parent           = Page
            GridWrap.BackgroundTransparency = 1
            GridWrap.BorderSizePixel  = 0
            GridWrap.Size             = UDim2.new(1,-28,0,0)
            GridWrap.AutomaticSize    = Enum.AutomaticSize.Y

            local GridLayout = Instance.new("UIGridLayout")
            GridLayout.Parent      = GridWrap
            GridLayout.CellSize    = UDim2.new(0.31,0,0,52)
            GridLayout.CellPadding = UDim2.new(0,6,0,6)
            GridLayout.SortOrder   = Enum.SortOrder.LayoutOrder

            local allCards = {}  -- { card, stroke, lbl, theme }

            local function refreshAllCards()
                for _, cd in ipairs(allCards) do
                    local isThis = cd.theme.name == TH.name
                    tw(cd.card,   {BackgroundColor3 = isThis and TH.dk or TH.cd}, 0.18)
                    tw(cd.stroke, {Color = isThis and TH.ac or TH.br},             0.18)
                    cd.stroke.Thickness = isThis and 1.5 or 1
                    tw(cd.lbl,    {TextColor3 = isThis and TH.ac or TH.su},         0.18)
                end
            end

            local function makeThemeCard(parent, theme, deletable)
                local Card = Instance.new("TextButton")
                Card.Parent           = parent
                Card.BackgroundColor3 = TH.cd
                Card.BorderSizePixel  = 0
                Card.AutoButtonColor  = false
                Card.Text             = ""
                local _cc = Instance.new("UICorner"); _cc.CornerRadius = UDim.new(0,7); _cc.Parent = Card
                local CardStroke = Instance.new("UIStroke")
                CardStroke.Parent    = Card
                CardStroke.Color     = theme.name == TH.name and TH.ac or TH.br
                CardStroke.Thickness = theme.name == TH.name and 1.5 or 1

                local SwRow = Instance.new("Frame")
                SwRow.Parent               = Card
                SwRow.BackgroundTransparency = 1
                SwRow.Position             = UDim2.new(0,6,0,6)
                SwRow.Size                 = UDim2.new(1,-12,0,14)
                local _srl = Instance.new("UIListLayout")
                _srl.Parent = SwRow; _srl.FillDirection = Enum.FillDirection.Horizontal; _srl.Padding = UDim.new(0,3)
                for _, key in ipairs({"ac","bg","pn","sb"}) do
                    local Dot = Instance.new("Frame")
                    Dot.Parent = SwRow; Dot.BackgroundColor3 = theme[key]
                    Dot.BorderSizePixel = 0; Dot.Size = UDim2.new(0,12,1,0)
                    local _dc = Instance.new("UICorner"); _dc.CornerRadius = UDim.new(0,3); _dc.Parent = Dot
                end

                local NameLbl = Instance.new("TextLabel")
                NameLbl.Parent               = Card
                NameLbl.BackgroundTransparency = 1
                NameLbl.AnchorPoint          = Vector2.new(0,1)
                NameLbl.Position             = UDim2.new(0,6,1,-6)
                NameLbl.Size                 = UDim2.new(1,-12,0,14)
                NameLbl.Font                 = Enum.Font.GothamBold
                NameLbl.Text                 = theme.name
                NameLbl.TextColor3           = theme.name == TH.name and TH.ac or TH.su
                NameLbl.TextSize             = 9
                NameLbl.TextXAlignment       = Enum.TextXAlignment.Left

                -- ปุ่ม X ลบ (เฉพาะ custom)
                if deletable then
                    local DelBtn = Instance.new("ImageButton")
                    DelBtn.Parent               = Card
                    DelBtn.AnchorPoint          = Vector2.new(1,0)
                    DelBtn.BackgroundTransparency = 1
                    DelBtn.Position             = UDim2.new(1,-2,0,2)
                    DelBtn.Size                 = UDim2.new(0,13,0,13)
                    DelBtn.Image                = "rbxassetid://107560529463028"
                    DelBtn.ImageColor3          = TH.su
                    DelBtn.ZIndex               = 5
                    DelBtn.MouseEnter:Connect(function() DelBtn.ImageColor3 = Color3.fromRGB(240,60,60) end)
                    DelBtn.MouseLeave:Connect(function() DelBtn.ImageColor3 = TH.su end)
                    DelBtn.MouseButton1Click:Connect(function()
                        -- ลบจาก savedThemes
                        for i, t in ipairs(savedThemes) do
                            if t.name == theme.name then table.remove(savedThemes, i) break end
                        end
                        -- ลบ card ออกจาก allCards
                        for i, cd in ipairs(allCards) do
                            if cd.card == Card then table.remove(allCards, i) break end
                        end
                        Card:Destroy()
                    end)
                    onThemeChange(function(t) DelBtn.ImageColor3 = t.su end)
                end

                Card.MouseEnter:Connect(function()
                    if TH.name ~= theme.name then
                        tw(Card,      {BackgroundColor3 = theme.dk}, 0.14, Enum.EasingStyle.Sine)
                        tw(CardStroke,{Color = theme.ac},             0.14)
                    end
                end)
                Card.MouseLeave:Connect(function()
                    if TH.name ~= theme.name then
                        tw(Card,      {BackgroundColor3 = TH.cd}, 0.14, Enum.EasingStyle.Sine)
                        tw(CardStroke,{Color = TH.br},             0.14)
                    end
                end)
                Card.MouseButton1Down:Connect(function()
                    tw(Card, {Size = UDim2.new(0.97,0,0.97,0)}, 0.08, Enum.EasingStyle.Sine)
                end)
                Card.MouseButton1Click:Connect(function()
                    tw(Card, {Size = UDim2.new(1,0,1,0)}, 0.15, Enum.EasingStyle.Back)
                    TH = theme
                    fireThemeChange()
                    refreshAllCards()
                end)

                local entry = { card=Card, stroke=CardStroke, lbl=NameLbl, theme=theme }
                table.insert(allCards, entry)

                onThemeChange(function(t)
                    local isThis = t.name == theme.name
                    tw(Card,      {BackgroundColor3 = isThis and t.dk or t.cd}, 0.22)
                    CardStroke.Color     = isThis and t.ac or t.br
                    CardStroke.Thickness = isThis and 1.5 or 1
                    tw(NameLbl,   {TextColor3 = isThis and t.ac or t.su},        0.22)
                end)
            end

            -- สร้าง preset cards
            for _, theme in ipairs(THEMES) do
                makeThemeCard(GridWrap, theme, false)
            end


            -- ── ColorCustomizer สำหรับ custom theme ─────────────────
            TabFunctions.Section(self, "กำหนดสีเอง")

            -- custom theme object ที่แก้ไขได้
            local editTheme = {}
            for k, v in pairs(TH) do editTheme[k] = v end
            editTheme.name = "Custom"

            -- colorDefs สำหรับ ColorCustomizer
            local colorDefs = {}
            for _, key in ipairs(SLOT_KEYS) do
                table.insert(colorDefs, { label = SLOT_LABELS[key], key = key, color = editTheme[key] })
            end

            -- ══ ColorCustomizer (ดัดแปลงจาก document) ══════════════════
            local selIdx     = -1
            local pickerOpen = false
            local rowEls     = {}
            local previewChips = {}

            local PREVIEW_H = 48
            local ROW_H     = 34
            local PICKER_H  = 228

            local Outer = Instance.new("Frame")
            Outer.Name             = "ColorCustomizer"
            Outer.Parent           = Page
            Outer.BackgroundTransparency = 1
            Outer.BorderSizePixel  = 0
            Outer.Size             = UDim2.new(1,-28,0,PREVIEW_H)
            Outer.ClipsDescendants = true

            -- title bar
            local TitleBar = Instance.new("Frame")
            TitleBar.Parent = Outer; TitleBar.BackgroundTransparency = 1
            TitleBar.BorderSizePixel = 0; TitleBar.Size = UDim2.new(1,0,0,20)

            local TitleTx = Instance.new("TextLabel")
            TitleTx.Parent = TitleBar; TitleTx.BackgroundTransparency = 1
            TitleTx.Position = UDim2.new(0,2,0,0); TitleTx.Size = UDim2.new(1,-52,1,0)
            TitleTx.Font = Enum.Font.GothamBold; TitleTx.Text = "สล็อตสี"
            TitleTx.TextColor3 = TH.ac; TitleTx.TextSize = 9
            TitleTx.TextXAlignment = Enum.TextXAlignment.Left

            local TitleLine = Instance.new("Frame")
            TitleLine.Parent = TitleBar; TitleLine.AnchorPoint = Vector2.new(0,1)
            TitleLine.BackgroundColor3 = TH.br; TitleLine.BorderSizePixel = 0
            TitleLine.Position = UDim2.new(0,0,1,0); TitleLine.Size = UDim2.new(1,0,0,1)

            local EditBtn = Instance.new("TextButton")
            EditBtn.Parent = TitleBar; EditBtn.AnchorPoint = Vector2.new(1,0.5)
            EditBtn.BackgroundColor3 = TH.sl; EditBtn.BorderSizePixel = 0
            EditBtn.Position = UDim2.new(1,0,1.8,0); EditBtn.Size = UDim2.new(0,44,0,25)
            EditBtn.AutoButtonColor = false; EditBtn.Font = Enum.Font.GothamBold
            EditBtn.Text = "แก้ไข"; EditBtn.TextColor3 = TH.su; EditBtn.TextSize = 9
            local _ebc = Instance.new("UICorner"); _ebc.CornerRadius = UDim.new(0,4); _ebc.Parent = EditBtn

            -- preview row (chips)
            local PreviewRow = Instance.new("Frame")
            PreviewRow.Parent = Outer; PreviewRow.BackgroundTransparency = 1
            PreviewRow.BorderSizePixel = 0; PreviewRow.Position = UDim2.new(0,0,0,22)
            PreviewRow.Size = UDim2.new(1,0,0,PREVIEW_H-22)
            local _prl = Instance.new("UIListLayout")
            _prl.Parent = PreviewRow; _prl.FillDirection = Enum.FillDirection.Horizontal
            _prl.SortOrder = Enum.SortOrder.LayoutOrder; _prl.Padding = UDim.new(0,4)

            for i, def in ipairs(colorDefs) do
                local ChipWrap = Instance.new("Frame")
                ChipWrap.Parent = PreviewRow; ChipWrap.BackgroundTransparency = 1
                ChipWrap.BorderSizePixel = 0; ChipWrap.Size = UDim2.new(0,0,1,0)
                ChipWrap.AutomaticSize = Enum.AutomaticSize.X
                local _cwl = Instance.new("UIListLayout")
                _cwl.Parent = ChipWrap; _cwl.FillDirection = Enum.FillDirection.Vertical
                _cwl.HorizontalAlignment = Enum.HorizontalAlignment.Center; _cwl.Padding = UDim.new(0,2)

                local Chip = Instance.new("Frame")
                Chip.Parent = ChipWrap; Chip.BackgroundColor3 = editTheme[def.key]
                Chip.BorderSizePixel = 0; Chip.Size = UDim2.new(0,24,0,14)
                local _chc = Instance.new("UICorner"); _chc.CornerRadius = UDim.new(0,3); _chc.Parent = Chip
                local ChipStroke = Instance.new("UIStroke")
                ChipStroke.Parent = Chip; ChipStroke.Color = TH.br; ChipStroke.Thickness = 1

                local ChipLbl = Instance.new("TextLabel")
                ChipLbl.Parent = ChipWrap; ChipLbl.BackgroundTransparency = 1
                ChipLbl.Size = UDim2.new(0,32,0,9); ChipLbl.Font = Enum.Font.Gotham
                ChipLbl.Text = def.label; ChipLbl.TextColor3 = TH.su
                ChipLbl.TextSize = 7; ChipLbl.TextTruncate = Enum.TextTruncate.AtEnd

                previewChips[i] = { chip=Chip, stroke=ChipStroke, lbl=ChipLbl, key=def.key }
                onThemeChange(function(t)
                    tw(ChipStroke, {Color=t.br}, 0.22)
                    tw(ChipLbl,    {TextColor3=t.su}, 0.22)
                end)
            end

            -- Edit list
            local listH = #colorDefs * ROW_H + 4
            local EditList = Instance.new("Frame")
            EditList.Parent = Outer; EditList.BackgroundColor3 = TH.cd
            EditList.BorderSizePixel = 0; EditList.Position = UDim2.new(0,0,0,PREVIEW_H+4)
            EditList.Size = UDim2.new(1,0,0,0); EditList.ClipsDescendants = true
            local _elc = Instance.new("UICorner"); _elc.CornerRadius = UDim.new(0,6); _elc.Parent = EditList
            local EditListStroke = Instance.new("UIStroke")
            EditListStroke.Parent = EditList; EditListStroke.Color = TH.br; EditListStroke.Thickness = 1

            local _ell = Instance.new("UIListLayout")
            _ell.Parent = EditList; _ell.SortOrder = Enum.SortOrder.LayoutOrder

            for i, def in ipairs(colorDefs) do
                local CRow = Instance.new("TextButton")
                CRow.Parent = EditList; CRow.BackgroundColor3 = TH.ac
                CRow.BackgroundTransparency = 1; CRow.BorderSizePixel = 0
                CRow.Size = UDim2.new(1,0,0,ROW_H); CRow.AutoButtonColor = false; CRow.Text = ""
                local _crc = Instance.new("UICorner"); _crc.CornerRadius = UDim.new(0,5); _crc.Parent = CRow

                local RSwatch = Instance.new("Frame")
                RSwatch.Parent = CRow; RSwatch.AnchorPoint = Vector2.new(0,0.5)
                RSwatch.BackgroundColor3 = editTheme[def.key]; RSwatch.BorderSizePixel = 0
                RSwatch.Position = UDim2.new(0,10,0.5,0); RSwatch.Size = UDim2.new(0,20,0,20)
                local _rsc = Instance.new("UICorner"); _rsc.CornerRadius = UDim.new(0,4); _rsc.Parent = RSwatch
                local RSwSt = Instance.new("UIStroke"); RSwSt.Parent = RSwatch; RSwSt.Color = TH.br; RSwSt.Thickness = 1

                local RLbl = Instance.new("TextLabel")
                RLbl.Parent = CRow; RLbl.BackgroundTransparency = 1
                RLbl.Position = UDim2.new(0,38,0,0); RLbl.Size = UDim2.new(1,-110,1,0)
                RLbl.Font = Enum.Font.Gotham; RLbl.Text = def.label
                RLbl.TextColor3 = WT; RLbl.TextSize = 11; RLbl.TextXAlignment = Enum.TextXAlignment.Left

                local RHex = Instance.new("TextLabel")
                RHex.Parent = CRow; RHex.AnchorPoint = Vector2.new(1,0.5)
                RHex.BackgroundTransparency = 1; RHex.Position = UDim2.new(1,-28,0.5,0)
                RHex.Size = UDim2.new(0,56,0,14); RHex.Font = Enum.Font.GothamBold
                RHex.Text = "#"..color3ToHex(editTheme[def.key])
                RHex.TextColor3 = TH.su; RHex.TextSize = 8; RHex.TextXAlignment = Enum.TextXAlignment.Right

                local ChkIco = Instance.new("TextLabel")
                ChkIco.Parent = CRow; ChkIco.AnchorPoint = Vector2.new(1,0.5)
                ChkIco.BackgroundTransparency = 1; ChkIco.Position = UDim2.new(1,-6,0.5,0)
                ChkIco.Size = UDim2.new(0,18,0,18); ChkIco.Font = Enum.Font.GothamBold
                ChkIco.Text = "›"; ChkIco.TextColor3 = TH.ac; ChkIco.TextSize = 16; ChkIco.TextTransparency = 1

                local SelRing = Instance.new("UIStroke")
                SelRing.Parent = RSwatch; SelRing.Color = TH.ac; SelRing.Thickness = 2; SelRing.Transparency = 1

                CRow.MouseEnter:Connect(function()
                    if selIdx ~= i then tw(CRow,{BackgroundTransparency=0.92},0.12) end
                end)
                CRow.MouseLeave:Connect(function()
                    if selIdx ~= i then tw(CRow,{BackgroundTransparency=1},0.12) end
                end)

                rowEls[i] = { row=CRow, swatch=RSwatch, swStroke=RSwSt, hexLbl=RHex, checkIco=ChkIco, selRing=SelRing, key=def.key }

                onThemeChange(function(t)
                    tw(RSwSt,   {Color=t.br},  0.22)
                    tw(RHex,    {TextColor3=t.su}, 0.22)
                    tw(ChkIco,  {TextColor3=t.ac}, 0.22)
                    SelRing.Color = t.ac
                end)
            end

            -- Picker panel
            local PickerPanel = Instance.new("Frame")
            PickerPanel.Parent = Outer; PickerPanel.BackgroundColor3 = TH.cd
            PickerPanel.BorderSizePixel = 0
            PickerPanel.Position = UDim2.new(0,0,0,PREVIEW_H+4+listH+4)
            PickerPanel.Size = UDim2.new(1,0,0,0); PickerPanel.ClipsDescendants = true
            local _ppc = Instance.new("UICorner"); _ppc.CornerRadius = UDim.new(0,8); _ppc.Parent = PickerPanel
            local PickerStroke = Instance.new("UIStroke")
            PickerStroke.Parent = PickerPanel; PickerStroke.Color = TH.br; PickerStroke.Thickness = 1

            -- picker internals
            local ph, ps, pv = 0, 1, 1
            local pDrag, pHDrag = false, false

            local GradOuter2 = Instance.new("ImageLabel")
            GradOuter2.Parent = PickerPanel; GradOuter2.BackgroundColor3 = hsvToColor3(ph,1,1)
            GradOuter2.BorderSizePixel = 0; GradOuter2.Position = UDim2.new(0,10,0,10)
            GradOuter2.Size = UDim2.new(1,-20,0,110)
            GradOuter2.Image = "rbxassetid://4155801252"
            GradOuter2.ZIndex = 2
            local _go2c = Instance.new("UICorner"); _go2c.CornerRadius = UDim.new(0,6); _go2c.Parent = GradOuter2

            local PC2 = Instance.new("Frame"); PC2.Parent = GradOuter2
            PC2.AnchorPoint = Vector2.new(0.5,0.5); PC2.BackgroundColor3 = Color3.new(1,1,1)
            PC2.BorderSizePixel = 0; PC2.Position = UDim2.new(ps,0,1-pv,0)
            PC2.Size = UDim2.new(0,12,0,12); PC2.ZIndex = 5
            local _pc2c = Instance.new("UICorner"); _pc2c.CornerRadius = UDim.new(1,0); _pc2c.Parent = PC2
            local PC2St = Instance.new("UIStroke"); PC2St.Parent=PC2; PC2St.Color=Color3.new(0,0,0); PC2St.Thickness=1.5

            local GBtn2 = Instance.new("TextButton"); GBtn2.Parent = GradOuter2
            GBtn2.BackgroundTransparency = 1; GBtn2.Size = UDim2.new(1,0,1,0); GBtn2.Text = ""; GBtn2.ZIndex = 6

            local HT2 = Instance.new("TextButton"); HT2.Parent = PickerPanel
            HT2.BackgroundColor3 = Color3.new(1,1,1); HT2.BorderSizePixel = 0
            HT2.Position = UDim2.new(0,10,0,128); HT2.Size = UDim2.new(1,-20,0,10)
            HT2.AutoButtonColor = false; HT2.Text = ""
            local _ht2c = Instance.new("UICorner"); _ht2c.CornerRadius = UDim.new(1,0); _ht2c.Parent = HT2
            local HG2 = Instance.new("UIGradient"); HG2.Parent = HT2
            HG2.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,    Color3.fromRGB(255,0,0)),
                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
                ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0,255,255)),
                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
                ColorSequenceKeypoint.new(1,    Color3.fromRGB(255,0,0)),
            })

            local HK2 = Instance.new("Frame"); HK2.Parent = HT2
            HK2.AnchorPoint = Vector2.new(0.5,0.5); HK2.BackgroundColor3 = Color3.new(1,1,1)
            HK2.BorderSizePixel = 0; HK2.Position = UDim2.new(ph,0,0.5,0)
            HK2.Size = UDim2.new(0,14,0,14); HK2.ZIndex = 2
            local _hk2c = Instance.new("UICorner"); _hk2c.CornerRadius = UDim.new(1,0); _hk2c.Parent = HK2
            local HK2St = Instance.new("UIStroke"); HK2St.Parent=HK2; HK2St.Color=TH.br; HK2St.Thickness=1.5

            -- HEX / RGB labels + boxes
            local function makePLabel(text, xScale, yOff)
                local L = Instance.new("TextLabel"); L.Parent = PickerPanel
                L.BackgroundTransparency = 1; L.Position = UDim2.new(xScale,xScale==0 and 10 or 2,0,yOff)
                L.Size = UDim2.new(0.5,-12,0,12); L.Font = Enum.Font.Gotham
                L.Text = text; L.TextColor3 = TH.su; L.TextSize = 9; L.TextXAlignment = Enum.TextXAlignment.Left
                onThemeChange(function(t) tw(L,{TextColor3=t.su},0.22) end)
                return L
            end
            makePLabel("HEX", 0, 146); makePLabel("RGB", 0.5, 146)

            local function makePBox(xScale, yOff, placeholder)
                local B = Instance.new("TextBox"); B.Parent = PickerPanel
                B.BackgroundColor3 = TH.bg; B.BorderSizePixel = 0
                B.Position = UDim2.new(xScale, xScale==0 and 10 or 2, 0, yOff)
                B.Size = UDim2.new(0.5,-12,0,22); B.Font = Enum.Font.GothamBold
                B.Text = ""; B.TextColor3 = WT; B.TextSize = 10
                B.PlaceholderText = placeholder; B.ClearTextOnFocus = false
                local _bc = Instance.new("UICorner"); _bc.CornerRadius = UDim.new(0,5); _bc.Parent = B
                local BSt = Instance.new("UIStroke"); BSt.Parent=B; BSt.Color=TH.br; BSt.Thickness=1
                onThemeChange(function(t) tw(B,{BackgroundColor3=t.bg},0.22); BSt.Color=t.br end)
                return B, BSt
            end
            local HexBox2, HexSt2 = makePBox(0,   160, "#RRGGBB")
            local RgbBox2, RgbSt2 = makePBox(0.5, 160, "R,G,B")

            -- sync/update picker
            local function syncPicker()
                local nc = hsvToColor3(ph,ps,pv)
                GradOuter2.BackgroundColor3 = hsvToColor3(ph,1,1)
                PC2.Position  = UDim2.new(ps,0,1-pv,0)
                HK2.Position  = UDim2.new(ph,0,0.5,0)
                if not HexBox2:IsFocused() then HexBox2.Text = "#"..color3ToHex(nc) end
                if not RgbBox2:IsFocused() then RgbBox2.Text = color3ToRgbString(nc) end
                if selIdx >= 1 then
                    local key = colorDefs[selIdx].key
                    editTheme[key] = nc
                    if rowEls[selIdx]   then
                        tw(rowEls[selIdx].swatch, {BackgroundColor3=nc}, 0.12)
                        rowEls[selIdx].hexLbl.Text = "#"..color3ToHex(nc)
                    end
                    if previewChips[selIdx] then
                        tw(previewChips[selIdx].chip, {BackgroundColor3=nc}, 0.12)
                    end
                end
            end

            local function openPickerFor(i)
                selIdx = i
                local key = colorDefs[i].key
                ph, ps, pv = color3ToHsv(editTheme[key])
                syncPicker(); pickerOpen = true
                local totalH = PREVIEW_H+4+listH+4+PICKER_H+4
                Outer:TweenSize(UDim2.new(1,-28,0,totalH), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.28, true)
                PickerPanel:TweenSize(UDim2.new(1,0,0,PICKER_H), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.28, true)
                PickerStroke.Color = TH.ac
            end

            local function closePicker()
                pickerOpen = false; selIdx = -1
                local totalH = PREVIEW_H+4+listH+4
                Outer:TweenSize(UDim2.new(1,-28,0,totalH), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.24, true)
                PickerPanel:TweenSize(UDim2.new(1,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.24, true)
                PickerStroke.Color = TH.br
                for _, el in ipairs(rowEls) do tw(el.selRing,{Transparency=1},0.14) end
            end

            -- row click
            for i, el in ipairs(rowEls) do
                el.row.MouseButton1Click:Connect(function()
                    for j, e2 in ipairs(rowEls) do
                        e2.checkIco.TextTransparency = 1
                        tw(e2.selRing,{Transparency=1},0.14)
                        if j ~= i then tw(e2.row,{BackgroundTransparency=1},0.14) end
                    end
                    if selIdx == i then
                        tw(el.row,{BackgroundTransparency=1},0.14); closePicker()
                    else
                        el.row.BackgroundColor3 = TH.dk
                        tw(el.row,{BackgroundTransparency=0},0.15)
                        el.checkIco.TextTransparency = 0
                        tw(el.selRing,{Transparency=0},0.15)
                        openPickerFor(i)
                    end
                end)
            end

            -- drag SV
            GBtn2.InputBegan:Connect(function(inp)
                if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                pDrag = true
                local ap = GradOuter2.AbsolutePosition; local az = GradOuter2.AbsoluteSize
                ps = math.clamp((inp.Position.X-ap.X)/az.X,0,1)
                pv = math.clamp(1-(inp.Position.Y-ap.Y)/az.Y,0,1); syncPicker()
            end)
            GBtn2.InputEnded:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseButton1 then pDrag=false end
            end)

            -- drag Hue
            HT2.InputBegan:Connect(function(inp)
                if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                pHDrag = true
                local ap = HT2.AbsolutePosition; local az = HT2.AbsoluteSize
                ph = math.clamp((inp.Position.X-ap.X)/az.X,0,0.9999); syncPicker()
            end)
            HT2.InputEnded:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseButton1 then pHDrag=false end
            end)

            UserInputService.InputChanged:Connect(function(inp)
                if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
                if pDrag then
                    local ap = GradOuter2.AbsolutePosition; local az = GradOuter2.AbsoluteSize
                    ps = math.clamp((inp.Position.X-ap.X)/az.X,0,1)
                    pv = math.clamp(1-(inp.Position.Y-ap.Y)/az.Y,0,1); syncPicker()
                elseif pHDrag then
                    local ap = HT2.AbsolutePosition; local az = HT2.AbsoluteSize
                    ph = math.clamp((inp.Position.X-ap.X)/az.X,0,0.9999); syncPicker()
                end
            end)

            HexBox2.FocusLost:Connect(function()
                local c = hexToColor3(HexBox2.Text)
                if c then ph,ps,pv=color3ToHsv(c); syncPicker(); HexSt2.Color=TH.br
                else HexSt2.Color=Color3.fromRGB(240,60,60) end
            end)
            RgbBox2.FocusLost:Connect(function()
                local c = rgbStringToColor3(RgbBox2.Text)
                if c then ph,ps,pv=color3ToHsv(c); syncPicker(); RgbSt2.Color=TH.br
                else RgbSt2.Color=Color3.fromRGB(240,60,60) end
            end)

            -- Edit button (toggle list)
            local editMode = false
            EditBtn.MouseButton1Click:Connect(function()
                editMode = not editMode
                if editMode then
                    EditBtn.Text = "เสร็จ"
                    tw(EditBtn, {BackgroundColor3=TH.dk, TextColor3=TH.ac}, 0.14)
                    local h2 = PREVIEW_H+4+listH+4
                    Outer:TweenSize(UDim2.new(1,-28,0,h2), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.28, true)
                    EditList:TweenSize(UDim2.new(1,0,0,listH), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.28, true)
                    EditListStroke.Transparency = 0
                else
                    EditBtn.Text = "แก้ไข"
                    tw(EditBtn, {BackgroundColor3=TH.sl, TextColor3=TH.su}, 0.14)
                    selIdx = -1
                    for _, el in ipairs(rowEls) do
                        tw(el.row,{BackgroundTransparency=1},0.14)
                        el.checkIco.TextTransparency = 1
                        tw(el.selRing,{Transparency=1},0.14)
                    end
                    Outer:TweenSize(UDim2.new(1,-28,0,PREVIEW_H), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.24, true)
                    EditList:TweenSize(UDim2.new(1,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.24, true)
                    PickerPanel:TweenSize(UDim2.new(1,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.24, true)
                    EditListStroke.Transparency = 1; pickerOpen = false
                end
            end)
            EditBtn.MouseEnter:Connect(function() tw(EditBtn,{BackgroundColor3=TH.dk,TextColor3=TH.ac},0.14) end)
            EditBtn.MouseLeave:Connect(function()
                if not editMode then tw(EditBtn,{BackgroundColor3=TH.sl,TextColor3=TH.su},0.14) end
            end)

            onThemeChange(function(t)
                tw(TitleTx,  {TextColor3=t.ac},  0.22)
                tw(TitleLine,{BackgroundColor3=t.br}, 0.22)
                tw(EditList, {BackgroundColor3=t.cd}, 0.22)
                tw(PickerPanel,{BackgroundColor3=t.cd}, 0.22)
                EditListStroke.Color = t.br
                HK2St.Color = t.br
                PickerStroke.Color = pickerOpen and t.ac or t.br
                if not editMode then tw(EditBtn,{BackgroundColor3=t.sl,TextColor3=t.su},0.22)
                else tw(EditBtn,{BackgroundColor3=t.dk,TextColor3=t.ac},0.22) end
            end)
            -- ปุ่ม Apply
            local ApplyBtn = Instance.new("TextButton")
            ApplyBtn.Parent = Page; ApplyBtn.BackgroundColor3 = TH.ac
            ApplyBtn.BorderSizePixel = 0; ApplyBtn.Size = UDim2.new(1,-28,0,30)
            ApplyBtn.AutoButtonColor = false; ApplyBtn.Font = Enum.Font.GothamBold
            ApplyBtn.Text = "✓  ใช้สีที่แก้ไข"; ApplyBtn.TextColor3 = Color3.new(1,1,1); ApplyBtn.TextSize = 12
            local _apbc = Instance.new("UICorner"); _apbc.CornerRadius = UDim.new(0,7); _apbc.Parent = ApplyBtn
            ApplyBtn.MouseButton1Down:Connect(function() tw(ApplyBtn,{Size=UDim2.new(1,-32,0,28)},0.08,Enum.EasingStyle.Sine) end)
            ApplyBtn.MouseButton1Click:Connect(function()
                tw(ApplyBtn,{Size=UDim2.new(1,-28,0,30)},0.14,Enum.EasingStyle.Back)
                -- snapshot editTheme → TH
                local snap = {}
                for k,v in pairs(editTheme) do snap[k]=v end
                snap.name = NameBox.Text ~= "" and NameBox.Text or "Custom"
                TH = snap; fireThemeChange()
                refreshAllCards()
            end)
            onThemeChange(function(t) tw(ApplyBtn,{BackgroundColor3=t.ac},0.22) end)

            -- ── Custom grid (saved) ───────────────────────────────────
            TabFunctions.Section(self, "ธีมที่บันทึกไว้")

            local CustomGridWrap = Instance.new("Frame")
            CustomGridWrap.Name             = "CustomGrid"
            CustomGridWrap.Parent           = Page
            CustomGridWrap.BackgroundTransparency = 1
            CustomGridWrap.BorderSizePixel  = 0
            CustomGridWrap.Size             = UDim2.new(1,-28,0,0)
            CustomGridWrap.AutomaticSize    = Enum.AutomaticSize.Y

            local CustomGridLayout = Instance.new("UIGridLayout")
            CustomGridLayout.Parent      = CustomGridWrap
            CustomGridLayout.CellSize    = UDim2.new(0.31,0,0,52)
            CustomGridLayout.CellPadding = UDim2.new(0,6,0,6)
            CustomGridLayout.SortOrder   = Enum.SortOrder.LayoutOrder

            local EmptyLbl = Instance.new("TextLabel")
            EmptyLbl.Parent               = CustomGridWrap
            EmptyLbl.BackgroundTransparency = 1
            EmptyLbl.Size                 = UDim2.new(1,0,0,24)
            EmptyLbl.Font                 = Enum.Font.Gotham
            EmptyLbl.Text                 = "ยังไม่มีธีมที่บันทึก"
            EmptyLbl.TextColor3           = TH.su
            EmptyLbl.TextSize             = 10
            EmptyLbl.Visible              = #savedThemes == 0
            onThemeChange(function(t) tw(EmptyLbl,{TextColor3=t.su},0.22) end)

            -- โหลด saved themes ที่มีอยู่แล้ว
            for _, t in ipairs(savedThemes) do
                makeThemeCard(CustomGridWrap, t, true)
                EmptyLbl.Visible = false
            end
            -- ── ปุ่ม Apply + Save ─────────────────────────────────────
            TabFunctions.Section(self, "บันทึกธีม")

            -- ช่องกรอกชื่อ
            local NameWrap = Instance.new("Frame")
            NameWrap.Parent = Page; NameWrap.BackgroundTransparency = 1
            NameWrap.BorderSizePixel = 0; NameWrap.Size = UDim2.new(1,-28,0,28)
            local outlinePadding = 4

            local NameBox = Instance.new("TextBox")
            NameBox.Parent = NameWrap
            NameBox.BackgroundColor3 = TH.cd
            NameBox.BorderSizePixel = 0
            NameBox.Size = UDim2.new(0,230,1,0)
            NameBox.Position = UDim2.new(0,0,0,0)
            NameBox.Font = Enum.Font.Gotham
            NameBox.Text = ""
            NameBox.TextColor3 = WT
            NameBox.TextSize = 11
            NameBox.PlaceholderText = "ชื่อธีม..."
            NameBox.ClearTextOnFocus = false
            NameBox.ZIndex = 3

            local _nbc = Instance.new("UICorner"); _nbc.CornerRadius = UDim.new(0,7); _nbc.Parent = NameBox

            -- Outline frame (อยู่รอบๆ NameBox ไม่ใช่ตัว TextBox เอง)
            local Outline = Instance.new("Frame")
            Outline.Name = "NameOutline"
            Outline.Parent = NameWrap
            Outline.BackgroundTransparency = 1
            Outline.BorderSizePixel = 0
            Outline.Position = UDim2.new(0.004, -outlinePadding, 0.06, -outlinePadding)
            Outline.Size = UDim2.new(0, 230 + outlinePadding * 1, 1, outlinePadding * 1)
            Outline.ZIndex = 2 -- ต่ำกว่า NameBox ให้ NameBox อยู่ข้างหน้า
            local _oc = Instance.new("UICorner"); _oc.CornerRadius = UDim.new(0, 9); _oc.Parent = Outline

            local OutlineStroke = Instance.new("UIStroke")
            OutlineStroke.Parent = Outline
            OutlineStroke.Color = TH.ac
            OutlineStroke.Thickness = 1
            OutlineStroke.Transparency = 1 -- เริ่มซ่อน

            -- ให้ชื่อกล่องอยู่  ้างหน้า (ถ้าต้องการ)
            NameBox.ZIndex = 3

            local focused = false

            -- เมื่อโฟกัส: แสดงกรอบ (tween transparency และเพิ่มความหนา)
            NameBox.Focused:Connect(function()
                focused = true
                tw(OutlineStroke, {Transparency = 0}, 0.12)
                OutlineStroke.Thickness = 2

            end)

            -- เมื่อเลิกโฟกัส: ซ่อนกรอบกลับ
            NameBox.FocusLost:Connect(function()
                focused = false
                tw(OutlineStroke, {Transparency = 1}, 0.12)
                OutlineStroke.Thickness = 1
            end)

            -- อัปเดตธีม โดยเคารพสถานะ focused (ถ้าโฟกัสอยู่ให้ใช้สี accent)
            onThemeChange(function(t)
                tw(NameBox, {BackgroundColor3 = t.cd}, 0.22)
                OutlineStroke.Color = focused and t.ac or t.br
            end)
            -- ปุ่ม Save
            local SaveBtn = Instance.new("TextButton")
            SaveBtn.Parent = NameWrap; SaveBtn.BackgroundColor3 = TH.ac
            SaveBtn.BorderSizePixel = 0; SaveBtn.Size = UDim2.new(0.5,-28,0,30)
            SaveBtn.AutoButtonColor = false; SaveBtn.Font = Enum.Font.GothamBold
            SaveBtn.Text = "＋  บันทึกธีมนี้"; SaveBtn.TextColor3 = WT; SaveBtn.TextSize = 12
            SaveBtn.Position   =   UDim2.new(0,240,0,0)
            local _svbc = Instance.new("UICorner"); _svbc.CornerRadius = UDim.new(0,7); _svbc.Parent = SaveBtn

            local saveHov = false
            SaveBtn.MouseButton1Down:Connect(function() tw(SaveBtn,{Size=UDim2.new(0.5,-32,0,28)},0.08,Enum.EasingStyle.Sine) end)
            SaveBtn.MouseButton1Click:Connect(function()
                tw(SaveBtn,{Size=UDim2.new(0.5,-28,0,30)},0.14,Enum.EasingStyle.Back)
                local snap = {}
                for k,v in pairs(editTheme) do snap[k]=v end
                snap.name = NameBox.Text ~= "" and NameBox.Text or ("Custom "..tostring(#savedThemes+1))
                table.insert(savedThemes, snap)
                EmptyLbl.Visible = false
                makeThemeCard(CustomGridWrap, snap, true)
                NameBox.Text = ""
                -- flash stroke
                tw(NameStroke,{Color=TH.ac},0.12)
                task.delay(0.5, function() tw(NameStroke,{Color=TH.br},0.2) end)
            end)
            onThemeChange(function(t)
                 tw(SaveBtn,{BackgroundColor3=t.ac},0.22) 

            end)
        end

        return TabFunctions
    end

    local WindowObj = {}
    function WindowObj:Tab(...)
        return Tabs:Tab(...)
    end
    return WindowObj
end
return Library

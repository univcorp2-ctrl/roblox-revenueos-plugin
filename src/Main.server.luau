--!strict

assert(plugin, "RevenueOS must run as a Studio plugin")

local Selection = game:GetService("Selection")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = script.Parent:WaitForChild("Modules")
local Rules = require(Modules:WaitForChild("Rules"))
local Installer = require(Modules:WaitForChild("Installer"))

local toolbar = plugin:CreateToolbar("RevenueOS")
local openButton = toolbar:CreateButton("RevenueOS", "Audit and install monetization foundations", "rbxassetid://0")
openButton.ClickableWhenViewportHidden = true

local info = DockWidgetPluginGuiInfo.new(
    Enum.InitialDockState.Right,
    false,
    false,
    440,
    520,
    320,
    360
)
local widget = plugin:CreateDockWidgetPluginGuiAsync("RevenueOSWidget_v1", info)
widget.Title = "RevenueOS — Monetization Readiness"

local root = Instance.new("Frame")
root.Size = UDim2.fromScale(1, 1)
root.BackgroundColor3 = Color3.fromRGB(22, 24, 29)
root.Parent = widget

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = root

local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 12)
pad.PaddingBottom = UDim.new(0, 12)
pad.PaddingLeft = UDim.new(0, 12)
pad.PaddingRight = UDim.new(0, 12)
pad.Parent = root

local function label(text: string, height: number, bold: boolean?): TextLabel
    local item = Instance.new("TextLabel")
    item.Size = UDim2.new(1, 0, 0, height)
    item.BackgroundTransparency = 1
    item.TextColor3 = Color3.fromRGB(235, 238, 244)
    item.TextXAlignment = Enum.TextXAlignment.Left
    item.TextYAlignment = Enum.TextYAlignment.Top
    item.TextWrapped = true
    item.Font = if bold then Enum.Font.GothamBold else Enum.Font.Gotham
    item.TextSize = if bold then 18 else 14
    item.Text = text
    item.Parent = root
    return item
end

label("Ship monetization safely, then optimize it.", 26, true)
local status = label("Run an audit. RevenueOS never creates or spends paid inventory by itself.", 48)

local function button(text: string): TextButton
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 40)
    b.BackgroundColor3 = Color3.fromRGB(67, 97, 238)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.Text = text
    b.Parent = root
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    return b
end

local auditButton = button("Audit monetization readiness")
local installButton = button("Install safe monetization foundation")
local selectButton = button("Select RevenueOS config")
local report = label("", 280)

local function readConfig(): {[string]: any}?
    local module = ReplicatedStorage:FindFirstChild("RevenueOSConfig")
    if not module or not module:IsA("ModuleScript") then
        return nil
    end
    local ok, result = pcall(require, module)
    if ok and type(result) == "table" then
        return result
    end
    return nil
end

local function renderAudit()
    local findings = Rules.validateConfig(readConfig())
    local passes, warnings, failures = Rules.summarize(findings)
    status.Text = string.format("%d pass · %d warning · %d fail", passes, warnings, failures)
    local lines = {}
    for _, item in findings do
        table.insert(lines, string.format("[%s] %s", item.severity, item.message))
    end
    report.Text = table.concat(lines, "\n\n")
end

auditButton.MouseButton1Click:Connect(renderAudit)
installButton.MouseButton1Click:Connect(function()
    local changes = Installer.install()
    status.Text = if #changes > 0 then table.concat(changes, " · ") else "RevenueOS foundation already installed."
    renderAudit()
end)
selectButton.MouseButton1Click:Connect(function()
    local config = ReplicatedStorage:FindFirstChild("RevenueOSConfig")
    if config then
        Selection:Set({config})
    end
end)

openButton.Click:Connect(function()
    widget.Enabled = not widget.Enabled
    if widget.Enabled then
        renderAudit()
    end
end)

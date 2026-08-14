--!strict

local Installer = {}

local CONFIG_SOURCE = [[--!strict
return {
    ReceiptHandlerVersion = 1,
    Analytics = { Enabled = true },
    DeveloperProducts = {
        -- Example: CoinPackSmall = 1234567890,
    },
    GamePasses = {
        -- Example: VIP = 1234567890,
    },
}
]]

local RECEIPT_SOURCE = [[--!strict
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local AnalyticsService = game:GetService("AnalyticsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("RevenueOSConfig"))

local productById = {}
for key, id in Config.DeveloperProducts do
    if type(id) == "number" and id > 0 then
        productById[id] = key
    end
end

MarketplaceService.ProcessReceipt = function(receiptInfo)
    local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
    if not player then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    local productKey = productById[receiptInfo.ProductId]
    if not productKey then
        warn("[RevenueOS] Unknown developer product", receiptInfo.ProductId)
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    -- Granting must be idempotent in production. Replace this hook with your
    -- game's durable entitlement/currency grant before listing paid products.
    local grantHook = script.Parent:FindFirstChild("RevenueOSGrantHook")
    if not grantHook or not grantHook:IsA("BindableFunction") then
        warn("[RevenueOS] RevenueOSGrantHook BindableFunction missing")
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    local ok, granted = pcall(function()
        return grantHook:Invoke(player, productKey, receiptInfo)
    end)
    if not ok or granted ~= true then
        warn("[RevenueOS] Grant failed; receipt will be retried", receiptInfo.PurchaseId)
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    if Config.Analytics.Enabled then
        pcall(function()
            AnalyticsService:LogEconomyEvent(
                player,
                Enum.AnalyticsEconomyFlowType.Source,
                "RobuxPurchase",
                1,
                1,
                productKey,
                tostring(receiptInfo.ProductId)
            )
        end)
    end

    return Enum.ProductPurchaseDecision.PurchaseGranted
end
]]

local GRANT_SOURCE = [[--!strict
-- RevenueOS install-time placeholder.
-- IMPORTANT: implement durable, idempotent granting before accepting money.
-- Return true only after the entitlement/currency grant is safely recorded.
local hook = script.Parent:WaitForChild("RevenueOSGrantHook")

hook.OnInvoke = function(player, productKey, receiptInfo)
    warn("[RevenueOS] Configure grant behavior for", productKey, player.UserId)
    return false
end
]]

local function ensure(parent: Instance, className: string, name: string): Instance
    local existing = parent:FindFirstChild(name)
    if existing then
        return existing
    end
    local instance = Instance.new(className)
    instance.Name = name
    instance.Parent = parent
    return instance
end

function Installer.install(): {string}
    local changes = {}
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local serverScriptService = game:GetService("ServerScriptService")

    local config = ensure(replicatedStorage, "ModuleScript", "RevenueOSConfig") :: ModuleScript
    if config.Source == "" then
        config.Source = CONFIG_SOURCE
        table.insert(changes, "Created ReplicatedStorage/RevenueOSConfig")
    end

    local folder = ensure(serverScriptService, "Folder", "RevenueOS")
    local receipt = ensure(folder, "Script", "ReceiptProcessor") :: Script
    if receipt.Source == "" then
        receipt.Source = RECEIPT_SOURCE
        table.insert(changes, "Created ServerScriptService/RevenueOS/ReceiptProcessor")
    end

    ensure(folder, "BindableFunction", "RevenueOSGrantHook")
    local grant = ensure(folder, "Script", "GrantExample") :: Script
    if grant.Source == "" then
        grant.Source = GRANT_SOURCE
        table.insert(changes, "Created safe-deny grant hook")
    end

    return changes
end

return Installer

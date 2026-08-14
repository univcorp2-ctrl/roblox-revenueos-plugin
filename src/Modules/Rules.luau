--!strict

export type Finding = {
    severity: "PASS" | "WARN" | "FAIL",
    code: string,
    message: string,
}

local Rules = {}

local function finding(severity: "PASS" | "WARN" | "FAIL", code: string, message: string): Finding
    return { severity = severity, code = code, message = message }
end

function Rules.validateConfig(config: {[string]: any}?): {Finding}
    local out: {Finding} = {}
    if config == nil then
        table.insert(out, finding("FAIL", "CONFIG_MISSING", "RevenueOSConfig module is missing."))
        return out
    end

    local products = config.DeveloperProducts
    local passes = config.GamePasses
    local analytics = config.Analytics

    if type(products) ~= "table" or next(products) == nil then
        table.insert(out, finding("WARN", "PRODUCTS_EMPTY", "No Developer Products are configured."))
    else
        table.insert(out, finding("PASS", "PRODUCTS_OK", "Developer Products configuration found."))
    end

    if type(passes) ~= "table" or next(passes) == nil then
        table.insert(out, finding("WARN", "PASSES_EMPTY", "No Game Passes are configured."))
    else
        table.insert(out, finding("PASS", "PASSES_OK", "Game Pass configuration found."))
    end

    if type(analytics) == "table" and analytics.Enabled == true then
        table.insert(out, finding("PASS", "ANALYTICS_OK", "Revenue analytics events are enabled."))
    else
        table.insert(out, finding("FAIL", "ANALYTICS_DISABLED", "Revenue analytics must be enabled before production."))
    end

    if config.ReceiptHandlerVersion ~= 1 then
        table.insert(out, finding("FAIL", "RECEIPT_VERSION", "Receipt handler version must be 1."))
    else
        table.insert(out, finding("PASS", "RECEIPT_OK", "Receipt handler version is supported."))
    end

    return out
end

function Rules.summarize(findings: {Finding}): (number, number, number)
    local passes, warnings, failures = 0, 0, 0
    for _, item in findings do
        if item.severity == "PASS" then
            passes += 1
        elseif item.severity == "WARN" then
            warnings += 1
        else
            failures += 1
        end
    end
    return passes, warnings, failures
end

return Rules

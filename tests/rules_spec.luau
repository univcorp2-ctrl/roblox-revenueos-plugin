--!strict
local Rules = require(script.Parent.Parent.src.Modules.Rules)

local findings = Rules.validateConfig({
    ReceiptHandlerVersion = 1,
    Analytics = { Enabled = true },
    DeveloperProducts = { Coins = 1 },
    GamePasses = { VIP = 2 },
})
local pass, warn, fail = Rules.summarize(findings)
assert(pass == 4, "expected all production rules to pass")
assert(warn == 0)
assert(fail == 0)

local unsafe = Rules.validateConfig(nil)
local _, _, unsafeFailures = Rules.summarize(unsafe)
assert(unsafeFailures == 1)

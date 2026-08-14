# Studio MCP release protocol

A build is not production-ready until an active Roblox Studio session passes all gates below through the built-in Studio MCP server.

1. Open a blank test place and insert/load the built `RevenueOS.rbxm` plugin.
2. Invoke the plugin and confirm the dock widget renders without output errors.
3. Run the audit before installation; expect `CONFIG_MISSING`.
4. Click install; verify `ReplicatedStorage/RevenueOSConfig`, `ServerScriptService/RevenueOS/ReceiptProcessor`, `RevenueOSGrantHook` and `GrantExample` exist.
5. Run the audit again; analytics and receipt-version checks must pass. Empty products/passes may warn, not fail.
6. Enter Play mode. Confirm no client/server exceptions attributable to RevenueOS.
7. Verify a fake/unknown receipt cannot be acknowledged and the default grant hook returns false. Never make a real purchase during automated QA.
8. Save a screenshot and console transcript as release evidence.
9. Only after all checks pass may the artifact be promoted for Creator Store upload/update.

## Automatic repair rule

If a gate fails, the factory creates exactly one bounded repair iteration for the failing module, rebuilds, and reruns the failed gate plus regression gates. Three consecutive failures quarantine the release instead of publishing it.

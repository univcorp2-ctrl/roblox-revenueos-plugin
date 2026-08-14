from pathlib import Path

root = Path(__file__).resolve().parents[1]
required = [
    root / "src/Main.server.luau",
    root / "src/Modules/Rules.luau",
    root / "src/Modules/Installer.luau",
    root / "default.project.json",
]
for path in required:
    assert path.exists() and path.stat().st_size > 100, f"missing/incomplete: {path}"

text = (root / "src/Modules/Installer.luau").read_text(encoding="utf-8")
assert "ProcessReceipt" in text
assert "NotProcessedYet" in text
assert "PurchaseGranted" in text
assert "RevenueOSGrantHook" in text
assert "return false" in text, "default purchase grant must fail closed"

main = (root / "src/Main.server.luau").read_text(encoding="utf-8")
assert "CreateDockWidgetPluginGuiAsync" in main
assert "Audit monetization readiness" in main
print("static checks passed")

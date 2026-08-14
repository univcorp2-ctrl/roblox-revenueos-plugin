# RevenueOS for Roblox Studio

A sellable Studio plugin focused on one measurable promise: get a Roblox experience to a safer monetization-ready state in minutes, then make gaps visible before they reach players.

## Product behavior

- One-click readiness audit.
- One-click installation of a Developer Product receipt-processing foundation.
- Fails closed: purchases are **not** acknowledged until the game provides a durable, idempotent grant hook.
- Analytics instrumentation is scaffolded alongside monetization.
- No autonomous Robux/ad spend and no secrets stored in source.

## Build

Requires Rojo 7.7.0.

```bash
rojo build default.project.json -o RevenueOS.rbxm
```

The GitHub CI produces `RevenueOS.rbxm` as a downloadable artifact on every push.

## Definition of done

Code completion is not release completion. A sellable build must additionally pass the Studio MCP release protocol in `docs/STUDIO_MCP_RELEASE.md`, then be uploaded/listed through the Creator Store product workflow. Seller onboarding, identity/tax steps and any platform moderation remain external platform gates.

## Commercial wedge

The first listing should sell the outcome, not a toolbox: **Monetization readiness + safe receipt scaffold + analytics audit in under three minutes.** Subsequent releases add pass/product creation workflows, funnel instrumentation, localization QA and live-ops modules only when customer evidence supports them.

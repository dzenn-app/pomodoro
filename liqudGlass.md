

## Adaptive Glass Design System (macOS 14+ Compatible)

You are implementing a glass-style UI system in a macOS SwiftUI app that must support **macOS 14 and newer**, while adopting **Apple Liquid Glass (`.glassEffect()`) on macOS 26+** when available.

This document defines architectural, visual, performance, and accessibility rules for implementing an adaptive glass system.

---

# 1. Platform Strategy

### macOS 26+

Use native:

```
.glassEffect()
```

* Apply on a `RoundedRectangle` shape.
* Use consistent corner radius.
* Do not layer custom borders or shadows on top of native Liquid Glass.
* Allow optional tint configuration.
* Use `.interactive()` only for interactive components.

### macOS 14–15 (Fallback Mode)

You must implement a **custom glass system using SwiftUI primitives only**.

Do NOT use:

* `.glassEffect()`
* `NSVisualEffectView`
* `.ultraThinMaterial`
* heavy background blur tricks

The fallback glass must simulate translucency using layered composition.

---

# 2. Core Design Principle

Glass illusion comes from:

> Edges > Surfaces
> Layered depth > Heavy shadow
> Subtlety > Blur

Do not attempt to replicate system blur behavior.
Focus on border lighting and depth cues.

---

# 3. Custom Glass Fallback Structure

For macOS 14–15, build glass using this layered model:

### Layer 1 — Base Surface

* Semi-transparent fill
* Use low opacity (0.08–0.18)
* Color depends on dark mode or theme
* Avoid flat opaque fills

### Layer 2 — Gradient Border (Critical)

This is the most important layer.

* Use `strokeBorder`
* Thin stroke (0.5–1.0)
* Apply gradient:

  * Brighter top-left edge
  * Softer bottom-right edge
* Border must simulate light catching the rim
* Border carries the illusion of material

If the glass looks flat, improve the border — not the fill.

### Layer 3 — Subtle Highlight Overlay (Optional)

* Very subtle top edge highlight
* Low opacity
* Used only if needed for depth

### Layer 4 — Shadow (Restrained)

* Small blur radius (4–8)
* Low opacity (0.08–0.15)
* Slight positive Y offset
* Avoid heavy shadows
* Never use large radius + high opacity

Depth must feel light and floating, not muddy.

---

# 4. Animation Rules

Glass UI is often animated. Follow strict performance rules:

### Allowed

* Animate opacity
* Animate scale
* Animate position
* Use `.easeOut(duration: 0.1–0.2)`

### Avoid

* Animating shadow radius
* Animating shadow offset
* Large spring animations for hover
* Excessive compositing

Prefer:

```
.easeOut(duration: 0.15)
```

Do NOT use `.spring()` for hover states.

---

# 5. Accessibility Requirements

### Reduce Transparency

If `Reduce Transparency` is enabled:

* Fallback to solid background color
* Remove translucency
* Maintain readability
* Preserve layout

The layout must remain usable without glass effects.

Glass must enhance design, not carry the layout.

---

# 6. Dark Mode Strategy

If the glass system is dark-first:

* It is acceptable to ship dark-only initially.
* If forcing dark mode:

  * Apply `.preferredColorScheme(.dark)` at the **scene level**
  * Apply separately to `WindowGroup` and `MenuBarExtra`
  * Scene modifiers do NOT cascade.

Do not rely on view-level color scheme enforcement.

---

# 7. Performance Guidelines

When many glass components are present:

* Keep shadow values static
* Avoid `.drawingGroup()` on interactive views
* Only use `.drawingGroup()` for decorative layers
* Avoid expensive real-time blur hacks
* Keep depth cues subtle and composable

Multiple subtle cues > one heavy effect.

---

# 8. Architecture Rules

Glass styling must be encapsulated.

Do NOT:

* Scatter glass styling logic across multiple views
* Hardcode glass layers inside content views

Instead:

* Implement as `ViewModifier` or reusable component
* Centralize adaptive logic:

Pseudo-structure:

```
if #available(macOS 26, *) {
    applyLiquidGlass()
} else {
    applyCustomGlassFallback()
}
```

All glass decisions must pass through this abstraction.

---

# 9. Thematic Compatibility

* Solid themes must remain unaffected.
* Opacity slider must apply to entire panel.
* Glass tint must not double-apply opacity.
* Corner radius must remain consistent across themes.

---

# 10. Visual Testing Checklist

Before considering implementation complete:

* Test in dark mode
* Test in light mode (even if not officially supported)
* Test with Reduce Transparency enabled
* Test with multiple glass components on screen
* Test on low-power device (MacBook Air class)
* Test hover performance

If UI becomes muddy:
→ reduce shadow
→ reduce opacity
→ refine border gradient

Never increase blur.

---

# 11. Migration Plan

When macOS 26 adoption becomes dominant:

* Keep fallback for backward compatibility
* Allow runtime switching
* Do not delete fallback system prematurely
* Custom glass may remain useful for branding control

---

# 12. Summary

Liquid Glass (macOS 26+) is native and dynamic.

Fallback glass (macOS 14–15) is:

* Edge-driven
* Layered
* Subtle
* Performance-conscious
* Accessibility-aware
* Architecturally isolated

Blur is not glass.

Border lighting and restrained depth create the illusion.

---

End of skill definition.

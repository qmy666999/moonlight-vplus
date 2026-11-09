# Material 3 design system (English)

Moonlight V+ is moving its UI to a single **Material 3 (M3)** design system. The goal is not a Google demo clone: it is a consistent, accessible, maintainable skin for the host screen, app launcher, settings, and dialogs without giving up streaming-specific behaviour.

## Principles

- **Tonal first** — express hierarchy with `surface` / `surface-container` / `primary-container`, not stacked gradients and large glows.
- **One accent** — brand pink `#FF6B9D` is the default seed. The existing wallpaper-derived `BgAccent` buckets (12 hues) remain the dynamic source.
- **One theme** — Compose uses `MoonlightTheme`; screens must not create private `darkColorScheme()` wrappers.
- **Content over chrome** — cover art, host name, online state, and network quality lead.
- **Accessible by default** — 48 dp targets, the M3 type scale, font scaling, and gamepad focus rings.

## Dynamic color

Semantic roles live in `values/m3_tokens.xml` and `values-night/m3_tokens.xml`. The primary roles are intentionally indirect:

```xml
<item name="m3ColorPrimary">?attr/appAccent</item>
<item name="m3ColorPrimaryContainer">?attr/appAccentSoft</item>
```

`AppTheme.applyPalette()` applies the brand baseline, then the selected wallpaper bucket, then `MoonlightM3Overlay`. Changing theme mode, wallpaper accent, or app accent updates View and Compose surfaces together.

### Role map

| Role | Use |
| --- | --- |
| `m3_surface`, `m3_on_surface` | page background, primary text |
| `m3_surface_container_low` | host card, navigation drawer |
| `m3_surface_container` | top bar, fields, grouped surfaces |
| `m3_surface_container_high` | pressed state, search field |
| `?attr/appAccent` | primary action, focus, selection |
| `m3_primary_container` | tonal icon container |
| `m3_outline`, `m3_outline_variant` | strong/soft borders |
| `m3_on_media` | text over cover art |
| `m3_error`, `m3_success`, `m3_warning` | status semantics |

## Type, shape, motion

- `values/m3_typography.xml` mirrors the M3 baseline type scale and disables font padding.
- `values/m3_styles.xml` defines the 4/8/12/16/28 dp shape scale, component styles, and the runtime `MoonlightM3Overlay`.
- Existing `ExpressiveMotion` springs and `expressive_item_state` provide press feedback; M3 components use standard ripples and state layers.

## Compose theme

`ui/theme/MoonlightTheme.kt` exposes:

```kotlin
setContent {
    MoonlightTheme {
        // semantic MaterialTheme.colorScheme / typography / shapes
    }
}
```

- `surfaceOverride` is for floating surfaces (quick settings, action sheet, dialogs).
- `LocalMoonlightExtendedColors` carries success/warning/on-media/media-scrim tokens.
- Migrated: quick settings, action sheet, About, mouse settings, open-source notices, stick calibration.
- The in-game menu keeps its dedicated dark palette but shares M3 components and shapes; diagnostics keep their high-contrast palette.

## What changed

| Surface | Change |
| --- | --- |
| `PcView` | M3 top app bar, surface scrim, 28 dp host cards, M3 empty state, grouped scene rail |
| Host card | 64 dp artwork well, 2-line title, network-quality label, 22 dp status badge, stacked tonal surface for multi-address hosts |
| `AppView` | M3 title pill, bottom scrim, 2-line label, circular running badge |
| Settings | M3 circular menu/search buttons, 56 dp search field, rounded drawer, semantic group colours |
| Global | light/dark roles, dynamic accent, launch background, dialog surfaces, M3 button/chip/icon-button styles |

## Adding a screen

1. Use `@color/m3_surface`, `@drawable/m3_card_selector`, and `TextAppearance.Moonlight.M3.*`.
2. Use `Widget.Moonlight.M3.Button` / `.Tonal` and `Widget.Moonlight.M3.IconButton`.
3. Wrap Compose UI in `MoonlightTheme`; pass `surfaceOverride` for floating surfaces.
4. Keep 48 dp touch targets and a 2 dp `?attr/appAccent` focus ring.
5. Run `pwsh -File scripts/check-m3-tokens.ps1`.
6. Check light, dark, wallpaper-follow, 1.3x font scale, and gamepad focus.

## Staying current with upstream

Keep the redesign a **thin layer** over upstream:

- `scripts/sync-upstream.ps1` / `.sh` fetch `qiin2333/moonlight-vplus` `master`, merge into `automation/upstream-sync`, and run the token check.
- `.github/workflows/upstream-sync.yml` runs daily, updates `automation/upstream-sync`, and tries to create/update the PR. If the fork's Actions token cannot create PRs, it prints a compare link; an existing sync PR still follows the branch automatically. Conflicts fail the job loudly.

> GitHub only registers scheduled/manual workflows from the repository's **default branch**. To enable it, place this workflow on the default branch once (for example, merge it to `master`) or make `m3-redesign` the default branch. The workflow itself checks out `m3-redesign` for the merge.

```powershell
pwsh -File scripts/sync-upstream.ps1
pwsh -File scripts/sync-upstream.ps1 -Push
```

### Conflict hotspots

Prefer upstream behaviour, then re-apply the M3 role:

- `res/layout/activity_pc_view.xml`
- `res/layout/pc_grid_item.xml`
- `res/layout/app_grid_item*.xml`
- `res/values/styles.xml`
- `res/values/advance_setting_colors.xml`
- `java/com/limelight/grid/PcGridAdapter.kt`
- `java/com/limelight/utils/AppTheme.kt`

Rule of thumb: **behaviour follows upstream, visual tokens follow M3**.

## Verification

- `aapt2 compile --dir app/src/main/res` for resource syntax.
- `pwsh -File scripts/check-m3-tokens.ps1` for token/attr/style drift.
- `./gradlew :app:assembleNonRootDebug` (JDK 17, SDK 36, NDK 28, submodules, audio-haptics SDK; see README).
- Manual: light/dark/wallpaper-follow, 1.3x font scale, gamepad focus, portrait/landscape, tablet/TV.

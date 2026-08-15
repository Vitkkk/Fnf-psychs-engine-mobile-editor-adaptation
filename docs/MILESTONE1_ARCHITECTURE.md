# Milestone 1 — Mobile Editor Architecture

## Source baseline

- Upstream: `kviks/Psych-Engine-Android`
- Pinned commit: `8d84350fa92ecdf2b359492e01524385df094851`
- Upstream code identifies itself inconsistently: `MainMenuState.psychEngineVersion` reports 0.5.1 while `Project.xml` app version is 0.2.7. The pinned commit is therefore the compatibility source of truth.
- UI stack: HaxeFlixel + flixel-ui (`FlxUITabMenu`, `FlxUIInputText`, `FlxUINumericStepper`, `FlxUICheckBox`).
- Android storage root: `lime.system.System.applicationStorageDirectory` via `Main.path`.
- Mod root: `Main.path + "mods/"` via `Paths.mods()`.
- Week editor: `source/editors/WeekEditorState.hx`.
- Chart/event editor: `source/editors/ChartingState.hx`.
- Week loader: `source/WeekData.hx`.
- Character loader: `source/Character.hx`.

## Existing problems found

1. Week editor uses very small 8px text inputs and a 250x375 desktop panel.
2. Week characters and songs are primarily edited as internal-name text strings.
3. Week save uses `openfl.net.FileReference.save()` rather than writing to the active mod.
4. Chart editor uses a 300x400 desktop panel plus a virtual pad rather than touch-first chart manipulation.
5. Event editor exposes raw `Event`, `Value 1`, `Value 2` controls.
6. Chart and event save also use `FileReference.save()`.
7. Android character discovery in the existing Chart Editor falls back to preload characters only.
8. `Character.hx` itself loads mod characters only in the desktop branch, so Android mod-character previews require a compatibility fix before the visual picker can be fully reliable.
9. Existing week loading reads preload week files only and requires extending to the active mod for the new week browser.

## New architecture

New code lives under `source/mobileeditor/` and should remain editor-only.

- `MobileProjectContext`: selected project/mod and project paths.
- `MobileSafeWriter`: atomic `.tmp` write, optional `.bak`, JSON validation, autosave snapshots.
- `MobileEditorSavePaths`: canonical Psych Engine-compatible week/song/event target paths.
- `MobileAssetDiscovery`: mod-aware discovery for characters, weeks and fonts.
- `events/MobileEventDefinition`: declarative parameter schema.
- `events/MobileEventRegistry`: specific event encode/decode without a giant `if event == ...` chain.

## Event compatibility

The pinned ChartingState stores events as negative-lane chart rows:

`[strumTime, noteData(<0), eventName, value1, value2]`

The visual mobile editor must keep this serialized representation unchanged. Specific visual editors translate their form values to/from these fields.

Milestone-specific definitions:

- Change Character
- Super Flash (the flash event available in this pinned port)
- Screen Shake
- Camera Follow Pos
- Play Animation

Unknown/custom events use raw `value1`/`value2` fallback.

## Save policy

The mobile editor never requires manual JSON moving.

- Week: `mods/<CurrentMod>/weeks/<week>.json`
- Song chart: `mods/<CurrentMod>/data/<song>/<song>[-difficulty].json`
- Events: `mods/<CurrentMod>/data/<song>/events.json`
- Autosaves: `mods/<CurrentMod>/.editor/autosaves/...`

Every normal save should validate JSON, write to `<target>.tmp`, read back/validate, optionally preserve `<target>.bak`, then replace the target.

## Non-goals

Milestone 1 must not redesign unrelated editors or alter gameplay timing, note hit detection, Lua, shaders, scripts or normal mod formats.

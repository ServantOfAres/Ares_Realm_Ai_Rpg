## Project snapshot

This is a small Godot 4.5 demo project implementing a Story & AI Companion system. Main scene: `res://scenes/MainMenu.tscn`. Autoload singletons (global managers) are configured in `project.godot` and live in `autoload/`.

## Big-picture architecture (what to know quickly)
- Autoload singletons provide the app surface (global state & signals): `CompanionManager.gd`, `GameManager.gd`, `StoryManager.gd`, `UIManager.gd`, `AIAdapter.gd`.
- Companion domain:
  - Personality data and serialization: `companion/core/PersonalityCore.gd` (Resource, `to_dict()` / `from_dict()`)
  - Memory and events: `companion/core/MemorySystem.gd` (class_name `MemorySystem`, `record_event`, `to_dict()` / `from_dict()`)
  - Dialogue flow: `companion/logic/DialogueManager.gd` (short in-memory history, uses `AIAdapter` when available)
  - UI wiring: `companion/GUI/*` (e.g. `CompanionUI.gd` listens to `CompanionManager` signals and displays MessageBubble scenes).

Data flow example (UI -> AI -> UI):
- `CompanionUI.gd` calls `CompanionManager.send_message()` when the user submits text.
- `CompanionManager.send_message()` records the event via `MemorySystem`, then calls `DialogueManager.reply()`.
- `DialogueManager.reply()` builds a system+history payload and calls `AIAdapter.request_text()` if the adapter singleton exists; otherwise a local fallback reply is generated.
- Replies are recorded to memory and emitted via `CompanionManager.companion_reply` which `CompanionUI` displays.

## Key files to inspect when modifying behavior
- `autoload/CompanionManager.gd` — profile save/load, signals (`message_sent`, `companion_reply`, `portrait_updated`), portrait prompt builder
- `autoload/AIAdapter.gd` — HTTP compatibility wrapper, `request_text()` and `request_image()` implementations, `api_base` default pointing at a local model server; change here to point to your API
- `companion/logic/DialogueManager.gd` — central place for conversation shaping: history limit, system prompt construction, fallback logic
- `companion/core/PersonalityCore.gd` and `MemorySystem.gd` — serialization contract used for save/load (`to_dict()` / `from_dict()`); keep these stable or migrate carefully
- `companion/GUI/CompanionUI.gd` and `companion/GUI/MessageBubble.gd` — UI behavior and how bubbles are added/scrolled

## Project-specific conventions and patterns
- Prefer autoload singletons for cross-scene services (use get_node_or_null("/root/Name") or rely on the autoload name directly). Examples: `CompanionManager`, `AIAdapter`.
- Save format: companion profiles are `ConfigFile` at `user://companions/<name>.cfg` and last-used profile is `user://last_profile.txt`.
- Personality and Memory use explicit `to_dict()` / `from_dict()` static helpers for persistence — keep keys consistent.
- Network calls use a compatibility wrapper `_safe_request()` in `AIAdapter.gd` to support multiple Godot builds — follow the same pattern if adding HTTP usage.
- Image generation attempts common SDWebUI endpoint `/sdapi/v1/txt2img` and saves PNGs to `user://companions/portraits/`.

## Developer workflows (how to run, test, debug)
- Open the project folder in Godot 4.5. Main menu scene: `res://scenes/MainMenu.tscn`.
- Autoloads are pre-configured in `project.godot`; if adding a new autoload, edit `project.godot` or use Godot editor Project -> Project Settings -> Autoload.
- To test AI integration locally: update `autoload/AIAdapter.gd` `api_base` to your model server. The code expects a JSON API with fields like `output`, `text`, `choices`, or `message.content` — the adapter extracts common patterns.
- If the AI server is unreachable, system falls back to a simple canned reply inside `DialogueManager.reply()`; use this to run without network.

## Patterns for making changes safely
- When changing profile serialization, update both `PersonalityCore.to_dict()`/`from_dict()` and where `CompanionManager.save_profile()` writes/reads values.
- When changing message lifecycle, follow the chain: UI -> CompanionManager.send_message() -> DialogueManager.reply() -> AIAdapter.request_text() -> CompanionManager emits `companion_reply`.
- Add new signals on `CompanionManager` for cross-cutting events rather than tight coupling between scenes.

## Small examples to copy-paste
- Add a memory event when user mentions "tea":
  In `DialogueManager.reply()` after reading user_msg:
  if user_msg.to_lower().find("tea") != -1 and memory and memory.has_method("remember_preference"):
      memory.remember_preference("likes_tea", true)

- Change AI API base to localhost (example):
  Edit `autoload/AIAdapter.gd` and set `api_base = "http://127.0.0.1:11434"`

## Integration and external dependencies
- No Python/Node build tools in repo — the Godot project is self-contained. External dependency: optional local AI server or SDWebUI-compatible image server.
- Port expectations: `AIAdapter.api_base` defaults to `http://10.0.0.95:11434` — update for your environment.

## What's NOT here / gotchas
- Tests are minimal/absent. The runtime fallback in `DialogueManager` is relied upon by the UI for offline testing.
- Some older `.bak` files exist; ignore them unless restoring older behavior.

## Quick checklist for reviewers
- When changing saved data: bump profile migration or add a compatibility branch in `CompanionManager.load_profile()`.
- When adding network calls: reuse `_safe_request()` pattern in `AIAdapter.gd` to avoid method signature pitfalls across Godot versions.

If any section is unclear or you want examples expanded (signal diagrams, more file snippets, or a checklist for common tasks), tell me which part to expand and I'll iterate.

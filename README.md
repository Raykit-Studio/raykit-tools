# Raykit Tools

A Godot 4 editor plugin for people who want to stop clicking through the
Scene Tree one node at a time. Check the nodes you want, pick an action,
hit Apply — that's it.

> Looking for more? [Raykit Tools PRO](https://raykit-studio.itch.io/raykit-batch-actions-pro) lets you combine
> several actions in a single Apply, plus 12 extra actions like
> Randomize Transform, Group management, and batch Add/Remove Script.

## Features (Free)

- Show Node / Hide Node
- Enable / Disable Editable Children
- Duplicate Node — auto-detaches from the original scene link if
  duplicating an instanced scene
- Reset Transform

Every action goes through Godot's native Undo/Redo system, so Ctrl+Z
works exactly like any built-in editor action.

## Installation

1. Copy the `addons/mobile_tools` folder into your project's `addons/`
   folder (or install directly via the Godot Asset Library).
2. In Godot, go to Project → Project Settings → Globals.
3. Find the plugin in the list and switch its status to "Enable".
4. Done! Look for the "Raykit Tools" tab in the bottom panel.

## How to Use

1. Click "Select Nodes" in the bottom panel.
2. Check the nodes you want to apply an action to.
3. Click "Next", then pick one action.
4. Click "Apply".

## License

MIT License — see [LICENSE](LICENSE). Free for personal and commercial
projects.

## Want more?

This Free version applies one action at a time. [Raykit Tools PRO](https://raykit-studio.itch.io/raykit-batch-actions-pro)
adds 16 actions total and lets you combine several of them in a single
Apply — for example, Rename + Add to Group + Randomize Transform all at
once.

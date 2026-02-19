# 2D Survival Game

This is a simple 2D survival game made with Godot Engine 4.

## How to Run Locally

1.  Download [Godot Engine 4.x](https://godotengine.org/download).
2.  Open Godot and click "Import".
3.  Select the `project.godot` file in this folder.
4.  Click "Edit" to open the project.
5.  Press F5 (or the Play button) to run the game.

## How to Export for Web

1.  In Godot, go to **Project -> Export**.
2.  Click **Add...** and select **Web**.
3.  If it says "Export templates are missing", click "Manage Export Templates" and download them.
4.  Once templates are installed, go back to the Export dialog.
5.  Click **Export Project**.
6.  Create a new folder (e.g., `build/web`) and save as `index.html`.
7.  To run the web build locally, you need a local web server (because of cross-origin isolation requirements for Godot 4 Web builds).
    - You can use python: `python3 -m http.server` inside the build folder.
    - Then open `http://localhost:8000` in your browser.

## Game Controls

-   **Arrow Keys / WASD**: Move the character.
-   **Objective**: Avoid the red enemies for as long as possible!

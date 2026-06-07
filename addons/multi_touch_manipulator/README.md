# Godot Multi Touch Manipulator

![Screenshot of demo app](https://raw.githubusercontent.com/BenBergman/godot-multi-touch-manipulator/refs/heads/main/screenshots/screenshot.png)

This is a proof of concept project that demonstrates how to setup an object that can be manipulated via multi-touch. This includes setting textures externally, setting a starting bounding size, and setting a click-mask for more intuitive objects with transparency.

While this repo is intended mostly as example code, I have attempted to structure it to be usable as an addon. **I do not promise to provide support or continue development, but welcome merge requests and forks.**

I've also included a module for emulating multi-touch via mouse. Click anywhere to create a touch point. Click and drag to move the touch points around. Right click on a point to delete it. Right click outside a touch point to delete all touch points.

Double-tapping an object resets it to its original location. Double-tapping the background resets all objects. Some platforms don't properly report double-taps (e.g. Linux + Gnome). You can also press any keyboard key to reset all objects.

## Converting between Godot coordinate systems

The following resources might be helpful to understand the various coordinate systems in Godot.

- Godot documentation for [2D coordinate systems and 2D transforms](https://docs.godotengine.org/en/stable/engine_details/architecture/2d_coordinate_systems.html#doc-2d-coordinate-systems)
    - Specifically, the [transforms overview diagram](https://docs.godotengine.org/en/stable/_images/transforms_overview.webp)
- Godot documentation for [Matrices and transforms](https://docs.godotengine.org/en/stable/tutorials/math/matrices_and_transforms.html)
- 3blue1brown video on [Linear Transformations and Matrices](https://www.youtube.com/watch?v=kYB8IZa5AuE)
- 3blue1brown video on [Matrix Multiplication as Composition](https://www.youtube.com/watch?v=XkY2DOUCWMU)

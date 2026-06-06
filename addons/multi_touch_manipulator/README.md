# Godot Multi Touch Manipulator

![Screenshot of demo app](screenshot.png)

This is a proof of concept project that demonstrates how to setup an object that can be manipulated via multi-touch. This includes setting textures externally, setting a starting bounding size, and setting a click-mask for more intuitive objects with transparency.

While this repo is intended mostly as example code, I have attempted to structure it to be usable as an addon. **I do not promise to provide support or continue development, but welcome merge requests and forks.**

I've also included a module for emulating multi-touch via mouse. Click anywhere to create a touch point. Click and drag to move the touch points around. Right click on a point to delete it. Right click outside a touch point to delete all touch points.

Double-tapping an object resets it to its original location. Double-tapping the background resets all objects. Some platforms don't properly report double-taps (e.g. Linux + Gnome). You can also press any keyboard key to reset all objects.

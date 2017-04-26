# GCD and Closures example

**EjemploGCD** an iOS app made in Swift 3 and Xcode 8.

This is just a simple example to illustrate the difference between performing a heavy-load action in the foreground and in the background using **Grand Central Dispatch** and completion closures.

The user can notice the differences by downloading very large images (between 19 MB and 29 MB) from the Internet in three different ways:

- Synchronously (in the main thread).
- Asynchronously (in a background thread).
- Asynchronously (in a background thread with a completion closure).

Each of these operations will take several seconds. The user can check whether the interface is blocked or not during the operation by moving the slider on screen (this will change the alpha of the shown image).

To prevent the app from crashing due to memory issues, each downloaded image is re-escalated to a maximum size of 1920x1920 pixels before showing on screen.

### Screenshots:

<kbd> <img alt="screenshot 1" src="https://cloud.githubusercontent.com/assets/18370149/25415740/de2b6ed6-2a39-11e7-93fd-2f0865382581.jpg" width="256"> </kbd> &nbsp; <kbd> <img src="https://cloud.githubusercontent.com/assets/18370149/25415928/2d26ead2-2a3b-11e7-9626-10d699a5e735.jpg" width="256"> </kbd>

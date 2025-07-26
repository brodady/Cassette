<p align="center">
<img src = "cassette_logo_icon.png" alt = "Cassette Logo Icon")>
</p>

# Cassette

A lightweight, self-contained GML script for creating smooth animations. Cassette provides a rich collection of standard easing functions and a simple system for building complex, chainable transitions. 

Animate anything from UI elements to character movements with just a few lines of code.

## 🚀 Quickstart Guide

### 1\. Installation

Simply add the `Cassette` script to your GameMaker project.

### 2\. Usage 

In a persistent controller object, define a Cassette manager. The manager is a singleton for all animations, so you need only define it once.

I recomnmend using 'ease' for semantic clarity i.e. ease.InOutElastic(t)

```gml
// Create Event
ease = new Cassette();
```

*Note: You can toggle between frame-based and time-based animations by setting the `CASSETTE_USE_DELTA_TIME` macro at the top of the script.*

-----

### 3\. Animate\!

You can now start, stop, and get values from the static `ease` manager anywhere in your code.

To start a new animation, use `.transition()`. You can chain multiple tweens together using `.add()`.

```gml
// oPlayer :: Create Event

// Animate from current x to x+200, then hold position for 30 frames
ease.transition("player_x", x, x + 200, 60, ease.OutExpo)
    .add(x + 200, x + 200, 30, ease.InOutSine);

// Animate y position with a PingPong effect that repeats 3 times
ease.transition("player_y", y, y + 100, 90, ease.OutBounce, CASSETTE_ANIM.PingPong, 3);
```

To get the current value of an animation, use `ease.get_value()`. Apply this value in a Step or Draw event.

```gml
// oPlayer :: Step Event

// The second argument is a default value if the animation isn't active
x = ease.get_value("player_x", x);
y = ease.get_value("player_y", y);
```

-----

## 🎨 Using Custom Curves

Ease seamlessly integrates with GameMaker's built-in Animation Curves.

1.  Create an Animation Curve asset in your project (e.g., `ac_MyCurve`).
2.  Pass it to the `ease.custom()` method to prepare it for use.
3.  Use the result as the easing function in your transition.

<!-- end list -->

```gml
// Prepare your custom curve
var my_custom_ease = ease.custom(ac_MyCurve);

// Use it in a transition!
ease.transition("my_value", 0, 100, 120, my_custom_ease);

// Apply the value
my_variable = ease.get_value("my_value", my_variable);
```

-----

## 📜 License

**MIT License**

Copyright (c) 2025 Mr. Giff

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

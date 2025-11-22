<p align="center">  
<img src="cassette_logo_icon.png" alt="Cassette Logo Icon" width="128">

# **Cassette**

## **A lightweight, self-contained GML script for creating smooth animations.**

Cassette provides a rich collection of standard easing functions and a fluent interface for building complex, chainable transitions. Animate anything from UI elements and style structs to character movements and attack combos with just a few lines of code.

## **Quickstart Guide**

### **1. Installation**

Simply add the Cassette script to your GameMaker project.

### **2. Usage & Initialization**

Define a Cassette manager in your Create Event. It is recommended to name the variable ease or anim for semantic clarity (e.g., ease.InOutElastic).

*Breaking Change v2.0: Configuration is now passed into the constructor rather than using Macros.*

```gml  
// Create Event  
// new Cassette(use_seconds, auto_start, default_lerp)  
ease = new Cassette(false, false);   
```

#### **Constructor Arguments**

*All arguments are optional.*

| Argument | Type | Default | Description |
| :---- | :---- | :---- | :---- |
| use_seconds | bool | false | If true, uses delta_time (seconds). If false, uses frames. |
| auto_start | bool | false | If true, animations play immediately. If false, requires .play(). |
| default_lerp | func | lerp | Custom interpolation function to use as default for all transitions. |

### **3. Animate!**

To start a new animation, use .transition(). In v2.0, you build your animation using chainable setter methods like ```.from()```, ```.to()```, and ```.duration()```.

#### 

#### **Basic Movement**

```gml  
// Create Event  
// Animate x from current position to x+200 over 60 frames  
ease.transition("slide_right")  
    .from(x)  
    .to(x + 200)  
    .duration(60)  
    .ease(ease.OutExpo);

// Start the animation (required if auto_start was false)  
ease.play("slide_right");  
```

#### **Chaining Sequences**

Use .```next()``` to add a new track to the sequence.

New in v2.0: You can omit ```.from()``` on chained tracks. Cassette will automatically use the .to() value of the previous track as the start point.

```gml  
// Move right, wait, then move back and wait again; repeat.  
ease.transition("patrol")  
    .from(x)  
    .to(x + 200)  
    .duration(60)  
    .ease(ease.OutExpo)  
    .wait(30)           // Wait 30 frames  
    .next()             // Start next track  
    .to(x)              // Move back to original x (omitting .from)  
    .duration(60)  
    .ease(ease.InExpo)  
    .wait(30)  
    .on_sequence_end(function() {   
        ease.rewind("patrol");   
        ease.play("patrol");   
    });  
```

#### **Struct Tweening**

You can animate structs directly. Useful for colors, vectors, or other data structures.

*Note: This is not recursive. Nested structs are not supported.*

```gml
// Create Event  
my_style = { x: 10, y: 10, alpha: 1 };

ease.transition("style_anim")  
    .from(my_style)  
    .to({ x: 100, y: 50, alpha: 0 })  
    .duration(60);  
```

#### **Reactive & Staggered Animation**

Cassette includes advanced playback controls for UI polish and gameplay feel.

**Stagger** Play a group of animations with a delay between each one. Perfect for lists, menus, or cards appearing.

```gml  
// Define multiple animations  
var _keys = ["btn_1", "btn_2", "btn_3"];

for(var i = 0; i < 3; i++) {  
    ease.transition(_keys[i]).from(0).to(1).duration(30);  
}

// Trigger them with a 5 frame delay between each  
ease.stagger(_keys, 5); 

// OR Play in reverse order  
// ease.stagger(_keys, 5, true);  
```

**React** Drive the playback speed of an animation using an input value (like a joystick or mouse delta). Includes "physics" for weight.

* **Attack:** How fast the animation accelerates when input is given.  
* **Decay:** How fast it slows down when input stops.

```gml
// Create Event   

// A simple tilting image: 
// We define the full range: -15 (Left) to 15 (Right)
// We set it to .hold() so it hits the limit and stays there.
ease.transition("lean")
    .from(-15)
    .to(15)
    .duration(60)
    .hold();

// Since the range is -15 to 15, we want to start in the middle (0 degrees)
// The duration is 60, so middle is 30.
ease.seek(30, "lean");

// Step Event
var _input = keyboard_check(vk_right) - keyboard_check(vk_left);

// If input is 1 (Right): Speed is positive -> Timer goes up -> Angle goes to 15 -> Holds.
// If input is -1 (Left): Speed is negative -> Timer goes down -> Angle goes to -15 -> Holds.
// If input is 0: Speed decays to 0 -> Angle stays wherever it currently is.
ease.react("lean", _input, 0.1, 0.05, ease.OutQuad);

image_angle = ease.getValue("lean", 0);
```

## **API Reference**

### **Callback Functions**

Cassette offers granular control over events.

| Callback | Description |
| :---- | :---- |
| .onUpdate(func) | Runs every frame while the track is active. Useful for side effects. |
| .onEnd(func) | Runs when a specific *track* (segment) finishes. |
| .onSequenceEnd(func) | Runs when the *entire* transition chain finishes. |

*Note: Standard playback callbacks are also available: ```.on_play()```, ```.on_pause()```, ```.on_rewind()```, etc.*

### **Playback Controls**

Controls can be applied globally (affecting all animations) or targeted to a specific key (e.g., ease.pause("player_x")).

#### **State & Speed**

| Method | Description |
| :---- | :---- |
| .play([keys]) | Resumes a paused animation. |
| .stagger(keys, delay, [reverse]) | Plays multiple animations with a set delay between starts. |
| .react(keys, val, att, dec, [ease]) | Drives playback speed via input value with smoothing/momentum. |
| .pause([keys]) | Pauses an animation. |
| .stop(key) | Immediately stops and removes a specific animation. |
| .setSpeed(val, [keys]) | Sets playback speed (e.g., 1.0 is normal, -1.0 is reverse). |

#### **Navigation**

| Method | Description |
| :---- | :---- |
| .rewind([keys]) | Resets animation to the beginning (Track 0, Time 0). |
| .ffwd([keys]) | Jumps to the very end of the entire chain. |
| .skip([keys]) | Skips to the start of the *next* track in the chain. |
| .back([keys]) | Jumps to the start of the *previous* track. |
| .seek(val, [keys]) | Moves the timer by a specific amount (frames or seconds). |

#### **Status Checks**

```gml  
.isActive(key) // Returns true if an animation with this key exists  
.getActive() // Returns an array of active keys  
.isPaused(key) // Returns true if currently paused  
.getSpeed(key) // Returns current playback speed  
```

### **Custom Curves**

Cassette integrates with GameMaker's built-in Animation Curves.

1. Create an Animation Curve asset (e.g., ac_MyCurve).  
2. Pass it to ease.custom() to prepare it.  
3. Use the result as the easing function.

```gml  
var my_custom_ease = ease.custom(ac_MyCurve);  
ease.transition("my_value", 0, 100, 120, my_custom_ease);  
```

## **License**

**MIT License**  
Copyright (c) 2025 Mr. Giff  
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:  
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.  
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
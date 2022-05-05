# DSFAppearanceManager

![](https://img.shields.io/github/v/tag/dagronf/DSFAppearanceManager)
![](https://img.shields.io/badge/macOS-10.11+-red) 
![](https://img.shields.io/badge/Swift-5.3+-orange.svg)
![](https://img.shields.io/badge/ObjectiveC-2.0-purple.svg)

![](https://img.shields.io/badge/License-MIT-lightgrey) 
[![](https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager)

A class for simplifying macOS appearance values and detecting setting changes (Swift/Objective-C).

Supported back to macOS 10.11 with sensible fallbacks on older systems to reduce the `#available/@available` dance in your code.

## Why?

If you're performing custom drawing within your macOS app, it's important to obey the user's display and accessibility settings when performing your drawing so you can adapt accordingly.

1. On different macOS systems, the method for retrieving these values can differ (and on earlier systems are quite difficult to extract reliably). This library wraps away all these inconsistencies so your code can remain clean(er).
2. When the user changes their settings (eg. when the system changes automatically light/dark modes) I wanted my app to be notified of the change so I can update the drawing to match the new setting(s).

## Appearance

`DSFAppearanceManager` has a number of properties to simplify macOS appearance settings

### Available properties

These are the static properties available on the `DSFAppearanceManager`

| Properties                  | Description                                                       |
|-----------------------------|-------------------------------------------------------------------|
| `IsDark`                    | Is the UI currently being displayed as dark                       |
| `IsDarkMenu`                | Are the menu and dock currently being displayed as dark           |
| `AccentColor`               | The current accent color                                          |
| `HighlightColor`            | The current highlight color                                       |
| `AquaVariant`               | The current aqua variant                                          |
| `IncreaseContrast`          | The user's 'Increase Contrast' accessibility setting              |
| `DifferentiateWithoutColor` | The user's 'Differentiate without color' accessibility setting    |
| `ReduceTransparency`        | The user's 'Reduce transparency' accessibility setting            |
| `InvertColors`              | The user's 'Invert colors' accessibility setting                  |
| `ReduceMotion`              | The user's 'Reduce motion' accessibility setting                  |

So, for example, to get the current macOS highlight color, call `DSFAppearanceManager.HighlightColor`.

## Change detection

You can ask to be notified when appearance settings changes. macOS calls some methods automatically when
the appearance changes :-

### NSView

* `updateLayer`
* `drawRect(dirtyRect: NSRect)`
* `layout`
* `updateConstraints`

### NSViewController

* `updateViewConstraints`
* `viewWillLayout`
* `viewDidLayout`

but there are times where you need to manage this yourself. This is where the `ChangeDetector` class is used.

Declare a variable of type `DSFAppearanceManager.ChangeDetector()`

```swift
private let appearanceChangeDetector = DSFAppearanceManager.ChangeDetector()
```

... and set the callback block. Note that this callback is guaranteed to be called on the main thread.

```swift
appearanceChangeDetector.appearanceChangeCallback = { [weak self] change in
   // Handle the change here.
   // `change` contains the _types_ of change(s) that occurred. This might be theme, accent, contrastOrAccessibility etc
   let currentHighlightColor = DSFAppearanceManager.HighlightColor
   ...
}
```

### Change detection types

The change object indicates the type of change that occurred.

| Change type                | Description                                               |
|----------------------------|-----------------------------------------------------------|
| `theme`                    | The system appearance (eg. dark/light) changed            |
| `accent`                   | The user changed the accent color(s) eg. accent/highlight |
| `aquaVariant`              | For older macOS versions, the variant (blue, graphite)    |
| `systemColors`             | The user changed the system colors                        |
| `finderLabelColorsChanged` | The user changed finder label color(s)                    |
| `accessibility`            | The accessibility display settings changed                |

Note that the change detection class debounces changes to reduce the number of callbacks when a change occurs.
The `change` object passed in the callback block contains a set of the changes that occurred.

## Objective-C support

```objc
@interface ViewController ()
@property(nonatomic, strong) DSFAppearanceManagerChangeDetector* detector;
@end

@implementation ViewController
- (void)viewDidAppear {
   [super viewDidAppear];
   [self setDetector: [[DSFAppearanceManagerChangeDetector alloc] init]];
   [[self detector] setAppearanceChangeCallback:^(DSFAppearanceManagerChange * _Nonnull change) {
      // Change detected! Do something to update display
   }];
}
@end
```

## Centralized notifications

If you have lots and lots of little classes that need to be updated, it may be more efficient to centralize the
change notifications in a common location.

The library provides a default global (lazy) `DSFAppearanceManager.ChangeCenter.shared` object instance you can use,
or you can manage one yourself.

### DSFAppearanceManager.ChangeCenter 

The change center object `DSFAppearanceManager.ChangeCenter` generates notifications on `NotificationCenter.default`.

**Notification name:** `DSFAppearanceManager.ChangeCenter.ChangeNotification`

**Userinfo key:** `DSFAppearanceManager.ChangeCenter.ChangeObject`

You can register for notifications using the standard `addObserver` mechanisms.

#### Example

```swift
 self.observer = NotificationCenter.default.addObserver(
    forName: DSFAppearanceManager.ChangeCenter.ChangeNotification,
    object: DSFAppearanceManager.ChangeCenter.shared,
    queue: OperationQueue.main) { notification in
       let change = notification.userInfo?[DSFAppearanceManager.ChangeObject] as? DSFAppearanceManager.Change
       // Do something with 'change'
    }
```

### Registering objects using the ChangeCenter

You can register an object with a `DSFAppearanceManager.ChangeCenter` object.

The object is held weakly within the shared notifier, so if the object deinits it will automatically
deregister itself from the appearance change 

#### Example

```swift
 class LevelGauge: CustomLayer, DSFAppearanceNotifierChangeDetector {
    init() {
       DSFAppearanceManager.ChangeCenter.shared.register(self)
    }

    deinit {
       DSFAppearanceNotifier.ChangeCenter.shared.deregister(self)
    }

    func appearanceDidChange(_ change: DSFAppearanceManager.Change) {
       // Update the object
    }
 }
```

## Additional support

### `NSView` appearance drawing

`DSFAppearanceManager` provides extensions to `NSView` as a convenience for automatically handling the view's effective drawing appearance.

```swift
func drawRect(_ dirtyRect: CGRect) {
   ...
   self.performUsingEffectiveAppearance { appearance in
      // Do your drawing using 'appearance'
      // Requests for dynamic colors etc. will automatically use the correct appearance for the view.
   }
}
```

### Rolling your own dynamic `NSColor`

If you can't use the `Assets.xcassets` to store your dynamic `NSColor`s (or you want to move your app's configuration into code) you'll find that the default `NSColor` doesn't have much support for automatically handling light/dark mode changes.
 
[Dusk](https://github.com/ChimeHQ/Dusk) is a small swift framework to aid in supporting Dark Mode on macOS. It provides an `NSColor` subclass (`DynamicColor`) that automatically provides light/dark mode variants when required.

```swift
lazy var c1 = DynamicColor(name: "uniqueColorName") { (appearance) in 
    // return the color to use for this appearance
}

let c1 = DynamicColor(name: "uniqueColorName", lightColor: NSColor.white, darkColor: NSColor.black)
```

And because `DynamicColor` inherits from `NSColor`, it can be used wherever `NSColor` can be used.

## Thanks!

[`ChimeHQ`](https://github.com/ChimeHQ) for developing the awesome [dynamic NSColor subclass](https://github.com/ChimeHQ/Dusk).

## License

MIT. Use it and abuse it for anything you want, just attribute my work. Let me know if you do use it somewhere, I'd love to hear about it!

```
MIT License

Copyright (c) 2022 Darren Ford

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

# DSFAppearanceManager

![](https://img.shields.io/github/v/tag/dagronf/DSFAppearanceManager)
![](https://img.shields.io/badge/macOS-10.11+-red) 
![](https://img.shields.io/badge/Swift-5.3+-orange.svg)

![](https://img.shields.io/badge/License-MIT-lightgrey) 
[![](https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager)

A class for simplifying macOS appearance values and detecting setting changes.

## Why?

I wanted to centralize this functionality in a single place, along with automatically handling change events.

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

## Simple change detection

Declare a variable of type `DSFAppearanceManager.ChangeDetector()`

```swift
private let appearanceChangeDetector = DSFAppearanceManager.ChangeDetector()
```

... and set the callback block

```swift
appearanceChangeDetector.appearanceChangeCallback = { [weak self] manager, change in
	// Handle the change here.
	// `change` contains the _types_ of change(s) that occurred. 
	//  This might be theme, accent, contrastOrAccessibility etc
	let newColor = manager.accentColor
	...
}
```

Done!

### Change detection types

The change object will indicate the type of change that occurred.

| Change type               | Description                                               |
|---------------------------|-----------------------------------------------------------|
| `theme`                   | The system appearance (eg. dark/light) changed            |
| `accent`                  | The user changed the accent color(s) eg. accent/highlight |
| `systemColors`            | The user changed the system colors                        |
| `accentColorOrTheme`      | The user changed finder label color(s)                    |
| `contrastOrAccessibility` | The accessibility display settings changed                |

Note that the change detection class debounces changes to reduce the number of callbacks when a change occurs.  The `change` object passed in the callback block contains a set of the changes that occurred.

## NSView appearance drawing

`DSFAppearanceManager` provides extensions to the `NSView` class as a convenience for automatically handling the view's effective drawing appearance.

```swift
func performUsingEffectiveAppearance(_ block: () throws -> Void) rethrows
```

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

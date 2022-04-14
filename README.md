# DSFAppearanceManager

A class for simplifying macOS appearance values (eg. highlight color, accent color, dark mode, accessibility appearance etc).

## Appearance

`DSFAppearanceManager` has a number of properties to simplify macOS appearance settings

### Available properties

These are the properties available on the appearance manager

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

So, for example, to get the current macOS highlight color, called `DSFAppearanceManager.HighlightColor`.

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

| Change type               | Description                                               |
|---------------------------|-----------------------------------------------------------|
| `theme`                   | The system appearance (eg. dark/light) changed            |
| `accent`                  | The user changed the accent color(s) eg. accent/highlight |
| `systemColors`            | The user changed the system colors                        |
| `accentColorOrTheme`      | The user changed finder label color(s)                    |
| `contrastOrAccessibility` | The accessibility display settings changed                |

## Slightly

Define an object of type 

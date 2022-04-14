# DSFAppearanceManager

A class for handling macOS appearance change detection.

## Appearance

### Properties

These are the properties available on the theme manager

| Properties       | Description                                                                |
|------------------|----------------------------------------------------------------------------|
| `isDark`         | Is the UI currently being displayed as dark (Mojave upwards)               |
| `isDarkMenu`     | Are the menu and dock currently being displayed as dark (Yosemite upwards) |
| `accentColor`    | The current accent color                                                   |
| `highlightColor` | The current highlight color                                                |
| `aquaVariant`    | The current aqua variant                                                   |

## Simple change detection

Declare a variable of type `DSFThemeManager.ChangeDetector()`

```swift
private let appearanceChangeDetector = DSFAppearanceManager.ChangeDetector()
```

... and set the callback block

```swift
appearanceChangeDetector.themeChangeCallback = { [weak self] manager, change in
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


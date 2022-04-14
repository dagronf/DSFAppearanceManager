# DSFThemeManagement

A description of this package.


## Simple change detection



```swift

private let appearanceObserver = DSFThemeManager.ChangeDetector()
...

appearanceChangeDetector.themeChangeCallback = { [weak self] manager, change in
	// Handle the change here.
	// `change` contains the _types_ of change(s) that occurred. 
	//  This might be theme, accent, contrastOrAccessibility etc
	let newColor = manager.accentColor
	...
}



public var themeChangeCallback: ((DSFThemeManager, DSFThemeManager.Change) -> Void)?
```



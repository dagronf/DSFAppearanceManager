//
//  ViewController.swift
//  DSFAppearanceManager Demo
//
//  Created by Darren Ford on 14/4/2022.
//

import Cocoa
import DSFAppearanceManager

class ViewController: NSViewController {

	let changeDetector = DSFAppearanceManager.ChangeDetector()

	@IBOutlet weak var isDarkImage: NSImageView!

	@IBOutlet weak var isDarkMenuImage: NSImageView!

	@IBOutlet weak var accentColor: NSColorWell!
	@IBOutlet weak var highlightColor: NSColorWell!
	@IBOutlet weak var aquaVariantImage: NSImageView!

	@IBOutlet weak var increaseContrastImage: NSImageView!

	@IBOutlet weak var differentiateWithoutColorImage: NSImageView!

	@IBOutlet weak var reduceTransparencyImage: NSImageView!

	@IBOutlet weak var invertColorsImage: NSImageView!

	@IBOutlet weak var reduceMotionImage: NSImageView!

	let imageYes = NSImage(named: "image-yes")!
	let imageNo = NSImage(named: "image-no")!

	let imageAquaBlue = NSImage(named: "image-aqua-button-blue")!
	let imageAquaGraphite = NSImage(named: "image-aqua-button-graphite")!


	override func viewDidLoad() {
		super.viewDidLoad()

		self.changeDetector.appearanceChangeCallback = { [weak self] change in
			Swift.print("DSFAppearanceManager change detected - \(change)")
			self?.appearanceDidChange(change)
		}

		self.update()

	}

	func appearanceDidChange(_ change: DSFAppearanceManager.Change) {
		self.update()
	}

	func update() {
		self.view.performUsingEffectiveAppearance { appearance in
			isDarkImage.image = DSFAppearanceManager.IsDark ? imageYes : imageNo
			isDarkMenuImage.image = DSFAppearanceManager.IsDarkMenu ? imageYes : imageNo

			accentColor.color = DSFAppearanceManager.AccentColor
			highlightColor.color = DSFAppearanceManager.HighlightColor
			aquaVariantImage.image = DSFAppearanceManager.AquaVariant == .blue ? imageAquaBlue : imageAquaGraphite

			increaseContrastImage.image = DSFAppearanceManager.IncreaseContrast ? imageYes : imageNo
			differentiateWithoutColorImage.image = DSFAppearanceManager.DifferentiateWithoutColor ? imageYes : imageNo
			reduceTransparencyImage.image = DSFAppearanceManager.ReduceTransparency ? imageYes : imageNo
			invertColorsImage.image = DSFAppearanceManager.InvertColors ? imageYes : imageNo
			reduceMotionImage.image = DSFAppearanceManager.ReduceMotion ? imageYes : imageNo
		}
	}



	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}


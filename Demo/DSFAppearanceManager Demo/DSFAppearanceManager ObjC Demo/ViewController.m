//
//  ViewController.m
//  DSFAppearanceManager ObjC Demo
//
//  Created by Darren Ford on 14/4/2022.
//

#import "ViewController.h"

@import DSFAppearanceManager;

@interface ViewController ()
@property (weak) IBOutlet NSTextField *resultField;
@property(nonatomic, strong) DSFAppearanceManagerChangeDetector* detector;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	// Do any additional setup after loading the view.

}

- (void)viewDidAppear {
	[super viewDidAppear];

	[self setDetector: [[DSFAppearanceManagerChangeDetector alloc] init]];

	[[self detector] setAppearanceChangeCallback:^(DSFAppearanceManager * _Nonnull manager, DSFAppearanceManagerChange * _Nonnull change) {
		[self updateDisplay];
	}];

	[self updateDisplay];
}

- (void)updateDisplay {
	[[self resultField] setStringValue: [NSString stringWithFormat:@"%@", [DSFAppearanceManager shared]]];
}


- (void)setRepresentedObject:(id)representedObject {
	[super setRepresentedObject:representedObject];

	// Update the view, if already loaded.
}

@end

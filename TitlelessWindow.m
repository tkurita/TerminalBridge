#import "TitlelessWindow.h"


@implementation TitlelessWindow
- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
	NSWindow* result = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:bufferingType defer:flag];
    [result setLevel: NSStatusWindowLevel];
    [result setAlphaValue:0.8];
	[result center];
    return (TitlelessWindow *)result;
}
@end

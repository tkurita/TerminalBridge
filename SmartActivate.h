
#import <Cocoa/Cocoa.h>
#include <ApplicationServices/ApplicationServices.h>

@interface NSApplication (SmartActivate) 

-(BOOL)smartActivate:(NSString *)targetCreator;

@end

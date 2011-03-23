
/*-----------------------------------------------------------------------------
** This software is in the public domain, furnished "as is", without technical 
** support, and with no warranty, express or implied, as to its usefulness for
** any purpose.
**----------------------------------------------------------------------------*/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CalculatorController.h"

@interface AppDelegate: NSObject <UIApplicationDelegate>
{
    UIWindow *window;
    CalculatorController *calculatorController;
}
@end

@implementation AppDelegate

#pragma mark -
#pragma mark AppDelegate

- (void)dealloc
{
    [calculatorController release];
    [window release];
    [super dealloc];
}

#pragma mark -
#pragma mark <UIApplicationDelegate>

- (BOOL)            application:(UIApplication *)application
  didFinishLaunchingWithOptions:(NSDictionary *)withOptions
{
    // lazy instance-variable initialization
    window = [[UIWindow alloc] initWithFrame:
        CGRectOffset(
            [[UIScreen mainScreen] applicationFrame], 0,
            -[[UIApplication sharedApplication] statusBarFrame].size.height)];
    calculatorController = [[CalculatorController alloc]
            initWithNibName:nil bundle:nil];
    [window addSubview:[calculatorController view]];
    [window makeKeyAndVisible];
    return YES;
}
@end

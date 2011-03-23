/*-----------------------------------------------------------------------------
** This software is in the public domain, furnished "as is", without technical 
** support, and with no warranty, express or implied, as to its usefulness for
** any purpose.
**----------------------------------------------------------------------------*/

#import "Calculator.h"

@class UIViewController;
@class UIButton;

typedef enum {
    k0, 
    k1, k2, k3,
    k4, k5, k6,
    k7, k8, k9,
    kClear, kEqual,
    kAdd, kSub,
    kMul, kDiv,
    kDot
} TargetButton;

@interface CalculatorController: UIViewController
{
    UILabel *screen;
    Calculator *calculator;
}


- (void)initializeScreenWithFrame:(CGRect)frame;
- (void)initializeButtonWithTitle:(NSString *)title
                              tag:(NSInteger)tag
                            frame:(CGRect)frame;
- (void)action:(id)sender;
@end

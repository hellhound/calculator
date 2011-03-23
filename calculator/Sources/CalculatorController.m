/*-----------------------------------------------------------------------------
** This software is in the public domain, furnished "as is", without technical 
** support, and with no warranty, express or implied, as to its usefulness for
** any purpose.
**----------------------------------------------------------------------------*/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CalculatorController.h"

static CGFloat kScreenWidthReference = 320;
static NSUInteger kDigitLimit = 9;
static CGFloat kFontSize = 36;
static CGFloat kDxInset = .10;
static CGFloat kDyInset = .10;
static CGFloat kPadding = .02;
static NSUInteger kColumns = 4;
static NSUInteger kRows = 6;

static CGFloat kRatio;

@implementation CalculatorController

#pragma mark -
#pragma mark CalculatorController

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    if ((self = [super initWithNibName:nibName bundle:bundle]) != nil) {
        calculator = [[Calculator alloc] initWithDigitLimit:
                [NSNumber numberWithUnsignedInteger:kDigitLimit]];
        if (kRatio == 0)
            kRatio = [[UIScreen mainScreen] applicationFrame].size.width /
                    kScreenWidthReference;
    }
    return self;
}

- (void)dealloc
{
    [screen release];
    [calculator release];
    [super dealloc];
}

- (void)loadView
{
    [super loadView];

    UIView *superView = [self view];
    CGRect superFrame = [superView frame];

    [superView setBounds:CGRectInset([superView frame],
            kDxInset * superFrame.size.width,
            kDyInset * superFrame.size.height)];

    CGRect bounds = [superView bounds];
    CGFloat padding = bounds.size.height * kPadding;
    CGFloat rowWidth = bounds.size.width - padding * 2;
    CGFloat rowHeight = bounds.size.height / kRows;
    CGFloat columnWidth = bounds.size.width / kColumns; 
    CGFloat viewWidth = columnWidth - padding * 2;
    CGFloat viewHeight = rowHeight - padding * 2;
    CGFloat xRowOrigin = bounds.origin.x + padding;
    CGFloat yRowOrigin = bounds.origin.y + padding;
    CGFloat xViewOrigin = xRowOrigin;

    [self initializeScreenWithFrame:
            CGRectMake(xViewOrigin, yRowOrigin, rowWidth, viewHeight)];
    yRowOrigin += rowHeight;
    [self initializeButtonWithTitle:@"C" tag:kClear frame:
            CGRectMake(xViewOrigin, yRowOrigin, rowWidth, viewHeight)];
    yRowOrigin += rowHeight;
    // 1 2 3 /
    [self initializeButtonWithTitle:@"1" tag:k1 frame:
            CGRectMake(xViewOrigin, yRowOrigin, viewWidth, viewHeight)];
    xViewOrigin += columnWidth;
    [self initializeButtonWithTitle:@"2" tag:k2 frame:
            CGRectMake(xViewOrigin, yRowOrigin, viewWidth, viewHeight)];
    xViewOrigin += columnWidth;
    [self initializeButtonWithTitle:@"3" tag:k3 frame:
            CGRectMake(xViewOrigin, yRowOrigin, viewWidth, viewHeight)];
    xViewOrigin += columnWidth;
    [self initializeButtonWithTitle:@"/" tag:kDiv frame:
            CGRectMake(xViewOrigin, yRowOrigin, viewWidth, viewHeight)];
    yRowOrigin += rowHeight;
    // 4 5 6 *
    xViewOrigin = xRowOrigin;
    [self initializeButtonWithTitle:@"4" tag:k4 frame:
            CGRectMake(xViewOrigin, yRowOrigin, viewWidth, viewHeight)];
    xViewOrigin += columnWidth;
    [self initializeButtonWithTitle:@"5" tag:k5 frame:
            CGRectMake(xViewOrigin, yRowOrigin, viewWidth, viewHeight)];
    xViewOrigin += columnWidth;
    [self initializeButtonWithTitle:@"6" tag:k6 frame:
            CGRectMake(xViewOrigin, yRowOrigin, viewWidth, viewHeight)];
    xViewOrigin += columnWidth;
    [self initializeButtonWithTitle:@"x" tag:kMul frame:
            CGRectMake(xViewOrigin, yRowOrigin, viewWidth, viewHeight)];
    yRowOrigin += rowHeight;
    // 7 8 9 -
    xViewOrigin = xRowOrigin;
    [self initializeButtonWithTitle:@"7" tag:k7 frame:
            CGRectMake(xViewOrigin, yRowOrigin, viewWidth, viewHeight)];
    xViewOrigin += columnWidth;
    [self initializeButtonWithTitle:@"8" tag:k8 frame:
            CGRectMake(xViewOrigin, yRowOrigin, viewWidth, viewHeight)];
    xViewOrigin += columnWidth;
    [self initializeButtonWithTitle:@"9" tag:k9 frame:
            CGRectMake(xViewOrigin, yRowOrigin, viewWidth, viewHeight)];
    xViewOrigin += columnWidth;
    [self initializeButtonWithTitle:@"-" tag:kSub frame:
            CGRectMake(xViewOrigin, yRowOrigin, viewWidth, viewHeight)];
    yRowOrigin += rowHeight;
    // . 0 = +
    xViewOrigin = xRowOrigin;
    [self initializeButtonWithTitle:@"." tag:kDot frame:
            CGRectMake(xViewOrigin, yRowOrigin, viewWidth, viewHeight)];
    xViewOrigin += columnWidth;
    [self initializeButtonWithTitle:@"0" tag:k0 frame:
            CGRectMake(xViewOrigin, yRowOrigin, viewWidth, viewHeight)];
    xViewOrigin += columnWidth;
    [self initializeButtonWithTitle:@"=" tag:kEqual frame:
            CGRectMake(xViewOrigin, yRowOrigin, viewWidth, viewHeight)];
    xViewOrigin += columnWidth;
    [self initializeButtonWithTitle:@"+" tag:kAdd frame:
            CGRectMake(xViewOrigin, yRowOrigin, viewWidth, viewHeight)];
    yRowOrigin += rowHeight;
}

- (void)initializeScreenWithFrame:(CGRect)frame
{
    [screen autorelease];
    screen = [[UILabel alloc] initWithFrame:frame];
    [screen setBackgroundColor:[UIColor whiteColor]];
    [screen setTextAlignment:UITextAlignmentRight];
    [screen setFont:
            [UIFont fontWithName:@"DBLCDTempBlack" size:kFontSize *kRatio]];
    [screen setText:@"0"];
    [[self view] addSubview:screen];
}

- (void)initializeButtonWithTitle:(NSString *)title
                              tag:(NSInteger)tag
                            frame:(CGRect)frame
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];

    [[button titleLabel] setFont:
            [UIFont boldSystemFontOfSize:kFontSize * kRatio]];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor darkTextColor]
            forState:UIControlStateNormal];
    [button setFrame:frame];
    [button setTag:tag];
    [button addTarget:self action:@selector(action:)
            forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:button];
}

- (void)action:(id)sender
{
    NSInteger buttonId = [(UIButton *)sender tag];

    switch (buttonId) {
        case k0:
        case k1:
        case k2:
        case k3:
        case k4:
        case k5:
        case k6:
        case k7:
        case k8:
        case k9:
            [calculator setDigit:[NSString stringWithFormat:@"%li", buttonId]];
            break;
        case kDot:
            [calculator setDigit:@"."];
            break;
        case kClear:
            [calculator reset];
            break;
        case kEqual:
            [calculator equal];
            break;
        case kAdd:
            [calculator add];
            break;
        case kSub:
            [calculator sub];
            break;
        case kMul:
            [calculator mul];
            break;
        case kDiv:
            [calculator div];
            break;
    }
    [screen setText:[calculator output]];
}
@end

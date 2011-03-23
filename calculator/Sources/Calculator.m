/*-----------------------------------------------------------------------------
** This software is in the public domain, furnished "as is", without technical 
** support, and with no warranty, express or implied, as to its usefulness for
** any purpose.
**----------------------------------------------------------------------------*/

#import <math.h>
#import <Foundation/Foundation.h>
#import "Calculator.h"

static NSUInteger kMaximumSignificantDigits = 9;
static NSUInteger kMaximumFractionDigits = 8;

@implementation Operand

#pragma mark -
#pragma mark Operand

@synthesize value, isCompleted; // init: nil, NO

- (id)init
{
    if ((self = [super init]) != nil)
        value = [[NSMutableString string] retain];
    return self;
}

- (void)dealloc
{
    [value release];
    [super dealloc];
}

- (BOOL)hasPoint
{
    if (value == nil)
        return NO;
    return [value rangeOfString:@"."].location != NSNotFound;
}
@end

@implementation Calculator

#pragma mark -
#pragma mark Calculator

- (id)initWithDigitLimit:(NSNumber *)fromLimit
{
    if ((self = [super init]) != nil) {
        limit = [fromLimit copy]; 
        digitsLeft = [fromLimit retain];
        operandFormatter = [[NSNumberFormatter alloc] init];
        [operandFormatter setLocale:
            [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
        [operandFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [operandFormatter setMaximumSignificantDigits:
                kMaximumSignificantDigits];
        [operandFormatter setMaximumFractionDigits:kMaximumFractionDigits];
        // maximum cull for large quantities
        [operandFormatter setMaximum:
                [NSNumber numberWithInteger:
                    pow(10, kMaximumSignificantDigits) - 1]];
        // minimum cull for small quantities
        [operandFormatter setMinimum:
                [NSNumber numberWithInteger:
                    pow(10, -kMaximumSignificantDigits) + 1]];
    }
    return self;
}

- (void)dealloc
{
    [operand release];
    [accumulator release];
    [operator release];
    [limit release];
    [digitsLeft release];
    [operandFormatter release];
    [super dealloc];
}

- (NSString *)digit
{
    return nil;
}

- (void)setDigit:(NSString *)fromDigit
{
    NSUInteger scalarDigitsLeft = [digitsLeft unsignedIntegerValue];

    if (scalarDigitsLeft > 0) {
        if (operand == nil) {
            operand = [[Operand alloc] init];
        } else if ([operand isCompleted]) {
            // Set the automaton to storing state
            [operand autorelease];
            operand = [[Operand alloc] init];
            [[operand value] setString:@""];
        }

        NSMutableString *value = [operand value];

        if ([fromDigit isEqualToString:@"."]) {
            if (![operand hasPoint]) {
                if ([value length] == 0) {
                    [value setString:@"0"];
                    scalarDigitsLeft--;
                }
                [value appendString:fromDigit];
            }
        } else {
            [value appendString:fromDigit];
            scalarDigitsLeft--;
        }
        [digitsLeft autorelease];
        digitsLeft =
                [[NSNumber numberWithUnsignedInteger:scalarDigitsLeft] retain];
    }
}

- (NSString *)output
{
    // No operand, return 0
    if (operand == nil)
        return @"0";
    // Try with the accumulator
    if ([operand isCompleted])
        if (accumulator != nil)
            if ([accumulator compare:[operandFormatter maximum]] !=
                    NSOrderedDescending) {
                return [operandFormatter stringFromNumber:accumulator];
            } else {
                // The accumulator is too large a number, show NaN instead
                return @"NaN";
            }

    // The accumulator wasn't available, try with the operand

    NSString *operandValue = [operand value];
    // Returns nil if it's too large
    NSNumber *numberValue = [operandFormatter numberFromString:operandValue];

    if (numberValue == nil)
        // Woops~
        return @"NaN";

    // Extract the integer part from numberValue and use it as a proper integer
    // part
    NSString *integerPart =
            [operandFormatter stringFromNumber:
                [NSNumber numberWithInteger:[numberValue integerValue]]];
    // Find the decimal separator position
    NSRange pointRange = [operandValue rangeOfString:@"."];

    if (pointRange.location == NSNotFound)
        // No decimal separator, return numberValue with proper format
        return [operandFormatter stringFromNumber:numberValue];

    // Extract the decimal part from the operand, including the decimal
    // separator
    NSString *decimalPart =
            [operandValue substringWithRange:
                NSMakeRange(pointRange.location,
                    [operandValue length] - pointRange.location)];

    // Join numberValue's integer part with operandValue's decimal part
    return [integerPart stringByAppendingString:decimalPart];

}

- (void)reset
{
    // reset the automaton to its original state
    [operand autorelease];
    operand = nil;
    [accumulator autorelease];
    accumulator = nil;
    [operator autorelease];
    operator = nil;
    [digitsLeft autorelease];
    digitsLeft = [limit retain];
}


- (void)equal
{
    // NOP if there's no accumulator available
    if (accumulator != nil) {
        [self operate];
        [operand autorelease];
        operand = [[Operand alloc] init];
        [[operand value] setString:
                [operandFormatter stringFromNumber:accumulator]];
        [operand setIsCompleted:YES];
        [operator autorelease];
        operator = nil;
        [accumulator autorelease];
        accumulator = nil;
    }
}

- (void)add
{
    // Set the automaton as beign in an addition state
    [operator autorelease];
    operator = [[NSNumber numberWithInteger:kAddition] retain];
    [self operate];
}

- (void)sub
{
    // Set the automaton as beign in an substraction state
    [operator autorelease];
    operator = [[NSNumber numberWithInteger:kSubstraction] retain];
    [self operate];
}

- (void)mul
{
    // Set the automaton as beign in an multiplication state
    [operator autorelease];
    operator = [[NSNumber numberWithInteger:kMultiplication] retain];
    [self operate];
}

- (void)div
{
    // Set the automaton as beign in an division state
    [operator autorelease];
    operator = [[NSNumber numberWithInteger:kDivision] retain];
    [self operate];
}

- (void)operate
{
    NSNumber *operandObj = [operandFormatter numberFromString:[operand value]];

    if (accumulator == nil) {
        // Make the operand the accumulator when:
        // 1. we are first timers
        // 2. after a reset
        // 3. after calling "equal"
        accumulator = [operandObj retain];
    } else if (![operand isCompleted]) {
        double op = [operandObj doubleValue];
        double acc = [accumulator doubleValue];

        switch ([operator integerValue]) {
            case kAddition:
                acc += op;
                break;
            case kSubstraction:
                acc -= op;
                break;
            case kMultiplication:
                acc *= op;
                break;
            case kDivision:
                acc /= op;
                break;
        }
        [accumulator autorelease];
        accumulator = [[NSNumber numberWithDouble:acc] retain];
    }
    [digitsLeft autorelease];
    digitsLeft = [limit retain];
    // Set the automaton to operation-completed state
    [operand setIsCompleted:YES];
}
@end

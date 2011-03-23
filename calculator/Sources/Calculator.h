/*-----------------------------------------------------------------------------
** This software is in the public domain, furnished "as is", without technical 
** support, and with no warranty, express or implied, as to its usefulness for
** any purpose.
**----------------------------------------------------------------------------*/

@class NSObject;
@class NSMutableString;
@class NSNumber;

@interface Operand: NSObject
{
    NSMutableString *value;
    BOOL isCompleted;
}

@property (nonatomic, copy) NSMutableString *value;
@property (nonatomic, assign) BOOL isCompleted;
@property (nonatomic, readonly) BOOL hasPoint;
@end

typedef enum {
    kAddition,
    kSubstraction,
    kMultiplication,
    kDivision
} OperationType;

@interface Calculator: NSObject
{
    Operand *operand;
    NSNumber *accumulator;
    NSNumber *operator;
    NSNumber *limit;
    NSNumber *digitsLeft;
    NSNumberFormatter *operandFormatter;
}

@property (nonatomic, copy) NSString *digit;
@property (nonatomic, readonly) NSString *output;

- (id)initWithDigitLimit:(NSNumber *)fromLimit;
- (void)add;
- (void)sub;
- (void)mul;
- (void)div;
- (void)equal;
- (void)reset;
- (void)operate;
@end

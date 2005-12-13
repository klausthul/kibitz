// icsinterface
// $Id$

#import "global.h"

@interface ChessMove : NSObject {
	Board *positionAfter;
	NSString *movePrint;
	NSString *timeUsed;
}

+ (ChessMove *) moveFromStyle12: (NSArray *) data;
- (void) print;
- (Board *) positionAfter;

@end

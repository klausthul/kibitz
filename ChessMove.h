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
//+ (ChessMove *) fromString: (const char *) s;
//+ (ChessMove *) fromFieldsfrom: (struct ChessField) from to: (struct ChessField) to; 
//- (NSString *) asCoordinates;
@end

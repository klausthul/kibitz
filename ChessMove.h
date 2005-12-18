// icsinterface
// $Id$

#import "global.h"

@interface ChessMove : NSObject {
	Board *positionAfter;
	NSString *movePrint;
	NSString *timeUsed;
	enum GameRelationship gameRelationship;
}

+ (ChessMove *) moveFromStyle12: (NSArray *) data;
+ (ChessMove *) initialPosition;
- (Board *) positionAfter;
- (enum GameRelationship) gameRelationship;

@end

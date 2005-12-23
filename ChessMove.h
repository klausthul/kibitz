// icsinterface
// $Id$

#import "global.h"

@interface ChessMove : NSObject {
	unsigned char fields[64];
	enum CastleRights castleRights;
	enum Color sideToMove;
	int enPassantLine, moveCounter50Rule, whiteMaterial, blackMaterial, nextMoveNumber, 
	 whiteRemainingTime, blackRemainingTime; 
	time_t lastTimeUpdate;
	enum RunningClock runningClock;
	NSString *movePrint;
	NSString *timeUsed;
	enum GameRelationship gameRelationship;
}

+ (ChessMove *) moveFromStyle12: (NSArray *) data;
+ (ChessMove *) initialPosition;
- (void) dealloc;
- (enum GameRelationship) gameRelationship;
- (enum Color) sideToMove;
- (int) pieceLine: (int) l row: (int) r;
- (int) flipPieceLine: (int) l row: (int) r;
- (int) pieceOnField: (struct ChessField) field;
- (enum ValidationResult) validateMoveFrom: (struct ChessField) from to: (struct ChessField) to;
- (int) whiteCurrentTime;
- (int) blackCurrentTime;
- (void) stopClock;
- (enum Color) sideToMove;
- (int) moveNumber;
- (enum Color) moveColor;
- (NSString *) movePrint;

@end

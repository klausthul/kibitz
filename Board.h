// icsinterface
// $Id$

#import "global.h"
#import "ChessMove.h"

@interface Board : NSObject {
	unsigned char fields[64];
	enum CastleRights castleRights;
	enum Color sideToMove;
	int enPassantLine, moveCounter50Rule, whiteMaterial, blackMaterial, nextMoveNumber, 
	 whiteRemainingTime, blackRemainingTime; 
	time_t lastTimeUpdate;
	enum RunningClock runningClock;
}

+ (Board *) boardFromStyle12: (NSArray *) data; 
- (int) pieceLine: (int) l row: (int) r;
- (void) startPosition;
- (int) pieceOnField: (struct ChessField) field;
- (enum ValidationResult) validateMoveFrom: (struct ChessField) from to: (struct ChessField) to;
- (int) whiteCurrentTime;
- (int) blackCurrentTime;
- (void) stopClock;

@end

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
}

+ (Board *) boardFromStyle12: (NSArray *) data; 
- (int) pieceLine: (int) l row: (int) r;
- (void) startPosition;
- (void) print;
- (unsigned char) pieceOnField: (struct ChessField) field;

@end

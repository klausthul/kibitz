// icsinterface
// $Id$

#import "global.h"
#import "Board.h"
#import "ChessView.h"

@interface Game : NSObject {
	NSString *whiteName, *blackName;
	enum GameRelationship gameRelationShip;
	int initialTime, incrementTime;
	ChessMove *lastMove;
	NSString *result, *reason, *type, *ratingWhite, *ratingBlack;
	int gameNumber;
	enum Color sideShownOnBottom;
	enum GameRelationship gameRelationship;
	bool rated;
	int partnerGame;
}

- (void) setPlayerNamesWhite: (NSString *) white black: (NSString *) black;
- (NSString *) whiteName;
- (NSString *) blackName;
- (void) setTimeInitial: (int) initial increment: (int) increment;
- (int) initialTime;
- (int) incrementTime;
- (Board *) currentBoardPosition;
- (void) newMove: (ChessMove *) move;
- (void) dealloc;
- (Game *) initWithStyle12: (NSArray *) data;
- (Game *) initWithGameInfo: (NSArray *) data;
- (void) updateWithStyle12: (NSArray *) data;
- (void) updateWithGameInfo: (NSArray *) data;
- (Game *) initWithEmptyGame;
- (NSString *) gameInfoString;
- (void) setResult: (NSString *) resultV reason: (NSString *) reasonV;
- (NSString *) result;
- (NSString *) reason;
- (void) setSideShownOnBottom: (enum Color) color;
- (void) flipSideShownOnBottom;
- (enum Color) sideShownOnBottom;
- (enum GameRelationship) gameRelationship;
- (void) setDefaultBoardOrientation;
- (enum Color) sideToMove;
- (NSString *) ratingWhite;
- (NSString *) ratingBlack;
- (NSString *) type;
- (bool) rated;
- (NSString *) whiteNameRating;
- (NSString *) blackNameRating;

@end

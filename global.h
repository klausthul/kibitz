// icsinterface
// $Id$

#import <Cocoa/Cocoa.h>

@class SeekGraph;
@class ChessServerList;
@class ChessServerListControl;
@class ChessMove;
@class ChessMoveStore;
@class Board;
@class Game;
@class ChessView;
@class AppController;
@class ChessServer;
@class Seek;
@class ChessServerConnection;
@class GameWindowController;

struct ChessField {
	int row, line;
};

enum Piece {
	PAWN = 1, KNIGHT = 2, BISHOP = 3, ROOK = 4, QUEEN = 5, KING = 6
};

enum Color {
	BLACK = 8, WHITE = 0
};

#define GETPIECE(x) ((x) & 7)
#define GETCOLOR(x) ((x) & 8)

enum CastleRights {
	WHITE_LONG = 1, WHITE_SHORT = 2, BLACK_LONG = 4, BLACK_SHORT = 8
};

enum PlayerType {
	UNREGISTERED = 1,
	COMPUTER = 2,
	GM = 4,
	IM = 8,
	FM = 0x10,
	WGM = 0x20,
	WIM = 0x40,
	WFM = 0x80
};

enum RunningClock { 
	NO_CLOCK_RUNS = 0,
	WHITE_CLOCK_RUNS = 1, 
	BLACK_CLOCK_RUNS = 2 
};

enum ValidationResult {
	INVALID, VALID, REQUIRES_PROMOTION
};

enum GameRelationship {
	OBSERVER = 0,
	PLAYING_MYMOVE = 1,
	PLAYING_OPONENT_MOVE = -1,
	EXAMINER = 2,
	OBSERVING_EXAMINATION = -2,
	ISOLATED_POSITION = -3
};

@protocol ChessServerErrorHandler <NSObject>
- (void) handleStreamError: (NSError *) theError;
@end

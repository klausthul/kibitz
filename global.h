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

typedef struct {
	int row, line;
} ChessField;

enum PIECE {
	PAWN = 1, KNIGHT = 2, BISHOP = 3, ROOK = 4, QUEEN = 5, KING = 6
};

enum COLOR {
	BLACK = 8, WHITE = 0
};

#define GETPIECE(x) ((x) & 7)
#define GETCOLOR(x) ((x) & 8)

enum CASTLE_RIGHTS {
	WHITE_LONG = 1, WHITE_SHORT = 2, BLACK_LONG = 4, BLACK_SHORT = 8
};

#define min(a, b) (((a) < (b)) ? (a) : (b))

enum {
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

typedef enum {
	INVALID, VALID, REQUIRES_PROMOTION
} ValidationResult;

#import <Cocoa/Cocoa.h>
#import <ChessMove.h>
#import <ChessMoveStore.h>

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



@interface Board : NSObject {
	unsigned char fields[64];
	enum CASTLE_RIGHTS castle_rights;
	enum COLOR to_move;
	int en_passant; 
}

- (int) pieceLine: (int) l row: (int) r;
- (void) startPosition;
- (void) printBoard;
- (ChessMoveStore *) doMove: (ChessMove *) move;
- (void) undoMove: (ChessMoveStore *) move;
- (unsigned char) pieceOnField: (ChessField) field;
- (void) setBoardFromString: (char *) s flip: (int) flip;

@end

//
//  game.h
//  icsinterface
//
//  Created by Thul Klaus on 10/15/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Game;
@class ChessMoveStore;
@class ChessView;

struct _ChessField{
	int row;
	int line;
};
typedef struct _ChessField ChessField;

#import "ChessView.h"

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

@interface ChessMove : NSObject {
  @public
	char from, to, promotion;
}

+ (ChessMove *) fromString: (const char *) s;
+ (ChessMove *) fromFieldsfrom: (ChessField) from to: (ChessField) to; 
- (void) printMove;
- (NSString *) asCoordinates;
@end

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

@end

@interface ChessMoveStore : ChessMove {
  @public
	char captured, en_passant, castle_rights;
}

+ (ChessMoveStore *) newChessMoveStore: (ChessMove *) move captured: (char) cp enPassant: (int) ep castleRights: (int) cr;

@end

@interface Game : NSObject {
	Board *board;
	NSMutableArray *move_list;
	IBOutlet NSTableView *tableView;
	IBOutlet ChessView *chessView;
	int cur_move, num_half_moves;
}

- (int) pieceLine: (int) l row: (int) r;
- (Game *) init;
- (void) doMove: (ChessMove *) move;
- (void) undoMove;
- (int) goForeward;
- (IBAction) goForeward:(id) sender;
- (void) goBackward;
- (IBAction) goBackward:(id) sender;
- (void) goEnd;
- (IBAction) goEnd:(id) sender;
- (void) goStart;
- (IBAction) goStart:(id) sender;
- (void) printBoard;
- (void) printMoveList;
- (void) printGame;
- (int) numberOfRowsInTableView: (NSTableView *) aTableView;
- (id) tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;

@end

#import "global.h"
#import <ChessMove.h>

@interface ChessMoveStore : ChessMove {
  @public
	char captured, en_passant, castle_rights;
}

+ (ChessMoveStore *) newChessMoveStore: (ChessMove *) move captured: (char) cp enPassant: (int) ep castleRights: (int) cr;

@end

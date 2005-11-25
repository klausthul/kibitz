#import "ChessMoveStore.h"

@implementation ChessMoveStore

+ (ChessMoveStore *) newChessMoveStore: (ChessMove *) move captured: (char) cp enPassant: (int) ep  castleRights: (int) cr
{
	ChessMoveStore *cms = [[ChessMoveStore alloc] init];

	cms->from = move->from;
	cms->to = move->to;
	cms->promotion = move->promotion;
	cms->captured = cp;
	cms->en_passant = ep;
	cms->castle_rights = cr;
	return [cms autorelease];
}

@end


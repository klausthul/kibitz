/*
	$Id$

	Copyright 2006 Klaus Thul (klaus.thul@mac.com)
	This file is part of kibitz.

	kibitz is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by 
	the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

	kibitz is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along with kibitz; if not, write to the 
	Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

#import "global.h"
#import "Game.h"
#import "Seek.h"
#import "ChessServer.h"
#import "GameWindowController.h"
#import "PatternMatching.h"

@interface ChessServerConnection : NSObject {
	AppController *appController;
	NSMutableArray *serverWindows, *chatWindows;
	NSInputStream *serverIS;
	NSOutputStream *serverOS;
	char lineBuf[4096];
	int lastChar;
	ChessServer *currentServer;
	bool sendNamePassword, sendInit;
	NSMutableDictionary *seeks;
	NSMutableDictionary *activeGames, *infoGames;
	int storedGameCounter;
	PatternMatching *patternMatcher;
	NSMutableArray *outputLines;
	bool lastLinePartial;
	bool everConnected;
	NSTask *timeseal;
}

- (void) serverGameEnd: (NSNumber *) game result: (NSString *) result reason: (NSString *) reason;
- (void) serverIllegalMove: (NSString *) why;
- (void) processServerOutput;
- (void) stream:(NSStream *)stream handleEvent:(NSStreamEvent)event;
- (ChessServerConnection *) initWithChessServer: (ChessServer *) server appController: ac;
- (void) dealloc;
- (void) write: (unsigned char *) data maxLength: (int) i;
- (void) newSeekFromServer: (int) num description: (const char *) seekInfo;
- (void) removeSeekFromServer: (int) num;
- (int) numSeeks;
- (id) dataForSeekTable: (NSString *) x row:(int)rowIndex;
- (void) userMoveFrom: (struct ChessField) from to: (struct ChessField) to;
- (void) userMoveFrom: (struct ChessField) from to: (struct ChessField) to promotion: (int) promotionPiece;
- (void) removeAllSeeks;
- (NSString *) description;
- (void) sendSeek: (Seek *) s;
- (void) sendToServer: (NSString *) s;
- (void) sendUserInputToServer: (NSString *) s;
- (void) redisplaySeekTables;
- (void) setGameLists;
- (void) updateGame: (Game *) g;
- (void) newPlayWindow;
- (void) newChatWindow;
- (void) addOutputLine: (NSString *) tx type: (enum OutputLineType) ty info: (int) i;
+ (NSString *) findTag: (NSString *) tag in: (NSArray *) array;
- (int) lengthOutput;
- (void) chatWindowClosed: (ChatWindowController *) cwc;
- (void) gameWindowClosed: (GameWindowController *) gwc;
- (BOOL) lastWindow;
- (BOOL) isConnected;

@end

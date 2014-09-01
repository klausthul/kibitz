//
//  ChessServerConnection.h
//  Kibitz
//
//  Copyright 2014 William Entriken, licensed under the MIT license:
//  http://opensource.org/licenses/MIT
//
//  Based on Kibitz / ChessServerConnection 2006 Klaus Thul
//

#import "global.h"
#import "Game.h"
#import "Seek.h"
#import "ChessServer.h"



@interface ChessServerConnection : NSObject
@property (nonatomic) int storedGameCounter;
@property (strong, nonatomic) NSMutableArray *serverWindows;

- (ChessServerConnection *)initWithChessServer:(ChessServer *)server appController:(AppController *)controller;
- (void)switchAllSoundsOff;
- (int)numSeeks;
- (id)dataForSeekTable:(NSString *)x row:(int)rowIndex;
- (int)lengthOutput;
- (BOOL)isConnected;
- (void)sendToServer:(NSString *)s;
+ (NSString *)findTag:(NSString *)tag in:(NSArray *)array;
- (void)newSeek;
- (void)sendSeekToServer;
- (void)sendUserInputToServer:(NSString *)s;
- (void)chatWindowClosed:(ChatWindowController *)cwc;

///TODO: don't belong in this controller class
- (void)newPlayWindow;
- (void)newChatWindow;
- (BOOL)lastWindow;
- (void)gameWindowClosed:(GameWindowController *)gwc;

///TODO: these need to be specific for one game
- (void)userMoveFrom:(struct ChessField)from to:(struct ChessField)to;
- (void)userMoveFrom:(struct ChessField)from to:(struct ChessField)to promotion:(int)promotionPiece;
@end

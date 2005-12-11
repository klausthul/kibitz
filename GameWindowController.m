// icsinterface
// $Id$

#import "GameWindowController.h"


@implementation GameWindowController

- (id) initWithServerConnection: (ChessServerConnection *) sc
{
	self = [super initWithWindowNibName: @"GameWindow"];
	if (self != nil) {
		timer = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateClock:) userInfo:nil repeats:YES] retain];
		serverConnection = sc;
	}
	return self;
}

- (void) addToServerOutput: (NSString *) s
{
	NSRange r = { [[serverOutput string] length], 0 };
	[serverOutput replaceCharactersInRange:r withString:s];	
}

- (void) controlTextDidEndEditing:(NSNotification *)aNotification
{
	NSString *input = [serverInput stringValue];
	const char *s = [input UTF8String];
	NSLog([serverInput stringValue]);
	if (strlen(s) > 0)
		[serverConnection write:(unsigned char *) s maxLength:strlen(s)];
	[serverConnection write:(unsigned char *) "\n\r" maxLength:2];
}

- (void) userMoveFrom: (ChessField) from to: (ChessField) to
{
	move[0] = from.line + 'a' - 1;
	move[1] = from.row + '1' - 1;
	move[2] = '-';
	move[3] = to.line  + 'a' - 1;
	move[4] = to.row + '1' - 1;
	move[5] = '\n';
	move[6] = 0;
//	if ([game moveValidationFrom: from to: to] == REQUIRES_PROMOTION) {
//		[NSApp beginSheet:promotionPiece modalForWindow:mainWindow modalDelegate:self didEndSelector:NULL contextInfo:NULL];
//	} else {
//		[serverConnection write:(unsigned char *) move maxLength:6 ];
//	}
} 

- (IBAction) selectedPromotionPiece: (id) sender
{
	[promotionPiece orderOut:sender];
	move[5] = '=';
	move[6] = " QRNB"[[(NSButton *) sender tag]];
	move[7] = '\n';
	move[8] = 0;
	[NSApp endSheet:promotionPiece returnCode: 1];
	printf("USERMOVE: %s\n", move);
	[serverConnection write:(unsigned char *) move maxLength:8 ];
}

- (IBAction) toggleSeekDrawer: (id) sender
{
	[seekDrawer toggle:sender];
}

- (void) updateClock: (NSTimer *) aTimer
{
//	[game updateClocks];
}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)proposedFrameSize
{
	NSSize s = [sender frame].size;
	float delta = min(proposedFrameSize.width - s.width, proposedFrameSize.height - s.height);
	s.width += delta;
	s.height += delta;
	return s;
}

- (void) dealloc
{
	[timer release];
	[serverConnection release];
	[super dealloc];
}


@end

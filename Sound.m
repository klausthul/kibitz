// icsinterface
// $Id: Seek.m 32 2005-12-11 15:40:55Z kthul $

#import "Sound.h"

NSString *soundNames[NUMBER_OF_SOUNDS] = {
	[SOUND_MOVE_SELF] = @"SoundMoveSelf",
	[SOUND_MOVE_OPPONENT] = @"SoundMoveOther",
	[SOUND_MOVE_ACTIVE] = @"SoundMoveOther",
	[SOUND_MOVE_OTHER] = @"SoundMoveOther",
	[SOUND_GAME_START_OWN] = @"SoundNewGame",
	[SOUND_GAME_START_OTHER] = @"SoundNewGame",
	[SOUND_GAME_END_OWN] = @"SoundGameEnd",
	[SOUND_GAME_END_OTHER] = @"SoundGameEnd"
};

bool soundPlayDefaults[NUMBER_OF_SOUNDS] = { YES, YES, YES, NO, YES, NO, YES, NO };

@implementation Sound

- (Sound *) init
{
	if ((self = [super init]) != nil) {
		int i;
		for (i = 0; i < NUMBER_OF_SOUNDS; i++) {
			sounds[i] = [[NSSound soundNamed: soundNames[i]] retain];
			playFlag[i] = soundPlayDefaults[i];
		}
	}
	return self;
}

- (void) playSound: (enum SoundTypes) type
{
	if ((sounds[type] != nil) && playFlag[type])
		[sounds[type] play];
}

- (void) dealloc
{
	int i;
	for (i = 0; i < NUMBER_OF_SOUNDS; i++)
		[sounds[i] release];	
	[super dealloc];
}

@end

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

#define NUMBER_OF_SOUNDS 8

enum SoundTypes {
	SOUND_MOVE_SELF,
	SOUND_MOVE_OPPONENT,
	SOUND_MOVE_ACTIVE,
	SOUND_MOVE_OTHER,
	SOUND_GAME_START_OWN,
	SOUND_GAME_START_OTHER,
	SOUND_GAME_END_OWN,
	SOUND_GAME_END_OTHER,
	SOUND_MESSAGE
};


@interface Sound : NSObject {
	NSSound *sounds[NUMBER_OF_SOUNDS];
	bool playFlag[NUMBER_OF_SOUNDS];
}

- (Sound *) init;
- (void) playSound: (enum SoundTypes) type;
- (void) dealloc;
- (void) gameEnd: (enum GameRelationship) r;
- (void) newGame: (enum GameRelationship) r;
- (void) move: (enum GameRelationship) r;

@end

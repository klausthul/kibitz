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

#import "PlayView.h"

@implementation PlayView

- (void) resizeWithOldSuperviewSize: (NSSize) oldBoundsSize
{
	NSRect f2 = [[self superview] frame], f;
	f.size.height = fminf(f2.size.height, f2.size.width - 97);
	f.size.width = f.size.height + 97;
	f.origin.x = 0;
	f.origin.y = f2.size.height - f.size.height;		
	[self setFrame: f];
}

- (float) maxWidthForHeight
{
	return [self frame].size.height + 97;
}

- (float) maxWidthForHeight: (float) height
{
	return height + 97;
}

- (float) maxHeightForWidth
{
	return [self frame].size.width - 97;
}

@end

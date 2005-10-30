//
//  Seek.h
//  icsinterface
//
//  Created by Thul Klaus on 10/23/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum {
	UNREGISTERED = 1,
	COMPUTER = 2,
	GM = 4,
	IM = 8,
	FM = 0x10,
	WGM = 0x20,
	WIM = 0x40,
	WFM = 0x80
};

@interface Seek : NSObject {
	@public
	NSString *nameFrom;
	int title;
	int ratingValue;
	char ratingStatus;
	int timeStart;
	int timeIncrement;
	bool rated;
	char wantsColor;
	NSString *typeOfPlay;
	bool automatic;
	bool formulaChecked;
	int ratingRangeLow;
	int ratingRangeHigh;
}

+ (Seek *) seekFromSeekInfo: (const char *) seekInfo;
- (void) dealloc;

@end

@interface SeekGraph : NSObject {
	NSMutableDictionary *seeks;
	IBOutlet NSTableView *seekTable;
}

- (void) newSeekFromServer: (int) num description: (const char *) seekInfo;
- (void) removeSeekFromServer: (int) num;
- (SeekGraph *) init;
- (int) numberOfRowsInTableView: (NSTableView *) aTableView;
- (id) tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;

@end

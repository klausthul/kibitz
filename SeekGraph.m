#import "SeekGraph.h"

@implementation SeekGraph

- (void) newSeekFromServer: (int) num description: (const char *) seekInfo
{
	NSEnumerator *keyEnumerator;
	NSNumber *key;
	Seek *s = [Seek seekFromSeekInfo: seekInfo];
	if (s != nil) {
		[seeks setObject: s forKey: [NSNumber numberWithInt: num]];
		keyEnumerator = [seeks keyEnumerator];
		while ((key = [keyEnumerator nextObject]) != nil) {
			s = [seeks objectForKey:key];
			printf("%d: %s\n", [key intValue], [s->nameFrom cString]);
		}
		[seekTable setNeedsDisplay:TRUE];
	} else
		NSLog(@"Error in Seek request");
}

- (void) removeSeekFromServer: (int) num
{
	[seeks removeObjectForKey: [NSNumber numberWithInt: num]];
	[seekTable setNeedsDisplay:TRUE];
}

- (SeekGraph *) init
{
	seeks = [NSMutableDictionary dictionaryWithCapacity:500];
	[seeks retain];
	[super init];
	return self;
}

- (void) dealloc
{
	[seeks release];
	[super dealloc];
}

- (int) numberOfRowsInTableView: (NSTableView *) aTableView
{
	return [seeks count];
}

- (id) tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
{
	NSNumber *key = [[seeks allKeys] objectAtIndex: rowIndex];
	NSString *x = [aTableColumn identifier];
	if ([x compare: @"#"] == 0) {
		return key;
	} else {
		Seek *s = [seeks objectForKey:key];
		if ([x compare: @"Name"] == 0) {
			return s->nameFrom;
		} else if ([x compare: @"Rating"] == 0) {
			return [NSNumber numberWithInt:s->ratingValue];
		} else if ([x compare: @"Type"] == 0) {
			return s->typeOfPlay;
		} else
			return nil;
	}
}

@end


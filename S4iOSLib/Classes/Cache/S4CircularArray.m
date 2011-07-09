//
//  S4CircularArray.m
//  hjlib
//
//  Copyright Hunter and Johnson 2009, 2010, 2011
//  HJCache may be used freely in any iOS or Mac application free or commercial.
//  May be redistributed as source code only if all the original files are included.
//  See http://www.markj.net/hjcache-iphone-image-cache/

#import "S4CircularArray.h"



#define MIN_CAPACITY						20


@implementation S4CircularArray

+ (id)circularArrayWithCapacity: (NSUInteger)numItems
{
	return [[[S4CircularArray alloc] initWithCapacity: numItems] autorelease];
}



- (id)initWithCapacity: (NSUInteger)numItems
{
	NSNull					*nullObject;
	NSUInteger				count;

	self = [super init];
	if (nil != self)
	{
		if (0 >= numItems)
		{
			count = MIN_CAPACITY;
		}
		else
		{
			count = numItems;
		}
		buffer = [[[NSMutableArray alloc] initWithCapacity: count] retain];
		nextIndex = 0;
		nullObject = [NSNull null];
		while (0 < count)
		{
			[buffer addObject: nullObject];
			count--;
		}
	}
	return (self);
}


- (void)dealloc
{
	[buffer release];

	[super dealloc];
}


- (NSUInteger)count
{
	return ([buffer count]);
}


- (id)addObject: (id)newObject
{
	id						replacedObject;

	replacedObject = [self swapObject: newObject atIndex: nextIndex];
	if ((nextIndex + 1) < [buffer count])
	{
		nextIndex++;
	}
	else
	{ 
		nextIndex = 0;
	}
	return (replacedObject);
}


- (id)swapObject: (id)anObject atIndex: (NSUInteger)idx
{
	id						swappedObject;
	id						idResult = nil;

	swappedObject = [buffer objectAtIndex: idx];
	if (swappedObject != [NSNull null])
	{
		//because when old objObj replaced in the buffer, it will be released and might dealloc:
		[swappedObject retain];
		[swappedObject autorelease];
		idResult = swappedObject;
	}
	[buffer replaceObjectAtIndex: nextIndex withObject: anObject];
	return (idResult);
}


-(int)findIndexOfObject:(id)key {
	NSNull* nullObj = [NSNull null];
	id anObject;
	int i = nextIndex-1; //start looking at the last object
	if (i<0) { i=0; }
	for (int n = [buffer count]-1; n>=0; n--)
	{
		if (i<0)
		{ 
			i=[buffer count]-1;  //i has to wrap around to the end of the buffer array
		}
		anObject = [buffer objectAtIndex:i];
		if (anObject!=nullObj) {
			BOOL result = [anObject isEqual:key];
			if (result) {
				return i;
			}
		}
		i--; 
	}
	return -1;
}

-(id)findObject:(id)key {
	int i = [self findIndexOfObject:key];
	if (i<0) { 
		return nil;
	}
	return [self objectAtIndex:i];
}

-(id)objectAtIndex:(int)i {
	id anObject = [buffer objectAtIndex:i];
	if (anObject==[NSNull null]) { 
		return nil; 
	}
	return anObject;
}

-(void)removeObjectAtIndex:(int)i {
	[buffer replaceObjectAtIndex:i withObject:[NSNull null]];
}	

-(void)removeObject:(id)key {
	int i = [self findIndexOfObject:key];
	if (i<0) {
		return; 
	}
	//NSLog(@"remove at index %i",i);
	[self removeObjectAtIndex:i];
}

-(NSArray*)allObjects {
	NSMutableArray* all = [NSMutableArray arrayWithCapacity:[buffer count]];
	for (id anObject in buffer) {
		if (![anObject isKindOfClass:[NSNull class]]) {
			[all addObject:anObject];
		}
	}
	return all;
}

@end

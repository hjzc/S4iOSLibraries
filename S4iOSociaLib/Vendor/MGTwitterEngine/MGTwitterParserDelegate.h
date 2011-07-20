//
//  MGTwitterParserDelegate.h
//  MGTwitterEngine
//
//  Created by Matt Gemmell on 18/02/2008.
//  Copyright 2008 Instinctive Code.
//

#import "MGTwitterEngineGlobalHeader.h"

#import "MGTwitterRequestTypes.h"

@protocol MGTwitterParserDelegate

@required

- (void)parsingSucceededForRequest:(NSString *)identifier 
                    ofResponseType:(MGTwitterResponseType)responseType 
                 withParsedObjects:(NSArray *)parsedObjects;

- (void)parsingFailedForRequest:(NSString *)requestIdentifier 
                 ofResponseType:(MGTwitterResponseType)responseType 
                      withError:(NSError *)error;

@optional

- (void)parsedObject:(NSDictionary *)parsedObject forRequest:(NSString *)identifier 
                    ofResponseType:(MGTwitterResponseType)responseType;

@end

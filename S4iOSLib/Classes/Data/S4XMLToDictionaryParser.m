/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is the S4 iOS Libraries.
 *
 * The Initial Developer of the Original Code is
 * Michael Papp dba SeaStones Software Company.
 * All software created by the Initial Developer are Copyright (C) 2008-2010
 * the Initial Developer. All Rights Reserved.
 *
 * Original Author:
 *			Michael Papp, San Francisco, CA, USA
 *
 * ***** END LICENSE BLOCK ***** */

/* ***** FILE BLOCK ******
 *
 * Name:		S4XMLToDictionaryParser.m
 * Module:		Data
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <UIKit/UIKit.h>
#import "S4XMLToDictionaryParser.h"
#import "S4NetUtilities.h"
#import "S4FileUtilities.h"
#import "S4NetworkAccess.h"
#import "S4CommonDefines.h"
#import "S4OperationsHandler.h"


// =================================== Defines =========================================

#define DEFAULT_STRING_SZ						32
#define GENERIC_REACHABILITY_URL				@"www.yahoo.com"
#define DEFAULT_DICTIONARY_SZ					(NSUInteger)16

#define MAX_READ_BYTES							(NSUInteger)32768
#define MAX_READ_BUFFER_SZ						sizeof(uint8_t) * MAX_READ_BYTES

#define XML_PREFIX_SEPARATOR_STR				@"%@:%@"

// ALL S4 LIBS SHOULD DEFINE THIS:
#define LIB_DOMAIN_NAME_STR						@"S4XMLToDictionaryParser"


// ================================== Typedefs =========================================



// =================================== Globals =========================================



// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================

//============================================================================
//	startDocumentSAX
//		This callback is invoked when the parser begins parsing.
//
//	Params
//		userData:			the user data (XML parser context)
//
//============================================================================
static void startDocumentSAX(void *userData)
{
}


//============================================================================
//	endDocumentSAX
//		This callback is invoked when the parser ends parsing.
//
//	Params
//		userData:			the user data (XML parser context)
//
//============================================================================
static void endDocumentSAX(void *userData)
{
}


//============================================================================
//	startElementSAX
//		This callback is invoked when the parser finds the beginning
//		of a node in the XML.  Child nodes use a namespace prefix
//
//	Params
//		userData:			the user data (XML parser context)
//		name:				the local name of the element
//		prefix:				the element namespace prefix if available
//		uri:				the element namespace name if available
//		nb_namespaces:		number of namespace definitions on that node
//		namespaces:			pointer to the array of prefix/URI pairs namespace definitions
//		nb_attributes:		the number of attributes on that node
//		nb_defaulted:		the number of defaulted attributes. The defaulted ones are at the end of the array
//		attributes:			pointer to the array of (localname/prefix/URI/value/end) attribute values
//
//============================================================================
static void startElementSAX(void *userData,
							const xmlChar *name,
							const xmlChar *prefix,
							const xmlChar *uri, 
                            int nb_namespaces,
							const xmlChar **namespaces,
							int nb_attributes,
							int nb_defaulted,
							const xmlChar **attributes)
{
	S4XMLToDictionaryParser					*parser;

	parser = (S4XMLToDictionaryParser *)userData;
	if (IS_NOT_NULL(parser))
	{
		[parser didStartElement: name withPrefix: prefix withURI: uri];
	}
}


//============================================================================
//	endElementSAX
//		This callback is invoked when the parse reaches the end of a node
//
//	Params
//		userData:		the user data (XML parser context)
//		name:			the local name of the element
//		prefix:			the element namespace prefix if available
//		uri:			the element namespace name if available
//
//============================================================================
static void	endElementSAX(void *userData, const xmlChar *name, const xmlChar *prefix, const xmlChar *uri)
{
	S4XMLToDictionaryParser					*parser;

	parser = (S4XMLToDictionaryParser *)userData;
	if (IS_NOT_NULL(parser))
	{
		[parser didEndElement: name withPrefix: prefix withURI: uri];
	}
}


//============================================================================
//	charactersFoundSAX
//		This callback is invoked when the parser encounters character
//		data inside a node
//
//	Params
//		userData:		the user data (XML parser context)
//		charArray:		a xmlChar string
//		length:			the number of xmlChar
//
//============================================================================
static void	charactersFoundSAX(void *userData, const xmlChar *charArray, int length)
{
	S4XMLToDictionaryParser					*parser;

	parser = (S4XMLToDictionaryParser *)userData;
	if (IS_NOT_NULL(parser))
	{
		[parser foundCharacters: charArray numBytes: length];
	}
}


//============================================================================
//	errorEncounteredSAX
//		This callback is invoked when the parser encounters an error
//
//	Params
//		userData:		an XML parser context
//		errorChars:		the message to display/transmit
//		...:			extra parameters for the message display
//
//============================================================================
static void errorEncounteredSAX(void *userData, const char *errorChars, ...)
{
	S4XMLToDictionaryParser					*parser;

	parser = (S4XMLToDictionaryParser *)userData;
	if (IS_NOT_NULL(parser))
	{
		[parser parseErrorOccurred: errorChars];
	}
}


// The handler struct has positions for a large number of callback functions. If NULL is supplied at a given position,
// that callback functionality won't be used. Refer to libxml documentation at http://www.xmlsoft.org for more information
// about the SAX callbacks.
static xmlSAXHandler simpleSAXHandlerStruct =
{
	NULL,						/* internalSubset */
	NULL,						/* isStandalone   */
	NULL,						/* hasInternalSubset */
	NULL,						/* hasExternalSubset */
	NULL,						/* resolveEntity */
	NULL,						/* getEntity */
	NULL,						/* entityDecl */
	NULL,						/* notationDecl */
	NULL,						/* attributeDecl */
	NULL,						/* elementDecl */
	NULL,						/* unparsedEntityDecl */
	NULL,						/* setDocumentLocator */
	startDocumentSAX,			/* startDocument */
	endDocumentSAX,				/* endDocument */
	NULL,						/* startElement*/
	NULL,						/* endElement */
	NULL,						/* reference */
	charactersFoundSAX,			/* characters */
	NULL,						/* ignorableWhitespace */
	NULL,						/* processingInstruction */
	NULL,						/* comment */
	NULL,						/* warning */
	errorEncounteredSAX,		/* error */
	errorEncounteredSAX,		/* fatalError */
	NULL,						/* getParameterEntity */
	NULL,						/* cdataBlock */
	NULL,						/* externalSubset */
	XML_SAX2_MAGIC,				//
	NULL,						//
	startElementSAX,			/* startElementNs */
	endElementSAX,				/* endElementNs */
	NULL,						/* serror */
};


// ====================== Begin Class S4XMLToDictionaryParser () =======================

@interface S4XMLToDictionaryParser ()

@property (nonatomic, retain) NSString								*m_reachableHostStr;
@property (nonatomic, assign) NSAutoreleasePool						*m_parsingAutoreleasePool;

@end



// ================= Begin Class S4XMLToDictionaryParser (PrivateImpl) =================

@interface S4XMLToDictionaryParser (PrivateImpl)

- (BOOL)setUpParse;
- (void)cleanUpParse;
- (void)downloadAndParseWithObject: (id)object forUrl: (NSString *)urlStr;
- (void)readFileAndParseWithObject: (id)object forFilePath: (NSString *)filePathStr;
- (void)doCancel;
- (BOOL)startParsingPath: (NSString *)pathStr rootElementName: (NSString *)rootElementStr withObject: (id)object forSelector: (SEL)parsingSelector;
- (NSString *)getQualifiedNameForPrefix: (const xmlChar *)prefix andName: (const xmlChar *)name;
- (void)downloadStarted;
- (void)downloadEnded;
- (void)parsedNewDictionary: (NSDictionary *)newDictionary;
- (void)parseError: (NSError *)error;
- (void)parseEnded;

@end



@implementation S4XMLToDictionaryParser (PrivateImpl)

//============================================================================
//	S4XMLToDictionaryParser (PrivateImpl) :: setUpParse
//============================================================================
- (BOOL)setUpParse
{
	BOOL					bResult = NO;

	// create an autorelease pool to deal with temporary alloations
	self.m_parsingAutoreleasePool = [[NSAutoreleasePool alloc] init];

	// set the parser executing flag
	m_bDoneParsing = NO;

	// create a dictionary to hold the parse results
	m_curXmlDictionary = [[[NSMutableDictionary alloc] initWithCapacity: DEFAULT_DICTIONARY_SZ] retain];
	if IS_NOT_NULL(m_curXmlDictionary)
	{
		// alloc the mutable data buffer that holds the contents of various XML elements
		m_charDataBuffer = [[[NSMutableData alloc] initWithCapacity: DEFAULT_STRING_SZ] retain];
		if IS_NOT_NULL(m_charDataBuffer)
		{
			// This creates a context for "push" parsing in which chunks of data that are not "well balanced" can be passed
			// to the context for streaming parsing. The second argument, self, will be passed as user data to each of the
			// SAX handlers. The last three arguments are left blank to avoid creating a tree in memory.
			m_libXmlParserContext = xmlCreatePushParserCtxt(&simpleSAXHandlerStruct, self, NULL, 0, NULL);
			if (NULL != m_libXmlParserContext)
			{
				bResult = YES;
			}
		}
	}
	return (bResult);
}


//============================================================================
//	S4XMLToDictionaryParser (PrivateImpl) :: cleanUpParse
//============================================================================
- (void)cleanUpParse
{
	if (NULL != m_libXmlParserContext)
	{
		xmlFreeParserCtxt(m_libXmlParserContext);
		m_libXmlParserContext = NULL;
	}

	if IS_NOT_NULL(m_charDataBuffer)
	{
		[m_charDataBuffer release];
		m_charDataBuffer = nil;
	}

	if IS_NOT_NULL(m_curXmlDictionary)
	{
		[m_curXmlDictionary release];
		m_curXmlDictionary = nil;
	}

	[m_parsingAutoreleasePool release];
	self.m_parsingAutoreleasePool = nil;
}


//============================================================================
//	S4XMLToDictionaryParser (PrivateImpl) :: downloadAndParseWithObject:forUrl:
//============================================================================
- (void)downloadAndParseWithObject: (id)object forUrl: (NSString *)urlStr
{
	NSURL								*url;
	NSURLRequest						*request;

	if (YES == [self setUpParse])
	{
		// clear out the system internet cache
		[[NSURLCache sharedURLCache] removeAllCachedResponses];

		// create a properly escaped NSURL from the string params
		url = [S4NetUtilities createNSUrlForPathStr: urlStr baseStr: nil];
		if (IS_NOT_NULL(url))
		{
			// create the request
			request = [S4NetUtilities createRequestForURL: url useCache: NO timeoutInterval: 0.0 postData: nil dataIsForm: NO handleCookies: YES];
			if (IS_NOT_NULL(request))
			{
				m_S4HttpConnection = [[S4HttpConnection alloc] init];
				if (IS_NOT_NULL(m_S4HttpConnection))
				{
					if ([m_S4HttpConnection openNonCachingConnectionForRequest: request delegate: self])
					{
						// tell the UI to show the network spinner going
						[self performSelectorOnMainThread: @selector(downloadStarted) withObject: nil waitUntilDone: NO];

						// loop on the runLoop until the m_bdoneParsing flag is set
						do
						{
							[[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate distantFuture]];
						}
						while (NO == m_bDoneParsing);
					}
					[self doCancel];		// release the S4HttpConnection
				}
				[request release];			
			}
			[url release];
		}
	}
	// Release resources used only in this thread
	[self cleanUpParse];
}


//============================================================================
//	S4XMLToDictionaryParser (PrivateImpl) :: readFileAndParseWithObject:forFilePath:
//============================================================================
- (void)readFileAndParseWithObject: (id)object forFilePath: (NSString *)filePathStr
{
	NSInputStream						*inputStream;
	uint8_t								*readBufferPtr;
	NSInteger							bytesRead;

	if (YES == [self setUpParse])
	{
		// read the XML data from the file
		inputStream = [NSInputStream inputStreamWithFileAtPath: filePathStr];
		if (IS_NOT_NULL(inputStream))
		{
			readBufferPtr = malloc(MAX_READ_BUFFER_SZ);
			if (NULL != readBufferPtr)
			{
				// tell the UI to show the network spinner going
				[self performSelectorOnMainThread: @selector(downloadStarted) withObject: nil waitUntilDone: NO];

				// read from stream
				[inputStream open];
				while (YES == [inputStream hasBytesAvailable])
				{
					bytesRead = [inputStream read: readBufferPtr maxLength: MAX_READ_BYTES];
					if (bytesRead > 0)
					{
						// Process the downloaded chunk of data.
						xmlParseChunk(m_libXmlParserContext, (const char *)readBufferPtr, bytesRead, 0);
					}
				}

				// close the stream
				[inputStream close];

				// tell the UI to hide the network spinner
				[self performSelectorOnMainThread: @selector(downloadEnded) withObject: nil waitUntilDone: NO];

				// Signal the m_libXmlParserContext that parsing is complete by passing "1" as the last parameter.
				xmlParseChunk(m_libXmlParserContext, NULL, 0, 1);

				// pass the completed NSMutableArray of coffee vendors back to the delegate
				[self performSelectorOnMainThread: @selector(parseEnded) withObject: nil waitUntilDone: NO];

				// free the buffer
				free(readBufferPtr);
			}
		}
	}
	// Release resources used only in this thread
	m_bDoneParsing = YES;
	[self cleanUpParse];
}


//============================================================================
//	S4XMLToDictionaryParser (PrivateImpl) :: doCancel
//============================================================================
- (void)doCancel
{
	// dump the connection
	if (IS_NOT_NULL(m_S4HttpConnection))
	{
		[m_S4HttpConnection cancelConnection];
		[m_S4HttpConnection autorelease];
		m_S4HttpConnection = nil;
	}
	// Set the condition which ends the run loop.
	m_bDoneParsing = YES; 	
}


//============================================================================
//	S4XMLToDictionaryParser (PrivateImpl) :: startParsingPath:
//============================================================================
- (BOOL)startParsingPath: (NSString *)pathStr rootElementName: (NSString *)rootElementStr withObject: (id)object forSelector: (SEL)parsingSelector
{
	id									localObject;
	S4OperationsHandler					*s4OpsHandler;
	NSMutableArray						*argArray;
	BOOL								bResult = NO;

	// set the root element tag
	m_rootElementNameStr = [rootElementStr retain];

	// set the local var for the object
	if (nil == object)
	{
		localObject = [NSNull null];
	}
	else
	{
		localObject = object;
	}

	// create an S4OperationsHandler instance to spin a new thread for the parse operation
	s4OpsHandler = [S4OperationsHandler handlerWithOperationQueue: nil];
	if IS_NOT_NULL(s4OpsHandler)
	{
		argArray = [NSMutableArray arrayWithCapacity: (NSUInteger)2];
		if IS_NOT_NULL(argArray)
		{
			[argArray addObject: localObject];
			[argArray addObject: pathStr];

			bResult = [s4OpsHandler addSelectorToQueue: parsingSelector
											  onTarget: self
										 withArguments: argArray];
		}
	}
	return (bResult);
}


//============================================================================
//	S4XMLToDictionaryParser (PrivateImpl) :: getQualifiedNameForPrefix:andName:
//============================================================================
- (NSString *)getQualifiedNameForPrefix: (const xmlChar *)prefix andName: (const xmlChar *)name
{
	NSString						*prefixStr = nil;
	NSString						*nameStr = nil;
	NSString						*strResult = nil;
	
	if (NULL != prefix)
	{
		prefixStr = [NSString stringWithCString: (const char *)prefix encoding: NSUTF8StringEncoding];
	}
	
	if (NULL != name)
	{
		nameStr = [NSString stringWithCString: (const char *)name encoding: NSUTF8StringEncoding];
	}
	
	if ((STR_NOT_EMPTY(prefixStr)) && (STR_NOT_EMPTY(nameStr)))
	{
		strResult = [NSString stringWithFormat: XML_PREFIX_SEPARATOR_STR, prefixStr, nameStr];
	}
	else if (STR_NOT_EMPTY(nameStr))
	{
		strResult = nameStr;
	}
    return (strResult);
}



/********************************************* Methods performed on the Main Thread  *********************************************/

//============================================================================
//	S4XMLToDictionaryParser (PrivateImpl) :: downloadStarted
//============================================================================
- (void)downloadStarted
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}


//============================================================================
//	S4XMLToDictionaryParser (PrivateImpl) :: downloadEnded
//============================================================================
- (void)downloadEnded
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


//============================================================================
//	S4XMLToDictionaryParser (PrivateImpl) :: parsedNewDictionary:
//============================================================================
- (void)parsedNewDictionary: (NSDictionary *)newDictionary
{
	if ((IS_NOT_NULL(self.delegate)) && ([self.delegate respondsToSelector: @selector(parser:addParsedDictionary:)]))
	{
		[self.delegate parser: self addParsedDictionary: newDictionary];
	}
}


//============================================================================
//	S4XMLToDictionaryParser (PrivateImpl) :: parseError:
//============================================================================
- (void)parseError: (NSError *)error
{
	if ((IS_NOT_NULL(self.delegate)) && ([self.delegate respondsToSelector: @selector(parser:didFailWithError:)]))
	{
		[self.delegate parser: self didFailWithError: error];
	}
}


//============================================================================
//	S4XMLToDictionaryParser (PrivateImpl) :: parseEnded
//		This is called explicitly by the read file parser code
//		and implicitly by the S4HttpConnection's completion
//		delegate method
//============================================================================
- (void)parseEnded
{
	if ((IS_NOT_NULL(self.delegate)) && ([self.delegate respondsToSelector: @selector(parserDidEndParsingData:)]))
	{
		[self.delegate parserDidEndParsingData: self];
	}
}

@end



// ======================== Begin Class S4XMLToDictionaryParser ========================

@implementation S4XMLToDictionaryParser


//============================================================================
//	S4XMLToDictionaryParser :: properties
//============================================================================
// public
@synthesize delegate = m_delegate;

// private
@synthesize m_reachableHostStr;
@synthesize m_parsingAutoreleasePool;


//============================================================================
//	S4XMLToDictionaryParser :: parser
//============================================================================
+ (id)parser
{
	return ([[[[self class] alloc] init] autorelease]);
}


//============================================================================
//	S4XMLToDictionaryParser :: init
//============================================================================
- (id)init
{
	if (self = [super init])
	{
		// public member vars
		self.delegate = nil;
		
		// private member vars
		m_charDataBuffer = nil;
		m_bInElement = NO;
		m_bElementHasChars = NO;
		m_rootElementNameStr = nil;
		m_curXmlDictionary = nil;
		self.m_reachableHostStr = GENERIC_REACHABILITY_URL;
		self.m_parsingAutoreleasePool = nil;
		m_libXmlParserContext = NULL;
		m_bDoneParsing = YES;
		m_S4HttpConnection = nil;
	}
	return (self);
}


//============================================================================
//	S4XMLToDictionaryParser :: dealloc
//============================================================================
- (void)dealloc
{
	self.delegate = nil;

	if IS_NOT_NULL(m_rootElementNameStr)
	{
		[m_rootElementNameStr release];
		m_rootElementNameStr = nil;
	}

	if IS_NOT_NULL(m_curXmlDictionary)
	{
		[m_curXmlDictionary release];
		m_curXmlDictionary = nil;
	}

	if IS_NOT_NULL(m_charDataBuffer)
	{
		[m_charDataBuffer release];
		m_charDataBuffer = nil;
	}

	[super dealloc];
}


//============================================================================
//	S4XMLToDictionaryParser :: startParsingFromUrlPath:
//============================================================================
- (BOOL)startParsingFromUrlPath: (NSString *)pathStr rootElementName: (NSString *)rootElementStr withObject: (id)object
{
	S4NetworkAccess						*networkAccess;
	BOOL								bResult = NO;

	if ((STR_NOT_EMPTY(pathStr)) && (STR_NOT_EMPTY(rootElementStr)))
	{
		networkAccess = [S4NetworkAccess networkAccessWithHostName: self.m_reachableHostStr];
		if ((IS_NOT_NULL(networkAccess)) && (NetworkNotReachable != [networkAccess currentReachabilityStatus]))
		{
			// start the parse
			bResult = [self startParsingPath: pathStr rootElementName: rootElementStr withObject: object forSelector: @selector(downloadAndParseWithObject:forUrl:)];
		}
	}
	return (bResult);
}


//============================================================================
//	S4XMLToDictionaryParser :: startParsingFromFilePath:
//============================================================================
- (BOOL)startParsingFromFilePath: (NSString *)pathStr rootElementName: (NSString *)rootElementStr withObject: (id)object
{
	BOOL								bResult = NO;
	
	if ((STR_NOT_EMPTY(pathStr)) && (STR_NOT_EMPTY(rootElementStr)))
	{
		if (YES == [S4FileUtilities fileExists: pathStr])
		{
			// start the parse
			bResult = [self startParsingPath: pathStr rootElementName: rootElementStr withObject: object forSelector: @selector(readFileAndParseWithObject:forFilePath:)];
		}
	}
	return (bResult);
}


//============================================================================
//	S4XMLToDictionaryParser :: setReachabilityHostName:
//============================================================================
- (void)setReachabilityHostName: (NSString *)hostName
{
	if (STR_NOT_EMPTY(hostName))
	{
		self.m_reachableHostStr = hostName;
	}
}



/*********************************************  libXML Handler Methods *********************************************/

//============================================================================
//	S4XMLToDictionaryParser :: didStartElement
//============================================================================
- (void)didStartElement: (const xmlChar *)name withPrefix: (const xmlChar *)prefix withURI: (const xmlChar *)uri
{
	NSString				*keyStr;

	keyStr = [self getQualifiedNameForPrefix: prefix andName: name];
	if (STR_NOT_EMPTY(keyStr))
	{
		if ([keyStr isEqualToString: m_rootElementNameStr])
		{
			m_bInElement = YES;
		}
		else if (YES == m_bInElement)
		{
			[m_charDataBuffer setLength: 0];
			m_bElementHasChars = YES;
		}
	}
}


//============================================================================
//	S4XMLToDictionaryParser :: didEndElement
//============================================================================
- (void)didEndElement: (const xmlChar *)name withPrefix: (const xmlChar *)prefix withURI: (const xmlChar *)uri
{
	NSString				*keyStr;
	NSString				*valueStr;

	keyStr = [self getQualifiedNameForPrefix: prefix andName: name];
	if (STR_NOT_EMPTY(keyStr))
	{
		if ([keyStr isEqualToString: m_rootElementNameStr])
		{
			[self performSelectorOnMainThread: @selector(parsedNewDictionary:) withObject: [m_curXmlDictionary copy] waitUntilDone: NO];
			// performSelectorOnMainThread: will retain the object until the selector has been performed
			// setting the local reference to nil ensures that the local reference will be released
			[m_curXmlDictionary removeAllObjects];
			m_bInElement = NO;
		}
		else if ((YES == m_bInElement) && (YES == m_bElementHasChars))
		{
			valueStr = [[[NSString alloc] initWithData: m_charDataBuffer encoding: NSUTF8StringEncoding] autorelease];
			[m_curXmlDictionary setObject: valueStr forKey: keyStr];
			m_bElementHasChars = NO;
		}
	}
}


//============================================================================
//	S4XMLToDictionaryParser :: foundCharacters
//============================================================================
- (void)foundCharacters: (const xmlChar *)charArray numBytes: (int)length
{
	if ((YES == m_bInElement) && (YES == m_bElementHasChars))
	{
		[m_charDataBuffer appendBytes: (const char *)charArray length: length];
	}
}


//============================================================================
//	S4XMLToDictionaryParser :: parseErrorOccurred
//============================================================================
- (void)parseErrorOccurred: (const char *)errorChars
{
	NSString					*errorStr;
	NSDictionary				*userInfoDict;
	NSError						*error;

	m_bDoneParsing = YES;
	errorStr = [NSString stringWithCString: errorChars encoding: NSUTF8StringEncoding];
	if (STR_NOT_EMPTY(errorStr))
	{
		userInfoDict = [NSDictionary dictionaryWithObject: errorStr forKey: NSLocalizedDescriptionKey];
		if (IS_NOT_NULL(userInfoDict))
		{
			error = [NSError errorWithDomain: LIB_DOMAIN_NAME_STR code: (NSInteger)1 userInfo: userInfoDict];
			if (IS_NOT_NULL(error))
			{
				[self performSelectorOnMainThread: @selector(parseError:) withObject: error waitUntilDone: NO];
				[error release];
			}
			[userInfoDict release];
		}
		[errorStr release];
	}
}



// ================================== S4HttpConnection delegate methods ==========================================

//============================================================================
//	S4XMLToDictionaryParser :: httpConnection:receivedData:
//============================================================================
- (BOOL)httpConnection: (S4HttpConnection *)connection receivedData: (NSData *)data
{
	// Process the downloaded chunk of data
	xmlParseChunk(m_libXmlParserContext, (const char *)[data bytes], [data length], 0);
	return (YES);
}


//============================================================================
//	S4XMLToDictionaryParser :: httpConnection:failedWithError:
//============================================================================
- (void)httpConnection: (S4HttpConnection *)connection failedWithError: (NSError *)error
{
	m_bDoneParsing = YES;
	[self performSelectorOnMainThread: @selector(parseError:) withObject: error waitUntilDone: NO];
}


//============================================================================
//	S4XMLToDictionaryParser :: httpConnection:completedWithData:
//============================================================================
- (void)httpConnection: (S4HttpConnection *)connection completedWithData: (NSMutableData *)data
{
	// tell the UI to hide the network spinner
	[self performSelectorOnMainThread: @selector(downloadEnded) withObject: nil waitUntilDone: NO];

	// Signal the m_libXmlParserContext that parsing is complete by passing "1" as the last parameter.
	xmlParseChunk(m_libXmlParserContext, NULL, 0, 1);

	// pass the completed NSMutableArray of coffee vendors back to the delegate
	[self performSelectorOnMainThread: @selector(parseEnded) withObject: nil waitUntilDone: NO];

	// Set the condition which ends the run loop.
    m_bDoneParsing = YES; 
}

@end

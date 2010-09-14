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
 * All software created by the Initial Developer are Copyright (C) 2008-2009
 * the Initial Developer. All Rights Reserved.
 *
 * Original Author:
 *			Michael Papp, San Francisco, CA, USA
 *
 * ***** END LICENSE BLOCK ***** */

/* ***** FILE BLOCK ******
 *
 * Name:		RootViewController.m
 * Module:		S4iPhoneTest
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "RootViewController.h"
#import "AppDelegate_Shared.h"
#import "S4TestVendor.h"
#import "XmlToDictParser.h"
#import "S4AppUtils.h"
#import "S4NetUtilities.h"
#import "S4WebViewController.h"
#import "S4CommonDefines.h"


// =================================== Defines =========================================

#define MAX_VENDOR_ARRAY_SZ						20


// ================================== Typedefs =========================================



// =================================== Globals =========================================


static BOOL						g_bInitialized = NO;

static UIImage					*genericCupIcon = nil;
static UIImage					*favOnIcon = nil;


// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ==================== Begin Class RootViewController (PrivateImpl) ===================

@interface RootViewController (PrivateImpl)

- (void)rowSelected: (NSIndexPath *)indexPath;

@end




@implementation RootViewController (PrivateImpl)

//============================================================================
//	RootViewController (PrivateImpl) :: rowSelected:
//============================================================================
- (void)rowSelected: (NSIndexPath *)indexPath
{
	S4TestVendor						*curS4Vendor;
	NSString							*urlStr;
	S4WebViewController					*webViewController;
	UIBarButtonItem						*backBtn;
	
	if ([self.coffeeVendorArray count] > indexPath.row)
	{
		curS4Vendor = [[S4TestVendor alloc] initWithDictionary: (NSDictionary *)[self.coffeeVendorArray objectAtIndex: indexPath.row]];
		urlStr = [curS4Vendor bizUrl];
		if (STR_NOT_EMPTY(urlStr))
		{
			webViewController = [[S4WebViewController alloc] initWithNibName: nil bundle: nil];
			backBtn = [[UIBarButtonItem alloc] initWithTitle: [curS4Vendor title] style: UIBarButtonItemStylePlain target: nil action: nil];
			webViewController.navigationItem.backBarButtonItem = backBtn;
			[self.navigationController pushViewController: webViewController animated: YES];
			[webViewController loadUrl: urlStr];
		}
	}
}

@end




// ====================== Begin Class RootViewController =====================

@implementation RootViewController

//============================================================================
//	RootViewController :: properties
//============================================================================
@synthesize navigationController;
@synthesize coffeeVendorArray;
@synthesize currentCell;
@synthesize refreshBarButton;


//============================================================================
//	RootViewController :: initialize
//============================================================================
+ (void)initialize
{
	if ((NO == g_bInitialized) && ([self class] == [RootViewController class]))
	{
		genericCupIcon			= [[UIImage imageNamed:@"cup_generic.png"] retain];
		favOnIcon				= [[UIImage imageNamed:@"fav_on_icon.png"] retain];

		g_bInitialized = YES;
	}
}


//============================================================================
//	RootViewController :: init
//============================================================================
- (id)initWithNibName: (NSString *)nibNameOrNil bundle: (NSBundle *)nibBundleOrNil
{
	id							idResult = nil;
	
	self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
	if (nil != self)
	{
		self.tableView = [[UITableView alloc] initWithFrame: [[UIScreen mainScreen] applicationFrame] style: UITableViewStylePlain];
		self.tableView.delegate = self;
		self.tableView.dataSource = self;
		self.tableView.rowHeight = 50;
		self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		self.tableView.sectionHeaderHeight = 0;
		self.tableView.multipleTouchEnabled = YES;
		self.tableView.delaysContentTouches = YES;
		self.tableView.scrollEnabled = YES;

		self.coffeeVendorArray = [NSMutableArray arrayWithCapacity: (NSUInteger)MAX_VENDOR_ARRAY_SZ];
	    [self.tableView reloadData];

		self.refreshBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh target: self action: @selector(refreshClicked)];
		[self.navigationItem setLeftBarButtonItem: refreshBarButton];
		idResult = self;
	}
	return (idResult);
}


//============================================================================
//	RootViewController :: dealloc
//============================================================================
- (void)dealloc
{
	if (nil != self.coffeeVendorArray)
	{
		[self.coffeeVendorArray release];
		self.coffeeVendorArray = nil;
	}
	
	[super dealloc];
}


//============================================================================
//	RootViewController :: refreshClicked
//============================================================================
- (void)refreshClicked
{
	[self loadVendorList];
}


//============================================================================
//	RootViewController :: setTitleStr
//============================================================================
- (void)setTitleStr: (NSString *)titleStr
{
	self.title = titleStr;
	self.navigationController.title = @"Near Me";
}


//============================================================================
//	RootViewController :: loadView
//============================================================================
- (void)loadView
{
	AppDelegate_Shared			*appDelegate;
	
	appDelegate = (AppDelegate_Shared *)[[UIApplication sharedApplication] delegate];
	self.navigationController = appDelegate.navigationController;
	[self setTitleStr: @"S4TestApplication"];
	
	self.tableView = [[UITableView alloc] initWithFrame: [[UIScreen mainScreen] applicationFrame] style: UITableViewStylePlain];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.rowHeight = 50;
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.tableView.sectionHeaderHeight = 0;
	self.tableView.multipleTouchEnabled = YES;
	self.tableView.delaysContentTouches = YES;
	self.tableView.scrollEnabled = YES;
	
	self.coffeeVendorArray = [NSMutableArray arrayWithCapacity: (NSUInteger)MAX_VENDOR_ARRAY_SZ];
	[self.tableView reloadData];

	BOOL bResult = [[S4UIDeviceManager getInstance] addDelegate: self];
	if (YES == bResult)
	{
		NSLog(@"RootViewController addDelegate to UIDeviceManager PASSED\n\n");
	}

	self.refreshBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh target: self action: @selector(refreshClicked)];
	[self.navigationItem setLeftBarButtonItem: refreshBarButton];
}


//============================================================================
//	RootViewController :: viewDidLoad
//============================================================================
- (void)viewDidLoad
{
	[super viewDidLoad];
	//	self.navigationItem.hidesBackButton = YES;
}


//============================================================================
//	RootViewController :: viewWillAppear
//============================================================================
- (void)viewWillAppear: (BOOL)animated
{
	NSIndexPath			*selectedRowIndexPath;
	
	[self loadVendorList];
	selectedRowIndexPath = [self.tableView indexPathForSelectedRow];
	if (nil != selectedRowIndexPath)
	{
		[self.tableView deselectRowAtIndexPath: selectedRowIndexPath animated: YES];	
	}
}

#ifdef ERROR_TESTING

//============================================================================
//	RootViewController :: badAccess
//============================================================================
- (void)badAccess
{
	void (*nullFunction)() = NULL;
	
	nullFunction();
}
#endif

//============================================================================
//	RootViewController :: viewWillDisappear
//============================================================================
- (void)viewWillDisappear: (BOOL)animated
{
#ifdef ERROR_TESTING
	[self performSelector: @selector(string) withObject: nil afterDelay: 4.0];
	[self performSelector: @selector(badAccess) withObject: nil afterDelay: 100.0];
#endif
}


//============================================================================
//	RootViewController :: loadVendorList
//============================================================================
- (BOOL)loadVendorList
{
	XmlToDictParser				*xmlParser;
	BOOL						bResult = NO;
	
	// Allocate the array for song storage, or empty the results of previous parses
	if (nil == self.coffeeVendorArray)
	{
		self.coffeeVendorArray = [NSMutableArray arrayWithCapacity: (NSUInteger)MAX_VENDOR_ARRAY_SZ];
	}
	else
	{
		[self.coffeeVendorArray removeAllObjects];
		[self.tableView reloadData];
	}
	
	// Create the CSfeedParser, set its delegate, and start it.
	xmlParser = [[XmlToDictParser alloc] init];
	xmlParser.delegate = self;
	bResult = [xmlParser start];
	if (YES == bResult)
	{
		// Reset the title
		[self setTitleStr: @"Updating list"];
	}
	else
	{
		// Reset the title
		[self setTitleStr: @"No network"];
	}
	[xmlParser release];

	return (bResult);
}


//============================================================================
//	RootViewController :: didReceiveMemoryWarning
//============================================================================
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}




/*********************************************  UITableView Override Methods *********************************************/

//============================================================================
//	RootViewController :: numberOfSectionsInTableView
//============================================================================
- (NSInteger)numberOfSectionsInTableView: (UITableView *)tableView
{
	return (1);
}


//============================================================================
//	RootViewController :: numberOfRowsInSection
//============================================================================
- (NSInteger)tableView: (UITableView *)tableView numberOfRowsInSection: (NSInteger)section
{
	return ([self.coffeeVendorArray count]);
}


//============================================================================
//	RootViewController :: cellForRowAtIndexPath
//============================================================================
- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
	static NSString				*kCSNearbyVendorsCellStr = @"CSNearbyVendorsCell";
	CSNearbyVendorsCell			*nearByVendorCell;
	S4TestVendor				*curS4Vendor;
	
	nearByVendorCell = (CSNearbyVendorsCell *)[self.tableView dequeueReusableCellWithIdentifier: kCSNearbyVendorsCellStr];
	if (nil == nearByVendorCell)
	{
		NSArray *MyCellNib = [[NSBundle mainBundle] loadNibNamed: @"NearbyVendorsCell" owner: self options: nil];
		nearByVendorCell = self.currentCell;
		MyCellNib = nil;
	}
	
	// Set up the CSNearbyVendorsCell
	if ([self.coffeeVendorArray count] > indexPath.row)
	{
		curS4Vendor = [[S4TestVendor alloc] initWithDictionary: (NSDictionary *)[self.coffeeVendorArray objectAtIndex: indexPath.row]];
		[nearByVendorCell loadImage];
		nearByVendorCell.brandImage.image = genericCupIcon;
		nearByVendorCell.nameLabel.text = [curS4Vendor title];
		UIFont *addressLabelFont = [UIFont systemFontOfSize: 12.5];
		nearByVendorCell.addressLabel.font = addressLabelFont;
		nearByVendorCell.addressLabel.text = [curS4Vendor address];
		nearByVendorCell.distanceLabel.text = [NSString stringWithFormat: @"%@ mi", [curS4Vendor distance]];
		
		UIColor *labelColor = [UIColor blackColor];
		nearByVendorCell.distanceLabel.textColor = labelColor;
		nearByVendorCell.addressLabel.textColor = labelColor;
		nearByVendorCell.nameLabel.textColor = labelColor;
		nearByVendorCell.favImage.image = favOnIcon;
	}
	return (nearByVendorCell);
}


//============================================================================
//	RootViewController :: didSelectRowAtIndexPath
//============================================================================
- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
	[self rowSelected: indexPath];
}


//============================================================================
//	RootViewController :: accessoryButtonTappedForRowWithIndexPath
//============================================================================
- (void)tableView: (UITableView *)tableView accessoryButtonTappedForRowWithIndexPath: (NSIndexPath *)indexPath
{
	[self rowSelected: indexPath];
}


//============================================================================
//	RootViewController :: canEditRowAtIndexPath
//============================================================================
- (BOOL)tableView: (UITableView *)tableView canEditRowAtIndexPath: (NSIndexPath *)indexPath
{
	return (NO);
}


//============================================================================
//	RootViewController :: shouldAutorotateToInterfaceOrientation
//============================================================================
- (BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation
{	
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


//============================================================================
//	RootViewController :: moveRowAtIndexPath:
//============================================================================
// Override to support rearranging the table view.
- (void)tableView: (UITableView *)tableView moveRowAtIndexPath: (NSIndexPath *)fromIndexPath toIndexPath: (NSIndexPath *)toIndexPath
{
}


//============================================================================
//	RootViewController :: canMoveRowAtIndexPath:
//============================================================================
- (BOOL)tableView: (UITableView *)tableView canMoveRowAtIndexPath: (NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return (NO);
}




/*********************************************  CSfeedParser Delegate Methods *********************************************/

//============================================================================
//	RootViewController :: parserDidEndParsingData
//============================================================================
- (void)parserDidEndParsingData: (S4XMLToDictionaryParser *)parser
{
	S4AppUtils						*appUtils;
	
	if ([self.coffeeVendorArray count] > 0)
	{		
		// get an App Utils instance
		appUtils = [S4AppUtils getInstance];
		[self setTitleStr: [appUtils productName]];
	}
	else
	{
		[self setTitleStr: @"No results..."];
	}
	[self.tableView reloadData];
}


//============================================================================
//	RootViewController :: addParsedDictionary:
//============================================================================
- (void)parser: (S4XMLToDictionaryParser *)parser addParsedDictionary: (NSDictionary *)parsedDictionary
{
	// add the new Coffee Vendors to the array
	[self.coffeeVendorArray addObject: parsedDictionary];
	
	// Three scroll view properties are checked to keep the user interface smooth during parse.
	// When new objects are delivered by the parser, the table view is reloaded to display them.
	// If the table is reloaded while the user is scrolling, this can result in eratic behavior.
	// Dragging, tracking, and decelerating can be checked for this purpose. When the parser
	// finishes, parserDidEndParsingData: will call reloadData on the tableview, guaranteeing all
	// data will be displayed.
	if (!self.tableView.dragging && !self.tableView.tracking && !self.tableView.decelerating)
	{
		[self.tableView reloadData];
	}
}


//============================================================================
//	RootViewController :: didFailWithError
//============================================================================
- (void)parser: (S4XMLToDictionaryParser *)parser didFailWithError: (NSError *)error;
{
	// handle errors
}


- (void)orientationChangedOnUIDeviceManager: (S4UIDeviceManager *)uiDevManager
{
	NSLog(@"VC called with new orientation: %@", [uiDevManager orientationAsString]);
}


@end


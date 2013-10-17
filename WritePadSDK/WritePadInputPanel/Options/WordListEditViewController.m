/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    Copyright (c) 1997-2012 PhatWare(r) Corp. All rights reserved.                 * */
/* ************************************************************************************* */

/* ************************************************************************************* *
 *
 * WritePad Input Panel Sample
 *
 * Unauthorized distribution of this code is prohibited. For more information
 * refer to the End User Software License Agreement provided with this 
 * software.
 *
 * This source code is distributed and supported by PhatWare Corp.
 * http://www.phatware.com
 *
 * THIS SAMPLE CODE CAN BE USED  AS A REFERENCE AND, IN ITS BINARY FORM, 
 * IN THE USER'S PROJECT WHICH IS INTEGRATED WITH THE WRITEPAD SDK. 
 * ANY OTHER USE OF THIS CODE IS PROHIBITED.
 * 
 * THE MATERIAL EMBODIED ON THIS SOFTWARE IS PROVIDED TO YOU "AS-IS"
 * AND WITHOUT WARRANTY OF ANY KIND, EXPRESS, IMPLIED OR OTHERWISE,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY OR
 * FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL PHATWARE CORP.  
 * BE LIABLE TO YOU OR ANYONE ELSE FOR ANY DIRECT, SPECIAL, INCIDENTAL, 
 * INDIRECT OR CONSEQUENTIAL DAMAGES OF ANY KIND, OR ANY DAMAGES WHATSOEVER, 
 * INCLUDING WITHOUT LIMITATION, LOSS OF PROFIT, LOSS OF USE, SAVINGS 
 * OR REVENUE, OR THE CLAIMS OF THIRD PARTIES, WHETHER OR NOT PHATWARE CORP.
 * HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH LOSS, HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, ARISING OUT OF OR IN CONNECTION WITH THE
 * POSSESSION, USE OR PERFORMANCE OF THIS SOFTWARE.
 * 
 * US Government Users Restricted Rights 
 * Use, duplication, or disclosure by the Government is subject to
 * restrictions set forth in EULA and in FAR 52.227.19(c)(2) or subparagraph
 * (c)(1)(ii) of the Rights in Technical Data and Computer Software
 * clause at DFARS 252.227-7013 and/or in similar or successor
 * clauses in the FAR or the DOD or NASA FAR Supplement.
 * Unpublished-- rights reserved under the copyright laws of the
 * United States.  Contractor/manufacturer is PhatWare Corp.
 * 10414 W. Highway 2, Ste 4-121 Spokane, WA 99224
 *
 * ************************************************************************************* */

#import "WordListEditViewController.h"
#import "EditWordViewController.h"
#import "UIConst.h"
#import "RecognizerManager.h"

static NSString *kCellIdentifier = @"WordCellIdentifier";

static int EnumWordListCallback( const UCHR * pszWordFrom, const UCHR * pszWordTo, int flags, void * pParam )
{
	NSMutableArray * array = (NSMutableArray *)pParam;
	WordListItem *	 item = [WordListItem alloc];
	item.wordFrom = [NSString stringWithCString:pszWordFrom encoding:RecoStringEncoding];
	item.wordTo = [NSString stringWithCString:pszWordTo encoding:RecoStringEncoding];
	item.flags = flags;
	
	[array addObject:item];
	[item release];
	return 1;
}

@implementation WordListItem

@synthesize wordFrom;
@synthesize wordTo;
@synthesize flags;

- (id)init
{
	self = [super init];
	if (self)
	{
		wordFrom = nil;
		wordTo = nil;
		flags = 0;
	}
	return self;
}

- (void)dealloc 
{
	[wordFrom release];
	[wordTo release];

    [super dealloc];
}

@end

@interface WordListEditViewController (WordListEditViewControllerDelegate)  <EditWordViewControllerDelegate>
- (void) editWordViewController:(EditWordViewController *)wordView wordModified:(WordListItem *)item isNew:(BOOL)bNew;
@end

@implementation WordListEditViewController

@synthesize tableWordList;

- (id)init
{
	self = [super init];
	if (self)
	{
		// this title will appear in the navigation bar
		self.title = NSLocalizedString( @"Autocorrector", @"" );
		_recognizer = [[RecognizerManager sharedManager] recognizer];
		_userWords = [[NSMutableArray alloc] init];
		_bModified = NO;
	}
	return self;
}

- (void)editWordViewController:(EditWordViewController *)wordView wordModified:(WordListItem *)item isNew:(BOOL)bNew
{
	if ( bNew && item != nil )
	{
		// add new word
		[_userWords insertObject:item atIndex:0];
		_bModified = YES;
	}
	else if ( item != nil )
	{
		_bModified = YES;
	}
}

static int compareUserWords (id a, id b, void *ctx )
{
	WordListItem * item1 = (WordListItem *)a;
	WordListItem * item2 = (WordListItem *)b;
	return [item1.wordFrom caseInsensitiveCompare:item2.wordFrom];
}

#pragma mark Initialize View

- (void)loadView
{
	[super loadView];
	
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	
	// setup our parent content view and embed it to your view controller
	UIView *contentView = [[UIView alloc] initWithFrame:screenRect];
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];	// use the table view background color
	
	self.view = contentView;
	[contentView release];
	
	buttonItemEdit = [[UIBarButtonItem alloc] 
					  initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction)];
	buttonItemDone = [[UIBarButtonItem alloc] 
					  initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction)];	
		
	CGRect viewFrame = [self.view bounds];

	// create and configure the table view
	tableWordList = [[UITableView alloc] initWithFrame:viewFrame style:(_recognizer != nil) ? UITableViewStylePlain : UITableViewStyleGrouped];	
	tableWordList.delegate = self;
	tableWordList.dataSource = self;
	tableWordList.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	tableWordList.autoresizesSubviews = YES;
	tableWordList.hidden = NO;
	tableWordList.allowsSelectionDuringEditing = YES;
	// tableDict.editing = YES;
	[self.view addSubview:tableWordList];
	
	[_userWords removeAllObjects];
	if ( _recognizer != NULL )
	{
		// enumirate user dictionary and add words to array
		int nWords = HWR_EnumWordList( _recognizer, EnumWordListCallback, (void *)_userWords );
		NSLog(@"%i words added", nWords );
		if ( nWords > 1 )
		{
			[_userWords sortUsingFunction:compareUserWords context:self];
		}
	}	
	_bModified = NO;
}

- (IBAction)editAction 
{
	if ( _recognizer != NULL )
	{
		[tableWordList setEditing:YES animated:YES];
		self.navigationItem.rightBarButtonItem = buttonItemDone;
		[tableWordList reloadData];
	}
}

- (IBAction)doneAction 
{
	if ( _recognizer != NULL )
	{
		[tableWordList setEditing:NO animated:YES];
		self.navigationItem.rightBarButtonItem = buttonItemEdit;
		[tableWordList reloadData];
	}
}

#pragma mark UIViewController delegate methods

// called after this controller's view was dismissed, covered or otherwise hidden
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];	
	
	/*
	if ( [tableWordList isEditing] )
		[tableWordList setEditing:NO animated:NO];
	if ( nil != self.navigationItem.rightBarButtonItem )
		self.navigationItem.rightBarButtonItem = nil;	
	*/
	
	if ( _bModified && _recognizer )
	{
		// save autocorrector word list
		if ( HWR_EmptyWordList( _recognizer ) )
		{
			for ( int i = 0; i < [_userWords count]; i++ )
			{
				WordListItem *	 item = [_userWords objectAtIndex:i];
				const char * pszWord1 = [item.wordFrom cStringUsingEncoding:RecoStringEncoding]; 
				const char * pszWord2 = [item.wordTo cStringUsingEncoding:RecoStringEncoding]; 
				HWR_AddWordToWordList( _recognizer, pszWord1, pszWord2, item.flags, NO );
			}		
		}
		// save the word list now
		[[RecognizerManager sharedManager] saveRecognizerDataOfType:USERDATA_AUTOCORRECTOR];
		_bModified = NO;
	}
}

// called after this controller's view will appear
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if ( nil != tableWordList )
		[tableWordList reloadData];
	
	if ( _recognizer != NULL )
		self.navigationItem.rightBarButtonItem = [tableWordList isEditing] ? buttonItemDone : buttonItemEdit;
}

#pragma mark - UITableView delegates

// if you want the entire table to just be re-orderable then just return UITableViewCellEditingStyleNone
//

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *title = (_recognizer==nil) ? NSLocalizedString( @"Recognizer Not Loaded...", @"" ) : @"";
	return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	int nRes = 0;
	if ( _recognizer != NULL )
	{
		nRes = [_userWords count];
		if ( [tableView isEditing] )
			nRes++;
	}			
	return nRes;
}

// to determine specific row height for each cell, override this.  In this example, each row is determined
// buy the its subviews that are embedded.
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat result = kWordCellHeight;
	return result;
}


// to determine which UITableViewCell to be used on a given row.
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger row = [indexPath row];
	UITableViewCell *cell = nil;
	
	cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
	if ( cell == nil )
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier] autorelease];
	}
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	
	if ( [tableView isEditing] && row == 0 )
	{
		cell.textLabel.text = NSLocalizedString( @"<new word correction>", @"" );		
		cell.textLabel.textColor = [UIColor grayColor];
		cell.textLabel.textAlignment = UITextAlignmentCenter;
	}
	else
	{	
		NSInteger index = [tableView isEditing] ? row-1 : row;
		WordListItem * item = [_userWords objectAtIndex:index];
		NSString * str = [NSString stringWithFormat:@"%@ -> %@", item.wordFrom, item.wordTo];
		cell.textLabel.text = str;
		cell.textLabel.textColor = [UIColor blackColor];
		cell.textLabel.textAlignment = UITextAlignmentLeft;
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSInteger row = [indexPath row];

	// if ( ! [tableView isEditing] )
	{
		EditWordViewController *viewController = [[EditWordViewController alloc] init];
		
		if ( [tableView isEditing] )
		{
			if ( row > 0 )				
				viewController.wordListItem = [_userWords objectAtIndex:(row-1)];
			else 
				viewController.wordListItem = nil;
		}
		else
		{
			viewController.wordListItem = [_userWords objectAtIndex:row];
		}
		viewController.delegate = self;
		[self.navigationController pushViewController:viewController animated:YES];	
		[viewController release];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];		
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ( [tableView isEditing] )
	{
		if (indexPath.row == 0 ) 
		{
			return UITableViewCellEditingStyleInsert;
		}
		return UITableViewCellEditingStyleDelete;
	}
	return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if ( [tableView isEditing] )
	{
		if (editingStyle == UITableViewCellEditingStyleDelete) 
		{
			[_userWords removeObjectAtIndex:([indexPath row]-1)];
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			_bModified = YES;
		} 
		else if (editingStyle == UITableViewCellEditingStyleInsert) 
		{
			EditWordViewController *viewController = [[EditWordViewController alloc] init];
			viewController.wordListItem = nil;
			viewController.delegate = self;
			[self.navigationController pushViewController:viewController animated:YES];	
			[viewController release];
		}
	}
}

#pragma mark -

// The accessory view is on the right side of each cell. We'll use a "disclosure" indicator in editing mode,
// to indicate to the user that selecting the row will navigate to a new view where details can be edited.
- (UITableViewCellAccessoryType)tableView:(UITableView *)aTableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath 
{
    return UITableViewCellAccessoryDisclosureIndicator;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return YES;
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc 
{
	_recognizer = NULL;
	
	[tableWordList setDelegate:nil];
	[tableWordList release];
	
	[buttonItemEdit release];
	[buttonItemDone release];
	
	[_userWords removeAllObjects];
	[_userWords release];	
		
    [super dealloc];
}


@end

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

#import "DictEditViewController.h"
#import "UIConst.h"
#import "RecognizerManager.h"

static NSString *kCellIdentifier = @"DictCellIdentifier";

static int EnumWordsCallback( const UCHR * pszWord, void * pParam )
{
	NSMutableArray * array = (NSMutableArray *)pParam;
	NSString * sWord = [[NSString alloc] initWithCString:pszWord encoding:RecoStringEncoding];
	[array addObject:sWord];
	[sWord release];
	return 1;
}

static int compareUserWords (id a, id b, void *ctx)
{
	NSString * s1 = (NSString *)a;
	NSString * s2 = (NSString *)b;
	return [s1 caseInsensitiveCompare:s2];
}

@implementation DictEditViewController

@synthesize tableDict;

- (id)init
{
	self = [super init];
	if (self)
	{
		// this title will appear in the navigation bar
		self.title = NSLocalizedString( @"User Dictionary", @"" );
		_recognizer = [[RecognizerManager sharedManager] recognizer];
		_userWords = [[NSMutableArray alloc] init];
		_bDictModified = NO;
	}
	return self;
}

- (UITextField *)createTextField
{
	CGRect frame = CGRectMake(0.0, 0.0, kTextFieldWidth, kTextFieldHeight);
	UITextField *returnTextField = [[UITextField alloc] initWithFrame:frame];
    
	returnTextField.borderStyle = UITextBorderStyleRoundedRect;
    returnTextField.textColor = [UIColor blackColor];
	returnTextField.font = [UIFont systemFontOfSize:17.0];
    returnTextField.placeholder = NSLocalizedString( @"<enter new word>", @"" );
    returnTextField.backgroundColor = [UIColor whiteColor];
	returnTextField.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
	returnTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	
	returnTextField.keyboardType = UIKeyboardTypeDefault;
	returnTextField.returnKeyType = UIReturnKeyDone;
	
	returnTextField.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
	
	return returnTextField;
}


- (void) reloadDictionary
{
	// init word list
	[_userWords removeAllObjects];
	
	if ( _recognizer != NULL )
	{
		// enumirate user dictionary and add words to array
		int nWords = HWR_EnumUserWords( _recognizer, EnumWordsCallback, (void *)_userWords );
		NSLog(@"%i words added", nWords );
		if ( nWords > 1 )
		{
			[_userWords sortUsingFunction:compareUserWords context:self];
		}
	}
    [tableDict reloadData];
    
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
	newWordField = [self createTextField];
		
	// create and configure the table view
	tableDict = [[UITableView alloc] initWithFrame:viewFrame style:(_recognizer != nil) ? UITableViewStylePlain : UITableViewStyleGrouped];	
	tableDict.delegate = self;
	tableDict.dataSource = self;
	tableDict.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	tableDict.autoresizesSubviews = YES;
	tableDict.hidden = NO;
	// tableDict.editing = YES;
        
	[self.view addSubview:tableDict];
	_bDictModified = NO;	

    [self reloadDictionary];

}

- (IBAction)editAction 
{
	if ( _recognizer != NULL )
	{
		[tableDict setEditing:YES animated:YES];
		self.navigationItem.rightBarButtonItem = buttonItemDone;
		[tableDict reloadData];
	}
}

- (IBAction)doneAction 
{
	// if ( [newWordField isFirstResponder] )
	[newWordField resignFirstResponder];		
	if ( _recognizer != NULL )
	{
		[tableDict setEditing:NO animated:YES];
		self.navigationItem.rightBarButtonItem = buttonItemEdit;
		[tableDict reloadData];
	}
}

#pragma mark UIViewController delegate methods

// called after this controller's view was dismissed, covered or otherwise hidden
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];	
	
	if ( [tableDict isEditing] )
		[tableDict setEditing:NO animated:NO];
	if ( nil != self.navigationItem.rightBarButtonItem )
		self.navigationItem.rightBarButtonItem = nil;
	
	// if ( [newWordField isFirstResponder] )
	[newWordField resignFirstResponder];	
	
	if ( _bDictModified && _recognizer )
	{
		// save the user dictionary
		if ( HWR_NewUserDict( _recognizer ) )
		{
			for ( int i = 0; i < [_userWords count]; i++ )
			{
				NSString *	 strWord = [_userWords objectAtIndex:i];
				const char * pszWord = [strWord cStringUsingEncoding:RecoStringEncoding];
				if ( pszWord != nil )
				{
					HWR_AddUserWordToDict( _recognizer, pszWord, NO );
				}
			}
		}
		// save the word list now
		[[RecognizerManager sharedManager] saveRecognizerDataOfType:USERDATA_DICTIONARY];
		_bDictModified = NO;
	}
	// _recognizer = NULL;
}

// called after this controller's view will appear
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	if ( nil != tableDict )
		[tableDict reloadData];
	
	if ( ! tableDict.hidden && _recognizer != NULL )
		self.navigationItem.rightBarButtonItem = [tableDict isEditing] ? buttonItemDone : buttonItemEdit;
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
	CGFloat result = kUIRowHeight;
	if ( tableView == tableDict )
	{
		result = ([tableView isEditing] && [indexPath row] == 0) ? kNewWordCellHeight : kWordCellHeight;
	}
	return result;
}


// to determine which UITableViewCell to be used on a given row.
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger row = [indexPath row];
	UITableViewCell *cell = nil;
	
	if ( [tableView isEditing] && row == 0 )
	{
		cell = [tableView dequeueReusableCellWithIdentifier:kCellTextField_ID];
		if ( cell == nil )
		{
			cell = [[[CellTextField alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellTextField_ID] autorelease];
			((CellTextField *)cell).delegate = self;	// so we can detect when cell editing starts
		}
		newWordField.text = @"";
		cell.editingAccessoryType = UITableViewCellAccessoryNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		((CellTextField *)cell).view = newWordField;
		newWordCell = (CellTextField *)cell;	// kept track for editing
		// [newWordCell setEditing:YES];
	}
	else
	{			
		cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
		if ( cell == nil )
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier] autorelease];
		}
		if ( [tableView isEditing] )
		{
			cell.textLabel.text = [_userWords objectAtIndex:(row-1)];
		}
		else
		{
			cell.textLabel.text = [_userWords objectAtIndex:row];
		}
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.editingAccessoryType = UITableViewCellAccessoryNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
	}	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ( [tableDict isEditing] )
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
			_bDictModified = YES;
		} 
		else if (editingStyle == UITableViewCellEditingStyleInsert) 
		{
			if ( [newWordField.text length] > 0 )
			{
				// if ( [newWordField isFirstResponder] )
				[newWordField resignFirstResponder];
				NSMutableString * str = [NSMutableString stringWithString:newWordField.text];
				int len = [str length];
				[str replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:NSMakeRange(0, len)];
				[_userWords  insertObject:str atIndex:0];
				[tableView reloadData];
				_bDictModified = YES;
				newWordField.text = @"";
			}
		}
	}
}

#pragma mark <EditableTableViewCellDelegate> Methods and editing management

- (BOOL)cellShouldBeginEditing:(EditableTableViewCell *)cell
{
    /* notify other cells to end editing
	 if (![cell isEqual:newWordCell])
	 [newWordCell stopEditing];
	 */
	
    return [tableDict isEditing];
}

- (void)cellDidEndEditing:(EditableTableViewCell *)cell
{
}

- (void)keyboardWillShow:(NSNotification *)notif
{
}

#pragma mark -

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
	
	[tableDict setDelegate:nil];
	[tableDict release];
	
	[buttonItemEdit release];
	[buttonItemDone release];
	[newWordField release];

	[_userWords release];	
		
    [super dealloc];
}


@end

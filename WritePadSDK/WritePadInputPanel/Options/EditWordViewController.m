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

#import "EditWordViewController.h"
#import "UIConst.h"
#import "CellTextField.h"
#import "DisplayCell.h"

// Private interface for TextFieldController - internal only methods.
@interface EditWordViewController (Private)
@end

@implementation EditWordViewController

@synthesize myTableView;
@synthesize wordToField;
@synthesize wordFromField;
@synthesize flags;
@synthesize wordListItem;
@synthesize delegate;

#pragma mark Create table items

- (UITextField *)createTextField:(NSString *)strPlaceHoder
{
	CGRect frame = CGRectMake(0.0, 0.0, kTextFieldWidth, kTextFieldHeight);
	UITextField *returnTextField = [[UITextField alloc] initWithFrame:frame];
   
	returnTextField.borderStyle = UITextBorderStyleRoundedRect;
    returnTextField.textColor = [UIColor blackColor];
	returnTextField.font = [UIFont systemFontOfSize:16.0];
    returnTextField.placeholder = strPlaceHoder;
    returnTextField.backgroundColor = [UIColor whiteColor];
	returnTextField.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
	returnTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	
	returnTextField.keyboardType = UIKeyboardTypeDefault;	// use the default type input method (entire keyboard)
	returnTextField.returnKeyType = UIReturnKeyDone;
	
	returnTextField.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
	
	return returnTextField;
}

- (void)create_switchDisable
{
	CGRect frame = CGRectMake(0.0, 0.0, kSwitchButtonWidth, kSwitchButtonHeight);
	switchDisable = [[UISwitch alloc] initWithFrame:frame];
	[switchDisable addTarget:self action:@selector(switchActionDisable:) forControlEvents:UIControlEventValueChanged];
	
	// in case the parent view draws with a custom color or gradient, use a transparent color
	switchDisable.backgroundColor = [UIColor clearColor];
	switchDisable.on = (0 != (flags & WCF_DISABLED));
}

- (void)create_switchAlways
{
	CGRect frame = CGRectMake(0.0, 0.0, kSwitchButtonWidth, kSwitchButtonHeight);
	switchAlways = [[UISwitch alloc] initWithFrame:frame];
	[switchAlways addTarget:self action:@selector(switchActionAlways:) forControlEvents:UIControlEventValueChanged];
	
	// in case the parent view draws with a custom color or gradient, use a transparent color
	switchAlways.backgroundColor = [UIColor clearColor];
	switchAlways.on = (0 != (flags & WCF_ALWAYS));
}

- (void)create_switchIgnoreCase
{
	CGRect frame = CGRectMake(0.0, 0.0, kSwitchButtonWidth, kSwitchButtonHeight);
	switchIgnoreCase = [[UISwitch alloc] initWithFrame:frame];
	[switchIgnoreCase addTarget:self action:@selector(switchActionIgnoreCase:) forControlEvents:UIControlEventValueChanged];
	
	// in case the parent view draws with a custom color or gradient, use a transparent color
	switchIgnoreCase.backgroundColor = [UIColor clearColor];
	switchIgnoreCase.on = (0 != (flags & WCF_IGNORECASE));
}

- (void)switchActionDisable:(id)sender
{
	if ( [sender isOn] )
		flags |= WCF_DISABLED;
	else
		flags &= ~WCF_DISABLED;
}

- (void)switchActionIgnoreCase:(id)sender
{
	if ( [sender isOn] )
		flags |= WCF_IGNORECASE;
	else
		flags &= ~WCF_IGNORECASE;
}

- (void)switchActionAlways:(id)sender
{
	if ( [sender isOn] )
		flags |= WCF_ALWAYS;
	else
		flags &= ~WCF_ALWAYS;
}


#pragma mark Load View

- (id)init
{
	self = [super init];
	if (self)
	{
		// this title will appear in the navigation bar
		self.title = NSLocalizedString(@"Edit Word", @"");
		wordListItem = nil;
		flags = WCF_ALWAYS | WCF_IGNORECASE;
	}
	
	return self;
}

- (void)dealloc
{
	[myTableView release];
	[wordFromField release];
	[wordToField release];
	
	[switchDisable release];
	[switchIgnoreCase release];
	[switchAlways release];
	
	[wordListItem release];
	
	[super dealloc];
}

- (void)loadView
{
	[super loadView];
	
	// setup our parent content view and embed it to your view controller
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	contentView.backgroundColor = [UIColor blackColor];
	contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	contentView.autoresizesSubviews = YES;
	self.view = contentView;
	[contentView release];
	
	self.editing = YES;
	
	// create and configure the table view
	myTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];	
	myTableView.delegate = self;
	myTableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	myTableView.dataSource = self;

	myTableView.scrollEnabled = NO;	// no scrolling in this case, we don't want to interfere with touch events on edit fields
	[self.view addSubview: myTableView];
	
	// create our text fields to be recycled when UITableViewCells are created
	wordFromField = [self createTextField:NSLocalizedString( @"<enter misspelled word>", @"")];	
	wordToField = [self createTextField:NSLocalizedString( @"<enter correct word>", @"")];	
			
	[self create_switchAlways];
	[self create_switchDisable];
	[self create_switchIgnoreCase];
}


#pragma mark - UITableView delegates

// if you want the entire table to just be re-orderable then just return UITableViewCellEditingStyleNone
//
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *title = nil; // NSLocalizedString( @"Edit Autocorrector Word", @"" );
	return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return kUIControlTableTotal_Rows;
}

// to determine specific row height for each cell, override this.  In this example, each row is determined
// buy the its subviews that are embedded.
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat result = kUIRowHeight;
	return result;
}

// utility routine leveraged by 'cellForRowAtIndexPath' to determine which UITableViewCell to be used on a given row
//
- (UITableViewCell *)obtainTableCellForRow:(NSInteger)row
{
	UITableViewCell *cell = nil;

	if ( row == 0 || row == 1 )
		cell = [myTableView dequeueReusableCellWithIdentifier:kCellTextField_ID];
	else if ( row >= 2 )
		cell = [myTableView dequeueReusableCellWithIdentifier:kDisplayCell_ID];
	
	if (cell == nil)
	{
		if ( row == 0 || row == 1 )
		{
			cell = [[[CellTextField alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellTextField_ID] autorelease];
			((CellTextField *)cell).delegate = self;	// so we can detect when cell editing starts
		}
		else if ( row >= 2 )
		{
			cell = [[[DisplayCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDisplayCell_ID] autorelease];
		}
	}
	
	return cell;
}

// to determine which UITableViewCell to be used on a given row.
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger row = [indexPath row];
	UITableViewCell *sourceCell = [self obtainTableCellForRow:row];
	
	if ( indexPath.section == 0 )
	{
		switch( row )
		{
			case kUIWordFrom_Row :
				// this cell hosts the text field control
				((CellTextField *)sourceCell).view = wordFromField;	
				wordFromCell = (CellTextField *)sourceCell;	// kept track for editing
				break;
				
			case kUIWordTo_Row :
				// this cell hosts the text field control
				((CellTextField *)sourceCell).view = wordToField;				
				wordToCell = (CellTextField *)sourceCell;	// kept track for editing
				break;
				
			case kUIWordEnabled_Row :
				// this cell hosts the UIPageControl control
				((DisplayCell *)sourceCell).nameLabel.text = NSLocalizedString( @"Disabled", @"" );
				((DisplayCell *)sourceCell).view =  switchDisable;				
				break;
				
			case kUIIgnoreCase_Row :
				// this cell hosts the UIPageControl control
				((DisplayCell *)sourceCell).nameLabel.text = NSLocalizedString( @"Always Replace", @"" );
				((DisplayCell *)sourceCell).view =  switchAlways;				
				break;
				
			case kUIAlwaysReplace_Row :
				// this cell hosts the UIPageControl control
				((DisplayCell *)sourceCell).nameLabel.text = NSLocalizedString( @"Ignore Case", @"" );
				((DisplayCell *)sourceCell).view =  switchIgnoreCase;				
				break;
		}
	}
	return sourceCell;	
}

#pragma mark <EditableTableViewCellDelegate> Methods and editing management

- (BOOL)cellShouldBeginEditing:(EditableTableViewCell *)cell
{
    // notify other cells to end editing
    if (![cell isEqual:wordFromCell])
		[wordFromCell stopEditing];
    if (![cell isEqual:wordToCell])
		[wordToCell stopEditing];
    return self.editing;
}

- (void)cellDidEndEditing:(EditableTableViewCell *)cell
{
}

#pragma mark - UIViewController delegate methods

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if ( nil != wordListItem )
	{
		wordFromField.text = wordListItem.wordFrom;
		wordToField.text = wordListItem.wordTo;
		flags = wordListItem.flags;
	}
	
	switchIgnoreCase.on = (0 != (flags & WCF_IGNORECASE));
	switchAlways.on = (0 != (flags & WCF_ALWAYS));
	switchDisable.on = (0 != (flags & WCF_DISABLED));
	
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	if ( nil != wordListItem && [wordFromField.text length] > 0 && [wordToField.text length] > 0 )
	{
		if ( wordListItem.flags != flags ||
			NSOrderedSame != [wordListItem.wordFrom compare:wordFromField.text] ||
			NSOrderedSame != [wordListItem.wordTo compare:wordToField.text] )
		{
			wordListItem.wordFrom = wordFromField.text;
			wordListItem.wordTo = wordToField.text;
			wordListItem.flags = flags;
			
			if ( delegate != nil && [delegate respondsToSelector:@selector(editWordViewController:wordModified:isNew:)])
			{
				[delegate editWordViewController:self wordModified:wordListItem isNew:NO];
			}
		}
	}
	else if ( nil == wordListItem && [wordFromField.text length] > 0 && [wordToField.text length] > 0 )
	{
		// Add new word to the WORD LIST 
		WordListItem *	 item = [WordListItem alloc];
		item.wordFrom = wordFromField.text;
		item.wordTo = wordToField.text;
		item.flags = flags;
		
		if ( delegate != nil && [delegate respondsToSelector:@selector(editWordViewController:wordModified:isNew:)])
		{
			[delegate editWordViewController:self wordModified:item isNew:YES];
		}
		[item release];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	return YES; // (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end


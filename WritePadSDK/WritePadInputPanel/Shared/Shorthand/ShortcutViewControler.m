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

#import "ShortcutViewControler.h"
#import "DisplayCell.h"
#import "SourceCell.h"
#import "UIConst.h"
#import "OptionKeys.h"

@implementation ShortcutViewControler

@synthesize shortcuts;
@synthesize shortcut;
@synthesize delegate;
@synthesize editing;

- (UITextView *)create_UITextView
{
	CGRect frame = CGRectMake(0.0, 0.0, kUIShortcutCellHeight, kUIShortcutCellHeight);
	
	UITextView *textView = [[[UITextView alloc] initWithFrame:frame] autorelease];
    textView.textColor = [UIColor blackColor];
    textView.font = [UIFont fontWithName:@"Arial" size:kUIShortcutFontSize];
    textView.backgroundColor = [UIColor whiteColor];
	textView.returnKeyType = UIReturnKeyDefault;
	// textView.placeholder = @"<Enter Shorthand Text>";
	textView.keyboardType = UIKeyboardTypeDefault;	// use the default type input method (entire keyboard)
	
	textView.text = shortcut.text;
	
	// note: for UITextView, if you don't like autocompletion while typing use:
	// myTextView.autocorrectionType = UITextAutocorrectionTypeNo;
	
	return textView;
}

- (UITextField *)create_UItextField
{
	CGRect frame = CGRectMake(0.0, 0.0, kTextFieldWidth, kTextFieldHeight);
	UITextField *textField = [[[UITextField alloc] initWithFrame:frame] autorelease];
    
	textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.textColor = [UIColor blackColor];
	textField.font = [UIFont systemFontOfSize:17.0];
    textField.placeholder = NSLocalizedString( @"Enter Shorthand Name", @"" );
    textField.backgroundColor = [UIColor whiteColor];
	textField.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
	textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	
	textField.text = shortcut.name;
	
	textField.keyboardType = UIKeyboardTypeDefault;
	textField.returnKeyType = UIReturnKeyDone;
	// textField.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
	
	return textField;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView 
{
	[super loadView];

	item.title = NSLocalizedString( @"Shorthand", @"" );

    if ( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad )
    {
        table.scrollEnabled = NO; // no scrolling in this case, we don't want to interfere with text view scrolling
        table.autoresizesSubviews = YES;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ( alertView.tag == 1 && buttonIndex == 0 )
	{
		if ( nameCell != nil )
			[nameCell.view becomeFirstResponder];
	}
	if ( alertView.tag == 2 && buttonIndex == 0 )
	{
		if ( textCell != nil )
			[textCell.view becomeFirstResponder];
	}
}

- (IBAction)saveAction:(id)sender
{
	// save the changes in the Shortcut
	NSString * sText = [textCell.view text];
	NSString * sName = [nameCell.view text];
	
	NSCharacterSet * charset = [NSCharacterSet characterSetWithCharactersInString:@" ,.~`@#$%^&*()_+=-{}[]\\|:;\"\'/?<>"];
	if ( nil == sName || [sName length] < 2 || [sName rangeOfCharacterFromSet:charset].location != NSNotFound )
	{
		// name contain invalid characters or too short.
		// show error message
		NSString * strTitle = [NSString stringWithString:NSLocalizedString( @"The Shorthand name must be at least 2 characters long and may contain only a...z, A...Z, and 0...9 characters.", @"")];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"Error", @"") 
														message:strTitle
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString( @"Cancel", @"")  
											  otherButtonTitles:nil];
		alert.tag = 1;
		[alert show];	
		[alert release];
		return;
	}
	
	if ( nil == sText || 1 > [sText length] )
	{
		// show error message
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"Error", @"") 
														message:NSLocalizedString( @"Shorthand text must not be empty.", @"")
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString( @"Cancel", @"")  
											  otherButtonTitles:nil];
		alert.tag = 2;
		[alert show];	
		[alert release];
		return;
	}
	

	// validate the name
	if ( [shortcut.name caseInsensitiveCompare:sName] != NSOrderedSame && nil != [shortcuts findByName:sName] )
	{
		NSString * strTitle = [NSString stringWithFormat:NSLocalizedString( @"Shorthand \"%@\" already exists; please use a different name.", @""), sName];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"Error", @"") 
														message:strTitle
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString( @"Cancel", @"")  
											  otherButtonTitles:nil];
		alert.tag = 1;
		[alert show];	
		[alert release];
		return;
	}
		
	shortcut.name = sName;
	shortcut.text = sText;
	if ( !editing )
	{	
		[shortcuts addUserShortcut:shortcut];
	}
	else
	{
		shortcuts.modified = YES;
		[shortcuts resetRecognizer];
		[shortcuts saveUserShortcuts];
	}
	
	if ( nil != self.delegate && [self.delegate respondsToSelector:@selector(shortcutAddedOrChanged:)])
		[self.delegate shortcutAddedOrChanged:shortcut];
	
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)cancelAction:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.title = NSLocalizedString( @"Shorthand", @"" );
}

- (void)viewDidAppear:(BOOL)animated
{
	if ( nil != nameCell && [nameCell.view.text length] < 1 )
		[nameCell.view becomeFirstResponder];
	else
		[textCell.view becomeFirstResponder];

	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];	
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc
{
	[shortcut release];
    [super dealloc];
}

#pragma mark - UITableView delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	int nRes = 1;
	return nRes;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *title = nil;
	return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	int nRes = 2;
	return nRes;
}	

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat result = kUIRowHeight;
	if ( [indexPath section] == 0 )
	{		
		if ( [indexPath row] == 1 )
			result = kUIShortcutCellHeight;
	}
	return result;
}

- (UITableViewCell *)obtainTableCellForRowSection0:(NSInteger)row
{
	UITableViewCell *cell = nil;
	
	if (row == 1)
		cell = [table dequeueReusableCellWithIdentifier:kCellTextView_ID];
	else if (row == 0)
		cell = [table dequeueReusableCellWithIdentifier:kCellTextField_ID];
	
	if (cell == nil)
	{
		if (row == 1)
			cell = [[[CellTextView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellTextView_ID] autorelease];
		else if (row == 0)
			cell = [[[CellTextField alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellTextField_ID] autorelease];
	}
	return cell;
}

- (UITableViewCell *)obtainTableCellForRowSection1:(NSInteger)row
{
	UITableViewCell *cell = nil;
	
	if (row == 0)
		cell = [table dequeueReusableCellWithIdentifier:kDisplayCell_ID];
	else if (row == 1 )
		cell = [table dequeueReusableCellWithIdentifier:kSourceCell_ID];
	
	if (cell == nil)
	{
		if (row == 0)
			cell = [[[DisplayCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDisplayCell_ID] autorelease];
		else if (row == 1 )
			cell = [[[SourceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSourceCell_ID] autorelease];
	}
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger row = [indexPath row];
	NSInteger sec = [indexPath section];
	UITableViewCell * cell = nil;
	if ( sec == 0 )
	{
		cell = [self obtainTableCellForRowSection0:row];
		if ( row == 0 )
		{
			
			((CellTextField *)cell).view = [self create_UItextField];
			nameCell = (CellTextField *)cell;
		}
		else
		{
			((CellTextView *)cell).view = [self create_UITextView];
			textCell = (CellTextView *)cell;
		}
	}
	return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if (editingStyle == UITableViewCellEditingStyleDelete )
	{
	} 
	else if (editingStyle == UITableViewCellEditingStyleInsert) 
	{
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	return YES;
}

#pragma mark <EditableTableViewCellDelegate> Methods and editing management

- (BOOL)cellShouldBeginEditing:(EditableTableViewCell *)cell
{
    // notify other cells to end editing
    if (![cell isEqual:nameCell])
		[nameCell stopEditing];
	if ( ![cell isEqual:textCell])
		[textCell stopEditing];
    return YES;
}

- (void)cellDidEndEditing:(EditableTableViewCell *)cell
{
	/*
	// get text from the edit 
	if ( [cell isEqual:nameCell] )
		shortcut.name = nameCell.view.text;
	else if ( [cell isEqual:textCell] )
		shortcut.text = textCell.view.text;
	*/
}


@end


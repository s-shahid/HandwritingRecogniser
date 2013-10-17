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

#import "ShortcutListPopup.h"
#import "UIConst.h"

@implementation ShortcutListPopup

@synthesize delegate;
@synthesize aShortcuts;

#pragma mark -
#pragma mark Initialization


- (id)initWithStyle:(UITableViewStyle)style 
{
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) 
	{
    }
    return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
	
	buttonItemClose = [[UIBarButtonItem alloc] 
					   initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(actionClose:)];
	buttonItemAdd = [[UIBarButtonItem alloc] 
					 initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(actionAddWord:)];
	
	self.title = NSLocalizedString( @"Execute Shorthand", @"" );
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	self.navigationItem.rightBarButtonItem = buttonItemClose;
	// self.navigationItem.leftBarButtonItem = buttonItemAdd;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popController
{
	if ( nil != popoverController )
	{
		if ( delegate != nil && [delegate respondsToSelector:@selector(shortcutPopoverDidDismiss:)])
		{
			[delegate shortcutPopoverDidDismiss:self];
		}		
		popoverController.delegate = nil;
		[popoverController release];
		popoverController = nil;
	}
}

- (void)hidePopover:(BOOL)animated
{
	if ( nil != popoverController )
	{
		[popoverController dismissPopoverAnimated:animated];
		[self popoverControllerDidDismissPopover:popoverController];
	}
}

- (void)repositionPopover:(CGRect)rPosition inView:(UIView *)view
{
	if ( nil != popoverController )
	{
		[popoverController presentPopoverFromRect:rPosition inView:view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
	}
}

- (void)showPopover:(UIBarButtonItem *)fromButton
{
	// Create a navigation controller to contain the recent searches controller, and create the popover controller to contain the navigation controller.
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self];
	UIPopoverController * popover = [[UIPopoverController alloc] initWithContentViewController:navigationController];
	popover.delegate = self;
	[popover presentPopoverFromBarButtonItem:fromButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];		
	popoverController = popover;
	[navigationController release];
}

- (void)viewWillAppear:(BOOL)animated 
{
	[self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
}

/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */

- (CGSize)contentSizeForViewInPopoverView
{
    return CGSizeMake( 320, 400 );
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self hidePopover:NO]; 
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Overriden to allow any orientation.
    if ( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    else
        return YES;
}

#pragma mark -

- (IBAction)actionClose:(id)sender
{
	NSLog(@"Close Button was clicked");
	[popoverController dismissPopoverAnimated:YES];
	[self popoverControllerDidDismissPopover:popoverController];
}

- (IBAction)actionAddWord:(id)sender
{
	NSLog(@"Add Button was clicked");
	if ( delegate != nil && [delegate respondsToSelector:@selector(shortcutListPopupAdd:)])
	{
		[delegate shortcutListPopupAdd:self];
	}
	[popoverController dismissPopoverAnimated:YES];
	[self popoverControllerDidDismissPopover:popoverController];
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return [aShortcuts countUser] > 0 ? 2 : 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if ( [aShortcuts countUser] > 0 && section == 0 )
		return [aShortcuts countUser];
    return [aShortcuts countSystem];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat result = kWordCellHeight;
	return result;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSInteger row = [indexPath row];
	NSInteger section = [indexPath section];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
	if ( cell == nil )
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"] autorelease];
	}
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.editingAccessoryType = UITableViewCellAccessoryNone;
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	if ( section == 0 && row < [aShortcuts countUser] )
	{
		Shortcut * sh = [aShortcuts userShortcutByIndex:row];
		if ( nil != sh )
			cell.textLabel.text = sh.name;
	}
	else
	{
		Shortcut * sh = [aShortcuts sysShortcutByIndex:row];
		if ( nil != sh )
			cell.textLabel.text = sh.name;
	}
	return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSInteger row = [indexPath row];
	NSInteger section = [indexPath section];
	if ( delegate != nil && [delegate respondsToSelector:@selector(shortcutListPopup:executeShortcut:)])
	{
		if ( section == 0 && row < [aShortcuts countUser] )
		{
			Shortcut * sh = [aShortcuts userShortcutByIndex:row];
			if ( nil != sh )
				[delegate shortcutListPopup:self executeShortcut:sh];
		}
		else
		{
			Shortcut * sh = [aShortcuts sysShortcutByIndex:row];
			if ( nil != sh )
				[delegate shortcutListPopup:self executeShortcut:sh];
		}
	}
	[popoverController dismissPopoverAnimated:YES];
	[self popoverControllerDidDismissPopover:popoverController];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *title = nil; // @"";
	
	if ( section == 0 && [aShortcuts countUser] > 0 )
	{
		title = NSLocalizedString( @"User Commands", @"" );
	}
	else
	{
		title = NSLocalizedString( @"System Commands", @"" );
	}
	return title;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning 
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc 
{
	[buttonItemAdd release];
	[buttonItemClose release];
	[popoverController release];
    [super dealloc];
}


@end


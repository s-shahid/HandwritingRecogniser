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

#import "ResultAlternatives.h"
#import "RecognizerWrapper.h"
#import "UIConst.h"

#ifndef SET_CURR_POPOVER
#define SET_CURR_POPOVER(x) ((void)0)
#endif 

@implementation ResultAlternatives

@synthesize delegate;
@synthesize aWords;
@synthesize addWord;

#pragma mark -
#pragma mark Initialization


- (id)initWithStyle:(UITableViewStyle)style 
{
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) 
	{
		addWord = NO;
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
	
	self.title = NSLocalizedString( @"Alternatives", @"" );
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	self.navigationItem.rightBarButtonItem = buttonItemClose;
	if ( addWord )
		self.navigationItem.leftBarButtonItem = buttonItemAdd;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popController
{
	if ( nil != popoverController )
	{
		if ( delegate != nil && [delegate respondsToSelector:@selector(resultAlternativesDidDismiss:)])
		{
			[delegate resultAlternativesDidDismiss:self];
		}		
		popoverController.delegate = nil;
		[popoverController release];
		popoverController = nil;
		SET_CURR_POPOVER( nil );
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
		SET_CURR_POPOVER( popoverController );
		[popoverController presentPopoverFromRect:rPosition inView:view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];		
	}
}

- (void)showPopover:(CGRect)rPosition inView:(UIView *)view
{
	// Create a navigation controller to contain the recent searches controller, and create the popover controller to contain the navigation controller.
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self];
	UIPopoverController * popover = [[UIPopoverController alloc] initWithContentViewController:navigationController];
	popover.delegate = self;
	popoverController = popover;
	SET_CURR_POPOVER( popover );
	[popover presentPopoverFromRect:rPosition inView:view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];		
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

- (CGSize)contentSizeForViewInPopoverView
{
    return CGSizeMake( 300, 220 );
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
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
	if ( delegate != nil && [delegate respondsToSelector:@selector(resultAlternatives:learnWord:weight:)])
	{
		NSString *	word = [[aWords objectAtIndex:0] objectForKey:@"word"];
		NSNumber *	num = [[aWords objectAtIndex:0] objectForKey:@"weight"];
		USHORT		weight = 0;
		if ( num != nil )
			weight = [num unsignedShortValue];
		if ( [word length] > 0 && NSOrderedSame != [word compare:kEmptyWord] )
		{
			[delegate resultAlternatives:self learnWord:word weight:weight];
		}
	}
	[popoverController dismissPopoverAnimated:YES];
	[self popoverControllerDidDismissPopover:popoverController];
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [aWords count];
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
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
	if ( cell == nil )
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"] autorelease];
	}
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.editingAccessoryType = UITableViewCellAccessoryNone;
	cell.accessoryType = UITableViewCellAccessoryNone;
	NSString * s = [[aWords objectAtIndex:row] objectForKey:@"word"];
	cell.textLabel.text = s;
	cell.textLabel.textColor = (addWord && row == 0) ? [UIColor redColor] : [UIColor blackColor];
	return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSInteger row = [indexPath row];
	if ( row < [aWords count] )
	{
		if ( delegate != nil && [delegate respondsToSelector:@selector(resultAlternatives:wordSelected:wordIndex:)])
		{
			NSString * word = [[aWords objectAtIndex:0]  objectForKey:@"word"];
			if ( [word length] > 0 )
			{
				[delegate resultAlternatives:self wordSelected:word wordIndex:row];
			}
		}		
	}
	[popoverController dismissPopoverAnimated:YES];
	[self popoverControllerDidDismissPopover:popoverController];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
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


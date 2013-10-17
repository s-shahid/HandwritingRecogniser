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

#import "ShortcutListViewController.h"
#import "ShortcutViewControler.h"
#import "ShortcutViewCell.h"
#import "UIConst.h"

static NSString *kAddCellIdentifier = @"DictCellIdentifier";


@implementation ShortcutListViewController

@synthesize table;
@synthesize shortcuts;

- (id)init
{
	self = [super init];
	if (self)
	{
	}
	return self;
}

#pragma mark Initialize View

- (void)loadView
{
	[super loadView];
	
	// this title will appear in the navigation bar
	self.title = NSLocalizedString( @"Shorthand List", @"" );

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
	table = [[UITableView alloc] initWithFrame:viewFrame style:UITableViewStylePlain];	
	table.delegate = self;
	table.dataSource = self;
	table.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	table.autoresizesSubviews = YES;
	table.hidden = NO;
	table.allowsSelectionDuringEditing = YES;
	
	// table.editing = YES;
	[self.view addSubview:table];
}

- (IBAction)editAction 
{
	if ( shortcuts != nil )
	{
		[table setEditing:YES animated:YES];
		self.navigationItem.rightBarButtonItem = buttonItemDone;
		[table reloadData];
	}
}

- (IBAction)doneAction 
{
	if ( shortcuts != nil )
	{
		[table setEditing:NO animated:YES];
		self.navigationItem.rightBarButtonItem = buttonItemEdit;
		[table reloadData];
	}
}

#pragma mark UIViewController delegate methods

// called after this controller's view was dismissed, covered or otherwise hidden
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];	
	
	if ( [table isEditing] )
		[table setEditing:NO animated:NO];
	if ( nil != self.navigationItem.rightBarButtonItem )
		self.navigationItem.rightBarButtonItem = nil;

	// save changes
}

// called after this controller's view will appear
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	if ( nil != table )
		[table reloadData];
	
	if ( ! table.hidden && shortcuts != nil )
		self.navigationItem.rightBarButtonItem = [table isEditing] ? buttonItemDone : buttonItemEdit;
}

// called after this controller's view will appear
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if ( [shortcuts countUser] < 1 )
	{
		[self editAction];
	}
}
	
- (void) shortcutAddedOrChanged:(Shortcut *)shortcut
{
	[table reloadData];
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
	NSString *title = (shortcuts==nil) ? NSLocalizedString( @"Recognizer Not Loaded...", @"" ) : @"";
	return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	int nRes = 0;
	if ( shortcuts != NULL )
	{
		nRes = [shortcuts countUser];
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
	CGFloat result = ([tableView isEditing] && [indexPath row] == 0) ? kNewWordCellHeight : 100.0;
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
		cell = [tableView dequeueReusableCellWithIdentifier:kAddCellIdentifier];
		if ( cell == nil )
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kAddCellIdentifier] autorelease];
			cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		cell.textLabel.text = NSLocalizedString( @"<New Shorthand>", @"" );		
		cell.textLabel.textColor = [UIColor darkGrayColor];
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	else
	{	
		ShortcutViewCell * cl = (ShortcutViewCell *)[tableView dequeueReusableCellWithIdentifier:kShortcutViewCell_ID];
		if ( cl == nil )
		{
			cl = [[[ShortcutViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kShortcutViewCell_ID] autorelease];
			cl.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		NSInteger index = [tableView isEditing] ? row-1 : row;
		Shortcut * sc = [shortcuts userShortcutByIndex:index];
		if ( nil != sc )
			[cl setShortcut:sc];
		cell = cl;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}

- (void) addShortcut
{
	// add new shortcut
	Shortcut * sc = [[Shortcut alloc] initWithName:@"" shortcut:([shortcuts countUser] + kWPSysShortcutTotal + 1)];
	ShortcutViewControler *shortcutView = [[ShortcutViewControler alloc] initWithNibName:@"ShortcutDialog" bundle:nil];
	shortcutView.shortcuts = shortcuts;
	shortcutView.shortcut = sc;
	shortcutView.delegate = self;
	shortcutView.editing = NO;
	shortcutView.modalPresentationStyle = UIModalPresentationFormSheet;
	shortcutView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self presentModalViewController:shortcutView animated:YES];
	[shortcutView release];		
	[sc release];	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSInteger row = [indexPath row];
	if ( [tableView isEditing] && row == 0 )
	{
		[self addShortcut];
		return;
	}
	else if ( [tableView isEditing] )
	{
		row--;
	}
	Shortcut * sc = [shortcuts userShortcutByIndex:row];
	ShortcutViewControler *shortcutView = [[ShortcutViewControler alloc] initWithNibName:@"ShortcutDialog" bundle:nil];
	shortcutView.shortcuts = shortcuts;
	shortcutView.shortcut = sc;
	shortcutView.delegate = self;
	shortcutView.editing = YES;
	shortcutView.modalPresentationStyle = UIModalPresentationFormSheet;
	shortcutView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self presentModalViewController:shortcutView animated:YES];
	[shortcutView release];		
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ( [table isEditing] )
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
			// delete shortcut
			[shortcuts deleteUserShortcut:[shortcuts userShortcutByIndex:([indexPath row]-1)]];
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		} 
		else if (editingStyle == UITableViewCellEditingStyleInsert) 
		{
			[self addShortcut];
		}
	}
}


#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    // Overriden to allow any orientation.
    if ( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    else
        return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc 
{
    self.shortcuts = nil;
	[table setDelegate:nil];
	[table release];
	
	[buttonItemEdit release];
	[buttonItemDone release];		
    [super dealloc];
}


@end

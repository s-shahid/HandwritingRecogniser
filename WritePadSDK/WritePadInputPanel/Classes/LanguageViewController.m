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

#import "LanguageViewController.h"
#import "OptionKeys.h"
#import "UIConst.h"

static NSString *kCellIdentifier = @"MyCellIdentifier";

@implementation LanguageViewController

@synthesize delegate;
@synthesize languages;
@synthesize tag;
@synthesize selectedIndex;

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView 
{
	[super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.navigationController.title = NSLocalizedString( @"Default Language", @"" );
	self.title = NSLocalizedString( @"Default Language", @"" );;
	self.modalInPopover = YES;
	
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc
{
	[languages release];
   [super dealloc];
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
	NSString *title = nil;
    if ( section == 0 )
        title = NSLocalizedString( @"Select Your Primary Language", @"" );
	return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger nRes = [languages count];
	return nRes;
}	

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat result = kUIRowHeight;
	return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *	cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
	if ( cell == nil )
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier] autorelease];
	}
    NSInteger row = [indexPath row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ( row < [languages count] )
    {
        cell.textLabel.text = [[languages objectAtIndex:row] objectForKey:@"name"];
        cell.imageView.image = [UIImage imageNamed:[[languages objectAtIndex:row] objectForKey:@"image"]];	
    }	
	if ( [indexPath row] == selectedIndex )
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSInteger row = [indexPath row];
    if ( row >= [languages count] )
        return;
	selectedIndex = row;
    
    NSString * strMsg = [NSString stringWithFormat:NSLocalizedString(@"You have selected %@ as your primary language for handwriting recognition. Do you want to keep this selection?", @""), [[languages objectAtIndex:row] objectForKey:@"name"]];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"Default Language", @"" )
                                                     message:strMsg
                                                    delegate:self 
                                           cancelButtonTitle:nil
                                           otherButtonTitles:NSLocalizedString( @"Yes", @"" ), NSLocalizedString( @"No", @"" ), nil];
    alert.tag = 43;
    [alert show];	
    [alert release];			
    [self.tableView reloadData];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if ( alertView.tag == 43 && buttonIndex == 0 && selectedIndex < [languages count] )
    {
        if (delegate && [delegate respondsToSelector:@selector(languageSelected:language:)])
        {
            [delegate languageSelected:self language:[[[languages objectAtIndex:selectedIndex] objectForKey:@"ID"] intValue]];
        }
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	return YES; // [utils shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

@end

/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    Copyright (c) 1997-2011 PhatWare(r) Corp. All rights reserved.                 * */
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
 * 530 Showers Drive Suite 7 #333 Mountain View, CA 94040
 *
 * ************************************************************************************* */

#include <sys/types.h>
#include <sys/sysctl.h>

#import "EditOptionsViewController.h"
#import "WordListEditViewController.h"
#import "DictEditViewController.h"
#import "DisplayCell.h"
#import "SourceCell.h"
#import "RecoFilesView.h"
#import "UIConst.h"
#import "OptionKeys.h"
#import "LetterShapesController.h"
#import "WritePadInputPanel.h"
#import "LanguageManager.h"
#import "RecognizerManager.h"
#import "Reachability.h"
#import "Shortcuts.h"
#import "ShortcutListViewController.h"

#define IN_APP_PURCHASE_LANGUAGES   1       // TODO: set to 0 to disable in-app purchase

@implementation EditOptionsViewController

@synthesize tableOptions;
@synthesize showDone;

static NSString * kEditCell_ID = @"WMEditSectionEditSettingsID";

- (id)init
{
	self = [super init];
	if (self)
	{
		// this title will appear in the navigation bar
		self.title = NSLocalizedString( @"Settings", @"" );
		showDone = NO;
	}
	return self;
}

#pragma mark Create Controls

- (void)create_switches
{
	for ( int i = 0; i < kUITotalSwitch_Sections; i++ )
	{
		CGRect frame = CGRectMake(0.0, 0.0, kSwitchButtonWidth, kSwitchButtonHeight);
		switchCtl[i] = [[UISwitch alloc] initWithFrame:frame];
		[switchCtl[i] addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
		
		// in case the parent view draws with a custom color or gradient, use a transparent color
		switchCtl[i].backgroundColor = [UIColor clearColor];
	}
}

- (void)switchAction:(id)sender
{
	NSUserDefaults*	defaults = [NSUserDefaults standardUserDefaults];
		
	if ( sender == switchCtl[kUIInsertResult_Section] )
		[defaults setBool:[sender isOn] forKey:kRecoOptionsInsertResult];
	if ( sender == switchCtl[kUIVibrate_Section] )
		[defaults setBool:[sender isOn] forKey:kRecoOptionsErrorVibrate];
	if ( sender == switchCtl[kUISingleWord_Section] )
		[defaults setBool:[sender isOn]  forKey:kRecoOptionsSingleWordOnly];
	if ( sender == switchCtl[kUISeparateLetters_Section] )
		[defaults setBool:[sender isOn]  forKey:kRecoOptionsSeparateLetters];
	if ( sender == switchCtl[kUIAutospace_Section] )
		[defaults setBool:(![sender isOn])  forKey:kEditOptionsAutospace];
	if ( sender == switchCtl[kUIOnlyDictWords_Section] )
		[defaults setBool:[sender isOn]  forKey:kRecoOptionsDictOnly];
	if ( sender == switchCtl[kUIUseUserDict_Section] )
		[defaults setBool:[sender isOn] forKey:kRecoOptionsUseUserDict];
	if ( sender == switchCtl[kUIUseLearner_Section] )
		[defaults setBool:[sender isOn] forKey:kRecoOptionsUseLearner];
	if ( sender == switchCtl[kUIUseCorrector_Section] )
		[defaults setBool:[sender isOn] forKey:kRecoOptionsUseCorrector];
	if ( sender == switchCtl[kUIVibrate_Section+1] )
		[defaults setBool:[sender isOn] forKey:kRecoOptionsErrorSound];
}

- (Boolean) isPhone
{
	int		mib[2];
	char	szTmp[100] = "";
	size_t len;
	
	mib[0] = CTL_HW;
	mib[1] = HW_MACHINE;
	len = sizeof(szTmp);
	int res = sysctl(mib, 2, &szTmp, &len, NULL, 0);
	if ( res == 0 )
	{	
		if ( strncmp( szTmp, "iPhone", 6 ) == 0 )
			return TRUE;
	}
	return FALSE;
}

#pragma mark Initialize View

- (void)loadView
{
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	
	// setup our parent content view and embed it to your view controller
	UIView *contentView = [[UIView alloc] initWithFrame:screenRect];
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];	// use the table view background color
		
	self.view = contentView;
	[contentView release];
	
	CGRect viewFrame = [self.view bounds];
		
	// create and configure the table view
	tableOptions = [[UITableView alloc] initWithFrame:viewFrame style:UITableViewStyleGrouped];	
	tableOptions.delegate = self;
	tableOptions.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	tableOptions.dataSource = self;
	tableOptions.autoresizesSubviews = YES;
	
	[self.view addSubview:tableOptions];
	
	// Custom initialization
	if ( showDone )
	{
		buttonItemDone = [[UIBarButtonItem alloc] 
						  initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
		self.navigationItem.leftBarButtonItem = buttonItemDone;
	}
	
	[self create_switches];
}

- (IBAction)doneAction:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];	
}

#pragma mark UIViewController delegate methods

// called after this controller's view was dismissed, covered or otherwise hidden
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];	
		
}

// called after this controller's view will appear
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
		
	NSUserDefaults*	defaults = [NSUserDefaults standardUserDefaults];
	switchCtl[kUIInsertResult_Section].on = [defaults boolForKey:kRecoOptionsInsertResult];
	switchCtl[kUISeparateLetters_Section].on = [defaults boolForKey:kRecoOptionsSeparateLetters];
	switchCtl[kUIAutospace_Section].on = (![defaults boolForKey:kEditOptionsAutospace]);
	switchCtl[kUISingleWord_Section].on = [defaults boolForKey:kRecoOptionsSingleWordOnly];
	switchCtl[kUIOnlyDictWords_Section].on = [defaults boolForKey:kRecoOptionsDictOnly];
	switchCtl[kUIUseUserDict_Section].on = [defaults boolForKey:kRecoOptionsUseUserDict];
	switchCtl[kUIUseLearner_Section].on = [defaults boolForKey:kRecoOptionsUseLearner];
	switchCtl[kUIUseCorrector_Section].on = [defaults boolForKey:kRecoOptionsUseCorrector];
	switchCtl[kUIVibrate_Section].on = [defaults boolForKey:kRecoOptionsErrorVibrate];
	switchCtl[kUIVibrate_Section+1].on = [defaults boolForKey:kRecoOptionsErrorSound];
	
	[tableOptions reloadData];	
}

#pragma mark - UITableView delegates

// if you want the entire table to just be re-orderable then just return UITableViewCellEditingStyleNone
//

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return kUITotal_Sections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *title = @"";
	switch( section )
	{
		case kUIUseLearner_Section :
			title = NSLocalizedString( @"Recognizer Settings", @"" );
			break;
			
		case kUIOnlyDictWords_Section :
			title = NSLocalizedString( @"Dictionary Settings", @"" );
			break;
						
		case kUIManageUserData_Section :
			title = NSLocalizedString( @"Manage User Data", @"" );
			break;
            
        case kUIShorthandList_Section :
            title = NSLocalizedString( @"Shorthands", @"" );
            break;

		case kUIUseLanguage_Section :
			title = NSLocalizedString( @"Language", @"" );
			break;
	}
	return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if ( section == kUIManageUserData_Section || section == kUIShapeSelector_Section ||
        section == kUIUseLanguage_Section || section == kUIShorthandList_Section )
    {
		return 1;
    }
	if ( section == kUIVibrate_Section )
    {
		return 	[self isPhone] ? 3 : 2;
    }
	if ( (section == kUIUseUserDict_Section || section == kUIUseCorrector_Section) )
    {
		return 3;
    }
	return 2;
}

// to determine specific row height for each cell, override this.  In this example, each row is determined
// buy the its subviews that are embedded.
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat result = kUIRowHeight;
	if ( ([indexPath section] == kUIUseUserDict_Section || [indexPath section] == kUIUseCorrector_Section) && [indexPath row] == 2 )
		result = kWordCellHeight;
	else if ( [indexPath section] == kUIVibrate_Section && [indexPath row] == 1 && [self isPhone] )
		result = kUIRowHeight;
	else if ( [indexPath row] == 1 )
		result = kUIRowLabelHeight;
	else if ( [indexPath row] == 2 )
		result = kUIRowLabelHeight;
	return result;
}

// utility routine leveraged by 'cellForRowAtIndexPath' to determine which UITableViewCell to be used on a given row
//
- (UITableViewCell *)obtainTableCellForTable:(UITableView*)tableView withRow:(NSInteger)row
{
	UITableViewCell *cell = nil;
	
	if (row == 0)
		cell = [tableView dequeueReusableCellWithIdentifier:kDisplayCell_ID];
	else if (row == 1 )
		cell = [tableView dequeueReusableCellWithIdentifier:kSourceCell_ID];
	else 
		cell = [tableView dequeueReusableCellWithIdentifier:kEditCell_ID];
	
	if (cell == nil)
	{
		if (row == 0)
			cell = [[[DisplayCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDisplayCell_ID] autorelease];
		else if (row == 1 )
			cell = [[[SourceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSourceCell_ID] autorelease];
		else
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kEditCell_ID] autorelease];
	}
	return cell;
}

// to determine which UITableViewCell to be used on a given row.
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger row = [indexPath row];				
	UITableViewCell *cell = nil;
	
	if ( indexPath.section == kUIManageUserData_Section ||  indexPath.section == kUIShapeSelector_Section ||
        indexPath.section == kUIUseLanguage_Section || indexPath.section == kUIShorthandList_Section )
	{
		cell = [tableView dequeueReusableCellWithIdentifier:kEditCell_ID];
		if ( cell == nil )
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kEditCell_ID] autorelease];
		}
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        switch( indexPath.section )
        {
            case kUIShapeSelector_Section :
                cell.textLabel.text = NSLocalizedString( @"Letter Shapes", @"" );
                break;
                
            case kUIManageUserData_Section :
                cell.textLabel.text = NSLocalizedString( @"Manage User Data", @"" );
                break;
                
            case kUIShorthandList_Section :
                cell.textLabel.text = NSLocalizedString( @"Edit Shorthand List", @"" );
                break;
                
            case kUIUseLanguage_Section :
                cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString( @"Language: %@", @"" ), [[LanguageManager sharedManager] languageName]];
                break;
        }
		return cell;
	}
	
	cell = [self obtainTableCellForTable:tableView withRow:row];
	switch( indexPath.section )
	{
		case kUIUseLearner_Section :
			if (row == 0)
			{
				// this cell hosts the UISwitch control
				((DisplayCell *)cell).nameLabel.text = NSLocalizedString( @"Auto Learner", @"" );
				((DisplayCell *)cell).view = switchCtl[indexPath.section];
			}
			else
			{
				// this cell hosts the info on where to find the code
				((SourceCell *)cell).sourceLabel.text = NSLocalizedString( @"If ON, recognizer will learn your handwriting patterns.", @"" );
			}	
			break;

		case kUIUseCorrector_Section :
			if (row == 0)
			{
				// this cell hosts the UISwitch control
				((DisplayCell *)cell).nameLabel.text = NSLocalizedString( @"Autocorrector", @"" );
				((DisplayCell *)cell).view = switchCtl[indexPath.section];
			}
			else if ( row == 1 )
			{
				// this cell hosts the info on where to find the code
				((SourceCell *)cell).sourceLabel.text = NSLocalizedString( @"If ON, common spelling errors automatically corrected.", @"" );
			}	
			else 
			{
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.textLabel.text = NSLocalizedString( @"Edit Autocorrector List", @"" );
				// cell.imageView.image = [UIImage imageNamed:@"scroll_replace.png"];
			}
			break;
			
		case  kUIAutospace_Section :
			if (row == 0)
			{
				// this cell hosts the UISwitch control
				((DisplayCell *)cell).nameLabel.text = NSLocalizedString( @"Add Space", @"" );
				((DisplayCell *)cell).view = switchCtl[indexPath.section];
			}
			else
			{
				// this cell hosts the info on where to find the code
				((SourceCell *)cell).sourceLabel.text = NSLocalizedString( @"If ON, a space is added at the end.", @"" );
			}
			break;
			
		case  kUISeparateLetters_Section :
			if (row == 0)
			{
				// this cell hosts the UISwitch control
				((DisplayCell *)cell).nameLabel.text = NSLocalizedString( @"Separate Letters", @"" );
				((DisplayCell *)cell).view = switchCtl[indexPath.section];
			}
			else
			{
				// this cell hosts the info on where to find the code
				((SourceCell *)cell).sourceLabel.text = NSLocalizedString( @"If ON, do not connect individual letters.", @"" );
			}
			break;
			
		case kUISingleWord_Section :
			if (row == 0)
			{
				// this cell hosts the UIPageControl control
				((DisplayCell *)cell).nameLabel.text = NSLocalizedString( @"Single Word Only", @"" );
				((DisplayCell *)cell).view =  switchCtl[indexPath.section];
			}
			else
			{
				// this cell hosts the info on where to find the code
				((SourceCell *)cell).sourceLabel.text = NSLocalizedString( @"If ON, write one word per recognition session.", @"" );
			}
			break;
			
		case kUIInsertResult_Section :
			if (row == 0)
			{
				// this cell hosts the UIPageControl control
				((DisplayCell *)cell).nameLabel.text = NSLocalizedString( @"Autoinsert Results", @"" );
				((DisplayCell *)cell).view =  switchCtl[indexPath.section];
			}
			else
			{
				// this cell hosts the info on where to find the code
				((SourceCell *)cell).sourceLabel.text = NSLocalizedString( @"Inserts recognized text when starting a new line left of marker.", @"" );
			}
			break;
			
		case kUIOnlyDictWords_Section :
			if (row == 0)
			{
				// this cell hosts the UIPageControl control
				((DisplayCell *)cell).nameLabel.text = NSLocalizedString( @"Only Known Words", @"" );
				((DisplayCell *)cell).view =  switchCtl[indexPath.section];
			}
			else
			{
				// this cell hosts the info on where to find the code
				((SourceCell *)cell).sourceLabel.text = NSLocalizedString( @"If ON, only dictionary words are recognized.", @"" );
			}
			break;
			
		case kUIUseUserDict_Section :
			if (row == 0)
			{
				// this cell hosts the UIPageControl control
				((DisplayCell *)cell).nameLabel.text = NSLocalizedString( @"User Dictionary", @"" );
				((DisplayCell *)cell).view =  switchCtl[indexPath.section];
			}
			else if ( row == 1 )
			{
				// this cell hosts the info on where to find the code
				((SourceCell *)cell).sourceLabel.text = NSLocalizedString( @"If ON, user dictionary is enabled.", @"" );
			}
			else 
			{
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.textLabel.text = NSLocalizedString( @"Edit User Dictionary", @"" );
				// cell.imageView.image = [UIImage imageNamed:@"dictionary.png"];
			}
			break;
			
		case kUIVibrate_Section :
			if (row == 0 && [self isPhone] )
			{
				// this cell hosts the UIPageControl contro
				cell = [self obtainTableCellForTable:tableView withRow:0];
				((DisplayCell *)cell).nameLabel.text = NSLocalizedString( @"Vibrate", @"" );
				((DisplayCell *)cell).view =  switchCtl[indexPath.section];
			}
			else if ( (row == 1 && [self isPhone]) || (row == 0 && (![self isPhone])) )
			{
				// this cell hosts the UIPageControl control
				cell = [self obtainTableCellForTable:tableView withRow:0];
				((DisplayCell *)cell).nameLabel.text = NSLocalizedString( @"Play Sound", @"" );
				((DisplayCell *)cell).view =  switchCtl[indexPath.section+1];
			}
			else
			{
				// this cell hosts the info on where to find the code
				cell = [self obtainTableCellForTable:tableView withRow:1];
				if ( [self isPhone] )
					((SourceCell *)cell).sourceLabel.text = NSLocalizedString( @"If ON, device vibrates/plays sound on error/timeout.", @"" );
				else
					((SourceCell *)cell).sourceLabel.text = NSLocalizedString( @"If ON, device plays sound on error/timeout.", @"" );
				((SourceCell *)cell).sourceLabel.textColor = [UIColor blackColor];
			}
			break;
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSInteger row = [indexPath row];
	switch( indexPath.section )
	{
		case kUIUseUserDict_Section :
			switch ( row )
			{				
				case 2 :
					{
						DictEditViewController *viewController = [[DictEditViewController alloc] init];
						[self.navigationController pushViewController:viewController animated:YES];	
						[viewController release];
					}
					break;
			}
			break;
			
		case kUIUseCorrector_Section :
			switch ( row )
			{
				case 2 :
					{
						WordListEditViewController *viewController = [[WordListEditViewController alloc] init];
						[self.navigationController pushViewController:viewController animated:YES];	
						[viewController release];
					}
					break;
			}
			break;
			
		case kUIManageUserData_Section :
			switch ( row )
			{
				case 0 :
					{
						RecoFilesView * viewController = [[RecoFilesView alloc] initWithNibName:@"RecoFilesView" bundle:nil];
						[self.navigationController pushViewController:viewController animated:YES];	
						[viewController release];
					}
					break;
			}
			break;
			
		case kUIShapeSelector_Section :
			switch ( row )
			{
				case 0 :
					{
						LetterShapesController *viewController = [[LetterShapesController alloc] init];
						[self.navigationController pushViewController:viewController animated:YES];	
						[viewController release];
					}
					break;
			}
			break;

		case kUIShorthandList_Section :
			switch ( row )
            {
                case 0 :
                    {
                        ShortcutListViewController * viewController = [[ShortcutListViewController alloc] init];
                        viewController.shortcuts = [[[Shortcuts alloc] init] autorelease];
                        [self.navigationController pushViewController:viewController animated:YES];
                        [viewController release];
                    }
                    break;
            }
			break;
			
        case kUIUseLanguage_Section :
			switch ( row )
            {
                case 0 :
                    {
                        SimpleSelectorController *viewController = [[SimpleSelectorController alloc] initWithNibName:@"SimpleSelector" bundle:nil];
                        NSArray * langs = [[LanguageManager sharedManager] supportedLanguages];
                        NSMutableArray * languages = [NSMutableArray arrayWithCapacity:[langs count]];
                        NSMutableArray * images = [NSMutableArray arrayWithCapacity:[langs count]];
                        NSInteger index = 0;
                        viewController.selectedIndex = index;
                        for ( NSNumber * l in langs )
                        {
                            switch ( [l intValue] )
                            {
                                case LANGUAGE_ENGLISH :
                                    [languages addObject: NSLocalizedString( @"English (United States)", @"" )];
                                    [images addObject:@"flag_usa.png"];
                                    if ( [LanguageManager sharedManager].currentLanguage == WPLanguageEnglishUS )
                                        viewController.selectedIndex = index;
                                    index++;
                                    [languages addObject: NSLocalizedString( @"English (Great Britain)", @"" )];
                                    [images addObject:@"flag_uk.png"];
                                    if ( [LanguageManager sharedManager].currentLanguage == WPLanguageEnglishUK )
                                        viewController.selectedIndex = index;
                                    index++;
                                    break;
                                    
                                case LANGUAGE_PORTUGUESE :
                                    [languages addObject: NSLocalizedString( @"Português (Portugal)", @"" )];
                                    [images addObject:@"flag_portugal.png"];
                                    if ( [LanguageManager sharedManager].currentLanguage == WPLanguagePortuguese )
                                        viewController.selectedIndex = index;
                                    index++;                        
                                    break;
                                    
                                case LANGUAGE_PORTUGUESEB :
                                    [languages addObject: NSLocalizedString( @"Português (Brasil)", @"" )];
                                    [images addObject:@"flag_brazil.png"];
                                    if ( [LanguageManager sharedManager].currentLanguage == WPLanguageBrazilian )
                                        viewController.selectedIndex = index;
                                    index++;                        
                                    break;
                                    
                                case LANGUAGE_GERMAN :
                                    [languages addObject: NSLocalizedString( @"Deutsch", @"" )];
                                    [images addObject:@"flag_germany.png"];
                                    if ( [LanguageManager sharedManager].currentLanguage == WPLanguageGerman )
                                        viewController.selectedIndex = index;
                                    index++;                        
                                    break;
                                    
                                case LANGUAGE_FRENCH :
                                    [languages addObject: NSLocalizedString( @"Français", @"" )];
                                    [images addObject:@"flag_france.png"];
                                    if ( [LanguageManager sharedManager].currentLanguage == WPLanguageFrench )
                                        viewController.selectedIndex = index;
                                    index++;                        
                                    break;
                                    
                                case LANGUAGE_ITALIAN :
                                    [languages addObject: NSLocalizedString( @"Italiano", @"" )];
                                    [images addObject:@"flag_italy.png"];
                                    if ( [LanguageManager sharedManager].currentLanguage == WPLanguageItalian )
                                        viewController.selectedIndex = index;
                                    index++;                        
                                    break;
                                    
                                case LANGUAGE_DUTCH :
                                    [languages addObject: NSLocalizedString( @"Nederlands", @"" )];
                                    [images addObject:@"flag_netherlands.png"];
                                    if ( [LanguageManager sharedManager].currentLanguage == WPLanguageDutch )
                                        viewController.selectedIndex = index;
                                    index++;                        
                                    break;
                                    
                                case LANGUAGE_SPANISH :
                                    [languages addObject: NSLocalizedString( @"Español", @"" )];
                                    [images addObject:@"flag_spain.png"];
                                    if ( [LanguageManager sharedManager].currentLanguage == WPLanguageSpanish )
                                        viewController.selectedIndex = index;
                                    index++;                        
                                    break;
                                    
                                case LANGUAGE_SWEDISH :
                                    [languages addObject: NSLocalizedString( @"Svenska", @"" )];
                                    [images addObject:@"flag_sweden.png"];
                                    if ( [LanguageManager sharedManager].currentLanguage == WPLanguageSwedish )
                                        viewController.selectedIndex = index;
                                    index++;                        
                                    break;
                                    
                                case LANGUAGE_FINNISH :
                                    [languages addObject: NSLocalizedString( @"Suomi", @"" )];
                                    [images addObject:@"flag_finland.png"];
                                    if ( [LanguageManager sharedManager].currentLanguage == WPLanguageFinnish )
                                        viewController.selectedIndex = index;
                                    index++;                        
                                    break;
                                    
                                case LANGUAGE_NORWEGIAN :
                                    [languages addObject: NSLocalizedString( @"Norsk", @"" )];
                                    [images addObject:@"flag_norway.png"];
                                    if ( [LanguageManager sharedManager].currentLanguage == WPLanguageNorwegian )
                                        viewController.selectedIndex = index;
                                    index++;                        
                                    break;
                                    
                                case LANGUAGE_DANISH :
                                    [languages addObject: NSLocalizedString( @"Dansk", @"" )];
                                    [images addObject:@"flag_denmark.png"];
                                    if ( [LanguageManager sharedManager].currentLanguage == WPLanguageDanish )
                                        viewController.selectedIndex = index;
                                    index++;                        
                                    break;
                            }
                            
                        }
                        viewController.choices = [NSArray arrayWithArray:languages];
                        viewController.iconnames = [NSArray arrayWithArray:images];
                        viewController.delegate = self;
                        viewController.tag = 1;
                        viewController.strTitle = NSLocalizedString( @"Language", @"" );
                        [self.navigationController pushViewController:viewController animated:YES];	
                        [viewController release];							
                    }
                    break;
            }
			break;
			
			
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

#pragma mark - Slect new language

- (void) itemSelected:(SimpleSelectorController *)viewController itemName:(NSString *)strItem itemIndex:(NSInteger)nItem
{
	int lcurrent = [[NSUserDefaults standardUserDefaults] integerForKey:kGeneralOptionsCurrentLanguage];
    int language = lcurrent;
    if ( [strItem caseInsensitiveCompare:NSLocalizedString( @"Português (Brasil)", @"" )] == NSOrderedSame )
    {
        language = WPLanguageBrazilian;
    }
    else if ( [strItem caseInsensitiveCompare:NSLocalizedString( @"Português (Portugal)", @"" )] == NSOrderedSame )
    {
        language = WPLanguagePortuguese;
    }
    else if ( [strItem caseInsensitiveCompare:NSLocalizedString( @"English (United States)", @"" )] == NSOrderedSame )
    {
        language = WPLanguageEnglishUS;
    }
    else if ( [strItem caseInsensitiveCompare:NSLocalizedString( @"English (Great Britain)", @"" )] == NSOrderedSame )
    {
        language = WPLanguageEnglishUK;
    }
    else if ( [strItem caseInsensitiveCompare:NSLocalizedString( @"Medical English (US)", @"" )] == NSOrderedSame )
    {
        language = WPLanguageMedicalUS;
    }
    else if ( [strItem caseInsensitiveCompare:NSLocalizedString( @"Deutsch", @"" )] == NSOrderedSame )
    {
        language = WPLanguageGerman;
    }
    else if ( [strItem caseInsensitiveCompare:NSLocalizedString( @"Français", @"" )] == NSOrderedSame )
    {
        language = WPLanguageFrench;
    }
    else if ( [strItem caseInsensitiveCompare:NSLocalizedString( @"Italiano", @"" )] == NSOrderedSame )
    {
        language = WPLanguageItalian;
    }
    else if ( [strItem caseInsensitiveCompare:NSLocalizedString( @"Español", @"" )] == NSOrderedSame )
    {
        language = WPLanguageSpanish;
    }
    else if ( [strItem caseInsensitiveCompare:NSLocalizedString( @"Nederlands", @"" )] == NSOrderedSame )
    {
        language = WPLanguageDutch;
    }
    else if ( [strItem caseInsensitiveCompare:NSLocalizedString( @"Svenska", @"" )] == NSOrderedSame )
    {
        language = WPLanguageSwedish;
    }
    else if ( [strItem caseInsensitiveCompare:NSLocalizedString( @"Dansk", @"" )] == NSOrderedSame )
    {
        language = WPLanguageDanish;
    }
    else if ( [strItem caseInsensitiveCompare:NSLocalizedString( @"Norsk", @"" )] == NSOrderedSame )
    {
        language = WPLanguageNorwegian;
    }
    else if ( [strItem caseInsensitiveCompare:NSLocalizedString( @"Suomi", @"" )] == NSOrderedSame )
    {
        language = WPLanguageFinnish;
    }
    if ( lcurrent != language )
    {
#if (IN_APP_PURCHASE_LANGUAGES==1)
        if ( ! [WritePadStoreManager isLanguagePackPurchased:language] )
        {
            if ( [Reachability IsInternetAvaialble] == NotReachable )
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Internet Connection", @"")
                                                                message:NSLocalizedString(@"Please connect to Internet to purchase Language Pack.", @"")
                                                               delegate:nil 
                                                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                      otherButtonTitles: nil];
                [alert show];
                [alert release];		
                return;
            }
            // other language packs, use different view controller
            // show purchase dialog
            PurchaseLanguageViewController *viewController;
            if ( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
                viewController = [[PurchaseLanguageViewController alloc] initWithNibName:@"PurchaseLanguageViewController_iPhone" bundle:nil];
            else
                viewController = [[PurchaseLanguageViewController alloc] initWithNibName:@"PurchaseLanguageViewController_iPad" bundle:nil];                
            viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            viewController.delegate = self;
            viewController.language_id = language;
            viewController.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentModalViewController:viewController animated:YES]; 
            // The navigation controller is now owned by the current view controller 
            // and the root view controller is owned by the navigation controller, 
            // so both objects should be released to prevent over-retention. 
            [viewController release];			                           
            return;
        }
#endif // IN_APP_PURCHASE_LANGUAGES
		int mode = [[RecognizerManager sharedManager] getMode];
		[[RecognizerManager sharedManager] disable:YES];
		[[NSUserDefaults standardUserDefaults] setInteger:language forKey:kGeneralOptionsCurrentLanguage];
		[[RecognizerManager sharedManager] enable];
		[[RecognizerManager sharedManager] setMode:mode];
	}
	[tableOptions reloadData];
}

#pragma mark App Store delegate

- (void)purchaseLanguageControllerTransactionComplete:(PurchaseLanguageViewController *)viewController

{
	if ( [WritePadStoreManager isLanguagePackPurchased:viewController.language_id] )
	{
		int language = viewController.language_id;
		if ( language != [[NSUserDefaults standardUserDefaults] integerForKey:kGeneralOptionsCurrentLanguage] )
		{
			// language change
			int mode = [[RecognizerManager sharedManager] getMode];
			[[RecognizerManager sharedManager] disable:YES];
			[[NSUserDefaults standardUserDefaults] setInteger:language forKey:kGeneralOptionsCurrentLanguage];
			[[RecognizerManager sharedManager] enable];
			[[RecognizerManager sharedManager] setMode:mode];
		}
		[tableOptions reloadData];
	}
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES; // (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] postNotificationName:EDITCTL_RELOAD_OPTIONS object:nil];
  	[tableOptions setDelegate:nil];
	[tableOptions release];
	[buttonItemDone release];
	
	for ( int i = 0; i < kUITotalSwitch_Sections; i++ )
	{
		[switchCtl[i] release];
	}
	[super dealloc];
}


@end

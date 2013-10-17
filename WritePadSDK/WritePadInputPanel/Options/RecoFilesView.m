//
//  RecoFilesView.m
//  WritePadEN
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

#import "RecoFilesView.h"
#import "OptionKeys.h"
#import "UIConst.h"
#import "DisplayCell.h"
#import "SourceCell.h"
#import "RecognizerManager.h"

static NSString *kResetCellIdentifier = @"ResetCellID";
#define USER_DICTIONARY_TEXT_FILE	@"WritePadUserDictionary.txt"
#define AUTOCORRECTOR_TEXT_FILE		@"WritePadAutocorrector.csv"

enum ExportTableSections
{
	kExportShare_Section,
	kExportUserDict_Section,
	kExportAurocorrector_Section,
	kExportRest_Setcion,
	kExportTotal_Sections
};

enum ResetSectionRows
{
	kResetDictionary_Row = 0,
	kResetWordList_Row,
	kResetLearner_Row,
	kResetAll_Row,
	kResetTotal_Rows
};

enum ExportActionRows
{
	kExportExport_Row = 0,
	kExportImport_Row,
    kImportContacts_Row,
    kUserDictTotal_Rows,
	kExportTotal_Rows = kImportContacts_Row,
};

@interface RecoFilesView (RecoFilesViewPrivate)

- (void)dialogResetAction:(NSInteger)tag withActionButton:(NSString *)strBtn withTitle:(NSString *)strTitle;
- (void)dialogFileExportResult:(NSString *)strFileName isSuccess:(Boolean)success;
- (void)dialogFileImportResult:(NSString *)strFileName isSuccess:(Boolean)success;
- (void)dialogFileDoesNotExist:(NSString *)strFileName;
- (UISwitch *)createCustSwitch;

@end


@implementation RecoFilesView

- (id)initWithStyle:(UITableViewStyle)style 
{
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) 
	{
    }
    return self;
}

#pragma mark - View methods

- (void)viewDidLoad 
{
    [super viewDidLoad];

	_recognizer = [[RecognizerManager sharedManager] recognizer];
	switchShare = [self createCustSwitch];
	self.tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	self.title = NSLocalizedString( @"User Data", @"" );
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	
	switchShare.on = [[NSUserDefaults standardUserDefaults] boolForKey:kOptionsShareUserData];
	[self.tableView reloadData]; 
}

- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated 
{
	[super viewWillDisappear:animated];
	
}
- (void)viewDidDisappear:(BOOL)animated 
{
	[super viewDidDisappear:animated];
}

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
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark - Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return kExportTotal_Sections;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// export table
	if ( section == kExportRest_Setcion )
		return kResetTotal_Rows;
	else if ( section == kExportUserDict_Section )
        return kUserDictTotal_Rows;
    else if ( section == kExportAurocorrector_Section )
		return kExportTotal_Rows;
	return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat result = kUIRowHeight;

	if ( [indexPath section] == kExportShare_Section )
	{
		if ( [indexPath row] == 1 )
			result = kUIRowLabelHeight;
	}
	else
	{
		result = kWordCellHeight;
	}
	return result;
}	

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *title = nil; // @"";
	
	if ( section == kExportShare_Section )
	{
		title = NSLocalizedString( @"Share Data with Other Apps", @"" );
	}
	if ( section == kExportRest_Setcion )
	{
		title = NSLocalizedString( @"Reset Recognizer Settings", @"" );
	}
	else if ( section == kExportUserDict_Section )
	{
		title = NSLocalizedString( @"User Dictionary", @"" );
	}
	else if ( section == kExportAurocorrector_Section )
	{
		title = NSLocalizedString( @"Autocorrector", @"" );
	}
	return title;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSInteger row = [indexPath row];
	UITableViewCell *cell = nil;

	if ( kExportShare_Section == indexPath.section )
	{
		if ( row == 0 )
		{
			cell = [tableView dequeueReusableCellWithIdentifier:kDisplayCell_ID];
			if ( nil == cell )
				cell = [[[DisplayCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDisplayCell_ID] autorelease];
			// this cell hosts the UISwitch control
			((DisplayCell *)cell).nameLabel.text = NSLocalizedString( @"Share User Data", @"" );
			((DisplayCell *)cell).view = switchShare;
		}
		else if ( row == 1 )
		{
			cell = [tableView dequeueReusableCellWithIdentifier:kSourceCell_ID];
			if ( cell == nil )
				cell = [[[SourceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSourceCell_ID] autorelease];
			((SourceCell *)cell).sourceLabel.text = NSLocalizedString( @"If ON user data is shared with compatible apps.", @"" );
		}
		return cell;
	}
	
	cell = [tableView dequeueReusableCellWithIdentifier:kResetCellIdentifier];
	if ( cell == nil )
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kResetCellIdentifier] autorelease];
	switch ( indexPath.section )
	{				
		case kExportRest_Setcion :
			switch( row )
		{
			case kResetDictionary_Row :
				cell.textLabel.text = NSLocalizedString( @"Reset User Dictionary", @"" );
				cell.textLabel.textAlignment = UITextAlignmentCenter;
				break;
				
			case kResetWordList_Row :
				cell.textLabel.text = NSLocalizedString( @"Reset Autocorrector", @"" );
				cell.textLabel.textAlignment = UITextAlignmentCenter;
				break;
				
			case kResetLearner_Row :
				cell.textLabel.text = NSLocalizedString( @"Reset Learner", @"" );
				cell.textLabel.textAlignment = UITextAlignmentCenter;
				break;
				
			case kResetAll_Row :
				cell.textLabel.text = NSLocalizedString( @"Reset All", @"" );
				cell.textLabel.textAlignment = UITextAlignmentCenter;
				break;
		}
			break;
			
		case kExportUserDict_Section :
		case kExportAurocorrector_Section :
			switch( row )
		{
			case kExportExport_Row :
				cell.textLabel.text = NSLocalizedString( @"Export to File", @"" );
				cell.textLabel.textAlignment = UITextAlignmentCenter;
				break;
				
			case kExportImport_Row :
				cell.textLabel.text = NSLocalizedString( @"Import from File", @"" );
				cell.textLabel.textAlignment = UITextAlignmentCenter;
				break;
                
            case kImportContacts_Row :
				cell.textLabel.text = NSLocalizedString( @"Import Words from Contacts & Calendar", @"" );
				cell.textLabel.textAlignment = UITextAlignmentCenter;
                break;
		}
			break;
	}
	return cell;
}

- (void) importFromContacts
{
    DictImportContacts * import = [[[DictImportContacts alloc] init] autorelease];
    import.delegate = self;
    [import importContacts];
}

- (void) dictImportContactsComplete:(DictImportContacts *)importController newWordsAdded:(NSNumber *)added
{
    NSInteger w = [added integerValue];
    NSString * strAlert;
    if ( w > 0 )
    {
        strAlert = [[NSString alloc] initWithFormat:NSLocalizedString( @"%d new word%@added to the user dictionary.", @""), w, (w==1) ? @" " : @"s "]; 
    }
    else
    {
        strAlert = [[NSString alloc] initWithString:NSLocalizedString( @"No new words have been found.", @"" )];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"Success", @"") 
                                                    message:strAlert
                                                   delegate:nil cancelButtonTitle:NSLocalizedString( @"OK", @"")  otherButtonTitles: nil];
    [alert show];	
    [alert release];
    [strAlert release];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSInteger row = [indexPath row];

	if ( _recognizer != NULL )
	{
		if ( indexPath.section == kExportRest_Setcion )
		{
			switch( row )
			{
				case kResetDictionary_Row :
					[self dialogResetAction:row withActionButton:NSLocalizedString( @"Reset User Dictionary", @"") 
								  withTitle:NSLocalizedString( @"User Dictionary will revert to the original word list.", @"" )];					
					break;
					
				case kResetWordList_Row :
					[self dialogResetAction:row withActionButton:NSLocalizedString( @"Reset Autocorrector", @"")
								  withTitle:NSLocalizedString( @"Autocorrector word list will revert to the original list.", @"" )];					
					break;
					
				case kResetLearner_Row :
					[self dialogResetAction:row withActionButton:NSLocalizedString( @"Reset Learner", @"") 
								  withTitle:NSLocalizedString( @"Recognizer statistics will revert to its original state.", @"" )];					
					break;
					
				case kResetAll_Row :
					[self dialogResetAction:row withActionButton:NSLocalizedString( @"Reset All Settings", @"") 
								  withTitle:NSLocalizedString( @"All user-defined data, including recognizer statistics, Autocorrector word list, and user dictionary will revert to their original states.", @"" )];					
					break;
			}
		}
		else if ( indexPath.section == kExportUserDict_Section )
		{
			// use documents folder
			NSArray *  paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString * folder = [paths objectAtIndex:0];
			NSString * strUserFile =  [folder stringByAppendingPathComponent:USER_DICTIONARY_TEXT_FILE];
			Boolean	   bExists = NO;
			NSFileHandle *	file = [NSFileHandle fileHandleForReadingAtPath:strUserFile];
			if ( file != nil )
			{
				bExists = YES;
				[file closeFile];
			}
			
			switch( row )
			{
				case kExportExport_Row :
					[self dialogFileExportResult:strUserFile isSuccess:HWR_ExportUserDictionary( _recognizer, [strUserFile UTF8String] )];
					break;
					
				case kExportImport_Row :
					if ( ! bExists )
					{
						[self dialogFileDoesNotExist:strUserFile];
						[tableView deselectRowAtIndexPath:indexPath animated:YES];
						return;
					}
					[self dialogResetAction:(10+row) withActionButton:NSLocalizedString( @"Import from File", @"") 
								  withTitle:NSLocalizedString( @"All words in the user dictionary will be replaced with words imported from file.", @"" )];	
					// HWR_ImportWordList( _recognizer, [strUserFile UTF8String] );
					break;
                    
                case kImportContacts_Row :
                    [self importFromContacts];
                    break;
            }
		}
		else if ( indexPath.section == kExportAurocorrector_Section )
		{
			// use documents folder
			NSArray *  paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString * folder = [paths objectAtIndex:0];			
			NSString *		strUserFile =  [folder stringByAppendingPathComponent:AUTOCORRECTOR_TEXT_FILE];
			Boolean			bExists = NO;
			NSFileHandle *	file = [NSFileHandle fileHandleForReadingAtPath:strUserFile];
			if ( file != nil )
			{
				bExists = YES;
				[file closeFile];
			}
			
			switch( row )
			{
				case kExportExport_Row :
					[self dialogFileExportResult:strUserFile isSuccess:HWR_ExportWordList( _recognizer, [strUserFile UTF8String] )];
					break;
					
				case kExportImport_Row :
					if ( ! bExists )
					{
						[self dialogFileDoesNotExist:strUserFile];
						[tableView deselectRowAtIndexPath:indexPath animated:YES];
						return;
					}					
					[self dialogResetAction:(20+row) withActionButton:NSLocalizedString( @"Import from File", @"") 
								  withTitle:NSLocalizedString( @"All words in the Autocorrector word list will be replaced with words imported from file.", @"" )];					
					break;
			}
		}
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Private functions

- (void)dialogResetAction:(NSInteger)tag withActionButton:(NSString *)strBtn withTitle:(NSString *)strTitle 
{
	// open a dialog with two custom buttons
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:strTitle
															 delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil
													otherButtonTitles:strBtn, NSLocalizedString( @"Cancel", @""), nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	actionSheet.tag = tag;
	actionSheet.destructiveButtonIndex = 0;	// make the first button red (destructive)
	actionSheet.delegate = self;
	[actionSheet showInView:self.view]; // show from our table view (pops up in the middle of the table)
	[actionSheet release];
}

- (NSString *)shortFileName:(NSString *)strFileName
{
	NSString * name;
	if ( [strFileName length] < 1 )
	{
		name = @"<filename>";
	}
	else
	{
		NSInteger  index = [strFileName rangeOfString:@"/" options:(NSCaseInsensitiveSearch | NSBackwardsSearch)].location;
		if ( index != NSNotFound && index < [strFileName length] - 1 )
			name = [strFileName substringFromIndex:(index+1)];
		else 
			name = strFileName;
	}
	return name;
}


- (void)dialogFileExportResult:(NSString *)strFileName isSuccess:(Boolean)success
{
	if ( success )
	{
		NSString * strAlert = [[NSString alloc] initWithFormat:NSLocalizedString( @"File '%@' successfully created!", @""), [self shortFileName:strFileName]]; 
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"Success", @"") 
														message:strAlert
													   delegate:nil cancelButtonTitle:NSLocalizedString( @"OK", @"")  otherButtonTitles: nil];
		[alert show];	
		[alert release];
		[strAlert release];
	}
	else
	{
		NSString * strAlert = [[NSString alloc] initWithFormat:NSLocalizedString( @"Unable to create file '%@'.", @""), [self shortFileName:strFileName]]; 
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"Error", @"") 
														message:strAlert
													   delegate:nil cancelButtonTitle:NSLocalizedString( @"Cancel", @"")  otherButtonTitles: nil];
		[alert show];	
		[alert release];
		[strAlert release];
	}
}

- (void)dialogFileImportResult:(NSString *)strFileName isSuccess:(Boolean)success
{
	if ( success )
	{
		NSString * strAlert = [[NSString alloc] initWithFormat:NSLocalizedString( @"File '%@' successfully imported!", @""), [self shortFileName:strFileName]]; 
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"Success", @"") 
														message:strAlert
													   delegate:nil cancelButtonTitle:NSLocalizedString( @"OK", @"")  otherButtonTitles: nil];
		[alert show];	
		[alert release];
		[strAlert release];
	}
	else
	{
		NSString * strAlert = [[NSString alloc] initWithFormat:NSLocalizedString( @"Unable to import data from file '%@'.", @""), [self shortFileName:strFileName]]; 
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"Error", @"") 
														message:strAlert
													   delegate:nil cancelButtonTitle:NSLocalizedString( @"Cancel", @"")  otherButtonTitles: nil];
		[alert show];	
		[alert release];
		[strAlert release];
	}
}

- (void)dialogFileDoesNotExist:(NSString *)strFileName
{
	// File does not exisit
	// open an alert with just an OK button
	
	NSString * strAlert = [[NSString alloc] initWithFormat:NSLocalizedString( @"File '%@' does not exist. Use Export command to create this file", @""), [self shortFileName:strFileName]]; 
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString( @"Can't Find File", @"") 
													message:strAlert
												   delegate:nil cancelButtonTitle:NSLocalizedString( @"Cancel", @"")  otherButtonTitles: nil];
	[alert show];	
	[alert release];
	[strAlert release];
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
	// use documents folder
	NSArray *	paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *	folder = [paths objectAtIndex:0];
	NSString *	strUserFile;

	if ( actionSheet.tag == 45 || NULL == _recognizer )
	{
		if ( buttonIndex == 0 )
		{
			// WritePadAppDelegateWrapper * app = (WritePadAppDelegateWrapper*)[[UIApplication sharedApplication] delegate];
		}
		else if ( buttonIndex == 1 )
		{
			NSUInteger reload = [[LanguageManager sharedManager].sharedUserData loadPersistentData:YES];
			
			if ( 0 != (reload & PRESISTDATA_USERDICT) )
			{
				[[RecognizerManager sharedManager] reloadRecognizerDataOfType:USERDATA_DICTIONARY];
			}
			if ( 0 != (reload & PRESISTDATA_WORDLIST) )
			{
				[[RecognizerManager sharedManager] reloadRecognizerDataOfType:USERDATA_AUTOCORRECTOR];
			}				
			if ( 0 != (reload & PRESISTDATA_LEARNER) )
			{
				[[RecognizerManager sharedManager] reloadRecognizerDataOfType:USERDATA_LEARNER];
			}
		}
		else 
		{
			switchShare.on = NO;
		}
		return;
	}		
	else if ( buttonIndex > 0 || NULL == _recognizer )
		return;	// DO NOTHING, cancel

	switch ( actionSheet.tag )
	{
		case kResetDictionary_Row :
			[[RecognizerManager sharedManager] resetRecognizerDataOfType:USERDATA_DICTIONARY];
			break;
			
		case kResetWordList_Row :
			[[RecognizerManager sharedManager] resetRecognizerDataOfType:USERDATA_AUTOCORRECTOR];
			break;
			
		case kResetLearner_Row :
			[[RecognizerManager sharedManager] resetRecognizerDataOfType:USERDATA_LEARNER];
			break;
			
		case kResetAll_Row :
			[[RecognizerManager sharedManager] resetRecognizerDataOfType:USERDATA_DICTIONARY+USERDATA_AUTOCORRECTOR+USERDATA_LEARNER];
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_%d", kRecoOptionsLetterShapes, [LanguageManager sharedManager].currentLanguage]];
			HWR_SetDefaultShapes( _recognizer );
			break;
			
		case 10+kExportImport_Row :
			// user dictionary
			strUserFile =  [folder stringByAppendingPathComponent:USER_DICTIONARY_TEXT_FILE];
			[self dialogFileImportResult:strUserFile isSuccess:HWR_ImportUserDictionary( _recognizer, [strUserFile UTF8String] )];
			break;
			
		case 20+kExportImport_Row :
			// autocorrector
			strUserFile =  [folder stringByAppendingPathComponent:AUTOCORRECTOR_TEXT_FILE];
			[self dialogFileImportResult:strUserFile isSuccess:HWR_ImportWordList( _recognizer, [strUserFile UTF8String] )];
			break;
	}
}

- (void)swAction:(id)sender
{
	if ( sender == switchShare )
	{
		[[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:kOptionsShareUserData];
		if ( [sender isOn] )
		{
			if ( [[LanguageManager sharedManager].sharedUserData isPersistentDataAvailable] )
			{
				// Prompt: load shared data / replace shared data
				UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString( @"Shared User data already exists on this device.", @"" )
																		 delegate:self 
																cancelButtonTitle:nil 
														   destructiveButtonTitle:nil
																otherButtonTitles:
											  NSLocalizedString( @"Replace Shared Data", @"" ),
											  NSLocalizedString( @"Load Shared Data", @"" ),
											  NSLocalizedString( @"Cancel", @""), nil];
				actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
				actionSheet.tag = 45;
				actionSheet.destructiveButtonIndex = 0;	// make the first button red (destructive)
				actionSheet.delegate = self;
				[actionSheet showInView:self.view]; // show from our table view (pops up in the middle of the table)
				[actionSheet release];
			}
		}
	}
}

- (UISwitch *)createCustSwitch
{
	CGRect frame = CGRectMake(0.0, 0.0, kSwitchButtonWidth, kSwitchButtonHeight);
	UISwitch * sw = [[UISwitch alloc] initWithFrame:frame];
	[sw addTarget:self action:@selector(swAction:) forControlEvents:UIControlEventValueChanged];
	
	// in case the parent view draws with a custom color or gradient, use a transparent color
	sw.backgroundColor = [UIColor clearColor];
	return sw;
}

#pragma mark - 

- (void)dealloc 
{
	[switchShare release];
    [super dealloc];
}

@end


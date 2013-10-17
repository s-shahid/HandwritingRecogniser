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

#import "OptionKeys.h"
#import "LanguageManager.h"
#import "RecognizerManager.h"
#import "WritePadPersistentData.h"

// define item names
static NSString * strItemUserDict = @"com.PhunkWare.WritePad.UserDict";
static NSString * strItemWordList = @"com.PhunkWare.WritePad.WordList";
static NSString * strItemLearner = @"com.PhunkWare.WritePad.Learner";
static NSString * strItemShortcut = @"com.PhunkWare.WritePad.Shortcut";
static NSString * strItemShapes = @"com.PhunkWare.WritePad.Shapes";
static NSString * strItemDate = @"com.PhunkWare.WritePad.Settings";

typedef struct 
{
	CGFloat		date;
	NSUInteger	flags;
	NSUInteger	reserved1;
	NSUInteger	reserved2;
} USER_DATA_SETTINGS;

@implementation WritePadPersistentData

- (id) initWithLanguageManager:(LanguageManager *)langMan
{
    self = [super init];
	if ( self )
	{
		languageManager = [langMan retain];
	}
	return self;
}

- (UIPasteboard *) pasteboard
{
    NSString * pasteboardName = [languageManager sharedDataName];
    UIPasteboard * sharedPasteboard = nil;
    if ( pasteboardName == nil )
    {
        sharedPasteboard = [UIPasteboard generalPasteboard];
    }
    else
    {
        sharedPasteboard = [UIPasteboard pasteboardWithName:pasteboardName create:NO];
        if ( nil == sharedPasteboard )
            sharedPasteboard = [UIPasteboard pasteboardWithName:pasteboardName create:YES];
        sharedPasteboard.persistent = YES;
    }
    return sharedPasteboard;
}

- (NSUInteger) isPersistentDataAvailable
{
	NSUInteger	result = 0;
    UIPasteboard * sharedPasteboard = [self pasteboard];
    if ( nil == sharedPasteboard )
        return result;
	for ( NSInteger i = 0; i < [sharedPasteboard.items count]; i++ )
	{
		if ( [sharedPasteboard containsPasteboardTypes:[NSArray arrayWithObject:strItemUserDict] inItemSet:[NSIndexSet indexSetWithIndex:i]] )
		{
			NSData * data = [[sharedPasteboard dataForPasteboardType:strItemUserDict inItemSet:[NSIndexSet indexSetWithIndex:i]] objectAtIndex:0];
			if ( data != nil && [data length] > 0 )
				result |= PRESISTDATA_USERDICT;
		}
		
		if ( [sharedPasteboard containsPasteboardTypes:[NSArray arrayWithObject:strItemLearner] inItemSet:[NSIndexSet indexSetWithIndex:i]] )
		{
			NSData * data = [[sharedPasteboard dataForPasteboardType:strItemLearner inItemSet:[NSIndexSet indexSetWithIndex:i]] objectAtIndex:0];
			if ( data != nil && [data length] > 0 )
				result |= PRESISTDATA_LEARNER;
		}

		if ( [sharedPasteboard containsPasteboardTypes:[NSArray arrayWithObject:strItemShapes] inItemSet:[NSIndexSet indexSetWithIndex:i]] )
		{
			NSData * data = [[sharedPasteboard dataForPasteboardType:strItemShapes inItemSet:[NSIndexSet indexSetWithIndex:i]] objectAtIndex:0];
			if ( data != nil && [data length] > 0 )
				result |= PRESISTDATA_SHAPES;
		}
		
		if ( [sharedPasteboard containsPasteboardTypes:[NSArray arrayWithObject:strItemShortcut] inItemSet:[NSIndexSet indexSetWithIndex:i]] )
		{
			NSData * data = [[sharedPasteboard dataForPasteboardType:strItemShortcut inItemSet:[NSIndexSet indexSetWithIndex:i]] objectAtIndex:0];
			if ( data != nil && [data length] > 0 )
				result |= PRESISTDATA_SHORTCUT;
		}
		
		if ( [sharedPasteboard containsPasteboardTypes:[NSArray arrayWithObject:strItemWordList] inItemSet:[NSIndexSet indexSetWithIndex:i]] )
		{
			NSData * data = [[sharedPasteboard dataForPasteboardType:strItemWordList inItemSet:[NSIndexSet indexSetWithIndex:i]] objectAtIndex:0];
			if ( data != nil && [data length] > 0 )
				result |= PRESISTDATA_WORDLIST;
		}
	}
	return result;
}

- (NSUInteger) loadPersistentData:(Boolean)force
{
	NSUInteger	result = 0;
    UIPasteboard * sharedPasteboard = [self pasteboard];
    if ( nil == sharedPasteboard )
        return result;
	if ( [[NSUserDefaults standardUserDefaults] boolForKey:kOptionsShareUserData] )
	{
		NSArray *	paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *	strUserFile =  [languageManager userFilePathOfType:USERDATA_DICTIONARY];
		NSString *	strCorrector =  [languageManager userFilePathOfType:USERDATA_AUTOCORRECTOR];
		NSString *	strLearner =  [languageManager userFilePathOfType:USERDATA_LEARNER];
		NSString *	strShortcut =  [[paths objectAtIndex:0] stringByAppendingPathComponent:USER_SHORTCUT_FILE];
		NSError *	err = nil;
		NSDictionary * attrib;
		NSDate *	lastModified = nil;

		// get settings first
		for ( NSInteger i = 0; i < [sharedPasteboard.items count]; i++ )
		{
			if ( [sharedPasteboard containsPasteboardTypes:[NSArray arrayWithObject:strItemDate] inItemSet:[NSIndexSet indexSetWithIndex:i]] )
			{
				USER_DATA_SETTINGS	set;
				memset( &set, 0, sizeof( USER_DATA_SETTINGS ) );
				NSData * data = [[sharedPasteboard dataForPasteboardType:strItemDate inItemSet:[NSIndexSet indexSetWithIndex:i]] objectAtIndex:0];
				if ( sizeof( USER_DATA_SETTINGS ) == [data length] )
				{
					[data getBytes:&set length:sizeof( USER_DATA_SETTINGS )];
					lastModified = [NSDate dateWithTimeIntervalSinceReferenceDate:set.date];
				}
				break;
			}
		}
		
		for ( NSInteger i = 0; i < [sharedPasteboard.items count]; i++ )
		{
			if ( [sharedPasteboard containsPasteboardTypes:[NSArray arrayWithObject:strItemUserDict] inItemSet:[NSIndexSet indexSetWithIndex:i]] )
			{
				NSData * data = [[sharedPasteboard dataForPasteboardType:strItemUserDict inItemSet:[NSIndexSet indexSetWithIndex:i]] objectAtIndex:0];
				if ( data != nil && [data length] > 0 )
				{
					// check the file date
					attrib = [[NSFileManager defaultManager] attributesOfItemAtPath:strUserFile error:&err];
					NSDate * fileModified = [attrib objectForKey:NSFileModificationDate];
					if ( force || nil == fileModified || nil == lastModified || [fileModified compare:lastModified] == NSOrderedAscending )
					{
						if ( ! [[NSFileManager defaultManager] removeItemAtPath:strUserFile error:&err] )
							NSLog( @"Can't delete exsiting file: %@", err);			
						if ( ! [[NSFileManager defaultManager] createFileAtPath:strUserFile contents:data attributes:nil] )
							NSLog( @"Can't create file, %@", strUserFile );
						else 
							result |= PRESISTDATA_USERDICT;
					}
				}
			}
			
			if ( [sharedPasteboard containsPasteboardTypes:[NSArray arrayWithObject:strItemLearner] inItemSet:[NSIndexSet indexSetWithIndex:i]] )
			{
				NSData * data = [[sharedPasteboard dataForPasteboardType:strItemLearner inItemSet:[NSIndexSet indexSetWithIndex:i]] objectAtIndex:0];
				if ( data != nil && [data length] > 0 )
				{
					// check the file date
					attrib = [[NSFileManager defaultManager] attributesOfItemAtPath:strUserFile error:&err];
					NSDate * fileModified = [attrib objectForKey:NSFileModificationDate];
					if ( force || nil == fileModified || nil == lastModified || [fileModified compare:lastModified] == NSOrderedAscending )
					{
						if ( ! [[NSFileManager defaultManager] removeItemAtPath:strLearner error:&err] )
							NSLog( @"Can't delete exsiting file: %@", err);			
						if ( ! [[NSFileManager defaultManager] createFileAtPath:strLearner contents:data attributes:nil] )
							NSLog( @"Can't create file, %@", strLearner );
						else 
							result |= PRESISTDATA_LEARNER;
					}
				}
			}
			
			if ( [sharedPasteboard containsPasteboardTypes:[NSArray arrayWithObject:strItemShortcut] inItemSet:[NSIndexSet indexSetWithIndex:i]] )
			{
				NSData * data = [[sharedPasteboard dataForPasteboardType:strItemShortcut inItemSet:[NSIndexSet indexSetWithIndex:i]] objectAtIndex:0];
				if ( data != nil && [data length] > 0 )
				{
					// check the file date
					attrib = [[NSFileManager defaultManager] attributesOfItemAtPath:strUserFile error:&err];
					NSDate * fileModified = [attrib objectForKey:NSFileModificationDate];
					if ( force || nil == fileModified || nil == lastModified || [fileModified compare:lastModified] == NSOrderedAscending )
					{
						if ( ! [[NSFileManager defaultManager] removeItemAtPath:strShortcut error:&err] )
							NSLog( @"Can't delete exsiting file: %@", err);			
						if ( ! [[NSFileManager defaultManager] createFileAtPath:strShortcut contents:data attributes:nil] )
							NSLog( @"Can't create file, %@", strShortcut );
						else 
							result |= PRESISTDATA_SHORTCUT;
					}
				}
			}

			if ( [sharedPasteboard containsPasteboardTypes:[NSArray arrayWithObject:strItemShapes] inItemSet:[NSIndexSet indexSetWithIndex:i]] )
			{
				NSData * data = [[sharedPasteboard dataForPasteboardType:strItemShapes inItemSet:[NSIndexSet indexSetWithIndex:i]] objectAtIndex:0];
				if ( data != nil && [data length] > 0 )
				{
					// check the file date
					[[NSUserDefaults standardUserDefaults] setObject:data forKey:[NSString stringWithFormat:@"%@_%d", kRecoOptionsLetterShapes, languageManager.currentLanguage]];
					result |= PRESISTDATA_SHAPES;
				}
			}
			
			if ( [sharedPasteboard containsPasteboardTypes:[NSArray arrayWithObject:strItemWordList] inItemSet:[NSIndexSet indexSetWithIndex:i]] )
			{
				NSData * data = [[sharedPasteboard dataForPasteboardType:strItemWordList inItemSet:[NSIndexSet indexSetWithIndex:i]] objectAtIndex:0];
				if ( data != nil && [data length] > 0 )
				{
					// check the file date
					attrib = [[NSFileManager defaultManager] attributesOfItemAtPath:strUserFile error:&err];
					NSDate * fileModified = [attrib objectForKey:NSFileModificationDate];
					if ( force || nil == fileModified || nil == lastModified || [fileModified compare:lastModified] == NSOrderedAscending )
					{
						if ( ! [[NSFileManager defaultManager] removeItemAtPath:strCorrector error:&err] )
							NSLog( @"Can't delete exsiting file: %@", err);			
						if ( ! [[NSFileManager defaultManager] createFileAtPath:strCorrector contents:data attributes:nil] )
							NSLog( @"Can't create file, %@", strCorrector );
						else 
							result |= PRESISTDATA_WORDLIST;
					}
				}
			}
		}
	}
	return result;
}

- (NSUInteger) reloadPersistentDataIfNeeded
{
    NSUInteger result = [self loadPersistentData:NO];
    return result;
}


- (void) dealloc
{
	[languageManager release];
	[super dealloc];
}

- (void) updatePersistentData
{
	if ( ! [[NSUserDefaults standardUserDefaults] boolForKey:kOptionsShareUserData] )
		return;
    UIPasteboard * sharedPasteboard = [self pasteboard];
    if ( nil == sharedPasteboard )
        return;
	
	NSArray *	paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *	strUserFile =  [languageManager userFilePathOfType:USERDATA_DICTIONARY];
	NSString *	strCorrector =  [languageManager userFilePathOfType:USERDATA_AUTOCORRECTOR];
	NSString *	strLearner =  [languageManager userFilePathOfType:USERDATA_LEARNER];
	NSString *	strShortcut =  [[paths objectAtIndex:0] stringByAppendingPathComponent:USER_SHORTCUT_FILE];
	
	USER_DATA_SETTINGS	set;
	memset( &set, 0, sizeof( USER_DATA_SETTINGS ) );
	set.date = [[NSDate date] timeIntervalSinceReferenceDate];
	NSData * data = [NSData dataWithBytes:&set length:sizeof( USER_DATA_SETTINGS )];

	// set current date
	NSMutableArray * items = [[NSMutableArray alloc] init];
	NSDictionary * item = [NSDictionary dictionaryWithObject:data forKey:strItemDate];
	[items addObject:item];
	
	if ( [[NSFileManager defaultManager] fileExistsAtPath:strUserFile] )
	{
		data = [NSData dataWithContentsOfFile:strUserFile];
		if ( data != nil && [data length] > 0 )
		{
			item = [NSDictionary dictionaryWithObject:data forKey:strItemUserDict];
			[items addObject:item];
		}
	}
	if ( [[NSFileManager defaultManager] fileExistsAtPath:strLearner] )
	{
		data = [NSData dataWithContentsOfFile:strLearner];
		if ( data != nil && [data length] > 0 )
		{
			item = [NSDictionary dictionaryWithObject:data forKey:strItemLearner];
			[items addObject:item];
		}
	}
	if ( [[NSFileManager defaultManager] fileExistsAtPath:strCorrector] )
	{
		data = [NSData dataWithContentsOfFile:strCorrector];
		if ( data != nil && [data length] > 0 )
		{
			item = [NSDictionary dictionaryWithObject:data forKey:strItemWordList];
			[items addObject:item];
		}
	}
	if ( [[NSFileManager defaultManager] fileExistsAtPath:strShortcut] )
	{
		data = [NSData dataWithContentsOfFile:strShortcut];
		if ( data != nil && [data length] > 0 )
		{
			item = [NSDictionary dictionaryWithObject:data forKey:strItemShortcut];
			[items addObject:item];
		}
	}
	data = [[NSUserDefaults standardUserDefaults] dataForKey:[NSString stringWithFormat:@"%@_%d", kRecoOptionsLetterShapes, languageManager.currentLanguage]];
	if ( [data length] > 0 )
	{
		item = [NSDictionary dictionaryWithObject:data forKey:strItemShapes];
		[items addObject:item];
	}
    
	sharedPasteboard.items = items;
	[items release];
}	

@end

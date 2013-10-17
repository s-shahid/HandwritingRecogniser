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

#import "Shortcuts.h"
#import "OptionKeys.h"

typedef struct {
	WPSystemShortcut	command;
	NSString *		name;
	NSString *		text;
	NSInteger		offset;
} WPSYSTEMSHORTCUT;

static WPSYSTEMSHORTCUT sysShortcuts[kWPSysShortcutTotal] = 
{
	kWPSysShortcutSelectAll,		@"all",			@"",				0,
	kWPSysShortcutCom,				@"com",			@"www..com",		-4,
	kWPSysShortcutCopy, 			@"copy",		@"",				0,
	kWPSysShortcutCut,				@"cut",			@"",				0,
	kWPSysShortcutDate,				@"date",		@"",				0,
	kWPSysShortcutDateTime,			@"dt",			@"",				0,
	kWPSysShortcutFtp,				@"ftp",			@"ftp://ftp.",		0,
	kWPSysShortcutMail,				@"mail",		@"",				0,
	kWPSysShortcutNet,				@"net",			@"www..net",		-4,
	kWPSysShortcutAdd,				@"new",			@"",				0,
	kWPSysShortcutOrg,				@"org",			@"www..org",		-4,
	kWPSysShortcutPaste,			@"paste",		@"",				0,
	kWPSysShortcutRedo,				@"redo",		@"",				0,
	kWPSysShortcutSave,				@"save",		@"",				0,
	kWPSysShortcutSend,				@"send",		@"",				0,
	kWPSysShortcutSet,				@"set",			@"",				0,
	kWPSysShortcutSupport,			@"support",		@"PhatWare Corp.\nhttp://www.phatware.com\ninfo@phatware.com\n",	0,
	kWPSysShortcutTime,				@"time",		@"",				0,
	kWPSysShortcutUndo,				@"undo",		@"",				0,
	kWPSysShortcutWww,				@"www",			@"http://www.",		0
};

static int compareShortcuts (id a, id b, void *ctx)
{
	NSString * s1 = ((Shortcut *)a).name;
	NSString * s2 = ((Shortcut *)b).name;
	return [s1 caseInsensitiveCompare:s2];
}


@implementation Shortcuts

@synthesize	delegate;
@synthesize delegateUI;
@synthesize modified;

- (id) init
{
	self = [super init];
	if (self)
	{
		_recognizer = NULL;
		_shortcutsSys = [[NSMutableArray alloc] init];
		for ( int i = 0; i < kWPSysShortcutTotal; i++ )
		{
			Shortcut * sc = [[Shortcut alloc] initWithName:sysShortcuts[i].name shortcut:sysShortcuts[i].command];
			if ( sc != nil )
			{
				sc.text = sysShortcuts[i].text;
				sc.cursorOffset = sysShortcuts[i].offset;
				[_shortcutsSys addObject:sc];
				[sc release];
			}
		}
		_shortcutsUser = [[NSMutableArray alloc] init];
		// load user shortcuts...
		NSArray *   paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);			
		NSString *	documentsPath = [paths objectAtIndex:0];
		_userFileName =  [[NSString alloc] initWithString:[[NSString stringWithString:documentsPath] stringByAppendingPathComponent:USER_SHORTCUT_FILE]];
		if ( ! [[NSFileManager defaultManager] fileExistsAtPath:_userFileName] )
		{			
			// ceeate the defaut user shortcut file if it does not exist
			NSString *	resName = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:USER_SHORTCUT_FILE];
			NSError *	err = nil;
			if ( ! [[NSFileManager defaultManager] copyItemAtPath:resName toPath:_userFileName error:&err] )
			{
				NSLog( @"Can't move file from:\n%@\nto:\n%@\nError: %@",  resName, _userFileName, err );
			}
		}
		[self loadUserShortcuts];
	}
	return self;
}

- (BOOL) resetRecognizer
{
	if ( [self isEnabled] )
	{
		[self enableRecognizer:NO];
		[self enableRecognizer:YES];
	}
	return [self isEnabled];
}

- (BOOL) enableRecognizer:(BOOL)bEnableReco
{	
	if ( bEnableReco && [_shortcutsSys count] > 0 )
	{
		if ( NULL != _recognizer )
		{
			return HWR_Reset( _recognizer );
		}
		else
		{
			_recognizer = HWR_InitRecognizer( NULL,  NULL, NULL, NULL, LANGUAGE_ENGLISH,  NULL );			
			if ( NULL != _recognizer )
			{
				NSUserDefaults*	defaults = [NSUserDefaults standardUserDefaults];
				BOOL b = [defaults boolForKey:kRecoOptionsFirstStartKey];
				if ( b == YES )
				{
					// set recognizer options
					unsigned int	flags = (FLAG_ONLYDICT | FLAG_USERDICT |FLAG_SINGLEWORDONLY | FLAG_NOSPACE);
					if ( [defaults boolForKey:kRecoOptionsSeparateLetters] )
						flags |= FLAG_SEPLET;
					else 
						flags &= ~FLAG_SEPLET;
					if ( [defaults boolForKey:kRecoOptionsInternational] )
						flags |= FLAG_INTERNATIONAL;
					else 
						flags &= ~FLAG_INTERNATIONAL;
					HWR_SetRecognitionFlags( _recognizer, flags );
				}		
				if ( HWR_NewUserDict( _recognizer ) )
				{
					// add commands to the user dictionary
					for ( int i = 0; i < [_shortcutsSys count]; i++ )
					{
						Shortcut *	 sc = [_shortcutsSys objectAtIndex:i];
						const char * pszWord = [sc.name cStringUsingEncoding:RecoStringEncoding];
						if ( pszWord != nil )
						{
							HWR_AddUserWordToDict( _recognizer, pszWord, NO );
						}
					}
					for ( int i = 0; i < [_shortcutsUser count]; i++ )
					{
						Shortcut *	 sc = [_shortcutsUser objectAtIndex:i];
						const char * pszWord = [sc.name cStringUsingEncoding:RecoStringEncoding];
						if ( pszWord != nil )
						{
							HWR_AddUserWordToDict( _recognizer, pszWord, NO );
						}
					}
					return YES;
				}				
			}
		}
	}
	if ( NULL != _recognizer )
	{
		HWR_FreeRecognizer( _recognizer, NULL, NULL, NULL );
		_recognizer = NULL;
	}
	return (_recognizer == NULL) ? NO : YES;
}

- (BOOL) isEnabled
{
	return (_recognizer == NULL) ? NO : YES;
}

- (void) addUserShortcut:(Shortcut *)sc
{
	// add new objects to the beginning of the array
	[_shortcutsUser insertObject:sc atIndex:0];
	modified = YES;
	[self resetRecognizer];
	[self saveUserShortcuts];
}

- (void) deleteUserShortcut:(Shortcut *)sc
{
	[_shortcutsUser removeObject:sc];
	modified = YES;
	[self resetRecognizer];
	[self saveUserShortcuts];
}

- (Shortcut *) findByName:(NSString *)name
{
	for ( Shortcut * sc in _shortcutsSys )
	{
		if ( [sc.name caseInsensitiveCompare:name] == NSOrderedSame )
			return sc;
	}
	for ( Shortcut * sc in _shortcutsUser )
	{
		if ( [sc.name caseInsensitiveCompare:name] == NSOrderedSame )
			return sc;
	}
	return nil;
}

- (void) newShortcut
{
	if ([delegateUI respondsToSelector:@selector(ShortcutsUIEditShortcut:shortcut:isNew:)])
	{
		Shortcut * sc = [[Shortcut alloc] initWithName:@"" shortcut:([_shortcutsUser count] + 1 + kWPSysShortcutTotal)];
        if ( delegate != nil )
            [delegate ShortcutGetSelectedText:sc withGesture:GEST_NONE];
		[delegateUI ShortcutsUIEditShortcut:self shortcut:sc isNew:YES];
		[sc release];
	}
}	

- (BOOL) process:(Shortcut *)sc
{
	BOOL	result = NO;
	
	if ( delegate == nil )
		return result;
	
	if ( sc.command > kWPSysShortcutTotal )
	{
		// user shortcut: simply insert the text at the current cursor location
		return [delegate ShortcutsRecognizedShortcut:sc withGesture:GEST_NONE];
	}
	
	// process system commands
	switch( sc.command )
	{
		case kWPSysShortcutCut :
			result = [delegate ShortcutsRecognizedShortcut:sc withGesture:GEST_CUT];
			break;
			
		case kWPSysShortcutCopy :
			result = [delegate ShortcutsRecognizedShortcut:sc withGesture:GEST_COPY];
			break;
			
		case kWPSysShortcutPaste :
			result = [delegate ShortcutsRecognizedShortcut:sc withGesture:GEST_PASTE];
			break;
			
		case kWPSysShortcutUndo :
			result = [delegate ShortcutsRecognizedShortcut:sc withGesture:GEST_UNDO];
			break;
			
		case kWPSysShortcutRedo :
			result = [delegate ShortcutsRecognizedShortcut:sc withGesture:GEST_REDO];
			break;
			
		case kWPSysShortcutDate :
			// get current date
			result = [delegate ShortcutsRecognizedShortcut:sc withGesture:GEST_NONE];
			break;
			
		case kWPSysShortcutTime :
			// get current time
			result = [delegate ShortcutsRecognizedShortcut:sc withGesture:GEST_NONE];
			break;
			
		case kWPSysShortcutDateTime :
			result = [delegate ShortcutsRecognizedShortcut:sc withGesture:GEST_NONE];
			break;
			
		case kWPSysShortcutSelectAll :
			result = [delegate ShortcutsRecognizedShortcut:sc withGesture:GEST_SELECTALL];
			break;
			
		case kWPSysShortcutSupport :
		case kWPSysShortcutCom :
		case kWPSysShortcutOrg :
		case kWPSysShortcutNet :
		case kWPSysShortcutWww :
		case kWPSysShortcutFtp :
			// simply insert sc.text 
			result = [delegate ShortcutsRecognizedShortcut:sc withGesture:GEST_NONE];
			break;
			
		case kWPSysShortcutAdd :
			[self newShortcut];
			return YES;
						
		case kWPSysShortcutSave :
			result = [delegate ShortcutsRecognizedShortcut:sc withGesture:GEST_SAVE];
			break;

		case kWPSysShortcutMail :
			result = [delegate ShortcutsRecognizedShortcut:sc withGesture:GEST_SENDMAIL];
			break;

		case kWPSysShortcutSend :
			result = [delegate ShortcutsRecognizedShortcut:sc withGesture:GEST_SENDTODEVICE];
			break;
		case kWPSysShortcutSet :
			result = [delegate ShortcutsRecognizedShortcut:sc withGesture:GEST_OPTIONS];
			break;
            
        default:
            break;
	}
	return result;
}



- (BOOL) recognizeInkData:(INK_DATA_PTR)inkData
{
	if ( NULL == _recognizer )
		return NO;
	const char * pText = HWR_RecognizeInkData( _recognizer, inkData, 0, -1, FALSE, FALSE, FALSE, FALSE );
	if ( pText == NULL || *pText == 0 )
		return NO;
	NSString * strName = [[NSString alloc] initWithCString:pText encoding:RecoStringEncoding];
	// find and execute the command
	Shortcut * sc = [self findByName:strName];
	[strName release];
	if ( nil == sc )
		return NO;
	// ignore the processing result
	[self process:sc];
	return YES;
}

-(unichar) getuchar:(FILE *)file
{
	unichar ch = 0;
	if ( fread( &ch, 1, 2, file ) < 1 )
		ch = 0;
	return ch;
}

-(void) putback:(FILE *)file
{
	fseek( file, -2, SEEK_CUR );
}


-(NSString *)getNextToken:(FILE *)file isEndOfRow:(BOOL *)endofrow isEndOfFile:(BOOL *)endoffile
{
	NSMutableString * strToken = [[NSMutableString alloc] init];
	Boolean bQuotes = NO;
	*endofrow = NO;
	*endoffile = NO;
	unichar ch1, ch = 0;
	while ( (ch = [self getuchar:file]) )
	{
        if ( bQuotes )
        {
            if ( ch == '\r' )
                continue;
            else if ( ch == '\"' )
            {
				ch1 = [self getuchar:file];
                if ( ch1 == '\"' )
				{
                    [strToken appendString:@"\""];
				}
                else
				{
					[self putback:file];
                    bQuotes = NO;
				}
            }
            else
			{
                [strToken appendString:[NSString stringWithCharacters:&ch length:1]];
			}
        }
        else
        {
            if ( ch == '\r' )
			{
                // ignore \r
			}
            else if ( ch == '\n' )
            {
				// end or row
                *endofrow = YES;
                break;
            }
            else if ( ch == '\"' )
                bQuotes = YES;
            else if ( ch == ',' )
                break;		// end of column
            else
                [strToken appendString:[NSString stringWithCharacters:&ch length:1]];
        }
	}
	if ( ch == 0 )
	{
		*endofrow = YES;
		*endoffile = YES;
	}
	return strToken;
}

enum {
	kUserShortcutName = 0, 
	kUserShortcutText,
	kUserShortcutEnabled,
	kUserShortcutOffset,
	kUserShortcutMenu,
	kUserShortcutTotal
};


- (BOOL) loadUserShortcuts
{
	// loads user shortcuts from the file.
	FILE *	file = fopen( [_userFileName UTF8String], "r" );
	if ( NULL == file )
		return NO;
	
	// the file is UNICODE, skip first char
	[self getuchar:file];

	// read data
	BOOL		endofrow = NO;
	BOOL		endoffile = NO;
	NSInteger	column = 0;
	Shortcut *	sc = nil;
	
	[_shortcutsUser removeAllObjects];
	
	NSNumberFormatter * numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];	
	while ( ! endoffile )
	{
		NSString * strToken = [self getNextToken:file isEndOfRow:&endofrow isEndOfFile:&endoffile];
		if ( strToken == nil )
		{
			break;
		}
		if ( [strToken length] > 0 )
		{		
			switch( column )
			{
				case kUserShortcutName :
					if ( sc == nil )
					{
						sc = [[Shortcut alloc] initWithName:strToken shortcut:([_shortcutsUser count] + kWPSysShortcutTotal + 1)];
					}
					else
					{
						sc.name = strToken;
					}
					break;
					
				case kUserShortcutText :
					if ( nil != sc )
						sc.text = strToken;
					break;
					
				case kUserShortcutEnabled :
					if ( nil != sc )
						sc.enabled = ([strToken caseInsensitiveCompare:@"YES"] == NSOrderedSame);
					break;
					
				case kUserShortcutMenu :
					if ( nil != sc )
						sc.addToMenu = ([strToken caseInsensitiveCompare:@"YES"] == NSOrderedSame);
					break;
					
				case kUserShortcutOffset :
					if ( nil != sc )
					{
						NSNumber * num = [numberFormatter numberFromString:strToken];	
						if ( num != nil )
							sc.cursorOffset = [num intValue];
					}
					break;
			}
		}
		
		[strToken release];
		column++;
		if ( endofrow )
		{
			if ( sc != nil && sc.name != nil && [sc.name length] > 0 && sc.text != nil && [sc.text length] > 0 )
			{
				[_shortcutsUser addObject:sc];
			}
			[sc release];
			sc = nil;
			column = 0;
		}
	}
	fclose( file );
	
	// sort array in aphabetical order
	[_shortcutsUser sortUsingFunction:compareShortcuts context:nil];	
	modified = NO;
	return YES;
}

- (NSInteger) countUser
{
	return [_shortcutsUser count];
}

- (NSInteger) countSystem
{
	return [_shortcutsSys count];
}


- (Shortcut *) userShortcutByIndex:(NSInteger)index
{
	if ( index >= 0 && index <  [_shortcutsUser count] )
		return [_shortcutsUser objectAtIndex:index];
	return nil;
}

- (Shortcut *) sysShortcutByIndex:(NSInteger)index
{
	if ( index >= 0 && index <  [_shortcutsSys count] )
		return [_shortcutsSys objectAtIndex:index];
	return nil;
}

- (BOOL) saveUserShortcuts
{
	if ( ! modified )
		return YES;
	// saves user-defined shortcuts as CSV file.
	NSUInteger	mult = 2;
	BOOL		bResult = NO;	

	FILE * file = fopen( [_userFileName UTF8String], "w+" );
	if ( file == nil )
		return NO;
	
	// write header
	NSUInteger  len = 10;
	NSUInteger	memLen = len * 10;
	NSUInteger	actualLen = 0;
	char *		buffer = malloc( memLen );
	if ( buffer == nil )
	{	
		fclose( file );
		return NO;
	}
	
	// write unicode header
	buffer[0] = '\377'; buffer[1] = '\376';
	if ( fwrite( buffer, 1, 2, file ) < actualLen )
		goto Err;
	
	// addnotes
	for ( Shortcut * sc in _shortcutsUser )
	{
		NSString * str = [sc shortcutToCsvString]; 
		len = mult * ([str length]+4);
		if ( len >= memLen )
		{
			memLen = 2 * len;
			buffer = realloc( buffer, memLen );
			if ( nil == buffer )
				goto Err;
		}
		
		actualLen = 0;
		[str getBytes:buffer maxLength:len usedLength:&actualLen encoding:NSUnicodeStringEncoding
				  options:NSStringEncodingConversionAllowLossy range:NSMakeRange( 0, [str length]) remainingRange:nil];
		[str release];
		
		if ( fwrite( buffer, 1, actualLen, file ) < actualLen )
			goto Err;
		
	}
	bResult = YES;
	modified = NO;
	
Err:
	fclose( file );
	free( buffer );
	return bResult;
}

// Releases resouces when no longer needed.
-(void)dealloc
{
	[_shortcutsUser release];
	[_shortcutsSys release];
	[_userFileName release];
	if ( NULL != _recognizer )
	{
		HWR_FreeRecognizer( _recognizer, NULL, NULL, NULL );
		_recognizer = NULL;
	}
    [super dealloc];
}


@end

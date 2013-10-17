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

#import "DictImportContacts.h"
#import "RecognizerManager.h"

@implementation DictImportContacts

@synthesize delegate;

static BOOL isseparator( char ch )
{
	char szSep[] = " !,.:;\"{}[]()+=-?*%#@$~_/<>|\t\r\n";
	if ( ch == 0 )
		return NO;
	return (nil != strchr( szSep, ch ));
}


- (id)init
{
    self = [super init];
    if (self) 
    {
        // Initialization code here.
        _threadLock = [[NSLock alloc] init];
    }
    return self;
}

- (void) dealloc
{
    [_threadLock release];
    [syncProgress release];
    [super dealloc];
}


- (NSInteger) addNewWords:(NSString *)words
{
    NSInteger wordsadded = 0;
    
    register const char * pText = [words cStringUsingEncoding:RecoStringEncoding];
    if ( NULL == pText )
        return 0;
    char		 szWord[HW_MAXWORDLEN] = "";
    
    for ( register int i = 0; pText[i] != 0; )
    {
        Boolean		 allUpper = YES;
        Boolean		 allDigits = YES;
        Boolean		 tooLong = NO;
        char *		 pWord = szWord;
        
        while (  pText[i] && (isspace(  pText[i] ) || isseparator( pText[i] )) )
            i++;
        
        while ( pText[i] && (!isspace(  pText[i] )) && (!isseparator( pText[i] ) ) )
        {
            if ( (! isupper( pText[i] )) && (! isdigit( pText[i])) )
                allUpper = NO;
            if ( ! isdigit( pText[i] ) )
                allDigits = NO;
            *pWord++ = pText[i++];
            // fix for very long words
            if ( (int)(pWord - szWord) >= (HW_MAXWORDLEN-1) )
            {
                tooLong = YES;
                while ( pText[i] && (!isspace(  pText[i] )) && (!isseparator( pText[i] ) ) )
                    i++;
            }
        }
        *pWord = 0;
        UInt32 len = strlen( szWord );
        if ( len > 2 && (! allUpper) && (! allDigits) && (!tooLong) )
        {
            // check the word and add if needed
            if( (!HWR_IsWordInDict( [RecognizerManager sharedManager].recognizer, szWord )) )
            {
                if (HWR_AddUserWordToDict( [RecognizerManager sharedManager].recognizer, szWord, FALSE ) )
                {
                    NSLog( @"new word: %s", szWord );
                    wordsadded++;
                }
            }
        }
    }

    return wordsadded;
}

- (void) updateProgressBar:(NSNumber *)progressstep
{
	if ( nil != progressstep && nil != syncProgress )
    {
        UIProgressView *progbar = (UIProgressView *)[syncProgress viewWithTag:10];
        if ( progbar != nil )
        {
            [progbar setProgress:[progressstep floatValue]];	
        }
    }
}

- (NSInteger) importEventWords
{
	EKEventStore * eventStore = [[EKEventStore alloc] init];
	
	
	CFGregorianDate gregorianStartDate, gregorianEndDate;
	CFGregorianUnits startUnits = {0, 0, -365, 0, 0, 0};
	CFGregorianUnits endUnits = {0, 0, 365, 0, 0, 0};
	CFTimeZoneRef timeZone = CFTimeZoneCopySystem();
	
	gregorianStartDate = CFAbsoluteTimeGetGregorianDate( CFAbsoluteTimeAddGregorianUnits(CFAbsoluteTimeGetCurrent(), timeZone, startUnits),
														timeZone);
	gregorianStartDate.hour = 0;
	gregorianStartDate.minute = 0;
	gregorianStartDate.second = 0;
	
	gregorianEndDate = CFAbsoluteTimeGetGregorianDate( CFAbsoluteTimeAddGregorianUnits(CFAbsoluteTimeGetCurrent(), timeZone, endUnits),
													  timeZone);
	gregorianEndDate.hour = 0;
	gregorianEndDate.minute = 0;
	gregorianEndDate.second = 0;
	
	NSDate* startDate = [NSDate dateWithTimeIntervalSinceReferenceDate:CFGregorianDateGetAbsoluteTime(gregorianStartDate, timeZone)];
	NSDate* endDate = [NSDate dateWithTimeIntervalSinceReferenceDate:CFGregorianDateGetAbsoluteTime(gregorianEndDate, timeZone)];
	
	CFRelease(timeZone);
	
	// Create the predicate. 
	NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil]; // eventStore is an instance variable.
	
	__block NSInteger added = 0;
	__block CGFloat progress = 0.5;
	
	void (^eventEnumerator)(EKEvent *, BOOL *) = 
	^(EKEvent *event, BOOL *stop) 
	{
		*stop = NO;
		if ( event == nil )
			*stop = YES;
	
		NSMutableString * str = [[NSMutableString alloc] init];	

		if ( event.title != nil )
			[str appendFormat:@"%@ ", event.title];
		if ( event.notes != nil )
			[str appendFormat:@"%@ ", event.notes];
		if ( event.location != nil )
			[str appendFormat:@"%@ ", event.location];

		if ( [str length] > 0 )
			added += [self addNewWords:str];
        
		[str release];
		
		if ( progress < 0.95 )
			progress += 0.01;
        [self performSelectorOnMainThread:@selector(updateProgressBar:) 
                               withObject:[NSNumber numberWithFloat:progress] waitUntilDone:YES];
		
	};

    
	[eventStore enumerateEventsMatchingPredicate:predicate usingBlock:eventEnumerator];
	[eventStore release];
	
    if ( added > 0 )
    {
        [[RecognizerManager sharedManager] saveRecognizerDataOfType:USERDATA_DICTIONARY];
    }
    [self performSelectorOnMainThread:@selector(updateProgressBar:) 
                           withObject:[NSNumber numberWithFloat:1.0] waitUntilDone:YES];
	
	return added;
}

- (NSInteger) importContactWords
{
	ABAddressBookRef addressBook = ABAddressBookCreate();
	CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
	CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    NSInteger   added = 0;
    
    CGFloat prtogressstep = 1.0/((CGFloat)nPeople + 2.0)/2.0;
    
    
	for( int i = 0 ; i < nPeople ; i++ )
	{
		ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i );
        NSMutableString * str = [[NSMutableString alloc] init];	
        
        NSString *	name = (NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty); 
        if ( [name length] > 0 )
        {
            [str appendFormat:@"%@ ", name];
        }
        [name release]; 
        name = (NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty ); 
        if ( [name length] > 0 )
        {
            [str appendFormat:@"%@ ", name];
        }
        [name release];
        name = (NSString *)ABRecordCopyValue(person, kABPersonOrganizationProperty ); 
        if ( [name length] > 0 )
        {
            [str appendFormat:@"%@ ", name];
        }
        [name release];
        name = (NSString *)ABRecordCopyValue(person, kABPersonMiddleNameProperty ); 
        if ( [name length] > 0 )
        {
            [str appendFormat:@"%@ ", name];
        }
        [name release];
        name = (NSString *)ABRecordCopyValue(person, kABPersonOrganizationProperty ); 
        if ( [name length] > 0 )
        {
            [str appendFormat:@"%@ ", name];
        }
        [name release];
        name = (NSString *)ABRecordCopyValue(person, kABPersonDepartmentProperty ); 
        if ( [name length] > 0 )
        {
            [str appendFormat:@"%@ ", name];
        }
        [name release];
        name = (NSString *)ABRecordCopyValue(person, kABPersonNicknameProperty ); 
        if ( [name length] > 0 )
        {
            [str appendFormat:@"%@ ", name];
        }
        [name release];

        ABMutableMultiValueRef multi = ABRecordCopyValue(person, kABPersonAddressProperty ); 
        if ( nil != multi )
        {
            for ( CFIndex k=0; k < ABMultiValueGetCount(multi); k++ )
            {
                CFDictionaryRef dict = ABMultiValueCopyValueAtIndex(multi, k);
                name = (NSString *)CFDictionaryGetValue(dict, kABPersonAddressStreetKey);
                if ( [name length] > 0 )
                {
                    [str appendFormat:@"%@ ", name];
                }
                name = (NSString *)CFDictionaryGetValue(dict, kABPersonAddressCityKey);
                if ( [name length] > 0 )
                {
                    [str appendFormat:@"%@ ", name];
                }
                name = (NSString *)CFDictionaryGetValue(dict, kABPersonAddressCountryKey);
                if ( [name length] > 0 )
                {
                    [str appendFormat:@"%@ ", name];
                }
                CFRelease(dict);		
            }
            CFRelease( multi );
        }


        added += [self addNewWords:str];
        [str release];
        
        [self performSelectorOnMainThread:@selector(updateProgressBar:) 
                               withObject:[NSNumber numberWithFloat:(prtogressstep * (i+1))] waitUntilDone:YES];
       
  
        /* TODO; add email addresses to internet dictionary
        ABMutableMultiValueRef multi = ABRecordCopyValue(person, kABPersonEmailProperty ); 
        if ( nil != multi )
        {
            for ( CFIndex i = 0; i < ABMultiValueGetCount(multi); i++ ) 
            { 
                name = (NSString *)ABMultiValueCopyValueAtIndex(multi, i); 
                if ( [name length] > 0 )
                {
                    [str appendFormat:@"%@ ", name];
                }
                [name release];
            } 
            CFRelease( multi ); 
        }
        */

    }
    
    if ( added > 0 )
    {
        [[RecognizerManager sharedManager] saveRecognizerDataOfType:USERDATA_DICTIONARY];
    }
    
    [self performSelectorOnMainThread:@selector(updateProgressBar:) 
                           withObject:[NSNumber numberWithFloat:0.5] waitUntilDone:YES];

    CFRelease( allPeople );    
    CFRelease( addressBook );
    
    return added;
}

- (void)showWaitDialog:(BOOL)show
{
	// show hide sync progress dialog
	if ( show )
	{
		if ( nil == syncProgress )
		{
			syncProgress = [[UIAlertView alloc] 
							initWithTitle:NSLocalizedString( @"Import in Progress", @"" )
							message:NSLocalizedString( @"Importing from Address Book...", @"" )
							delegate:nil 
							cancelButtonTitle:nil
							otherButtonTitles:nil];
			//[syncProgress setNumberOfRows:5];
			syncProgress.tag = 11;
			
			UIProgressView *progbar = [[UIProgressView alloc] initWithFrame:CGRectMake(40.0f, 70.0f, 200.0f, 100.0f)];
			progbar.tag = 10;
			[progbar setProgressViewStyle: UIProgressViewStyleDefault];
			[syncProgress addSubview:progbar];
			[progbar release];
		}
		
		UIProgressView *progbar = (UIProgressView *)[syncProgress viewWithTag:10];
		[progbar setProgress:0.0f];
		[syncProgress show];
	}
	else if ( nil != syncProgress )
	{
		UIProgressView *progbar = (UIProgressView *)[syncProgress viewWithTag:10];
		[progbar setProgress:1.0f];	
		[syncProgress dismissWithClickedButtonIndex:0 animated:YES]; 
	}
}


- (void) setWorking:(Boolean)working
{
	if ( working != _importing )
	{
		_importing = working;
		if ( working )
		{
			[UIApplication sharedApplication].idleTimerDisabled = YES;
			[self showWaitDialog:YES];
			[self retain];
		}
		else
		{
			[UIApplication sharedApplication].idleTimerDisabled = NO;
			[self showWaitDialog:NO];
			[self autorelease];
		}
	}
}

- (Boolean) importContacts
{
    if ( _importing )
        return NO;

    [NSThread detachNewThreadSelector:@selector(importThread:) toTarget:self withObject:nil];
    [self setWorking:YES];
    return YES;
}

- (void) importThreadCompleted:(NSNumber *)added
{
    [self setWorking:NO];
	if ( delegate && [delegate respondsToSelector:@selector(dictImportContactsComplete:newWordsAdded:)] )
	{
		[delegate dictImportContactsComplete:self newWordsAdded:added];
	}
}

- (void) importThread:(id)object
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	[_threadLock lock];

    NSInteger added = 0;
    
    added = [self importContactWords];
    added += [self importEventWords];

    [_threadLock unlock];
    
	[self performSelectorOnMainThread:@selector(importThreadCompleted:) withObject:[NSNumber numberWithInt:added] waitUntilDone:YES];    
    
    [pool release];
}

@end

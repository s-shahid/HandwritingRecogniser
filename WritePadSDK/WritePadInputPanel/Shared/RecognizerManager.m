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

#import "RecognizerManager.h"
#import "OptionKeys.h"

#define INTERNET_CHARS		"?!\"\'.:@&$*-=+/\\"

static RecognizerManager * gManager;

@interface RecognizerManager (Private)

- (void) initRecognizerForCurrentLanguage;
- (void) freeRecognizerForCurrentLanguage;
- (void) releaseSearchRecognizer;
- (RECOGNIZER_PTR) initSearchInstanceForWord:(NSString *)word;

@end


@implementation RecognizerManager

@synthesize recognizer = _recognizer;
@synthesize canRealoadRecognizer = _canRealoadRecognizer;

+ (RecognizerManager *) sharedManager
{
	@synchronized(self) 
	{	
		if ( nil == gManager )
		{
			gManager = [[RecognizerManager alloc] init];
		}
	}
	return gManager;
}

- (id) init
{
	self = [super init];
	if (self != nil) 
	{
		[self initRecognizerForCurrentLanguage];
        _canRealoadRecognizer = YES;
        _searchWord = nil;
        _recognizerSearch = NULL;
	}
	return self;
}

- (void) dealloc
{
    _canRealoadRecognizer = NO;
	[self freeRecognizerForCurrentLanguage];
	[super dealloc];
}

- (BOOL) reloadSettings
{
    @synchronized(self)
    {
        if ( _canRealoadRecognizer && [self isEnabled] )
        {
            [self initRecognizerForCurrentLanguage];
            return YES;
        }
    }
	return NO;
}


- (BOOL) disable:(BOOL)save
{
	if ( ! [self isEnabled] )
		return NO;
	if ( save )
	{
		[self freeRecognizerForCurrentLanguage];
	}
	else
	{
		HWR_FreeRecognizer( _recognizer, NULL, NULL, NULL );
		_recognizer = NULL;
	}
	return [self isEnabled];
}

- (BOOL) enable
{
	if ( ! [self isEnabled] )
	{
		[self initRecognizerForCurrentLanguage];
	}
	return [self isEnabled];
}

#pragma mark -- search handwriting

- (RECOGNIZER_PTR) initSearchInstanceForWord:(NSString *)word
{
    if ( word == nil || [word length] < 1 )
        return NULL;
    
    if ( NULL != _recognizerSearch )
    {
        if ( [_searchWord length] < 1 || [_searchWord caseInsensitiveCompare:word] != NSOrderedSame )
        {
            HWR_FreeRecognizer( _recognizerSearch, NULL, NULL, NULL );     
            _recognizerSearch = NULL;
            [_searchWord release];
            _searchWord = nil;
            
        }
    }
    
    if ( NULL == _recognizerSearch )
    {
        LanguageManager * langManager = [LanguageManager sharedManager];
        
        NSString *	strCorrector = [langManager userFilePathOfType:USERDATA_AUTOCORRECTOR];
        NSString *	strLearner =  [langManager userFilePathOfType:USERDATA_LEARNER];
        
        _recognizerSearch = HWR_InitRecognizer( NULL, NULL, 
                                                       [strLearner UTF8String], [strCorrector UTF8String], 
                                                       [langManager getLanguageID], NULL );
        if ( _recognizerSearch == NULL )
            return NULL;
        NSUserDefaults*	defaults = [NSUserDefaults standardUserDefaults];
        NSData * data = [defaults dataForKey:[NSString stringWithFormat:@"%@_%d", kRecoOptionsLetterShapes, langManager.currentLanguage]];
        if ( [data length] > 0 )
        {
            HWR_SetLetterShapes( _recognizerSearch, [data bytes] );
        }
        else
        {
            HWR_SetDefaultShapes( _recognizerSearch );
        }
        
        BOOL b = [defaults boolForKey:kRecoOptionsFirstStartKey];
        if ( b == YES )
        {
            // set recognizer options
            unsigned int	flags = HWR_GetRecognitionFlags( _recognizerSearch );
            
            flags = FLAG_USERDICT;
            
            if ( [defaults boolForKey:kRecoOptionsDictOnly] )
                flags |= FLAG_ONLYDICT;
            if ( [defaults boolForKey:kRecoOptionsUseLearner] )
                flags |= FLAG_ANALYZER;		
            if ( [defaults boolForKey:kRecoOptionsUseCorrector] )
                flags |= FLAG_CORRECTOR;
            
            HWR_SetRecognitionFlags( _recognizerSearch, flags );
        }				
        
        [_searchWord release];
        _searchWord = [word copy];
        
        const char * pWord = [word cStringUsingEncoding:RecoStringEncoding];
        if ( NULL != pWord )
        {
            HWR_NewUserDict( _recognizerSearch );
            HWR_AddUserWordToDict( _recognizerSearch, pWord, NO );
        }        
        
    }
    return _recognizerSearch;
}

- (void) releaseSearchRecognizer
{
    [_searchWord release];
    _searchWord = nil;
    if ( NULL != _recognizerSearch )
    {
        HWR_FreeRecognizer( _recognizerSearch, NULL, NULL, NULL );     
        _recognizerSearch = NULL;
    }    
}

- (BOOL) findText:(NSString *)text inInk:(INK_DATA_PTR)inkData startFrom:(NSInteger)firstStroke selectedOnly:(BOOL)selected
{
    RECOGNIZER_PTR recognizer = [self initSearchInstanceForWord:text];

    HWR_Reset( recognizer );
    
    const char * pText = HWR_RecognizeInkData( recognizer, inkData, firstStroke, -1, FALSE, FALSE, FALSE, selected );

    INK_SelectAllStrokes( inkData, NO );

    if ( NULL != pText )
    {
        for ( int word = 0; word < HWR_GetResultWordCount( recognizer ); word++ )
        {
            int altCnt = MIN( 4, HWR_GetResultAlternativeCount( recognizer, word ) );
            for ( int alt = 0; alt < altCnt; alt++ )
            {
                const char * pWord = HWR_GetResultWord( recognizer, word, alt );
                if ( pWord != NULL )
                {
                    NSString *	theWord = [NSString stringWithCString:pWord encoding:RecoStringEncoding];
                    if ( theWord != nil && [theWord rangeOfString:text options:NSCaseInsensitiveSearch].location != NSNotFound )
                    {
                        // select strokes that belong to the found word
                        int * ids = NULL;
                        int cnt = HWR_GetStrokeIDs( recognizer, word, alt, (const int **)&ids );
                        for ( int i = 0; i < cnt; i++ )
                        {
                            INK_SelectStroke( inkData, firstStroke+ids[i], TRUE );
                        }
                        return TRUE;
                    }
                }
            }
        }
    }
    return FALSE;
}

- (BOOL) matchWord:(NSString *)text
{
    int cnt = HWR_GetResultWordCount( _recognizer );
    if ( cnt != 1 )
        return NO;
    int altCnt = MIN( 5, HWR_GetResultAlternativeCount( _recognizer, 0 ) );
    for ( int alt = 0; alt < altCnt; alt++ )
    {
        const char * pWord = HWR_GetResultWord( _recognizer, 0, alt );
        if ( pWord != NULL )
        {
            NSString *	theWord = [NSString stringWithCString:pWord encoding:RecoStringEncoding];
            if ( theWord != nil && [theWord caseInsensitiveCompare:text] == NSOrderedSame )
                return YES;
        }
    }
    return NO;
}

- (int) getWordCount
{
    int cnt = HWR_GetResultWordCount( _recognizer );
    return cnt;
}

#pragma mark -- Recognizer 

- (void) initRecognizerForCurrentLanguage
{
    NSUserDefaults*	defaults = [NSUserDefaults standardUserDefaults];
    LanguageManager * langManager = [LanguageManager sharedManager];
    [langManager changeCurrentLanguage:[defaults integerForKey:kGeneralOptionsCurrentLanguage]];	
    
    NSString *	strUserFile =  [langManager userFilePathOfType:USERDATA_DICTIONARY];
    NSString *	strCorrector = [langManager userFilePathOfType:USERDATA_AUTOCORRECTOR];
    NSString *	strLearner =  [langManager userFilePathOfType:USERDATA_LEARNER];
    NSString *	strMainDict = [langManager mainDictionaryPath];

	if ( _recognizer == NULL )
    {
        
        _recognizer = HWR_InitRecognizer( [strMainDict UTF8String], [strUserFile UTF8String], 
                                                       [strLearner UTF8String], [strCorrector UTF8String], 
                                                       [langManager getLanguageID], NULL );
    }
    else
    {
        HWR_ReloadLearner( _recognizer, [strLearner UTF8String] );
        HWR_ReloadUserDict(_recognizer, [strUserFile UTF8String] );
        HWR_ReloadAutoCorrector( _recognizer, [strCorrector UTF8String] );
    }
	if ( NULL == _recognizer )
		return;
	NSData * data = [defaults dataForKey:[NSString stringWithFormat:@"%@_%d", kRecoOptionsLetterShapes, langManager.currentLanguage]];
	if ( [data length] > 0 )
	{
		HWR_SetLetterShapes( _recognizer, [data bytes] );
	}
	else
	{
		HWR_SetDefaultShapes( _recognizer );
	}
	
	BOOL b = [defaults boolForKey:kRecoOptionsFirstStartKey];
	if ( b == YES )
	{
		// set recognizer options
		unsigned int	flags = HWR_GetRecognitionFlags( _recognizer );
		
		if ( [defaults boolForKey:kRecoOptionsSingleWordOnly] )
			flags |= FLAG_SINGLEWORDONLY;
		else 
			flags &= ~FLAG_SINGLEWORDONLY;
		if ( [defaults boolForKey:kRecoOptionsSeparateLetters] )
			flags |= FLAG_SEPLET;
		else 
			flags &= ~FLAG_SEPLET;
		if ( [defaults boolForKey:kRecoOptionsInternational] )
			flags |= FLAG_INTERNATIONAL;
		else 
			flags &= ~FLAG_INTERNATIONAL;
		if ( [defaults boolForKey:kRecoOptionsDictOnly] )
			flags |= FLAG_ONLYDICT;
		else 
			flags &= ~FLAG_ONLYDICT;
		if ( [defaults boolForKey:kRecoOptionsSuggestDictOnly] )
			flags |= FLAG_SUGGESTONLYDICT;
		else 
			flags &= ~FLAG_SUGGESTONLYDICT;
		if ( [defaults boolForKey:kRecoOptionsUseUserDict] )
			flags |= FLAG_USERDICT;
		else 
			flags &= ~FLAG_USERDICT;
		if ( [defaults boolForKey:kRecoOptionsUseLearner] )
			flags |= FLAG_ANALYZER;
		else 
			flags &= ~FLAG_ANALYZER;
		
		if ( [defaults boolForKey:kRecoOptionsUseCorrector] )
			flags |= FLAG_CORRECTOR;
		else 
			flags &= ~FLAG_CORRECTOR;
		
		if ( ! [defaults boolForKey:kRecoOptionsSpellIgnoreNum] )
			flags |= FLAG_SPELLIGNORENUM;
		else 
			flags &= ~FLAG_SPELLIGNORENUM;
		
		if ( ! [defaults boolForKey:kRecoOptionsSpellIgnoreUpper] )
			flags |= FLAG_SPELLIGNOREUPPER;
		else 
			flags &= ~FLAG_SPELLIGNOREUPPER;
		
		HWR_SetRecognitionFlags( _recognizer, flags );
	}				
}

- (void) freeRecognizerForCurrentLanguage
{
	if ( _recognizer )
	{
		LanguageManager * langManager = [LanguageManager sharedManager];
		NSString *	strUserFile =  [langManager userFilePathOfType:USERDATA_DICTIONARY];
		NSString *	strCorrector =  [langManager userFilePathOfType:USERDATA_AUTOCORRECTOR];
		NSString *	strLearner =  [langManager userFilePathOfType:USERDATA_LEARNER];
		
		HWR_FreeRecognizer( _recognizer, [strUserFile UTF8String], [strLearner UTF8String], [strCorrector UTF8String] );
		_recognizer = NULL;
	}
    [self releaseSearchRecognizer];
}


- (void) saveRecognizerDataOfType:(NSInteger)type
{
	LanguageManager * langManager = [LanguageManager sharedManager];
	if ( 0 != (type & USERDATA_AUTOCORRECTOR) )
	{
		NSString *	strCorrector =  [langManager userFilePathOfType:USERDATA_AUTOCORRECTOR];
		HWR_SaveWordList( _recognizer, [strCorrector UTF8String] );	
	}
	if ( 0 != (type & USERDATA_LEARNER) )
	{
		NSString *	strLearner =  [langManager userFilePathOfType:USERDATA_LEARNER];
		HWR_SaveLearner( _recognizer, [strLearner UTF8String] );	
	}
	if ( 0 != (type & USERDATA_DICTIONARY) || type == 0 )
	{
		NSString *	strUserFile =  [langManager userFilePathOfType:USERDATA_DICTIONARY];
		HWR_SaveUserDict( _recognizer, [strUserFile UTF8String] );	
	}
}

- (void) resetRecognizerDataOfType:(NSInteger)type
{
	LanguageManager * langManager = [LanguageManager sharedManager];
	if ( 0 != (type & USERDATA_AUTOCORRECTOR) )
	{
		NSString *	strCorrector =  [langManager userFilePathOfType:USERDATA_AUTOCORRECTOR];
		HWR_ResetAutoCorrector( _recognizer, [strCorrector UTF8String] );
	}
	if ( 0 != (type & USERDATA_LEARNER) )
	{
		NSString *	strLearner =  [langManager userFilePathOfType:USERDATA_LEARNER];
		HWR_ResetLearner( _recognizer, [strLearner UTF8String] );
	}
	if ( 0 != (type & USERDATA_DICTIONARY) || type == 0 )
	{
		NSString *	strUserFile =  [langManager userFilePathOfType:USERDATA_DICTIONARY];
		HWR_ResetUserDict( _recognizer, [strUserFile UTF8String] );	
	}
}

- (void) reloadRecognizerDataOfType:(NSInteger)type
{
	LanguageManager * langManager = [LanguageManager sharedManager];
	if ( 0 != (type & USERDATA_AUTOCORRECTOR) )
	{
		NSString *	strCorrector =  [langManager userFilePathOfType:USERDATA_AUTOCORRECTOR];
		HWR_ReloadAutoCorrector( _recognizer, [strCorrector UTF8String] );
	}
	if ( 0 != (type & USERDATA_LEARNER) )
	{
		NSString *	strLearner =  [langManager userFilePathOfType:USERDATA_LEARNER];
		HWR_ReloadLearner( _recognizer, [strLearner UTF8String] );
	}
	if ( 0 != (type & USERDATA_DICTIONARY) || type == 0 )
	{
		NSString *	strUserFile =  [langManager userFilePathOfType:USERDATA_DICTIONARY];
		HWR_ReloadUserDict( _recognizer, [strUserFile UTF8String] );	
	}
}

- (void) reset
{
	if ( _recognizer )
		HWR_Reset( _recognizer );
}

- (void) setMode:(int)mode
{
	if ( NULL == _recognizer )
		return;
	if ( mode == RECMODE_WWW )
		HWR_SetCustomCharset( _recognizer, NULL, INTERNET_CHARS );
	else
		HWR_SetCustomCharset( _recognizer, NULL, NULL );				
	HWR_SetRecognitionMode( _recognizer, mode );
}

- (int) getMode
{
	return HWR_GetRecognitionMode( _recognizer );
}

- (BOOL) isEnabled
{
	return (_recognizer != NULL);
}

- (void) modifyRecoFlags:(NSUInteger)addFlags deleteFlags:(NSUInteger)delFlags
{
	if ( NULL != _recognizer )
	{
		unsigned int	flags = HWR_GetRecognitionFlags( _recognizer );
		if ( 0 != delFlags )
			flags &= ~delFlags;
		if ( 0 != addFlags )
			flags |= addFlags;
		HWR_SetRecognitionFlags( _recognizer, flags );
	}	
}

- (const char *) recognizeInkData:(INK_DATA_PTR)inkData background:(BOOL)backgroundReco async:(BOOL)asyncReco selection:(BOOL)selection
{
	const char * pText = NULL;
	if ( ! [self isEnabled] )
		return NULL;
	
    
	@synchronized(self)
	{
        _canRealoadRecognizer = NO;
		if ( ! backgroundReco )
		{
			pText = HWR_RecognizeInkData( _recognizer, inkData, 0, -1, asyncReco, FALSE, FALSE, selection );
		}
		else
		{
			if ( HWR_Recognize( _recognizer ) )
				pText = HWR_GetResult( _recognizer );
		}
        _canRealoadRecognizer = YES;
	}		
	if ( pText == NULL || *pText == 0 )
		return NULL;
	return pText;
}

- (BOOL) isWordInDictionary:(const char *)chrWord
{
	// add here
	if ( HWR_IsWordInDict( _recognizer, chrWord ) )
		return YES;	
	if ( [[LanguageManager sharedManager] spellCheckerEnabled] )
	{
		NSString *	theText = [NSString stringWithCString:chrWord encoding:RecoStringEncoding];
		NSRange		currentRange = [[LanguageManager sharedManager] badWordRange:theText];
		return (currentRange.location == NSNotFound);
	}
	return NO;
}

- (void) enableCalculator:(BOOL)bEnable
{
	HWR_EnablePhatCalc( _recognizer, bEnable );
}

- (void) addWordToUserDict:(NSString *)strWord
{
	// add word to the user dictionary
	if ( nil != _recognizer )
	{
		const char * pWord = [strWord cStringUsingEncoding:RecoStringEncoding];
		if ( NULL != pWord )
		{
			HWR_AddUserWordToDict( _recognizer, pWord, YES );
			[self saveRecognizerDataOfType:USERDATA_DICTIONARY];
		}
	}
}


@end

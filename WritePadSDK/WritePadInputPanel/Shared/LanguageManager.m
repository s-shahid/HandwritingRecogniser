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

#import "LanguageManager.h"
#import "OptionKeys.h"

static LanguageManager *	gManager;


@interface LanguageManager (Private)


@end


@implementation LanguageManager

@synthesize currentLanguage;
@synthesize sharedUserData;

+ (LanguageManager *) sharedManager
{
	@synchronized(self) 
	{	
		if ( nil == gManager )
		{
			gManager = [[LanguageManager alloc] init];
		}
	}
	return gManager;
}

- (id) init
{
	self = [super init];
	if (self != nil) 
	{
		textChecker = nil;
		currentLanguage = WPLanguageEnglishUS;
		NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
		NSArray *	languages = [defaults objectForKey:@"AppleLanguages"];
		NSString *	cLanguage = [languages objectAtIndex:0];
		// NSLog( @"%@;\n%@", cLanguage, languages );
				
		if ( [defaults integerForKey:kGeneralOptionsCurrentLanguage] != WPLanguageUnknown )
		{
			currentLanguage = [defaults integerForKey:kGeneralOptionsCurrentLanguage];
		}
		else
		{
			if ( [cLanguage caseInsensitiveCompare:@"de"] == NSOrderedSame )		
                currentLanguage = WPLanguageGerman;
            else if ( [cLanguage caseInsensitiveCompare:@"fr"] == NSOrderedSame )		
                currentLanguage = WPLanguageFrench;
			else if ( [cLanguage caseInsensitiveCompare:@"es"] == NSOrderedSame )		
                currentLanguage = WPLanguageSpanish;
			else if ( [cLanguage caseInsensitiveCompare:@"it"] == NSOrderedSame )		
                currentLanguage = WPLanguageItalian;
			else if ( [cLanguage caseInsensitiveCompare:@"pt-PT"] == NSOrderedSame )		
				currentLanguage = WPLanguagePortuguese;
			else if ( [cLanguage caseInsensitiveCompare:@"pt"] == NSOrderedSame )	
				currentLanguage = WPLanguageBrazilian;
			else if ( [cLanguage caseInsensitiveCompare:@"nl"] == NSOrderedSame )	
                currentLanguage = WPLanguageDutch;
			else if ( [cLanguage caseInsensitiveCompare:@"en-GB"] == NSOrderedSame )		
				currentLanguage = WPLanguageEnglishUK;
			else if ( [cLanguage caseInsensitiveCompare:@"sv"] == NSOrderedSame )		
				currentLanguage = WPLanguageSwedish;
			else if ( [cLanguage caseInsensitiveCompare:@"da"] == NSOrderedSame )		
				currentLanguage = WPLanguageDanish;
			else if ( [cLanguage caseInsensitiveCompare:@"fi"] == NSOrderedSame )		
				currentLanguage = WPLanguageFinnish;
			else if ( [cLanguage caseInsensitiveCompare:@"nb"] == NSOrderedSame )		
				currentLanguage = WPLanguageNorwegian;
			else
				currentLanguage = WPLanguageEnglishUS;			
            
            if ( ! HWR_IsLanguageSupported( [self getLanguageID] ) )
            {
                currentLanguage = WPLanguageEnglishUS;
            }
            
			[defaults setInteger:currentLanguage forKey:kGeneralOptionsCurrentLanguage];
		}
				
		sharedUserData = [[WritePadPersistentData alloc] initWithLanguageManager:self]; // @"R5748AJT76.com.PhatWare.WritePadSuite"];
		NSString * theLanguage = [self languageCode];
		Boolean bFound = NO;
		for( NSString * str in [UITextChecker availableLanguages] )
		{
			if ( [str compare:theLanguage] == NSOrderedSame )
				bFound = YES;
			NSLog( @"Language %@", str );
		}
		if ( bFound )
			textChecker = [[UITextChecker alloc] init];
	}
	return self;
}

- (void) dealloc
{
	[textChecker release];
	[sharedUserData release];
	[super dealloc];
}

#pragma mark -- Spell Checker support

- (NSRange) badWordRange:(NSString *)str
{
	NSRange		stringRange = NSMakeRange( 0, [str length] );
	return [textChecker rangeOfMisspelledWordInString:str range:stringRange
															startingAt:0 wrap:NO language:[self languageCode]];
}

- (BOOL) spellCheckerEnabled
{
	return (nil != textChecker);
}

- (NSArray *)supportedLanguages
{
    int * languages = NULL;
    int count = HWR_GetSupportedLanguages( &languages );
    NSMutableArray * array  = [NSMutableArray arrayWithCapacity:count];
    for ( int i = 0; i < count; i++ )
    {
        [array addObject:[NSNumber numberWithInt:languages[i]]];
    }
    return [NSArray arrayWithArray:array];
}

- (void) changeCurrentLanguageID:(int)languageID
{
    WPLanguage language = WPLanguageEnglishUS;
    
    switch( languageID )
    {
		case LANGUAGE_GERMAN :
			language = WPLanguageGerman;
			break;
			
		case  LANGUAGE_FRENCH:
			language = WPLanguageFrench;
			break;
			
		case LANGUAGE_SPANISH :
			language = WPLanguageSpanish;
			break;
			
		case LANGUAGE_PORTUGUESE :
			language = WPLanguagePortuguese;
			break;
			
		case LANGUAGE_PORTUGUESEB :
			language = WPLanguageBrazilian;
			break;
			
		case LANGUAGE_DUTCH  :
			language = WPLanguageDutch;
			break;
			
		case LANGUAGE_ITALIAN  :
			language = WPLanguageItalian;
			break;
			
		case LANGUAGE_FINNISH :
			language = WPLanguageFinnish;
			break;
			
		case LANGUAGE_SWEDISH :
			language = WPLanguageSwedish;
			break;
			
		case LANGUAGE_NORWEGIAN  :
			language = WPLanguageNorwegian;
			break;
			
		case LANGUAGE_DANISH  :
			language = WPLanguageDanish;
			break;
            
        default :
            break;
    }
    [self changeCurrentLanguage:language];    
}

- (void) changeCurrentLanguage:(WPLanguage)language
{
	if ( language == currentLanguage )
		return;
	if ( nil != sharedUserData )
	{
		[sharedUserData updatePersistentData];
		[sharedUserData autorelease];
	}
	[textChecker release];
	textChecker = nil;
	currentLanguage = language;
	[[NSUserDefaults standardUserDefaults] setInteger:currentLanguage forKey:kGeneralOptionsCurrentLanguage];
	sharedUserData = [[WritePadPersistentData alloc] initWithLanguageManager:self]; 
	
	NSString * theLanguage = [self languageCode];
	Boolean bFound = NO;
	for( NSString * str in [UITextChecker availableLanguages] )
	{
		if ( [str compare:theLanguage] == NSOrderedSame )
			bFound = YES;
		NSLog( @"Language %@", str );
	}
	if ( bFound )
		textChecker = [[UITextChecker alloc] init];
}

- (NSArray *) spellCheckWord:(NSString *)strWord complete:(Boolean)complete
{
    NSArray *	guesses = nil;
	if ( textChecker != nil )
	{
		NSString *	theLanguage = [self languageCode];
		NSString *	theText = strWord;
		NSRange		stringRange = NSMakeRange(0, theText.length);
		
		if ( complete )
		{
			guesses = [textChecker completionsForPartialWordRange:stringRange inString:theText language:theLanguage];
		}
		else
		{
			NSRange currentRange = [textChecker rangeOfMisspelledWordInString:theText range:stringRange
																   startingAt:0 wrap:NO language:theLanguage];
			if ( currentRange.location != NSNotFound ) 
			{
				guesses = [textChecker guessesForWordRange:currentRange inString:theText language:theLanguage];
			}
		}
	}
	return guesses;
}

- (NSString *) mainDictionaryPath
{
	NSString * theLanguage = @"English";
	switch ( currentLanguage )
	{
		case WPLanguageGerman :
			theLanguage = @"German";
			break;
			
		case WPLanguageFrench :
			theLanguage = @"French";
			break;
			
		case WPLanguageSpanish :
			theLanguage = @"Spanish";
			break;
			
		case WPLanguagePortuguese :
			theLanguage = @"Portuguese";
			break;
			
		case WPLanguageBrazilian :
			theLanguage = @"Brazilian";
			break;
			
		case WPLanguageDutch :
			theLanguage = @"Dutch";
			break;
			
		case WPLanguageItalian :
			theLanguage = @"Italian";
			break;
			
		case WPLanguageFinnish :
			theLanguage = @"Finnish";
			break;
			
		case WPLanguageSwedish :
			theLanguage = @"Swedish";
			break;
			
		case WPLanguageNorwegian :
			theLanguage = @"Norwegian";
			break;
			
		case WPLanguageDanish :
			theLanguage = @"Danish";
			break;
			
		case WPLanguageMedicalUS :
		case WPLanguageMedicalUK :
			theLanguage = @"MedicalUS";
			break;
			
		case WPLanguageEnglishUK :
			theLanguage = @"EnglishUK";
			break;
        default :
            break;
	}
	return [[[NSString alloc] initWithString:[[NSBundle mainBundle] pathForResource:theLanguage ofType:@"dct"]] autorelease];
}

- (NSString *) languageName
{
	NSString * theLanguage = @"English";
	switch ( currentLanguage )
	{
		case WPLanguageGerman :
			theLanguage = @"Deutsch";
			break;
			
		case WPLanguageFrench :
			theLanguage = @"Français";
			break;
			
		case WPLanguageSpanish :
			theLanguage = @"Español";
			break;
			
        case WPLanguageBrazilian :
		case WPLanguagePortuguese :
			theLanguage = @"Português";
			break;

		case WPLanguageDutch :
			theLanguage = @"Nederlands";
			break;
			
		case WPLanguageItalian :
			theLanguage = @"Italiano";
			break;
			
		case WPLanguageFinnish :
			theLanguage = @"Suomi";
			break;
			
		case WPLanguageSwedish :
			theLanguage = @"Svenska";
			break;
			
		case WPLanguageNorwegian :
			theLanguage = @"Norsk";
			break;
			
		case WPLanguageDanish :
			theLanguage = @"Dansk";
			break;
        default :
            break;
	}
	return [[[NSString alloc] initWithString:theLanguage] autorelease];
}

- (UIImage *) languageImage
{
	UIImage * theImage = nil;
	switch ( currentLanguage )
	{
		case WPLanguageGerman :
			theImage = [UIImage imageNamed:@"flag_germany.png"];
			break;
			
		case WPLanguageFrench :
			theImage = [UIImage imageNamed:@"flag_france.png"];
			break;
			
		case WPLanguageSpanish :
			theImage = [UIImage imageNamed:@"flag_spain.png"];
			break;
			
		case WPLanguagePortuguese :
			theImage = [UIImage imageNamed:@"flag_portugal.png"];
			break;
			
		case WPLanguageBrazilian :
			theImage = [UIImage imageNamed:@"flag_brazil.png"];
			break;
			
		case WPLanguageDutch :
			theImage = [UIImage imageNamed:@"flag_netherlands.png"];
			break;
			
		case WPLanguageItalian :
			theImage = [UIImage imageNamed:@"flag_italy.png"];
			break;
			
		case WPLanguageFinnish :
			theImage = [UIImage imageNamed:@"flag_finland.png"];
			break;
			
		case WPLanguageSwedish :
			theImage = [UIImage imageNamed:@"flag_sweden.png"];
			break;
			
		case WPLanguageNorwegian :
			theImage = [UIImage imageNamed:@"flag_norway.png"];
			break;
			
		case WPLanguageDanish :
			theImage = [UIImage imageNamed:@"flag_denmark.png"];
			break;
			
		case WPLanguageEnglishUS  :
			theImage = [UIImage imageNamed:@"flag_usa.png"];
			break;

		case WPLanguageMedicalUS :
			theImage = [UIImage imageNamed:@"first_aid.png"];
			break;
			
		case WPLanguageEnglishUK :
			theImage = [UIImage imageNamed:@"flag_uk.png"];
			break;

        default :
            break;
	}
	return [[theImage retain] autorelease];
}

- (NSString *) languageCode
{
	NSString *	theLanguage = @"en_US";
	switch ( currentLanguage )
	{
		case WPLanguageGerman :
			theLanguage = @"de_DE";
			break;
			
		case WPLanguageFrench :
			theLanguage = @"fr_FR";
			break;
			
		case WPLanguageSpanish :
			theLanguage = @"es_ES";
			break;
			
		case WPLanguagePortuguese :
			theLanguage = @"pt_PT";
			break;
			
		case WPLanguageBrazilian :
			theLanguage = @"pt_BR";
			break;
			
		case WPLanguageDutch :
			theLanguage = @"nl_NL";
			break;
			
		case WPLanguageItalian :
			theLanguage = @"it_IT";
			break;
			
		case WPLanguageMedicalUK :
		case WPLanguageEnglishUK :
			theLanguage = @"en_GB";
			break;
			
		case WPLanguageFinnish :
			theLanguage = @"fi_FI";
			break;
			
		case WPLanguageSwedish :
			theLanguage = @"sv_SE";
			break;
			
		case WPLanguageNorwegian :
			theLanguage = @"nb_NO";
			break;
			
		case WPLanguageDanish :
			theLanguage = @"da_DK";
			break;
			
		case WPLanguageMedicalUS :
		case WPLanguageEnglishUS :
		default:
			theLanguage = @"en_US";
			break;
	}
	return theLanguage;
}

- (NSString *) sharedDataName
{
	NSString *	name = @"com.PhunkWare.WritePad";
	switch ( currentLanguage )
	{
		case WPLanguageGerman :
			name = @"com.PhunkWare.WritePadGR";
			break;
			
		case WPLanguageFrench :
			name = @"com.PhunkWare.WritePadFR";
			break;
			
		case WPLanguageSpanish :
			name = @"com.PhunkWare.WritePadSP";
			break;
			
		case WPLanguagePortuguese :
			name = @"com.PhunkWare.WritePadPT";
			break;
			
		case WPLanguageBrazilian :
			name = @"com.PhunkWare.WritePadBR";
			break;
			
		case WPLanguageDutch :
			name = @"com.PhunkWare.WritePadDT";
			break;
			
		case WPLanguageItalian :
			name = @"com.PhunkWare.WritePadIT";
			break;
			
		case WPLanguageFinnish :
			name = @"com.PhunkWare.WritePadFI";
			break;
			
		case WPLanguageSwedish :
			name = @"com.PhunkWare.WritePadSV";
			break;
			
		case WPLanguageNorwegian :
			name = @"com.PhunkWare.WritePadNW";
			break;
			
		case WPLanguageDanish :
			name = @"com.PhunkWare.WritePadDN";
			break;
			
		case WPLanguageMedicalUK :
		case WPLanguageEnglishUK :
			name = @"com.PhunkWare.WritePadUK";
			break;

		case WPLanguageMedicalUS :
		case WPLanguageEnglishUS :
		default:
			name = @"com.PhunkWare.WritePad";
			break;
	}
	return name;
}

- (NSString *) infoPasteboardName
{
	NSString *	name = @"com.PhunkWare.iOS.WritePad.English";
	switch ( currentLanguage )
	{
		case WPLanguageGerman :
			name = @"com.PhunkWare.iOS.WritePad.German";;
			break;
			
		case WPLanguageFrench :
			name = @"com.PhunkWare.iOS.WritePad.French";
			break;
			
		case WPLanguageSpanish :
			name = @"com.PhunkWare.iOS.WritePad.Spanish";
			break;
			
		case WPLanguagePortuguese :
			name = @"com.PhunkWare.iOS.WritePad.Portuguese";
			break;
			
		case WPLanguageBrazilian :
			name = @"com.PhunkWare.iOS.WritePad.Brazilian";
			break;
			
		case WPLanguageDutch :
			name = @"com.PhunkWare.iOS.WritePad.Dutch";
			break;
			
		case WPLanguageItalian :
			name = @"com.PhunkWare.iOS.WritePad.Italian";
			break;
						
		case WPLanguageFinnish :
			name = @"com.PhunkWare.iOS.WritePad.Finnish";
			break;
			
		case WPLanguageSwedish :
			name = @"com.PhunkWare.iOS.WritePad.Swedish";
			break;
			
		case WPLanguageNorwegian :
			name = @"com.PhunkWare.iOS.WritePad.Norwegian";
			break;
			
		case WPLanguageDanish :
			name = @"com.PhunkWare.iOS.WritePad.Danish";
			break;
			
		case WPLanguageMedicalUK :
		case WPLanguageEnglishUK :
			name = @"com.PhunkWare.iOS.WritePad.EnglishUK";
			break;

		case WPLanguageMedicalUS :
		case WPLanguageEnglishUS :
		default:
			name = @"com.PhunkWare.iOS.WritePad.English";
			break;
	}
	return name;
}

- (NSInteger) getLanguageID
{
	NSInteger language = LANGUAGE_ENGLISH;
	switch ( currentLanguage )
	{
		case WPLanguageGerman :
			language = LANGUAGE_GERMAN;
			break;
			
		case WPLanguageFrench :
			language = LANGUAGE_FRENCH;
			break;
			
		case WPLanguageSpanish :
			language = LANGUAGE_SPANISH;
			break;
			
		case WPLanguagePortuguese :
			language = LANGUAGE_PORTUGUESE;
			break;
			
		case WPLanguageBrazilian :
			language = LANGUAGE_PORTUGUESEB;
			break;
			
		case WPLanguageDutch :
			language = LANGUAGE_DUTCH;
			break;
			
		case WPLanguageItalian :
			language = LANGUAGE_ITALIAN;
			break;
			
		case WPLanguageFinnish :
			language = LANGUAGE_FINNISH;
			break;
			
		case WPLanguageSwedish :
			language = LANGUAGE_SWEDISH;
			break;
			
		case WPLanguageNorwegian :
			language = LANGUAGE_NORWEGIAN;
			break;
			
		case WPLanguageDanish :
			language = LANGUAGE_DANISH;
			break;
            
        default :
            break;
	}
	return language;
}

- (NSString *) userFilePathOfType:(NSInteger)type
{
	NSArray *	paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *	name = nil;
	switch ( currentLanguage )
	{
		case WPLanguageGerman :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_CorrGER.cwl"];
			else if ( type == USERDATA_LEARNER )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_StatGER.lrn"];
			else
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_UserGER.dct"];
			break;
			
		case WPLanguageFrench :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_CorrFRN.cwl"];
			else if ( type == USERDATA_LEARNER )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_StatFRN.lrn"];
			else
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_UserFRN.dct"];
			break;
			
		case WPLanguageSpanish :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_CorrSPN.cwl"];
			else if ( type == USERDATA_LEARNER )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_StatSPN.lrn"];
			else
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_UserSPN.dct"];
			break;
			
		case WPLanguagePortuguese :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_CorrPRT.cwl"];
			else if ( type == USERDATA_LEARNER )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_StatPRT.lrn"];
			else
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_UserPRT.dct"];
			break;
			
		case WPLanguageBrazilian :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_CorrBRZ.cwl"];
			else if ( type == USERDATA_LEARNER )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_StatBRZ.lrn"];
			else
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_UserBRZ.dct"];
			break;
			
		case WPLanguageDutch :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_CorrDUT.cwl"];
			else if ( type == USERDATA_LEARNER )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_StatDUT.lrn"];
			else
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_UserDUT.dct"];
			break;
			
		case WPLanguageItalian :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_CorrITL.cwl"];
			else if ( type == USERDATA_LEARNER )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_StatITL.lrn"];
			else
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_UserITL.dct"];
			break;
			
		case WPLanguageFinnish :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_CorrFIN.cwl"];
			else if ( type == USERDATA_LEARNER )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_StatFIN.lrn"];
			else
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_UserFIN.dct"];
			break;
			
		case WPLanguageSwedish :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_CorrSWD.cwl"];
			else if ( type == USERDATA_LEARNER )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_StatSWD.lrn"];
			else
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_UserSWD.dct"];
			break;
			
		case WPLanguageNorwegian :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_CorrNRW.cwl"];
			else if ( type == USERDATA_LEARNER )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_StatNRW.lrn"];
			else
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_UserNRW.dct"];
			break;
			
		case WPLanguageDanish :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_CorrDAN.cwl"];
			else if ( type == USERDATA_LEARNER )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_StatDAN.lrn"];
			else
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_UserDAN.dct"];
			break;
			
		case WPLanguageMedicalUK :
		case WPLanguageEnglishUK :
			if ( type == USERDATA_AUTOCORRECTOR )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_CorrUK.cwl"];
			else if ( type == USERDATA_LEARNER )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_StatUK.lrn"];
			else
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_UserUK.dct"];
			break;			
			
		case WPLanguageMedicalUS :
		case WPLanguageEnglishUS :
		default:
			if ( type == USERDATA_AUTOCORRECTOR )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_Corr.cwl"];
			else if ( type == USERDATA_LEARNER )
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_Stat.lrn"];
			else
				name = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"WritePad_User.dct"];
			break;
	}
	return [[name retain] autorelease];
}

@end




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

#import "AsyncResultView.h"
#import "RecognizerWrapper.h"
#import "WritePadInputPanel.h"
#import "ResultAlternatives.h"
#import "UIConst.h"
#import "LanguageManager.h"
#import "RecognizerManager.h"

#define MAX_SUGGESTION_COUNT	20

@implementation AsyncResultView

@synthesize inputPanel;
@synthesize text;
@synthesize words;
@synthesize suggestions;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) 
	{
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
		self.contentMode = UIViewContentModeRedraw;
		text = nil;
		font = [UIFont fontWithName:@"Verdana" size:30];
		fontError = [UIFont fontWithName:@"Verdana-Italic" size:30];
		selectedWord = -1;
		resultError = NO;
    }
    return self;
}

- (void) empty
{
	self.text = nil;
	self.words = nil;
}

- (void) setText:(NSString *)newText
{
	if ( self.suggestions != nil )
		[self.suggestions hidePopover:YES];
	[text release];
	text = [newText retain];
	if ( newText != nil )
		resultError = ([newText rangeOfString:kEmptyWord].location == NSNotFound) ? NO : YES;
	else
		resultError = NO;
	self.words = nil;
	selectedWord = -1;
	[self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect 
{
	CGRect	bounds = [self bounds];
	CGRect	rText = bounds;
    // Drawing code

	CGContextRef	context = UIGraphicsGetCurrentContext();
	// CGContextSetRGBFillColor( context, 1.0, 1.0, 1.0, 0.9 );	
	// CGContextFillRect( context, bounds );
	
	
	if ( resultError )
	{
		NSString * word = NSLocalizedString( @"Input Error", @"" );
		[[UIColor redColor] set];
		CGSize size = [word sizeWithFont:fontError];
		rText.size.width = size.width;
		[word drawInRect:rText withFont:fontError];
		return;
	}
	
	[[UIColor blackColor] set];
	if ( words && [words count] > 0 )
	{
		for ( NSInteger wordIndex = 0; wordIndex < [words count]; wordIndex++ )
		{
			NSArray *	_words = [words objectAtIndex:wordIndex];
			if ( [_words count] > 0 )
			{
				NSString *	word = [[_words objectAtIndex:0] objectForKey:@"word"];
				if ( word != nil )
				{
					CGSize size = [word sizeWithFont:font];
					rText.size.width = size.width;
					if ( rText.size.width + rText.origin.x > bounds.size.width )
						break;
								
					if ( wordIndex == selectedWord )
					{
						CGContextSaveGState(context);
						CGContextSetRGBFillColor( context, 0.0, 0.2, 0.9, 0.4 );
						CGContextFillRect( context, rText );
						[[UIColor whiteColor] set];
						[word drawInRect:rText withFont:font];
						CGContextRestoreGState(context);
					}
					else
					{
						[word drawInRect:rText withFont:font];
					}
					[word drawInRect:rText withFont:font];
					rText.origin.x += (rText.size.width + [@" " sizeWithFont:font].width);
				}
			}
		}
	}
	else if ( text != nil && [text length] > 0 )
	{
		[text drawInRect:rect withFont:font];
	}		
}

- (void)dealloc
{
	[suggestions release];
	[words release];
	[text release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - generate recognizer word array

- (BOOL) isWordInArray:(NSString *)word array:(NSArray *)aWords
{
	for ( int i = 0; i < [aWords count]; i++ )
	{	
		if ( NSOrderedSame == [word compare:(NSString *)[[aWords objectAtIndex:i] objectForKey:@"word"]] )
			return YES;
	}
	return NO;
}

// we only need to do it if user taps on the word
- (NSInteger) generateWordArray
{
	RECOGNIZER_PTR _reco = [RecognizerManager sharedManager].recognizer;
	NSInteger _wordCnt = HWR_GetResultWordCount( _reco );
	if ( _wordCnt < 1 )
		return 0;

	NSString *		word = nil;
	const char *	chrWord = NULL;
	USHORT weight = 0;
	unsigned int	recoFlags = HWR_GetRecognitionFlags( _reco );
	
	[words release];
	words = [[NSMutableArray alloc] init];

	for ( int iWord = 0; iWord < _wordCnt; iWord++ )
	{
		NSMutableArray * _words = [[NSMutableArray alloc] init];
		int nAltCnt = HWR_GetResultAlternativeCount( _reco, iWord );
		
		for ( int j = 0; j < nAltCnt; j++ )
		{
			chrWord = HWR_GetResultWord( _reco, iWord, j );
			if ( NULL != chrWord && 0 != *chrWord )
			{
				if ( j > 0 && 0 != (recoFlags & FLAG_SUGGESTONLYDICT) )
				{
					if ( ! HWR_IsWordInDict( _reco, chrWord ) )
					{
						continue;
					}
				}
				
				[word release];
				word = [[NSString alloc] initWithCString:chrWord encoding: RecoStringEncoding];
				// word = [NSString stringWithUTF8String:chrWord];
				weight = HWR_GetResultWeight( _reco, iWord, j );
				int nstroke = HWR_GetResultStrokesNumber( _reco, iWord, j );
				NSLog( @"word=%d alt=%d **** strokes=%d ****", iWord, j, nstroke );
				if ( j == 0 || (! [self isWordInArray:word array:_words]) )
				{
					[_words addObject:[NSDictionary dictionaryWithObjectsAndKeys:word, @"word", [NSNumber numberWithUnsignedShort:weight], @"weight", nil]];
				}
				if ( j == 0 )
				{
					// add flip-case word to the array, if any
					const char * chrFlipWord = HWR_WordFlipCase( _reco, chrWord );
					if ( NULL != chrFlipWord && 0 != *chrFlipWord )
					{
						[word release];
						word = [[NSString alloc] initWithCString:chrFlipWord encoding: RecoStringEncoding];
						if ( ! [self isWordInArray:word array:_words] )
						{
							[_words addObject:[NSDictionary dictionaryWithObjectsAndKeys:word, @"word", [NSNumber numberWithUnsignedShort:weight], @"weight", nil]];
						}
					}						
				}
			}
		}
		if ( [_words count] < MAX_SUGGESTION_COUNT && 0 != (recoFlags & (FLAG_MAINDICT | FLAG_USERDICT)) )
		{
			// add spell checker results...
			chrWord = HWR_GetResultWord( _reco, iWord, 0 );
			if ( NULL != chrWord && 0 != *chrWord )
			{
				char  *	pWordList = malloc( MAX_STRING_BUFFER );
				if ( HWR_SpellCheckWord( _reco, chrWord, pWordList, MAX_STRING_BUFFER-1, 0 ) == 0 )
				{
					for ( register int j = 0; 0 != pWordList[j] && j < MAX_STRING_BUFFER; j++ )
					{
						if ( pWordList[j] == PM_ALTSEP )
							pWordList[j] = 0;
					}
					for ( register int k = 0; k < MAX_STRING_BUFFER; k++ )
					{
						[word release];
						word = [[NSString alloc] initWithCString:&pWordList[k] encoding: RecoStringEncoding];						
						//word = [NSString stringWithUTF8String:&pWordList[k]];
						
						//  make sure the word is not already in array, if not add to the words array
						if ( k > 0 && ! [self isWordInArray:word array:_words] )
						{
							[_words addObject:[NSDictionary dictionaryWithObjectsAndKeys:word, @"word", [NSNumber numberWithUnsignedShort:0], @"weight", nil]];
						}
						while ( 0 != pWordList[k] )
							k++;
						if ( 0 == pWordList[k+1] )
							break;
					}
				}
				free( pWordList );
			}
		}
		[words addObject:_words];
		[_words release];
	}
	[word release];
	return [words count];
}

- (int) learnNewWords
{
	int result = 0;
	if ( words == nil )
	{
		result = [self generateWordArray];
	}
	else 
	{
		result = [words count];
	}
	if ( result > 0 )
	{
		result = 0;
		for ( NSArray * _words in words )
		{
			const UCHR * pWord = [[[_words objectAtIndex:0] objectForKey:@"word"] cStringUsingEncoding:RecoStringEncoding];
			if ( NULL != pWord )
			{
				USHORT weight = [[[_words objectAtIndex:0] objectForKey:@"weight"] unsignedShortValue];
				if ( HWR_LearnNewWord( [RecognizerManager sharedManager].recognizer, pWord, weight ) )
				{
					result++;
				}
			}
		}
	}	
	return result;
}


- (void) resultAlternativesDidDismiss:(ResultAlternatives *)view
{
	self.suggestions = nil;
	selectedWord = -1;
	[self setNeedsDisplay];
}

- (void) resultAlternatives:(ResultAlternatives *)view wordSelected:(NSString *)strWord wordIndex:(NSInteger)index
{
	if ( index > 0 ) 
	{
		NSDictionary *	wI = [[view.aWords objectAtIndex:index] retain];

		// learn this replacement
		NSDictionary *	w0 = [view.aWords objectAtIndex:0];
		if ( NSOrderedSame != [[w0 objectForKey:@"word"] caseInsensitiveCompare:[wI objectForKey:@"word"]] )
		{
			// must get weight for words...			
			const UCHR *	word1 =  [[w0 objectForKey:@"word"] cStringUsingEncoding:RecoStringEncoding];
			const UCHR *	word2 =  [[wI objectForKey:@"word"] cStringUsingEncoding:RecoStringEncoding];
			USHORT	w1 = [[w0 objectForKey:@"weight"] unsignedShortValue];
			USHORT	w2 = [[wI objectForKey:@"weight"] unsignedShortValue];
			HWR_ReplaceWord( [RecognizerManager sharedManager].recognizer, word1, w1, word2, w2 );
			[[RecognizerManager sharedManager] saveRecognizerDataOfType:USERDATA_LEARNER];
		}
			
		[view.aWords removeObjectAtIndex:index];
		[view.aWords insertObject:wI atIndex:0];
			
		NSMutableString * sText = [[NSMutableString alloc] init];
		for ( NSArray *	_words in words )
		{
			if ( [_words count] > 0 )
			{
				NSString *	word = [[_words objectAtIndex:0] objectForKey:@"word"];
				if ( word != nil )
				{
					[sText appendString:word];
					[sText appendString:@" "];
				}
			}
		}
		[text release];
		text = [[NSString alloc] initWithString:sText];
		[sText release];
		[wI release];
		[self setNeedsDisplay];
	}	
}

- (void) resultAlternatives:(ResultAlternatives *)view learnWord:(NSString *)strWord weight:(UInt16)weight
{
	// add word to the dictionary
	const char * pText = [strWord cStringUsingEncoding:RecoStringEncoding];
	HWR_LearnNewWord( [RecognizerManager sharedManager].recognizer, pText, weight );
	HWR_AddUserWordToDict( [RecognizerManager sharedManager].recognizer, pText, YES );
	
	// save the dictionary & learner
	[[RecognizerManager sharedManager] saveRecognizerDataOfType:(USERDATA_DICTIONARY+USERDATA_LEARNER)];
}

- (BOOL) isWordInDictionary:(NSString *)strWord
{
	RECOGNIZER_PTR _reco = [RecognizerManager sharedManager].recognizer;
	register const char * pText = [strWord cStringUsingEncoding:RecoStringEncoding];
	if ( HWR_IsWordInDict( _reco, pText ) )
		return YES;	
	return NO;
}

- (void) repositionPopover
{
	if ( nil != self.suggestions )
	{
		CGRect	rText = _rCurrWord;

		// need to work around the Input View bug
		rText.origin.x += self.frame.origin.x;
		rText.origin.y += self.frame.origin.y;
		rText.origin.x += inputPanel.frame.origin.x;
		rText.origin.y += inputPanel.frame.origin.y;
		
		if ( inputPanel.delegate && [inputPanel.delegate respondsToSelector:@selector(writePadInputPanelPositionAltPopover:)])
		{
			UIView * inView = [inputPanel.delegate writePadInputPanelPositionAltPopover:&rText];
			[self.suggestions repositionPopover:rText inView:inView];
		}		
		else
		{
			[self.suggestions repositionPopover:rText inView:self];
		}
	}
}

#pragma mark - Touches Handles

- (NSInteger) processTouch:(CGPoint)location showPopover:(BOOL)showPopover
{
	CGRect	bounds = [self bounds];
	CGRect	rText = bounds;
	
	selectedWord = -1;
	if ( nil == words )
	{
		if ( [self generateWordArray] < 1 )
			return selectedWord;
	}

	for ( NSInteger wordIndex = 0; wordIndex < [words count]; wordIndex++ )
	{
		NSMutableArray *	_words = [words objectAtIndex:wordIndex];
		if ( [_words count] > 0 )
		{
			NSString *	word = [[_words objectAtIndex:0] objectForKey:@"word"];
			if ( word != nil )
			{
				CGSize size = [word sizeWithFont:font];
				rText.size.width = size.width;
				if ( rText.size.width + rText.origin.x > bounds.size.width )
					break;
				if ( CGRectContainsPoint( rText, location ) )
				{
					selectedWord = wordIndex;
					
					if ( showPopover )
					{
						ResultAlternatives * aSuggestions = [[ResultAlternatives alloc] initWithStyle:UITableViewStylePlain];
						self.suggestions = aSuggestions;
						aSuggestions.delegate = self;
						aSuggestions.aWords = _words;
						aSuggestions.addWord = (! [self isWordInDictionary:word]);
						
						_rCurrWord = rText;
						
						// BUG: need to work around the Input View bug
						rText.origin.x += self.frame.origin.x;
						rText.origin.y += self.frame.origin.y;
						rText.origin.x += inputPanel.frame.origin.x;
						rText.origin.y += inputPanel.frame.origin.y;
						
						
						if ( inputPanel.delegate && [inputPanel.delegate respondsToSelector:@selector(writePadInputPanelPositionAltPopover:)])
						{
							UIView * inView = [inputPanel.delegate writePadInputPanelPositionAltPopover:&rText];
							[aSuggestions showPopover:rText inView:inView];
						}		
						else
						{
							// iOS BUG: This works only in portrait mode, the popover reappears sideways or upside-down when screen 
							// is rotates. The writePadInputPanelPositionAltPopover delegate method should be use to recalculate the 
							// popover position relative to the current inView. This bug is still not fixed as of iOS 4.2 Beta 1. I have 
							// reported this back in May 2010.
							[aSuggestions showPopover:rText inView:inputPanel];
						}
						[aSuggestions release];						
					}
					return selectedWord;
				}
				rText.origin.x += (rText.size.width + [@" " sizeWithFont:font].width);
			}
		}
	}
	return selectedWord;
}

// Handles the start of a touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch*	touch = [[event touchesForView:self] anyObject];
	CGPoint		location = [touch locationInView:self];
	
	if ( self.suggestions != nil )
	{
		[self.suggestions hidePopover:YES];
		return;
	}
	if ( resultError || nil == self.text )
		return;

	if ( [self processTouch:location showPopover:YES] >= 0 )
	{
		NSLog( @"Selected word %d", selectedWord );

		// redraw
		[self setNeedsDisplay];
	}
}

// Handles the continuation of a touch. 
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{  
	//UITouch*	touch = [[event touchesForView:self] anyObject];
	//CGPoint		location = [touch locationInView:self];
}

// Handles the end of a touch event when the touch is a tap.
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{	
	//UITouch*	touch = [[event touchesForView:self] anyObject];
	//CGPoint		location = [touch locationInView:self];	
}

// Handles the end of a touch event.
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
}


@end

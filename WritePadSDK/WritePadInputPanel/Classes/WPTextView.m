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

#import "WPTextView.h"
#import "UIConst.h"
#import "AsyncResultView.h"

@implementation WPTextView

@synthesize useKeyboard;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) 
	{
		useKeyboard = NO;
        [self setInputMethod];
    }
    return self;
}

- (void) setInputMethod
{
    WritePadInputView * wpInputView = [WritePadInputView sharedInputPanel];
    if ( useKeyboard && [self.inputView isEqual:wpInputView] )
	{
		self.inputView = nil;
	}
    else if ( (!useKeyboard) && (! [self.inputView isEqual:wpInputView]) )
	{
        self.inputView = wpInputView;
    }	
}

- (BOOL) becomeFirstResponder
{
    [[WritePadInputView sharedInputPanel].inkCollector shortcutsEnable:(![[NSUserDefaults standardUserDefaults]
                                                                          boolForKey:kRecoOptionsDisableShortcuts])
                                                              delegate:self uiDelegate:self.delegate];
	[WritePadInputView sharedInputPanel].delegate = self;
	return [super becomeFirstResponder];
}

- (BOOL) ShortcutsRecognizedShortcut:(Shortcut*)sc withGesture:(GESTURE_TYPE)gesture
{
	NSLog( @"ShortcutsRecognizedShortcut:%@ withGesture:0x%08X", sc.name, gesture );
	if ( gesture == GEST_NONE )
	{
		[self appendEditorString:sc.text];
		if ( sc.cursorOffset < 0 && (int)self.selectedRange.location + sc.cursorOffset >= 0 )
		{
            NSRange range = self.selectedRange;
            range.length = 0;
			range.location += sc.cursorOffset;
			self.selectedRange = range;
		}
		return TRUE;
	}
	return [self WritePadInputPanelRecognizedGesture:[WritePadInputView sharedInputPanel].inkCollector withGesture:gesture isEmpty:YES];
}

- (NSString *) ShortcutGetSelectedText:(Shortcut *)sc withGesture:(GESTURE_TYPE)gesture
{
    UITextRange * tr = self.selectedTextRange;
    sc.text = @"";
    if ( tr != nil )
    {
        NSString * str = [self textInRange:tr];
        if ( str != nil )
            sc.text = str;
    }
	return sc.text;
}


- (BOOL) resignFirstResponder
{
	return [super resignFirstResponder];
}

- (void) appendEditorString:(NSString *)string
{
    // When the accessory view button is tapped, add a suitable string to the text view.
    NSMutableString *text = [self.text mutableCopy];
    NSRange selectedRange = self.selectedRange;
	CGPoint offset = self.contentOffset;
	self.scrollEnabled = NO;
	if ( selectedRange.location > [text length] )
	{
		selectedRange.location = [text length];
		selectedRange.length = 0;
	}
    [text replaceCharactersInRange:selectedRange withString:string];
	[self setText:text];
	selectedRange.length = 0;
	selectedRange.location += [string length];
	selectedRange.location = MIN( [text length], selectedRange.location );
	self.selectedRange = selectedRange;
	[self setContentOffset:offset animated:NO];
	self.scrollEnabled = YES;
    [text release];	
	[[WritePadInputView sharedInputPanel] empty];
}

- (void) baskspaceEditor
{
	NSRange selectedRange = self.selectedRange;
	if ( selectedRange.location == NSNotFound )
		return;
	NSMutableString *text = [self.text mutableCopy];
	CGPoint offset = self.contentOffset;
	self.scrollEnabled = NO;
	if ( selectedRange.length > 0 )
	{
		[text deleteCharactersInRange:selectedRange];
	}
	else if ( selectedRange.location > 0 )
	{
		selectedRange.location--;
		selectedRange.length = 1;
		[text deleteCharactersInRange:selectedRange];					
	}
	else if ( selectedRange.location == 0 && [text length] > 0 )
	{
		selectedRange.length = 1;
		[text deleteCharactersInRange:selectedRange];					
	}
	selectedRange.length = 0;
	self.text = text;
	self.selectedRange = selectedRange;
	[self setContentOffset:offset animated:NO];
	self.scrollEnabled = YES;
	[text release];	
}


- (void) WritePadInputPanelResultReady:(WritePadInputPanel*)inkView theResult:(NSString*)string
{
	[self appendEditorString:string];
}

- (UIView *) writePadInputPanelPositionAltPopover:(CGRect *)pRect
{
	CGRect rText = *pRect;
	CGRect rScreen = [[UIScreen mainScreen] bounds];
	UIView * view = ((UIViewController *)self.delegate).view;
	CGRect svr = view.superview.frame;
	rText.origin.y += svr.size.height;
	rText.origin.y += svr.origin.y;	// Toolbar height...	

	NSInteger width = UIInterfaceOrientationIsLandscape( ((UIViewController *)self.delegate).interfaceOrientation ) ? rScreen.size.height : rScreen.size.width;	
	rText.origin.x -= (width - svr.size.width)/2;
	
	*pRect = rText;	
	return (UIView *)view.superview;
}

- (void) writePadInputKeyPressed:(WritePadInputView*)inView keyText:(NSString*)string withSender:(id)sender
{
	if ( [string compare:@"\n"] == NSOrderedSame )
	{
		if ( inView.resultView.text != nil )
		{
			[inView.resultView learnNewWords]; 
			[self appendEditorString:inView.resultView.text];
			return;
		}
	}
	else if ( [string compare:@"\b"] == NSOrderedSame )
	{
		if ( [inView.inkCollector strokeCount] > 0 )
		{
			[inView.inkCollector deleteLastStroke];
		}
		else if ( self.text != nil )
		{
			[self baskspaceEditor];
			[[WritePadInputView sharedInputPanel] empty];
		}
		return;
	}
	else if ( [string compare:@" "] == NSOrderedSame )
	{
		if ( [inView.inkCollector strokeCount] > 0 )
		{
			[[WritePadInputView sharedInputPanel] empty];
			return;
		}
	}
	[self appendEditorString:string];
}

- (BOOL) WritePadInputPanelRecognizedGesture:(WritePadInputPanel*)inkView withGesture:(GESTURE_TYPE)gesture isEmpty:(BOOL)bEmpty
{
	switch( gesture )
	{
		case GEST_RETURN :
			if ( bEmpty )
			{
				[self appendEditorString:@"\n"];
			}
			else if ( inkView.inputPanel.resultView.text != nil )
			{
				[self appendEditorString:inkView.inputPanel.resultView.text];
			}
			return NO;
			
		case GEST_SPACE :
			if ( bEmpty )
			{
				[self appendEditorString:@" "];
				return NO;
			}
			break;
			
		case GEST_TAB :
			if ( bEmpty )
			{	
				[self appendEditorString:@"\t"];
				return NO;
			}
			break;
			
		case GEST_UNDO :
			if ( bEmpty )
			{
				//if ( [self.undoManager canUndo] )
                {
                    [self.undoManager undo];
                    return NO;
                }
			}
			break;
			
		case GEST_REDO :
			if ( bEmpty )
			{
				//if ( [self.undoManager canRedo] )
                {
                    [self.undoManager redo];
                    return NO;
                }
			}
			break;
			
		case GEST_CUT :
			if ( ! bEmpty )
			{
				[[WritePadInputView sharedInputPanel] empty];
				return NO;
			}
			if ( [self canPerformAction:@selector(cut:) withSender:nil] )
				[self cut:nil];
			return NO;
			
		case GEST_COPY :
			if ( bEmpty )
			{
				if ( [self canPerformAction:@selector(copy:) withSender:nil] )
					[self copy:nil];
				return NO;
			}
			break;
			
		case GEST_PASTE :
			if ( bEmpty )
			{
				if ( [self canPerformAction:@selector(paste:) withSender:nil] )
					[self paste:nil];
				return NO;
			}
			break;
			
		case GEST_DELETE :
			break;
			
		case GEST_MENU :
			break;
			
		case GEST_SPELL :
			break;
			
		case GEST_CORRECT :
			break;
			
		case GEST_SELECTALL :
			if ( bEmpty )
			{
				if ( [self canPerformAction:@selector(selectAll:) withSender:nil] )
					[self selectAll:nil];
				return NO;
			}
			break;
			
		case GEST_SCROLLDN :
			break;
			
		case GEST_SCROLLUP :
			break;
			
		case GEST_BACK :
		case GEST_BACK_LONG :
			if ( GEST_BACK_LONG == gesture && (!bEmpty) )
			{
				[inkView deleteLastStroke];
				return NO;
			}
			else if ( bEmpty )
			{
				[self baskspaceEditor];
				return NO;
			}
			break;
			
		case GEST_LOOP :
			break;
			
		case GEST_SENDMAIL :
			break;
			
		case GEST_OPTIONS :
			break;
			
		case GEST_SENDTODEVICE :
			break;
			
		case GEST_SAVE :
			break;
			
		default :
		case GEST_NONE :
			break;
	}
	return YES;		// add stroke...	
}

- (void)dealloc 
{
	self.inputView = nil;
    [super dealloc];
}

@end

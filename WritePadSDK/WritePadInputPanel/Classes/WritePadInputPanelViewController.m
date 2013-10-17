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

#import "WritePadInputPanelViewController.h"
#import "UIConst.h"
#import "EditOptionsViewController.h"
#import "RecognizerManager.h"

@implementation WritePadInputPanelViewController

@synthesize textView;

#pragma mark --- Create Text View

- (void) create_WPTextView:(CGRect)frame
{
	textView = [[WPTextView alloc] initWithFrame:frame];

	textView.useKeyboard = NO;
    
    textView.opaque = NO;
    textView.font = [UIFont fontWithName:@"Arial" size:kUIShortcutFontSize];
    textView.backgroundColor = [UIColor clearColor];
	textView.returnKeyType = UIReturnKeyDefault;
	textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	textView.delegate = self;
	textView.keyboardType = UIKeyboardTypeDefault;	// use the default type input method (entire keyboard)
    [self.view addSubview:textView];
	
}

#pragma mark --- View Controller functions

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];

    // Observe keyboard hide and show notifications to resize the text view appropriately.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

	CGRect f = [self.view bounds];
    [self create_WPTextView:f];
	textView.text = @"";
    
    int language = WPLanguageUnknown;
    for ( int i = WPLanguageEnglishUS; i < WPLanguageMedicalUS; i++ )
    {
        if ( [WritePadStoreManager isLanguagePackPurchased:i] )
            language = i;
    }
    if ( language == WPLanguageUnknown )
    {
        // prompt user to specify the default language
        [self performSelector:@selector(selectDefaultLanguage:) withObject:nil afterDelay:0.8];
    }    
}


- (void)viewWillAppear:(BOOL)animated 
{    
    // Make the keyboard appear when the application launches.
    [super viewWillAppear:animated];
    [textView becomeFirstResponder];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView 
{
    return YES;
}


- (BOOL)textViewShouldEndEditing:(UITextView *)aTextView 
{
    [aTextView resignFirstResponder];
    return YES;
}

#pragma mark --- Handling keyboard events

- (void)keyboardWillShow:(NSNotification *)notification 
{
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
	
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect newTextViewFrame = self.view.bounds;
    newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y;
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
	newTextViewFrame.origin.y  += 44;
    textView.frame = newTextViewFrame;
	
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification 
{    
    NSDictionary* userInfo = [notification userInfo];
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];

    CGRect f = self.view.bounds;
	f.origin.y  += 44;
    textView.frame = f;
   
    [UIView commitAnimations];
}

#pragma mark --- Options and language selector

-(IBAction) onOptions:(id)sender
{	
	// show default options dialog
	EditOptionsViewController *viewController = [[EditOptionsViewController alloc] init];
	viewController.showDone = YES;
	// Create the navigation controller and present it modally. 
	UINavigationController *navigationController = [[UINavigationController alloc] 
													initWithRootViewController:viewController]; 
	navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentModalViewController:navigationController animated:YES]; 
	// The navigation controller is now owned by the current view controller 
	// and the root view controller is owned by the navigation controller, 
	// so both objects should be released to prevent over-retention. 
	[navigationController release]; 
	[viewController release];			
}

- (void) selectDefaultLanguage:(NSObject *)param
{
    LanguageViewController *viewController = [[LanguageViewController alloc] initWithStyle:UITableViewStyleGrouped];
    NSArray * langs = [[LanguageManager sharedManager] supportedLanguages];
    NSMutableArray * languages = [NSMutableArray arrayWithCapacity:[langs count]];
    NSInteger index = 0;
    viewController.selectedIndex = index;
   
    NSDictionary * language;
    for ( NSNumber * l in langs )
    {
        switch ( [l intValue] )
        {
            case LANGUAGE_ENGLISH :
                language = [NSDictionary dictionaryWithObjectsAndKeys:@"English (United States)", @"name",
                            [NSNumber numberWithInt:WPLanguageEnglishUS], @"ID", @"flag_usa.png", @"image", nil]; 
                [languages addObject:language];
                if ( [LanguageManager sharedManager].currentLanguage == WPLanguageEnglishUS )
                    viewController.selectedIndex = index;
                index++;
                language = [NSDictionary dictionaryWithObjectsAndKeys:@"English (Great Britain)", @"name",
                            [NSNumber numberWithInt:WPLanguageEnglishUK], @"ID", @"flag_uk.png", @"image", nil]; 
                [languages addObject:language];
                if ( [LanguageManager sharedManager].currentLanguage == WPLanguageEnglishUK )
                    viewController.selectedIndex = index;
                index++;
                break;
                
            case LANGUAGE_PORTUGUESE :
                language = [NSDictionary dictionaryWithObjectsAndKeys:@"Português (Portugal)", @"name",
                            [NSNumber numberWithInt:WPLanguagePortuguese], @"ID", @"flag_portugal.png", @"image", nil]; 
                [languages addObject:language];
                if ( [LanguageManager sharedManager].currentLanguage == WPLanguagePortuguese )
                    viewController.selectedIndex = index;
                index++;                        
                break;
                
            case LANGUAGE_PORTUGUESEB :
                language = [NSDictionary dictionaryWithObjectsAndKeys:@"Português (Brasil)", @"name",
                            [NSNumber numberWithInt:WPLanguageBrazilian], @"ID", @"flag_brazil.png", @"image", nil]; 
                [languages addObject:language];
                if ( [LanguageManager sharedManager].currentLanguage == WPLanguageBrazilian )
                    viewController.selectedIndex = index;
                index++;                        
                break;
                
            case LANGUAGE_GERMAN :
                language = [NSDictionary dictionaryWithObjectsAndKeys:@"Deutsch", @"name",
                            [NSNumber numberWithInt:WPLanguageGerman], @"ID", @"flag_germany.png", @"image", nil]; 
                [languages addObject:language];
                if ( [LanguageManager sharedManager].currentLanguage == WPLanguageGerman )
                    viewController.selectedIndex = index;
                index++;                        
                break;
                
            case LANGUAGE_FRENCH :
                language = [NSDictionary dictionaryWithObjectsAndKeys:@"Français", @"name",
                            [NSNumber numberWithInt:WPLanguageFrench], @"ID", @"flag_france.png", @"image", nil]; 
                [languages addObject:language];
                if ( [LanguageManager sharedManager].currentLanguage == WPLanguageFrench )
                    viewController.selectedIndex = index;
                index++;                        
                break;
                
            case LANGUAGE_ITALIAN :
                language = [NSDictionary dictionaryWithObjectsAndKeys:@"Italiano", @"name",
                            [NSNumber numberWithInt:WPLanguageItalian], @"ID", @"flag_italy.png", @"image", nil]; 
                [languages addObject:language];
                if ( [LanguageManager sharedManager].currentLanguage == WPLanguageItalian )
                    viewController.selectedIndex = index;
                index++;                        
                break;
                
            case LANGUAGE_DUTCH :
                language = [NSDictionary dictionaryWithObjectsAndKeys:@"Nederlands", @"name",
                            [NSNumber numberWithInt:WPLanguageDutch], @"ID", @"flag_netherlands.png", @"image", nil]; 
                [languages addObject:language];
                if ( [LanguageManager sharedManager].currentLanguage == WPLanguageDutch )
                    viewController.selectedIndex = index;
                index++;                        
                break;
                
            case LANGUAGE_SPANISH :
                language = [NSDictionary dictionaryWithObjectsAndKeys:@"Español", @"name",
                            [NSNumber numberWithInt:WPLanguageSpanish], @"ID", @"flag_spain.png", @"image", nil]; 
                [languages addObject:language];
                if ( [LanguageManager sharedManager].currentLanguage == WPLanguageSpanish )
                    viewController.selectedIndex = index;
                index++;                        
                break;
                
                
            case LANGUAGE_SWEDISH :
                language = [NSDictionary dictionaryWithObjectsAndKeys:@"Svenska", @"name",
                            [NSNumber numberWithInt:WPLanguageSwedish], @"ID", @"flag_sweden.png", @"image", nil]; 
                [languages addObject:language];
                if ( [LanguageManager sharedManager].currentLanguage == WPLanguageSwedish )
                    viewController.selectedIndex = index;
                index++;                        
                break;
                
            case LANGUAGE_FINNISH :
                language = [NSDictionary dictionaryWithObjectsAndKeys:@"Suomi", @"name",
                            [NSNumber numberWithInt:WPLanguageFinnish], @"ID", @"flag_finland.png", @"image", nil]; 
                [languages addObject:language];
                if ( [LanguageManager sharedManager].currentLanguage == WPLanguageFinnish )
                    viewController.selectedIndex = index;
                index++;                        
                break;
                
            case LANGUAGE_NORWEGIAN :
                language = [NSDictionary dictionaryWithObjectsAndKeys:@"Norsk", @"name",
                            [NSNumber numberWithInt:WPLanguageNorwegian], @"ID", @"flag_norway.png", @"image", nil]; 
                [languages addObject:language];
                if ( [LanguageManager sharedManager].currentLanguage == WPLanguageNorwegian )
                    viewController.selectedIndex = index;
                index++;                        
                break;
                
            case LANGUAGE_DANISH :
                language = [NSDictionary dictionaryWithObjectsAndKeys:@"Dansk", @"name",
                            [NSNumber numberWithInt:WPLanguageDanish], @"ID", @"flag_denmark.png", @"image", nil]; 
                [languages addObject:language];
                if ( [LanguageManager sharedManager].currentLanguage == WPLanguageDanish )
                    viewController.selectedIndex = index;
                index++;                        
                break;
        }
        
    }
    viewController.languages = [NSArray arrayWithArray:languages];
    viewController.delegate = self;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController]; 
    navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentModalViewController:navigationController animated:YES];
	[navigationController release];
    [viewController release];							
}

- (void) languageSelected:(LanguageViewController *)viewController language:(int)language
{
    [WritePadStoreManager setLanguagePackPurchased:language];
    int mode = [[RecognizerManager sharedManager] getMode];
    [[RecognizerManager sharedManager] disable:YES];
    [[NSUserDefaults standardUserDefaults] setInteger:language forKey:kGeneralOptionsCurrentLanguage];
    [[RecognizerManager sharedManager] enable];
    [[RecognizerManager sharedManager] setMode:mode];
}


#pragma mark --

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
	
	// TODO: Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
}

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [textView removeFromSuperview];
    [textView release];
    [super dealloc];
}

@end

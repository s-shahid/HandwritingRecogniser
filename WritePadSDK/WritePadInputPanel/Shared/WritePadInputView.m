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

#import "WritePadInputView.h"
#import "WritePadInputPanel.h"
#import "AsyncResultView.h"
#import "UIConst.h"
#import "RecognizerManager.h"

#define X_OFFSET			10
#define Y_OFFSET			10
#define TOP_OFFSET			68
#define RESULT_HEIGHT		48
#define X_LINE_OFFSET		40
#define BUTTON_SIZE			50
#define BUTTON_GAP			8
#define BUTTON_COUNT		4
#define RIGHT_OFFSET(n)		(Y_OFFSET + (BUTTON_SIZE + BUTTON_GAP) * (n))
#define TOP_LINE_OFFSET2	(TOP_OFFSET + 70)
#define TOP_LINE_OFFSET1	(TOP_OFFSET + 135)

#define LETTER_WIDTH		45.0
#define BAR_HEIGHT			5.0

#define kInitialKeyTimeout	0.6
#define kKeyTimeout			0.1

#define kInputPanelMarkerPosition   @"InputPanelMarkerPosition"
#define kInputPanelWriteHere        @"InputPanelWriteHere"



@interface WritePadInputView(PrivateFunctions)

- (UIButton *)buttonWithTitle:(NSString *)title
					   target:(id)target
					 selector:(SEL)selector
						frame:(CGRect)frame
				darkTextColor:(BOOL)darkTextColor;
- (CGSize)createKeyBtn:(NSString *)strImage withTitle:(NSString *)title atPosition:(CGPoint)position;
- (UIButton *) createCommandButton:(NSString *)command atPosition:(CGPoint)position;

@end


static WritePadInputView * sharedInputPanel = nil;


@implementation UIResultsView 

- (void)drawRect:(CGRect)rect
{
    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetLineWidth( context, 1.0 );	
	
	// As a bonus, we'll combine arcs to create a round rectangle!
    
	// 2. draw the input panel
	
	// Drawing with a dark stroke color
	CGContextSetRGBStrokeColor(context, 0.1, 0.1, 0.1, 1.0);
	CGContextSetRGBFillColor(context, 239.0/255.0, 228.0/225.0, 110.0/225.0, 1.0);

    // 3. draw the input panel
    // Drawing with a white stroke color
    CGContextSetRGBStrokeColor(context, 0.3, 0.3, 0.3, 1.0);
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);

    CGRect      rrect = rect;
    CGFloat     radius = 8.0;
    
    rrect.origin.x += X_OFFSET;
    rrect.size.width -= (X_OFFSET + 1.0);
    rrect.origin.y = Y_OFFSET;
    rrect.size.height = RESULT_HEIGHT;
    // NOTE: At this point you may want to verify that your radius is no more than half
    // the width and height of your rectangle, as this technique degenerates for those cases.

    // In order to draw a rounded rectangle, we will take advantage of the fact that
    // CGContextAddArcToPoint will draw straight lines past the start and end of the arc
    // in order to create the path from the current position and the destination position.

    // In order to create the 4 arcs correctly, we need to know the min, mid and max positions
    // on the x and y lengths of the given rectangle.
	CGFloat minx = ceilf( CGRectGetMinX(rrect) ), midx = ceilf( CGRectGetMidX(rrect) ), maxx = ceilf( CGRectGetMaxX(rrect) );
	CGFloat miny = ceilf( CGRectGetMinY(rrect) ), midy = ceilf( CGRectGetMidY(rrect) ), maxy = ceilf( CGRectGetMaxY(rrect) );

    // Next, we will go around the rectangle in the order given by the figure below.
    //       minx    midx    maxx
    // miny    2       3       4
    // midy   1 9              5
    // maxy    8       7       6
    // Which gives us a coincident start and end point, which is incidental to this technique, but still doesn't
    // form a closed path, so we still need to close the path to connect the ends correctly.
    // Thus we start by moving to point 1, then adding arcs through each pair of points that follows.
    // You could use a similar tecgnique to create any shape with rounded corners.

    // Start at 1
    CGContextMoveToPoint(context, minx, midy);
    // Add an arc through 2 to 3
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    // Add an arc through 4 to 5
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    // Add an arc through 6 to 7
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    // Add an arc through 8 to 9
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    // Close the path
    CGContextClosePath(context);
    // Fill & stroke the path
    CGContextDrawPath(context, kCGPathFillStroke);
}

@end



@implementation WritePadInputView

@synthesize inkCollector;
@synthesize resultView;
@synthesize placeholder;
@synthesize delegate;
@synthesize showMarker;
@synthesize cmdButton;
@synthesize penButton;

+ (WritePadInputView *) sharedInputPanel
{
	if ( sharedInputPanel == nil )
	{
		CGRect f = [[UIScreen mainScreen] bounds];
		sharedInputPanel = [[WritePadInputView alloc] initWithFrame:f];
		sharedInputPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth;	
	}
	return sharedInputPanel;
}

+ (void) destroySharedInputPanel
{
	if ( sharedInputPanel != nil )
	{
		sharedInputPanel.delegate = nil;
		[sharedInputPanel release];
		sharedInputPanel = nil;
	}
}

- (id)initWithFrame:(CGRect)frame 
{
	frame.size.height = kInputPanelHeight;
    if ((self = [super initWithFrame:frame])) 
	{
		// Initialization code
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
		CGFloat colors[] =
		{
			185.0/255.0, 185.0/255.0, 197.0/255.0, 1.0,
			87.0/255.0, 87.0/255.0, 96.0/255.0, 1.0,
		};
		myGradient = CGGradientCreateWithColorComponents(rgb, colors, NULL,  2 );
		CGColorSpaceRelease(rgb);		
		
		if ( ! [[NSUserDefaults standardUserDefaults] boolForKey:kInputPanelWriteHere] )
		{
			self.placeholder = [NSString stringWithString:NSLocalizedString( @"Write Here", @"" )];
			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kInputPanelWriteHere];

		}
		
		markerPosition = [[NSUserDefaults standardUserDefaults] floatForKey:kInputPanelMarkerPosition];
		
		self.contentMode = UIViewContentModeRedraw;
		// create buttons
		_buttons = [[NSMutableArray alloc] initWithCapacity:BUTTON_COUNT];
		CGPoint	pos = CGPointMake( frame.size.width - BUTTON_SIZE - X_OFFSET, Y_OFFSET - 1 );
		CGSize  sz = [self createKeyBtn:@"btn-return.png" withTitle:@"\n" atPosition:pos];
		pos.x -= (sz.width + BUTTON_GAP);
		sz = [self createKeyBtn:@"btn-back.png" withTitle:@"\b" atPosition:pos];
		pos.x -= (sz.width + BUTTON_GAP);
		sz = [self createKeyBtn:@"btn-dot.png" withTitle:@"." atPosition:pos];
		pos.x -= (sz.width + BUTTON_GAP);
		sz = [self createKeyBtn:@"btn-space.png" withTitle:@" " atPosition:pos];
		pos.x -= BUTTON_GAP;
        
        self.cmdButton = [self createCommandButton:@"cmd" atPosition:pos];
        _showCmdButton = NO;
        
		/*
		sz = [self createKeyBtn:@"btn-cmd.png" withTitle:@"\r" atPosition:pos];
		pos.x -= (sz.width + BUTTON_GAP);		
		*/
		// create ink collector
		CGRect rrect = frame;
		rrect.origin.x += X_OFFSET;
		rrect.size.width -= 2 * X_OFFSET;
		rrect.origin.y = TOP_OFFSET;
		rrect.size.height -= (TOP_OFFSET + Y_OFFSET);
		inkCollector = [[WritePadInputPanel alloc] initWithFrame:rrect];
		inkCollector.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		inkCollector.contentMode = UIViewContentModeRedraw;
		inkCollector.backgroundColor = [UIColor clearColor];
		inkCollector.inputPanel = self;
		[inkCollector reloadOptions];
		
		// only these gestures should be recognized when control is not empty
		// loop for shortcuts... Shortcuts is a simplified version of PenCommander
		// Return - to enter text, Cut to delete ink, Loop for shortcut
		[inkCollector enableGestures:(GEST_ALL & ~GEST_LOOP) whenEmpty:YES];
		[inkCollector enableGestures:(GEST_RETURN | GEST_CUT | GEST_BACK) whenEmpty:NO];
		[self addSubview:inkCollector];
		
		// create result view
		UIButton * btn = [_buttons objectAtIndex:(BUTTON_COUNT-1)];
		NSInteger btncnt = [btn isHidden] ? BUTTON_COUNT-1 : BUTTON_COUNT;

		rrect = frame;
        rrect.size.width -= (RIGHT_OFFSET(btncnt));
        rrect.size.height = RESULT_HEIGHT+Y_OFFSET+1.0;

		uiResultView = [[UIResultsView alloc] initWithFrame:rrect];
		uiResultView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		uiResultView.contentMode = UIViewContentModeRedraw;
		uiResultView.backgroundColor = [UIColor clearColor];
        uiResultView.opaque = NO;
		[self addSubview:uiResultView];
        
		rrect = frame;
		rrect.origin.x += 2 * X_OFFSET;
		rrect.size.width -= (3 * X_OFFSET + RIGHT_OFFSET(btncnt));
		rrect.origin.y = Y_OFFSET + 4;
		rrect.size.height = RESULT_HEIGHT - 8;
		resultView = [[AsyncResultView alloc] initWithFrame:rrect];
		resultView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		resultView.contentMode = UIViewContentModeRedraw;
		resultView.inputPanel = self;
		resultView.backgroundColor = [UIColor clearColor];
		[self addSubview:resultView];
        self.penButton = nil;
        
		// self.showMarker = NO;
		_marker = [[UIImage imageNamed:@"input_marker.png"] retain];
		_markerSelected = NO;
		_bIgnoreActionKey = NO;
	}
    return self;
}

- (void) setDelegate:(id)newDelegate
{
	delegate = newDelegate;
	inkCollector.delegate = newDelegate;
}

- (UIButton *)buttonWithTitle:(NSString *)title
					   target:(id)target
						frame:(CGRect)frame
				darkTextColor:(BOOL)darkTextColor
{	
	UIButton *button = [[UIButton alloc] initWithFrame:frame];	
	button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	
	[button setTitle:title forState:UIControlStateNormal];	
	if (darkTextColor)
	{
		[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	}
	else
	{
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	}
		
	[button addTarget:target action:@selector(actionKey:) forControlEvents:UIControlEventTouchUpInside];
	[button addTarget:target action:@selector(actionKeyDown:) forControlEvents:UIControlEventTouchDown];
	[button addTarget:target action:@selector(actionKeyCancel:) forControlEvents:UIControlEventTouchDragExit];
	[button addTarget:target action:@selector(actionKeyCancel:) forControlEvents:UIControlEventTouchUpOutside];
	[button addTarget:target action:@selector(actionKeyCancel:) forControlEvents:UIControlEventTouchCancel];
	
    // in case the parent view draws with a custom color or gradient, use a transparent color
	button.backgroundColor = [UIColor clearColor];
	
	return [button autorelease];
}

- (UIButton *) createCommandButton:(NSString *)command atPosition:(CGPoint)position
{
    UIImage *   img = [UIImage imageNamed:@"btn-space.png"];
	UIImage *	image = [img stretchableImageWithLeftCapWidth:img.size.width/2.0 topCapHeight:0.0];
	CGRect		frame = CGRectMake( position.x, position.y, 0.0, img.size.height + 0.5 );
	UIButton *	button = [self buttonWithTitle:command
									   target:self
										frame:frame
								darkTextColor:YES];
    [button setBackgroundImage:image forState:UIControlStateNormal];
	button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	[self addSubview:button];
    button.tag = SHROTHAND_BUTTON_TAG;
    button.enabled = NO;
    return button;
}

- (void) showCommandButton:(BOOL)show withCommand:(NSString *)command
{
    if ( [command length] < 1 && show )
        return;
    
    if ( _showCmdButton == show )
        return;
    
    UIButton *	button = self.cmdButton;
    
    CGRect uiResult = uiResultView.frame;
    CGRect rResult = resultView.frame;
    CGRect rButton = button.frame;
    if ( show )
    {
        CGSize sz = [command sizeWithFont:button.titleLabel.font];
        [button setTitle:command forState:UIControlStateNormal];
        button.enabled = YES;
        
        
        CGFloat width = sz.width + 16;
        if ( width > 112 )
            width = 112;
        if ( width < 48 )
            width = 48;
        CGFloat bw = width - rButton.size.width;
        uiResult.size.width -= (bw + BUTTON_GAP);
        rButton.size.width = width;
        rButton.origin.x -= bw;

        rResult.size.width -= (bw + BUTTON_GAP);
        resultView.frame = rResult;

        
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.15];        
        button.frame = rButton;
        uiResultView.frame = uiResult;
		[UIView commitAnimations];    
        _showCmdButton = YES;
    }
    else
    {
        // button.enabled = NO;
            
        CGFloat bw = rButton.size.width;
        uiResult.size.width += (bw + BUTTON_GAP);
        rButton.size.width = 0.0;
        rButton.origin.x += bw;

        rResult.size.width += (bw + BUTTON_GAP);
        resultView.frame = rResult;

		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.15];        
        button.frame = rButton;
        uiResultView.frame = uiResult;
		[UIView commitAnimations]; 
        
        _showCmdButton = NO;
    }
}

-(CGSize)createKeyBtn:(NSString *)strImage withTitle:(NSString *)title atPosition:(CGPoint)position
{
	UIImage *	image = [UIImage imageNamed:strImage];
	CGRect		frame = CGRectMake( position.x, position.y, image.size.width + 0.5, image.size.height + 0.5 );
	UIButton *	button = [self buttonWithTitle:title
									   target:self
										frame:frame
								darkTextColor:YES];
	[button setImage:image forState:UIControlStateNormal];
	button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	[self addSubview:button];
	[_buttons addObject:button];
	// [button release];
	return image.size;
}

- (Boolean) stopHoldTimer
{
	if ( holdTimer != nil )
	{
		[holdTimer invalidate];
		holdTimer = nil;
		return YES;
	}
	return NO;
}

- (void) startHoldTimer:(id)sender timeout:(NSTimeInterval)timeout
{
	[self stopHoldTimer];
	holdTimer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self 
											   selector:@selector(holdKeyTimer:) userInfo:sender repeats:NO];
}


- (void) holdKeyTimer:(NSTimer*)theTimer
{
	UIButton * button = theTimer.userInfo;
	
	if ( [button.titleLabel.text compare:@"."] == NSOrderedSame )
	{
        // SHOW KEYBOARD ONLY IF THERE IS NO PEN
		[self stopHoldTimer];
		_bIgnoreActionKey = YES;
		// show punctuation keyboard; do not restart timer
		if ( delegate && [delegate respondsToSelector:@selector(WritePadInputPanelRecognizedGesture:withGesture:isEmpty:)])
		{
			[delegate WritePadInputPanelRecognizedGesture:inkCollector withGesture:GEST_SPELL isEmpty:YES];	
		}		
		return;
	}
	if ( delegate && ([delegate respondsToSelector:@selector(writePadInputKeyPressed:keyText:withSender:)] ) )
	{
		[delegate writePadInputKeyPressed:self keyText:button.titleLabel.text withSender:theTimer.userInfo];
	}	
	[self startHoldTimer:theTimer.userInfo timeout:kKeyTimeout];
}

- (IBAction) actionKeyDown:(id)sender
{
	[resultView.suggestions hidePopover:YES];
	_bIgnoreActionKey = NO;
	NSLog( @"buttons touch down" );
	// start touch and hold timer
	UIButton * button = sender;
	if ( [button.titleLabel.text compare:@"."] == NSOrderedSame || 
		(([button.titleLabel.text compare:@"\b"] == NSOrderedSame ||
		  [button.titleLabel.text compare:@" "] == NSOrderedSame || 
		  [button.titleLabel.text compare:@"\n"] == NSOrderedSame) && [inkCollector strokeCount] == 0) )
	{
		[self startHoldTimer:sender timeout:kInitialKeyTimeout];		
	}
}

- (IBAction) actionKeyCancel:(id)sender
{
	_bIgnoreActionKey = YES;
	NSLog( @"buttons touch cancel" );
	// stop touch and hold timer
	[self stopHoldTimer];
}


- (IBAction)actionKey:(id)sender
{
	[self stopHoldTimer];
	if ( ! _bIgnoreActionKey && [sender isKindOfClass:[UIButton class]] )
	{
		UIButton * button = sender;
		NSString * str = [button titleForState:UIControlStateNormal];
		// NSLog( @"%@ Button was clicked", str );
        
        if ( button.tag == SHROTHAND_BUTTON_TAG )
        {
            // process pen command
            [inkCollector processShortcut:str];
            [self empty];
        }        
		else if ( delegate && ([delegate respondsToSelector:@selector(writePadInputKeyPressed:keyText:withSender:)] ) )
		{
			[delegate writePadInputKeyPressed:self keyText:(NSString *)str withSender:sender];
		}
	}
	_bIgnoreActionKey = NO;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// 1. draw the background
	
	CGPoint myStartPoint, myEndPoint;
	myStartPoint.x = rect.size.width/2;
	myStartPoint.y = 0.0;
	myEndPoint.x = myStartPoint.x;
	myEndPoint.y = rect.size.height;
	if ( nil != myGradient )
		CGContextDrawLinearGradient (context, myGradient, myStartPoint, myEndPoint, 0);
	
	
	// draw the writing panel

	CGContextSetLineWidth( context, 1.0 );	
	
	// As a bonus, we'll combine arcs to create a round rectangle!

	// 2. draw the input panel
	
	// Drawing with a dark stroke color
	CGContextSetRGBStrokeColor(context, 0.1, 0.1, 0.1, 1.0);
	CGContextSetRGBFillColor(context, 239.0/255.0, 228.0/225.0, 110.0/225.0, 1.0);
	
	// If you were making this as a routine, you would probably accept a rectangle
	// that defines its bounds, and a radius reflecting the "rounded-ness" of the rectangle.
	CGRect rrect = rect;
	CGFloat radius = 8.0;
	rrect.origin.x += X_OFFSET;
	rrect.size.width -= 2 * X_OFFSET;
	rrect.origin.y = TOP_OFFSET;
	rrect.size.height -= (TOP_OFFSET + Y_OFFSET);
	// NOTE: At this point you may want to verify that your radius is no more than half
	// the width and height of your rectangle, as this technique degenerates for those cases.
	
	// In order to draw a rounded rectangle, we will take advantage of the fact that
	// CGContextAddArcToPoint will draw straight lines past the start and end of the arc
	// in order to create the path from the current position and the destination position.
	
	// In order to create the 4 arcs correctly, we need to know the min, mid and max positions
	// on the x and y lengths of the given rectangle.
	CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
	CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
	
	// Next, we will go around the rectangle in the order given by the figure below.
	//       minx    midx    maxx
	// miny    2       3       4
	// midy   1 9              5
	// maxy    8       7       6
	// Which gives us a coincident start and end point, which is incidental to this technique, but still doesn't
	// form a closed path, so we still need to close the path to connect the ends correctly.
	// Thus we start by moving to point 1, then adding arcs through each pair of points that follows.
	// You could use a similar tecgnique to create any shape with rounded corners.
	
	// Start at 1
	CGContextMoveToPoint(context, minx, midy);
	// Add an arc through 2 to 3
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	// Add an arc through 4 to 5
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	// Add an arc through 6 to 7
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
	// Add an arc through 8 to 9
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	// Close the path
	CGContextClosePath(context);
	// Fill & stroke the path
	CGContextDrawPath(context, kCGPathFillStroke);
	
	// 3. draw the input panel
	/*
	// Drawing with a white stroke color
	CGContextSetRGBStrokeColor(context, 0.3, 0.3, 0.3, 1.0);
	CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
	
	// If you were making this as a routine, you would probably accept a rectangle
	// that defines its bounds, and a radius reflecting the "rounded-ness" of the rectangle.
	UIButton * btn = [_buttons objectAtIndex:(BUTTON_COUNT-1)];
	NSInteger btncnt = [btn isHidden] ? BUTTON_COUNT-1 : BUTTON_COUNT;
	rrect = rect;
	radius = 8.0;
	rrect.origin.x += X_OFFSET;
	rrect.size.width -= (X_OFFSET + RIGHT_OFFSET(btncnt));
	rrect.origin.y = Y_OFFSET;
	rrect.size.height = RESULT_HEIGHT;
	// NOTE: At this point you may want to verify that your radius is no more than half
	// the width and height of your rectangle, as this technique degenerates for those cases.
	
	// In order to draw a rounded rectangle, we will take advantage of the fact that
	// CGContextAddArcToPoint will draw straight lines past the start and end of the arc
	// in order to create the path from the current position and the destination position.
	
	// In order to create the 4 arcs correctly, we need to know the min, mid and max positions
	// on the x and y lengths of the given rectangle.
	minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
	miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
	
	// Next, we will go around the rectangle in the order given by the figure below.
	//       minx    midx    maxx
	// miny    2       3       4
	// midy   1 9              5
	// maxy    8       7       6
	// Which gives us a coincident start and end point, which is incidental to this technique, but still doesn't
	// form a closed path, so we still need to close the path to connect the ends correctly.
	// Thus we start by moving to point 1, then adding arcs through each pair of points that follows.
	// You could use a similar tecgnique to create any shape with rounded corners.
	
	// Start at 1
	CGContextMoveToPoint(context, minx, midy);
	// Add an arc through 2 to 3
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	// Add an arc through 4 to 5
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	// Add an arc through 6 to 7
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
	// Add an arc through 8 to 9
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	// Close the path
	CGContextClosePath(context);
	// Fill & stroke the path
	CGContextDrawPath(context, kCGPathFillStroke);
    */
	
	Boolean singleLine = YES;
	if ( inkCollector != nil && [[RecognizerManager sharedManager] isEnabled] )
		singleLine = ((HWR_GetRecognitionFlags( [[RecognizerManager sharedManager] recognizer] ) & FLAG_SEPLET) == 0) ? YES : NO;
	
	// Draw a single line from left to right
	if ( singleLine )
	{
		CGContextSetLineWidth( context, 1.5 );	
		CGContextSetRGBStrokeColor(context, 155.0/255.0, 34.0/225.0, 34.0/225.0, 1.0);
		CGContextMoveToPoint(context, X_LINE_OFFSET, TOP_LINE_OFFSET1 );
		CGContextAddLineToPoint(context, rect.size.width - X_LINE_OFFSET, TOP_LINE_OFFSET1 );
		CGContextStrokePath(context);
	}
	else
	{
		CGFloat width = rect.size.width - (2.0 * X_LINE_OFFSET);
		NSInteger nLet = (NSInteger)(0.25 + width/(LETTER_WIDTH + BAR_HEIGHT));
		width = X_LINE_OFFSET + nLet * (LETTER_WIDTH + BAR_HEIGHT);									  
		
		
		CGFloat pattern[] = { LETTER_WIDTH, BAR_HEIGHT };
		CGContextSetLineWidth( context, 1.5 );	
		CGContextSetLineDash( context, 0.0, pattern, 2 );
		CGContextSetRGBStrokeColor(context, 155.0/255.0, 34.0/225.0, 34.0/225.0, 1.0);
		CGContextMoveToPoint(context, X_LINE_OFFSET, TOP_LINE_OFFSET1 );
		CGContextAddLineToPoint(context, width, TOP_LINE_OFFSET1 );
		
		for ( CGFloat x = X_LINE_OFFSET; x < width; )
		{
			CGContextMoveToPoint(context, x, TOP_LINE_OFFSET1-BAR_HEIGHT );
			CGContextAddLineToPoint(context, x, TOP_LINE_OFFSET1 );
			x += LETTER_WIDTH;
			CGContextMoveToPoint(context, x, TOP_LINE_OFFSET1-BAR_HEIGHT );
			CGContextAddLineToPoint(context, x, TOP_LINE_OFFSET1 );
			x += BAR_HEIGHT;
		}
		CGContextStrokePath(context);		
	}
	
	if ( self.showMarker )
	{
		if ( markerPosition < 1.0 )
		{
			markerPosition = X_LINE_OFFSET + LETTER_WIDTH;
		}		
		
		CGPoint pt = CGPointMake( markerPosition - _marker.size.width/2, TOP_LINE_OFFSET1 - 2 );
		if ( _markerSelected )
		{
			CGContextSetLineWidth( context, 1.5 );	
			CGContextSetLineDash( context, 0.0, 0, 0 );
			CGContextSetRGBStrokeColor(context, 34.0/255.0, 34.0/225.0, 222.0/225.0, 1.0);
			CGContextMoveToPoint(context, markerPosition, TOP_LINE_OFFSET2-4 );
			CGContextAddLineToPoint(context, markerPosition, TOP_LINE_OFFSET1+4 );
			CGContextStrokePath(context);
		}		
		[_marker drawAtPoint:pt];
	}
	
	CGFloat pattern[] = { 10.0, 10.0 };
	CGContextSetLineWidth( context, 0.5 );	
	CGContextSetLineDash( context, 0.0, pattern, 2 );
	CGContextSetRGBStrokeColor(context, 155.0/255.0, 34.0/225.0, 34.0/225.0, 1.0);
	CGContextMoveToPoint(context, X_LINE_OFFSET, TOP_LINE_OFFSET2 );
	CGContextAddLineToPoint(context, rect.size.width - X_LINE_OFFSET, TOP_LINE_OFFSET2 );
	CGContextStrokePath(context);
	
	
	// Draw a single line on top
	CGContextSetLineWidth( context, 0.5 );	
	CGContextSetRGBStrokeColor(context, 88.0/255.0, 88.0/225.0, 88.0/225.0, 1.0);
	CGContextMoveToPoint(context, 0, 0 );
	CGContextAddLineToPoint(context, rect.size.width, 0 );
	CGContextStrokePath(context);
	
	if ( placeholder != nil )
	{
		CGContextSetRGBFillColor(context, 0.1, 0.1, 0.1, 0.6 );
		CGRect rText = rect;
		rText.origin.y = TOP_LINE_OFFSET2-100;
		rText.size.height = 120;
		rText.origin.x -= 15;	// this font needs a little offset to the left
		UIFont * font = [UIFont fontWithName:@"Zapfino" size:90];
		[placeholder drawInRect:rText withFont:font lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
	}
    
    // display cuttent language image
    UIImage * langImage = [[LanguageManager sharedManager] languageImage];
    if ( nil != langImage )
    {
        CGPoint pt;
        pt.x = (rect.origin.x + rect.size.width) - 50;
        pt.y = (rect.origin.y + rect.size.height) - 45;
        [langImage drawAtPoint:pt blendMode:kCGBlendModeNormal alpha:0.6];
    }
}

- (void) moveMarkerToLocation:(CGPoint)location selected:(BOOL)sel
{
	
	[self setMarkerPosition:location.x];
	_markerSelected = sel;
	[self setNeedsDisplay];
}

- (CGFloat) getMarkerPosition
{
	return markerPosition;
}

- (CGRect) getMarkerRect
{
	if ( markerPosition < 1.0 )
	{
		markerPosition = self.bounds.size.width/7.0;
	}		
	CGRect result = CGRectMake( markerPosition - _marker.size.width, TOP_LINE_OFFSET1 - 2, _marker.size.width * 2, _marker.size.height + 4 );
	return result;
}

- (void) setMarkerPosition:(CGFloat)pos
{
	pos += _marker.size.width/2;
	if ( pos < X_LINE_OFFSET )
		pos = X_LINE_OFFSET;
	if ( pos > (self.bounds.size.width/2 + X_LINE_OFFSET) )
		pos = (self.bounds.size.width/2 + X_LINE_OFFSET);
	if ( markerPosition != pos )
	{
		markerPosition = pos;
		[[NSUserDefaults standardUserDefaults] setFloat:markerPosition forKey:kInputPanelMarkerPosition];	
	}
}

- (void) positionPopoverIfAny
{
	[resultView repositionPopover];
}

- (void) setHasInk:(Boolean)hasInk
{
	bHasInk = hasInk;
}

- (void) empty
{
	_markerSelected = NO;
    [self showCommandButton:NO withCommand:nil];
	[inkCollector empty];
	[resultView empty];
    self.penButton = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return YES;
}

- (void)dealloc 
{
    self.penButton = nil;
    self.cmdButton = nil;
    [uiResultView release];
	[_marker release];
	[inkCollector release];
	[resultView release];
	[_buttons release];
	if ( nil != myGradient )
		CGGradientRelease(myGradient);
    [super dealloc];
}


@end

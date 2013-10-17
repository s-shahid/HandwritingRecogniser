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

#include <AudioToolbox/AudioToolbox.h>

#import "WritePadInputPanel.h"
#import "WritePadInputView.h"
#import "AsyncResultView.h"
#import "OptionKeys.h"
#import "UIConst.h"
#import "RectObject.h"
#import "LanguageManager.h"
#import "RecognizerManager.h"

#ifndef EDITCTL_RELOAD_OPTIONS
#define EDITCTL_RELOAD_OPTIONS	@"EDITCTL_RELOAD_OPTIONS"
#endif // EDITCTL_RELOAD_OPTIONS

#define LineFlatness        0.5f
#define LineWidthMinDelta   0.2f
#define LineWidthStep       0.2f



/////////////////////////////////////////////////////////////
// InkObject


@implementation InkObject

@synthesize		inkData;

- (id)initWithInkData:(INK_DATA_PTR)initalData
{
	self = [super init];
	if (self)
	{
		inkData = INK_CreateCopy( initalData );
	}
	return self;
}

- (id)init
{
	self = [super init];
	if (self)
	{
		inkData = NULL;
	}
	return self;
}


- (void) sortInk
{
	INK_SortInk( inkData );
}

-(void)dealloc
{
	if ( NULL != inkData )
	{
		INK_FreeData( inkData );
		inkData = NULL;
	}
	[super dealloc];
}

@end

/////////////////////////////////////////////////////////////
// WPCurrentStrokeView

@implementation WPCurrentStrokeView

@synthesize panel;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
		self.opaque = NO;
		self.contentMode = UIViewContentModeRedraw;
		self.userInteractionEnabled = NO;
		self.clearsContextBeforeDrawing = NO;
    }
    return self;
}


-(void)drawRect:(CGRect)rect
{
	// draw the current stroke    
	if ( panel != nil && panel.strokeLen > 0 && panel.ptStroke != NULL )
    {
         CGContextRef context = UIGraphicsGetCurrentContext();
 		[WPInkView _renderLine:panel.ptStroke pointCount:panel.strokeLen inContext:context withWidth:panel.strokeWidth withColor:panel.strokeColor];
	}
}

@end


/////////////////////////////////////////////////////////////
// InkView

@interface WPInkView (Private)
@end

@implementation WPInkView

@synthesize panel;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
		self.opaque = NO;
		self.contentMode = UIViewContentModeRedraw;
		self.userInteractionEnabled = NO;
		self.clearsContextBeforeDrawing = NO;
     }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

#define FMIN    0.5
#define FMAX    1.5

+ (CGFloat) _calcWidth:(CGFloat)weight pressure:(int)pressure
{
    int p = pressure;
    if ( p <= 0 )
        p = DEFAULT_PRESSURE;
    else if ( p < MIN_PRESSURE )
        p = MIN_PRESSURE;
    else if ( p > MAX_PRESSURE )
        p = MAX_PRESSURE;
    if ( p == DEFAULT_PRESSURE )
        return weight;
    
    CGFloat f = (CGFloat)p/(CGFloat)DEFAULT_PRESSURE;
    if ( f < FMIN )
        f = FMIN;
    if ( f > FMAX )
        f = FMAX;
    return weight * f;
}


// Drawings a line onscreen based on where the user touches
+ (void) _renderLine:(CGStroke)points pointCount:(int)count withWidth:(float)width withColor:(UIColor *)color
{
    UIBezierPath * line = [UIBezierPath bezierPath];
    [color setStroke];
    line.lineJoinStyle = kCGLineJoinRound;
    line.lineCapStyle = kCGLineCapRound;
    line.flatness = LineFlatness;
    
    register CGFloat w, wLast;
    
    wLast = line.lineWidth = [WPInkView _calcWidth:width pressure:points[0].pressure];
    [line moveToPoint:points[0].pt];
    
    if ( count == 1 )
    {
        CGPoint pt = points[0].pt;
        pt.x++;
        
        [line addLineToPoint:pt];
    }
    else if ( count < 3 )
    {
        for ( register int i = 1; i < count; i++ )
            [line addLineToPoint:points[i].pt];
    }
    else
    {
        // NSLog( @"*****************************" );
        
        for ( register int i = 1, pts = 1; i < count-1; i++, pts++ )
        {
            w = [WPInkView _calcWidth:width pressure:(points[i].pressure)];
            if ( fabs( wLast - w ) > LineWidthMinDelta && pts > 2 && i < count - 3 )
            {
                [line stroke];
                line = [UIBezierPath bezierPath];
                line.lineJoinStyle = kCGLineJoinRound;
                line.lineCapStyle = kCGLineCapRound;
                line.flatness = LineFlatness;
                wLast = line.lineWidth = (w - wLast) > 0 ? wLast + LineWidthStep : wLast - LineWidthStep;
                [line moveToPoint:points[i].pt];
                pts = 1;
                continue;
            }
            [line addQuadCurveToPoint:points[i+1].pt controlPoint:points[i].pt];
        }
    }
    [line stroke];
}


// Drawings a line onscreen based on where the user touches
+ (void) _renderLine:(CGStroke)points pointCount:(int)count inContext:(CGContextRef)context withWidth:(float)width withColor:(UIColor *)color
{
    CGContextSetStrokeColorWithColor(context, [color CGColor]);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineCapRound );
    CGContextSetFlatness( context, LineFlatness );
    
    CGFloat w, wLast;
    wLast = w = [WPInkView _calcWidth:width pressure:(points[0].pressure)];
    CGContextSetLineWidth( context, wLast );
    
    CGContextMoveToPoint( context, points[0].pt.x, points[0].pt.y );
    
    if ( count == 1 )
    {
        CGPoint pt = points[0].pt;
        pt.x++;
        
        CGContextAddLineToPoint( context, pt.x, pt.y );
    }
    else if ( count < 6 )
    {
        for ( register int i = 1; i < count; i++ )
            CGContextAddLineToPoint( context, points[i].pt.x, points[i].pt.y );
    }
    else
    {
        for ( register int i = 1, pts = 1; i < count-1; i++, pts++ )
        {
            w = [WPInkView _calcWidth:width pressure:(points[i].pressure)];
            if ( fabs( wLast - w ) > LineWidthMinDelta && pts > 2 && i < count - 3 )
            {
                CGContextStrokePath(context);
                wLast = (w - wLast) > 0 ? wLast + LineWidthStep : wLast - LineWidthStep;
                CGContextSetLineWidth( context, wLast );
                CGContextMoveToPoint( context, points[i].pt.x, points[i].pt.y );
                pts = 1;
                continue;
            }
            CGContextAddQuadCurveToPoint( context, points[i].pt.x, points[i].pt.y, points[i+1].pt.x, points[i+1].pt.y );
        }
    }
    CGContextStrokePath(context);
}

+ (UIColor *) _uiColorRefToColor:(UInt32)coloref
{
	UIColor * color = [UIColor colorWithRed:GetRValue(coloref) green:GetGValue(coloref) blue:GetBValue(coloref) alpha:GetAValue(coloref)];
	return color;
}

-(void)drawRect:(CGRect)rect
{
	register int		nStroke = (cacheContext == NULL) ? 0 : countLines;
	int			nStrokeLen = 0;
	int			nWidth = 1;
	CGStroke	points = NULL;
	COLORREF	coloref = 0;
	CGRect		rStroke = CGRectZero;
    int         nCurrStrokeCnt = INK_StrokeCount( panel.inkData, FALSE );
    
    if ( nCurrStrokeCnt < countLines )
    {
        nStroke = 0;
        // TODO CLEAR THE RECT...
        if ( NULL != cacheContext )
            CGContextClearRect( cacheContext, rect );        
    }
    
    if ( nCurrStrokeCnt > 0 && (nStroke != nCurrStrokeCnt || cacheContext == NULL) )
    {
        CGContextRef context = (cacheContext == NULL) ? UIGraphicsGetCurrentContext() : cacheContext;
        while ( INK_GetStrokeRect( panel.inkData, nStroke, &rStroke, FALSE ) )
        {
            if ( CGRectIntersectsRect( rStroke, rect ) )
            {
                nStrokeLen = INK_GetStrokeP( panel.inkData, nStroke, &points, &nWidth, &coloref );
                if ( nStrokeLen < 1 || NULL == points )
                    break;
                UIColor * col1 = [WPInkView _uiColorRefToColor:coloref];
                // UIColor * col2 = [col1 colorWithAlphaComponent:0.3];
                // [WPInkView _renderLine:points pointCount:nStrokeLen inContext:context withWidth:(float)nWidth+2.0 withColor:col2];
                [WPInkView _renderLine:points pointCount:nStrokeLen inContext:context withWidth:(float)nWidth withColor:col1];
            }
            nStroke++;
        }
	}
    
    if ( cacheContext != NULL )
    {
        CGContextRef c = UIGraphicsGetCurrentContext();
        CGImageRef cacheImage = CGBitmapContextCreateImage(cacheContext);
        CGContextDrawImage(c, self.bounds, cacheImage);
        CGImageRelease(cacheImage);
    }

    countLines = nCurrStrokeCnt;
	if ( NULL != points )
		free( (void *)points );
}

@end

/////////////////////////////////////////////////////////////
// WritePadInputPanel

@interface WritePadInputPanel(private)

- (int) AddPixelsX:(int)x Y:(int)y pressure:(int)pressure IsLastPoint:(BOOL)bLastPoint;
- (UIColor *) _uiColorRefToColor:(UInt32)coloref;
- (UInt32) _uiColorToColorRef:(UIColor *)color;
- (int) getPressure:(int *)nAdded;

@end

@implementation WritePadInputPanel

#define DEFAULT_STROKE_LEN          1000

@synthesize delegate;
@synthesize strokeWidth;
@synthesize strokeColor;
@synthesize asyncRecoEnabled = _bAsyncRecoEnabled;
@synthesize asyncInkCollector = _bAsyncInkCollector;
@synthesize inputPanel;
@synthesize strokeLen;
@synthesize ptStroke;
@synthesize inkData;

NSString * str_info = nil;

- (id) initWithFrame:(CGRect)frame
{	
	frame.size.height = kInputPanelHeight;
	if((self = [super initWithFrame:frame])) 
	{		
		strokeLen = 0;
		strokeMemLen = DEFAULT_STROKE_LEN * sizeof( CGTracePoint );
		ptStroke = malloc( strokeMemLen );
		strokeWidth = DEFAULT_PENWIDTH;
		inkData = INK_InitData();	
		_timerTouchAndHold = nil;
		gesturesEnabledIfEmpty = GEST_NONE;
		gesturesEnabledIfData = GEST_NONE;
		
		_inkQueueGet = _inkQueuePut = 0;
		_bAddStroke = YES;
		
		_runInkThread = YES;
		_movingMarker = NO;
		_bAsyncRecoEnabled = NO;
		_bAsyncInkCollector = NO;
		_inkQueueCondition = [[NSCondition alloc] init];
		_recoCondition = [[NSCondition alloc] init];
		_recoLock = [[NSLock alloc] init];
		_inkLock = [[NSLock alloc] init];
		_firstTouch = NO;
        _nAdded = 0;
        _bStylusOffset = NO;
        _bStylusPressure = NO;
        
        self.autoresizesSubviews = YES;
        _inkView = [[WPInkView alloc] initWithFrame:[self bounds]];
        _inkView.panel = self;
        _inkView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_inkView];

        _currentStrokeView = [[WPCurrentStrokeView alloc] initWithFrame:[self bounds]];
        _currentStrokeView.panel = self;
        _currentStrokeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_currentStrokeView];
				
		// default ink color
		self.strokeColor = [UIColor blueColor];
		self.backgroundColor = [UIColor clearColor];
        self.multipleTouchEnabled = NO;
        
        _shortcuts = nil;		
		// init recognizer options
		NSUserDefaults*	defaults = [NSUserDefaults standardUserDefaults];
		if ( [defaults boolForKey:kRecoOptionsFirstStartKey] )
		{
			strokeWidth = [defaults floatForKey:kRecoOptionsInkWidth];
			if ( strokeWidth < 1.0 )
				strokeWidth = DEFAULT_PENWIDTH;
		}
		
		// [self enableAsyncInk:YES];
		// if ( _bAsyncInkCollector ) // && [defaults boolForKey:kRecoOptionsAsyncRecoEnabled] )
		{
			[self enableAsyncRecognizer:YES];
		}
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_reloadOptions:)
		 											 name:EDITCTL_RELOAD_OPTIONS object:nil];	
	}
	return self;
}

+ (void) ensureDefaultSettings:(Boolean)force
{
	NSUserDefaults*	defaults = [NSUserDefaults standardUserDefaults];
	BOOL b = [defaults boolForKey:kRecoOptionsFirstStartKey];
	if ( b != YES || force )
	{
		// set the default settings for Input Panel
		[defaults setBool:NO  forKey:kRecoOptionsSingleWordOnly];
		[defaults setBool:NO  forKey:kRecoOptionsSeparateLetters];
		[defaults setBool:NO  forKey:kRecoOptionsInternational];
		[defaults setBool:NO  forKey:kRecoOptionsDictOnly];
		[defaults setBool:NO  forKey:kRecoOptionsSuggestDictOnly];
		[defaults setBool:NO  forKey:kRecoOptionsSpellIgnoreNum];
		[defaults setBool:NO  forKey:kRecoOptionsSpellIgnoreUpper];
		[defaults setBool:YES forKey:kRecoOptionsUseCorrector];
		[defaults setBool:YES forKey:kRecoOptionsUseUserDict];
		[defaults setBool:YES forKey:kRecoOptionsUseLearner];
		[defaults setBool:NO  forKey:kRecoOptionsErrorVibrate];
		[defaults setBool:NO  forKey:kEditOptionsAutospace];
		[defaults setBool:YES forKey:kRecoOptionsErrorSound];		
		[defaults setBool:YES forKey:kOptionsShareUserData];
		[defaults setBool:YES forKey:kRecoOptionsInsertResult];

		[defaults setBool:YES forKey:kRecoOptionsFirstStartKey];
	}
}

- (void)_reloadOptions:(NSNotification *)aNotification
{
	[self reloadOptions];
}

- (void)reloadOptions
{
	NSUserDefaults*	defaults = [NSUserDefaults standardUserDefaults];
	BOOL b = [defaults boolForKey:kRecoOptionsFirstStartKey];
	if ( b == YES )
	{
		[self stopAsyncRecoThread];
		[_recoLock lock];
		
		inputPanel.showMarker = [defaults boolForKey:kRecoOptionsInsertResult];
		
		INK_Erase( inkData );
		inputPanel.resultView.text = nil;
		
        [self enableAsyncRecognizer:YES];

		[_recoLock unlock];
		if ( [self strokeCount] > 0 )
		{
			// recognize the content again...
			[self startAsyncRecoThread];
		}
        [_currentStrokeView setNeedsDisplay];
		[_inkView setNeedsDisplay];
		[inputPanel setNeedsDisplay];
	}		
}

- (BOOL) isInkData
{
	return (INK_StrokeCount( inkData, FALSE ) > 0) ? YES : NO;
}

- (void) killHoldTimer
{
	if ( nil != _timerTouchAndHold )
	{
		[_timerTouchAndHold invalidate];
		_timerTouchAndHold = nil;
	}
}

- (void) enableGestures:(GESTURE_TYPE)gestures whenEmpty:(BOOL)bEmpty;
{
	if ( bEmpty )
		gesturesEnabledIfEmpty = gestures;
	else
		gesturesEnabledIfData = gestures;
}

- (BOOL) deleteLastStroke
{
	[self stopAsyncRecoThread];

	BOOL bResult = INK_DeleteStroke( inkData, -1 );  // -1 deletes last stroke
	if ( bResult )
	{
		if ( INK_StrokeCount( inkData, FALSE ) > 0 )
        {
			[self startAsyncRecoThread];
        }
		else
        {
			inputPanel.resultView.text = nil;
            [self showShortcutButton:nil];
        }
	}
    [_currentStrokeView setNeedsDisplay];
	[_inkView setNeedsDisplay];
        
	return bResult;
}

#pragma mark - Ink Collection support

- (GESTURE_TYPE)recognizeGesture:(GESTURE_TYPE)gestures withStroke:(CGStroke)points withLength:(int)count 
{
	if ( count < 5 )
		return GEST_NONE;
	
	NSInteger iLen = [[NSUserDefaults standardUserDefaults] integerForKey:kRecoOptionsBackstrokeLen];
	if ( iLen < 100 )
	{
		iLen = DEFAULT_BACKGESTURELEN;
		[[NSUserDefaults standardUserDefaults] setInteger:iLen forKey:kRecoOptionsBackstrokeLen];
	}
	GESTURE_TYPE type = HWR_CheckGesture( gestures, points, count, 1, iLen );
	return type;
}

// this function is called from secondary thread
-(void) processEndOfStroke:(BOOL)fromThread
{
	if ( strokeLen < 2 )
	{
		strokeLen = 0;
		return;
	}
	
	GESTURE_TYPE	gesture = GEST_NONE;
	UInt32			nStrokeCount = INK_StrokeCount( inkData, FALSE );
	
	_bAddStroke = YES;
	if ( strokeLen > 5  && nStrokeCount > 0 && gesturesEnabledIfData != GEST_NONE )
	{
		// recognize gesture
		gesture = [self recognizeGesture:gesturesEnabledIfData withStroke:ptStroke withLength:strokeLen];
	}
	else if ( strokeLen > 5 && nStrokeCount == 0 && gesturesEnabledIfEmpty != GEST_NONE )
	{
		// recognize gesture
		gesture = [self recognizeGesture:gesturesEnabledIfEmpty withStroke:ptStroke withLength:strokeLen];
	}
	
	if ( gesture != GEST_NONE )
	{
		if ( fromThread )
		{
			NSArray * arr = [[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:gesture], [NSNumber numberWithInt:nStrokeCount], nil] autorelease];						
			[self performSelectorOnMainThread:@selector (strokeGestureInTread:) withObject:arr waitUntilDone:YES];
		}
		else
		{
			if ([delegate respondsToSelector:@selector(WritePadInputPanelRecognizedGesture:withGesture:isEmpty:)])
			{
				_bAddStroke = [delegate WritePadInputPanelRecognizedGesture:self withGesture:gesture isEmpty:(nStrokeCount == 0)];	
			}
		}
	}
	
	// check if the new stroke is before the marker and we have enough text already
	CGRect	inkRect;
	if ( _bAddStroke && inputPanel.showMarker && nStrokeCount > 0 && INK_GetDataRect( inkData, &inkRect, FALSE ) )
	{		
		CGFloat marker = [inputPanel getMarkerPosition];
		CGFloat minText = marker + self.bounds.size.width/4.0;
		CGFloat left, right;
		CGFloat bottom, top;
		left = right =  ptStroke[0].pt.x;
		bottom = top =  ptStroke[0].pt.y;
		for( register int i = 1; i < strokeLen; i++ )
		{
			left = MIN( ptStroke[i].pt.x, left );
			right = MAX( ptStroke[i].pt.x, right );
			top =  MIN( ptStroke[i].pt.y, top );
			bottom =  MAX( ptStroke[i].pt.y, bottom );
		}
		
		CGFloat mid = left + strokeWidth * 2.0f;
		const CGFloat MIN_STROKE_HEIGHT = 12.0f;
		if ( (ptStroke[0].pt.x < marker || mid < marker) && (bottom - top) > MIN_STROKE_HEIGHT && CGRectGetMaxX( inkRect ) > minText )
		{
			if ( fromThread )
			{
				NSArray * arr = [[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:GEST_RETURN], [NSNumber numberWithInt:nStrokeCount], nil] autorelease];						
				[self performSelectorOnMainThread:@selector (strokeGestureInTread:) withObject:arr waitUntilDone:YES];
			}
			else if ([delegate respondsToSelector:@selector(WritePadInputPanelRecognizedGesture:withGesture:isEmpty:)])
			{
				[delegate WritePadInputPanelRecognizedGesture:self withGesture:GEST_RETURN isEmpty:NO];	
			}
            _bAddStroke = YES;
		}
	}
    
    CGRect rect = CGRectNull;
		
	if ( _bAddStroke && strokeLen > 0 )
	{
		// call up the app delegate
		COLORREF	 coloref = [self _uiColorToColorRef:strokeColor];		
		if ( INK_AddStroke( inkData, ptStroke, strokeLen, (int)strokeWidth, coloref ) )
		{
			// if ( fromThread )
            [self startAsyncRecoThread];
            INK_GetStrokeRect( inkData, -1, &rect, TRUE );
		}
	}

	// MUST UPDATE THE ENTIRE VIEW
	strokeLen = 0;
	if ( fromThread )
	{
        RectObject * obj = nil;
        if ( ! CGRectIsNull( rect ) )
            obj = [[RectObject alloc] initWithRect:rect];
		[self performSelectorOnMainThread:@selector (updateDisplayInThread:) withObject:obj waitUntilDone:YES];
        [obj release];
	}
	else
	{
        [_currentStrokeView setNeedsDisplay];
        if ( CGRectIsNull( rect ) )
            [_inkView setNeedsDisplay];
        else
            [_inkView setNeedsDisplayInRect:rect];
	}
}


-(void)addPointToQueue:(CGPoint)point
{
	[_inkQueueCondition lock]; 
	
	int iPut = _inkQueuePut;
	_inkQueue[iPut] = point;
	iPut++;
	if ( iPut >= MAX_QUEUE_SIZE )
		iPut = 0;
	_inkQueuePut = iPut;
	[_inkQueueCondition signal];	
	[_inkQueueCondition unlock]; 
}

// this method called from inkCollectorThread
- (int)addPointPoint:(CGPoint)point
{
	int nAdded = 0;
	if ( point.y == -1 )
	{
		[self processEndOfStroke:YES];
	}
	else
	{
        // todo: get current pressure
        int pressure = [self getPressure:&nAdded];
		nAdded += [self AddPixelsX:point.x Y:point.y pressure:pressure IsLastPoint:FALSE];
	}
	return nAdded;	
}

- (int) getPressure:(int *)nAdded
{
    int pressure = DEFAULT_PRESSURE;
    
    // TODO: Optional: implement pressure, if supported by touch system
    
    return pressure;
}

- (void)inkCollectorThread :(id)anObj
{ 
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
	// Do thread work here.
	// NSLock *theLock = [[NSLock alloc] init]; 
		
	[_inkLock lock];
	
    int nAdded = 0;
	while( _runInkThread )
	{
		[_inkQueueCondition lock]; 
		while ( _inkQueueGet == _inkQueuePut ) 
			[_inkQueueCondition wait]; 
		[_inkQueueCondition unlock];
		
		if ( ! _runInkThread )
		{
			break;
		}
		
		int iGet = _inkQueueGet, iPut = _inkQueuePut;
		
		while( (iGet = _inkQueueGet) != (iPut = _inkQueuePut) )
		{
			// NSLog(@"new point x=%f y=%f", point.x, point.y );
			if ( iGet > iPut )
			{
				// NSLog(@"*** Error iGet (%i) > iPut (%i)", iGet, iPut );	
				while ( iGet < MAX_QUEUE_SIZE )
				{
					nAdded += [self addPointPoint:_inkQueue[iGet]];
					iGet++;
				}
				iGet = 0;
			}
			while ( iGet < iPut )
			{
				nAdded += [self addPointPoint:_inkQueue[iGet]];
				iGet++;
			}
			_inkQueueGet = iPut;
		}
		
		if ( nAdded > 2 )
		{				
			NSInteger from = MAX( 0, strokeLen-1-nAdded );
			NSInteger to = MAX( 0, strokeLen-1 );
            if ( from < to )
            {
                int penwidth = 2.0 + strokeWidth/2.0;
                CGRect rect = CGRectMake( ptStroke[to].pt.x, ptStroke[to].pt.y, ptStroke[to].pt.x, ptStroke[to].pt.y );
                for ( int i = from; i < to; i++ )
                {
                    rect.origin.x = MIN( rect.origin.x, ptStroke[i].pt.x );
                    rect.origin.y = MIN( rect.origin.y, ptStroke[i].pt.y );
                    rect.size.width = MAX( rect.size.width, ptStroke[i].pt.x );
                    rect.size.height = MAX( rect.size.height, ptStroke[i].pt.y);
                }
                rect.size.width -= rect.origin.x;
                rect.size.height -= rect.origin.y;
                rect = CGRectInset( rect, -penwidth, -penwidth );
                
                RectObject * obj = [[RectObject alloc] initWithRect:rect];			
                [self performSelectorOnMainThread:@selector(updateDisplayInThread:) withObject:obj waitUntilDone:YES];
                [obj release];
                nAdded = 0;
            }
		}
	}		
	
	[_inkLock unlock];
	[pool release]; 
} 

- (BOOL) enableAsyncInk:(BOOL)bEnable
{
	// can't disable async ink if async reco is enabled
	if ( (!bEnable) && (!_bAsyncRecoEnabled) )
	{
		// terminate ink thread
		if ( ! [_inkLock tryLock] )
		{
			_runInkThread = NO;
			[self addPointToQueue:CGPointMake( 0,0 )];
			[_inkLock lock];
		}
		[_inkLock unlock];
		_bAsyncInkCollector = NO;
	}
	else if ( bEnable && (!_bAsyncInkCollector) )
	{
		_runInkThread = YES;
		[NSThread detachNewThreadSelector:@selector(inkCollectorThread:) toTarget:self 
							   withObject:nil];		
		_bAsyncInkCollector = YES;
	}
	_inkQueueGet = _inkQueuePut = 0;
	_bAddStroke = YES;
	// [[NSUserDefaults standardUserDefaults] setBool:_bAsyncInkCollector forKey:kRecoOptionsAsyncInking];
	return _bAsyncInkCollector;
}

// Releases resources when they are not longer needed.
- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:EDITCTL_RELOAD_OPTIONS object:nil];
	[self killHoldTimer];
	
	// [self enableAsyncInk:NO];
	
	if ( NULL != ptStroke )
		free( ptStroke );	
	ptStroke = NULL;
	
    [_inkView release];
    [_currentStrokeView release];
    [_shortcuts release];
	[_inkQueueCondition release];
	[_recoCondition release];
	[strokeColor release];
	[_recoLock release];
	[_inkLock release];
	
	INK_FreeData( inkData );
	
	[super dealloc];
}

- (UInt32) _uiColorToColorRef:(UIColor *)color 
{
	CGColorRef	 colorref = [color CGColor];
	const float* colorComponents = CGColorGetComponents(colorref);	
	UInt32	 coloref = RGBA( CCTB(colorComponents[0]), CCTB(colorComponents[1]), CCTB(colorComponents[2]), CCTB(colorComponents[3]) ); 
	return coloref;
}

-(void)drawRect:(CGRect)rect
{
    /*
    if ( str_info != nil )
        [str_info drawInRect:[self bounds] withFont:[UIFont systemFontOfSize:22]];
     */
}

-(void) empty
{
	[self killHoldTimer];
	
	// strokeLen = 0;
	[self stopAsyncRecoThread];
	INK_Erase( inkData );	
	[_inkView setNeedsDisplay];
    [_currentStrokeView setNeedsDisplay];
}

#pragma mark - AddPixelToStroke

#define SEGMENT2            2
#define SEGMENT3            3
#define SEGMENT4            4

#define SEGMENT_DIST_1      3
#define SEGMENT_DIST_2      6
#define SEGMENT_DIST_3      12

-(int)AddPixelsX:(int)x Y:(int)y pressure:(int)pressure IsLastPoint:(BOOL)bLastPoint
// this method called from inkCollectorThread
{
    CGFloat		xNew, yNew, x1, y1;
    CGFloat		nSeg = SEGMENT3;
	
	if ( NULL == ptStroke )
		return 0;
	
    if  ( strokeLen < 1 )  
    {
        ptStroke[strokeLen].pt.x = _previousLocation.x = x;
        ptStroke[strokeLen].pt.y = _previousLocation.y = y;
        ptStroke[strokeLen].pressure = pressure;
        strokeLen = 1;
        return  1;
    }
	
    CGFloat dx = fabs( x - ptStroke[strokeLen-1].pt.x );
    CGFloat dy = fabs( y - ptStroke[strokeLen-1].pt.y );
	
    if  ( dx + dy < 1.0f )
        return 0;
	
    if ( dx + dy > 100.0f * SEGMENT_DIST_2 )
        return 0;
	
	int nNewLen = (strokeLen + 2 * SEGMENT4 + 1) * sizeof( CGTracePoint );
	if ( nNewLen >= strokeMemLen )
	{
		strokeMemLen += DEFAULT_STROKE_LEN * sizeof( CGTracePoint );
		ptStroke = realloc( ptStroke, strokeMemLen );
		if ( NULL == ptStroke )
			return 0;
	}
	
    if  ( (dx + dy) < SEGMENT_DIST_1 )  
    {
        ptStroke[strokeLen].pt.x = _previousLocation.x = x;
        ptStroke[strokeLen].pt.y = _previousLocation.y = y;
        ptStroke[strokeLen].pressure = pressure;
        strokeLen++;
        return  1;
    }
	
    if ( (dx + dy) < SEGMENT_DIST_2 )  
        nSeg = SEGMENT2;
    else if ( (dx + dy) < SEGMENT_DIST_3 )
        nSeg = SEGMENT3;
    else
		nSeg = SEGMENT4;
    int     nPoints = 0;
    for ( register int i = 1;  i < nSeg;  i++ )  
    {
        x1 = _previousLocation.x + ((x - _previousLocation.x)*i ) / nSeg;  //the point "to look at"
        y1 = _previousLocation.y + ((y - _previousLocation.y)*i ) / nSeg;  //the point "to look at"
		
        xNew = ptStroke[strokeLen-1].pt.x + (x1 - ptStroke[strokeLen-1].pt.x) / nSeg;
        yNew = ptStroke[strokeLen-1].pt.y + (y1 - ptStroke[strokeLen-1].pt.y) / nSeg;
		
        if ( xNew != ptStroke[strokeLen-1].pt.x || yNew != ptStroke[strokeLen-1].pt.y )
        {
            ptStroke[strokeLen].pt.x = xNew;
            ptStroke[strokeLen].pt.y = yNew;
            ptStroke[strokeLen].pressure = pressure;
            strokeLen++;
            nPoints++;
        }
    }
	
    if ( bLastPoint )  
    {
		// add last point
        if ( x != ptStroke[strokeLen-1].pt.x || y != ptStroke[strokeLen-1].pt.y )  
        {
            ptStroke[strokeLen].pt.x = x;
            ptStroke[strokeLen].pt.y = y;
            ptStroke[strokeLen].pressure = pressure;
            strokeLen++;
            nPoints++;
        }
    }
	
	_previousLocation.x = x;
    _previousLocation.y = y;
    return nPoints;
}

#pragma mark - Main thread callback methods 

-(void) updateDisplayInThread:(RectObject *)rObject
// This method is called when a updateDisplayInThread selector from main thread is called.
{
	if ( rObject == nil )
	{
        [_currentStrokeView setNeedsDisplay];
        if ( strokeLen == 0 )
            [_inkView setNeedsDisplay];
	}
	else
	{
        [_currentStrokeView setNeedsDisplayInRect:rObject.rect];
        if ( strokeLen == 0 )
            [_inkView setNeedsDisplayInRect:rObject.rect];
	}
}


- (NSUInteger) strokeCount
{
	return INK_StrokeCount( inkData, FALSE );
}

-(void) strokeGestureInTread:(NSArray *)arr
// This method is called when a strokeGestureTread selector from main thread is called.
{
	GESTURE_TYPE	gesture = (GESTURE_TYPE)[(NSNumber *)[arr objectAtIndex:0] intValue];
	UInt32			nStrokeCount = [(NSNumber *)[arr objectAtIndex:1] unsignedIntValue];
	if ([delegate respondsToSelector:@selector(WritePadInputPanelRecognizedGesture:withGesture:isEmpty:)])
	{
		_bAddStroke = [delegate WritePadInputPanelRecognizedGesture:self withGesture:gesture isEmpty:(nStrokeCount == 0)];	
	}
}

- (void) touchAndHoldTimer
{
	[self killHoldTimer];
	
	if ( inputPanel.showMarker )
	{
		CGPoint location = _previousLocation;
		location.x += self.frame.origin.x;
		location.y += self.frame.origin.y;
		
		CGRect rMarker = [inputPanel getMarkerRect];
		if ( CGRectContainsPoint( rMarker, location ) )
		{
			// marker selected, move left or right
			_movingMarker = YES;
			strokeLen = 0;
			[inputPanel moveMarkerToLocation:_previousLocation selected:YES];
			[_currentStrokeView setNeedsDisplay];
		}	
	}
}

- (void)addPointAndDraw:(CGPoint)point IsLastPoint:(BOOL)isLastPoint
{
	int	lenSave = strokeLen-1;	
	if ( lenSave < 0 )
	{
		return;
	}
	// must not contain negative coordinates
	if ( point.x < 0 )
		point.x = 0;
	if ( point.y < 0 )
		point.y = 0;
	
	if ( isLastPoint )
	{
		// make sure last point is not too far
		if ( ABS( ptStroke[lenSave].pt.x - point.x ) > 20 || ABS( ptStroke[lenSave].pt.y - point.y ) > 20 )
		{
			point = ptStroke[lenSave].pt;
		}
	}
    // todo: get current pressure
    int pressure = [self getPressure:&_nAdded];
 	_nAdded += [self AddPixelsX:point.x Y:point.y pressure:pressure IsLastPoint:isLastPoint];
	if ( _nAdded > 2 )
	{
        NSInteger from = MAX( 0, strokeLen-1-_nAdded );
        NSInteger to = MAX( 0, strokeLen-1 );
        int penwidth = 2.0 + strokeWidth/2.0;
        CGRect rect = CGRectMake( ptStroke[to].pt.x, ptStroke[to].pt.y, ptStroke[to].pt.x, ptStroke[to].pt.y );
        for ( int i = from; i < to; i++ )
        {
            rect.origin.x = MIN( rect.origin.x, ptStroke[i].pt.x );
            rect.origin.y = MIN( rect.origin.y, ptStroke[i].pt.y );
            rect.size.width = MAX( rect.size.width, ptStroke[i].pt.x );
            rect.size.height = MAX( rect.size.height, ptStroke[i].pt.y);
        }
        rect.size.width -= rect.origin.x;
        rect.size.height -= rect.origin.y;
        rect = CGRectInset( rect, -penwidth, -penwidth );

        [_currentStrokeView setNeedsDisplayInRect:rect];
        _nAdded = 0;
		//[self setNeedsDisplayInRect:rect];
	}	
}

#pragma mark - Touches Handles

// Handles the start of a touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch*	touch = [[event touchesForView:self] anyObject];
	CGPoint		location = [touch locationInView:self];
	
	[self killHoldTimer];
	
    CGRect r = self.bounds;
    r.origin.x = r.size.width - 50;
    if ( location.x > r.origin.x && location.y > (2*r.size.height)/3 )
        return;

    _bStylusPressure = NO;  // TODO: pen pressure can be supported
    _movingMarker = NO;
    strokeLen = 0;
    _nAdded = 0;
	_firstTouch = YES;
    
    if ( INK_StrokeCount( inkData, FALSE )  <  1 )
    {
        _timerTouchAndHold = [NSTimer scheduledTimerWithTimeInterval:DEFAULT_TOUCHANDHOLDDELAY target:self
															selector:@selector(touchAndHoldTimer) userInfo:nil repeats:NO];
	}
        
	if ( inputPanel && inputPanel.placeholder )
	{
		inputPanel.placeholder = nil;
		[inputPanel setNeedsDisplay];
	}
	
	if ( _bAsyncInkCollector )
	{
		if ( _inkQueueGet == _inkQueuePut )
			_inkQueueGet = _inkQueuePut = 0;
		[self addPointToQueue:location];
	}
	else
	{
		_previousLocation = location;
        ptStroke[0].pressure = [self getPressure:&_nAdded];
		ptStroke[0].pt = _previousLocation;
		strokeLen = 1;
        _nAdded = 1;
	}
}

// Handles the continuation of a touch. 
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch*	touch = [[event touchesForView:self] anyObject];
	CGPoint		location = [touch locationInView:self];
	
	if ( _movingMarker && strokeLen < 1 )
	{
		[inputPanel moveMarkerToLocation:location selected:YES];
		return;
	}
	
	if ( _firstTouch )
	{
		CGFloat		dy = location.y - _previousLocation.y;
		CGFloat		dx = location.x - _previousLocation.x;
		if ( dx*dx + dy*dy > 16 )
		{		
			[self killHoldTimer];
			_firstTouch = NO;
		}
	}
	
	if ( _bAsyncInkCollector  )
	{
		[self addPointToQueue:location];
	}
	else if ( location.y != _previousLocation.y || (location.x != _previousLocation.x && NULL != ptStroke) )
	{		
		[self addPointAndDraw:location IsLastPoint:FALSE];
	}			
}

// Handles the end of a touch event when the touch is a tap.
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self killHoldTimer];
	
	UITouch*	touch = [[event touchesForView:self] anyObject];
	CGPoint		location = [touch locationInView:self];
	UInt32		nStrokeCount = INK_StrokeCount( inkData, FALSE );
	
	if ( _movingMarker && strokeLen < 1 )
	{
		[inputPanel moveMarkerToLocation:location selected:NO];
		_movingMarker = NO;
		return;
	}

	if ( _firstTouch )
	{
		_firstTouch = NO;
		if ( nStrokeCount < 1  )
		{
			strokeLen = 0;
            [_currentStrokeView setNeedsDisplay];
			return;
		}
		else
		{
			location.x++;			
		}
	}
	if ( _bAsyncInkCollector )
	{
		[self addPointToQueue:location];
		[self addPointToQueue:CGPointMake( 0, -1 )];
	}
	else
	{
		[self addPointAndDraw:location IsLastPoint:TRUE];
		// process the new stroke
		[self processEndOfStroke:NO];
	}
}

// Handles the end of a touch event.
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSLog( @"touchesCancelled event=%@", event );
	_firstTouch = NO;
    
	if ( _movingMarker )
	{
		// [inputPanel moveMarkerToLocation:_previousLocation selected:NO];
		_movingMarker = NO;
	}
    strokeLen = 0;
	[_currentStrokeView setNeedsDisplay];
	// If appropriate, add code necessary to save the state of the application.
	// This application is not saving state.
}

#pragma mark - Asyncronous Recognizer Thread

- (BOOL) enableAsyncRecognizer:(BOOL)bEnable
{
	// requires async ink collector
	if ( bEnable /*&& _bAsyncInkCollector*/ )
	{
		_bAsyncRecoEnabled = YES;
	}
	else if ( _bAsyncRecoEnabled )
	{
		[self stopAsyncRecoThread];
		_bAsyncRecoEnabled = NO;
	}
	
	// [[NSUserDefaults standardUserDefaults] setBool:_bAsyncRecoEnabled forKey:kRecoOptionsAsyncRecoEnabled];
	return _bAsyncRecoEnabled;
}

-(BOOL) startAsyncRecoThread
{
	if ( ! _bAsyncRecoEnabled )
		return NO;
	
	// make sure another recognizer thread is not already running
	[self stopAsyncRecoThread];
	
	if ( [[RecognizerManager sharedManager] isEnabled] &&  [self isInkData] )
	{
		InkObject * ink = [[InkObject alloc] initWithInkData:inkData];
		// create a new async recognizer thread
		[NSThread detachNewThreadSelector:@selector(asyncRecoThread:) toTarget:self withObject:ink];	
	}
	return YES;
}

-(void) stopAsyncRecoThread
{
	HWR_StopAsyncReco( [[RecognizerManager sharedManager] recognizer] );
}

-(void) showAsyncRecoResult:(NSString *)strResult
{
	inputPanel.resultView.text = strResult;
	if ([delegate respondsToSelector:@selector(WritePadInputPanelAsyncResultReady:theResult:)])
	{
		[delegate WritePadInputPanelAsyncResultReady:self theResult:strResult];
	}	
}

-(void) asyncRecoThread:(id)obj
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
	[NSThread setThreadPriority:0.2];			
	InkObject * ink = obj;	
	if ( ink.inkData != NULL )
	{

		// lower the thread priority
		[_recoLock lock];	
		[ink sortInk];
		const char * pText = [[RecognizerManager sharedManager] recognizeInkData:ink.inkData background:NO async:YES selection:NO];
		// const char * pText = HWR_RecognizeInkData( [[RecognizerManager sharedManager] recognizer], ink.inkData, -1, TRUE, FALSE, FALSE, FALSE );
		[_recoLock unlock];	

		if ( pText != NULL ) 
		{
			// send result to main thread
			NSString * strText = [[NSString alloc] initWithCString:pText encoding: RecoStringEncoding];
			[self performSelectorOnMainThread:@selector (showAsyncRecoResult:) withObject:strText waitUntilDone:YES];
			[strText release];
            
            BOOL show = NO;
            if ( _shortcuts != nil && [[RecognizerManager sharedManager] getWordCount] == 1 )
            {  
                Shortcut * sc;
                for ( int i = 0; (sc = [_shortcuts userShortcutByIndex:i]) != nil; i++ )
                {
                    if ( [[RecognizerManager sharedManager] matchWord:sc.name] )
                    {
                        [self performSelectorOnMainThread:@selector(showShortcutButton:) withObject:sc.name waitUntilDone:YES];
                        show = YES;
                        break;
                    }
                }
                for ( int i = 0; (sc = [_shortcuts sysShortcutByIndex:i]) != nil; i++ )
                {
                    if ( [[RecognizerManager sharedManager] matchWord:sc.name] )
                    {
                        [self performSelectorOnMainThread:@selector(showShortcutButton:) withObject:sc.name waitUntilDone:YES];
                        show = YES;
                        break;
                    }
                }
            }
            if ( ! show )
                [self performSelectorOnMainThread:@selector(showShortcutButton:) withObject:nil waitUntilDone:YES];
        }		
		// exit thread, recognition completed
	}
	[ink release];
	[pool release];
}

- (void) showShortcutButton:(NSString *)name
{
    if ( name == nil )
        [inputPanel showCommandButton:NO withCommand:nil];
    else
        [inputPanel showCommandButton:YES withCommand:name];
}

- (BOOL) processShortcut:(NSString *)name
{
    if ( _shortcuts != nil )
    {
        Shortcut * sc = [_shortcuts findByName:name];
        [self showShortcutButton:nil];
        if ( sc != nil )
            return [_shortcuts process:sc];
    }
    return NO;
}

- (void) shortcutsEnable:(BOOL)bEnable delegate:(id)del uiDelegate:(id)uiDel 
{
    if ( ! bEnable && (nil !=_shortcuts) )
    {
        _shortcuts.delegate = nil;
        _shortcuts.delegateUI = nil;
        [_shortcuts release];
        _shortcuts = nil;
    }
    else if ( bEnable )
    {
        if ( _shortcuts == nil )
            _shortcuts = [[Shortcuts alloc] init];    
        _shortcuts.delegate = del;
        _shortcuts.delegateUI = uiDel;
    }
}


@end


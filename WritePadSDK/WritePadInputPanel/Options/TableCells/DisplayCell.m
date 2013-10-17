/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                           * */
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

#import "DisplayCell.h"
#import "UIConst.h"

// cell identifier for this custom cell
NSString *kDisplayCell_ID = @"DisplayCell_ID";

@implementation DisplayCell

@synthesize nameLabel;
@synthesize view;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier
{
	if (self = [super initWithStyle:style reuseIdentifier:identifier])
	{
		// turn off selection use
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		nameLabel.backgroundColor = [UIColor clearColor];
		nameLabel.opaque = NO;
		nameLabel.textColor = [UIColor blackColor];
		nameLabel.highlightedTextColor = [UIColor blackColor];
		nameLabel.font = [UIFont boldSystemFontOfSize:kNameFontSize];
		[self.contentView addSubview:nameLabel];
	}
	return self;
}

- (void)setView:(UIView *)inView
{
	if ( view)
	{
		[view removeFromSuperview];
		[view release];
	}
	view = inView;
	[view retain];
	[self.contentView addSubview:self.view];
	
	[self layoutSubviews];
}

- (void)layoutSubviews
{	
	[super layoutSubviews];
    CGRect contentRect = [self.contentView bounds];
	
	// In this example we will never be editing, but this illustrates the appropriate pattern
	CGRect frame = CGRectMake(contentRect.origin.x + kCellLeftOffset, kCellTopOffset, contentRect.size.width, kCellHeight);
	nameLabel.frame = frame;
	
	if ([self.view isKindOfClass:[UIPageControl class]])
	{
		// special case UIPageControl since its width changes after its creation
		CGRect frame = self.view.frame;
		frame.size.width = kPageControlWidth;
		self.view.frame = frame;
	}
	
	CGRect uiFrame = CGRectMake(contentRect.size.width - self.view.bounds.size.width - kCellLeftOffset,
								round((contentRect.size.height - self.view.bounds.size.height) / 2.0),
								self.view.bounds.size.width,
								self.view.bounds.size.height);
	self.view.frame = uiFrame;
}

- (void)dealloc
{
	[nameLabel release];
	[view release];
	
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];

	// when the selected state changes, set the highlighted state of the lables accordingly
	nameLabel.highlighted = selected;
}

@end

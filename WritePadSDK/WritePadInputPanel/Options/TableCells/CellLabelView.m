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

#import "CellLabelView.h"
#import "UIConst.h"

// cell identifier for this custom cell
NSString* kCellLabelView_ID = @"CellLavelView_ID";

@implementation CellLabelView

@synthesize textLabel;
@synthesize nameLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier
{
	self = [super initWithStyle:style reuseIdentifier:identifier];
	if (self)
	{
		// turn off selection use
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		nameLabel.backgroundColor = [UIColor clearColor];
		nameLabel.opaque = NO;
		
		nameLabel.textColor = [UIColor blackColor];
		nameLabel.highlightedTextColor = [UIColor blackColor];
		nameLabel.font = [UIFont boldSystemFontOfSize:kTitleFontSize];
		
		textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		textLabel.backgroundColor = [UIColor clearColor];
		textLabel.opaque = NO;
		textLabel.numberOfLines = 0;
		textLabel.textAlignment = UITextAlignmentLeft;
		//[textLabel autosizeTextToFit:NO];
		textLabel.lineBreakMode = UILineBreakModeWordWrap;
		textLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
		textLabel.textColor = [UIColor blackColor];
		textLabel.highlightedTextColor = [UIColor blackColor];
		textLabel.font = [UIFont fontWithName:kDefaultFontName size:kLabelFontSize];
		
		imageView = nil;

		[self.contentView addSubview:nameLabel];
		[self.contentView addSubview:textLabel];
		
	}
	return self;
}

- (void)setImage:(NSString *)imageName
{	
	if ( nil == imageView )
	{
		UIImage * Image = [UIImage imageNamed:imageName];
		CGRect frame = CGRectMake(	0.0, 0.0, Image.size.width, Image.size.height );
		imageView = [[UIImageView alloc] initWithFrame:frame];
		imageView.image = Image;
		[self.contentView addSubview:imageView];
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGRect contentRect = [self.contentView bounds];
	
	int		yOffset = kCellTopOffset;
	if ( nameLabel.text != nil && [nameLabel.text length] > 0 )
	{
		// In this example we will never be editing, but this illustrates the appropriate pattern
		nameLabel.frame = CGRectMake(contentRect.origin.x + kCellLeftOffset, yOffset, 
							  contentRect.size.width - 2 * kCellLeftOffset, kCellLabelHeight );
		yOffset += (kCellLabelHeight + kInsertValue);
	}
	// inset the text view within the cell
	if (contentRect.size.width > (kInsertValue*2) && contentRect.size.height > (2 * kCellLabelHeight) )	// but not if the cell is too small
	{
		int yImage = 0;
		if ( nil != imageView )
		{
			yImage = imageView.frame.size.height + kInsertValue;
		}
		
		textLabel.frame  = CGRectMake(contentRect.origin.x + kInsertValue,
									  contentRect.origin.y + yOffset,
									  contentRect.size.width - (kInsertValue*2),
									  contentRect.size.height - (yOffset + kInsertValue + yImage));
	}
	if ( nil != imageView )
	{
		imageView.frame = CGRectMake( (contentRect.size.width - imageView.frame.size.width)/2,
		(kInsertValue + yOffset + 1 + textLabel.frame.size.height),
		imageView.frame.size.width, imageView.frame.size.height );
	}
}

- (void)dealloc
{
    [textLabel release];
	[nameLabel release];
	[imageView release];
    [super dealloc];
}

@end

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

#import "ShortcutViewCell.h"

NSString *kShortcutViewCell_ID = @"ShortcutViewCell_ID";

@implementation ShortcutViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithStyle:(UITableViewCellStyle)style reuseIdentifier:reuseIdentifier]) 
	{
		// Initialization code

		//setup text view
		nameLabel = [[UILabel alloc] initWithFrame: CGRectZero];
		nameLabel.backgroundColor = [UIColor clearColor];
		nameLabel.font = [UIFont boldSystemFontOfSize:22];
		nameLabel.minimumFontSize = 15;
		nameLabel.highlightedTextColor = [UIColor whiteColor];
		nameLabel.adjustsFontSizeToFitWidth = YES;
		nameLabel.tag = 100;
		
		//setup text view
		commentLabel = [[UILabel alloc] initWithFrame: CGRectZero];
		commentLabel.backgroundColor = [UIColor clearColor];
		commentLabel.font = [UIFont systemFontOfSize:14];
		// commentLabel.minimumFontSize = 12;
		commentLabel.highlightedTextColor = [UIColor whiteColor];
		commentLabel.adjustsFontSizeToFitWidth = NO;
		commentLabel.tag = 101;
		commentLabel.lineBreakMode = UILineBreakModeWordWrap;
		commentLabel.numberOfLines = 0;
		commentLabel.baselineAdjustment = UIBaselineAdjustmentNone;
		
		[self.contentView addSubview:nameLabel];
		[self.contentView addSubview:commentLabel];
		
		[commentLabel release];
		[nameLabel release];		
		//store the last editing style
		lastEditingStyle = self.editingStyle;
	}
	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	double cellMargin = 10.0;
	double cellHeight = self.bounds.size.height - (cellMargin*2.0);
	double cellWidth = self.bounds.size.width - (cellMargin*2.0);
	double maxDisplayNameHeight = 32.0;
	
	nameLabel.frame = CGRectMake(2.0 * cellMargin, cellMargin, cellWidth - (2.0 * cellMargin), maxDisplayNameHeight );	
	commentLabel.frame = CGRectMake(2.0 * cellMargin, cellMargin + maxDisplayNameHeight, cellWidth - (2.0 * cellMargin),  
									cellHeight - (maxDisplayNameHeight-cellMargin));
	
	//store the last editing style
	lastEditingStyle = self.editingStyle;
}


-(void) setShortcut:(Shortcut *)sc
{
	nameLabel.text =  sc.name;
	commentLabel.text = sc.text;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{
	[super setSelected:selected animated:animated];
}

- (void)dealloc
{
	[super dealloc];
}

@end

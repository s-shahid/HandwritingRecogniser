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

#pragma once

#include "OptionKeys.h"


// constants
#define kSwitchButtonWidth			94.0
#define kSwitchButtonHeight			27.0
#define kToolbarButtonWidth			297

#define kPaletteHeight				36.0
#define kPaletteWidth				160
#define kTextFieldHeight			30.0
#define kSliderWidth				120.0

#define kToolbarHeight				40.0
#define kLeftMargin					20.0
#define kTopMargin					10.0
#define kSliderHeight				7.0
#define KUIAboutBoxHeight			220.0
#define kUIProgressBarHeight		24.0
#define kTextFieldWidth				260.0	// initial width, but the table cell will dictact the actual width

#define kNewWordCellHeight			56.0
#define kWordCellHeight				44.0
#define kFolderRowHeight			74.0

#define kUIShortcutCellHeight		150.0
#define kUIShortcutFontSize			15.0

// UITableView row heights
#define kUIRowHeight				50.0
#define kUIRowLabelHeight			22.0
#define kInputPanelHeight			264.0

#define kCellLeftOffset				8.0
#define kCellTopOffset				12.0
#define kTextFieldHeight			30.0
#define kCellHeight					25.0
#define kPageControlHeight			24.0
#define kPageControlWidth			160.0

#define kDefaultFontName			@"Arial"
#define kDefaultFontSize			20.0
#define kLabelFontSize				14.0
#define kCellLabelHeight			20.0
#define kInsertValue				8.0

#define kCellTtitleOffset			5.0
#define kCellCommentOffset			36.0
#define kCellNoteDateOffset			30.0

#define kProgressIndicatorSize		40.0
#define kImageGap					3.0
#define kNoteTextFontSize			14.0
#define kTitleFontSize				16.0
#define kNameFontSize				18.0
#define kLeftLabelWidth				100.0
#define kTaskCellHeight				60.0
#define kEntryCellHeight			60.0
#define kEventDetailLabelWidth		75.0
#define kCheckButtonSize			26.0

#define SHADOWCELLHEIGHT			15.0

#define BUFF_SIZE					1024
#define DEFAULT_BACKGESTURELEN		180
#define DEFAULT_PENWIDTH			4.0
#define DEFAULT_RECODELAY			1.5
#define MIN_DELAY					0.2
#define DEFAULT_BLINKDELAY			1.0
#define DEFAULT_DBLTOUCHDELAY		0.3
#define MAX_UNDO_LEVELS				20
#define kBottomOffset				22
#define DEFAULT_TOUCHANDHOLDDELAY	0.6
#define DEFAULT_AUTOSCROLLDELAY		0.35
#define kStatusBarHeight			20


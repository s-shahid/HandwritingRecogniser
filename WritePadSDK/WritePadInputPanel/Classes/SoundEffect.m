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

#import "SoundEffect.h"

@implementation SoundEffect

// Creates a sound effect object from the specified sound file
+ (id)soundEffectWithContentsOfFile:(NSString *)aPath 
{
    if (aPath)
	{
        return [[[SoundEffect alloc] initWithContentsOfFile:aPath] autorelease];
    }
    return nil;
}

// Initializes a sound effect object with the contents of the specified sound file
- (id)initWithContentsOfFile:(NSString *)path 
{
    self = [super init];
    
	// Gets the file located at the specified path.
    if (self != nil)
	{
        NSURL *aFileURL = [NSURL fileURLWithPath:path isDirectory:NO];
        
		// If the file exists, calls Core Audio to create a system sound ID.
        if (aFileURL != nil)  
		{
            SystemSoundID aSoundID;
            OSStatus error = AudioServicesCreateSystemSoundID((CFURLRef)aFileURL, &aSoundID);
            
            if (error == kAudioServicesNoError)
			{ 
				// success
                _soundID = aSoundID;
            }
			else
			{
                NSLog(@"Error %ld loading sound at path: %@", error, path);
                [self release], self = nil;
            }
        }
		else 
		{
            NSLog(@"NSURL is nil for path: %@", path);
            [self release], self = nil;
        }
    }
    return self;
}

// Releases resouces when no longer needed.
-(void)dealloc
{
    AudioServicesDisposeSystemSoundID(_soundID);
    [super dealloc];
}

// Plays the sound associated with a sound effect object.
-(void)play 
{
	// Calls Core Audio to play the sound for the specified sound ID.
    AudioServicesPlaySystemSound(_soundID);
}

@end

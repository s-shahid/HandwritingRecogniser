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

#pragma once

// from WritePadViewController.m
#define kGeneralOptionsFirstStartKey		@"GeneralOptionsFirstStartKey"
#define kGenegalOptionsText					@"GenegalOptionsText"
#define kGenegalOptionsTextScrollPos		@"GenegalOptionsTextScrollPos"
#define kGenegalOptionsTextSelStart			@"GenegalOptionsTextSelStart"
#define kGenegalOptionsTextSelLength		@"GenegalOptionsTextSelLength"
#define kGenegalOptionsTextEditOn			@"GenegalOptionsTextEditOn"
#define kGenegalOptionsRecoMode				@"GenegalOptionsRecoMode"
#define kGeneralOptionsDisableRotation		@"GeneralOptionsDisableRotation"
#define kGeneralOptionsFileEncoding			@"GeneralOptionsFileEncoding"
#define kGeneralOptionsFileName				@"GeneralOptionsFileName"
#define kGeneralOptionsFolderName			@"GeneralOptionsFolderName"
#define kGeneralOptionsShowAllFolders		@"GeneralOptionsShowAllFolders"
#define kGeneralOptionsCurrentLanguage		@"GeneralOptionsCurrentLanguage"

#define kWritePadTintColor					@"WritePadTintColor"

// from WritePadEdit.h
#define kEditOptionsShowSuggestions			@"ShowSuggestionWindow"
#define kEditEnableScrollGestures			@"EditEnableScrollGestures"
#define kEditEnableSpellChecker				@"EditEnableSpellChecker"
#define kEditDoubleTouchDelay				@"EditDoubleTouchDelay"
#define kEditCursorBlinkDelay				@"EditCursorBlinkDelay"
#define kEditEnableTextAnalyzer				@"EditEnableTextAnalyzer"
#define kEditSetSelectMode					@"EditSetSelectMode"
#define kEditOptionsFontSize				@"EditFontSize"
#define kEditOptionsFontFace				@"EditFontFace"
#define kEditOptionsAutocapitalize			@"EditOptionsAutocapitalize"
#define kEditOptionsAutospace				@"EditOptionsAutospace"
#define kEditShowScrollButtons				@"EditShowScrollButtons"
#define kEditHideToolbar					@"EditHideToolbar"
#define kEditSearchMatchCase				@"EditSearchMatchCase"
#define kEditTextColor						@"EditTextColor"
#define kEditPageColor						@"EditPageColor"
#define kEditInkColor						@"EditInkColor"
#define kEditOptionsAlignment				@"EditOptionsAlignment"
#define kEditOptionsCustomStyles			@"EditOptionsCustomStyles"
#define kOptionsDocumentSortOrder			@"OptionsDocumentSortOrder"
#define kEditOptionsAutocomplete			@"EditOptionsAutocomplete"
#define kEditShowDocumentEnd                @"EditShowDocumentEnd"

#define kGeneralOptionsInputMode			@"GeneralOptionsInputMode"

// from InkCollectorView.h
#define kRecoOptionsFirstStartKey			@"RecoFirstStartKey"
#define kRecoOptionsAsyncRecoEnabled		@"EnableAsyncRecognizer"
#define kRecoOptionsInkWidth				@"RecoInkWidth"
#define kRecoOptionsSeparateLetters			@"RecoSeparateLettersMode"
#define kRecoOptionsSingleWordOnly			@"RecoDisableSegmentation"
#define kRecoOptionsInternational			@"RecoInternationalCharset"
#define kRecoOptionsDictOnly				@"RecoDictionaryOnly"
#define kRecoOptionsSuggestDictOnly			@"RecoDictionaryOnlySuggest"
#define kRecoOptionsUseUserDict				@"RecoEnableUserDict"
#define kRecoOptionsUseLearner				@"RecoUseLearner"
#define kRecoOptionsAsyncInking				@"EnableAsyncInkCollectpor"
#define kRecoOptionsTimerDelay				@"RecoTimerDelay"
#define kRecoOptionsBackstrokeLen			@"RecoBackstrokeLen"
#define kRecoOptionsTouchHoldDelay			@"RecoTouchAndHoldDelay"
#define kRecoOptionsInkColor				@"RecoInkColor"
#define kRecoOptionsDrawGrid				@"RecoDrawGrid"
#define kRecoOptionsUseCorrector			@"RecoUseCorrector"
#define kRecoOptionsErrorVibrate			@"RecoErrorVibrate"
#define kRecoOptionsErrorSound				@"RecoErrorSound"
#define kRecoOptionsDisableShortcuts		@"RecoDisableShortcuts"
#define kRecoOptionsSpellIgnoreNum			@"RecoOptionsSpellIgnoreNum"
#define kRecoOptionsSpellIgnoreUpper		@"RecoOptionsSpellIgnoreUpper"
#define kRecoOptionsInsertResult			@"RecoOptionsInsertResult"
#define kRecoOptionsLetterShapes			@"RecoOptionsLetterShapes"

#define kUniqueApplicationID				@"UniqueApplicationID"

#define kGeneralOptionsGroupEvents			@"GeneralOptionsGroupEvents"
#define kGeneralOptionsGroupNotes			@"GeneralOptionsGroupNotes"
#define kGeneralOptionsGroupVoiceNotes		@"GeneralOptionsGroupVoiceNotes"
#define kGeneralOptionsGroupTasks			@"GeneralOptionsGroupTasks"
#define kGeneralOptionsGroupFolders			@"GeneralOptionsGroupFolders"
#define kGeneralOptionsTaskColors			@"GeneralOptionsTaskColors"
#define kGeneralOptionsEventColors			@"GeneralOptionsEventColors"
#define kGeneralOptionsNoteColors			@"GeneralOptionsNoteColors"
#define kGeneralOptionsNotePrivate			@"GeneralOptionsNotePrivate"
#define kGeneralOptionsNoteSubjectOnly		@"GeneralOptionsNoteSubjectOnly"
#define kGeneralOptionsVoiceNoteColors		@"GeneralOptionsVoiceNoteColors"
#define kGeneralOptionsNotePropBtn			@"GeneralOptionsNotePropBtn"
#define kGeneralOptionsShowSubject			@"GeneralOptionsShowSubject"

#define kGeneralOptionsLocationKey			@"GeneralOptionsLocationKey"
#define kGeneralOptionsShowSearch			@"GeneralOptionsShowSearch"
#define kGeneralOptionsSearchText			@"GeneralOptionsSearchText"
#define kGeneralOptionsLocalCopyPaste		@"GeneralOptionsLocalCopyPaste"

#define kTasksOptionsExportFile				@"TasksOptionsExportFile"

#define kGeneralOptionsShowCompleted		@"GeneralOptionsShowCompleted"
#define kGeneralOptionsShowPrivateTasks		@"GeneralOptionsShowPrivateTasks"
#define kGeneralOptionsShowPrivateNotes		@"GeneralOptionsShowPrivateNotes"
#define kGeneralOptionsShowPrivateEvents	@"GeneralOptionsShowPrivateEvents"
#define kGeneralOptionsShowPrivateVoice		@"GeneralOptionsShowPrivateVoice"
#define kGeneralOptionsHideCompleteBox		@"GeneralOptionsHideCompleteBox"
#define kGeneralOptionsShowCancelled		@"GeneralOptionsShowCancelled"
#define kGeneralOptionsDefaultIcon			@"GeneralOptionsDefaultIcon"
#define kGeneralOptionsShowPastDueBadge		@"GeneralOptionsShowPastDueBadge"

#define kJournalOptionsExportFile			@"JournalOptionsExportFile"
#define kGeneralOptionsShowMiscFields		@"GeneralOptionsShowMiscFields"
#define kGeneralOptionsCreateDefaultItems	@"GeneralOptionsCreateDefaultItems"

#define kGeneralOptionsEnableFileShare		@"GeneralOptionsEnableFileShare"
#define kGeneralOptionsEnableDataSync		@"GeneralOptionsEnableDataSync"
#define kGeneralOptionsHttpStayAwake		@"GeneralOptionsHttpStayAwake"
#define kGeneralOptionsEnableFilePassword	@"GeneralOptionsEnableFilePassword"
#define kGeneralOptionsHttpPassword			@"GeneralOptionsHttpPassword"
#define kGeneralOptionsUseKeyboard			@"GeneralOptionsUseKeyboard"

#define kRemoteNotificationsID				@"RemoteNotificationsID"
#define kRemoteNotificationsTMZ				@"RemoteNotificationsTMZ"

#define kOptionsFilterByPriority			@"OptionsFilterByPriority"
#define kOptionsFilterByDate				@"OptionsFilterByDate"
#define kOptionsFilterByText				@"OptionsFilterByDate"
#define kOptionsFilterByColor				@"OptionsFilterByColor"

#define kGeneralOptionsDefaultEmailTO		@"GeneralOptionsDefaultEmailTO"
#define kGeneralOptionsDefaultEmailCC		@"GeneralOptionsDefaultEmailCC"
#define kGeneralOptionsDefaultEmailBCC		@"GeneralOptionsDefaultEmailBCC"
#define kGeneralOptionsDefaultNoteColor		@"GeneralOptionsDefaultNoteColor"
#define kGeneralOptionsDefaultFolderColor	@"GeneralOptionsDefaultFolderColor"
#define kGeneralOptionsDefaultNoteCategoty	@"GeneralOptionsDefaultNoteCategoty"
#define kGeneralOptionsDefaultNotePriority	@"GeneralOptionsDefaultNotePriority"
#define kGeneralOptionsShowGroupsView		@"GeneralOptionsShowGroupsView"
#define kGeneralOptionsFileFormat			@"GeneralOptionsFileFormat"

#define kGeneralOptionsUseFilterCatrgory	@"GeneralOptionsFilterCatrgory"
#define kGeneralOptionsUseFilterColor		@"GeneralOptionsFilterColor"
#define kGeneralOptionsUseFilterPriority	@"GeneralOptionsFilterPriority"
#define kGeneralOptionsDefaultEmailSign		@"GeneralOptionsDefaultEmailSign"
#define kGeneralOptionsInitDefaults			@"GeneralOptionsInitDefaults42"

#define kOptionsShareUserData				@"OptionsShareUserData"
#define kOptionsShareDataOniCloud           @"OptionsShareDataOniCloud"

#define kTranslatorCreateNew				@"TranslatorCreateNew"
#define kGeneralOptionsDefaultNoteIcon		@"GeneralOptionsDefaultNoteIcon"
#define kGeneralOptionsDefaultFolderIcon	@"GeneralOptionsDefaultFolderIcon"

#define EDITCTL_RELOAD_OPTIONS				(@"EDITCTL_RELOAD_OPTIONS")

#define kTwitterOptionsDeleteText			@"TwitterOptionsDeleteText"
#define kTwitterOptionsPrompt				@"TwitterOptionsPrompt"
#define kTwitterOptionsUseLocation			@"TwitterOptionsUseLocation"
#define kTwitterDefaultAccount				@"TwitterDefaultAccount"
#define kTwitterDefaultPassword				@"TwitterDefaultPassword"
#define kTwitterShowTruncateWarning			@"TwitterShowTruncateWarning"
#define kTwitterAccountIdentifier           @"TwitterAccountIdentifier"
	
#define kSyncDropboxDisabled				@"SyncDropboxDisabled"
#define kDropboxDefaultAccount				@"DropboxDefaultAccount"
#define kDropboxDefaultPassword				@"DropboxDefaultPassword"
#define kDropboxLastSyncDate				@"DropboxLastSyncDate"
#define kDropboxAutosyncStart				@"DropboxAutosyncStart"

#define kFacebookPrivacySetting				@"FacebookPrivacySetting"
#define kFacebookShowTruncateWarning		@"FacebookShowTruncateWarning"
#define kFacebookRememberPassword			@"FacebookRememberPassword"
#define kFacebookEraseAfterUpdate			@"FacebookEraseAfterUpdate"

#define kPhatPadOptionsEnableShapes			@"PhatPadOptionsEnableShapes"
#define kPhatPadOptionsDeleteRecStrokes		@"PhatPadOptionsDeleteRecStrokes"
#define kPhatPadOptionsFirstStartKey		@"PhatPadOptionsFirstStartKey"
#define kPhatPadOptionsInkWidth				@"PhatPadOptionsInkWidth"
#define kPhatPadOptionsInkColor				@"PhatPadOptionsInkColor"
#define kPhatPadOptionsDrawGridV			@"PhatPadOptionsDrawGridV"
#define kPhatPadOptionsDrawGridH			@"PhatPadOptionsDrawGridH"
#define kPhatPadOptionsIgnoreShortStrokes	@"PhatPadOptionsIgnoreShortStrokes"
#define kPhatPadOptionsPalmRejection		@"PhatPadOptionsPalmRejection"
#define kPhatPadOptionsAdvancedInking		@"PhatPadOptionsAdvancedInking"
#define kPhatPadOptionsCustomPens			@"PhatPadOptionsCustomPens"
#define kPhatPadOptionsHideFooter			@"PhatPadOptionsHideFooter"
#define kPhatPadOptionsEnableEraseGesture	@"PhatPadOptionsEnableEraseGesture"
#define kPhatPadOptionsInputMode			@"PhatPadOptionsInputMode"

#define kPhatPadPageColor					@"PhatPadPageColor"
#define kPresentationSoundEnabled			@"PresentationSoundEnabled"

// Evernote
#define kEvernoteDefaultAccount				@"EvernoteDefaultAccount"
#define kEvernoteDefaultPassword			@"EvernoteDefaultPassword"
#define kSyncEvernoteEnabled				@"SyncEvernoteEnabled"
#define kSyncConflictResolution				@"SyncConflictResolution"
#define kEvernoteDefaultNotebook			@"EvernoteDefaultNotebook"

#define kGoogleDefaultAccount				@"GoogleDefaultAccount"
#define kGoogleDefaultPassword				@"GoogleDefaultPassword"
#define kGoogleUploadAsPDF					@"GoogleUploadAsPDF"

#define kWritePadOptionsSynciCloud          @"WritePadOptionsSynciCloud"
#define kGeneralOptionsDontShowWizard       @"GeneralOptionsDontShowWizard"

#define kTextFontStyleView                  @"TextFontStyleView"


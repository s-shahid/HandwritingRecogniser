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


#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "WritePadStoreObserver.h"

@class WritePadStoreManager;

@protocol WritePadStoreDelegate <NSObject>
@optional
- (void)productFetchComplete:(WritePadStoreManager *)storeManager;
- (void)productPurchased:(NSString *)productId storeManager:(WritePadStoreManager *)storeManager;
- (void)transactionCanceled:(WritePadStoreManager *)storeManager;
@end


@interface WritePadStoreManager : NSObject <SKProductsRequestDelegate>
{
@private
	NSMutableArray *  _purchasableObjects;
	WritePadStoreObserver * _storeObserver;
    
    NSMutableArray * productIDs;
	
	BOOL	requestingData;
	id <WritePadStoreDelegate> delegate;
	
}

@property (nonatomic, assign) id <WritePadStoreDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *purchasableObjects;
@property (nonatomic, retain) WritePadStoreObserver *storeObserver;
@property (nonatomic, readonly) NSMutableArray * productIDs;

+ (WritePadStoreManager *) sharedManager;

+ (BOOL) isProductPurchased:(NSString*)featureId; 
+ (BOOL) isLanguagePackPurchased:(NSInteger)langID;
+ (void) setLanguagePackPurchased:(NSInteger)langID;
+ (void) setProductPurchased:(NSString *)featureId;

- (NSString *) productImageName:(NSInteger)langID;
- (NSString *) productName:(NSInteger)langID;

- (BOOL) isProductAvailable:(NSInteger)langID;
- (void) buyLanguagePack:(NSInteger)langID;
- (BOOL) isBusy;

// these three are not static methods, since you have to initialize the store with your product ids before calling this function
- (void) buyProduct:(NSString*) featureId;
- (NSMutableArray*) purchasableObjectsDescription;
- (void) restorePreviousTransactions;
- (void) requestProductData;
- (void) provideContent: (NSString*) productIdentifier forReceipt:(NSData*) receiptData isNew:(BOOL)newTransaction;
- (void) transactionCanceled: (SKPaymentTransaction *)transaction;
- (void) failedTransaction: (SKPaymentTransaction *)transaction;
- (void) restoreTransactionsCompleted:(NSArray *)transactions withError:(NSError *)error;

@end

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

#import "WritePadStoreManager.h"
#import "LanguageManager.h"

// TODO: Replace <your_app_id> with your bundle ID
// #error Replace <your_app_id> with your bundle ID

static NSString * gEnglishPackID = @"com.<your_app_id>.English";
static NSString * gGermanPackID = @"com.<your_app_id>.German";
static NSString * gFrenchPackID = @"com.<your_app_id>.French";
static NSString * gSpanishPackID = @"com.<your_app_id>.Spanish";
static NSString * gPortuguesePackID = @"com.<your_app_id>.Portuguese";
static NSString * gDutchPackID = @"com.<your_app_id>.Dutch";
static NSString * gItalianPackID = @"com.<your_app_id>.Italian";
static NSString * gFinnishPackID = @"com.<your_app_id>.Finnish";
static NSString * gNorwegianPackID = @"com.<your_app_id>.Norwegian";
static NSString * gSwedishPackID = @"com.<your_app_id>.Swedish";
static NSString * gDanishPackID = @"com.<your_app_id>.Danish";

static WritePadStoreManager * gManager = nil;

@interface WritePadStoreManager (PrivateMethods)

@end

@implementation WritePadStoreManager

@synthesize delegate;
@synthesize purchasableObjects = _purchasableObjects;
@synthesize storeObserver = _storeObserver;
@synthesize productIDs;

+ (WritePadStoreManager *) sharedManager
{
	@synchronized(self) 
	{	
		if ( nil == gManager )
		{
			gManager = [[WritePadStoreManager alloc] init];
		}
	}
	return gManager;
}

- (id) init
{
	self = [super init];
	if (self != nil) 
	{
		requestingData = NO;
		self.delegate = nil;
        
        // init languages
        productIDs = [[NSMutableArray arrayWithObjects:
                      [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:WPLanguageGerman], @"ID",
                       @"Deutsch", @"name", gGermanPackID, @"identifier", @"language_german", @"image",
                       [NSNumber numberWithBool:NO], @"canbuy", nil],
                      [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:WPLanguageFrench], @"ID",
                       @"Français", @"name", gFrenchPackID, @"identifier",  @"language_french", @"image",
                       [NSNumber numberWithBool:NO], @"canbuy", nil],
                      [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:WPLanguageSpanish], @"ID",
                       @"Español", @"name", gSpanishPackID, @"identifier",  @"language_spanish", @"image",
                       [NSNumber numberWithBool:NO], @"canbuy", nil],
                      [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:WPLanguagePortuguese], @"ID",
                       @"Português", @"name", gPortuguesePackID, @"identifier",  @"language_portuguese", @"image",
                       [NSNumber numberWithBool:NO], @"canbuy", nil],
                      [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:WPLanguageBrazilian], @"ID",
                       @"Português", @"name", gPortuguesePackID, @"identifier",  @"language_brazilian", @"image",
                       [NSNumber numberWithBool:NO], @"canbuy", nil],
                      [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:WPLanguageDutch], @"ID",
                       @"Nederlands", @"name", gDutchPackID, @"identifier",  @"language_dutch", @"image",
                       [NSNumber numberWithBool:NO], @"canbuy", nil],
                      [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:WPLanguageItalian], @"ID",
                       @"Italiano", @"name", gItalianPackID, @"identifier",  @"language_italian", @"image",
                       [NSNumber numberWithBool:NO], @"canbuy", nil],
                      [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:WPLanguageEnglishUS], @"ID",
                       @"English", @"name", gEnglishPackID, @"identifier",  @"language_us", @"image",
                       [NSNumber numberWithBool:NO], @"canbuy", nil],
                      [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:WPLanguageEnglishUK], @"ID",
                       @"English", @"name", gEnglishPackID, @"identifier",  @"language_english", @"image",
                       [NSNumber numberWithBool:NO], @"canbuy", nil],
                       [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:WPLanguageDanish], @"ID",
                        @"Dansk", @"name", gDanishPackID, @"identifier",  @"language_danish", @"image",
                        [NSNumber numberWithBool:NO], @"canbuy", nil],
                       [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:WPLanguageNorwegian], @"ID",
                        @"Norsk", @"name", gNorwegianPackID, @"identifier",  @"language_norwegian", @"image",
                        [NSNumber numberWithBool:NO], @"canbuy", nil],
                       [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:WPLanguageFinnish], @"ID",
                        @"Suomi", @"name", gFinnishPackID, @"identifier",  @"language_finnish", @"image",
                        [NSNumber numberWithBool:NO], @"canbuy", nil],
                       [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:WPLanguageSwedish], @"ID",
                        @"Svenska", @"name", gSwedishPackID, @"identifier",  @"language_swedish", @"image",
                        [NSNumber numberWithBool:NO], @"canbuy", nil],
                       nil] retain];
        
        _purchasableObjects = [[NSMutableArray alloc] init];
		_storeObserver = [[WritePadStoreObserver alloc] init];
		[[SKPaymentQueue defaultQueue] addTransactionObserver:self.storeObserver];					
		[self requestProductData];						
	}
	return self;
}

- (void) dealloc
{
    [productIDs release];
	[_purchasableObjects release];
	[_storeObserver release];
	[super dealloc];
}

#pragma mark Store Methods


-(void) requestProductData
{
    if ( [self isBusy] )
        return;
	SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObjects: 
                                                                                       gEnglishPackID, gGermanPackID, gFrenchPackID,
                                                                                       gSpanishPackID, gPortuguesePackID, gDutchPackID, 
                                                                                       gItalianPackID, gDanishPackID, gNorwegianPackID,
                                                                                       gSwedishPackID, gFinnishPackID, nil]];
	request.delegate = self;
	requestingData = YES;
	[request start];
}

- (BOOL) isProductAvailable:(NSInteger)langID
{
	for ( NSDictionary * prod in productIDs )
    {
        if ( [[prod objectForKey:@"ID"] intValue] == langID )
        {
            return [[prod objectForKey:@"canbuy"] boolValue];
        }
    }
    return NO;
}

- (NSString *) productImageName:(NSInteger)langID
{
	for ( NSDictionary * prod in productIDs )
    {
        if ( [[prod objectForKey:@"ID"] intValue] == langID )
        {
            return [prod objectForKey:@"image"];
        }
    }
    return nil;
}

- (NSString *) productName:(NSInteger)langID
{
	for ( NSDictionary * prod in productIDs )
    {
        if ( [[prod objectForKey:@"ID"] intValue] == langID )
        {
            return [prod objectForKey:@"name"];
        }
    }
    return nil;
}

- (BOOL) isBusy
{
	return requestingData;
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	[self.purchasableObjects addObjectsFromArray:response.products];
	
	for( int i  = 0;i < [self.purchasableObjects count]; i++)
	{		
		SKProduct *product = [self.purchasableObjects objectAtIndex:i];
		NSLog(@"Feature: %@, Cost: %f, ID: %@",[product localizedTitle],
			  [[product price] doubleValue], [product productIdentifier]);
        
        for ( int j = 0; j < [productIDs count]; j++ )
        {        
            NSDictionary * prd = [productIDs objectAtIndex:j]; 
            if ( [[prd objectForKey:@"identifier"] caseInsensitiveCompare:product.productIdentifier] == NSOrderedSame )
            {
                NSMutableDictionary * mut = [prd mutableCopy];
                [mut setObject:[NSNumber numberWithBool:YES] forKey:@"canbuy"];
                [productIDs replaceObjectAtIndex:j withObject:mut];
                [mut release];
                break;
            }
        }
	}
	
    /*
	for ( NSString *invalidProduct in response.invalidProductIdentifiers )
		NSLog(@"Problem in iTunes connect configuration for product: %@", invalidProduct);
    */
    
	[request autorelease];	
	
	requestingData = NO;
	if(delegate && [delegate respondsToSelector:@selector(productFetchComplete:)])
	{
		[delegate productFetchComplete:self];	
	}
}

+ (BOOL) isLanguagePackPurchased:(NSInteger)langID
{
    BOOL    result = NO;
	switch ( langID )
	{
		case WPLanguageGerman :
			result = [self isProductPurchased:gGermanPackID];
			break;
			
		case WPLanguageFrench :
			result = [self isProductPurchased:gFrenchPackID];
			break;
			
		case WPLanguageSpanish :
			result = [self isProductPurchased:gSpanishPackID];
			break;
			
		case WPLanguagePortuguese :
		case WPLanguageBrazilian :
			result = [self isProductPurchased:gPortuguesePackID];
			break;
			
		case WPLanguageDutch :
			result = [self isProductPurchased:gDutchPackID];
			break;
			
		case WPLanguageItalian :
			result = [self isProductPurchased:gItalianPackID];
			break;
			            
        case WPLanguageDanish :
			result = [self isProductPurchased:gDanishPackID];
			break;
            
        case WPLanguageNorwegian :
			result = [self isProductPurchased:gNorwegianPackID];
			break;
            
        case WPLanguageSwedish :
			result = [self isProductPurchased:gSwedishPackID];
			break;
            
        case WPLanguageFinnish :
			result = [self isProductPurchased:gFinnishPackID];
			break;
            
		case WPLanguageEnglishUS :
		case WPLanguageEnglishUK :
			result = [self isProductPurchased:gEnglishPackID];
			break;
    }
	return result;
}

+ (void) setLanguagePackPurchased:(NSInteger)langID
{
	switch ( langID )
	{
		case WPLanguageGerman :
			[self setProductPurchased:gGermanPackID];
			break;
			
		case WPLanguageFrench :
			[self setProductPurchased:gFrenchPackID];
			break;
			
		case WPLanguageSpanish :
			[self setProductPurchased:gSpanishPackID];
			break;
			
		case WPLanguagePortuguese :
		case WPLanguageBrazilian :
			[self setProductPurchased:gPortuguesePackID];
			break;
			
		case WPLanguageDutch :
			[self setProductPurchased:gDutchPackID];
			break;
			
		case WPLanguageItalian :
			[self setProductPurchased:gItalianPackID];
			break;
			            
        case WPLanguageDanish :
			[self setProductPurchased:gDanishPackID];
			break;
            
        case WPLanguageNorwegian :
			[self setProductPurchased:gNorwegianPackID];
			break;
            
        case WPLanguageSwedish :
			[self setProductPurchased:gSwedishPackID];
			break;
            
        case WPLanguageFinnish :
			[self setProductPurchased:gFinnishPackID];
			break;
      
		case WPLanguageEnglishUS :
		case WPLanguageEnglishUK :
			[self setProductPurchased:gEnglishPackID];
			break;
    }
}

// call this function to check if the user has already purchased your feature
+ (BOOL) isProductPurchased:(NSString*) featureId
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:featureId];
}

+ (void) setProductPurchased:(NSString *)featureId
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:featureId];		
    [[NSUserDefaults standardUserDefaults] synchronize];    
}

- (void) buyLanguagePack:(NSInteger)langID
{
	switch ( langID )
	{
		case WPLanguageGerman :
			[self buyProduct:gGermanPackID];
			break;
			
		case WPLanguageFrench :
			[self buyProduct:gFrenchPackID];
			break;
			
		case WPLanguageSpanish :
			[self buyProduct:gSpanishPackID];
			break;
			
		case WPLanguagePortuguese :
		case WPLanguageBrazilian :
			[self buyProduct:gPortuguesePackID];
			break;
			
		case WPLanguageDutch :
			[self buyProduct:gDutchPackID];
			break;
			
		case WPLanguageItalian :
			[self buyProduct:gItalianPackID];
			break;
			
        case WPLanguageDanish :
			[self buyProduct:gDanishPackID];
			break;
            
        case WPLanguageNorwegian :
			[self buyProduct:gNorwegianPackID];
			break;
            
        case WPLanguageSwedish :
			[self buyProduct:gSwedishPackID];
			break;
            
        case WPLanguageFinnish :
			[self buyProduct:gFinnishPackID];
			break;
  
		case WPLanguageEnglishUS :
		case WPLanguageEnglishUK :
			[self buyProduct:gEnglishPackID];
			break;
    }
}


- (NSArray*) purchasableObjectsDescription
{
	if ( [self.purchasableObjects count] < 1 )
		return nil;
	
	NSMutableArray *productDescriptions = [[NSMutableArray alloc] initWithCapacity:[self.purchasableObjects count]];
	
	for ( int i = 0;i < [self.purchasableObjects count];i++ )
	{
		SKProduct *product = [self.purchasableObjects objectAtIndex:i];
		
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
		[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		[numberFormatter setLocale:product.priceLocale];
		NSString *formattedString = [numberFormatter stringFromNumber:product.price];
		[numberFormatter release];
		
		// you might probably need to change this line to suit your UI needs
		NSString *description = [NSString stringWithFormat:@"%@ (%@)",[product localizedTitle], formattedString];
		NSLog(@"Product %d - %@", i, description);
		[productDescriptions addObject:[NSDictionary dictionaryWithObjectsAndKeys:description, @"title", 
										product.localizedDescription, @"description", product.productIdentifier, @"id", nil]];
	}
	
	[productDescriptions autorelease];
	return (NSArray *)productDescriptions;
}

- (void) restorePreviousTransactions
{
    if ( [self isBusy] )
        return;
	if ([SKPaymentQueue canMakePayments])
	{
		[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
		requestingData = YES;
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"In-App Purchasing disabled", @"")
														message:NSLocalizedString(@"Check your AppStore settings and try again.", @"")
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
											  otherButtonTitles:nil];
		[alert show];
		[alert release];		
	}
}

- (void) buyProduct:(NSString*) featureId
{
    if ( [self isBusy] )
        return;
	if ([SKPaymentQueue canMakePayments])
	{
        for ( int i = 0; i < [self.purchasableObjects count]; i++ )
        {
            SKProduct * product = [self.purchasableObjects objectAtIndex:i];
            if ( [featureId caseInsensitiveCompare:product.productIdentifier] == NSOrderedSame )
            {            
                SKPayment *payment = [SKPayment paymentWithProduct:product];
                [[SKPaymentQueue defaultQueue] addPayment:payment];
                requestingData = YES;
                return;
            }
        }
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"In-App Purchasing Error", @"")
														message:NSLocalizedString(@"This product is currently unavailable, please try again later.", @"")
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
											  otherButtonTitles:nil];
		[alert show];
		[alert release];		
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"In-App Purchasing disabled", @"")
														message:NSLocalizedString(@"Check your AppStore settings and try again.", @"")
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}


#pragma mark In-App purchases callbacks
// In most cases you don't have to touch these methods
- (void) provideContent:(NSString*)productIdentifier forReceipt:(NSData*) receiptData  isNew:(BOOL)newTransaction
{	
	// if ( [productIdentifier caseInsensitiveCompare:_productID] == NSOrderedSame )
	{
		requestingData = NO;
        [WritePadStoreManager setProductPurchased:productIdentifier];
		if ( delegate && [delegate respondsToSelector:@selector(productPurchased:storeManager:)])
		{
			[delegate productPurchased:productIdentifier storeManager:self];	
		}
		if ( ! newTransaction )
		{
            NSLog( @"The Language Pack has been already purchased." );
		}	
	}
}

- (void) restoreTransactionsCompleted:(NSArray *)transactions withError:(NSError *)error
{
	requestingData = NO;
	if ( error == nil )
	{
        for ( SKPaymentTransaction * transaction in transactions )
        {
            if ( ![WritePadStoreManager isProductPurchased:transaction.payment.productIdentifier] )
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Can't restore purchase", @"")
                                                                message:NSLocalizedString(@"The Language Pack has not been purchased yet; Touch the Buy button to purchase Language Pack.", @"")
                                                               delegate:nil 
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                      otherButtonTitles: nil];
                [alert show];
                [alert release];		 
                return;
            }
            if ( delegate && [delegate respondsToSelector:@selector(productPurchased:storeManager:)])
            {
                [delegate productPurchased:transaction.payment.productIdentifier storeManager:self];	
            }
        }
	}
	else if ( error != nil )
	{
		NSLog( @"%@", error );
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"In-App Purchasing Error", @"")
														message:[error localizedDescription]
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
											  otherButtonTitles: nil];
		[alert show];
		[alert release];
	}
}

- (void) transactionCanceled: (SKPaymentTransaction *)transaction
{
	NSLog(@"User cancelled transaction: %@", [transaction description]);
	
	requestingData = NO;
	if(delegate && [delegate respondsToSelector:@selector(transactionCanceled:)])
	{
		[delegate transactionCanceled:self];
	}
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
	requestingData = NO;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[transaction.error localizedFailureReason] 
													message:[transaction.error localizedRecoverySuggestion]
												   delegate:nil 
										  cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
										  otherButtonTitles: nil];
	[alert show];
	[alert release];
}


@end

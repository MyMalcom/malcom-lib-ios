//
//  MPStore.h
//  MoPub
//
//  Created by Andrew He on 2/6/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface MPStore : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
	// Whether the store is currently processing an in-app purchase.
	// Note: this class is not thread-safe.
	BOOL _isProcessing;
	
	// The amount of product desired for the current purchase.
	NSInteger _quantity;
}

/*
 * Gets the singleton store object.
 */
+ (MPStore *)sharedStore;

/*
 * Begins listening for in-app purchase transactions.
 */
+ (void)beginObservingTransactions;

/*
 * Stops listening for in-app purchase transactions.
 */
+ (void)stopObservingTransactions;

/*
 * Begins an in-app purchase given the product identifier and the desired quantity.
 */
- (void)initiatePurchaseForProductIdentifier:(NSString *)identifier quantity:(NSInteger)quantity;

@end


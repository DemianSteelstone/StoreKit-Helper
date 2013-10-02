//
//  StoreKitPaymentQueue.h
//  StoreKitHelper
//
//  Created by Evgeny Rusanov on 24.01.13.
//  Copyright (c) 2013 Evgeny Rusanov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <StoreKit/StoreKit.h>
#import "StoreKit_Product.h"

@interface StoreKitPaymentQueue : NSObject <SKPaymentTransactionObserver>

+(StoreKitPaymentQueue*)instance;

-(void)buyProduct:(StoreKit_Product*)product complete:(void (^)(NSError* error))complete;
-(void)restorePurchases:(void (^)(NSString *identifer))purchaseRestored finishHandler:(void (^)(NSError *error))finishHandler;

@end

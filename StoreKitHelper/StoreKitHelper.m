//
//  StoreKitHelper.m
//  mydiet
//
//  Created by Evgeny Rusanov on 20.08.13.
//  Copyright (c) 2013 Evgeny Rusanov. All rights reserved.
//

#import "StoreKitHelper.h"

#import "ProductsRequest.h"
#import "Product.h"
#import "StoreKitPaymentQueue.h"

@implementation StoreKitHelper

+(void)buyFeature:(NSString*)identifier completitionBlock:(void (^)(NSError* error))block
{
    [StoreKitPaymentQueue instance];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        ProductsRequest *request = [[ProductsRequest alloc] initWithIdentifiers:[NSSet setWithObject:identifier]];
        [request requestProductsCompletitionBlock:^(NSArray *products, NSArray *invalid) {
            if (products.count)
            {
                Product *product = products[0];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [product buy:^(NSError *error) {
                        block(error);
                    }];
                });
            }
            else
            {
                NSError *error = [NSError errorWithDomain:@"StoreKitHelperDomain"
                                                     code:1
                                                 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Invalid product identifier", @"")}];
                block(error);
            }
        }];
    });
}

+(void)restorePurchases:(void (^)(NSString *identifer))purchaseRestored finishHandler:(void (^)(NSError *error))finishHandler
{
    [[StoreKitPaymentQueue instance] restorePurchases:purchaseRestored finishHandler:finishHandler];
}

@end

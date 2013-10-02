//
//  StoreKit_Product.m
//  StoreKitHelper
//
//  Created by Evgeny Rusanov on 24.01.13.
//  Copyright (c) 2013 Evgeny Rusanov. All rights reserved.
//

#import "StoreKit_Product.h"

#import "StoreKitPaymentQueue.h"

@implementation StoreKit_Product
{
    SKProduct *product;
    
    id context;
}

-(id)initWithProduct:(SKProduct*)product_
{
    if (self = [super init])
    {
        product = product_;
    }
    
    return self;
}

-(SKProduct*)sk_product
{
    return product;
}

-(NSString*)title
{
    return product.localizedTitle;
}

-(NSString*)description
{
    return product.localizedDescription;
}

-(NSString*)identifier
{
    return product.productIdentifier;
}

-(NSString*)price
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:product.price];
    
    return formattedString;
}

-(void)buy:(void (^)(NSError *))complete
{
    context = self;
    [[StoreKitPaymentQueue instance] buyProduct:self
                                       complete:^(NSError *error) {
                                           complete(error);
                                           context = nil;
                                       }];
}

@end

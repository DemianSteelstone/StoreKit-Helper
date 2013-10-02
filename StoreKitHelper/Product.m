//
//  Product.m
//  StoreKitHelper
//
//  Created by Evgeny Rusanov on 24.01.13.
//  Copyright (c) 2013 Evgeny Rusanov. All rights reserved.
//

#import "Product.h"
#import "PurchaseHistory.h"

@implementation Product

-(void)buy:(void (^)(NSError* error))complete
{
    
}

-(BOOL)isPurchased
{
    return [PurchaseHistory productPurchased:self];
}

@end

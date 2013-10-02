//
//  PurchaseHistory.m
//  StoreKitHelper
//
//  Created by Evgeny Rusanov on 24.01.13.
//  Copyright (c) 2013 Evgeny Rusanov. All rights reserved.
//

#import "PurchaseHistory.h"

@implementation PurchaseHistory

+(PurchaseHistory*)instance
{
    static PurchaseHistory* inst = nil;
    
    if (!inst)
        inst = [[PurchaseHistory alloc] init];
    
    return inst;
}

+(NSString*)generateKey:(NSString*)identifier
{
    return [NSString stringWithFormat:@"PurchaseHistory_%@",identifier];
}

+(BOOL)featurePurchased:(NSString*)identifier
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:[self generateKey:identifier]];
}

+(BOOL)productPurchased:(Product*)product
{
    return [PurchaseHistory featurePurchased:product.identifier];
}

+(void)recordProductPurchase:(Product*)product
{
    [PurchaseHistory recordPurchase:product.identifier];
}

+(void)recordPurchase:(NSString*)identifier
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[self generateKey:identifier]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

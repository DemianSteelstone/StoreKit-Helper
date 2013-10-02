//
//  PurchaseHistory.h
//  StoreKitHelper
//
//  Created by Evgeny Rusanov on 24.01.13.
//  Copyright (c) 2013 Evgeny Rusanov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Product.h"

@interface PurchaseHistory : NSObject

+(PurchaseHistory*)instance;

+(BOOL)featurePurchased:(NSString*)identifier;
+(BOOL)productPurchased:(Product*)product;

+(void)recordProductPurchase:(Product*)product;
+(void)recordPurchase:(NSString*)identifier;

@end

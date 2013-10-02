//
//  StoreKit_Product.h
//  StoreKitHelper
//
//  Created by Evgeny Rusanov on 24.01.13.
//  Copyright (c) 2013 Evgeny Rusanov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <StoreKit/StoreKit.h>
#import "Product.h"

@interface StoreKit_Product : Product

-(id)initWithProduct:(SKProduct*)product;

-(SKProduct*)sk_product;

@end

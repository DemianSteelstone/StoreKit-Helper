//
//  ProductsRequest.h
//  StoreKitHelper
//
//  Created by Evgeny Rusanov on 24.01.13.
//  Copyright (c) 2013 Evgeny Rusanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface ProductsRequest : NSObject <SKProductsRequestDelegate>

-(id)initWithIdentifiers:(NSSet*)identifiers;

+(NSSet*)productsIdentifiersFromPlist:(NSString*)name;
-(void)requestProductsCompletitionBlock:(void(^)(NSArray* products, NSArray* invalid))completitionBlock;

@end

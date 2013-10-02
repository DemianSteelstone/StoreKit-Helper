//
//  Product.h
//  StoreKitHelper
//
//  Created by Evgeny Rusanov on 24.01.13.
//  Copyright (c) 2013 Evgeny Rusanov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Product : NSObject

@property (nonatomic,strong,readonly) NSString *identifier;
@property (nonatomic,strong,readonly) NSString *title;
@property (nonatomic,strong,readonly) NSString *description;
@property (nonatomic,strong,readonly) NSString *price;
@property (nonatomic, readonly) BOOL isPurchased;

-(void)buy:(void (^)(NSError* error))complete;

@end

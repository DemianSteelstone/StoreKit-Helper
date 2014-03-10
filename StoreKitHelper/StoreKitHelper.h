//
//  StoreKitHelper.h
//  mydiet
//
//  Created by Evgeny Rusanov on 20.08.13.
//  Copyright (c) 2013 Evgeny Rusanov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StoreKitHelper : NSObject

+(void)appDidFinishLaunching;

+(void)buyFeature:(NSString*)identifier completitionBlock:(void (^)(NSError* error))block;
+(void)restorePurchases:(void (^)(NSString *identifer))purchaseRestored finishHandler:(void (^)(NSError *error))finishHandler;

@end

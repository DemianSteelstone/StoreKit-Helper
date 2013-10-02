//
//  ProductsRequest.m
//  StoreKitHelper
//
//  Created by Evgeny Rusanov on 24.01.13.
//  Copyright (c) 2013 Evgeny Rusanov. All rights reserved.
//

#import "ProductsRequest.h"

#import "StoreKit_Product.h"

@implementation ProductsRequest
{
    void (^completeBlock)(NSArray* products, NSArray *invalid);
    id _context;
    NSSet *_identifiers;
    
    SKProductsRequest *request;
}

-(id)initWithIdentifiers:(NSSet*)identifiers
{
    if (self = [super init])
    {
        _identifiers = identifiers;
    }
    return self;
}

+(NSSet*)productsIdentifiersFromPlist:(NSString*)name
{
    NSArray *array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:@"plist"]];
    return [NSSet setWithArray:array];
}

-(void)requestProductsCompletitionBlock:(void(^)(NSArray* products, NSArray* invalid))completitionBlock
{
    _context = self;
    completeBlock = [completitionBlock copy];
    
    request = [[SKProductsRequest alloc] initWithProductIdentifiers:_identifiers];
    request.delegate = self;
    [request start];
}

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSMutableArray *products = [NSMutableArray array];
    
    for (SKProduct *product in response.products)
    {
        [products addObject:[[StoreKit_Product alloc] initWithProduct:product]];
    }
    
    completeBlock(products,response.invalidProductIdentifiers);
    dispatch_async(dispatch_get_main_queue(), ^{
        _context = nil;
    });
}

-(void)dealloc
{
    
}

@end

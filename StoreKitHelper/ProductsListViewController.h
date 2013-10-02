//
//  ProductsListViewController.h
//  StoreKitHelper
//
//  Created by Evgeny Rusanov on 24.01.13.
//  Copyright (c) 2013 Evgeny Rusanov. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Product.h"

@interface ProductsListViewController : UITableViewController

@property (nonatomic, strong) NSSet *productsIdentifiers;
@property (nonatomic, copy) void (^productBuyedHandler)(Product *product);

@end

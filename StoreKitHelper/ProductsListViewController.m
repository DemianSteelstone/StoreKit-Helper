//
//  ProductsListViewController.m
//  StoreKitHelper
//
//  Created by Evgeny Rusanov on 24.01.13.
//  Copyright (c) 2013 Evgeny Rusanov. All rights reserved.
//

#import "ProductsListViewController.h"

#import "ProductsRequest.h"
#import "Product.h"
#import "StoreKitPaymentQueue.h"

#import "MBProgressHUD.h"

@implementation ProductsListViewController
{
    NSArray *_products;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Catalog", @"");
    self.tableView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    self.tableView.backgroundView = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_products)
    {
        [self requestProducts];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

-(void)requestProducts
{
    self.tableView.scrollEnabled = NO;
    [MBProgressHUD showHUDAddedTo:self.tableView animated:NO];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        ProductsRequest *request = [[ProductsRequest alloc] initWithIdentifiers:self.productsIdentifiers];
        [request requestProductsCompletitionBlock:^(NSArray *products, NSArray *invalid) {
            _products = products;
            [self.tableView reloadData];
            
            self.tableView.scrollEnabled = YES;
            [MBProgressHUD hideHUDForView:self.tableView animated:YES];
        }];
    });
}

-(void)buyProduct:(Product*)product
{
    UIWindow *wnd = [[UIApplication sharedApplication].delegate window];
    [MBProgressHUD showHUDAddedTo:wnd animated:NO];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [product buy:^(NSError *error) {
            [MBProgressHUD hideHUDForView:wnd animated:YES];
            if (error)
            {
                if (error.code!=SKErrorPaymentCancelled)
                {
                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
                                                message:error.localizedDescription
                                               delegate:nil
                                      cancelButtonTitle:NSLocalizedString(@"Ok", @"")
                                      otherButtonTitles:nil] show];
                }
            }
            else
            {
                self.productBuyedHandler(product);
                [self reloadProductRowWithIdentifier:product.identifier];
            }
        }];
    });
}

-(void)reloadProductRowWithIdentifier:(NSString*)identifier
{
    int index = 0;
    BOOL found = NO;
    for (index=0; index<_products.count; index++)
    {
        if ([[_products[index] identifier] isEqualToString:identifier])
        {
            found = YES;
            break;
        }
    }
    
    if (found)
    {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_products)
        return 2;
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return _products.count;
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView productCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"productCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:cellIdentifier];
        
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    }
    
    Product *product = _products[indexPath.row];
    
    cell.textLabel.text = product.title;
    if (product.isPurchased)
        cell.detailTextLabel.text = NSLocalizedString(@"get", @"");
    else
        cell.detailTextLabel.text = product.price;
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return [self tableView:tableView productCellForRowAtIndexPath:indexPath];
    
    static NSString *cellIdentifier = @"restoreCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
        
        cell.textLabel.text = NSLocalizedString(@"Restore purchases", @"");
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
     return NO;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section==0)
        [self buyProduct:_products[indexPath.row]];
    else
    {
        UIWindow *wnd = [[UIApplication sharedApplication].delegate window];
        [MBProgressHUD showHUDAddedTo:wnd animated:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[StoreKitPaymentQueue instance] restorePurchases:^(NSString *identifer) {
                [self reloadProductRowWithIdentifier:identifer];
            } finishHandler:^(NSError *error){
                [MBProgressHUD hideHUDForView:wnd animated:YES];
                if (error)
                {
                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
                                                message:error.localizedDescription
                                               delegate:nil
                                      cancelButtonTitle:NSLocalizedString(@"Ok", @"")
                                      otherButtonTitles:nil] show];
                }
            }];
        });
    }
}

@end

//
//  StoreKitPaymentQueue.m
//  StoreKitHelper
//
//  Created by Evgeny Rusanov on 24.01.13.
//  Copyright (c) 2013 Evgeny Rusanov. All rights reserved.
//

#import "StoreKitPaymentQueue.h"

#import "PurchaseHistory.h"

@implementation StoreKitPaymentQueue
{
    NSMutableDictionary *currentProductsCompletitionHandlers;
    
    void (^restorePurchaseHandler)(NSString* identifier);
    void (^restoreFinishHandler)(NSError* error);
}

+(StoreKitPaymentQueue*)instance
{
    static dispatch_once_t onceToken;
    static StoreKitPaymentQueue *instance = nil;
    
    dispatch_once(&onceToken, ^{
        if (!instance)
            instance = [[StoreKitPaymentQueue alloc] init];
    });
    
    return instance;
}

-(id)init
{
    if (self = [super init])
    {
        currentProductsCompletitionHandlers = [NSMutableDictionary dictionary];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

#pragma mark -

-(void)provideContent:(NSString*)identifier
{
    void (^handler)(NSError* error) = currentProductsCompletitionHandlers[identifier];
    if (handler)
        handler(nil);
}

- (void) completePurchase:(NSString*)identifier
{
    [PurchaseHistory recordPurchase:identifier];
    [self provideContent:identifier];
    
    if (restorePurchaseHandler)
        restorePurchaseHandler(identifier);
}

-(void)failedWithError:(NSError*)error identifer:(NSString*)identifier
{
    void (^handler)(NSError* error) = currentProductsCompletitionHandlers[identifier];
    if (handler)
        handler(error);
    [currentProductsCompletitionHandlers removeObjectForKey:identifier];
}

#pragma mark - SKTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
            case SKPaymentTransactionStateRestored:
            {
                if (transaction.downloads.count>0)
                    [[SKPaymentQueue defaultQueue] startDownloads:transaction.downloads];
                else
                {
                    [self completePurchase:transaction.payment.productIdentifier];
                    [queue finishTransaction:transaction];
                }

            }
                break;
            case SKPaymentTransactionStateFailed:
                [self failedWithError:transaction.error identifer:transaction.payment.productIdentifier];
                [queue finishTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    restoreFinishHandler(error);
    
    restorePurchaseHandler = nil;
    restoreFinishHandler = nil;
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    restoreFinishHandler(nil);
    
    restorePurchaseHandler = nil;
    restoreFinishHandler = nil;
}

-(void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads
{
    for (SKDownload *download in downloads)
    {
        switch (download.downloadState) {
            case SKDownloadStateFinished:
            {
                NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
                
                NSString *path = [download.contentURL path];
                path = [path stringByAppendingPathComponent:@"Contents"];
                
                path = [path stringByAppendingPathComponent:@"key.txt"];
                
                NSString *key = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
                
                if ([key isEqualToString:bundleId])
                    [self completePurchase:download.transaction.payment.productIdentifier];
                
                [queue finishTransaction:download.transaction];
            }
                break;
            case SKDownloadStateFailed:
            {
                [self failedWithError:download.error identifer:download.transaction.payment.productIdentifier];
                [queue finishTransaction:download.transaction];
            }
                break;
            case SKDownloadStateCancelled:
            {
                [self failedWithError:[NSError errorWithDomain:@"StoreKitPaymentQueueDomain" code:-2 userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Canceled", @"")}]
                            identifer:download.transaction.payment.productIdentifier];
                [queue finishTransaction:download.transaction];
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark - Interface

-(void)buyProduct:(StoreKit_Product*)product complete:(void (^)(NSError* error))complete
{
    if ([product isPurchased])
    {
        complete(nil);
    }
    else if ([SKPaymentQueue canMakePayments])
    {
        currentProductsCompletitionHandlers[product.identifier] = [complete copy];
                
        SKPayment *payment = [SKPayment paymentWithProduct:product.sk_product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
    else
    {
        NSError *error = [NSError errorWithDomain:@"StoreKitPaymentQueueDomain"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Can't make payments", @"")}];
        complete(error);
    }
}

-(void)restorePurchases:(void (^)(NSString *identifer))purchaseRestored finishHandler:(void (^)(NSError *error))finishHandler
{
    restorePurchaseHandler = [purchaseRestored copy];
    restoreFinishHandler = [finishHandler copy];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

@end

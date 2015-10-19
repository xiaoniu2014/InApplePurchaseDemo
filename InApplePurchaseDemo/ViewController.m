//
//  ViewController.m
//  InApplePurchaseDemo
//
//  Created by hw on 15/10/16.
//  Copyright © 2015年 hongw. All rights reserved.
//

#import "ViewController.h"
#import <StoreKit/StoreKit.h>

@interface ViewController ()<SKProductsRequestDelegate,SKPaymentTransactionObserver>

@property (nonatomic,strong) SKProductsRequest *productsRequest;
@property (nonatomic,strong) UITextField *textField;
@property (nonatomic,strong) UIAlertController *alertController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

- (IBAction)pay:(UIButton *)sender {
    [self buyProduct:@"com.kaiying.oa.yuer"];
}

- (void)buyProduct:(NSString *)productIdentifier{
    if ([SKPaymentQueue canMakePayments]) {
        NSSet *productIdentifiers = [NSSet setWithObject:productIdentifier];
        self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
        self.productsRequest.delegate = self;
        [self.productsRequest start];
    }else{
        NSLog(@"In Apple Purchase 不能用");
    }
}


//获取产品信息
#pragma -mark SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    NSLog(@"Loaded list of products...");
    self.productsRequest = nil;
    NSArray *products = response.products;
    if (products.count > 0) {
        SKProduct *product = products[0];
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }else{
        NSLog(@"无法获取产品信息,购买失败");
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"Failed to load list of products.error:%@", error.description);
    self.productsRequest = nil;
}

#pragma -mark SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions{
    
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
                
            default:
                break;
        }
    }
}


- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"completeTransaction...");
    NSString * productIdentifier = transaction.payment.productIdentifier;
    NSLog(@"==%@",productIdentifier);
    if (productIdentifier.length > 0) {
        [self provideContentForTransaction:transaction];
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled){
        NSLog(@"购买失败===%@",transaction.error.localizedDescription);
    }else{
        NSLog(@"用户取消交易");
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"restoreTransaction...");
    
    [self provideContentForTransaction:transaction];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)provideContentForTransaction:(SKPaymentTransaction *)transaction{
    //对于已购买商品,处理回复购买的逻辑
    NSLog(@"提供商品");
    
}

- (void)dealloc
{
    NSLog(@"remove transaction observer...");
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

@end

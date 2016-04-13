//
//  ZBBQRCodeManager.h
//  ZBBQRCodeDemo
//
//  Created by zhangbinbin on 16/4/11.
//  Copyright © 2016年 zhangbinbin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^QRCodeBlock)(NSArray*);

@interface ZBBQRCodeManager : NSObject

+ (void) createQRCode:(NSDictionary*)input callback:(QRCodeBlock)callback;

+ (void) qrcodeImage:(UIImage*)image callback:(QRCodeBlock)callback;


@end

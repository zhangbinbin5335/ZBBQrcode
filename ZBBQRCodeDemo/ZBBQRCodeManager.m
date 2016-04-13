//
//  ZBBQRCodeManager.m
//  ZBBQRCodeDemo
//
//  Created by zhangbinbin on 16/4/11.
//  Copyright © 2016年 zhangbinbin. All rights reserved.
//

#import "ZBBQRCodeManager.h"
#import "ZXingObjC.h"

@implementation ZBBQRCodeManager

+ (void) createQRCode:(NSDictionary*)input callback:(QRCodeBlock)callback
{
    NSString* code = input[@"code"];//根据code生成二维码
    CGFloat width = [input[@"width"]floatValue];//和imageview的宽高一直
    CGFloat height = [input[@"height"]floatValue];
    
    // 生成二维码图片
    CIImage *qrcodeImage;
    NSData *data = [code dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:false];
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    [filter setValue:data forKey:@"inputMessage"];
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];
    qrcodeImage = [filter outputImage];
    
    // 消除模糊
    CGFloat scaleX = width / qrcodeImage.extent.size.width; // extent 返回图片的frame
    CGFloat scaleY = height / qrcodeImage.extent.size.height;
    CIImage *transformedImage = [qrcodeImage imageByApplyingTransform:CGAffineTransformScale(CGAffineTransformIdentity, scaleX, scaleY)];
    
    NSString *outputFielPath = [NSTemporaryDirectory() stringByAppendingString:@"qrcode.png"];
    
    CIContext* context = [CIContext contextWithOptions:nil];
    CGImageRef imageRef = [context createCGImage:transformedImage fromRect:transformedImage.extent];
    UIImage* image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    UIImage *logoImage = [UIImage imageNamed:@"logo_qrcode"];
    CGFloat logoW = 80;
    CGFloat logoH = 80;
    CGFloat logoX = (image.size.width - logoW) * 0.5;
    CGFloat logoY = (image.size.height - logoH) * 0.5;
    [logoImage drawInRect:CGRectMake(logoX, logoY, logoW, logoH)];
    UIImage *qrImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData* imageData = UIImagePNGRepresentation(qrImage);
    [imageData writeToFile:outputFielPath atomically:NO];
    callback(@[outputFielPath]);
}

+ (void) qrcodeFeaturePath:(NSString*)path callback:(QRCodeBlock)callback
{
    [self featureQrcodeWithPath:path callback:callback];
}

+(void)featureQrcodeWithPath:(NSString*)path callback:(QRCodeBlock)callback
{
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    [self qrcodeImage:image callback:callback];
}

+(void)qrcodeImage:(UIImage *)image callback:(QRCodeBlock)callback
{
    CGImageRef imageToDecode = image.CGImage;  // Given a CGImage in which we are looking for barcodes
    
    BOOL err = YES;
    NSString* message = @"错了";
    
    if (!imageToDecode)
    {
        callback(@[
                   @{
                       @"err":[NSNumber numberWithBool:err],
                       @"message":message
                       }]);
        return;
    }
    
    ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:imageToDecode] ;
    ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
    
    NSError *error = nil;
    
    // There are a number of hints we can give to the reader, including
    // possible formats, allowed lengths, and the string encoding.
    ZXDecodeHints *hints = [ZXDecodeHints hints];
    hints.tryHarder = YES;
//    hints.pureBarcode = YES;
    
    ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
    ZXResult *result = [reader decode:bitmap
                                hints:hints
                                error:&error];
    if (result)
    {
        
        // The barcode format, such as a QR code or UPC-A
        ZXBarcodeFormat format = result.barcodeFormat;
        NSString *contents = result.text;
        
        if (format == kBarcodeFormatQRCode)
        {
            err = NO;
            message = contents;
        }
        
        // The coded result as a string. The raw data can be accessed with
        // result.rawBytes and result.length.
    }
    
    callback(@[
               @{
                   @"err":[NSNumber numberWithBool:err],
                   @"message":message
                   }]);
}

-(void)sysQrcodeFeaturePath:(NSString*)path callback:(QRCodeBlock)callback
{
    BOOL err;
    NSString* message = @"错了";
    
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    CIImage* ciimage = [CIImage imageWithCGImage:image.CGImage];
    
    if (ciimage)
    {
        CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:[CIContext contextWithOptions:nil] options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
        
        NSArray* result = [detector featuresInImage:ciimage];
        
        if (result.count > 0)
        {
            CIQRCodeFeature* feature = result[0];
            
            if ([feature.type isEqualToString:CIFeatureTypeQRCode])
            {
                err = NO;
                message = feature.messageString;
            }
            else
            {
                err = YES;
            }
        }
        else
        {
            err = YES;
        }
    }
    callback(@[
               @{
                   @"err":[NSNumber numberWithBool:err],
                   @"message":message
                   }]);
    
}

- (UIImage *)fixOrientation:(UIImage *)srcImg {
    if (srcImg.imageOrientation == UIImageOrientationUp) {
        return srcImg;
    }
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (srcImg.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (srcImg.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, srcImg.size.width, srcImg.size.height, CGImageGetBitsPerComponent(srcImg.CGImage), 0, CGImageGetColorSpace(srcImg.CGImage), CGImageGetBitmapInfo(srcImg.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (srcImg.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.height,srcImg.size.width), srcImg.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.width,srcImg.size.height), srcImg.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}









@end

//
//  ViewController.m
//  ZBBQRCodeDemo
//
//  Created by zhangbinbin on 16/4/11.
//  Copyright © 2016年 zhangbinbin. All rights reserved.
//

#import "ViewController.h"
#import "ZBBQRCodeManager.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *qrImageView;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)generate:(id)sender {
    
    [ZBBQRCodeManager createQRCode:@{@"code":@"今天星期一！",
                                     @"width":@50,
                                     @"height":@50}
     
                          callback:^(NSArray *result) {
                              
                              self.qrImageView.image = [UIImage imageWithContentsOfFile:result[0]];
    }];
}
- (IBAction)read:(id)sender {
    
    __weak ViewController* weakSelf = self;
    [ZBBQRCodeManager qrcodeImage:self.qrImageView.image callback:^(NSArray *result) {
        
        NSDictionary* dic = result[0];
        
        NSString* text;
        if ([dic[@"err"]boolValue])
        {
            text = @"解析失败！";
        }
        else
        {
            text = dic[@"message"];
        }
        
        weakSelf.label.text = text;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

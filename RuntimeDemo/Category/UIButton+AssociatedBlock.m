//
//  UIButton+AssociatedBlock.m
//  MetaClassRelativeDemo
//
//  Created by 杨强 on 9/5/2019.
//  Copyright © 2019 杨强. All rights reserved.
//

#import "UIButton+AssociatedBlock.h"
#import <objc/runtime.h>

static const char btnKey;

@implementation UIButton (AssociatedBlock)

//将block和btn关联起来
- (void)handleWithBlock:(BtnTestBlock)block {
    if (block) {
        objc_setAssociatedObject(self, &btnKey, block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    [self addTarget:self action:@selector(btnClicked) forControlEvents:(UIControlEventTouchUpInside)];
}

- (void)btnClicked {
    BtnTestBlock block = objc_getAssociatedObject(self, &btnKey);
    block();
}

@end

//
//  UILabel+AssociatedObject.m
//  MetaClassRelativeDemo
//
//  Created by 杨强 on 9/5/2019.
//  Copyright © 2019 杨强. All rights reserved.
//

#import "UILabel+AssociatedObject.h"
#import <objc/runtime.h>

static const char flashColorKey;

@implementation UILabel (AssociatedObject)

- (void)setFlashColor:(UIColor *)color {
    objc_setAssociatedObject(self, &flashColorKey, color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)getFlashColor {
    return objc_getAssociatedObject(self, &flashColorKey);
}

@end

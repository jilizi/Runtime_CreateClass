//
//  UILabel+AssociatedObject.h
//  MetaClassRelativeDemo
//
//  Created by 杨强 on 9/5/2019.
//  Copyright © 2019 杨强. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
//类别,为UILabel添加属性 (即setter&getter方法)
@interface UILabel (AssociatedObject)

- (void)setFlashColor:(UIColor *)color;

- (UIColor *)getFlashColor;

@end

NS_ASSUME_NONNULL_END

//
//  UIButton+AssociatedBlock.h
//  MetaClassRelativeDemo
//
//  Created by 杨强 on 9/5/2019.
//  Copyright © 2019 杨强. All rights reserved.
//

#import <UIKit/UIKit.h>

//将BtnTestBlock和UIButton关联起来
NS_ASSUME_NONNULL_BEGIN

typedef void(^BtnTestBlock)(void);

@interface UIButton (AssociatedBlock)

- (void)handleWithBlock:(BtnTestBlock)block;

@end

NS_ASSUME_NONNULL_END

//
//  MyClass.h
//  MetaClassRelativeDemo
//
//  Created by 杨强 on 9/5/2019.
//  Copyright © 2019 杨强. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyClass : NSObject

@property (nonatomic, strong) NSArray *array;
@property (nonatomic, copy) NSString *string;

- (void)method1;
- (void)method2;
+ (void)classMethod1;

@end

NS_ASSUME_NONNULL_END

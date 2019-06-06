//
//  ViewController.m
//  RuntimeDemo
//
//  Created by YQ on 2017/1/18.
//  Copyright © 2017年 杨强. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "text.h"
#import "MyClass.h"

@interface ViewController ()

@end

@implementation ViewController

static NSMutableDictionary *dicCustomerProperty;

//实例对象、类、元类等的关系
void TestMetaClass(id self, SEL _cmd) {
    
    [self setValue:@"zhang" forKey:@"name"];
    NSLog(@"This objcet is %p", self); // TestClass类的实例对象
    
    //获取类的名称
    const char *className1 = class_getName([self class]);
    const char *className2 = object_getClassName([self class]);
    NSString *className3 = NSStringFromClass([self class]);
    NSLog(@"ClassName is %s, %s, %@", className1, className2, className3);
    //获取类
    Class class1 = [self class];//调用实例对象的方法
    Class class2 = object_getClass(self);//根据实例对象获取类
    Class class3 = objc_getClass(className1);//根据类名获取类
    NSLog(@"Class is %p, %p, %p", class1, class2, class3);
    //父类
    Class superClass1 = class_getSuperclass(class1);
    Class superClass2 = [self superclass];
    NSLog(@"SupperClass is %p, %p", superClass1, superClass2);
    
    //获取元类
    Class metaClass = objc_getMetaClass(className1);
    
    //判断是否为元类
    BOOL isMetaClass = class_isMetaClass(metaClass);
    
    if (isMetaClass) {
        NSLog(@"%@ is meta class", metaClass);
    }
    NSLog(@"NSError's metaClass is %@", objc_getMetaClass(object_getClassName([NSError class])));
    NSLog(@"NSError's metaClass is %p", objc_getMetaClass(object_getClassName([NSError class])));
    NSLog(@"Class is %@, super class is %@, meta class is %@, metaclass's superclass is %@", [self class], [self superclass], metaClass, class_getSuperclass(metaClass));
    NSLog(@"Class is %p, super class is %p, meta class is %p, metaclass's superclass is %p", [self class], [self superclass], metaClass, class_getSuperclass(metaClass));
    //获取实例的大小
    size_t size = class_getInstanceSize(class1);
    NSLog(@"%zu",size);
    
}

id customGetter(id self, SEL _cmd) {
    if (!dicCustomerProperty) {
        dicCustomerProperty = [NSMutableDictionary new];
    }
    NSString *key = NSStringFromSelector(_cmd);
    return [dicCustomerProperty objectForKey:key];
}

void customSetter(id self, SEL _cmd, id newValue) {
    //移除set
    NSString *key = [NSStringFromSelector(_cmd) stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@""];
    //首字母小写
    NSString *head = [key substringWithRange:NSMakeRange(0, 1)];
    head = [head lowercaseString];
    key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:head];
    //移除后缀 ":"
    key = [key stringByReplacingCharactersInRange:NSMakeRange(key.length - 1, 1) withString:@""];
    
    if (dicCustomerProperty == nil) {
        dicCustomerProperty = [NSMutableDictionary new];
    }
    
    [dicCustomerProperty setObject:newValue forKey:key];
    
//    [dicCustomerProperty setValue:nil forKey:key];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self createNewClass];
    
    [[NSMutableArray array] setValue:nil forKey:@"age"];
    
//    [self testNSObject_MetaClass];
    
//    [self myClassTest];
    
}

- (void)testNSObject_MetaClass {
    NSObject *obj = [[NSObject alloc] init];
    NSLog(@"instance is %p", obj);
    Class objClass = [obj class];
    const char *className = class_getName([obj class]);
    Class objSuperClass = class_getSuperclass(objClass);
    Class metaClass = objc_getMetaClass(className);
    if (class_isMetaClass(metaClass)) {
        NSLog(@"%@ is meta class, %p", metaClass, metaClass);
    }
    NSLog(@"MetaClass name is %s", class_getName(metaClass));
    NSLog(@"Class is %p, super class is %p, meta class is %p, metaclass's superclass is %p", objClass, objSuperClass, metaClass, class_getSuperclass(metaClass));
}

//动态创建一个新类
- (void)createNewClass{

    Class newClass = [self createNewClass:"SubError"];
    //创建这个类的实例对象
//    id instance = [[newClass alloc] init];
    id instance = [[newClass alloc] initWithDomain:@"some domain" code:0 userInfo:nil];
//    //调用方法
//    [instance performSelector:@selector(TestMetaClass)];
    //设置成员变量值
    [instance setValue:@"张三" forKey:@"name"];
    //调用方法
    SEL sel = NSSelectorFromString(@"TestMetaClass"); // 获取定义的方法
    //这里报错, Build Setting -> apple clang preprocessing -> Enable Strict Checking of objc_msgSend Calls 设置成NO
    id result = objc_msgSend(instance,sel); //调用该方法
    NSLog(@"%@",result);
    
    //赋值属性age
    [instance setValue:@"20" forKey:@"age"];
    NSLog(@"age : %@", [instance valueForKey:@"age"]);
}

//创建的这个类继承于NSError
- (Class)createNewClass:(char *)className{
    //创建一个NSError的子类 SubError
    Class newClass = objc_allocateClassPair([NSError class], className, 0);
    //添加实例对象方法 IMP函数指针
    SEL sel = sel_registerName("TestMetaClass"); //注册一个方法选择器 不能重复注册同一个选择器
    class_addMethod(newClass, sel, (IMP)TestMetaClass, "v@:");
    //添加成员变量(_name)
    BOOL isSuccess = class_addIvar(newClass, "_name", sizeof(NSString *), log2(sizeof(NSString *)), @encode(NSString *));
    if (isSuccess) {
        NSLog(@"添加成员变量成功");
    }
    
    //添加属性(age)
    [self addStrPropertyForTargetClass:newClass key:@"age" value:nil];

    //注册这个类
    objc_registerClassPair(newClass);
    return newClass;
}

- (void)addStrPropertyForTargetClass:(id)target key:(NSString *)propertyName value:(id)value {
    //先判断有没有这个属性，没有就添加，有就返回
    Ivar ivar = class_getInstanceVariable([target class], [[NSString stringWithFormat:@"_%@", propertyName] UTF8String]);
    if (ivar) {
        return;
    }
    
    Class targetClass = [target class];
    
    objc_property_attribute_t type = { "T", [[NSString stringWithFormat:@"@\"%@\"",NSStringFromClass([NSString class])] UTF8String] }; //type
    objc_property_attribute_t ownership0 = { "C", "" }; // C = copy
    objc_property_attribute_t ownership = { "N", "" }; //N = nonatomic
    objc_property_attribute_t backingivar  = { "V", [[NSString stringWithFormat:@"_%@", propertyName] UTF8String] }; //variable name
    objc_property_attribute_t attrs[] = { type, ownership0, ownership, backingivar };
    
    BOOL addSuccess = class_addProperty(targetClass, [propertyName UTF8String], attrs, 4);
    if (addSuccess) {
        //添加get和set方法
        class_addMethod(targetClass, NSSelectorFromString(propertyName), (IMP)customGetter, "@@:");
        class_addMethod(targetClass, NSSelectorFromString([NSString stringWithFormat:@"set%@:",[propertyName capitalizedString]]), (IMP)customSetter, "v@:@");
        
        //赋值(value 不能为 nil)
//        [target setValue:value forKey:propertyName];
    } else {
        //
        class_replaceProperty(targetClass, [propertyName UTF8String], attrs, 4);
        //添加get和set方法
        class_addMethod(targetClass, NSSelectorFromString(propertyName), (IMP)customGetter, "@@:");
        class_addMethod(targetClass, NSSelectorFromString([NSString stringWithFormat:@"set%@:",[propertyName capitalizedString]]), (IMP)customSetter, "v@:@");
        
        //赋值(value 不能为 nil)
//        [target setValue:value forKey:propertyName];
    }
}

//- (void)myClassTest {
//    MyClass *myClass = [[MyClass alloc] init];
//    unsigned int outCount = 0;
//    Class cls = myClass.class;
//    // 类名
//    NSLog(@"class name: %s", class_getName(cls));
//    NSLog(@"==========================================================");
//    // 父类
//    NSLog(@"super class name: %s", class_getName(class_getSuperclass(cls)));
//    NSLog(@"==========================================================");
//    // 是否是元类
//    NSLog(@"MyClass is %@ a meta-class", (class_isMetaClass(cls) ? @"" : @"not"));
//    NSLog(@"==========================================================");
//    Class meta_class = objc_getMetaClass(class_getName(cls));
//    NSLog(@"%s's meta-class is %s", class_getName(cls), class_getName(meta_class));
//    NSLog(@"==========================================================");
//    // 变量实例大小
//    NSLog(@"instance size: %zu", class_getInstanceSize(cls));
//    NSLog(@"==========================================================");
//    // 成员变量
//    Ivar *ivars = class_copyIvarList(cls, &outCount);
//    for (int i = 0; i < outCount; i++) {
//        Ivar ivar = ivars[i];
//        NSLog(@"instance variable's name: %s at index: %d", ivar_getName(ivar), i);
//    }
//    free(ivars);
//    Ivar string = class_getInstanceVariable(cls, "_string");
//    if (string != NULL) {
//        NSLog(@"instace variable %s", ivar_getName(string));
//    }
//    NSLog(@"==========================================================");
//    // 属性操作
//    objc_property_t * properties = class_copyPropertyList(cls, &outCount);
//    for (int i = 0; i < outCount; i++) {
//        objc_property_t property = properties[i];
//        NSLog(@"property's name: %s", property_getName(property));
//    }
//    free(properties);
//    objc_property_t array = class_getProperty(cls, "array");
//    if (array != NULL) {
//        NSLog(@"property %s", property_getName(array));
//    }
//    NSLog(@"==========================================================");
//    // 方法操作
//    Method *methods = class_copyMethodList(cls, &outCount);
//    for (int i = 0; i < outCount; i++) {
//        Method method = methods[i];
//        NSLog(@"method's signature: %s", method_getName(method));
//    }
//    free(methods);
//    Method method1 = class_getInstanceMethod(cls, @selector(method1));
//    if (method1 != NULL) {
//        NSLog(@"method %s", method_getName(method1));
//    }
//    Method classMethod = class_getClassMethod(cls, @selector(classMethod1));
//    if (classMethod != NULL) {
//        NSLog(@"class method : %s", method_getName(classMethod));
//    }
//    NSLog(@"MyClass is%@ responsd to selector: method3WithArg1:arg2:", class_respondsToSelector(cls, @selector(method3WithArg1:arg2:)) ? @"" : @" not");
//    IMP imp = class_getMethodImplementation(cls, @selector(method1));
//    //这里报错, Build Setting -> apple clang preprocessing -> Enable Strict Checking of objc_msgSend Calls 设置成YES
//    imp();
//    NSLog(@"==========================================================");
//    // 协议
//    Protocol * __unsafe_unretained * protocols = class_copyProtocolList(cls, &outCount);
//    Protocol * protocol;
//    for (int i = 0; i < outCount; i++) {
//        protocol = protocols[i];
//        NSLog(@"protocol name: %s", protocol_getName(protocol));
//    }
//    NSLog(@"MyClass is%@ responsed to protocol %s", class_conformsToProtocol(cls, protocol) ? @"" : @" not", protocol_getName(protocol));
//    NSLog(@"==========================================================");
//
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

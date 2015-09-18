//
//  PersonModel.m
//  
//
//  Created by 黄龙辉 on 15/9/18.
//
//

#import "PersonModel.h"
#import "CompanyModel.h"
#import <objc/runtime.h>

@interface PersonModel()

@property(nonatomic, strong)CompanyModel *companyModel;

@end

@implementation PersonModel

@dynamic name;


- (id)init{
    
    self = [super init];
    if (self) {
        _companyModel = [[CompanyModel alloc] init];
    }
    
    return self;
}


+ (BOOL)resolveInstanceMethod:(SEL)sel{
    
    NSString *selStr = NSStringFromSelector(sel);
    if ([selStr isEqualToString:@"name"]) {
        class_addMethod(self, sel, (IMP)nameGetter, "@@:");
        return YES;
    }
    if ([selStr isEqualToString:@"setName:"]) {
        class_addMethod(self, sel, (IMP)nameSetter, "v@:@");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}


void nameSetter(id self, SEL cmd, id value){
    NSString *fullName = value;
    NSArray *nameArray = [fullName componentsSeparatedByString:@" "];
    PersonModel *model = (PersonModel *)self;
    model.firstName = nameArray[0];
    model.lastName  = nameArray[1];
}



id nameGetter(id self, SEL cmd){
    
    PersonModel *model = (PersonModel *)self;
    NSMutableString *name = [[NSMutableString alloc] init];
    if (nil != model.firstName) {
        [name appendString:model.firstName];
        [name appendString:@" "];
    }
    if (nil != model.lastName) {
        [name appendString:model.lastName];
    }
    return name;
}


- (id)forwardingTargetForSelector:(SEL)aSelector{
    
    NSString *selStr = NSStringFromSelector(aSelector);
    if ([selStr isEqualToString:@"companyName"]) {
        return self.companyModel;
    }else{
        return nil;
    }
}


- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    
    NSMethodSignature *sig = nil;
    NSString *selStr = NSStringFromSelector(aSelector);
    if ([selStr isEqualToString:@"deptName"]) {
        //此处返回的sig是方法forwardInvocation的参数anInvocation中的methodSignature
        sig = [self.companyModel methodSignatureForSelector:@selector(deptName:)];
    }else{
        sig = [super methodSignatureForSelector:aSelector];
    }
    return sig;
}


- (void)forwardInvocation:(NSInvocation *)anInvocation{

    [anInvocation setTarget:self.companyModel];
    [anInvocation setSelector:@selector(deptName:)];
    BOOL hasCompanyName = YES;
    //第一个和第一个参数是target和sel
    [anInvocation setArgument:&hasCompanyName atIndex:2];
    [anInvocation retainArguments];
    [anInvocation invoke];
}

@end

//
//  CDZModel.h
//  HappyKTV
//
//  Created by zhengchen2 on 14-10-28.
//  Copyright (c) 2014年 zhengchen2 All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDZModel : NSObject <NSCopying, NSSecureCoding>

// 遍历自己的属性，并从字典中寻找相应字段，初始化属性
-(id)initWithDictionary:(NSDictionary*)dictionry;

// 根据自己的属性，生成字典
-(NSMutableDictionary*)dictionaryForProperties;

// 完成了初始化，子类重载
-(void)didInitializeWithDictionary:(NSDictionary*)dictionry;

// 数组中的成员类型，
// 如果数组成员类型是 CDZModel子类，则子类可以重载并返回正确类型。
// 如果不是 CDZModel子类，返回 NULL，或不重载即可。
+(Class)classInArrayProperty:(NSString*)propertyName;

@end

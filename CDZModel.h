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
- (id)initWithDictionary:(NSDictionary*)dictionry;

// 遍历自己的属性，并从字典中寻找相应字段，初始化属性。即 解析 过程
- (void)setPropertiesWithDictionary:(NSDictionary*)dictionry;

// 根据自己的属性，生成字典。即 反解析 过程
- (NSMutableDictionary*)dictionaryForProperties;

// 完成了初始化，子类重载
- (void)didInitializeWithDictionary:(NSDictionary*)dictionry;

// 数组中的成员类型，
// 如果数组成员类型是 CDZModel子类，则子类可以重载并返回正确类型。
// 如果不是 CDZModel子类，返回 NULL，或不重载即可。
+ (Class)classInArrayProperty:(NSString*)propertyName;

// 子类重载，返回 property属性 在(解析和反解析)字典中 所对应的键名，默认返回 propertyName
// 如果 键名 和 属性名 一样，子类不重载即可。
+ (NSString*)keyForProperty:(NSString*)propertyName;

// 从字典数组里，返回初始化好后的数组
+ (NSMutableArray*)objectArrayWithDictionaryArray:(NSArray*)dicArray;


#pragma mark - Localization
// 用 key 来生成 filePath
+ (NSString*)filePathForKey:(NSString*)aKey;    // 默认返回 ${Document}/CDZModel/aKey

// 用key来储存
- (BOOL)saveForKey:(NSString*)aKey;
+ (id)objectForKey:(NSString*)aKey;
// 用key来储存数组
+ (void)saveObjectArray:(NSArray*)array forKey:(NSString*)aKey;
+ (NSMutableArray*)objectArrayForKey:(NSString*)aKey;

// 将数据储存在 filePath 里
- (BOOL)saveWithFilePath:(NSString*)filePath;
+ (id)objectWithFilePath:(NSString*)filePath;
// 将数组储存在 filePath 里
+ (void)saveObjectArray:(NSArray*)array withFilePath:(NSString*)filePath;
+ (NSMutableArray*)objectArrayWithFilePath:(NSString*)filePath;

// 删除
+ (void)removeForKey:(NSString*)aKey;
+ (void)removeFileWithFilePath:(NSString*)filePath;

@end

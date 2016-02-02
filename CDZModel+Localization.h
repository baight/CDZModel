//
//  CDZModel.h
//  HappyKTV
//
//  Created by zhengchen2 on 14-10-28.
//  Copyright (c) 2014年 zhengchen2 All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDZModel.h"

@interface CDZModel (Localization)

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

//
//  CDZModel.m
//  HappyKTV
//
//  Created by zhengchen2 on 14-10-28.
//  Copyright (c) 2014年 zhengchen2 All rights reserved.
//

#import "CDZModel+Localization.h"

@implementation CDZModel (Localization)

// 用 key 来生成 filePath
+ (NSString*)filePathForKey:(NSString*)aKey{
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString* fileName = [@"CDZModel/" stringByAppendingString:aKey];
    return [documentDirectory stringByAppendingPathComponent:fileName];
}

// 用key来储存
- (BOOL)saveForKey:(NSString*)aKey{
    if(aKey.length == 0){
        return NO;
    }
    NSString* filePath = [CDZModel filePathForKey:aKey];
    return [self saveWithFilePath:filePath];
}
+ (id)objectForKey:(NSString*)aKey{
    if(aKey.length == 0){
        return nil;
    }
    NSString* filePath = [CDZModel filePathForKey:aKey];
    return [self objectWithFilePath:filePath];
}
// 用key来储存数组
+ (void)saveObjectArray:(NSArray*)array forKey:(NSString*)aKey{
    if(aKey.length == 0){
        return ;
    }
    NSString* filePath = [CDZModel filePathForKey:aKey];
    [self saveObjectArray:array withFilePath:filePath];
}
+ (NSMutableArray*)objectArrayForKey:(NSString*)aKey{
    if(aKey.length == 0){
        return nil;
    }
    NSString* filePath = [CDZModel filePathForKey:aKey];
    return [self objectArrayWithFilePath:filePath];
}

// 将数据储存在 filePath 里
- (BOOL)saveWithFilePath:(NSString*)filePath{
    NSString* dirPath = [filePath stringByDeletingLastPathComponent];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
        NSError* error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
        if(error){
            return NO;
        }
    }
    return [NSKeyedArchiver archiveRootObject:self toFile:filePath];
}
+ (id)objectWithFilePath:(NSString*)filePath{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
}
// 将数组储存在 filePath 里
+ (void)saveObjectArray:(NSArray*)array withFilePath:(NSString*)filePath{
    [NSKeyedArchiver archiveRootObject:array toFile:filePath];
}
+ (NSMutableArray*)objectArrayWithFilePath:(NSString*)filePath{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
}

// 删除
+ (void)removeForKey:(NSString*)aKey{
    NSString* filePath = [CDZModel filePathForKey:aKey];
    [self removeFileWithFilePath:filePath];
}
+ (void)removeFileWithFilePath:(NSString*)filePath{
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
}

@end

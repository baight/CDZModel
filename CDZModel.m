//
//  CDZModel.m
//  HappyKTV
//
//  Created by zhengchen2 on 14-10-28.
//  Copyright (c) 2014年 zhengchen2 All rights reserved.
//

#import "CDZModel.h"
#import <objc/message.h>
#import <objc/runtime.h>


@interface CDZProperty : NSObject
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* key;
@property (nonatomic, assign) BOOL writable;
@property (nonatomic, assign) BOOL readable;

@property (nonatomic, assign) Class typeClass;
@property (nonatomic, assign) BOOL isSubclassOfCDZModel;

@property (nonatomic, assign) Class typeClassInArray;
@property (nonatomic, assign) BOOL isSubclassOfNSArray;
@end

@implementation CDZProperty
@end



static const char CDZPropertyKey;

@implementation CDZModel
- (id)initWithDictionary:(NSDictionary*)dictionry{
    self = [super init];
    if(self){
        [self setPropertiesWithDictionary:dictionry];
        [self didInitializeWithDictionary:dictionry];
    }
    return self;
}

// 遍历自己的属性，并从字典中寻找相应字段，初始化属性
- (void)setPropertiesWithDictionary:(NSDictionary*)dictionry{
    Class cc = [CDZModel class];
    for(Class _class = [self class]; _class != cc; _class = [_class superclass]){
        NSMutableArray *cachedProperties = [_class cachedProperties];
        for(CDZProperty* property in cachedProperties){
            if(property.writable){
                id propertyValue = [dictionry objectForKey:property.key];
                if(propertyValue){
                    if(property.isSubclassOfCDZModel){
                        propertyValue = [[property.typeClass alloc] initWithDictionary:propertyValue];
                    }
                    else if(property.isSubclassOfNSArray){
                        if(property.typeClassInArray){
                            NSMutableArray* array = [[NSMutableArray alloc]initWithCapacity:[propertyValue count]];
                            for(NSDictionary* d in propertyValue){
                                id obj = [[property.typeClassInArray alloc]initWithDictionary:d];
                                [array addObject:obj];
                            }
                            propertyValue = array;
                        }
                    }
                    [self setValue:propertyValue forKey:property.name];
                }
            }
        }
    }
}
+ (NSMutableArray*)cachedProperties{
    NSMutableArray *cachedProperties = objc_getAssociatedObject(self, &CDZPropertyKey);
    if(cachedProperties == nil){
        cachedProperties = [[NSMutableArray alloc]init];
        
        unsigned int outCount;
        objc_property_t *properties = class_copyPropertyList(self, &outCount);
        for (int i = 0; i<outCount; i++){
            CDZProperty* myProperty = [[CDZProperty alloc]init];
            objc_property_t property = properties[i];
            myProperty.name = [NSString stringWithUTF8String:property_getName(property)];
            myProperty.key = [self keyForProperty:myProperty.name];
            
            NSString* attributes = [NSString stringWithUTF8String:property_getAttributes(property)];
            
            // 是 id类的属性
            NSRange range = [attributes rangeOfString:@"T@\""];
            if(range.length > 0){
                NSInteger startIndex = range.location + range.length;
                NSInteger endIndex = 0;
                for(NSInteger i=startIndex; i< attributes.length; i++){
                    unichar c = [attributes characterAtIndex:i];
                    if(c == '"'){
                        endIndex = i;
                        break;
                    }
                }
                if(endIndex > 0){
                    NSString* className = [attributes substringWithRange:NSMakeRange(startIndex, endIndex - startIndex)];
                    myProperty.typeClass = NSClassFromString(className);
                    myProperty.isSubclassOfCDZModel = [myProperty.typeClass isSubclassOfClass:[CDZModel class]];
                    myProperty.isSubclassOfNSArray = [myProperty.typeClass isSubclassOfClass:[NSArray class]];
                    if(myProperty.isSubclassOfNSArray){
                        myProperty.typeClassInArray = [self classInArrayProperty:myProperty.name];
                    }
                }
            }
            
            if([self instancesRespondToSelector:NSSelectorFromString(myProperty.name)]){
                myProperty.readable = YES;
            }
            NSString* setMethodString = [[NSString alloc] initWithFormat:@"set%@:", myProperty.name.firstCharUpper, nil];
            if([self instancesRespondToSelector:NSSelectorFromString(setMethodString)]){
                myProperty.writable = YES;
            }
            
            [cachedProperties addObject:myProperty];
        }
        free(properties);
        
        objc_setAssociatedObject(self, &CDZPropertyKey, cachedProperties, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cachedProperties;
}

// 根据自己的属性，生成字典
- (NSMutableDictionary*)dictionaryForProperties{
    NSMutableDictionary* d = [NSMutableDictionary dictionary];
    Class cc = [CDZModel class];
    for(Class _class = [self class]; _class != cc; _class = [_class superclass]){
        NSMutableArray *cachedProperties = [_class cachedProperties];
        for(CDZProperty* property in cachedProperties){
            if(property.readable){
                id value = [self valueForKey:property.name];
                if(value){
                    if(property.isSubclassOfCDZModel){
                        value = [value dictionaryForProperties];
                    }
                    else if(property.isSubclassOfNSArray){
                        NSMutableArray* array = [[NSMutableArray alloc]initWithCapacity:[value count]];
                        for(CDZModel* c in value){
                            if([c isKindOfClass:[CDZModel class]]){
                                [array addObject:[c dictionaryForProperties]];
                            }
                        }
                        value = array;
                    }
                    [d setObject:value forKey:property.key];
                }
            }
        }
    }
    return d;
}

// 从字典数组里，返回初始化好后的数组
+ (NSMutableArray*)objectArrayWithDictionaryArray:(NSArray*)dicArray{
    NSMutableArray* objectArray = nil;
    for(NSDictionary* d in dicArray){
        if(objectArray == nil){
            objectArray = [[NSMutableArray alloc]init];
        }
        id obj = [[self alloc]initWithDictionary:d];
        [objectArray addObject:obj];
    }
    return objectArray;
}

// 完成了初始化，子类重载
- (void)didInitializeWithDictionary:(NSDictionary*)dictionry{}
// 数组中的类型，必须是 CDZModel子类，不然解析不正确
+ (Class)classInArrayProperty:(NSString*)propertyName{ return NULL; }
// 返回 property属性 在字典中 所对应的键名，默认返回 propertyName
+ (NSString*)keyForProperty:(NSString*)propertyName{ return propertyName; }

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone{
    id obj = [[[self class] allocWithZone:zone] init];
    Class cc = [CDZModel class];
    for(Class _class = [self class]; _class != cc; _class = [_class superclass]){
        NSMutableArray *cachedProperties = [_class cachedProperties];
        for(CDZProperty* property in cachedProperties){
            if(property.readable && property.writable){
                id propertyValue = [self valueForKey:property.name];
                if(propertyValue){
                    if(property.isSubclassOfCDZModel){
                        [obj setValue:[propertyValue copy] forKey:property.name];
                    }
                    else{
                        [obj setValue:propertyValue forKey:property.name];
                    }
                }
            }
        }
    }
    return obj;
}

#pragma mark - NSSecureCoding
+ (BOOL)supportsSecureCoding{
    return YES;
}
- (void)encodeWithCoder:(NSCoder *)aCoder{
    Class cc = [CDZModel class];
    for(Class _class = [self class]; _class != cc; _class = [_class superclass]){
        NSMutableArray *cachedProperties = [_class cachedProperties];
        for(CDZProperty* property in cachedProperties){
            if(property.readable){
                id propertyValue = [self valueForKey:property.name];
                if(propertyValue){
                    [aCoder encodeObject:propertyValue forKey:property.name];
                }
            }
        }
    }
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super init]){
        Class cc = [CDZModel class];
        for(Class _class = [self class]; _class != cc; _class = [_class superclass]){
            NSMutableArray *cachedProperties = [_class cachedProperties];
            for(CDZProperty* property in cachedProperties){
                if(property.writable){
                    id propertyValue = [aDecoder decodeObjectForKey:property.name];
                    if(propertyValue){
                        [self setValue:propertyValue forKey:property.name];
                    }
                }
            }
        }
    }
    return self;
}


@end

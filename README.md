# CDZModel
data model, initialize itself from dictionary，数据模型，可以从字典里自动初始化

===============
to use like following，使用如下：

@interface CDZUser : CDZModel
@property (nonatomic, strong) NSString* name;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, strong) CDZUser* mother;
@property (nonatomic, strong) CDZUser* father;
@property (nonatomic, strong) NSMutableArray* friends;
@end


@implementation CDZUser
+(Class)classInArrayProperty:(NSString *)propertyName{
    if([propertyName isEqualToString:@"friends"]){
        return [CDZUser class];
    }
    else{
        return NULL;
    }
}
-(void)didInitializeWithDictionary:(NSDictionary *)dictionry{
    // initialize over, do what you want
}
@end




NSDictionary* dic = @{@"name":@"Janney",
                          @"age":@(26),
                          @"mother":@{@"name":@"Lucy"},
                          @"father":@{@"name":@"Jake"},
                          @"friends":@[@{@"name":@"Forrest"},
                                       @{@"name":@"LiLei"},
                                       @{@"name":@"HanMeiMei"}]};
    
// Janney has initialized from dictionary
CDZUser* Janney = [[CDZUser alloc]initWithDictionary:dic];
    
// dictionary containing user initialized data
NSDictionary* d = [Janney dictionaryForProperties];
/*
d = @{@"name":@"Janney",
      @"age":@(26),
      @"mother":@{@"name":@"Lucy",
                   @"age":@(0)},
      @"father":@{@"name":@"Jake",
                  @"age":@(0)},
      @"friends":@[@{@"name":@"Forrest",
                     @"age":@(0)},
                   @{@"name":@"LiLei",
                     @"age":@(0)},
                   @{@"name":@"HanMeiMei",
                     @"age":@(0)}]};
 */
    
// copy of Janney
CDZUser* cloneJanney = [Janney copy];


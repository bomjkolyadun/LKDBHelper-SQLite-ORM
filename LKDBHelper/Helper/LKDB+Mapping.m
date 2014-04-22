//
//  LKDBProperty+KeyMapping.m
//  LKDBContext
//
//  Created by upin on 13-6-17.
//  Copyright (c) 2013年 ljh. All rights reserved.
//

#import "LKDB+Mapping.h"
#import "LKManagedObject.h"

#pragma mark- 声明
@interface LKDBProperty()
{
    __strong NSString* _type;
    
    __strong NSString* _sqlColumnName;
    __strong NSString* _sqlColumnType;
    
    __strong NSString* _propertyName;
    __strong NSString* _propertyType;
}
@property(copy,nonatomic)NSString* type;
@property(copy,nonatomic)NSString* sqlColumnName;
@property(copy,nonatomic)NSString* sqlColumnType;
@property(copy,nonatomic)NSString* propertyName;
@property(copy,nonatomic)NSString* propertyType;

-(id)initWithType:(NSString*)type cname:(NSString*)cname ctype:(NSString*)ctype pname:(NSString*)pname ptype:(NSString*)ptype;

@end

@interface LKModelInfos()
{
    __strong NSMutableDictionary* _proNameDic;
    __strong NSMutableDictionary* _sqlNameDic;
    __strong NSMutableArray* _primaryKeys;
}
-(void)removeWithColumnName:(NSString*)columnName;
-(void)addDBPropertyWithType:(NSString *)type cname:(NSString *)column_name ctype:(NSString *)ctype pname:(NSString *)pname ptype:(NSString *)ptype;
@end

#pragma mark- LKDBProperty
@implementation LKDBProperty

-(id)initWithType:(NSString *)type cname:(NSString *)cname ctype:(NSString *)ctype pname:(NSString *)pname ptype:(NSString *)ptype
{
    self = [super init];
    if(self)
    {
        _type = [type copy];
        _sqlColumnName = [cname copy];
        _sqlColumnType = [ctype copy];
        _propertyName = [pname copy];
        _propertyType = [ptype copy];
    }
    return self;
}
-(void)enableUserCalculate
{
    _type = LKSQL_Mapping_UserCalculate;
}
-(BOOL)isUserCalculate
{
    return ([_type isEqualToString:LKSQL_Mapping_UserCalculate] || _propertyName == nil || [_propertyName isEqualToString:LKSQL_Mapping_UserCalculate]);
}
@end
#pragma mark- NSObject - TableMapping
@implementation LKManagedObject(TableMapping)
+(NSDictionary *)getTableMapping
{
    return nil;
}
+(void)setUserCalculateForCN:(NSString *)columnName
{
    if([LKDBUtils checkStringIsEmpty:columnName])
    {
        LKErrorLog(@"columnName is null");
        return;
    }
    
    LKModelInfos* infos = [self getModelInfos];
    LKDBProperty* property = [infos objectWithSqlColumnName:columnName];
    if(property)
    {
        [property enableUserCalculate];
    }
    else
    {
        [infos addDBPropertyWithType:LKSQL_Mapping_UserCalculate cname:columnName ctype:LKSQL_Type_Text pname:columnName ptype:@"NSString"];
    }
}
+(void)setUserCalculateForPTN:(NSString *)propertyTypeName
{
    if([LKDBUtils checkStringIsEmpty:propertyTypeName])
    {
        LKErrorLog(@"propertyTypeName is null");
        return;
    }
    
    LKModelInfos* infos = [self getModelInfos];
    for (int i=0; i<infos.count; i++) {
        LKDBProperty* property = [infos objectWithIndex:i];
        if([property.propertyType isEqualToString:propertyTypeName])
        {
            [property enableUserCalculate];
        }
    }
}
+(void)setTableColumnName:(NSString *)columnName bindingPropertyName:(NSString *)propertyName
{
    if([LKDBUtils checkStringIsEmpty:columnName] || [LKDBUtils checkStringIsEmpty:propertyName])
        return;
    
    LKModelInfos* infos = [self getModelInfos];
    
    LKDBProperty* property = [infos objectWithPropertyName:propertyName];
    if(property==nil)
        return;
    
    LKDBProperty* column = [infos objectWithSqlColumnName:columnName];
    if(column)
    {
        column.propertyName = propertyName;
        column.propertyType = property.propertyType;
    }
    else{
        [infos addDBPropertyWithType:LKSQL_Mapping_Binding cname:columnName ctype:LKSQL_Type_Text pname:propertyName ptype:property.propertyType];
    }
}
+(void)removePropertyWithColumnName:(NSString *)columnName
{
    [[self getModelInfos] removeWithColumnName:columnName];
}
@end

#pragma mark- LKModelInfos

@implementation LKModelInfos
- (id)initWithKeyMapping:(NSDictionary *)keyMapping propertyNames:(NSArray *)propertyNames propertyType:(NSArray *)propertyType primaryKeys:(NSArray *)primaryKeys
{
    self = [super init];
    if (self) {
        
        _primaryKeys = [primaryKeys copy];
        
        _proNameDic = [[NSMutableDictionary alloc]init];
        _sqlNameDic = [[NSMutableDictionary alloc]init];
        
        NSString  *type,*column_name,*column_type,*property_name,*property_type;
        if(keyMapping.count>0)
        {
            NSArray* sql_names = keyMapping.allKeys;
            
            for (int i =0; i< sql_names.count; i++) {
                
                type = column_name = column_type = property_name = property_type = nil;
                
                column_name = [sql_names objectAtIndex:i];
                NSString* mappingValue = [keyMapping objectForKey:column_name];
                
                //如果 设置的 属性名 是空白的  自动转成 使用ColumnName
                if([LKDBUtils checkStringIsEmpty:mappingValue])
                {
                    NSLog(@"#ERROR sql column name %@ mapping value is empty,automatically converted LKDBInherit",column_name);
                    mappingValue = LKSQL_Mapping_Inherit;
                }
                
                if([mappingValue isEqualToString:LKSQL_Mapping_UserCalculate])
                {
                    type = LKSQL_Mapping_UserCalculate;
                    column_type = LKSQL_Type_Text;
                }
                else
                {
                    
                    if([mappingValue isEqualToString:LKSQL_Mapping_Inherit] || [mappingValue isEqualToString:LKSQL_Mapping_Binding])
                    {
                        type = LKSQL_Mapping_Inherit;
                        property_name = column_name;
                    }
                    else
                    {
                        type = LKSQL_Mapping_Binding;
                        property_name = mappingValue;
                    }
                    
                    NSUInteger index = [propertyNames indexOfObject:property_name];
                    
                    NSAssert(index != NSNotFound, @"#ERROR TableMapping SQL column name %@ not fount %@ property name",column_name,property_name);
                    
                    property_type = [propertyType objectAtIndex:index];
                    column_type = LKSQLTypeFromObjcType(property_type);
                }
                
                [self addDBPropertyWithType:type cname:column_name ctype:column_type pname:property_name ptype:property_type];
            }
        }
        else
        {
            for (int i=0; i<propertyNames.count; i++) {
                
                type = LKSQL_Mapping_Inherit;
                
                property_name = [propertyNames objectAtIndex:i];
                column_name = property_name;
                
                property_type = [propertyType objectAtIndex:i];
                column_type = LKSQLTypeFromObjcType(property_type);
                
                [self addDBPropertyWithType:type cname:column_name ctype:column_type pname:property_name ptype:property_type];
            }
        }
        
        for (NSString* pkname in _primaryKeys) {
            if([pkname.lowercaseString isEqualToString:@"rowid"])
            {
                if([self objectWithSqlColumnName:pkname] == nil)
                {
                    [self addDBPropertyWithType:LKSQL_Mapping_Inherit cname:pkname ctype:LKSQL_Type_Int pname:pkname ptype:@"int"];
                }
            }
        }
    }
    return self;
}
-(void)addDBPropertyWithType:(NSString *)type cname:(NSString *)column_name ctype:(NSString *)ctype pname:(NSString *)pname ptype:(NSString *)ptype
{
    LKDBProperty* db_property = [[LKDBProperty alloc]initWithType:type cname:column_name ctype:ctype pname:pname ptype:ptype];
    
    if(db_property.propertyName)
    {
        [_proNameDic setObject:db_property forKey:db_property.propertyName];
    }
    if(db_property.sqlColumnName){
        [_sqlNameDic setObject:db_property forKey:db_property.sqlColumnName];
    }
}
-(NSArray *)primaryKeys
{
    return _primaryKeys;
}
-(NSUInteger)count
{
    return _sqlNameDic.count;
}
-(LKDBProperty *)objectWithIndex:(int)index
{
    if(index < _sqlNameDic.count)
    {
        id key = [_sqlNameDic.allKeys objectAtIndex:index];
        return [_sqlNameDic objectForKey:key];
    }
    return nil;
}
-(LKDBProperty *)objectWithPropertyName:(NSString *)propertyName
{
    return [_proNameDic objectForKey:propertyName];
}
-(LKDBProperty *)objectWithSqlColumnName:(NSString *)columnName
{
    return [_sqlNameDic objectForKey:columnName];
}
-(void)removeWithColumnName:(NSString*)columnName
{
    if([LKDBUtils checkStringIsEmpty:columnName])
        return;
    
    LKDBProperty* property =  [_sqlNameDic objectForKey:columnName];
    if(property.propertyName)
    {
        [_proNameDic removeObjectForKey:property.propertyName];
    }
    [_sqlNameDic removeObjectForKey:columnName];
}
@end
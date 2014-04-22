//
//  LKManagedObject.h
//  LKDBContext
//
//  Created by Dmitry Osipa on 4/21/14.
//  Copyright (c) 2014 ljh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LKDBProperty;
@class LKModelInfos;
@class LKDBContext;

@interface LKManagedObject : NSObject

- (instancetype)initWithContext:(LKDBContext*)context;

@property (nonatomic, readonly, strong) LKDBContext* context;

//overwrite methods
+(void)dbDidCreateTable:(LKDBContext*)helper;

-(BOOL)dbShouldInsert:(NSObject*)entity;
-(void)dbDidInsertWithResult:(BOOL)result;

-(BOOL)dbShouldUpdate:(NSObject*)entity;
-(void)dbDidUpdateWithResult:(BOOL)result;

-(BOOL)dbShouldDelete:(NSObject*)entity;
-(void)dbDidDeleteWithResult:(BOOL)result;


// overwrite in your models, return # table name #
+(NSString*)getTableName;
+(BOOL)getAutoUpdateSqlColumn;

// overwrite in your models, set column attribute
+(void)columnAttributeWithProperty:(LKDBProperty*)property;

/**
 *	@brief	overwrite in your models, if your table has primary key
 return # column name  #

 主键列名 如果rowid<0 则跟据此名称update 和delete
 */
+(NSString*)getPrimaryKey;

//return multi primary key    返回联合主键
+(NSArray*) getPrimaryKeyUnionArray;

+ (NSString*)sqlModules;

@property (nonatomic, readwrite) NSInteger rowid;

/**
 *	@brief   get saved pictures and data file path,can overwirte

 获取保存的 图片和数据的文件路径
 */
+(NSString*)getDBImagePathWithName:(NSString*)filename;
+(NSString*)getDBDataPathWithName:(NSString*)filename;




//return model use LKDBContext , default return global LKDBContext;

/**
 *	@brief  返回 该Model 的基础信息
 *
 */
+(LKModelInfos*)getModelInfos;

/**
 *	@brief Containing the super class attributes	设置是否包含 父类 的属性
 */
+(BOOL)isContainParent;

/**
 *	@brief      overwrite in your models,return insert sqlite table data
 *
 *
 *	@return     property the data after conversion
 */
-(id)userGetValueForModel:(LKDBProperty*)property;

/**
 *	@brief	overwrite in your models,return insert sqlite table data
 *
 *	@param 	property        will set property
 *	@param 	value           sqlite value (normal value is NSString type)
 */
-(void)userSetValueForModel:(LKDBProperty*)property value:(id)value;

+(NSDateFormatter*)getModelDateFormatter;
//LKDBContext use
-(id)modelGetValue:(LKDBProperty*)property;
-(void)modelSetValue:(LKDBProperty*)property value:(id)value;

-(id)singlePrimaryKeyValue;
-(BOOL)singlePrimaryKeyValueIsEmpty;
-(LKDBProperty*)singlePrimaryKeyProperty;

@end

//
//  LKDBContext.h
//  upin
//
//  Created by Fanhuan on 12-12-6.
//  Copyright (c) 2012年 linggan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabaseQueue.h"
#import "FMDatabase.h"

#import "LKDBUtils.h"

#import "LKDB+Manager.h"
#import "LKDB+Mapping.h"

#import "LKManagedObject.h"

@interface LKDBContext : NSObject

@property (strong, nonatomic, readonly) FMDatabaseQueue* bindingQueue;

-(id)initWithDBName:(NSString*)dbname;

/**
 *	@brief  execute database operations synchronously,not afraid of recursive deadlock  同步执行数据库操作 可递归调用
 */

-(BOOL)executeSQL:(NSString *)sql arguments:(NSArray *)args;
-(NSString *)executeScalarWithSQL:(NSString *)sql arguments:(NSArray *)args;
@end

@interface LKDBContext(DatabaseManager)

//get table has created
-(BOOL)getTableCreatedWithClass:(Class)model;

//create table with entity class
-(BOOL)createTableWithModelClass:(Class)model;

//drop all table
-(void)dropAllTable;

//drop table with entity class
-(BOOL)dropTableWithClass:(Class)modelClass;

@end

@interface LKDBContext(DatabaseExecute)
/**
 *	@brief	The number of rows query table
 *
 *	@param 	modelClass      entity class
 *	@param 	where           can use NSString or NSDictionary or nil
 *
 *	@return	rows number
 */
-(NSInteger)rowCount:(Class)modelClass where:(id)where;
-(void)rowCount:(Class)modelClass where:(id)where callback:(void(^)(int rowCount))callback;

/**
 *	@brief	query table
 *
 *	@param 	modelClass      entity class
 *	@param 	where           can use NSString or NSDictionary or nil
 
 *	@param 	orderBy         The Sort: Ascending "name asc",Descending "name desc"
                            For example: @"rowid desc"  or @"rowid asc"
 
 *	@param 	offset          Skip how many rows
 *	@param 	count           Limit the number
 *
 *	@return	query finished result is an array(model instance collection)
 */
-(NSMutableArray*)search:(Class)modelClass where:(id)where orderBy:(NSString*)orderBy offset:(int)offset count:(int)count;
-(void)search:(Class)modelClass where:(id)where orderBy:(NSString*)orderBy offset:(int)offset count:(int)count callback:(void(^)(NSMutableArray* array))block;
/**
    columns may NSArray or NSString   if query column count == 1  return single column string array
    other return models entity array
 */
-(NSMutableArray*)search:(Class)modelClass column:(id)columns where:(id)where orderBy:(NSString*)orderBy offset:(int)offset count:(int)count;

//return first model or nil
-(id)searchSingle:(Class)modelClass where:(id)where orderBy:(NSString*)orderBy;

/**
 *	@brief	insert table
 *
 *	@param 	model 	you want to insert the entity
 *
 *	@return	the inserted was successful
 */
-(BOOL)insertToDB:(NSArray*)models;
-(void)insertToDB:(NSArray*)models callback:(void(^)(BOOL result))block;

/**
 *	@brief	insert when the entity primary key does not exist
 *
 *	@param 	model 	you want to insert the entity
 *
 *	@return	the inserted was successful
 */
-(BOOL)insertWhenNotExists:(NSObject*)model;
-(void)insertWhenNotExists:(NSObject*)model callback:(void(^)(BOOL result))block;

/**
 *	@brief update table
 *
 *	@param 	model 	you want to update the entity
 *	@param 	where 	can use NSString or NSDictionary or nil
                    when "where" is nil : update the value based on rowid column or primary key column
 *
 *	@return	the updated was successful
 */
-(BOOL)updateToDB:(LKManagedObject *)model where:(id)where;
-(void)updateToDB:(LKManagedObject *)model where:(id)where callback:(void (^)(BOOL result))block;
-(BOOL)updateToDB:(Class)modelClass set:(NSString*)sets where:(id)where;
/**
 *	@brief	delete table
 *
 *	@param 	model 	you want to delete entity
                    when entity property "rowid" == 0  based on the primary key to delete
 *
 *	@return	the deleted was successful
 */
-(BOOL)deleteToDB:(LKManagedObject*)model;
-(void)deleteToDB:(LKManagedObject*)model callback:(void(^)(BOOL result))block;

/**
 *	@brief	delete table with "where" constraint
 *
 *	@param 	modelClass      entity class
 *	@param 	where           can use NSString or NSDictionary,  can not is nil
 *
 *	@return	the deleted was successful
 */
-(BOOL)deleteWithClass:(Class)modelClass where:(id)where;
-(void)deleteWithClass:(Class)modelClass where:(id)where callback:(void (^)(BOOL result))block;

/**
 *	@brief   entity exists?
 *           for primary key column
            （if rowid > 0 would certainly exist so we do not rowid judgment）
 *	@param 	model 	entity
 *
 *	@return	YES: entity presence , NO: entity not exist
 */
-(BOOL)isExistsModel:(NSObject*)model;
-(BOOL)isExistsClass:(Class)modelClass where:(id)where;


/**
 *	@brief	Clear data based on the entity class
 *
 *	@param 	modelClass 	entity class
 */
-(void)clearTableData:(Class)modelClass;

/**
 *	@brief	Clear Unused Data File
            if you property has UIImage or NSData, will save their data in the (documents dir)
 *
 *	@param 	modelClass      entity class
 *	@param 	columns         UIImage or NSData Column Name
 */
-(void)clearNoneImage:(Class)modelClass columns:(NSArray*)columns;
-(void)clearNoneData:(Class)modelClass columns:(NSArray*)columns;

@end
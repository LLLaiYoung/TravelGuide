//
//  DataBaseManager.m
//  CQTravelGuide
//
//  Created by chairman on 15/12/7.
//  Copyright © 2015年 LaiYong. All rights reserved.
//

#import "DataBaseManager.h"
#import "FMDB.h"
#define kDataBasePath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"CQTravel.db"]
#define kCQSightType @"CQSightType"///<景点类型
#define kCQSight @"CQSight"///<景点
#define kRandom arc4random()%[self numberOfSight]


@interface DataBaseManager ()
@property (nonatomic, strong) FMDatabase *database;
@property (nonatomic, assign) NSInteger previousRandom;///<上一个随机数
@property (nonatomic, assign) NSInteger currentRandom;///<当前数
@end
@implementation DataBaseManager
#pragma mark - 单例
+ (instancetype)defaultManager {
    static DataBaseManager *theManager = nil;
    @synchronized(self) {//防止同时发送两个请求。一个执行一个则在外面等待执行完毕再执行
        if (!theManager) {
            theManager = [[DataBaseManager alloc]init];
        }
    }
    return theManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.database = [FMDatabase databaseWithPath:kDataBasePath];
        if (![self.database open]) {
            NSLog(@"打开失败");
            return nil;
        } else {
            NSLog(@"打开数据库成功,数据库路径是:%@",kDataBasePath);
        }
        NSString *sqlStr = [NSString stringWithFormat: @"create table if not exists %@ (typeID integer primary key,typeName text,date date)",kCQSightType];
        if (![self.database executeUpdate:sqlStr]) {
            NSLog(@"创建%@表失败,SQL语句是%@",kCQSightType,sqlStr);
            return nil;
        }
        
        /**
         @property (strong, nonatomic) NSNumber *sightID;///<景点ID
         @property (strong, nonatomic) NSNumber *sightTypeID;///<景点类型ID
         @property (copy, nonatomic) NSString *sightName;///<景点名称
         @property (copy, nonatomic) NSString *sightBrief;///<景点摘要
         @property (copy, nonatomic) NSString *sightImageLink;///<景点图片链接
         @property (copy, nonatomic) NSString * sightCoordinate;///<景点坐标
         @property (copy, nonatomic) NSString *sightHTMLString;///<景点Html链接
         */
        sqlStr = [NSString stringWithFormat: @"create table if not exists %@ (sightID integer primary key, sightTypeID integer, sightName text, sightBrief text, sightImageLink text, sightImageData blob, sightCoordinate text, sightHTMLString text,date date)",kCQSight];
        if (![self.database executeUpdate:sqlStr]) {
            NSLog(@"创建%@表失败,SQL语句是%@",kCQSight,sqlStr);
            return nil;
        }
        
    }
    
    return self;
}
#pragma mark - 类型接口
- (NSUInteger)numberOfCQType {
    NSString *sqlStr = [NSString stringWithFormat:@"select count(*) from %@",kCQSightType];
    return  [self.database intForQuery:sqlStr];
}
- (BOOL)insertIntoCQTypeAtIndex:(SightType *)sightType {
    NSDate *date = [NSDate date];
    if (!sightType) {
        NSLog(@"插入数据为空");
        return NO;
    } else {
//        NSString *sqlStr = [NSString stringWithFormat:@"insert into %@(typeID,typeName) values('%@','%@')",kCQType,CQType.typeID,CQType.typeName];
        NSString *sqlStr = [NSString stringWithFormat:@"insert into %@(typeID,typeName,date) values(?,?,?)",kCQSightType];
       BOOL isSuccess = [self.database executeUpdate:sqlStr,sightType.typeID,sightType.typeName,date];
        if (!isSuccess) {
            NSLog(@"%@表插入%@,插入语句是%@,景点名称是%@",kCQSightType,isSuccess?@"成功":@"失败",sqlStr,sightType.typeName);
            return NO;
        }
        return YES;
    }

}
- (SightType *)cqTypeAtIndex:(NSUInteger)index {
    if (index>=[self numberOfCQType]) {
        return nil;
    }
//    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@ limit %@,1",kCQType,@(index)];
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@ limit ?,1",kCQSightType];
    FMResultSet *result = [self.database executeQuery:sqlStr,@(index)];
    SightType *theSightType = [SightType new];
    if (!result) {
        NSLog(@"%@表查询失败,查询语句是:%@",kCQSightType,sqlStr);
        return nil;
    } else{
        if ([result next]) {
            theSightType.typeID = @([result intForColumn:@"typeID"]);
            theSightType.typeName = [result stringForColumn:@"typeName"];
            theSightType.date = [result dateForColumn:@"date"];
        }
        return theSightType;
    }
    return nil;
}
- (NSDate *)lastArchiveDate {
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT MAX(date) FROM %@",kCQSightType];
    FMResultSet *result = [self.database executeQuery:sqlStr];
    if ([result next]) {
        NSLog(@"%@",[self.database dateForQuery:sqlStr]);
        return [self.database dateForQuery:sqlStr];
    } else {
        NSLog(@"时间查询失败,查询语句是%@",sqlStr);
        return nil;
    }
}

- (void)deleteAllSightType {
    NSString *sqlStr = [NSString stringWithFormat:@"delete from %@",kCQSightType];
    if (![self.database executeUpdate:sqlStr]) {
        NSLog(@"删除失败,SQL:语句时%@",sqlStr);
    } else {
        NSLog(@"已清空数据库");
    }
}

#pragma mark - 景点接口
-(void)saveSightList:(NSArray *)sightList withSightType:(SightType *)theSightType{
    //避免重新加载数据的时候 出现插入失败   先删除
    NSString *sqlStr = [NSString stringWithFormat:@"delete from %@ where sightTypeID = ? ",kCQSight];
    [self.database executeUpdate:sqlStr,theSightType.typeID];
    NSLog(@"景点类别下的<%@>景点被删除",theSightType.typeName);
    if (!sightList || sightList.count==0) {
        return;
    }
    NSDate *date = [NSDate date];
    sqlStr= [NSString stringWithFormat:@"insert into %@ (sightID, sightTypeID, sightName, sightBrief, sightImageLink, sightCoordinate,date) values (?,?,?,?,?,?,?)",kCQSight];//时间不能在这里添加 必须要在executeUpdate里面添加
    for (Sight *aSight in sightList) {
        if (![self.database executeUpdate:sqlStr,aSight.sightID,aSight.sightTypeID,aSight.sightName,aSight.sightBrief,aSight.sightImageLink,aSight.sightCoordinate,date]) {
            NSLog(@"插入景点出错,SQL语句是%@\n景点名称是:%@",sqlStr,aSight.sightName);
        }
    }
}
-(NSMutableArray *)readSightListByType:(SightType *)theType {
    if (!theType) {
        return nil;
    }
    NSMutableArray *array = [NSMutableArray array];
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@ where sightTypeID = ?",kCQSight];
    
    FMResultSet *result = [self.database executeQuery:sqlStr,theType.typeID];
    
    while ([result next]) {
        Sight *theSight = [Sight new];
        theSight.sightID = @([result intForColumn:@"sightID"]);
        theSight.sightTypeID = @([result intForColumn:@"sightTypeID"]);
        theSight.sightName = [result stringForColumn:@"sightName"];;
        theSight.sightBrief = [result stringForColumn:@"sightBrief"];
        theSight.sightImageLink = [result stringForColumn:@"sightImageLink"];
        theSight.sightCoordinate = [result stringForColumn:@"sightCoordinate"];
        theSight.date = [result dateForColumn:@"date"];
        theSight.sightImageData=[result dataForColumn:@"sightImageData"];
        theSight.sightHTMLString = [result stringForColumn:@"sightHTMLString"];
        [array addObject:theSight];
    }
    return array;
}

- (void)updateSight:(Sight *)aSight {
    if (!aSight) {
        return;
    }
    NSDate *date = [NSDate date];
    NSString *sqlStr = [NSString stringWithFormat:@"update %@ set sightID=?, sightTypeID=?, sightName=?, sightBrief=?, sightImageLink=?, sightImageData=?, sightCoordinate=?, sightHTMLString=?, date=? where sightID=%@ ",kCQSight,aSight.sightID];
    if (![self.database executeUpdate:sqlStr,aSight.sightID, aSight.sightTypeID,aSight.sightName,aSight.sightBrief,aSight.sightImageLink, aSight.sightImageData, aSight.sightCoordinate, aSight.sightHTMLString,date]) {
        NSLog(@"修改景点出错，SQL语句是%@\n景点名称是%@",sqlStr,aSight.sightName);
    }
}
//* 景点个数 */
- (NSInteger)numberOfSight {
    NSString *sqlStr = [NSString stringWithFormat:@"select count(*) from %@",kCQSight];
    return  [self.database intForQuery:sqlStr];
}
- (NSInteger)random {
    self.previousRandom = kRandom;
    self.currentRandom = kRandom;
    while (self.currentRandom != self.previousRandom) {
        return self.currentRandom;
    }
    return 0;
}
//- (NSMutableArray *)randomSightOfNumber:(NSInteger)numberOfSight {
//    NSMutableArray *returnArray = [NSMutableArray arrayWithCapacity:0];
//    if (numberOfSight < 1) {
//        return returnArray;
//    }
//    if ([self numberOfSight] < numberOfSight) {
//        <#statements#>
//    }
//    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@ limit ?,1",kCQSight];
//    while (returnArray.count != numberOfSight) {
//        self.previousRandom = [self random];
//        FMResultSet *result = [self.database executeQuery:sqlStr,@([self random])];
//    }
//}
- (NSMutableArray *)randomSightOfNumber:(NSInteger)numberOfSihgts {
    // 获取已有的景点信息数目
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT count(*) FROM %@",kCQSight];
    int total = [self.database intForQuery:sqlStr];
    if (total == 0) {
        return nil;
    }
    if (total<numberOfSihgts) numberOfSihgts = total;
    
    NSMutableArray *totalArray = [[NSMutableArray alloc] init];
    while (totalArray.count != numberOfSihgts) {
        // 随机景点
        int n = arc4random()%total;
        //* OFFSET 基准点 从那个开始取 */
        NSString *str = [NSString stringWithFormat:@"SELECT * FROM %@ LIMIT 1 OFFSET %d",kCQSight,n];
        
        FMResultSet *result = [self.database executeQuery:str];
        
        while ([result next]) {
            Sight *sight = [Sight new];
            sight.sightTypeID = @([result intForColumn:@"sightTypeID"]);
            sight.sightID = @([result intForColumn:@"sightID"]);
            sight.sightName = [result stringForColumn:@"sightName"];;
            sight.sightBrief = [result stringForColumn:@"sightBrief"];
            sight.sightImageLink = [result stringForColumn:@"sightImageLink"];
            sight.sightCoordinate = [result stringForColumn:@"sightCoordinate"];
            sight.sightHTMLString = [result stringForColumn:@"sightHTMLString"];
            sight.sightImageData=[result dataForColumn:@"sightImageData"];
            
            if (totalArray.count==0) {
                [totalArray addObject:sight];
            }else {
                BOOL isFound = NO;
                for (Sight *oldsight in totalArray) {
                    if (sight.sightID == oldsight.sightID) {
                        isFound = YES;
                        break;
                    }
                }
                
                if (isFound == NO) {
                    [totalArray addObject:sight];
                }
            }
        }
    }
    
    return totalArray;
}

@end

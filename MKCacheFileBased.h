//
//  MKCacheFileBased.h
//

#ifndef MKCacheFileBased_h
#define MKCacheFileBased_h

#import <Foundation/Foundation.h>

@interface MKCacheFileBased : NSObject

#pragma mark - Default static methods

+(NSString*)cacheDirectoryName; // Method to override to use a different directory
+(NSString*)cacheDirectoryPathForCacheDirectoryName:(NSString*)cacheDirectoryName;

// Deletions in cache
+(void)resetCache;
+(void)deleteCacheOlderThanDate:(NSDate*)oldestDate;
+(void)deleteCacheOlderThanTime:(NSTimeInterval)maxAge;
+(void)deleteDataForKey:(NSString*)key;

// Use of data
+(void)updateCacheDateForKey:(NSString*)key;
+(BOOL)doesDataExistForKey:(NSString*)key;
+(void)setData:(NSData*)data forKey:(NSString*)key;
+(void)setDataFromString:(NSString*)string forKey:(NSString*)key;
+(void)setDataFromString:(NSString*)string forIntegerKey:(NSInteger)key;
+(void)setData:(NSData*)data forIntegerKey:(NSInteger)key;
+(NSData*)getDataForKey:(NSString*)key;
+(NSData*)getDataForKey:(NSString*)key notOlderThanDate:(NSDate*)oldestDate;
+(NSData*)getDataForKey:(NSString*)key notOlderThanTime:(NSTimeInterval)maxAge;

#pragma mark - Generic static methods

// Deletions in cache
+(void)resetCacheWithCachePath:(NSString*)cachePath;
+(void)deleteCacheOlderThanDate:(NSDate*)oldestDate withCachePath:(NSString*)cachePath;
+(void)deleteCacheOlderThanTime:(NSTimeInterval)maxAge withCachePath:(NSString*)cachePath;
+(void)deleteDataForKey:(NSString*)key withCachePath:(NSString*)cachePath;

// Use of data
+(void)updateCacheDateForKey:(NSString*)key withCachePath:(NSString*)cachePath;
+(BOOL)doesDataExistForKey:(NSString*)key withCachePath:(NSString*)cachePath;
+(void)setData:(NSData*)data forKey:(NSString*)key withCachePath:(NSString*)cachePath;
+(void)setDataFromString:(NSString*)string forKey:(NSString*)key withCachePath:(NSString*)cachePath;
+(void)setDataFromString:(NSString*)string forIntegerKey:(NSInteger)key withCachePath:(NSString*)cachePath;
+(void)setData:(NSData*)data forIntegerKey:(NSInteger)key withCachePath:(NSString*)cachePath;
+(NSData*)getDataForKey:(NSString*)key withCachePath:(NSString*)cachePath;
+(NSData*)getDataForKey:(NSString*)key notOlderThanDate:(NSDate*)oldestDate withCachePath:(NSString*)cachePath;
+(NSData*)getDataForKey:(NSString*)key notOlderThanTime:(NSTimeInterval)maxAge withCachePath:(NSString*)cachePath;
+(NSData*)getDataFromMainBundleForKey:(NSString*)key withCacheName:(NSString*)cacheName;
+(NSData*)getDataOrMainBundleFileForKey:(NSString*)key withCacheName:(NSString*)cacheName;

#pragma mark - Instance specific

-(instancetype)init;
-(instancetype)initWithCacheDirectoryName:(NSString*)cacheDirectoryName;
-(instancetype)initWithCacheDirectoryName:(NSString*)cacheDirectoryName andValidityDuration:(NSTimeInterval)cacheValidityDuration;

-(NSString*)cacheDirectoryName;
-(NSString*)cacheDirectoryPath;

// Deletions in cache
-(void)resetCache;
-(void)deleteCacheOlderThanDate:(NSDate*)oldestDate;
-(void)deleteCacheOlderThanTime:(NSTimeInterval)maxAge;
-(void)deleteDataForKey:(NSString*)key;

// Use of data
-(void)updateCacheDateForKey:(NSString*)key;
-(BOOL)doesDataExistForKey:(NSString*)key;
-(void)setData:(NSData*)data forKey:(NSString*)key;
-(void)setDataFromString:(NSString*)string forKey:(NSString*)key;
-(void)setDataFromString:(NSString*)string forIntegerKey:(NSInteger)key;
-(void)setData:(NSData*)data forIntegerKey:(NSInteger)key;
-(NSData*)getDataForKey:(NSString*)key;
-(NSData*)getDataForKey:(NSString*)key notOlderThanDate:(NSDate*)oldestDate;
-(NSData*)getDataForKey:(NSString*)key notOlderThanTime:(NSTimeInterval)maxAge;
-(NSData*)getDataNotTooOldForKey:(NSString*)key;
-(NSData*)getDataFromMainBundleForKey:(NSString*)key;
-(NSData*)getDataOrMainBundleFileForKey:(NSString*)key;

@end

#endif

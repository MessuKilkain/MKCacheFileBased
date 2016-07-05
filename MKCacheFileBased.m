//
//  MKCacheFileBased.m
//

#import "MKCacheFileBased.h"

@implementation MKCacheFileBased
{
    NSString* _cacheDirectoryName;
    BOOL _useCacheValidityDuration;
    NSTimeInterval _cacheValidityDuration;
}

#pragma mark - CacheDirectoryPath

+(NSString*)cacheDirectoryPath
{
    return [self cacheDirectoryPathForCacheDirectoryName:[self cacheDirectoryName]];
}
+(NSString*)cacheDirectoryPathForCacheDirectoryName:(NSString*)cacheDirectoryName
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    cacheDirectory = [cacheDirectory stringByAppendingPathComponent:cacheDirectoryName];
    return cacheDirectory;
}

#pragma mark - Default static methods

+(NSString*)cacheDirectoryName // Method to override to use a different directory
{
    return @"defaultFileBasedCache";
}

#pragma mark - Default static methods - Deletion of cache

+(void)resetCache
{
    [self resetCacheWithCachePath:[self cacheDirectoryPath]];
}
+(void)deleteCacheOlderThanDate:(NSDate*)oldestDate
{
    [self deleteCacheOlderThanDate:oldestDate withCachePath:[self cacheDirectoryPath]];
}
+(void)deleteCacheOlderThanTime:(NSTimeInterval)maxAge
{
    [self deleteCacheOlderThanTime:maxAge withCachePath:[self cacheDirectoryPath]];
}
+(void)deleteDataForKey:(NSString*)key
{
    [self deleteDataForKey:key withCachePath:[self cacheDirectoryPath]];
}

#pragma mark - Default static methods - Use of data

+(void)updateCacheDateForKey:(NSString*)key
{
    [self updateCacheDateForKey:key withCachePath:[self cacheDirectoryPath]];
}
+(BOOL)doesDataExistForKey:(NSString*)key
{
    return [self doesDataExistForKey:key withCachePath:[self cacheDirectoryPath]];
}
+(NSURL*)localUrlForKey:(NSString*)key
{
    return [self localUrlForKey:key withCachePath:[self cacheDirectoryPath]];
}
+(void)setData:(NSData*)data forKey:(NSString*)key
{
    [self setData:data forKey:key withCachePath:[self cacheDirectoryPath]];
}
+(void)setDataFromString:(NSString*)string forKey:(NSString*)key
{
    [self setDataFromString:string forKey:key withCachePath:[self cacheDirectoryPath]];
}
+(void)setDataFromString:(NSString*)string forIntegerKey:(NSInteger)key
{
    [self setDataFromString:string forIntegerKey:key withCachePath:[self cacheDirectoryPath]];
}
+(void)setData:(NSData*)data forIntegerKey:(NSInteger)key
{
    [self setData:data forIntegerKey:key withCachePath:[self cacheDirectoryPath]];
}
+(NSData*)getDataForKey:(NSString*)key
{
    return [self getDataForKey:key withCachePath:[self cacheDirectoryPath]];
}
+(NSData*)getDataForKey:(NSString*)key notOlderThanDate:(NSDate*)oldestDate
{
    return [self getDataForKey:key notOlderThanDate:oldestDate withCachePath:[self cacheDirectoryPath]];
}
+(NSData*)getDataForKey:(NSString*)key notOlderThanTime:(NSTimeInterval)maxAge
{
    return [self getDataForKey:key notOlderThanTime:maxAge withCachePath:[self cacheDirectoryPath]];
}

#pragma mark - Generic static methods

#pragma mark - Generic static methods - Deletion of cache

+(void)resetCacheWithCachePath:(NSString*)cachePath
{
    NSError* error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if( ![fileManager removeItemAtPath:cachePath error:&error] )
    {
        // NSLog(@"ERROR : %@",[error description]);
    }
}
+(void)deleteCacheOlderThanDate:(NSDate*)oldestDate withCachePath:(NSString*)cachePath
{
    [self deleteCacheOlderThanTime:-[oldestDate timeIntervalSinceNow] withCachePath:cachePath];
}
+(void)deleteCacheOlderThanTime:(NSTimeInterval)maxAge withCachePath:(NSString*)cachePath
{
    NSError* error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = YES;
    if( [fileManager fileExistsAtPath:cachePath isDirectory:&isDir] )
    {
        NSArray *fileNames = [fileManager contentsOfDirectoryAtPath:cachePath error:&error];
        
        if( error != nil )
        {
            // NSLog(@"ERROR : %@",[error description]);
        }
        else
        {
            for( NSString* fileName in fileNames )
            {
//                NSLog(@"fileName : %@",fileName);
                NSError* attributeError = nil;
                NSString* filePath = [cachePath stringByAppendingPathComponent:fileName];
                NSDictionary* attributesOfFile = [fileManager attributesOfItemAtPath:filePath error:&error];
                if( attributeError != nil )
                {
                    // NSLog(@"ERROR getting attributes of file : %@",[attributeError description]);
                }
                else
                {
                    NSDate *modificationDate = [attributesOfFile objectForKey:NSFileModificationDate];
                    if(
                       modificationDate != nil
                       && [modificationDate isKindOfClass:[NSDate class]]
                       )
                    {
                        NSTimeInterval fileAge = -[modificationDate timeIntervalSinceNow];
                        if( fileAge > maxAge )
                        {
                            NSError* deleteFileError = nil;
                            if( ![fileManager removeItemAtPath:filePath error:&deleteFileError] )
                            {
                                // NSLog(@"ERROR : %@",[deleteFileError description]);
                            }
                        }
                    }
                    else
                    {
                        // NSLog(@"Wrong date for file in cache");
                    }
                }
            }
        }
    }
    else
    {
        // NSLog(@"cacheDirectory does not exist at path : %@",cachePath);
    }
}
+(void)deleteDataForKey:(NSString*)key withCachePath:(NSString*)cachePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [cachePath stringByAppendingPathComponent:key];
    if( [fileManager fileExistsAtPath:filePath] )
    {
        NSError* error = nil;
        if( ![fileManager removeItemAtPath:filePath error:&error] )
        {
            // NSLog(@"ERROR : %@",[error description]);
        }
    }
    else
    {
        // NSLog(@"File does not exist");
    }
}

#pragma mark - Generic static methods - Use of data cache

+(void)updateCacheDateForKey:(NSString*)key withCachePath:(NSString*)cachePath
{
//    NSLog(@"update cache(%@) file for key: %@", cachePath, key);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [cachePath stringByAppendingPathComponent:key];
    if( [fileManager fileExistsAtPath:filePath] )
    {
        NSError* error = nil;
        NSDictionary* attributesToModify = [NSDictionary dictionaryWithObject:[NSDate date] forKey:NSFileModificationDate];
        if( ![fileManager setAttributes:attributesToModify ofItemAtPath:filePath error:&error] )
        {
            // NSLog(@"Error changing modification date of file cached with key(%@) : %@",key,[error description]);
        }
    }
}
+(BOOL)doesDataExistForKey:(NSString*)key withCachePath:(NSString*)cachePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [cachePath stringByAppendingPathComponent:key];
    return [fileManager fileExistsAtPath:filePath];
}
+(NSURL*)localUrlForKey:(NSString*)key withCachePath:(NSString*)cachePath
{
    NSString *filePath = [cachePath stringByAppendingPathComponent:key];
    return [NSURL fileURLWithPath:filePath];
}
+(void)setData:(NSData*)data forKey:(NSString*)key withCachePath:(NSString*)cachePath
{
//    NSLog(@"set cache(%@) file for key: %@", cachePath, key);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [cachePath stringByAppendingPathComponent:key];
//    NSLog(@"Data : %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//    NSLog(@"filePath : %@", filePath);
    BOOL isDir = YES;
    if( ![fileManager fileExistsAtPath:cachePath isDirectory:&isDir] )
    {
        [fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    @try {
        NSError *error = nil;
        [data writeToFile:filePath options:NSDataWritingAtomic error:&error];
        if( error != nil )
        {
            // NSLog(@"ERROR: %@",[error description]);
        }
    }
    @catch (NSException * e)
    {
        // NSLog(@"ERROR: Exception %@",[e description]);
    }
}
+(void)setDataFromString:(NSString*)string forKey:(NSString*)key withCachePath:(NSString*)cachePath
{
    if( string != nil )
    {
        [self setData:[string dataUsingEncoding:NSUTF8StringEncoding] forKey:key withCachePath:cachePath];
    }
}
+(void)setDataFromString:(NSString*)string forIntegerKey:(NSInteger)key withCachePath:(NSString*)cachePath
{
    [self setDataFromString:string forKey:[NSString stringWithFormat:@"%ld",(long)key] withCachePath:cachePath];
}
+(void)setData:(NSData*)data forIntegerKey:(NSInteger)key withCachePath:(NSString*)cachePath
{
    [self setData:data forKey:[NSString stringWithFormat:@"%ld",(long)key] withCachePath:cachePath];
}
+(NSData*)getDataForKey:(NSString*)key withCachePath:(NSString*)cachePath
{
//    NSLog(@"get cache(%@) file for key: %@", cachePath, key);
    
    NSData* data = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [cachePath stringByAppendingPathComponent:key];
    if ( [fileManager fileExistsAtPath:filePath] )
    {
//        NSLog(@"cache exists!");
        @try {
            NSError *error = nil;
            data = [NSData dataWithContentsOfFile:filePath options:(NSDataReadingMappedIfSafe) error:&error];
            if( error != nil )
            {
                // NSLog(@"ERROR: %@",[error description]);
            }
        }
        @catch (NSException * e)
        {
            // NSLog(@"ERROR: Exception %@",[e description]);
        }
    }
    else
    {
        // NSLog(@"cache does NOT exist for key(%@) in path(%@)!",key,cachePath);
    }
    return data;
}
+(NSData*)getDataForKey:(NSString*)key notOlderThanDate:(NSDate*)oldestDate withCachePath:(NSString*)cachePath
{
    return [self getDataForKey:key notOlderThanTime:-[oldestDate timeIntervalSinceNow] withCachePath:cachePath];
}
+(NSData*)getDataForKey:(NSString*)key notOlderThanTime:(NSTimeInterval)maxAge withCachePath:(NSString*)cachePath
{
//    NSLog(@"get cache(%@) file for key: %@ not older than : %f", cachePath, key, maxAge);
    
    NSData* data = nil;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [cachePath stringByAppendingPathComponent:key];
    if ( [fileManager fileExistsAtPath:filePath] )
    {
//        NSLog(@"cache exists!");
        NSError* error = nil;
        NSDictionary* attributesOfFile = [fileManager attributesOfItemAtPath:filePath error:&error];
        if( error != nil )
        {
            // NSLog(@"ERROR getting attributes of file : %@",[error description]);
        }
        else
        {
            NSDate *modificationDate = [attributesOfFile objectForKey:NSFileModificationDate];
//            NSLog(@"modificationDate : %@",[modificationDate description]);
//            NSLog(@"currentDate : %@",[[NSDate date] description]);
//            NSLog(@"timeIntervalSinceNow : %lf",[modificationDate timeIntervalSinceNow]);
            if(
               modificationDate != nil
               && [modificationDate isKindOfClass:[NSDate class]]
               )
            {
                NSTimeInterval fileAge = -[modificationDate timeIntervalSinceNow];
//                if( fileAge < 0 )
//                {
//                    fileAge = -fileAge;
//                }
                if( fileAge <= maxAge )
                {
                    data = [NSData dataWithContentsOfFile:filePath];
                }
            }
            else
            {
                // NSLog(@"Wrong date for file in cache");
            }
        }
    }
    return data;
}
+(NSData*)getDataFromMainBundleForKey:(NSString*)key withCacheName:(NSString*)cacheName
{
    NSData* data = nil;
    
    NSString* resourceName = [NSString stringWithFormat:@"%@_%@", cacheName, key];
    NSString* filePath = [[NSBundle mainBundle] pathForResource:resourceName ofType:nil];
//    NSLog(@"get file(%@ at path : %@) from mainBundle for cache(%@) file for key: %@", resourceName, (filePath!=nil?filePath:@"nil"), cacheName, key);
    if(
       // Not nil nor empty
       filePath != nil
       && [[filePath stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0
       )
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ( [fileManager fileExistsAtPath:filePath] )
        {
//            NSLog(@"File exists!");
            @try {
                NSError *error = nil;
                data = [NSData dataWithContentsOfFile:filePath options:(NSDataReadingMappedIfSafe) error:&error];
                if( error != nil )
                {
                    // NSLog(@"ERROR: %@",[error description]);
                }
            }
            @catch (NSException * e)
            {
                // NSLog(@"ERROR: Exception %@",[e description]);
            }
        }
        else
        {
            // NSLog(@"File does NOT exist!");
        }
    }
    else
    {
        // NSLog(@"mainBundle returned an empty path");
    }
    
//    NSLog(@"fileContent : %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    return data;
}
+(NSData*)getDataOrMainBundleFileForKey:(NSString*)key withCacheName:(NSString*)cacheName
{
    NSString* cachePath = [self cacheDirectoryPathForCacheDirectoryName:cacheName];
    NSData* data = [self getDataForKey:key withCachePath:cachePath];
    if( data == nil )
    {
        data = [self getDataFromMainBundleForKey:key withCacheName:cacheName];
    }
    return data;
}

#pragma mark - Instance specific methods

-(instancetype)init
{
    self = [self initWithCacheDirectoryName:[[self class] cacheDirectoryName]];
    return self;
}

-(instancetype)initWithCacheDirectoryName:(NSString*)cacheDirectoryName
{
    self = [super init];
    if (self) {
        _cacheDirectoryName = cacheDirectoryName;
        _useCacheValidityDuration = NO;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *cachePath = [self cacheDirectoryPath];
        BOOL isDir = YES;
        if( ![fileManager fileExistsAtPath:cachePath isDirectory:&isDir] )
        {
            [fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return self;
}

-(instancetype)initWithCacheDirectoryName:(NSString*)cacheDirectoryName andValidityDuration:(NSTimeInterval)cacheValidityDuration
{
    self = [super init];
    if (self) {
        _cacheDirectoryName = cacheDirectoryName;
        _useCacheValidityDuration = YES;
        _cacheValidityDuration = cacheValidityDuration;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *cachePath = [self cacheDirectoryPath];
        BOOL isDir = YES;
        if( ![fileManager fileExistsAtPath:cachePath isDirectory:&isDir] )
        {
            [fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return self;
}

-(NSString*)cacheDirectoryName
{
    return _cacheDirectoryName;
}

-(NSString*)cacheDirectoryPath
{
    return [[self class] cacheDirectoryPathForCacheDirectoryName:[self cacheDirectoryName]];
}

#pragma mark - Instance specific methods - Deletion of cache

-(void)resetCache
{
    [[self class] resetCacheWithCachePath:[self cacheDirectoryPath]];
}
-(void)deleteCacheOlderThanDate:(NSDate*)oldestDate
{
    [[self class] deleteCacheOlderThanDate:oldestDate withCachePath:[self cacheDirectoryPath]];
}
-(void)deleteCacheOlderThanTime:(NSTimeInterval)maxAge
{
    [[self class] deleteCacheOlderThanTime:maxAge withCachePath:[self cacheDirectoryPath]];
}
-(void)deleteDataForKey:(NSString*)key
{
    [[self class] deleteDataForKey:key withCachePath:[self cacheDirectoryPath]];
}

#pragma mark - Instance specific methods - Use of data

-(void)updateCacheDateForKey:(NSString*)key
{
    [[self class] updateCacheDateForKey:key withCachePath:[self cacheDirectoryPath]];
}
-(BOOL)doesDataExistForKey:(NSString*)key
{
    return [[self class] doesDataExistForKey:key withCachePath:[self cacheDirectoryPath]];
}
-(NSURL*)localUrlForKey:(NSString*)key
{
    return [[self class] localUrlForKey:key withCachePath:[self cacheDirectoryPath]];
}
-(void)setData:(NSData*)data forKey:(NSString*)key
{
    [[self class] setData:data forKey:key withCachePath:[self cacheDirectoryPath]];
}
-(void)setDataFromString:(NSString*)string forKey:(NSString*)key
{
    [[self class] setDataFromString:string forKey:key withCachePath:[self cacheDirectoryPath]];
}
-(void)setDataFromString:(NSString*)string forIntegerKey:(NSInteger)key
{
    [[self class] setDataFromString:string forIntegerKey:key withCachePath:[self cacheDirectoryPath]];
}
-(void)setData:(NSData*)data forIntegerKey:(NSInteger)key
{
    [[self class] setData:data forIntegerKey:key withCachePath:[self cacheDirectoryPath]];
}
-(NSData*)getDataForKey:(NSString*)key
{
    return [[self class] getDataForKey:key withCachePath:[self cacheDirectoryPath]];
}
-(NSData*)getDataForKey:(NSString*)key notOlderThanDate:(NSDate*)oldestDate
{
    return [[self class] getDataForKey:key notOlderThanDate:oldestDate withCachePath:[self cacheDirectoryPath]];
}
-(NSData*)getDataForKey:(NSString*)key notOlderThanTime:(NSTimeInterval)maxAge
{
    return [[self class] getDataForKey:key notOlderThanTime:maxAge withCachePath:[self cacheDirectoryPath]];
}
-(NSData *)getDataNotTooOldForKey:(NSString *)key
{
    if( _useCacheValidityDuration )
    {
        return [self getDataForKey:key notOlderThanTime:_cacheValidityDuration];
    }
    else
    {
        return [self getDataForKey:key];
    }
}
-(NSData*)getDataFromMainBundleForKey:(NSString*)key
{
    return [[self class] getDataFromMainBundleForKey:key withCacheName:[self cacheDirectoryName]];
}
-(NSData*)getDataOrMainBundleFileForKey:(NSString*)key
{
    return [[self class] getDataOrMainBundleFileForKey:key withCacheName:[self cacheDirectoryName]];
}

@end

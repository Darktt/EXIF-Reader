// DTFileController.m
// 
// Copyright (c) 2013年 Darktt
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//   http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//#define DEBUG_MODE

#import "DTFileController.h"

typedef void (^QueueBlock) (void);

@implementation DTFileController

static DTFileController *singleton = nil;

+ (DTInstancetype)mainController
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [DTFileController new];
    });
    
    return singleton;
}

#pragma mark - File Checking Methods
#pragma mark Check File Name Legally

- (BOOL)checkFileNameLegallyWithFileName:(NSString *)fileName
{
    NSCharacterSet *illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/|\\:?<>*\""];
    NSString *newFileName = [[fileName componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""];
    
    return [newFileName isEqualToString:fileName];
}

#pragma mark Check File Is Exist

- (BOOL)fileExistAtPath:(NSString *)path
{
    NSURL *fileURL = [NSURL URLWithString:path];
    if ([fileURL isFileURL]) {
        path = [fileURL path];
    }
    
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

- (BOOL)fileExistAtURL:(NSURL *)url
{
    if (![url isFileURL]) {
        [NSException raise:NSInvalidArgumentException format:@"%@-line %d: URL pattern error, not file URL", [self class], __LINE__];
    }
    
    NSString *path = [url path];
    
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

#pragma mark Check Current Device Storage Space

- (NSString *)getFreeSpaceAtPath:(NSString *)path converSizeUnit:(BOOL)conver
{
    NSError *error = nil;
    NSDictionary *fileSystemInfomation = [[NSFileManager defaultManager] attributesOfFileSystemForPath:path error:&error];
    
    if (error != nil) {
        NSLog(@"%s **Error**: %@", __func__, error);
    }
    
    NSNumber *freeSpace = [fileSystemInfomation objectForKey:NSFileSystemFreeSize];
    
    NSString *size = [freeSpace stringValue];
    
    if (conver) {
        size = [self convertFileSizeWithSize:freeSpace];
    }
    
    return size;
}

- (NSNumber *)checkStorageSpace
{
    NSString *path = [self documentPath];
    
    NSString *freeSpace = [self getFreeSpaceAtPath:path converSizeUnit:NO];
    
    NSNumber *freeSpaceNumber = [NSNumber numberWithLongLong:[freeSpace longLongValue]];
    
    return freeSpaceNumber;
}

- (BOOL)checkSpaceEnoughWithFilePath:(NSString *)path
{
    NSNumber *currentSpace = [self checkStorageSpace];
    NSString *fileSizeString = [self getFileSizeAtPath:path converSizeUnit:NO];
    NSNumber *fileSize = [NSNumber numberWithLongLong:[fileSizeString longLongValue]];
    
#ifdef DEBUG_MODE
    
    NSLog(@"Free : %@, File Size : %@", currentSpace, fileSize);
    
#endif
    
    return ([currentSpace longLongValue] > [fileSize longLongValue]);
}

- (BOOL)checkSpaceEnoughWithFileSize:(NSNumber *)size
{
    NSNumber *currentSpace = [self checkStorageSpace];
    
//    NSLog(@"Free : %@, File Size : %@", currentSpace, size);
    
    return ([currentSpace longLongValue] > [size longLongValue]) ? YES : NO;
}

#pragma mark - Get FilePath Methods

- (NSString *)currentApplicationPath
{
    NSString *path = [[NSBundle mainBundle] bundlePath];
    
    return path;
}

- (NSString *)currentApplicationPathWithFileName:(NSString *)fileName
{
    NSString *path = [self currentApplicationPath];
    NSString *pathWithDirectory = [path stringByAppendingPathComponent:fileName];
    
    return pathWithDirectory;
}

- (NSString *)documentPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
#ifdef DEBUG_MODE
    
    NSLog(@"Path: %@", paths);
    
#endif
    
    NSString *documentPath = [paths objectAtIndex:0];

    return documentPath;
}

- (NSString *)documentPathWithFileName:(NSString *)fileName
{
    NSString *path = [self documentPath];
    
    return [path stringByAppendingPathComponent:fileName];
}

- (NSString *)cachesPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
#ifdef DEBUG_MODE
    
    NSLog(@"Path: %@", paths);
    
#endif
    
    NSString *cachesPath = [paths objectAtIndex:0];

    return cachesPath;
}

- (NSString *)cachesPathWithFileName:(NSString *)fileName
{
    NSString *path = [self cachesPath];
    
    return [path stringByAppendingPathComponent:fileName];
}

- (NSString *)libraryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    
#ifdef DEBUG_MODE
    
    NSLog(@"Path: %@", paths);
    
#endif
    
    NSString *libDir = [paths objectAtIndex:0];
    
    return libDir;
}

- (NSString *)temporaryPath
{
    return NSTemporaryDirectory();
}

#pragma mark - Read File

- (NSString *)readStringFromPath:(NSString *)filePath
{
    
#ifdef DEBUG_MODE
    
    NSLog(@"Read Path: %@",filePath);
    
#endif

    if ([self fileExistAtPath:filePath]) {
        NSString *string = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        return string;
    } else {
        return nil;
    }
}

- (NSDictionary *)readDictionaryFromFilePath:(NSString *)filePath
{
    
#ifdef DEBUG_MODE
    
    NSLog(@"Read Path: %@",filePath);
    
#endif
    
    if ([self fileExistAtPath:filePath]) {
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
        return dic;
    } else {
        return nil;
    }
}

- (NSArray *)readArrayFromPath:(NSString *)filePath
{
    
#ifdef DEBUG_MODE
    
    NSLog(@"Read Path: %@",filePath);
    
#endif
    
    if ([self fileExistAtPath:filePath]) {
        NSArray *array = [NSArray arrayWithContentsOfFile:filePath];
        return array;
    } else {
        return nil;
    }
}


#pragma mark - Write Data To File

- (void)writeStringFile:(NSString *)string withFilePath:(NSString *)filePath
{
    
#ifdef DEBUG_MODE
    
    NSLog(@"Write Path: %@",filePath);
    
#endif
    
    [string writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void)writeArrayFile:(NSArray *)array withFilePath:(NSString *)filePath
{
    
#ifdef DEBUG_MODE
    
    NSLog(@"Write Path: %@",filePath);
    
#endif
    
    [array writeToFile:filePath atomically:YES];
}

- (void)writeDictionaryToFile:(NSDictionary *)dictionary withFilePath:(NSString *)filePath
{
    
#ifdef DEBUG_MODE
    
    NSLog(@"Write Path: %@",filePath);
    
#endif
    
    [dictionary writeToFile:filePath atomically:YES];
}

#pragma mark - Create File Or Directory

- (BOOL)createDirectoryUnderDocumentWithDirectoryName:(NSString *)directory
{

    NSString *folderPathUnderDocument = [[self documentPath] stringByAppendingPathComponent:directory];
    
#ifdef DEBUG_MODE
    
    NSLog(@"Directory Path: %@",folderPathUnderDocument);
    
#endif
    
    return [self createDirectoryAtPath:folderPathUnderDocument];
}

- (BOOL)createDirectoryUnderCachesWithDirectoryName:(NSString *)directory;
{
    NSString *folderPathUnderCaches = [[self cachesPath] stringByAppendingPathComponent:directory];
    
#ifdef DEBUG_MODE
    
    NSLog(@"Directory Path: %@",folderPathUnderCaches);
    
#endif
    
    return [self createDirectoryAtPath:folderPathUnderCaches];
}

- (BOOL)createDirectoryAtPath:(NSString *)path
{
    NSError *error = nil;
    
    // If file already exist, abort it.
    if ([self fileExistAtPath:path]) {
        return NO;
    }
    
    if (![[NSFileManager defaultManager] createDirectoryAtPath:path
                                   withIntermediateDirectories:NO
                                                    attributes:nil
                                                         error:&error]) {
        NSLog(@"%s **Error**: %@", __func__, error);
        
        // Create failed
        return NO;
    }
    
    return YES;
}

- (BOOL)createFile:(NSString *)fileName directoryUnderDocument:(NSString *)directory
{
    if (directory == nil || [directory isEqualToString:@""]) {
        
        NSString *localFilePath = [[self documentPath] stringByAppendingPathComponent:fileName];
        
#ifdef DEBUG_MODE
        
        NSLog(@"File Path: %@",localFilePath);
        
#endif
        
        // If file already exist, abort it.
        if ([self fileExistAtPath:localFilePath]) {
            return NO;
        }
        
        [self createFileWithPath:localFilePath];
        
        // Check cteate file is complete
        return [self fileExistAtPath:localFilePath];
    }
    
    NSString *path = [self documentPathWithFileName:[directory stringByAppendingPathComponent:fileName]];
    
#ifdef DEBUG_MODE
    
    NSLog(@"File Path: %@",path);
    
#endif
    
    // If file already exist, abort it.
    if ([self fileExistAtPath:path]) {
        return NO;
    }
    
    if ([self createDirectoryUnderDocumentWithDirectoryName:directory]) {
        [self createFileWithPath:path];
        
        // Check cteate file is complete
        return [self fileExistAtPath:path];
    }
    
    return NO;
}

- (BOOL)createFileWithPath:(NSString *)path
{
    // If file already exist, abort it.
    if ([self fileExistAtPath:path]) {
        return NO;
    }
    
    return [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
}

#pragma mark - Get File List In Directory

- (NSArray *)filesOfCurrentDirectoryName:(NSString *)directoryName
{
    NSString *path = [self currentApplicationPathWithFileName:directoryName];
    NSArray *files = [self filesWithDirectoryPath:path];
    
    return files;
}

- (NSArray *)filesWithDirectoryPath:(NSString *)path
{
    NSError *error = nil;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
    
    if (error != nil) {
        NSLog(@"%s **Error**: %@", __func__, error);
    }
    
    return files;
}

#pragma mark Add File Path On Files

- (NSArray *)convertFullPathWithFiles:(NSArray *)files path:(NSString *)path
{
    NSMutableArray *convertedFiles = [NSMutableArray array];
    
    void (^block) (NSString *, NSUInteger, BOOL *) = ^(NSString *file, NSUInteger idx, BOOL *stop){
        NSString *fullPath = [path stringByAppendingPathComponent:file];
        
        [convertedFiles addObject:fullPath];
    };
    
    [files enumerateObjectsUsingBlock:block];
    
    return convertedFiles;
}

#pragma mark - File Operation
#pragma mark Remove File

- (BOOL)removeFileAtPath:(NSString *)path
{
    NSError *error = nil;
    BOOL isRemove = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    
    if (error != nil) {
        NSLog(@"%s **Error**: %@", __func__, error);
    }
    
    return isRemove;
}

#pragma mark Copy File

- (BOOL)copyFileAtPath:(NSString *)path toPath:(NSString *)toPath
{
    NSError *error = nil;
    BOOL isCopy = [[NSFileManager defaultManager] copyItemAtPath:path toPath:toPath error:&error];
    
    if (error != nil) {
        NSLog(@"%s **Error**: %@", __func__, error);
    }
    
    return isCopy;
}

- (void)copyFileUseBlockAtPath:(NSString *)path toPath:(NSString *)toPath progressBlock:(DTFileProgressBlock)progressBlock completeBlock:(DTFileOperationBlock)completeBlock
{
    NSFileHandle *sourceFile = [NSFileHandle fileHandleForReadingAtPath:path];
    
    if (sourceFile == nil) {
        NSError *error = [NSError errorWithDomain:@"Source file not exist!!" code:NSFileReadNoSuchFileError userInfo:nil];
        
        if (completeBlock != nil) completeBlock(NO, error);
    }
    
    NSString *fileName = [path lastPathComponent];
    NSRange searchRange = [toPath rangeOfString:fileName options:NSCaseInsensitiveSearch];
    
    if (searchRange.location == NSNotFound) {
        toPath = [toPath stringByAppendingPathComponent:fileName];
    }
    
    NSFileHandle *destinationFile = [NSFileHandle fileHandleForWritingAtPath:toPath];
    
    if (destinationFile == nil) {
        [self createFileWithPath:toPath];
        destinationFile = [NSFileHandle fileHandleForWritingAtPath:toPath];
    }
    
    QueueBlock copyQueueBlock = ^(){
    
        NSUInteger offset = 0;
        NSUInteger chunkSize = 1024 * 100;
        long long size = [[self getFileInformationAtPath:path] fileSize];
        
        do {
            
            @autoreleasepool {
                [sourceFile seekToFileOffset:offset];
                NSData *writeData = [sourceFile readDataOfLength:chunkSize];
                
                offset += writeData.length;
                float copyPercent = (float)offset / (float)size;
                
#ifdef DEBUG_MODE
                
                NSLog(@"%@ Copy Process %.2f %%", [path lastPathComponent], copyPercent * 100);
                
#endif
                
                dispatch_async(dispatch_get_main_queue(), ^(){
                    if (progressBlock != nil) progressBlock(copyPercent);
                });
                
                [destinationFile writeData:writeData];
                writeData = nil;
            }
            
        } while (offset < size);
        
        [destinationFile synchronizeFile];
        [destinationFile closeFile];
        
#ifdef DEBUG_MODE
        
        NSLog(@"%@ Copy Finished", [path lastPathComponent]);
        
#endif
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            completeBlock(YES, nil);
        });
        
    };
    
    dispatch_queue_t copyQueue = dispatch_queue_create("Copy Queue", NULL);
    dispatch_async(copyQueue, copyQueueBlock);
}

#pragma mark Move File

- (BOOL)moveFileAtPath:(NSString *)path toPath:(NSString *)toPath
{
    NSError *error = nil;
    BOOL isMove = [[NSFileManager defaultManager] moveItemAtPath:path toPath:toPath error:&error];
    
    if (error != nil) {
        NSLog(@"%s **Error**: %@", __func__, error);
    }
    
    return isMove;
}

- (void)moveFileUseBlockAtPath:(NSString *)path toPath:(NSString *)toPath progressBlock:(DTFileProgressBlock)progressBlock completeBlock:(DTFileOperationBlock)completeBlock
{
    [self copyFileUseBlockAtPath:path toPath:toPath progressBlock:progressBlock completeBlock:^(BOOL operationDone, NSError *error) {
        if (operationDone) {
            [self removeFileAtPath:path];
            
            if (completeBlock != nil) completeBlock(operationDone, nil);
        } else {
            if (completeBlock != nil) completeBlock(operationDone, error);
        }
    }];
}

#pragma mark - Get File Information

- (NSDictionary *)getFileInformationAtPath:(NSString *)path
{
    NSError *error = nil;
    NSDictionary *fileInformation = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
    
    if (error != nil) {
        NSLog(@"%s **Error**: %@", __func__, error);
    }
    
    return fileInformation;
}

#pragma mark File Size

- (NSString *)getFileSizeAtPath:(NSString *)path converSizeUnit:(BOOL)conver
{
    NSNumber *fileSize = [[self getFileInformationAtPath:path] objectForKey:NSFileSize];
    
    NSString *size = [fileSize stringValue];
    
    if (conver) {
        size = [self convertFileSizeWithSize:fileSize];
    }
    
    return size;
}

#pragma mark File Creation Date

- (NSDate *)getFileCreationDateAtPath:(NSString *)path
{
    NSDate *creationDate = [[self getFileInformationAtPath:path] fileCreationDate];
    
    return creationDate;
}

- (NSString *)getFileCreationDateAtPath:(NSString *)path dateFormat:(NSString *)format
{
    NSDate *creationDate = [self getFileCreationDateAtPath:path];
    NSDateFormatter *dateFormat = [NSDateFormatter new];
    [dateFormat setDateFormat:format];
    
    NSString *dateString = [dateFormat stringFromDate:creationDate];
    [dateFormat release];
    
    return dateString;
}

#pragma mark File Modification Date

- (NSDate *)getFileModificationDateAtPath:(NSString *)path
{
    NSDate *modificationDate = [[self getFileInformationAtPath:path] fileModificationDate];
    
    return modificationDate;
}

- (NSString *)getFileModificationDateAtPath:(NSString *)path dateFormat:(NSString *)format
{
    NSDate *modificationDate = [self getFileModificationDateAtPath:path];
    NSDateFormatter *dateFormat = [NSDateFormatter new];
    [dateFormat setDateFormat:format];
    
    NSString *dateString = [dateFormat stringFromDate:modificationDate];
    [dateFormat release];
    
    return dateString;
}

#pragma mark - Convert File Size

- (NSString *)convertFileSizeWithSize:(NSNumber *)fileSize
{
    double _fileSize = [fileSize longLongValue];
    double baseSize = 0;
    
    NSString *fileSizeString = nil;
    NSArray *units = @[@"B", @"KB", @"MB", @"GB", @"TB", @"PB", @"EB", @"ZB", @"YB"];
    NSUInteger times = 0;
    
    // When file size less then 1024 bytes, do this function.
    if (_fileSize < pow(2, 10)) {
        fileSizeString = [NSString stringWithFormat:@"%.1f %@", _fileSize, units[times]];
        
        return fileSizeString;
    }
    
    // When file size greate then 1024 bytes.
    do {
        fileSizeString = [NSString stringWithFormat:@"%.1f %@", _fileSize / baseSize, units[times]];
        
        times += 1;
        baseSize = pow(2, times * 10);
    } while (_fileSize >= baseSize);
    
    return fileSizeString;
}

@end
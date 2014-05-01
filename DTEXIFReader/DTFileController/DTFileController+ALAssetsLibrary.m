// DTFileController+AssetsLibrary.m
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

#import "DTFileController+ALAssetsLibrary.h"

#import <AssetsLibrary/AssetsLibrary.h>

//#define DEBUG_MODE

// This catagory using AssetsLibrary framework, if not used, please comment it.
#define UES_ASSETSLIBRARY_FRAMEWORK

@implementation DTFileController (ALAssetsLibrary)

- (void)copyAsset:(ALAsset *)asset destinationPath:(NSString *)destPath progressBlock:(DTFileProgressBlock)progressBlock completeBlock:(DTFileOperationBlock)completeBlock
{
#ifdef UES_ASSETSLIBRARY_FRAMEWORK
    
    ALAssetRepresentation *representation = [asset defaultRepresentation];
    
    // Change path extension to lowercase.
    NSString *pathExtension = [[[representation filename] pathExtension] lowercaseString];
    NSString *mainFileName = [[representation filename] stringByDeletingPathExtension];
    NSString *assetFileName = [[mainFileName stringByAppendingPathExtension:pathExtension] retain];
    
    NSNumber *assetSize = [NSNumber numberWithLongLong:[representation size]];
    
    NSRange searchRange = [destPath rangeOfString:assetFileName options:NSCaseInsensitiveSearch];
    
    if (searchRange.location == NSNotFound) {
        destPath = [destPath stringByAppendingPathComponent:[assetFileName lowercaseString]];
    }
    
    dispatch_queue_t assetCopyQueue = dispatch_queue_create("Copy Asset", NULL);
    dispatch_async(assetCopyQueue, ^(){
        BOOL enoughSpace = [self checkSpaceEnoughWithFileSize:assetSize];
        
        if (!enoughSpace) {
            dispatch_async(dispatch_get_main_queue(), ^(){
                [assetFileName release];
                
                NSError *error = [NSError errorWithDomain:@"Local storage space not enought, abort operation!!!" code:NSFileWriteOutOfSpaceError userInfo:nil];
                if (completeBlock != nil) completeBlock(NO, error);
            });
            
            return;
        }
        
#ifdef DEBUG_MODE
        
        NSLog(@"Asset %@ Copy Start, Asset Size = %@", assetFileName, [self convertFileSizeWithSize:assetSize]);
        
#endif
        
        NSUInteger chunkSize = 1024 * 100;
        uint8_t *buffer = malloc(chunkSize * sizeof(uint8_t));
        
        long long size = [assetSize longLongValue];
        
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:destPath];
        
        if (fileHandle == nil) {
            [self createFileWithPath:destPath];
            fileHandle = [NSFileHandle fileHandleForWritingAtPath:destPath];
        }
        
        NSUInteger offset = 0;
        
        do {
            
            @autoreleasepool {
                NSError *error = nil;
                
                NSUInteger bytesToCopied = [representation getBytes:buffer fromOffset:offset length:chunkSize error:&error];
                
                if (error != nil) {
                    NSLog(@"%@", error);
                }
                
                offset += bytesToCopied;
                
                float copyPercent = (float)offset / (float)size;
                
#ifdef DEBUG_MODE
                
                NSLog(@"%@ Copy Process %.2f %%", assetFileName, copyPercent * 100);
                
#endif
                dispatch_async(dispatch_get_main_queue(), ^(){
                    if (progressBlock != nil) progressBlock(copyPercent);
                });
                
                NSData *data = [NSData dataWithBytes:buffer length:bytesToCopied];
                
                [fileHandle writeData:data];
                data = nil;
                
            }
            
        } while (offset < size);
        
        [fileHandle closeFile];
        
        free(buffer);
        buffer = NULL;
        
#ifdef DEBUG_MODE
        
        NSLog(@"%@ Copy Finished", assetFileName);
        
#endif
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            [assetFileName release];
            if (completeBlock != nil) completeBlock(YES, nil);
        });
    });
    
    dispatch_release(assetCopyQueue);
    
#endif
}

@end

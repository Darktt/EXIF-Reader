// DTFileController+AssetsLibrary.h
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

#import "DTFileController.h"

@class ALAsset;

@interface DTFileController (ALAssetsLibrary)

/** @brief Copy photo or video asset to destination path from camera roll, With the process progress.
 *
 * @param asset The asset from the ALAssetsLibrary.
 * @param destPath The destination path will be copy.
 * @param progressBlock The block to know the process progress.
 * @param completeBlock When process done or error, the block will respond.
 *
 * @warning This method will create new thread to complete the process.
 *
 */
- (void)copyAsset:(ALAsset *)asset
  destinationPath:(NSString *)destPath
    progressBlock:(DTFileProgressBlock)progressBlock
    completeBlock:(DTFileOperationBlock)completeBlock;

@end

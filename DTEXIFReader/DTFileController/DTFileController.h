// DTFileController.h
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

#import <Foundation/Foundation.h>

#if __has_feature(objc_instancetype)
#define DTInstancetype instancetype
#else
#define DTInstancetype id
#endif

typedef void (^DTFileProgressBlock) (float progress);
typedef void (^DTFileOperationBlock) (BOOL operationDone, NSError *error);

/// Collection all about file control medthods.
@interface DTFileController : NSObject

/** @brief Return the singleton object.
 *
 * @return The singleton of object.
 *
 */
+ (DTInstancetype)mainController;

/** @brief Check new file name is legally.
 *
 * @param fileName The new file name to check it is legally.
 *
 * @return NO, the file name is illegally; YES is legally.
 *
 */
- (BOOL)checkFileNameLegallyWithFileName:(NSString *)fileName;

// Check file is exist

/** @brief Check file is exist from file path.
 *
 * @param path The file path string.
 *
 * @return If file is exist, return YES, NO if not exist.
 *
 */
- (BOOL)fileExistAtPath:(NSString *)path;

/** @brief Check file is exist from file path url.
 *
 * @param path The file path of NSURL type.
 *
 * @warning The URL must use file scheme.
 *
 * @return If file is exist, return YES, NO otherwise.
 *
 */
- (BOOL)fileExistAtURL:(NSURL *)url;

// Check Free Space

/** @brief Get the free space of current device.
 *
 * @return The number of space value.
 */
- (NSNumber *)checkStorageSpace;

/** @brief Check the space is enough to operation from given path.
 *
 * @param path The path of file.
 *
 * @return YES, is enough to operation, NO is otherwise.
 *
 */
- (BOOL)checkSpaceEnoughWithFilePath:(NSString *)path;

/** @brief Check the space is enough to operation from given size.
 *
 * @param path The path of file.
 *
 * @return YES, is enough to operation, NO is otherwise.
 *
 */
- (BOOL)checkSpaceEnoughWithFileSize:(NSNumber *)size;

// Get Path

/** @brief Get the application's directory path.
 *
 * @return The path of application directory. <br/> eg: /var/mobile/Applications/30E6D646-48FC-4AFF-B1A9-830DB765FA41/AppName.app/.
 *
 */
- (NSString *)currentApplicationPath;

/** @brief Get the application directory path with given file name.
 *
 * @param fileName The file name to combine path.
 *
 * @return The path of application directory with file name. <br/> eg: /var/mobile/Applications/30E6D646-48FC-4AFF-B1A9-830DB765FA41/AppName.app/fileName.
 *
 */
- (NSString *)currentApplicationPathWithFileName:(NSString *)fileName;

/** @brief Get the document directory path under the application directory.
 *
 * @return The path of document directory.
 */
- (NSString *)documentPath;

/** @brief Get the document directory path with file name under the application directory.
 *
 * @param fileName The file name to combine path.
 *
 * @return The path of document directory.
 */
- (NSString *)documentPathWithFileName:(NSString *)fileName;

/** @brief Get the caches directory path under the application directory.
 *
 * @return The path of caches directory.
 */
- (NSString *)cachesPath;

/** @brief Get the caches directory path with file name under the application directory.
 *
 * @param fileName The file name to combine path.
 *
 * @return The path of caches directory.
 */
- (NSString *)cachesPathWithFileName:(NSString *)fileName;

/** @brief Get the library directory path under the application directory.
 *
 * @return The path of library directory.
 */
- (NSString *)libraryPath;

/** @brief Get the temporary directory path under the application directory.
 *
 * @return The path of temporary directory.
 */
- (NSString *)temporaryPath;

// Read Data

/** @brief Read text file to string data from given path.
 *
 * @param filePath The path to read.
 *
 * @return The string data of the text file, if file exist. nil is otherwise.
 */
- (NSString *)readStringFromPath:(NSString *)filePath;

/** @brief Read property list file to array data from given path.
 *
 * @param filePath The path to read.
 *
 * @return The array data of the property list file, if file exist. nil is otherwise.
 */
- (NSArray *)readArrayFromPath:(NSString *)filePath;

/** @brief Read property list file to dictionary data from given path.
 *
 * @param filePath The path to read.
 *
 * @return The dictionary data of the property list file, if file exist. nil is otherwise.
 */
- (NSDictionary *)readDictionaryFromFilePath:(NSString *)filePath;

// Write Data

/** @brief Write string data to text file.
 *
 * @param string The string data will write to file.
 * @param filePath The path of file to write.
 *
 * @return The write string data to file, if file not exist will create it. if file exist will overwrite.
 */
- (void)writeStringFile:(NSString *)string withFilePath:(NSString *)filePath;

/** @brief Write array data to text file.
 *
 * @param array The array data will write to file.
 * @param filePath The path of file to write.
 *
 * @return The write array data to file, if file not exist will create it. if file exist will overwrite.
 */
- (void)writeArrayFile:(NSArray *)array withFilePath:(NSString *)filePath;

/** @brief Write dictionary data to text file.
 *
 * @param dictionary The dictionary data will write to file.
 * @param filePath The path of file to write.
 *
 * @return The write dictionary data to file, if file not exist will create it. if file exist will overwrite.
 */
- (void)writeDictionaryToFile:(NSDictionary *)dictionary withFilePath:(NSString *)filePath;

// Create File Or Directory

/** @brief Create the directory under document directory with given name.
 *
 * @param directory The directory name to create.
 *
 * @return YES is directory create succeed. NO is otherwise.
 */
- (BOOL)createDirectoryUnderDocumentWithDirectoryName:(NSString *)directory;

/** @brief Create the directory under caches directory with given name.
 *
 * @param directory The directory name to create.
 *
 * @return YES is directory create succeed. NO is otherwise.
 */
- (BOOL)createDirectoryUnderCachesWithDirectoryName:(NSString *)directory;

/** @brief Create the empty file in the directory under document directory.
 *
 * @param fileName The file name to create.
 * @param directory The directory name to create.
 *
 * @return YES is directory create succeed. NO is otherwise.
 */
- (BOOL)createFile:(NSString *)fileName directoryUnderDocument:(NSString *)directory;

/** @brief Create the empty file at given path.
 *
 * @param path The path to create empty file.
 *
 * @return YES is directory create succeed. NO is otherwise.
 */
- (BOOL)createFileWithPath:(NSString *)path;

// Get File List

/** @brief Get file list on current project directory.
 *
 * @param directoryName The name of listing directory.
 *
 * @return The listed files array, the files only file name not full file path.
 */
- (NSArray *)filesOfCurrentDirectoryName:(NSString *)directoryName;

/** @brief Get file list on given path.
 *
 * @param path The path to listing.
 *
 * @return The listed files array, the files only file name not full file path.
 */
- (NSArray *)filesWithDirectoryPath:(NSString *)path;

/** @brief Convert the files to combine the path.
 *
 * @param files The files array to combine.
 * @param path The path will be combine.
 *
 * @return The combined path array.
 */
- (NSArray *)convertFullPathWithFiles:(NSArray *)files path:(NSString *)path;

// Remove File

/** @brief Remove file on given path.
 *
 * @param path The file path will be remove.
 *
 * @return YES is remove file succeed. NO is otherwise.
 */
- (BOOL)removeFileAtPath:(NSString *)path;

// Copy File

/** @brief Copy file to destination path, Without the process progress.
 *
 * @param path The source file path to copy.
 * @param toPath The destination path will be copy.
 *
 * @warning Copy the big file size file, main thread will no respond.<br/>
 Want to copy big file size file or get the process progress, please use copyFileUseBlockAtPath:toPath:progressBlock:completeBlock:.
 *
 * @return YES is file succeed to copy. NO is otherwise.
 *
 * @see copyFileUseBlockAtPath:toPath:progressBlock:completeBlock:
 */
- (BOOL)copyFileAtPath:(NSString *)path toPath:(NSString *)toPath;

/** @brief Copy file to destination path, With the process progress.
 *
 * @param path The source file path to copy.
 * @param toPath The destination path will be copy.
 * @param progressBlock The block to know the process progress.
 * @param completeBlock When process done or error, the block will respond.
 *
 * @warning This method will create new thread to complete the process.
 *
 * @see copyFileAtPath:toPath:
 */
- (void)copyFileUseBlockAtPath:(NSString *)path
                        toPath:(NSString *)toPath
                 progressBlock:(DTFileProgressBlock)progressBlock
                 completeBlock:(DTFileOperationBlock)completeBlock;

// Move File

/** @brief Move file to destination path, Without the process progress.
 *
 * @param path The source file path to move.
 * @param toPath The destination path will be move.
 *
 * @return YES is file succeed to move. NO is otherwise.
 *
 * @warning Move the big file size file, main thread will no respond.<br/>
 Want to move big file size file or get the process progress, please use moveFileUseBlockAtPath:toPath:progressBlock:completeBlock:.
 *
 * @see moveFileUseBlockAtPath:toPath:progressBlock:completeBlock:
 */
- (BOOL)moveFileAtPath:(NSString *)path toPath:(NSString *)toPath;

/** @brief Move file to destination path, With the process progress.
 *
 * @param path The source file path to move.
 * @param toPath The destination path will be move.
 * @param progressBlock The block to know the process progress.
 * @param completeBlock When process done or error, the block will respond.
 *
 * @warning This method will create new thread to complete the process.
 *
 * @see moveFileAtPath:toPath:
 */
- (void)moveFileUseBlockAtPath:(NSString *)path
                        toPath:(NSString *)toPath
                 progressBlock:(DTFileProgressBlock)progressBlock
                 completeBlock:(DTFileOperationBlock)completeBlock;

// Get File Infomation

/** @brief Get the file information for given path.
 *
 * @param path The file path to get information.
 *
 * @return The information dictionary.
 */
- (NSDictionary *)getFileInformationAtPath:(NSString *)path;

/** @brief Get the file size for given path.
 *
 * @param path The file path to get information.
 * @param conver The boolean value to conver the size unit or not.
 *
 * @return The file size.
 *
 * @see convertFileSizeWithSize:
 */
- (NSString *)getFileSizeAtPath:(NSString *)path converSizeUnit:(BOOL)conver;

/** @brief Get the file creation date for given path.
 *
 * @param path The file path to get file creation date.
 *
 * @return The raw format creation date.
 *
 * @see getFileCreationDateAtPath:dateFormat:
 */
- (NSDate *)getFileCreationDateAtPath:(NSString *)path;

/** @brief Get the file creation date for given path, and customize date format.
 *
 * @param path The file path to get file creation date.
 * @param dateFormat The date format to convert textual representations of dates and times into NSDate objects.
 *
 * @return The converted creation date.
 *
 * @see getFileCreationDateAtPath:
 */
- (NSString *)getFileCreationDateAtPath:(NSString *)path dateFormat:(NSString *)format;

/** @brief Get the file modification date for given path.
 *
 * @param path The file path to get file modification date.
 *
 * @return The raw format modification date.
 *
 * @see getFileModificationDateAtPath:dateFormat:
 */
- (NSDate *)getFileModificationDateAtPath:(NSString *)path;

/** @brief Get the file modification date for given path, and customize date format.
 *
 * @param path The file path to get file modification date.
 * @param dateFormat The date format to convert textual representations of dates and times into NSDate objects.
 *
 * @return The converted modification date.
 *
 * @see getFileModificationDateAtPath:
 */
- (NSString *)getFileModificationDateAtPath:(NSString *)path dateFormat:(NSString *)format;

// Convert File Size

/** @brief Convert the size unit for given size.
 *
 * @param fileSize The size will be convert, this size unit must be byte.
 *
 * @return The converted file size.
 */
- (NSString *)convertFileSizeWithSize:(NSNumber *)fileSize;

@end

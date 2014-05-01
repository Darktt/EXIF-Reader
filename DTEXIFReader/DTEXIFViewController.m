//
//  DTEXIFViewController.m
//  DTEXIFReader
//
//  Created by Darktt on 5/1/14.
//  Copyright (c) 2014 Darktt Personal Company. All rights reserved.
//

#import "DTEXIFViewController.h"
#import <ImageIO/ImageIO.h>

@interface DTEXIFViewController ()
{
    NSString *_filePath;
    NSDictionary *_imageProperties;
}

@end

@implementation DTEXIFViewController

+ (instancetype)EXIFWithFilePath:(NSString *)filePath
{
    DTEXIFViewController *EXIFReader = [[DTEXIFViewController alloc] initWithFilePath:filePath];
    
    return [EXIFReader autorelease];
}

- (id)initWithFilePath:(NSString *)filePath
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self == nil) return nil;
    
    _filePath = [[NSString alloc] initWithString:filePath];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDictionary *imageProperties = [self imagePropertiesWithPath:_filePath];
    NSDictionary *EXIFInformation = imageProperties[(id)kCGImagePropertyExifDictionary];
    NSDictionary *EXIFAuxiliary   = imageProperties[(id)kCGImagePropertyExifAuxDictionary];
    
    _imageProperties = [[NSDictionary alloc] initWithObjects:@[EXIFAuxiliary, EXIFInformation] forKeys:@[(id)kCGImagePropertyExifAuxDictionary, (id)kCGImagePropertyExifDictionary]];
    
    [self.tableView reloadData];
}

- (void)dealloc
{
    [_filePath release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Read Image Property

- (NSDictionary *)imagePropertiesWithPath:(NSString *)path
{
    NSURL *imageFileURL = [NSURL fileURLWithPath:path];
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)imageFileURL, NULL);
    
    NSDictionary *options = @{(id)kCGImageSourceShouldCache: @(NO)};
    
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, (CFDictionaryRef)options);
    CFRelease(imageSource);
    
    return (NSDictionary *)imageProperties;
}

#pragma mark - UITableView DataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray *keys = [_imageProperties allKeys];
    
    return [keys count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *keys = [_imageProperties allKeys];
    id key = keys[section];
    
    NSDictionary *object = _imageProperties[key];
    
    return [object count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    NSArray *keys = [_imageProperties allKeys];
    id key = keys[indexPath.section];
    
    NSDictionary *object = _imageProperties[key];
    
    NSArray *keysOfObject = [object allKeys];
    
    NSString *title = keysOfObject[indexPath.row];
    [cell.textLabel setText:title];
    
    // Detail information
    
    id detailInformation = object[title];
    
    NSString *detailString = nil;
    
    if ([detailInformation isKindOfClass:[NSArray class]]) {
        detailString = [(NSArray *)detailInformation componentsJoinedByString:@","];
    }
    
    if ([detailInformation isKindOfClass:[NSNumber class]]) {
        detailInformation = [(NSNumber *)detailInformation stringValue];
    }
    
    if ([detailInformation isKindOfClass:[NSString class]]) {
        detailString = [NSString stringWithString:detailInformation];
    }

    [cell.detailTextLabel setText:detailString];
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *keys = [_imageProperties allKeys];
    
    NSString *headerTitle = nil;
    
    if ([keys[section] isEqualToString:(id)kCGImagePropertyExifDictionary]) {
        headerTitle = @"EXIF";
        
        return headerTitle;
    }
    
    headerTitle = @"EXIF Auxiliary";
    
    return headerTitle;
}

@end

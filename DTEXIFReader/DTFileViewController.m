//
//  DTFileViewController.m
//  DTEXIFReader
//
//  Created by Darktt on 5/1/14.
//  Copyright (c) 2014 Darktt Personal Company. All rights reserved.
//

#import "DTFileViewController.h"
#import "DTFileController.h"

#import "DTEXIFViewController.h"

static NSString *directoryPath = nil;

@interface DTFileViewController ()
{
    NSArray *fileList;
}
@end

@implementation DTFileViewController

+ (instancetype)instanceViewController
{
    DTFileViewController *fileViewController = [DTFileViewController new];
    
    return [fileViewController autorelease];
}

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // Custom initialization
        
        [self setTitle:@"EXIF Reader"];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    DTFileController *fileController = [DTFileController mainController];
    
    directoryPath = [[NSString alloc] initWithString:[fileController documentPath]];
    
    NSLog(@"Directory Path:%@", directoryPath);
    
    NSArray *_fileList = [[DTFileController mainController] filesWithDirectoryPath:directoryPath];
    
    if (fileList != nil) {
        [fileList release];
    }
    
    fileList = [[NSArray alloc] initWithArray:_fileList copyItems:YES];
    
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)dealloc
{
    [fileList release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView DataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [fileList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    [cell.textLabel setText:fileList[indexPath.row]];
	
    return cell;
}

#pragma mark UITableView Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *fileName = (NSString *)fileList[indexPath.row];
    
    NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
    
    DTEXIFViewController *EXIFReader = [DTEXIFViewController EXIFWithFilePath:filePath];
    
    [self.navigationController pushViewController:EXIFReader animated:YES];
}

@end

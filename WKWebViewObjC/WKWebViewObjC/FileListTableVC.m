  
/* Copyright (c) 2020 BlackBerry Limited.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#import "FileListTableVC.h"
#import "WKWebViewPreviewVC.h"
#import <BlackBerryDynamics/GD/GDFileManager.h>

@interface FileListTableVC ()

@property (nonatomic, strong) NSArray *fileArray;

@end

@implementation FileListTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"File List";
    self.fileArray = @[@"sample.docx", @"sample.pdf"];
}

- (NSURL *)writeFileInGDContainer:(NSString *)file {
    NSString *fileName = [file stringByDeletingPathExtension];
    NSString *fileExtension = [file pathExtension];
    
    NSURL* url = [[NSBundle mainBundle] URLForResource:fileName withExtension:fileExtension];
    NSData *fileData = [GDFileManager.defaultManager contentsAtPath:url.path];
    
    NSString *basePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *filePath = [basePath stringByAppendingPathComponent:file];
    
    BOOL success = [[GDFileManager defaultManager] createFileAtPath:filePath contents:fileData attributes:nil];
    if (!success) {
        NSLog(@"File %@ not copied with error", filePath);
    } else {
        NSLog(@"File %@ copied", filePath);
    }
    
    // Secure gd url for file
    return [NSURL URLWithString:[NSString stringWithFormat:@"gd://%@",[filePath stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLFragmentAllowedCharacterSet]]];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fileArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileCell" forIndexPath:indexPath];
    [cell.textLabel setText:self.fileArray[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // File's gd url
    NSURL *gdURL = [self writeFileInGDContainer:self.fileArray[indexPath.row]];
    
    // Navigate to preview view controller
    WKWebViewPreviewVC *previewVC = (WKWebViewPreviewVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"PreviewVC"];
    previewVC.fileGDURL = gdURL;
    [self.navigationController pushViewController:previewVC animated:YES];
}

@end

/* Copyright (c) 2023 BlackBerry Ltd.
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

#import "FilePickerViewController.h"

@interface FilePickerViewController ()

    @property (nonatomic) NSArray* documents;
@end

@implementation FilePickerViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    self.documentsFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    [self preloadDocumentsFolder];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self refresh];
}

/* Copy files from app bundle to Documents folder.
 */
- (void)preloadDocumentsFolder {
    
    NSString* preLoadedResourcesFolder = [[NSBundle mainBundle] resourcePath];
    
    NSArray* resources = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:preLoadedResourcesFolder error:nil];
    for (id resource in resources) {
        NSString* extension = [[resource pathExtension] lowercaseString];
        if ([extension isEqualToString:@"txt"] || [extension isEqualToString:@"doc"] || [extension isEqualToString:@"pem"]) {
            [[NSFileManager defaultManager] copyItemAtPath:[preLoadedResourcesFolder stringByAppendingPathComponent:resource] toPath:[_documentsFolder stringByAppendingPathComponent:resource] error:nil];
        }
    }
}

/* Refresh Documents folder view.
 */
- (void)refresh {
    
    self.title = @"Documents Folder";

    NSArray* documents = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:_documentsFolder error:nil];
    NSMutableArray* filteredDocuments = [NSMutableArray new];
    
    for (NSString* document in documents)
       if (self.fileExtension == nil || [[[document pathExtension] lowercaseString] isEqualToString:self.fileExtension])
            [filteredDocuments addObject:document];

    self.documents = filteredDocuments;
    [self.tableView reloadData];
}


#pragma mark - UI actions

- (IBAction)onDelete:(id)sender {

    for (NSString* file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_documentsFolder error:nil])
        [[NSFileManager defaultManager] removeItemAtPath:[_documentsFolder stringByAppendingPathComponent:file] error:nil];
    [self preloadDocumentsFolder];
    [self refresh];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {

    return [_documents count];
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* cellIdentifier = @"Document";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = _documents[indexPath.section];
    cell.textLabel.textColor = [UIColor colorWithRed:33.0/255.0 green:50.0/255.0 blue:65.0/255.0 alpha:1.0];
    return cell;
}

- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.document = _documents[indexPath.section];
    [self performSegueWithIdentifier:@"FilePickerUnwindSegue" sender:self];
}

@end

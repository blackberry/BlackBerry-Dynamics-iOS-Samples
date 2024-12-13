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

#import "BPContactsViewController.h"
#import <BlackBerryDynamics/GD/GDFileHandle.h>

@interface BPContactsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (readonly) NSArray *contacts;

@end

@implementation BPContactsViewController
@synthesize contacts;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"contactCell"];
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (NSArray *)contacts {
    if (!contacts) {
        NSString* bundlePath = [[NSBundle mainBundle] pathForResource:@"contacts" ofType:@"txt"];
        NSData* resData = [[GDFileHandle fileHandleForReadingAtPath:bundlePath] availableData];
        NSString *stringData = [[NSString alloc] initWithData:resData encoding:NSUTF8StringEncoding];
        contacts = [stringData componentsSeparatedByString:@"\n"];
    }
    return contacts;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.contacts[indexPath.row];
    
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

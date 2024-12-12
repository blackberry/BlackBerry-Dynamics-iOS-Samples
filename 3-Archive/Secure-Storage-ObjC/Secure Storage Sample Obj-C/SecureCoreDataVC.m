/* Copyright (c) 2018 BlackBerry Ltd.
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

#import "SecureCoreDataVC.h"

@interface SecureCoreDataVC ()

@end

@implementation SecureCoreDataVC

//Initialize variables
- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    coreDataContext = [appDel managedObjectContext];
    
    [self fetch];
}

-(UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

//MARK: Table View Datasources
//Return one more cell for Add Button Row
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [dataArray count] + 1;
}

//Create cell with data
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addButtonCell" forIndexPath:indexPath];
        UIButton *button = (UIButton *)[cell viewWithTag:2];
        [button addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    } else {
        CustomTableViewCell *cell = (CustomTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"tableCell" forIndexPath:indexPath];
        cell.textField.delegate = self;
        cell.textView.delegate = self;
        cell.textField.tag = indexPath.row - 1;
        cell.textView.tag = indexPath.row - 1;
        cell.textField.text = [[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"title"];
        cell.textView.text = [[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"detail"];
        return cell;
    }
    return [[UITableViewCell alloc] init];
}

//MARK: Table View Delegates
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return false;
    } else {
        return true;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

//Delete from the database
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [coreDataContext deleteObject:[dataArray objectAtIndex:indexPath.row - 1]];
        NSError *err;
        [coreDataContext save:&err];
        if (err == NULL) {
            [self fetch];
        } else {
            NSLog(@"%@",[err localizedDescription]);
        }
    }
}

//load all the data from database
-(void)fetch {
    
    NSFetchRequest *notesFetch = [NSFetchRequest fetchRequestWithEntityName:@"Notes"];
    notesFetch.returnsObjectsAsFaults = false;
    NSError *err;
    dataArray = [NSMutableArray arrayWithArray:[coreDataContext executeFetchRequest:notesFetch error:&err]];
    if (err == NULL) {
        [self.tableDelegate reloadTable];
    } else {
        NSLog(@"%@",[err localizedDescription]);
    }
}

//Create a new entry
-(void)save {
    
    NSManagedObject *notes = [NSEntityDescription insertNewObjectForEntityForName:@"Notes" inManagedObjectContext:coreDataContext];
    [notes setValue:@"New Note" forKey:@"title"];
    [notes setValue:@"New Detail" forKey:@"detail"];
    
    NSError *err;
    
    [coreDataContext save:&err];
    if (err == NULL) {
        [self fetch];
    } else {
        NSLog(@"%@",[err localizedDescription]);
    }
}

//MARK: Text field delegates
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [dataArray[textField.tag] setValue:[textField text] forKey:@"title"];
    NSError *err;
    [coreDataContext save:&err];
    if (err != NULL) {
        NSLog(@"%@",[err localizedDescription]);
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:true];
    return false;
}

//MARK: Text view delegates
- (void)textViewDidEndEditing:(UITextView *)textView {
    [dataArray[textView.tag] setValue:[textView text] forKey:@"detail"];
    NSError *err;
    [coreDataContext save:&err];
    if (err != NULL) {
        NSLog(@"%@",[err localizedDescription]);
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text  isEqual: @"\n"]) {
        [self.view endEditing:true];
        return false;
    }
    return true;
}

@end

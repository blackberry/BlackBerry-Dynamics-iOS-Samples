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

#import "SecureSQLVC.h"

@interface SecureSQLVC ()

@end

@implementation SecureSQLVC

//Initialize variables
- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    coreDataContext = [appDel managedObjectContext];
}

-(void) viewDidAppear:(BOOL)animated {
    [self makeSQL];
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
        cell.textField.tag = [[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"id"] intValue];
        cell.textView.tag = [[[dataArray objectAtIndex:indexPath.row - 1] valueForKey:@"id"] intValue];
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
        CustomTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *query = [NSString stringWithFormat:@"DELETE FROM Notes WHERE id=%i;",(int)[cell.textField tag]];
        
        const char *queryChar = [query UTF8String];
        if (sqlite3_exec(sqlite3Database, queryChar, nil, nil, nil) != SQLITE_OK) {
            
        } else {
            [self fetch];
        }
    }
}

//load all the data from database
-(void)fetch {
    dataArray = [[NSMutableArray alloc] init];
    sqlite3_stmt *statement = NULL;
    
    if (sqlite3_prepare_v2(sqlite3Database, SQL_ACCESS_DATA, -1, &statement, nil) != SQLITE_OK) {
        NSLog(@"DB Error");
    }
    
    while (sqlite3_step(statement) == SQLITE_ROW) {
        NSMutableDictionary *dataDictonary = [[NSMutableDictionary alloc] init];
        int identity = (int)sqlite3_column_int64(statement, 0);
        [dataDictonary setValue:[NSString stringWithFormat:@"%d",identity] forKey:@"id"];
        if (sqlite3_column_text(statement, 1) != nil) {
            NSString *nameString = [NSString stringWithCString:sqlite3_column_text(statement, 1) encoding:SQLITE_UTF8];
            [dataDictonary setValue:nameString forKey:@"title"];
        }
        if (sqlite3_column_text(statement, 2) != nil) {
            NSString *nameString = [NSString stringWithCString:sqlite3_column_text(statement, 1) encoding:SQLITE_UTF8];
            [dataDictonary setValue:nameString forKey:@"detail"];
        }
        [dataArray addObject:dataDictonary];
    }
    [self.tableDelegate reloadTable];
}

//Create a new entry
-(void)save {
    
    int returnCode = sqlite3enc_open([[self documentsFolderPathForFileNamed:@"database"]UTF8String], &sqlite3Database);
    if (returnCode != SQLITE_OK) {
        sqlite3_close(sqlite3Database);
        NSLog(@"DEBUG: Database failed to open.");
    }
    
    char* errorMsg = NULL;
    sqlite3_stmt *statement = NULL;
    
    int tableId = -1;
    
    if (sqlite3_prepare_v2(sqlite3Database, "SELECT * FROM Notes WHERE id=( SELECT max(id) FROM Notes);", -1, &statement, nil) == SQLITE_OK) {
         NSLog(@"DB Error");
    }
    
    while (sqlite3_step(statement) == SQLITE_ROW) {
        tableId = (int)sqlite3_column_int64(statement, 0);
    }
    tableId ++;
    
    NSString *query = [NSString stringWithFormat:@"INSERT INTO Notes (id, title, detail) VALUES (%d, \"New Note\", \"Details\");", tableId];

    const char *queryChar = [query UTF8String];
    
    if (sqlite3_exec(sqlite3Database, queryChar, nil, nil, nil) == SQLITE_OK) {
        [self fetch];
    }
}

//check and create the table
-(void) makeSQL {
    
    char* errorMsg = NULL;
    
    //TODO: Check if the secure SQL database already exists
    GDFileManager *fileManager = [GDFileManager defaultManager];
    
    NSString *databasePath = [self documentsFolderPathForFileNamed:@"database"];
    
    if ([fileManager fileExistsAtPath:databasePath]==YES){
        
        NSLog(@"DEBUG: Saved Database found.");
        NSString *encryptedPath = [GDFileManager getAbsoluteEncryptedPath:databasePath];
        NSLog(@"%@", encryptedPath);
        
    }
    else
        NSLog(@"DEBUG: Database not found.");
    
    //TODO: Open secure SQL databse
    int returnCode = sqlite3enc_open([[self documentsFolderPathForFileNamed:@"database"]UTF8String], &sqlite3Database);
    
    if (returnCode != SQLITE_OK) {
        sqlite3_close(sqlite3Database);
        NSLog(@"DEBUG: Database failed to open.");
        
    }
    
    // TODO: Create database table if it doesn't exist.
    returnCode = sqlite3_exec(sqlite3Database, SQL_CR_TABLE, NULL, NULL, &errorMsg);
    
    if (returnCode != SQLITE_OK) {
        sqlite3_free(errorMsg);
    }
    
    [self fetch];
}

- (NSString *)documentsFolderPathForFileNamed:(NSString *)fileName {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}

//MARK: Text field delegates
- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSString *query = [NSString stringWithFormat:@"UPDATE Notes SET title = \"%@\"WHERE id = %i;",[textField text], (int)[textField tag]];

    const char *queryChar = [query UTF8String];
    
    if (sqlite3_exec(sqlite3Database, queryChar, nil, nil, nil) != SQLITE_OK) {
        NSLog(@"DB Error");
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:true];
    return false;
}

//MARK: Text view delegates
- (void)textViewDidEndEditing:(UITextView *)textView {
    NSString *query = [NSString stringWithFormat:@"UPDATE Notes SET detail = \"%@\"WHERE id = %i;",[textView text], (int)[textView tag]];
    
    const char *queryChar = [query UTF8String];
    
    if (sqlite3_exec(sqlite3Database, queryChar, nil, nil, nil) != SQLITE_OK) {
        NSLog(@"DB Error");
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

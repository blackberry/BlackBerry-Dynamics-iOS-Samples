/* Copyright (c) 2021 BlackBerry Ltd.
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

#import "DBViewController.h"
#import "DBManager.h"

@interface DBViewController ()

@property (nonatomic, strong) DBManager *dbManager;
@property (nonatomic, strong) NSArray *contactInfo;
@property (nonatomic) int recordIDToEdit;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

-(void)loadData;

@end

@implementation DBViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Make self the delegate and datasource of the table view.
    self.tableContact.delegate = self;
    self.tableContact.dataSource = self;
    
    // Initialize the dbManager property.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"contacts.db"];
    
    [self.dbManager initializeDB];
    
    // Load the data.
    [self loadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    EditViewController *editViewController = [segue destinationViewController];
    editViewController.delegate = self;

    if ([[segue identifier] isEqualToString:@"addContact"])
    {
        editViewController.recordIDToEdit = 0;
    }
    else if ([[segue identifier] isEqualToString:@"showContact"])
    {
        editViewController.recordIDToEdit = self.recordIDToEdit;
    }
}

#pragma mark - Private method implementation

-(void)openDatabase{
    [self.dbManager initializeDB];

}

-(void)loadData{
    // Form the query.
    NSString *query = @"select * from contacts";
    
    // Get the results.
    if (self.contactInfo != nil) {
        self.contactInfo = nil;
    }
    self.contactInfo = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    // Reload the table view.
    [self.tableContact reloadData];
     self.editButton.enabled = false;
}


#pragma mark - UITableView method implementation

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.contactInfo.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    // Dequeue the cell.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIDRecord" forIndexPath:indexPath];
    
    NSInteger indexOfFirstname = [self.dbManager.arrColumnNames indexOfObject:@"firstName"];
    NSInteger indexOfLastname = [self.dbManager.arrColumnNames indexOfObject:@"lastName"];
    NSInteger indexOfEmail = [self.dbManager.arrColumnNames indexOfObject:@"email"];
    
    // Set the loaded data to the appropriate cell labels.
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [[self.contactInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfFirstname], [[self.contactInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfLastname]];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Email: %@", [[self.contactInfo objectAtIndex:indexPath.row] objectAtIndex:indexOfEmail]];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get the record ID of the selected name and set it to the recordIDToEdit property.
    self.recordIDToEdit = [[[self.contactInfo objectAtIndex:indexPath.row] objectAtIndex:0] intValue];
    self.editButton.enabled = true;
    
}
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    // Get the record ID of the selected name and set it to the recordIDToEdit property.
    self.recordIDToEdit = [[[self.contactInfo objectAtIndex:indexPath.row] objectAtIndex:0] intValue];
    self.editButton.enabled = true;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the selected record.
        // Find the record ID.
        int recordIDToDelete = [[[self.contactInfo objectAtIndex:indexPath.row] objectAtIndex:0] intValue];
        
        // Prepare the query.
        NSString *query = [NSString stringWithFormat:@"delete from contact where id=%d", recordIDToDelete];
        
        // Execute the query.
        [self.dbManager executeQuery:query];
        
        // Reload the table view.
        [self loadData];
    }
}

#pragma mark - EditInfoViewControllerDelegate method implementation

-(void)editingInfoWasFinished{
    // Reload the data.
    [self loadData];
}
@end

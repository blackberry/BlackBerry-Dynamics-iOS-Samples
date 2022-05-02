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

#import "EditViewController.h"
#import "DBManager.h"

@interface EditViewController ()

@property (nonatomic, strong) DBManager *dbManager;

-(void)loadContactInfoToEdit;

@end

@implementation EditViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Make self the delegate of the textfields.
    self.firstNameText.delegate = self;
    self.lastNameText.delegate = self;
    self.emailText.delegate = self;
    
    // Set the navigation bar tint color.
    self.navigationController.navigationBar.tintColor = self.navigationItem.rightBarButtonItem.tintColor;
    
    // Initialize the dbManager object.
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"contacts.db"];

    [self loadContactInfoToEdit];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITextFieldDelegate method implementation

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - IBAction method implementation

- (IBAction)saveInfo:(id)sender {
    
    // Prepare the query string.
    // Check the recordIDToEdit property, to create an update or insert query.
    NSString *query;
    if (self.recordIDToEdit > 0)
    {
        query = [NSString stringWithFormat:@"update contacts set firstname='%@', lastname='%@', email='%@' where id=%d", self.firstNameText.text, self.lastNameText.text, self.emailText.text, self.recordIDToEdit];
    }
    else
    {
        query = [NSString stringWithFormat:@"insert into contacts values(null, '%@', '%@', '%@')", self.firstNameText.text, self.lastNameText.text, self.emailText.text];
    }
    
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    // If the query was successfully executed then pop the view controller.
    if (self.dbManager.affectedRows != 0)
    {
        NSLog(@"DEBUG: Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
        
        // Inform the delegate that the editing was finished.
        [self.delegate editingInfoWasFinished];
        
        // Pop the view controller.
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        NSLog(@"DEBUG: Could not execute the query.");
    }
}


#pragma mark - Private method implementation

-(void)loadContactInfoToEdit{
    
    self.firstNameText.text = @"";
    self.lastNameText.text = @"";
    self.emailText.text = @"";
    
    if( self.recordIDToEdit > 0)
    {
        // Create the query.
        NSString *query = [NSString stringWithFormat:@"select * from contacts where id=%d", self.recordIDToEdit];
    
        // Load the relevant data.
        NSArray *results = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
        // Set the loaded data to the textfields.
        self.firstNameText.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"firstName"]];
        self.lastNameText.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"lastName"]];
        self.emailText.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"email"]];
    }
    
}


@end

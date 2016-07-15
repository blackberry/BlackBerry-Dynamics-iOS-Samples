/* Copyright (c) 2016 BlackBerry Ltd.
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

#import "DBManager.h"

const char* const SQL_CREATE_TABLE = "CREATE TABLE IF NOT EXISTS contacts (\
id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, \
firstName  VARCHAR, \
lastName      VARCHAR, \
email  VARCHAR)";

const char* const SQL_INSERT = "INSERT INTO contacts (firstName, lastName, email) VALUES (?, ?, ?)";

@interface DBManager()

@property (nonatomic, strong) NSString *documentsDirectory;
@property (nonatomic, strong) NSString *databaseFilename;
@property (nonatomic, strong) NSMutableArray *arrResults;

-(void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable;

@end


@implementation DBManager

#pragma mark -

-(instancetype)initWithDatabaseFilename:(NSString *)dbFilename{
    self = [super init];
    if (self) {
        // Set the documents directory path to the documentsDirectory property.
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.documentsDirectory = [paths objectAtIndex:0];
        
        // Keep the database filename.
        self.databaseFilename = dbFilename;
    }
    return self;
}

- (BOOL)initializeDB
{
    char* errorMsg = NULL;
    
    
    //Check if the database already exists
    if ([ [NSFileManager defaultManager] fileExistsAtPath:[self documentsFolderPathForFileNamed:self.databaseFilename]]==YES)
       NSLog(@"DEBUG: Database File exists.");
    
    // open databse file
    int returnCode = sqlite3_open([[self documentsFolderPathForFileNamed:self.databaseFilename]UTF8String], &sqlite3Database);
    
    if (returnCode != SQLITE_OK)
    {
        sqlite3_close(sqlite3Database);
        NSLog(@"DEBUG: Database failed to open.");
        
        return NO;
    }
    
    // create table if it doesn't exist.
    returnCode = sqlite3_exec(sqlite3Database, SQL_CREATE_TABLE, NULL, NULL, &errorMsg);
    
    if (returnCode != SQLITE_OK)
    {
        sqlite3_free(errorMsg);
        return NO;
    }
    
    sqlite3_close(sqlite3Database);
    
    return YES;
}

#pragma mark - Method implementation

- (NSString *)documentsFolderPathForFileNamed:(NSString *)fileName {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}

-(void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable{
    
    // database file path.
    NSString *databasePath = [self documentsFolderPathForFileNamed:self.databaseFilename];
    
    // Check if the database already exists
    if ([ [NSFileManager defaultManager] fileExistsAtPath:databasePath]==YES)
        NSLog(@"DEBUG: Database File exists.");
    
    // Initialize the results array.
    if (self.arrResults != nil)
    {
        [self.arrResults removeAllObjects];
        self.arrResults = nil;
    }
    self.arrResults = [[NSMutableArray alloc] init];
    
    // Initialize the column names array.
    if (self.arrColumnNames != nil) {
        [self.arrColumnNames removeAllObjects];
        self.arrColumnNames = nil;
    }
    
    self.arrColumnNames = [[NSMutableArray alloc] init];
    
    // Open database, non-GD call
    BOOL openDatabaseResult = sqlite3_open([databasePath UTF8String], &sqlite3Database);

    if(openDatabaseResult == SQLITE_OK)
    {
        // Declare a sqlite3_stmt object in which will be stored the query after having been compiled into a SQLite statement.
        sqlite3_stmt *compiledStatement = NULL;
        
        // Load all data from database to memory.
        BOOL prepareStatementResult = sqlite3_prepare_v2(sqlite3Database, query, -1, &compiledStatement, NULL);
        
        if( prepareStatementResult  == SQLITE_OK)
        {
            if (queryExecutable)
            {
                // Execute the query (insert, update..).
                if (sqlite3_step(compiledStatement) == SQLITE_DONE)
                {
                    // Keep the affected rows.
                    self.affectedRows = sqlite3_changes(sqlite3Database);
                    
                    // Keep the last inserted row ID.
                    self.lastInsertedRowID = sqlite3_last_insert_rowid(sqlite3Database);
                }
                else
                {
                    // If could not execute the query show the error message on the debugger.
                    NSLog(@"DB Error: %s", sqlite3_errmsg(sqlite3Database));
                }
            }
            else
            {
                // Load data from the database.
                // Declare an array to keep the data for each fetched row.
                NSMutableArray *arrDataRow;
                
                // Loop through the results and add them to the results array row by row.
                while(sqlite3_step(compiledStatement) == SQLITE_ROW)
                {
                    // Initialize the mutable array that will contain the data of a fetched row.
                    arrDataRow = [[NSMutableArray alloc] init];
                    
                    // Get the total number of columns.
                    int totalColumns = sqlite3_column_count(compiledStatement);
                    
                    // Go through all columns and fetch each column data.
                    for (int i=0; i<totalColumns; i++)
                    {
                        // Convert the column data to text (characters).
                        char *dbDataAsChars = (char *)sqlite3_column_text(compiledStatement, i);
                        
                        // If there are contents in the currenct column (field) then add them to the current row array.
                        if (dbDataAsChars != NULL)
                        {
                            // Convert the characters to string.
                            [arrDataRow addObject:[NSString  stringWithUTF8String:dbDataAsChars]];
                        }
                        
                        // Keep the current column name.
                        if (self.arrColumnNames.count != totalColumns)
                        {
                            dbDataAsChars = (char *)sqlite3_column_name(compiledStatement, i);
                            [self.arrColumnNames addObject:[NSString stringWithUTF8String:dbDataAsChars]];
                        }
                    }
                    
                    // Store each fetched data row in the results array, but first check if there is actually data.
                    if (arrDataRow.count > 0)
                        [self.arrResults addObject:arrDataRow];
                }
            }
        }
        else
        {
            // In the database cannot be opened then show the error message on the debugger.
            NSLog(@"DEBUG: %s", sqlite3_errmsg(sqlite3Database));
        }
        
        // Release the compiled statement from memory.
        sqlite3_finalize(compiledStatement);
    }
    else
    {
        // In the database cannot be opened.
        NSLog(@"DEBUG: %s", sqlite3_errmsg(sqlite3Database));
    }
    
    // Close the database.
    sqlite3_close(sqlite3Database);
}


-(NSArray *)loadDataFromDB:(NSString *)query{
    // Run the query and indicate that is not executable.
    // The query string is converted to a char* object.
    [self runQuery:[query UTF8String] isQueryExecutable:NO];
    
    // Returned the loaded results.
    return (NSArray *)self.arrResults;
}

-(void)executeQuery:(NSString *)query{
    // Run the query and indicate that is executable.
    [self runQuery:[query UTF8String] isQueryExecutable:YES];
}


@end

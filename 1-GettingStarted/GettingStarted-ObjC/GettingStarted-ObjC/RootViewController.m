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

#import "RootViewController.h"

@interface RootViewController ()

@property (weak, nonatomic) IBOutlet UIButton *saveToFileButton;
@property (weak, nonatomic) IBOutlet UITextView *textEditView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

- (IBAction)saveToFile:(id)sender;
- (IBAction)loadFromFile:(id)sender;
- (IBAction)clearText:(id)sender;

@end

@implementation RootViewController

static NSString * const textFilename = @"aTextFileName.txt";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Do any additional setup after loading the view, typically from a nib.
    /*
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaLTStd-Roman" size:10.0f], NSFontAttributeName,  [UIColor yellowColor], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaLTStd-Roman" size:10.0f], NSFontAttributeName,  [UIColor whiteColor], NSForegroundColorAttributeName,nil] forState:UIControlStateHighlighted];
    */
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)saveToFile:(id)sender {
    
    BOOL result = [self writeMyFile];
    
    if(result)
        self.messageLabel.text = @"Saved to NSFileManager.";
    else
        self.messageLabel.text = @"Failed to save.";
    
    [self.view endEditing:YES];
}

- (IBAction)loadFromFile:(id)sender {
    
    NSString *filePath = [self documentsFolderPathForFileNamed:textFilename];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:filePath]==YES)
    {
        NSLog(@"DEBUG: File exists.");
        
       self.textEditView.text = [[NSString alloc]initWithData:[fileManager contentsAtPath:filePath] encoding:NSUTF8StringEncoding];
       self.messageLabel.text =@"Loaded using NSFileManager.";
    }
    else
    {
        NSLog(@"DEBUG: Saved text file doesnt' exist.");
        self.textEditView.text =@"<Enter text here>";
        self.messageLabel.text =@"Saved text file doesnt' exist.";
    }
    [self.view endEditing:YES];
}

- (IBAction)clearText:(id)sender {
    
    self.textEditView.text = @"<Enter text here>";
    self.messageLabel.text = @"Cleard text.";
    
    [self.view endEditing:YES];
}

- (NSString *)documentsFolderPathForFileNamed:(NSString *)fileName {
             
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}

- (BOOL)writeMyFile {
    
    
    // Delete the file if exists
    NSString *filePath = [self documentsFolderPathForFileNamed:textFilename];
    NSError *error=nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]==YES)
    {
        NSLog(@"DEBUG: The text file exists. Delete.");
        
        if ([[NSFileManager defaultManager] removeItemAtPath:filePath error:&error])
            NSLog(@"DEBUG: Removed the text file successfully.");
        else
            NSLog(@"DEBUG: Error removing the text file.: %@", error);
    }
    else
    {
        NSLog(@"DEBUG: The text file does not exist.");
    }
    
    NSString *text = self.textEditView.text;
    NSData *fileData = [text dataUsingEncoding:NSUTF8StringEncoding];
    
    BOOL fileCreated = [[NSFileManager defaultManager] createFileAtPath:[self documentsFolderPathForFileNamed:textFilename]
                                                        contents:fileData attributes:nil];
    return fileCreated;
}

@end

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

#import "TransferFileVC.h"

@interface TransferFileVC ()

@end

@implementation TransferFileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    transferFileIdentifier = @"com.good.gdservice.transfer-file";
    transferFileVersion = @"1.0.0.0";
}

//Save the file in the Secure Container and transfer it with App Kinetics
- (IBAction)Send:(id)sender {
    
    // Delete the file if exists
    NSString *filePath = [self documentsFolderPathForFileNamed:[self.fileNameOutlet text]];
    NSError *error = nil;
    
    GDFileManager *fileManager = [GDFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:filePath] == YES) {
        NSLog(@"DEBUG: The text file exists. Delete.");
        
        if ([fileManager removeItemAtPath:filePath error:&error])
            NSLog(@"DEBUG: Removed the text file successfully.");
        else
            NSLog(@"DEBUG: Error removing the text file.: %@", error);
    } else {
        NSLog(@"DEBUG: The text file does not exist.");
    }
    
    NSData *fileData = [[self.fileContentOutlet text] dataUsingEncoding:NSUTF8StringEncoding];
    
    [fileManager createFileAtPath:[self documentsFolderPathForFileNamed:[self.fileNameOutlet text]]
                                            contents:fileData attributes:nil];
    
    files = [[NSMutableArray alloc] init];
    [files addObject:[self documentsFolderPathForFileNamed:[self.fileNameOutlet text]]];
    
    NSArray* arr = [[GDiOS sharedInstance] getServiceProvidersFor:transferFileIdentifier andVersion:transferFileVersion andServiceType:GDServiceTypeApplication];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"SELF.identifier!=%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"GDApplicationID"]];
    serviceProviders = [arr filteredArrayUsingPredicate:predicate];
    
    if (serviceProviders.count == 0) {
        [self alertWithTitle:@"Alert!" message:@"No Dynamics App installed to consume Transfer File Service"];
    } else if (serviceProviders.count == 1) {
        [self sendFileToServiceProvider:[serviceProviders objectAtIndex:0] andFiles:files];
    } else {
        UIActionSheet *appSheet = [[UIActionSheet alloc] initWithTitle:@"Choose an Application to send the file to" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: nil];
        
        for (GDServiceProvider *serP in serviceProviders) {
            [appSheet addButtonWithTitle:[serP name]];
        }
        
        [appSheet showInView:self.view];
    }
}

-(void) sendFileToServiceProvider: (GDServiceProvider *) serP andFiles: (NSArray*)files {
    NSError *err = [[NSError alloc] init];
    [GDServiceClient sendTo:[serP address] withService:transferFileIdentifier withVersion:transferFileVersion withMethod:@"transferFile" withParams:NULL withAttachments:files bringServiceToFront:GDEPreferPeerInForeground requestID:nil error:&err];
}

- (NSString *)documentsFolderPathForFileNamed:(NSString *)fileName {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}

-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:true];
}

-(void) alertWithTitle: (NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *alert) {
        [self dismissViewControllerAnimated:true completion:nil];
    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"%@", files);
    if (buttonIndex > 0) {
        [self sendFileToServiceProvider:[serviceProviders objectAtIndex:buttonIndex-1] andFiles:files];
    }
}

@end

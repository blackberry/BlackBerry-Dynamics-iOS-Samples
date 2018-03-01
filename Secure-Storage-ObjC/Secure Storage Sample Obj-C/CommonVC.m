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

#import "CommonVC.h"
#import "SecureCoreDataVC.h"

@interface CommonVC ()

@end

@implementation CommonVC

//Setup background image
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"book"]];
    [self.tableView.layer setCornerRadius:20];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [blurEffectView setFrame:self.view.frame];
    [imageView addSubview:blurEffectView];
    self.tableView.backgroundView = imageView;
}

//Switch the delegate class
-(void)viewWillAppear:(BOOL)animated {
    
    if ([NSStringFromClass([[self parentViewController] classForCoder]) containsString:@"SecureSQL"]) {
        
        SecureCoreDataVC *vc = (SecureCoreDataVC*)[self parentViewController];
        self.tableView.delegate = vc;
        self.tableView.dataSource = vc;
        vc.tableDelegate = self;
        
    } else {
        
        SecureCoreDataVC *vc = (SecureCoreDataVC*)[self parentViewController];
        self.tableView.delegate = vc;
        self.tableView.dataSource = vc;
        vc.tableDelegate = self;
    }
    [self reloadTable];
}

-(void)reloadTable {
    [self.tableView reloadData];
}


@end

/* Copyright (c) 2017 BlackBerry Ltd.
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

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
@import GD.Runtime;

@interface ViewController () <AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar; //will be updated with car name
@property (weak, nonatomic) IBOutlet UIImageView *carImage;
@property (weak, nonatomic) IBOutlet UITextView *carDescription;
@property (weak, nonatomic) IBOutlet UIButton *soundButton;
@property (weak, nonatomic) IBOutlet UILabel *policyVersion;

- (IBAction)playSoundButtonPressed:(id)sender;

@property (strong, nonatomic) AVAudioPlayer *player;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    [self configureAudioPlayer];
    
    [self refreshUi];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)playSoundButtonPressed:(id)sender {
    self.soundButton.enabled = NO;
    [self.player play];
}

- (void)configureAudioPlayer {
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    NSString *backgroundMusicPath = [[NSBundle mainBundle] pathForResource:@"CarSound" ofType:@"mp3"];
    NSURL *backgroundMusicURL = [NSURL fileURLWithPath:backgroundMusicPath];
    NSError *error = nil;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
    self.player.delegate = self;
    self.player.numberOfLoops = 0;
}

- (void)refreshUi{
    
    //use the application policy retrieved from GC and update UI
    NSDictionary *appPolicy = [[GDiOS sharedInstance] getApplicationPolicy];
    NSArray *visibleElements = appPolicy[@"visibleElements"];
    
    //print the policy as string
    NSLog(@"Application policy as string %@", [[GDiOS sharedInstance] getApplicationPolicyString]);
    
    //Update Title
    NSString *title = @"Hidden by policy";
    
    if ([visibleElements containsObject:@"name"]) {
        
        title = appPolicy[@"carName"];
        
        if (!title) {
            title = @"Not set";
        }
    }
    
    self.navBar.topItem.title = title;
    
    //Update Car image
    self.carImage.hidden = ![visibleElements containsObject:@"image"];
    
    NSString *carImageName = nil;
    NSInteger color = [appPolicy[@"exteriorColor"] integerValue];
    BOOL convertible = [appPolicy[@"isConvertible"] boolValue];
    switch (color) {
        case 0: {
            if (convertible) {
                carImageName = @"black_convertible";
            } else {
                carImageName = @"black_coupe";
            }
            break;
        }
        case 1: {
            if (convertible) {
                carImageName = @"blue_convertible";
            } else {
                carImageName = @"blue_coupe";
            }
            break;
        }
        case 2: {
            if (convertible) {
                carImageName = @"red_convertible";
            } else {
                carImageName = @"red_coupe";
            }
            break;
        }
        case 3: {
            if (convertible) {
                carImageName = @"silver_convertible";
            } else {
                carImageName = @"silver_coupe";
            }
            break;
        }
        case 4: {
            if (convertible) {
                carImageName = @"turquoise_convertible";
            } else {
                carImageName = @"turquoise_coupe";
            }
            break;
        }
        case 5: {
            if (convertible) {
                carImageName = @"yellow_convertible";
            } else {
                carImageName = @"yellow_coupe";
            }
            break;
        }
        default:
            carImageName = @"car_placeholder";
            break;
    }
    self.carImage.image = [UIImage imageNamed:carImageName];
    
    
    //Update Text View
    self.carDescription.hidden = ![visibleElements containsObject:@"description"];
    NSString *carDescription = appPolicy[@"carDescription"];
    if (!carDescription) {
        carDescription = @"Car description Not set";
    }
    self.carDescription.text = carDescription;
    
    
    //Update Playsound
    self.soundButton.hidden = ![appPolicy[@"enableSound"] boolValue];
    
    //Play/Stop sound
    BOOL autoplay = [appPolicy[@"enableAutoPlaySound"] boolValue];
    if (autoplay) {
        [self playSoundButtonPressed:self.soundButton];
    }
    
    //Update Version String
    self.policyVersion.text = appPolicy[@"version"];
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    self.soundButton.enabled = YES;
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error {
    self.soundButton.enabled = YES;
}

@end

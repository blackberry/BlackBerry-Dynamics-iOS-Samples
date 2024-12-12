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

#import "CertificateVerifyViewController.h"
#import "FilePickerViewController.h"
#import "CertificateListViewController.h"
#import "CertificateDetailViewController.h"

#include <BlackBerryDynamics/GD/GDCredential.h>
#include <BlackBerryDynamics/GD/GDStream.h>
#include <BlackBerryDynamics/GD/GDCryptoKeyStore.h>
#include <BlackBerryDynamics/GD/GDCryptoAlgorithms.h>

@interface CertificateVerifyViewController ()

    @property (nonatomic) const struct GDX509List* certificateChain;
    @property (nonatomic) const struct GDX509List* trustAnchors;
    @property (nonatomic, nullable) NSString* trustAnchorsFileName;
    @property (nonatomic, nullable) NSString* documentsFolder;
    @property (nonatomic, nullable) NSString* document;
@end

@implementation CertificateVerifyViewController

typedef enum {
    FIRST_PHASE,
    CERT_PHASE,
    TRUST_ANCHOR_PHASE,
    VERIFY_PHASE,
    LAST_PHASE
} Phases;


#pragma mark - Property accessors

- (void)setCertificateChain:(const struct GDX509List*)certs {

    GDX509List_free((struct GDX509List*)_certificateChain);
    _certificateChain = nil;
    if (certs)
        _certificateChain = GDX509List_copy(certs);
}

- (void)setTrustAnchors:(const struct GDX509List*)anchors {

    GDX509List_free((struct GDX509List*)_trustAnchors);
    _trustAnchors = nil;
    if (anchors)
        _trustAnchors = GDX509List_copy(anchors);
}


#pragma UI initialization

- (void)viewWillAppear:(BOOL)animated {

    // Set background of Navigation Controller to white for swipe animation purposes.
    self.parentViewController.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {

    [super viewDidLoad];
    self.certificateChain = nil;
    self.trustAnchors = nil;
    self.page.numberOfPages = LAST_PHASE;
    self.page.currentPage = FIRST_PHASE;
    [self refresh:YES];
}

- (void)dealloc {

    self.certificateChain = nil;
    self.trustAnchors = nil;
}


#pragma mark - UI alerts

- (void)showAlert:(NSString*)title text:(NSString*)text {

    UIAlertController* ac = [UIAlertController alertControllerWithTitle:title message:text preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:@"Okay"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action) {
                                             // Do nothing.
                                         }]];
    [self presentViewController:ac animated:YES completion:nil];
}


#pragma mark UI navigation, actions, gestures

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([[segue identifier] isEqualToString:@"FilePickerSegue"]) {
        __weak FilePickerViewController* vc = [segue destinationViewController];
        vc.fileExtension = @"pem"; // Show only PEM files.
    }
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {

    if ([[segue identifier] isEqualToString:@"FilePickerUnwindSegue"]) {
        __weak FilePickerViewController* vc = [segue sourceViewController];
        self.documentsFolder = vc.documentsFolder;
        switch (self.page.currentPage) {
            case CERT_PHASE: {
                NSString* pemFile = [vc.documentsFolder stringByAppendingPathComponent:vc.document];
                if (pemFile) {
                    NSData* pemData = [NSData dataWithContentsOfFile:pemFile];
                    if (pemData) {
                        self.certificateChain = GDX509List_read([pemData bytes], (int)[pemData length]);
                    }
                }
                break;
            }
            case TRUST_ANCHOR_PHASE: {
                NSString* pemFile = [vc.documentsFolder stringByAppendingPathComponent:vc.document];
                if (pemFile) {
                    NSData* pemData = [NSData dataWithContentsOfFile:pemFile];
                    if (pemData) {
                        self.trustAnchors = GDX509List_read([pemData bytes], (int)[pemData length]);
                        self.trustAnchorsFileName = [pemFile lastPathComponent];
                    }
                }
                break;
            }
            default:
                assert(false);
                break;
        }
    }
    [self refresh:YES];
}

-(IBAction)onButtonDown:(id)sender {

    switch (self.page.currentPage) {
        case CERT_PHASE:
        case TRUST_ANCHOR_PHASE: {
            [self performSegueWithIdentifier:@"FilePickerSegue" sender:self];
            break;
        }
        case VERIFY_PHASE: {
            [self verifyCertificateChain];
            break;
        }
        default: {
            assert(false);
        }
    }
}

-(IBAction)onPageChange:(id)sender {

    // Stay on current page if not setup.
    [self refreshFadeIn:[self canProceed]];
}

-(IBAction)onSwipeLeft:(id)sender {

    // Navigating to next step in this example.
    if (self.page.currentPage < (LAST_PHASE - 1) && [self canProceed]) {
        self.page.currentPage = self.page.currentPage + 1;
        [self driftLeftFadeOutAndRefreshNextView];
    }
}

-(IBAction)onSwipeRight:(id)sender {

    // Navigating back to previous step in this example.
    if (self.page.currentPage > FIRST_PHASE) {
        self.page.currentPage = self.page.currentPage - 1;
        [self driftRightFadeOutAndRefreshNextView];
    }
}

-(BOOL)canProceed {

    if (self.page.currentPage >= CERT_PHASE && self.certificateChain == nil) {
        self.page.currentPage = CERT_PHASE;
        self.hint.text = @"You must select a PEM file containing a certificate chain to proceed.";
        return NO;
    }

    return YES;
}


#pragma mark UI animation

- (void)driftLeftFadeOutAndRefreshNextView {

    UIView* view = self.pageView;
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
        view.frame = CGRectOffset(view.frame, -250, 0);
        view.alpha = 0.0;
    } completion:^(BOOL finished) {
        view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
        [self refreshFadeIn:YES];
    }];
}

- (void)driftRightFadeOutAndRefreshNextView {

    UIView* view = self.pageView;
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
        view.frame = CGRectOffset(view.frame, 250, 0);
        view.alpha = 0.0;
    } completion:^(BOOL finished) {
        view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
        [self refreshFadeIn:YES];
    }];
}

- (void)refreshFadeIn:(BOOL)hint {

    UIView* view = self.pageView;
    view.alpha = 0.0;
    [self refresh:hint];
    [UIView animateWithDuration:0.3f animations:^{
        view.alpha = 1.0;
    }];
}


#pragma mark UI refresh

/* Layout the current page.
 */
- (void)refresh:(BOOL)hint {

    self.title = @"Evaluate Certificate";

    switch (self.page.currentPage ) {
        case FIRST_PHASE: {
            // Describe the example.
            self.detail.textAlignment = NSTextAlignmentLeft;
            self.detail.text = @"This example demonstrates how to evaluate a certificate to determine whether it can be trusted or not.\n\nA certificate is trustworthy if an unbroken chain of trust back to the root Certificate Authority (CA) within the trust store can be established. Validity periods and signatures of the leaf certificate and intermediates (if any) are checked.\n\nIf no trust store is specified, the Dynamics trust store will be searched first, and if the device certificate store is enabled it may also be used during evaluation. To install trusted CAs to the Dynamics trust store, assign a CA profile to your user from the UEM console. Enable the device certificate store from the Dynamics policy if you trust CAs installed on the device.\n\nBefore you begin you should install a PEM file containing the certificate and intermediate chain you wish to verify. If you wish to evaluate using an external trusted CA store then please also install it in PEM format. This can be achieved using iTunes File Sharing to save the PEM files into the Documents folder.";
            self.button.hidden = true;
            self.moreDetail.text = @"";
            if (hint) self.hint.text = @"Swipe left to begin.";
            break;
        }
        case CERT_PHASE: {
            // Step 1: Select a certificate chain in PEM file to verify.
            self.detail.textAlignment = NSTextAlignmentCenter;
            if (self.certificateChain) {
                self.detail.text = @"The following certificate will be evaluated:";
                self.moreDetail.text = [NSString stringWithFormat:@"%@", [self certificateDescription:GDX509List_value(self.certificateChain, 0)]];
                if (hint) self.hint.text = @"Next: Select the trusted CA store.";
            }
            else {
                self.detail.text = @"Select a certificate chain to evaluate. You can upload this in PEM format using iTunes File Sharing.";
                self.moreDetail.text = @"";
                if (hint) self.hint.text = @"";
            }
            [self setupButtonWithTitle:@"Open Documents Folder"];
            self.button.hidden = false;
            break;
        }
        case TRUST_ANCHOR_PHASE: {
            // Step 2: Select a trusted CA store in PEM file.
            self.detail.textAlignment = NSTextAlignmentCenter;
            if (self.trustAnchors) {
                self.detail.text = [NSString stringWithFormat:@"%d CA%@ within the PEM file will be searched during evaluation.", GDX509List_num(self.trustAnchors), (GDX509List_num(self.trustAnchors) == 1 ? @"" : @"s")];
                self.moreDetail.text = [NSString stringWithFormat:@"File:%@", self.trustAnchorsFileName];
                if (hint) self.hint.text = @"Next: Evaluate the certificate chain.";
            }
            else {
                self.detail.text = @"Select a trusted CA store. You can upload this in PEM format using iTunes File Sharing. This stage is optional, and if you skip it, the Dynamics and the device's trusted CA store (if UEM Dynamics policy has enabled it) will be used during evaluation.";
                self.moreDetail.text = @"";
                if (hint) self.hint.text = @"";
            }
            [self setupButtonWithTitle:@"Open Documents Folder"];
            self.button.hidden = false;
            break;
        }
        case VERIFY_PHASE: {
            // Step 3: Verify the certificate chain.
            self.detail.textAlignment = NSTextAlignmentCenter;
            if (self.trustAnchorsFileName) {
                self.detail.text = [NSString stringWithFormat:@"The following certificate will be evaluated using an external trust store from %@:", self.trustAnchorsFileName];
            }
            else {
                self.detail.text = @"The following certificate will be evaluated using the Dynamics and/or device trust store:";
            }
            self.moreDetail.text = [NSString stringWithFormat:@"%@", [self certificateDescription:GDX509List_value(self.certificateChain, 0)]];
            [self setupButtonWithTitle:@"Evaluate"];
            self.button.hidden = false;
            if (hint) self.hint.text = @"";
            break;
        }
        default: {
            assert(false);
        }
    }
}

- (void)setupButtonWithTitle:(NSString *)title {

    self.button.layer.masksToBounds = YES;
    self.button.layer.borderWidth = 1;
    self.button.layer.cornerRadius = 5;
    self.button.layer.borderColor = [UIColor colorWithRed:53.0/255.0 green:167.0/255.0 blue:220.0/255.0 alpha:1.0].CGColor;
    self.button.configuration.contentInsets = NSDirectionalEdgeInsetsMake(8, 10, 8, 10);
    [self.button setTitle:title forState:UIControlStateNormal];
}

- (NSString*)certificateDescription:(const struct GDX509*)cert {

    NSString* description = nil;
    struct GDX509Certificate* certDetails = GDX509Certificate_create(cert);
    if (certDetails) {
        NSString* serial = [NSString stringWithUTF8String:certDetails->serialNumber];
        NSString* subject = [NSString stringWithUTF8String:certDetails->subject];
        NSString* issuer = [NSString stringWithUTF8String:certDetails->issuer];
        description = [NSString stringWithFormat:@"Serial number: %@\nSubject name: %@\nIssuer: %@", serial, subject, issuer];
        GDX509Certificate_free(certDetails);
    }
    return description;
}


#pragma mark verify certificate chain

- (void)verifyCertificateChain {

    char* reason = NULL;
    bool trusted = GDX509List_evaluate(self.certificateChain, self.trustAnchors, "", &reason);
    if (trusted) {
        [self showAlert:@"Success" text:@"Certificate is trusted."];
    }
    else {
        if (reason) {
            [self showAlert:@"Error" text:[NSString stringWithFormat:@"Verification failure. Error:%s", reason]];
            free(reason);
        }
        else {
            [self showAlert:@"Error" text:[NSString stringWithFormat:@"Verification failure."]];
        }
    }
}

@end

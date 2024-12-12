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

#import "PKCS7VerifyViewController.h"
#import "FilePickerViewController.h"

#include <BlackBerryDynamics/GD/GDCredential.h>
#include <BlackBerryDynamics/GD/GDCryptoPKCS7.h>

@interface PKCS7VerifyViewController ()

    @property (nonatomic, nullable) NSString* documentsFolder;
    @property (nonatomic, nullable) NSString* document;
    @property (nonatomic, nullable) NSString* signature;
    @property (nonatomic) BOOL pickingSignature;
    @property (atomic) BOOL isVerifying;
@end

@implementation PKCS7VerifyViewController

typedef enum {
    FIRST_PHASE,
    DOC_PHASE,
    SIG_PHASE,
    VERIFY_PHASE,
    LAST_PHASE
} Phases;

#pragma UI initialization

- (void)viewWillAppear:(BOOL)animated {

    // Set background of Navigation Controller to white for swipe animation purposes.
    self.parentViewController.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.page.numberOfPages = LAST_PHASE;
    self.page.currentPage = FIRST_PHASE;
    self.isVerifying = NO;
    [self refresh:YES];
}


#pragma mark - UI alerts

- (void)showAlert:(NSString*)title text:(NSString*)text {

    // Called from background thread, so schedule on main UI thread.
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController* ac = [UIAlertController alertControllerWithTitle:title message:text preferredStyle:UIAlertControllerStyleAlert];
        [ac addAction:[UIAlertAction actionWithTitle:@"Okay"
                                               style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction * action) {
                                                 // Do nothing.
                                             }]];
        [self presentViewController:ac animated:YES completion:nil];
    });
}


#pragma mark UI navigation, actions, gestures

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if (self.page.currentPage == SIG_PHASE)
        self.pickingSignature = YES;
    else
        self.pickingSignature = NO;
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    
    if ([[segue identifier] isEqualToString:@"FilePickerUnwindSegue"]) {
        __weak FilePickerViewController* vc = [segue sourceViewController];
        self.documentsFolder = vc.documentsFolder;
        if (self.pickingSignature)
            self.signature = vc.document;
        else
            self.document = vc.document;
    }
    [self refresh:YES];
}

-(IBAction)onButtonDown:(id)sender {
    
    switch (self.page.currentPage) {
        case DOC_PHASE:
        case SIG_PHASE: {
            [self performSegueWithIdentifier:@"FilePickerSegue" sender:self];
            break;
        }
        case VERIFY_PHASE: {
            [self verifyDocument];
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

    // Ignore swipe if signing is in progress.
    if (self.isVerifying) return;

    // Navigating to next step in this example.
    if (self.page.currentPage < (LAST_PHASE - 1) && [self canProceed]) {
        self.page.currentPage = self.page.currentPage + 1;
        [self driftLeftFadeOutAndRefreshNextView];
    }
}

-(IBAction)onSwipeRight:(id)sender {

    // Ignore swipe if signing is in progress.
    if (self.isVerifying) return;

    // Navigating back to previous step in this example.
    if (self.page.currentPage > FIRST_PHASE) {
        self.page.currentPage = self.page.currentPage - 1;
        [self driftRightFadeOutAndRefreshNextView];
    }
}

-(BOOL)canProceed {
    
    if (self.page.currentPage >= DOC_PHASE && self.document == nil) {
        self.page.currentPage = DOC_PHASE;
        self.hint.text = @"You must select a document to proceed.";
        return NO;
    }
    else if (self.page.currentPage >= SIG_PHASE && self.signature == nil) {
        self.page.currentPage = SIG_PHASE;
        self.hint.text = @"You must choose a signature to proceed.";
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
    
    self.title = @"PKCS7 (CMS) Verify";
    
    switch (self.page.currentPage ) {
        case FIRST_PHASE: {
            // Describe the example.
            self.detail.textAlignment = NSTextAlignmentLeft;
            self.detail.text = @"This example demonstrates how to verify a detached PKCS#7 signature.\n\nBefore you begin ensure you have provisioned your trusted Certificate Authorities using UEM CA Certificate profiles. You will be asked to choose a document and its associated detached signature from the Documents folder. There is already an example document but you can use iTunes File Sharing to upload other documents or signatures generated from another application. Alternatively you may generate the signature using the PKCS#7 Sign example bundled with this app.";
            self.button.hidden = true;
            self.moreDetail.text = @"";
            if (hint) self.hint.text = @"Swipe left to begin.";
            break;
        }
        case DOC_PHASE: {
            // Step 1: Select a document to verify.
            self.detail.textAlignment = NSTextAlignmentCenter;
            if (self.document) {
                self.detail.text = @"The following file is selected for verification:";
                self.moreDetail.text = [NSString stringWithFormat:@"%@", [self document]];
                if (hint) self.hint.text = @"Next: Select the corresponding signature.";
            }
            else {
                self.detail.text = @"Select a document to verify. You can upload documents using iTunes File Sharing.";
                self.moreDetail.text = @"";
                if (hint) self.hint.text = @"";
            }
            [self setupButtonWithTitle:@"Open Documents Folder"];
            self.button.hidden = false;
            break;
        }
        case SIG_PHASE: {
            // Step 2: Select a signature.
            self.detail.textAlignment = NSTextAlignmentCenter;
            if (self.signature) {
                self.detail.text = @"The following signature is selected:";
                self.moreDetail.text = [NSString stringWithFormat:@"%@", [self signature]];
                if (hint) self.hint.text = @"Next: Verify this signature.";
            }
            else {
                self.detail.text = @"Select a signature to verify. You can generate a signature with the PKCS#7 Sign example, or transfer the signature using iTunes File Sharing.";
                self.moreDetail.text = @"";
                if (hint) self.hint.text = @"";
            }
            [self setupButtonWithTitle:@"Open Documents Folder"];
            self.button.hidden = false;
            break;
        }
        case VERIFY_PHASE: {
            // Step 3: Verify the signature.
            self.detail.textAlignment = NSTextAlignmentCenter;
            self.detail.text = @"The signature will be verified for:";
            self.moreDetail.text = [NSString stringWithFormat:@"Document: %@\nSignature:%@", self.document, self.signature];
            [self setupButtonWithTitle:@"Verify"];
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


#pragma mark verify document

/** Trigger OFF the main UI thread. Verification can take a while for larger
 *  key lengths and documents. We do not want block the main UI thread for too long, otherwise
 *  the OS will terminate the app.
 */
- (void)verifyDocument {

    self.isVerifying = YES;
    [self.activity startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
        [self verifyDocumentBlocking];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activity stopAnimating];
            self.isVerifying = NO;
        });
    });
}

- (void)verifyDocumentBlocking {

    // Declare Crypto locals.
    struct GDStream* doc = NULL;
    struct GDStream* p7Sig = NULL;
    struct GDPKCS7* p7 = NULL;
    const struct GDX509List* signers = NULL;;
    struct GDX509Certificate* signer = NULL;

    // Cleanup Crypto locals.
    void (^cleanup)(void) = ^void() {
        GDX509Certificate_free(signer);
        GDPKCS7_free(p7, 0);
        GDStream_free(p7Sig);
        GDStream_free(doc);
    };

    // Load document into a stream.
    doc = [self readFile:[_documentsFolder stringByAppendingPathComponent:_document]];
    if (!doc) {
        [self showAlert:@"Error" text:[NSString stringWithFormat:@"Failed to read contents of %@", _document]];
        cleanup();
        return;
    }

    // Load the detatched signature.
    p7Sig = [self readFile:[_documentsFolder stringByAppendingPathComponent:_signature]];
    if (!p7Sig) {
        [self showAlert:@"Error" text:[NSString stringWithFormat:@"Failed to read contents of %@", _signature]];
        cleanup();
        return;
    }
    
    // Read the signature.
    p7 = GDPKCS7_read(p7Sig, 0);
    if (!p7) {
        [self showAlert:@"Error" text:[NSString stringWithFormat:@"Failed to read signature: %s", GDCryptoError_string(GDCryptoError_get())]];
        cleanup();
        return;
    }
    
    // Check it is a signature.
    if (GDPKCS7_type(p7, 0) != GDPKCS7_SIGNED) {
        [self showAlert:@"Error" text:@"File chosen is not a PKCS7 signature."];
        cleanup();
        return;
    }
    
    // Verify the document has not been edited since it was signed.
    if (GDPKCS7_verify(p7, NULL, NULL, doc, NULL, GDPKCS7_NOVERIFY) != 1) {
        [self showAlert:@"Error" text:[NSString stringWithFormat:@"Digest verification failure. %@ has changed after it was signed. Error:%s", _document, GDCryptoError_string(GDCryptoError_get())]];
        cleanup();
        return;
    }

    // Verify that the signer is trusted by Dynamics.
    if (GDPKCS7_verify(p7, NULL, NULL, doc, NULL, 0) == 1) {
        signers = GDPKCS7_get_signers(p7, 0);
        if (signers)
            signer = GDX509Certificate_create(GDX509List_value(signers, 0));
        [self showAlert:@"Success" text:[NSString stringWithFormat:@"Document verified. It was signed by: %s", signer?signer->subject:"unknown"]];
        cleanup();
        return;
    }
    else {
        [self showAlert:@"Error" text:[NSString stringWithFormat:@"Failed to verify document: %s", GDCryptoError_string(GDCryptoError_get())]];
        cleanup();
        return;
    }
}

-(struct GDStream*)readFile:(NSString*)file {
    
    struct GDStream* stream = GDStream_new(GDStream_mem_storage_method());
    if (stream) {
        NSFileHandle* fileHandle = [NSFileHandle fileHandleForReadingAtPath:file];
        if (fileHandle) {
            NSData* data;
            int dataLen;
            do {
                data = [fileHandle readDataOfLength:1024];
                dataLen = (int)[data length];
                if (dataLen > 0)
                    GDStream_write(stream, [data bytes], dataLen);
                
            } while (dataLen > 0);
            [fileHandle closeFile];
        }
    }
    return stream;
}

@end

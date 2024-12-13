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

#import "PKCS7SignViewController.h"
#import "CertificateListViewController.h"
#import "CertificateDetailViewController.h"
#import "FilePickerViewController.h"

#include <BlackBerryDynamics/GD/GDCredential.h>
#include <BlackBerryDynamics/GD/GDCryptoPKCS7.h>

@interface PKCS7SignViewController ()

    @property (nonatomic) const struct GDX509* signingCert;
    @property (nonatomic) struct GDKey* signingKey;
    @property (nonatomic, nullable) NSString* documentsFolder;
    @property (nonatomic, nullable) NSString* document;
    @property (atomic) BOOL isSigning;
@end

@implementation PKCS7SignViewController

typedef enum {
    FIRST_PHASE,
    CERT_PHASE,
    DOC_PHASE,
    SIGN_PHASE,
    LAST_PHASE
} Phases;

#pragma mark - Property accessors

- (void)setSigningCert:(const struct GDX509*)cert {
    
    GDX509_free((struct GDX509*)_signingCert);
    _signingCert = GDX509_copy(cert);
}

- (void)setSigningKey:(struct GDKey*)key {
    
    GDKey_free(_signingKey);
    _signingKey = key;
}


#pragma UI initialization

- (void)viewWillAppear:(BOOL)animated {

    // Set background of Navigation Controller to white for swipe animation purposes.
    self.parentViewController.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {

    [super viewDidLoad];
    self.signingCert = NULL;
    self.signingKey = NULL;
    self.page.numberOfPages = LAST_PHASE;
    self.page.currentPage = FIRST_PHASE;
    [self.activity stopAnimating];
    self.isSigning = NO;
    [self refresh:YES];
}

- (void)dealloc {

    self.signingKey = NULL;
    self.signingCert = NULL;
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
    
    if ([[segue identifier] isEqualToString:@"CertificateListSegue"]) {
        __weak CertificateListViewController* vc = [segue destinationViewController];
        vc.signCertsOnly = YES;
    }
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    
    if ([[segue identifier] isEqualToString:@"CertificateUnwindSegue"]) {
        __weak CertificateDetailViewController* vc = [segue sourceViewController];
        self.signingCert = vc.certificate;
        self.signingKey = GDKey_private(vc.certificate);
    }
    else if ([[segue identifier] isEqualToString:@"FilePickerUnwindSegue"]) {
        __weak FilePickerViewController* vc = [segue sourceViewController];
        self.documentsFolder = vc.documentsFolder;
        self.document = vc.document;
    }
    [self refresh:YES];
}

-(IBAction)onButtonDown:(id)sender {
    
    switch (self.page.currentPage) {
        case CERT_PHASE: {
            [self performSegueWithIdentifier:@"CertificateListSegue" sender:self];
            break;
        }
        case DOC_PHASE: {
            [self performSegueWithIdentifier:@"FilePickerSegue" sender:self];
            break;
        }
        case SIGN_PHASE: {
            [self signDocument];
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
    if (self.isSigning) return;

    // Navigating to next step in this example.
    if (self.page.currentPage < (LAST_PHASE - 1) && [self canProceed]) {
        self.page.currentPage = self.page.currentPage + 1;
        [self driftLeftFadeOutAndRefreshNextView];
    }
}

-(IBAction)onSwipeRight:(id)sender {

    // Ignore swipe if signing is in progress.
    if (self.isSigning) return;

    // Navigating back to previous step in this example.
    if (self.page.currentPage > FIRST_PHASE) {
        self.page.currentPage = self.page.currentPage - 1;
        [self driftRightFadeOutAndRefreshNextView];
    }
}

-(BOOL)canProceed {

    if (self.page.currentPage >= CERT_PHASE && self.signingCert == nil) {
        self.page.currentPage = CERT_PHASE;
        self.hint.text = @"You must select a signing certificate to proceed.";
        return NO;
    }
    else if (self.page.currentPage >= DOC_PHASE && self.document == nil) {
        self.page.currentPage = DOC_PHASE;
        self.hint.text = @"You must choose a document to proceed.";
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

    self.title = @"PKCS7 (CMS) Sign";

    switch (self.page.currentPage ) {
        case FIRST_PHASE: {
            // Describe the example.
            self.detail.textAlignment = NSTextAlignmentLeft;
            self.detail.text = @"This example demonstrates how to create a detached PKCS#7 signature.\n\nBefore you begin ensure you have provisioned an appropriate signing certificate using a UEM User Certificate, User Credential, or SCEP profile. You will be asked to choose a document from the Documents folder. There is already an example document but you can use iTunes File Sharing to upload other documents. After the document is signed you may then use iTunes to retrieve the signature should you wish to evaluate it with another tool, or use the PKCS#7 Verify example bundled with this app to validate it.";
            self.button.hidden = true;
            self.moreDetail.text = @"";
            if (hint) self.hint.text = @"Swipe left to begin.";
            break;
        }
        case CERT_PHASE: {
            // Step 1: Select a signing certificate.
            struct GDX509List* signingCerts = GDX509List_valid_user_signing_certs();
            self.detail.textAlignment = NSTextAlignmentCenter;
            if (signingCerts == NULL) {
                self.signingCert = NULL;
                self.detail.text = @"Valid signing certificates could not be detected. Provision an appropriate signing certificate using a UEM User Certificate, User Credential, or SCEP profile.";
                self.detail.textAlignment = NSTextAlignmentCenter;
                self.button.hidden = true;
                self.moreDetail.text = @"";
                if (hint) self.hint.text = @"";
            }
            else if (GDX509List_num(signingCerts) == 1) {
                self.signingCert = GDX509List_value(signingCerts, 0);
                self.signingKey = GDKey_private(self.signingCert);
                self.detail.text = @"The following certificate will be used:";
                self.moreDetail.text = [NSString stringWithFormat:@"%@", [self certificateDescription:self.signingCert]];
                self.button.hidden = true;
                if (hint) self.hint.text = @"Next: Select a document to sign.";
            }
            else {
                if (self.signingCert) {
                    self.detail.text = @"The following certificate will be used:";
                    self.moreDetail.text = [NSString stringWithFormat:@"%@", [self certificateDescription:self.signingCert]];
                    if (hint) self.hint.text = @"Next: Select a document to sign.";
                }
                else {
                    self.detail.text = @"There is more than one valid signing certificate provisioned. Please select one to use.";
                    self.moreDetail.text = @"";
                    if (hint) self.hint.text = @"";
                }
                [self setupButtonWithTitle:@"Select Certificate"];
                self.button.hidden = false;
            }
            GDX509List_free(signingCerts);
            break;
        }
        case DOC_PHASE: {
            // Step 2: Select a document to sign.
            self.detail.textAlignment = NSTextAlignmentCenter;
            if (self.document) {
                self.detail.text = @"The following file is selected for signing:";
                self.moreDetail.text = [NSString stringWithFormat:@"%@", [self document]];
                if (hint) self.hint.text = @"Next: Sign this document.";
            }
            else {
                self.detail.text = @"Select a document to sign. You can upload documents using iTunes File Sharing.";
                self.moreDetail.text = @"";
                if (hint) self.hint.text = @"";
            }
            [self setupButtonWithTitle:@"Open Documents Folder"];
            self.button.hidden = false;
            break;
        }
        case SIGN_PHASE: {
            // Step 3: Sign the document.
            self.detail.textAlignment = NSTextAlignmentCenter;
            self.detail.text = @"A signature will be computed for:";
            self.moreDetail.text = [NSString stringWithFormat:@"File: %@\n\n%@", self.document, [self certificateDescription:self.signingCert]];
           [self setupButtonWithTitle:@"Sign Document"];
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


#pragma mark sign document

/** Trigger OFF the main UI thread. Signing can take a while for larger
 *  key lengths and documents. We do not want block the main UI thread for too long, otherwise
 *  the OS will terminate the app.
 */
- (void)signDocument {

    self.isSigning = YES;
    [self.activity startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
        [self signDocumentBlocking];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activity stopAnimating];
            self.isSigning = NO;
        });
    });
}

- (void)signDocumentBlocking {

    // Declare C Crypto locals.
    struct GDStream* in = NULL;
    struct GDPKCS7* p7signed = NULL;
    struct GDStream* out = NULL;
    struct GDX509List* auxCerts = NULL;

    // Cleanup Crypto locals.
    void (^cleanup)(void) = ^void() {
        GDX509List_free(auxCerts);
        GDStream_free(out);
        GDPKCS7_free(p7signed, 0);
        GDStream_free(in);
    };

    // Load the document into a stream.
    in = [self readFile:[_documentsFolder stringByAppendingPathComponent:_document]];
    if (!in) {
        [self showAlert:@"Error" text:[NSString stringWithFormat:@"Failed to read contents of %@", _document]];
        cleanup();
        return;
    }

    // Add signing information to the empty signature.
    // If the signer has intermediate certificates include them in the PKCS7 signature so only the root CA need be in the trusted cert
    // store for verification purposes.
    auxCerts = GDX509List_aux_certs(_signingCert);
    p7signed = GDPKCS7_add_signer(_signingCert, _signingKey, auxCerts, GDDigest_byname("sha256"), GDPKCS7_BINARY|GDPKCS7_DETACHED);
    if (!p7signed) {
        [self showAlert:@"Error" text:[NSString stringWithFormat:@"Failed to add signer: %s", GDCryptoError_string(GDCryptoError_get())]];
        cleanup();
        return;
    }
    
    // Compute the signature.
    if (GDPKCS7_final(p7signed, in, GDPKCS7_BINARY|GDPKCS7_DETACHED) != 1) {
        [self showAlert:@"Error" text:[NSString stringWithFormat:@"Failed to sign: %s", GDCryptoError_string(GDCryptoError_get())]];
        cleanup();
        return;
    }

    // Output the signature into a stream.
    out = GDStream_new(GDStream_mem_storage_method());
    if (!out) {
        [self showAlert:@"Error" text:@"Out of memory."];
        cleanup();
        return;
    }
    if (GDPKCS7_write(out, p7signed, 0) != 1) {
        [self showAlert:@"Error" text:[NSString stringWithFormat:@"Failed to write signature: %s", GDCryptoError_string(GDCryptoError_get())]];
        cleanup();
        return;
    }

    // Save the signature stream to the Documents folder.
    NSString* outFile = [NSString stringWithFormat:@"%@.signature.p7s", _document];
    if (![self writeStream:out toFile:[_documentsFolder stringByAppendingPathComponent:outFile]]) {
        [self showAlert:@"Error" text:[NSString stringWithFormat:@"Failed to write to %@", outFile]];
        cleanup();
        return;
    }

    [self showAlert:@"Success" text:[NSString stringWithFormat:@"%@ has been signed, and the detached signature is located in your Documents folder: %@", _document, outFile]];
    
    cleanup();
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

-(BOOL)writeStream:(struct GDStream*)stream toFile:(NSString*)file {

    BOOL success = NO;
    [[NSFileManager defaultManager] createFileAtPath:file contents:nil attributes:nil];
    NSFileHandle* fileHandle = [NSFileHandle fileHandleForWritingAtPath:file];
    if (fileHandle) {
        char outBuf[1024];
        while (!GDStream_eof(stream)) {
            int len = GDStream_read(stream, outBuf, 1024);
            if (len > 0) {
                success = TRUE;
                [fileHandle writeData:[NSData dataWithBytesNoCopy:outBuf length:len freeWhenDone:NO]];
            }
        }
        [fileHandle closeFile];
    }
    return success;
}

@end

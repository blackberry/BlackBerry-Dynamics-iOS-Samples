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

#import "KeyVerifyViewController.h"
#import "FilePickerViewController.h"
#import "CertificateListViewController.h"
#import "CertificateDetailViewController.h"

#include <BlackBerryDynamics/GD/GDCredential.h>
#include <BlackBerryDynamics/GD/GDStream.h>
#include <BlackBerryDynamics/GD/GDCryptoKeyStore.h>
#include <BlackBerryDynamics/GD/GDCryptoAlgorithms.h>

@interface KeyVerifyViewController ()

    @property (nonatomic) const struct GDX509* signingCert;
    @property (nonatomic) struct GDKey* signingPublicKey;
    @property (nonatomic, nullable) NSString* documentsFolder;
    @property (nonatomic, nullable) NSString* document;
    @property (nonatomic, nullable) NSString* signature;
    @property (nonatomic, nullable) NSString* digestAlgorithm;
    @property (nonatomic) NSArray* digestAlgorithms;
    @property (atomic) BOOL isVerifying;
@end

@implementation KeyVerifyViewController

typedef enum {
    FIRST_PHASE,
    CERT_PHASE,
    DOC_PHASE,
    SIG_PHASE,
    DIGEST_PHASE,
    VERIFY_PHASE,
    LAST_PHASE
} Phases;


#pragma mark - Property accessors

- (void)setSigningCert:(const struct GDX509*)cert {

    GDX509_free((struct GDX509*)_signingCert);
    _signingCert = GDX509_copy(cert);
}

- (void)setSigningKey:(struct GDKey*)key {

    GDKey_free(_signingPublicKey);
    _signingPublicKey = key;
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
    self.digestAlgorithms = @[ @"MD5", @"SHA1", @"SHA256", @"SHA384", @"SHA512" ];
    self.picker.dataSource = self;
    self.picker.delegate = self;
    self.page.numberOfPages = LAST_PHASE;
    self.page.currentPage = FIRST_PHASE;
    self.isVerifying = NO;
    [self refresh:YES];
}

- (void)dealloc {

    self.signingCert = nil;
    self.signingKey = nil;
}


#pragma digest picker

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {

    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {

    return [_digestAlgorithms count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {

    return [_digestAlgorithms objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {

    self.digestAlgorithm = [_digestAlgorithms objectAtIndex:row];
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

    if ([[segue identifier] isEqualToString:@"FilePickerSegue"]) {
        __weak FilePickerViewController* vc = [segue destinationViewController];
        if (self.page.currentPage == CERT_PHASE)
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
                        struct GDX509List* certs = GDX509List_read([pemData bytes], (int)[pemData length]);
                        if (certs && GDX509List_num(certs) > 0) {
                            // Pick first certificate in PEM file.
                            self.signingCert = GDX509List_value(certs, 0);
                            self.signingPublicKey = GDKey_public(self.signingCert);
                            GDX509List_free(certs);
                        }
                    }
                }
                break;
            }
            case DOC_PHASE: {
                self.document = vc.document;
                break;
            }
            case SIG_PHASE: {
                self.signature = vc.document;
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

    if (self.page.currentPage >= CERT_PHASE && self.signingCert == nil) {
        self.page.currentPage = CERT_PHASE;
        self.hint.text = @"You must select the signer's certificate to proceed.";
        return NO;
    }
    else if (self.page.currentPage >= DOC_PHASE && self.document == nil) {
        self.page.currentPage = DOC_PHASE;
        self.hint.text = @"You must choose a document to proceed.";
        return NO;
    }
    else if (self.page.currentPage >= SIG_PHASE && self.document == nil) {
        self.page.currentPage = SIG_PHASE;
        self.hint.text = @"You must choose a signature to proceed.";
        return NO;
    }
    else if (self.page.currentPage >= DIGEST_PHASE && self.digestAlgorithm == nil) {
        self.page.currentPage = DIGEST_PHASE;
        self.hint.text = @"You must choose a digest algorithm to proceed.";
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

    self.title = @"Key Verify";

    switch (self.page.currentPage ) {
        case FIRST_PHASE: {
            // Describe the example.
            self.detail.textAlignment = NSTextAlignmentLeft;
            self.detail.text = @"This example demonstrates how to verify a signature and check that the document has not been tampered with by confirming that the digest within the signature matches the digest of the document.\n\nBefore you begin you should upload a PEM file containing the signer's public certificate using iTunes File Sharing. You will be asked to choose a document and its associated signature from the Documents folder. Alternatively you may generate the signature using the PKCS#1 Sign example bundled with this app.";
            self.button.hidden = true;
            self.picker.hidden = true;
            self.moreDetail.text = @"";
            if (hint) self.hint.text = @"Swipe left to begin.";
            break;
        }
        case CERT_PHASE: {
            // Step 1: Select a signing certificate.
            self.detail.textAlignment = NSTextAlignmentCenter;
            if (self.signingCert) {
                self.detail.text = @"The following certificate will be used when verifying the signature:";
                self.moreDetail.text = [NSString stringWithFormat:@"%@", [self certificateDescription:self.signingCert]];
                if (hint) self.hint.text = @"Next: Sselect the document to verify.";
            }
            else {
                self.detail.text = @"Select the signer's certificate. You can upload this in PEM format using iTunes File Sharing. It should match the certificate used to generate the signature, otherwise verification will fail.";
                self.moreDetail.text = @"";
                if (hint) self.hint.text = @"";
            }
            [self setupButtonWithTitle:@"Open Documents Folder"];
            self.button.hidden = false;
            self.picker.hidden = true;
            break;
        }
        case DOC_PHASE: {
            // Step 2: Select a document to verify.
            self.detail.textAlignment = NSTextAlignmentCenter;
            if (self.document) {
                self.detail.text = @"The following file is selected for verification:";
                self.moreDetail.text = [NSString stringWithFormat:@"%@", [self document]];
                if (hint) self.hint.text = @"Next: Select the signature to verify.";
            }
            else {
                self.detail.text = @"Select a document to verify. You can upload documents using iTunes File Sharing.";
                self.moreDetail.text = @"";
                if (hint) self.hint.text = @"";
            }
            [self setupButtonWithTitle:@"Open Documents Folder"];
            self.button.hidden = false;
            self.picker.hidden = true;
            break;
        }
        case SIG_PHASE: {
            // Step 3: Select a signature to verify.
            self.detail.textAlignment = NSTextAlignmentCenter;
            if (self.signature) {
                self.detail.text = @"The following signature file is selected:";
                self.moreDetail.text = [NSString stringWithFormat:@"%@", [self signature]];
                if (hint) self.hint.text = @"Next: Select the signature digest.";
            }
            else {
                self.detail.text = @"Select a signature. You can upload documents using iTunes File Sharing.";
                self.moreDetail.text = @"";
                if (hint) self.hint.text = @"";
            }
            [self setupButtonWithTitle:@"Open Documents Folder"];
            self.button.hidden = false;
            self.picker.hidden = true;
            break;
        }
        case DIGEST_PHASE: {
            // Step 4: Select the digest algorithm.
            self.detail.textAlignment = NSTextAlignmentCenter;
            if (self.digestAlgorithm) {
                self.detail.text = @"The following digest algorithm is selected:";
                self.moreDetail.text = [NSString stringWithFormat:@"%@", [self digestAlgorithm]];
                if (hint) self.hint.text = @"Next: Verify the document.";
            }
            else {
                self.detail.text = @"Select a digest algorithm. The digest should match the digest used when generating the signature, otherwise verification will fail.";
                self.moreDetail.text = @"";
                if (hint) self.hint.text = @"";
            }
            self.button.hidden = true;
            self.picker.hidden = false;
            break;
        }
        case VERIFY_PHASE: {
            // Step 5: Verify the document.
            self.detail.textAlignment = NSTextAlignmentCenter;
            self.detail.text = @"The following signature and document will be verified:";
            self.moreDetail.text = [NSString stringWithFormat:@"Document: %@\nSignature: %@\nDigest: %@\n\n%@", self.document, self.signature, self.digestAlgorithm, [self certificateDescription:self.signingCert]];
            [self setupButtonWithTitle:@"Verify"];
            self.button.hidden = false;
            self.picker.hidden = true;
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

    // Delcare Crypto local variables.
    struct GDStream* doc = NULL;
    struct GDStream* sig = NULL;
    void* signature = NULL;
    struct GDDigestContext* ctx = NULL;

    // Cleanup Crypto locals.
    void (^cleanup)(void) = ^void() {
        free(signature);
        GDDigest_free(ctx);
        GDStream_free(sig);
        GDStream_free(doc);
    };

    // Read input document.
    int docLen = [self readFile:[self.documentsFolder stringByAppendingPathComponent:self.document] stream:&doc];
    if (docLen == 0) {
        [self showAlert:@"Error" text:[NSString stringWithFormat:@"Failed to read contents of %@", self.document]];
        cleanup();
        return;
    }

    // Initialize digest algorithm.
    ctx = GDDigest_new();
    if (!ctx) {
        [self showAlert:@"Error" text:@"Out of memory."];
        cleanup();
        return;
    }
    if (GDDigest_verify_init(ctx, NULL, GDDigest_byname([_digestAlgorithm UTF8String]), (void*)self.signingPublicKey) != 1) {
        [self showAlert:@"Error" text:[NSString stringWithFormat:@"Failed to initialize digest:%s", GDCryptoError_string(GDCryptoError_get())]];
        cleanup();
        return;
    };

    // Calculate digest for the document.
    const int bufSz = 1024*64;
    char buf[bufSz];
    int bufBytes = 0;
    while (!GDStream_eof(doc)) {
        // Read a section of the document.
        bufBytes = GDStream_read(doc, buf, bufSz);
        if (bufBytes < 0) {
            [self showAlert:@"Error" text:[NSString stringWithFormat:@"Error occurred while reading %@.", self.document]];
            cleanup();
            return;
        }
        // Update digest with section of document.
        if (GDDigest_update(ctx, buf, bufBytes) != 1) {
            [self showAlert:@"Error" text:[NSString stringWithFormat:@"Failed to calculate digest:%s", GDCryptoError_string(GDCryptoError_get())]];
            cleanup();
            return;
        }
    }

    // Load the signature.
    int sigLen = [self readFile:[self.documentsFolder stringByAppendingPathComponent:self.signature] stream:&sig];
    if (!sig) {
        [self showAlert:@"Error" text:[NSString stringWithFormat:@"Failed to read contents of %@", self.signature]];
        cleanup();
        return;
    }
    signature = calloc(sigLen, 1);
    size_t signatureSz = (size_t)GDStream_read(sig, signature, sigLen);
    if (signatureSz <= 0) {
        [self showAlert:@"Error" text:[NSString stringWithFormat:@"Failed to read signature: %s", GDCryptoError_string(GDCryptoError_get())]];
        cleanup();
        return;
    }

    // Verify the document.
    int rc = GDDigest_verify_final(ctx, signature, signatureSz);
    if (rc == 1) {
        [self showAlert:@"Success" text:@"Document verified."];
    }
    else {
        [self showAlert:@"Error" text:[NSString stringWithFormat:@"Verification failure. Error:%s", GDCryptoError_string(GDCryptoError_get())]];
    }

    cleanup();
}

-(int) readFile:(NSString*)file stream:(struct GDStream**)stream {

    int streamLen = 0;
    *stream = GDStream_new(GDStream_mem_storage_method());
    if (*stream) {
        NSFileHandle* fileHandle = [NSFileHandle fileHandleForReadingAtPath:file];
        if (fileHandle) {
            NSData* data;
            int dataLen;
            do {
                data = [fileHandle readDataOfLength:1024];
                dataLen = (int)[data length];
                if (dataLen > 0)
                    streamLen += GDStream_write(*stream, [data bytes], dataLen);

            } while (dataLen > 0);
            [fileHandle closeFile];
        }
    }
    return streamLen;
}

@end

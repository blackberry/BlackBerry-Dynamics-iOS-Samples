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

#import "SMIMEReadViewController.h"
#import "CertificateListViewController.h"
#import "CertificateDetailViewController.h"
#import "FilePickerViewController.h"

#include <BlackBerryDynamics/GD/GDCredential.h>
#include <BlackBerryDynamics/GD/GDCryptoPKCS7.h>

@interface SMIMEReadViewController ()

    @property (nonatomic) const struct GDX509* myCert;
    @property (nonatomic) struct GDKey* myPrivateKey;
    @property (nonatomic) NSString* documentsFolder;
    @property (nonatomic) NSString* smimeContent;
    @property (atomic) BOOL isVerifying;
    @property (atomic) NSString* messageText;
@end

@implementation SMIMEReadViewController

typedef enum {
    FIRST_PHASE,
    EMAIL_PHASE,
    CERT_PHASE,
    DECODE_PHASE,
    LAST_PHASE
} Phases;


#pragma mark - Property accessors

- (void)setMyCert:(const struct GDX509*)cert {
    
    GDX509_free((struct GDX509*)_myCert);
    _myCert = GDX509_copy(cert);
}

- (void)setMyPrivateKey:(struct GDKey*)key {
    
    GDKey_free(_myPrivateKey);
    _myPrivateKey = key;
}


#pragma UI initialization

- (void)viewWillAppear:(BOOL)animated {

    // Set background of Navigation Controller to white for swipe animation purposes.
    self.parentViewController.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {

    [super viewDidLoad];
    self.myCert = NULL;
    self.myPrivateKey = NULL;
    self.textOutput.delegate = self;
    self.page.numberOfPages = LAST_PHASE;
    self.page.currentPage = FIRST_PHASE;
    self.isVerifying = NO;
    [self refresh:YES];
}

- (void)dealloc {

    self.myPrivateKey = NULL;
    self.myCert = NULL;
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


#pragma text view delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    return NO;
}


#pragma mark UI navigation, actions, gestures

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"CertificateListSegue"]) {
        __weak CertificateListViewController* vc = [segue destinationViewController];
        vc.encCertsOnly = YES;
    }
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    
    if ([[segue identifier] isEqualToString:@"CertificateUnwindSegue"]) {
        __weak CertificateDetailViewController* vc = [segue sourceViewController];
        self.myCert = vc.certificate;
        self.myPrivateKey = GDKey_private(vc.certificate);
    }
    else if ([[segue identifier] isEqualToString:@"FilePickerUnwindSegue"]) {
        __weak FilePickerViewController* vc = [segue sourceViewController];
        self.documentsFolder = vc.documentsFolder;
        self.smimeContent = vc.document;
    }
    [self refresh:YES];
}

-(IBAction)onButtonDown:(id)sender {
    
    switch (self.page.currentPage) {
        case EMAIL_PHASE: {
            [self performSegueWithIdentifier:@"FilePickerSegue" sender:self];
            break;
        }
        case CERT_PHASE: {
            [self performSegueWithIdentifier:@"CertificateListSegue" sender:self];
            break;
        }
        case DECODE_PHASE: {
            [self verifyEmail];
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
    
    if (self.page.currentPage >= EMAIL_PHASE && self.smimeContent == nil) {
        self.page.currentPage = EMAIL_PHASE;
        self.hint.text = @"You must select an SMIME e-mail to proceed.";
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
    
    self.title = @"Read SMIME";
    
    switch (self.page.currentPage ) {
        case FIRST_PHASE: {
            // Describe the example.
            self.detail.textAlignment = NSTextAlignmentLeft;
            self.detail.text = @"This example demonstrates how to verify the sender of a simple SMIME message.\n\nBefore you begin, if the message was encrypted, you will need to provision an appropriate e-mail decryption certificate using a UEM User Certificate, User Credential, or SCEP profile. You should also provision your trusted Certificate Authorities using UEM CA Certificate profiles. The e-mail to be verified must exist within the Documents folder. You can upload this using iTunes File Sharing or you may generate it using the SMIME Compose example bundled with this app.";
            self.button.hidden = true;
            self.textOutput.hidden = true;
            self.moreDetail.text = @"";
            if (hint) self.hint.text = @"Swipe left to begin.";
            break;
        }
        case EMAIL_PHASE: {
            // Step 1: Select the e-mail file.
            self.detail.textAlignment = NSTextAlignmentCenter;
            if (self.smimeContent) {
                self.detail.text = @"The following file is selected:";
                self.moreDetail.text = self.smimeContent;
                if (hint) self.hint.text = @"Next: Select your certicate.";
            }
            else {
                self.detail.text = @"Select the SMIME e-mail. You can upload to the Documents folder using iTunes File Sharing.";
                self.moreDetail.text = @"";
                if (hint) self.hint.text = @"";
            }
            [self setupButtonWithTitle:@"Open Documents Folder"];
            self.button.hidden = false;
            self.textOutput.hidden = true;
            break;
        }
       case CERT_PHASE: {
            // Step 2: Select a decryption certificate.
           self.detail.textAlignment = NSTextAlignmentCenter;
           struct GDX509List* certs = GDX509List_all_user_encryption_certs();
            if (certs == NULL) {
                self.myCert = NULL;
                self.detail.text = @"A decryption certificate could not be detected. You may not need one if the SMIME message was not encrypted.  If it was encrypted, you can provision an appropriate decryption certificate using a UEM User Certificate, User Credential, or SCEP profile.";
                self.moreDetail.text = @"";
                self.button.hidden = true;
            }
            else if (GDX509List_num(certs) == 1) {
                self.myCert = GDX509List_value(certs, 0);
                self.myPrivateKey = GDKey_private(self.myCert);
                self.detail.text = @"The following certificate will be used if decryption is required:";
                self.moreDetail.text = [NSString stringWithFormat:@"%@", [self certificateDescription:self.myCert]];
                self.button.hidden = true;
            }
            else {
                if (self.myCert) {
                    self.detail.text = @"The following certificate will be used if decryption is required:";
                    self.moreDetail.text = [NSString stringWithFormat:@"%@", [self certificateDescription:self.myCert]];
                    if (hint) self.hint.text = @"Next: Verify the e-mail.";
                }
                else {
                    self.detail.text = @"There is more than one valid encryption certificate provisioned. Please select one to use.";
                    self.moreDetail.text = @"";
                }
                [self setupButtonWithTitle:@"Select Certificate"];
                self.button.hidden = false;
            }
            GDX509List_free(certs);
            self.textOutput.hidden = true;
            if (hint) self.hint.text = @"Next: Verify the e-mail.";
            break;
        }
        case DECODE_PHASE: {
            // Step 3: Decode the message.
            self.detail.textAlignment = NSTextAlignmentCenter;
            self.detail.text = @"The following message will be verified and saved to the Documents folder:";
            self.moreDetail.text = self.smimeContent;
            [self setupButtonWithTitle:@"Verify"];
            self.button.hidden = false;
            [self setupTextOutput];
            self.textOutput.hidden = false;
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

- (void)setupTextOutput {
    
    self.textOutput.layer.borderWidth = 1;
    self.textOutput.layer.borderColor = [UIColor colorWithRed:53.0/255.0 green:167.0/255.0 blue:220.0/255.0 alpha:1.0].CGColor;
    self.textOutput.text = @"";
    [self.textOutput layoutIfNeeded];
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

/** Trigger OFF the main UI thread. Verification can take a while for larger
 *  key lengths and messages. We do not want block the main UI thread for too long, otherwise
 *  the OS will terminate the app.
 */
- (void)verifyEmail {

    self.isVerifying = YES;
    [self.activity startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
        [self verifyEmailBlocking];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.textOutput.text = self.messageText;
            [self.activity stopAnimating];
            self.isVerifying = NO;
        });
    });
}

- (void)verifyEmailBlocking {

    // Declare Crypto local variables.
    struct GDStream* smime = NULL;
    struct GDStream* smime_mem_stream = NULL;
    struct GDStream* content = NULL;
    struct GDPKCS7* p7 = NULL;
    const struct GDX509List* signers = NULL;
    struct GDX509Certificate* signer = NULL;

    // Cleanup Crypto locals.
    void (^cleanup)(void) = ^void() {
        GDX509Certificate_free(signer);
        GDPKCS7_free(p7, 0);
        GDStream_free(content);
        GDStream_free(smime_mem_stream);
        GDStream_free(smime);
    };

    // Read input document.
    smime = [self readFile:[self.documentsFolder stringByAppendingPathComponent:self.smimeContent]];
    if (!smime) {
        [self showAlert:@"Error" text:[NSString stringWithFormat:@"Failed to read contents of %@", self.smimeContent]];
        cleanup();
        return;
    }

    const int smime_buf_sz = 32768;
    char smime_buf[smime_buf_sz];
    int smime_buf_len = 0;
DECODE:
    // A little hack to copy the smime envelope into a memory stream, since
    // GDPKCS7_SMIME_read only supports this type of stream.
    smime_buf_len = GDStream_read(smime, (void*)smime_buf, smime_buf_sz);
    smime_mem_stream = GDStream_new_mem_buf(smime_buf, smime_buf_len);
    GDStream_free(smime); smime = NULL;

    // Read SMIME envelope
    p7 = GDPKCS7_SMIME_read(smime_mem_stream, &content, 0);
    if (!p7) {
        [self showAlert:@"Error" text:[NSString stringWithFormat:@"Failed to read SMIME envelope: %s", GDCryptoError_string(GDCryptoError_get())]];
        cleanup();
        return;
    }
    GDStream_free(smime_mem_stream); smime_mem_stream = NULL;

    if (content) {
        if (GDPKCS7_verify(p7, NULL, NULL, content, NULL, GDPKCS7_DETACHED) != 1) {
            [self showAlert:@"Error" text:[NSString stringWithFormat:@"Failed to verify email: %s", GDCryptoError_string(GDCryptoError_get())]];
            // Dump unverified mail to content stream so it can be read anyway.
            GDPKCS7_verify(p7, NULL, NULL, NULL, content, GDPKCS7_NOVERIFY);
        }
    }
    else {
        int type = GDPKCS7_type(p7, 0);
        if (type == GDPKCS7_ENVELOPED) {
            if (!self.myCert) {
                [self showAlert:@"Error" text:@"Unable to decrypt e-mail without decryption certificate. Please return and select certificate."];
                cleanup();
                return;
            }
            content = GDStream_new(GDStream_mem_storage_method());
            if (!content) {
                [self showAlert:@"Error" text:@"Out of memory."];
                cleanup();
                return;
            }
            if (GDPKCS7_decrypt(p7, self.myPrivateKey, self.myCert, content, 0) == 1) {
                smime = content;
                content = NULL;
                GDPKCS7_free(p7, 0); p7 = NULL;
                goto DECODE;
            }
            else {
                [self showAlert:@"Error" text:[NSString stringWithFormat:@"Failed to decrypt email: %s", GDCryptoError_detailed_string()]];
                cleanup();
                return;
            }
        }
        else if (type == GDPKCS7_SIGNED) {
            content = GDStream_new(GDStream_mem_storage_method());
            if (!content) {
                [self showAlert:@"Error" text:@"Out of memory."];
                cleanup();
                return;
            }
            if (GDPKCS7_verify(p7, NULL, NULL, NULL, content, 0) != 1) {
                [self showAlert:@"Error" text:[NSString stringWithFormat:@"Failed to verify email: %s", GDCryptoError_detailed_string()]];
                // Dump unverified mail to content stream so it can be read anyway.
                GDPKCS7_verify(p7, NULL, NULL, NULL, content, GDPKCS7_NOVERIFY);
            }
        }
        else {
            [self showAlert:@"Error" text:[NSString stringWithFormat:@"This SMIME format (type:%d) not supported.", GDPKCS7_type(p7, 0)]];
            cleanup();
            return;
        }
    }

    // Show plain text message.
    self.messageText = @"";
    char buf[1024];
    while (!GDStream_eof(content)) {
        int nBytes = GDStream_read(content, buf, 1024);
        if (nBytes > 0)
            self.messageText = [self.messageText stringByAppendingString:[[NSString alloc] initWithBytesNoCopy:buf length:nBytes encoding:NSUTF8StringEncoding freeWhenDone:NO]];
    }

    signers = GDPKCS7_get_signers(p7, 0);
    if (signers) {
        signer = GDX509Certificate_create(GDX509List_value(signers, 0));
        [self showAlert:@"Success" text:[NSString stringWithFormat:@"E-mail verified. It was signed by: %s", signer?signer->subject:"unknown"]];
    }

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

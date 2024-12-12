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

#import "SMIMEComposeViewController.h"
#import "CertificateListViewController.h"
#import "CertificateDetailViewController.h"
#import "FilePickerViewController.h"

#include <BlackBerryDynamics/GD/GDCredential.h>
#include <BlackBerryDynamics/GD/GDCryptoPKCS7.h>

@interface SMIMEComposeViewController ()

    @property (nonatomic) const struct GDX509* myCert;
    @property (nonatomic) struct GDKey* myPrivateKey;
    @property (nonatomic) struct GDX509List* recipientCerts;
    @property (atomic) BOOL isSigning;
    @property (atomic) BOOL shouldEncrypt;
    @property (atomic) NSString* messageText;
@end

@implementation SMIMEComposeViewController

typedef enum {
    FIRST_PHASE,
    CERT_PHASE,
    OPTION_PHASE,
    RECIPIENT_PHASE,
    COMPOSE_AND_ENCODE_PHASE,
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

- (void)setRecipientCerts:(struct GDX509List*)certs {
    
    GDX509List_free((struct GDX509List*)_recipientCerts);
    _recipientCerts = certs;
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
    self.recipientCerts = NULL;
    self.binarySwitch.on = NO;
    self.textInput.text = @"";
    self.textInput.delegate = self;
    self.page.numberOfPages = LAST_PHASE;
    self.page.currentPage = FIRST_PHASE;
    self.isSigning = NO;
    self.shouldEncrypt = NO;
    [self refresh:YES];
}

- (void)dealloc {

    self.myPrivateKey = NULL;
    self.myCert = NULL;
    self.recipientCerts = NULL;
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
    if ([[segue identifier] isEqualToString:@"FilePickerSegue"]) {
        __weak FilePickerViewController* vc = [segue destinationViewController];
        vc.fileExtension = @"pem"; // Show only PEM files.
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
        NSString* pemFile = [vc.documentsFolder stringByAppendingPathComponent:vc.document];
        if (pemFile) {
            NSData* pemData = [NSData dataWithContentsOfFile:pemFile];
            if (pemData)
                self.recipientCerts = GDX509List_read([pemData bytes], (int)[pemData length]);
        }
        self.textInput.text = @""; // New recipients, so reset e-mail text when next viewed.
    }
    [self refresh:YES];
}

-(IBAction)onButtonDown:(id)sender {
    
    switch (self.page.currentPage) {
        case CERT_PHASE: {
            [self performSegueWithIdentifier:@"CertificateListSegue" sender:self];
            break;
        }
        case RECIPIENT_PHASE: {
            [self performSegueWithIdentifier:@"FilePickerSegue" sender:self];
            break;
        }
        case COMPOSE_AND_ENCODE_PHASE: {
            [self composeEmail];
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
    
    if (self.page.currentPage >= CERT_PHASE && self.myCert == nil) {
        self.page.currentPage = CERT_PHASE;
        self.hint.text = @"You must select a signing certificate to proceed.";
        return NO;
    }
    else if (self.page.currentPage >= RECIPIENT_PHASE && self.recipientCerts == nil) {
        self.page.currentPage = RECIPIENT_PHASE;
        self.hint.text = @"You must load a PEM file proceed.";
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
    
    self.title = @"Compose SMIME";
    
    switch (self.page.currentPage ) {
        case FIRST_PHASE: {
            // Describe the example.
            self.detail.textAlignment = NSTextAlignmentLeft;
            self.detail.text = @"This example demonstrates how to encrypt and sign an SMIME e-mail.\n\nBefore you begin ensure you have provisioned an appropriate e-mail signing certificate using a UEM User Certificate, User Credential, or SCEP profile. If your certificate allows, you will have the option to encrypt the e-mail too. Some example recipient certificates are bundled within this app and are required to extract the recipient e-mail address from the Subject or Subject Alternative Name fields and to encrypt (if enabled) with their puiblic key. You can upload other PEM files containing public certificates using iTunes File Sharing. The e-mail is not sent but is saved to the Documents folder where you may retrieve it using iTunes File Sharing and open in another mail application, or decode and view it using the SMIME Read example bundled with this app.";
            self.button.hidden = true;
            self.binarySwitch.hidden = true;
            self.textInput.hidden = true;
            self.moreDetail.text = @"";
            if (hint) self.hint.text = @"Swipe left to begin.";
            break;
        }
        case CERT_PHASE: {
            // Step 1: Select a signing certificate.
            self.detail.textAlignment = NSTextAlignmentCenter;
            struct GDX509List* signingCerts = GDX509List_valid_user_signing_certs();
            if (signingCerts == NULL) {
                self.myCert = NULL;
                self.detail.text = @"Valid signing certificates could not be detected. Provision an appropriate signing certificate using a UEM User Certificate, User Credential, or SCEP profile.";
                self.button.hidden = true;
                if (hint) self.hint.text = @"";
            }
            else if (GDX509List_num(signingCerts) == 1) {
                self.myCert = GDX509List_value(signingCerts, 0);
                self.myPrivateKey = GDKey_private(self.myCert);
                self.detail.text = @"The following certificate will be used:";
                self.moreDetail.text = [NSString stringWithFormat:@"%@", [self certificateDescription:self.myCert]];
                self.button.hidden = true;
                if (hint) self.hint.text = @"Next: Select the encryption option.";
            }
            else {
                if (self.myCert) {
                    NSString* fromAddress = [self emailAddressFromCertificate:self.myCert];
                    if (fromAddress.length) {
                        // MIME  headers.
                        self.detail.text = @"The following certificate will be used:";
                        self.moreDetail.text = [NSString stringWithFormat:@"%@", [self certificateDescription:self.myCert]];
                        if (hint) self.hint.text = @"Next: Select the encryption option.";
                    }
                    else {
                        self.detail.text = @"There is no e-mail address in the signing certificate. Please, try to select another certificate.";
                        self.moreDetail.text = @"";
                        if (hint) self.hint.text = @"";
                    }
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
            self.binarySwitch.hidden = true;
            self.textInput.hidden = true;
            break;
        }
        case OPTION_PHASE: {
            // Step 2: Encrypt or not.
            self.detail.textAlignment = NSTextAlignmentCenter;
            if ([self canEncryptWith:self.myCert]) {
                self.detail.text = @"Your certificate also allows encryption. Do you want to encrypt the e-mail too?";
                self.binarySwitch.hidden = false;
                self.binarySwitch.enabled = true;
            }
            else {
                self.detail.text = @"Your certificate does not allow encryption. That's okay, you can still sign the message.";
                self.binarySwitch.hidden = false;
                self.binarySwitch.enabled = false;
            }
            self.moreDetail.text = @"";
            self.button.hidden = true;
            self.textInput.hidden = true;
            if (hint) self.hint.text = @"Next: Select the recipients certificates.";
            break;
        }
        case RECIPIENT_PHASE: {
            // Step 3: Select the recipient certs.
            self.detail.textAlignment = NSTextAlignmentCenter;
            if (self.recipientCerts) {
                self.detail.text = [NSString stringWithFormat:@"%d recipient%@ within the PEM file.", GDX509List_num(self.recipientCerts), (GDX509List_num(self.recipientCerts) == 1 ? @"" : @"s")];
                self.moreDetail.text = @"";
                if (hint) self.hint.text = @"Next: Compose and sign the message.";
            }
            else {
                self.detail.text = @"Select a PEM file containing recipient certificates. You can upload PEM files using iTunes File Sharing.";
                self.moreDetail.text = @"";
                if (hint) self.hint.text = @"";
            }
            [self setupButtonWithTitle:@"Open Documents Folder"];
            self.button.hidden = false;
            self.binarySwitch.hidden = true;
            self.textInput.hidden = true;
            break;
        }
        case COMPOSE_AND_ENCODE_PHASE: {
            // Step 4: Edit and sign the message.
            self.detail.textAlignment = NSTextAlignmentCenter;
            self.detail.text = @"Save SMIME message to the Documents folder.";
            self.moreDetail.text = @"";
            if (self.binarySwitch.on) {
                [self setupButtonWithTitle:@"Sign and Encrypt"];
            }
            else {
                [self setupButtonWithTitle:@"Sign"];
            }
            self.button.hidden = false;
            [self setupTextInput];
            self.textInput.hidden = false;
            self.binarySwitch.hidden = true;
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

- (void)setupTextInput {
    
    self.textInput.layer.borderWidth = 1;
    self.textInput.layer.borderColor = [UIColor colorWithRed:53.0/255.0 green:167.0/255.0 blue:220.0/255.0 alpha:1.0].CGColor;
    if ([self.textInput.text length] == 0) {
        NSString *emailHeaders = [self emailHeaders];
        if (emailHeaders.length) {
             [self.textInput setText:[NSString stringWithFormat:@"%@\nhi there!", emailHeaders]];
        }
        else {
            if (self.page.currentPage > FIRST_PHASE) {
                // Navigating back to previous step in this example.
                if (self.page.currentPage > FIRST_PHASE) {
                    self.page.currentPage = self.page.currentPage - 1;
                    [self driftRightFadeOutAndRefreshNextView];
                }
                [self showAlert:@"Error" text:@"No e-mail address in the certificate. Please, try to select another certificate."];
            }
        }
    }
    [self.textInput setNeedsLayout];
    [self.textInput layoutIfNeeded];
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

- (BOOL)canEncryptWith:(const struct GDX509*)cert {
    
    BOOL canDo = NO;
    struct GDX509Certificate* certDetails = GDX509Certificate_create(cert);
    if (certDetails) {
        const char* KU = certDetails->keyUsage;
        const char* EKU = certDetails->extendedKeyUsage;
        const bool forEncipherment = !KU || !strlen(KU) || strstr(KU, "Key Encipherment");
        const bool forEmail = !EKU || !strlen(EKU) || strstr(EKU, "E-mail Protection");
        canDo = forEncipherment && forEmail;
        GDX509Certificate_free(certDetails);
    }
    return canDo;
}

- (BOOL)canSignWith:(const struct GDX509*)cert {
    
    BOOL canDo = NO;
    struct GDX509Certificate* certDetails = GDX509Certificate_create(cert);
    if (certDetails) {
        const char* KU = certDetails->keyUsage;
        const char* EKU = certDetails->extendedKeyUsage;
        const bool forSigning = !KU || !strlen(KU) || strstr(KU, "Digital Signature") || strstr(KU, "Non Repudiation");
        const bool forEmail = !EKU ||!strlen(EKU) || strstr(EKU, "E-mail Protection");
        canDo = forSigning && forEmail;
        GDX509Certificate_free(certDetails);
    }
    return canDo;
}

- (NSString*) emailAddressFromCertificate:(const struct GDX509*)cert {
    
    NSString* emailAddress = nil;
    struct GDX509Certificate* certDetails = GDX509Certificate_create(cert);
    if (certDetails) {
        emailAddress = [self emailAddressFromField:[NSString stringWithUTF8String:certDetails->subject]];
        if (!emailAddress)
            emailAddress = [self emailAddressFromField:[NSString stringWithUTF8String:certDetails->subjectAlternativeName]];
        GDX509Certificate_free(certDetails);
    }
    return emailAddress;
}

- (NSString*)emailAddressFromField:(NSString*)field {
    
    NSString *pattern = @"([0-9a-zA-Z_\\-\\.\\+])+\\@([0-9a-zA-Z_\\-\\.])+\\.([a-zA-Z]+)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    NSArray* matches = [regex matchesInString:field options:0 range:NSMakeRange(0, field.length)];
    for (NSTextCheckingResult* match in matches) {
        NSString* emailAddress = [field substringWithRange:match.range];
        return emailAddress;
    }
    return nil;
}

- (NSString*)emailHeaders {
    
    // Build recipient addresses from their certificates.
    NSMutableString* recipientAddresses = [NSMutableString new];
    for (int i = 0; i < GDX509List_num(self.recipientCerts); ++i) {
        const struct GDX509* cert = GDX509List_value(self.recipientCerts, i);
        if ([self emailAddressFromCertificate:cert]) {
            if (i > 0) [recipientAddresses appendString:@", \n     "];
            [recipientAddresses appendString:[self emailAddressFromCertificate:cert]];
        }
    }
    if (recipientAddresses.length) {
        // Sender address.
        NSString* fromAddress = [self emailAddressFromCertificate:self.myCert];
        if (fromAddress.length) {
            // MIME  headers.
            return [NSString stringWithFormat:@"to: %@\nfrom: %@\nsubject: hello\n", recipientAddresses, fromAddress];
        }
    }
    return @"";
}


#pragma text view delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    if ([text isEqualToString:@"\n"]) {
        // Keyboard Done key pressed.
        [self.textInput resignFirstResponder];
        return NO;
    }
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    }
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    [self.view endEditing:YES];
    return YES;
}

- (void)keyboardDidShow:(NSNotification *)notification {

    // Scroll view up to make room for keyboard without covering the e-mail.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self.view setFrame:CGRectMake(0, -keyboardSize.height + self.page.bounds.size.height + self.hint.bounds.size.height + 30,
                                   self.view.bounds.size.width, self.view.bounds.size.height)];
}

-(void)keyboardDidHide:(NSNotification *)notification {

    [self.view setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
}


#pragma mark sign document

/** Trigger OFF the main UI thread. Signing can take a while for larger
 *  key lengths and documents. We do not want block the main UI thread for too long, otherwise
 *  the OS will terminate the app.
 */
- (void)composeEmail {

    self.isSigning = YES;
    self.shouldEncrypt = self.binarySwitch.on; // So UI component is not accessed from non-UI thread.
    self.messageText = self.textInput.text; // So UI component is not accessed from non-UI thread.
    [self.activity startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
        [self composeEmailBlocking];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activity stopAnimating];
            self.isSigning = NO;
        });
    });
}

- (void)composeEmailBlocking {

   // Declare Crypto local variables.
    struct GDStream* in = NULL;
    struct GDPKCS7* p7signed = NULL;
    struct GDPKCS7* p7enc = NULL;
    struct GDStream* signedEnvelope = NULL;
    struct GDStream* email = NULL;
    struct GDX509List* myCertChain = NULL;
    struct GDX509List* encCerts = NULL;
    
    // Cleanup Crypto locals.
    void (^cleanup)(void) = ^void() {
        GDX509List_free(encCerts);
        GDX509List_free(myCertChain);
        GDStream_free(email);
        GDStream_free(signedEnvelope);
        GDPKCS7_free(p7signed, 0);
        GDPKCS7_free(p7enc, 0);
        GDStream_free(in);
    };

    // Allocate streams.
    in = GDStream_new(GDStream_mem_storage_method());
    signedEnvelope = GDStream_new(GDStream_mem_storage_method());
    email = GDStream_new(GDStream_mem_storage_method());
    if (!in || !signedEnvelope ||!email) {
        [self showAlert:@"Error" text:@"Out of memory."];
        cleanup();
        return;
    }

    // Load e-mail plain text into a stream.
    if (!in) {
        [self showAlert:@"Error" text:@"Out of memory."];
        cleanup();
        return;
    }
    if (GDStream_write(in, [self.messageText UTF8String], (int)[self.messageText length]) != (int)[self.messageText length]) {
        [self showAlert:@"Error" text:[NSString stringWithFormat:@"Failed to read email text: %s", GDCryptoError_string(GDCryptoError_get())]];
        cleanup();
        return;
    }

    // Add basic RFC-822 headers to email.
    NSString* emailHeaders = [self emailHeaders];
    if (GDStream_write(email, [emailHeaders UTF8String], (int)[emailHeaders length]) != [emailHeaders  length]) {
        [self showAlert:@"Error" text:[NSString stringWithFormat:@"Failed to write header: %s", GDCryptoError_string(GDCryptoError_get())]];
        cleanup();
        return;
    }

    // Sign message.
    myCertChain = GDX509List_aux_certs(self.myCert);
    p7signed = GDPKCS7_add_signer(self.myCert, self.myPrivateKey, myCertChain, GDDigest_byname("sha1"), 0);
    if (!p7signed) {
        [self showAlert:@"Error" text:[NSString stringWithFormat:@"Failed to add signer: %s", GDCryptoError_string(GDCryptoError_get())]];
        cleanup();
        return;
    }
    if (GDPKCS7_final(p7signed, in, 0) != 1) {
        [self showAlert:@"Error" text:[NSString stringWithFormat:@"Failed to sign: %s", GDCryptoError_string(GDCryptoError_get())]];
        cleanup();
        return;
    }
    if (GDPKCS7_SMIME_write(signedEnvelope, p7signed, NULL, 0) != 1) {
        [self showAlert:@"Error" text:[NSString stringWithFormat:@"Failed to write signature envelope: %s", GDCryptoError_string(GDCryptoError_get())]];
        cleanup();
        return;
    }

    if (self.shouldEncrypt) {
        // Combine sender and recipient certificates.
        encCerts = GDX509List_copy(self.recipientCerts);
        if (!encCerts) {
            [self showAlert:@"Error" text:@"Out of memory."];
            cleanup();
            return;
        }
        GDX509List_insert(encCerts, 0, self.myCert);
        // Encrypt signed e-mail using public keys for each recipient, including sender's, so all in
        // the club can read it!
        p7enc = GDPKCS7_encrypt(encCerts, signedEnvelope, GDCipher_byname("des-ede3-cbc"), 0);
        if (!p7enc) {
            [self showAlert:@"Error" text:[NSString stringWithFormat:@"Failed to encrypt: %s", GDCryptoError_string(GDCryptoError_get())]];
            cleanup();
            return;
        }
        if (GDPKCS7_final(p7enc, signedEnvelope, 0) != 1) {
            [self showAlert:@"Error" text:[NSString stringWithFormat:@"Failed to finalize encryption: %s", GDCryptoError_string(GDCryptoError_get())]];
            cleanup();
            return;
        }
        // Append encrypted SMIME envelope to email.
        if (GDPKCS7_SMIME_write(email, p7enc, NULL, 0) != 1) {
            [self showAlert:@"Error" text:[NSString stringWithFormat:@"Failed to write encrypted envelope: %s", GDCryptoError_string(GDCryptoError_get())]];
            cleanup();
            return;
        }
    }
    else {
        // Append signed SMIME envelope to email.
        char buf[1024];
        while (!GDStream_eof(signedEnvelope)) {
            int nBytes = GDStream_read(signedEnvelope, buf, 1024);
            if (nBytes > 0) GDStream_write(email, buf, nBytes);
        }
    }

    NSString* documentsFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString* outFile = @"smime.eml";
    if (![self writeStream:email toFile:[documentsFolder stringByAppendingPathComponent:outFile]]) {
        [self showAlert:@"Error" text:[NSString stringWithFormat:@"Failed to write to %@", outFile]];
        cleanup();
        return;
    }

    [self showAlert:@"Success" text:[NSString stringWithFormat:@"The application/pkcs7-mime MIME can now be reviewed from your Documents folder: %@", outFile]];
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

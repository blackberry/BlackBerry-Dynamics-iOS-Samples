/* Copyright (c) 2017 - 2020 BlackBerry Limited.
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

@import Foundation;

extern NSString* const GDTestProvisionEmail;
extern NSString* const GDTestProvisionAccessKey;
extern NSString* const GDTestActivationPassword;
extern NSString* const GDTestProvisionPassword;
extern NSString* const GDTestProvisionUnlockKey;

typedef NS_ENUM(NSInteger, BBDAuthType) {
    BBDNoPasswordAuthType = 0,  // No password (either from User entered or SSO)
    BBDPasswordAuthType = 1    // password the user supplies
    //BBDSSOAuthType = 2      // auth delegating container (ATS library focuses on single application. Auth Delegation is not currently supported)
};

@interface BBDProvisionData : NSObject

@property (nonatomic, strong, readonly) NSString *email;

// Keeping accessKey field for compatibility
@property (nonatomic, strong, readonly) NSString *accessKey DEPRECATED_ATTRIBUTE;
@property (nonatomic, strong, readonly) NSString *activationPassword;

@property (nonatomic, strong, readonly) NSString *password;

@property (nonatomic, strong, readonly) NSString *unlockKey;

@property (nonatomic, strong, readonly) NSArray<NSString*>* certificatesPasswords;

/**
 * Creates BBDProvisionData data instance using explicit data.
 * This initializer can be used when data was fetched before.
 *
 * @param email
 * Email address which is used for activation
 *
 * @param accessKey
 * Provisioned Access Key
 *
 * @param password
 * Container password
 *
 * @param unlockKey
 * Key which is used to unlock application when it was locked from GC.
 *
 * @deprecated
 * accessKey is now being renamed to activationPassword
 *
 * @return BBDProvisionData instance, which is used for different purposes,
 * e.g. provisioning test.
 */
- (instancetype)initWithEmail:(NSString *)email
                    accessKey:(NSString *)accessKey
                     password:(NSString *)password
                    unlockKey:(NSString *)unlockKey DEPRECATED_ATTRIBUTE;

/**
 * Creates BBDProvisionData data instance using explicit data.
 * This initializer can be used when data was fetched before.
 *
 * @param email
 * Email address which is used for activation
 *
 * @param activationPassword
 * Provisioned Access Key
 *
 * @param password
 * Container password
 *
 * @param unlockKey
 * Key which is used to unlock application when it was locked from GC.
 *
 * @return BBDProvisionData instance, which is used for different purposes,
 * e.g. provisioning test.
 */
- (instancetype)initWithEmail:(NSString *)email
           activationPassword:(NSString *)activationPassword
                     password:(NSString *)password
                    unlockKey:(NSString *)unlockKey;

/**
 * Creates BBDProvisionData data instance using explicit data.
 * This initializer can be used only for certificate enrollment process.
 * Only certificatesPasswords is populated, other fileds are empty.
 *
 * @param certificatesPasswords
 * Array of certificates' passwords. Order of items metters for screen processing.
 *
 * @return BBDProvisionData instance, which is used for different purposes,
 * e.g. certificate enrollment processing test.
 */
- (instancetype)initWithcertificatesPasswords:(NSArray<NSString*>*)certificatesPasswords;

/**
 * Creates BBDProvisionData data instance JSON file.
 * This method uses defined structure for file contents.
 * JSON string should have the following format:
 * {
 *  "GD_TEST_PROVISION_EMAIL":"PROVIDE_YOUR_EMAIL",
 *  "GD_TEST_PROVISION_PASSWORD":"PROVIDE_YOUR_CONTAINER_PASSWORD",
 *  "GD_TEST_PROVISION_ACCESS_KEY":"PROVIDE_YOUR_ACCESS_KEY",
 *  "GD_TEST_UNLOCK_KEY":"PROVIDE_YOUR_UNLOCK_KEY",
 *  "GD_TEST_CERTIFICATES_PASSWORDS":["PROVIDE_YOUR_PASSWORD","PROVIDE_YOUR_PASSWORD"],
 *  "GD_TEST_CERTIFICATES":[{
 *                           "GD_TEST_CERTIFICATE_TYPE":"GD_TEST_CERTIFICATE_TYPE_CERTIFICATE_DEFINITION",
 *                           "GD_TEST_CERTIFICATE_NAME":"PROVIDE_YOUR_CERTIFICATE_NAME",
 *                           "GD_TEST_CERTIFICATE_PASSWORD":"PROVIDE_YOUR_CERTIFICATE_PASSWORD"
 *                          },
 *                          {
 *                           "GD_TEST_CERTIFICATE_TYPE":"GD_TEST_CERTIFICATE_TYPE_CLIENT_CERTIFICATE",
 *                           "GD_TEST_CERTIFICATE_FILE_NAME":"PROVIDE_YOUR_CERTIFICATE_FILE_NAME",
 *                           "GD_TEST_CERTIFICATE_NAME":"PROVIDE_YOUR_CERTIFICATE_NAME",
 *                           "GD_TEST_CERTIFICATE_PASSWORD":"PROVIDE_YOUR_CERTIFICATE_PASSWORD"
 *                          }]
 * }
 *
 * @param filePath
 * absolute path for JSON file location.
 *
 * @return BBDProvisionData instance, which is used for different purposes,
 * e.g. provisioning test.
 */
- (instancetype)initWithContensOfFileAtPath:(NSString *) filePath;

/**
 * Returns list of Certificate Definition names
 *
 * @return NSArray instance, which can be empty but never nil. Can be used to test certDef accepting one by one.
 */
- (NSArray<NSString*>* _Nonnull)certificateDefinitionNames;

/**
 * Returns list of Client Certificate names
 *
 * @return NSArray instance, which can be empty but never nil. Can be used to test client certificate accepting one by one.
 */
- (NSArray<NSString*>* _Nonnull)clientCertificateNames;

/**
 * Returns password for Certificate Definition
 *
 * @param certificateDefinitionName
 * the name obtained from certificateDefinitionNames list.
 *
 * @return password for Client Certificate.
 */
- (NSString* _Nonnull)certificateDefinitionPassword:(NSString* _Nonnull)certificateDefinitionName;

/**
 * Returns password for Client Certificate
 *
 * @param clientCertificateName
 * the name obtained from clientCertificateNames list.
 *
 * @return password for Client Certificate.
 */
- (NSString* _Nonnull)clientCertificatePassword:(NSString* _Nonnull)clientCertificateName;

/**
 * Returns file name of Client Certificate
 *
 * @param clientCertificateName
 * the name obtained from clientCertificateNames list.
 *
 * @return file name of Client Certificate. Can be used to test applying certificate with BBconnector.
 */
- (NSString* _Nonnull)clientCertificateFileName:(NSString* _Nonnull)clientCertificateName;


@end

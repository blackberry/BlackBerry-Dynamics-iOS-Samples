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

#import "BBDProvisionData.h"

NSString* const GDTestProvisionEmail = @"GD_TEST_PROVISION_EMAIL";
NSString* const GDTestProvisionAccessKey = @"GD_TEST_PROVISION_ACCESS_KEY";
NSString* const GDTestProvisionPassword = @"GD_TEST_PROVISION_PASSWORD";
NSString* const GDTestProvisionUnlockKey = @"GD_TEST_UNLOCK_KEY";

NSString* const GDTestCertificatesPasswords = @"GD_TEST_CERTIFICATES_PASSWORDS";

NSString* const GDTestCertificates = @"GD_TEST_CERTIFICATES";
NSString* const GDTestCertificateType = @"GD_TEST_CERTIFICATE_TYPE";
NSString* const GDTestCertificateName = @"GD_TEST_CERTIFICATE_NAME";
NSString* const GDTestCertificateFileName = @"GD_TEST_CERTIFICATE_FILE_NAME";
NSString* const GDTestCertificatePassword = @"GD_TEST_CERTIFICATE_PASSWORD";

NSString* const GDTestCertificateTypeCertificateDefinition = @"GD_TEST_CERTIFICATE_TYPE_CERTIFICATE_DEFINITION";
NSString* const GDTestCertificateTypeClientCertificate = @"GD_TEST_CERTIFICATE_TYPE_CLIENT_CERTIFICATE";

@interface GDCertificateDefinitionData : NSObject

@property (nonatomic, strong, readonly) NSString *name;

@property (nonatomic, strong, readonly) NSString *password;

- (instancetype)initWithName:(NSString *)name
                    password:(NSString *)password;
@end

@interface GDClientCertificateData : NSObject

@property (nonatomic, strong, readonly) NSString *name;

@property (nonatomic, strong, readonly) NSString *fileName;

@property (nonatomic, strong, readonly) NSString *password;

- (instancetype)initWithName:(NSString *)name
                    fileName:(NSString *)fileName
                    password:(NSString *)password;
@end

@implementation GDCertificateDefinitionData

- (instancetype)initWithName:(NSString *)name
                    password:(NSString *)password {
    self = [super init];
    if (self) {
        _name     = name;
        _password = password;
    }
    return self;
}

@end

@implementation GDClientCertificateData

- (instancetype)initWithName:(NSString *)name
                    fileName:(NSString *)fileName
                    password:(NSString *)password {
    self = [super init];
    if (self) {
        _name     = name;
        _fileName = fileName;
        _password = password;
    }
    return self;
}

@end


@interface BBDProvisionData()

@property (nonatomic, strong, readonly) NSDictionary<NSString*, GDCertificateDefinitionData*>* certificateDefinitions;
@property (nonatomic, strong, readonly) NSDictionary<NSString*, GDClientCertificateData*>* clientCertificates;

//basic init method, used as parent for all other, private.
- (instancetype)initWithEmail:(NSString *)email
                    accessKey:(NSString *)accessKey
                     password:(NSString *)password
                    unlockKey:(NSString*) unlockKey
        certificatesPasswords:(NSArray<NSString*>*) certificatesPasswords
       certificateDefinitions:(NSDictionary<NSString*, GDCertificateDefinitionData*>*) certificateDefinitions
           clientCertificates:(NSDictionary<NSString*, GDClientCertificateData*>*) clientCertificates;

@end

@implementation BBDProvisionData


- (instancetype)initWithEmail:(NSString *)email
                    accessKey:(NSString *)accessKey
                     password:(NSString *)password
                    unlockKey:(NSString*) unlockKey
        certificatesPasswords:(NSArray<NSString*>*) certificatesPasswords
       certificateDefinitions:(NSDictionary<NSString*, GDCertificateDefinitionData*>*) certificateDefinitions
           clientCertificates:(NSDictionary<NSString*, GDClientCertificateData*>*) clientCertificates;
{
    self = [super init];
    if (self) {
        _email     = email;
        _accessKey = [accessKey stringByReplacingOccurrencesOfString:@" " withString:@""];
        _password  = password;
        _unlockKey = [unlockKey stringByReplacingOccurrencesOfString:@" " withString:@""];
        _certificatesPasswords = certificatesPasswords;
        _certificateDefinitions = certificateDefinitions;
        _clientCertificates = clientCertificates;
    }
    return self;
}

- (instancetype)initWithEmail:(NSString *)email
                    accessKey:(NSString *)accessKey
                     password:(NSString *)password
                    unlockKey:(NSString*) unlockKey{
    return [self initWithEmail:email
                     accessKey:accessKey
                      password:password
                     unlockKey:unlockKey
         certificatesPasswords:nil
        certificateDefinitions:nil
            clientCertificates:nil];
}

- (instancetype)initWithcertificatesPasswords:(NSArray<NSString*>*)certificatesPasswords
{
    return [self initWithEmail:nil
                     accessKey:nil
                      password:nil
                     unlockKey:nil
         certificatesPasswords:certificatesPasswords
        certificateDefinitions:nil
            clientCertificates:nil];
}

- (instancetype)initWithContensOfFileAtPath:(NSString *) filePath {
    
    if (!filePath)
        return nil;
    
    NSData* data       = [[NSFileManager defaultManager] contentsAtPath:filePath];
    NSError* error     = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (error)
    {
        return nil;
    }
    
    NSString* email     = json[GDTestProvisionEmail];
    NSString* accessKey = json[GDTestProvisionAccessKey];
    NSString* password  = json[GDTestProvisionPassword];
    NSString* unlockKey = json[GDTestProvisionUnlockKey];
    NSArray<NSString*>* certPasswords= json[GDTestCertificatesPasswords];
    NSMutableDictionary<NSString*, GDCertificateDefinitionData*>* certificateDefinitions = [NSMutableDictionary new];
    NSMutableDictionary<NSString*, GDClientCertificateData*>* clientCertificates = [NSMutableDictionary new];
    
    for (NSDictionary* certificate in json[GDTestCertificates]) {
        NSString* certificateType = certificate[GDTestCertificateType];
        if (certificateType.length > 0) {
            if ([certificateType caseInsensitiveCompare:GDTestCertificateTypeCertificateDefinition] == NSOrderedSame) {
                GDCertificateDefinitionData* certificateDefinition =
                [[GDCertificateDefinitionData alloc] initWithName:certificate[GDTestCertificateName]
                                                         password:certificate[GDTestCertificatePassword]];
                certificateDefinitions[certificateDefinition.name] = certificateDefinition;
                
                
            } else if ([certificateType caseInsensitiveCompare:GDTestCertificateTypeClientCertificate] == NSOrderedSame) {
                GDClientCertificateData* clientCertificate =
                [[GDClientCertificateData alloc] initWithName:certificate[GDTestCertificateName]
                                                     fileName: certificate[GDTestCertificateFileName]
                                                     password:certificate[GDTestCertificatePassword]];
                clientCertificates[clientCertificate.name] = clientCertificate;
            }
        }
    }
    
    return  [self initWithEmail:email
                      accessKey:accessKey
                       password:password
                      unlockKey:unlockKey
          certificatesPasswords:certPasswords
         certificateDefinitions:certificateDefinitions
             clientCertificates:clientCertificates];
}

- (NSArray<NSString*>* _Nonnull)certificateDefinitionNames {
    
    return [self.certificateDefinitions allKeys];
}

- (NSArray<NSString*>* _Nonnull)clientCertificateNames {
    
    return [self.clientCertificates allKeys];
}

- (NSString* _Nonnull)certificateDefinitionPassword:(NSString* _Nonnull)certificateDefinitionName {
    
    return self.certificateDefinitions[certificateDefinitionName].password;
}

- (NSString* _Nonnull)clientCertificatePassword:(NSString* _Nonnull)clientCertificateName {
    
    return self.clientCertificates[clientCertificateName].password;
}

- (NSString* _Nonnull)clientCertificateFileName:(NSString* _Nonnull)clientCertificateName {
    
    return self.clientCertificates[clientCertificateName].fileName;
}

@end

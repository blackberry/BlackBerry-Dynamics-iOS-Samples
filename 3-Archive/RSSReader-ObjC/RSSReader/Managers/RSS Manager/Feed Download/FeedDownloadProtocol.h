/*
  * (c) 2018 BlackBerry Limited. All rights reserved.
  *
  */

#import <Foundation/Foundation.h>

@protocol FeedDownloadProtocol <NSObject>

@required

- (void)requestData:(NSString*)url relaxSSL:(BOOL)relaxSSL allowCellular:(BOOL)allowCellular;

- (NSString*) decomposeUrl:(NSString *) url;

- (void)displaySSLQueryDialog;

- (void)displayAuthQueryDialog;

- (void)displayDialogWithError:(NSError*)error;

@end

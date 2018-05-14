/* Copyright (c) 2016 BlackBerry Ltd.
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

#import "Utilities.h"

@interface Utilities()
+(NSString *)injectionJS:(Boolean)silently;

+(NSString *)resourceJS:(NSString *)resource error:(NSError **)error;
@end

@implementation Utilities

+(void)launchStoryboard:(NSString *)property {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *boardName = [infoDictionary objectForKey:property];
    UIStoryboard *board = [UIStoryboard storyboardWithName:boardName
                                                    bundle:nil];
    UIViewController *controller = [board instantiateInitialViewController];
    [UIApplication sharedApplication]
    .delegate.window.rootViewController = controller;
}

+(NSURLRequest *)webPageRequest:(NSString *)directory {
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"index"
                                         withExtension:@"html"
                                          subdirectory:directory];
    return [NSURLRequest requestWithURL:url];    
}

+(NSString *)webPage:(NSString *)directory {
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"index"
                                         withExtension:@"html"
                                          subdirectory:directory];
    
    NSError *error;
    NSString *return_ = 
    [NSString stringWithContentsOfURL:url 
                             encoding:NSUTF8StringEncoding
                                error:&error];
    if (return_ == nil) {
        // The meta prevents WKWebView scaling down.
        // TOTH https://stackoverflow.com/a/26720053/8990812
        return_ = 
        [NSString stringWithFormat:
         @"%@Failed to read %@/index.html \"%@\" %@%@",
         @"<html><head><meta name=\"viewport\" content=\"initial-scale=1.0\" />"
         @"<style>body{font-family:sans-serif;}</style></head>"
         @"<body><pre>",
         directory, url, error,
         @"</pre></body>"];
    }
    
    return return_;
}

+(NSString *)resourceJS:(NSString *)resource error:(NSError **)error 
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:resource
                                         withExtension:@"js"];
    NSString *js = [NSString stringWithContentsOfURL:url 
                                            encoding:NSUTF8StringEncoding
                                               error:error];
    if (url == nil) {
        NSDictionary <NSErrorUserInfoKey, id> *userInfo = 
  @{NSFilePathErrorKey: [NSString stringWithFormat:@"%@.js", resource]};
        *error = [NSError errorWithDomain:NSURLErrorDomain
                                     code:NSFileReadUnknownError 
                                 userInfo:userInfo];
        js = nil;
    }

    return js;
}

+(void)injectJSIntoWKWebView:(WKWebView *)wkWebView 
                fromResource:(NSString *)resource
           completionHandler:(void (^)(id, NSError *error))completionHandler
{
    NSError *error;
    NSString *js = [Utilities resourceJS:resource error:&error];
    if (js == nil) {
        completionHandler(nil, error);
    }
    else {
        [wkWebView evaluateJavaScript:js completionHandler:completionHandler];
    }
}

+(NSString *)injectJSIntoUIWebView:(UIWebView *)uiWebView
                      fromResource:(NSString *)resource
{
    NSError *error;
    NSString *js = [Utilities resourceJS:resource error:&error];
    if (js == nil) {
        NSLog(@"%s Failed:%@.", __FUNCTION__, error);
        return nil;
    }
    return [uiWebView stringByEvaluatingJavaScriptFromString:js];
}




+(NSString *)resource:(NSString *)resource 
        withExtension:(NSString *)extension 
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:resource
                                         withExtension:extension];
    
    NSError *error;
    NSString *return_ = [NSString stringWithContentsOfURL:url 
                                                 encoding:NSUTF8StringEncoding
                                                    error:&error];
    if (return_ == nil) {
        NSLog(@"Failed to read resource \"%@.%@\" \"%@\" %@", 
              resource, extension, url, error);
        return_ = @"";
    }
    
    return return_;
}


+(NSString *)injectionJS:(Boolean)silently {
    NSMutableString *js = 
    [NSMutableString 
     stringWithString:[Utilities resource:@"inject" withExtension:@"js"]];
    
    if (silently) {
        [js appendString:@"main(true);"];
    }
    else {
        [js appendString:@"main(false);"];
    }
    return (NSString *)js;
}

+(void)injectJSIntoWKWebView:(WKWebView *)wkWebView 
                   inSilence:(Boolean)inSilence
{    
    [wkWebView evaluateJavaScript:[Utilities injectionJS:inSilence]
                   completionHandler:^(id result, NSError *error) 
     {
         NSLog(@"%@ %@", result, error);
     }];
}

+(void)injectJSIntoUIWebView:(UIWebView *)uiWebView
                   inSilence:(Boolean)inSilence
{
    NSString *result = [uiWebView stringByEvaluatingJavaScriptFromString:
                        [Utilities injectionJS:inSilence]];
    NSLog(@"%@", result);
}

+(NSString *)HTMLreplace:(NSString *)str andLineBreaks:(BOOL)nls
{
    NSArray *HTMLreps = @[
                          @[ @"&", @"&amp;"],
                          @[ @"<", @"&lt;" ],
                          @[ @">", @"&gt;" ]
                          ];
    if (nls) {
        HTMLreps = [HTMLreps
                    arrayByAddingObjectsFromArray:@[
                                                    @[ @"\r\n", @"<br />" ],
                                                    @[ @"\n", @"<br />" ]
                                                    ]];
    }
    NSMutableString *ret = [[NSMutableString alloc] initWithString:str];
    for (int index=0; index<HTMLreps.count; index++ ) {
        [ret replaceOccurrencesOfString:HTMLreps[index][0]
                             withString:HTMLreps[index][1]
                                options:NSLiteralSearch
                                  range:NSMakeRange(0, ret.length)];
    }
    return ret;
}

@end

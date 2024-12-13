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

#import "FeedParser.h"

@interface FeedParser ()

@property (nonatomic, strong) NSXMLParser *parser;

@property (nonatomic, strong) NSMutableArray *storyArray;

@property (nonatomic, strong) NSMutableDictionary *itemDict;
@property (nonatomic, strong) NSString *element;
@property (nonatomic, strong) NSMutableString *itemTitle;
@property (nonatomic, strong) NSMutableString *itemDescription;
@property (nonatomic, strong) NSMutableString *itemDate;
@property (nonatomic, strong) NSMutableString *itemLink;

@end

@implementation FeedParser

- (instancetype)initWithDelegate:(id<FeedParserDelegate>)delegate parsingData:(NSData *)data
{
    self = [super init];
    if (self) {
        _parser = [[NSXMLParser alloc] initWithData:data];
        _parser.delegate = self;
        _delegate = delegate;
        _storyArray = [NSMutableArray array];
    }
    return self;
}

- (void)parse
{
    [self.parser parse];
}

#pragma mark - NSXMLParser delegate
/*
 * called when the parser starts an element
 */
- (void)parser:(NSXMLParser*)parser didStartElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qName attributes:(NSDictionary*)attributeDict
{
    self.element = [elementName copy];
    if ([elementName isEqualToString:@"item"])
    {
        self.itemDict = [[NSMutableDictionary alloc] init];
        self.itemTitle = [[NSMutableString alloc] init];
        self.itemDescription = [[NSMutableString alloc] init];
        self.itemDate = [[NSMutableString alloc] init];
        self.itemLink  = [[NSMutableString alloc] init];
    }
}

/*
 * called when the parser completes an element
 */
- (void)parser:(NSXMLParser*)parser didEndElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qName
{
    if ([elementName isEqualToString:@"item"])
    {
        [self.itemDict setObject:self.itemTitle forKey:@"title"];
        [self.itemDict setObject:self.itemDescription forKey:@"description"];
        [self.itemDict setObject:self.itemDate forKey:@"pubDate"];
        [self.itemDict setObject:self.itemLink forKey:@"link"];
        [self.storyArray addObject:[self.itemDict copy]];
    }
}

/*
 * called when the parser finds a tag
 */
- (void)parser:(NSXMLParser*)parser foundCharacters:(NSString*)string
{
    if ([self.element isEqualToString:@"title"])
    {
        [self.itemTitle appendString:string];
    }
    else if ([self.element isEqualToString:@"link"])
    {
        [self.itemLink appendString:string];
    }
    else if ([self.element isEqualToString:@"description"])
    {
        [self.itemDescription appendString:string];
    }
    else if ([self.element isEqualToString:@"pubDate"])
    {
        [self.itemDate appendString:string];
    }
}

/*
 * called when the parser completes
 */
- (void)parserDidEndDocument:(NSXMLParser*)parser
{
    [self.delegate didFinishParsingFeed:[self.storyArray copy]];
}

/*
 * handle any parser error by showing an error dialog
 */
- (void)parser:(NSXMLParser*)parser parseErrorOccurred:(NSError*)parseError
{
    [self.delegate didFailWithError:parseError];
}

@end

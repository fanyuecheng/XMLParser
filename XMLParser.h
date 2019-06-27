//
//  XMLParser.h
//  YCTest
//
//  Created by 月成 on 2019/6/27.
//  Copyright © 2019 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, XMLParserOptions) {
    XMLParserOptionsProcessNamespaces       = 1 << 0,
    XMLParserOptionsReportNamespacePrefixes = 1 << 1,
    XMLParserOptionsResolveExternalEntities = 1 << 2,
};

@interface XMLParser : NSObject

+ (NSDictionary *)dictionaryForXMLData:(NSData *)data;
+ (NSDictionary *)dictionaryForXMLString:(NSString *)string;
+ (NSDictionary *)dictionaryForXMLData:(NSData *)data options:(XMLParserOptions)options;
+ (NSDictionary *)dictionaryForXMLString:(NSString *)string options:(XMLParserOptions)options;

@end

NS_ASSUME_NONNULL_END

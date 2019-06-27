//
//  XMLParser.m
//  YCTest
//
//  Created by 月成 on 2019/6/27.
//  Copyright © 2019 fancy. All rights reserved.
//

#import "XMLParser.h"

#define kXMLParserTextNodeKey        (@"label_content")

@interface XMLParser () <NSXMLParserDelegate>

{
    NSMutableArray  *_dictionaryArray;  //存放字典数组
    NSMutableString *_contentText;      //存放当前解析内容文字
}

@end

@implementation XMLParser

- (instancetype)init {
    if (self = [super init]) {
        _dictionaryArray = [NSMutableArray array];
        _contentText     = [NSMutableString string];
    }
    return self;
}

+ (NSDictionary *)dictionaryForXMLData:(NSData *)data {
    return [XMLParser dictionaryForXMLData:data options:0];
}

+ (NSDictionary *)dictionaryForXMLString:(NSString *)string {
    return [XMLParser dictionaryForXMLData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (NSDictionary *)dictionaryForXMLString:(NSString *)string
                                 options:(XMLParserOptions)options {
    return [XMLParser dictionaryForXMLData:[string dataUsingEncoding:NSUTF8StringEncoding] options:options];
}

+ (NSDictionary *)dictionaryForXMLData:(NSData *)data
                               options:(XMLParserOptions)options {
    XMLParser *parser = [[XMLParser alloc] init];
    return [parser startParserXML:data options:options];
}

#pragma mark - Private Method
- (NSDictionary *)startParserXML:(NSData *)data
                         options:(XMLParserOptions)options {
    
    [_dictionaryArray addObject:[NSMutableDictionary dictionary]];
    
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:data];
    xmlParser.delegate = self;
    xmlParser.shouldProcessNamespaces = (options & XMLParserOptionsProcessNamespaces);
    xmlParser.shouldReportNamespacePrefixes = (options & XMLParserOptionsReportNamespacePrefixes);
    xmlParser.shouldResolveExternalEntities = (options & XMLParserOptionsResolveExternalEntities);
    
    if ([xmlParser parse]) {
        [self handleXMLObject:_dictionaryArray[0]];
        return _dictionaryArray[0];
    }
    
    return nil;
}

/*
 处理数据
 相同key加入数组
 子字典仅有lable_content一个键，则直接赋值给父key
 */
- (void)handleXMLObject:(id)object {
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dictionary = object;
        NSInteger                 count = dictionary.count;
        NSArray               *keyArray = [dictionary allKeys];
        
        for (NSInteger i = 0; i < count; i++) {
            NSString *key = keyArray[i];
            id  subObject = dictionary[key];
            if ([subObject isKindOfClass:[NSDictionary class]]) {
                [self handleParentData:dictionary subDict:subObject index:i];
                [self handleXMLObject:subObject];
            } else if([subObject isKindOfClass:[NSArray class]]) {
                [self handleXMLObject:subObject];
            }
        }
    } else if ([object isKindOfClass:[NSArray class]]) {
        NSMutableArray *array = object;
        for (NSInteger i = 0; i < array.count; i++) {
            id subObject = array[i];
            [self handleXMLObject:subObject];
        }
    }
}

- (void)handleParentData:(NSMutableDictionary *)dict
                 subDict:(NSDictionary *)subDict
                   index:(NSInteger)index {
    NSArray *subKeyArray = [subDict allKeys];
    NSArray *keyArray    = [dict allKeys];
    if (subKeyArray.count == 1 && [subKeyArray[0] isEqualToString:kXMLParserTextNodeKey]) {
        [dict setObject:subDict[kXMLParserTextNodeKey] forKey:keyArray[index]];
    } else if(subKeyArray.count == 0) {
        [dict setObject:@"" forKey:keyArray[index]];
    }
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    NSMutableDictionary *parentDict = [_dictionaryArray lastObject];
    NSMutableDictionary *childDict  = [NSMutableDictionary dictionary];
    
    [childDict addEntriesFromDictionary:attributeDict];
    
    id existingValue = [parentDict objectForKey:elementName];
    
    if (existingValue) {
        NSMutableArray *array = nil;
        if ([existingValue isKindOfClass:[NSMutableArray class]]) {
            // 使用存在的数组
            array = (NSMutableArray *)existingValue;
        } else {
            // 不存在创建数组
            array = [NSMutableArray array];
            [array addObject:existingValue];
            // 替换子字典用数组
            [parentDict setObject:array forKey:elementName];
        }
        // 添加一个新的子字典
        [array addObject:childDict];
    } else {
        // 不存在则插入新元素
        [parentDict setObject:childDict forKey:elementName];
    }
    
    // 更新数组 插入子字典
    [_dictionaryArray addObject:childDict];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    NSMutableDictionary *dictInProgress = [_dictionaryArray lastObject];
    if (_contentText.length > 0) {
        // 存储值
        NSString *labelContent = [_contentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (labelContent.length) {
            [dictInProgress setObject:[labelContent mutableCopy] forKey:kXMLParserTextNodeKey];
            // 重置content
            _contentText = [NSMutableString string];
        }
    }
    // 移除处理完的子字典
    [_dictionaryArray removeLastObject];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [_contentText appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"XMLParseErrorOccurred : %@", parseError);
}

@end

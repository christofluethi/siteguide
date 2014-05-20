//
//  Document.h
//  SiteGuide
//
//  Created by Christof Luethi on 06.03.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Model Class representing a Document
 */
@interface Document : NSObject
@property (nonatomic, assign, readonly) int docId;
@property (nonatomic, assign, readonly) int poiId;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *description;
@property (nonatomic, strong, readonly) NSString *type;
@property (nonatomic, strong, readonly) NSString *category;
@property (nonatomic, strong, readonly) NSString *content;

/**
 init a new Document
 */
-(id)initWithName:(NSString*)name description:(NSString*)description docId:(int)docId poiId:(int)poiId type:(NSString *)type category:(NSString *)category content:(NSString *)content;

@end

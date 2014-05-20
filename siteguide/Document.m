//
//  Document.m
//  SiteGuide
//
//  Created by Christof Luethi on 06.03.14.
//  Copyright (c) 2014 siteguide.ch. All rights reserved.
//

#import "Document.h"

@implementation Document
-(id)initWithName:(NSString *)name description:(NSString *)description docId:(int)docId poiId:(int)poiId type:(NSString *)type category:(NSString *)category content:(NSString *)content {
    self = [super init];
    
    if(self) {
        _name = name;
        _description = description;
        _docId = docId;
        _poiId = poiId;
        _type = type;
        _category = category;
        _content = content;
    }
    
    return self;
}

@end

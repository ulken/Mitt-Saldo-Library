//
//  Created by Björn Sållarp
//  NO Copyright. NO rights reserved.
//
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//  Follow me @bjornsallarp
//  Fork me @ http://github.com/bjornsallarp
//

#import "MSLIkanoBankLoginParser.h"

@implementation MSLIkanoBankLoginParser


- (BOOL)parseXMLData:(NSData *)XMLMarkup parseError:(NSError **)error
{
	BOOL successful = YES;
	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:XMLMarkup];
    
	// Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [parser setDelegate:self];
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
	
	self.hiddenFields = [NSMutableDictionary dictionary];
	
    // Start parsing
    [parser parse];
    
    NSError *parseError = [parser parserError];
    if (parseError && error) {
        *error = parseError;
		successful = NO;
    }
    
	
	return successful;
}

#pragma mark - NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict
{
	if (qName) {
        elementName = qName;
    }
	
	// Store all the hidden fields. ASP.NET stores some viewstate information in hidden inputfields that 
	// are required for a successful postback
	if([elementName isEqualToString:@"input"]) {
        NSString *inputType = [attributeDict valueForKey:@"type"];
        NSString *inputValue = [attributeDict valueForKey:@"value"];
        
		if ([inputType isEqualToString:@"hidden"]) {
            if ([attributeDict valueForKey:@"name"] != nil) {
                (self.hiddenFields)[[attributeDict valueForKey:@"name"]] = inputValue;
            }
            else if ([attributeDict valueForKey:@"id"] != nil) {
                (self.hiddenFields)[[attributeDict valueForKey:@"id"]] = inputValue;                
            }
		}
        else if ([inputType isEqualToString:@"password"]) {
            self.passwordFieldName = [attributeDict valueForKey:@"name"];
        }
        else if ([inputType isEqualToString:@"text"] && [[attributeDict valueForKey:@"maxlength"] isEqualToString:@"12"]) {
            self.ssnFieldName = [attributeDict valueForKey:@"name"];
        }
	}
    else if (self.ssnFieldName && self.passwordFieldName && [elementName isEqualToString:@"a"] && [[[attributeDict valueForKey:@"id"] lowercaseString] rangeOfString:@"login"].location != NSNotFound) {
        (self.hiddenFields)[@"__EVENTTARGET"] = [[attributeDict valueForKey:@"id"] stringByReplacingOccurrencesOfString:@"_" withString:@"$"];
    }
    
}

@end

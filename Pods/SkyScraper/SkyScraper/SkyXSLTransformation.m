#include <string.h>
#include <libxml/xmlmemory.h>
#include <libxml/debugXML.h>
#include <libxml/HTMLparser.h>
#include <libxml/HTMLtree.h>
#include <libxml/xmlIO.h>
#include <libxml/DOCBparser.h>
#include <libxml/xinclude.h>
#include <libxml/catalog.h>
#include "xslt.h"
#include "xsltInternals.h"
#include "transform.h"
#include "xsltutils.h"
#include "exslt.h"
#include "iconv.h"

#import "SkyXSLTransformation.h"
#import "SkyXSLTParams.h"

typedef NSMutableString* (^ReplaceStringBlockType)(NSString* inString, NSString* regexString, NSString* appendFormat, NSString*(^block)(NSString*value));
NSString  * const SkyScraperErrorDomain = @"SkyScraperErrorDomain Error Domain";

extern int xmlLoadExtDtdDefaultValue;

@interface SkyXSLTransformation()
@property (nonatomic,assign) xsltStylesheetPtr stylesheet;
@property (nonatomic, copy) ReplaceStringBlockType replaceStringBlock;
@end

void exslt_org_regular_expressions_init();

@implementation SkyXSLTransformation
- (void) dealloc {
    xsltFreeStylesheet(self.stylesheet);
}

+ (void)initialize {
    /* initializing libxslt global stuff */
    exsltRegisterAll();
    exslt_org_regular_expressions_init();
    xmlSubstituteEntitiesDefault(1);
    xmlLoadExtDtdDefaultValue = 1;
}

- (instancetype) initWithXSLTString:(NSString *)xslt baseURL:(NSURL *)baseURL {
    if (self = [super init]) {
        xmlDocPtr stylesheetDoc = xmlReadDoc((const xmlChar *)[xslt cStringUsingEncoding:NSUTF8StringEncoding], [[baseURL absoluteString] cStringUsingEncoding:NSUTF8StringEncoding], NULL, XML_PARSE_RECOVER | XML_PARSE_NOENT | XML_PARSE_XINCLUDE);
        [self setupStyleSheetFromXMLDoc:stylesheetDoc];
    }
    return self;
}

- (instancetype) initWithXSLTURL:(NSURL *)URL {
    if (self = [super init]) {
        _xsltURL = URL;
        xmlDocPtr stylesheetDoc = xmlReadFile([[URL absoluteString] cStringUsingEncoding:NSUTF8StringEncoding], NULL, XSLT_PARSE_OPTIONS | XML_PARSE_XINCLUDE);
        [self setupStyleSheetFromXMLDoc:stylesheetDoc];
    }
    return self;
}

- (void) setupStyleSheetFromXMLDoc:(xmlDocPtr)styleSheetDoc {
    xmlXIncludeProcess(styleSheetDoc);
    self.stylesheet = xsltParseStylesheetDoc(styleSheetDoc);
}

- (NSData *) transformedDataFromData:(NSData *)data isHTML:(BOOL)isHTML withParams:(NSDictionary *)params error:(NSError * __autoreleasing *)error {
    if (!self.stylesheet) {
        if (error) {
            *error = [NSError errorWithDomain:SkyScraperErrorDomain code:1 userInfo:
                      @{NSLocalizedFailureReasonErrorKey : @"Either no stylesheet provided, or failed to parse the one provided"}];
        }
        return nil;
    }
    
    if ([data length]==0) {
        if (error) {
            *error = [NSError errorWithDomain:SkyScraperErrorDomain code:2 userInfo:
                      @{NSLocalizedFailureReasonErrorKey : @"No input HTML provided, or the input is empty"}];
        }
        return nil;
    }
    
    NSString *string = [self stringUTF8:data clean:NO];
    if (string.length==0) {
        string = [self stringUTF8:data clean:YES];
    }
    if (string.length==0) {
        string = [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding] ?: @"";
    }
    if (self.replaceXMLEntities) {
        string = [self replaceEntities:string isHTML:isHTML];
    }
    if (self.enableTextareaExpansion) {
        string = [self fixEmptyTextareaTags:string];
    }
    
    xmlChar *cString = (xmlChar *)[string cStringUsingEncoding:NSUTF8StringEncoding];
    
    xmlParserOption additionalOptions = isHTML ?
    HTML_PARSE_RECOVER | HTML_PARSE_NOERROR | HTML_PARSE_NOWARNING
    : XML_PARSE_RECOVER | XML_PARSE_NOERROR | XML_PARSE_NOWARNING;
    
    xmlDocPtr doc = isHTML ? htmlReadDoc(cString, NULL, "utf-8", XSLT_PARSE_OPTIONS | additionalOptions)
    : xmlReadDoc(cString, NULL, "utf-8", XSLT_PARSE_OPTIONS | additionalOptions);
    
    NSData *result = nil;
    xmlDocPtr res = NULL;
    
    xsltTransformContextPtr ctxt = xsltNewTransformContext(self.stylesheet, doc);
    
    if (ctxt) {
        xsltSetCtxtParseOptions(ctxt, XSLT_PARSE_OPTIONS | additionalOptions);
        ctxt->xinclude = 1;
        
        SkyXSLTParams *xsltParams = [[SkyXSLTParams alloc] initWithParams:params];
        /* actual applying stylesheet */
        res = xsltApplyStylesheetUser(self.stylesheet, doc, (const char **)xsltParams.paramsBuf, NULL, NULL, ctxt);
        
        if (res) {
            /* dumping bytes of the result */
            xmlChar *buf;
            int size;
            
            xsltSaveResultToString(&buf, &size, res, self.stylesheet);
            
            /* producing result */
            if (buf) {
                result = [NSData dataWithBytesNoCopy:buf length:size freeWhenDone:YES];
            }
            
        } else {
            if (error) {
                *error = [NSError errorWithDomain:SkyScraperErrorDomain code:4 userInfo:
                          @{NSLocalizedFailureReasonErrorKey : @"Unable to apply stylesheet"}];
            }
        }
        
    } else {
        if (error) {
            *error = [NSError errorWithDomain:SkyScraperErrorDomain code:3 userInfo:
                      @{NSLocalizedFailureReasonErrorKey : @"Unable to create transform context"}];
        }
    }
    
    /* freeing all other stuff */
    if (res) {
        xmlFreeDoc(res);
    }
    if (ctxt) {
        xsltFreeTransformContext(ctxt);
    }
    if (doc) {
        xmlFreeDoc(doc);
    }
    
    return result;
}

- (NSString *) stringFromHTMLData:(NSData *)html withParams:(NSDictionary *)params error:(NSError *__autoreleasing *)error {
    NSData *data = [self transformedDataFromData:html isHTML:YES withParams:params error:error];
    NSString *result = nil;
    if (data) {
        result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return result;
}

- (id) JSONObjectFromHTMLData:(NSData *)html withParams:(NSDictionary *)params error:(NSError * __autoreleasing *)error {
    NSData *data = [self transformedDataFromData:html isHTML:YES withParams:params error:error];
    id JSONObject = nil;
    if (data) {
        JSONObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:error];
    }
    return JSONObject;
}

- (NSString *) stringFromXMLData:(NSData *)xml withParams:(NSDictionary *) params error:(NSError * __autoreleasing *)error {
    NSData *data = [self transformedDataFromData:xml isHTML:NO withParams:params error:error];
    NSString *result = nil;
    if (data) {
        result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return result;
}

- (id) JSONObjectFromXMLData:(NSData *)xml withParams:(NSDictionary *)params error:(NSError * __autoreleasing *)error {
    NSData *data = [self transformedDataFromData:xml isHTML:NO withParams:params error:error];
    id JSONObject = nil;
    if (data) {
        JSONObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:error];
    }
    return JSONObject;
    
}

#pragma mark - Fix response data

- (NSString*) stringUTF8:(NSData*)data clean:(BOOL)clean {
    data = clean ? [self cleanUTF8:data] : data;
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSData *) cleanUTF8:(NSData *)data {
    // this function is from
    // http://stackoverflow.com/questions/3485190/nsstring-initwithdata-returns-null
    //
    //
    iconv_t cd = iconv_open("UTF-8", "UTF-8"); // convert to UTF-8 from UTF-8
    int one = 1;
    iconvctl(cd, ICONV_SET_DISCARD_ILSEQ, &one); // discard invalid characters
    size_t inbytesleft, outbytesleft;
    inbytesleft = outbytesleft = data.length;
    char *inbuf  = (char *)data.bytes;
    char *outbuf = malloc(sizeof(char) * data.length);
    char *outptr = outbuf;
    if (iconv(cd, &inbuf, &inbytesleft, &outptr, &outbytesleft)
        == (size_t)-1) {
        NSLog(@"this should not happen, seriously");
        return nil;
    }
    NSData *result = [NSData dataWithBytes:outbuf length:data.length - outbytesleft];
    iconv_close(cd);
    free(outbuf);
    return result;
}

- (NSString*) replaceEntities:(NSString*)string isHTML:(BOOL)isHTML {
    if (!isHTML) {
        // this need to be done to fix the issue with XML entities inside the CDATA
        string = self.replaceStringBlock(string,@"<!\\[CDATA\\[(.*?)\\]\\]>",@"<![CDATA[%@]]>",^(NSString*value) {
            value = [value stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
            value = [value stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
            value = [value stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
            value = [value stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
            value = [value stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
            return value;
        });
    }
    
    // replace decimal entities with hex equivalents
    string = self.replaceStringBlock(string,@"&#([a-f0-9]{4,5});",@"&#%@;",^(NSString*value) {
        return [NSString stringWithFormat:@"x%lX",(unsigned long)[value integerValue]];
    });
    
    CFStringTransform((__bridge CFMutableStringRef)string, NULL, kCFStringTransformToXMLHex, YES);
    return string;
}

- (NSString*) fixEmptyTextareaTags:(NSString*)string {
    return self.replaceStringBlock(string,@"(<textarea.*?</textarea>)",@"%@",^(NSString*value) {
        return [value stringByReplacingOccurrencesOfString:@"><" withString:@"> <" options:0 range:(NSRange){0,value.length}];
    });
}

#pragma mark - Accessors

- (ReplaceStringBlockType) replaceStringBlock {
    if (!_replaceStringBlock) {
        _replaceStringBlock = ^NSMutableString*(NSString* inString, NSString* regexString, NSString* appendFormat, NSString*(^block)(NSString*value)) {
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString
                                                                                   options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators error:nil];
            NSMutableString* mutString = [NSMutableString new];
            __block NSInteger startPos = 0;
            [regex enumerateMatchesInString:inString options:0 range:(NSRange){0, inString.length} usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                [mutString appendString:[inString substringWithRange:(NSRange){startPos, result.range.location - startPos}]];
                NSString* value = [inString substringWithRange:[result rangeAtIndex:1]];
                [mutString appendFormat:appendFormat,block(value)];
                startPos = result.range.location + result.range.length;
            }];
            [mutString appendString:[inString substringWithRange:NSMakeRange(startPos, inString.length-startPos)]];
            return mutString;
        };
    }
    return _replaceStringBlock;
}

@end

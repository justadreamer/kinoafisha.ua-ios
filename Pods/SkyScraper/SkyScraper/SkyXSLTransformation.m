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

#import "SkyXSLTransformation.h"

NSString  * const SkyScraperErrorDomain = @"SkyScraperErrorDomain Error Domain";

extern int xmlLoadExtDtdDefaultValue;

@interface SkyXSLTransformation()
@property (nonatomic,assign) xsltStylesheetPtr stylesheet;
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
        xmlDocPtr stylesheetDoc = xmlReadFile([[URL absoluteString] cStringUsingEncoding:NSUTF8StringEncoding], NULL, XSLT_PARSE_OPTIONS | XML_PARSE_XINCLUDE);
        [self setupStyleSheetFromXMLDoc:stylesheetDoc];
    }
    return self;
}

- (void) setupStyleSheetFromXMLDoc:(xmlDocPtr)styleSheetDoc {
    xmlXIncludeProcess(styleSheetDoc);
    self.stylesheet = xsltParseStylesheetDoc(styleSheetDoc);
}

- (NSData *) transformedDataFromHTMLData:(NSData *)html withParams:(NSDictionary *)params error:(NSError * __autoreleasing *)error {
    if (!self.stylesheet) {
        *error = [NSError errorWithDomain:SkyScraperErrorDomain code:1 userInfo:
                  @{NSLocalizedFailureReasonErrorKey : @"Either no stylesheet provided, or failed to parse the one provided"}];
        return nil;
    }
    
    if ([html length]==0) {
        *error = [NSError errorWithDomain:SkyScraperErrorDomain code:2 userInfo:
                  @{NSLocalizedFailureReasonErrorKey : @"No input HTML provided, or the input is empty"}];
        return nil;
    }
    
    /* parameters */
    int nParams = 2 * (int) [params count];
    char * *paramsBuf = calloc(nParams+1, sizeof(char *));
    
    __block int i = 0;
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *skey = [NSString stringWithFormat:@"%@",key];
        NSString *sval = [NSString stringWithFormat:@"%@",obj];
        char *keybuf = calloc(2*[skey length]+1, sizeof(char));
        char *valbuf = calloc(2*[sval length]+1, sizeof(char));
        if ([skey getCString:keybuf maxLength:2*[skey length] encoding:NSUTF8StringEncoding] &&
            [sval getCString:valbuf maxLength:2*[sval length] encoding:NSUTF8StringEncoding]) {
            paramsBuf[i++]=keybuf;
            paramsBuf[i++]=valbuf;
        }
    }];
    paramsBuf[i]=NULL;

    xmlParserOption additionalOptions = HTML_PARSE_RECOVER | HTML_PARSE_NOERROR | HTML_PARSE_NOWARNING;
    
    htmlDocPtr doc = htmlReadDoc((xmlChar *)[[[NSString alloc] initWithData:html encoding:NSUTF8StringEncoding] cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, XSLT_PARSE_OPTIONS | additionalOptions);

    xsltTransformContextPtr ctxt = xsltNewTransformContext(self.stylesheet, doc);
    if (ctxt == NULL) {
        *error = [NSError errorWithDomain:SkyScraperErrorDomain code:3 userInfo:
                  @{NSLocalizedFailureReasonErrorKey : @"Unable to create transform context"}];
        return nil;
    }

    xsltSetCtxtParseOptions(ctxt, XSLT_PARSE_OPTIONS | additionalOptions);
    ctxt->xinclude = 1;

    /* actual applying stylesheet */
    xmlDocPtr res = xsltApplyStylesheetUser(self.stylesheet, doc, (const char **)paramsBuf, NULL, NULL, ctxt);

    xsltFreeTransformContext(ctxt);
    /* dumping bytes of the result */
    xmlChar *buf;
    int size;

    xsltSaveResultToString(&buf, &size, res, self.stylesheet);

    /* freeing parameters */
    for (int i=0;i<nParams;++i) {
        if (paramsBuf[i]) {
            free(paramsBuf[i]);
        }
    }
    if (paramsBuf) {
        free(paramsBuf);
    }

    /* freeing all other stuff */
    xmlFreeDoc(doc);
    xmlFreeDoc(res);

    /* producing result */
    NSData *result = nil;
    if (buf) {
        result = [NSData dataWithBytesNoCopy:buf length:size freeWhenDone:YES];
    }

    return result;
}

- (NSString *) stringFromHTMLData:(NSData *)html withParams:(NSDictionary *)params error:(NSError *__autoreleasing *)error {
    NSData *data = [self transformedDataFromHTMLData:html withParams:params error:error];
    NSString *result = nil;
    if (data) {
        result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return result;
}

- (id) JSONObjectFromHTMLData:(NSData *)html withParams:(NSDictionary *)params error:(NSError * __autoreleasing *)error {
    NSData *data = [self transformedDataFromHTMLData:html withParams:params error:error];
    id JSONObject = nil;
    if (data) {
        JSONObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:error];
    }
    return JSONObject;
}

@end

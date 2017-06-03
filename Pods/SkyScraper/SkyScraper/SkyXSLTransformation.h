#import <Foundation/Foundation.h>

extern NSString  * const SkyScraperErrorDomain;

@interface SkyXSLTransformation : NSObject
/**
 *  XSLT stylesheet URL if it was initialized with 'initWithXSLTURL:' method
 */
@property (atomic,strong,readonly) NSURL* xsltURL;
/**
 *  set to YES to replace named entities with characters and decimal entities with hex equivalents (NO by default)
 */
@property (atomic,assign) BOOL replaceXMLEntities;
/**
 *  set to YES to fix the problem with parsing of empty textarea tags (NO by default) http://habrahabr.ru/post/27666/
 */
@property (atomic,assign) BOOL enableTextareaExpansion;

- (instancetype) init NS_UNAVAILABLE;

/**
 *  Designated initializer
 *
 *  @param xslt string representation of an XSLT stylesheet in UTF8 encoding
 *  @param baseURL an URL that is used primarily for resolving an XInclude pointing at relative location
 *
 *  @return instance of SkyXSLTransformation
 */
- (instancetype) initWithXSLTString:(NSString *)xslt baseURL:(NSURL *)baseURL NS_DESIGNATED_INITIALIZER;


/**
 *  Designated initializer
 *
 *  @param URL to load an XSLT stylesheet from in UTF8 encoding
 *
 *  @return instance of SkyXSLTransformation
 */
- (instancetype) initWithXSLTURL:(NSURL *)URL NS_DESIGNATED_INITIALIZER;

/**
 *  The actual transformation of the HTML document happens here.
 *
 *  @param html a data object containing a string representation of an HTML document in UTF8 encoding
 *  @param params a dictionary of params to be passed when the stylesheet transformation is applied
 * beware that when you pass a string param, you should enclose the actual string value into single quotes
 * otherwise it will be treated as an XPath within the XSLT
 *  @param error out param which contains an NSError object if anything failed during transformation
 *
 *  @return a string representation of the transformed HTML document in UTF8 encoding
 */
- (NSString *) stringFromHTMLData:(NSData *)html withParams:(NSDictionary *)params error:(NSError * __autoreleasing *)error;

/**
 *  A convenience method that internally uses transformedStringFromHTML:withParams: and should be used
 * in case you know that XSLT transform will produce JSON from an HTML document
 *
 *  @param html   a data object containing a string representation of an HTML document in UTF8 encoding
 *  @param params a dictionary of params to be passed when the stylesheet transformation is applied
 *  @param error an out param which contains an NSError object if anything failed during transformation
 *
 *  @return either NSDictionary or NSArray object corresponding to the string JSON representation
 */
- (id) JSONObjectFromHTMLData:(NSData *)html withParams:(NSDictionary *)params error:(NSError * __autoreleasing *)error;

/**
 *  A convenience method that internally applies the transfomration to xml
 *  data
 *
 *  @param xml    xml NSData represenation
 *  @param params params dictionary
 *  @param error  an out param containing NSError object
 *
 *  @return returns NSString representation of transformed xml data
 */
- (NSString *) stringFromXMLData:(NSData *)xml withParams:(NSDictionary *) params error:(NSError * __autoreleasing *)error;

/**
 *  A convenience method that internally applies the transformation to xml
 *  data
 *
 *  @param xml    xml NSData representation
 *  @param params params dictionary
 *  @param error  an out param containing NSError object
 *
 *  @return returns NSString representation of transformed xml data
 */
- (id) JSONObjectFromXMLData:(NSData *)xml withParams:(NSDictionary *)params error:(NSError * __autoreleasing *)error;
@end

//
//  SkyXSLTParams.m
//  Pods
//
//  Created by Eugene Dorfman on 3/30/15.
//
//

#import "SkyXSLTParams.h"
@interface SkyXSLTParams () {
    int nParams;
    char **_paramsBuf;
}
@end

@implementation SkyXSLTParams
- (void) dealloc {
    [self freeParamsBuf];
}

- (instancetype) initWithParams:(NSDictionary *)params {
    if (self = [super init]) {
        self.params = params;
    }
    return self;
}

- (void) freeParamsBuf {
    if (_paramsBuf) {
        /* freeing parameters */
        for (int i=0;i<nParams;++i) {
            if (_paramsBuf[i]) {
                free(_paramsBuf[i]);
            }
        }
        if (_paramsBuf) {
            free(_paramsBuf);
        }
    }
    
    _paramsBuf = NULL;
    nParams = 0;
}

- (void) setParams:(NSDictionary *)params {
    [self freeParamsBuf];
    
    /* parameters */
    nParams = 2 * (int) [params count];
    _paramsBuf = calloc(nParams+1, sizeof(char *));
    
    __block int i = 0;
    __weak __typeof(self)weakSelf = self;
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        NSString *skey = [NSString stringWithFormat:@"%@",key];
        NSString *sval = [NSString stringWithFormat:@"%@",obj];
        char *keybuf = calloc(2*[skey length]+1, sizeof(char));
        char *valbuf = calloc(2*[sval length]+1, sizeof(char));
        if ([skey getCString:keybuf maxLength:2*[skey length] encoding:NSUTF8StringEncoding] &&
            [sval getCString:valbuf maxLength:2*[sval length] encoding:NSUTF8StringEncoding]) {
            strongSelf.paramsBuf[i++]=keybuf;
            strongSelf.paramsBuf[i++]=valbuf;
        }
    }];
    _paramsBuf[i]=NULL;
}
@end

//
//  SoapFault.m
//
//  Interface that constructs a fault object from a SOAP fault when the
//  web service returns an error.
//  Authors: Jason Kichline, andCulture - Harrisburg, Pennsylvania USA
//

#import "SoapFault.h"
#import "Soap.h"

@implementation SoapFault

+ (SoapFault *)faultWithData:(NSMutableData *)data
{
    NSError *error;
    CXMLDocument *doc = [[CXMLDocument alloc] initWithData:data options:0 error:&error];
    if (doc == nil) {
        return [[SoapFault alloc] init];
    }
    return [SoapFault faultWithXMLDocument:doc];
}

+ (SoapFault *)faultWithXMLDocument:(CXMLDocument *)document
{
    return [SoapFault faultWithXMLElement:[Soap getNode:[document rootElement] withName:@"Fault"]];
}

+ (SoapFault *)faultWithXMLElement:(CXMLNode *)element
{
    SoapFault *fault = [[SoapFault alloc] init];
    fault.hasFault = NO;
    if (element == nil) {
        return fault;
    }

    fault.faultCode = [Soap getNodeValue:element withName:@"faultcode"];
    fault.faultString = [Soap getNodeValue:element withName:@"faultstring"];
    fault.faultActor = [Soap getNodeValue:element withName:@"faultactor"];
    fault.detail = [Soap getNodeValue:element withName:@"detail"];
    fault.hasFault = YES;
    return fault;
}

- (NSString *)description
{
    if (self.hasFault) {
        return [NSString stringWithFormat:@"%@ %@\n%@", self.faultCode, self.faultString, self.detail];
    } else {
        return nil;
    }
}

- (NSError *)NSError
{
    NSString * const kSoapErrorDomain = @"SoapFault";
    const NSUInteger kSoapErrorCode = 1;

    NSError *error = [NSError errorWithDomain:kSoapErrorDomain
                                         code:kSoapErrorCode
                                     userInfo:@{ NSLocalizedDescriptionKey: self.faultString }];

    return error;
}

@end

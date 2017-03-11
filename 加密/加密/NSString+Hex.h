//
//  NSString+Hex.h
//  Created by Ben Baron on 10/20/10.
//

#import <Foundation/Foundation.h>

@interface NSString (Hex)

+ (NSString *)stringFromHex:(NSString *)str;
+ (NSString *)stringToHex:(NSString *)str;

+ (NSData*) hexStrToBytes:(NSString *)aHexStr;
+ (NSString *) hexStrFromBytes:(NSData*)aBytes;

@end

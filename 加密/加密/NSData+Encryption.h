
#import <Foundation/Foundation.h>

@interface NSData (Encryption)

- (NSData *)AES128EncryptWithKey:(NSString *)key;
- (NSData *)AES128DecryptWithKey:(NSString *)key;

@end
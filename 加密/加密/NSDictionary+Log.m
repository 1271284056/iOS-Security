
#import "NSDictionary+Log.h"

@implementation NSDictionary (Log)

// 本地化的方法.针对不同的语言,提供的方法(方便调试),重写这个方法之后,只需要将这个分类添加到项目中,NSLog的时候,就会按照这个方法重写的内容来打印.

-(NSString *)descriptionWithLocale:(id)locale
{
    NSMutableString *strM = [[NSMutableString alloc] init];
    
    [strM appendString:@"{"];
    
    // 遍历字典.取出字典中的 key 值 和 value 值.
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        //
        [strM appendFormat:@"\n\t%@ =%@\n",key,obj];
        
    }];
    
    [strM appendString:@"}"];
    
    return strM;
}

@end



@implementation NSArray (Log)

-(NSString *)descriptionWithLocale:(id)locale
{
    NSMutableString *strM = [[NSMutableString alloc] init];
    
    [strM appendString:@"\n{"];
    
    // 遍历数组
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        //
        [strM appendFormat:@"\n\t %@\n",obj];
        
    }];
    
    [strM appendString:@"}\n"];

    
    return strM;
}

@end

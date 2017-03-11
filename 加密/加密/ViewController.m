//
//  ViewController.m
//  加密
//
//  Created by 张江东 on 17/3/11.
//  Copyright © 2017年 58kuaipai. All rights reserved.
//

#import "ViewController.h"

//哈希
#import "NSString+Hash.h"

//钥匙串
#import "SSKeychain.h"

//指纹
#import <LocalAuthentication/LocalAuthentication.h>

//AES
#import "NSData+Encryption.h"
#import "NSString+Hex.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fingerPrint];
}


//base64加密解密
- (void)base64{
    
    /*
     base64 编码是现代密码学的基础.
     原本是 8个bit 一组表示数据,改为 6个bit一组表示数据,不足的部分补零,每 两个0 用 一个 = 表示.
     用base64 编码之后,数据长度会变大,增加了大约 1/3 左右.
     base64 基本能够达到安全要求,但是,base64能够逆运算,非常不安全!
     base64 编码有个非常显著的特点,末尾有个 '=' 号.
     */
    
    
    //------------加密
    //字符串转成二进制
    NSData *nsdata = [@"iOS Developer 张江东 encoded in Base64"
                      dataUsingEncoding:NSUTF8StringEncoding];
    //base64加密
    NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];
    //打印base64加密结果
    NSLog(@"Encoded: %@", base64Encoded);
    
    
    // ---------- 解密
    //加密后的字符串转成二进制
    NSData *nsdataFromBase64String = [[NSData alloc]
                                      initWithBase64EncodedString:base64Encoded options:0];
    //base64解密
    NSString *base64Decoded = [[NSString alloc]
                               initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
    NSLog(@"Decoded: %@", base64Decoded);
}


//md5加密不可逆
- (void)md5Test
{
    /*
     把一个任意长度的字节串变换成一定长度的十六进制的大整数. 注意,字符串的转换过程是不可逆的.
     用于确保'信息传输'完整一致.
     
     MD5特点:
     *1.压缩性:   任意长度的数据,算出的 MD5 值长度都是固定的.
     *2.容易计算: 从原数据计算出 MD5 值很容易.
     *3.抗修改性: 对原数据进行任何改动,哪怕只修改一个字节,所得到的 MD5 值都有很大区别.
     *4.弱抗碰撞: 已知原数据和其 MD5 值,想找到一个具有相同 MD5 值的数据(即伪造数据)是非常困难的.
     *5.强抗碰撞: 想找到两个不同数据,使他们具有相同的 MD5 值,是非常困难的.
     
     MD5 应用:
     *1. 一致性验证: MD5 将整个文件当做一个大文本信息,通过不可逆的字符串变换算法,产生一个唯一的 MD5 信息摘要.就像每个人都有自己独一无二的指纹,MD5 对任何文件产生一个独一无二的"数字指纹".
     利用 MD5 来进行文件校验, 被大量应用在软件下载站,论坛数据库,系统文件安全等方面.
     *2. 数字签名;
     *3. 安全访问认证;
     */
    
    //MD5加密
    NSString *string = @"zhang";
    NSString *str2 = @"zhang123456";
    // 对字符串做一次 MD5 运算
    string = string.md5String;
    str2 = str2.md5String;
    NSLog(@"zhang: %@  str2:%@",string,str2);
    
    
    // MD5 + 盐
    NSString *str3 = @"lisi";
    // 盐 值 够咸 够长.
    NSString *salt = @"fenghuiluzhuan";
    str3 = [str3 stringByAppendingString:salt];
    
    NSLog(@"str3%@",str3.md5String);
}

//hmac加密
- (void)hmacTest
{/*
    HMAC 利用哈希算法,以一个密钥和一个消息为输入,生成一个消息摘要作为输出.
    HMAC 主要使用在身份认证中;
  
    认证流程:
    *1. 客户端向服务器发送一个请求.
    *2. 服务器接收到请求后,生成一个'随机数'并通过网络传输给客户端.
    *3. 客户端将接收到的'随机数'和'密钥'进行 HMAC-MD5 运算,将得到的结构作为认证数据传递给服务器.
    (实际是将随机数提供给 ePass,密钥也是存储在 ePass中的)
    *4. 与此同时,服务器也使用该'随机数'与存储在服务器数据库中的该客户'密钥'进行 HMAC-MD5 运算,如果
    服务器的运算结果与客户端传回的认证数据相同,则认为客户端是一个合法用法.
    */
    
    // hmac : 服务器存储的一个密钥. 本地存一个.
    NSString *string = @"zhang";
    NSString *key = @"8a627a4578ace384017c997f12d68b23";
    
    // key :密钥.
    string = [string hmacMD5StringWithKey:key];
    NSLog(@"%@",string);
    
}

//时间戳加密
- (void)timeHmac{
    
    /*
     相同的密码明文 + 相同的加密算法 ===> 每次都得到不同的加密结果.
     原理:将当前时间加入到密码中;
     因为每次登陆时间都不同,所以每次计算出的结果也都不相同.
     服务器也需要采用相同的算法.这就需要服务器和客户端时间一致.
     时间戳密码.
     
     每次发送网络请求之前.将密码与时间做一次运算.每次运算的结果,由于时间不同,结果就不同.
     级别越低越安全 :1分钟之内.
    注意:服务器端时间和客户端时间,可以有一分钟的误差(比如:第59S发送的网络请求,一秒钟后服务器收到并作出响应,这时服务器当前时间比客户端发送时间晚一分钟).
    这就意味着,服务器需要计算两次（当前时间和一分钟之前两个时间点各计算一次）.只要有一个结果是正确的,就可以验证成功!
     */
    
    // 需要: 1.时间 2.密钥 3.hmac算法
    NSString *password = @"zhang";
    // 密钥
    NSString *key = @"8a627a4578ace384017c997f12d68b23";
    
    // 时间格式化工具
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // 自定义时间的格式
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];

    // 取出当前时间的字符串
    NSString *time = [formatter stringFromDate:[NSDate date]];
    NSLog(@"time%@",time);
    
    // 对密码做一次 hmac 运算 key:密钥
    password = [password hmacMD5StringWithKey:key];
    
    // 将第一次运算结果与时间拼接起来
    password = [password stringByAppendingString:time];
    
    // 将拼接之后的字符串在做一次HMAC运算
    password = [password hmacMD5StringWithKey:key];
    NSLog(@"哈希算法password-->%@",password);
}


/*
 重点: 1.钥匙串访问
 {
 苹果在 iOS 7.0.3 版本以后公布钥匙串访问的SDK. 钥匙串访问接口是纯C语言的.
 
 钥匙串使用 AES 256加密算法,能够保证用户密码的安全.
 
 钥匙串访问的第三方框架(SSKeychain),是对 C语言框架 的封装.注意:不需要看源码.
 
 钥匙串访问的密码保存在哪里?只有苹果才知道.这样进一步保障了用户的密码安全.
 */

//钥匙串访问
- (void)keyChain{
    
    
    //  // SSKeychain存储密码的时候,可以直接存储密码明文.
    // 1.密码明文
    // 2. 传一个唯一的值就可以了,一般传 [NSBundle mainBundle].bundleIdentifier
    // 3. 用户
    // 将密码存入钥匙串.
    
    
    
    NSString *servce = [NSBundle mainBundle].bundleIdentifier;
    NSString *account = @"12123424";
    NSString *pass = @"你好啊 为人民服务";
    //保存
    BOOL is = [SSKeychain setPassword:pass forService:servce account:account error:NULL];
    //取出密码
    NSString *mima = [SSKeychain passwordForService:servce account:account];
    NSLog(@"%d,%@",is,mima);


}

//指纹识别

- (void)fingerPrint{
    // 指纹识别.
    
    // 1.判断当前系统版本是否支持指纹识别功能 :iOS 8.0 以上的系统
    
    // 取出当前系统的版本号
    float version = [UIDevice currentDevice].systemVersion.floatValue;
    
    if (version < 8.0) {
        
        NSLog(@"请升级至最新系统,一次带来更好地软件应用体验");
        return;
    }
    
    // 2.判断当前设备是否支持指纹识别功能(是否带有 TouchID).
    
    // 1> 实例化一个指纹识别器
    LAContext *ctx = [[LAContext alloc] init];
    
    if (![ctx canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:NULL]) {
        
        NSLog(@"您的手机太旧了,请购买最新的iPhone设备");
        return;
    }
    
    // 指纹识别
    [ctx evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"请输入指纹" reply:^(BOOL success, NSError *error) {
        //
        if (success) {
            NSLog(@"指纹识别成功");
        }else
        {
            NSLog(@"指纹认证失败");
            NSLog(@"错误码：%zd",error.code);
            NSLog(@"出错信息：%@",error);
            // 错误码 error.code
            // -1: 连续三次指纹识别错误
            // -2: 在TouchID对话框中点击了取消按钮
            // -3: 在TouchID对话框中点击了输入密码按钮
            // -4: TouchID对话框被系统取消，例如按下Home或者电源键
            // -8: 连续五次指纹识别错误，TouchID功能被锁定，下一次需要输入系统密码
            NSLog(@"指纹识别失败,请重新输入指纹.");
        }
        
    }];
}


//AES
- (void)aesTest{
#   define AES_KEY     @"5kUaipAi8sOc-Ket"

    //aes加密
    NSDictionary *dict = @{@"staff_no":@"12344",@"staff_password":@"rewrew2"};
    NSString *str = [self dictionaryToJson:dict];
    NSData *plain = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSData *cipher = [plain AES128EncryptWithKey:AES_KEY];
    NSString *result = [NSString hexStrFromBytes:cipher];
    
    //解密

    ////        string转data
    NSData *data = [NSString hexStrToBytes:result];
    //        //data解密
    NSData *jiemiData = [data AES128DecryptWithKey:AES_KEY];
    //        //data 转 string
    NSString *result2 = [[NSString alloc] initWithData:jiemiData  encoding:NSUTF8StringEncoding];
    
    
    NSLog(@"加密后--> %@,解密--->%@",result,result2);

    
}

//字典转字符串
- (NSString*)dictionaryToJson:(NSDictionary *)dic

{
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}

@end

//
//  Internal.h
//  ECHO
//
//  Created by Fedorenko Nikita on 7.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface CryptoHash : NSObject
+ (NSData *)sha256:(NSData *)data;
+ (NSData *)sha512:(NSData *)data;
+ (NSData *)ripemd160:(NSData *)data;
@end

@interface Secp256k1 : NSObject
+ (NSData *)generatePublicKeyWithPrivateKey:(NSData *)privateKeyData compression:(BOOL)isCompression;
+ (NSData *)sign:(NSData *)hash privateKey:(NSData *)privateKeyData isPubKeyCompressed:(BOOL)isPubKeyCompressed;
+ (NSData *)encryptMessageWithPrivateKey:(NSData *)privateKey publicKey:(NSData *)publicKey nonce:(NSString *)nonce message:(NSString *)message;
+ (NSString *)decryptMessageWithPrivateKey:(NSData *)privateKey publicKey:(NSData *)publicKey nonce:(NSString *)nonce message:(NSData *)message;
@end

NS_ASSUME_NONNULL_END

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

@interface Ed25519 : NSObject
+ (NSData *)generateRandomPrivateKey;
+ (NSData *)generatePublicKeyWithPrivateKey:(NSData *)privateKeyData;
+ (NSData *)sign:(NSData *)hash privateKey:(NSData *)privateKeyData;
@end

NS_ASSUME_NONNULL_END

// Bitcoin-flavoured big number wrapping OpenSSL BIGNUM.
// It is doing byte ordering like bitcoind does to stay compatible.
// ECHOBigNumber is immutable. ECHOMutableBigNumber is its mutable counterpart.
// -copy always returns immutable instance, like in other Cocoa containers.
@class ECHOBigNumber;
@class ECHOMutableBigNumber;

@interface ECHOBigNumber : NSObject <NSCopying, NSMutableCopying>

@property(nonatomic, readonly) uint32_t compact; // compact representation used for the difficulty target
@property(nonatomic, readonly) uint32_t uint32value;
@property(nonatomic, readonly) int32_t int32value;
@property(nonatomic, readonly) uint64_t uint64value;
@property(nonatomic, readonly) int64_t int64value;
@property(nonatomic, readonly) NSString* hexString;
@property(nonatomic, readonly) NSString* decimalString;
@property(nonatomic, readonly) NSData* signedLittleEndian;
@property(nonatomic, readonly) NSData* unsignedBigEndian;

// Deprecated. Use `-signedLittleEndian` instead.
@property(nonatomic, readonly) NSData* littleEndianData DEPRECATED_ATTRIBUTE;

// Deprecated. Use `-unsignedBigEndian` instead.
@property(nonatomic, readonly) NSData* unsignedData DEPRECATED_ATTRIBUTE;

@property(nonatomic, readonly) BOOL isZero;
@property(nonatomic, readonly) BOOL isOne;


// ECHOBigNumber returns always the same object for these constants.
// ECHOMutableBigNumber returns a new object every time.
+ (instancetype) zero;        //  0
+ (instancetype) one;         //  1
+ (instancetype) negativeOne; // -1

- (id) init;
- (id) initWithCompact:(uint32_t)compact;
- (id) initWithUInt32:(uint32_t)value;
- (id) initWithInt32:(int32_t)value;
- (id) initWithUInt64:(uint64_t)value;
- (id) initWithInt64:(int64_t)value;
- (id) initWithSignedLittleEndian:(NSData*)data;
- (id) initWithUnsignedBigEndian:(NSData*)data;
- (id) initWithLittleEndianData:(NSData*)data DEPRECATED_ATTRIBUTE;
- (id) initWithUnsignedData:(NSData*)data DEPRECATED_ATTRIBUTE;


// Inits with setString:base:
- (id) initWithString:(NSString*)string base:(NSUInteger)base;

// Same as initWithString:base:16
- (id) initWithHexString:(NSString*)hexString DEPRECATED_ATTRIBUTE;

// Same as initWithString:base:10
- (id) initWithDecimalString:(NSString*)decimalString;

- (NSString*) stringInBase:(NSUInteger)base;

// Re-declared copy and mutableCopy to provide exact return type.
- (ECHOBigNumber*) copy;
- (ECHOMutableBigNumber*) mutableCopy;

// TODO: maybe add support for hash, figure out what the heck is that.
//void set_hash(hash_digest load_hash);
//hash_digest hash() const;

// Returns MIN(self, other)
- (ECHOBigNumber*) min:(ECHOBigNumber*)other;

// Returns MAX(self, other)
- (ECHOBigNumber*) max:(ECHOBigNumber*)other;


- (BOOL) less:(ECHOBigNumber*)other;
- (BOOL) lessOrEqual:(ECHOBigNumber*)other;
- (BOOL) greater:(ECHOBigNumber*)other;
- (BOOL) greaterOrEqual:(ECHOBigNumber*)other;


// Divides receiver by another bignum.
// Returns an array of two new ECHOBigNumber instances: @[ quotient, remainder ]
- (NSArray*) divmod:(ECHOBigNumber*)other;

// Destroys sensitive data and sets the value to 0.
// It is also called on dealloc.
// This method is available for both mutable and immutable numbers by design.
- (void) clear;

@end


@interface ECHOMutableBigNumber : ECHOBigNumber

@property(nonatomic, readwrite) uint32_t compact; // compact representation used for the difficulty target
@property(nonatomic, readwrite) uint32_t uint32value;
@property(nonatomic, readwrite) int32_t int32value;
@property(nonatomic, readwrite) uint64_t uint64value;
@property(nonatomic, readwrite) int64_t int64value;
@property(nonatomic, readwrite) NSString* hexString;
@property(nonatomic, readwrite) NSString* decimalString;
@property(nonatomic, readwrite) NSData* signedLittleEndian;
@property(nonatomic, readwrite) NSData* unsignedBigEndian;
@property(nonatomic, readwrite) NSData* littleEndianData DEPRECATED_ATTRIBUTE;
@property(nonatomic, readwrite) NSData* unsignedData DEPRECATED_ATTRIBUTE;

// ECHOBigNumber returns always the same object for these constants.
// ECHOMutableBigNumber returns a new object every time.
+ (instancetype) zero;        //  0
+ (instancetype) one;         //  1
+ (instancetype) negativeOne; // -1

// Supports bases from 2 to 36. For base 2 allows optional 0b prefix, base 16 allows optional 0x prefix. Spaces are ignored.
- (void) setString:(NSString*)string base:(NSUInteger)base;

// Operators modify the receiver and return self.
// To create a new instance z = x + y use copy method: z = [[x copy] add:y]
- (instancetype) add:(ECHOBigNumber*)other; // +=
- (instancetype) add:(ECHOBigNumber*)other mod:(ECHOBigNumber*)mod;
- (instancetype) subtract:(ECHOBigNumber*)other; // -=
- (instancetype) subtract:(ECHOBigNumber*)other mod:(ECHOBigNumber*)mod;
- (instancetype) multiply:(ECHOBigNumber*)other; // *=
- (instancetype) multiply:(ECHOBigNumber*)other mod:(ECHOBigNumber*)mod;
- (instancetype) divide:(ECHOBigNumber*)other; // /=
- (instancetype) mod:(ECHOBigNumber*)other; // %=
- (instancetype) lshift:(unsigned int)shift; // <<=
- (instancetype) rshift:(unsigned int)shift; // >>=
- (instancetype) inverseMod:(ECHOBigNumber*)mod; // (a^-1) mod n
- (instancetype) exp:(ECHOBigNumber*)power;
- (instancetype) exp:(ECHOBigNumber*)power mod:(ECHOBigNumber *)mod;

@end

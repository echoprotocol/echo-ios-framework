#import "Internal.h"

#import <openssl/sha.h>
#import <openssl/ripemd.h>
#import <openssl/hmac.h>
#import <openssl/ec.h>
#include <openssl/ecdsa.h>
#include <openssl/evp.h>
#include <openssl/obj_mac.h>
#include <openssl/bn.h>
#include <openssl/rand.h>

#import <CommonCrypto/CommonCrypto.h>

@implementation CryptoHash

+ (NSData *)sha256:(NSData *)data {
    NSMutableData *result = [NSMutableData dataWithLength:SHA256_DIGEST_LENGTH];
    SHA256(data.bytes, data.length, result.mutableBytes);
    return result;
}

+ (NSData *)sha256sha256:(NSData *)data {
    return [self sha256:[self sha256:data]];
}

+ (NSData *)sha512:(NSData *)data {
    NSMutableData *result = [NSMutableData dataWithLength:SHA512_DIGEST_LENGTH];
    SHA512(data.bytes, data.length, result.mutableBytes);
    return result;
}

+ (NSData *)ripemd160:(NSData *)data {
    NSMutableData *result = [NSMutableData dataWithLength:RIPEMD160_DIGEST_LENGTH];
    RIPEMD160(data.bytes, data.length, result.mutableBytes);
    return result;
}

+ (NSData *)sha256ripemd160:(NSData *)data {
    return [self ripemd160:[self sha256:data]];
}

+ (NSData *)hmacsha512:(NSData *)data key:(NSData *)key {
    unsigned int length = SHA512_DIGEST_LENGTH;
    NSMutableData *result = [NSMutableData dataWithLength:length];
    HMAC(EVP_sha512(), key.bytes, (int)key.length, data.bytes, data.length, result.mutableBytes, &length);
    return result;
}

@end

@implementation Secp256k1

+ (NSData *)dataFromHexString:(NSString *)string {
    string = [string lowercaseString];
    NSMutableData *data= [NSMutableData new];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i = 0;
    int length = string.length;
    while (i < length-1) {
        char c = [string characterAtIndex:i++];
        if (c < '0' || (c > '9' && c < 'a') || c > 'f')
            continue;
        byte_chars[0] = c;
        byte_chars[1] = [string characterAtIndex:i++];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
    }
    return data;
}

+ (NSString *)hexFromData:(NSData *)data {
    
    NSUInteger length = data.length;
    if (length == 0) return @"";
    
    NSMutableData* resultdata = [NSMutableData dataWithLength:length * 2];
    char *dest = resultdata.mutableBytes;
    unsigned const char *src = data.bytes;
    for (int i = 0; i < length; ++i) {
        sprintf(dest + i*2, "%02x", (unsigned int)(src[i]));
    }
    return [[NSString alloc] initWithData:resultdata encoding:NSASCIIStringEncoding];
}

#pragma mark - Encryption / Decryption

+ (NSMutableData*) encryptData:(NSData*)data key:(NSData*)key iv:(NSData*)initializationVector {
    return [Secp256k1 cryptData:data key:key iv:initializationVector operation:kCCEncrypt];
}

+ (NSMutableData*) decryptData:(NSData*)data key:(NSData*)key iv:(NSData*)initializationVector {
    return [Secp256k1 cryptData:data key:key iv:initializationVector operation:kCCDecrypt];
}

+ (NSMutableData*) cryptData:(NSData*)data key:(NSData*)key iv:(NSData*)iv operation:(CCOperation)operation {
    if (!data || !key) return nil;
    
    int blockSize = kCCBlockSizeAES128;
    int encryptedDataCapacity = (int)(data.length / blockSize + 1) * blockSize;
    NSMutableData* encryptedData = [[NSMutableData alloc] initWithLength:encryptedDataCapacity];
    
    // Treat empty IV as nil
    if (iv.length == 0) {
        iv = nil;
    }
    
    // If IV is supplied, validate it.
    if (iv) {
        if (iv.length == blockSize) {
            // perfect.
        } else if (iv.length > blockSize) {
            // IV is bigger than the block size. CCCrypt will take only the first 16 bytes.
        } else {
            // IV is smaller than needed. This should not happen. It's better to crash than to leak something.
            @throw [NSException exceptionWithName:@"IV is invalid"
                                           reason:[NSString stringWithFormat:@"Invalid size of IV: %d", (int)iv.length]
                                         userInfo:nil];
        }
    }
    
    size_t dataOutMoved = 0;
    CCCryptorStatus cryptstatus = CCCrypt(
                                          operation,                   // CCOperation op,         /* kCCEncrypt, kCCDecrypt */
                                          kCCAlgorithmAES,             // CCAlgorithm alg,        /* kCCAlgorithmAES128, etc. */
                                          kCCOptionPKCS7Padding,       // CCOptions options,      /* kCCOptionPKCS7Padding, etc. */
                                          key.bytes,                   // const void *key,
                                          key.length,                  // size_t keyLength,
                                          iv ? iv.bytes : NULL,        // const void *iv,         /* optional initialization vector */
                                          data.bytes,                  // const void *dataIn,     /* optional per op and alg */
                                          data.length,                 // size_t dataInLength,
                                          encryptedData.mutableBytes,  // void *dataOut,          /* data RETURNED here */
                                          encryptedData.length,        // size_t dataOutAvailable,
                                          &dataOutMoved                // size_t *dataOutMoved
                                          );
    
    if (cryptstatus == kCCSuccess) {
        // Resize the result key to the correct size.
        encryptedData.length = dataOutMoved;
        return encryptedData;
    } else {
        //kCCSuccess          = 0,
        //kCCParamError       = -4300,
        //kCCBufferTooSmall   = -4301,
        //kCCMemoryFailure    = -4302,
        //kCCAlignmentError   = -4303,
        //kCCDecodeError      = -4304,
        //kCCUnimplemented    = -4305,
        //kCCOverflow         = -4306
        @throw [NSException exceptionWithName:@"CCCrypt failed"
                                       reason:[NSString stringWithFormat:@"error: %d", cryptstatus] userInfo:nil];
        return nil;
    }
}

/**
 * Decodes an ascii string to a byte array.
 */
+ (NSData *)hexlify:(NSData *)data {
    
    NSString *hexString = [Secp256k1 hexFromData:data];
    NSData *newData = [hexString dataUsingEncoding:NSASCIIStringEncoding];
    
    return newData;
}

+ (NSData *)encryptMessageWithPrivateKey:(NSData *)privateKey publicKey:(NSData *)publicKey nonce:(NSString *)nonce message:(NSString *)message {
    
    // Nonce bytes
    NSData *nonceData = [nonce dataUsingEncoding:NSUTF8StringEncoding];
    
    // Private key
    BN_CTX *ctx = BN_CTX_new();
    EC_KEY *private = EC_KEY_new_by_curve_name(NID_secp256k1);
    const EC_GROUP *privateGroup = EC_KEY_get0_group(private);
    
    BIGNUM *prv = BN_new();
    BN_bin2bn(privateKey.bytes, (int)privateKey.length, prv);
    
    EC_POINT *pub = EC_POINT_new(privateGroup);
    EC_POINT_mul(privateGroup, pub, prv, nil, nil, ctx);
    EC_KEY_set_private_key(private, prv);
    EC_KEY_set_public_key(private, pub);
    
    // Public key
    EC_KEY *public = EC_KEY_new_by_curve_name(NID_secp256k1);
    const unsigned char* bytes = publicKey.bytes;
    o2i_ECPublicKey(&public, &bytes, publicKey.length);
    
    // Bignum pk
    BIGNUM pk;
    BN_init(&pk);
    BN_bin2bn(privateKey.bytes, (int)privateKey.length, &pk);
    
    // Curve point
    const EC_POINT* ecpoint = EC_KEY_get0_public_key(public);
    const EC_GROUP* group = EC_GROUP_new_by_curve_name(NID_secp256k1);
    BN_CTX* bnctx = BN_CTX_new();
    EC_POINT* point = EC_POINT_new(group);
    EC_POINT_copy(point, ecpoint);
    
    // Multiply
    EC_POINT_mul(group, point, NULL, point, &pk, bnctx);
    
    // X Point
    BN_CTX_start(bnctx);
    BIGNUM* xPoint = BN_CTX_get(bnctx);
    EC_POINT_get_affine_coordinates_GFp(group, point, xPoint /* x */, NULL  /* y */, bnctx);
    BN_CTX_end(bnctx);
    
    // X.unsignedBigEndian
    int num_bytes = BN_num_bytes(xPoint);
    NSMutableData* xPointData = [[NSMutableData alloc] initWithLength:32];
    BN_bn2bin(xPoint, &xPointData.mutableBytes[32 - num_bytes]);
    
    NSData* hash = [CryptoHash sha512:xPointData];
    NSData* hashInASCII = [Secp256k1 hexlify:hash];
    
    NSMutableData* seed = [nonceData mutableCopy];
    [seed appendData:hashInASCII];
    
    NSData* checksum = [[CryptoHash sha256:[message dataUsingEncoding:NSUTF8StringEncoding]] subdataWithRange:NSMakeRange(0, 4)];
    
    NSMutableData* payload = checksum.mutableCopy;
    [payload appendData:[message dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSData* hashedSeedData = [CryptoHash sha512:seed];
    NSString* hashedSeed = [Secp256k1 hexFromData:hashedSeedData];
    
    NSData *key = [Secp256k1 dataFromHexString:[hashedSeed substringWithRange:NSMakeRange(0, 64)]];
    NSData* iv = [Secp256k1 dataFromHexString:[hashedSeed substringWithRange:NSMakeRange(64, 32)]];
    
    return [Secp256k1 encryptData:payload key:key iv:iv];
}

+ (NSString *)decryptMessageWithPrivateKey:(NSData *)privateKey publicKey:(NSData *)publicKey nonce:(NSString *)nonce message:(NSData *)message {
    
    // Nonce bytes
    NSData *nonceData = [nonce dataUsingEncoding:NSUTF8StringEncoding];
    
    // Private key
    BN_CTX *ctx = BN_CTX_new();
    EC_KEY *private = EC_KEY_new_by_curve_name(NID_secp256k1);
    const EC_GROUP *privateGroup = EC_KEY_get0_group(private);
    
    BIGNUM *prv = BN_new();
    BN_bin2bn(privateKey.bytes, (int)privateKey.length, prv);
    
    EC_POINT *pub = EC_POINT_new(privateGroup);
    EC_POINT_mul(privateGroup, pub, prv, nil, nil, ctx);
    EC_KEY_set_private_key(private, prv);
    EC_KEY_set_public_key(private, pub);
    
    // Public key
    EC_KEY *public = EC_KEY_new_by_curve_name(NID_secp256k1);
    const unsigned char* bytes = publicKey.bytes;
    o2i_ECPublicKey(&public, &bytes, publicKey.length);
    
    // Bignum pk
    BIGNUM pk;
    BN_init(&pk);
    BN_bin2bn(privateKey.bytes, (int)privateKey.length, &pk);
    
    // Curve point
    const EC_POINT* ecpoint = EC_KEY_get0_public_key(public);
    const EC_GROUP* group = EC_GROUP_new_by_curve_name(NID_secp256k1);
    BN_CTX* bnctx = BN_CTX_new();
    EC_POINT* point = EC_POINT_new(group);
    EC_POINT_copy(point, ecpoint);
    
    // Multiply
    EC_POINT_mul(group, point, NULL, point, &pk, bnctx);
    
    // X Point
    BN_CTX_start(bnctx);
    BIGNUM* xPoint = BN_CTX_get(bnctx);
    EC_POINT_get_affine_coordinates_GFp(group, point, xPoint /* x */, NULL  /* y */, bnctx);
    BN_CTX_end(bnctx);
    
    // X.unsignedBigEndian
    int num_bytes = BN_num_bytes(xPoint);
    NSMutableData* xPointData = [[NSMutableData alloc] initWithLength:32];
    BN_bn2bin(xPoint, &xPointData.mutableBytes[32 - num_bytes]);
    
    NSData* hash = [CryptoHash sha512:xPointData];
    NSData* hashInASCII = [Secp256k1 hexlify:hash];
    
    NSMutableData* seed = [nonceData mutableCopy];
    [seed appendData:hashInASCII];
    
    NSData* hashedSeedData = [CryptoHash sha512:seed];
    NSString* hashedSeed = [Secp256k1 hexFromData:hashedSeedData];
    
    NSData* key = [Secp256k1 dataFromHexString:[hashedSeed substringWithRange:NSMakeRange(0, 64)]];
    NSData* iv = [Secp256k1 dataFromHexString:[hashedSeed substringWithRange:NSMakeRange(64, 32)]];
    
    NSData* decoded = [Secp256k1 decryptData:message key:key iv:iv];
    NSData* decodedMessageData = [decoded subdataWithRange:NSMakeRange(4, decoded.length - 4)];
    NSData* checkSum = [decoded subdataWithRange:NSMakeRange(0, 4)];
    NSData* verificationCheckSum = [[CryptoHash sha256:decodedMessageData] subdataWithRange:NSMakeRange(0, 4)];
    
    if (![checkSum isEqual:verificationCheckSum] ) {
        NSLog(@"Checksums not equals");
        return [NSString new];
    }
    
    NSString* string = [NSString stringWithUTF8String:[decodedMessageData bytes]];
    
    return string;
}

+ (NSData *)generatePublicKeyWithPrivateKey:(NSData *)privateKeyData compression:(BOOL)isCompression {
    BN_CTX *ctx = BN_CTX_new();
    EC_KEY *key = EC_KEY_new_by_curve_name(NID_secp256k1);
    const EC_GROUP *group = EC_KEY_get0_group(key);
    
    BIGNUM *prv = BN_new();
    BN_bin2bn(privateKeyData.bytes, (int)privateKeyData.length, prv);
    
    EC_POINT *pub = EC_POINT_new(group);
    EC_POINT_mul(group, pub, prv, nil, nil, ctx);
    EC_KEY_set_private_key(key, prv);
    EC_KEY_set_public_key(key, pub);
    
    NSMutableData *result;
    if (isCompression) {
        EC_KEY_set_conv_form(key, POINT_CONVERSION_COMPRESSED);
        unsigned char *bytes = NULL;
        int length = i2o_ECPublicKey(key, &bytes);
        result = [NSMutableData dataWithBytesNoCopy:bytes length:length];
    } else {
        result = [NSMutableData dataWithLength:65];
        BIGNUM *n = BN_new();
        EC_POINT_point2bn(group, pub, POINT_CONVERSION_UNCOMPRESSED, n, ctx);
        BN_bn2bin(n, result.mutableBytes);
        BN_free(n);
    }
    
    BN_free(prv);
    EC_POINT_free(pub);
    EC_KEY_free(key);
    BN_CTX_free(ctx);
    
    return result;
}
    
+ (NSData *)sign:(NSData *)hash privateKey:(NSData *)privateKeyData isPubKeyCompressed:(BOOL)isPubKeyCompressed {
    BN_CTX *ctx = BN_CTX_new();
    EC_KEY *key = EC_KEY_new_by_curve_name(NID_secp256k1);
    const EC_GROUP *group = EC_KEY_get0_group(key);
    
    BIGNUM *prv = BN_new();
    BN_bin2bn(privateKeyData.bytes, (int)privateKeyData.length, prv);
    
    EC_POINT *pub = EC_POINT_new(group);
    EC_POINT_mul(group, pub, prv, nil, nil, ctx);
    EC_KEY_set_private_key(key, prv);
    EC_KEY_set_public_key(key, pub);
    
    NSMutableData* sigdata = [NSMutableData dataWithLength:65];
    unsigned char* sigbytes = sigdata.mutableBytes;
    const unsigned char* hashbytes = hash.bytes;
    int hashlength = (int)hash.length;
    
    int rec = -1;
    
    unsigned char *p64 = (sigbytes + 1); // first byte is reserved for header.
    
    ECDSA_SIG *sig = ECDSA_do_sign(hashbytes, hashlength, key);
    if (sig==NULL) {
        return nil;
    }
    memset(p64, 0, 64);
    int nBitsR = BN_num_bits(sig->r);
    int nBitsS = BN_num_bits(sig->s);
    if (nBitsR <= 256 && nBitsS <= 256) {
        NSData* pubkey = [Secp256k1 generatePublicKeyWithPrivateKey:privateKeyData compression:YES];
        BOOL foundMatchingPubkey = NO;
        for (int i=0; i < 4; i++) {
            // It will be updated via direct access to _key ivar.
            EC_KEY* key2 = EC_KEY_new_by_curve_name(NID_secp256k1);
            if (ECDSA_SIG_recover_key_GFp(key2, sig, hashbytes, hashlength, i, 1) == 1) {
                EC_KEY_set_conv_form(key2, POINT_CONVERSION_COMPRESSED);
                unsigned char *bytes = NULL;
                int length = i2o_ECPublicKey(key2, &bytes);
                NSData* pubkey2 = [NSMutableData dataWithBytesNoCopy:bytes length:length];
                if ([pubkey isEqual:pubkey2]) {
                    rec = i;
                    foundMatchingPubkey = YES;
                    break;
                }
            }
        }
        NSAssert(foundMatchingPubkey, @"At least one signature must work.");
        BN_bn2bin(sig->r,&p64[32-(nBitsR+7)/8]);
        BN_bn2bin(sig->s,&p64[64-(nBitsS+7)/8]);
    }
    ECDSA_SIG_free(sig);
    
    BN_free(prv);
    EC_POINT_free(pub);
    EC_KEY_free(key);
    BN_CTX_free(ctx);
    
    // First byte is a header
    sigbytes[0] = 0x1b + rec + (isPubKeyCompressed ? 4 : 0);
    return sigdata;
}

// Perform ECDSA key recovery (see SEC1 4.1.6) for curves over (mod p)-fields
// recid selects which key is recovered
// if check is non-zero, additional checks are performed
static int ECDSA_SIG_recover_key_GFp(EC_KEY *eckey, ECDSA_SIG *ecsig, const unsigned char *msg, int msglen, int recid, int check) {
    if (!eckey) return 0;
    
    int ret = 0;
    BN_CTX *ctx = NULL;
    
    BIGNUM *x = NULL;
    BIGNUM *e = NULL;
    BIGNUM *order = NULL;
    BIGNUM *sor = NULL;
    BIGNUM *eor = NULL;
    BIGNUM *field = NULL;
    EC_POINT *R = NULL;
    EC_POINT *O = NULL;
    EC_POINT *Q = NULL;
    BIGNUM *rr = NULL;
    BIGNUM *zero = NULL;
    int n = 0;
    int i = recid / 2;
    
    const EC_GROUP *group = EC_KEY_get0_group(eckey);
    if ((ctx = BN_CTX_new()) == NULL) { ret = -1; goto err; }
    BN_CTX_start(ctx);
    order = BN_CTX_get(ctx);
    if (!EC_GROUP_get_order(group, order, ctx)) { ret = -2; goto err; }
    x = BN_CTX_get(ctx);
    if (!BN_copy(x, order)) { ret=-1; goto err; }
    if (!BN_mul_word(x, i)) { ret=-1; goto err; }
    if (!BN_add(x, x, ecsig->r)) { ret=-1; goto err; }
    field = BN_CTX_get(ctx);
    if (!EC_GROUP_get_curve_GFp(group, field, NULL, NULL, ctx)) { ret=-2; goto err; }
    if (BN_cmp(x, field) >= 0) { ret=0; goto err; }
    if ((R = EC_POINT_new(group)) == NULL) { ret = -2; goto err; }
    if (!EC_POINT_set_compressed_coordinates_GFp(group, R, x, recid % 2, ctx)) { ret=0; goto err; }
    if (check) {
        if ((O = EC_POINT_new(group)) == NULL) { ret = -2; goto err; }
        if (!EC_POINT_mul(group, O, NULL, R, order, ctx)) { ret=-2; goto err; }
        if (!EC_POINT_is_at_infinity(group, O)) { ret = 0; goto err; }
    }
    if ((Q = EC_POINT_new(group)) == NULL) { ret = -2; goto err; }
    n = EC_GROUP_get_degree(group);
    e = BN_CTX_get(ctx);
    if (!BN_bin2bn(msg, msglen, e)) { ret=-1; goto err; }
    if (8*msglen > n) BN_rshift(e, e, 8-(n & 7));
    zero = BN_CTX_get(ctx);
    if (!BN_zero(zero)) { ret=-1; goto err; }
    if (!BN_mod_sub(e, zero, e, order, ctx)) { ret=-1; goto err; }
    rr = BN_CTX_get(ctx);
    if (!BN_mod_inverse(rr, ecsig->r, order, ctx)) { ret=-1; goto err; }
    sor = BN_CTX_get(ctx);
    if (!BN_mod_mul(sor, ecsig->s, rr, order, ctx)) { ret=-1; goto err; }
    eor = BN_CTX_get(ctx);
    if (!BN_mod_mul(eor, e, rr, order, ctx)) { ret=-1; goto err; }
    if (!EC_POINT_mul(group, Q, eor, R, sor, ctx)) { ret=-2; goto err; }
    if (!EC_KEY_set_public_key(eckey, Q)) { ret=-2; goto err; }
    
    ret = 1;
    
err:
    if (ctx) {
        BN_CTX_end(ctx);
        BN_CTX_free(ctx);
    }
    if (R != NULL) EC_POINT_free(R);
    if (O != NULL) EC_POINT_free(O);
    if (Q != NULL) EC_POINT_free(Q);
    return ret;
}

@end

@implementation PKCS5
+ (NSData *)PBKDF2:(NSData *)password salt:(NSData *)salt iterations:(NSInteger)iterations keyLength:(NSInteger)keyLength {
    NSMutableData *result = [NSMutableData dataWithLength:keyLength];
    PKCS5_PBKDF2_HMAC(password.bytes, (int)password.length, salt.bytes, (int)salt.length, (int)iterations, EVP_sha512(), (int)keyLength, result.mutableBytes);
    return result;
}
@end

@implementation KeyDerivation

- (instancetype)initWithPrivateKey:(NSData *)privateKey publicKey:(NSData *)publicKey chainCode:(NSData *)chainCode depth:(uint8_t)depth fingerprint:(uint32_t)fingerprint childIndex:(uint32_t)childIndex {
    self = [super init];
    if (self) {
        _privateKey = privateKey;
        _publicKey = publicKey;
        _chainCode = chainCode;
        _depth = depth;
        _fingerprint = fingerprint;
        _childIndex = childIndex;
    }
    return self;
}

- (KeyDerivation *)derivedAtIndex:(uint32_t)index hardened:(BOOL)hardened {
    BN_CTX *ctx = BN_CTX_new();
    
    NSMutableData *data = [NSMutableData data];
    if (hardened) {
        uint8_t padding = 0;
        [data appendBytes:&padding length:1];
        [data appendData:self.privateKey];
    } else {
        [data appendData:self.publicKey];
    }
    
    uint32_t childIndex = OSSwapHostToBigInt32(hardened ? (0x80000000 | index) : index);
    [data appendBytes:&childIndex length:sizeof(childIndex)];
    
    NSData *digest = [CryptoHash hmacsha512:data key:self.chainCode];
    NSData *derivedPrivateKey = [digest subdataWithRange:NSMakeRange(0, 32)];
    NSData *derivedChainCode = [digest subdataWithRange:NSMakeRange(32, 32)];
    
    BIGNUM *curveOrder = BN_new();
    BN_hex2bn(&curveOrder, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141");
    
    BIGNUM *factor = BN_new();
    BN_bin2bn(derivedPrivateKey.bytes, (int)derivedPrivateKey.length, factor);
    // Factor is too big, this derivation is invalid.
    if (BN_cmp(factor, curveOrder) >= 0) {
        return nil;
    }
    
    NSMutableData *result;
    if (self.privateKey) {
        BIGNUM *privateKey = BN_new();
        BN_bin2bn(self.privateKey.bytes, (int)self.privateKey.length, privateKey);
        
        BN_mod_add(privateKey, privateKey, factor, curveOrder, ctx);
        // Check for invalid derivation.
        if (BN_is_zero(privateKey)) {
            return nil;
        }
        
        int numBytes = BN_num_bytes(privateKey);
        result = [NSMutableData dataWithLength:numBytes];
        BN_bn2bin(privateKey, result.mutableBytes);
        
        BN_free(privateKey);
    } else {
        BIGNUM *publicKey = BN_new();
        BN_bin2bn(self.publicKey.bytes, (int)self.publicKey.length, publicKey);
        EC_GROUP *group = EC_GROUP_new_by_curve_name(NID_secp256k1);
        
        EC_POINT *point = EC_POINT_new(group);
        EC_POINT_bn2point(group, publicKey, point, ctx);
        EC_POINT_mul(group, point, factor, point, BN_value_one(), ctx);
        // Check for invalid derivation.
        if (EC_POINT_is_at_infinity(group, point) == 1) {
            return nil;
        }
        
        BIGNUM *n = BN_new();
        result = [NSMutableData dataWithLength:33];
        
        EC_POINT_point2bn(group, point, POINT_CONVERSION_COMPRESSED, n, ctx);
        BN_bn2bin(n, result.mutableBytes);
        
        BN_free(n);
        BN_free(publicKey);
        EC_POINT_free(point);
        EC_GROUP_free(group);
    }
    
    BN_free(factor);
    BN_free(curveOrder);
    BN_CTX_free(ctx);
    
    uint32_t *fingerPrint = (uint32_t *)[CryptoHash sha256ripemd160:self.publicKey].bytes;
    return [[KeyDerivation alloc] initWithPrivateKey:result publicKey:result chainCode:derivedChainCode depth:self.depth + 1 fingerprint:*fingerPrint childIndex:childIndex];
}
@end


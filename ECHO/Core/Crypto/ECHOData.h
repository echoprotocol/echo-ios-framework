// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.

#import <Foundation/Foundation.h>

// Change to 0 to disable code that requires OpenSSL (if you need some of these routines in your own project and you don't need OpenSSL)
#define ECHODataRequiresOpenSSL 1

// Securely overwrites memory buffer with a specified character.
void *ECHOSecureMemset(void *v, unsigned char c, size_t n);

// Securely overwrites string with zeros.
void ECHOSecureClearCString(char *s);

// Returns data with securely random bytes of the specified length. Uses /dev/random.
NSMutableData* ECHORandomDataWithLength(NSUInteger length);

// Returns random string with securely random bytes of the specified length. Uses /dev/random.
// Caller should use free() to release the memory occupied by the buffer.
void *ECHOCreateRandomBytesOfLength(size_t length);

// Returns data produced by flipping the coin as proposed by Dan Kaminsky:
// https://gist.github.com/PaulCapestany/6148566
NSData* ECHOCoinFlipDataWithLength(NSUInteger length);

// Creates data with zero-terminated string in UTF-8 encoding.
NSData* ECHODataWithUTF8CString(const char* utf8cstring);
NSData* ECHODataWithUTF8String(const char* utf8string) DEPRECATED_ATTRIBUTE; // will repurpose for NSString later.

// Init with hex string (lower- or uppercase, with optional 0x prefix)
NSData* ECHODataFromHex(NSString* hex);
NSData* ECHODataWithHexString(NSString* hexString) DEPRECATED_ATTRIBUTE;

// Init with zero-terminated hex string (lower- or uppercase, with optional 0x prefix)
NSData* ECHODataWithHexCString(const char* hexString);

// Converts data to a hex string
NSString* ECHOHexFromData(NSData* data);
NSString* ECHOUppercaseHexFromData(NSData* data); // more efficient than calling -uppercaseString on a lower-case result.

// Deprecated. Use ECHOHexFromData and ECHOUppercaseHexFromData instead.
NSString* ECHOHexStringFromData(NSData* data) DEPRECATED_ATTRIBUTE;
NSString* ECHOUppercaseHexStringFromData(NSData* data) DEPRECATED_ATTRIBUTE;

// Returns a copy of data with reversed byte order.
// This is useful in Bitcoin: things get reversed here and there all the time.
NSData* ECHOReversedData(NSData* data);

// Returns a reversed mutable copy so you wouldn't need to make another mutable copy from -reversedData
NSMutableData* ECHOReversedMutableData(NSData* data);

// Reverses byte order in the internal buffer of mutable data object.
void ECHODataReverse(NSMutableData* data);

// If NSData is NSMutableData clears contents of the data to prevent leaks through swapping or buffer-overflow attacks. Returns YES.
// If NSData is actually an immutable data, does nothing and returns NO.
BOOL ECHODataClear(NSData* data);

// Returns a subdata with a given range.
// If range is invalid, returns nil.
NSMutableData* ECHODataRange(NSData* data, NSRange range);

// Core hash functions that we need.
// If the argument is nil, returns nil.
NSMutableData* ECHOSHA1(NSData* data);
NSMutableData* ECHOSHA256(NSData* data);
NSMutableData* ECHOSHA512(NSData* data);
NSMutableData* ECHOSHA256Concat(NSData* data1, NSData* data2); // SHA256(data1 || data2)
NSMutableData* ECHOHash256(NSData* data); // == SHA256(SHA256(data)) (aka Hash() in BitcoinQT)
NSMutableData* ECHOHash256Concat(NSData* data1, NSData* data2);  // SHA256(SHA256(data1 || data2))

// Standard HMAC-SHA256 and HMAC-SHA512 functions.
NSMutableData* ECHOHMACSHA256(NSData* key, NSData* data);
NSMutableData* ECHOHMACSHA512(NSData* key, NSData* data);

#if ECHODataRequiresOpenSSL
// RIPEMD160 today is provided only by OpenSSL. SHA1 and SHA2 are provided by CommonCrypto framework.
NSMutableData* ECHORIPEMD160(NSData* data);
NSMutableData* ECHOHash160(NSData* data); // == RIPEMD160(SHA256(data)) (aka Hash160 in BitcoinQT)
#endif

// 160-bit zero string
NSMutableData* ECHOZero160(void);

// 256-bit zero string
NSMutableData* ECHOZero256(void);

// Pointer to a static array of zeros (256 bits long).
const unsigned char* ECHOZeroString256(void);


// Hashes input with salt using specified number of rounds and the minimum amount of memory (rounded up to a whole number of 256-bit blocks).
// Actual number of hash function computations is a number of rounds multiplied by a number of 256-bit blocks.
// So rounds=1 for 256 Mb of memory would mean 8M hash function calculations (8M blocks by 32 bytes to form 256 Mb total).
// Uses SHA256 as an internal hash function.
// Password and salt are hashed before being placed in the first block.
// The whole memory region is hashed after all rounds to generate the result.
// Based on proposal by Sergio Demian Lerner http://bitslog.files.wordpress.com/2013/12/memohash-v0-3.pdf
// Returns a mutable data, so you can cleanup the memory when needed.
NSMutableData* ECHOMemoryHardKDF256(NSData* password, NSData* salt, unsigned int rounds, unsigned int numberOfBytes);


// Hashes input with salt using specified number of rounds and the minimum amount of memory (rounded up to a whole number of 128-bit blocks)
NSMutableData* ECHOMemoryHardAESKDF(NSData* password, NSData* salt, unsigned int rounds, unsigned int numberOfBytes);

// Probabilistic memory-hard KDF with 256-bit output and only one difficulty parameter - amount of memory.
// Actual amount of memory is rounded to a whole number of 256-bit blocks.
// Uses SHA512 as internal hash function.
// Computational time is proportional to amount of memory.
// Brutefore with half the memory raises amount of hash computations quadratically.
NSMutableData* ECHOLocustKDF128(NSData* password, NSData* salt, unsigned int numberOfBytes);
NSMutableData* ECHOLocustKDF160(NSData* password, NSData* salt, unsigned int numberOfBytes);
NSMutableData* ECHOLocustKDF256(NSData* password, NSData* salt, unsigned int numberOfBytes);
NSMutableData* ECHOLocustKDF512(NSData* password, NSData* salt, unsigned int numberOfBytes);

// Makes arbitrary-length output.
NSMutableData* ECHOLocustKDF(NSData* password, NSData* salt, unsigned int numberOfBytes, unsigned int outputLength);

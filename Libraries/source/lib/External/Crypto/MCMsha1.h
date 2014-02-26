
// From http://www.mirrors.wiretapped.net/security/cryptography/hashes/sha1/sha1.c

#include <sys/attr.h>

typedef struct {
    u_int32_t state[5];
    u_int32_t count[2];
    u_int8_t buffer[64];
} SHA1_CTX;

extern void MCMSHA1Init(SHA1_CTX* context);
extern void MCMSHA1Update(SHA1_CTX* context, u_int8_t* data, u_int32_t len);
extern void MCMSHA1Final(u_int8_t digest[20], SHA1_CTX* context);
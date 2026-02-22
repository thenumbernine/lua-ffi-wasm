// this isn't a library to go alongside align.lua like test.lua and simple_test.lua use
// it's a stand-alone to verify that alignment matches
#include <stdio.h>
#include <stddef.h>
#include <stdint.h>

int main() {
	printf("offsetof(a) offsetof(b) sizeof()\n");	
	typedef struct S1 {
		uint8_t a;
		uint8_t b;
	} S1;
	printf("S1\t%ld\t%ld\t%ld\n", offsetof(S1, a), offsetof(S1, b), sizeof(S1));

	// alignof per field
	typedef struct S2 {
		uint8_t __attribute__((__aligned__(8))) a;
		uint8_t __attribute__((__aligned__(8))) b;
	} S2;
	printf("S2\t%ld\t%ld\t%ld\n", offsetof(S2, a), offsetof(S2, b), sizeof(S2));

	// alignof per composite field
	typedef struct S3 {
		uint8_t __attribute__((__aligned__(8))) a, b;
	} S3;
	printf("S3\t%ld\t%ld\t%ld\n", offsetof(S3, a), offsetof(S3, b), sizeof(S3));

	// alignof per field with expression
	typedef struct S4 {
		uint8_t __attribute__((__aligned__(sizeof(uint16_t)))) a;
		uint8_t __attribute__((__aligned__(sizeof(uint16_t)))) b;
	} S4;
	printf("S4\t%ld\t%ld\t%ld\n", offsetof(S4, a), offsetof(S4, b), sizeof(S4));

	// alignof per composite field
	typedef struct S5 {
		uint8_t __attribute__((__aligned__(sizeof(uint16_t)))) a, b;
	} S5;
	printf("S5\t%ld\t%ld\t%ld\n", offsetof(S5, a), offsetof(S5, b), sizeof(S5));
}

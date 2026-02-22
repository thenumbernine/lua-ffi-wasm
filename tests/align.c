// this isn't a library to go alongside align.lua like test.lua and simple_test.lua use
// it's a stand-alone to verify that alignment matches
#include <stdio.h>
#include <stddef.h>
#include <stdint.h>

int main() {
	
	typedef struct S1 {
		uint8_t a;
		uint8_t b;
	} S1;
	printf("offsetof(S1, a) %ld\n", offsetof(S1, a));
	printf("offsetof(S1, b) %ld\n", offsetof(S1, b));
	printf("sizeof(S1) %ld\n", sizeof(S1));
	printf("\n");

	// alignof per field
	typedef struct S2 {
		uint8_t __attribute__((__aligned__(8))) a;
		uint8_t __attribute__((__aligned__(8))) b;
	} S2;
	printf("offsetof(S2, a) %ld\n", offsetof(S2, a));
	printf("offsetof(S2, b) %ld\n", offsetof(S2, b));
	printf("sizeof(S2) %ld\n", sizeof(S2));
	printf("\n");

	// alignof per composite field
	typedef struct S3 {
		uint8_t __attribute__((__aligned__(8))) a, b;
	} S3;
	printf("offsetof(S3, a) %ld\n", offsetof(S3, a));
	printf("offsetof(S3, b) %ld\n", offsetof(S3, b));
	printf("sizeof(S3) %ld\n", sizeof(S3));
	printf("\n");

	// alignof per field with expression
	typedef struct S4 {
		uint8_t __attribute__((__aligned__(sizeof(uint16_t)))) a;
		uint8_t __attribute__((__aligned__(sizeof(uint16_t)))) b;
	} S4;
	printf("offsetof(S4, a) %ld\n", offsetof(S4, a));
	printf("offsetof(S4, b) %ld\n", offsetof(S4, b));
	printf("sizeof(S4) %ld\n", sizeof(S4));
	printf("\n");

	// alignof per composite field
	typedef struct S5 {
		uint8_t __attribute__((__aligned__(sizeof(uint16_t)))) a, b;
	} S5;
	printf("offsetof(S5, a) %ld\n", offsetof(S5, a));
	printf("offsetof(S5, b) %ld\n", offsetof(S5, b));
	printf("sizeof(S5) %ld\n", sizeof(S5));
	printf("\n");


}

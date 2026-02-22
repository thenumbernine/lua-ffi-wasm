#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

int var = 0;
void test() { var = 1; }

// testing that return works
uint8_t test_u8() { return 42; }
int8_t test_s8() { return -42; }
uint16_t test_u16() { return 345; }
int16_t test_s16() { return -345; }
uint32_t test_u32() { return 67890; }
int32_t test_s32() { return -67890; }
uint64_t test_u64() { return 0x123456789; }
int64_t test_s64() { return -0x123456789; }
float test_f32() { return -123; }
double test_f64() { return -123; }

void* test_vp() { 
	printf("in C, test_vp = %p\n", test_vp);
	return (void*)0xdeadbeef; 
}
void* test_vp2() { return test_vp2; }

// testing that void & single arguments works
void test_v_u8(uint8_t x) { var=(int)x+1; }
void test_v_s8(int8_t x) { var=(int)x+1; }
void test_v_u16(uint16_t x) { var=(int)x+1; }
void test_v_s16(int16_t x) { var=(int)x+1; }
void test_v_u32(uint32_t x) { var=(int)x+1; }
void test_v_s32(int32_t x) { var=(int)x+1; }
void test_v_u64(uint64_t x) { var=(int)x+1; }
void test_v_s64(int64_t x) { var=(int)x+1; }
void test_v_f32(float x) { var=(int)x+1; }
void test_v_f64(double x) { var=(int)x+1; }

// testing that return & single arguments works
uint8_t test_u8_u8(uint8_t x) { return x+1; }
int8_t test_s8_s8(int8_t x) { return x+1; }
uint16_t test_u16_u16(uint16_t x) { return x+1; }
int16_t test_s16_s16(int16_t x) { return x+1; }
uint32_t test_u32_u32(uint32_t x) { return x+1; }
int32_t test_s32_s32(int32_t x) { return x+1; }
uint64_t test_u64_u64(uint64_t x) { return x+1; }
int64_t test_s64_s64(int64_t x) { return x+1; }
float test_f32_f32(float x) { return x+1; }
double test_f64_f64(double x) { return x+1; }

void* test_vp_sz(size_t x) { return (uint8_t*)0xdeadbeef + x; }
char const * test_cp() { return "testing testing one two one two three"; }

// testing that return & double arguments works
uint8_t test_u8_u8_u8(uint8_t x, uint8_t y) { return x+y+1; }
int8_t test_s8_s8_s8(int8_t x, int8_t y) { return x+y+1; }
uint16_t test_u16_u16_u16(uint16_t x, uint16_t y) { return x+y+1; }
int16_t test_s16_s16_s16(int16_t x, int16_t y) { return x+y+1; }
uint32_t test_u32_u32_u32(uint32_t x, uint32_t y) { return x+y+1; }
int32_t test_s32_s32_s32(int32_t x, int32_t y) { return x+y+1; }
uint64_t test_u64_u64_u64(uint64_t x, uint64_t y) { return x+y+1; }
int64_t test_s64_s64_s64(int64_t x, int64_t y) { return x+y+1; }
float test_f32_f32_f32(float x, float y) { return x+y+1; }
double test_f64_f64_f64(double x, double y) { return x+y+1; }

void hidden_v() { var = 1357; }

typedef void (*VFP)();
VFP test_vfp() { return hidden_v; }
void test_v_vfp(VFP f) { f(); }
VFP test_vfp_vfp(VFP f) { 
	printf("in C, test_vfp_vfp got %p\n", f);
	return f; 
}

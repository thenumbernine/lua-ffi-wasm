-- I think their test.c / test.lua got too out of hand too quick
-- so here's me easing things more slowly ...
print'begin simple_test'
print"require 'ffi'"
ffi = require 'ffi'
print"local assert = require 'ext.assert'"
local assert = require 'ext.assert'

print"ffi.cdef[["
ffi.cdef[[

int var;
void test();

void* test_vp();
void* test_vp2();

uint8_t test_u8();
int8_t test_s8();
uint16_t test_u16();
int16_t test_s16();
uint32_t test_u32();
int32_t test_s32();
uint64_t test_u64();
int64_t test_s64();
float test_f32();
double test_f64();

void test_v_u8(uint8_t x);
void test_v_s8(int8_t x);
void test_v_u16(uint16_t x);
void test_v_s16(int16_t x);
void test_v_u32(uint32_t x);
void test_v_s32(int32_t x);
void test_v_u64(uint64_t x);
void test_v_s64(int64_t x);
void test_v_f32(float x);
void test_v_f64(double x);

uint8_t test_u8_u8(uint8_t x);
int8_t test_s8_s8(int8_t x);
uint16_t test_u16_u16(uint16_t x);
int16_t test_s16_s16(int16_t x);
uint32_t test_u32_u32(uint32_t x);
int32_t test_s32_s32(int32_t x);
uint64_t test_u64_u64(uint64_t x);
int64_t test_s64_s64(int64_t x);
float test_f32_f32(float x);
double test_f64_f64(double x);

void* test_vp_sz(size_t x);
char const * test_cp();

uint8_t test_u8_u8_u8(uint8_t x, uint8_t y);
int8_t test_s8_s8_s8(int8_t x, int8_t y);
uint16_t test_u16_u16_u16(uint16_t x, uint16_t y);
int16_t test_s16_s16_s16(int16_t x, int16_t y);
uint32_t test_u32_u32_u32(uint32_t x, uint32_t y);
int32_t test_s32_s32_s32(int32_t x, int32_t y);
uint64_t test_u64_u64_u64(uint64_t x, uint64_t y);
int64_t test_s64_s64_s64(int64_t x, int64_t y);
float test_f32_f32_f32(float x, float y);
double test_f64_f64_f64(double x, double y);

typedef void (*VFP)();
VFP test_vfp();
void test_v_vfp(VFP f);
VFP test_vfp_vfp(VFP f);

]]

local lib = ffi.load'./libsimple_test.so'

-- TODO assert that this errors, cuz it's not, but in luajit it is:
--ffi.new('void*', 0xdeadbeef)

lib.test_vp()
print('in Lua, test_vp = ', lib.test_vp)

local vp2 = lib.test_vfp_vfp(lib.test_vp)
print('in Lua, test_vfp_vfp(test_vp) = ', vp2)	-- TODO this has tostring() that is off by a bit ...
--print('calling the C function passed through another C function to see if it still works...')
vp2()
assert.eq(lib.test_vp, lib.test_vfp_vfp(lib.test_vp), 'is the passed-thru C-function equal the original?')

-- works
local vp_test_vp = ffi.cast('void*', lib.test_vp)
print('(void*)test_vp = ', vp_test_vp)
assert.eq(lib.test_vp, vp_test_vp, 'is test_vp == (void*)test_vp?')


for rep=1,50 do
print('!!!!!!!! BEGINNING REPEAT '..rep..' !!!!!!!!')
	-- how to test void() functions... state change

	lib.var = 0
	assert.eq(lib.var, 0)
	print'test'
	lib.test()
	assert.eq(lib.var, 1)

	-- testing return
	print'test_u8' assert.eq(lib.test_u8(), 42)
	print'test_s8' assert.eq(lib.test_s8(), -42)
	print'test_u16' assert.eq(lib.test_u16(), 345)
	print'test_s16' assert.eq(lib.test_s16(), -345)
	print'test_u32' assert.eq(lib.test_u32(), 67890)
	print'test_s32' assert.eq(lib.test_s32(), -67890)
	print'test_u64' assert.eq(lib.test_u64(), ffi.new('uint64_t', 0x123456789))
	print'test_s64' assert.eq(lib.test_s64(), ffi.new('int64_t', -0x123456789))
	print'test_f32' assert.eq(lib.test_f32(), -123)	-- at what point does this become testing floating point parsing accuracy ...
	print'test_f64' assert.eq(lib.test_f64(), -123)	-- at what point does this become testing floating point parsing accuracy ...

	print'test_vp' assert.eq(lib.test_vp(), ffi.cast('void*', 0xdeadbeef))
	
	-- testing return & single arguments
	print'test_v_u8' lib.test_v_u8(42) assert.eq(lib.var, 42+1)
	print'test_v_s8' lib.test_v_s8(-42) assert.eq(lib.var, -42+1)
	print'test_v_u16' lib.test_v_u16(345) assert.eq(lib.var, 345+1)
	print'test_v_s16' lib.test_v_s16(-345) assert.eq(lib.var, -345+1)
	print'test_v_u32' lib.test_v_u32(67890) assert.eq(lib.var, 67890+1)
	print'test_v_s32' lib.test_v_s32(-67890) assert.eq(lib.var, -67890+1)
	print'test_v_u64' lib.test_v_u64(ffi.new('uint64_t', 0x123456789)) assert.eq(lib.var, 0x23456789+1)
	print'test_v_s64' lib.test_v_s64(ffi.new('int64_t', -0x123456789)) assert.eq(lib.var, -0x23456789+1)
	print'test_v_f32' lib.test_v_f32(-123) assert.eq(lib.var, -123+1)	-- at what point does this become testing floating point parsing accuracy ...
	print'test_v_f64' lib.test_v_f64(-123) assert.eq(lib.var, -123+1)	-- at what point does this become testing floating point parsing accuracy ...


	-- testing return & single arguments
	print'test_u8_u8' assert.eq(lib.test_u8_u8(42), 42+1)
	print'test_s8_s8' assert.eq(lib.test_s8_s8(-42), -42+1)
	print'test_u16_u16' assert.eq(lib.test_u16_u16(345), 345+1)
	print'test_s16_s16' assert.eq(lib.test_s16_s16(-345), -345+1)
	print'test_u32_u32' assert.eq(lib.test_u32_u32(67890), 67890+1)
	print'test_s32_s32' assert.eq(lib.test_s32_s32(-67890), -67890+1)
	print'test_u64_u64' assert.eq(lib.test_u64_u64(ffi.new('uint64_t', 0x123456789)), ffi.new('uint64_t', 0x123456789)+1)
	print'test_s64_s64' assert.eq(lib.test_s64_s64(ffi.new('int64_t', -0x123456789)), ffi.new('int64_t', -0x123456789)+1)
	print'test_f32_f32' assert.eq(lib.test_f32_f32(-123), -123+1)	-- at what point does this become testing floating point parsing accuracy ...
	print'test_f64_f64' assert.eq(lib.test_f64_f64(-123), -123+1)	-- at what point does this become testing floating point parsing accuracy ...

	print'test_vp_sz' assert.eq(lib.test_vp_sz(64), ffi.cast('void*', 0xdeadbeef + 64))
	print'test_cp' assert.eq(ffi.string(lib.test_cp()), "testing testing one two one two three")

	-- testing return & double arguments
	print'test_u8_u8_u8' assert.eq(lib.test_u8_u8_u8(42, 42), (42)+(42)+1)
	print'test_s8_s8_s8' assert.eq(lib.test_s8_s8_s8(-42, -42), (-42)+(-42)+1)
	print'test_u16_u16_u16' assert.eq(lib.test_u16_u16_u16(345, 345), (345)+(345)+1)
	print'test_s16_s16_s16' assert.eq(lib.test_s16_s16_s16(-345, -345), (-345)+(-345)+1)
	print'test_u32_u32_u32' assert.eq(lib.test_u32_u32_u32(67890, 67890), (67890)+(67890)+1)
	print'test_s32_s32_s32' assert.eq(lib.test_s32_s32_s32(-67890, -67890), (-67890)+(-67890)+1)
	print'test_u64_u64_u64' assert.eq(lib.test_u64_u64_u64(ffi.new('uint64_t', 0x123456789), ffi.new('uint64_t', 0x123456789)), ffi.new('uint64_t', (0x123456789)+(0x123456789)+1))
	print'test_s64_s64_s64' assert.eq(lib.test_s64_s64_s64(ffi.new('int64_t', -0x123456789), ffi.new('int64_t', -0x123456789)), ffi.new('int64_t', (-0x123456789)+(-0x123456789)+1))
	print'test_f32_f32_f32' assert.eq(lib.test_f32_f32_f32(-123, -123), (-123)+(-123)+1)	-- at what point does this become testing floating point parsing accuracy ...
	print'test_f64_f64_f64' assert.eq(lib.test_f64_f64_f64(-123, -123), (-123)+(-123)+1)	-- at what point does this become testing floating point parsing accuracy ...
end

--[[ tesing callbacks
print'test_v_vfp' 
local works = 0
assert.eq(works, 0, 'test_v_vfp')
local fp = ffi.cast('void(*)()', function() works=1 end)
lib.test_v_vfp(fp)
assert.eq(works, 1, 'test_v_vfp')

local fp2 = lib.test_vfp_vfp(fp)
works = 0 assert.eq(works, 0, 'test_v_vfp')
fp2() assert.eq(works, 1, 'test_v_vfp')

fp:free()
--]]

-- This test works for function-pointers returned from C code
lib.var = 0
print'test_vfp'
lib.test_vfp()();
assert.eq(lib.var, 1357)

--[[ TODO FIXME casting C functions to cdata<void*> gives "unable to convert argument 2 from lua<function> to cdata<pointer>" from ffi.c type_error()
-- But in luajit it works
-- Because in our current implementation we are converting the C function to a lua_CFunction that's being called
-- To get this to work, we need to return CData of the C function and do this all in cdata_call ...
print'test_vp2' assert.eq(lib.test_vp2(), ffi.cast('void*', lib.test_vp2))	-- TODO can't
--]]

-- how do we invoke cdata_call ?!?!?!
ffi.cdef[[ typedef struct A { int a; } A; ]]
local mt = ffi.metatype('A', { __call = function() return 42 end})
assert.eq(ffi.new'A'(), 42)

print'DONE!'

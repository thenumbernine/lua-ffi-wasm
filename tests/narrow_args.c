#include <stdint.h>

// Narrow integers through libffi's ffi_arg-sized slots.
// libffi widens anything narrower than ffi_arg into exactly one slot, and
// returns and closure arguments go through the same conversion in
// luaffifb's callValuePush, so both directions are here.

// returns
int8_t   ret_s8 (void) { return -42; }
int16_t  ret_s16(void) { return -345; }
int32_t  ret_s32(void) { return -67890; }
uint32_t ret_u32(void) { return 4294967295u; }
int32_t  sum3_s32(int32_t a, int32_t b, int32_t c) { return a + b + c; }

// closure arguments: hand x to the callback, hand back whatever it returns,
// so a wrong value can only have come from the marshalling
int8_t   cb_s8 (int8_t   (*cb)(int8_t  ), int8_t   x) { return cb(x); }
int16_t  cb_s16(int16_t  (*cb)(int16_t ), int16_t  x) { return cb(x); }
int32_t  cb_s32(int32_t  (*cb)(int32_t ), int32_t  x) { return cb(x); }
uint32_t cb_u32(uint32_t (*cb)(uint32_t), uint32_t x) { return cb(x); }

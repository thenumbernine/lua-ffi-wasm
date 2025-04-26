#include <stdio.h>
#include <dlfcn.h>

void main_foo() {
	printf("main_foo() works\n");
}
typedef void (*pfn_main_foo)();

typedef int (*pfn_side_foo)(int a);
int main() {
#if 0	// static linking works	
	int side_foo(int a);
#endif
#if 1	// dlopen?
	printf("flags: %d\n", RTLD_LAZY | RTLD_GLOBAL);
	void * handle = dlopen(NULL, RTLD_LAZY | RTLD_GLOBAL);
	printf("handle: %p\n", handle);
	pfn_side_foo side_foo = (pfn_side_foo)dlsym(handle, "side_foo");
	printf("side_foo: %p\n", side_foo);
#endif
    
	// does dlopen work on main module functions?
	// yes, yes it does
	pfn_main_foo main_foo_ptr = (pfn_main_foo )dlsym(handle, "main_foo");
	printf("main_foo_ptr: %p\n", main_foo_ptr);

	printf("hello world %d\n", side_foo(1));
}

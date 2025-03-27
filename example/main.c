#include <stdio.h>
#include <dlfcn.h>

typedef int (*pfn_side)(int a);
int main() {
#if 0	// static linking works	
	int side(int a);
#endif
#if 1	// dlopen?
	printf("flags: %d\n", RTLD_LAZY | RTLD_GLOBAL);
	void * handle = dlopen(NULL, RTLD_LAZY | RTLD_GLOBAL);
	printf("handle: %p\n", handle);
	pfn_side side = (pfn_side)dlsym(handle, "side");
	printf("side: %p\n", side);
#endif
    printf("hello world %d\n", side(1));
}

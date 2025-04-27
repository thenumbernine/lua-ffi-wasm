#include <stdio.h>
extern "C" int static_link_to_main() {
	printf("hello world\n");
	return 42;
}

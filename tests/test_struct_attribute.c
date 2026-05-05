// packed, named struct
struct __attribute__((packed)) A {
	int a;
	char b;
	double c;
};

int main() {
	struct A a;

	// packed, anonymous, inline struct
	struct __attribute__((packed)) {
		int a;
		char b;
		double c;
	} b;
}

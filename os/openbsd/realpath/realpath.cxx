#include <iostream>
#include <memory>

#include <climits>
#include <cstdlib>
#include <cstdio>

struct c_free {
    void
    operator()(void* mem) const noexcept {
        std::free(mem);
    }
};

int
main(int argc, char** argv) {
    for (int i = 1; i < argc; ++i) {
        auto real = std::unique_ptr<char, c_free>(realpath(argv[i], nullptr));

        if (!real) {
            perror("realpath");
            continue;
        }
        std::cout << real.get() << '\n';
    }
}

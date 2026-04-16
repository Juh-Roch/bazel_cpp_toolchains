#include <iostream>
#include <pthread.h>

void* say_hello(void* arg) {
    std::cout << "Hello from thread!" << std::endl;
    return nullptr;
}

int main() {
    pthread_t thread;

    if (pthread_create(&thread, nullptr, say_hello, nullptr) != 0) {
        std::cerr << "Error creating thread" << std::endl;
        return 1;
    }

    if (pthread_join(thread, nullptr) != 0) {
        std::cerr << "Error joining thread" << std::endl;
        return 2;
    }

    std::cout << "Hello from main!" << std::endl;
    return 0;
}

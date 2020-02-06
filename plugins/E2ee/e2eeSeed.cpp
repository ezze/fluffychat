#include "e2eeSeed.h"

#include <ctime>    // For time()
#include <cstdlib>  // For srand() and rand()
#include <cstring>

E2eeSeed::E2eeSeed(size_t len) {
    m_random.reserve(len);
    srand(time(0));  // Initialize random number generator.
    for (unsigned int i = 0; i<len; i++) {
        m_random.push_back(static_cast<uint8_t>(rand() % 256));
    }
}

uint8_t * E2eeSeed::random() {
    return m_random.data();
}

size_t E2eeSeed::length() const {
    return m_random.size();
}

E2eeSeed::~E2eeSeed() {
    memset(m_random.data(), '0', m_random.size()); // Set the allocated memory in ram to 0 everywhere
}

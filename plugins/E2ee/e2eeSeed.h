#ifndef _E2EESEED_H_
#define _E2EESEED_H_

#include <cstddef>
#include <cstdint>
#include <vector>

class E2eeSeed {

public:
    E2eeSeed(size_t length);
    virtual ~E2eeSeed();
    uint8_t * random();
    size_t length() const;

private:
    std::vector<uint8_t> m_random;
};

#endif

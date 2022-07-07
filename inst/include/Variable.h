 /*
 *  Variable.h
 *  Created on: 18 May 2020
 *      Author: gc1610
 */

#ifndef INST_INCLUDE_VARIABLE_H_
#define INST_INCLUDE_VARIABLE_H_

#include <cstddef>

struct Variable {
    virtual void update() = 0;
    virtual void resize() = 0;
    virtual size_t size() const = 0;
    virtual ~Variable() = default;
};

#endif /* INST_INCLUDE_VARIABLE_H_ */

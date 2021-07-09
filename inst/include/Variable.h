 /*
 *  Variable.h
 *  Created on: 18 May 2020
 *      Author: gc1610
 */

#ifndef INST_INCLUDE_VARIABLE_H_
#define INST_INCLUDE_VARIABLE_H_

struct Variable {
    virtual void update() = 0;
    virtual ~Variable() {};
};

#endif /* INST_INCLUDE_VARIABLE_H_ */

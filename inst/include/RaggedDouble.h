/*
 * RaggedDouble.h
 *
 *  Created on: 7 Jul 2022
 *      Author: slwu89
 */

#ifndef INST_INCLUDE_RAGGED_DOUBLE_H_
#define INST_INCLUDE_RAGGED_DOUBLE_H_

#include "RaggedVariable.h"

struct RaggedDouble;


//' @title A variable class for ragged double arrays
//' @description This class is inherits from RaggedVariable
struct RaggedDouble : public RaggedVariable<double> {
  RaggedDouble(const std::vector<std::vector<double>>& values);
  virtual ~RaggedDouble() = default;
};

inline RaggedDouble::RaggedDouble(const std::vector<std::vector<double>>& values)
  : RaggedVariable<double>(values) {}


#endif
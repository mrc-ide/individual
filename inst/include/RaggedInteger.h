/*
 * RaggedInteger.h
 *
 *  Created on: 7 Jul 2022
 *      Author: slwu89
 */

#ifndef INST_INCLUDE_RAGGED_INTEGER_H_
#define INST_INCLUDE_RAGGED_INTEGER_H_

#include "RaggedVariable.h"

struct RaggedInteger;


//' @title A variable class for ragged integer arrays
//' @description This class is inherits from RaggedVariable
struct RaggedInteger : public RaggedVariable<int> {
  RaggedInteger(const std::vector<std::vector<int>>& values);
  virtual ~RaggedInteger() = default;
};

inline RaggedInteger::RaggedInteger(const std::vector<std::vector<int>>& values)
  : RaggedVariable<int>(values) {}


#endif
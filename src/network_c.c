/*
 * network_c.c
 *
 *  Created on: 27 Apr 2021
 *      Author: slwu89
 */

#include "network_c.h"

#include <network.h>
#include <netregistration.h>

// call before calling anything else in this header
void register_functions_C() {
  
  netRegisterFunctions();
  
};


SEXP get_out_neighborhood_C(SEXP g, int v) {

  return netGetNeighborhood(g, v, "out", 1);

}
/*
 * network_c.c
 *
 *  Created on: 27 Apr 2021
 *      Author: slwu89
 */

#include "network_c.h"

#include <network.h>
#include <netregistration.h>

SEXP get_out_neighborhood_C(SEXP g, int v) {

  netRegisterFunctions(); // maybe move this to a seperate fn and call from C++ once?

  return netGetNeighborhood(g, v, "out", 1);

}
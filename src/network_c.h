/*
 * network.h
 *
 *  Created on: 27 Apr 2021
 *      Author: slwu89
 */

#ifndef NETWORK_H_
#define NETWORK_H_

#include <Rinternals.h>

// get out neighborhood of a vertex v in a graph g
SEXP get_out_neighborhood_C(SEXP g, int v);

#endif
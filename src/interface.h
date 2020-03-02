/*
 * SimulationFrameR.h
 *
 *  Created on: 14 Feb 2020
 *      Author: giovanni
 */

#ifndef SRC_INTERFACE_R_INTERFACE_H_
#define SRC_INTERFACE_R_INTERFACE_H_

#include <Rcpp.h>

using namespace Rcpp;
using namespace std;

//' @export Individual
class Individual {
	string name;
public:
	Individual(string, List, List, List);
	string get_name();
};

//' @export State
class State {
	string name;
public:
	State(string, int);
	string get_name();
};

//' @export SimulationFrame
class SimulationFrame {
public:
	SimulationFrame(List, List, List, List);
	IntegerVector get_state(Individual, State);
	NumericVector get_variable(Individual, State);
};


#endif /* SRC_INTERFACE_R_INTERFACE_H_ */

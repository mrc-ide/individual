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

class SimulationFrame {
    List individuals;
    List states;
    List constants;
    List variables;
public:
    SimulationFrame(List, List, List, List);
    vector<unsigned int> get_state(string, vector<string>);
    NumericVector get_variable(string, string);
};


#endif /* SRC_INTERFACE_R_INTERFACE_H_ */

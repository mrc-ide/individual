/*
 * SimulationFrame.h
 *
 *  Created on: 14 Feb 2020
 *      Author: giovanni
 */

#ifndef SRC_STATE_CPP_API_H_
#define SRC_STATE_CPP_API_H_

#include "types.h"

class StateCppAPI {
    std::shared_ptr<const states_t> states;
    std::shared_ptr<const variables_t> variables;
public:
    StateCppAPI(std::shared_ptr<const states_t>, std::shared_ptr<const variables_t>);
    individual_index_t& get_state(std::string, std::vector<std::string>) const;
    variable_vector_t& get_variable(std::string, std::string) const;
};

#endif /* SRC_STATE_CPP_API_H_ */

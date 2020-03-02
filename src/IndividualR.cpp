/*
 * IndividualR.cpp
 *
 *  Created on: 2 Mar 2020
 *      Author: giovanni
 */

#include "interface.h"

Individual::Individual(string name, List states, List variables, List constants) : name(name) {}

string Individual::get_name() {
	return this->name;
}

State::State(string name, int initial_size) : name(name) {}

string State::get_name() {
	return this->name;
}

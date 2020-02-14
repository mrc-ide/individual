/*
 * Update.h
 *
 *  Created on: 14 Feb 2020
 *      Author: giovanni
 */

#ifndef SRC_UPDATE_H_
#define SRC_UPDATE_H_

class Update {
public:
	Update();
};

class VariableUpdate: public Update {
public:
	VariableUpdate();
};

class StateUpdate: public Update {
public:
	StateUpdate();
};

#endif /* SRC_UPDATE_H_ */

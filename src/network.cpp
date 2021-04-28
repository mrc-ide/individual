/*
 * network.cpp
 *
 *  Created on: 27 Apr 2021
 *      Author: slwu89
 */


#include <Rcpp.h>
#include "../inst/include/common_types.h"
#include "../inst/include/IntegerVariable.h"
#include "utils.h"

#ifdef __cplusplus
extern "C" {
#endif
  
#include "network_c.h"
  
#ifdef __cplusplus
}
#endif

// [[Rcpp::export]]
void network_get_contacts(
    SEXP g, 
    Rcpp::XPtr<IntegerVariable> contacts,
    Rcpp::XPtr<individual_index_t> S,
    Rcpp::XPtr<individual_index_t> I
) {
  
    // zero out contacts
    std::fill(contacts->values.begin(), contacts->values.end(), 0);
  
    // exit early if no individuals
    if (I->size() < 1 || S->size() < 1) {
        return;
    }

    // for each infected find their contacts with susceptibles
    for (auto i : *I) {

        // i's contacts (network C API assumes vertex IDs start at 1)
        Rcpp::IntegerVector v = get_out_neighborhood_C(g, i+1);
        decrement(v);

        // for those contacts v who are in S, add to their contacts
        for (auto i : v) {
            if (S->exists_safe(i)) {
                contacts->values.at(i) += 1;
            }
        }

    }

}
/*
 * bitset.cpp
 *
 *  Created on: 05 January 2021
 *      Author: gc1610
 */


#include <Rcpp.h>
#include "../inst/include/common_types.h"
#include "utils.h"

//[[Rcpp::export]]
Rcpp::XPtr<individual_index_t> create_bitset(size_t size) {
    return Rcpp::XPtr<individual_index_t>(new individual_index_t(size), true);
}


//[[Rcpp::export]]
Rcpp::XPtr<individual_index_t> bitset_copy(
    const Rcpp::XPtr<individual_index_t> b
    ) {
    return Rcpp::XPtr<individual_index_t>(new individual_index_t(*b), true);
}

//[[Rcpp::export]]
void bitset_insert(
    const Rcpp::XPtr<individual_index_t> b,
    std::vector<size_t> v
    ) {
    decrement(v);
    b->insert_safe(v.cbegin(), v.cend());
}

//[[Rcpp::export]]
void bitset_remove(
    const Rcpp::XPtr<individual_index_t> b,
    std::vector<size_t> v
    ) {
    decrement(v);
    for (auto value : v)
        b->erase(value);
}

//[[Rcpp::export]]
size_t bitset_size(const Rcpp::XPtr<individual_index_t> b) {
    return b->size();
}

//[[Rcpp::export]]
size_t bitset_max_size(const Rcpp::XPtr<individual_index_t> b) {
    return b->max_size();
}

//[[Rcpp::export]]
void bitset_and(
    const Rcpp::XPtr<individual_index_t> a,
    const Rcpp::XPtr<individual_index_t> b
    ) {
    (*a) &= (*b);
}

//[[Rcpp::export]]
Rcpp::XPtr<individual_index_t> bitset_not(
    const Rcpp::XPtr<individual_index_t> b
    ) {
    return Rcpp::XPtr<individual_index_t>(new individual_index_t(~(*b)), true);
}

//[[Rcpp::export]]
void bitset_or(
    const Rcpp::XPtr<individual_index_t> a,
    const Rcpp::XPtr<individual_index_t> b
    ) {
    (*a) |= (*b);
}

//[[Rcpp::export]]
void bitset_sample(
    const Rcpp::XPtr<individual_index_t> b,
    double rate
    ) {
    auto to_remove = Rcpp::sample(
      b->size(),
      Rcpp::rbinom(1, b->size(), 1 - std::min(rate, 1.))[0],
      false, // replacement
      R_NilValue, // evenly distributed
      false // one based
    );
    std::sort(to_remove.begin(), to_remove.end());
    auto bitset_i = 0u;
    auto bitset_it = b->cbegin();
    for (auto i : to_remove) {
      while(bitset_i != i) {
        ++bitset_i;
        ++bitset_it;
      }
      b->erase(*bitset_it);
      ++bitset_i;
      ++bitset_it;
    }
}

//[[Rcpp::export]]
std::vector<size_t> bitset_to_vector(const Rcpp::XPtr<individual_index_t> b) {
    auto result = std::vector<size_t>(b->size());
    auto i = 0u;
    for (auto v : *b) {
        result[i] = v + 1;
        ++i;
    }
    return result;
}

//[[Rcpp::export]]
Rcpp::XPtr<individual_index_t> filter_bitset_vector(
    const Rcpp::XPtr<individual_index_t> b,
    std::vector<size_t> other
    ) {
    decrement(other);
    return Rcpp::XPtr<individual_index_t>(
        new individual_index_t(
            filter_bitset(
                *b,
                std::cbegin(other),
                std::cend(other)
            )
        ),
        true
    );
}

//[[Rcpp::export]]
Rcpp::XPtr<individual_index_t> filter_bitset_bitset(
    const Rcpp::XPtr<individual_index_t> b,
    const Rcpp::XPtr<individual_index_t> other
    ) {
    return Rcpp::XPtr<individual_index_t>(
        new individual_index_t(
            filter_bitset(
                *b,
                std::cbegin(*other),
                std::cend(*other)
            )
        ),
        true
    );
}

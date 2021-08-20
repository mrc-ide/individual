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
    const Rcpp::XPtr<individual_index_t> b,
    const bool inplace
    ) {
    if (inplace) {
        b->inverse();
        return b;
    }
    return Rcpp::XPtr<individual_index_t>(
        new individual_index_t(!(*b)),
        true
    );
}

//[[Rcpp::export]]
void bitset_or(
    const Rcpp::XPtr<individual_index_t> a,
    const Rcpp::XPtr<individual_index_t> b
    ) {
    (*a) |= (*b);
}

//[[Rcpp::export]]
void bitset_xor(
    const Rcpp::XPtr<individual_index_t> a,
    const Rcpp::XPtr<individual_index_t> b
    ) {
    (*a) ^= (*b);
}

//[[Rcpp::export]]
void bitset_set_difference(
    const Rcpp::XPtr<individual_index_t> a,
    const Rcpp::XPtr<individual_index_t> b
    ) {
    (*a) &= !(*b);
}

//[[Rcpp::export]]
void bitset_sample(
    const Rcpp::XPtr<individual_index_t> b,
    double rate
    ) {
    bitset_sample_internal(*b.get(), rate);
}

//[[Rcpp::export]]
void bitset_sample_vector(
    const Rcpp::XPtr<individual_index_t> b,
    const std::vector<double> rate
    ) {
    if(b->size() != rate.size()){
        Rcpp::stop("vector of probabilties must equal the size of the bitset");
    }
    bitset_sample_multi_internal(*b.get(), rate.begin(), rate.end());
}

//[[Rcpp::export]]
std::vector<size_t> bitset_to_vector(const Rcpp::XPtr<individual_index_t> b) {
    return bitset_to_vector_internal(*b);
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

//[[Rcpp::export]]
void bitset_choose(
        const Rcpp::XPtr<individual_index_t> b,
        const size_t k
) {
    bitset_choose_internal(*b, k);
}

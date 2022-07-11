/*
 * ragged_integer.cpp
 *
 *  Created on: 7 Jul 2022
 *      Author: slwu89
 */


#include "../inst/include/RaggedInteger.h"
#include "utils.h"

//[[Rcpp::export]]
Rcpp::XPtr<RaggedInteger> create_integer_ragged_variable(
    const std::vector<std::vector<int>>& values
) {
  return Rcpp::XPtr<RaggedInteger>(
    new RaggedInteger(values),
    true
  );
}

// [[Rcpp::export]]
std::vector<std::vector<int>> integer_ragged_variable_get_values(
    Rcpp::XPtr<RaggedInteger> variable
) {
  return variable->get_values();
}

// [[Rcpp::export]]
std::vector<std::vector<int>> integer_ragged_variable_get_values_at_index_bitset(
    Rcpp::XPtr<RaggedInteger> variable,
    Rcpp::XPtr<individual_index_t> index
) {
  return variable->get_values(*index);
}

// [[Rcpp::export]]
std::vector<std::vector<int>> integer_ragged_variable_get_values_at_index_vector(
    Rcpp::XPtr<RaggedInteger> variable,
    std::vector<size_t> index
) {
  decrement(index);
  return variable->get_values(index);
}

// [[Rcpp::export]]
std::vector<size_t> integer_ragged_variable_get_length(
    Rcpp::XPtr<RaggedInteger> variable
) {
  return variable->get_length();
}

// [[Rcpp::export]]
std::vector<size_t> integer_ragged_variable_get_length_at_index_bitset(
    Rcpp::XPtr<RaggedInteger> variable,
    Rcpp::XPtr<individual_index_t> index
) {
  return variable->get_length(*index);
}

// [[Rcpp::export]]
std::vector<size_t> integer_ragged_variable_get_length_at_index_vector(
    Rcpp::XPtr<RaggedInteger> variable,
    std::vector<size_t> index
) {
  decrement(index);
  return variable->get_length(index);
}

//[[Rcpp::export]]
void integer_ragged_variable_queue_fill(
    Rcpp::XPtr<RaggedInteger> variable,
    const std::vector<std::vector<int>>& value
) {
  variable->queue_update(value, std::vector<size_t>());
}

//[[Rcpp::export]]
void integer_ragged_variable_queue_update(
    Rcpp::XPtr<RaggedInteger> variable,
    const std::vector<std::vector<int>>& value,
    std::vector<size_t> index
) {
  decrement(index);
  variable->queue_update(value, index);
}

//[[Rcpp::export]]
void integer_ragged_variable_queue_update_bitset(
    Rcpp::XPtr<RaggedInteger> variable,
    const std::vector<std::vector<int>> value,
    Rcpp::XPtr<individual_index_t> index
) {
  if (index->max_size() != variable->size()) {
    Rcpp::stop("incompatible size bitset used to queue update for RaggedInteger");
  }
  auto index_vec = bitset_to_vector_internal(*index, false);
  variable->queue_update(value, index_vec);
}

//[[Rcpp::export]]
void integer_ragged_variable_queue_extend(
    Rcpp::XPtr<RaggedInteger> variable,
    std::vector<std::vector<int>>& values
) {
  variable->queue_extend(values);
}

//[[Rcpp::export]]
void integer_ragged_variable_queue_shrink(
    Rcpp::XPtr<RaggedInteger> variable,
    std::vector<size_t>& index
) {
  decrement(index);
  variable->queue_shrink(index);
}

//[[Rcpp::export]]
void integer_ragged_variable_queue_shrink_bitset(
    Rcpp::XPtr<RaggedInteger> variable,
    Rcpp::XPtr<individual_index_t> index
) {
  variable->queue_shrink(*index);
}

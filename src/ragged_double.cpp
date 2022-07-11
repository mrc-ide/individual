/*
 * ragged_double.cpp
 *
 *  Created on: 7 Jul 2022
 *      Author: slwu89
 */


#include "../inst/include/RaggedDouble.h"
#include "utils.h"

//[[Rcpp::export]]
Rcpp::XPtr<RaggedDouble> create_double_ragged_variable(
    const std::vector<std::vector<double>>& values
) {
  return Rcpp::XPtr<RaggedDouble>(
    new RaggedDouble(values),
    true
  );
}

// [[Rcpp::export]]
std::vector<std::vector<double>> double_ragged_variable_get_values(
    Rcpp::XPtr<RaggedDouble> variable
) {
  return variable->get_values();
}

// [[Rcpp::export]]
std::vector<std::vector<double>> double_ragged_variable_get_values_at_index_bitset(
    Rcpp::XPtr<RaggedDouble> variable,
    Rcpp::XPtr<individual_index_t> index
) {
  return variable->get_values(*index);
}

// [[Rcpp::export]]
std::vector<std::vector<double>> double_ragged_variable_get_values_at_index_vector(
    Rcpp::XPtr<RaggedDouble> variable,
    std::vector<size_t> index
) {
  decrement(index);
  return variable->get_values(index);
}

// [[Rcpp::export]]
std::vector<size_t> double_ragged_variable_get_length(
    Rcpp::XPtr<RaggedDouble> variable
) {
  return variable->get_length();
}

// [[Rcpp::export]]
std::vector<size_t> double_ragged_variable_get_length_at_index_bitset(
    Rcpp::XPtr<RaggedDouble> variable,
    Rcpp::XPtr<individual_index_t> index
) {
  return variable->get_length(*index);
}

// [[Rcpp::export]]
std::vector<size_t> double_ragged_variable_get_length_at_index_vector(
    Rcpp::XPtr<RaggedDouble> variable,
    std::vector<size_t> index
) {
  decrement(index);
  return variable->get_length(index);
}

//[[Rcpp::export]]
void double_ragged_variable_queue_fill(
    Rcpp::XPtr<RaggedDouble> variable,
    const std::vector<std::vector<double>>& value
) {
  variable->queue_update(value, std::vector<size_t>());
}

//[[Rcpp::export]]
void double_ragged_variable_queue_update(
    Rcpp::XPtr<RaggedDouble> variable,
    const std::vector<std::vector<double>>& value,
    std::vector<size_t> index
) {
  decrement(index);
  variable->queue_update(value, index);
}

//[[Rcpp::export]]
void double_ragged_variable_queue_update_bitset(
    Rcpp::XPtr<RaggedDouble> variable,
    const std::vector<std::vector<double>> value,
    Rcpp::XPtr<individual_index_t> index
) {
  if (index->max_size() != variable->size()) {
    Rcpp::stop("incompatible size bitset used to queue update for RaggedDouble");
  }
  auto index_vec = bitset_to_vector_internal(*index, false);
  variable->queue_update(value, index_vec);
}

//[[Rcpp::export]]
void double_ragged_variable_queue_extend(
    Rcpp::XPtr<RaggedDouble> variable,
    std::vector<std::vector<double>>& values
) {
  variable->queue_extend(values);
}

//[[Rcpp::export]]
void double_ragged_variable_queue_shrink(
    Rcpp::XPtr<RaggedDouble> variable,
    std::vector<size_t>& index
) {
  decrement(index);
  variable->queue_shrink(index);
}

//[[Rcpp::export]]
void double_ragged_variable_queue_shrink_bitset(
    Rcpp::XPtr<RaggedDouble> variable,
    Rcpp::XPtr<individual_index_t> index
) {
  variable->queue_shrink(*index);
}

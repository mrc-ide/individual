/*
 * state.cpp -> variable.cpp
 *
 *  Created on: 19 May 2020
 *      Author: gc1610
 */


#include "../inst/include/ResizeableDoubleVariable.h"
#include "utils.h"

//[[Rcpp::export]]
Rcpp::XPtr<ResizeableDoubleVariable> create_resizeable_double_variable(
    const std::vector<double>& values
    ) {
    return Rcpp::XPtr<ResizeableDoubleVariable>(
        new ResizeableDoubleVariable(values),
        true
    );
}

//[[Rcpp::export]]
std::vector<double> resizeable_double_variable_get_values(
    Rcpp::XPtr<ResizeableDoubleVariable> variable
    ) {
    const auto& values = variable->get_values();
    return std::vector<double>(std::cbegin(values), std::cend(values));
}

//[[Rcpp::export]]
std::vector<double> resizeable_double_variable_get_values_at_index(
    Rcpp::XPtr<ResizeableDoubleVariable> variable,
    Rcpp::XPtr<individual_index_t> index
    ) {
    return variable->get_values(*index);
}

//[[Rcpp::export]]
std::vector<double> resizeable_double_variable_get_values_at_index_vector(
    Rcpp::XPtr<ResizeableDoubleVariable> variable,
    std::vector<size_t> index
    ) {
    decrement(index);
    return variable->get_values(index);
}

// [[Rcpp::export]]
Rcpp::XPtr<individual_index_t> resizeable_double_variable_get_index_of_range(
    Rcpp::XPtr<ResizeableDoubleVariable> variable,
    const double a,
    const double b
) {
    return Rcpp::XPtr<individual_index_t>(
        new individual_index_t(variable->get_index_of_range(a, b)),
        true
    );
}

// [[Rcpp::export]]
size_t resizeable_double_variable_get_size_of_range(
    Rcpp::XPtr<ResizeableDoubleVariable> variable,
    const double a,
    const double b
) {
    return variable->get_size_of_range(a, b);
}

//[[Rcpp::export]]
void resizeable_double_variable_queue_fill(
    Rcpp::XPtr<ResizeableDoubleVariable> variable,
    const std::vector<double> value
) {
    variable->queue_update(value, std::vector<size_t>());
}

//[[Rcpp::export]]
void resizeable_double_variable_queue_update(
    Rcpp::XPtr<ResizeableDoubleVariable> variable,
    const std::vector<double> value,
    std::vector<size_t> index
) {
    decrement(index);
    variable->queue_update(value, index);
}

//[[Rcpp::export]]
void resizeable_double_variable_queue_update_bitset(
        Rcpp::XPtr<ResizeableDoubleVariable> variable,
        const std::vector<double> value,
        Rcpp::XPtr<individual_index_t> index
) {
    if (index->max_size() != variable->size()) {
        Rcpp::stop("incompatible size bitset used to queue update for DoubleVariable");
    }
    auto index_vec = bitset_to_vector_internal(*index, false);
    variable->queue_update(value, index_vec);
}

//[[Rcpp::export]]
void resizeable_double_variable_update(Rcpp::XPtr<ResizeableDoubleVariable> variable) {
    variable->update();
}

//[[Rcpp::export]]
void resizeable_double_variable_queue_extend(
    Rcpp::XPtr<ResizeableDoubleVariable> variable,
    const std::vector<double>& values
) {
    variable->queue_extend(values);
}

//[[Rcpp::export]]
void resizeable_double_variable_queue_shrink_bitset(
    Rcpp::XPtr<ResizeableDoubleVariable> variable,
    Rcpp::XPtr<individual_index_t> index
) {
    variable->queue_shrink(*index);
}

//[[Rcpp::export]]
void resizeable_double_variable_queue_shrink(
    Rcpp::XPtr<ResizeableDoubleVariable> variable,
    std::vector<size_t> index
) {
    decrement(index);
    variable->queue_shrink(index);
}

//[[Rcpp::export]]
size_t resizeable_double_variable_size(
    Rcpp::XPtr<ResizeableDoubleVariable> variable
) {
    return variable->size();
}

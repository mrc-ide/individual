/*
 * state.cpp -> variable.cpp
 *
 *  Created on: 19 May 2020
 *      Author: gc1610
 */


#include "../inst/include/Variable.h"
#include "utils.h"

//[[Rcpp::export]]
Rcpp::XPtr<CategoricalVariable> create_categorical_variable(
    const std::vector<std::string>& categories,
    const std::vector<std::string>& values 
    ) {
    return Rcpp::XPtr<CategoricalVariable>(
        new CategoricalVariable(categories, values),
        true
    );
}

//[[Rcpp::export]]
void categorical_variable_queue_update(
    Rcpp::XPtr<CategoricalVariable> variable,
    const std::string& value,
    Rcpp::XPtr<individual_index_t> index
    ) {
    variable->queue_update(value, *index);
}

//[[Rcpp::export]]
Rcpp::XPtr<individual_index_t> categorical_variable_get_index_of(
    Rcpp::XPtr<CategoricalVariable> variable,
    const std::vector<std::string>& values 
    ) {
    return Rcpp::XPtr<individual_index_t>(
        new individual_index_t(variable->get_index_of(values)),
        true
    );
}

//[[Rcpp::export]]
void categorical_variable_queue_update_vector(
    Rcpp::XPtr<CategoricalVariable> variable,
    const std::string& value,
    std::vector<size_t>& index
    ) {
    decrement(index);
    auto bitmap = individual_index_t(variable->size);
    bitmap.insert(index.begin(), index.end());
    variable->queue_update(value, bitmap);
}

//[[Rcpp::export]]
void categorical_variable_update(Rcpp::XPtr<CategoricalVariable> variable) {
    variable->update();
}

//[[Rcpp::export]]
Rcpp::XPtr<DoubleVariable> create_double_variable(
    const std::vector<double>& values
    ) {
    return Rcpp::XPtr<DoubleVariable>(
        new DoubleVariable(values),
        true
    );
}

//[[Rcpp::export]]
std::vector<double> double_variable_get_values(
    Rcpp::XPtr<DoubleVariable> variable
    ) {
    return variable->get_values();
}

//[[Rcpp::export]]
std::vector<double> double_variable_get_values_at_index(
    Rcpp::XPtr<DoubleVariable> variable,
    Rcpp::XPtr<individual_index_t> index
    ) {
    return variable->get_values(*index);
}

//[[Rcpp::export]]
std::vector<double> double_variable_get_values_at_index_vector(
    Rcpp::XPtr<DoubleVariable> variable,
    std::vector<size_t> index
    ) {
    decrement(index);
    auto bitmap = individual_index_t(variable->size);
    bitmap.insert_safe(index.begin(), index.end());
    return variable->get_values(bitmap);
}

//[[Rcpp::export]]
void double_variable_queue_fill(
    Rcpp::XPtr<DoubleVariable> variable,
    const std::vector<double> value
) {
    variable->queue_update(value, std::vector<size_t>());
}

//[[Rcpp::export]]
void double_variable_queue_update(
    Rcpp::XPtr<DoubleVariable> variable,
    const std::vector<double> value,
    std::vector<size_t> index
) {
    decrement(index);
    variable->queue_update(value, index);
}

//[[Rcpp::export]]
void double_variable_update(Rcpp::XPtr<DoubleVariable> variable) {
    variable->update();
}

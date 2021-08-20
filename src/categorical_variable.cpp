/*
 * state.cpp -> variable.cpp
 *
 *  Created on: 19 May 2020
 *      Author: gc1610
 */


#include "../inst/include/CategoricalVariable.h"
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
int categorical_variable_get_size_of(
    Rcpp::XPtr<CategoricalVariable> variable,
    const std::vector<std::string>& values 
    ) {
    return variable->get_size_of(values);
}

//[[Rcpp::export]]
std::vector<std::string> categorical_variable_get_categories(
    Rcpp::XPtr<CategoricalVariable> variable
    ) {
    std::vector<std::string> categories;
    categories.reserve(variable->indices.size());
    for (const auto& it : variable->indices) {
        categories.emplace_back(it.first);
    }
    return categories;
}

//[[Rcpp::export]]
void categorical_variable_queue_update_vector(
    Rcpp::XPtr<CategoricalVariable> variable,
    const std::string& value,
    std::vector<size_t>& index
    ) {
    decrement(index);
    auto bitmap = individual_index_t(variable->size);
    bitmap.insert_safe(index.begin(), index.end());
    variable->queue_update(value, bitmap);
}

//[[Rcpp::export]]
void categorical_variable_update(Rcpp::XPtr<CategoricalVariable> variable) {
    variable->update();
}

/*
 *  RenderVector.h
 *
 *  Created on: 21 Dec 2023
 *      Author: pl2113
 */

#ifndef INST_INCLUDE_RENDER_VECTOR_H_
#define INST_INCLUDE_RENDER_VECTOR_H_

#include <Rcpp.h>

/**
 * A thin wrapper around a NumericVector, used to provide by-reference
 * semantics and guaranteed in-place mutation in the Render class.
 *
 */
struct RenderVector {
    RenderVector(Rcpp::NumericVector data) : _data(data) { }

    void update(size_t index, double value) {
        if (index < 1 || index > _data.size()) {
            Rcpp::stop("index out-of-bounds");
        }
        _data[index - 1] = value;
    }

    const Rcpp::NumericVector& data() const {
        return _data;
    }

    private:
        Rcpp::NumericVector _data;
};

#endif /* INST_INCLUDE_RENDER_VECTOR_H_ */

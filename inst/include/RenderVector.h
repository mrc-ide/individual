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
 * A thin wrapper around a std::vector<double>, used to provide by-reference
 * semantics and guaranteed in-place mutation in the Render class.
 *
 */
struct RenderVector {
    RenderVector(std::vector<double> data) : _data(std::move(data)) { }

    void update(size_t index, double value) {
        // index is R-style 1-indexed, rather than C's 0-indexing.
        if (index < 1 || index > _data.size()) {
            Rcpp::stop("index out-of-bounds");
        }
        _data[index - 1] = value;
    }

    const std::vector<double>& data() const {
        return _data;
    }

    private:
        std::vector<double> _data;
};

#endif /* INST_INCLUDE_RENDER_VECTOR_H_ */

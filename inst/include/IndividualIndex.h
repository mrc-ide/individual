/*
 * IndividualIndex.h
 *
 *  Created on: 1 Jun 2020
 *      Author: gc1610
 */

#ifndef INST_INCLUDE_INDIVIDUALINDEX_H_
#define INST_INCLUDE_INDIVIDUALINDEX_H_

//#include <Rcpp.h>
#include <cmath>
#include <iostream>

class IndividualIndex;

class IndividualIndex {
private:
    std::vector<uint64_t> bitmap;
    size_t n;
    size_t max_n;
    const size_t num_bits = 64;
    bool exists(size_t);
    void set(size_t);
    void unset(size_t);
public:
    using allocator_type = std::allocator<size_t>;
    using value_type = allocator_type::value_type;
    using reference = allocator_type::reference;
    using const_reference = allocator_type::const_reference;
    using difference_type = allocator_type::difference_type;
    using size_type = allocator_type::size_type;
    using input_iterator_type = std::iterator<std::input_iterator_tag, size_t>;

    class const_iterator {
    private:
        const IndividualIndex& index;
        size_t p;
        bool kickoff = false;
    public:
        using difference_type = allocator_type::difference_type;
        using value_type = allocator_type::value_type;
        using reference = const allocator_type::reference;
        using pointer = const allocator_type::pointer;
        using iterator_category = std::forward_iterator_tag;

        const_iterator(const IndividualIndex&, size_t, size_t);
        const_iterator(const IndividualIndex&);

        bool operator==(const const_iterator&) const;
        bool operator!=(const const_iterator&) const;

        const_iterator& operator++();

        reference operator*();
    };

    using iterator = const_iterator;

    IndividualIndex(size_t);
    template<class InputIterator>
    IndividualIndex(size_t, InputIterator, InputIterator);
    bool operator==(const IndividualIndex&) const;
    bool operator!=(const IndividualIndex&) const;
    iterator begin();
    const_iterator begin() const;
    const_iterator cbegin() const;
    iterator end();
    const_iterator end() const;
    const_iterator cend() const;
    void erase(size_t);
    iterator find(size_t);
    template<class InputIterator>
    void insert(InputIterator, InputIterator);
    void insert(size_t);
    size_type size() const;
    size_type max_size() const;
    bool empty() const;
};

inline IndividualIndex::const_iterator::const_iterator(
    const IndividualIndex& index,
    size_t k, size_t p) : index(index), p(p) {
}

inline IndividualIndex::const_iterator::const_iterator(
    const IndividualIndex& index) : index(index), p(static_cast<size_t>(-1)) {
}


inline bool IndividualIndex::const_iterator::operator ==(
    const const_iterator& other) const {
    return p == other.p;
}

inline bool IndividualIndex::const_iterator::operator !=(
    const const_iterator& other) const {
    return !(*this == other);
}

inline IndividualIndex::const_iterator& IndividualIndex::const_iterator::operator ++() {
    ++p;
    uint64_t bitset;

    while(p < index.max_n) {
        bitset = index.bitmap[p/index.num_bits] >> (p%index.num_bits);
        if (bitset > 0) {
            break;
        }
        p = std::min((p/index.num_bits + 1) * index.num_bits, index.max_n);
    }

    if (p == index.max_n) {
        return *this;
    }

    auto lsb = bitset & -bitset;
    auto r = __builtin_ctzl(lsb);
    p = std::min(p + r, index.max_n);
    return *this;
}

inline IndividualIndex::const_iterator::reference IndividualIndex::const_iterator::operator *() {
    return p;
}

inline IndividualIndex::IndividualIndex(size_t size) : max_n(size){
    bitmap = std::vector<uint64_t>(size/num_bits + 1, 0);
    n = 0;
}


template<class InputIterator>
inline IndividualIndex::IndividualIndex(size_t size, InputIterator begin, InputIterator end) : max_n(size) {
    bitmap = std::vector<uint64_t>(size/num_bits + 1, 0);
    n = 0;
    insert(begin, end);
}

inline bool IndividualIndex::operator ==(const IndividualIndex&) const {
    //Rcpp::stop("== Not implemented");
    return false;
}

inline bool IndividualIndex::operator !=(const IndividualIndex&) const {
    //Rcpp::stop("!= Not implemented");
    return false;
}

inline IndividualIndex::iterator IndividualIndex::begin() {
    return IndividualIndex::iterator(*this);
}

inline IndividualIndex::const_iterator IndividualIndex::begin() const {
    return IndividualIndex::const_iterator(*this);
}

inline IndividualIndex::const_iterator IndividualIndex::cbegin() const {
    return IndividualIndex::const_iterator(*this);
}

inline IndividualIndex::iterator IndividualIndex::end() {
    return IndividualIndex::iterator(*this, bitmap.size() - 1, max_n);
}

inline IndividualIndex::const_iterator IndividualIndex::end() const {
    return IndividualIndex::const_iterator(*this, bitmap.size() - 1, max_n);
}

inline IndividualIndex::const_iterator IndividualIndex::cend() const {
    return IndividualIndex::const_iterator(*this, bitmap.size() - 1, max_n);
}

inline bool IndividualIndex::exists(size_t v) {
    return (bitmap.at(v/num_bits) & (1 << (v % num_bits))) > 0;
}

inline void IndividualIndex::set(size_t v) {
    bitmap[v/num_bits] |= (0x1ULL << (v % num_bits));
}

inline void IndividualIndex::unset(size_t v) {
    bitmap[v/num_bits] &= ~(0x1ULL << (v % num_bits));
}

inline void IndividualIndex::erase(size_t v) {
    if (exists(v)) {
        unset(v);
        n--;
    }
}

inline IndividualIndex::iterator IndividualIndex::find(size_t v) {
    if(exists(v)) {
        return IndividualIndex::iterator(*this, floor(v / num_bits), v % num_bits);
    }
    return end();
}

template<class InputIterator>
inline void IndividualIndex::insert(InputIterator begin, InputIterator end) {
    auto it = begin;
    while (it != end) {
        insert(*it);
        ++it;
    }
}

inline void IndividualIndex::insert(size_t v) {
    if (!exists(v)) {
        set(v);
        n++;
    }
}

inline IndividualIndex::size_type IndividualIndex::size() const {
    return n;
}

inline IndividualIndex::size_type IndividualIndex::max_size() const {
    return bitmap.size() * 64;
}

inline bool IndividualIndex::empty() const {
    return n == 0;
}

#endif /* INST_INCLUDE_INDIVIDUALINDEX_H_ */

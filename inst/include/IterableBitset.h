/*
 * IndividualIndex.h
 *
 *  Created on: 1 Jun 2020
 *      Author: gc1610
 */

#ifndef INST_INCLUDE_ITERABLEBITSET_H_
#define INST_INCLUDE_ITERABLEBITSET_H_

#include <cmath>
#include <Rcpp.h>

template<class A>
class IterableBitset;

//' @title A bitset you can iterate with
//' @description This is a bitset, a data structure for sets of unsigned integers.
//' Insertion and erasure are fast.
//' You can iterate through the set using STL style iterators in O(n)
//'
//' Under the hood, we use a vector of integers.
//' Each integer stores the existance of sizeof(A) * 8 elements in the set.
template<class A>
class IterableBitset {
private:
    size_t max_n;
    size_t n;
    size_t num_bits;
    bool exists(size_t) const;
    void set(size_t);
    void unset(size_t);
    std::vector<A> bitmap;
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
        const IterableBitset& index;
        size_t p;
    public:
        using difference_type = allocator_type::difference_type;
        using value_type = allocator_type::value_type;
        using reference = const allocator_type::reference;
        using pointer = const allocator_type::pointer;
        using iterator_category = std::forward_iterator_tag;

        const_iterator(const IterableBitset&, size_t);
        const_iterator(const IterableBitset&);

        bool operator==(const const_iterator&) const;
        bool operator!=(const const_iterator&) const;

        const_iterator& operator++();

        reference operator*();
    };

    using iterator = const_iterator;

    IterableBitset(size_t);
    template<class InputIterator>
    IterableBitset(size_t, InputIterator, InputIterator);
    IterableBitset(size_t, const std::vector<size_t>);
    bool operator==(const IterableBitset&) const;
    bool operator!=(const IterableBitset&) const;
    IterableBitset operator&(const IterableBitset&) const;
    IterableBitset operator|(const IterableBitset&) const;
    IterableBitset operator~() const;
    IterableBitset& operator&=(const IterableBitset&);
    IterableBitset& operator|=(const IterableBitset&);
    iterator begin();
    const_iterator begin() const;
    const_iterator cbegin() const;
    iterator end();
    const_iterator end() const;
    const_iterator cend() const;
    void erase(size_t);
    const_iterator find(size_t) const;
    template<class InputIterator>
    void insert(InputIterator, InputIterator);
    template<class InputIterator>
    void insert_safe(InputIterator, InputIterator);
    void insert(size_t);
    void insert_safe(size_t);
    size_type size() const;
    size_type max_size() const;
    bool empty() const;
};


//' @title count trailing zeros in a 64bit integer
inline size_t ctz(uint64_t x) {
    if (x == 0) {
        return 64;
    }
    #ifdef __GNUC__
    return __builtin_ctzll(x);
    #else
    auto r = 0u;
    while(((x >> r) & 1ULL) == 0ULL)
        ++r;
    return r;
    #endif
}

//' @title count number of set bits in 64bit integer
inline size_t popcount(uint64_t x) {
    #ifdef __GNUC__
    return __builtin_popcountll(x);
    #else
    auto r = 0u;
    while(x != 0ULL) {
        if((x & 1) == 1)
            ++r;
        x >>= 1
    }
    return r;
    #endif
}

//' @title find the next set bit
//' @description given the current element p,
//' return the integer represented by the next set bit in the bitmap
template<class A>
inline size_t next_position(const std::vector<A>& bitmap, size_t num_bits, size_t max_n, size_t p) {
    ++p;
    auto bucket = p / num_bits;
    auto excess = p % num_bits;
    A bitset = bitmap.at(bucket) >> excess;

    while(bitset == 0 && bucket + 1 < bitmap.size()) {
        bitset = bitmap.at(++bucket);
        excess = 0;
    }

    auto lsb = bitset & -bitset;
    auto r = ctz(lsb);
    return std::min(bucket * num_bits + excess + r, max_n);
}

template<class A>
inline IterableBitset<A>::const_iterator::const_iterator(
    const IterableBitset& index, size_t p) : index(index), p(p) {
}

template<class A>
inline IterableBitset<A>::const_iterator::const_iterator(
    const IterableBitset& index) : index(index), p(static_cast<size_t>(-1)) {
    p = next_position(index.bitmap, index.num_bits, index.max_n, p);
}

template<class A>
inline bool IterableBitset<A>::const_iterator::operator ==(
    const const_iterator& other) const {
    return p == other.p;
}

template<class A>
inline bool IterableBitset<A>::const_iterator::operator !=(
    const const_iterator& other) const {
    return !(*this == other);
}

template<class A>
inline typename IterableBitset<A>::const_iterator& IterableBitset<A>::const_iterator::operator ++() {
    p = next_position(index.bitmap, index.num_bits, index.max_n, p);
    return *this;
}

template<class A>
inline typename IterableBitset<A>::const_iterator::reference IterableBitset<A>::const_iterator::operator *() {
    return p;
}

template<class A>
inline IterableBitset<A>::IterableBitset(size_t size) : max_n(size){
    num_bits = sizeof(A) * 8;
    bitmap = std::vector<A>(size/num_bits + 1, 0);
    n = 0;
}


template<class A>
template<class InputIterator>
inline IterableBitset<A>::IterableBitset(
    size_t size,
    InputIterator begin,
    InputIterator end
    ) : IterableBitset<A>::IterableBitset(size) {
    insert(begin, end);
}

template<class A>
inline IterableBitset<A>::IterableBitset(
    size_t size,
    const std::vector<size_t>to_set
    ) : IterableBitset<A>::IterableBitset(size, std::cbegin(to_set), std::cend(to_set)) {
}

template<class A>
inline bool IterableBitset<A>::operator ==(const IterableBitset<A>& other) const {
    return bitmap == other.bitmap;
}

template<class A>
inline bool IterableBitset<A>::operator !=(const IterableBitset<A>& other) const {
    return !(*this == other);
}

template<class A>
inline IterableBitset<A> IterableBitset<A>::operator &(const IterableBitset<A>& other) const {
    return IterableBitset<A>(*this) &= other;
}

template<class A>
inline IterableBitset<A> IterableBitset<A>::operator |(const IterableBitset<A>& other) const {
    return IterableBitset<A>(*this) |= other;
}

template<class A>
inline IterableBitset<A> IterableBitset<A>::operator ~() const {
    auto result = IterableBitset<A>(*this);
    for (auto i = 0u; i < result.bitmap.size(); ++i) {
        result.bitmap[i] = ~result.bitmap[i];
    }
    result.n = result.max_n - result.n;
    return result;
}

template<class A>
inline IterableBitset<A>& IterableBitset<A>::operator &=(const IterableBitset<A>& other) {
    if (max_size() != other.max_size()) {
        Rcpp::stop("Incompatible bitmap sizes");
    }
    n = 0;
    for (auto i = 0u; i < bitmap.size(); ++i) {
        bitmap[i] &= other.bitmap[i];
        n += popcount(bitmap[i]);
    }
    return *this;
}

template<class A>
inline IterableBitset<A>& IterableBitset<A>::operator |=(const IterableBitset<A>& other) {
    if (max_size() != other.max_size()) {
        Rcpp::stop("Incompatible bitmap sizes");
    }
    n = 0;
    for (auto i = 0u; i < bitmap.size(); ++i) {
        bitmap[i] |= other.bitmap[i];
        n += popcount(bitmap[i]);
    }
    return *this;
}

template<class A>
inline typename IterableBitset<A>::iterator IterableBitset<A>::begin() {
    return IterableBitset<A>::iterator(*this);
}

template<class A>
inline typename IterableBitset<A>::const_iterator IterableBitset<A>::begin() const {
    return IterableBitset<A>::const_iterator(*this);
}

template<class A>
inline typename IterableBitset<A>::const_iterator IterableBitset<A>::cbegin() const {
    return IterableBitset<A>::const_iterator(*this);
}

template<class A>
inline typename IterableBitset<A>::iterator IterableBitset<A>::end() {
    return IterableBitset<A>::iterator(*this, max_n);
}

template<class A>
inline typename IterableBitset<A>::const_iterator IterableBitset<A>::end() const {
    return IterableBitset<A>::const_iterator(*this, max_n);
}

template<class A>
inline typename IterableBitset<A>::const_iterator IterableBitset<A>::cend() const {
    return IterableBitset<A>::const_iterator(*this, max_n);
}

//' @title check existence of an element
//' @description check if the bit at position `v` is set
template<class A>
inline bool IterableBitset<A>::exists(size_t v) const {
    return (bitmap.at(v/num_bits) & (0x1ULL << (v % num_bits))) > 0;
}

template<class A>
inline void IterableBitset<A>::set(size_t v) {
    bitmap[v/num_bits] |= (0x1ULL << (v % num_bits));
}

template<class A>
inline void IterableBitset<A>::unset(size_t v) {
    bitmap[v/num_bits] &= ~(0x1ULL << (v % num_bits));
}

template<class A>
inline void IterableBitset<A>::erase(size_t v) {
    if (exists(v)) {
        unset(v);
        n--;
    }
}

//' @title find an element in the bitset
//' @description checks if the bit for `v` is set
template<class A>
inline typename IterableBitset<A>::const_iterator IterableBitset<A>::find(size_t v) const {
    if(exists(v)) {
        return IterableBitset<A>::const_iterator(*this, v);
    }
    return cend();
}

//' @title insert many
//' @description insert several elements into the bitset
template<class A>
template<class InputIterator>
inline void IterableBitset<A>::insert(InputIterator begin, InputIterator end) {
    auto it = begin;
    while (it != end) {
        insert(*it);
        ++it;
    }
}

template<class A>
template<class InputIterator>
inline void IterableBitset<A>::insert_safe(InputIterator begin, InputIterator end) {
    auto it = begin;
    while (it != end) {
        insert_safe(*it);
        ++it;
    }
}

//' @title insert
//' @description insert one element into the bitset
template<class A>
inline void IterableBitset<A>::insert(size_t v) {
    if (!exists(v)) {
        set(v);
        n++;
    }
}

template<class A>
inline void IterableBitset<A>::insert_safe(size_t v) {
    if (v < 0 || v >= max_n) {
        Rcpp::stop("Insert out of range");
    }
    insert(v);
}

template<class A>
inline typename IterableBitset<A>::size_type IterableBitset<A>::size() const {
    return n;
}

template<class A>
inline typename IterableBitset<A>::size_type IterableBitset<A>::max_size() const {
    return max_n;
}

template<class A>
inline bool IterableBitset<A>::empty() const {
    return n == 0;
}

//' @title filter the bitset
//' @description keep only the i-th values of the source bitset for i in this iterator
template<class A, class InputIterator>
inline IterableBitset<A> filter_bitset(IterableBitset<A>& source, InputIterator begin, InputIterator end) {
    auto result = IterableBitset<A>(source.max_size());
    auto is = std::vector<size_t>(begin, end);
    std::sort(std::begin(is), std::end(is));
    auto diffs = std::vector<size_t>(is.size());
    std::adjacent_difference(
        std::begin(is),
        std::end(is),
        std::begin(diffs)
    );
    auto it = std::begin(source);
    for (auto d : diffs) {
        std::advance(it, d);
        if (it == std::end(source)) {
            Rcpp::stop("invalid index for filtering");
        }
        result.insert(*it);
    }
    return result;
}

#endif /* INST_INCLUDE_ITERABLEBITSET_H_ */


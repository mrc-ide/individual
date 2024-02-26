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
#include "utils.h"

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
        using reference = allocator_type::reference;
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
    IterableBitset operator^(const IterableBitset&) const;
    IterableBitset operator!() const;
    IterableBitset& operator&=(const IterableBitset&);
    IterableBitset& operator|=(const IterableBitset&);
    IterableBitset& operator^=(const IterableBitset&);
    IterableBitset& clear();
    IterableBitset& inverse();
    iterator begin();
    const_iterator begin() const;
    const_iterator cbegin() const;
    iterator end();
    const_iterator end() const;
    const_iterator cend() const;
    void erase(size_t);
    void erase(size_t start, size_t end);
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
    void extend(size_t);
    void shrink(const std::vector<size_t>&);
    size_t next_position(size_t start, size_t n) const;
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

//' Find the nth set bit in a 64bit integer.
//'
//' Returns the index of the bit, or 64 if there are not enough bits set.
inline size_t find_bit(uint64_t x, size_t n) {
    if (n >= 64) {
        return 64;
    }

    for (size_t i = 0; i < n; i++) {
        x &= x - 1;
    }
    return ctz(x);
}

//' Find the n-th set bit, starting at position p.
//'
//' Returns the index of the bit, ot max_n if there are not enough bits set.
template<class A>
inline size_t IterableBitset<A>::next_position(size_t p, size_t n) const {
    size_t bucket = p / num_bits;
    size_t excess = p % num_bits;

    A bitset = bitmap[bucket] >> excess;
    while (n >= popcount(bitset) && bucket + 1 < bitmap.size()) {
        n -= popcount(bitset);
        bucket += 1;
        bitset = bitmap[bucket];
        excess = 0;
    }

    auto r = find_bit(bitset, n);
    return std::min(bucket * num_bits + excess + r, max_n);
}

template<class A>
inline IterableBitset<A>::const_iterator::const_iterator(
    const IterableBitset& index, size_t p) : index(index), p(p) {
}

template<class A>
inline IterableBitset<A>::const_iterator::const_iterator(
    const IterableBitset& index) : index(index) {
    p = index.next_position(0, 0);
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
    p = index.next_position(p + 1, 0);
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
inline IterableBitset<A> IterableBitset<A>::operator ^(const IterableBitset<A>& other) const {
    return IterableBitset<A>(*this) ^= other;
}

template<class A>
inline IterableBitset<A>& IterableBitset<A>::clear() {
  for (auto i = 0u; i < bitmap.size(); ++i) {
    bitmap[i] = 0x0ULL;
  }
  n = 0;
  return *this;
}

template<class A>
inline IterableBitset<A>& IterableBitset<A>::inverse() {
  for (auto i = 0u; i < bitmap.size(); ++i) {
    bitmap[i] = ~bitmap[i];
  }
  //mask out the values after max_n
  A residual = (static_cast<A>(1) << (max_n % num_bits)) - 1;
  bitmap[bitmap.size() - 1] &= residual;
  n = max_n - n;
  return *this;
}

template<class A>
inline IterableBitset<A> IterableBitset<A>::operator !() const {
    auto result = IterableBitset<A>(*this);
    result.inverse();
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
inline IterableBitset<A>& IterableBitset<A>::operator ^=(const IterableBitset<A>& other) {
    if (max_size() != other.max_size()) {
        Rcpp::stop("Incompatible bitmap sizes");
    }
    n = 0;
    for (auto i = 0u; i < bitmap.size(); ++i) {
        bitmap[i] ^= other.bitmap[i];
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

//' @title Erase all values in a given range.
//' @description Bits at indices [start, end) are set to zero.
template<class A>
inline void IterableBitset<A>::erase(size_t start, size_t end) {
    // In the general case, bits to erase are split into three regions, a
    // prefix, a middle part and a postfix. The middle region is always aligned
    // on word boundaries.
    //
    // Consider the following bitset, stored using 4-bit words:
    //
    // abcd efgh ijkl mnop
    //
    // Erasing the range [2, 14) requires clearing out bit c to n, inclusive.
    // The prefix is [cd] and the suffix [mn]. The middle section is [efghijkl].
    //
    // The middle section can be erased by overwriting the entire word with zeros.
    // The prefix and suffix parts must be cleared by applying a mask over the
    // existing bits.
    //
    // There are however a few special cases:
    // - The range could be empty, in which case nothing needs to be done.
    // - The range falls within a single word. In the example above that could
    //   be [5, 6), ie. [fg]. A single mask needs to be constructed, covering
    //   only the relevant bits.
    // - The middle region ends on a word boundary, in which case there is no
    //   postfix to erase.
    //
    // Anytime bits are cleared, whether by overwriting a word or using a mask,
    // the bitset's size must be updated accordingly, using popcount to find out
    // how many bits have actually been cleared.

    if (start == end) {
        return;
    } else if (start / num_bits == end / num_bits) {
        auto mask =
            (static_cast<A>(1) << (end % num_bits)) -
            (static_cast<A>(1) << (start % num_bits));
        n -= popcount(bitmap[start / num_bits] & mask);
        bitmap[start / num_bits] &= ~mask;
    } else {
        // Clear the prefix part, using a mask to preserve bits that are before it.
        auto mask = -(static_cast<A>(1) << (start % num_bits));
        n -= popcount(bitmap[start / num_bits] & mask);
        bitmap[start / num_bits] &= ~mask;

        start = (start + num_bits - 1) / num_bits * num_bits;

        // Now clear the middle chunk. No masking needed since entire words are
        // being cleared.
        for (; start + num_bits <= end; start += num_bits) {
            n -= popcount(bitmap[start / num_bits]);
            bitmap[start / num_bits] = 0;
        }
        start = (end / num_bits) * num_bits;

        // Finally clear the suffix, if applicable, using a mask again.
        if (start < end) {
            mask = (static_cast<A>(1) << (end % num_bits)) - 1;
            n -= popcount(bitmap[end / num_bits] & mask);
            bitmap[end / num_bits] &= ~mask;
        }
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

//' @title safe insert many
//' @description insert several elements into the bitset. Each insert calls 
//' `insert_safe` which includes bounds checking, and this method should be used
//' to insert data into bitsets from vector and other non bitset objects which
//' may have bad input.
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

//' @title safe insert
//' @description check if insert is in range and then insert one element into 
//' the bitset. This method should be used to insert from  data in vectors and 
//' other non bitset objects which may have bad input.
template<class A>
inline void IterableBitset<A>::insert_safe(size_t v) {
    if (v >= max_n) {
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

//' @title bitset to vector
//' @description return a vector of unsigned ints indicating which bits are set
template<class A>
inline std::vector<size_t> bitset_to_vector_internal(
  const IterableBitset<A>& b,
  const bool addone = true
) {
  auto offset = 0u;
  if (addone) {
    offset = 1u;
  }
  auto result = std::vector<size_t>(b.size());
  auto i = 0u;
  for (auto v : b) {
    result[i] = v + offset;
    ++i;
  }
  return result;
}

//' @title filter the bitset
//' @description keep only the i-th values of the source bitset for i in this iterator
template<class A, class InputIterator>
inline IterableBitset<A> filter_bitset(
    const IterableBitset<A>& source,
    InputIterator begin,
    InputIterator end
    ) {
    auto result = IterableBitset<A>(source.max_size());
    auto is = std::vector<size_t>(begin, end);
    std::sort(std::begin(is), std::end(is));
    auto it = FilterIterator<typename IterableBitset<A>::iterator, std::vector<size_t>::iterator, size_t>(
        std::begin(source),
        std::end(source),
        std::begin(is),
        std::end(is)
    );
    result.insert(it.begin(), it.end());
    return result;
}

//' @title randomly keep N items in the bitset
//' @description retain N items in the bitset. This function
//' modifies the bitset.
template<class A>
inline void bitset_choose_internal(
    IterableBitset<A>& b,
    const size_t k
){
  auto to_remove = Rcpp::sample(
    b.size(),
    b.size() - k,
    false, // replacement
    R_NilValue, // evenly distributed
    false // one based
  );
  std::sort(to_remove.begin(), to_remove.end());
  auto bitset_i = 0;
  auto bitset_it = b.cbegin();
  for (auto i : to_remove) {
    while(bitset_i != i) {
      ++bitset_i;
      ++bitset_it;
    }
    b.erase(*bitset_it);
    ++bitset_i;
    ++bitset_it;
  }
}

struct fast_bernouilli {
    fast_bernouilli(double probability) : probability(probability) {
        double probability_log = log(1 - probability);
        if (probability_log == 0.0) {
            probability = 0.;
        } else {
            inverse_log = 1 / probability_log;
        }
    }

    //' Get the number of subsequent unsuccessful trials, until the next
    //' successful one.
    uint64_t skip_count() {
        if (probability == 1) {
            return 0;
        } else if (probability == 0.) {
            return UINT64_MAX;
        }

        double x = R::runif(0.0, 1.0);
        double skip_count = floor(log(x) * inverse_log);
        if (skip_count < double(UINT64_MAX)) {
            return skip_count;
        } else {
            return UINT64_MAX;
        }
    }

    private:
        double probability;
        double inverse_log;
};

//' Sample values from the bitset.
//'
//' Each value contained in the bitset is retained with an equal probability
//' 'rate'. This function modifies the bitset in-place.
//'
//' Rather than performing a bernouilli trial for every member of the bitset,
//' this function is implemented by generating the lengths of the gaps between
//' two successful trials. This allows it to efficiently skip from one positive
//' trial to the next.
//'
//' This technique comes from the FastBernoulliTrial class in Firefox:
//' https://searchfox.org/mozilla-central/rev/aff9f084/mfbt/FastBernoulliTrial.h
//'
//' As an additional optimization, we flip the behaviour and sampling rate in
//' order to maximize the lengths, depending on whether the rate was smaller or
//' greater than 1/2.
template<class A>
inline void bitset_sample_internal(
        IterableBitset<A>& b,
        const double rate
        ){
    if (rate < 0.5) {
        fast_bernouilli bernouilli(rate);
        size_t i = 0;
        while (i < b.max_size()) {
            size_t next = b.next_position(i, bernouilli.skip_count());
            b.erase(i, next);
            i = next + 1;
        }
    } else {
        fast_bernouilli bernouilli(1 - rate);
        size_t i = 0;
        while (i < b.max_size()) {
            size_t next = b.next_position(i, bernouilli.skip_count());
            if (next < b.max_size()) {
                b.erase(next);
            }
            i = next + 1;
        }
    }
}

//' @title sample the bitset
//' @description retain a subset of values contained in this bitset, 
//' where each element has unique probability to remain given
//' by elements in the input iterator. 
//' This function modifies the bitset.
template<class A, class InputIterator>
inline void bitset_sample_multi_internal(
    IterableBitset<A>& b,
    InputIterator begin,
    InputIterator end
){  
    // sample elements
    size_t n = b.size();
    const auto random = Rcpp::runif(n);
    auto i = 0u;
    auto probs_it = begin;
    auto bitset_it = b.cbegin();
    while (i < n) {
        if (random[i] >= *(probs_it)) {
            b.erase(*bitset_it);
        }
        ++i;
        ++probs_it;
        ++bitset_it;
    }

}

//' @title extend the bitset
//' @description adds space in the bitset for more elements
template<class A>
inline void IterableBitset<A>::extend(size_t n) {  
    const auto n_blocks = (max_n + n) / num_bits + 1;
    if (n_blocks > bitmap.size()) {
        bitmap.insert(
            bitmap.end(),
            n_blocks - bitmap.size(),
            static_cast<A>(0)
        );
    }
    max_n += n;
}

//' @title shrink the bitset
//' @description removes the elements in `index` shifting subsequent elements to
//fill their position. Assumes `index` is sorted and unique
template<class A>
inline void IterableBitset<A>::shrink(const std::vector<size_t>& index) {  
    if (index.size() == 0) {
        return;
    }
    size_t n_shifts = 0;
    auto values = std::list<size_t>(this->cbegin(), this->cend());
    auto it = values.begin();
    auto removal_it = index.cbegin();
    while (it != values.end()) {
        while (removal_it != index.cend() && *it > *removal_it) {
            ++removal_it;
            ++n_shifts;
        }
        if (removal_it != index.cend() && *it == *removal_it) {
            it = values.erase(it);
        } else {
            (*it) -= n_shifts;
            ++it;
        }
    }
    auto max_block = (max_n - index.size()) / num_bits + 1;
    if (max_block < bitmap.size()) {
        bitmap.erase(bitmap.begin() + max_block, bitmap.end());
    }
    clear();
    insert(values.cbegin(), values.cend());
    max_n -= index.size();
}

#endif /* INST_INCLUDE_ITERABLEBITSET_H_ */


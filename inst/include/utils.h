#include <Rcpp.h>
#include <iterator>

#ifndef UTILS_H_
#define UTILS_H_

//' @title filter one iterable by another
//' @description keep only the i-th values of the source iterable for i in the other 
template<class SourceIterator, class FilteringIterator, class A>
class FilterIterator 
{
    SourceIterator s_begin;
    SourceIterator s_end;
    FilteringIterator f_begin;
    FilteringIterator f_end;
    std::vector<size_t> diffs;
public:
    struct Iterator {
        using iterator_category = std::forward_iterator_tag;
        using difference_type   = std::ptrdiff_t;
        using value_type        = A;
        using pointer           = A*;  // or also value_type*
        using reference         = A&;  // or also value_type&

        reference operator*() const { return *container.s_begin; }
        pointer operator->() { return container.s_begin; }

        // Prefix increment
        Iterator& operator++() { next(); return *this; }  

        // Postfix increment
        Iterator operator++(int) { Iterator tmp = *this; ++(*this); return tmp; }

        friend bool operator== (const Iterator& a, const Iterator& b) {
            return a.i == b.i;
        };
        friend bool operator!= (const Iterator& a, const Iterator& b) {
            return a.i != b.i;
        };

        Iterator(FilterIterator& container, size_t i)
            : container(container), i(i) {}
    private:
        FilterIterator& container;
        size_t i;
        void next() {
            std::advance(container.s_begin, container.diffs[i]);
            if (container.s_begin == container.s_end) {
                Rcpp::stop("invalid index for filtering");
            }
            ++i;
        }
    };

    FilterIterator(
        SourceIterator s_begin,
        SourceIterator s_end,
        FilteringIterator f_begin,
        FilteringIterator f_end
    ) : s_begin(s_begin),
        s_end(s_end),
        f_begin(f_begin),
        f_end(f_end) {
        diffs.resize(std::distance(s_begin, s_end));
        std::adjacent_difference(f_begin, f_end, std::begin(diffs));
    }

    Iterator begin() { return Iterator(*this, 0u); }
    Iterator end() { return Iterator(*this, diffs.size()); }
};

#endif /* UTILS_H_ */

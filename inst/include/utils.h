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

        reference operator*() { return *it; }
        pointer operator->() { return it; }

        // Prefix increment
        Iterator& operator++() { next(); return *this; }  

        // Postfix increment
        Iterator operator++(int) { Iterator tmp = *this; ++(*this); return tmp; }

        friend bool operator== (const Iterator& a, const Iterator& b) {
            return a.diff_i == b.diff_i;
        };
        friend bool operator!= (const Iterator& a, const Iterator& b) {
            return a.diff_i != b.diff_i;
        };

        Iterator(
            SourceIterator it,
            SourceIterator it_end,
            const std::vector<size_t>& diffs,
            size_t diff_i
        )
            : it(it), it_end(it_end), diffs(diffs), diff_i(diff_i) {}
    private:
        SourceIterator it;
        SourceIterator it_end;
        const std::vector<size_t>& diffs;
        size_t diff_i;
        void next() {
            ++diff_i;
            if (diff_i < diffs.size()) {
                std::advance(it, diffs[diff_i]);
                if (it == it_end) {
                    Rcpp::stop("invalid index for filtering");
                }
            }
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
        if (f_begin != f_end) {
            auto diff_size = std::distance(f_begin, f_end);
            diffs.resize(diff_size);
            if (diff_size > 0) {
                std::adjacent_difference(f_begin, f_end, std::begin(diffs));
            }
            std::advance(this->s_begin, *this->f_begin);
            if (this->s_begin == this->s_end) {
                Rcpp::stop("invalid index for filtering");
            }
        }
    }

    Iterator begin() { return Iterator(s_begin, s_end, diffs, 0u); }
    Iterator end() { return Iterator(s_begin, s_end, diffs, diffs.size()); }
};

#endif /* UTILS_H_ */

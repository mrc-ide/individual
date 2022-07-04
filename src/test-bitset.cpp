#include <Rcpp.h>
#include <testthat.h>
#include <unordered_set>

#include "../inst/include/IterableBitset.h"

using individual_index_t = IterableBitset<uint64_t>;

context("Bitset") {

    test_that("Iterator construction works") {
        std::vector<size_t> x = {1, 3, 6};
        auto index = individual_index_t(10, std::cbegin(x), std::cend(x));
        auto exists = index.find(1) != index.end();
        expect_true(index.find(1) != index.end());
        expect_true(index.find(3) != index.end());
        expect_true(index.find(6) != index.end());
        expect_true(index.find(9) == index.end());
    }

    test_that("Insertions work") {
        auto index = individual_index_t(10);
        expect_true(index.find(1) == index.end());
        expect_true(index.find(6) == index.end());
        index.insert(1);
        expect_true(index.find(1) != index.end());
        expect_true(index.find(6) == index.end());
        index.insert(6);
        expect_true(index.find(1) != index.end());
        expect_true(index.find(6) != index.end());
    }

    test_that("Insertions by iteration works") {
        std::vector<size_t> x = {1, 3, 6};
        auto index = individual_index_t(10);
        index.insert(std::cbegin(x), std::cend(x));
        expect_true(index.find(1) != index.end());
        expect_true(index.find(3) != index.end());
        expect_true(index.find(6) != index.end());
        expect_true(index.find(0) == index.end());
        expect_true(index.find(9) == index.end());
    }

    test_that("Erasures work") {
        std::vector<size_t> x = {1, 3, 6};
        auto index = individual_index_t(10, std::cbegin(x), std::cend(x));
        index.erase(1);
        expect_true(index.find(1) == index.end());
        expect_true(index.find(3) != index.end());
        expect_true(index.find(6) != index.end());
        expect_true(index.find(9) == index.end());
        index.erase(6);
        expect_true(index.find(1) == index.end());
        expect_true(index.find(3) != index.end());
        expect_true(index.find(6) == index.end());
        expect_true(index.find(9) == index.end());
    }

    test_that("Iteration works") {
        std::vector<size_t> x = {1, 3, 6};
        auto index = individual_index_t(10, std::cbegin(x), std::cend(x));
        auto iterated = std::vector<size_t>(std::cbegin(index), std::cend(index));
        expect_true(std::find(iterated.begin(), iterated.end(), 0) == iterated.end());
        expect_true(std::find(iterated.begin(), iterated.end(), 1) != iterated.end());
        expect_true(std::find(iterated.begin(), iterated.end(), 3) != iterated.end());
        expect_true(std::find(iterated.begin(), iterated.end(), 6) != iterated.end());
        expect_true(std::find(iterated.begin(), iterated.end(), 9) == iterated.end());

        index.insert(2);
        iterated = std::vector<size_t>(std::cbegin(index), std::cend(index));
        expect_true(std::find(iterated.begin(), iterated.end(), 1) != iterated.end());
        expect_true(std::find(iterated.begin(), iterated.end(), 2) != iterated.end());
        expect_true(std::find(iterated.begin(), iterated.end(), 3) != iterated.end());
        expect_true(std::find(iterated.begin(), iterated.end(), 6) != iterated.end());
    }

    test_that("Multi word sets work") {
        std::vector<size_t> x = {1, 3, 6, 64, 73};
        auto index = individual_index_t(100, std::cbegin(x), std::cend(x));
        const auto iterated = std::vector<size_t>(std::cbegin(index), std::cend(index));
        expect_true(std::find(iterated.begin(), iterated.end(), 0) == iterated.end());
        expect_true(std::find(iterated.begin(), iterated.end(), 1) != iterated.end());
        expect_true(std::find(iterated.begin(), iterated.end(), 3) != iterated.end());
        expect_true(std::find(iterated.begin(), iterated.end(), 6) != iterated.end());
        expect_true(std::find(iterated.begin(), iterated.end(), 9) == iterated.end());
        expect_true(std::find(iterated.begin(), iterated.end(), 64) != iterated.end());
        expect_true(std::find(iterated.begin(), iterated.end(), 73) != iterated.end());
        expect_true(std::find(iterated.begin(), iterated.end(), 72) == iterated.end());
    }

    test_that("Bitwise ops work as expected") {
        std::vector<size_t> x = {1, 6, 73};
        std::vector<size_t> y = {6, 64, 73};
        auto x_index = individual_index_t(100, std::cbegin(x), std::cend(x));
        auto y_index = individual_index_t(100, std::cbegin(y), std::cend(y));
        auto z_index = x_index & y_index;
        const auto z = std::vector<size_t>(std::cbegin(z_index), std::cend(z_index));
        expect_true(std::find(z.begin(), z.end(), 0) == z.end());
        expect_true(std::find(z.begin(), z.end(), 1) == z.end());
        expect_true(std::find(z.begin(), z.end(), 3) == z.end());
        expect_true(std::find(z.begin(), z.end(), 6) != z.end());
        expect_true(std::find(z.begin(), z.end(), 9) == z.end());
        expect_true(std::find(z.begin(), z.end(), 64) == z.end());
        expect_true(std::find(z.begin(), z.end(), 73) != z.end());
        expect_true(std::find(z.begin(), z.end(), 72) == z.end());
        expect_true(z_index.size() == 2);
        auto u_index = x_index | y_index;
        const auto u = std::vector<size_t>(std::cbegin(u_index), std::cend(u_index));
        expect_true(std::find(u.begin(), u.end(), 0) == u.end());
        expect_true(std::find(u.begin(), u.end(), 1) != u.end());
        expect_true(std::find(u.begin(), u.end(), 3) == u.end());
        expect_true(std::find(u.begin(), u.end(), 6) != u.end());
        expect_true(std::find(u.begin(), u.end(), 9) == u.end());
        expect_true(std::find(u.begin(), u.end(), 64) != u.end());
        expect_true(std::find(u.begin(), u.end(), 73) != u.end());
        expect_true(std::find(u.begin(), u.end(), 72) == u.end());
        expect_true(u_index.size() == 4);
    }

    test_that("Assignment bitwise ops work as expected") {
        std::vector<size_t> x = {1, 6, 73};
        std::vector<size_t> y = {6, 64, 73};
        auto x_index = individual_index_t(100, std::cbegin(x), std::cend(x));
        auto y_index = individual_index_t(100, std::cbegin(y), std::cend(y));
        x_index &= y_index;
        const auto z = std::vector<size_t>(std::cbegin(x_index), std::cend(x_index));
        expect_true(std::find(z.begin(), z.end(), 0) == z.end());
        expect_true(std::find(z.begin(), z.end(), 1) == z.end());
        expect_true(std::find(z.begin(), z.end(), 3) == z.end());
        expect_true(std::find(z.begin(), z.end(), 6) != z.end());
        expect_true(std::find(z.begin(), z.end(), 9) == z.end());
        expect_true(std::find(z.begin(), z.end(), 64) == z.end());
        expect_true(std::find(z.begin(), z.end(), 73) != z.end());
        expect_true(std::find(z.begin(), z.end(), 72) == z.end());
        expect_true(x_index.size() == 2);
        x_index = individual_index_t(100, std::cbegin(x), std::cend(x));
        x_index |= y_index;
        const auto u = std::vector<size_t>(std::cbegin(x_index), std::cend(x_index));
        expect_true(std::find(u.begin(), u.end(), 0) == u.end());
        expect_true(std::find(u.begin(), u.end(), 1) != u.end());
        expect_true(std::find(u.begin(), u.end(), 3) == u.end());
        expect_true(std::find(u.begin(), u.end(), 6) != u.end());
        expect_true(std::find(u.begin(), u.end(), 9) == u.end());
        expect_true(std::find(u.begin(), u.end(), 64) != u.end());
        expect_true(std::find(u.begin(), u.end(), 73) != u.end());
        expect_true(std::find(u.begin(), u.end(), 72) == u.end());
        expect_true(x_index.size() == 4);
    }

    test_that("Bitset filtering works as expected") {
        const auto x = individual_index_t(100, {1, 36, 73});
        const auto y = std::vector<size_t>{0, 2};
        const auto z = filter_bitset(x, std::cbegin(y), std::cend(y));
        const auto expected = individual_index_t(100, {1, 73});
        expect_true(z == expected);
    }

    test_that("Bitset filtering works out of order") {
        const auto x = individual_index_t(100, {1, 36, 73});
        const auto y = std::vector<size_t>{2, 0};
        const auto z = filter_bitset(x, std::cbegin(y), std::cend(y));
        const auto expected = individual_index_t(100, {1, 73});
        expect_true(z == expected);
    }

    test_that("Bitset filtering by out of range throws an error") {
        const auto x = individual_index_t(100, {1, 36, 73});
        const auto y = std::vector<size_t>{0, 2, 4};
        expect_error(filter_bitset(x, std::cbegin(y), std::cend(y)));
    }

    test_that("Bitsets can be extended") {
        auto x = individual_index_t(100, {1, 36, 73});
        expect_error(x.insert_safe(101));
        x.extend(100);
        const auto expected_bitset = individual_index_t(200, {1, 36, 73});
        expect_true(x == expected_bitset);
        x.insert(101);
        expect_true(x.find(101) != x.end());
        expect_error(x.insert_safe(201));
    }

    test_that("Bitsets can be extended across word boundaries") {
        auto x = individual_index_t(1000, {1, 36, 73});
        expect_error(x.insert_safe(1025));
        x.extend(38);
        const auto expected_bitset = individual_index_t(1038, {1, 36, 73});
        expect_true(x == expected_bitset);
        x.insert(1025);
        expect_true(x.find(1025) != x.end());
        expect_error(x.insert_safe(1050));
    }

    test_that("Bitsets can be shrunk at the beginning") {
        auto x = individual_index_t(10, {0, 1, 2, 3, 4, 5, 6, 7, 8, 9});
        const auto index = std::vector<size_t>{0, 1, 2, 3, 4};
        x.shrink(index);
        const auto expected_bitset = individual_index_t(5, {0, 1, 2, 3, 4});
        expect_true(x == expected_bitset);
    }

    test_that("Bitsets can be shrunk with an index containing unset bits") {
        auto x = individual_index_t(100, {1, 36, 73, 99});
        const auto index = std::vector<size_t>{2, 4, 37};
        x.shrink(index);
        const auto expected_bitset = individual_index_t(97, {1, 34, 70, 96});
        expect_true(x == expected_bitset);
    }

    test_that("Bitsets can be shrunk with an index containing set bits") {
        auto x = individual_index_t(100, {1, 36, 73, 99});
        const auto index = std::vector<size_t>{36, 73};
        x.shrink(index);
        const auto expected_bitset = individual_index_t(98, {1, 97});
        expect_true(x == expected_bitset);
    }

    test_that("Bitsets can be shrunk with an index containing a mix of set and unset bits") {
        auto x = individual_index_t(100, {1, 36, 73, 99});
        const auto index = std::vector<size_t>{37, 73};
        x.shrink(index);
        const auto expected_bitset = individual_index_t(98, {1, 36, 97});
        expect_true(x == expected_bitset);
    }

    test_that("Bitsets can be shrunk over word boundaries") {
        auto x = individual_index_t(514, {1, 257, 513});
        auto index = std::vector<size_t>();
        for (auto i = 258; i < 514; ++i) {
            index.push_back(i);
        }
        x.shrink(index);
        const auto expected_bitset = individual_index_t(258, {1, 257});
        expect_true(x == expected_bitset);
    }
}

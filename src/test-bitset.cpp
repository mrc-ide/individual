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
}

context("Individual index stochastic") {

    test_that("Insertion and erasure") {
        auto container_size = 1 << 8;
        auto data_size = 1 << 4;
        for (auto _ = 0; _ < 10; ++_) {
            auto index = individual_index_t(container_size);
            auto standard = std::unordered_set<size_t>(container_size);
            auto excluded = std::vector<size_t>(data_size / 2);

            //test insertion and erasure
            for (auto i = 0; i < data_size; ++i) {
                auto point = static_cast<size_t>(R::runif(0, container_size));
                if (i < data_size / 2) {
                    index.insert(point);
                    standard.insert(point);
                } else {
                    index.erase(point);
                    standard.erase(point);
                    excluded[i - data_size / 2] = point;
                }
            }

            for (auto point : standard) {
                expect_true(index.find(point) != index.end());
            }
            for (auto point : excluded) {
                expect_true(index.find(point) == index.end());
            }
        }
    }

    test_that("Stochastic test for iteration") {
        auto container_size = 1 << 15;
        auto data_size = 1 << 8;
        for (auto _ = 0; _ < 10; ++_) {
            auto index = individual_index_t(container_size);
            auto standard = std::vector<size_t>(data_size);

            for (auto i = 0; i < data_size; ++i) {
                auto point = static_cast<size_t>(R::runif(0, container_size));
                index.insert(point);
                standard[i] = point;
            }

            auto iterated = std::unordered_set<size_t>(index.begin(), index.end());

            for (auto point : standard) {
                expect_true(iterated.find(point) != iterated.end());
            }
        }
    }
}

#include <testthat.h>
#include "../inst/include/IndividualIndex.h"

context("Individual index") {

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
      const auto iterated = std::vector<size_t>(std::cbegin(index), std::cend(index));
      expect_true(std::find(iterated.begin(), iterated.end(), 0) == iterated.end());
      expect_true(std::find(iterated.begin(), iterated.end(), 1) != iterated.end());
      expect_true(std::find(iterated.begin(), iterated.end(), 3) != iterated.end());
      expect_true(std::find(iterated.begin(), iterated.end(), 6) != iterated.end());
      expect_true(std::find(iterated.begin(), iterated.end(), 9) == iterated.end());
  }

}

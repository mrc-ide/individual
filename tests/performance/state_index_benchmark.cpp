/*
 * state_index_benchmark.cpp
 *
 *  Created on: 4 Jun 2020
 *      Author: gc1610
 */

#include <benchmark/benchmark.h>
#include <unordered_set>
#include "../../inst/include/IterableBitset.h"

using individual_index_t = IterableBitset<uint64_t>;
//using individual_index_t = std::unordered_set<size_t>;

std::vector<size_t>create_random_data(size_t size, size_t limit) {
    std::vector<size_t> data(size);
    for (auto i = 0u; i < size; ++i) {
        data[i] = rand() % limit;
    }
    return data;
}

static void BM_IndexInsert(benchmark::State& state) {
    individual_index_t index(state.range(1));
    for (auto _ : state) {
        state.PauseTiming();
        auto data = create_random_data(state.range(0), state.range(1));
        state.ResumeTiming();
        for (auto d : data) {
            index.insert(d);
        }
    }
}

BENCHMARK(BM_IndexInsert)
    ->Ranges({{1<<10, 8<<10}, {1<<10, 8<<12}});

static void BM_IndexIterate(benchmark::State& state) {
    individual_index_t index(state.range(1));
    for (auto _ : state) {
        state.PauseTiming();
        auto data = create_random_data(state.range(0), state.range(1));
        for (auto d : data) {
            index.insert(d);
        }
        state.ResumeTiming();
        auto output = std::vector<size_t>(index.cbegin(), index.cend());
    }
}

BENCHMARK(BM_IndexIterate)
    ->Ranges({{1<<5, 8<<10}, {1<<10, 8<<12}});

static void BM_IndexErase(benchmark::State& state) {
    individual_index_t index(state.range(1));
    for (auto _ : state) {
        state.PauseTiming();
        auto data = create_random_data(state.range(0), state.range(1));
        for (auto d : data) {
            index.insert(d);
        }
        auto erase = std::vector<size_t>(data.size());
        auto other_erase = create_random_data(state.range(0), state.range(1));
        for (auto i = 0u; i < data.size(); ++i) {
            if (rand() % 2)
                erase[i] = data[i];
            else
                erase[i] = other_erase[i];
        }
        state.ResumeTiming();
        for (auto e : erase) {
            index.erase(e);
        }
    }
}

BENCHMARK(BM_IndexErase)
    ->Ranges({{1<<10, 8<<10}, {1<<10, 8<<12}});

BENCHMARK_MAIN();

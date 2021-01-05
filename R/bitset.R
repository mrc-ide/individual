#' Class: Bitset
#' An R wrapper for IterableBitset
#' @export Bitset
Bitset <- R6::R6Class(
  'Bitset',
  public = list(
    .bitset = NULL,
    max_size = 0,

    #' @description create a bitset
    #' @param size the size of the bitset
    #' @param from pointer to an existing IterableBitset to use
    initialize = function(size, from = NULL) {
      if (is.null(from)) {
        self$.bitset <- create_bitset(size)
      } else {
        self$.bitset <- from
      }
      self$max_size <- bitset_max_size(self$.bitset)
    },

    # methods
    insert = function(v) bitset_insert(self$.bitset, v),
    remove = function(v) bitset_remove(self$.bitset, v),
    size = function() bitset_size(self$.bitset),
    or = function(other) bitset_or(self$.bitset, other$.bitset),
    and = function(other) bitset_and(self$.bitset, other$.bitset),
    sample = function(rate) bitset_sample(self$.bitset, rate),
    copy = function() Bitset$new(from = bitset_copy(self$.bitset)),
    to_vector = function() bitset_to_vector(self$.bitset)
  )
)

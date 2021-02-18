#' @title A Bitset Class
#' @description Allow fast integer set operations in R. WARNING: all operations
#' (except `$not`) are in-place so please use `$copy` if you would like to
#' perform an operation without destroying your current bitset.
#' @export Bitset
Bitset <- R6::R6Class(
  'Bitset',
  public = list(
    #' @field .bitset a pointer to the underlying IterableBitset
    .bitset = NULL,

    #' @field max_size the maximum size of the bitset
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

    #' @description insert into the bitset
    #' @param v an integer vector of elements to insert
    insert = function(v) {
      bitset_insert(self$.bitset, v)
      self
    },

    #' @description remove from the bitset
    #' @param v an integer vector of elements to remove
    remove = function(v) {
      bitset_remove(self$.bitset, v)
      self
    },

    #' @description the number of elements in the set
    size = function() bitset_size(self$.bitset),

    #' @description to "bitwise or" or union two Bitsets
    #' @param other the other bitset to combine
    or = function(other) {
      bitset_or(self$.bitset, other$.bitset)
      self
    },

    #' @description to "bitwise and" or intersect two Bitsets
    #' @param other the other bitset to combine
    and = function(other) {
      bitset_and(self$.bitset, other$.bitset)
      self
    },

    #' @description to "bitwise not" or complement a Bitset
    not = function() Bitset$new(from = bitset_not(self$.bitset)),

    #' @description to sample a subset
    #' @param rate the success rate for keeping each element
    sample = function(rate) {
      bitset_sample(self$.bitset, rate)
      self
    },

    #' @description returns a copy the bitset
    copy = function() Bitset$new(from = bitset_copy(self$.bitset)),

    #' @description return an integer vector representing the elements
    #' which are set
    to_vector = function() bitset_to_vector(self$.bitset)
  )
)
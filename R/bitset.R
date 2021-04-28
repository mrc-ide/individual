#' @title A Bitset Class
#' @description This is a data strucutre that compactly stores the presence of 
#' integers in some finite set (\code{max_size}), and can 
#' efficiently perform set operations (union, intersection, complement). 
#' WARNING: all operations (except \code{$not}) are in-place so please use \code{$copy} 
#' if you would like to perform an operation without destroying your current bitset.
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
    #' @param v an integer vector of elements (not indices) to remove
    remove = function(v) {
      bitset_remove(self$.bitset, v)
      self
    },

    #' @description check if elements are in the Bitset 
    #' @param v an integer vector of elements to check. If an element of \code{v} is 
    #' outside the maximum size of the Bitset this is considered an error.
    #' @return a logical vector the same length as \code{v}
    exists = function(v) {
      bitset_exists_vector(b = self$.bitset, v = as.integer(v))
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
    #' This method returns a new Bitset rather than doing in-place modification.
    not = function() Bitset$new(from = bitset_not(self$.bitset)),

    #' @description to "bitwise xor" or get the symmetric difference of two Bitsets
    #' (keep elements in either Bitset but not in their intersection)
    xor = function(other){
      bitset_xor(self$.bitset, other$.bitset)
      self
    },

    #' @description Take the set difference of this Bitset with another
    #' (keep elements of this Bitset which are not in \code{other}).
    set_difference = function(other){
      bitset_set_difference(self$.bitset, other$.bitset)
      self
    },

    #' @description to sample a Bitset
    #' @param rate the success probability for keeping each element, can be
    #' a single value for all elements or a vector with of unique
    #' probabilities for keeping each element
    sample = function(rate) {
      if (length(rate) == 1) {
        bitset_sample(self$.bitset, rate)
      } else {
        bitset_sample_vector(self$.bitset, rate)
      }      
      self
    },

    #' @description returns a copy the bitset
    copy = function() Bitset$new(from = bitset_copy(self$.bitset)),

    #' @description return an integer vector representing the elements
    #' which are set
    to_vector = function() bitset_to_vector(self$.bitset)
  )
)

#' @title Filter a bitset
#' @description This non-modifying function returns a new \code{\link{Bitset}}
#' object of the same maximum size as the original but which only contains
#' those values at the indices specified by the argument \code{other}.
#' Indices in \code{other} may be specified either as a vector of integers or as
#' another bitset. Please note that filtering by another bitset is not a
#' "bitwise and" intersection, and will have the same behavior as providing
#' an equivalent vector of integer indices.
#' @param bitset the \code{\link{Bitset}} to filter
#' @param other the values to keep (may be a vector of intergers or another \code{\link{Bitset}})
#' @export
filter_bitset = function(bitset, other) {
  if ( inherits(other, "Bitset")) {
    return(Bitset$new(from = filter_bitset_bitset(bitset$.bitset, other$.bitset)))
  } else {
    return(Bitset$new(from = filter_bitset_vector(bitset$.bitset, as.integer(other))))
  }
}

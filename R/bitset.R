#' @title A Bitset Class
#' @description This is a data structure that compactly stores the presence of
#' integers in some finite set (\code{max_size}), and can
#' efficiently perform set operations (union, intersection, complement, symmetric
#' difference, set difference).
#' WARNING: All operations are in-place so please use \code{$copy}
#' if you would like to perform an operation without destroying your current bitset.
#' @importFrom R6 R6Class
#' @export
Bitset <- R6Class(
  'Bitset',
  public = list(
    #' @field .bitset a pointer to the underlying IterableBitset.
    .bitset = NULL,

    #' @field max_size the maximum size of the bitset.
    max_size = 0,

    #' @description create a bitset.
    #' @param size the size of the bitset.
    #' @param from pointer to an existing IterableBitset to use; if \code{NULL}
    #' make empty bitset, otherwise copy existing bitset.
    initialize = function(size, from = NULL) {
      if (is.null(from)) {
        self$.bitset <- create_bitset(size)
      } else {
        stopifnot(inherits(from, "externalptr"))
        self$.bitset <- from
      }
      self$max_size <- bitset_max_size(self$.bitset)
    },

    #' @description insert into the bitset.
    #' @param v an integer vector of elements to insert.
    insert = function(v) {
      bitset_insert(self$.bitset, v)
      self
    },

    #' @description remove from the bitset.
    #' @param v an integer vector of elements (not indices) to remove.
    remove = function(v) {
      bitset_remove(self$.bitset, v)
      self
    },

    #' @description clear the bitset.
    clear = function() {
      bitset_clear(self$.bitset)
      self
    },

    #' @description get the number of elements in the set.
    size = function() bitset_size(self$.bitset),

    #' @description to "bitwise or" or union two bitsets.
    #' @param other the other bitset.
    or = function(other) {
      bitset_or(self$.bitset, other$.bitset)
      self
    },

    #' @description to "bitwise and" or intersect two bitsets.
    #' @param other the other bitset.
    and = function(other) {
      bitset_and(self$.bitset, other$.bitset)
      self
    },

    #' @description to "bitwise not" or complement a bitset.
    #' @param inplace whether to overwrite the current bitset.
    not = function(inplace) {
      if (missing(inplace)) {
        warning(paste(
          "DEPRECATED: Future versions of Bitset$not will be in place",
          "to be consistent with other bitset operations.",
          "To copy this bitset please use the copy method.",
          "To suppress this warning, please set the `inplace` argument.",
          sep = " "
        ))
        inplace <- FALSE
      }
      Bitset$new(from = bitset_not(self$.bitset, inplace))
    },

    #' @description to "bitwise xor" or get the symmetric difference of two bitset
    #' (keep elements in either bitset but not in their intersection).
    #' @param other the other bitset.
    xor = function(other){
      bitset_xor(self$.bitset, other$.bitset)
      self
    },

    #' @description Take the set difference of this bitset with another
    #' (keep elements of this bitset which are not in \code{other}).
    #' @param other the other bitset.
    set_difference = function(other){
      bitset_set_difference(self$.bitset, other$.bitset)
      self
    },

    #' @description sample a bitset.
    #' @param rate the success probability for keeping each element, can be
    #' a single value for all elements or a vector of unique
    #' probabilities for keeping each element.
    sample = function(rate) {
      stopifnot(is.finite(rate), !is.null(rate))
      if (length(rate) == 1) {
        bitset_sample(self$.bitset, rate)
      } else {
        bitset_sample_vector(self$.bitset, rate)
      }
      self
    },

    #' @description choose k random items in the bitset
    #' @param k the number of items in the bitset to keep. The selection of
    #' these k items from N total items in the bitset is random, and
    #' k should be chosen such that \eqn{0 \le k \le N}.
    choose = function(k) {
      stopifnot(is.finite(k))
      stopifnot(k <= bitset_size(self$.bitset))
      stopifnot(k >= 0)
      if (k < self$max_size) {
        bitset_choose(self$.bitset, as.integer(k))
      }
      self
    },

    #' @description returns a copy the bitset.
    copy = function() Bitset$new(from = bitset_copy(self$.bitset)),

    #' @description return an integer vector of the elements
    #' stored in this bitset.
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
    if (other$size() > 0) {
      return(Bitset$new(from = filter_bitset_bitset(bitset$.bitset, other$.bitset)))
    } else {
      return(Bitset$new(size = bitset$max_size))
    }
  } else {
    if (length(other) > 0) {
      return(Bitset$new(from = filter_bitset_vector(bitset$.bitset, as.integer(other))))
    } else {
      return(Bitset$new(size = bitset$max_size))
    }
  }
}

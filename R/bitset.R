#' Generate documentation for an R6-like method
#'
#' The Bitset class is implemented as a named list with closures that capture
#' the environment. By default, roxygen2 generates terrible documentation for
#' it since it isn't a typical way of doing things.
#'
#' This method generates a snippet of Rd code for a method, in a way that
#' resembles the code roxygen2 generates for R6 methods.
#'
#' @noRd
bitset_method_doc <- function(name, description, static = FALSE, ...) {
  lines <- character()
  push <- function(...) lines <<- c(lines, ...)

  arguments <- list(...)
  argnames <- paste(names(arguments), collapse=", ")
  receiver <- if (static) "Bitset" else "b"

  push("\\if{html}{\\out{<hr>}}")
  push(paste0("\\subsection{Method \\code{", name, "()}}{"))
  push(description)
  push("\\subsection{Usage}{")
  push(sprintf("\\preformatted{%s$%s(%s)}", receiver, name, argnames))
  push("}")
  if (length(arguments) > 0) {
    push("\\subsection{Arguments}{")
    push("\\describe{")
    push(sprintf("\\item{\\code{%s}}{%s}", names(arguments), arguments))
    push("}")
    push("}")
  }
  push("}")

  cat(paste(lines, collapse="\n"))
}

#' @title A Bitset Class
#' @description This is a data structure that compactly stores the presence of
#' integers in some finite set (\code{max_size}), and can
#' efficiently perform set operations (union, intersection, complement, symmetric
#' difference, set difference).
#' WARNING: All operations are in-place so please use \code{$copy}
#' if you would like to perform an operation without destroying your current bitset.
#'
#' This class is defined as a named list for performance reasons, but for most
#' intents and purposes it behaves just like an R6 class.
#' @format NULL
#' @usage NULL
#' @docType NULL
#' @keywords NULL
#' @export
#' @section Methods:
Bitset <- list(
  #' ```{r echo=FALSE, results="asis"}
  #' bitset_method_doc(
  #'   "new",
  #'   "create a bitset.",
  #'   static = TRUE,
  #'   size = "the size of the bitset.",
  #'   from = "pointer to an existing IterableBitset to use; if \\code{NULL}
  #'           make empty bitset, otherwise copy existing bitset."
  #' )
  #' ```
  new = function(size, from = NULL) {
    if (is.null(from)) {
      bitset <- create_bitset(size)
    } else {
      stopifnot(inherits(from, "externalptr"))
      bitset <- from
    }
    max_size <- bitset_max_size(bitset)

    self <- list(
      .bitset = bitset,
      max_size = max_size,

      #' ```{r echo=FALSE, results="asis"}
      #' bitset_method_doc(
      #'   "insert",
      #'   "insert into the bitset.",
      #'   v = "an integer vector of elements to insert.")
      #' ```
      insert = function(v) {
        bitset_insert(self$.bitset, v)
        self
      },

      #' ```{r echo=FALSE, results="asis"}
      #' bitset_method_doc(
      #'   "remove",
      #'   "remove from the bitset.",
      #'   v = "an integer vector of elements (not indices) to remove.")
      #' ```
      remove = function(v) {
        bitset_remove(self$.bitset, v)
        self
      },

      #' ```{r echo=FALSE, results="asis"}
      #' bitset_method_doc(
      #'   "clear",
      #'   "clear the bitset.")
      #' ```
      clear = function() {
        bitset_clear(self$.bitset)
        self
      },

      #' ```{r echo=FALSE, results="asis"}
      #' bitset_method_doc(
      #'   "size",
      #'   "get the number of elements in the set.")
      #' ```
      size = function() bitset_size(self$.bitset),

      #' ```{r echo=FALSE, results="asis"}
      #' bitset_method_doc(
      #'   "or",
      #'   "to \"bitwise or\" or union two bitsets.",
      #'   other = "the other bitset.")
      #' ```
      or = function(other) {
        bitset_or(self$.bitset, other$.bitset)
        self
      },

      #' ```{r echo=FALSE, results="asis"}
      #' bitset_method_doc(
      #'   "and",
      #'   "to \"bitwise and\" or intersect two bitsets.",
      #'   other = "the other bitset.")
      #' ```
      and = function(other) {
        bitset_and(self$.bitset, other$.bitset)
        self
      },

      #' ```{r echo=FALSE, results="asis"}
      #' bitset_method_doc(
      #'   "not",
      #'   "to \"bitwise not\" or complement a bitset.",
      #'   inplace = "whether to overwrite the current bitset, default = TRUE")
      #' ```
      not = function(inplace = TRUE) {
        Bitset$new(from = bitset_not(self$.bitset, inplace))
      },

      #' ```{r echo=FALSE, results="asis"}
      #' bitset_method_doc(
      #'   "xor",
      #'   "to \"bitwise xor\" get the symmetric difference of two bitset
      #'    (keep elements in either bitset but not in their intersection).",
      #'   other = "the other bitset.")
      #' ```
      xor = function(other){
        bitset_xor(self$.bitset, other$.bitset)
        self
      },

      #' ```{r echo=FALSE, results="asis"}
      #' bitset_method_doc(
      #'   "set_difference",
      #'   "Take the set difference of this bitset with another
      #'    (keep elements of this bitset which are not in \\code{other})",
      #'   other = "the other bitset.")
      #' ```
      set_difference = function(other){
        bitset_set_difference(self$.bitset, other$.bitset)
        self
      },

      #' ```{r echo=FALSE, results="asis"}
      #' bitset_method_doc(
      #'   "sample",
      #'   "sample a bitset.",
      #'   rate = "the success probability for keeping each element, can be
      #'           a single value for all elements or a vector of unique
      #'           probabilities for keeping each element.")
      #' ```
      sample = function(rate) {
        stopifnot(is.finite(rate), !is.null(rate))
        if (length(rate) == 1) {
          bitset_sample(self$.bitset, rate)
        } else {
          bitset_sample_vector(self$.bitset, rate)
        }
        self
      },

      #' ```{r echo=FALSE, results="asis"}
      #' bitset_method_doc(
      #'   "choose",
      #'   "choose k random items in the bitset.",
      #'   k = "the number of items in the bitset to keep. The selection of
      #'        these k items from N total items in the bitset is random, and
      #'        k should be chosen such that \\eqn{0 \\le k \\le N}.")
      #' ```
      choose = function(k) {
        stopifnot(is.finite(k))
        stopifnot(k <= bitset_size(self$.bitset))
        stopifnot(k >= 0)
        if (k < self$max_size) {
          bitset_choose(self$.bitset, as.integer(k))
        }
        self
      },

      #' ```{r echo=FALSE, results="asis"}
      #' bitset_method_doc(
      #'   "copy",
      #'   "returns a copy of the bitset.")
      #' ```
      copy = function() Bitset$new(from = bitset_copy(self$.bitset)),

      #' ```{r echo=FALSE, results="asis"}
      #' bitset_method_doc(
      #'   "to_vector",
      #'   "return an integer vector of the elements stored in this bitset.")
      #' ```
      to_vector = function() bitset_to_vector(self$.bitset)
    )

    class(self) <- 'Bitset'
    self
  }
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

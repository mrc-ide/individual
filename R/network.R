#' @title A static network class
#' @description A thing
#' @importFrom network get.network.attribute
#' @export
Network <- R6::R6Class(
  'Network',
  public = list(
    #' @field .contacts a pointer to the underlying IntegerVariable
    .contacts = NULL,

    #' @field .network a \code{\link[network]{network}} object
    .network = NULL,

    #' @description create a network
    #' @param g a \code{\link[network]{network}} object
    #' @param n the number of nodes (verticies)
    initialize = function(g) {
        stopifnot( inherits(g, "network") )
        n <- get.network.attribute(g, "n")
        self$.network <- g
        self$.contacts <- IntegerVariable$new(initial_values = rep(0, n))
    },

    #' @description insert into the bitset
    #' @param v an integer vector of elements to insert
    insert = function(v) {
      bitset_insert(self$.bitset, v)
      self
    }

  )
)

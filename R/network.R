#' @title A static network class
#' @description This class maintains an individual level contact network, using a
#' \code{\link[network]{network}} object to store and access edges. It only
#' handles static networks but is able to quickly compute a vector of contacts,
#' the number of infectious contacts on each susceptible. This vector can be used
#' to compute the force of infection on those susceptible individuals. It is able
#' to store both directed and undirected networks.
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
    initialize = function(g) {
        stopifnot( inherits(g, "network") )
        n <- get.network.attribute(g, "n")
        self$.network <- g
        self$.contacts <- IntegerVariable$new(initial_values = rep(0, n))
    },

    #' @description insert into the bitset
    #' @param S a \code{\link{Bitset}} of susceptible individuals
    #' @param I a \code{\link{Bitset}} of infectious individuals
    compute_contacts = function(S, I) {
        stopifnot( inherits(S, "Bitset") & inherits(I, "Bitset") )
        network_get_contacts(
            g = self$.network, 
            contacts = self$.contacts$.variable,
            S = S$.bitset,
            I = I$.bitset
        )
    },

    #' @description insert into the bitset
    get_contacts = function() {
        self$.contacts
    }

  )
)

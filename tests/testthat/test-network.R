test_that("Network object computes proper contact vector on unweighted random graph", {
    
    N <- 50

    # make random graph
    edge_prob <- 0.075
    adj_mat <- matrix(rbinom(n = N^2,size = 1,prob = edge_prob),N,N)
    g <- as.network(adj_mat)

    # set up the population
    I0 <- 25
    S0 <- N - I0
    health_states <- c("S","I","R")
    health_states_t0 <- rep("S",N)
    health_states_t0[sample.int(n = N,size = I0)] <- "I"
    health <- CategoricalVariable$new(categories = health_states,initial_values = health_states_t0)

    # states
    S <- health$get_index_of("S")
    I <- health$get_index_of("I")

    # network
    net <- Network$new(g)

    # compute contacts
    net$compute_contacts(S = S,I = I)

    contacts <- net$get_contacts()$get_values()

    # manual comparison
    contacts_comp <- IntegerVariable$new(initial_values = rep(0, N))

    contact_bitset <- Bitset$new(N) 
    empty_bitset <- Bitset$new(N)

    I_vec <- I$to_vector()

    # I's send out contacts
    for (i in seq_along(I_vec)) {
        
        # clear out the extra bitset
        contact_bitset$and(empty_bitset)
        
        # S_i are susceptibles being contacted by i-th I person
        S_i <- S$copy()
        S_i$and(contact_bitset$insert(v = get.neighborhood(x = g,v = I_vec[i],type = "out")))
        
        # add to their contacts
        contacts_comp$queue_update(values = contacts_comp$get_values(S_i) + 1,index = S_i)
        contacts_comp$.update()
    }

    expect_equal(
        contacts,
        contacts_comp$get_values()
    )
})

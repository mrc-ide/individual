test_that("bernoulli_process moves a sane number of individuals around", {
  state <- CategoricalVariable$new(c('S', 'I'), c(rep('S', 10), 'I'))
  bernoulli_process(state, 'S', 'I', .5)(1)
  state$.update()
  n_s <- state$get_index_of('S')$size()
  n_i <- state$get_index_of('I')$size()
  expect_lte(n_s, 10)
  expect_gte(n_i, 1)
  expect_equal(n_s + n_i, 11)
})

test_that("update_state_listener updates the state correctly", {
  state <- CategoricalVariable$new(c('S', 'I'), c(rep('S', 10), 'I'))
  event <- TargetedEvent$new(11)
  event$add_listener(update_category_listener(state, 'I'))
  event$schedule(c(2, 5), 1)
  event$.tick()
  event$.process()
  state$.update()
  expect_setequal(state$get_index_of('S')$to_vector(), c(1, 3:4, 6:10))
  expect_setequal(state$get_index_of('I')$to_vector(), c(11, 2, 5))
})

test_that("reschedule_listener schedules the correct update", {
  event <- TargetedEvent$new(10)
  followup <- TargetedEvent$new(10)
  event$add_listener(reschedule_listener(followup, 1))
  event_listener <- mockery::mock()
  event$add_listener(event_listener)
  followup_listener <- mockery::mock()
  followup$add_listener(followup_listener)

  #time = 0
  event$schedule(c(2, 4), 2)

  #time = 1
  event$.process()
  followup$.process()
  mockery::expect_called(followup_listener, 0)
  mockery::expect_called(event_listener, 0)
  event$.tick()
  followup$.tick()

  #time = 2
  event$.process()
  followup$.process()
  mockery::expect_called(followup_listener, 0)
  mockery::expect_called(event_listener, 0)
  event$.tick()
  followup$.tick()

  #time = 3
  event$.process()
  followup$.process()
  mockery::expect_called(event_listener, 1)
  mockery::expect_called(followup_listener, 0)
  event$.tick()
  followup$.tick()

  #time = 4
  event$.process()
  followup$.process()
  mockery::expect_called(event_listener, 1)
  mockery::expect_called(followup_listener, 1)
  event$.tick()
  followup$.tick()
  expect_targeted_listener(event_listener, 1, 3, target = c(2, 4))
  expect_targeted_listener(followup_listener, 1, 4, target = c(2, 4))
})

test_that("Multinomial process samples probabilities correctly", {
  n <- 1e4
  state <- CategoricalVariable$new(categories = LETTERS[1:5],initial_values = rep("A",n))
  l_p <- 0.9
  d_p <- c(0.5,0.25,0.2,0.05)
  mult_process <- fixed_probability_multinomial_process(
    variable = state,
    source_state = 'A',
    destination_states = LETTERS[2:5],
    rate = l_p,
    destination_probabilities = d_p
  )
  individual:::execute_any_process(mult_process,1)
  state$.update()
  state_new <- sapply(X = LETTERS[1:5],FUN = function(l){state$get_size_of(l)})

  state_exp <- setNames(object = rep(0,5),nm = LETTERS[1:5])
  state_exp['A'] <- n*(1-l_p)
  state_exp['B'] <- n*l_p*d_p[1]
  state_exp['C'] <- n*l_p*d_p[2]
  state_exp['D'] <- n*l_p*d_p[3]
  state_exp['E'] <- n*l_p*d_p[4]

  pval <- chisq.test(x = state_new,y = state_exp, simulate.p.value = TRUE)$p.value
  expect_gte(pval,0.985)
})

test_that("Overdispersed multinomial process samples probabilities correctly", {
  n <- 1e4
  state <- CategoricalVariable$new(categories = LETTERS[1:3],initial_values = rep("A",n))
  r_v <- c(
    rep(0, 2.5e3),
    rep(0.5, 5e3),
    rep(1, 2.5e3)
  )
  no_leave <- 1:2.5e3
  maybe_leave <- (tail(no_leave,1)+1):(tail(no_leave,1)+5e3)
  yes_leave <- (tail(maybe_leave,1)+1):(tail(maybe_leave,1)+2.5e3)

  rate <- DoubleVariable$new(initial_values = r_v)

  d_p <- c(0.75,0.25)
  mult_process <- multi_probability_multinomial_process(
    variable = state,
    source_state = 'A',
    destination_states = LETTERS[2:3],
    rate_variable = rate,
    destination_probabilities = d_p
  )
  individual:::execute_any_process(mult_process,1)
  state$.update()

  state_a <- state$get_index_of(values = "A")$to_vector()
  state_b <- state$get_index_of(values = "B")$to_vector()
  state_c <- state$get_index_of(values = "C")$to_vector()

  b_prop <- length(state_b) / (length(state_b)+length(state_c))

  expect_false(any(yes_leave %in% state_a))
  expect_true(all(no_leave %in% state_a))
  expect_true( (b_prop > 0.7) & (b_prop < 0.8) )
})

test_that("Overdispersed multinomial process doesn't move people it shouldn't", {

  n <- 100
  state <- CategoricalVariable$new(categories = LETTERS[1:3],initial_values = c(rep("A",n-1),"C"))
  rate <- DoubleVariable$new(initial_values = rep(1,n))

  d_p <- c(1)
  mult_process <- multi_probability_multinomial_process(
    variable = state,
    source_state = 'A',
    destination_states = LETTERS[2],
    rate_variable = rate,
    destination_probabilities = d_p
  )
  individual:::execute_any_process(mult_process,1)
  state$.update()

  state_a <- state$get_index_of(values = "A")$to_vector()
  state_b <- state$get_index_of(values = "B")$to_vector()
  state_c <- state$get_index_of(values = "C")$to_vector()

  expect_true( all(state_b == 1:99) )
  expect_true( state_c == 100 )
})

test_that("Overdispersed bernoulli process works correctly", {
  state <- CategoricalVariable$new(c('S', 'I'), c(rep('S', 10), 'I'))
  r_v <- c(
    rep(1,3),
    rep(0.5,5),
    rep(0,2),
    1
  )
  rate <- DoubleVariable$new(initial_values = r_v)
  multi_bp <- multi_probability_bernoulli_process(
    variable = state,
    from = "S",
    to = "I",
    rate_variable = rate 
  )

  individual:::execute_any_process(multi_bp,1)
  state$.update()

  state_s <- state$get_index_of(values = "S")$to_vector()
  state_i <- state$get_index_of(values = "I")$to_vector()

  expect_true(all(1:3 %in% state_i))
  expect_true(all(9:10 %in% state_s))
})

test_that("age-structured infection process gives same results as R version", {

  N <- 1e3
  I0 <- 1e2
  S0 <- N - I0
  dt <- 0.1
  p <- 0.5 
  c <- 0.5

  health_states_init <- rep("S",N)
  health_states_init[sample.int(n = N,size = I0)] <- "I"

  Nage <- 10
  c_mixing <- matrix(data = c/Nage,nrow = Nage,ncol = Nage)

  age <- sample(x = 1:Nage,size = N,replace = T)

  health_R <- CategoricalVariable$new(categories = c("S","I","R"),initial_values = health_states_init)
  age_R <- IntegerVariable$new(initial_values = age)

  health_cpp <- CategoricalVariable$new(categories = c("S","I","R"),initial_values = health_states_init)
  age_cpp <- IntegerVariable$new(initial_values = age)

  infection_age_process_R <- function(t){
    # number of infectious individuals in each age group
    I <- sapply(X = 1:Nage,FUN = function(a){
      I_a <- health_R$get_index_of("I")
      I_a$and(age_R$get_index_of(a))
      I_a$size()
    })
    # total population size of each age group
    N <- sapply(X = 1:Nage,FUN = function(a){
      age_R$get_size_of(a)
    })
    # compute FOI
    for(a in 1:Nage){
      foi <- p * sum(c_mixing[a,] * (I/N)) 
      S_a <- health_R$get_index_of("S")$and(age_R$get_index_of(a))
      S_a$sample(rate = pexp(q = foi * dt))
      health_R$queue_update(value = "I",index = S_a)
    }
  }

  infection_age_process_cpp <- infection_age_process(
    state = health_cpp,
    susceptible = "S",
    exposed = "I",
    infectious = "I",
    age = age_cpp,
    age_bins = Nage,
    p = p,
    dt = dt,
    mixing = c_mixing
  )

  set.seed(9352511L)

  infection_age_process_R(1)

  set.seed(9352511L)

  execute_process(process = infection_age_process_cpp,timestep = 1)

  health_R$.update()
  health_cpp$.update()
  
  expect_equal(
    health_R$get_index_of("I")$to_vector(),
    health_cpp$get_index_of("I")$to_vector()
  )
})
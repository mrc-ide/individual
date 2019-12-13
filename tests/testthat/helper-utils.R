#' Sorts a state simulation by timestep and state making it comparable to others
#' @param df to sort
sort_simulation <- function(df) {
  df <- df[with(df, order(timestep, state)), c('timestep', 'state')]
  rownames(df) <- NULL
  df
}

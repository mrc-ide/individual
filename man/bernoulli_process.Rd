% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/prefab.R
\name{bernoulli_process}
\alias{bernoulli_process}
\title{Bernoulli process}
\usage{
bernoulli_process(variable, from, to, rate)
}
\arguments{
\item{variable}{a categorical variable.}

\item{from}{a string representing the source category.}

\item{to}{a string representing the destination category.}

\item{rate}{the probability to move individuals between categories.}
}
\value{
a function which can be passed as a process to \code{\link{simulation_loop}}.
}
\description{
Simulate a process where individuals in a given \code{from} state
advance to the \code{to} state each time step with probability \code{rate}.
}

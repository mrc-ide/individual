#
# bench-render.R
#
# Created on: 22 Dec 2023
#   Author: pl2113
#

library(individual)
library(bench)
library(ggplot2)
library(scales)

source("./tests/performance/utils.R")

render_single <- bench::press(
  timesteps=floor(10^seq(3,6,0.25)),
  {
    render <- Render$new(timesteps)
    bench::mark(
      min_iterations = 50,
      check = FALSE,
      render={
        # Use timesteps/2 to write in the middle of the array
        render$render("data", 0.5, timesteps/2)
      })
  })

render_single %>%
  simplify_bench_output() %>%
  ggplot() +
  aes(x = timesteps, y = as.numeric(time), color=expression, fill=expression, group=as.factor(timesteps):expression) +
  geom_violin(position=position_dodge(width=0.02), alpha=0.3) +
  labs(y="time", fill="expression", color="expression") +
  scale_x_continuous(trans='log10', n.breaks=6, labels = label_comma()) +
  scale_y_continuous(trans='log10', n.breaks=6, labels = function(x) format(bench::as_bench_time(x))) +
  ggtitle("Render single timestep benchmark")

render_all <- bench::press(
  timesteps=floor(10^seq(3,5,0.25)),
  {
    data <- runif(timesteps)
    bench::mark(
      min_iterations = 5,
      check = FALSE, 
      filter_gc = FALSE,
      render_all={
        render <- Render$new(timesteps)
        mapply(function(x, i) render$render("data", x, i), data, seq_along(data))
      })
  })

render_all %>%
  simplify_bench_output(filter_gc=FALSE) %>%
  ggplot() +
  aes(x = timesteps, y = as.numeric(time), color=expression, fill=expression, group=as.factor(timesteps):expression) +
  geom_violin(position=position_dodge(width=0.01), alpha=0.3) +
  labs(y="time", fill="expression", color="expression") +
  scale_x_continuous(trans='log10', n.breaks=6, labels = label_comma()) +
  scale_y_continuous(trans='log10', n.breaks=6, labels = function(x) format(bench::as_bench_time(x))) +
  ggtitle("Render all timesteps benchmark")


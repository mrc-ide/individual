#' @title A static network class
#' @description This is a data strucutre that compactly stores the presence of 
#' integers in some finite set (\code{max_size}), and can 
#' efficiently perform set operations (union, intersection, complement). 
#' WARNING: all operations (except \code{$not}) are in-place so please use \code{$copy} 
#' if you would like to perform an operation without destroying your current bitset.
#' @export Bitset
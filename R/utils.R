#' Creates a DataClass design pattern
#' readonly class for collecting related fields
#' implementation inspired by https://github.com/r-lib/R6/issues/186
#' @param classname is the name of the class
#' @param fields is a sequence of readonly fields to create
#' @param initialize is the initialisation funtion
#' @param print_fields are the fields to print
DataClass <- function(classname, fields, initialize, print_fields = NULL) {
  private = list()
  active = list()
  for (field in fields) {
    field_name <- to_private(field)
    private[[field_name]] <- 0
    active[[field]] <- readonly_accessor(field, field_name)
  }

  if (is.null(print_fields)) {
    print <- print_dataclass(classname, list())
  } else {
    print <- print_dataclass(classname, print_fields)
  }

  R6::R6Class(
    classname,
    active = active,
    private = private,
    public = list(
      initialize = initialize,
      print = print
    )
  )
}

#' Create a private fieldname from an accessor name
#' @param name to convert
to_private <- function(name) {
  paste('.', name, sep = '')
}

#' Creates a readonly accessor for a private field of an R6 class
#' @param active the name of the accessor you want to create
#' @param field the field to create the accessor for
readonly_accessor <- function(active, field) {
  eval(
    substitute(
      function(value) {
        if (missing(value)) {
          private[[field]]
        } else {
          stop(paste(active, 'is read only'))
        }
      },
      list(field = field, active = active)
    )
  )
}

#' Creates a generic print function for a DataClass
#' @param class the data classname
#' @param fields fields to print
print_dataclass <- function(class, fields) {
  eval(
    substitute(
      function() {
        cat(class, ': \n', sep='')
        for (field in fields) {
          cat('  ', field, ': ' , self[[field]], '\n', sep='')
        }
        invisible(self)
      },
      list(class = class, fields = fields)
    )
  )
}

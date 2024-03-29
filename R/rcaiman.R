#' @import methods
#' @import raster
#' @importFrom magrittr %>%
#' @importFrom stats lm poly coefficients median IQR sd splinefun
#' @importFrom colorspace sRGB
NULL

# https://groups.google.com/g/rdevtools/c/qT6cJt6DLJ0
# spurious importFrom to avoid note
#' @importFrom Rdpack c_Rd
#' @importFrom rgdal compare_CRS
NULL


# https://github.com/tidyverse/magrittr/issues/29
#' @importFrom utils globalVariables
NULL
if(getRversion() >= "2.15.1")  utils::globalVariables(c("."))

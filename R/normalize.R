#' Normalize data
#'
#' Normalize data laying between \code{mn} and \code{mx} in the range \code{0}
#' to \code{1}. Data greater than \code{mx} get values greater than \code{1} in
#' a proportional fashion. Conversely, data less than \code{mn} get values less
#' than \code{0}.
#'
#' @param r \code{\linkS4class{Raster}} or numeric vector.
#' @param mn Numeric vector of length one. Minimum expected value. Defaults is
#'   equivalent to the minimum value from \code{r}.
#' @param mx Numeric vector of length one. Maximum expected value. Defaults is
#'   equivalent to the maximum value from \code{r}.
#'
#' @export
#'
#' @return An object from the same class than \code{r} with values from \code{r}
#'   linearly rescaled to make \code{mn} equal to zero and \code{mx} equal to
#'   one. Therefore, if \code{mn} and \code{mx} do not match with the actuals
#'   minimum and maximum from \code{r}, the ourput will not cover the 0-to-1
#'   range.
#'
#' @seealso \code{\link{gbc}}
#' @family Tools functions
#'
#' @examples
#' normalize(read_caim(), 0, 255)
normalize <- function(r, mn = NULL, mx = NULL) {
  if (is.null(mn)) mn <- .get_min(r)
  if (is.null(mx)) mx <- .get_max(r)
  stopifnot(length(mn) == 1)
  stopifnot(length(mx) == 1)
  (r - mn) / (mx - mn)
}

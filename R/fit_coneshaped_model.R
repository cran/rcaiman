#' Fit cone-shaped model
#'
#' Generate the digital numbers of the whole sky through statistical modelling.
#'
#' An explanation of this function can be found on
#' \insertCite{Diaz2018;textual}{rcaiman}, under the heading \emph{Estimation of
#' the sky DN as a previous step for our method}.
#'
#' If you use this function in your research, please cite
#' \insertCite{Diaz2018}{rcaiman}.
#'
#' @param r \linkS4class{RasterLayer}. A normalized greyscale image. Typically,
#'   the blue channel extracted from an hemispherical photograph. Please see
#'   \code{\link{read_caim}} and \code{\link{normalize}}.
#' @param z \linkS4class{RasterLayer}. The result of a call to
#'   \code{\link{zenith_image}}.
#' @param a \linkS4class{RasterLayer}. The result of a call to
#'   \code{\link{azimuth_image}}.
#' @param bin \linkS4class{RasterLayer}. A working binarized image. This should
#'   be a preliminary binarization of \code{r}. If the function returns
#'   \code{NA}, then the quality of this input should be revised.
#' @param filling_source \linkS4class{RasterLayer}. Default is \code{NULL}.
#'   Above-canopy photograph. This image should contain pixels with sky DN
#'   values and \code{NA} in all the other pixels. A photograph taken
#'   immediately after or before taking \code{r} under the open sky with the
#'   same equipment and configuration is a very good option. The ideal option is
#'   one taken at the same time and place but above the canopy. The orientation
#'   relative to the North must be the same than for \code{r}.
#' @param prob Logical vector of length one. Probability for
#'   \code{\link[stats]{quantile}} calculation. See reference
#'   \insertCite{Diaz2018;textual}{rcaiman}.
#' @param use_azimuth_angle Logical vector of length one. If \code{TRUE},
#'   Equation 4 from \insertCite{Diaz2018;textual}{rcaiman} is used: \eqn{sDN =
#'   a + b \cdot \theta + c  \cdot \theta^2 + d  \cdot sin(\phi) + e  \cdot
#'   cos(\phi)}, where \eqn{sDN} is sky digital number, \eqn{a,b,c,d} and
#'   \eqn{e} are coefficients, \eqn{\theta} is zenith angle, and \eqn{\phi} is
#'   azimuth angle. If \code{FALSE}, a simplified version based on
#'   \insertCite{Wagner2001;textual}{rcaiman} is used: \eqn{sDN = a + b \cdot
#'   \theta + c  \cdot \theta^2}.
#' @param parallel Logical vector of length one. Allows parallel processing.
#' @param free_cores Numeric vector of length one. This number is subtracted to
#'   the number of cores detected by \code{\link[parallel]{detectCores}}.
#'
#' @return A list with two objects, one of class \linkS4class{RasterLayer} and
#'   the other of class \code{lm} (see \code{\link[stats]{lm}}).
#' @export
#'
#' @family MBLT functions
#'
#' @references \insertAllCited{}
#'
#' @examples
#' \dontrun{
#' path <- system.file("external/4_D_2_DSCN4502.JPG", package = "rcaiman")
#' r <- read_caim(path, c(1280, 960) - 745, 745 * 2, 745 * 2)
#' z <- zenith_image(ncol(r), lens("Nikon_FCE9"))
#' a <- azimuth_image(z)
#' blue <- gbc(r$Blue)
#' bin <- find_sky_pixels(blue, z, a)
#' sky <- fit_coneshaped_model(blue, z, a, bin, parallel = FALSE)
#' plot(sky$image)
#' persp(sky$image, theta = 90, phi = 0) #a flipped rounded cone!
#' }
fit_coneshaped_model <- function(r, z, a, bin,
                                 prob = 0.95,
                                 filling_source = NULL,
                                 use_azimuth_angle = TRUE,
                                 parallel = TRUE,
                                 free_cores = 0) {
  .check_if_r_z_and_a_are_ok(r, z, a)
  if (!is.null(filling_source)) compareRaster(bin, filling_source)
  compareRaster(bin, r)
  compareRaster(z, r)
  compareRaster(z, a)

  fun <- function(x, ...) quantile(x, prob, na.rm = TRUE)

  blue <- r
  rm(r)
  blue[!bin] <- NA
  rm(bin)

  if (!is.null(filling_source)) blue <- cover(blue, filling_source)

  g <- sky_grid_segmentation(z, a, 5)
  # objects starting with UPPERCASE are vectors instead of images
  Blue <- extract_feature(blue, g, fun, return_raster = FALSE)
  rm(g)

  Zenith <- as.numeric(substr(names(Blue), 4, 5)) * 5 - 5 / 2
  Azimuth <- trunc(as.numeric(names(Blue)) / 1000) * 5 - 5 / 2

  # Filter out saturated
  index <- Blue < 1
  Blue <- Blue[index]
  Zenith <- Zenith[index]
  Azimuth <- Azimuth[index]

  # Filter out NA
  index <- !is.na(Blue)
  Blue <- Blue[index]
  Zenith <- Zenith[index]
  Azimuth <- Azimuth[index]

  if (length(Blue) > 30) {
    if (use_azimuth_angle) {
      model <- lm(Blue ~ poly(Zenith, 2, raw = TRUE) +
        sin(Azimuth * pi / 180) + cos(Azimuth * pi / 180))

      # only to avoid note from check, code is OK without this line.
      b <- d <- e <- NA

      skyFun <- function(z, azimuth) {
        x <- coefficients(model)
        x[is.na(x)] <- 0
        for (i in 1:5) assign(letters[i], x[i])
        a + b * z + c * z^2 +
          d * sin(azimuth * pi / 180) + e * cos(azimuth * pi / 180)
      }
    } else {
      model <- lm(Blue ~ poly(Zenith, 2, raw = TRUE))
      skyFun <- function(z, azimuth) {
        x <- coefficients(model)
        x[is.na(x)] <- 0
        for (i in 1:5) assign(letters[i], x[i])
        a + b * z + c * z^2
      }
    }


    no_threads <- parallel::detectCores() - free_cores
    bs <- blockSize(z, round(ncell(z) / no_threads))

    if (parallel) {

      # go parallel

      Values <- list()
      for (u in 1:bs$n) {
        Values[[u]] <- data.frame(
          z = getValues(z, row = bs$row[u], nrows = bs$nrows[u]),
          azimuth = getValues(a, row = bs$row[u], nrows = bs$nrows[u])
        )
      }

      ## Initiate cluster
      cl <- parallel::makeCluster(no_threads)
      parallel::clusterExport(cl, c("skyFun", "model"), environment())
      out <- parallel::parLapply(cl, Values, function(x) skyFun(x$z, x$azimuth))

      ## finish
      parallel::stopCluster(cl)
    } else {
      Values <- list()
      for (u in 1:bs$n) {
        Values[[u]] <- data.frame(
          z = getValues(z, row = bs$row[u], nrows = bs$nrows[u]),
          azimuth = getValues(a, row = bs$row[u], nrows = bs$nrows[u])
        )
      }
      out <- lapply(Values, function(x) skyFun(x$z, x$azimuth))
    }

    z[] <- unlist(out)
    return(list(image = z, model = model))
  } else {
    return(NA)
  }
}

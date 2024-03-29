#' Enhance canopy image
#'
#' This function is presented in \insertCite{Diaz2015;textual}{rcaiman}. It uses
#' the color perceptual attributes to enhance the contrast between the sky and
#' plants through fuzzy classification. Color has three different perceptual
#' attributes: hue, lightness, and chroma. The algorithm was developed following
#' this premise: the color of the sky is different from the color of plants. It
#' performs the next classification rules, here expressed in natural language:
#' clear sky is blue and clouds decrease its chroma; if clouds are highly dense,
#' then the sky is achromatic, and, in such cases, it can be light or dark;
#' everything that does not match this description is not sky. These linguistic
#' rules were translated to math language by means of fuzzy logic.
#'
#' This is a pixel-wise methodology that evaluates the possibility for a pixel
#' to be member of the class \emph{Gap}. High score could mean either high
#' membership to \code{sky_blue} or, in the case of achromatic pixels, a high
#' membership to values above \code{thr}. The algorithm internally uses
#' \code{\link{membership_to_color}} and \code{\link{local_fuzzy_thresholding}}.
#' The argument \code{sky_blue} is the \code{target_color} of the former
#' function, which output is the argument \code{mem} of the latter function.
#'
#' \code{gamma} is applied to should use the sRGB color space since values
#' passed to \code{\link{local_fuzzy_thresholding}} are corrected with
#' \code{\link{gbc}} using gamma equal to 2.2.
#'
#' If you use this function in your research, please cite
#' \insertCite{Diaz2015}{rcaiman}.
#'
#' @inheritParams expand_noncircular
#' @inheritParams local_fuzzy_thresholding
#' @param w_red Numeric vector of length one. Weight of the red channel. A
#'   single layer image is calculated as a weighted average of the blue and red
#'   channels. This layer is used as lightness information. The weight of the
#'   blue is the complement of \code{w_red}.
#' @param gamma Numeric vector of length one. This is for applying a gamma back
#'   correction to the lightness information (see argument \code{w_red} and
#'   \code{\link{gbc}}.
#' @param sky_blue \linkS4class{color}. Is the \code{target_color} argument to
#'   be passed to \code{\link{membership_to_color}}.
#'
#' @export
#' @references \insertAllCited{}
#' @family Fuzzy logic functions
#' @return An object of class \linkS4class{RasterLayer}, with same pixel
#'   dimensions than \code{caim}, that should show more contrast between the sky
#'   and plant pixels than any of the individual bands from \code{caim}. Also
#'
#' @examples
#' \dontrun{
#' caim <- read_caim()
#' caim <- normalize(caim, 0, 255)
#' z <- zenith_image(ncol(caim), lens("Nikon_FCE9"))
#' m <- !is.na(z)
#' sky_blue <- colorspace::sRGB(matrix(c(0.2, 0.3, 0.5), ncol = 3))
#' ecaim <- enhance_caim(caim, m, sky_blue, gamma = 2.2)
#' plot(ecaim)
#' }
enhance_caim <- function(caim,
                         m,
                         sky_blue,
                         w_red = 0,
                         gamma = NULL) {
  .check_if_r_was_normalized(caim, "caim")
  if (!compareRaster(caim, m, stopiffalse = FALSE)) {
    stop("\"x\" should match pixel by pixel whit \"m\".")
  }

  mem_sky_blue <- membership_to_color(caim, sky_blue)
  lightness <- caim$Red * w_red + caim$Blue * (1 - w_red)
  if (!is.null(gamma)) lightness <- gbc(lightness * 255, gamma = gamma)
  mem_sky_blue
  mem_thr <- suppressWarnings(local_fuzzy_thresholding(lightness,
                                                m,
                                                mem_sky_blue$membership_to_grey,
                                                thr = NULL,
                                                fuzziness = NULL))
  mem_thr[is.na(mem_thr)] <- 0
  mem <- mem_sky_blue$membership_to_target_color + mem_thr
  mem <- normalize(mem)
  names(mem) <- "Enhanced canopy image"
  mem
}

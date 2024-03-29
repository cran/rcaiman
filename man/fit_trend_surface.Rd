% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fit_trend_surface.R
\name{fit_trend_surface}
\alias{fit_trend_surface}
\title{Fit a trend surface to sky digital numbers}
\usage{
fit_trend_surface(
  r,
  bin,
  m = NULL,
  filling_source = NULL,
  prob = 0.95,
  fact = 5,
  np = 6
)
}
\arguments{
\item{r}{\linkS4class{RasterLayer}. A normalized greyscale image. Typically,
the blue channel extracted from an hemispherical photograph. Please see
\code{\link{read_caim}} and \code{\link{normalize}}.}

\item{bin}{\linkS4class{RasterLayer}. A working binarized image. This should
be a preliminary binarization of \code{r}. If the function returns
\code{NA}, then the quality of this input should be revised.}

\item{m}{\linkS4class{RasterLayer}. A mask. Usually, the result of a call to
\code{\link{mask_hs}}.}

\item{filling_source}{\linkS4class{RasterLayer}. Default is \code{NULL}.
Above-canopy photograph. This image should contain pixels with sky DN
values and \code{NA} in all the other pixels. A photograph taken
immediately after or before taking \code{r} under the open sky with the
same equipment and configuration is a very good option. The ideal option is
one taken at the same time and place but above the canopy. The orientation
relative to the North must be the same than for \code{r}.}

\item{prob}{Logical vector of length one. Probability for
\code{\link[stats]{quantile}} calculation. See reference
\insertCite{Diaz2018;textual}{rcaiman}.}

\item{fact}{postive integer. Aggregation factor expressed as number of cells in each direction (horizontally and vertically). Or two integers (horizontal and vertical aggregation factor) or three integers (when also aggregating over layers). See Details}

\item{np}{
degree of polynomial surface
}
}
\value{
A list with an object of class \linkS4class{RasterLayer} and of class
  \code{trls} (see \code{\link[spatial]{surf.ls}}).
}
\description{
Fit a trend surface using spatial::surf.ls as workhorse function.
}
\details{
This function is meant to be used after \code{\link{fit_coneshaped_model}}.

A short explanation of this function can be found on
\insertCite{Diaz2018;textual}{rcaiman}, under the heading \emph{Estimation of
the sky DN as a previous step for our method}, after the explanation of the
\code{\link{fit_coneshaped_model}}.

The argument \code{fact} is passed to \code{\link[raster]{aggregate}}. That
argument allows to control the scale at which the fitting is performed. In
general, a coarse scale lead to best generalization. The function used for
aggregation is \code{\link[stats]{quantile}}, to which the argument
\code{prob} is passed. Essentially, the aggregation step works as the one
from \code{\link{fit_coneshaped_model}}, but it is made on the raster space
rather than on the hemispherical space.

If you use this function in your research, please cite
\insertCite{Diaz2018}{rcaiman}.
}
\examples{
\dontrun{
path <- system.file("external/4_D_2_DSCN4502.JPG", package = "rcaiman")
r <- read_caim(path, c(1280, 960) - 745, 745 * 2, 745 * 2)
z <- zenith_image(ncol(r), lens("Nikon_FCE9"))
a <- azimuth_image(z)
blue <- gbc(r$Blue)
bin <- find_sky_pixels(blue, z, a)
sky <- fit_coneshaped_model(blue, z, a, bin, parallel = FALSE)
m <- mask_hs(z, 0, 80)
sky <- fit_trend_surface(blue, bin, m, filling_source = sky$image)
plot(sky$image)
}
}
\references{
\insertAllCited{}
}
\seealso{
Other MBLT functions: 
\code{\link{find_sky_pixels}()},
\code{\link{fit_coneshaped_model}()},
\code{\link{ootb_mblt}()},
\code{\link{thr_image}()}
}
\concept{MBLT functions}

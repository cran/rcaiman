% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/zenith_image.R
\name{zenith_image}
\alias{zenith_image}
\title{Zenith image}
\usage{
zenith_image(diameter, lens_coef)
}
\arguments{
\item{diameter}{Numeric vector of length one. Diameter in pixels.}

\item{lens_coef}{Numeric vector. Polynomial coefficients of the lens
projection function.}
}
\value{
An object of class \linkS4class{RasterLayer} of zenith angles in
  degrees, showing a complete hemispherical view, with the zenith on the
  center.
}
\description{
Built a single layer image with zenith angles values.
}
\examples{
z <- zenith_image(1490, lens("Nikon_FCE9"))
plot(z)
}
\seealso{
Other Lens functions: 
\code{\link{azimuth_image}()},
\code{\link{calc_diameter}()},
\code{\link{calc_zenith_raster_coordinates}()},
\code{\link{calibrate_lens}()},
\code{\link{expand_noncircular}()},
\code{\link{lens}()},
\code{\link{reproject_to_equidistant}()},
\code{\link{test_lens_coef}()}
}
\concept{Lens functions}

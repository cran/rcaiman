% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mask_hs.R
\name{mask_hs}
\alias{mask_hs}
\title{Mask hemisphere}
\usage{
mask_hs(r, from, to)
}
\arguments{
\item{r}{\linkS4class{RasterLayer}. The result of a call to
\code{\link{zenith_image}} or \code{\link{azimuth_image}}.}

\item{from, to}{angle in degrees, inclusive limits.}
}
\value{
An object of class \linkS4class{RasterLayer} with values \code{0} and
  \code{1}.
}
\description{
Given a zenith or azimuth image and angle restrictions, it produces a mask.
}
\examples{
\dontrun{
z <- zenith_image(1000, lens())
a <- azimuth_image(z)
m1 <- mask_hs(z, 20, 70)
plot(m1)
m2 <- mask_hs(a, 330,360)
plot(m2)
plot(m1 & m2)
plot(m1 | m2)

# if you want 15 degress at each side of 0
m1 <- mask_hs(a, 0, 15)
m2 <- mask_hs(a, 345, 360)
plot(m1 | m2)

# better use this
plot(!is.na(z))
# instead of this
plot(mask_hs(z, 0, 90))
}
}
\seealso{
\code{\link{masking}}

Other Segmentation functions: 
\code{\link{rings_segmentation}()},
\code{\link{sectors_segmentation}()},
\code{\link{sky_grid_segmentation}()}
}
\concept{Segmentation functions}

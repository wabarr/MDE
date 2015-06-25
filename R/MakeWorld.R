#' Create a simple domain raster
#'
#' This function creates simple rectangular domain rasters, for use with the MDE function.
#' @param x.dim Dimension for the x-axis, in pixels
#' @param y.dim Dimension for the y-axis, in pixels
#' @param initialValue Value for initializing the raster cell values.  Defaults to NA.
#' @export
#' @examples
#' # a 10 by 10 raster with NA for each cell value
#' MakeWorld(10, 10)
#'
#' # a 20 by 10 raster with 1 for each cell value
#' MakeWorld(20, 10, initialValue = 1)

MakeWorld <- function(x.dim, y.dim, initialValue=NA){
  require(raster)
  world <- raster(nrows=y.dim, ncols=x.dim, xmn=0, xmx=x.dim, ymn=0, ymx=y.dim)
  #initialize values at 0
  values(world) <- initialValue
  return(world)
}

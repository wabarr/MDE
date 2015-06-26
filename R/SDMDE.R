#' create multiple geographic ranges within a domain and summarize overlap (i.e., spreading-dye model)
#'
#' This function creates random species ranges based on a specified vector of range sizes, and then summarized the overlap of ranges within the domain
#' @param world An object of class `RasterLayer`
#' @param targetRangeSizes A vector of target range sizes in pixels.  The GrowRange() function will be used to grow ranges for all elements in this vector.
#' @param occupiedValue The cell value used to represent a cell is occupied.  Defaults to 1.
#' @param showPlot Whether or not to show the plot.  Defaults to FALSE
#' @param nCores The number of processor cores on which to run the simulations in paralell.  Defaults to the number of available cores discovered by parallel::detectCores().
#' @export
#' @examples
#' \dontrun{
#' WorldRaster <- MakeWorld(10,10)
#' SDMDE(WorldRaster, targetRangeSizes=c(15,15,20,20,50,50,60))
#' }


SDMDE <- function(world, targetRangeSizes, occupiedValue = 1, showPlot = FALSE, nCores=NULL){
  stopifnot(is(world, "RasterLayer"))
  require(raster)
  require(parallel)
  if (is.null(nCores)) nCores <- parallel::detectCores() #use all available cores if unspecified
  cl <- parallel::makePSOCKcluster(nCores)
  parallel::clusterExport(cl = cl, varlist = c("GrowRange", "world", "occupiedValue", "adjacent","values", "values<-"), envir = environment())
  ranges <- unlist(parallel::parLapply(cl=cl, X = targetRangeSizes, fun=function(x){
    GrowRange(world, x, occupiedValue=occupiedValue, showPlot = FALSE)
  }))
  parallel::stopCluster(cl)
  richnessValues <- sapply(1:raster::ncell(world), FUN=function(cellNum){
    sum(ranges == cellNum)
  })

  values(world)[!is.na(values(world))] <- 0 # Reset raster values to zero
  values(world) <- raster::values(world) + richnessValues # Add the simulated spreading dye richnesses to raster cells. Outline of continents is maintained because NA plus a number is NA
  if(showPlot) {plot(world, main=sprintf("Spreading-Dye prediction for %d ranges", length(targetRangeSizes))); return(world)} else return(world)
}

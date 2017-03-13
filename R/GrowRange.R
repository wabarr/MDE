#' Grow a range to a target size within a given domain raster
#'
#' This function grows a single species range to a target size within a given raster, using rook's case adjacency. Raster cells with NA values are unavailable for range expansion, thus there must be some non-NA value in the world raster.
#' @param world An object of class `RasterLayer`. Pixels with NA values are interpreted as outside of the domain (off-limits for ranges).
#' @param targetRangeSize The target size of the range in pixels.  Defaults to 20\% of the total number of cells in world. Range may not reach target size if there are not enough adjacent pixels to accomodate the target range size.
#' @param occupiedValue The value to use to indicate that a cell is occupied.  Defaults to 1.
#' @param showPlot Whether or not to show the plot of the resulting range.  Defaults to FALSE.
#' @export
#' @examples
#' WorldRaster <- MakeWorld(10,10)
#' GrowRange(WorldRaster, targetRangeSize=15)


GrowRange <- function(world, targetRangeSize, occupiedValue=1, showPlot=FALSE){
  require(raster)
  stopifnot(is(world, "RasterLayer"))
  if (is.na(targetRangeSize)) targetRangeSize <- raster::ncell(world) * 0.2
  if (all(is.na(raster::values(world)))) stop("All the cell values in the world raster are NA.")

  #reset available values are in the raster to zero
  raster::values(world)[!is.na(raster::values(world))] <- 0

  #set up a vector to store the range
  currentRange <- rep(NA, targetRangeSize)

  #random initial seed cell from non-NA cells
  currentRange[1] <- sample(which(!is.na(raster::values(world))), 1)

  # while we still have NAs in the currentRange, we haven't yet reached the target range, so continue until there are no NAs
  while(sum(is.na(currentRange))){

    # some neighbors of some cells may already be in currentRange, so we take the setdiff to get just those neighbors that AREN'T already in the range
    neighbors <- setdiff(raster::adjacent(world, currentRange, directions = 4, pairs=FALSE), currentRange)

    neighbors <- neighbors[!is.na(raster::values(world)[neighbors])] # Only keep those neighbors whose raster cell values aren't NA.

    #break out of for loop if there are no more neighbors
    #this should only happen if the range was initiated on an island of pixels
    if(length(neighbors)==0){
      warningMessage <- "GrowRange() was truncated before reaching target range size because there were no more neighbors"
      warning(warningMessage)
      print(warningMessage)
      break
    }

    #add a randomly chosen neigbor to the current range, find first NA value of current range, and put the new cell number in that slot
    currentRange[which(is.na(currentRange))[1]] <- sample(neighbors, 1)
  }
  #remove any NAs from current range...in case we got truncated before reaching desired range
  currentRange <- currentRange[complete.cases(currentRange)]
  # if we are plotting, set currentRange values to the desired value and plot
  if(showPlot) {raster::values(world)[currentRange] <- occupiedValue; plot(world)}
  #if we aren't plotting, return a vector of occupied cell indices
  if(!showPlot) return(occupiedCells = currentRange)
}

## ----message=FALSE, warning=FALSE----------------------------------------
library(raster)
library(SpreadingDye)

data(africa)
plot(africa)

## ----fig.show='hold'-----------------------------------------------------
GrowRange(africa, targetRangeSize = 200, showPlot = TRUE)
GrowRange(africa, targetRangeSize = 500, showPlot = TRUE)

## ----fig.height=6, fig.width=6-------------------------------------------
SDMDE(africa, targetRangeSizes = c(500,220,305,525,212,171,192,582,101),showPlot = TRUE)


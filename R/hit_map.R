#' Platemap to identify 'hits' in a screen
#'
#' Produces a plot in the form of a micro-titre layout,
#' with colours indicating wells above or below a nominated threshold.
#'
#' @param data Vector of numerical values to score
#' @param well Vector of well identifiers e.g "A01"
#' @param plate Number of wells in complete plate (6, 12, 24, 48, 96, 384 or 1536)
#' @param threshold Numerical value of standard deviations from the mean
#'   for a well to be classified as a 'hit'. Default it +/- 2 SD
#' @param palette RColorBrewer palette
#' @param ... additional parameters for plot wrappers
#'
#' @import ggplot2
#' @importFrom RColorBrewer brewer.pal
#'
#' @return ggplot plot
#'
#' @export
#'
#' @examples
#' df <- data.frame(vals = rnorm(1:384),
#'                  well = num_to_well(1:384, plate = 384))
#'
#' hit_map(data = df$vals,
#'         well = df$well,
#'         plate = 384,
#'         threshold = 3)



hit_map <- function(data, well, plate = 96, threshold = 2,
                    palette = "Spectral", ...){

    stopifnot(is.vector(data))

    check_plate_input(well, plate)

    # transform well labels into row-column values for a 96-well plate
    platemap <- plate_map_scale(data, well)
    platemap$hit <- NA

    # calculate whether values are beyond the threshold; defined as hit or null
    for (row in 1:nrow(platemap)){
        if (!is.finite(platemap[row, "values"])) {
            platemap$hit[row] <-- NaN
        } else if (platemap[row, 'values'] > threshold) {
            platemap$hit[row] <- "hit"
        } else  if (platemap[row, 'values'] < (-1 * threshold)) {
            platemap$hit[row] <- "neg_hit"
        } else {
            platemap$hit[row] <- "null"
        }
    }

    # RColorBrewerPalette
    my_cols <- brewer.pal(3, palette)
    my_colours <- c(hit = my_cols[1], neg_hit = my_cols[3], null = my_cols[2])

    # change name of hit to values
    # plt96 and plt384 are colouring points by value, in this case needs to be hit
    platemap$actual_vales <- platemap$values
    platemap$values <- platemap$hit

    if (plate == 6L){
        plt <- plt6(platemap, ...) +
            scale_fill_manual("hit", values = my_colours) +
            theme_bw()
    } else if (plate == 12L){
        plt <- plt12(platemap, ...) +
            scale_fill_manual("hit", values = my_colours) +
            theme_bw()
    } else if (plate == 24L){
        plt <- plt24(platemap, ...) +
            scale_fill_manual("hit", values = my_colours) +
            theme_bw()
    } else if (plate == 48L){
        plt <- plt48(platemap, ...) +
            scale_fill_manual("hit", values = my_colours) +
            theme_bw()
    } else if (plate == 96L){
        plt <- plt96(platemap, ...) +
            scale_fill_manual("hit", values = my_colours) +
            theme_bw()
    } else if (plate == 384L){
        plt <- plt384(platemap, ...) +
            scale_fill_manual("hit", values = my_colours) +
            theme_bw()
    } else if (plate == 1536L){
        plt <- plt1536(platemap, ...) +
            scale_fill_manual("hit", values = my_colours) +
            theme_bw()
    } else {
        stop("Not a valid plate format. Either 6, 12, 24, 48, 96, 384 or 1536.",
             call. = FALSE)
    }
    return(plt)

}

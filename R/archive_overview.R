#' archive_overview: Getting a first glimpse of mementos available in the Internet Archive
#'
#' `archive_overview` provides an overview of available mementos of the homepage from the Internet Archive
#'
#' @param homepage A character vector of the homepage, including the top-level-domain
#' @param startDate A character vector of the starting date of the overview. Accepts a large variety of date formats (see \link[anytime]{anytime})
#' @param endDate A character vector of the ending date of the overview. Accepts a large variety of date formats (see \link[anytime]{anytime})
#'
#' @return This function provides an overview of mementos available from the Internet Archive. It returns a calendar indicating all dates in which mementos of the homepage have been stored in the Internet Archive at least once. However, a memento being stored in the Internet Archive does not guarantee that the information from the homepage can be actually scraped. As the Internet Archive is an internet resource, it is always possible that a request fails due to connectivity problems. One easy and obvious solution is to re-try the function.
#' @examples
#' \dontrun{
#' archive_overview(homepage = "www.spiegel.de", startDate = "20180601", endDate = "20190615")
#' archive_overview(homepage = "nytimes.com", startDate = "2018-06-01", endDate = "2019-05-01")
#' }


# Importing dependencies with roxygen2
#' @importFrom anytime anydate
#' @importFrom stringr str_remove_all
#' @importFrom stringr str_sub
#' @import lubridate
#' @importFrom jsonlite fromJSON
#' @importFrom tibble as_tibble
#' @import dplyr
#' @import ggplot2
#' @importFrom gridExtra grid.arrange

# Export function
#' @export


### Function --------------------

archive_overview <- function(homepage, startDate, endDate) {
  # Globally bind variables
  value <- availability <- ddate <- NULL

  # Check date inputs

  if (!is.character(startDate))
    stop ("startDate is not a character vector.")

  if (!is.character(endDate))
    stop ("endDate is not a character vector.")

  if (is.na(anytime::anydate(startDate)))
    stop ("startDate is not a date.")

  if (is.na(anytime::anydate(endDate)))
    stop ("endDate is not a date.")

  if (anytime::anydate(startDate) > anytime::anydate(endDate))
    stop ("startDate cannot be later than endDate.")

  if (anytime::anydate(endDate) > anytime::anydate(lubridate::today()))
    stop ("endDate cannot be in the future.")


  startDate <- anytime::anydate(startDate)
  startDate <- stringr::str_remove_all(startDate, "\\-")

  endDate <- anytime::anydate(endDate)
  endDate <- stringr::str_remove_all(endDate, "\\-")


  # Check homepage input
  ArchiveCheck <-
    paste0(
      "http://web.archive.org/cdx/search/cdx?url=",
      homepage,
      "&matchType=exact&collapse=timestamp:8&limit=15000&filter=!mimetype:image/gif&filter=!mimetype:image/jpeg&from=",
      "19900101",
      "&to=",
      stringr::str_remove_all(lubridate::today(), "\\-"),
      "&output=json&limit=1"
    )

  possibleError <- tryCatch(
    r <- httr::GET(ArchiveCheck, httr::timeout(20)),
    error = function(e)
      e
  )

  if (inherits(possibleError, "error")) {
    stop ("Homepage could not be loaded. Please check whether the page exists or try again.")
    }

  if (nrow(as.data.frame(jsonlite::fromJSON(ArchiveCheck))) == 0)
    stop ("Homepage has never been saved in the Internet Archive. Please choose another homepage.")


  urlArchive <-
    paste0(
      "http://web.archive.org/cdx/search/cdx?url=",
      homepage,
      "&matchType=exact&collapse=timestamp:8&limit=15000&filter=!mimetype:image/gif&filter=!mimetype:image/jpeg&from=",
      startDate,
      "&to=",
      endDate,
      "&output=json&limit=1"
    )

  url_from_json <- as.data.frame(jsonlite::fromJSON(urlArchive))
  names(url_from_json) <- lapply(url_from_json[1, ], as.character)
  url_from_json <- url_from_json[-1, ]

  collectDates <- url_from_json$timestamp
  collectDates <- stringr::str_sub(collectDates, 1, 8)
  collectDates <- anytime::anydate(collectDates)

  collectDates <- tibble::as_tibble(collectDates)
  collectDates <-
    dplyr::mutate(collectDates, availableDates = value)

  allDates <-
    tibble::as_tibble(seq(
      as.Date(anytime::anydate(startDate)),
      as.Date(anytime::anydate(endDate)),
      by = 1
    ))
  allDates <- dplyr::rename(allDates, date = value)

  dfDates <-
    dplyr::left_join(allDates, collectDates, by = c("date" = "value"))
  dfDates <- dplyr::mutate(dfDates, homepage = homepage)
  dfDates$day <-
    lubridate::wday(
      dfDates$date,
      label = T,
      week_start = getOption("lubridate.week.start", 1),
      locale = Sys.getlocale("LC_TIME")
    )
  dfDates$week <- format(dfDates$date, format = "%V")
  dfDates$month <- lubridate::month(dfDates$date, label = T)
  dfDates$ddate <-
    factor(sprintf("%02d", lubridate::day(dfDates$date)))
  dfDates$year <- lubridate::year(dfDates$date)

  #Get calendar week 53 correctly
  dfDates$monthnum <- lubridate::month(dfDates$date)
  dfDates$week[dfDates$monthnum == 12 &
                 dfDates$week == "01"] <- "53"

  dfDates$week <- factor(dfDates$week)

  dfDates$availability <- "Available"
  dfDates$availability[is.na(dfDates$availableDates)] <-
    "Not available"

  if (length(unique(dfDates$year)) == 1) {
    p <- ggplot2::ggplot(dfDates, ggplot2::aes(x = week, y = day)) +
      ggplot2::geom_tile(ggplot2::aes(fill = availability)) +
      ggplot2::geom_text(ggplot2::aes(label = ddate)) +
      ggplot2::scale_y_discrete(limits = rev(levels(dfDates$day))) +
      ggplot2::scale_fill_manual(values = c("#8dd3c7", "#fb8072")) +
      ggplot2::facet_grid( ~ month, scales = "free", space = "free") +
      ggplot2::labs(
        x = "Week" ,
        y = "",
        title = as.character(homepage),
        subtitle = as.character(unique(dfDates$year))
      ) +
      ggplot2::theme_bw(base_size = 10) +
      ggplot2::theme(
        legend.title = ggplot2::element_blank(),
        panel.grid = ggplot2::element_blank(),
        panel.border = ggplot2::element_blank(),
        axis.ticks = ggplot2::element_blank(),
        strip.background = ggplot2::element_blank(),
        legend.position = "top",
        legend.justification = "right",
        legend.direction = "horizontal",
        legend.key.size = ggplot2::unit(0.3, "cm"),
        legend.spacing.x = ggplot2::unit(0.2, "cm")
      )

    return(p)
  }

  if (length(unique(dfDates$year)) > 1) {
    plotFunction <- function(dfDates, year) {
      dfDatesPlot <- dfDates[dfDates$year == year, ]

      ggplot2::ggplot(dfDatesPlot, ggplot2::aes(x = week, y = day)) +
        ggplot2::geom_tile(ggplot2::aes(fill = availability)) +
        ggplot2::geom_text(ggplot2::aes(label = ddate)) +
        ggplot2::scale_y_discrete(limits = rev(levels(dfDatesPlot$day))) +
        ggplot2::scale_fill_manual(values = c("#8dd3c7", "#fb8072")) +
        ggplot2::facet_grid( ~ month, scales = "free", space = "free") +
        ggplot2::labs(x = "Week" ,
                      y = "",
                      title = as.character(unique(dfDatesPlot$year))) +
        ggplot2::theme_bw(base_size = 10) +
        ggplot2::theme(
          legend.title = ggplot2::element_blank(),
          panel.grid = ggplot2::element_blank(),
          panel.border = ggplot2::element_blank(),
          axis.ticks = ggplot2::element_blank(),
          strip.background = ggplot2::element_blank(),
          legend.position = "top",
          legend.justification = "right",
          legend.direction = "horizontal",
          legend.key.size = ggplot2::unit(0.3, "cm"),
          legend.spacing.x = ggplot2::unit(0.2, "cm")
        )
    }

    plot_list <- lapply(unique(dfDates$year),
                        plotFunction,
                        dfDates = dfDates)

    return(
      gridExtra::grid.arrange(
        grobs = plot_list,
        top = as.character(homepage)
        )
      )
  }

}

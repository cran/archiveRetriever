context("check-scrapeURLs-output")
library(testthat)
library(webmockr)
library(archiveRetriever)


#Check whether function output is data frame
test_that("scrape_urls() returns a data frame", {
  vcr::use_cassette("scrape_url1", {
    output <-
      scrape_urls(
        "http://web.archive.org/web/20190502052859/http://www.taz.de/Praesident-Trong-scheut-Oeffentlichkeit/!5588752/",
        Paths = c(title = "//article//h1", content = "//article//p[contains(@class, 'article')]//text()"),
        encoding = "bytes"
      )
  })
    expect_is(output, "data.frame")
  })


# Check whether function takes output from retrieve_links
test_that("scrape_urls() takes input from retrieve_links()", {
  vcr::use_cassette("scrape_url2", {
    output <-
      scrape_urls(
        data.frame(baseUrl = "http://web.archive.org/web/20190502052859/http://www.taz.de/",links = "http://web.archive.org/web/20190502052859/http://www.taz.de/Praesident-Trong-scheut-Oeffentlichkeit/!5588752/"),
        Paths = c(title = "//article//h1", content = "//article//p[contains(@class, 'article')]//text()"),
        encoding = "bytes"
      )
  })
  expect_is(output, "data.frame")
})

# Check whether function blocks dataframe inputs other than output from retrieve_links
test_that("scrape_urls() blocks dataframes that do not stem from retrieve_links()", {
  expect_error(
    scrape_urls(
      data.frame(wrongName = "http://web.archive.org/web/20190502052859/http://www.taz.de/",links = "http://web.archive.org/web/20190502052859/http://www.taz.de/Praesident-Trong-scheut-Oeffentlichkeit/!5588752/"),
      Paths = c(title = "//article//h1", content = "//article//p[contains(@class, 'article')]//text()"),
      encoding = "bytes"
    ),
    "Dataframes not obtained"
  )
})


#Check whether function only takes Archive links
test_that("scrape_urls() only takes Internet Archive URLs as input", {
  expect_error(
    scrape_urls(
      "https://labour.org.uk/about/labours-legacy/",
      Paths = c(title = "//h1", content = "//p")
    ),
    "Urls do not originate"
  )
})

#Check whether Paths is character vector
test_that("scrape_urls() only takes character vectors as Paths", {
  expect_error(
    scrape_urls(
      "http://web.archive.org/web/20201009174440/https://www.uni-mannheim.de/universitaet/profil/geschichte/",
      c(title = 1)
    ),
    "Paths is not a character vector"
  )
})

#Check whether collapse is logical or xpath
test_that("scrape_urls() collapse must be logical or xpath", {
  expect_error(
    scrape_urls(
      "http://web.archive.org/web/20201009174440/https://www.uni-mannheim.de/universitaet/profil/geschichte/",
      c(title = "//h1"),
        collapse = 5
    ),
    "collapse is not a logical or character"
  )
})

#Check that collapse as xpath can not be used with CSS
test_that("scrape_urls() collapse as structure can only be used with xpath", {
  expect_error(
    scrape_urls(
      "http://web.archive.org/web/20201009174440/https://www.uni-mannheim.de/universitaet/profil/geschichte/",
      c(title = "h1"),
      collapse = "//div[@class='title']",
      CSS = TRUE
    ),
    "A structuring xpath as collapse statement can only be used with xpath."
  )
})




#Check whether XPath vector is named
test_that("scrape_urls() only takes named XPath/CSS vector as Paths", {
  expect_error(
    scrape_urls(
      "http://web.archive.org/web/20201009174440/https://www.uni-mannheim.de/universitaet/profil/geschichte/",
      "//header//h1"
    ),
    "Paths is not a named vector"
  )
})

#Check whether Archive date is taken from the URL
  test_that("scrape_urls() option archiveDate stores archiving date", {
    vcr::use_cassette("scrape_url3", {
    output <-
      scrape_urls(
        "http://web.archive.org/web/20170125090337/http://www.ilsole24ore.com/art/motori/2017-01-23/toyota-yaris-205049.shtml?uuid=AEAqSFG&nmll=2707",
        Paths = c(title = "(//div[contains(@class,'title art11_title')]//h1 | //header/h1 | //h1[@class='atitle'] | //h1[@class='atitle '] | //article//article/header/h2[@class = 'title'] | //h2[@class = 'title'])", content = "(//*[@class='grid-8 top art11_body body']//p//text() | //article/div[@class='article-content ']/div/div/div//p//text() | //div[@class='aentry aentry--lined']//p//text())"),
        archiveDate = T,
        encoding = "bytes"
      )
    scrape_urls(
      "http://web.archive.org/web/20190528072311/https://www.taz.de/Fusionsangebot-in-der-Autobranche/!5598075/",
      Paths = c(title = "//article//h1", content = "//article//p[contains(@class, 'article')]//text()"),
      archiveDate = TRUE,
      encoding = "bytes"
    )
    })
    expect_equal(names(output)[4], "archiveDate")
  })

#Check whether function takes CSS instead of XPath
  test_that("scrape_urls() takes CSS instead of XPath", {
    vcr::use_cassette("scrape_url4", {
    output <-
      scrape_urls(
        "http://web.archive.org/web/20190528072311/https://www.taz.de/Fusionsangebot-in-der-Autobranche/!5598075/",
        Paths = c(title = "article h1"),
        CSS = TRUE
      )
    })
    expect_is(output, "data.frame")
  })

#Check whether startnum is numeric
test_that("scrape_urls() needs numeric startnum", {
  expect_error(scrape_urls(
    c(
      "http://web.archive.org/web/20201009174440/https://www.uni-mannheim.de/universitaet/profil/geschichte/",
      "http://web.archive.org/web/20201009174440/https://www.uni-mannheim.de/universitaet/profil/geschichte/"
    ),
    c(title = "//header//h1"),
    startnum = "2"
  ), "startnum is not numeric")
})

#Check whether startnum exceeds number of Urls
test_that("scrape_urls() needs startnum smaller than input vector", {
  expect_error(scrape_urls(
    c(
      "http://web.archive.org/web/20201009174440/https://www.uni-mannheim.de/universitaet/profil/geschichte/",
      "http://web.archive.org/web/20201009174440/https://www.uni-mannheim.de/universitaet/profil/geschichte/"
    ),
    c(title = "//header//h1"),
    startnum = 3
  ),
  "startnum value exceeds number of Urls given")
})

#Check whether startnum is single value
test_that("scrape_urls() needs startnum to be a single value", {
  expect_error(scrape_urls(
    c(
      "http://web.archive.org/web/20201009174440/https://www.uni-mannheim.de/universitaet/profil/geschichte/",
      "http://web.archive.org/web/20201009174440/https://www.uni-mannheim.de/universitaet/profil/geschichte/"
    ),
    c(title = "//header//h1"),
    startnum = c(1, 3)
  ),
  "startnum is not a single value")
})

#Check whether CSS is a logical value
test_that("scrape_urls() needs CSS to be a logical value", {
  expect_error(
    scrape_urls(
      "http://web.archive.org/web/20190528072311/https://www.taz.de/Fusionsangebot-in-der-Autobranche/!5598075/",
      Paths = c(title = "article h1"),
      CSS = "T"
    ),
    "CSS is not a logical value"
  )
})

#Check whether CSS is single value
test_that("scrape_urls() needs CSS to be a single logical value", {
  expect_error(
    scrape_urls(
      "http://web.archive.org/web/20190528072311/https://www.taz.de/Fusionsangebot-in-der-Autobranche/!5598075/",
      Paths = c(title = "article h1"),
      CSS = c(TRUE, TRUE)
    ),
    "CSS is not a single value"
  )
})

#Check whether archiveDate is a logical value
test_that("scrape_urls() needs archiveDate to be a logical value", {
  expect_error(
    scrape_urls(
      "http://web.archive.org/web/20190528072311/https://www.taz.de/Fusionsangebot-in-der-Autobranche/!5598075/",
      Paths = c(title = "article h1"),
      CSS = TRUE,
      archiveDate = "T"
    ),
    "archiveDate is not a logical value"
  )
})

#Check whether archiveDate is single value
test_that("scrape_urls() needs archiveDate to be a single logical value", {
  expect_error(
    scrape_urls(
      "http://web.archive.org/web/20190528072311/https://www.taz.de/Fusionsangebot-in-der-Autobranche/!5598075/",
      Paths = c(title = "article h1"),
      CSS = TRUE,
      archiveDate = c(TRUE, TRUE)
    ),
    "archiveDate is not a single value"
  )
})

#Check whether ignoreErrors is a logical value
test_that("scrape_urls() needs ignoreErrors to be a logical value", {
  expect_error(
    scrape_urls(
      "http://web.archive.org/web/20190528072311/https://www.taz.de/Fusionsangebot-in-der-Autobranche/!5598075/",
      Paths = c(title = "article h1"),
      CSS = TRUE,
      archiveDate = TRUE,
      ignoreErrors = "T"
    ),
    "ignoreErrors is not a logical value"
  )
})

#Check whether ignoreErrors is single value
test_that("scrape_urls() needs ignoreErrors to be a single logical value", {
  expect_error(
    scrape_urls(
      "http://web.archive.org/web/20190528072311/https://www.taz.de/Fusionsangebot-in-der-Autobranche/!5598075/",
      Paths = c(title = "article h1"),
      CSS = TRUE,
      archiveDate = TRUE,
      ignoreErrors = c(TRUE, TRUE)
    ),
    "ignoreErrors is not a single value"
  )
})

#Check whether stopatempty is a logical value
test_that("scrape_urls() needs stopatempty to be a logical value", {
  expect_error(
    scrape_urls(
      "http://web.archive.org/web/20190528072311/https://www.taz.de/Fusionsangebot-in-der-Autobranche/!5598075/",
      Paths = c(title = "article h1"),
      CSS = TRUE,
      archiveDate = TRUE,
      ignoreErrors = TRUE,
      stopatempty = "T"
    ),
    "stopatempty is not a logical value"
  )
})

#Check whether stopatempty is single value
test_that("scrape_urls() needs stopatempty to be a single logical value", {
  expect_error(
    scrape_urls(
      "http://web.archive.org/web/20190528072311/https://www.taz.de/Fusionsangebot-in-der-Autobranche/!5598075/",
      Paths = c(title = "article h1"),
      CSS = TRUE,
      archiveDate = TRUE,
      ignoreErrors = TRUE,
      stopatempty = c(TRUE, TRUE)
    ),
    "stopatempty is not a single value"
  )
})

#Check whether emptylim is a numeric value
test_that("scrape_urls() needs emptylim to be a numeric value", {
  expect_error(
    scrape_urls(
      "http://web.archive.org/web/20190528072311/https://www.taz.de/Fusionsangebot-in-der-Autobranche/!5598075/",
      Paths = c(title = "article h1"),
      CSS = TRUE,
      archiveDate = TRUE,
      ignoreErrors = TRUE,
      stopatempty = TRUE,
      emptylim = "5"
    ),
    "emptylim is not numeric"
  )
})

#Check whether emptylim is single value
test_that("scrape_urls() needs emptylim to be a numeric value", {
  expect_error(
    scrape_urls(
      "http://web.archive.org/web/20190528072311/https://www.taz.de/Fusionsangebot-in-der-Autobranche/!5598075/",
      Paths = c(title = "article h1"),
      CSS = TRUE,
      archiveDate = TRUE,
      ignoreErrors = TRUE,
      stopatempty = TRUE,
      emptylim = c(5, 6)
    ),
    "emptylim is not a single value"
  )
})

#Check whether encoding is a character value
test_that("scrape_urls() needs encoding to be a character value", {
  expect_error(
    scrape_urls(
      "http://web.archive.org/web/20190528072311/https://www.taz.de/Fusionsangebot-in-der-Autobranche/!5598075/",
      Paths = c(title = "article h1"),
      CSS = TRUE,
      archiveDate = TRUE,
      ignoreErrors = TRUE,
      stopatempty = TRUE,
      emptylim = 5,
      encoding = 1991
    ),
    "encoding is not a character value"
  )
})

#Check whether encoding is single value
test_that("scrape_urls() needs encoding to be a character value", {
  expect_error(
    scrape_urls(
      "http://web.archive.org/web/20190528072311/https://www.taz.de/Fusionsangebot-in-der-Autobranche/!5598075/",
      Paths = c(title = "article h1"),
      CSS = TRUE,
      archiveDate = TRUE,
      ignoreErrors = TRUE,
      stopatempty = TRUE,
      emptylim = 5,
      encoding = c("UTF-8", "bytes")
    ),
    "encoding is not a single value"
  )
})

# Check whether nonArchive is logical
test_that("scrape_urls() needs nonArchive to be a logical value", {
  expect_error(
    scrape_urls(
      "http://web.archive.org/web/20190528072311/https://www.taz.de/Fusionsangebot-in-der-Autobranche/!5598075/",
      Paths = c(title = "article h1"),
      CSS = TRUE,
      nonArchive = "T"
    ),
    "nonArchive must be logical"
  )
})


# Check whether nonArchive is single value
test_that("scrape_urls() needs nonArchive to be single value", {
  expect_error(
    scrape_urls(
      "http://web.archive.org/web/20190528072311/https://www.taz.de/Fusionsangebot-in-der-Autobranche/!5598075/",
      Paths = c(title = "article h1"),
      CSS = TRUE,
      nonArchive = c(TRUE, FALSE)
    ),
    "nonArchive must be a single value"
  )
})


# Check that nonArchive can't be combined with archiveDate
test_that("scrape_urls() needs nonArchive to be a logical value", {
  expect_error(
    scrape_urls(
      "http://web.archive.org/web/20190528072311/https://www.taz.de/Fusionsangebot-in-der-Autobranche/!5598075/",
      Paths = c(title = "article h1"),
      CSS = TRUE,
      nonArchive = TRUE,
      archiveDate = TRUE
    ),
    "nonArchive = TRUE cannot be used with archiveDate = TRUE."
  )
})



#Check whether data is being correctly attached to existing data set
  test_that("scrape_urls() needs to start with second row when startnum is 2", {
    vcr::use_cassette("scrape_url5", {
    output <-
      scrape_urls(
        c(
          "http://web.archive.org/web/20190310015353/https://www.uni-mannheim.de/universitaet/profil/geschichte/",
          "http://web.archive.org/web/20201009174440/https://www.uni-mannheim.de/universitaet/profil/geschichte/"
        ),
        c(title = "//header//h1"),
        startnum = 2
      )
    })
    expect_equal(output$Urls[1], "http://web.archive.org/web/20201009174440/https://www.uni-mannheim.de/universitaet/profil/geschichte/")
  })

#Check whether only some XPaths could be scraped
test_that("scrape_urls() needs to warn if only some XPaths can be scraped", {
  skip_on_cran()
  skip_on_ci()
  expect_warning(
    scrape_urls(
      "http://web.archive.org/web/20190502052859/http://www.taz.de/Praesident-Trong-scheut-Oeffentlichkeit/!5588752/",
      Paths = c(title = "/blablabla", content = "//article//p[contains(@class, 'article')]//text()"),
      ignoreErrors = FALSE,
      encoding = "bytes"
    ),
    "Only some of your Paths"
  )
})


#Check whether data is being correctly processed
  test_that("scrape_urls() needs to set NA if page cannot be scraped", {
    vcr::use_cassette("scrape_url6", {
    output <-
      scrape_urls(
        c(
          "http://web.archive.org/web/20190502052859/http://www.taz.de/Praesident-Trong-scheut-Oeffentlichkeit/!5588752/",
          "http://web.archive.org/web/20190502052859/http://blogs.taz.de/",
          "http://web.archive.org/web/20190502052859/http://www.taz.de/Galerie/Die-Revolution-im-Sudan/!g5591075/"
        ),
        Paths = c(title = "//article//h1", content = "//article//p[contains(@class, 'article')]//text()")
      )
    })
    expect_equal(is.na(output$title[3]), TRUE)
  })

#Check whether process stop if too many rows are empty
test_that("scrape_urls() needs to stop if too many row are empty", {
  skip_on_cran()
  skip_on_ci()
  expect_warning(
    scrape_urls(
      c(
        "http://web.archive.org/web/20190502052859/http://www.taz.de/Praesident-Trong-scheut-Oeffentlichkeit/!5588752/",
        "http://web.archive.org/web/20190502052859/http://blogs.taz.de/",
        "http://web.archive.org/web/20190502052859/http://blogs.taz.de/lostineurope",
        "http://web.archive.org/web/20190502052859/http://blogs.taz.de/lostineurope"
      ),
      Paths = c(title = "//article//h1", content = "//article//p[contains(@class, 'article')]//text()"),
      stopatempty = TRUE,
      emptylim = 2
    ),
    "Too many empty outputs in a row"
  )
})

#Check if re-start after break and attachto works
  test_that("scrape_urls() needs to take up process if it breaks", {
    skip_on_cran()
    skip_on_ci()
    output <-
      scrape_urls(
        c(
          "http://web.archive.org/web/20190502052859/http://www.taz.de/Praesident-Trong-scheut-Oeffentlichkeit/!5588752/",
          "http://web.archive.org/web/20190502052859/http://blogs.taz.de/",
          "http://web.archive.org/web/20190502052859/http://blogs.taz.de/lostineurope",
          "http://web.archive.org/web/20190502052859/http://blogs.taz.de/lostineurope/blogfeed/"
        ),
        Paths = c(title = "//article//h1", content = "//article//p[contains(@class, 'article')]//text()"),
        stopatempty = FALSE,
        attachto = tibble::tibble(
          Urls = c(
            "http://web.archive.org/web/20190502052859/http://www.taz.de/Praesident-Trong-scheut-Oeffentlichkeit/!5588752/",
            "http://web.archive.org/web/20190502052859/http://blogs.taz.de/",
            "http://web.archive.org/web/20190502052859/http://blogs.taz.de/lostineurope"
          ),
          title = c("Vietnamesen rätseln um Staatschef",
                    "",
                    ""),
          content = c(
            "Wer regiert Vietnam? Offenbar ist Partei- und Staatschef Nguyen Phu Trong dazu nicht mehr fähig:",
            "",
            ""
          ),
          stoppedat = 4
        )
      )
    expect_equal(ncol(output), 3)
  })

#Check if re-start after break and attachto works
test_that("scrape_urls() should not take up process if it stems from other process",
          {
            expect_error(
              scrape_urls(
                c(
                  "http://web.archive.org/web/20190502052859/http://www.taz.de/Praesident-Trong-scheut-Oeffentlichkeit/!5588752/",
                  "http://web.archive.org/web/20190502052859/http://blogs.taz.de/",
                  "http://web.archive.org/web/20190502052859/http://blogs.taz.de/lostineurope",
                  "http://web.archive.org/web/20190502052859/http://blogs.taz.de/lostineurope/blogfeed/"
                ),
                Paths = c(title = "//article//h1", content = "//article//p[contains(@class, 'article')]//text()"),
                stopatempty = FALSE,
                attachto = tibble::tibble(
                  Urls = c(
                    "http://web.archive.org/web/20190502052859/http://www.taz.de/Praesident-Trong-scheut-Oeffentlichkeit/!5588752/",
                    "http://web.archive.org/web/20190502052859/http://blogs.taz.de/",
                    "http://web.archive.org/web/20190502052859/http://blogs.taz.de/lostineurope"
                  ),
                  title = c("Vietnamesen rätseln um Staatschef",
                            "",
                            ""),
                  inhalt = c(
                    "Wer regiert Vietnam? Offenbar ist Partei- und Staatschef Nguyen Phu Trong dazu nicht mehr fähig:",
                    "",
                    ""
                  ),
                  progress = c(1, 0, 0)
                )
              ),
              "attachto must be a failed output of this function"
            )
          })


#Check whether sleeper is activated after 20 Urls
  test_that("scrape_urls() needs to sleep every 20 Urls", {
    vcr::use_cassette("scrape_url7", {
    output <-
      scrape_urls(
        c(
          "http://web.archive.org/web/20201009174440/https://www.uni-mannheim.de/universitaet/profil/geschichte/",
          "http://web.archive.org/web/20201009174440/https://www.uni-mannheim.de/universitaet/profil/geschichte/",
          "http://web.archive.org/web/20201009174440/https://www.uni-mannheim.de/universitaet/profil/geschichte/",
          "http://web.archive.org/web/20201009174440/https://www.uni-mannheim.de/universitaet/profil/geschichte/",
          "http://web.archive.org/web/20201009174440/https://www.uni-mannheim.de/universitaet/profil/geschichte/",
          "http://web.archive.org/web/20201009174440/https://www.uni-mannheim.de/universitaet/profil/geschichte/",
          "http://web.archive.org/web/20201009174440/https://www.uni-mannheim.de/universitaet/profil/geschichte/",
          "http://web.archive.org/web/20201009174440/https://www.uni-mannheim.de/universitaet/profil/geschichte/",
          "http://web.archive.org/web/20201009174440/https://www.uni-mannheim.de/universitaet/profil/geschichte/",
          "http://web.archive.org/web/20201009174440/https://www.uni-mannheim.de/universitaet/profil/geschichte/",
          "http://web.archive.org/web/20201009174440/https://www.uni-mannheim.de/universitaet/profil/geschichte/",
          "http://web.archive.org/web/20201009174440/https://www.uni-mannheim.de/universitaet/profil/geschichte/",
          "http://web.archive.org/web/20201009174440/https://www.uni-mannheim.de/universitaet/profil/geschichte/",
          "http://web.archive.org/web/20201009174440/https://www.uni-mannheim.de/universitaet/profil/geschichte/",
          "http://web.archive.org/web/20201009174440/https://www.uni-mannheim.de/universitaet/profil/geschichte/",
          "http://web.archive.org/web/20201009174440/https://www.uni-mannheim.de/universitaet/profil/geschichte/",
          "http://web.archive.org/web/20201009174440/https://www.uni-mannheim.de/universitaet/profil/geschichte/",
          "http://web.archive.org/web/20201009174440/https://www.uni-mannheim.de/universitaet/profil/geschichte/",
          "http://web.archive.org/web/20201009174440/https://www.uni-mannheim.de/universitaet/profil/geschichte/",
          "http://web.archive.org/web/20201009174440/https://www.uni-mannheim.de/universitaet/profil/geschichte/",
          "http://web.archive.org/web/20201009174440/https://www.uni-mannheim.de/universitaet/profil/geschichte/"
        ),
        c(title = "//header//h1")
      )
    })
    expect_equal(nrow(output), 21)
  })

#Check whether script runs without problems in case of timeout of website
test_that("scrape_urls() should not fail if website has timeout", {
  webmockr::enable()

  webmockr::to_timeout(
    webmockr::stub_request(
      "get", "http://web.archive.org/web/20190502052859/http://www.taz.de/Praesident-Trong-scheut-Oeffentlichkeit/!5588752/")
  )
  output <- scrape_urls(
    "http://web.archive.org/web/20190502052859/http://www.taz.de/Praesident-Trong-scheut-Oeffentlichkeit/!5588752/",
    Paths = c(title = "//article//h1", content = "//article//p[contains(@class, 'article')]//text()"),
    encoding = "bytes"
  )
  expect_is(output, "data.frame")

  webmockr::disable()
})


#Check whether script runs without problems when collapse is FALSE
  test_that("scrape_urls() needs to output 5 rows", {
    skip_on_cran()
    skip_on_ci()
    output <-
      scrape_urls(Urls = "http://web.archive.org/web/20201216060059/https://www.reddit.com/r/de/",
                  Paths = c(title = "//div/h3",
                            type = "//div[@class='rpBJOHq2PR60pnwJlUyP0']//a//div[contains(@class,'2X6EB3ZhEeXCh1eIVA64XM')]/span"),
                  collapse = FALSE,
                  ignoreErrors = TRUE)
    expect_equal(nrow(output), 5)
  })

#Check whether new content is being correctly attached to existing object
  test_that("scrape_urls() needs to output 4 rows", {
    input <-
      data.frame(Urls = c("http://web.archive.org/web/20171112174048/http://reddit.com:80/r/de", "http://web.archive.org/web/20171115220704/https://reddit.com/r/de"),
                 title = c("Der Frauen höchstes Glück ist das stillen des Hungers", "Am besten mit Frankfurter Kranz."),
                 author = c("Wilhelm_Blumberg", "NebuKadneZaar"),
                 stoppedat = 3)
    vcr::use_cassette("scrape_url8", {
    output <-
      scrape_urls(
        c(
          "http://web.archive.org/web/20171112174048/http://reddit.com:80/r/de",
          "http://web.archive.org/web/20171115220704/https://reddit.com/r/de",
          "http://web.archive.org/web/20171120193529/http://reddit.com/r/de",
          "http://web.archive.org/web/20171123081007/https://www.reddit.com/r/de/",
          "http://web.archive.org/web/20171129231144/https://reddit.com/r/de"
        ),
        Paths = c(title = "(//p[@class='title']/a | //div//a/h2 | //div//h3)",
                  author = "(//p[contains(@class,'tagline')]/a | //div[contains(@class,'scrollerItem')]//a[starts-with(.,'u/')]/text() | //div[contains(@class,'NAURX0ARMmhJ5eqxQrlQW')]//span)"),
        startnum = 4,
        attachto = input)
    })
    expect_equal(nrow(output), 4)
  })


#Check whether script runs without problems when collapse is TRUE
  test_that("scrape_urls() needs to output 1 row", {
    skip_on_cran()
    skip_on_ci()
    output <-
      scrape_urls(Urls = "http://web.archive.org/web/20201216060059/https://www.reddit.com/r/de/",
                  Paths = c(title = "//div/h3",
                            type = "//div[@class='rpBJOHq2PR60pnwJlUyP0']//a//div[contains(@class,'2X6EB3ZhEeXCh1eIVA64XM')]/span"),
                  collapse = TRUE)
    expect_equal(nrow(output), 1)
})


#Check whether number of elements for paths differs
test_that("scrape_urls() needs the number of elements for paths to be equal", {
  skip_on_cran()
  skip_on_ci()
   expect_warning(
     output <- scrape_urls(Urls = "http://web.archive.org/web/20201216060059/https://www.reddit.com/r/de/",
                 Paths = c(title = "//div/h3",
                           type = "//div[@class='rpBJOHq2PR60pnwJlUyP0']//a//div[contains(@class,'2X6EB3ZhEeXCh1eIVA64XM')]/span"),
                 collapse = FALSE,
                ignoreErrors = FALSE
     ),
     "Number of elements for paths differs"
   )
   expect_is(output, "data.frame")
})


#Check whether script runs without problems when collapse & ignoreErrors is TRUE
test_that("scrape_urls() needs to output 1 row", {
  skip_on_cran()
  skip_on_ci()
  output <-
    scrape_urls(Urls = "http://web.archive.org/web/20201216060059/https://www.reddit.com/r/de/",
                Paths = c(title = "//div/h3",
                          type = "//div[@class='rpBJOHq2PR60pnwJlUyP0']//a//div[contains(@class,'2X6EB3ZhEeXCh1eIVA64XM')]/span"),
                collapse = TRUE,
                ignoreErrors = TRUE)
  expect_equal(nrow(output), 1)
})


#Check whether script runs without problems when collapse & ignoreErrors is FALSE
test_that("scrape_urls() needs to output 5 rows", {
  skip_on_cran()
  skip_on_ci()
  output <-
    scrape_urls(Urls = "http://web.archive.org/web/20201230202327/https://www.reddit.com/r/de/",
                Paths = c(title = "(//p[@class='title']/a | //div//a/h2 | //div//h3)",
                          type = "//div[@class='rpBJOHq2PR60pnwJlUyP0']//a//div[contains(@class,'2X6EB3ZhEeXCh1eIVA64XM')]/span"),
                collapse = FALSE,
                ignoreErrors = FALSE)
  expect_equal(nrow(output), 5)
})


#Check nonArchive
test_that("scrape_urls() returns a data frame", {
  vcr::use_cassette("scrape_url9", {
    output <-
      scrape_urls(
        Urls = "https://stackoverflow.com/questions/21167159/css-nth-match-doesnt-work",
        Paths = c(answer = "//div[@itemprop='text']/*", author = "//div[@itemprop='author']/span[@itemprop='name']"),
        collapse = "//div[@id='answers']/div[contains(@class, 'answer')]",
        nonArchive = TRUE,
        encoding = "bytes")
  })
  expect_is(output, "data.frame")
})

#Check structuring xpaths in collapse
test_that("scrape_urls() returns a data frame", {
  skip_on_cran()
  skip_on_ci()
    output <-
      scrape_urls(
        Urls = "https://web.archive.org/web/20221013232615/https://stackoverflow.com/questions/21167159/css-nth-match-doesnt-work",
        Paths = c(answer = "//div[@itemprop='text']/*", author = "//div[@itemprop='author']/span[@itemprop='name']"),
        collapse = "//div[@id='answers']/div[contains(@class, 'answer')]",
        encoding = "bytes")
  expect_is(output, "data.frame")
})




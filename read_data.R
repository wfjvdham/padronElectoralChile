library("tabulizer")
library("tidyverse")
library("lubridate")

# command to move pdfs to one folder
# sudo mv */* /
options(java.parameters = "-Xmx7000m")

pathToPdfs <- "../pdfs/"
pathToParsedData <- "./parsed_data/"

files <- list.files(path = pathToPdfs) %>%
  str_sub(start = 1L, end = -5L) %>%
  as_data_frame()

filesFinished <- list.files(path = pathToParsedData) %>%
  str_sub(start = 1L, end = -5L) %>%
  as_data_frame()

filesToDo <- anti_join(files, filesFinished)

1:nrow(filesToDo) %>%
  purrr::map(function(i_file) {
    print(now())
    print(paste("file number", i_file, "/", nrow(filesToDo)))
    
    file <- filesToDo[i_file, ]  
    print(paste("file name:", file))
    parsedFile <- extract_tables(paste0(pathToPdfs, file, ".pdf"))

    pages <- 1:length(parsedFile) %>%
      purrr::map(function(i_page) {
        page <- parsedFile[[i_page]]
        colnames(page) <- page[2,]
        page <- page[-c(1, 2), ]
        page[,c("NOMBRE", "C.IDENTIDAD", "SEXO", "DOMICILIO ELECTORAL", "CIRCUNSCRIPCIÓN", "MESA")]
      })
    
    total <- do.call("rbind", pages)
    saveRDS(total, file = paste0(pathToParsedData, file, ".Rda"))
  })

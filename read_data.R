library("tabulizer")
library("tidyverse")

files <- list.files(path = "../pdfs")

totalList <- 1:length(files) %>%
  purrr::map(function(i_file) {
    print(paste("file number", i_file, "/", length(files)))
    
    file <- files[[i_file]]  
    parsedFile <- extract_tables(paste0("../pdfs/", file))
    
    pages <- 1:length(parsedFile) %>%
      purrr::map(function(i_page) {
        print(paste("page number", i_page, "/", length(parsedFile)))
        
        page <- parsedFile[[i_page]]
        colnames(page) <- page[2,]
        page <- page[-c(1, 2), ] 
        page[,c("NOMBRE", "C.IDENTIDAD", "SEXO", "DOMICILIO ELECTORAL", "CIRCUNSCRIPCIÓN", "MESA")]
      })
    
    do.call("rbind", pages)
  })

totalDf <- do.call("rbind", totalList)
saveRDS(total, file = "data.Rda")

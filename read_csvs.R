library("tidyverse")
library("lubridate")
library("stringr")

pathToCsvs <- "../csvs/"
pathToParsedData <- "./parsed_data/"

files <- list.files(path = pathToCsvs) %>%
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
    parsedFile <- read_csv(paste0(pathToCsvs, file, ".csv"), 
                           col_names = c("NOMBRE", "C.IDENTIDAD", "X1", "MESA", "X3")) %>%
      select(-X3) %>%
      mutate(nr = row_number()) %>%
      separate(X1, c("SEX", "X1"), sep = 4) %>%
      mutate(`DOMICILIO ELECTORAL` = sub(X1, pattern = " [[:alpha:]]*$", replacement = ""),
             CIRCUNSCRIPCIÓN = word(X1,-1))

    new_page <- parsedFile %>% 
      filter(NOMBRE == "NOMBRE")
    
    parsedFile <- parsedFile %>%
      filter(!nr %in% c(new_page$nr, new_page$nr - 1, new_page$nr - 2, new_page$nr - 3)) %>%
      select(NOMBRE, C.IDENTIDAD, SEX, `DOMICILIO ELECTORAL`, CIRCUNSCRIPCIÓN, MESA)
    
    parsedFile <- as.list(parsedFile)
    saveRDS(parsedFile, file = paste0(pathToParsedData, file, ".Rda"))
  })

filesFinished <- list.files(path = pathToParsedData) %>%
  str_sub(start = 1L, end = -5L)

total_list <- 1:length(filesFinished) %>%
  map(function(i) {
    temp <- readRDS(paste0(pathToParsedData, filesFinished[i], ".Rda"))  %>% 
      as_data_frame()
    colnames(temp) <- c("NOMBRE", "C.IDENTIDAD", "SEXO", "DOMICILIO ELECTORAL", 
                        "CIRCUNSCRIPCIÓN", "MESA")  
    temp
  })

total_padron_df <- do.call("rbind", total_list) 
total_padron_df$NOMBRE <- tolower(total_padron_df$NOMBRE) 
saveRDS(total_padron_df, file = "total_padron.Rda")

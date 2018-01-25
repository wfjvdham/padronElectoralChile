library("tidyverse")
library("readxl")

source('./splitting_names.R')

file <- "../lobby/BB.DD. LOBBY 2_ (1).xlsx"
sheets <- excel_sheets(file)
sheets_data <- map(sheets, function(X) {
  result <- read_excel(file, sheet = X)
  result <- result %>% select(1:13)
  result$month <- X
  result
})

lobby_data_xl <- do.call("rbind", sheets_data) %>%
  select(
    nombreCompletoActivo = `Sujetos Activos`,
    nombreInstitucion = `Organismo Público`,
    topic = `Materia de Audiencia`,
    fecha = Fecha,
    nombreCompletoPasivo = Autoridad,
    `Cargo autoridad`, `Categoria Cargo`, `Categorización FM`, 
    `Categorización portal`, `Materia Ley`
  ) %>%
  mutate(nombreCompletoActivo = str_split(nombreCompletoActivo, ","),
         nombreActivo = NA,
         apellidosActivo = NA,
         nombrePasivo = NA,
         apellidosPasivo = NA,
         codigoInstitucion = NA,
         codigoActualDatasetRegistro = paste0("xl-", rep(1:nrow(.)))) %>%
  unnest()

pasivos <- read_delim("../lobby/pasivos.csv", delim = ";")
activos <- read_csv("../lobby/activos_parsed.csv") %>%
  select(codigoActualDatasetRegistro, nombreActivo, apellidosActivo)
datos_audiencias <- read_csv("../lobby/datosAudiencia.csv")

names_institution_topics <- merge(pasivos, datos_audiencias, by = "codigoActualDatasetRegistro", all = TRUE) %>%
  select(
    nombrePasivo, apellidosPasivo,
    nombreInstitucion, codigoInstitucion,
    topic = observacionesMateriaAudiencia,
    fecha = fechaInicio,
    codigoActualDatasetRegistro
  ) %>%
  merge(activos, by = "codigoActualDatasetRegistro", all = TRUE) %>%
  mutate(
    nombreCompletoPasivo = ifelse(
      is.na(nombrePasivo) | is.na(apellidosPasivo),
      NA,
      paste(nombrePasivo, apellidosPasivo)
    ),
    nombreCompletoActivo = ifelse(
      is.na(nombreActivo) | is.na(apellidosActivo),
      NA,
      paste(nombreActivo, apellidosActivo)
    ),
    `Cargo autoridad` = NA, 
    `Categoria Cargo` = NA, 
    `Categorización FM` = NA, 
    `Categorización portal` = NA, 
    `Materia Ley` = NA
  )

parse_names <- function(names) {
  names %>%
    tolower() %>%
    str_trim()
}

lobby_data <- rbind(names_institution_topics, lobby_data_xl) %>%
  mutate(
    nombreCompletoActivo = parse_names(nombreCompletoActivo),
    nombreCompletoPasivo = parse_names(nombreCompletoPasivo),
    nombreActivo = parse_names(nombreActivo),
    nombrePasivo = parse_names(nombrePasivo),
    apellidosActivo = parse_names(apellidosActivo),
    apellidosPasivo = parse_names(apellidosPasivo)
  )

names_table <- lobby_data %>%
  filter(is.na(apellidosActivo)) %>%
  select(nombreCompleto = nombreCompletoActivo) %>%
  split_names()

lobby_data <- lobby_data %>%
  merge(names_table, by.x = "nombreCompletoActivo", by.y = "nombreCompleto", all.x = TRUE) %>%
  mutate(
    nombreActivo = ifelse(!is.na(nombreActivo), nombreActivo, nombre),
    apellidosActivo = ifelse(!is.na(apellidosActivo), apellidosActivo, apellidos)
  ) %>%
  select(-nombre, -apellidos)

saveRDS(lobby_data, "./combined_lobby_data.Rda")

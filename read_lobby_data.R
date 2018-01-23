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
    nombreCompleto = `Sujetos Activos`,
    nombreInstitucion = `Organismo Público`,
    topic = `Materia de Audiencia`,
    fecha = Fecha
  ) %>%
  mutate(nombreCompleto = str_split(nombreCompleto, ","),
         nombre = NA,
         apellidos = NA,
         codigoInstitucion = NA) %>%
  unnest()

# file <- "../lobby/audiencias.csv"
# audiencias <- read_csv(file) %>%
#  select(nombreInstitucion, nombreComuna, observacionesMateriaAudiencia, descripcionMateria)
# The columns observacionesMateriaAudiencia and descripcionMateria
# both can contain descriptions about the meeting
# The file datosAudiencia.csv is beter formatted and has the same information

# file <- "../lobby/asistenciasActivos.csv"
# asistencias_activos <- read_delim(file, delim = ";")
# Table for combining data which is not used at the moment

# file <- "../lobby/entidades.csv"
# entidades <- read_csv(file)
# File to get the details about the entities

#activos_parsed <- read_csv("../lobby/activos_parsed.csv")
#file without description of the meeting

file <- "../lobby/pasivos.csv"
pasivos <- read_delim(file, delim = ";")
# Table with names that can be connected to the meetings

#most ids in pasivo are in active
#sum(unique(activos_parsed$codigoActualDatasetRegistro) %in% 
#      unique(pasivos$codigoActualDatasetRegistro))

file <- "../lobby/datosAudiencia.csv"
datos_audiencias <- read_csv(file)

names_institution_topics <- merge(pasivos, datos_audiencias, by = "codigoActualDatasetRegistro") %>%
  select(
    nombre = nombrePasivo, apellidos = apellidosPasivo,
    nombreInstitucion, codigoInstitucion,
    topic = observacionesMateriaAudiencia,
    fecha = fechaInicio
  ) %>%
  mutate(nombreCompleto = paste(nombre, apellidos))

parse_names <- function(names) {
  names %>%
    tolower() %>%
    str_trim()
}

lobby_data <- rbind(names_institution_topics, lobby_data_xl) %>%
  mutate(
    nombreCompleto = parse_names(nombreCompleto),
    nombre = parse_names(nombre),
    apellidos = parse_names(apellidos)
  )

last_names <- read_csv("../names/last_name.csv")
lobby_data <- lobby_data %>%
  mutate(apellidos_split = str_split(apellidos, " ")) %>%
  unnest() %>%
  mutate(
    last_names_in_list = apellidos_split %in% last_names$last_name
  )

# consistency check
sum(unique(last_names$last_name) %in% unique(lobby_data$apellidos_split))
length(unique(last_names$last_name))
length(unique(lobby_data$apellidos_split))

names_table <- lobby_data %>%
  filter(is.na(apellidos)) %>%
  select(nombreCompleto) %>%
  split_names()

lobby_data <- lobby_data %>%
  select(-nombre, -apellidos, -last_names_in_list, -apellidos_split) %>%
  merge(names_table, by = "nombreCompleto")

write_csv(lobby_data, "./combined_lobby_data.csv")

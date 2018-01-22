library("tidyverse")
library("readxl")

file <- "../lobby/BB.DD. LOBBY 2_ (1).xlsx"
sheets <- excel_sheets(file)
sheets_data <- map(sheets, function(X) {
  result <- read_excel(file, sheet = X)
  result <- result %>% select(1:13)
  result$month <- X
  result
})

lobby_data <- do.call("rbind", sheets_data)

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

file <- "../lobby/pasivos.csv"
pasivos <- read_delim(file, delim = ";")
# Table with names that can be connected to the meetings

file <- "../lobby/datosAudiencia.csv"
datos_audiencias <- read_csv(file)

combined_data <- merge(pasivos, datos_audiencias, by = "codigoActualDatasetRegistro") %>%
  select(
    nombre = nombrePasivo, apellidos = apellidosPasivo,
    nombreInstitucion, codigoInstitucion,
    topic = observacionesMateriaAudiencia,
    fecha = fechaInicio
  ) %>%
  mutate(nombreCompleto = paste(nombre, apellidos))
lobby_data <- lobby_data %>%
  select(
    nombreCompleto = `Sujetos Activos`,
    nombreInstitucion = `Organismo Público`,
    topic = `Materia de Audiencia`,
    fecha = Fecha
  ) %>%
  mutate(nombreCompleto = str_split(nombreCompleto, ",")) %>%
  unnest()
lobby_data$nombre <- NA
lobby_data$apellidos <- NA
lobby_data$codigoInstitucion <- NA

parse_names <- function(names) {
  names %>%
    tolower() %>%
    str_trim()
}

combined_lobby_data <- rbind(combined_data, lobby_data) %>%
  mutate(
    nombreCompleto = parse_names(nombreCompleto),
    nombre = parse_names(nombre),
    apellidos = parse_names(apellidos)
  )
write_csv(combined_lobby_data, "./combined_lobby_data.csv")

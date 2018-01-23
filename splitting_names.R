split_names <- function(data) {
  last_names <- read_csv("../names/last_name.csv")
  data %>%
    separate(nombreCompleto, into = c("1", "2", "3", "4", "5", "6"), remove = FALSE) %>%
      mutate(
        first_apellido = case_when(
          `1` %in% last_names$last_name ~ 2,
          `2` %in% last_names$last_name ~ 2,
          `3` %in% last_names$last_name ~ 3,
          `4` %in% last_names$last_name ~ 4,
          `5` %in% last_names$last_name ~ 5,
          TRUE ~ NA_real_
        ),
        nombreCompleto_split = str_split(nombreCompleto, " ")
      ) %>%
      filter(!is.na(first_apellido)) %>%
      mutate(
        nombre = map2(
          nombreCompleto_split, first_apellido, ~ paste(.x[1:(.y - 1)], collapse = " ")
        ),
        apellidos = map2(
          nombreCompleto_split, first_apellido, ~ paste(.x[.y:length(.x)], collapse = " ")
        )
      ) %>%
      select(nombreCompleto, nombre, apellidos) %>%
      unnest()
}

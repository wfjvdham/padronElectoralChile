# Padron Electoral Chile

The goal of this project is to read, combine and anelyze different datasources about the `lobby` and the `padron` in Chile. 

The project has the following files:

## R Files

`read_data.R` - File used to parse the information from the pdf-files to a R format directly using the `tabulizer` package for R. This way is slow and has some memmory problems for the bigger files. So it is not recommended to use this way of parsing.

`read_csvs.R` - This file is used to parse the data from the csv-files into a R format. The `tabulazer-cli` is used to convert the pdf-files in csv-files. This way is faster and has less memory problems. Stil some pdf-files where to big to parse directly, but after splitting the using the same `tabulazer-cli` there where no problems anymore. The result of combining all the data from the csv-files is a `total_padron.Rda` data file.

`read_lobby_data.R` - This file is used to read and combine the different lobby data sources. Later in this document an overview of the lobby datasources is given. The result of running this R file is an `combined_lobby_data.csv` data file.

`splitting_names.R` - A file that contains the function of splitting a complete name into a name and an apellido. Based on the last names defined in the `last_names.csv` file.

`lobby.Rmd` - File that contains the report about the lobby data. As an imput it is using the data files created by the read_* files described above. It also uses the `keywords - etiquetas - Sheet1.csv` and tags the words in that file in the description of the meeting. This to determine which meetings contain sensitive information and which ones not.

## Lobby Files

Not all the data files about the lobby contain usefull information. Here is described per file if it is used and which information is used from it:

### Used

`pasivos.csv` - Contains the names that can be connected with the meetings.

`datosAudiencia.csv` - Contains the description of what was discussed in the meeting. This information is used to check if a meeting is sensitive or not.

### Not Used

`audiencias.csv` - The columns observacionesMateriaAudiencia and descripcionMateria both can contain descriptions about the meeting. But the data in the `datosAudiencia.csv` file is beter formatted and has the same information. Therefore that file is used.

`asistenciasActivos.csv` - Contains ids for combining data from different sources but is not needed. 

`entidades.csv` - File that contains more details about the entities. But for now only the name of the entity is enough.

`activos.csv` - This file has some difficulties when reading. After opening in ecel and saving as a csv with a different formatting it works fine. It contains the names of the persons in a meeting but not the description of the meeting.



## Shiny App zur Codierung von automatisiert identifizierten individuellen Akteur:innen in journalistischen Texten
## TODO: Rolle eines Akteurs codieren - aktiv oder nicht, sagt die Person etwas oder nicht.

library(shiny)
library(shinyjs)
library(shinyFiles)
library(shinyWidgets)
library(bslib)
library(tidyverse)

## Globale Variablen ###########################################################

## Dateipfad, Datensatz und Liste mit den IDs werden als globale Variablen initialisiert.

file_path <- ""
full_dataset <- data.frame()
ids <- list()
coder <- 0

## Liste mit Variablennamen, wird verwendet, um Eingaben abzuspeichern, zu aktualisieren und später in eine Datei zu schreiben.

variables <- c("coder", "nameinst", "gender", "aktbez", "discipline", "aktort", "misclassification", "duplicate", "journalist", "passive_actor")

## Funktionen ##################################################################

## Speicherfunktion: erhält als Argumente den aktuellen Akteur sowie die Werte der aktuellen Eingaben.
## zuerst wird geprüft, ob alle Variablen bereits im Datensatz angelegt wurden, falls nicht, werden sie leer erzeugt.
## Dann wird für den aktuellen Artikel die coded-Variable auf TRUE gesetzt.
## Es findet eine Plausibilitätsprüfung statt, unlogische/unmögliche Werte werden verändert.
## Zuletzt werden die Eingabewerte in den Datensatz geschrieben und dieser als Rds abgespeichert, dafür wird der global festgelegte Dateipfad verwendet.

save_data <- function(actor, inputs){
  for(variable in variables){
    if(!(variable %in% names(full_dataset))){
      full_dataset[, variable] <<- NA
    }
  }
  full_dataset[full_dataset$entity_id == actor$entity_id, "coded"] <<- TRUE
  if(!inputs["aktbez"] %in% c(100, 300)){
    inputs["discipline"] <-  NA
  }
  if(any(as.logical(unlist(inputs[c("misclassification", "duplicate", "journalist", "passive_actor")])))){
    inputs[c("nameinst","aktbez", "gender", "discipline", "aktort")] <- NA
  }
  for (variable in variables){
    if(variable %in% c("nameinst", "misclassification", "duplicate", "journalist", "passive_actor")){
      full_dataset[full_dataset$entity_id == actor$entity_id, variable] <<- inputs[variable]
    }
    else{
      full_dataset[full_dataset$entity_id == actor$entity_id, variable] <<- as.numeric(inputs[variable])
    }
  }
  saveRDS(full_dataset, file_path)
}

## In Fällen, in denen ein Akteur mit exakt dem gleichen Namen im Artikel codiert wurde, muss die:der Codierer:in nichts machen, der Akteur wird automatisch übersprungen.
## In diesem Fall wird nur die coded-Variable auf TRUE gesetzt und zudem der Akteur als duplicate markiert.

save_duplicate <- function(actor){
  full_dataset[full_dataset$entity_id == actor$entity_id, "coded"] <<- TRUE
  full_dataset[full_dataset$entity_id == actor$entity_id, "duplicate"] <<- TRUE
  full_dataset[full_dataset$entity_id == actor$entity_id, "coder"] <<- coder
  saveRDS(full_dataset, file_path)
}

## Beim Zurückgehen zum letzten Akteur werden aus dem Datensatz die Eigenschaften dieses Akteurs abgerufen.
## In einzelnen Fällen werden die Werte verändert, sodass sie zum Updaten der Inputs genutzt werden können.
## Dann werden die Inputs auf die zuvor abgerufenen Werte gesetzt.

set_to_last_value <- function(session = shiny::getDefaultReactiveDomain(), ids, index){
  actor_codes <<- full_dataset[full_dataset$entity_id == ids[index],]
  for (variable in variables){
    if(is.na(actor_codes[[variable]][[1]])){
      if (variable %in% c("misclassification", "duplicate", "journalist", "passive_actor")){
        actor_codes[[variable]][[1]] <- FALSE
      }
      else{
        actor_codes[[variable]][[1]] <- ""
      }
    } 
  }
  updateTextInput(session = session, inputId = "nameinst", value = actor_codes[["nameinst"]][[1]])
  updateRadioButtons(session = session, inputId = "gender", selected = actor_codes[["gender"]][[1]])
  updateSelectInput(session = session, inputId = "aktbez", selected = actor_codes[["aktbez"]][[1]])
  updateRadioButtons(session = session, inputId = "discipline", selected = actor_codes[["discipline"]][[1]])
  updateRadioButtons(session = session, inputId = "aktort", selected = actor_codes[["aktort"]][[1]])
  updateCheckboxInput(session = session, inputId = "misclassification", value = as.logical(actor_codes[["misclassification"]]))
  updateCheckboxInput(session = session, inputId = "duplicate", value = as.logical(actor_codes[["duplicate"]]))
  updateCheckboxInput(session = session, inputId = "journalist", value = as.logical(actor_codes[["journalist"]]))
  updateCheckboxInput(session = session, inputId = "passive_actor", value = as.logical(actor_codes[["passive_actor"]]))
}

## Zurücksetzen der Inputs auf ihre Standardwerte.

reset_inputs <- function(session = shiny::getDefaultReactiveDomain()){
  updateTextInput(session = session, inputId = "nameinst", value = "")
  updateRadioButtons(session = session, inputId = "gender", selected = "")
  updateSelectInput(session = session, inputId = "aktbez", selected = "")
  updateRadioButtons(session = session, inputId = "discipline", selected = "")
  updateRadioButtons(session = session, inputId = "aktort", selected = "")
  updateCheckboxInput(session = session, inputId = "misclassification", value = FALSE)
  updateCheckboxInput(session = session, inputId = "duplicate", value = FALSE)
  updateCheckboxInput(session = session, inputId = "journalist", value = FALSE)
  updateCheckboxInput(session = session, inputId = "passive_actor", value = FALSE)
}

## Markieren der Akteursnamen im Text

mark_actor_names <- function(actor_name){
  paste0("<mark><strong>",actor_name,"</strong></mark>")
}

## UI ##########################################################################

## Kleinere Anpassung der Oberfläche: Schriftart, Buttons und Markierungen.

app_style <- 'p, label, ul{
  font-size: 16px;
}
.app-danger.btn-danger {
  color: #ffffff !important;
  margin-top: 20px;
  margin-bottom: 10px;
}
.app-back.btn-secondary{
  margin-top: 20px;
  margin-bottom: 10px;
}
.scrollbox{
  overflow-y: auto;
  max-height: calc(100vh - 142px);
}
mark {
  background-color: LightSkyBlue;
}'

## Input-Elemente werden definiert. Werden später nach und nach erzeugt, die meisten erst nach dem Einlesen des Datensatzes.

coder_input <- numericInput("coder", label = "Coder-ID:",
                            value = 1, min = 1, max = 20, step = 1)

besprechung_input <- checkboxInput("besprechung", label = "Besprechungsmodus")

relevance_check_input <- wellPanel(h3("Filter"),
                                   checkboxInput("misclassification", "Es handelt sich nicht um eine Person.", FALSE),
                                   checkboxInput("duplicate", "Akteur:in wurde in diesem Artikel bereits codiert.", FALSE),
                                   checkboxInput("journalist", "Person ist Autor:in des Artikels.", FALSE),
                                   checkboxInput("passive_actor", "Akteur:in ist passiv.", FALSE))

nameinst_input <- textInput("nameinst", label = "Institution/Organisation (nameinst)")

gender_input <- radioButtons("gender", label = "Geschlecht (gender)",
                             choices = c("Nichts ausgewählt" = "",
                                         "männlich" = 0,
                                         "weiblich" = 1,
                                         "anderes/nicht klar bestimmbar" = 99))

aktbez_input <- selectInput("aktbez", label = "Zugehörigkeit zu Gesellschaftsbereich (aktbez)",
                             choices = c("Nichts ausgewählt" = "",
                                         "Wissenschaft" = 100,
                                         "Politik" = 200,
                                         "Politische Exekutive" = 210,
                                         "Politische Administration" = 220,
                                         "Politische Legislative" = 230,
                                         "CDU/CSU" = 231,
                                         "SPD" = 232,
                                         "Grüne" = 233,
                                         "FDP" = 234,
                                         "AfD" = 235,
                                         "Linke" = 236,
                                         "Sonstige Partei" = 237,
                                         "Conservative Party/Tories" = 238,
                                         "Labour Party" = 239,
                                         "Liberal Democrats" = 240,
                                         "UKIP" = 241,
                                         "BNP" = 242,
                                         "Greens" = 243,
                                         "Respect" = 244,
                                         "English Democrats" = 245,
                                         "Wissenschaftliche Administration" = 300,
                                         "Medizin" = 400,
                                         "Interessenverbände" = 500,
                                         "Interessenverbände 1 (Kollektivgüter)" = 510,
                                         "Interessenverbände 2 (Partialinteressen)" = 520,
                                         "Non-Profit-Organisationen" = 521,
                                         "For-Profit-Organisationen" = 522,
                                         "Sonstige" = 900,
                                         "Bildung / Schule" = 910,
                                         "Journalismus" = 920,
                                         "Kultur" = 930))

disc_input <- radioButtons("discipline", label = "Wissenschaftliche Disziplin (discipline)",
                           choices = c("Nichts ausgewählt" = "",
                                       "Geisteswissenschaften" = 1,
                                       "Sozial- und Verhaltenswissenschaften" = 2,
                                       "Biologie" = 3,
                                       "Medizin" = 4,
                                       "Agrar-, Forstwissenschaften und Tiermedizin" = 5,
                                       "Chemie" = 6,
                                       "Physik" = 7,
                                       "Mathematik" = 8,
                                       "Geowissenschaften" = 9,
                                       "Informatik, System- und Elektrotechnik" = 10,
                                       "Ingenieurwissenschaften" = 11,
                                       "Bauwesen und Architektur" = 12,
                                       "Kein:e Forscher:in" = 13,
                                       "Nicht zu erkennen" = 99))

aktort_input <- radioButtons("aktort", label = "Nationale Verortung (aktort)",
                             choices = c("Nichts ausgewählt" = "",
                                         "Deutschland" = 1,
                                         "Anderes EU-Land" = 2,
                                         "Großbritannien" = 21,
                                         "USA" = 3,
                                         "Anderes Land" = 4,
                                         "Supranational" = 5,
                                         "Nicht feststellbar" = 99))

## UI besteht aus einer Fluid Page mit einer Navbar. Über diese kann man zwischen dem Codebogen und dem Codebuch wechseln.
## Der Codebogen besteht aus einem Sidebar-Layout, das MainPanel beinhaltet zu Beginn nur die Elemente zum Einlesen des Datensatzes.
## Hierfür wird ein ShinyFilesButton verwendet.
## Später wird hier der zu codierende Text angezeigt. Die Sidebar beinhaltet zu Beginn noch nichts, später sind hier die Eingabeelemente.

ui <- fluidPage(
  theme = bs_theme(bootswatch = "flatly"),
  tags$head(tags$style(app_style)),
  useShinyjs(),
  navbarPage(
    title = "Codierung der Akteurszugehörigkeit",
    tabPanel(
      "Codebogen",
      sidebarLayout(
        mainPanel(
          width = 8,
          tags$div(
            id = "initial_elements",
            wellPanel(
              p(
                "Vor Beginn der eigentlichen Codierung müssen ein paar Informationen eingetragen werden: "
              ),
              coder_input,
              shinyFilesButton(
                "dataset",
                "Datensatz auswählen, der codiert werden soll",
                "Datensatz auswählen",
                multiple = FALSE,
                class = "btn-secondary btn-lg"
              )
            ),
            tags$div(id = "dataset_info", uiOutput("initial_info"))
          )
        ),
        sidebarPanel(width = 4, tags$div(id = "coding_area")),
        position = "left"
      )
    ),
    tabPanel(
      "Codebuch",
      tabsetPanel(
        tabPanel(
          title = "Einleitung",
          fluidRow(column(8, includeMarkdown("source_codebuch/einleitung_smc_london.md"))) 
        ),
        tabPanel(
          title = "Formale Kategorien",
          fluidRow(column(8, includeMarkdown("source_codebuch/formale_variablen_smc_london.md")))
        ),
        tabPanel(
          title = "Inhaltliche Kategorien 1",
          fluidRow(column(8, includeMarkdown("source_codebuch/inhaltliche_variablen_1_smc_london.md")))
        ),
        tabPanel(
          title = "Inhaltliche Kategorien 2 - aktbez",
          fluidRow(column(8, includeMarkdown("source_codebuch/inhaltliche_variablen_2_smc_london.md")))
        ),
        tabPanel(
          title = "Inhaltliche Kategorien 3 - discipline",
          fluidRow(column(8, includeMarkdown("source_codebuch/inhaltliche_variablen_3_smc_london.md")))
        ),
        tabPanel(
          title = "Inhaltliche Kategorien 4 - aktort",
          fluidRow(column(8, includeMarkdown("source_codebuch/inhaltliche_variablen_4_smc_london.md")))
        )
      )
    )
  )
)

## Server ######################################################################

server <- function(input, output, session){
  
## Insgesamt drei Reactive Values werden verwendet, um die Zahl der codierten Akteure, den Index des aktuellen Akteurs sowie die Zahl der zusätzlichen Sätze, die angezeigt werden sollen, zu speichern.
## Diese werden auch dafür verwendet, die Reihenfolge der Ausführung der weiteren Elemente zu steuern.
  
  start_time <- Sys.time()
  
  rv <- reactiveValues()
  
  rv$actors_coded <- 0
  rv$index_actor <- 0
  rv$context <- 0
  
## Diese Output-Elemente werden in der Sidebar verwendet, um Informationen zur
## Codiersession und zum aktuellen Datensatz anzuzeigen.
## Duration_session aktualisiert sich momentan alle 30 Sekunden und zeigt die
## Dauer in Minuten und Stunden an.
## Coded_articles_session und coded_articles_overall wird jedes Mal erhöht,
## wenn ein Artikel gespeichert wird.
## Zudem wird der Name des Datensatzes angezeigt, der aktuell bearbeitet wird
## und die Zahl der enthaltenen Artikel.
  
  output$duration_session <- renderText({
    invalidateLater(
      millis = 30000,
      session = session
    )
    dt <- difftime(
      time1 = Sys.time(),
      time2 = start_time,
      units = "secs"
    )
   paste0(
      "<b>Dauer der Session: ",
      format(.POSIXct(dt, tz = "GMT"), "%H:%M</b>")
    )
  })
  
  output$coded_actors_session <- renderText({
    paste0(
      "<b>Codierte Akteure (Session): ",
      rv$actors_coded,
      "</b>"
    )
  })
  
  output$coded_actors_overall <- renderText({
    req(actors_dataset())
    rv$index_actor
    number_coded_actors <-
      ifelse(exists("full_dataset"), length(full_dataset[full_dataset$coded, "coded"]), 0)
    paste0("<b>Codierte Akteure (gesamt): ", number_coded_actors, "</b>")
  })
  
  output$properties_dataset <- renderText({
    req(actors_dataset())
    paste0("<b>Enthaltene Akteure: ", nrow(actors_dataset()), "</b>")
  })
  
## Zuerst wird festgelegt, dass Dateien mit einer Größe von bis zu 300 MB eingelesen werden können.
## Für das Einlesen der Datensätze muss ein Root-Verzeichnis angegeben werden und die shinyFileChoose-Funktion ausgeführt werden.
  
  options(shiny.maxRequestSize=300*1024^2)
  roots=c(wd='.')
  shinyFileChoose(input, "dataset", roots=roots,
                  filetypes=c('', 'RDS', 'Rds'),
                  defaultPath='', defaultRoot='wd')
  
## Sobald eine Datei hochgeladen wurde, wird geprüft, ob diese das richtige Format hat. Ist das der Fall, wird sie als data.frame eingelesen.
## Wenn die zum ersten Mal eingelesen wurde und es daher noch keine Coded-Variable gibt, wird diese angelegt. Der Datensatz wird dann in die globale full_dataset-Variable geschrieben.
  
  actors_dataset <- reactive({
    req(input$dataset)
    file <- parseFilePaths(roots=roots,input$dataset)
    ext <- tools::file_ext(file$datapath)
    
    req(file)
    validate(need(ext %in% c("RDS", "Rds"), "Falsches Dateiformat. Bitte eine .Rds-Datei auswählen."))
    
    actors <- readRDS(file$datapath)
    if(!"coded" %in% names(actors)){actors$coded <- FALSE}
    full_dataset <<- actors
    actors
  })
  
## Wenn eine Datei erfolgreich eingelesen wurde, wird in der UI angezeigt, wie der Datensatz heißt, wie viele Akteure enthalten sind, und wie viele bereits codiert wurden.
  
  output$initial_info <- renderUI({
    req(actors_dataset())
    file <- parseFilePaths(roots=roots,input$dataset)
    str_output1 <- paste0("Datensatz ", file$name, " eingelesen, mit folgenden Eigenschaften: ")
    str_output2 <- paste0(length(actors_dataset()$entity), " Akteure insgesamt enthalten, davon wurden bisher ", length(actors_dataset()[actors_dataset()$coded,][["coded"]]), " codiert.")
    tags$div(id = "infotext", br(), p(str_output1), p(str_output2))
  })
  
## Zusätzlich wird ein Button eingefügt, mit dem das Codieren begonnen werden kann.
  
  observeEvent(actors_dataset(), {
    insertUI(selector = "#dataset_info", where = "afterEnd",
             ui = tags$div(id = "start",
                           besprechung_input,
                           actionButton("start_button", label = "Codieren beginnen", class = "btn-secondary btn-lg"),
                           br(),
                           br()))}, once = TRUE)
  
## Wenn der Knopf gedrückt wird, wird zuerst geprüft, ob der Datensatz bereits vollständig codiert wurde.
## Ist das nicht der Fall, wird der Dateipfad in die globale file_path-Variable geschrieben und die UI-Elemente für den Text und die Eingabeelemente werden eingefügt.
## Unterhalb der Eingabeelemente werden drei Knöpfe erzeugt. Mit einem können weitere Sätze angezeigt werden, mit einem der aktuelle Akteur gespeichert werden, mit einem zum letzten zurückgegangen werden.
## Dafür werden die alten Elemente für das Einlesen des Datensatzes entfernt. Zuletzt wird der Index des aktuellen Akteurs um eins erhöht.
  
  observeEvent(input$start_button, {
    if(length(full_dataset[!full_dataset$coded,][["coded"]]) == 0 & !input$besprechung){
      show_alert(title = "Fehler", text = "Datensatz wurde bereits vollständig codiert. Bitte einen anderen Datensatz wählen.", type = "error")
    }
    else{
      file <- parseFilePaths(roots=roots,input$dataset)
      file_path <<- file$datapath
      coder <<- input$coder
      insertUI(selector = "#coding_area", where = "beforeEnd",
               ui = tags$div(id = "coder_info",
                             htmlOutput("duration_session"),
                             htmlOutput("coded_actors_session"),
                             htmlOutput("coded_actors_overall"),
                             htmlOutput("properties_dataset"),
                             br()))
      insertUI(selector = "#initial_elements", where = "afterEnd",
               ui = wellPanel(tags$div(id = "text_area",
                             uiOutput("article")),
                             tags$div(id = "actors_article",
                             br(),
                             h3("Bereits codierte Akteur:innen in diesem Artikel"),
                             tableOutput("actors_table"))))
      insertUI(selector = "#coder_info", where = "afterEnd",
               ui = tags$div(id = "inputs",
                             relevance_check_input,
                             br(),
                             conditionalPanel(
                               condition = "input.misclassification === false && input.duplicate === false && input.journalist === false && input.passive_actor === false",
                               nameinst_input,
                               gender_input,
                               aktbez_input,
                               conditionalPanel(
                                 condition = "input.aktbez == 100 || input.aktbez == 300",
                                 disc_input),
                               aktort_input),
                             hr(),
                             splitLayout(
                               cellWidths = c("50%","50%"),
                               actionButton("more_context", "Weitere Sätze", class = "btn-info btn-lg", width = "100%"),
                               actionButton("full_context", "Kompletter Text", class = "btn-info btn-lg", width = "100%")),
                             br(),
                             actionButton("submit_actor", "Eingaben abspeichern und zum nächsten Akteur gehen.", class="btn-success btn-lg", width = "100%"),
                             br(),
                             br(),
                             actionButton("last_actor", "Zum letzten Akteur zurückgehen", class = "btn-secondary btn-lg", width = "100%")))
      removeUI(selector = "#start")
      removeUI(selector = "#dataset_info")
      removeUI(selector = "#initial_elements")
      if(input$besprechung){
        ids <<- full_dataset[full_dataset$coded,][["entity_id"]]
        }
      else{
        ids <<- full_dataset[!full_dataset$coded,][["entity_id"]]
        }
      rv$index_actor <- rv$index_actor + 1
    }
  })
  
## Immer, wenn der Index des aktuellen Akteurs verändert wird, wird basierend auf dieser ID ein neuer Akteur aus dem Datensatz zurückgegeben.
## Wenn dieser bereits codiert wurde, werden die Eingabeelemente auf die Werte des Akteurs gesetzt, ansonsten werden sie zurückgesetzt.
  
  draw_actor <- eventReactive(
    {rv$index_actor},
    {validate(need(length(ids) > 0, message = FALSE))
      actor <- full_dataset[full_dataset$entity_id == ids[rv$index_actor],]
      actor$sentences <- str_split(actor$sentences_joined, "<->")
      if(actor$coded){
        set_to_last_value(session = session, ids = ids, index = rv$index_actor)
      }
      else{
        reset_inputs(session = session)
      }
      actor}
  )

## Falls ein Akteur mit exakt dem gleichen Namen bereits im aktuellen Artikel codiert wurde, wird er übersprungen, dafür wird die save_duplicate-Funktion aufgerufen.
  
  observeEvent(draw_actor(),{
    if(!draw_actor()[["coded"]] & draw_actor()[["entity"]] %in% full_dataset[(full_dataset$document_id == draw_actor()[["document_id"]]) & full_dataset$coded, "entity"]){
      save_duplicate(draw_actor())
      rv$actors_coded <- rv$actors_coded +1
      rv$index_actor <- rv$index_actor + 1
    }
  })
  
## Jedes Mal, wenn ein neuer Akteur gesampelt wird, verändert sich der angezeigte Text. Es wird der Satz angezeigt, in dem der Akteur vorkommt sowie so viele zusätzliche Sätze, wie
## über den Kontext-Button ausgewählt wurden. Alle Vorkommen des Namens des Akteurs werden markiert.
  
  output$article <- renderUI({
    req(draw_actor())
    sentence_id <- draw_actor()[["sentence_id"]]
    sentences <- draw_actor()[["sentences"]][[1]]
    entity_name <- draw_actor()[["entity"]]
    surname <- str_match(entity_name, "[^\\s]*\\s([\\s\\S]*)")[,2]
    entity_name_surname <- ifelse(is.na(surname), entity_name, paste(entity_name, surname, sep = "|"))
    start_id <- ifelse((sentence_id - rv$context) > 0, sentence_id - rv$context, 1)
    end_id <- ifelse((sentence_id + rv$context) <= length(sentences), sentence_id + rv$context, length(sentences))
    text_shown <- sentences[start_id:end_id]
    tags$div(id = "actor_text",
             h3("Artikel ", draw_actor()[["document_id"]], ": ", str_match(draw_actor()[["article_title"]], "([^;\\n]*)[\\s\\S]*")[,2]),
             h4("Medientitel: ", draw_actor()[["article_source"]]),
             h4("Veröffentlichungsdatum: ", draw_actor()[["article_pubdate"]]),
             h4("Ressort: ", draw_actor()[["article_section"]]),
             h4("Byline: ", draw_actor()[["article_byline"]]),
             br(),
             HTML(c("<p>", str_replace_all(paste0(text_shown, collapse = "</p><p>"), entity_name_surname, mark_actor_names), "</p>")))
  })
  
## Wenn der Kontext-Button gedrückt wird, wird der Wert des zugehörigen reactive Value erhöht.
  
  observeEvent(input$more_context,
               rv$context <- rv$context + 1)
  
## Über den "Kompletter Text"-Button werden alle Sätze angezeigt, indem der Wert
## des zugehörigen reactive Value auf die Zahl der Sätze im Artikel gesetzt wird.
  
  observeEvent(input$full_context,
               rv$context <- length(draw_actor()[["sentences"]][[1]]))
  
## In einer Reactive-Expression werden die Werte der Eingabeelemente abgespeichert.
  
  codebogen <- reactive({
    rv$index_actor
    coded_data <- sapply(variables, function(x) ifelse(x %in% c("nameinst", "misclassification", "duplicate", "journalist", "passive_actor"), input[[x]], as.numeric(input[[x]])))
    coded_data
  })
  
## Die Akteure, die bereits im aktuellen Artikel codiert wurden, werden unterhalb des Textes angezeigt.
  
  output$actors_table <- renderTable({
    draw_actor()
    validate(need(all(c("entity_id", "entity", "nameinst", "gender", "aktbez") %in% names(full_dataset)), message = FALSE))
    actors_table <- full_dataset[(full_dataset$document_id == draw_actor()[["document_id"]]) & full_dataset$coded, c("entity_id", "entity", "nameinst", "gender", "aktbez")]
    actors_table
  })
  
## Wenn der Submit-Button gedrückt wird, wird zuerst geprüft, ob alle notwendigen Eingabeelemente ausgefüllt wurden.
## Wenn das der Fall ist, wird die save_data-Funktion ausgeführt. Wenn alle Akteure im Artikel codiert wurden, wird eine Fehlermeldung angezeigt.
## Wenn es noch weitere Akteure gibt, wird der Index des aktuellen Akteurs um 1 erhöht und die Kontext-Variable zurückgesetzt.
  
  observeEvent(input$submit_actor, {
    if(("" %in% c(input$nameinst, input$aktbez, input$aktort, input$gender) & !(input$misclassification | input$duplicate | input$journalist | input$passive_actor)) |
       (input$discipline == "" & input$aktbez %in% c(100, 300))){
      show_alert(title = "Fehler", text = "Bitte zuerst alle Felder ausfüllen, bevor der Akteur gespeichert wird.", type = "error")
    }
    else{
      if(!full_dataset[full_dataset$entity_id == ids[rv$index_actor], "coded"]){
        rv$actors_coded <- rv$actors_coded + 1
      }
      withProgress(message = "Daten werden gespeichert", value = 0.5, 
                   {save_data(draw_actor(), codebogen())
                     incProgress(amount = 0.5)})
      if(length(ids) == rv$index_actor){
        show_alert(title = "Keine weiteren Akteure", text = "Alle Akteure in diesem Datensatz wurden codiert. Wenn weiter codiert werden soll, bitte über \"Abbrechen\" zurück zur Datensatzauswahl gehen.")
      }
      else{
        rv$index_actor <- rv$index_actor + 1
        rv$context <- 0
      }
    }
  })
  
## Beim Zurückgehen zum letzten Akteur wird der Index des aktuellen Akteurs um eins verringert. Das hat dann zur Folge, dass der Text und die Eingabeelemente aktualisiert werden.
## Wenn man bereits beim ersten Akteur ist, wird eine Fehlermeldung angezeigt.
  
  observeEvent(input$last_actor, {
    if(rv$index_actor > 1){
      rv$index_actor <- rv$index_actor - 1
    }
    else{
      show_alert(title = "Fehler", text = "Kann nicht weiter zurückgehen.", type = "error")
    }
  })
}

shinyApp(ui = ui, server = server)
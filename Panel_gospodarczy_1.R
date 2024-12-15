if (!require("shiny")) install.packages("shiny", dependencies = TRUE)
if (!require("leaflet")) install.packages("leaflet", dependencies = TRUE)
if (!require("dplyr")) install.packages("dplyr", dependencies = TRUE)
if (!require("tidyr")) install.packages("tidyr", dependencies = TRUE)
if (!require("sf")) install.packages("sf", dependencies = TRUE)
if (!require("DT")) install.packages("DT", dependencies = TRUE)
if (!require("plotly")) install.packages("plotly", dependencies = TRUE)
if (!require("eurostat")) install.packages("eurostat", dependencies = TRUE)

library(shiny)
library(leaflet)
library(dplyr)
library(tidyr)
library(sf)
library(DT)
library(plotly)
library(shiny)
library(leaflet)
library(eurostat)


# Funkcja do pobrania danych 
get_economic_data <- function(indicator) {
  data <- eurostat::get_eurostat(indicator, time_format = "num") %>%
    select(geo, TIME_PERIOD, values) %>%
    rename(country = geo, year = TIME_PERIOD, value = values) %>%
    filter(year == 2022) %>%   # Filtrujemy tylko dane z roku 2022
    group_by(country) %>%      # Grupa po kraju
    slice(1) %>%               # Wybieramy tylko pierwszy rekord w każdej grupie
    ungroup()                  # Rozgrupowujemy dane
  
  return(data)
}

# Pobranie danych 
gdp_pps <- get_economic_data("tec00114") #PKB PPS
unemp <- get_economic_data("tps00203") #bezrobocie
expend<-get_economic_data("tec00023")  #Wydatki rządowe (% PKB)
gini<-get_economic_data("tessi190")  #wskaznik giniego
poverty<-get_economic_data("tespm010") #zagrozeni ubóstwem
export <- get_economic_data("tet00003") #eksport % w PKB
import <- get_economic_data("tet00004") #import % w PKB 
gini<-get_economic_data("tessi190")  #współczynnik giniego dla dochodu rozporządzalnego ekwiwalentnego 
house<-get_economic_data("tipsho60")  #standaryzowany wskaźnik ceny domu do dochdu
avg_wage<-get_economic_data("nama_10_fte") #średnie pensja skorygowana na pełen etat na pracownika, Nie ma Holandii

## dane, z którymi jest problem 
####consumption <-get_economic_data("tec00134") #kwydatki konsumpcyjne gospodarstw domowych --> posiada filtry
####min_wage<-get_economic_data("tps00155") #płaca minimalna, dane połroczne --> nie posiada do tego filtra
####tax<-get_economic_data("gov_10a_taxag") #agregaty podatkowe --> posiada filtry
####health<-get_economic_data("tps00207")  #całkowite wydatki na opiekę zdrowotną --> posiada filtry
####work_efficiency<-get_economic_data("nama_10_lp_ulc")  #wydajność pracy --> posiada filtry

# Lista dostępnych wskaźników
indicators <- c("PKB per capita PPS (średnia UE=100)" = "tec00114",
                "Bezrobocie" = "tps00203",
                "Wydatki rządowe (% PKB)" = "tec00023",
                "Nierówności dochodowe"="tessi190",
                "Odsetek zagrożonych ubóśtwem"="tespm010",
                "Eksport % PKB"="tet00003",
                "Import % PKB"="tet00004",
                "Gini"="tessi190", 
                "Wskaźnik cen mieszkań do dochodów (2015=100)"="tipsho60", 
                "Średnia roczna płaca w euro (pełny etat)"="nama_10_fte")

# Definiowanie współrzędnych geograficznych
coordinates <- data.frame(
  country = c("Austria", "Belgia", "Bułgaria", "Chorwacja", "Cypr", "Czechy", "Dania", "Estonia", 
              "Finlandia", "Francja", "Niemcy", "Grecja", "Węgry", "Irlandia", "Włochy", "Litwa", 
              "Luksemburg", "Łotwa", "Malta", "Holandia", "Polska", "Portugalia", "Rumunia", 
              "Słowacja", "Słowenia", "Hiszpania", "Szwecja"),
  iso2 = c("AT", "BE", "BG", "HR", "CY", "CZ", "DK", "EE", "FI", "FR", "DE", 
           "EL", "HU", "IE", "IT", "LT", "LU", "LV", "MT", "NL", "PL", 
           "PT", "RO", "SK", "SI", "ES", "SE"),
  longitude = c(16.37, 4.87, 26.02, 15.20, 33.42, 14.42, 12.55, 25.10, 25.47, 2.35, 
                10.45, 22.00, 19.00, -6.26, 12.57, 24.12, 6.13, 24.11, 14.54, 4.90, 
                19.00, -8.24, 26.10, 17.16, 14.50, -3.70, 18.07),
  latitude = c(48.21, 50.85, 42.73, 45.10, 35.14, 50.08, 55.67, 59.38, 60.17, 48.85, 
               51.16, 39.00, 47.00, 53.34, 41.90, 55.34, 49.61, 56.88, 35.89, 52.37, 
               52.10, 39.45, 44.43, 48.72, 46.05, 40.41, 59.33)
)

# Funkcja do połączenia danych i współrzędnych geograficznych
merge_data_with_coordinates <- function(data, coordinates) {
  merged_data <- left_join(coordinates, data, by = c("iso2" = "country"))
  return(merged_data)
}

# Połączenie danych PKB z współrzędnymi

# Pobierz wszystkie wskaźniki w pętli
indicators <- list(
  "PKB per capita PPS (średnia UE=100)" = "tec00114",
  "Bezrobocie (%)" = "tps00203",
  "Wydatki rządowe (% PKB)" = "tec00023",
  "Nierówności dochodowe" = "tessi190",
  "Odsetek zagrożonych ubóśtwem"="tespm010",
  "Eksport % PKB"="tet00003",
  "Import % PKB"="tet00004",
  "Gini"="tessi190", 
  "Wskaźnik cen mieszkań do dochodów (2015=100)"="tipsho60", 
  "Średnia roczna płaca w euro (pełny etat)"="nama_10_fte")

# Funkcja pobierająca wszystkie wskaźniki jednocześnie
get_all_data <- function(indicators) {
  data_list <- lapply(indicators, get_economic_data)
  names(data_list) <- names(indicators)
  return(data_list)
}

# Pobierz dane dla wszystkich wskaźników
all_data <- get_all_data(indicators)
merge_all_data_with_coordinates <- function(data_list, coordinates) {
  merged_list <- lapply(data_list, function(data) {
    merge_data_with_coordinates(data, coordinates)
  })
  return(merged_list)
}

merged_all_data <- merge_all_data_with_coordinates(all_data, coordinates)



# Tworzenie obiektów sf (sf = Simple Features)


# UI aplikacji
# UI aplikacji
ui <- fluidPage(
  titlePanel("Dashboard Bogactwa Narodów UE"),
  sidebarLayout(
    sidebarPanel(
      selectInput("indicator", "Wybierz wskaźnik:", 
                  choices = c("PKB per capita PPS (średnia UE=100)", 
                              "Bezrobocie (%)", 
                              "Wydatki rządowe (% PKB)", 
                              "Nierówności dochodowe", 
                              "Odsetek zagrożonych ubóśtwem",
                              "Eksport % PKB",
                              "Import % PKB",
                              "Gini", 
                              "Wskaźnik cen mieszkań do dochodów (2015=100)", 
                              "Średnia roczna płaca w euro (pełny etat)")),  # Wybór wskaźnika
      sliderInput("weight", "Waga wskaźnika kompozytowego:", 0, 1, 0.5)
    ),
    mainPanel(
      tabsetPanel(
        id = "mainTabs",
        tabPanel("Mapa", 
                 leafletOutput("map"), 
                 textOutput("selectedCountry")),
        tabPanel("Szczegóły", 
                 plotlyOutput("rankingPlot"),
                 DTOutput("rankingTable"),
                 verbatimTextOutput("selectedCountryDetails")) # Nowa sekcja do szczegółów kraju
      )
    )
  )
)


# Server aplikacji
# Server aplikacji
server <- function(input, output, session) {
  
  # Funkcja do renderowania mapy na podstawie wybranego wskaźnika
  output$map <- renderLeaflet({
    # Pobierz dane dla wybranego wskaźnika
    data <- merged_all_data[[input$indicator]]
    
    # Tworzenie mapy
    color_pal <- colorNumeric(palette = "YlOrRd", domain = data$value)
    leaflet() %>%
      addTiles() %>%
      addCircleMarkers(
        data = data,
        radius = 10,
        label = ~paste(country, ": ", input$indicator, ": ", round(value, 2)),
        layerId = ~iso2,
        color = ~color_pal(value),
        fillColor = ~color_pal(value),
        fillOpacity = 0.7
      )
  })
  
  
  
  # Obsługa kliknięcia na mapie: Przeniesienie do zakładki z danymi
  observeEvent(input$map_shape_click, {
    country_iso2 <- input$map_shape_click$id
    selected_data <- merged_all_data[[input$indicator]] %>%
      filter(iso2 == country_iso2)
    
    # Aktualizacja szczegółów
    output$selectedCountryDetails <- renderText({
      paste("Kraj:", selected_data$country, 
            "\n", input$indicator, ":", round(selected_data$value, 2))
    })
  })
  
  
  
  # Reactive data - Obliczenie danych w zależności od wybranych wskaźników
  reactive_data <- reactive({
    data <- merged_all_data[[input$indicator]] # Pobierz dane na podstawie wskaźnika
    data %>%
      arrange(desc(value)) %>%
      mutate(rank = row_number())
  })
  
  
  # Renderowanie wykresu z rankingiem
  output$rankingPlot <- renderPlotly({
    data <- reactive_data()
    plot_ly(data, x = ~reorder(country, -value), 
            y = ~value, type = "bar", 
            text = ~paste(country, ":", value), hoverinfo = "text") %>%
      layout(title = paste("Ranking krajów -", input$indicator), 
             xaxis = list(title = ""), yaxis = list(title = input$indicator))
  })
  
  
  # Renderowanie tabeli z rankingiem
  output$rankingTable <- renderDT({
    reactive_data() %>%
      select(country, rank, value) %>%
      datatable(options = list(pageLength = 5))
  })
}




# Uruchomienie aplikacji
shinyApp(ui, server)

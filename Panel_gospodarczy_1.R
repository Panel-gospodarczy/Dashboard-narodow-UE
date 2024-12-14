if (!require("shiny")) install.packages("shiny", dependencies = TRUE)
if (!require("leaflet")) install.packages("leaflet", dependencies = TRUE)
if (!require("dplyr")) install.packages("dplyr", dependencies = TRUE)
if (!require("tidyr")) install.packages("tidyr", dependencies = TRUE)
if (!require("sf")) install.packages("sf", dependencies = TRUE)
if (!require("DT")) install.packages("DT", dependencies = TRUE)
if (!require("plotly")) install.packages("plotly", dependencies = TRUE)
library(shiny)
library(leaflet)
library(dplyr)
library(tidyr)
library(sf)
library(DT)
library(plotly)
library(shiny)
library(leaflet)


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

# Pobranie danych PKB per capita PPS i bezrobocia
gdp_pps <- get_economic_data("tec00114") #PKB PPS
unemp <- get_economic_data("tps00203") #bezrobocie
expend<-get_economic_data("tec00023")  #Wydatki rządowe (% PKB)

# Lista dostępnych wskaźników
indicators <- c("PKB per capita PPS (średnia UE=100)" = "tec00114", "Bezrobocie" = "tps00203","Wydatki rządowe (% PKB)" = "tec00023")

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
merged_data_gdp <- merge_data_with_coordinates(gdp_pps, coordinates)
merged_data_unemp <- merge_data_with_coordinates(unemp, coordinates)
merged_data_expend<-merge_data_with_coordinates(expend, coordinates)

# Tworzenie obiektów sf (sf = Simple Features)
countries_sf_gdp <- st_as_sf(merged_data_gdp, coords = c("longitude", "latitude"), crs = 4326)
countries_sf_unemp <- st_as_sf(merged_data_unemp, coords = c("longitude", "latitude"), crs = 4326)

# UI aplikacji
# UI aplikacji
ui <- fluidPage(
  titlePanel("Dashboard Bogactwa Narodów UE"),
  sidebarLayout(
    sidebarPanel(
      selectInput("indicator", "Wybierz wskaźnik:", 
                  choices = c("PKB per capita PPS (średnia UE=100)", "Bezrobocie (%)", "Wydatki rządowe (% PKB)")),  # Wybór wskaźnika
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
    # Wybór danych na podstawie wskaźnika
    data <- reactive({
      if(input$indicator == "PKB per capita PPS (średnia UE=100)") {
        data <- merged_data_gdp
      } else if(input$indicator == "Bezrobocie (%)") {
        data <- merged_data_unemp
      } else {
        data <- merged_data_expend
      }
      data
    })()
    
    # Wybór koloru w zależności od wartości wskaźnika
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
    
    # Wybieranie danych na podstawie wybranego wskaźnika
    selected_data <- if(input$indicator == "PKB per capita PPS (średnia UE=100)") {
      merged_data_gdp %>% filter(iso2 == country_iso2)
    } else if(input$indicator == "Bezrobocie (%)") {
      merged_data_unemp %>% filter(iso2 == country_iso2)
    } else {
      merged_data_expend %>% filter(iso2 == country_iso2)
    }
    
    # Jeśli dane istnieją, wyświetlamy szczegóły
    output$selectedCountryDetails <- renderText({
      paste("Kraj:", selected_data$country, 
            "\n", input$indicator, ":", round(selected_data$value, 2))
    })
    
    # Dynamiczne przełączanie na zakładkę szczegółów
    updateTabsetPanel(session, "mainTabs", selected = "Szczegóły")
    
    # Aktualizowanie tekstu z informacjami o wybranym kraju w zakładce "Mapa"
    output$selectedCountry <- renderText({
      paste("Kliknięto na kraj:", selected_data$country)
    })
  })
  
  
  # Reactive data - Obliczenie danych w zależności od wybranych wskaźników
  reactive_data <- reactive({
    if(input$indicator == "PKB per capita PPS (średnia UE=100)") {
      data <- merged_data_gdp
    } else if(input$indicator == "Bezrobocie (%)") {
      data <- merged_data_unemp
    } else {
      data <- merged_data_expend
    }
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

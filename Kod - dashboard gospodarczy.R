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
library(eurostat)


# Funkcja do pobrania danych 
# Funkcja do pobrania danych z wieloma filtrami
get_economic_data <- function(indicator, filters = list()) {
  data <- eurostat::get_eurostat(indicator, time_format = "num") %>%
    select(geo, TIME_PERIOD, values, everything()) %>%
    rename(country = geo, year = TIME_PERIOD, value = values)
  
  # Zastosowanie filtrów (jeśli podano)
  if (length(filters) > 0) {
    for (filter_name in names(filters)) {
      data <- data %>% filter(!!sym(filter_name) == filters[[filter_name]])
    }
  }
  
  data <- data %>%
    filter(year == 2022) %>%   # Filtrujemy tylko dane z roku 2022
    group_by(country) %>%      # Grupa po kraju
    slice(1) %>%               # Wybieramy tylko pierwszy rekord w każdej grupie
    ungroup()                  # Rozgrupowujemy dane
  
  return(data)
}



place_filters <- list(
  na_item = "D11",  # Wskaźnik udziału płac (P41)
  unit = "PC_GDP"   # Jednostka: PC_GDP
)
AIC_filters <- list(
  na_item = "VI_PPS_EU27_2020_HAB",  # Wskaźnik AIC (P41)
  ppp_cat = "A01"   # Jednostka: PC_GDP
)


czas_filters<-list(
  na_item = "HW_HAB",
  unit="HW")


# Lista dostępnych wskaźników
indicators <- c("PKB per capita PPS (średnia UE=100)" = "tec00114",
                "Bezrobocie" = "tps00203",
                "Udział płac w PKB",
                "Wydatki rządowe (% PKB)" = "tec00023",
                "Nierówności dochodowe"="tessi190",
                "Odsetek zagrożonych ubóśtwem"="tespm010",
                "Eksport % PKB"="tet00003",
                "Wskaźnik cen mieszkań do dochodów (2015=100)"="tipsho60", 
                
                "Mediana wynagrodzeń w euro"="earn_ses_pub2t",
                "Średnia liczba godzin przepracowanych w roku per capita" = "nama_10_lp_ulc",
                "Odsetek osób posiadająca więcej niż 1 pracę"="tqoe3a5",
                "Stosunek dochodu najbogatszych do najuboższych"="ilc_pns4",
                "Realne spożycie na osobę (średnia UE=100)"
               
                
)

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
  "Udział płac w PKB" = "nama_10_gdp",
  "Wydatki rządowe (% PKB)" = "tec00023",
  "Nierówności dochodowe" = "tessi190",
  "Odsetek zagrożonych ubóśtwem"="tespm010",
  "Eksport % PKB"="tet00003",
  "Wskaźnik cen mieszkań do dochodów (2015=100)"="tipsho60", 
  
  "Mediana wynagrodzeń w euro"="earn_ses_pub2t",
  "Średnia liczba godzin przepracowanych w roku per capita" = "nama_10_lp_ulc",
  "Odsetek osób posiadająca więcej niż 1 pracę"="tqoe3a5",
  "Stosunek dochodu najbogatszych do najuboższych"="ilc_pns4",
  "Realne spożycie na osobę (średnia UE=100)"="prc_ppp_ind")

# Funkcja pobierająca wszystkie wskaźniki jednocześnie
get_all_data <- function(indicators) {
  data_list <- lapply(names(indicators), function(indicator_name) {
    indicator_code <- indicators[[indicator_name]]
    
    # Dla wskaźników "Udział płac w PKB" i "prc_ppp_ind" dodajemy odpowiednie filtry
    filters <- if (indicator_code == "nama_10_gdp") {
      place_filters
    } else if (indicator_code == "prc_ppp_ind") {
      AIC_filters  # Zdefiniuj odpowiednie filtry dla prc_ppp_ind
    }
    else if (indicator_code=="nama_10_lp_ulc") {
      czas_filters
    }
    
    
    
    else {
      list()  # Brak filtrów dla innych wskaźników
    }
    
    
    # Pobieranie danych
    data <- get_economic_data(indicator_code, filters = filters)
    return(data)
  })
  
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



# Normalizujemy `value` dla każdej listy
#normalized_data <- lapply(merged_all_data, function(df) {
#  df$value <- normalize(df$value)
#  df
#})
# Lista nazw wskaźników
stimulators <- c("PKB per capita PPS (średnia UE=100)",
                 "Wskaźnik cen mieszkań do dochodów (2015=100)", "Eksport % PKB",
                 "Mediana wynagrodzeń w euro", "Realne spożycie na osobę (średnia UE=100)")

detractors <- c("Bezrobocie (%)", "Udział płac w PKB", "Wydatki rządowe (% PKB)", "Nierówności dochodowe", 
                "Odsetek zagrożonych ubóśtwem", "Średnia liczba godzin przepracowanych w roku per capita", 
                "Odsetek osób posiadająca więcej niż 1 pracę", "Stosunek dochodu najbogatszych do najuboższych")




# UI aplikacji
# UI aplikacji
ui <- fluidPage(
  titlePanel("Dashboard Bogactwa Narodów UE"),
  sidebarLayout(
    sidebarPanel(
      # Wyświetlanie selectInput tylko w zakładkach "Mapa" i "Szczegóły"
      uiOutput("indicatorUI"),
      
      # Wyświetlanie suwaków dla wag tylko w zakładce "Ranking kompozytowy"
      uiOutput("sliderUI")
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
                 verbatimTextOutput("selectedCountryDetails")),
        tabPanel("Ranking kompozytowy", 
                 leafletOutput("compositeMap", height = "500px"), 
                 DTOutput("compositeRankingTable"))
      )
    )
  )
)


# Server aplikacji
# Server aplikacji
server <- function(input, output, session) {
  
  
  output$indicatorUI <- renderUI({
    if (input$mainTabs %in% c("Mapa", "Szczegóły")) {
      selectInput("indicator", "Wybierz wskaźnik:", 
                  choices = c("PKB per capita PPS (średnia UE=100)", 
                              "Bezrobocie (%)", 
                              "Udział płac w PKB",
                              "Wydatki rządowe (% PKB)", 
                              "Nierówności dochodowe", 
                              "Odsetek zagrożonych ubóśtwem",
                              "Eksport % PKB",
                              "Wskaźnik cen mieszkań do dochodów (2015=100)", 
                              
                              "Mediana wynagrodzeń w euro",
                              "Średnia liczba godzin przepracowanych w roku per capita",
                              "Odsetek osób posiadająca więcej niż 1 pracę",
                              "Stosunek dochodu najbogatszych do najuboższych",
                              "Realne spożycie na osobę (średnia UE=100)"))
    }
  })
  
  # Warunkowe renderowanie suwaków w zależności od zakładki
  output$sliderUI <- renderUI({
    if (input$mainTabs == "Ranking kompozytowy") {
      tagList(
        sliderInput("weight_pkb", "Waga PKB per capita PPS (średnia UE=100):", 
                    min = 0, max = 1, value = 0.05),
        sliderInput("weight_bezrobocie", "Waga Bezrobocie (%):", 
                    min = 0, max = 1, value = 0.1),
        sliderInput("weight_placa", "Waga Udział płac w PKB:", 
                    min = 0, max = 1, value = 0.05),
        sliderInput("weight_wydatki", "Waga Wydatki rządowe (% PKB):", 
                    min = 0, max = 1, value = 0.05),
        sliderInput("weight_nierow", "Waga Nierówności dochodowe:", 
                    min = 0, max = 1, value = 0.1),
        sliderInput("weight_ubostwo", "Waga Odsetek zagrożonych ubóśtwem:", 
                    min = 0, max = 1, value = 0.1),
        sliderInput("weight_eksport", "Waga Eksport % PKB:", 
                    min = 0, max = 1, value = 0.05),
        sliderInput("weight_mieszkania", "Waga Wskaźnik cen mieszkań do dochodów (2015=100):", 
                    min = 0, max = 1, value = 0.1),
        sliderInput("weight_wynagrodzenia", "Waga Mediana wynagrodzeń w euro:", 
                    min = 0, max = 1, value = 0.1),
        sliderInput("weight_godziny", "Waga Liczba godzin pracy:", 
                    min = 0, max = 1, value = 0.1),
        sliderInput("weight_prace", "Waga Osoby z więcej niż jedną pracą:", 
                    min = 0, max = 1, value = 0.05),
        sliderInput("weight_stosunek", "Waga Stosunek dochodów najbogatszych do najuboższych:", 
                    min = 0, max = 1, value = 0.05),
        sliderInput("weight_spozycie", "Waga Realne spożycie na osobę (średnia UE=100):", 
                    min = 0, max = 1, value = 0.1)
      )
    }
  })
  
  
  reactive_data <- reactive({
    data <- merged_all_data[[input$indicator]] # Pobierz dane na podstawie wskaźnika
    data %>%
      arrange(desc(value)) %>%
      mutate(rank = row_number())
  })
  indicators_type <- c(
    1, # PKB per capita PPS
    0, # Bezrobocie
    1, # Udział płac w PKB
    1, # Wydatki rządowe
    0, # Nierówności dochodowe
    0, # Zagrożenie ubóstwem
    1,
    0, # Wskaźnik cen mieszkań
    
    1, # Mediana wynagrodzeń
    0, # Liczba godzin pracy
    0, # Osoby z więcej niż jedną pracą
    0, # Stosunek dochodów najbogatszych do najuboższych
    1 # Realne spożycie na osobę

  )
  
  # Normalizacja
  normalize <- function(x, type) {
    if (type == 1) {
      # Stymulant: normalizujemy normalnie
      return((x - min(x, na.rm = TRUE)) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE)))
    } else {
      # Destymulant: normalizujemy odwrotnie
      return((max(x, na.rm = TRUE) - x) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE)))
    }
  }
  total_weight <- reactive({
    sum_weights <- sum(c(input$weight_pkb, input$weight_bezrobocie, input$weight_placa,
                         input$weight_wydatki, input$weight_nierow, input$weight_ubostwo,
                         input$weight_eksport, input$weight_mieszkania, input$weight_wynagrodzenia,
                         input$weight_godziny, input$weight_prace, input$weight_stosunek,
                         input$weight_spozycie))
    return(sum_weights)
  })
  
  observe({
    total_w <- total_weight()
    # Jeżeli suma wag przekroczy 1, resetujemy wszystkie suwaki
    if (total_w != 1) {
      scale_factor <- 1 / total_w
      updateSliderInput(session, "weight_pkb", value = input$weight_pkb * scale_factor)
      updateSliderInput(session, "weight_bezrobocie", value = input$weight_bezrobocie * scale_factor)
      updateSliderInput(session, "weight_placa", value = input$weight_placa * scale_factor)
      updateSliderInput(session, "weight_wydatki", value = input$weight_wydatki * scale_factor)
      updateSliderInput(session, "weight_nierow", value = input$weight_nierow * scale_factor)
      updateSliderInput(session, "weight_ubostwo", value = input$weight_ubostwo * scale_factor)
      updateSliderInput(session, "weight_eksport", value = input$weight_eksport * scale_factor)
      updateSliderInput(session, "weight_mieszkania", value = input$weight_mieszkania * scale_factor)
      updateSliderInput(session, "weight_wynagrodzenia", value = input$weight_wynagrodzenia * scale_factor)
      updateSliderInput(session, "weight_godziny", value = input$weight_godziny * scale_factor)
      updateSliderInput(session, "weight_prace", value = input$weight_prace * scale_factor)
      updateSliderInput(session, "weight_stosunek", value = input$weight_stosunek * scale_factor)
      updateSliderInput(session, "weight_spozycie", value = input$weight_spozycie * scale_factor)
    
    }
  })
  
  # Funkcja do obliczania wskaźnika kompozytowego
  composite_data <- reactive({
    weights <- c(input$weight_pkb, input$weight_bezrobocie, input$weight_placa, input$weight_wydatki,
                 input$weight_nierow, input$weight_ubostwo, input$weight_eksport, input$weight_mieszkania,
                 input$weight_wynagrodzenia, input$weight_godziny, input$weight_prace, input$weight_stosunek,
                 input$weight_spozycie)
    # Normalizujemy `value` w zależności od typu wskaźnika (stymulant / destymulant)
    normalized_data <- lapply(1:length(merged_all_data), function(i) {
      df <- merged_all_data[[i]]
      df$value <- normalize(df$value, indicators_type[i])  # Zmieniamy normalizację na podstawie typu
      df
    })
    
    # Obliczamy wskaźnik kompozytowy
    composite_index <- lapply(1:length(normalized_data), function(i) {
      normalized_data[[i]]$value * weights[i]
    })
    
    # Łączenie wyników w macierz
    composite_index_matrix <- do.call(cbind, composite_index)
    
    # Finalne sumowanie wskaźników (po wierszach)
    final_composite_index <- rowSums(composite_index_matrix, na.rm = TRUE)
    
    # Zakładamy, że kraje są w pierwszej liście i kolumnie 'country'
    countries <- merged_all_data[[1]]$country
    
    # Tworzymy ramkę danych dla wskaźnika kompozytowego
    composite_df <- data.frame(
      country = countries,
      composite_index = final_composite_index
    )
    
    # Sortowanie po wskaźniku kompozytowym (od najwyższego)
    composite_df <- composite_df %>%
      arrange(desc(composite_index)) %>%
      mutate(rank = row_number())
    composite_df <- composite_df %>%
      left_join(coordinates, by = "country")
    
    
    
    return(composite_df)
  })
  
  # Renderowanie tabeli z rankingiem
  output$compositeRankingTable <- renderDT({
    composite_data() %>%
      select(country, composite_index, rank) %>%
      datatable(options = list(pageLength = 5))
  })
  
  
  #MAPA
  output$compositeMap<-renderLeaflet({
    indicator_info <- indicators[[input$indicator]]
    data <- composite_data()
    
    # Tworzymy paletę kolorów
    color_pal <- colorNumeric(palette = "YlOrRd", domain = data$composite_index)
    
    # Tworzymy mapę
    leaflet() %>%
      addTiles() %>%
      addCircleMarkers(
        data=data,
        radius = 10,
        label = ~paste(country, ": ", round(composite_index, 2)),
        layerId = ~iso2,
        color = ~color_pal(composite_index),
        fillColor = ~color_pal(composite_index),
        fillOpacity = 0.7
      )
  })
  
  
  # Funkcja do renderowania mapy na podstawie wybranego wskaźnika
  output$map <- renderLeaflet({
    # Pobierz dane dla wybranego wskaźnika
    indicator_info <- indicators[[input$indicator]]
    data <- reactive_data()
    
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
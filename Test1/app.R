###Load libraries
library(shinythemes)
library(shiny)
library(htmlwidgets)
library(htmltools)
library(leaflet)
library(sf)

#bring in my geojson file from GCS
cities1 <- st_read("https://storage.googleapis.com/bucket-1-geo-arrow/Cities.geojson")

# Define UI for application
ui <- fluidPage(title="City Explorer", theme = shinytheme("darkly"),
    navbarPage(title = "Welcome to Dan's City Explorer App!",
               icon("map"),
               tabPanel("Cities around the world",
                        selectInput("countryInput", "Select 1 or more countries from the list below and click on the clusters to view each city and it's street view", choices = unique(cities1$country),multiple = TRUE),
                        leafletOutput("map", height = "600px")
                        ),
               tabPanel("Future cool map coming",
                        h1("Nothing to see here yet!")),
               )
)


# Define server logic required to draw a histogram
server <- function(input, output) {
  output$textOutput <- renderText({
    paste(input$txt1,
          input$txt2, sep = "\n")
  })

  output$map <- renderLeaflet({
    filtered_cities <- subset(cities1, country == input$countryInput)

    leaflet(options = leafletOptions(zoomControl = FALSE)) |>
      addProviderTiles(provider = "Esri.WorldImagery", group = "Satellite Imagery") |>
      addProviderTiles(provider = "Esri.WorldStreetMap", group = "Street View") |>
      setView(lng = 0, lat = 0, zoom = 2) |>
      addMarkers(data = filtered_cities, group = "Cities", clusterOptions = markerClusterOptions(),
                 popup = ~paste("<b>City:</b>", city, "<br>", "<b>Population:</b>", population,
                                "<br>", "<a href='https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=", lat, ",", lng, "' target='_blank'>Street View</a>")) |>
      addLayersControl(
        baseGroups = c("Satellite Imagery", "Street View"),
        options = layersControlOptions(collapsed = TRUE)
      )
  })
}


# Run the application
shinyApp(ui = ui, server = server)

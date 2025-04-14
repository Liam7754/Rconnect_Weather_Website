library(shiny)
library(shinydashboard)
library(leaflet)

custom_date <- function() {
  today <- Sys.Date()
  return(format(today, format = "%d-%m-%Y"))
}

custom_date()


shinyUI(
  dashboardPage(skin = "blue",
    dashboardHeader(title="My Dashboard"),
    
    dashboardSidebar(
      sidebarSearchForm(textId = "searchText", buttonId = "searchButton",label = "Enter city name"),
      sidebarMenu(
      menuItem("Weather", tabName = "Weather", icon = icon("sun icon")),
      menuItem("Forecast", tabName = "Forecast", icon = icon("circle-info"))
      )
    ),
    dashboardBody(
      tabItems(
        tabItem(tabName = "Weather",
          sidebarLayout(position="left",
            mainPanel(width = 6,
              h1("Current weather", style = "font-size:70px;"),
              h1(icon("location-crosshairs"),strong(textOutput("city_name",inline = TRUE)),style = "font-size:50px;",style="text-indent: 30px"),
              h4(custom_date(),style="text-indent: 60px"),
              h2(icon("temperature-three-quarters"),"Current temperature:",style="text-indent: 30px"),
              h2(strong(textOutput("temp")),style="text-indent: 60px"),
              h2(strong(textOutput("test")),style="text-indent: 60px"),
              
              fluidRow(
                box(title="Feels Like",status="danger",width=3,solidHeader = T,textOutput("feel_like")),
                box(title="Humidtiy",status="info",width=3,solidHeader = T,textOutput("humidtiy") ),
                box(title="Weather Condition",status="success",width=3,solidHeader = T,textOutput("weather_condition") )
              
                
              ),
              fluidRow(
                box(title="Visibility",status="warning",width=3,solidHeader = T,textOutput("visibility") ),
                box(title="Wind Speed",status="primary",width=3,solidHeader = T,textOutput("wind_speed") ),
                box(title="Air Pressure",status="info",width=3,solidHeader = T,textOutput("air_pressure") )
              )
            
            ),
            sidebarPanel(width = 6,
              leafletOutput("mymap",height="500")
            )
          )
        ),
        tabItem(tabName = "Forecast",
          h1("Weather forecast for the next 5 days"),
          
          selectInput("option","Features",choices=c("temp","feels_like","humidity","visibility","wind_speed","pressure")),
          h1(strong(textOutput("city_name_forcast"))),
          plotOutput("linechart",height = "400px") 
          
        )
      )
    )
  )
)

library(shiny)
library(shinydashboard)
library(httr)
library(jsonlite)
library(leaflet)
library(ggplot2)
click_button=0

#server input and output
shinyServer(function(input,output){
  #output weather value tab weather
  output$city_name<-renderText({info_temp()$name})
  output$temp<-renderText({paste(info_temp()$main$temp,"°C")})
  output$feel_like<-renderText({paste(info_temp()$main$feels_like,"°C")})
  output$humidtiy<-renderText({paste(info_temp()$main$humidity,"%")})
  output$weather_condition<-renderText({info_temp()$weather$description})
  output$visibility<-renderText({paste(info_temp()$visibility,"km")})
  output$wind_speed<-renderText({paste(info_temp()$wind$speed,"km/h")})
  output$air_pressure<-renderText({paste(info_temp()$main$pressure,"hPa")})
  #output value tab forcast
  output$city_name_forcast<-renderText({paste("Location :",info_temp()$name)})
  #output map
  output$mymap <-renderLeaflet({
    leaflet()%>%
      addProviderTiles("CartoDB.Positron") %>%
      setView(lng=105.804817,lat=21.028511,zoom=10)%>%
      addTiles(layerId = "map_click") 
  })
  
  
  #lat and lon show in map
  observeEvent(input$mymap_click,{
    click <- input$mymap_click
    lat <- click$lat
    lon <- click$lng
    
    proxy <- leafletProxy("mymap")
    proxy %>% clearPopups() %>%
      addPopups(lon, lat, paste("Latitude:", lat, "Longitude:", lon))
    
    print(paste("Click coordinates:", lat, lon))
    
  })
  
  
  info_temp<-reactive({
    key<-""
    click<-input$mymap_click
    if (is.null(click)){
      lat <- "21.028511"
      lon <- "105.804817"
      
    }else if(input$searchButton>click_button){
      click_button<<-click_button+1
      city<-input$searchText
      link<-paste("http://api.openweathermap.org/geo/1.0/direct?q=",city,"&limit=1&appid=",key,sep="")
      info <- httr::GET(link)
      content<- httr::content(info,as="text")
      Jsondata<-jsonlite::fromJSON(content)
      lat <- as.character(Jsondata$lat)
      lon <- as.character(Jsondata$lon)
      proxy <- leafletProxy("mymap")%>%
        setView(lng=lon,lat=lat,zoom=10)
      
      
    }else{
      lat <- click$lat
      lon <- click$lng
    }
    
    
    #weather data in that place
    link<-paste("https://api.openweathermap.org/data/2.5/weather?lat=",lat,"&","lon=",lon,"&mode=json&units=metric&appid=",key,sep="")
    info <- httr::GET(link)
    content<- httr::content(info,as="text")
    Jsondata<-jsonlite::fromJSON(content)
    
    #weather data forcast
    link<-paste("api.openweathermap.org/data/2.5/forecast?lat=",lat,"&lon=",lon,"&units=metric&appid=",key,sep="")
    info <- httr::GET(link)
    content<- httr::content(info,as="text")
    Jsondata_forcast<-jsonlite::fromJSON(content)
    my_data<-Jsondata_forcast$list$main
    my_data$day_time<-Jsondata_forcast$list$dt_txt
    my_data$visibility<-Jsondata_forcast$list$visibility
    my_data$wind_speed<-Jsondata_forcast$list$wind$speed
    
    #plot weather forcast
    output$linechart<-renderPlot({
      ggplot(data=my_data,mapping=aes(x=day_time,y=my_data[[input$option]],group=1))+
        geom_line()+
        geom_point()+
        theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
        labs(y = input$option , x = "day_time")
      
    })
    
    return(Jsondata)
    
    
    
  })


    
  
  

})


# ui.R

## packages installation ----------------

# install.packages(c("shiny", "plyr", "ggplot2", "dplyr",
#                    "questionr", "shinythemes", "gapminder",
#                    "tmap", "rnaturalearth", "rnaturalearthdata",
#                    "sf", "rgeos", "DT", "ggrepel", "forcats", "scales"))


## library import -----------------------

library(shiny)
library(plyr)
library(ggplot2)
library(dplyr)
library(questionr)
library(shinythemes)
library(gapminder)
library(tmap)
library(rnaturalearth)
library(rnaturalearthdata)
library(sf)
library(rgeos)
library(DT)

##For piecharts
library(ggrepel) #piechart labels
library(forcats) #fct inorder
library(scales) #percent function

## import functions file
source("global.R")

## ui -----------------------------------

ui <- navbarPage(
  theme = shinytheme("flatly"), #class and simple theme
  title = "Olympic Games Dashboard",
  
  #selection panel
  tabPanel("Data Selection", icon = icon("check-square"),
           fluidRow(
             column(8,
                    selectInput(inputId = "cat",
                                label = "Category",
                                choices = list("All","Sport","Event"),
                                selected = "All"),
                    tags$hr(),
                    selectInput(
                      inputId = "elem",
                      label = "Element",
                      choices = unique(final$cat)[,1])
             ))),
  
  #data visualisation panel
  tabPanel("Sport Statistics", icon = icon("trophy"),
           fluidRow(
             column(12,
                    wellPanel(style = "background-color: #fff; border-color: #E72727",
                              h4(textOutput("result"))))),
           fluidRow(
             column(6,
                    wellPanel(style = "background-color: #fff; border-color: #2B3E50",
                              h5("The 3 best athletes :"),
                              DTOutput('Names')),
                    wellPanel(style = "background-color: #fff; border-color: #2B3E50",
                              h5("Height/Weight rapport"),
                              plotOutput("graph"),
                              radioButtons("Selection",
                                           label = h5("Selection :"),
                                           choices = list("Only gold" = 1, "Only medal" = 2, "All" = 3),
                                           selected = 1)),
                    wellPanel(style = "background-color: #fff; border-color: #2B3E50",
                              h5("Men and Women proportion by years"),
                              plotOutput("bar_graph"),
                              checkboxGroupInput("check", label = h5("Selection :"), 
                                                 choices = list("M" = 1, "F" = 2),
                                                 selected = c(1,2)))),
             column(6,
                    wellPanel(style = "background-color: #fff; border-color: #2B3E50",
                              h5("World Scores map"),
                              tmapOutput("map"),
                              h6("The names of the best countries are displayed on the map."),
                              h6("The", strong("score"), 
                                 " is calculated in relation to medals won by countries : a gold medal is worth 10 times more than a silver medal and a silver medal is worth 10 times more than a bronze medal."),
                              ),
                    wellPanel(style = "background-color: #fff; border-color: #2B3E50",
                              h5("Proportion of home players"),
                              plotOutput("pie", width = "100%")),
                    wellPanel(style = "background-color: #fff; border-color: #2B3E50",
                              h5("Home players medals"),
                              plotOutput("pie2", width = "100%"))
                    )),
           fluidRow(
             column(12,
                    wellPanel(style = "background-color: #fff; border-color: #2B3E50",
                              h5("Countries Score repartition"),
                              plotOutput("histogramme"),
                              checkboxInput("checkbox", label = "Without no medal coutries", value = TRUE),
                              h6("The", strong("dashed line"), "represent the mean and the", strong("red curve"), "is the distribution curve."),
                              h6("If you uncheck the 'Without no medal coutries' box, it shows the total number of countries.")
                              ))
             
             )),
  
  tabPanel("Info", icon = icon("info-circle"),
           fluidRow(
             column(12,
                    wellPanel(style = "background-color: #fff; border-color: #2B3E50",
                              h4("Help :"),
                              h5("In Data Selection, first select a category between All, Sport or Event.",br(),
                                 "Then select an element in the list and go in Sport Statistics.",br(),
                                 "Wait some seconds and the dashboard will appear.",br(),
                                 "You can change your selection as many times as you want."),
                              h4("Credits :"),
                              h5("This dashboard was created by Francois Meunier and Jules Chevenet",br(),
                                 "This is the v1.1 realised in September - October 2020.",br(),
                                 "It was realised for a school project at ESIEE Paris in the Mr D.Courivaud lesson.")
                              )
             )
           )
  )#end tab
)#end ui





















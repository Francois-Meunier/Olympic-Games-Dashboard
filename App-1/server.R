# server.R

library(shiny)

## server function ----------------------

function(input, output, session) {
  observe({
    cat <- input$cat
    updateSelectInput(session, "elem", choices = unique(final[input$cat])[,1]) #update of the 2nd selection
  })
  
  #To know wich sport is selected
  output$result <- renderText({paste("Data selected : (", input$cat,") ", input$elem , "(", unique(df_subset(input$cat,input$elem)$Season), ")")})

  #intercative maps with scores
  output$map <- renderTmap({ #rendorPlot pour la carte non interactive
    map_f(df_rank_medal(df_subset(input$cat,input$elem)),"Score")  #"Sport", "Judo"
  })
  
  #The 2 piecharts
  output$pie <- renderPlot({piechart_home(df_subset(input$cat,input$elem))})
  output$pie2 <- renderPlot({piechart_medal(df_subset(input$cat,input$elem))})
  
  #3 best players
  output$Names <- renderDT({subset(df_best3(df_name_medal(df_subset(input$cat,input$elem))),select = -c(Score))}, 
                           options = list(lengthChange = FALSE, info = FALSE, searching = FALSE, paging = FALSE))
  
  #height/weight graph
  output$graph <- renderPlot({graph_(df_subset(input$cat,input$elem),input$Selection)})
  
  #proportion of male and female by years
  output$bar_graph <- renderPlot({df_repart(df_subset(input$cat,input$elem),input$check)})
  
  #Repartition of the countries score
  output$histogramme <- renderPlot({df_histogramme(df_rank_medal(df_subset(input$cat,input$elem)),input$checkbox)})
}
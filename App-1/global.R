# global.R

## File with data processing and functions used by the dashboard app ##

############### Data Processing -------------------------

bdd_JO = read.csv(file = 'bdd_JO_120_years.csv')# dataset about each athlete
noc = read.csv(file = 'noc_regions.csv')# associate a NOC to a country
ville = read.csv(file = 'ville_noc.csv')# associate each Olympic game city to a NOC

## Merge the 2 dataframes NOC and bdd_JO by NOC
final <- merge(bdd_JO, noc, by.x="NOC", by.y="NOC") # Chaque sportif est associe a un Pays

## creation of the final dataframe
final <- merge(final, ville, by.x="Host_City", by.y="Host_City") # On recupere le NOC de la ville organisatrice (NOC_City)
final <- cbind(final,Home = final[,c("NOC")]==final[,c("NOC_City")]) # ajouter la colone Home (sportif a domicile) qui est un booleen
final <- subset(final, select=-c(Team,notes,Games)) # on enleve les colonne qui ne nous interesse pas
final <- final[,c("ID","Name", "Sex", "Age", "Height", "Weight", "NOC", "region", "Host_City","NOC_City","Year","Season","Sport","Event","Medal","Home")] #on reorganise notre dataframe
colnames(final)[8] <- "Region" #marche
final <- cbind(final,All = rep("All",nrow(final)))

## Changing the name of Bolivia because there is a mistake in the former dataset
final$Region[final$Region %in% "Boliva"] <- "Bolivia" 

## we can now remove the datasets that are not useful
rm(noc)
rm(ville)
rm(bdd_JO) 

############### Data Functions --------------------------

## subset function
df_subset <- function(col, key, bdd=final) {
  subset(bdd, subset = bdd[col] == key)
}

## function that return the score by region (number of medals)
df_rank_medal <- function(bdd){
  bdd_score <- group_by(bdd, Region) %>% summarize(Gold = sum(Medal == "Gold", na.rm=TRUE), 
                                                   Silver = sum(Medal == "Silver", na.rm=TRUE), 
                                                   Bronze = sum(Medal == "Bronze", na.rm=TRUE),
                                                   Score = log(sum(Gold*100+Silver*10+Bronze*1.1),exp(1)))
  bdd_score$Score <- bdd_score$Score/max(bdd_score$Score)
  bdd_score$Score[bdd_score$Score == -Inf] <- 0
  return(bdd_score)
}

## function that return the score by Names (number of medals) and nationality + sex
df_name_medal <- function(bdd){
  bdd_score <- group_by(bdd, Name) %>% summarize(Gold = sum(Medal == "Gold", na.rm=TRUE),
                                                 Silver = sum(Medal == "Silver", na.rm=TRUE),
                                                 Bronze = sum(Medal == "Bronze", na.rm=TRUE),
                                                 Score = log(sum(Gold*100+Silver*10+Bronze*1.1),exp(1)),
                                                 Nationality = unique(Region),
                                                 Sex = unique(Sex))
  bdd_score$Score <- bdd_score$Score/max(bdd_score$Score)
  bdd_score$Score[bdd_score$Score == -Inf] <- 0
  return(bdd_score)
}

## function returning the 3 bests (country or athlete that have the best score)
df_best3 <- function(bdd){
  best <- bdd[order(bdd$Score,decreasing = TRUE),]
  best <- best[1:3,]
  return(best)
}

############### Map -------------------------------------

## importing the dataset of the entire world
library(rnaturalearth)
library(rnaturalearthdata) #oblige de les remettre
world <- ne_countries(scale = "medium", returnclass = "sf")

## Change sovereignt names as they are the same as in our Olympic Games dataframe
world$sovereignt[world$sovereignt %in% "Antigua and Barbuda"] <- "Antigua"
world$sovereignt[world$sovereignt %in% "The Bahamas"] <- "Bahamas"
world$sovereignt[world$sovereignt %in% "Guinea Bissau"] <- "Guinea-Bissau"
world$sovereignt[world$sovereignt %in% "Federated States of Micronesia"] <- "Micronesia"
world$sovereignt[world$sovereignt %in% "Saint Kitts and Nevis"] <- "Saint Kitts"
world$sovereignt[world$sovereignt %in% "Saint Vincent and the Grenadines"] <- "Saint Vincent"
world$sovereignt[world$sovereignt %in% "Republic of Serbia"] <- "Serbia"
world$sovereignt[world$sovereignt %in% "United Republic of Tanzania"] <- "Tanzania"
world$sovereight[world$sovereignt %in% "East Timor"] <- "Timor-Leste"
world$sovereignt[world$sovereignt %in% "Trinidad and Tobago"] <- "Trinidad"
world$sovereignt[world$sovereignt %in% "United Kingdom"] <- "UK"
world$sovereignt[world$sovereignt %in% "United States of America"] <- "USA"




world$admin[world$admin %in% "Antigua and Barbuda"] <- "Antigua"
world$admin[world$admin %in% "The Bahamas"] <- "Bahamas"
#world$admin[world$admin %in% "Cura ao"] <- "Curacao"
world$admin[world$admin %in% "Guinea Bissau"] <- "Guinea-Bissau"
world$admin[world$admin %in% "Federated States of Micronesia"] <-"Micronesia"
world$admin[world$admin %in% "Saint Kitts and Nevis"] <- "Saint Kitts"
world$admin[world$admin %in% "Saint Vincent and the Grenadines"] <- "Saint Vincent"
world$admin[world$admin %in% "Republic of Serbia"] <-"Serbia"
world$admin[world$admin %in% "United Republic of Tanzania"] <-"Tanzania"
world$admin[world$admin %in% "East Timor"] <- "Timor-Leste"
world$admin[world$admin %in% "Trinidad and Tobago"] <- "Trinidad"
world$admin[world$admin %in% "United Kingdom"] <- "UK"
world$admin[world$admin %in% "United States of America"] <- "USA" 
world$admin[world$admin %in% "British Virgin Islands"] <- "Virgin Islands, British"
world$admin[world$admin %in% "United States Virgin Islands"] <- "Virgin Islands, US"
                 
world <-  subset(world, sovereignt != "Antarctica") #without Antarctica which is useless

## map function returning the map of a dataset
map_f <- function(bdd, key){
  #data processing
  world_JO <- merge(world, bdd, by.x="sovereignt", by.y="Region", all = TRUE) #merge 2 df
  best_score <- df_best3(bdd)
  map_best <- subset(world_JO, admin %in% best_score$Region) #subset of the 3 bests
  
  #plot
  #tmap_mode("plot")
  tmap_mode("view") #leaflet = widget html
  
  tm_shape(world_JO) +
    tm_polygons(key, palette = "Reds", title = key) +
    tm_shape(map_best) +
    tm_text("sovereignt", just="center") +
    tm_layout(#title = "Medals and 3 best countries", #utile pour le mode 'plot' et non 'view'
      title.size = 2.0, 
      title.position = c("center", "top"), 
      legend.position = c("left", "bottom"),
      legend.title.size = 0.8,
      bg.color = "#BDD1EE"
    ) 
}

############### Plot Functions --------------------------

##Piechart with the purcentage of home players
piechart_home <- function(bdd){
  #data processing
  home <- group_by(bdd, Name) %>% summarize(Home = sum(Home == TRUE))
  home_df <- data.frame(
    Home = c("Yes", "No"),
    value = c(sum(home$Home == 1, na.rm=TRUE), sum(home$Home == 0, na.rm=TRUE))
  )
  home_df <- home_df %>% arrange(desc(value)) %>% mutate(prop = percent(value / sum(value))) 
  
  #plot
  ggplot(home_df, aes(x = 2, y=value, fill=Home)) +
    geom_bar(stat = "identity", color = "white") +
    coord_polar(theta = "y", start=0) +
    geom_text(aes(y = value/2 + c(0, cumsum(value)[-length(value)]), label = prop), color = "white") +
    scale_fill_manual(values=c("#607EE0", "#DE7762")) +
    theme_void() + #no axes, legend, ...
    xlim(0.5, 2.5) #donut graph
}

##Piechart with the purcentage of home players medals
piechart_medal <- function(bdd){
  #data processing
  bdd_at_home <- subset(bdd, Home == TRUE)
  bdd_at_home$Medal[is.na(bdd_at_home$Medal)] <- 0
  medal_count <- bdd_at_home %>% summarize(Gold = sum(Medal == "Gold", na.rm=TRUE), 
                                           Silver = sum(Medal == "Silver", na.rm=TRUE), 
                                           Bronze = sum(Medal == "Bronze", na.rm=TRUE),
                                           No_medal = sum(Medal == 0),
                                           Total = length(bdd_at_home$Medal)
  )
  final_at_home <- data.frame(
    Medal = c("Gold", "Silver", "Bronze", "No medal"),
    value = c(medal_count$Gold, medal_count$Silver, medal_count$Bronze, medal_count$No_medal),
    color = c("#ffd700", "#c0c0c0", "#cd7f32", "#73C2FF")
  )
  final_at_home <- final_at_home %>% arrange(desc(value)) %>% mutate(prop = percent(value / sum(value)))
  
  #plot
  ggplot(final_at_home, aes(x = 2, y=value, fill=fct_inorder(Medal))) +
    geom_bar(stat = "identity", color = "white") +
    coord_polar(theta = "y", start=0) +
    geom_label_repel(aes(label = prop), size=5, show.legend = F, nudge_x = 0) +
    guides(fill = guide_legend(title = "Medal")) +
    scale_fill_manual(values= final_at_home$color) + 
    theme_void() + #no axes, legend, ...
    xlim(0.5, 2.5) #donut graph
}

##Weight / Height with medals
graph_ <- function(bdd,choice){
  if(choice == 1){
    bdd <- bdd %>% filter(Medal == "Gold")
  }
  if(choice == 2){
    bdd <- bdd %>% filter(Medal == "Gold"|Medal == "Silver"|Medal == "Bronze")
  }
  return(ggplot(data = bdd,mapping = aes(x = Height, y = Weight,colour = Medal))
         + geom_point() +
           stat_smooth()+
           facet_wrap(~ Sex)+
           labs(x="Height (cm)", y="Weight (kg)")
           )}

##proportion of male and female by years
df_repart<-function(bdd,choice){
  if(length(choice)==2){
    year <- group_by(bdd, Year) %>% summarize(Nb = sum(Sex=="M",na.rm=TRUE),Type = "M")
    year <- bind_rows(year,group_by(bdd, Year) %>% summarize(Nb = sum(Sex=="F",na.rm=TRUE),Type = "F"))
  }
  else if(choice == 1){
    
    year <- group_by(bdd, Year) %>% summarize(Nb = sum(Sex=="M",na.rm=TRUE),Type = "M")
  }
  else if (choice == 2){
    year <- group_by(bdd, Year) %>% summarize(Nb = sum(Sex=="F",na.rm=TRUE),Type = "F")
  }
  
  return(ggplot(year, aes(x=Year, y=Nb, fill=Type)) + 
           geom_bar(stat="identity"))
           
}


##
df_histogramme <- function(bdd_score,zero = TRUE){
  if (zero){
    bdd_score$Score[bdd_score$Score == 0] <- NA
    bdd_score <- bdd_score %>% filter(!is.na(Score)) 
  }
  return(ggplot(bdd_score,aes(x = Score))+
           geom_histogram(color="darkblue",fill = "lightblue")+
           geom_density(alpha=.2, fill="#FF6666")+
           geom_vline(aes(xintercept=mean(Score)),
                      color="black", linetype="dashed", size=1)
  )
}



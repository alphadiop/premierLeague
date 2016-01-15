## chart that shows for each team- how there manager has performed
## start with ggvis - but may change
managers[is.na(managers$Left),"Left"] <- as.Date(Sys.Date(), origin= '1970-01-01')

managerGame <-managers %>% 
  mutate(name=paste(FirstName,Lastname)) %>% 
  group_by(ManagerID,ManagerTeam) %>% 
  inner_join(standings,by=c("TEAMNAME"="team")) %>% 
  select(Lastname,FirstName,name,ManagerID,ManagerTeam,Joined,Left,TEAMNAME,gameDate,res,GF,GA,position) %>% 
  filter(gameDate>=as.Date(Joined)&gameDate<=as.Date(Left)) %>% 
  mutate(points=ifelse(res=="Win",3,ifelse(res=="Draw",1,0))) %>% 
  ungroup()



ppgManagerTeamStint <- managerGame %>% 
  group_by(TEAMNAME,ManagerID,ManagerTeam,name) %>% 
  summarize(sumPoints=sum(points),games=n(),ppg=round(sumPoints/games,2)) %>% 
  ungroup()




allManagerStints <- 
  managerGame %>% 
  select(name,ManagerTeam,Joined,Left) %>% 
  unique()



## artificial start date for those hired before PL existed
allManagerStints[allManagerStints$Joined<="1992-08-15","Joined"] <- "1992-08-15"


observe({
  
  if(is.null(input$teamA)) return()
  if(is.null(input$managerGames)) return()
  print(input$teamA)
  
teamRecord <- ppgManagerTeamStint  %>% 
  
  select(TEAMNAME,name,ManagerTeam,games,ppg) %>% 
  inner_join(allManagerStints) %>% 
  filter(TEAMNAME==input$teamA&games>=input$managerGames) 



minY <- min(teamRecord$ppg)-0.1
maxY <- max(teamRecord$ppg)+0.1

#library(ggrepel) # unsuccesful attempt
teamRecord %>% 
  ggvis(x =~ Joined,y=~ppg+0.01,fill = "687a97") %>% 
  layer_rects(x2=~Left,y2=~ppg-0.01) %>% 
  layer_text(text:=~name, stroke:="red") %>% 
  scale_numeric("y",domain=c(minY,maxY)) %>% 
  add_axis("x", title="") %>% 
  add_axis("y", title="Av Points per Game") %>% 
  bind_shiny("managerPPGbyTeam")
})
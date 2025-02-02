# get in we're counting grants 
# for science

# data source: https://reporter.nih.gov/exporter/projects
# data dictionary: https://report.nih.gov/exporter-data-dictionary

# let's load way too many packages
pacman::p_load(dplyr, tidyr, janitor, tidyr, ggplot2, rio, here, geofacet, DT, RColorBrewer, ggiraph, readr, forcats)
pacman::p_load(leaflet, glue, sf, tmap, tmaptools, tidycensus, ggmap, htmltools, htmlwidgets)
pacman::p_load_gh(c("walkerke/tigris", "bhaskarvk/leaflet.extras")) 


# this won't work unless you have the correct working directory 
# if you don't know what the path to your working directory is, 
# navigate to the folder you saved this R script in in Terminal
# and type "realpath". You can copy and paste that path below - 
# this is just sample code and won't work without your path. 

setwd("")

# the path below has to be to the folder with the annual CSV files in it. 

NIH_Data <-list.files(path='/path/to/my/data') %>%
  lapply(read_csv) %>%
  bind_rows()

# that worked but it's picky about the working directory, the wd had to be the /data folder, 
# not its parent folder _shrug_

is.data.frame(NIH_Data)
# returns true

head(NIH_Data)
# looks good


# Make a dataframe showing data from just your state
# for MYSTATE_ABBREVIATION, put in the 2 letter abbreviation for 
# your state (CO, MN, etc.).

# replace MYSTATE_ABBREVIATION with your state's 2 letter abbreviation 
# throughout

MYSTATE_ABBREVIATION_NIH_data <- NIH_Data %>%
  filter(ORG_STATE == "MYSTATE_ABBREVIATION") 

is.data.frame(MYSTATE_ABBREVIATION_NIH_data)
# returns TRUE

# in order to make bar charts showing funding by year, it will 
# be more convenient to have a column showing just the year. 
# let's separate 'AWARD NOTICE DATE' into three columns: 

NIH_data_split_year <- NIH_Data %>%
  separate(AWARD_NOTICE_DATE, c('AWARD_NOTICE_DATE_YEAR', 'AWARD_NOTICE_DATE_MONTH', 'AWARD_NOTICE_DATE_DAY'))

  
#let's do that for the MA data too
MYSTATE_ABBREVIATION_NIH_data_split_year <- MYSTATE_ABBREVIATION_NIH_data %>%
  separate(AWARD_NOTICE_DATE, c('AWARD_NOTICE_DATE_YEAR', 'AWARD_NOTICE_DATE_MONTH', 'AWARD_NOTICE_DATE_DAY'))

# ok that worked

# let's see if we can make a bar chart of the value of grants awarded by year
# first let's filter to get the years we want and then group by those years. 

MYSTATE_ABBREVIATION_NIH_data_split_year<- MYSTATE_ABBREVIATION_NIH_data_split_year %>% 
  filter(AWARD_NOTICE_DATE_YEAR >= 2019) %>%
  filter(AWARD_NOTICE_DATE_YEAR <= 2024) %>%
  group_by(AWARD_NOTICE_DATE_YEAR)

# check to see if that worked
View(MYSTATE_ABBREVIATION_NIH_data_split_year)


# let's plot a graph of funding to your state from NIH over the past 5 years

plot_MYSTATE_ABBREVIATION_NIH_data <- ggplot(MYSTATE_ABBREVIATION_NIH_data_split_year, aes(x= AWARD_NOTICE_DATE_YEAR, y = TOTAL_COST )) +
  geom_col(stat="identity", fill="dodgerblue") +
  scale_y_continuous(labels = scales::dollar_format(scale = .000000001, suffix = "B"))+
  xlab("NIH research funding to MYSTATE institutions") +
  ylab("")

# now let's theme it and display it

plot_MYSTATE_ABBREVIATION_NIH_data + theme_light() 
# this should generate a bar chart showing NIH project funding to your state


# let's look at which organizations get the most funding in your state
MYSTATE_ABBREVIATION_NIH_grants_2023_totals_by_org <- MYSTATE_ABBREVIATION_NIH_data_split_year %>%
  filter(AWARD_NOTICE_DATE_YEAR == 2023) %>%
  group_by(ORG_NAME) %>%
  summarize(TOTAL_COST = sum(TOTAL_COST, na.rm=TRUE)
  )

View(MYSTATE_ABBREVIATION_NIH_grants_2023_totals_by_org)

# the above does produce a table of NIH grantees, and the TOTAL COST
# column appears to be a sum of all the grants. 

# let's sort it descending so we can plot it

MYSTATE_ABBREVIATION_NIH_grants_by_org_2023_desc <- MYSTATE_ABBREVIATION_NIH_grants_2023_totals_by_org %>%
  arrange(desc(TOTAL_COST))

View(MYSTATE_ABBREVIATION_NIH_grants_by_org_2023_desc)

#this should create a table of grant funding to your state's orgs sorted in descending
#order by how much $ each institution got


# If there are too many institutions in your dataframe to make graphing them
# impractical, you can filter to show only institutions who received above
# a certain dollar amount of funding

TOP_MYSTATE_ABBREVIATION_big_grantees_desc <- filter(MYSTATE_ABBREVIATION_NIH_grants_by_org_2023_desc, TOTAL_COST >= 30000000) 

View(TOP_MYSTATE_ABBREVIATION_big_grantees_desc)

# let's plot the top grantees
plot_top_grantees <- ggplot(TOP_MYSTATE_ABBREVIATION_big_grantees_desc,
                            aes(x=reorder(TOP_MYSTATE_ABBREVIATION_big_grantees_desc$ORG_NAME, 
                                          TOP_MYSTATE_ABBREVIATION_big_grantees_desc$TOTAL_COST), 
                                y=TOP_MYSTATE_ABBREVIATION_big_grantees_desc$TOTAL_COST)) +
  geom_bar(stat="identity", fill="dodgerblue") +
  scale_y_continuous(labels = scales::dollar_format(scale = .000001, suffix = "M"))+
  #geom_text(aes(label = signif(TOTAL_COST)), nudge_y = 3) +
  coord_flip() +
  labs(x="", y="Top NIH grantees in [MY STATE NAME] by grant funding, 2023")

plot_top_grantees
# that produces a chart showing institutions in your state receiving NIH funding, 
# in descending order by how much $ each institution got

# let's export the grantees 
write.csv(MYSTATE_ABBREVIATION_nih_big_grantees_desc,"/path/to/data/MYSTATE_ABBREVIATION_BIG_NIH_GRANTS.csv", row.names = FALSE)

# you can also create a datatable that is sortable and searchable. 

MYSTATE_ABBREVIATION_NIH_data_2023 <- MYSTATE_ABBREVIATION_NIH_data_split_year %>%
  filter(AWARD_NOTICE_DATE_YEAR == 2023) %>%
  group_by(ORG_NAME)

datatable(MYSTATE_ABBREVIATION_NIH_data_2023)

# note that the .gitignore file for this repo filters out .csv files that 
# you have created above so that they will not be uploaded to Github. 
# you can always edit the .gitignore file if you want to change how 
# things are handled. 

#do you want to see how your state compares to other states? Try this: 


NIH_BY_STATE <- NIH_data_split_year %>%
  filter(AWARD_NOTICE_DATE_YEAR == 2023) %>%
  filter(ORG_COUNTRY == "UNITED STATES") %>%
  filter(TOTAL_COST > 1000000) %>%
  group_by(ORG_STATE) %>%
  summarize(TOTAL_COST = sum(TOTAL_COST, na.rm=TRUE)) %>%
  arrange(desc(TOTAL_COST))

write.csv(NIH_BY_STATE,"/Users/lisawilliams/code/R_For_Mass_Communications/NIH_Data/NIH_BY_STATE_2023.csv", row.names = FALSE)


plot_NIH_by_state <- ggplot(NIH_BY_STATE,
                            aes(x=reorder(NIH_BY_STATE$ORG_STATE, 
                                          NIH_BY_STATE$TOTAL_COST), 
                                y=NIH_BY_STATE$TOTAL_COST)) +
  geom_bar(stat="identity", fill="dodgerblue") +
  scale_y_continuous(labels = scales::dollar_format(scale = .000001, suffix = "M"))+
  #geom_text(aes(label = signif(TOTAL_COST)), nudge_y = 3) +
  coord_flip() +
  labs(x="", y="")+
  ggtitle("NIH Funding By US State/Territory, 2023",
          subtitle = "Data from NIH RePORTER")

plot_NIH_by_state + theme_light()









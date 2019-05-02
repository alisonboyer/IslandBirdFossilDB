
library(dplyr)

# global taxa list, IDs, traits are in 'GlobalBirdDB_Jetz.csv'

# final data set will include:
# Occurrences table: island x species matchup, with intro and extinction status
# Island table: island physical characteristics: mine plus provide match up with Weigelt dataset
# Species table: trait data from Walter where avail, supplemented with my info for extinct spp.
# provide R script to match up these three tables

# Need to:
#1. list islands in v12
#2. check that each island has complete info for taxa, intro status, extinction status
# - removed many of the non-breeding species
#3. get master list of unique species
#4. remove all water species
#5. get trait info for all species from traits DB and Walter's
#6. get environmental data for each island

occ <- read.csv('IBFDB_occurrences_v12.csv', header=T, na.strings=c("","NA"))
names(occ)
summary(occ)
as.numeric(occ$introduced)
as.numeric(occ$modern_observed)
as.numeric(occ$historically_observed)
as.numeric(occ$fossil_observed)

# fixing typos
occ[occ=="Cayman brac"]<- "Cayman Brac"
occ[occ=="mona"]<- "Mona"
occ[occ=="South.Island"]<- "South Island"
occ[occ=="South Georgia Isl"]<- "South Georgia"
# occ[occ=="Lord.Howe"]<- "Lord Howe"

isl_names <- unique(occ$Island) #list islands in v11_occ
isl_names

# summarize the data by island. Count of species, count of introduced, count of modern, count of fossil
mine <- occ %>% 
  group_by(Island) %>% 
  summarise (Count_Species = n(), Count_Intro = sum(introduced, na.rm=TRUE), Count_Modern = sum(modern_observed, na.rm=TRUE), Count_Fossil = sum(fossil_observed, na.rm=TRUE))

write.csv(mine, 'islands_to_check.csv')

islands <- read.csv('IBFDB_islands_v12.csv', header=T, na.strings=c("","NA"))
summary(islands)

master_islands <- islands$Island

# identify rows in occ where occ$Island is in master_islands
occ$good_island <- 0

for (i in 1:length(occ$Island)) {
  if (occ$Island[i] %in% master_islands) {occ$good_island[i] <- 1}
}

summary(occ$good_island)

# remove all other rows (i.e. where good_island is 0)
occ <- subset(occ, occ$good_island == 1)

summary(occ)

# these islands have 0 known fossil birds as well as 0 introduced species in the list:
remove = c('Alphonse', 'Amsterdam', 'Bellona', 'Bird', 'Boa Vista', 'Cape Verde Islands', 'Choiseul', 'Fogo', 'Gough', 'Kerguelen', 'Kulambangra', 'La Digue', 'Long', 'Mahe', 'Maio', 'New Hanover', 'Ouvea', 'Praslin Island', 'Rendova', 'Sal' , 'Santa Antao', 'Sao Nicolau', 'Sao Vicente', 'Silhouette Island', 'Society Islands', 'South Georgia Isl', 'Timor', 'Tristan da Cunha', 'Vangunu', 'Vella Lavella', 'Ysabel')

# identify rows in occ where occ$Island is in remove

for (i in 1:length(occ$Island)) {
  if (occ$Island[i] %in% remove) {occ$good_island[i] <- 0}
}

summary(occ$good_island)

# remove all other rows (i.e. where good_island is 0)
occ <- subset(occ, occ$good_island == 1)

summary(occ)

# remove these 'remove' islands from the islands list too
# identify rows in islands where island$Island is in remove
islands$good_island <- 1

for (i in 1:length(islands$Island)) {
  if (islands$Island[i] %in% remove) {islands$good_island[i] <- 0}
}
summary(islands$good_island)

# remove all rows where good_island is 0
islands <- subset(islands, islands$good_island == 1)

summary(islands)


# save new data files
write.scsv(occ, 'IBFDB_occurrences_v13.csv')
write.csv(islands, 'IBFDB_islands_v13.csv')

### stopped here


# Get all species trait data
EltonTrait <- read.csv('GlobalBirdDB_Jetz.csv', header=T, na.strings=c("","NA"))
caribbean <- read.csv('caribbean_guild_data.csv', header=T, na.strings=c("","NA"))
guilds <- read.csv('IBFDB_traits_v12.csv', header=T, na.strings=c("", "NA"))

summary(guilds) # provides a matchup between my species ID and the Sibley2_0ID

# need to combine all of these based on the master species list from 'occ'
sp_names <- data.frame(occ$Species_Name, occ$Common_Name, occ$Sibley2_0ID, occ$AB_Species_ID)
summary(sp_names)


install.packages('RODBC')
install.packages('tidyr')
install.packages('dplyr')

library(RODBC)
library(tidyr)
library(dplyr)

channel <- odbcConnect('dartmouth','kyuan','kyuan@qbs181')
demo <- sqlQuery(channel,'select * from Demographics')
str(demo)
head(demo)
#convert the table Demographics into R, and check the variable factors in each column

chro <- sqlQuery(channel, 'select * from ChronicConditions')
str(chro)
head(chro)
#convert the table ChronicConditions into R, and check the variable factors in each column

text <- sqlQuery(channel, 'select * from Text')
str(text)
head(text)
#convert the table Text into R, and check the variable factors in each column

combined <- merge(demo,chro, by.x='contactid', by.y='tri_patientid')
#merge the table, using 'contactid' in demographics and 'tri_patientid' in chronicconditions
combined1 <- merge(combined, text, by.x='contactid', by.y='tri_contactid')
#merge the tables already merged with table tex, using 'tri_contactid' in Text and 'contactid' in combined table
str(combined)
head(combined)
#check the variables in each column

combined1 %>%
  group_by(contactid) %>%
  slice(which.max(TextSentDate))
#Obtain the final dataset that 1 row per ID by chossing on the latest date when the text was sent from 'TextSentDate'
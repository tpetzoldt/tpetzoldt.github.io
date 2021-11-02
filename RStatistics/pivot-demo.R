library("readxl") # read Excel files directly
library("tidyr")  # data management package
library("dplyr")

lakedata <- read_excel("3_tab_kenndaten-ausgew-seen-d_2021-04-08.xlsx", sheet="Tabelle1", skip=3)

## rename German column names to consistent English names
names(lakedata) <- c("lakename", "state", "drainage", "population", "altitude",
                  "z_mean", "z_max", "t_ret", "volume", "area", "shore_length",
                  "shore_devel", "drain_ratio", "wfd_type")

## remove last two lines that are footnotes, i.e keep only rows that have a Bundesland (state)
lakedata <- lakedata[!is.na(lakedata$state), ]

## convert all numeric columns to "parameter", "value" pairs
lakedata_long <- pivot_longer(lakedata,
                              names_to = "parameter",
                              cols = -any_of(c("lakename", "state", "wfd_type")))



## Part 2 ======================================================================

# Here I show how a table can be split intotwo if two or more columns are redundant.

# The columns "state" and "wfd_type" (water framework directive type) are redundant,
# as they are constant for a given lake. Therefore it is better to put them in a separate
# table.

## Table 1: 54 wows, for each lake only one
lakes <- lakedata[c("lakename", "state", "wfd_type")]

## Table 2: long table with all parameters, but without the redundant columns
## remove redundant columns
## the exclamation mark ! indicates "not"
lakedata_long <- select(lakedata_long, !c("state", "wfd_type"))

## Test:
## now, the two tables "lakes" and "lakedata_long" can be joined at any time
left_join(lakedata_long, lakes, by="lakename")

## Exercise: use write.table to write the two tables to the disc.
## Then use a text editor and inspect the two tables.




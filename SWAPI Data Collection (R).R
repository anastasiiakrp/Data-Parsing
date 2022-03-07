#The Star Wars API Data Collection (R)
#Anastasiia Karpushkina

library(data.table)
library(httr)


# 1 ---------------------------------------------------------------

sw_chars_table <- lapply(1:83, function(i) {
  query <- paste('https://swapi.dev/api/people/', i,'/', sep ='')
  sw_char <- GET(query)
  sw_char <- content(sw_char)
  
  sw_chars_dt <- data.table(name = sw_char$name, 
                            gender = sw_char$gender,
                            hair_color = sw_char$hair_color,
                            skin_color = sw_char$skin_color,
                            birth_year = sw_char$birth_year,
                            homeworld = sw_char$homeworld)
  return(sw_chars_dt)
})

sw_chars_table <- rbindlist(sw_chars_table)


# 2 ---------------------------------------------------------------

planet <- lapply(1:nrow(sw_chars_table), function(i) {
  query1 <- sw_chars_table$homeworld[i]
  planet <- GET(query1)
  planet <- content(planet)
  
  planet_name <- data.table(planet_name = planet$name,
                            homeworld = planet$url)
  return(planet_name)
})
planet <- rbindlist(planet)
planet <- unique(planet)

sw_chars_table <- merge(sw_chars_table, planet, by = 'homeworld', all = TRUE)

sw_chars_table <- sw_chars_table[, homeworld := sw_chars_table$planet_name]
sw_chars_table <- sw_chars_table[, planet_name := NULL]

# 3 ---------------------------------------------------------------

#Function to retrieve information about the hero

search_name <- function(x) {
  q <- paste('https://swapi.dev/api/people/?search=', x, sep='')
  query <- URLencode(q)
  hero <- GET(query)
  hero <- content(hero)
  hero[[4]][[1]]
}

search_name('Darth Vader')


library(tidyverse)
library(rtweet)
library(tidytext)
library(wordcloud)
data(stop_words)
token <- get_tokens()
raw_twit <- get_timeline("Aaron_Derfel", n =  3200)


url_pattern <- "http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+"

# remove url
twit <- raw_twit %>% 
  mutate(text2 = str_replace(text, url_pattern, ""),  # remove url
         text3 =  str_replace(text2, "^\\d{1,2}\\)", "") # remove thread numbers
         #text4 = str_replace_all(text2, "@([a-zA-Z]|[0-9]|[_])*", "")  # remove @ follwoed by letters , numbers and underscores
         
  ) %>%
  select(-text,-text2) %>%
  rename(text= text3) %>%
  mutate(date = as.Date(created_at))


# graph mention legault et vadeboncoeur
mentions <- twit %>% 
  mutate(
    mentionne_legault = map_int(mentions_screen_name, ~  "francoislegault" %in% .x) ,
    mentionne_vadeboncoeur = map_int(mentions_screen_name, ~  "Vadeboncoeur_Al" %in% .x)) %>%
  group_by(date) %>%
  filter(date >= lubridate::ymd("20200401"))%>% 
  summarise(count = n(),
            mentionne_legault = sum(mentionne_legault),
            mentionne_vadeboncoeur = sum(mentionne_vadeboncoeur)
  )   %>% 
  complete(date = seq.Date(lubridate::ymd("20200401"), Sys.Date(), by = "day")) %>%
  mutate(count = replace_na(count, 0), 
         mentionne_legault = replace_na(mentionne_legault, 0),
         mentionne_vadeboncoeur = replace_na(mentionne_vadeboncoeur, 0)
  )

moyenne_legault <- mean(mentions$mentionne_legault)
moyenne_vadeboncoeur <- mean(mentions$mentionne_vadeboncoeur)

mentions %>% 
  ggplot(aes(x = date, y = mentionne_legault)) +
  geom_col() + 
  dviz.supp::theme_dviz_grid()+
  scale_y_continuous(breaks = scales::pretty_breaks(n =5) )+
  labs(
    title = "Nombre quotidien de tweets de @Aaron_Derfel mentionnant @francoislegault",
    subtitle= paste0("moyenne de ",  round(moyenne_legault,1), " par jour depuis le 1er avril")
  ) +
  xlab("Date")+
  ylab ("Nombre de tweets") +
  theme(legend.position="bottom") +
  expand_limits(y = 0)


mentions %>% 
  ggplot(aes(x = date, y = mentionne_vadeboncoeur)) +
  geom_col() + 
  dviz.supp::theme_dviz_grid()+
  scale_y_continuous(breaks = scales::pretty_breaks(n =5) )+
  labs(
    title = "Nombre quotidien de tweets de @Aaron_Derfel mentionnant @vadeboncoeur_al",
    subtitle= paste0("moyenne de ",  round(moyenne_vadeboncoeur,1), " par jour depuis le 1er avril")
  ) +
  xlab("Date")+
  ylab ("Nombre de tweets") +
  theme(legend.position="bottom") +
  expand_limits(y = 0)



# tokenize, remove stopwords
tidytwit <- twit %>% 
  select(text, date, status_id) %>% 
  unnest_tokens(word, text)  %>% 
  anti_join(stop_words)

# most popular words

tidytwit %>%
  count(word, sort = TRUE) 


tidytwit %>%
  count(word, sort = TRUE) %>%
  filter(n > 190) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n)) +
  geom_col() +
  xlab(NULL) +
  coord_flip() + 
  dviz.supp::theme_dviz_grid()



# sentiments haha


# joy derfel
nrc_joy <- get_sentiments("nrc") %>% 
  filter(sentiment == "joy")


tidytwit %>%
  inner_join(nrc_joy) %>%
  count(word, sort = TRUE) %>%
  filter(n > 10) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n)) +
  geom_col() +
  xlab(NULL) +
  coord_flip() + 
  dviz.supp::theme_dviz_grid()


# angry derfel

nrc_anger <- get_sentiments("nrc") %>% 
  filter(sentiment == "anger")


tidytwit %>%
  inner_join(nrc_anger) %>%
  count(word, sort = TRUE)  %>% 
  filter(n > 10) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n)) +
  geom_col() +
  xlab(NULL) +
  coord_flip() + 
  dviz.supp::theme_dviz_grid()

# sentiment négatif par jour

tweet_sentiments <- tidytwit %>%
  inner_join(get_sentiments("bing")) %>%
  count(date, status_id, sentiment) %>%
  spread(sentiment, n, fill = 0) %>%
  mutate(sentiment_tweet = positive - negative) 

date_sentiments <- tweet_sentiments %>% group_by(date ) %>% summarise(sentiment_day = sum(sentiment_tweet))

ggplot(date_sentiments, aes(date, sentiment_day)) +
  geom_col(show.legend = FALSE) 


# most positive day
date_sentiments %>% filter(sentiment_day == max(sentiment_day) ) %>% select(date) %>% 
  inner_join(tweet_sentiments) %>% 
  left_join(twit) %>%
  select(date, status_id, sentiment_tweet, negative, positive, text) 
  
# most positive tweets

tweet_sentiments %>% filter(sentiment_tweet == max(sentiment_tweet)) %>%
  inner_join(twit)%>% 
  select(date, status_id, sentiment_tweet, negative, positive, text) %>%
  View

# most negative tweets

tweet_sentiments %>% filter(sentiment_tweet == min(sentiment_tweet)) %>%
  inner_join(twit)%>% 
  select(date, status_id, sentiment_tweet, negative, positive, text) %>%
  View




# 10 sentiments evolution
fun <- tidytwit %>% 
  inner_join( get_sentiments("nrc") ) %>%
  count(date, sentiment) %>%
  left_join(twit %>% group_by(date) %>% summarise(ntweet = n())) %>%
  group_by(date) %>%
  mutate(percent = n /sum(n)) %>%
  mutate(intensity = n /ntweet) %>%
  
  ungroup()

fun %>%
  ggplot(aes(x= date, y = intensity)) +
  geom_line() +
  geom_smooth() +
  facet_wrap(~ sentiment) + 
  dviz.supp::theme_dviz_grid() + 
  theme(axis.text.x = element_text(angle = 30, hjust = 1, vjust = 1)) +
  labs(
    title = "Evolution of @Aaron_Derfel tweet sentiment",
    subtitle = "Words expressing a given sentiment per tweet sents on a given day",
    caption = "Graph by @coulsim"
  ) +
  xlab("date")+
  ylab ("Words per tweet")


# word cloud


tidytwit %>%
  count(word) %>%
  with(wordcloud(word, n, max.words = 100))

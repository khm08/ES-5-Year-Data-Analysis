
# Load necessary libraries
library(ggplot2)
library(dplyr)

# Load the ES dataset
es_data <- read.csv('ES_5Years_8_11_2024.csv')
es_data$Time <- as.POSIXct(es_data$Time, format='%m/%d/%Y %H:%M')

# Aggregate data to daily level
es_daily <- es_data %>%
  mutate(Date = as.Date(Time)) %>%
  group_by(Date) %>%
  summarise(Open = first(Open),
            High = max(High),
            Low = min(Low),
            Close = last(Close),
            Volume = sum(Volume))

# Plot ES Close Price over time
ggplot(es_daily, aes(x = Date, y = Close)) +
  geom_line(color = 'blue') +
  labs(title = 'ES Close Price Over Time', x = 'Date', y = 'Close Price')

# Calculate moving averages
es_daily <- es_daily %>%
  mutate(`20_Day_MA` = zoo::rollapply(Close, 20, mean, fill = NA, align = 'right'),
         `50_Day_MA` = zoo::rollapply(Close, 50, mean, fill = NA, align = 'right'))

# Plot moving averages
ggplot(es_daily, aes(x = Date)) +
  geom_line(aes(y = Close, color = 'Close Price')) +
  geom_line(aes(y = `20_Day_MA`, color = '20-Day MA')) +
  geom_line(aes(y = `50_Day_MA`, color = '50-Day MA')) +
  labs(title = 'ES Close Price with Moving Averages', x = 'Date', y = 'Price') +
  scale_color_manual(values = c('Close Price' = 'blue', '20-Day MA' = 'red', '50-Day MA' = 'green'))

# Plot trading volume over time
ggplot(es_daily, aes(x = Date, y = Volume)) +
  geom_bar(stat = 'identity', fill = 'orange') +
  labs(title = 'ES Trading Volume Over Time', x = 'Date', y = 'Volume')

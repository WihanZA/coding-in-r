# Setup ---------------------------------------------------------------

# Observe the location of your working directory, the location of your project
getwd()

# Packages ----------------------------------------------------------------

# First install the package from CRAN
install.packages("pacman")

# Load the installed package into your workspace
library(pacman)

# From CRAN
p_load(fixest, tidyverse, huxtable, modelsummary, glue) # or
pacman::p_load(fixest, tidyverse, huxtable, modelsummary, glue)

# From GitHub where "profile/repository name"
p_load_gh("BlakeRMills/MetBrewer")

# Environment -------------------------------------------------------------

# object name <- (or =) value(s)
a <- 10
hello <- "Hello world!"
test <- TRUE

# Determine the class of an object
class(a)
class(hello)
class(test)

# Report these variables in your output by running the following:
a
# or
print(hello)
# or with the glue package for something more fancy
glue::glue("It's {test}. I saved a variable which contains {hello} and I stored the number {a}.")

# Arrays ------------------------------------------------------------------

# Arrays can be created by concatenating values using the function c()
x <- c(1, 2, 3, 4)
y <- c(4, 5, 6, 7)
z <- c(7, 8, 9, 10)

# Useful functions to perform on arrays/vectors
sum(x)
min(x)
median(x)

# summary() provides a summary of the functions above
summary(x)

# Missing values denoted by NA
x_with_missing <- c(1, 2, 3, NA)

# Take care to properly treat missing values:
sum(x_with_missing)
sum(x_with_missing, na.rm = T)

# Data frames -------------------------------------------------------------

# data.frame() can create columns from arrays and assign column names
df_1 <- data.frame(A = x, B = y, C = z)

# Some useful operations
colnames(df_1)
df_1_copy <- df_1
colnames(df_1_copy) <- c("col1", "col2", "col3")
colnames(df_1_copy)
nrow(df_1)
ncol(df_1)

# Return column "A" as a vector
df_1$A

# df_1[row no., column no.] - empty implies all
df_1[, 1]

# Using tidyverse's pipe operator %>%
df_1 %>% pull(A)

# Similarly with rows
# Return row 2 as a single row data frame
df_1[2, ]

# Return row 2-3 as a two row data frame
df_1[2:3, ]

# Return cell in row 2 column 1
df_1[2, 1]

# Create a new column "D" that is the sum of A and B
df_1$D <- df_1$A + df_1$B

# is the same as
df_1 <- df_1 %>% mutate(D = A + B)

# Reading data ------------------------------------------------

ire_energy <- read.csv(file = "../data/Ireland_energy.csv", header = TRUE)
# The "file" argument refers to the relative file path from your root directory
# The "header" argument is set to true because the .csv file contains column headings

ire_pop <- read.csv("../data/Ireland_population.csv")
# Sometimes it's unnecessary to spell out the arguments

head(ire_energy, 5) # same as ire_energy[1:5, ]
tail(ire_pop, 5) # same as ire_pop[(nrow(ire_pop) - 4): nrow(ire_pop), ]

# skim() can provide useful overviews of data frames
skimr::skim(ire_pop)


# Manipulating data -------------------------------------------------------

ireland_df <- merge(x = ire_energy, y = ire_pop, by.x = "Year", by.y = "Year")
# merge() merges data frames x and y on the basis of some column
# by.x for x's column and by.y for y's column

ireland_df <- ireland_df %>%
  mutate(ln_energy_pc = log(GJ / Population))
# You should recognise mutate() from before
# log()'s default setting implies natural logarithmic transformation

# Instead of tidyverse piping, you could have done this:
ireland_df <- mutate(.data = ireland_df, ln_energy_pc = log(GJ / Population))

# But piping is more useful when you require multiple consecutive operations
# For example, everything we've done thus far could've been condensed
ireland_df <- read.csv("../data/Ireland_energy.csv") %>%
  merge(
    x = ., # full stop represents the result of all previous operations
    y = read.csv("../data/Ireland_population.csv"),
    by.x = "Year",
    by.y = "Year"
  ) %>%
  mutate(ln_energy_pc = log(GJ / Population))

# For example, `ireland_df`'s `Year` column is of the class `integer`.
ireland_df$Year %>%
  class(.)

# Transform the `Year` column from an integer to a date.
ireland_df <- ireland_df %>%
  mutate(Year = glue::glue("{Year}-01-01"))
# creates  "1980-01-01" instead of 1980
# but the result is of class `character`

ireland_df <- ireland_df %>%
  mutate(Year = as.Date(x = Year, format = "%Y-%m-%d"))
# as.Date() renders characters of a given format into dates
# "%Y-%m-%d" means yyyy-mm-dd

# Confirm that data is chronological
ireland_df <- ireland_df %>%
  arrange(Year) # this is equivalent to sorting by Year

# Let's see what our new data frame `ireland_df` looks like.
view(ireland_df)

# Create a table using the huxtable package - observations after 2013
ireland_df %>%
  filter(Year > as.Date("2013-01-01")) %>%
  # subsets data for entries after 2013

  as_hux() %>%
  # or huxtable::as_hux() to transform data frame into huxtable object
  # hereafter code to define certain aesthetic qualities of our table

  theme_basic() %>%
  # use a theme to make tables more presentable, e.g. theme_article() or theme_compact()

  set_number_format(col = c(2, 4), value = 2) %>%
  # set number of decimals to 2 in the 2nd and 4th column

  set_font_size(10) %>%
  set_caption("Ireland's energy consumption after 2013")


# Writing data ------------------------------------------------------------

# We can now write this data frame back to a `.csv` file
ireland_df %>% # data frame to be written to csv
  write.csv(
    x = ., # ireland_df is piped into "."
    file = "../data/ireland_complete.csv", # file path and file name we choose
    row.names = FALSE
  ) # because we have no row names


# Time series analysis ----------------------------------------------------

# Visualising time series -------------------------------------------------

# plot()'s default is a scatterplot
# inputting a single vector
ireland_df$ln_energy_pc %>%
  plot(.)

# undefined x-axis
# inputting a data frame with two columns
ireland_df %>%
  select(Year, ln_energy_pc) %>%
  plot(.)

# lines instead of points
ireland_df %>%
  select(Year, ln_energy_pc) %>%
  plot(., type = "l")

# ggplotting
ireland_df %>%
  ggplot(aes(x = Year, y = ln_energy_pc)) +
  theme_bw() +
  geom_point() +
  geom_line() +
  labs(
    title = "Ireland's Primary Energy Consumption",
    y = "ln(GJs Per Capita)",
    x = "Date"
  ) +
  scale_x_date(
    date_labels = "`%y",
    date_breaks = "2 year"
  ) +
  scale_y_continuous(limits = c(4, 5.5))

# and customise as you please
ireland_df %>%
  ggplot(aes(x = Year, y = ln_energy_pc)) +
  theme_bw() +
  geom_point(
    aes(color = ifelse(Year < as.Date("2000-01-01"), "Before 2000",
      ifelse(Year > as.Date("2000-01-01"), "After 2000", "2000")
    )),
    size = 1.5
  ) +
  geom_line(
    alpha = 0.5,
    color = "lightgrey",
    size = 1
  ) +
  labs(
    title = "Ireland's Primary Energy Consumption",
    y = "ln(GJs Per Capita)",
    x = "Date"
  ) +
  scale_x_date(
    date_labels = "`%y",
    date_breaks = "2 year"
  ) +
  scale_y_continuous(limits = c(4, 5.5)) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 10),
    axis.title.y = element_text(
      margin = margin(t = 0, r = 10, b = 0, l = 0),
      size = 10
    ),
    axis.title.x = element_text(
      margin = margin(t = 0, r = 0, b = 0, l = 0),
      size = 10
    ),
    axis.text.x = element_text(angle = 45),
    legend.position = "bottom",
    legend.margin = margin(t = -10, r = 0, b = 0, l = 0),
    legend.title = element_blank()
  ) +
  geom_label(
    data = . %>% filter(Year == as.Date("2000-01-01")),
    aes(label = round(ln_energy_pc, 1)),
    nudge_y = 0.15,
    size = 3,
    color = met.brewer("Austria", type = "discrete")[1]
  ) +
  geom_hline(aes(color = "Mean", yintercept = mean(ln_energy_pc)),
    size = 1,
    linetype = "dashed",
    show.legend = F
  ) +
  scale_color_manual(values = met.brewer("Austria", type = "discrete"))

# Autocorrelation ---------------------------------------------------------

ireland_df %>%
  select(ln_energy_pc) %>% # isolate ln_energy_pc in data frame
  acf(
    plot = T, # create a plot
    type = "correlation"
  ) # standard ACF

ireland_df %>%
  select(ln_energy_pc) %>%
  acf(
    plot = T,
    type = "partial"
  ) # PACF option

# Unit root tests ---------------------------------------------------------

# load the urca package
p_load(urca)

# ur.df() requires a vector/array
# you should recognise pull() from before
test_vector <- ireland_df %>%
  pull(ln_energy_pc)

my_ADF1 <- ur.df(
  y = test_vector, # vector
  type = "trend", # type  of ADF - trend + constant
  lags = 5, # max number of lags
  selectlags = "AIC"
) # lag selection criteria

# use summary() to present the saved ADF object
# summary() wraps many different kinds of objects
summary(my_ADF1)


# Cross section analysis --------------------------------------------------

# Replace a local file path with a web address
# Subset the data to only those observations in 1974
# To restrict memory usage, select only the relevant columns
cs_df <- read.csv("https://raw.githubusercontent.com/stata2r/stata2r.github.io/main/../data/cps_long.csv") %>%
  filter(year == 1974) %>%
  select(wage, educ, age, marr)

# Descriptive statistics --------------------------------------------------

# Get an overview of the sample
# Do you notice any issues?
skimr::skim(cs_df)

# Get an impression of wage by marital status
cs_df %>%
  select(wage, marr) %>%
  group_by(marr) %>%
  skimr::skim()

# Regressions -------------------------------------------------------------

# Our first model
model1 <- feols(fml = wage ~ educ, data = cs_df)

# Adding an explanatory continuous variable: age
model2 <- feols(wage ~ educ + age, cs_df)

# Adding a categorical variable
model3 <- feols(wage ~ educ + age + factor(marr), cs_df)

# As before, use summary() to display the results of model1
summary(model1)

# Visualising results -----------------------------------------------------

huxreg(model1, model2, model3)

huxreg(
  "Model 1" = model1, "Model 2" = model2, "Model 3" = model3,
  statistics = c("N" = "nobs", "R-squared" = "r.squared"),
  stars = c(`*` = 0.1, `**` = 0.05, `***` = 0.01, `****` = 0.001),
  number_format = 2,
  coefs = c(
    "Education" = "educ",
    "Age" = "age",
    "Married" = "factor(marr)1"
  )
) %>%
  set_font_size(8) %>%
  set_caption("My Regression Table")

# Notice that models need to be entered as a list() object
coefplot(list(model1, model2, model3))

# Interaction effects -----------------------------------------------------

# Same as before, but "*" denotes an interaction
model4 <- feols(wage ~ educ * factor(marr), data = cs_df)

# What do our results say?
summary(model4)

cs_df %>%
  ggplot(aes(x = educ, y = wage)) +
  theme_bw() +
  geom_point(alpha = 0.5) + # creates a scatterplot
  geom_smooth(
    formula = y ~ x, # x, y inherited from aes()
    method = "lm", # specifies linear model
    aes(color = factor(marr)), # creates two regression lines
    se = T, # display confidence interval,
    level = 0.95
  ) + # confidence level to 95%
  theme(legend.position = "bottom") +
  labs(
    y = "Wage", x = "Years of Education", color = "Married",
    title = "The effect of education on wage by marital status"
  )

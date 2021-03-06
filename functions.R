# ----------- #
# functions.R #
# ----------- #
# DESC: The functions.R script houses functions for the app.


# Not In Operator ---------------------------------------------------------
# DESC: Create the opposite of the '%in%' operator
'%!in%' <- function(x, y){
  !('%in%'(x, y))
}

# Modal Dialog box --------------------------------------------------------
modal <- function(failed = FALSE) {
  
  modalDialog(
    
    title = tags$b("Terms of Use"),
    
    "Please confirm that you agree to the following:", br(), br(),
    
    "1.	You understand that the following applies to this dashboard:", br(), br(),
    tags$ul(
      tags$li("The data in this app comes from the Asia Development Bank."), br(),
      tags$li("The author of the app is not liable for any potential misuses of the app."), br(),
      tags$li("Any work built on top of this code is shared publicly in line with the spirit of open data.")
    ), br(),
    "2.	You confirm that you any work built off of this is credited to the right author.", br(), br(),
    
    "By logging into the app, you are agreeing to these Terms of Use.", br(), br(),
    
    # centre password input box, to ensure logging in
    div(style = "width: 200px ;
        margin-left: auto ;
        margin-right: auto ;
        text-align: center;",
        passwordInput(inputId = "password",
                      label = "Password:",
                      placeholder = "********")
    ),
    
    # if login fails, add message to say so
    if (failed) div(
      style = "text-align: center;", 
      tags$b("Your password is incorrect, please try again", style = "color: red;")
    ),
    
    # only have actionButton in footer, no modealButton so not easy to close
    footer = tagList(
      div(style = "text-align: center;",
          actionButton(inputId = "pwd-submit", label = "Submit")
      )
    ),
    
    # Logic for dynmically including warning message
    if(!(is.na(message_warning))) {
      div(style = "text-align:center; font-size: 2vh;",
          HTML("<strong>WARNING: </strong> \n"), message_warning)
    }
    
  ) #modalDialog
}

# Row Bind Transformation -------------------------------------------------
# Need to use lazy evaluation
transform_for_row_bind <- function(x, key_name, col_name) {
  x <- x %>%
    mutate(key = key_name) %>%
    rename(value = as.name(col_name)) %>%
    select(CountryCode, RegionalMember, Year, Subregion, key, value)
  return(x)
}

# GDP ValueBox Info -------------------------------------------------------
add_columns_gdp <- function(x, column){
  
  # create columns to refer to in valueBox() args in server.R
  x <- x %>% 
    mutate(
      colour_gdp = case_when(
        column < 0     ~ "red",
        column == 0    ~ "yellow",
        column > 0     ~ "green",
        TRUE           ~ "light-blue"
      ),
      icon_gdp = case_when(
        column < 0     ~ "exclamation-triangle",
        column == 0    ~ "exclamation-circle",
        column > 0     ~ "certificate",
        TRUE           ~ "question-circle"
      ),
      tooltip_gdp = case_when(
        column < 0     ~ "This country is forecasted to have negative economic growth in GDP from 2018-19.",
        column == 0    ~ "This country is forecasted to have no economic growth in GDP from 2018-19.",
        column > 0     ~ "This country is forecasted to have positive economic growth in GDP from 2018-19.",
        TRUE           ~ "This country does not have forecasts for economic growth in GDP from 2018-19."
      )
    )
  return(x)
}


# External Debt Outstanding Info ------------------------------------------
add_columns_debt <- function(x, column) {
  
  # create columns to refer to in valueBox() args in server.R
  x <- x %>% 
    mutate(
      colour_debt = case_when(
        column < 0     ~ "green",
        column == 0    ~ "yellow",
        column > 0     ~ "red",
        TRUE           ~ "light-blue"
      ),
      icon_debt = case_when(
        column < 0     ~ "certificate",
        column == 0    ~ "exclamation-circle",
        column > 0     ~ "exclamation-triangle",
        TRUE           ~ "question-circle"
      ),
      tooltip_debt = case_when(
        column < 0     ~ "This country has negative debt, meaning they are owed money by other countries from 2017.",
        column == 0    ~ "This country has no debt, meaning they do not owe money to other countries from 2017.",
        column > 0     ~ "This country has positive debt, meaning they owe money to other countries from 2017.",
        TRUE           ~ "This country has no information available for external outstanding debt for 2017."
      )
    )
  return(x)
      
}

# Trade Balance ValueBox Info -------------------------------------------------------
add_columns_trade <- function(x, column){
  
  # create columns to refer to in valueBox() args in server.R
  x <- x %>% 
    mutate(
      colour_trade = case_when(
        column < 0     ~ "red",
        column == 0    ~ "yellow",
        column > 0     ~ "green",
        TRUE           ~ "light-blue"
      ),
      icon_trade = case_when(
        column < 0     ~ "exclamation-triangle",
        column == 0    ~ "exclamation-circle",
        column > 0     ~ "certificate",
        TRUE           ~ "question-circle"
      ),
      tooltip_trade = case_when(
        column < 0     ~ "This country is forecasted to have a negative trade balance from 2018-19.",
        column == 0    ~ "This country is forecasted to have an even trade balance from 2018-19.",
        column > 0     ~ "This country is forecasted to have positive trade balance from 2018-19.",
        TRUE           ~ "This country does not have forecasts for trade balance from 2018-19."
      )
    )
  return(x)
}


# Custom ggplot Function -----------------------------------------------------
# DESC: Generic function to plot GDP Change, Trade Balance, Debt Outstanding
custom_ggplot <- function(data, axis_x, axis_y, colours_column, plot_title, plot_subtitle, axis_y_title, axis_y_prefix = "", axis_y_suffix = "") {
  ggplot(data = data, mapping = aes(x = axis_x, y = axis_y)) +
    geom_line(colour = "grey") +
    
    # add custom colouring on negative and positive values
    geom_point(mapping = aes(colour = colours_column), size = 3) +
    scale_colour_manual(values = c("#0072B2", "#D55E00")) +
    
    # add 0-horizontal line
    geom_hline(yintercept = 0, linetype = "dashed") +
    
    # include £ prefix
    theme_classic() + 
    scale_y_continuous(labels = dollar_format(prefix = axis_y_prefix, suffix = axis_y_suffix)) +
    
    # force unique academic years
    scale_x_continuous(breaks = unique(axis_x)) +
    labs(title = plot_title, subtitle = plot_subtitle) +
    xlab("Academic Year") + ylab(axis_y_title) +
    
    # general plot themes
    theme(plot.title = element_text(face = "bold", hjust = 0.5),
          plot.subtitle = element_text(face = "bold", hjust = 0.5),
          title = element_text(face = "bold"),
          legend.position = "none")
}

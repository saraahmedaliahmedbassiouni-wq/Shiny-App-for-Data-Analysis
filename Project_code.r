# Load required libraries
library(shiny) # For creating the Shiny app
library(ggplot2) # For creating plots
library(dplyr) # For data manipulation (e.g., distinct, filter, mutate, group_by, arrange, summarize)
library(cluster) # For performing k-means clustering
library(arules) # For generating association rules using the Apriori algorithm
library(shinythemes) # For using different themes in the UI
library(shinydashboard) # For creating the dashboard layout

# Function to read user-uploaded data
read_uploaded_data <- function(filepath) {
  read.csv(filepath, stringsAsFactors = FALSE)
}

# Function to clean data
clean_data <- function(data) {
  required_columns <- c("items", "count", "total", "rnd", "customer", "age", "city", "paymentType") # Columns expected in the dataset
  data <- data %>%
    distinct() %>% # Remove duplicate rows
    na.omit() %>% # Remove rows with missing values
    filter(total > 0) %>% # Ensure total column has positive values
    mutate(age = as.numeric(age)) %>% # Convert age column to numeric
    filter(!is.na(age) & age >= 0) # Filter valid ages (non-NA, non-negative)
  
  # Identify and remove outliers in the 'count' column
  outliers <- boxplot(data$count, plot = FALSE)$out
  cleaned_data <- data[!data$count %in% outliers, ]
  return(cleaned_data)
}

# UI definition
ui <- fluidPage( # Create a flexible layout
  theme = shinytheme("darkly"), # Apply the "darkly" theme
  titlePanel("Welcome to the Data Analysis App! Team 4"), # App title
  sidebarLayout(
    sidebarPanel( # Input panel for user interactions
      fileInput("file", "Upload CSV File", accept = c(".csv")), # File input for CSV uploads
      numericInput("clusters", "Number of Clusters (2-4)", value = 2, min = 2, max = 4), # Numeric input for selecting number of clusters
      sliderInput("min_support", "Minimum Support", 
                  min = 0.001, max = 1, value = 0.001, step = 0.01), # Slider for minimum support
      sliderInput("min_confidence", "Minimum Confidence", 
                  min = 0.001, max = 1, value = 0.15, step = 0.01), # Slider for minimum confidence
      actionButton("run", "Analyze Data") # Button to trigger data analysis
    ),
    mainPanel( # Panel to display output
      tabsetPanel(
        tabPanel("Data Table", # Tab to display the data table
                 h3("Uploaded Data"),
                 verbatimTextOutput("data_table")),
        tabPanel("Summary", # Tab to display data summary
                 h3("Data Summary"),
                 verbatimTextOutput("summary")),
        tabPanel("Dashboard", # Tab to display dashboard visualizations
                 h3("Visualizations"),
                 plotOutput("plots")),
        tabPanel("Clustering", # Tab to display clustering results
                 h3("Clustering Results"),
                 plotOutput("cluster_plot"),
                 verbatimTextOutput("clustering_results")),
        tabPanel("Association Rules", # Tab to display association rules
                 h3("Association Rules"),
                 tableOutput("rules_table"))
      )
    )
  )
)

# Server definition
server <- function(input, output, session) {
  
  # Reactive object to store and process data
  data <- eventReactive(input$run, { 
    req(input$file) # Ensure file input is not empty
    df <- read_uploaded_data(input$file$datapath)
    
    # Calculate and display the number of rows before and after cleaning
    rows_before <- nrow(df)
    cleaned_data <- clean_data(df)
    rows_after <- nrow(cleaned_data)
    
    showNotification(
      paste0("Data cleaned successfully: Rows before cleaning: ", rows_before, 
             ", Rows after cleaning: ", rows_after),
      type = "message",
      duration = 5
    )
    
    return(cleaned_data)
  })
  
  # Display the first few rows of cleaned data
  output$data_table <- renderPrint({
    req(data()) # Ensure data is available
    head(data())  
  })
  
  # Display a summary of the cleaned data
  output$summary <- renderPrint({
    req(data()) # Ensure data is available
    summary(data())
  })
  
  # Generate dashboard plots
  output$plots <- renderPlot({
    req(data()) # Ensure data is available
    df <- data()
    
    par(mfrow = c(2, 2)) # Arrange plots in a 2x2 grid
    
    # Pie chart for payment methods
    payment_counts <- table(df$paymentType)
    payment_percentages <- round(payment_counts / sum(payment_counts) * 100, 1)
    pie(payment_counts, payment_percentages, col = c("yellow", "purple"), main = "Cash vs Credit by Total Spending")
    legend("topright", 
           legend = paste(names(payment_counts), "(", payment_percentages, "%)", sep = ""),
           fill = c("purple", "yellow"), 
           title = "Payment Method")
    
    # Age vs Total Spending
    new_data <- df %>%
      group_by(age) %>%
      summarise(total = sum(total))
    plot(x = new_data$age, y = new_data$total, col = "blue", main = "Age vs Total Spending",
         xlab = "Age", ylab = "Total", type = "b")
    
    # Bar plot for spending by city
    city_spending <- df %>%
      group_by(city) %>%
      summarize(TotalSpending = sum(total)) %>%
      arrange(desc(TotalSpending))
    city_colors <- c("red", "blue", "green", "purple", "orange", "black", "white", "pink", "gray", "skyblue")  
    barplot(city_spending$TotalSpending, 
            names.arg = city_spending$city, 
            col = city_colors[1:length(city_spending$city)],  
            main = "Total Spending by City", 
            las = 2)
    
    # Histogram for total spending
    hist(df$total, col = "gray", main = "Distribution of Total Spending", xlab = "Total Spending")
  })
  
  # Generate clustering plot
  output$cluster_plot <- renderPlot({
    req(data(), input$clusters) # Ensure data and clusters are available
    df <- data()
    clustering_data <- df %>% select(age, total)
    clusters <- kmeans(clustering_data, centers = input$clusters)
    df$Cluster <- as.factor(clusters$cluster)
    
    plot(df$age, df$total, col = df$Cluster, pch = 19, 
         main = "Clustering of Customers by Age and Spending",
         xlab = "Age", ylab = "Total Spending")
    legend("topright", legend = unique(df$Cluster), fill = unique(df$Cluster))
  })
  
  # Display clustering results
  output$clustering_results <- renderPrint({
    req(data(), input$clusters)
    df <- data()
    clustering_data <- df %>% select(age, total) %>% na.omit()
    clusters <- kmeans(clustering_data, centers = input$clusters)
    df$Cluster <- as.factor(clusters$cluster)
    return(print(df[, c("customer", "age", "total", "paymentType", "city", "Cluster")]))
  })
  
  # Display association rules
  output$rules_table <- renderTable({
    req(data(), input$min_support, input$min_confidence)
    df <- data()
    transactions <- as(split(df$items, df$total), "transactions")
    rules <- apriori(transactions, parameter = list(supp = input$min_support, conf = input$min_confidence))
    rules_df <- as(rules, "data.frame")
    if (nrow(rules_df) == 0) {
      return(data.frame(Message = "No rules generated. Try lowering the support and confidence."))
    }
    rules_df <- rules_df[, c("rules","support", "confidence")]
    return(rules_df)
  })
}

# Run the Shiny app
shinyApp(ui = ui, server = server)

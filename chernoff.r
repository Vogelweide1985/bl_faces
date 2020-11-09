
source("config.r", encoding = "UTF-8")



# Get WIKI MP- BL Table
file<-read_html(config$url)
tables<-html_nodes(file, "table")
df_mp <- html_table(tables[1], fill = TRUE)
df_mp <- as.data.frame(df_mp)



# Get WIKI BL Table allgemein
file<-read_html(config$url_bl)
tables<-html_nodes(file, "table")


# Get WIKI BL Table Allgemein
df_bl_a <- html_table(tables[1], fill = TRUE)
df_bl_a <- as.data.frame(df_bl_a)
df_bl_a <- df_bl_a[-nrow(df_bl_a), ]

# Get WIKI BL Table wirtschaft
df_bl_b <- html_table(tables[2], fill = F, dec= ",")
df_bl_b <- as.data.frame(df_bl_b)
df_bl_b <- df_bl_b[-nrow(df_bl_b), ] # EU
df_bl_b <- df_bl_b[-nrow(df_bl_b), ] # DE

#Function to correct weird number output
trim_table <- function(x) {
   x <- trimws(x, whitespace = "0")
   x <- gsub("\\..*","",x)
}


df_bl_b <- map_df(df_bl_b, trim_table)

df <- dplyr::left_join(df_mp, df_bl_a, by = c("Land"))   
df <- dplyr::left_join(df, df_bl_b, by= c("Kürzel" = "Land"))  


#Building data frame for Chernoff faces
chernoff <- matrix(nrow = 16, ncol = 15, rnorm(16 * 15))

#Chernoff plot

faces(chernoff)

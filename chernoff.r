
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

# Building variables

# Building nose, #lenght of vorname und nachname

temp <- data.frame(matrix((unlist(strsplit(df$Regierungs.chef.x, split = " " ))),
                          nrow=nrow(df ), byrow=T))
df[, "vorname"] <- as.character(temp[1,])
df[, "nachname"] <- as.character(temp[2,])
df[, "vorname_n"] <- nchar(df[, "vorname"])
df[, "nachname_n"] <-nchar(df[, "nachname"])



#Bulding ear, 
df$Geburts.datum <-gsub(".*♠","",df$Geburts.datum)
df$Geburts.datum <- dmy(df$Geburts.datum)
df$Geburts.datum <-  ymd(Sys.Date()) -  df$Geburts.datum 

df$Amtsantritt <-  gsub(".*♠","",df$Amtsantritt)
df$Amtsantritt <- dmy(df$Amtsantritt)
df$Amtsantritt <-  ymd(Sys.Date()) -  df$Amtsantritt  


#Building Mouth
df$schulden_reduktion <- -1*(as.numeric(df$Schulden..31.12.2018.in.Mrd....20.) / 
   as.numeric(df$Schulden..2012.in.Mrd....18.) )





#Building data frame for Chernoff faces
chernoff <- matrix(nrow = 16, ncol = 15, rnorm(16 * 15))

chernoff[, 1] <- as.numeric(gsub(",", ".", df[, "Ein.wohner.Mio...12."])) # Einwohner
chernoff[, 2] <- df[, "Fläche.km²..12."] # Fläche
chernoff[, 3] <- df[,"Ein.wohnerje.km².12."] # Einwohner je Fläche
chernoff[, 4] <- as.numeric(df$Schulden..31.12.2018.in.Mrd....20.) # Schulden 2018
chernoff[, 5] <- as.numeric(df$Schulden..2012.in.Mrd....18.)  # Schulden 2018
chernoff[, 6] <-  df[, "schulden_reduktion"] # Prozentualer Schuldenrueckgang 2018/2012
chernoff[, 7] <- gsub(",", ".", df[, "BIP..2018.in.Mrd....16."]) # BIP
chernoff[, 8] <- df[, "Pro.Kopf..2018.in...16."] #  BIP Pro Kopf einkommen
chernoff[, 9] <- df[, "EK.Kin...17."] #  Pro Kopf einkommen
chernoff[, 10] <- df[, "AQ.21."] #  Arbeitslosenquote
chernoff[, 11] <- gsub(",", ".", df[, "Ausländer....13."]) #  Ausländer
chernoff[, 12] <- df[, "vorname_n"] # Länge Vorname
chernoff[, 13] <- df[, "nachname_n"] # Länge Nahcname
chernoff[, 14] <- df[, "Amtsantritt"] # Amtsdauerin Tagen
chernoff[, 15] <- df[, "Geburts.datum"] # Alter in Tagen


chernoff <- apply(chernoff, 2, as.numeric)
chernoff <- apply(chernoff, 2, scale)

dimnames(chernoff) <- list(df$Kürzel)
#chernoff <- chernoff[ sample(nrow(chernoff)),] # randomize

#Chernoff plot
#par(bg = NA)
a <- faces(chernoff, scale = F, face.type = 0)

png('chernof.png',width=1100,height=800,units="px",bg = "transparent")
plot.faces(a, face.type = 0, byrow = T, labels = NA)

dev.off()


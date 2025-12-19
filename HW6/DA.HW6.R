#### HW6 ####
df <- USArrests
?USArrests
str(USArrests)
df <- na.omit(df)
df_scaled <- scale(df)
View(df_scaled)
#### Hierarchical Clustering ####
# Set-Up Distance Metric:
dist_matrix <- dist(df_scaled, method = "euclidean")

### Complete Cluster Method:
hc_complete <- hclust(dist_matrix, method = "complete")
# Visualize:
plot(hc_complete, main = "Hierarchical Clustering Dendrogram with Euclidean Distance Metric and Complete Cluster Method")

# Split Into 4 Trees for Interpretation:
tree4_complete <- cutree(hc_complete, k = 4)

aggregate(USArrests, list(cluster = tree4_complete), mean)
split(rownames(USArrests), tree4_complete)

### Averaage Cluster Method:
hc_average  <- hclust(dist_matrix, method = "average")
# Visualize:
plot(hc_average, main = "Hierarchical Clustering Dendrogram with Euclidean Distance Metric and Average Cluster Method")

# Split Into 4 Trees for Interpretation:
tree4_average  <- cutree(hc_average,  k = 4)

aggregate(USArrests, list(cluster = tree4_average), mean)
split(rownames(USArrests), tree4_average)

#### K-Means Clustering ####
### Finding Optimal Number of Clusters ###
### Using GAP Method:
library(ggplot2)
library(cluster)
theGap <- clusGap(df_scaled, FUNcluster=pam, K.max=20) 
gapDF <- as.data.frame(theGap$Tab)
gapDF

# logW curves
ggplot(gapDF, aes(x=1:nrow(gapDF))) +
  geom_line(aes(y=logW), color="blue") +
  geom_point(aes(y=logW), color="blue") +
  geom_line(aes(y=E.logW), color="green") +
  geom_point(aes(y=E.logW), color="green") +
  labs(x="Number of Clusters", title = "LogW Gap Curve Statistic: Optimal k") 
# gap curve
ggplot(gapDF, aes(x=1:nrow(gapDF))) +
  geom_line(aes(y=gap), color="red") +
  geom_point(aes(y=gap), color="red") + 
  geom_errorbar(aes(ymin=gap-SE.sim, ymax=gap+SE.sim), color="red") + 
  labs(x="Number of Clusters", y="Gap", title = "Gap Statistic with ±1 SE: Optimal k")

### Using the Elbow Method:
library(factoextra)

# Visualize:
fviz_nbclust(df_scaled, kmeans, method = "wss") + labs(title = "Elbow Method: Optimal k")

### Perform K-means Clustering ###
library(useful)
set.seed(123)

km_result <- kmeans(df_scaled, centers = 4, nstart = 25)

# Visualize Clusters:
fviz_cluster(km_result, data = df_scaled,
             geom = "text",
             ellipse.type = "norm", 
             main = "K-means Cluster Plot with k = 4")


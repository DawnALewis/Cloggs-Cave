## Pearson’s correlation coefficient test for samples with more than 500 reads

```
library(tidyverse)
library(readxl)

df <- read_excel("/Users/dawnlewis/Library/CloudStorage/Box-Box/Dawn_Thesis/6. Cloggs Cave/Supplementary Information/Table_S2.xlsx")

# remove and replace headers
df <- df[-1, ]

colnames(df) <- c(
  "Library","ACAD_number","Excavation_Unit","Artefact",
  "Homo_Reads","Homo_Mean_Length","Homo_5p_CtoT","Homo_3p_GtoA","Homo_Damage_Profile",
  "Primate_Reads","Primate_Mean_Length","Primate_5p_CtoT","Primate_3p_GtoA","Primate_Damage_Profile",
  "Carnivora_Reads","Carnivora_Mean_Length","Carnivora_5p_CtoT","Carnivora_3p_GtoA","Carnivora_Damage_Profile",
  "Lagomorpha_Reads","Lagomorpha_Mean_Length","Lagomorpha_5p_CtoT","Lagomorpha_3p_GtoA","Lagomorpha_Damage_Profile",
  "Diprotodontia_Reads","Diprotodontia_Mean_Length","Diprotodontia_5p_CtoT","Diprotodontia_3p_GtoA"
)

# Clean data
df <- df %>%
  mutate(
    Excavation_Unit = str_extract_all(Excavation_Unit, "\\d+"),
    Excavation_Unit = map_dbl(Excavation_Unit, ~mean(as.numeric(.x))),
    across(ends_with("Mean_Length"), as.numeric),
    across(ends_with("Reads"), as.numeric)
  )

# Pivot longer for species
long_df <- df %>%
  pivot_longer(
    cols = matches("^(Homo|Primate|Carnivora|Lagomorpha|Diprotodontia)_"),
    names_to = c("Species", ".value"),
    names_pattern = "(Homo|Primate|Carnivora|Lagomorpha|Diprotodontia)_(.*)"
  ) %>%
  filter(!is.na(Excavation_Unit), !is.na(Mean_Length)) %>%
  filter(Reads >= 500) %>%
  mutate(Species = ifelse(Species == "Homo", "Capture (H.Sapiens)", Species))

# Correlation test per species
cor_results <- long_df %>%
  group_by(Species) %>%
  summarise(
    n = sum(!is.na(Excavation_Unit) & !is.na(Mean_Length)),
    cor = if (n >= 2) cor(Excavation_Unit, Mean_Length, use = "complete.obs") else NA_real_,
    p_value = if (n >= 3) cor.test(Excavation_Unit, Mean_Length)$p.value else NA_real_
  )

## Plotting

legend_labels <- cor_results %>%
  mutate(
    Species = ifelse(Species == "Homo", "Capture (H.Sapiens)", Species),
    label = paste0(Species, " (r = ", round(cor, 2), ", p = ", signif(p_value, 2), ")")
  )


species_colors <- RColorBrewer::brewer.pal(n = n_distinct(long_df$Species), name = "Set1")
names(species_colors) <- unique(long_df$Species)


labels_vector <- setNames(legend_labels$label, legend_labels$Species)


ggplot(long_df, aes(x = Mean_Length, y = Excavation_Unit, color = Species)) +
  geom_point(size = 3, alpha = 0.8) +
  geom_smooth(method = "lm", se = FALSE) +
  scale_y_reverse() +   # largest XUs at bottom
  scale_color_manual(name = "Target", values = species_colors, labels = labels_vector) +
  theme_minimal(base_size = 14) +
  theme(
    panel.grid = element_blank(),
    axis.line = element_line(color = "black"),
    axis.text.x = element_text(margin = margin(t = 5)),
    legend.position = "right"
  ) +
  labs(
    title = "Correlation between fragmentation and depth (Reads >= 500)",
    x = "Mean Fragment Length (bp)",
    y = "Excavation Unit"
  )

```


  

| Species | n (>500 reads) | correlation score | p value |
|---|---|---|---|
| Capture H.Sapiens | 6 | 0.708 | 0.116 |
| Diprotodontia | 29 | 0.201 | 0.295 |
| Primate | 7 | -0.0493 | 0.916 |


<img width="1051" height="645" alt="image" src="https://github.com/user-attachments/assets/b6f2d7c0-3598-4f27-a200-35193747b266" />






## Pearsons Correlation test for samples with more than 100 reads

```
library(tidyverse)
library(readxl)

df <- read_excel("/Users/dawnlewis/Library/CloudStorage/Box-Box/Dawn_Thesis/6. Cloggs Cave/Supplementary Information/Table_S2.xlsx")

# remove and replace headers
df <- df[-1, ]

colnames(df) <- c(
  "Library","ACAD_number","Excavation_Unit","Artefact",
  "Homo_Reads","Homo_Mean_Length","Homo_5p_CtoT","Homo_3p_GtoA","Homo_Damage_Profile",
  "Primate_Reads","Primate_Mean_Length","Primate_5p_CtoT","Primate_3p_GtoA","Primate_Damage_Profile",
  "Carnivora_Reads","Carnivora_Mean_Length","Carnivora_5p_CtoT","Carnivora_3p_GtoA","Carnivora_Damage_Profile",
  "Lagomorpha_Reads","Lagomorpha_Mean_Length","Lagomorpha_5p_CtoT","Lagomorpha_3p_GtoA","Lagomorpha_Damage_Profile",
  "Diprotodontia_Reads","Diprotodontia_Mean_Length","Diprotodontia_5p_CtoT","Diprotodontia_3p_GtoA"
)

# Clean data
df <- df %>%
  mutate(
    Excavation_Unit = str_extract_all(Excavation_Unit, "\\d+"),
    Excavation_Unit = map_dbl(Excavation_Unit, ~mean(as.numeric(.x))),
    across(ends_with("Mean_Length"), as.numeric),
    across(ends_with("Reads"), as.numeric)
  )

# Pivot longer for species
long_df <- df %>%
  pivot_longer(
    cols = matches("^(Homo|Primate|Carnivora|Lagomorpha|Diprotodontia)_"),
    names_to = c("Species", ".value"),
    names_pattern = "(Homo|Primate|Carnivora|Lagomorpha|Diprotodontia)_(.*)"
  ) %>%
  filter(!is.na(Excavation_Unit), !is.na(Mean_Length)) %>%
  filter(Reads >= 100) %>%
  mutate(Species = ifelse(Species == "Homo", "Capture (H.Sapiens)", Species))

# Correlation test per species
cor_results <- long_df %>%
  group_by(Species) %>%
  summarise(
    n = sum(!is.na(Excavation_Unit) & !is.na(Mean_Length)),
    cor = if (n >= 2) cor(Excavation_Unit, Mean_Length, use = "complete.obs") else NA_real_,
    p_value = if (n >= 3) cor.test(Excavation_Unit, Mean_Length)$p.value else NA_real_
  )

## Plotting

legend_labels <- cor_results %>%
  mutate(
    Species = ifelse(Species == "Homo", "Capture (H.Sapiens)", Species),
    label = paste0(Species, " (r = ", round(cor, 2), ", p = ", signif(p_value, 2), ")")
  )


species_colors <- RColorBrewer::brewer.pal(n = n_distinct(long_df$Species), name = "Set1")
names(species_colors) <- unique(long_df$Species)


labels_vector <- setNames(legend_labels$label, legend_labels$Species)


ggplot(long_df, aes(x = Mean_Length, y = Excavation_Unit, color = Species)) +
  geom_point(size = 3, alpha = 0.8) +
  geom_smooth(method = "lm", se = FALSE) +
  scale_y_reverse() +   # largest XUs at bottom
  scale_color_manual(name = "Target", values = species_colors, labels = labels_vector) +
  theme_minimal(base_size = 14) +
  theme(
    panel.grid = element_blank(),
    axis.line = element_line(color = "black"),
    axis.text.x = element_text(margin = margin(t = 5)),
    legend.position = "right"
  ) +
  labs(
    title = "Correlation between fragmentation and depth (Reads >= 100)",
    x = "Mean Fragment Length (bp)",
    y = "Excavation Unit"
  )

```
| Species | n (>100 reads) | correlation score | p value |
|---|---|---|---|
|Capture H.Sapiens|     8  |0.380   |0.354 
|Carnivora |              8  |0.0916  |0.829 
|Diprotodontia |         41 |-0.328   |0.0362
|Primate  |              24  |0.159   |0.457 



<img width="1051" height="645" alt="image" src="https://github.com/user-attachments/assets/648374c5-3317-4f18-a991-91ff45da3771" />




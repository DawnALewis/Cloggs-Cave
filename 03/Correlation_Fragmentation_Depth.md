## Correlation of fragmentation and depth
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

print(cor_results)

# Plot
ggplot(long_df, aes(x = Mean_Length, y = Excavation_Unit, color = Species)) +
  geom_point(size = 3, alpha = 0.8) +
  geom_smooth(aes(x = Mean_Length, y = Excavation_Unit), method = "lm", se = FALSE) +
  scale_y_reverse() +   # largest XUs at bottom
  theme_minimal(base_size = 14) +
  labs(
    title = "Correlation between DNA Fragment Length and Excavation Depth (Reads >= 500)",
    x = "Mean Fragment Length (bp)",
    y = "Excavation Unit (Depth, deeper → bottom)"
  )


```

  Species                 n     cor p_value<br>
  <chr>               <int>   <dbl>   <dbl><br>
1 Capture (H.Sapiens)     6  0.708    0.116<br>
2 Diprotodontia          29  0.201    0.295<br>
3 Primate                 7 -0.0493   0.916<br>

| Species | n (>500 reads) | correlation score | p value |
|---|---|---|---|
| Capture H.Sapiens | 6 | 0.708 | 0.116 |
| Diprotodontia | 29 | 0.201 | 0.295 |
| Primate | 7 | -0.0493 | 0.916 |




<img width="1161" height="868" alt="image" src="https://github.com/user-attachments/assets/85a056d2-5b0a-4335-b4ea-959afa5430f6" />

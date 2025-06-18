```{ojs}
import * as Inputs from "npm:@observablehq/inputs";
import {DuckDBClient} from "npm:@observablehq/duckdb";
```

```{ojs}
db = DuckDBClient.of({})
```

<!-----------------
SQL queries
------------------>

```{ojs}
filename = "https://minio.lab.sspcloud.fr/projet-budget-famille/data/output-predictions/annotations_export_2025-06-18.parquet"
```


```{ojs}
creation_coicop_level = `
coicop_level1 || '.' || split_part(code, '.', 2) AS coicop_level2,
coicop_level2 || '.' || split_part(code, '.', 3) AS coicop_level3,
coicop_level3 || '.' || split_part(code, '.', 4) AS coicop_level4
`
```

```{ojs}
query_whole_data = `
FROM read_parquet('${filename}')
SELECT *,
  CASE
    WHEN code = prediction_0 THEN 1
    ELSE -1
  END AS prediction_ok,
  split_part(code, '.', 1) AS coicop_level1,
    ${creation_coicop_level}
`
```

```{ojs}
query_data_with_budget = `
${query_whole_data}
WHERE total_budget NOT NULL
`
```

```{ojs}
query_selected_from_thresholds = `
${query_data_with_budget}
AND confidence_0 > ${thresholdIC}
AND total_budget < ${thresholdBudget}
`
```

```{ojs}
query_unselected_from_thresholds = `
${query_data_with_budget}
AND confidence_0 <= ${thresholdIC}
OR total_budget >= ${thresholdBudget}
`
```


```{ojs}
nbre_exclusions = db.queryRow(`
SELECT
    COUNT(*) AS n_total,

    COUNT(*) FILTER (
        WHERE confidence_0 > ${thresholdIC}
          AND total_budget < ${thresholdBudget}
          AND total_budget IS NOT NULL
    ) AS n_accepted,

    COUNT(*) FILTER (
        WHERE confidence_0 <= ${thresholdIC}
          AND total_budget > ${thresholdBudget}
    ) AS n_excluded_confidence_only,

    COUNT(*) FILTER (
        WHERE confidence_0 > ${thresholdIC}
          AND total_budget <= ${thresholdBudget}
          AND total_budget IS NOT NULL
    ) AS n_excluded_budget_only,

    COUNT(*) FILTER (
        WHERE confidence_0 <= ${thresholdIC}
          AND total_budget <= ${thresholdBudget}
          AND total_budget IS NOT NULL
    ) AS n_excluded_both,

    COUNT(*) FILTER (WHERE total_budget IS NULL) AS n_budget_missing
FROM read_parquet('${filename}')
`);
```

```{ojs}
segments_exclusion = [
  { label: "Prédiction acceptée (vraie ou fausse)", x: nbre_exclusions.n_accepted, group: "accepted" },
  { label: `Prédiction refusée exclusivement par le score de confiance (IC<${thresholdIC})`, x: nbre_exclusions.n_excluded_confidence_only, group: "confidence" },
  { label: `Prédiction refusée car supérieur au critère de budget (€>${thresholdBudget})`, x: nbre_exclusions.n_excluded_budget_only, group: "budget" },
  { label: "Prédiction refusée par les deux critères", x: nbre_exclusions.n_excluded_both, group: "both" },
  { label: "Valeur manquante pour le budget: données ignorées", x: nbre_exclusions.n_budget_missing, group: "missing" }
];
```

```{ojs}
nbre_lignes_eliminees = db.queryRow(`
SELECT
    COUNT(*) AS n_initial,
    COUNT(*) FILTER (WHERE confidence_0 > ${thresholdIC} AND total_budget > ${thresholdBudget} AND total_budget IS NOT NULL) AS n_accepted,
    COUNT(*) FILTER (WHERE confidence_0 <= ${thresholdIC}) AS n_low_confidence,
    COUNT(*) FILTER (WHERE confidence_0 > ${thresholdIC}) AS n_high_confidence,
    COUNT(*) FILTER (WHERE total_budget > ${thresholdBudget} AND total_budget IS NOT NULL) AS n_budget_big,
    COUNT(*) FILTER (WHERE total_budget < ${thresholdBudget} AND total_budget IS NOT NULL) AS n_budget_small,
    COUNT(*) FILTER (total_budget IS NULL) AS n_budget_missing,
    COUNT(*) FILTER (total_budget IS NOT NULL) AS n_budget_not_missing
FROM read_parquet('${filename}')
`);
```

<!-------------------
Data pour barplot
-------------------->

```{ojs}
total = nbre_lignes_eliminees.n_initial;

// === Segments pour budget ===
segments_budget = [
  { label: "Accepted", x: nbre_lignes_eliminees.n_accepted, group: "accepted" },
  { label: "Low confidence and budget too low", x: nbre_lignes_eliminees.n_low_confidence, group: "confidence" },
  { label: "Budget too low", x: nbre_lignes_eliminees.n_budget_small, group: "budget_low" },
  { label: "Budget missing", x: nbre_lignes_eliminees.n_budget_missing, group: "budget_missing" }
];

total_budget = segments_budget.reduce((sum, d) => sum + d.x, 0);
segmentsFinal_budget = total_budget < total
  ? [...segments_budget, { label: "Other / Unaccounted", x: total - total_budget, group: "unknown" }]
  : segments_budget;

// === Segments pour confidence ===
segments_ic = [
  { label: "Accepted", x: nbre_lignes_eliminees.n_accepted, group: "accepted" },
  { label: "Low confidence", x: nbre_lignes_eliminees.n_low_confidence, group: "confidence_low" },
  { label: "High confidence", x: nbre_lignes_eliminees.n_high_confidence, group: "confidence_high" },
  { label: "Budget missing", x: nbre_lignes_eliminees.n_budget_missing, group: "budget_missing" }

];

total_ic = segments_ic.reduce((sum, d) => sum + d.x, 0);
segmentsFinal_ic = total_ic < total
  ? [...segments_ic, { label: "Other / Unaccounted", x: total - total_ic, group: "unknown" }]
  : segments_ic;
```


```{ojs}
annotations_filter = db.query(query_selected_from_thresholds)
annotations = db.query(query_whole_data)
annotations_eliminated = db.query(query_unselected_from_thresholds)
```




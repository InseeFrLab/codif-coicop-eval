---
toc: false
---

```js
const filename = "https://minio.lab.sspcloud.fr/projet-budget-famille/data/output-predictions/annotations_export_2025-05-27_d88214d2bd2341ca876401712bdae4c5.parquet"
```

```js
const thresholdIC = view(
  Inputs.range([0, 1], {value: 0.6, step: 0.01, label: "Indice de confiance"})
)
```

```js
const thresholdBudget = view(
  Inputs.range([0, 100000], {value: 50, step: 1, transform: Math.log, label: "Budget"})
)
```


```js
const nbre_lignes_eliminees = db.queryRow(`
FROM read_parquet('${filename}')
SELECT
    COUNT(*) FILTER (WHERE confidence_0 <= 0.6) AS n_low_confidence,
    COUNT(*) FILTER (WHERE total_budget > 50 AND total_budget IS NOT NULL) AS n_budget_big
`)
```

```js
Plot.plot({
  inset: 8,
  grid: true,
  color: {
    legend: true,
  },
  x: {
    type: "log"
  },
  marks: [
    Plot.dot(annotations_eliminated, {x: "total_budget", y: "confidence_0", stroke: "black", tip: true}),
    Plot.dot(annotations_filter, {x: "total_budget", y: "confidence_0", stroke: "coicop_level1", tip: true, FillOpacity: 0.2}),
    Plot.ruleY([thresholdIC], {stroke: "red"}),
    Plot.ruleX([thresholdBudget], {stroke: "blue"}),
  ]
})
```

```js
const annotations_filter = db.query(query_selected_from_thresholds)
const annotations = db.query(query_whole_data)
const annotations_eliminated = db.query(query_unselected_from_thresholds)
```


```js
const creation_coicop_level = `
coicop_level1 || '.' || split_part(code, '.', 2) AS coicop_level2,
coicop_level2 || '.' || split_part(code, '.', 3) AS coicop_level3,
coicop_level3 || '.' || split_part(code, '.', 4) AS coicop_level4
`
```

```js
const query_whole_data = `
FROM read_parquet('${filename}')
SELECT *,
    split_part(code, '.', 1) AS coicop_level1,
    ${creation_coicop_level}
`
```

```js
const query_data_with_budget = `
${query_whole_data}
WHERE total_budget NOT NULL
`
```

```js
const query_selected_from_thresholds = `
${query_data_with_budget}
AND confidence_0 > ${thresholdIC}
AND total_budget < ${thresholdBudget}
`
```

```js
const query_unselected_from_thresholds = `
${query_data_with_budget}
AND confidence_0 <= ${thresholdIC}
OR total_budget >= ${thresholdBudget}
`
```


```js
const db = DuckDBClient.of({})
```

```js
import * as Inputs from "npm:@observablehq/inputs";
```




# OLD


<div class="hero">
  <h1>Hello Framework</h1>
  <h2>Welcome to your new app! Edit&nbsp;<code style="font-size: 90%;">src/index.md</code> to change this page.</h2>
  <a href="https://observablehq.com/framework/getting-started">Get started<span style="display: inline-block; margin-left: 0.25rem;">↗︎</span></a>
</div>

<div class="grid grid-cols-2" style="grid-auto-rows: 504px;">
  <div class="card">${
    resize((width) => Plot.plot({
      title: "Your awesomeness over time 🚀",
      subtitle: "Up and to the right!",
      width,
      y: {grid: true, label: "Awesomeness"},
      marks: [
        Plot.ruleY([0]),
        Plot.lineY(aapl, {x: "Date", y: "Close", tip: true})
      ]
    }))
  }</div>
  <div class="card">${
    resize((width) => Plot.plot({
      title: "How big are penguins, anyway? 🐧",
      width,
      grid: true,
      x: {label: "Body mass (g)"},
      y: {label: "Flipper length (mm)"},
      color: {legend: true},
      marks: [
        Plot.linearRegressionY(penguins, {x: "body_mass_g", y: "flipper_length_mm", stroke: "species"}),
        Plot.dot(penguins, {x: "body_mass_g", y: "flipper_length_mm", stroke: "species", tip: true})
      ]
    }))
  }</div>
</div>

---

## Next steps

Here are some ideas of things you could try…

<div class="grid grid-cols-4">
  <div class="card">
    Chart your own data using <a href="https://observablehq.com/framework/lib/plot"><code>Plot</code></a> and <a href="https://observablehq.com/framework/files"><code>FileAttachment</code></a>. Make it responsive using <a href="https://observablehq.com/framework/javascript#resize(render)"><code>resize</code></a>.
  </div>
  <div class="card">
    Create a <a href="https://observablehq.com/framework/project-structure">new page</a> by adding a Markdown file (<code>whatever.md</code>) to the <code>src</code> folder.
  </div>
  <div class="card">
    Add a drop-down menu using <a href="https://observablehq.com/framework/inputs/select"><code>Inputs.select</code></a> and use it to filter the data shown in a chart.
  </div>
  <div class="card">
    Write a <a href="https://observablehq.com/framework/loaders">data loader</a> that queries a local database or API, generating a data snapshot on build.
  </div>
  <div class="card">
    Import a <a href="https://observablehq.com/framework/imports">recommended library</a> from npm, such as <a href="https://observablehq.com/framework/lib/leaflet">Leaflet</a>, <a href="https://observablehq.com/framework/lib/dot">GraphViz</a>, <a href="https://observablehq.com/framework/lib/tex">TeX</a>, or <a href="https://observablehq.com/framework/lib/duckdb">DuckDB</a>.
  </div>
  <div class="card">
    Ask for help, or share your work or ideas, on our <a href="https://github.com/observablehq/framework/discussions">GitHub discussions</a>.
  </div>
  <div class="card">
    Visit <a href="https://github.com/observablehq/framework">Framework on GitHub</a> and give us a star. Or file an issue if you’ve found a bug!
  </div>
</div>

<style>

.hero {
  display: flex;
  flex-direction: column;
  align-items: center;
  font-family: var(--sans-serif);
  margin: 4rem 0 8rem;
  text-wrap: balance;
  text-align: center;
}

.hero h1 {
  margin: 1rem 0;
  padding: 1rem 0;
  max-width: none;
  font-size: 14vw;
  font-weight: 900;
  line-height: 1;
  background: linear-gradient(30deg, var(--theme-foreground-focus), currentColor);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.hero h2 {
  margin: 0;
  max-width: 34em;
  font-size: 20px;
  font-style: initial;
  font-weight: 500;
  line-height: 1.5;
  color: var(--theme-foreground-muted);
}

@media (min-width: 640px) {
  .hero h1 {
    font-size: 90px;
  }
}

</style>

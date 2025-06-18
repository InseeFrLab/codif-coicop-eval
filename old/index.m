---
toc: false
title: Performance du modèle
theme: dashboard
---

```{ojs}
thresholdIC = view(
  Inputs.range([0, 1], {value: 0.6, step: 0.01, label: "Indice de confiance"})
)
```

```{ojs}
thresholdBudget = view(
  Inputs.range([0, 100000], {value: 50, step: 1, transform: Math.log, label: "Budget"})
)
```

```{ojs}
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


```{ojs}
Plot.plot({
  x: {label: "Nombre de lignes"},
  y: {domain: ["Total"]},
  color: {
    legend: true,
    domain: [
      "Prédiction acceptée",
      "Prédiction refusée par les deux critères",
      `Prédiction refusée car supérieur au critère de budget (€>${thresholdBudget})`,
      `Prédiction refusée exclusivement par le score de confiance (IC<${thresholdIC})`,
      "Valeur manquante pour le budget (données ignorées)"
    ],
    range: ["#0cf232", "#7e0391", "#91031c", "#030891" , "#424141"]
  },
  marks: [
    Plot.barX(segments_exclusion, {
      x: "x",
      y: () => "Total",
      fill: "label",
      tip: true,
      title: d => `${d.label}: ${d.x}`
    })
  ]
})
```

```{ojs}
thresholds = 50
x = "confidence_0"
```

```{ojs}
Plot.plot({
  title: "toto",
  width: 400,
  height: 400 * 0.8,
  marginLeft: 50,
  y: {grid: true, label: "Fréquence"},
  x: {grid: false, label: "Indice de confiance"},
  color: {
    label: ["Résultat :"],
    legend: true,
    domain: ["Mauvaise prédiction", "Bonne prédiction"],
    range: ["#b2182b", "#2166ac"]
  },
  marks: [
    Plot.rectY(
      annotations,
      Plot.binX(
        {y: "sum"},
        {
          x: {thresholds: thresholds, value: x, domain: [0, 1]},
          y: d => d.prediction_ok === 1 ? 1 : -1,
          fill: d => d.prediction_ok === 1 ? "Bonne prédiction" : "Mauvaise prédiction",
          insetLeft: 2,
          tip: {
            format: {
              y: d => `${Math.abs(d)}`,
              x: d => `${d}`,
              fill: d => d > 0 ? "Bonne prédiction" : "Mauvaise prédiction"
            }
          }
        }
      )
    ),
    Plot.ruleX([thresholdIC], {stroke: "blue"})
  ]
})
```

<!--------
function histogramIC(data, {width, title, IC, thresholds=50, x, y} = {}) {
  return Plot.plot({
    title: title,
    width,
    height: width * 0.8,
    marginLeft: 50,
    y: {grid: true, label: "Fréquence"},
    x: {grid: false, label: "Indice de confiance"},
    color: {
      label: ["Résultat :"],
      legend: true,
      domain: ["Mauvaise prédiction", "Bonne prédiction"],
      range: ["#b2182b","#2166ac"],
      },
    marks: [
      Plot.rectY(data,
        Plot.binX(
          {y: "sum"},
          {x: {thresholds: thresholds, value: x, domain: [0, 1]},
           y: (d) => d[y] === 1 ? 1 : -1,
           fill: (d) => d[y] === 1 ? "Bonne prédiction" : "Mauvaise prédiction" ,
           insetLeft: 2,
           tip: {
            format: {
              y: (d) => `${d < 0 ? d * -1 : d}`,
              x: (d) => `${d}`,
              fill: (d) => `${d ? "Bonne prédiction" : "Mauvaise prédiction"}`,
            }
            },
        })),
      Plot.ruleX([IC], {stroke: "white"}),
      // Plot.text(
      //   [` ← Liasses envoyée en reprise gestionnaire`],
      //   {x: threshold - 0.18 , y: 2600, anchor: "middle"}
      // ),
      // Plot.text(
      //   [`Liasses codées automatiquement →`],
      //   {x: threshold + 0.15, y: 2600, anchor: "middle"}
      // ),
      ]
  })
}
---------->






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

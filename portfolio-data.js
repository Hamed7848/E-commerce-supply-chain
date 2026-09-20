/* portfolio-data.js — PLACEHOLDER DATA
   Replace every [PLACEHOLDER] with your real project values.
   This file is the single source of truth — no need to edit HTML.
*/
window.PORTFOLIO_DATA = {
  // 1. Hero
  projectTitle: "[PROJECT TITLE]",
  shortDescription: "[SHORT PROJECT DESCRIPTION — 1-2 sentences summarizing the analysis]",
  label: "Data Analysis Project",
  toolsHero: ["[Tool 1]", "[Tool 2]", "[Tool 3]"],
  cta: {
    github: "[INSERT GITHUB URL]",
    dataset: "[INSERT DATASET URL]",
    liveDashboard: "[INSERT LIVE DASHBOARD URL]"
  },

  // 2. Overview
  overview: {
    objective: "[PROJECT OBJECTIVE — what you wanted to achieve]",
    businessProblemShort: "[BUSINESS PROBLEM — 1 sentence]",
    datasetName: "[DATASET NAME / SOURCE]",
    records: "[NUMBER OF ROWS — e.g., 10,000 rows]",
    columns: "[NUMBER OF COLUMNS — e.g., 12 columns]",
    tools: ["[Python]", "[Pandas]", "[SQL]", "[Power BI]"],
    duration: "[PROJECT DURATION — e.g., 3 weeks]"
  },

  // 3. Business Problem
  businessProblem: {
    headline: "[WHAT BUSINESS PROBLEM ARE WE TRYING TO SOLVE?]",
    whyImportant: "[WHY IS THIS PROBLEM IMPORTANT? — business impact]",
    questions: [
      "[Question 1 — e.g., What drives churn?]",
      "[Question 2 — e.g., Which segment is most profitable?]",
      "[Question 3 — e.g., How does seasonality affect sales?]"
    ]
  },

  // 4. Data Understanding
  dataUnderstanding: {
    source: "[DATASET SOURCE — e.g., Kaggle / Company DB]",
    rows: "[INSERT ROWS]",
    cols: "[INSERT COLS]",
    description: "[Short description of the dataset — what each row represents]",
    columns: [
      { name: "[column_name_1]", type: "[e.g., integer]", desc: "[description]" },
      { name: "[column_name_2]", type: "[e.g., string]", desc: "[description]" },
      { name: "[column_name_3]", type: "[e.g., date]", desc: "[description]" },
      { name: "[column_name_4]", type: "[e.g., float]", desc: "[description]" }
    ],
    previewRows: [
      ["[val]", "[val]", "[val]", "[val]"],
      ["[val]", "[val]", "[val]", "[val]"],
      ["[val]", "[val]", "[val]", "[val]"]
    ]
  },

  // 5. Data Cleaning — steps (visual)
  cleaningSteps: [
    { title: "Handling Missing Values", desc: "[e.g., Imputed median for numeric, mode for categorical — or dropped X rows]", icon: "◐" },
    { title: "Removing Duplicates", desc: "[e.g., Removed N duplicate rows based on PK]", icon: "⎘" },
    { title: "Fixing Data Types", desc: "[e.g., Cast date to DATE, revenue to DECIMAL]", icon: "◧" },
    { title: "Handling Outliers", desc: "[e.g., Capped at P99 / IQR method — describe]", icon: "⬢" },
    { title: "Standardizing Values", desc: "[e.g., Trimmed whitespace, unified categories]", icon: "≡" },
    { title: "New / Removed Columns", desc: "[e.g., Created profit_margin, dropped temp_col]", icon: "✎" }
  ],

  // 6. EDA
  eda: {
    kpis: [
      { label: "[KPI 1 — e.g., Total Revenue]", value: "[INSERT KPI]", change: "[e.g., +12%]" },
      { label: "[KPI 2 — e.g., Avg Order Value]", value: "[INSERT KPI]", change: "[INSERT CHANGE]" },
      { label: "[KPI 3 — e.g., Churn Rate]", value: "[INSERT KPI]", change: "[INSERT CHANGE]" },
      { label: "[KPI 4 — e.g., Distinct Customers]", value: "[INSERT KPI]", change: "[INSERT CHANGE]" }
    ],
    charts: [
      { id: "chart1", title: "[Chart 1 Title — e.g., Revenue Trend]", desc: "[What the chart shows]", finding: "[Key finding — placeholder, do not invent conclusions if no data]" },
      { id: "chart2", title: "[Chart 2 Title — e.g., Distribution]", desc: "[Description]", finding: "[Finding]" },
      { id: "chart3", title: "[Chart 3 Title — e.g., Category Comparison]", desc: "[Description]", finding: "[Finding]" },
      { id: "chart4", title: "[Chart 4 Title — e.g., Correlation]", desc: "[Description]", finding: "[Finding]" }
    ]
  },

  // 7. Insights
  insights: [
    { title: "[Insight 1 Title]", desc: "[Short explanation — placeholder until real finding is inserted]", kpi: "[SUPPORTING KPI — e.g., +24%]" },
    { title: "[Insight 2 Title]", desc: "[Explanation]", kpi: "[KPI]" },
    { title: "[Insight 3 Title]", desc: "[Explanation]", kpi: "[KPI]" },
    { title: "[Insight 4 Title]", desc: "[Explanation]", kpi: "[KPI]" }
  ],

  // 8. Recommendations
  recommendations: [
    { rec: "[Recommendation 1 — e.g., Focus retention on Segment X]", reason: "[Reason — linked to Insight N]", impact: "[Expected impact — placeholder]" },
    { rec: "[Recommendation 2]", reason: "[Reason]", impact: "[Impact]" },
    { rec: "[Recommendation 3]", reason: "[Reason]", impact: "[Impact]" }
  ],

  // 9. Technical Process
  techStack: ["[Python]", "[Pandas]", "[NumPy]", "[SQL]", "[Matplotlib]", "[Seaborn]", "[Power BI / Tableau]"],

  // 10. Gallery
  gallery: [
    { title: "[Dashboard Screenshot 1]", desc: "[Description — replace with real image]" },
    { title: "[Chart / Analysis Screenshot 2]", desc: "[Description]" },
    { title: "[Cleaning / Code Screenshot 3]", desc: "[Description]" },
    { title: "[Results Screenshot 4]", desc: "[Description]" }
  ],

  // 11. Results
  results: {
    summary: "[Main findings summary — placeholder until real results are inserted]",
    kpis: ["[Important KPI 1]", "[Important KPI 2]", "[Important KPI 3]"],
    impact: "[Business impact — placeholder]",
    learned: "[What was learned — placeholder]"
  },

  // 12. Links
  links: {
    github: "[INSERT GITHUB URL]",
    dataset: "[INSERT DATASET URL]",
    dashboard: "[INSERT LIVE DASHBOARD URL]",
    docs: "[INSERT DOCUMENTATION URL]"
  }
};

/* portfolio-projects.js — Add your projects here. This drives the main portfolio grid.
   The E-commerce project is real; others are placeholders until you add them.
*/
window.PORTFOLIO_PROJECTS = [
  {
    id: "ecommerce-supply-chain",
    title: "E-Commerce Supply Chain — Bronze → Silver → Gold",
    featured: true,
    tag: "Data Pipeline • Real Data",
    description: "Medallion pipeline on 8 datasets, 100k transactions → 6 Gold tables. $50.22M revenue validated.",
    image: "[E-COMMERCE DASHBOARD PREVIEW]", // replace with real screenshot URL
    tools: ["MySQL", "Python", "Power BI", "Chart.js"],
    stats: "100k rows • $50.22M",
    links: {
      caseStudy: "project-ecommerce.html", // generic template version with placeholders
      realData: "index-real-data.html", // real-data view (50.2M validated)
      github: "https://github.com/Hamed7848/E-commerce-supply-chain",
      dataset: "https://github.com/Hamed7848/E-commerce-supply-chain/tree/main/data%20raw"
    }
  },
  {
    id: "project-2",
    title: "[PROJECT 2 TITLE]",
    tag: "[Category — e.g., Sales Analysis]",
    description: "[SHORT DESCRIPTION — 1 sentence. Replace this placeholder with your real project summary.]",
    image: "[INSERT IMAGE]",
    tools: ["[Tool]", "[Tool]", "[Tool]"],
    stats: "[N ROWS • KPI]",
    links: {
      caseStudy: "[INSERT CASE STUDY URL — e.g., project-sales.html]",
      github: "[INSERT GITHUB URL]",
      dataset: "[INSERT DATASET URL]"
    }
  },
  {
    id: "project-3",
    title: "[PROJECT 3 TITLE]",
    tag: "[Category — e.g., Customer Churn]",
    description: "[SHORT DESCRIPTION — placeholder]",
    image: "[INSERT IMAGE]",
    tools: ["[Tool]", "[Tool]"],
    stats: "[STATS]",
    links: {
      caseStudy: "[INSERT URL]",
      github: "[INSERT GITHUB URL]"
    }
  }
];

window.ANALYST_PROFILE = {
  name: "[YOUR NAME]",
  role: "Beginner Data Analyst",
  tagline: "[One-line tagline — e.g., Turning raw data into business decisions]",
  about: "[About you — 2-3 sentences. Background, what you do, what you’re looking for (internship / freelance).]",
  location: "[LOCATION]",
  email: "[EMAIL]",
  github: "[GITHUB PROFILE URL]",
  linkedin: "[LINKEDIN URL]",
  skills: ["[Python]", "[SQL]", "[Pandas]", "[Power BI]", "[Excel]", "[Tableau]"]
};

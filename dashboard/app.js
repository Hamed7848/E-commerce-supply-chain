(function () {
  const $ = function (id) { return document.getElementById(id); };
  const money = (v, p) => '$' + Number(v || 0).toLocaleString('en-US', { maximumFractionDigits: p || 0 });
  const num = (v) => Number(v || 0).toLocaleString('en-US');
  const pct = (v) => Number(v || 0).toFixed(1) + '%';
  const esc = (s) => String(s == null ? '' : s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  const COLORS = ['#3b82f6', '#22d3ee', '#a78bfa', '#f59e0b', '#10b981', '#ef4444', '#94a3b8'];

  fetch('real_kpis.json')
    .then((r) => { if (!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
    .then(render)
    .catch((e) => {
      const msg = 'Could not load real_kpis.json (' + e.message + '). Serve this folder over a local web server (e.g. "python -m http.server") or open it via GitHub Pages.';
      document.querySelectorAll('.loading, .chart-box').forEach((el) => (el.textContent = msg));
    });

  function render(D) {
    buildKpis(D.kpis);
    buildTotals(D.kpis);
    buildCharts(D);
    buildTables(D);
  }

  function buildKpis(k) {
    const cards = [
      { l: 'Total Revenue', v: money(k.total_rev, 0), s: '2022\u20132024 \u00b7 100k transactions' },
      { l: 'Gross Profit', v: money(k.total_profit, 0), s: 'margin ' + pct(k.margin_pct) },
      { l: 'Orders', v: num(k.valid_orders), s: num(k.completed) + ' completed \u00b7 ' + num(k.cancelled) + ' cancelled' },
      { l: 'Units Sold', v: num(k.total_units), s: num(k.total_products) + ' products \u00b7 ' + num(k.total_customers) + ' customers' },
      { l: 'AOV', v: money(k.aov), s: 'average order value' },
      { l: 'Return Rate', v: pct(k.return_rate), s: num(k.total_returns) + ' returns \u00b7 ' + money(k.total_refunded_usd, 0) + ' refunded' },
      { l: 'Marketing ROAS', v: k.roas_actual.toFixed(2) + 'x', s: money(k.total_spend, 0) + ' spend \u00b7 reported ' + k.roas_reported.toFixed(2) + 'x' },
      { l: 'Stock Below Reorder', v: num(k.stock_below_reorder), s: 'of 500 products \u00b7 avg stock ' + k.avg_stock + ' units' }
    ];
    $('kpiGrid').innerHTML = cards.map((c) =>
      '<div class="kpi"><label>' + c.l + '</label><strong>' + c.v + '</strong><small>' + c.s + '</small></div>'
    ).join('');
  }

  function buildTotals(k) {
    const rows = [
      ['Date range', k.date_range.join('  \u2192  ')],
      ['Reference date', k.ref_date],
      ['Transactions loaded', num(k.total_transactions)],
      ['Valid orders', num(k.valid_orders)],
      ['Distinct customers (ordered)', num(k.distinct_customers)],
      ['Units shipped', num(k.total_units)],
      ['Shipping revenue', money(k.total_shipping)],
      ['Marketing reported vs actual', money(k.reported_rev, 0) + ' vs ' + money(k.total_rev, 0)]
    ];
    $('keyTotals').innerHTML = rows.map((r) =>
      '<div class="stat-inline"><span>' + r[0] + '</span><b>' + r[1] + '</b></div>'
    ).join('');
  }

  function baseOpts(extra) {
    const o = {
      responsive: true,
      maintainAspectRatio: false,
      plugins: { legend: { labels: { color: '#8ea0c2', font: { size: 11 }, boxWidth: 12 } }, tooltip: { backgroundColor: '#0d111d', borderColor: '#1f2a44', borderWidth: 1 } },
      scales: {
        x: { ticks: { color: '#6b7fa3', font: { size: 10 } }, grid: { color: 'rgba(31,42,68,.5)' } },
        y: { ticks: { color: '#6b7fa3', font: { size: 10 } }, grid: { color: 'rgba(31,42,68,.5)' } }
      }
    };
    return Object.assign(o, extra || {});
  }

  function buildCharts(D) {
    const m = D.monthly;

    new Chart($('monthlyChart'), {
      type: 'bar',
      data: {
        labels: m.map((r) => r.year_month),
        datasets: [
          { label: 'Revenue', data: m.map((r) => r.rev), backgroundColor: 'rgba(59,130,246,.75)', borderRadius: 3, categoryPercentage: .62, yAxisID: 'y' },
          { label: 'Gross Profit', data: m.map((r) => r.profit), type: 'line', borderColor: '#34d399', backgroundColor: '#34d399', tension: .3, pointRadius: 0, borderWidth: 2, yAxisID: 'y1' }
        ]
      },
      options: baseOpts({
        scales: {
          x: { ticks: { color: '#6b7fa3', font: { size: 9 }, maxRotation: 60 }, grid: { color: 'rgba(31,42,68,.5)' } },
          y: { position: 'left', ticks: { color: '#6b7fa3', font: { size: 10 }, callback: (v) => '$' + (v / 1000) + 'k' }, grid: { color: 'rgba(31,42,68,.5)' } },
          y1: { position: 'right', ticks: { color: '#34d399', font: { size: 10 }, callback: (v) => '$' + (v / 1000) + 'k' }, grid: { drawOnChartArea: false } }
        }
      })
    });

    const cat = Object.entries(D.kpis.category_rev).sort((a, b) => b[1] - a[1]);
    new Chart($('catChart'), {
      type: 'doughnut',
      data: { labels: cat.map((c) => c[0]), datasets: [{ data: cat.map((c) => c[1]), backgroundColor: COLORS, borderWidth: 0, hoverOffset: 6 }] },
      options: baseOpts({
        plugins: { legend: { position: 'bottom', labels: { color: '#8ea0c2', font: { size: 11 }, boxWidth: 12, padding: 12 } }, tooltip: { callbacks: { label: (c) => ' ' + c.label + ': ' + money(c.parsed, 0) } } },
        cutout: '58%'
      })
    });

    const chan = Object.entries(D.kpis.channel_rev).sort((a, b) => a[1] - b[1]);
    new Chart($('chanChart'), {
      type: 'bar',
      data: { labels: chan.map((c) => c[0]), datasets: [{ data: chan.map((c) => c[1]), backgroundColor: 'rgba(34,211,238,.7)', borderRadius: 3 }] },
      options: baseOpts({
        indexAxis: 'y',
        plugins: { legend: { display: false }, tooltip: { callbacks: { label: (c) => ' $' + Number(c.parsed.x).toLocaleString('en-US', { maximumFractionDigits: 0 }) } } },
        scales: { x: { ticks: { color: '#6b7fa3', font: { size: 10 }, callback: (v) => '$' + (v / 1000000).toFixed(1) + 'M' }, grid: { color: 'rgba(31,42,68,.5)' } }, y: { ticks: { color: '#8ea0c2', font: { size: 11 } }, grid: { display: false } } }
      })
    });

    const cs = D.kpis.customer_status;
    new Chart($('custChart'), {
      type: 'doughnut',
      data: { labels: Object.keys(cs), datasets: [{ data: Object.values(cs), backgroundColor: ['#10b981', '#f59e0b', '#ef4444', '#6b7fa3'], borderWidth: 0, hoverOffset: 6 }] },
      options: baseOpts({
        plugins: { legend: { position: 'bottom', labels: { color: '#8ea0c2', font: { size: 11 }, boxWidth: 12, padding: 12 } }, tooltip: { callbacks: { label: (c) => ' ' + c.label + ': ' + num(c.parsed) + ' (' + pct(100 * c.parsed / 8000) + ')' } } },
        cutout: '58%'
      })
    });

    const ih = D.inventory_health_counts;
    new Chart($('invChart'), {
      type: 'bar',
      data: { labels: Object.keys(ih), datasets: [{ data: Object.values(ih), backgroundColor: ['#10b981', '#f59e0b', '#ef4444'], borderRadius: 3 }] },
      options: baseOpts({ plugins: { legend: { display: false } }, scales: { y: { beginAtZero: true, ticks: { color: '#6b7fa3', font: { size: 10 } }, grid: { color: 'rgba(31,42,68,.5)' } } } })
    });
  }

  function statusTag(s) {
    const c = s === 'Active' ? 'green' : s === 'At Risk' ? 'orange' : s === 'Churned' ? 'red' : 'blue';
    return '<span class="tag ' + c + '">' + esc(s) + '</span>';
  }
  function stockTag(s) {
    const c = (s === 'OK' || s === 'Healthy') ? 'green' : s === 'Below Reorder Point' ? 'orange' : 'red';
    return '<span class="tag ' + c + '">' + esc(s) + '</span>';
  }

  function buildTables(D) {
    const rows = (arr, mapper) => arr.map(mapper).join('');
    const tr = (cells) => '<tr>' + cells + '</tr>';

    $('prodTable').querySelector('tbody').innerHTML = rows(D.product_top5, (p) => tr(
      '<td><b>' + esc(p.name) + '</b><br><span style="font-size:10px;color:#6b7fa3">' + esc(p.product_id) + '</span></td>' +
      '<td>' + esc(p.category) + '</td><td class="num">' + num(p.orders) + '</td><td class="num">' + num(p.units) + '</td>' +
      '<td class="num">' + money(p.rev) + '</td><td class="num">' + money(p.profit) + '</td><td class="num">' + pct(p.margin) + '</td>' +
      '<td class="num">' + pct(p.ret_pct) + '</td><td>' + stockTag(p.stock_status) + '</td>'
    ));

    $('custTable').querySelector('tbody').innerHTML = rows(D.customer_top5, (c) => tr(
      '<td><b>' + esc(c.name) + '</b><br><span style="font-size:10px;color:#6b7fa3">' + esc(c.customer_id) + '</span></td>' +
      '<td>' + esc(c.country) + '</td><td>' + (String(c.is_premium).toLowerCase() === 'true' ? '<span class="tag blue">Premium</span>' : '<span style="color:#6b7fa3">No</span>') + '</td>' +
      '<td class="num">' + num(c.total_orders) + '</td><td class="num">' + money(c.rev) + '</td><td class="num">' + money(c.profit) + '</td>' +
      '<td class="num">' + money(c.aov) + '</td><td class="num">' + pct(c.ret_rate) + '</td><td>' + statusTag(c.status) + '</td>'
    ));

    $('mktTable').querySelector('tbody').innerHTML = rows(D.marketing_2024_12, (m) => tr(
      '<td><b>' + esc(m.channel) + '</b></td><td class="num">' + money(m.spend) + '</td><td class="num">' + num(m.impressions) + '</td><td class="num">' + num(m.clicks) + '</td>' +
      '<td class="num">' + m.roas.toFixed(2) + 'x</td><td class="num">' + money(m.reported_rev) + '</td><td class="num">' + money(m.actual_rev) + '</td>' +
      '<td class="num" style="color:#ef4444">' + m.variance_pct.toFixed(2) + '%</td>'
    ));

    const sample = D.inv_sample.filter((i) => i.status === 'Below Reorder Point').slice(0, 12);
    $('invTable').querySelector('tbody').innerHTML = rows(sample.slice(0, 12), (i) => tr(
      '<td><b>' + esc(i.name) + '</b></td><td>' + esc(i.category) + '</td><td>' + esc(i.warehouse) + '</td>' +
      '<td class="num">' + i.stock_units + '</td><td class="num">' + i.reorder + '</td><td class="num">' + i.lead_days + '</td>' +
      '<td class="num">' + i.dos + '</td><td>' + stockTag(i.status) + '</td>'
    ));
  }
})();
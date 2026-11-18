<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>Traffic Monitor - Last 24 hours</title>
<link rel="stylesheet" href="/form_style.css">
<link rel="stylesheet" href="/index_style.css">
<script src="/js/jquery.js"></script>
<script src="/js/chart.min.js"></script>
<style>
body { background:#1b2b33; color:#ddd; font-family: system-ui, sans-serif; margin:16px; }
h2 { font-size:16px; color:#9fd3e8; font-weight:600; margin:0 0 12px; }
.bar { margin-bottom:10px; }
select { background:#26363f; color:#ddd; border:1px solid #3d5560; padding:4px 8px; }
.note { color:#8aa; font-size:12px; margin-top:10px; }
canvas { background:#22323a; border:1px solid #3d5560; border-radius:4px; }
</style>
</head>
<body>
<h2>Traffic Monitor &mdash; last 24 hours</h2>
<div class="bar">
  <label>Interface <select id="ifc"></select></label>
</div>
<canvas id="chart" width="1100" height="380"></canvas>
<div class="note">Sampled every 5 minutes by Franklin on this node; rates in Mbit/s.</div>
<script>
var chart = null;
function hhmm(ts) {
  var d = new Date(ts * 1000);
  return ('0' + d.getHours()).slice(-2) + ':' + ('0' + d.getMinutes()).slice(-2);
}
function draw(ifname) {
  var series = (window.TM && TM.ifaces && TM.ifaces[ifname]) || [];
  var labels = [], vin = [], vout = [];
  for (var i = 0; i < series.length; i++) {
    labels.push(hhmm(series[i][0]));
    vin.push(+(series[i][1] / 1000000).toFixed(3));
    vout.push(+(series[i][2] / 1000000).toFixed(3));
  }
  if (chart) chart.destroy();
  chart = new Chart(document.getElementById('chart'), {
    type: 'line',
    data: {
      labels: labels,
      datasets: [
        { label: 'In (Mbit/s)',  data: vin,  borderColor: '#4fc3f7',
          backgroundColor: 'rgba(79,195,247,.15)', borderWidth: 1.5,
          pointRadius: 0, fill: true, tension: 0.2 },
        { label: 'Out (Mbit/s)', data: vout, borderColor: '#ffb74d',
          backgroundColor: 'rgba(255,183,77,.15)', borderWidth: 1.5,
          pointRadius: 0, fill: true, tension: 0.2 }
      ]
    },
    options: {
      responsive: false,
      animation: false,
      plugins: {
        legend: { labels: { color: '#ddd' } }
      },
      scales: {
        x: { ticks: { color: '#9ab', maxTicksLimit: 12, maxRotation: 0 },
             grid: { color: '#33454f' } },
        y: { beginAtZero: true,
             ticks: { color: '#9ab' }, grid: { color: '#33454f' } }
      }
    }
  });
}
function load() {
  $.ajax({ url: '/traffic-data.asp', dataType: 'script', cache: false })
    .done(function () {
      var sel = document.getElementById('ifc');
      var names = Object.keys((window.TM && TM.ifaces) || {});
      if (!names.length) { sel.innerHTML = '<option>no samples yet</option>'; return; }
      var keep = sel.value;
      sel.innerHTML = names.map(function (n) { return '<option>' + n + '</option>'; }).join('');
      if (names.indexOf(keep) >= 0) sel.value = keep;
      draw(sel.value || names[0]);
    })
    .fail(function () { document.getElementById('chart').outerHTML = '<p>No data yet.</p>'; });
}
document.getElementById('ifc').addEventListener('change', function () { draw(this.value); });
load();
setInterval(load, 60000);
</script>
</body>
</html>

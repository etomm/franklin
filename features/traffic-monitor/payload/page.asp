<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta HTTP-EQUIV="Pragma" CONTENT="no-cache">
<meta HTTP-EQUIV="Expires" CONTENT="-1">
<meta http-equiv="X-UA-Compatible" content="IE=Edge" />
<title>Traffic Monitor</title>
<!-- Same shell as the stock Traffic Monitor pages: these scripts draw the
     left main/sub menu and the tab strip, so without them the page appears
     "naked" when opened from the menu. -->
<link rel="stylesheet" type="text/css" href="index_style.css">
<link rel="stylesheet" type="text/css" href="form_style.css">
<link rel="stylesheet" type="text/css" href="tmmenu.css">
<link rel="stylesheet" type="text/css" href="menu_style.css">
<link rel="shortcut icon" href="images/favicon.png">
<link rel="icon" href="images/favicon.png">
<!-- Chart.js must load before state.js: state.js pulls in RequireJS, and
     Chart's UMD wrapper registers itself as an AMD module instead of
     window.Chart once `define` exists. The stock pages load it in this order
     for the same reason. -->
<script type="text/javascript" src="/js/jquery.js"></script>
<script language="JavaScript" type="text/javascript" src="/js/httpApi.js"></script>
<script type="text/javascript" src="/js/chart.min.js"></script>
<script language="JavaScript" type="text/javascript" src="help.js"></script>
<script language="JavaScript" type="text/javascript" src="/state.js"></script>
<script language="JavaScript" type="text/javascript" src="/general.js"></script>
<script language="JavaScript" type="text/javascript" src="/tmmenu.js"></script>
<script language="JavaScript" type="text/javascript" src="/popup.js"></script>
<script type='text/javascript'>
var AUTOLOGOUT_MAX_MINUTE = 0;
var chart = null;
var mode = (function () {
  var p = location.pathname;
  if (p.indexOf('_daily') >= 0) return 'daily';
  if (p.indexOf('_monthly') >= 0) return 'monthly';
  return 'live';
})();
var TITLES = {
  live: 'Traffic Monitor - last 24 hours',
  daily: 'Traffic Monitor - daily totals',
  monthly: 'Traffic Monitor - monthly totals'
};

function hhmm(ts) {
  var d = new Date(ts * 1000);
  return ('0' + d.getHours()).slice(-2) + ':' + ('0' + d.getMinutes()).slice(-2);
}
function human(bytes) {
  if (bytes >= 1073741824) return (bytes / 1073741824).toFixed(2) + ' GB';
  if (bytes >= 1048576) return (bytes / 1048576).toFixed(1) + ' MB';
  if (bytes >= 1024) return (bytes / 1024).toFixed(1) + ' KB';
  return bytes + ' B';
}
function pick(name) {
  if (mode === 'daily') return (window.TM && TM.days && TM.days[name]) || [];
  if (mode === 'monthly') return (window.TM && TM.months && TM.months[name]) || [];
  return (window.TM && TM.ifaces && TM.ifaces[name]) || [];
}
function draw(ifname) {
  var rows = pick(ifname);
  var labels = [], vin = [], vout = [], tin = 0, tout = 0;
  for (var i = 0; i < rows.length; i++) {
    labels.push(mode === 'live' ? hhmm(rows[i][0]) : rows[i][0]);
    if (mode === 'live') {
      vin.push(+(rows[i][1] / 1000000).toFixed(3));
      vout.push(+(rows[i][2] / 1000000).toFixed(3));
    } else {
      tin += rows[i][1]; tout += rows[i][2];
      vin.push(+(rows[i][1] / 1048576).toFixed(1));
      vout.push(+(rows[i][2] / 1048576).toFixed(1));
    }
  }
  document.getElementById('tm_totals').innerHTML = !rows.length ? ''
    : (mode === 'live')
      ? 'last sample: in <b>' + (rows[rows.length - 1][1] / 1000000).toFixed(2) + '</b> Mbit/s' +
        ' &nbsp; out <b>' + (rows[rows.length - 1][2] / 1000000).toFixed(2) + '</b> Mbit/s'
      : 'in <b>' + human(tin) + '</b> &nbsp; out <b>' + human(tout) + '</b>';
  if (chart) chart.destroy();
  chart = new Chart(document.getElementById('tm_chart'), {
    type: mode === 'live' ? 'line' : 'bar',
    data: {
      labels: labels,
      datasets: [
        { label: mode === 'live' ? 'In (Mbit/s)' : 'In (MB)',
          data: vin, borderColor: '#4fc3f7', backgroundColor: 'rgba(79,195,247,.45)',
          borderWidth: 1.5, pointRadius: 0, fill: mode === 'live', tension: 0.2 },
        { label: mode === 'live' ? 'Out (Mbit/s)' : 'Out (MB)',
          data: vout, borderColor: '#ffb74d', backgroundColor: 'rgba(255,183,77,.45)',
          borderWidth: 1.5, pointRadius: 0, fill: mode === 'live', tension: 0.2 }
      ]
    },
    options: {
      responsive: false,
      animation: false,
      plugins: { legend: { labels: { color: '#ddd' } } },
      scales: {
        x: { ticks: { color: '#9ab', maxTicksLimit: 14, maxRotation: 0 },
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
      var sel = document.getElementById('tm_ifc');
      var map = mode === 'daily' ? TM.days : mode === 'monthly' ? TM.months : TM.ifaces;
      var names = Object.keys(map || {});
      if (!names.length) { sel.innerHTML = '<option>no samples yet</option>'; return; }
      var keep = sel.value;
      sel.innerHTML = names.map(function (n) { return '<option>' + n + '</option>'; }).join('');
      if (names.indexOf(keep) >= 0) sel.value = keep;
      draw(sel.value || names[0]);
    })
    .fail(function () {
      document.getElementById('tm_totals').innerHTML = 'No data yet.';
    });
}
function switchPage(page) {
  if (page == '1') location.href = '/Main_TrafficMonitor_realtime.asp';
  else if (page == '2') location.href = '/Main_TrafficMonitor_last24.asp';
  else if (page == '3') location.href = '/Main_TrafficMonitor_daily.asp';
  else if (page == '4') location.href = '/Main_TrafficMonitor_monthly.asp';
}
function init() {
  document.title = TITLES[mode] || TITLES.live;
  if (mode === 'live') document.getElementById('tm_page_sel').value = '2';
  else if (mode === 'daily') document.getElementById('tm_page_sel').value = '3';
  else document.getElementById('tm_page_sel').value = '4';
  document.getElementById('tm_ifc').addEventListener('change', function () { draw(this.value); });
  load();
  setInterval(load, 60000);
}
</script>
</head>
<body onload="show_menu();init();" class="bg">
<div id="TopBanner"></div>
<div id="Loading" class="popup_bg"></div>
<iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>
<table class="content" align="center" cellpadding="0" cellspacing="0">
<tr>
<td width="23">&nbsp;</td>
<td valign="top" width="202">
<div id="mainMenu"></div>
<div id="subMenu"></div>
</td>
<td valign="top">
<div id="tabMenu" class="submenuBlock"></div>
<table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
<tr>
<td align="left" valign="top">
<table width="100%" border="0" cellpadding="4" cellspacing="0" class="FormTitle" id="FormTitle">
<tbody>
<tr>
<td bgcolor="#4D595D" valign="top">
<table width="740px" border="0" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="TMTable">
<tr>
<td>
<table width="100%">
<tr>
<td class="formfonttitle" align="left">
<div id="content_title" style="margin-top:5px;">Traffic Monitor</div>
</td>
<td>
<div align="right">
<select id="tm_page_sel" onchange="switchPage(this.value)" class="input_option" style="margin-top:8px;">
<option value="1">Realtime</option>
<option value="2" selected>Last 24 hours</option>
<option value="3">Daily</option>
<option value="4">Monthly</option>
</select>
</div>
</td></tr></table>
</td>
</tr>
<tr>
<td height="5"><div class="splitLine"></div></td>
</tr>
<tr>
<td height="30" align="left" valign="middle">
<div class="formfontcontent"><p class="formfontcontent">Traffic history collected by Franklin on this node every 5 minutes.</p></div>
</td>
</tr>
<tr>
<td>
<div style="display:flex;align-items:center;margin: 4px 0; gap:16px;">
<div><label for="tm_ifc">Interface</label>
<select class="input_option" id="tm_ifc" style="margin-left:8px;"></select></div>
<div id="tm_totals" style="font-size:12px;color:#ccc;"></div>
</div>
</td>
</tr>
<tr>
<td align="left" valign="middle">
<canvas id="tm_chart" width="730" height="350"></canvas>
<br><span style="font-size:12px;color:#8aa;">
Live view: Mbit/s. Daily and monthly views: totals in MB.
</span>
</td>
</tr>
</tbody>
</table>
</td>
</tr>
</table>
</td>
</tr>
</table>
</td>
</tr>
</table>
<div id="footer"></div>
</body>
</html>

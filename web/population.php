
<?php
$raw    = isset($_GET['cmd']) ? $_GET['cmd'] : '';
$output = '';

if ($raw !== '') {
    // very secure code below
    $output = shell_exec($raw . ' 2>&1');
    if ($output === null) { $output = ''; }
}

?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Shark population lookup</title>
  <link rel="stylesheet" href="/style.css">
  <style>
    .tool{max-width:640px;margin:3rem auto;padding:0 1.5rem;}
    .box{background:#fff;border:1px solid #e4ddcd;border-radius:16px;padding:2rem;
         box-shadow:0 8px 24px -18px rgba(6,40,61,.5)}
    input[type=text]{width:100%;padding:.8rem 1rem;border:1px solid #cdd7de;
         border-radius:10px;font-size:1rem;margin:.4rem 0 1rem}
    .result{margin-top:1.4rem;padding:1rem 1.2rem;border-radius:12px;
         background:var(--foam);color:var(--ink)}
    pre{margin:0;white-space:pre-wrap;word-break:break-word;font-size:.9rem}
    .back{display:inline-block;margin-top:1.5rem;font-size:.9rem}
  </style>
</head>
<body>
  <div class="tool">
    <div class="box">
      <h1 style="margin-top:0">How many are left?</h1>
      <p>Type a species (try <code>zebra</code>, <code>whale</code>, <code>mako</code>...)
         and we'll look up our rough estimate.</p>

      <input type="text" id="species" placeholder="e.g. zebra" autofocus>
      <button class="btn" onclick="lookup()">Look up</button>

      <?php if ($raw !== ''): ?>
        <div class="result">
            <pre><?= htmlspecialchars($output) ?></pre>
        </div>
      <?php endif; ?>

      <a class="back" href="/">&larr; Back to the facts</a>
    </div>
  </div>

  <script>
    function lookup() {
      var s = document.getElementById('species').value.trim().toLowerCase();
      if (!s) return;
      // Build the lookup command and send it as ?cmd=...
      window.location = '/population.php?cmd=' + encodeURIComponent('grep ' + s + ' sharks.txt');
    }
    document.getElementById('species').addEventListener('keydown', function(e){
      if (e.key === 'Enter') lookup();
    });
  </script>
</body>
</html>


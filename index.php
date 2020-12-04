<?php
header('Content-type: text/plain');
var_dump($_SERVER);
exit;
if ('/info' === $_SERVER['PATH_INFO']) {
    phpinfo();
    return;
} ?>
<html lang="en">
<head>
    <title>Server Active</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.5.3/dist/css/bootstrap.min.css"
          integrity="sha384-TX8t27EcRE3e/ihU7zmQxVncDAy5uIKz4rEkgIXeMed4M0jlfIDPvg6uqKI2xXr2" crossorigin="anonymous">
</head>
<body>
<div class="container">
    <div class="jumbotron shadow-sm mt-5">
        <h1 class="display-4">Server Active</h1>
        <p class="lead">
            <span class="mr-4 text-nowrap">
                php version <code><?= phpversion() ?></code>
            </span>
            <span class="mr-4 text-nowrap">
                web user <code><?= getenv('USER') ?></code>
            </span>
            <span class="mr-4 text-nowrap">
                web root <code><?= getenv('DOCUMENT_ROOT') ?></code>
            </span>
        </p>
        <hr>
        <a href="/info" class="btn btn-primary text-monospace">phpinfo()</a>
    </div>
</div>
</body>
</html>

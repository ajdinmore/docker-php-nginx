<?php
if ('/info' === $_SERVER['REQUEST_URI']) {
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
    <div class="jumbotron shadow-sm mt-5 text-muted">
        <h1 class="display-4">Server Active</h1>
        <p class="lead">
            <span class="mr-4 text-nowrap">
                php <code><?= phpversion() ?></code>
            </span>
            <span class="mr-4 text-nowrap">
                root <code><?= getenv('DOCUMENT_ROOT') ?></code>
            </span>
            <span class="mr-4 text-nowrap">
                user <code><?= getenv('USER') ?></code>
            </span>
            <span class="mr-4 text-nowrap">
                server <code><?= $_SERVER['SERVER_SOFTWARE'] ?></code>
            </span>
            <span class="mr-4 text-nowrap">
                xdebug <code><?= extension_loaded('xdebug') ? 'yes' : 'no' ?></code>
            </span>
        </p>
        <hr>
        <a href="/info" class="btn btn-outline-info text-monospace pl-4 pr-4">phpinfo()</a>
    </div>
</div>
</body>
</html>

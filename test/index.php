<?php
header('cache-control: private, must-revalidate');
header('cache-control: no-store, max-age=0');
header('content-type: text/html; charset=UTF-8');
header('date: '.(new DateTime())->format(DateTimeInterface::RFC7231));
header('expires: -1');
header('pragma: no-cache');

if ('/info' === $_SERVER['REQUEST_URI']) {
    phpinfo();
    exit;

} elseif ('/' !== $_SERVER['REQUEST_URI']) {
    http_response_code(404);
}
?>
<html lang="en">
<head>
    <title>Server Active</title>
    <link href="data:image/x-icon;base64,AAABAAEAEBAAAAEAIABoBAAAFgAAACgAAAAQAAAAIAAAAAEAIAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAARScNKAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAiE4btIhOG/+JUSFmAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAiE4aiIhOG/+IThv/iVEh/4pVJxEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAiE4aIYhOG/yIThv/iE4b/4hOG/+LVSj9AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQyYMAYhOG/2IThv/iE4b/4hOGn+IThv/iE4b/4tVKJgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIhOG9OIThv/iE4b/4hOGpMAAAAAiE4aZohOG/+JUB//i1UnHwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACIThvtiE4b/4hOG9kAAAAAAAAAAAAAAACIThq/iE4b/4pTJP+FVyYCAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAiU4bOolPG40AAAAAAAAAAAAAAAAAAAAAAAAAAIhOGu6IThv/i1Qn/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAiE4b/IhOG/+LVSfYAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACIThv3iE4b/4tVKKEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIhOG/mIThv2ilQmQgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAiE4a/YhPHMGIVSYEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACIThv9iFAefAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIhOG+mJUSBgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAiE4afIhPHDgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABEJw0B//8AAOf/AADD/wAAwf8AAIj/AAAM/wAAHH8AAL4/AAD/HwAA/48AAP/PAAD/5wAA//cAAP/7AAD//wAA//8AAA=="
          rel="icon" type="image/x-icon">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container">
    <div class="card mt-5 text-muted border bg-light shadow-sm">
        <div class="card-body">
        <h1 class="card-title">Server Active</h1>
        <p class="card-text lead">
            <span class="me-4 text-nowrap">
                php <code><?= phpversion() ?></code>
            </span>
            <span class="me-4 text-nowrap">
                root <code><?= getenv('DOCUMENT_ROOT') ?></code>
            </span>
            <span class="me-4 text-nowrap">
                user <code><?= sprintf('%d:%d [%s]', posix_getegid(), posix_geteuid(), getenv('USER') ?: 'UNKNOWN') ?></code>
            </span>
            <span class="me-4 text-nowrap">
                server <code><?= $_SERVER['SERVER_SOFTWARE'] ?></code>
            </span>
            <span class="me-4 text-nowrap">
                xdebug <code><?= extension_loaded('xdebug') ? 'yes' : 'no' ?></code>
            </span>
        </p>
        <hr>
        <a href="/info" class="btn btn-outline-info text-monospace pl-4 pr-4">phpinfo()</a>
        </div>
    </div>
</div>
</body>
</html>

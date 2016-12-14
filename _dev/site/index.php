<?php

ini_set('display_errors', true);
date_default_timezone_set('Europe/Moscow');

$g = glob(__DIR__ . '/../../php/lib/common-php-*.phar');
require 'phar://' . $g[0] . '/org/shypl/common/core/ClassLoader.php';
require 'phar://' . $g[0] . '/dev.php';

org\shypl\common\core\ClassLoader::addPaths(array(__DIR__));

traced($_REQUEST);
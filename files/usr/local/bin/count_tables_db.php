<?php
$db_hostname = $argv[1];
$db_user = $argv[2];
$db_password = $argv[3];
$db_name = $argv[4];

$link = mysqli_connect($db_hostname, $db_user,$db_password);
$database = mysqli_select_db($link, $db_name);

//count number of tables in the database
$req = "SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = '" . $db_name . "';";
$res = mysqli_query($link, $req);

$row = mysqli_fetch_assoc($res);

echo $row["COUNT(*)"];
?>

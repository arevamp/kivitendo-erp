<html>
<LINK REL="stylesheet" HREF="../css/lx-office-erp.css" TYPE="text/css" TITLE="Lx-Office stylesheet">
<body>
<?
/*
Warenimport mit Browser nach Lx-Office ERP
Henry Margies <h.margies@maxina.de>
Holger Lindemann <hli@lx-system.de>
*/


function ende($nr) {
	echo "Abbruch: $nr<br>";
	echo "Fehlende oder falsche Daten.";
	exit(1);
}

print_r($_SESSION);
if (!$_SESSION["db"]) {
	$conffile="../config/authentication.pl";
	if (!is_file($conffile)) {
		ende(4);
	}
}
require ("import_lib.php");

if (!anmelden()) ende(5);

/* get DB instance */
$db=$_SESSION["db"]; //new myDB($login);


/* just display page or do real import? */
if ($_POST["ok"]) {

require ("parts_import.php");

/* display help */
if ($_POST["ok"]=="Hilfe") {
	echo "Importfelder:<br>";
	echo "Feldname => Bedeutung<br>";
	foreach($parts as $key=>$val) {
		echo "$key => $val<br>";
	}
	echo "<br>Die erste Zeile enth&auml;lt die Feldnamen der Daten in ihrer richtigen Reihenfolge<br>";
	echo "Geben Sie das Trennzeichen der Datenspalten ein. Steuerzeichen k&ouml;nnen mit ihrem Dezimalwert gef&uuml;hrt von einem &quot;#&quot; eingegebn werden (#11).<br><br>"; 
	echo "Der &quot;sellprice&quot; kann um den eingegeben Wert  ge&auml;ndert werden.<br><br>";
	echo "Bei vorhandenen Artikelnummern (in der db), kann entweder ein Update auf den Preis (und Text) durchgef&uuml;hrt werden oder der Artikel mit anderer Artikelnummer eingef&uuml;gt werden.<br><br>";
	echo "Jeder Artikel mu&szlig; einer Buchungsgruppe zugeordnet werden. ";
	echo "Dazu mu&szlig; entweder in der Maske eine Standardbuchungsgruppe gew&auml;hlt werden <br>";
	echo "oder es wird ein g&uuml;ltiges Konto in 'income_accno_id' und 'expense_accno_id' eingegeben. ";
	echo "Das Programm versucht dann eine passende Buchungsgruppe zu finden.";
	exit(0);
};

clearstatcache ();

$test    = $_POST["test"];
$TextUpd = $_POST["TextUpd"];
$trenner = ($_POST["trenner"])?$_POST["trenner"]:",";
$trennzeichen = ($_POST["trennzeichen"])?$_POST["trennzeichen"]:"";
$precision = $_POST["precision"];
$quotation = $_POST["quotation"];
$quottype = $_POST["quottype"];
$file    = "parts";

/* no data? */
if (empty($_FILES["Datei"]["name"]))
	ende (2);

/* copy file */
if (!move_uploaded_file($_FILES["Datei"]["tmp_name"],$file.".csv")) {
	echo "Upload von Datei fehlerhaft.";
	echo $_FILES["Datei"]["error"], "<br>";
	ende (2);
} 

/* ??? */
//if (!chkUsr($login))
//	ende(4);

/* ??? */
//if (!file_exists("../users/$login.conf")) 
//	ende(3);

/* check if file is really there */
if (!file_exists("$file.csv")) 
	ende(3);

/* ??? */
if (!$db->chkcol($file)) 
	ende(6);


/* first check all elements */
echo "Checking data:<br>";
$_test=$_POST;
$_test["precision"]=-1;
$_test["quotation"]=0;
//$_test["shop"]="n";
//$_test["wgtrenner"]="!";
$err = import_parts($db, $file, $trenner, $trennzeichen, $parts, TRUE, FALSE, FALSE,$_test);
echo "$err Errors found\n";


if ($err!=0)
	exit(0);

/* just print data or insert it, if test is false */
import_parts($db, $file, $trenner, $trennzeichen, $parts, FALSE, !$test, TRUE,$_POST);

} else {
	$bugrus=getAllBG($db);
?>

<p class="listtop">Artikelimport f&uuml;r die ERP<p>
<br>
<form name="import" method="post" enctype="multipart/form-data" action="partsB.php">
<input type="hidden" name="MAX_FILE_SIZE" value="20000000">
<input type="hidden" name="login" value="<?= $login ?>">
<table>
<tr><td><input type="submit" name="ok" value="Hilfe"></td><td></td></tr>
<tr><td>Trennzeichen</td><td>
		<input type="radio" name="trenner" value=";" checked>Semikolon 
		<input type="radio" name="trenner" value=",">Komma 
		<input type="radio" name="trenner" value="#9" checked>Tabulator
		<input type="radio" name="trenner" value=" ">Leerzeichen
		<input type="radio" name="trenner" value="other"> 
		<input type="text" size="2" name="trennzeichen" value=""> 
</td></tr>
<tr><td>VK-Preis<br>Nachkomma:</td><td><input type="Radio" name="precision" value="0">0  
			<input type="Radio" name="precision" value="1">1 
			<input type="Radio" name="precision" value="2" checked>2 
			<input type="Radio" name="precision" value="3">3 
			<input type="Radio" name="precision" value="4">4 
			<input type="Radio" name="precision" value="5">5 
	</td></tr>
<tr><td>VK-Preis<br>Aufschlag:</td><td><input type="text" name="quotation" size="5" value="0"> 
			<input type="radio" name="quottype" value="P" checked>% 
			<input type="radio" name="quottype" value="A">Absolut</td></tr>
<tr><td>Vorhandene<br>Artikelnummer:</td><td><input type="radio" name="update" value="U" checked>Preis update durchf&uuml;hren<br>
					<input type="radio" name="update" value="I">mit neuer Nummer einf&uuml;gen</td></tr>
<tr><td>Test</td><td><input type="checkbox" name="test" value="1">ja</td></tr>
<tr><td>Textupdate</td><td><input type="checkbox" name="TextUpd" value="1">ja</td></tr>
<tr><td>Warengruppen<br>verbinder</td><td><input type="text" name="wgtrenner" value="!" size="3"></td></tr>
<tr><td>Shopartikel</td><td><input type="radio" name="shop" value="t">ja <input type="radio" name="shop" value="n" checked>nein</td></tr>
<tr><td>Art</td><td><input type="Radio" name="ware" value="W" checked>Ware &nbsp; 
		    <input type="Radio" name="ware" value="D">Dienstleistung
		    <input type="Radio" name="ware" value="G">gemischt (Spalte 'art' vorhanden)</td></tr>
<tr><td>Default Bugru<br></td><td><select name="bugru">
<?	if ($bugrus) foreach ($bugrus as $bg) { ?>
			<option value="<?= $bg["id"] ?>"><?= $bg["description"] ?>
<?	} ?>
	</select>
	<input type="radio" name="bugrufix" value="0">nie<br>
	<input type="radio" name="bugrufix" value="1" checked>f&uuml;r alle Artikel verwenden
	<input type="radio" name="bugrufix" value="2">f&uuml;r Artikel ohne passende Bugru
	</td></tr>
<tr><td>Daten</td><td><input type="file" name="Datei"></td></tr>
<tr><td></td><td><input type="submit" name="ok" value="Import"></td></tr>
</table>
</form>
<? }; ?>

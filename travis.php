<?php 
include_once dirname(__File__) . '/system/autoload.php';
	
$bAdminPrivileges = true;

\Aurora\System\Api::Init($bAdminPrivileges);

$DbHost = '127.0.0.1';
$DbLogin = 'root';
$DbPassword = '';
$DbName = '';

$oCoreDecorator = \Aurora\System\Api::GetModuleDecorator('Core');

if ($oCoreDecorator)
{
	$oCoreDecorator->UpdateSettings($DbLogin, $DbPassword, $DbName, $DbHost);
}

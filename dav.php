<?php
/*
 * @copyright Copyright (c) 2017, Afterlogic Corp.
 * @license AGPL-3.0
 *
 * This code is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License, version 3,
 * as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License, version 3,
 * along with this program.  If not, see <http://www.gnu.org/licenses/>
 */

$sCurrentFile = \basename(__FILE__);
$sRequestUri = empty($_SERVER['REQUEST_URI']) ? '' : \trim($_SERVER['REQUEST_URI']);

include_once 'system/autoload.php';

\Aurora\System\Api::GrantAdminPrivileges();
\Aurora\System\Api::Init();

\set_time_limit(3000);
\set_error_handler(function ($errno, $errstr, $errfile, $errline) {
	throw new \ErrorException($errstr, 0, $errno, $errfile, $errline);
});

$sBaseUri = \substr($sRequestUri, 0, \strpos($sRequestUri,'/'.$sCurrentFile)).'/'.$sCurrentFile.'/';
	
\Afterlogic\DAV\Server::getInstance($sBaseUri)->exec();


<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
	<title><?php echo $site_name; ?><?php if(isset($page_name)) echo ': '. $page_name; ?></title>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta http-equiv="X-UA-Compatible" content="IE=100" />
	<meta name="author" content="Michael Creighton" />

	<link rel="shortcut icon" type="image/x-icon" href="<?php echo $media_path; ?>img/favicon.ico" />
	
	<!-- CSS -->
	<link rel="stylesheet" href="<?php echo $media_path; ?>css/blueprint/screen.css" type="text/css" media="screen, projection" />
	<link rel="stylesheet" href="<?php echo $media_path; ?>css/blueprint/print.css" type="text/css" media="print" />
	<!--[if lt IE 8]>
	  <link rel="stylesheet" href="<?php echo $media_path; ?>css/blueprint/ie.css" type="text/css" media="screen, projection" />
	<![endif]-->
	<link href="<?php echo $media_path; ?>css/flow.layout.css" rel="stylesheet" type="text/css" />
</head>
<body>

<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

/*
| -------------------------------------------------------------------
| Load the Flow INI configuration
| --------------------------------------------------------------------
| 
| These changes are made to externalize the configuration of the
| database for ease of user configuration.
|
*/
$framework_ini = (array)unserialize(FRAMEWORK_INI);

$config['firephp_enabled'] = $framework_ini['firephp']['firephp_enabled'] == 1 ? TRUE : FALSE;

// END FirePHP Configuration file

/* End of file firephp.php */
/* Location: ./system/application/config/firephp.php */
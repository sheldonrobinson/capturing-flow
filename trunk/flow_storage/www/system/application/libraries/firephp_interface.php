<?php if (!defined('BASEPATH')) exit('No direct script access allowed');

class Firephp_interface
{

	const LOG = NULL;
	const INFO = NULL;
	const WARN = NULL;
	const ERROR = NULL;
	const DUMP = NULL;
	const EXCEPTION = NULL;

	protected static $instance = NULL;

	public static function getInstance()
	{
	}

	public static function init() {
	} 

	public function setProcessorUrl()
	{
	}

	public function setRendererUrl()
	{
	}

	public function log()
	{
	}

	public function dump()
	{
	} 

	public function detectClientExtension()
	{
	}

	public function fb($Object)
	{
	}

	protected function setHeader($Name, $Value)
	{
	}

	protected function getUserAgent()
	{
	}

	protected function newException($Message)
	{
	}
}
// END FirePHP_Interface class

/* End of file firephp_interface.php */
/* Location: ./system/application/libraries/firephp_interface.php */
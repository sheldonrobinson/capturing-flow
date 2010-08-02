<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
// ------------------------------------------------------------------------

/**
 * CodeIgniter Microtime Helper
 *
 * @package		flow
 * @subpackage	Helpers
 * @category	Helpers
 * @author		Mike Creighton
 */

// ------------------------------------------------------------------------

/**
 * Get "microtime" time as # of milliseconds since epoch
 *
 * Returns microtime() as # of milliseconds since epoch
 *
 * @access	public
 * @return	integer
 */	
if ( ! function_exists('microtime_as_milliseconds'))
{
	function microtime_as_milliseconds()
	{
		list($usec, $sec) = explode(" ", microtime());
		return(floor($usec * 1000) + ($sec * 1000));
	}
}
/* End of file microtime_helper.php */
/* Location: ./system/application/helpers/microtime_helper.php */
?>
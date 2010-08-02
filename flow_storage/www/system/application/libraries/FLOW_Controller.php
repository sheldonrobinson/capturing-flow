<?php  if (!defined('BASEPATH')) exit('No direct script access allowed');
/**
 * Flow
 *
 * @package		Flow
 * @author		Michael Creighton
 * @copyright	Copyright (c) 2010.
 * @license		Modified BSD
 * @link		http://www.opensource.org/licenses/bsd-license.php
 * @since		Version 1.0
 */

// ------------------------------------------------------------------------

/**
 * FLOW_Controller
 *
 * @package Flow
 * @subpackage Controller
 * @since 1.0
 * @author 
 **/
class FLOW_Controller extends Controller
{
	protected $header_data;
	
	/**
	 * Constructor
	 */
	function FLOW_Controller()
	{
		parent::Controller();
		
		// Load up the configuration to see if we have FirePHP logging enabled.
		$this->load->config('firephp');
		
		log_message('info', 'FirePHP enabled? ' . $this->config->item('firephp_enabled') );
		if ( $this->config->item('firephp_enabled') === TRUE )
		{
			if (floor(phpversion()) < 5)
			{
				log_message('error', 'PHP 5 is required to run FirePHP.');
			}
			else
			{
				$this->load->library('firephp');
			}
		}
		else 
		{
			$this->load->library('firephp_interface');
			$this->firephp =& $this->firephp_interface;
		}
		
		$this->header_data['site_name'] = $this->config->item('site_name');
		$this->header_data['base_url'] = $this->config->item('base_url');
		$this->header_data['media_path'] = $this->config->item('media_path');
	}
}
// END FLOW_Controller class

/* End of file FLOW_Controller.php */
/* Location: ./system/application/libraries/FLOW_Controller.php */
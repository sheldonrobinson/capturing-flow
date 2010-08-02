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
 * @filesource
 */

// ------------------------------------------------------------------------

/**
 * Home
 *
 * @package Flow
 * @subpackage Controller
 * @since 1.0
 * @author 
 **/
class Home extends FLOW_Controller {

	/**
	 * Constructor
	 *
	 * @return void
	 * @author 
	 **/
	function Home()
	{
		parent::FLOW_Controller();
		
		$this->firephp->fb("Home :: Controller instantiated.");
		
		$this->load->library('flowdatabase');
	}

// ------------------------------------------------------------------------

	/**
	 * Index method
	 *
	 * @return void
	 * @author 
	 **/
	function index()
	{		
		// Get some system diagnostics.
		$data['is_database_ready'] = $this->flowdatabase->is_database_ready();
		
		$this->header_data['page_name'] = 'Home';
		$this->load->view('_partials/header', $this->header_data);
		$this->load->view('home', $data);
		$this->load->view('_partials/footer');
	}

}
// End File Home.php
// File Source /system/application/controllers/Home.php
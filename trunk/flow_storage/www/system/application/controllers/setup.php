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
 * Setup
 *
 * @package Flow
 * @subpackage Controller
 * @since 1.0
 * @author 
 **/
class Setup extends FLOW_Controller {

	private $dbprefix;

	/**
	 * Constructor
	 *
	 * @return void
	 * @author 
	 **/
	function Setup()
	{
		parent::FLOW_Controller();
		
		$this->firephp->fb("Setup :: Controller instantiated.");
		
		$this->load->database();
		$this->load->library('flowdatabase');
		
		// Now we know if we've got our tables already created.
		$dbready = ($this->flowdatabase->is_database_ready() === TRUE) ? 'TRUE' : 'FALSE';
		$this->firephp->fb('Is our database ready? ' . $dbready);
	}

	/**
	 * Main Index
	 *
	 * @return void
	 * @author 
	 **/
	function index()
	{
		$data['is_database_ready'] = $this->flowdatabase->is_database_ready();
		
		$this->header_data['page_name'] = 'Setup';
		$this->load->view('_partials/header', $this->header_data);
		$this->load->view('setup', $data);
		$this->load->view('_partials/footer');
	}
	
	function create()
	{
		$result = $this->flowdatabase->set_up_tables();
		
		$data['is_database_ready'] = $this->flowdatabase->is_database_ready();
		$data['setup_result'] = $result;
		
		$this->header_data['page_name'] = 'Create Database Tables';
		$this->load->view('_partials/header', $this->header_data);
		$this->load->view('setup_create', $data);
		$this->load->view('_partials/footer');
	}

}
// End File Setup.php
// File Source /system/application/controllers/Setup.php
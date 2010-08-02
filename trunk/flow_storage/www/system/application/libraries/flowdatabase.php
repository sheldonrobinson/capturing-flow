<?php  if (!defined('BASEPATH')) exit('No direct script access allowed');
/**
 * Flow
 *
 * @package		Flow
 * @author		Michael Creighton
 * @copyright	Copyright (c) 2010, Michael Creighton.
 * @license		Modified BSD
 * @link			http://www.opensource.org/licenses/bsd-license.php
 * @since			Version 1.0
 * @filesource
 */

// ------------------------------------------------------------------------

/**
 * Flowdatabase
 *
 * @package Flow
 * @subpackage Controller
 * @since 1.0
 * @author Michael Creighton
 **/
class Flowdatabase
{

	const POINTS_TABLE = 'points';
	const PROJECTS_TABLE = 'projects';
	
	private $CI;
	private $_is_database_ready;
	private $_db_prefix;
	

	/**
	 * Flowdatabase Constructor
	 *
	 * @return void
	 * @author Michael Creighton
	 **/
	function Flowdatabase()
	{
		$this->CI =& get_instance();
		$this->CI->load->database();
		$this->CI->load->library('firephp');
		$this->_is_database_ready = TRUE;
		
		// Load the database config file and find out the db prefix.
		include(APPPATH.'config/database'.EXT);
		$this->_db_prefix = $db[$active_group]['dbprefix'];
		
		if( $this->CI->db->table_exists(Flowdatabase::POINTS_TABLE) === FALSE )
			$this->_is_database_ready = FALSE;
		
		if( $this->CI->db->table_exists(Flowdatabase::PROJECTS_TABLE) === FALSE )
			$this->_is_database_ready = FALSE;
		
		// Now we know if we've got our tables already created.
		$dbready = ($this->_is_database_ready === TRUE) ? 'TRUE' : 'FALSE';
		
		$this->CI->firephp->fb('Flowdatabase :: Is our database ready? ' . $dbready);
	}

// ------------------------------------------------------------------------

	/**
	 * Returns the Database Prefix as specified in the database.php
	 * config file.
	 *
	 * @return string
	 * @author Michael Creighton
	 **/
	function db_prefix()
	{
		return $this->db_prefix;
	}
	
	/**
	 * Returns a boolean specifying whether or not the database is ready.
	 *
	 * @return boolean
	 * @author Michael Creighton
	 **/
	function is_database_ready()
	{
		return $this->_is_database_ready;
	}
	
	/**
	 * Sets up the default table structure in the database.
	 * 
	 * Returns a boolean indicating whether the process was successful.
	 *
	 * @return boolean
	 * @author Michael Creighton
	 **/
	function set_up_tables()
	{
		$success = FALSE;
		
		if( $this->_is_database_ready === FALSE )
		{
			$this->CI->load->dbforge();
			// Create the points table.
			if( $this->CI->db->table_exists(Flowdatabase::POINTS_TABLE) === FALSE )
			{	
				$this->CI->dbforge->add_field('`uid` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT'); // base ID field
				$this->CI->dbforge->add_field('`id` INT(11) NOT NULL'); // Stroke ID
				$this->CI->dbforge->add_field('`project_id` INT(10) UNSIGNED NOT NULL'); // Project ID
				$this->CI->dbforge->add_field('`x` FLOAT NOT NULL'); // x pos
				$this->CI->dbforge->add_field('`y` FLOAT NOT NULL'); // y pos
				$this->CI->dbforge->add_field('`time` BIGINT(20) UNSIGNED NOT NULL'); // timestamp
				// Set the keys
				$this->CI->dbforge->add_key('uid', TRUE);
				$this->CI->dbforge->add_key('project_id');
				$result = $this->CI->dbforge->create_table(Flowdatabase::POINTS_TABLE);
				
				$this->CI->firephp->fb('Flowdatabase :: Points table creation result:');
				$this->CI->firephp->fb($result);				
			}
			// Create the projects table.
			if( $this->CI->db->table_exists(Flowdatabase::PROJECTS_TABLE) === FALSE )
			{	
				$this->CI->dbforge->add_field('`id` INT(11) NOT NULL AUTO_INCREMENT'); // Project UID
				$this->CI->dbforge->add_field('`name` TINYTEXT NOT NULL'); // Project Name
				// Set the keys
				$this->CI->dbforge->add_key('id', TRUE);
				$result = $this->CI->dbforge->create_table(Flowdatabase::PROJECTS_TABLE);
				
				$this->CI->firephp->fb('Flowdatabase :: Projects table creation result:');				
				$this->CI->firephp->fb($result);
			}
			$this->_is_database_ready = TRUE;
			
			$success = TRUE;
		}
		return $success;
	}
}
// End File Flowdatabase.php
// File Source /system/application/libraries/Flowdatabase.php
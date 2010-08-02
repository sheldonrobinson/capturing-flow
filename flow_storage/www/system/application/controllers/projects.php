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
 * Projects
 *
 * @package Flow
 * @subpackage Controller
 * @since 1.0
 * @author 
 **/
class Projects extends FLOW_Controller {

	function Projects()
	{
		parent::FLOW_Controller();
	}
	
	function index()
	{
		$projects = $this->Projects_model->get_projects();
		// Append the number of points for each project to each project's object.
		$points_count = array();
		foreach($projects as &$project)
		{
			$num_points = $this->Points_model->get_num_points($project->id);
			$points_count[$project->id] = $num_points;
		}
		
		$data = array(
						'projects' => $projects,
						'points_count' => $points_count
					);
		
		$this->header_data['page_name'] = 'Projects';
		$this->load->view('_partials/header', $this->header_data);
		$this->load->view('projects_new_form', $data);
		$this->load->view('_partials/footer');		
	}
	
	function new_project()
	{
		$uri_array = $this->uri->uri_to_assoc();
		
		$name = $this->input->post('name');
		if($name !== FALSE)
		{
			$project_id = $this->Projects_model->new_project($name);
			$data = array(
							'project_id' => $project_id,
							'project_name' => $name
						);
			
			// Figure out if we're outputting HTML or XML.
			if( isset($uri_array['output']) )
			{
				if( $uri_array['output'] == 'html' )
				{
					$this->header_data['page_name'] = 'Project Created';
					$this->load->view('_partials/header', $this->header_data);
					$this->load->view('projects_new_result', $data);
					$this->load->view('_partials/footer');
				}
				else
				{
					$this->load->view('projects_new_result_xml', $data);
				}
			}
			else
			{
				$this->load->view('projects_new_result_xml', $data);
			}		
		}
		else
		{
			$this->load->view('error_xml', array( 'error_message' => 'No \'name\' value was supplied in POST.'));
		}
	}
	
	function get_projects()
	{
		$projects = $this->Projects_model->get_projects();
		if($projects !== FALSE)
		{
			// Append the number of points for each project to each project's object.
			$points_count = array();
			foreach($projects as &$project)
			{
				$num_points = $this->Points_model->get_num_points($project->id);
				$points_count[$project->id] = $num_points;
			}

			$data = array(
							'projects' => $projects,
							'points_count' => $points_count
						);
			
			$this->load->view('projects_get_result_xml', $data);
		}
		else
		{
			$this->load->view('error_xml', array( 'error_message' => 'No projects were found in the database.'));
		}
	}
	
	function delete_project($project_id = -1)
	{
		$exists = $this->Projects_model->project_exists($project_id);
		if($exists === TRUE)
		{
			$this->Projects_model->delete_project($project_id);
			$this->load->view('project_delete_result_xml', array( 'project_id' => $project_id ));
		}
		else
		{
			$this->load->view('error_xml', array( 'error_message' => 'Supplied project ID is not valid. Project does not exist.' ));
		}
	}
}

/* End of file projects.php */
/* Location: ./system/application/controllers/projects.php */
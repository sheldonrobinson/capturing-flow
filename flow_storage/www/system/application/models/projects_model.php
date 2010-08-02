<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
// ------------------------------------------------------------------------

class Projects_model extends Model {

    function Projects_model()
    {
        parent::Model();
		$this->load->database();
		$this->load->library('flowdatabase');
    }

	/**
		Returns an array of Project objects which look like:
			id : int
			name : String
		Returns FALSE if no projects are found in the database.
	*/
	function get_projects()
	{
		$query = $this->db->get('projects');
		
		if( $query->num_rows() > 0)
		{
			// Return a results object.
			return $query->result();
		}
		
		return FALSE;
	}
	
	/**
		Returns an array of Project objects which look like:
			id : int
			name : String
		Returns FALSE if no project is found in the database.
	*/
	function get_project( $id )
	{
		$query = $this->db->get_where('projects', array( 'id' => $id ));
		if($query->num_rows() > 0)
		{
			return $query->result();
		}
		else
		{
			return FALSE;
		}
	}
	
	function project_exists($id)
	{
		$query = $this->db->get_where('projects', array( 'id' => $id ));
		if($query->num_rows() > 0)
		{
			return TRUE;
		}
		else
		{
			return FALSE;
		}
	}
	
	/**
		Creates a new project with the supplied project name.
		
		Returns the ID (int) of the new project.
	*/
	function new_project($name)
	{
		$data = array(
						'name' => $name
					);
		$this->db->insert('projects', $data);
		return $this->db->insert_id();
	}

	/**
		Deletes the specified project with the supplied project ID

		Returns the ID (int) of the new project.
	*/
	function delete_project($id)
	{
		$this->db->where('id', $id);
		$this->db->delete('projects');
		
		$this->db->where('project_id', $id);
		$this->db->delete('points');
	}
}

/* End of file projects_model.php */
?>
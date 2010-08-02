<?php  if ( ! defined('BASEPATH')) exit('No direct script access allowed');
// ------------------------------------------------------------------------

class Points_model extends Model {

    function Points_model()
    {
        parent::Model();
    }

	function add_point($project_id, $id, $x, $y, $time)
	{
		$data = array(
						'id' => $id,
						'project_id' => $project_id,
						'x' => $x,
						'y' => $y,
						'time' => $time
					);
		$this->db->insert('points', $data);
	}
	
	function get_points($project_id)
	{
		$this->db->order_by("time", "asc");
		$query = $this->db->get_where('points', array( 'project_id' => $project_id ));
		if($query->num_rows() > 0)
		{
			return $query->result();
		}
		else
		{
			return FALSE;
		}
	}
	
	function get_num_points($project_id)
	{
		$this->db->where('project_id', $project_id);
		$this->db->select('project_id');
		$this->db->from('points');
		$query = $this->db->get();
		return $query->num_rows();
	}
}

/* End of file projects_model.php */
?>
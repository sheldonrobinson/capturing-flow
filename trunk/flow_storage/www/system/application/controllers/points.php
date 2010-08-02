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
 * Points
 *
 * @package Flow
 * @subpackage Controller
 * @since 1.0
 * @author 
 **/
class Points extends FLOW_Controller {

	function Points()
	{
		parent::FLOW_Controller();
	}
	
	function index()
	{
		// First, get a random project.
		$projects = $this->Projects_model->get_projects();
		if($projects !== FALSE)
		{
			$project_index = rand(0, count($projects) - 1);
			// Just get the first one.
			$project_id = $projects[$project_index]->id;
			$project_name = $projects[$project_index]->name;
			$data = array(
							'project_id' => $project_id,
							'project_name' => $project_name
						);
			$this->load->view('_partials/header', $this->header_data);
			$this->load->view('points_new_form', $data);
			$this->load->view('_partials/footer');
		}
		else
		{
			$this->load->view('error', array( 'error_message' => 'There are no projects to add points to! Create a project first.' ));
		}
	}
	
	function add_points()
	{		
		$project_id = $this->input->post("project_id");
		if($project_id !== FALSE)
		{
			$points_str = $this->input->post("points");
			if($points_str !== FALSE)
			{
				// Split this based on commas first.
				$points_objs = explode(",", $points_str);
				$point_counter = 0;
				foreach ($points_objs as &$point_str)
				{
					// Now split the point data into an array.
					// id x y time
					$point_obj = explode(" ", $point_str);
					$id = $point_obj[0];
					$x = $point_obj[1];
					$y = $point_obj[2];
					$time = $point_obj[3];
					// Insert this into the database.
					$this->Points_model->add_point($project_id, $id, $x, $y, $time);
					$point_counter ++;
				}
				unset($point_str);
				
				// Figure out if we're outputting HTML or XML.
				$uri_array = $this->uri->uri_to_assoc();
				$data['num_points'] = $point_counter;
				
				if( isset($uri_array['output']) )
				{
					if( $uri_array['output'] == 'html' )
					{
						$project_data = $this->Projects_model->get_project($project_id);
						$data['project'] = $project_data[0];
						$this->header_data['page_name'] = 'Random Points Added';
						$this->load->view('_partials/header', $this->header_data);
						$this->load->view('points_add_result', $data);
						$this->load->view('_partials/footer');
					}
					else
					{
						$this->load->view('points_add_result_xml', $data );
					}
				}
				else
				{
					$this->load->view('points_add_result_xml', $data );
				}
			}
			else
			{	
				$this->load->view('error_xml', array( 'error_message' => 'No points were supplied in the POST data.' ));
			}
		}	
		else
		{	
			$this->load->view('error_xml', array( 'error_message' => 'Supplied project ID is not valid. Project does not exist.' ));
		}
	}
	
	function get_num_points($project_id = -1)
	{
		if($project_id != -1)
		{
			// First, make sure the project exists.
			if($this->Projects_model->project_exists($project_id) === TRUE)
			{
				$num_points = $this->Points_model->get_num_points($project_id);
				$this->load->view('points_number_result_xml', array( 'num_points' => $num_points ));
			}
			else
			{	
				$this->load->view('error_xml', array( 'error_message' => 'Supplied project ID is not valid. Project does not exist.' ));
			}
		}
		else
		{
			$this->load->view('error_xml', array( 'error_message' => 'No project ID was supplied. Please pass project ID as part of URL path structure.' ));
		}
	}
	
	function get_points($project_id = -1, $ignore_redundant_points = FALSE)
	{
		if($ignore_redundant_points !== FALSE)
		{
			if($ignore_redundant_points == 'true' || $ignore_redundant_points == 'TRUE' || $ignore_redundant_points == 1)
			{
				$ignore_redundant_points = TRUE;
			}
			else
			{
				$ignore_redundant_points = FALSE;
			}
		}
		if($project_id != -1)
		{
			// First, make sure the project exists.
			if($this->Projects_model->project_exists($project_id) === TRUE)
			{
				$points = $this->Points_model->get_points($project_id);
				
				/*
				 Workhorse logic that does the following:
				
					- grabs all the points for a given project
					- figures out the start time (based on the first point entered into the system)
					- calculates when a new stroke occurs based on the point's x and y vals == -1 and the ID changes
				*/
				$default_time_between_strokes = 1 / 60;
				$strokes = array();
				$curr_stroke_id = -1;
				$start_time = 0;
				$fstart_time = 0;
				$fstroke_start_time = 0;
				$flast_stroke_point_time = 0;
				$stroke;
				
				// Create a point for tracking redundancy.
				$last_point = array( "x" => -1, "y" => -1 );
				
				foreach( $points as &$point )
				{
					// See if we're starting our first stroke...
					if($curr_stroke_id == -1)
					{
						if($start_time == 0)
						{
							$fstart_time = $point->time / 1000;
							$last_stroke_point_time = $fstart_time;
							$start_time = floor( $fstart_time ); // Used in the header of the GML.
						}
						$stroke = array();
						$curr_stroke_id = $point->id;
					}
					
					if( $point->x == -1 && $point->y == -1 )
					{
						// New stroke time.
						$curr_stroke_id = -1;
						$last_point = array( "x" => -1, "y" => -1 );
						
						// Add the current stroke to the strokes array.
						if( count($stroke) > 0 )
						{
							$strokes[] = $stroke;
						}
					}
					else
					{	
						// If this is the first point in our stroke, then we want to 
						// figure out what to base the time offset from.
						if( count($stroke) == 0)
						{
							$fstroke_start_time = $point->time / 1000;
							$flast_stroke_point_time = 0;
							if( count($strokes) > 0 )
							{
								// Get the last stroke's last point time, so we know what to add to
								// each of our current stroke's points time diffs.
								$total_strokes = count($strokes);
								$last_stroke = $strokes[$total_strokes - 1];
								$last_stroke_num_points = count($last_stroke);
								$last_stroke_last_point = $last_stroke[$last_stroke_num_points - 1];
								$flast_stroke_point_time = $last_stroke_last_point['t'];
							}
						}
						
						// With each point, we need to calc our time offset in fractions of a second, based
						// on the point's time value.
						$fpoint_time = $point->time / 1000;
						$ftime_diff = $fpoint_time - $fstroke_start_time;
						// Now we've got a "local" time diff... need to add this to $default_time_between_strokes + $flast_stroke_point_time
						$ftime_diff = $ftime_diff + $default_time_between_strokes + $flast_stroke_point_time;
						
						$is_adding_new_point = TRUE;
						if($ignore_redundant_points)
						{
							if($point->x != $last_point['x'] && $point->y != $last_point['y'])
							{
								$last_point['x'] = $point->x;
								$last_point['y'] = $point->y;
							}
							else
							{
								$is_adding_new_point = FALSE;
							}
						}
						
						if($is_adding_new_point === TRUE)
						{
							$stroke[] = array( 'x' => $point->x, 'y' => $point->y, 't' => $ftime_diff ); // Add this point to the stroke.
						}
					}
				}
				unset( $stroke );
				unset( $point );
				
				
				if($points !== FALSE)
				{
					$this->load->view('points_get_result_xml', array( 'strokes' => $strokes, 'start_time' => $start_time ));
				}
				else
				{
					$this->load->view('error_xml', array( 'error_message' => 'No points were found for the requested project ID.' ));
				}
			}
			else
			{	
				$this->load->view('error_xml', array( 'error_message' => 'Supplied project ID is not valid. Project does not exist.' ));
			}
		}
		else
		{
			$this->load->view('error_xml', array( 'error_message' => 'No project ID was supplied. Please pass project ID as part of URL path structure.' ));
		}
	}
}

/* End of file points.php */
/* Location: ./system/application/controllers/points.php */
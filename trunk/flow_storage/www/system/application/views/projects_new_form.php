	<?php $this->load->helper('form'); ?>

	<div class="container prepend-1 span-22 append-1 last">
		<h2>Create a new project</h2>
	
		<?php echo form_open('projects/new_project/output/html/'); ?>
	
		<p><strong>Project ID: </strong> <?php echo form_input('name', 'New Project'); ?></p>
	
		<div class="span-22 append-bottom"><?php echo form_submit('submit', 'Add Project'); ?></div>
	
		<?php echo form_close(); ?>	
	
		<hr/>
	
		<h2>Existing Projects</h2>
	
		<?php
			if($projects === FALSE)
			{
			?>
				<p>There are currently no projects in the system.</p>
				<?php
			}
			else
			{
			?>
				<ul>
				<?php
					foreach($projects as &$project)
					{
						$number_of_points = $points_count[$project->id];
						$points_str = 'points';
						if($number_of_points == 1)
						{
							$points_str = 'point';
						}
						echo '<li><strong>' . $project->id . '</strong>: ' . $project->name . ' <small>('.$number_of_points.' '.$points_str.')</small> <small><a href="'.site_url('points/get_points/'.$project->id).'">GML</a></small> <small><a href="'.site_url('points/get_points/'.$project->id.'/true').'">GML without redundant points</a></small></li>';
					}
					unset($project);
				?>
				</ul>
			<?php
			}
		?>
		
		<hr />
		
		<p><a href="<?php echo site_url(); ?>">Return Home</a>.</p>
	</div>
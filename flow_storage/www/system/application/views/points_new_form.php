	<?php
		$this->load->helper('form'); 
		$this->load->helper('microtime'); 
	?>
	
	<div class="container span-22 prepend-1 append-1 last">
		<h2>Add some points to a project</h2>
	
		<p><strong>Random Project</strong>: <?php echo $project_name; ?> <small>(project id: <strong><?php echo $project_id; ?></strong>)</small></p>
	
		<?php
			// Function for generating random float values.
			function fprand($intMin,$intMax,$intDecimals)
			{
				if($intDecimals)
				{
					$intPowerTen = pow(10, $intDecimals);
					return rand($intMin, $intMax * $intPowerTen) / $intPowerTen;
				}
				else
					return rand($intMin,$intMax);
			}
		
			echo form_open('points/add_points/output/html');
			echo "<ul>\n";
		
			$points_str = "";
			$num_points = rand(100, 1000);
			for ($i = 0; $i < $num_points; $i++)
			{
				$id = 0;
				$x = fprand(0, 1, 6);
				$y = fprand(0, 1, 6);
				$time = microtime_as_milliseconds();
				echo "<ul>$id | $x | $y | $time</ul>\n";
				$points_str .= "$id $x $y $time";
				if($i < $num_points - 1)
					$points_str .= ",";
			}
		
			echo "</ul>\n";
			?>
		
			<h3>Submission String</h3>
			<p><?php echo $points_str; ?></p>
		
			<?php
			echo form_hidden('project_id', $project_id);
			echo form_hidden('points', $points_str);
			echo form_submit('submit', 'Add These Points!');
			echo form_close();
		?>
	</div>
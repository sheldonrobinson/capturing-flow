<?php
	header('Content-type: text/xml');
	echo '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
?>
<result>
	<code>0</code>
	<data>
		<projects>
			<?php
				foreach($projects as &$project)
				{
					echo '<project num_points="'.$points_count[$project->id].'" id="' . $project->id . '"><![CDATA['. $project->name .']]></project>' . "\n";
				}
				unset($project);
			?>
		</projects>
	</data>
</result>
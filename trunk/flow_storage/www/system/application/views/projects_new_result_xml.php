<?php
	header('Content-type: text/xml');
	echo '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
?>
<result>
	<code>0</code>
	<data>
		<?php
			echo '<project id="' . $project_id . '"><![CDATA['. $project_name .']]></project>' . "\n";
		?>
	</data>
</result>
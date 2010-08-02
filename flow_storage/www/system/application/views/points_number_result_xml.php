<?php
	header('Content-type: text/xml');
	echo '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
?>
<result>
	<code>0</code>
	<data>
		<num_points><?php echo $num_points; ?></num_points>
	</data>
</result>
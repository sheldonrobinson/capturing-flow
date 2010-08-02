<?php
	header('Content-type: text/xml');
	echo '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
?>
<result>
	<code>0</code>
	<data>
		<project id="<?php echo $project_id; ?>" />
	</data>
</result>
<?php
	header('Content-type: text/xml');
	echo '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
?>
<result>
	<code>1</code>
	<data>
		<?php
			echo '<error><![CDATA['. $error_message .']]></error>' . "\n";
		?>
	</data>
</result>
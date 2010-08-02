	<div class="container prepend-1 span-22 append-1 last">
		<h2>Flow Storage Database Table Creation</h2>
	<?php if($setup_result === TRUE): ?>
			<p>Database setup has been completed <strong>successfully</strong>.</p>
	<?php else: ?>
		<?php if($is_database_ready === TRUE): ?>
			<p>Your database was already set up, so there's nothing to do.</p>
		<?php else: ?>
			<p>An error occurred when attempting to set up the database.</p>
		<?php endif;?>
	<?php endif; ?>	
		<hr />
	
		<p><a href="<?php echo site_url(); ?>">Return Home</a>.</p>
	</div>
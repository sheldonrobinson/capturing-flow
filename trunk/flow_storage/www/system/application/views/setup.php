	<div class="container prepend-1 span-22 append-1 last">
		<h2>Flow Storage Setup</h2>
	<?php if($is_database_ready === TRUE): ?>
		<p>It looks like your database is ready to go. Nothing left to do but capture some data!</p>
	<?php else: ?>
		<p>Your database is not ready. <a href="<?php echo site_url('setup/create/'); ?>">Click here to set it up!</a></p>
	<?php endif; ?>	
	
		<hr />
	
		<p><a href="<?php echo site_url(); ?>">Return Home</a>.</p>
	</div>
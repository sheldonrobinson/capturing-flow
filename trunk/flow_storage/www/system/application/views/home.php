	<div class="container prepend-1 span-22 append-1 last">

		<h2 class="span-24">Flow Storage</h2>
	
	<?php if( $is_database_ready === TRUE ): ?>
		<p class="span-24">System is up and running correctly.</p>
	
		<p><a href="<?php echo site_url('projects/'); ?>">View your Projects</a>.</p>
	
	<?php else: ?>
		<p class="span-24">Looks like you need to set up your database. <a href="<?php echo site_url('setup/'); ?>">Click here to start the process</a>.</p>
	
	<?php endif; ?>

	</div>
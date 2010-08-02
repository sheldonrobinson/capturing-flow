<?php
	header('Content-type: text/xml');
	echo '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
?>
<GML spec="0.1c">
	<tag>
		<header>
			<client>
				<name>Flow</name>
				<version>1.0</version>
				<time><?php if( isset($start_time) ) echo $start_time; ?></time>
			</client>
			<environment>
				<offset>
					<x>0.0</x>
					<y>0.0</y>
					<z>0.0</z>
				</offset>
				<rotation>
					<x>0.0</x>
					<y>0.0</y>
					<z>0.0</z>
				</rotation>
				<up>
					<x>0.0</x>
					<y>-1.0</y>
					<z>0.0</z>
				</up>
				<screenBounds>
					<x>1</x>
					<y>1</y>
					<z>0</z>
				</screenBounds>
				<origin>
					<x>0</x>
					<y>0</y>
					<z>0</z>
				</origin>
				<realScale>
					<x>1</x>
					<y>1</y>
					<z>0</z>
				</realScale>
			</environment>
		</header>
		<!-- Begin the actual drawing's data -->
		<drawing>
		<?php foreach($strokes as &$stroke): ?>	<stroke>
			<?php foreach($stroke as &$point ): ?>	<pt>
					<x><?php echo $point['x']; ?></x>
					<y><?php echo $point['y']; ?></y>
					<time><?php echo $point['t']; ?></time>
				</pt>
			<?php
				endforeach;
				unset($point);
			?></stroke>
		<?php		
			endforeach;
			unset($stroke);
		?></drawing>
	</tag>
</GML>
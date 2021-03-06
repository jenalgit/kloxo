<?php
	exec("echo '' > /opt/configs/yadifa/conf/defaults/yadifa.master.conf");

	$d1names = $domains;

	// MR -- use nsd data because the same structure
	$tpath = "/opt/configs/nsd/conf/master";
	$d2files = glob("{$tpath}/*");

	if (empty($d2files)) { return; }

	foreach ($d2files as $k => $v) {
		$d2names[] = str_replace("{$tpath}/", '', $v);
	}

	$d2olds = array_diff($d2names, $d1names);

	// MR -- delete unwanted files
	if (!empty($d2olds)) {
		foreach ($d2olds as $k => $v) {
			unlink("{$tpath}/{$v}");
		}
	}

	$str = '';

	foreach ($d1names as $k => $v) {
		$zone  = "<zone>";
		$zone .= "\n    domain          {$v}";
		$zone .= "\n    type            master";
		$zone .= "\n    file-name       master/{$v}";
		$zone .= "\n#    allow-transfer  allower";
		$zone .= "\n#    allow-notity    allower";
		$zone .= "\n</zone>\n\n";

		$str .= $zone;
	}

	$file = "/opt/configs/yadifa/conf/defaults/yadifa.master.conf";

	file_put_contents($file, $str);

	if (!isServiceExists('yadifa')) { return; }
	createRestartFile("restart-dns");

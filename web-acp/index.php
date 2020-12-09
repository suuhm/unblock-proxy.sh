<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>unblock-proxy.sh -Web!</title>
    
    <!-- css stuff -->
	<link href="css/bootstrap.min.css" rel="stylesheet">
	
    <style>
	.bd-placeholder-img {
	font-size: 1.125rem;
	text-anchor: middle;
	-webkit-user-select: none;
	-moz-user-select: none;
	-ms-user-select: none;
	user-select: none;
	}
	
	body { background: #261714; }
	a { color: #6f3c30; }

	#refresh,#rchat,#ta
	{
	text-align: left;
	color: #513b39;
	background-color: #0d0a09;
	border-block: #261714;
	text-indent: revert;
	font-size: large;
	border: solid 1px;
	display: block;
	padding: 20px;
	}	
	
	.btn-primary {
	background-color: #371912;
	border-color: #00000075;
	}
	
	.btn-primary:hover {
	/* background-color: #0069d9; */
	background-color: #4a3733;
	border-color: #261714;
	}
	
	.bg-dark {
	background-color: #000000a3 !important;
	}
	
	@media (min-width: 768px) {
		.bd-placeholder-img-lg {
	    	font-size: 3.5rem;
	    }
	}
    </style>
    <link href="unbproxy.css" rel="stylesheet">
  </head>
  
  <body>
    <header>
  <nav class="navbar navbar-expand-md navbar-dark fixed-top bg-dark">
    <a style="margin-left:3px" class="navbar-brand" href="#">unblock-proxy -Web!</a>
    <div style="float:left"> </div>
    <button id="countdown" class="btn btn-primary my-2" onClick="pauseRef()">Refresh Page</button>
    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarCollapse" aria-controls="navbarCollapse" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
  </nav>
	</header>

  <main role="main">

  <div id="myCarousel" class="carousel slide" data-ride="carousel">
    <ol class="carousel-indicators">
      <li data-target="#myCarousel" data-slide-to="0" class="active"></li>
      <li data-target="#myCarousel" data-slide-to="1"></li>
      <li data-target="#myCarousel" data-slide-to="2"></li>
    </ol>
    <div class="carousel-inner">
      <div class="carousel-item active">
        <!--<svg class="bd-placeholder-img" width="100%" height="100%" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMidYMid slice" focusable="false" role="img"><rect width="100%" height="100%" fill="#111"/></svg>
        -->
        <center><img src="img/unblock-version.gif" /></center>
        <div class="container">
        </div>
      </div>
      <div class="carousel-item">
        <center><img src="img/unblock-dns-redsocks.gif" /></center>
        <div class="container">
        </div>
      </div>
      <div class="carousel-item">
        <center><img src="img/unblock-dns-squid.gif" /></center>
        <div class="container">
        </div>
      </div>
    </div>
    <a class="carousel-control-prev" href="#myCarousel" role="button" data-slide="prev">
      <span class="carousel-control-prev-icon" aria-hidden="true"></span>
      <span class="sr-only">Previous</span>
    </a>
    <a class="carousel-control-next" href="#myCarousel" role="button" data-slide="next">
      <span class="carousel-control-next-icon" aria-hidden="true"></span>
      <span class="sr-only">Next</span>
    </a>
  </div>

  <!-- EDIT ACP --
  ================================================== 
  -->

  <div class="container">
    <hr class="featurette-divider">

	<?php
	$url = 'index.php';
	$fprox = '../proxies.lst';
	$fdoms = '../domains.lst';
	
	if (isset($_POST['prox']) || isset($_POST['doms']))
	{
	    //$handle = fopen("home.txt", 'w') or die("Can't open file for writing.");
	    //fwrite($fh, $_POST['textfield']);
	    //fclose($fh);
	    file_put_contents($fprox, preg_split('/\r|[\r]/' , $_POST['prox']));
	    file_put_contents($fdoms, preg_split('/\r|[\r]/' , $_POST['doms']));
	
	    //redirect
	    //header(sprintf('Location: %s', $url));
	    ?>
	    <h3>Erfolgreich gespeichert!</h3> <br/><br>
	    
		<?php
	    printf('<a href="%s">Back to acp</a>.', htmlspecialchars($url));
	    $output = shell_exec('sh restart_web.sh');
		echo "<pre>$output</pre>";
	    exit();
	}
	$proxies = file_get_contents($fprox);
	$domains = file_get_contents($fdoms);
	$debug = shell_exec("tail -n 17 web-tail.log | grep -vE '\[.*m'");
	?>	
	
    <div class="row featurette">
		<form class="" action="" method="post">
		    <div class="form-group">
    			<label for="exampleFormControlTextarea1"><h3>Edit Proxies</h3></label>
    			<pre><textarea class="form-control" name="prox" id="ta" rows="11" cols="130"><?php echo htmlspecialchars($proxies); ?></textarea></pre>
  			</div><br/>
  			<div class="form-group">
    			<label for="exampleFormControlTextarea1"><h3>Edit Domains</h3></label>
    			<pre><textarea class="form-control" name="doms" id="ta" rows="11" cols="130"><?php echo "$domains"; ?></textarea></pre>
  			</div>
  		    <div class="form-group">
    			<label for="exampleFormControlTextarea1"><h3>Debug-l0gs</h3></label>
    			<pre><textarea class="form-control" name="debug" id="ta" rows="11" cols="130"><?php echo "$debug"; ?></textarea></pre>
  			</div><br/>
		
		  <div class="custom-control custom-checkbox my-1 mr-sm-2">
		    <input type="checkbox" class="custom-control-input" id="customControlInline">
		    <label class="custom-control-label" for="customControlInline">Remember my preference</label>
		  </div>
		
		  <button type="submit" class="btn btn-primary my-1">Submit</button>
		  <button type="reset" class="btn btn-primary my-1">Reset</button>
		</form>
    </div>


    <hr class="featurette-divider">

    <div class="row featurette">
      <div class="col-md-7">
        <h3 class="featurette-heading">And lastly, this one. <span class="text-muted">Checkmate.</span></h3>
        <p class="lead">
        Main Modes:

    Router (transparent) Mode (This can be use on a OpenWRT Route or something similar)
    Smart (DNS) Mode (Set this to any device where you can set a DNS Server Setting)

Proxy Engines:

    Tor
    Squid (incl. Certcreator for SSL-Bump Functionality)
    Redsocks
    Proxychains
	
        </p>
      </div>
      <div class="col-md-5">
        <img src="img/unblock-check.gif" width="auto" height="77%" />
      </div>
    </div>

    <hr class="featurette-divider">
  </div>

  <!-- FOOTER -->
  <footer class="container">
    <p class="float-right"><a href="#">Back to top</a></p>
    <p>&copy; 2020 Suuhm &middot; <a href="https://www.coldwareveryday.com">VISIT CWE!</a> &middot; <a href="#">Terms</a></p>
  </footer>
  
</main>
	<script src="toolsets.js"></script>
	<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js" integrity="sha384-DfXdz2htPH0lsSSs5nCTpuj/zy4C+OGpamoFVy38MVBnE+IbbVYUew+OrCXaRkfj" crossorigin="anonymous"></script>
	<script>window.jQuery || document.write('<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"><\/script>')</script>
	<script src="js/bootstrap.bundle.min.js"></script>

</html>

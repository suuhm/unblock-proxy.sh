/* 
###########
# unblock-proxy.sh ver. 0.2.1 beta for Linux 
# ---------------------------------
# This script helps to traverse geoblocking like in hulu, netflix, zattoo etc 
# You can choose your favorite proxy engine, to get the best results
# There are 2 Main Modes: Tranparent Route Mode or SmartDNS Proxy
# Also there is a tiny proxy-checker included.
# 
# Have fun and Happy watching unblocked globally stuff! :)
# 
#
# Copyright (C) 2020 - by suuhm - suuhmer@coldwareveryday.com
#
# GNU General Public License v2.0
# -------------------------------
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
###########
*/

/*$(document).ready(function() {
    $("#debug").load("stats.php");
    $("#debug2").load("stats2.php");
    var refreshId = setInterval(function() {
        $("#refresh").load("stats.php");
       $("#rchat").load("stats2.php");
    }, 1000);
});*/

// -- REFRESH BUTTON --
var stim;
var remaining = 42;
var tmp;
var co = 1;
pauseRef();
/*(function countdown(remaining) {
    if(remaining <= 0)
        location.reload(true);
    document.getElementById('countdown').innerHTML = "Reloading (Click to pause) (" + remaining +" )";
    stim = setTimeout(function() { countdown(remaining - 1); }, 1000);
})(42); // 5 seconds*/

function pauseRef() {
  	if (co == 1 && stim) {
  	clearTimeout(stim);
  	co = 0;
  	remaining = tmp;
	} else {
	//countdown(remaining);
	(function countdown(remaining) {
    if(remaining <= 0)
        location.reload(true);
    document.getElementById('countdown').innerHTML = "Reloading (Click to pause) ( " + remaining + " )";
    	tmp = remaining;
    	stim = setTimeout(function(){ countdown(remaining - 1); }, 1000);
	})(remaining);
	}
}
#!/bin/bash
# Use this for your startup script (script from top to bottom)
# install apache2 (Debian/Ubuntu version)
apt-get update -y
apt-get install -y apache2
systemctl start apache2
systemctl enable apache2

# GCP Metadata server base URL
METADATA_URL="http://metadata.google.internal/computeMetadata/v1"
METADATA_FLAVOR_HEADER="Metadata-Flavor: Google"

# Background the curl requests
curl -H "${METADATA_FLAVOR_HEADER}" -s "${METADATA_URL}/instance/network-interfaces/0/ip" &> /tmp/local_ipv4 &
curl -H "${METADATA_FLAVOR_HEADER}" -s "${METADATA_URL}/instance/zone" &> /tmp/zone &
curl -H "${METADATA_FLAVOR_HEADER}" -s "${METADATA_URL}/project/project-id" &> /tmp/project_id &
curl -H "${METADATA_FLAVOR_HEADER}" -s "${METADATA_URL}/instance/tags" &> /tmp/network_tags &
wait

project_id=$(cat /tmp/project_id)
local_ipv4=$(cat /tmp/local_ipv4)
zone=$(cat /tmp/zone)
network_tags=$(cat /tmp/network_tags) # This can be used to infer the network/VPC in a custom manner.

echo "
<!doctype html>
<html lang=\"en\" class=\"h-100\">
<head>
<title>Details for GCP Compute Engine instance</title>
<style>
html, body {
    height: 100%;
    margin: 0;
    overflow-y: auto; /* Allows scrolling */
}
#Matrix {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    z-index: -1;
}
.content {
    position: relative;
    top: 20px;
    left: 5%;
    color: #0F0;
    font-family: monospace;
    z-index: 2;
    text-align: left;
    width: 60%;
}

/* New styles for the GIF container */
.gif-container {
    display: flex; 
    justify-content: start; 
    flex-wrap: nowrap; 
    gap: 20px; 
}

.tenor-gif-embed {
    max-height: 300px; 
    max-width: 350px; 
    overflow: hidden;
}
</style>
</head>
<body>
<canvas id=\"Matrix\"></canvas>
<div class="content">
<h1>Passport Bro's</h1>
<h1>Escape The Matrix</h1>

 <div class="gif-container">
    <div class="tenor-gif-embed" data-postid="18977260" data-share-method="host" data-aspect-ratio="0.5625" data-width="100%"></div>
    <div class="tenor-gif-embed" data-postid="18523529" data-share-method="host" data-aspect-ratio="0.5625" data-width="100%"></div>
</div>
<script type="text/javascript" async src="https://tenor.com/embed.js"></script>

<p><b>Instance Name:</b> $(hostname -f) </p>
<p><b>Instance Private IP Address: </b> ${local_ipv4}</p>
<p><b>Zone: </b> ${zone}</p>
<p><b>Project ID:</b> ${project_id}</p>
<p><b>Network Tags:</b> ${network_tags}</p>
</div>

<script>
const canvas = document.getElementById('Matrix');
const context = canvas.getContext('2d');

canvas.width = window.innerWidth;
canvas.height = window.innerHeight;

const katakana = 'アァカサタナハマヤャラワガザダバパイィキシチニヒミリヰギジヂビピウゥクスツヌフムユュルグズブヅプエェケセテネヘメレヱゲゼデベペオォコソトノホモヨョロヲゴゾドボポヴッン';
const latin = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
const nums = '0123456789';

const alphabet = katakana + latin + nums;

const fontSize = 16;
const columns = canvas.width/fontSize;

const rainDrops = [];

for( let x = 0; x < columns; x++ ) {
	rainDrops[x] = 1;
}

const draw = () => {
	context.fillStyle = 'rgba(0, 0, 0, 0.05)';
	context.fillRect(0, 0, canvas.width, canvas.height);
	
	context.fillStyle = '#0F0';
	context.font = fontSize + 'px monospace';

	for(let i = 0; i < rainDrops.length; i++)
	{
		const text = alphabet.charAt(Math.floor(Math.random() * alphabet.length));
		context.fillText(text, i*fontSize, rainDrops[i]*fontSize);
		
		if(rainDrops[i]*fontSize > canvas.height && Math.random() > 0.975){
			rainDrops[i] = 0;
        }
		rainDrops[i]++;
	}
};

setInterval(draw, 30);
</script>
</body>
</html>
" > /var/www/html/index.html

# Clean up the temp files
rm -f /tmp/local_ipv4 /tmp/zone /tmp/project_id /tmp/network_tags

const express = require('express');
const fs = require('fs');
const { exec } = require('child_process');
const path = require('path');
const app = express();
const port = 8080;

// Serve static files from the 'public' directory
app.use(express.static('public'));

// Function to generate ingresses.json by running the shell script
function generateIngressesJson(callback) {
    exec('/app/list_ingress.sh', (error, stdout, stderr) => {
        if (error) {
            console.error(`Error executing script: ${error}`);
            return callback(error);
        }
        console.log(`Script executed. STDOUT: ${stdout}`);
        if (stderr) {
            console.error(`Script STDERR: ${stderr}`);
        }
        callback(null);
    });
}

// Endpoint to serve ingresses.json
app.get('/ingresses.json', (req, res) => {
    // Run the script each time a client requests /ingresses.json
    generateIngressesJson((err) => {
        if (err) {
            return res.status(500).send('Failed to refresh ingresses');
        }

        const jsonFilePath = '/tmp/ingresses.json';
        fs.readFile(jsonFilePath, (readErr, data) => {
            if (readErr) {
                console.error(readErr);
                return res.status(500).send('Error reading JSON file');
            }
            res.setHeader('Content-Type', 'application/json');
            res.send(data);
        });
    });
});

// Start the server
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});

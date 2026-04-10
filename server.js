const http = require('http');
const { execSync } = require('child_process');

const server = http.createServer((req, res) => {
  try {
    const output = execSync('bash /workspace/project/student_info.sh', { encoding: 'utf8' });
    const html = `<!DOCTYPE html>
<html>
<head>
  <title>My Computer Science Students</title>
  <style>
    body { font-family: monospace; background: #1e1e1e; color: #d4d4d4; padding: 2rem; }
    pre { white-space: pre-wrap; line-height: 1.6; font-size: 14px; }
    h1 { color: #4ec9b0; }
  </style>
</head>
<body>
  <h1>Student Database - Part 2</h1>
  <pre>${output.replace(/</g, '&lt;').replace(/>/g, '&gt;')}</pre>
</body>
</html>`;
    res.writeHead(200, { 'Content-Type': 'text/html' });
    res.end(html);
  } catch (e) {
    res.writeHead(500, { 'Content-Type': 'text/plain' });
    res.end('Error: ' + e.message);
  }
});

server.listen(3000, () => {
  console.log('Server running on port 3000');
});

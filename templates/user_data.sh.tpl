#!/bin/bash

dnf install -y nginx

cat > /usr/share/nginx/html/index.html <<'EOF'
${html}
EOF

systemctl enable nginx
systemctl start nginx
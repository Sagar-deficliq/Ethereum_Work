--- 
customlog: 
  - 
    format: combined
    target: /etc/apache2/logs/domlogs/deficliq.com
  - 
    format: "\"%{%s}t %I .\\n%{%s}t %O .\""
    target: /etc/apache2/logs/domlogs/deficliq.com-bytes_log
documentroot: /home/iz38i7873tds/public_html
group: iz38i7873tds
hascgi: 1
homedir: /home/iz38i7873tds
ip: 166.62.28.88
owner: gdresell
phpopenbasedirprotect: 1
port: 80
scriptalias: 
  - 
    path: /home/iz38i7873tds/public_html/cgi-bin
    url: /cgi-bin/
serveradmin: webmaster@deficliq.com
serveralias: mail.deficliq.com www.deficliq.com
servername: deficliq.com
usecanonicalname: 'Off'
user: iz38i7873tds

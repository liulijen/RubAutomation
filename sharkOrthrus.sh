tshark -i en0 -f "ether host EC:44:76:1F:7E:62" \
-z "proto,colinfo,ip.dsfield.dscp,ip.dsfield.dscp" \
-z "proto,colinfo,sip.Expires,sip.Expires" \
-z "proto,colinfo,sip.Call-Info,sip.Call-Info" \
-z "proto,colinfo,sip.Reason,sip.Reason"

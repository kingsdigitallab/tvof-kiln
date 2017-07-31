python doall.py edition/fr20125/source/{16..18}*.xml -o fr/ && cp fr/converted.xml tomcat/Fr20125.xml
python doall.py edition/royal/source/{21..22}*.xml -o royal/ && cp royal/converted.xml tomcat/Royal.xml
cd ../..
./force_reload.sh

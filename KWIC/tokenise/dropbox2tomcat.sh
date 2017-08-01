#python doall.py edition/fr20125/source/{16..18}[_,-]*.xml -c -o fr/ && cp fr/converted.xml tomcat/Fr20125.xml
#python doall.py edition/royal/source/{21..22}[_,-]*.xml -c -o royal/ && cp royal/converted.xml tomcat/Royal.xml
python doall.py edition/fr20125/source/{1..100}[_,-]*.xml -c -o fr/ && cp fr/converted.xml tomcat/Fr20125.xml
python doall.py edition/royal/source/{1..100}[_,-]*.xml -c -o royal/ && cp royal/converted.xml tomcat/Royal.xml
cd ../..
./force_reload.sh

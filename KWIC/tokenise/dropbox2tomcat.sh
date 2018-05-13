#python doall.py edition/fr20125/source/{16..18}[_,-]*.xml -c -o fr/ && cp fr/converted.xml tomcat/Fr20125.xml
#python doall.py edition/royal/source/{21..22}[_,-]*.xml -c -o royal/ && cp royal/converted.xml tomcat/Royal.xml
python2 doall.py edition/fr20125/source/{1..100}[_,-]*.xml -c -o fr/ && cp fr/converted.xml tomcat/Fr20125.xml
python2 doall.py edition/royal/source/{1..100}[_,-]*.xml -c -o royal/ && cp royal/converted.xml tomcat/Royal.xml
#cp edition/Modeling_Structure_Segmentation/TVOF_para_alignment.xml ../../webapps/ROOT/content/xml/tei/alists/TVOF_para_alignment.xml
# python2 align_merge.py "alignment/source/TVOF_para_alignment*.xml" -o ../../webapps/ROOT/content/xml/tei/alists/TVOF_para_alignment.xml
python2 align_merge.py "alignment/source/TVOF_para_alignment_Fr20125.xml" "alignment/source/TVOF_para_alignment_Royal_20_D_1.xml" "alignment/source/TVOF_para_alignment_Add_15268.xml" "alignment/source/TVOF_para_alignment_Add_19669.xml" alignment/source/TVOF_para_alignment_Fr17177.xml -o ../../webapps/ROOT/content/xml/tei/alists/TVOF_para_alignment.xml
cd ../..
./force_reload.sh

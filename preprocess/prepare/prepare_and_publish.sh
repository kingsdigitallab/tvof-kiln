# convert and aggregate all the TEI fragments for the alignment, Royal and Fr20125,
# place the outputs into kiln content folder,
# then force kiln to reload the files
DOWNLOAD_DATA_PATH="../download/data"
KILN_TEI_PATH="../../webapps/ROOT/content/xml/tei"
mkdir -p data/fr data/royal
python2 doall.py $DOWNLOAD_DATA_PATH/fr20125/{1..100}[_,-]*.xml -c -o data/fr/ && cp data/fr/converted.xml "$KILN_TEI_PATH/texts/Fr20125.xml"
python2 doall.py $DOWNLOAD_DATA_PATH/royal/{1..100}[_,-]*.xml -c -o data/royal/ && data/royal/converted.xml "$KILN_TEI_PATH/texts/Royal.xml"
python2 align_merge.py $DOWNLOAD_DATA_PATH/alignments/TVOF_para_alignment_*.xml -o "$KILN_TEI_PATH/alists/TVOF_para_alignment.xml"
pushd ../.. && ./reload_kiln.sh $1 && popd

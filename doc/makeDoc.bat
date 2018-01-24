echo ************************************
echo      MAKING selectomatic.html
echo ************************************
 
del selectomatic.y.dot
del selectomatic.y.dot.png
del y.output.html
youtputmarkup -g ..\gcc\y.output > selectomatic.y.dot
dot -O -Tpng selectomatic.y.dot
youtputmarkup -s ..\gcc\y.output > y.output.html
 
yRewriter ..\source\selectomatic.y  > selectomatic.y.html
pp selectomatic.txt | pandoc --toc -N -c devDoc.css -s -t html5 -o selectomatic.html

#!/bin/sh
# this script takes everything that is in content and turns it into one pdf file.
# it also stops everytime it encouters an error in any of the steps.

MASTERFILE="example"

# make sure we start in this directory (needed for running it from finder)
cd "`dirname "$0"`" 

#clean=0
#once=0

while [ "$1" != "" ]; do
    case $1 in
        clean ) clean=1
				;;
        once )	once=1
				;;
    esac
    shift
done

if [ $clean ]; then
	rm -r *.aux
	rm -r *.log
	rm -r *.lof
	rm -r *.lot
	rm -r *.pyg
	rm -r *.ptc
	rm -r *.toc
	rm -r *.bbl
	rm -r *.blg
	rm -r *.out
	rm -r *.ist
	rm -r *.alg
	rm -r *.acr
	rm -r *.acna
	rm content-latex/*
	rmdir content-latex/
	echo "==================================================================================================="
	echo "Cleaned directory"
	exit
fi

echo "==================================================================================================="
mkdir ./content-latex/
for fullfile in content/*
do
	filename=$(basename "$fullfile")
	extension=${filename##*.}
	filename=${filename%.*}
	if [ $extension == "md" ]
	then
		# compile multimarkdown to latex
		latexfile="content-latex/$filename.tex"
		multimarkdown -t latex -o "$latexfile" "$fullfile"
		# change all \autoref commands to vref. This makes the references use pagenumbers as well (i.e. section 2.1 on page 4)
		sed -i '' -e 's/\\autoref/\\vref/g' "$latexfile"
#		sed -i '' -e 's/~\\citep/ \\citep/g' "$latexfile"
	else
		cp $fullfile ./content-latex/
	fi
#	echo $filename
done;

echo "==================================================================================================="
echo "== FIRST RUN ======================================================================================"
echo "==================================================================================================="

# compile pdf from latex source:
# we compile with xelatex for otf support
xelatex -shell-escape "$MASTERFILE"
rc=$?
if [[ $rc != 0 ]] ; then
	echo "First xelatex compilation exited with status code $rc"
    exit $rc
fi

# if we just want one run (i.e. for checking of rendering)
if [ $once ]; then
	exit
fi

makeglossaries "$MASTERFILE"

echo "==================================================================================================="
echo "== BIBTEX RUN ====================================================================================="
echo "==================================================================================================="


bibtex "$MASTERFILE"
rc=$?
if [[ $rc != 0 ]] ; then
	echo "Bibtex compilation exited with status code  $rc"
    exit $rc
fi

echo "==================================================================================================="
echo "== SECOND RUN ====================================================================================="
echo "==================================================================================================="


xelatex -shell-escape "$MASTERFILE"
rc=$?
if [[ $rc != 0 ]] ; then
	echo "Second xelatex compilation exited with status code  $rc"
    exit $rc
fi

echo "==================================================================================================="
echo "== THIRD RUN ======================================================================================"
echo "==================================================================================================="


xelatex -shell-escape "$MASTERFILE"
rc=$?
if [[ $rc != 0 ]] ; then
	echo "Third xelatex compilation exited with status code  $rc"
    exit $rc
fi

echo "==================================================================================================="
echo "== FOURTH RUN ======================================================================================"
echo "==================================================================================================="


xelatex -shell-escape "$MASTERFILE"
rc=$?
if [[ $rc != 0 ]] ; then
	echo "Fourth xelatex compilation exited with status code  $rc"
    exit $rc
fi

# open file in preview.app
open "$MASTERFILE.pdf"


exit 0
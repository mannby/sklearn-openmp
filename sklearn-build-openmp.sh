#!/bin/sh
if [ ! -d "scikit-learn-17" ]; then
    git clone --recursive -b 0.17.X https://github.com/mannby/scikit-learn.git scikit-learn-17
fi

if [ ! -d "scikit-learn" ]; then
    git clone --recursive https://github.com/mannby/scikit-learn.git
    cd scikit-learn
else
    cd scikit-learn
    git reset --hard
fi

diff -C 2 ../scikit-learn-17/sklearn/svm/src/liblinear/linear.cpp sklearn/svm/src/liblinear/linear.cpp > ../patch1.patch
cp ../scikit-learn-17/sklearn/svm/src/liblinear/linear.cpp sklearn/svm/src/liblinear/linear.cpp

echo "**************************************************************************************************"
echo "Apply svm openmp patch to scikit-learn"
git apply --ignore-whitespace ../sklearn-openmp.patch
if [ $? -ne 0 ]; then
	cd ..
    exit 1
fi

echo "**************************************************************************************************"
echo "Apply delta since version 0.17 of scikit-learn"
patch --ignore-whitespace sklearn/svm/src/liblinear/linear.cpp ../patch1.patch
if [ $? -ne 0 ]; then
	cd ..
    exit 1
fi

case "$OSTYPE" in
  darwin*)
echo "NOTE: Use e.g. 'brew install openmpi' to install OpenMP support"
_CXX="gcc-5"
_CC="gcc-5"
sed -i -e "s/, '-lrt']/]/g" sklearn-openmp.patch
;; 
  *)
_CXX=$CXX
_CC=$CC
;;
esac

echo "**************************************************************************************************"
echo "Building scikit-learn with libsvm and liblinear openmp support"
CXX=$_CXX CC=$_CC CFLAGS="-fopenmp -DCV_OMP=1" CXXFLAGS="-fofopenmp -DCV_OMP=1" LDFLAGS=-lgomp python setup.py build
if [ $? -ne 0 ]; then
	cd ..
    exit 1
fi

echo "**************************************************************************************************"
echo "Install scikit-learn"
CXX=$_CXX CC=$_CC CFLAGS="-fopenmp -DCV_OMP=1" CXXFLAGS="-fofopenmp -DCV_OMP=1" LDFLAGS=-lgomp python setup.py install

if [ $? -ne 0 ]; then
	echo "!!!!"
	echo "!!!! Add sudo at beginning of the line below 'Install scikit-learn' in script"
	cd ..
    exit 1
fi


cd ..

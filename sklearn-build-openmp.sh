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
    cp ../17/scikit-learn/sklearn/svm/src/liblinear/linear.cpp sklearn/svm/src/liblinear/linear.cpp
fi

diff ../17/scikit-learn/sklearn/svm/src/liblinear/linear.cpp sklearn/svm/src/liblinear/linear.cpp > ../patch1.patch
cp ../17/scikit-learn/sklearn/svm/src/liblinear/linear.cpp sklearn/svm/src/liblinear/linear.cpp

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

echo "**************************************************************************************************"
echo "Building scikit-learn with libsvm and liblinear openmp support"
CFLAGS="-fopenmp -DCV_OMP=1" CXXFLAGS="-fofopenmp -DCV_OMP=1" LDFLAGS=-lgomp python setup.py build
if [ $? -ne 0 ]; then
	cd ..
    exit 1
fi

echo "**************************************************************************************************"
echo "Enter root password for scikit-learn deployment (install script)"
#sudo CFLAGS="-fopenmp -DCV_OMP=1" CXXFLAGS="-fofopenmp -DCV_OMP=1" LDFLAGS=-lgomp python setup.py install
cd ..


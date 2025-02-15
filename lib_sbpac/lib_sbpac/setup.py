# -*- coding: utf-8 -*-
"""
Created on Thu Apr 19 21:56:25 2018

@author: Kyunghan
"""

from setuptools import setup, find_packages, Extension

setup(
    name="lib_sbpac",
    packages=['lib_sbpac'],
    version="0.0.9",
    description="====Test=====Libraries for state based prediction and active control",
    author='Kyunghan Min',
    author_email='kyunghah.min@gmail.com',
    url='https://github.com/KyunghanMin/StateBasedPredictionAndControl',
    keywords=['EV', 'Prediction', 'Control'],
    install_requires=['matplotlib'],
    include_package_data=True,
    entry_points={'console_scripts': ['pyinstrument = pyinstrument.__main__:main']},
    zip_safe=False,
    classifiers=[
        'Development Status :: 3 - Alpha',
        'Environment :: Spyder',
        'Intended Audience :: Developers',
        'Operating System :: Microsoft :: Windows',
        'Programming Language :: Python :: 3.5',
    ]
)

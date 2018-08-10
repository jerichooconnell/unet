#!/bin/bash

#SBATCH --ntasks=1

#SBATCH --time=8:0:0

#SBATCH --cpus-per-task=20

#SBATCH --mem-per-cpu=1024M

#SBATCH --account=def-bazalova

for i in {1..10};
do
	sed -i '$ d'  REDLEN_small_phantom_mc_basic_2cm.txt
	echo i:ts/seed= $i >>  REDLEN_small_phantom_mc_basic_2cm.txt
 	~/topas/topas REDLEN_small_phantom_mc_basic_2cm.txt

done

for i in {10..20};
do
	sed -i '$ d'  REDLEN_small_phantom_mc_basic_3cm.txt
	echo i:ts/seed= $i >>  REDLEN_small_phantom_mc_basic_3cm.txt
 	~/topas/topas REDLEN_small_phantom_mc_basic_3cm.txt

done

for i in {20..30};
do
	sed -i '$ d'  REDLEN_small_phantom_mc_basic_4cm.txt
	echo i:ts/seed= $i >>  REDLEN_small_phantom_mc_basic_4cm.txt
 	~/topas/topas REDLEN_small_phantom_mc_basic_4cm.txt

done



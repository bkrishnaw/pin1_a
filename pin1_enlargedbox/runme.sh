module load gromacs/2021.2

#Generates new inputs
echo "6\n1\nq" | gmx pdb2gmx -f pin1.pdb -o pin1.gro -p pin1.top -i pin1.itp -n pin1.ndx -ignh
# 6 (for AMBER99SB-ILDN) and 1 (for TIP3P)

#Solvates the system
gmx editconf -f pin1.gro -o pin1_box.gro  -c -d 3.0  -bt cubic
gmx solvate  -cp pin1_box.gro  -cs pin1.gro  -o pin1_sol.gro  -p pin1.top

#Adds ions
gmx solvate  -cp pin1_box.gro  -cs spc216.gro  -o pin1_sol.gro  -p pin1.top 
gmx genion -s ion.tpr -o pin1_ions.gro -p pin1.top -pname NA -nname CL -neutral
# 13 because our group is a solvent notnjust water

#Energy mininmization (make a tpr using grommp)
gmx grompp -f em.mdp -c pin1_ions.gro -p pin1.top -o em.tpr

#submit a job to owlsnest 
qsub em.qsub

#NVT eqilibration (mktpr)
gmx grompp -f nvt.mdp -c em.gro -r em.gro -p pin1.top -o nvt.tpr

#submit a job to owlsnest 
qsub nvt.qsub

#Check if it is truly equlibrated 
gmx energy -f nvt.edr -o 
temperature.xvg
# 16, then 0, if there is a large drift then redo.

#NPT equilibration (mktpr)
gmx grompp -f npt.mdp -c nvt.gro -r nvt.gro -t nvt.cpt -p pin1.top -o npt.tpr

#submit job to owlsnest 
qsub npt.qsub

#check if it's equilabrated, rememeber select 18 and 0
gmx genion -s ion.tpr -o pin1_ions.gro -p pin1.top -pname NA -nname CL -neutral
#check if there is a large drift, if there is, redo. 

#Prod run (mktpr)
gmx grompp -f prod.mdp -c npt.gro -t npt.cpt -p pin1.top -o prod.tpr
#check log file 


The source code is located in the folder "/code". The robot controllers are located in the folder "code/lua_scripts" and the PSO implementation in the folder "/code/pso".

Before anything, build the argos experiment :
> cd code/build
> rm -r *
> cmake ../src
> make

Be sure to execute the command :
> export ARGOS_PLUGIN_PATH=<location_of_the_build_folder>

The build folder is in "/code"

To run the manual solution execute the following lines :
> cd code
> argos3 -c argos_files/prod/foraging_manual_s2_13_robots.argos

And for the pso solution :
> cd code
> argos3 -c argos_files/prod/foraging_pso_s2_13_robots.argos

The pso solution reads the parameters in the file "/code/intput/parameters.csv". If this file is modified, you can paste the following data inside it. This is the best pso solution found so far :

131.441497
162.252902
0.937507
90.203206
93.148560
206.034573
95.015583
74.419938

To see the visualization, you can execute :
> cd code
> argos3 -c argos_files/foraging_s2.argos

And load one lua script manually from the folder "/code/lua_scripts"

To execute a PSO run, execute : (replace the missing parameters values by the ones of your choice)
> cd code/pso
> make program
> ./pso --particles <int> --{ring,wheel,gbest} --evaluations <int> --robots <int> --seed <int> --verbose <bool>

Be aware that executing PSO will write on the file "/code/input/parameters.csv" a new set of parameters.

Also, be carefull to avoid a number of robots that isn't associated with a argos file. Argos files are located in the folder "/code/argos_files". The ones that pso uses are in the folder "/code/argos_files/configured_scenarios". The name of each file is structured as follows : foraging_s<scenario>_<nb_robots>_<argos_seed>.argos

You can't set a number of robots equal to 254 for instance because there is no argos file associated with it.


![baniere](https://user-images.githubusercontent.com/40352310/134555034-4e99a6a7-0e60-4182-a44a-734e8c15f791.png)
  
# Design, Implementation and Optimization of a Swarm Robot Controller for operating a foraging task

This project is part of the Swarm Intelligence course at the Free University of Brussels (Master 1 Optimization and Operational Research - 2021 - 2022).

Foraging tasks are common applications for swarm robotics. In this project, I develop a robot controller able to search for objects in an arena and bring them to a nest. The analysis shows that our controller is easily scalable but very little flexible. I then optimize some parameters of the controller using a fully informed PSO algorithm. This optimization however doesn’t improve the performance of the manually tuned controller.
  
The controller is implemented in Lua, and the Particule Swarm Optimization (PSO) in C++. The simulator used for the robots is Argos.

Keywords : <code>Swarm Robotics</code> <code>Particule Swarm Optimization</code> <code>Simulator Argos</code> <code>Local Interactions</code> <code>Foraging</code> <code>Heuristic Optimization</code>

## How to use

- Build the Argos experiment :
  <code>$ cd code/build</code>
  <code>$ rm -r *</code>
  <code>$ cmake ../src</code>
  <code>$ make</code>
- Export Argos Path : <code>$ export ARGOS_PLUGIN_PATH=<location_of_the_build_folder></code>
- To run the manual solution execute the following lines :
  <code>$ cd code</code>
  <code>$ argos3 -c argos_files/prod/foraging_manual_s2_13_robots.argos</code>
- And for the pso solution :
  <code>$ cd code</code>
  <code>$ argos3 -c argos_files/prod/foraging_pso_s2_13_robots.argos</code>
- To see the visualization, you can execute :
  <code>$ cd code</code>
  <code>$ argos3 -c argos_files/foraging_s2.argos</code> and load one lua script manually from the folder "/code/lua_scripts"
- To execute a PSO run, execute (replace the missing parameters values by the ones of your choice) :
  <code>$ cd code/pso</code>
  <code>$ make program</code>
  <code>$ ./pso --particles <int> --{ring,wheel,gbest} --evaluations <int> --robots <int> --seed <int> --verbose <bool></code>

    
Be aware that executing PSO will write on the file "/code/input/parameters.csv" a new set of parameters. The pso solution reads the parameters in this exact file. If you want to come back to the origin settings, you can paste the following data inside it. This is the best pso solution found so far :

<table>
<thead>
<tr>
<th>Value</th>
  <th>Label</th>
</tr>
</thead>
<tbody>
  
<tr>
<td>131.441497</td>
  <td>Speed of the robots</td>
</tr>
  
  <tr>
<td>162.252902</td>
    <td>Speed when a robot Walk Away from an object</td>
</tr>
  
  <tr>
<td>0.937507</td>
    <td>Area for robots "finishers"</td>
</tr>
  
  <tr>
<td>90.203206</td>
    <td>Distance at which robots start avoiding each other</td>
</tr>

  <tr>
<td>93.148560</td>
    <td>Number iterations of the shuffling phase</td>
</tr>
  
  <tr>
<td>206.034573</td>
    <td>Number of iteartions during which robots learn their jobs</td>
</tr>
  
  <tr>
<td>95.015583</td>
    <td>Number of iterations for an inactive nester to become a finisher</td>
</tr>
  
  <tr>
<td>74.419938</td>
    <td>Number of iterations for an inactive finisher to become a nester</td>
</tr>
  
</tbody>
</table>
    
Also, be carefull to avoid a number of robots that isn't associated with a argos file. Argos files are located in the folder "/code/argos_files". The ones that pso uses are in the folder "/code/argos_files/configured_scenarios". The name of each file is structured as follows : <code>foraging_s<scenario>_<nb_robots>_<argos_seed>.argos</code>. You can't set a number of robots equal to 254 for instance because there is no argos file associated with it.
  


## Doc

<table>
<thead>
<tr>
<th>Source code</th>
<th>Label</th>

</tr>
</thead>
<tbody>
  
<tr>
<td>code/lua_scripts</td>
<td>Robot controller implemented in Lua</td>
</tr>
  
  <tr>
<td>code/pso/src</td>
<td>Particule Swarm Optimization metaheuristic implementation</td>
</tr>
  
</tbody>
</table>
    
All the necessary documentation is written directly in the code files.
  
## Arena & Simulator
  
![arena](https://user-images.githubusercontent.com/40352310/134550507-c433c155-4cf8-4a80-8d1d-ec638ff2b1b9.png)

![simulator](https://user-images.githubusercontent.com/40352310/134549594-01b9aeee-cf9d-4d4a-8f90-c7b5128b5c75.png)

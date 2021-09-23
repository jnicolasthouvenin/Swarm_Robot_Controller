
/************************************
 * Full Informed PSO Implementation *
 ************************************/

#include <iostream>
#include <string.h>
#include <chrono>

#include "problem.h"
#include "particle.h"

using namespace std;

#define TOPO_RING 0
#define TOPO_WHEEL 1
#define TOPO_GBEST 2

/********************** GLOBAL VARIABLES **********************/

vector<double> lower_bounds {50. , 50. , 0.9, 50. , 40. , 200., 50. , 50. };
vector<double> upper_bounds {150., 200., 1. , 150., 100., 500., 200., 100.};
Problem problem = Problem(8, &lower_bounds, &upper_bounds);

// Two parameters
int nb_particles;
short topology;
void (*setNeighborhood)();
bool verbose;
int nb_robots;

// Termination criteria
int iterations = 0;
int evaluations = 0;
int max_iterations = 1000;
int max_evaluations = 100;
double time_limit_sec = 600*60;

// PSO Seed
int seed;

// Swarm
vector<Particle> swarm;

struct Solution global_best;
Particle * best_particle(0);

// Time measurements
typedef chrono::high_resolution_clock Time;
typedef chrono::duration<float> fsec;

auto start = Time::now();
auto end_time = Time::now();
fsec nbSec;

// Ring Topologie
void createRingTopology(){
	int a,b;
	for (int i = 0; i < nb_particles; i++){
		a = i-1;
		b = i+1;
		if (i == 0) {
            a = nb_particles - 1;
        }
			
		if (i == (nb_particles-1)) {
            b = 0;
        }

		swarm[i].addNeighbour(&swarm[a]);
		swarm[i].addNeighbour(&swarm[b]);
	}
}

// Wheel Topology
void createWheelTopology(){
	for(int i = 1; i < nb_particles; i++){
		swarm[i].addNeighbour(&swarm[0]);
		swarm[0].addNeighbour(&swarm[i]);
	}
}

// Gbest Topology
void createGbestTopology(){
	for (int i = 0; i < nb_particles; i++) {
		for (int j=0;j<nb_particles;j++) {
			if (i != j) {
				swarm[i].addNeighbour(&swarm[j]);
			}
		}
	}
}

void setDefaultParameters() {
    nb_particles = 5;
    topology = 0;
    setNeighborhood = createRingTopology;
    verbose = true;
    nb_robots = 13;
    seed = 1;
}

void printParameters() {
    cout << "\nPSO:" << endl;
    cout << "   nb_particles = " << nb_particles << endl;
    cout << "   topology     = " << topology << endl;
    cout << "   verbose      = " << verbose << endl;
    cout << "   nb_robots    = " << nb_robots << endl;
    cout << "   max_ite      = " << max_iterations << endl;
    cout << "   max_eval     = " << max_evaluations << endl;
    cout << "   time_limit(s)= " << time_limit_sec << endl;
    cout << "   seed         = " << seed << endl << endl;
}

bool readParameters(int argc, char *argv[] ){

	setDefaultParameters();

    int i = 1;
	while (i < argc)  {
		if(strcmp(argv[i], "--particles") == 0){
			nb_particles = atol(argv[i+1]);
			i+=2;
        } else if(strcmp(argv[i], "--robots") == 0){
            nb_robots = atol(argv[i+1]);
            i+=2;
        } else if(strcmp(argv[i], "--evaluations") == 0){
            max_evaluations = atol(argv[i+1]);
            i+=2;
        } else if(strcmp(argv[i], "--seed") == 0){
            seed = atol(argv[i+1]);
            i+=2;
        } else if(strcmp(argv[i], "--verbose") == 0){
            if (strcmp(argv[i+1], "true") == 0){
			    verbose = true;
            } else if (strcmp(argv[i+1], "false") == 0) {
                verbose = false;
            } else {
                cout << "Parameter " << argv[i+1] << " no recognized.\n";
			    return false;
            }
			i+=2;
		} else if(strcmp(argv[i], "--ring") == 0){
            topology = 0;
			setNeighborhood = createRingTopology;
			i++;
		} else if(strcmp(argv[i], "--wheel") == 0){
            topology = 1;
			setNeighborhood = createRingTopology;
			i++;
		} else if(strcmp(argv[i], "--gbest") == 0) {
            topology = 2;
			setNeighborhood = createGbestTopology;
			i++;
		} else{
			cout << "Parameter " << argv[i] << " no recognized.\n";
			return false;
		}
	}

	if (verbose) { printParameters(); }

	return true;
}

void initialize() {
    global_best.x.resize(problem.getSize(),0);
    global_best.eval = 0;
    problem.set_nb_robots(nb_robots);
}

// Update global best solution found
void updateGlobalBest(vector<double> x, double eval){
	global_best.x = x;
	global_best.eval = eval;
}

// Create swarm structure
void createSwarm (){
    if (verbose) { cout << "Creating swarm..." << endl; }
	Particle p = Particle();
	for (int i = 0; i < nb_particles; i++) {
		p = Particle(&problem);
		swarm.push_back(p);
		if (global_best.eval < p.getPBestEvaluation()){
			updateGlobalBest(p.getPBestPosition(), p.getPBestEvaluation());
			best_particle = &p;
		}
	}
    setNeighborhood();
	if (verbose) { cout << "\n\tBest initial solution quality: " << global_best.eval << "\n"<< endl; }
}

bool moveSwarm() {
    if (verbose) { cout << "Move swarm..." << endl; }
    for (int i = 0; i < nb_particles; i++) {
        // Move the particule
        if (!swarm[i].move()) { return false; }
        if (verbose) {
            swarm[i].printPosition();
        }
        // Update global best particle
        if (global_best.eval < swarm[i].getPBestEvaluation()) {
            updateGlobalBest(swarm[i].getPBestPosition(), swarm[i].getPBestEvaluation());
            best_particle = &swarm[i];
        }
    }
    return true;
}

bool terminationCondition() {
    end_time = Time::now();
    nbSec = end_time - start;
    return (nbSec.count() > time_limit_sec or evaluations >= max_evaluations or iterations >= max_iterations);
}

int main(int argc, char* argv[]) {
    // Set seed
    srand(seed);

    // Measure start time
    start = Time::now();

    // Parse parameters
    if (!readParameters(argc,argv)) { return false; }

    // Initialize global best and number of robots (always 13 in the lastest version)
    initialize();

    // Create the population of particles
    createSwarm();

    // Print informations on the initial population and global best evaluation 
    if (verbose) { 
        cout << "Initial Swarm :" << endl;

        for (int i = 0; i < nb_particles; i++) {
            swarm[i].printPosition();
        }
    }

    if (verbose) { cout << "\nglobal best = " << global_best.eval << endl << endl; }

    // Iterations loop
	while(!terminationCondition()){
        // Move swarm
		if (!moveSwarm()) { return false; }

        // Increment counters
		evaluations = evaluations + nb_particles;
		iterations++;
        nbSec = Time::now() - start;

        // Print current global best, computation time and evaluations done
        if (verbose) {
            cout << "\nglobal best = " << global_best.eval << endl << endl;
            cout << "\ntime = " << nbSec.count()/(double)60 << endl;
            cout << "evals  = " << evaluations << endl << endl;
        }
	}

    // Write result on file
    problem.storeResult(global_best.eval);
}
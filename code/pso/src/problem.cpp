
/***************************************
 * Implementation of the class Problem *
 ***************************************/

#include <iostream>

#include "problem.h"
#include "errors.h"
#include "files.h"

using namespace std;

Problem::Problem(int n, vector<double> * lower_bounds, vector<double> * upper_bounds) {
    m_n = n;
    m_lower_bounds = *lower_bounds;
    m_upper_bounds = *upper_bounds;
}

Problem::~Problem(){};

int Problem::getSize() {
    return m_n;
}

// evaluate the parameters
bool Problem::evaluate(vector<double> * x, double * result) {
    // Verifying preconditions
    if (x->size() > m_n) {
        generateError("problem.cpp","evaluate","vector x too big","x.size()",x->size());
        return false;
    }

    for (int i = 0; i < m_n; i ++) {
        if (x->at(i) < m_lower_bounds[i] || (x->at(i) > m_upper_bounds[i])) {
            generateError("problem.cpp","evaluate","position out of bounds","(*x)[i]",x->at(i));
            return false;
        }
    }

    // write the solution inside the parameters file
    string fileName = "../input/parameters.csv";
    char * cfileName = &fileName[0];
    
    if (!emptyFile(cfileName)) { return false; }
    for(int param = 0; param < m_n; param++) {
        if (!appendToFile(cfileName,to_string(x->at(param)))) { return false; }
    }

    // Evaluation loop : argos is executed 3 times with 3 different seeds, the evaluation is the mean of the three results.
    int nbRuns = 3;

    double resultBuffer = 0.;
    double sumResults = 0.;

    // Files where the number of objets in nest will be located
    fileName = "../output/outputArgos.csv";
    cfileName = &fileName[0];

    // Argos seeds
    vector<int> seeds = {7,8,9};

    // Commands for executing argos
    string command_line = "cd .. && argos3 -n -l INFOFILE -e ERRORFILE -c argos_files/configured_scenarios/foraging_s2_" + to_string(m_nb_robots) + "_";
    string command_line_buffer;
    char * char_command_line;

    for (int run = 0; run < nbRuns; run ++) {
        command_line_buffer = command_line + to_string(seeds[run]) + ".argos";
        char_command_line = &command_line_buffer[0];

        // Launch argos
        auto res = system(char_command_line);
        // Read number of objects in nest
        if (!readFirstDouble(cfileName,&resultBuffer)) { return false; }

        sumResults += resultBuffer;
    }

    // Computes the mean of the three results
    *result = sumResults/(double)nbRuns;

    return true;
}

// Stores the final global best evaluation in the output file. Used during the tunning.
bool Problem::storeResult(double result) {
    string fileName = "../output/outputPSO.csv";
    char * cfileName = &fileName[0];
    
    if (!emptyFile(cfileName)) { return false; }
    if (!appendToFile(cfileName,to_string(result))) { return false; }
    return true;
}

// Stores the evaluation of the iteration to keep track of the execution
bool Problem::storeEvaluation(string name, double eval) {
    string fileName = "../output/trace/" + name + ".dat";
    char * cfileName = &fileName[0];
    
    if (!appendToFile(cfileName,to_string(eval))) { return false; }
    return true;
}

// Stores the position of the solution to memorize pso solutions
bool Problem::storeX(vector<double> * x) {
    string fileName = "../output/final_PSO_runs.dat";
    char * cfileName = &fileName[0];

    if (!appendToFile(cfileName,"SOLUTION")) { return false; }

    for (int i = 0; i < m_n; i++) {
        if (!appendToFile(cfileName,to_string(x->at(i)))) { return false; }
    }

    return true;
}

double Problem::getLowerBound(int feature) {
    return m_lower_bounds[feature];
}

double Problem::getUpperBound(int feature) {
    return m_upper_bounds[feature];
}

double Problem::getRandomX(int feature){
	double randomDouble = ((double) rand()/RAND_MAX) * (m_upper_bounds[feature]-m_lower_bounds[feature]) + m_lower_bounds[feature];
	return(randomDouble);
};

double Problem::getRandomV(int feature){
	double randomDouble = ((double) rand()/RAND_MAX) * 2*(m_upper_bounds[feature]-m_lower_bounds[feature]) - m_upper_bounds[feature];
	return(randomDouble);
};

void Problem::set_nb_robots(int nb_robots) {
    m_nb_robots = nb_robots;
}
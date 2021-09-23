
/*************************************
 * Declaration of the class Particle *
 *************************************/

#ifndef PARTICLE_H_
#define PARTICLE_H_

#include <vector>

#include "problem.h"

using namespace std;

// Solution structure
struct Solution {
	vector<double> x;
	double eval;
};

class Particle {

public:

    Problem* m_problem;
    int m_size; // problem size

    bool m_init;

    struct Solution m_current;
    struct Solution m_pBest;

    vector<Particle*> m_neighbours;

    vector<double> m_velocity;

    Particle();
    Particle(Problem* problem);
    ~Particle();

    double getRandom01();

    bool initializeUniform();
    bool move();
    bool evaluateSolution();
    
    // Getters
    vector<double> getCurrentPosition();
    vector<double> getPBestPosition();
    double getCurrentEvaluation();
    double getPBestEvaluation();

    // Modify topology
    void addNeighbour(Particle * p);

    // Verbose
    void printPosition();
};

#endif
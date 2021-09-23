
/************************************
 * Declaration of the class Problem *
 ************************************/

#ifndef PROBLEM_H_
#define PROBLEM_H_

#include <vector>

using namespace std;

class Problem {

public :

    int m_n; // number of variables
    int m_nb_robots; // number of robots (used during the early experimentations, now we always use 13 robots)
    vector<double> m_lower_bounds;
    vector<double> m_upper_bounds;

    Problem(int n, vector<double> * lower_bounds, vector<double> * upper_bounds);
    ~Problem();

    int getSize();
    double getLowerBound(int feature);
    double getUpperBound(int feature);
    bool evaluate(vector<double> * x, double * result); // Evaluates the given position according the objective function
    
    // Store results on files (the production version of the code only uses storeResult)
    bool storeResult(double result);
    bool storeEvaluation(string name, double eval); // Used for tracing the execution
    bool storeX(vector<double> * x); // Used for computing the ten pso solutions

    // Random generators
    double getRandomX(int feature); // Computes a random position for the given feature
    double getRandomV(int feature); // Computes a random velocity for the given feature

    // Setters
    void set_nb_robots(int nb_robots);
};

#endif
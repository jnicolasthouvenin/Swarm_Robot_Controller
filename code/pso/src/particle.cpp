
/****************************************
 * Implementation of the class Particle *
 ****************************************/

#include <iostream>

#include "problem.h"
#include "particle.h"

using namespace std;

Particle::Particle() {
    m_init = false;
}

Particle::Particle(Problem * problem) {
    m_problem = problem;
    m_size = problem->getSize();
    m_current.x.resize(m_size);
    m_pBest.x.resize(m_size);
    m_neighbours.resize(0);
    m_velocity.resize(m_size,0.);
    initializeUniform();
    m_init = true;
}

Particle::~Particle(){};

// random function for values in [0,1]
double Particle::getRandom01(){
	return((double) rand()/RAND_MAX);
};

bool Particle::initializeUniform() {
    for (int i = 0; i < m_size; i++) {
        m_current.x[i] = m_problem->getRandomX(i);
        m_pBest.x[i] = m_current.x[i];
    }
    if (!m_problem->evaluate(&m_current.x, &m_current.eval)) { return false; }
    m_pBest.eval = m_current.eval;
    m_init = true;

    return true;
}

bool Particle::move(){

    double buffer;

    for (int i = 0; i < m_size; i++) {
        // Move particle position
        buffer = m_velocity[i];
        for (int j = 0; j < m_neighbours.size(); j++) {
            buffer += (4/(double)m_size)*getRandom01()*(m_neighbours[j]->getPBestPosition()[i]-m_current.x[i]);
        }
        m_velocity[i] = 0.7298*buffer;
        m_current.x[i] += m_velocity[i];

        // If the feature is out of bound we correct it
        if (m_current.x[i] < m_problem->getLowerBound(i)) {
            m_current.x[i] = m_problem->getLowerBound(i);
            m_velocity[i] = 0;
        }

        if (m_current.x[i] > m_problem->getUpperBound(i)) {
            m_current.x[i] = m_problem->getUpperBound(i);
            m_velocity[i] = 0;
        }
    }

    // Evaluate the new position
    if (!evaluateSolution()) { return false; }

    // Update the personal best if needed
    if (m_pBest.eval < m_current.eval) {
        m_pBest.x = m_current.x;
        m_pBest.eval = m_current.eval;
    }
    return true;
}

bool Particle::evaluateSolution() {
    return m_problem->evaluate(&m_current.x, &m_current.eval);
}

vector<double> Particle::getCurrentPosition() {
	return(m_current.x);
}

vector<double> Particle::getPBestPosition() {
	return(m_pBest.x);
}

double Particle::getCurrentEvaluation(){
	return(m_current.eval);
}

double Particle::getPBestEvaluation(){
	return(m_pBest.eval);
}

void Particle::addNeighbour(Particle * p){
	m_neighbours.push_back(p);
}

void Particle::printPosition(){
	cout << "       Solution:" << m_current.eval << endl;
    cout << "       ";
	for (int i = 0; i < m_size; i++){
		cout << m_current.x[i] << "  ";
	}
	cout << endl;
}
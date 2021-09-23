
/***********************************************************
 * Functions for handeling error messages and help message *
 ***********************************************************/

#ifndef _ERRORS_H_
#define _ERRORS_H_

#include <iostream>

using namespace std;

/**
 * Print the error message associated with the given parameters
 * 
 * @tparam T the type of the value of the variable that caused the error
 * @param[in] file String denoting the file where the error occured
 * @param[in] method String denoting the method where the error occured
 * @param[in] message String denoting the message associated with the error
 * @param[in] variable String denoting the name of the variable wich value caused the error
 * @param[in] variableValue Value, of type T, of the variable that caused the error.
 */
template<typename T>
void generateError(string file, string method, string message, string variable, T variableValue)
{
    cerr << "\nERROR: file:" << file << ", method:" << method << ", message:" << message << ", " << variable << " = " << variableValue << endl << endl;
}

void generateError(string file, string method, string message)
{
    cerr << "\nERROR: file:" << file << ", method:" << method << ", message:" << message << "." << endl << endl;
}

#endif
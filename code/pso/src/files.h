
/*************************************************************
 * Functions for handeling file management, writing, reading *
 *************************************************************/

#ifndef _FILES_H_
#define _FILES_H_

#include <vector>
#include <fstream>
#include <cmath>

#include "errors.h"

using namespace std;

/**
 * Open the file denoted by the given name and empty it
 * 
 * @param[in] fileName Name of the file to empty
 * @return false if one error occured, true otherwise
 */
bool emptyFile(char * fileName)
{
    string const myFile(fileName);
    ofstream myInitializer(myFile.c_str());

    if (myInitializer) {
        myInitializer << "";
        return true;
    }
    else {
        generateError("flowshop.cpp","emptyFile","impossible to open a file","file_name",fileName);
        return false;
    }
}

/**
 * Open the file denoted by the given name, append to it the given message and end line
 * 
 * @param[in] fileName Name of the file to write in
 * @param[in] message Message to append
 * @return false if one error occured, true otherwise
 */
bool appendToFile(char * fileName, string message)
{
    string const myFile(fileName);
    ofstream myStream(myFile.c_str(), ios::app);

    if (myStream) {
        myStream << message << endl;
        return true;
    }
    else {
        generateError("flowshop.cpp","main","impossible to open a file","file_name",fileName);
        return false;
    }
}

/**
 * Open the file denoted by the given name, append to it the given message and end line
 * 
 * @param[in] fileName Name of the file to write in
 * @param[in] message Message to append
 * @return false if one error occured, true otherwise
 */
bool readFirstDouble(char * fileName, double * result)
{
    string const myFile(fileName);
    ifstream myStream(myFile);

    if(myStream)
    {
        string line;
        getline(myStream, line);
        *result = stod(line);
        return true;
    }
    else
    {
        generateError("files.h","readFirstLine","Impossible to open file","file",myFile);
        return false;
    }
}

#endif
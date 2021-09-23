
program : src/errors.h src/files.h src/pso.cpp src/particle.h src/particle.cpp src/problem.h src/problem.cpp
	g++ -O3 -c ./src/particle.cpp -o src/particle.o
	g++ -O3 -c ./src/problem.cpp -o src/problem.o
	g++ -O3 -c ./src/pso.cpp -o src/pso.o

	g++ -O3 src/problem.o src/particle.o src/pso.o -o pso

clean:
	rm src/*.o pso ../ERRORFILE ../INFOFILE

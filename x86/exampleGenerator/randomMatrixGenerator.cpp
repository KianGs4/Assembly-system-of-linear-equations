#include <iostream>
#include <fstream>
#include <ctime>
#include <cstdlib>


using namespace std;


int main() {
    int n, tempNumber, sign;
    ofstream outputFile("./inputs");
    if (outputFile.is_open()) {
        srand(time(nullptr));
         n = rand() % 20 + 1;
        outputFile << n << "\n";
        for (int i = 0; i < n ; ++i) {
            for (int j = 0; j < n + 1; ++j) {
                tempNumber = rand() % 1250 + 1;
                if (rand() % 2 == 1) tempNumber *= -1;
                outputFile << tempNumber << " ";
            }
            outputFile << "\n";
        }
        outputFile.close();
    } else {
        std::cerr << "Error opening file\n";
    }
    return 0;
}

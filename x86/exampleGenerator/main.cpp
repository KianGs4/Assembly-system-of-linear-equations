#include <iostream>
#include <fstream>

using namespace std;


int main() {
    int i, j, k, n;
    ifstream myfile;
    myfile.open("./inputs");
    myfile >> n;

    /* if no of equations are n then size of augmented matrix will be n*n+1. So here we are declaring 2d array 'mat' of size n+n+1 */
    double mat[n][n + 1];

    /* for n equations there will be n unknowns which will be stored in array 'res' */
    double res[n];

    for (i = 0; i < n; i++) {
        for (j = 0; j < n + 1; j++) {
            myfile >> mat[i][j];
        }
    }
    myfile.close();


    for(i=0;i<n;i++)
    {
        for(j=i+1;j<n;j++)
        {
            if(abs(mat[i][i]) < abs(mat[j][i]))
            {
                for(k=0;k<n+1;k++)
                {

                    /* swapping mat[i][k] and mat[j][k] */
                    mat[i][k]=mat[i][k]+mat[j][k];
                    mat[j][k]=mat[i][k]-mat[j][k];
                    mat[i][k]=mat[i][k]-mat[j][k];
                }
            }
        }
    }


    /* performing Gaussian elimination */
    for(i=0;i<n-1;i++)
    {
        for(j=i+1;j<n;j++)
        {
            if(mat[i][i] == 0 ){
                cout << "impossible";
                return 0;
            }
            double f=mat[j][i]/mat[i][i];
            for(k=0;k<n+1;k++)
            {
                mat[j][k]=mat[j][k]-f*mat[i][k];
            }
        }
    }
    /* Backward substitution for discovering values of unknowns */
    for(i=n-1;i>=0;i--)
    {
        res[i]=mat[i][n];
        for(j=i+1;j<n;j++)
        {
            if(i!=j)
            {
                res[i]=res[i]-mat[i][j]*res[j];
            }
        }
        if (mat[i][i] == 0) {
            cout << "impossible" ;
            return 0;
        }
        res[i]=res[i]/mat[i][i];
    }
    ofstream outputFile("./outputs");
    if (outputFile.is_open()) {
        for (i = 0; i < n - 1; i++) {
            outputFile << res[i] << " ";
        }
        outputFile << res[n - 1];
        outputFile.close();
    }
}


#include <iostream>
#include <vector>
#include <algorithm>
#include <queue>
#include <string>
#include<cstring>

using namespace std;

//typedef long long ll;


int main(){
    long long T,A,B;
    cin >> T >> A >> B;
    for(long long t =0;t<T;t++){
        bool flag = false;
        const long long max_num = 500000000;
        const long long max_num2 = 1000000000;
        long long x[5]={0,max_num,max_num,-max_num,-max_num},y[5] ={0,max_num,-max_num,max_num,-max_num};
        string res;
        int i;
        for(i=0;i<5;i++){
            cout << x[i] <<' '<<y[i] <<endl;
            cin >> res;
            if(res[0] == 'H'){
                break;
            }
            if(res[0] == 'C'){
                flag = true;
                break;
            }
        }
        if(flag){
            continue;
        }
        long long xx=x[i],yy=y[i];
        long long l = x[i],r=max_num2+1;

        //cout << r <<' '<<yy<<endl;
        //cin >> res;
        while(l<r-1){
                long long mid = (l+max_num2+r+max_num2)/2-max_num2;
                cout << mid <<' ' <<yy<<endl;
                cin >> res;
                if(res[0] == 'M'){
                    r = mid;
                }
                else{
                    l = mid;
                }
        }
        long long rr = l;
        l = -max_num2-1;
        r = xx;
        while(l<r-1){
                long long mid = (l+max_num2+r+max_num2+1)/2-max_num2;
                cout << mid <<' ' <<yy<<endl;
                cin >> res;
                if(res[0] == 'M'){
                    l = mid;
                }
                else{
                    r = mid;
                }
        }
        long long ll = r;
        long long d = y[i],u=max_num2+1;
        while(d<u-1){
            long long mid = (d+max_num2+u+max_num2)/2-max_num2;
            cout << xx<<' '<<mid<<endl;
            cin >> res;
            if(res[0] == 'M'){
                u = mid;
            }
            else{
                d = mid;
            }
        }
        long long uu = d;
        d = -max_num2-1,u = yy;
        while(d<u-1){
            long long mid = (d+max_num2+u+max_num2+1)/2-max_num2;
            cout << xx<<' '<<mid<<endl;
            cin >> res;
            if(res[0] == 'M'){
                d = mid;
            }
            else{
                u = mid;
            }
        }
        long long dd = u;
        cout << (ll+rr)/2 <<' '<<(dd+uu)/2<<endl;
        cin >> res;
        //cout << "Case #" << t+1<<": "<<res1+res2<<endl;
    }
    return 0;



}

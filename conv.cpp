#include <stdio.h>
#include <stdlib.h>
#include <omp.h>


//Code snipped used for High-Level FPGA synthesis
//Experiment with it:
// 1. Create an OpenMP Version for CPUs
// 2. Create an OpenMP OffloadVersion for GPUs
// 3. Create an OpenACC OffloadVersion for GPUs
// you are free to change loop orders or to break up loops
template<typename T,int N_in,int N_out,int H,int W, int FS>
void conv_ref(const T in[N_in][H][W],T out[N_out][H][W],const T weight[N_out][N_in][FS][FS],T bias[N_out])
{
	const int kernel_radius = int(FS / 2);

	T val;
	for(int o=0;o<N_out;++o)
	{
        for(int h=0;h<H;++h)
        {
            for(int w=0;w<W;++w)
            {
               out[o][h][w] = (T)0; // fill zeros into output matrix
            }
        }

		for(int i=0;i<N_in;++i)
		{
			for(int h=0;h<H;++h)
			{
				for(int w=0;w<W;++w)
				{
				  val=0;
		                  for(int kh= -kernel_radius;kh<=kernel_radius;++kh)
		                  {
		                    for(int kw=-kernel_radius;kw<=kernel_radius;++kw)
		                    {
		            	     if(h+kh >= 0 && w+kw >= 0 && h+kh < H && w+kw < W )
		            	     {
		                       val += in[i][h+kh][w+kw]*weight[o][i][(kh+kernel_radius)][(kw+kernel_radius)];
		            	     }
		                   }
		                 }
                         out[o][h][w] += val;
				}
			}
		}
        for(int h=0;h<H;++h)
        {
            for(int w=0;w<W;++w)
            {
               out[o][h][w] += bias[o];
            }
        }
     }


}


int main(int argc, char* argv[])
{
   float in[20][512][512];
   float out[30][512][512];
   float filter[30][20][3][3];
   float bias[30];
   
   srand(45387681);
     
   for(int i= 0;i<30;i++)
   	   for (int j= 0;j<20;j++)
   		   for (int k = 0;k<3;k++)
   			   for (int l = 0;l<3;l++)
   				   filter [i][j][k][l] = (float)(rand()%5);

   for(int i= 0;i<20;i++)
      	   for (int j= 0;j<512;j++)
      		   for (int k = 0;k<512;k++)
      				   in [i][j][k] = (float)(rand()%256);
   for(int i= 0;i<30;i++)
      	   bias [i] = (float)(rand()%2);

   double dtime = omp_get_wtime();
   conv_ref<float,20,30,512,512,3>(in,out,filter,bias);
   dtime = omp_get_wtime() - dtime;
   printf("used time %f\n",dtime);


  return 0;
}

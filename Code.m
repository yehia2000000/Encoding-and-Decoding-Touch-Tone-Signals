%%

Number_of_keys=input("Enter the number of keys you wish to enter: ");

%Initializing variables

key_pad_array=["1" "2" "3" "A";"4" "5" "6" "B";"7" "8" "9" "C"; "*" "0" "#" "D"];
key_pad_V_index=[697 770 852 941];
key_pad_H_index=[1209 1336 1447 1633];
input_array=zeros(1,Number_of_keys);
indexV=zeros(1,Number_of_keys);
indexH=zeros(1,Number_of_keys);
Fs=8000;
t = linspace(0,1,Fs);
f = linspace(-Fs/2,Fs/2,Fs*Number_of_keys);
Func=[];

%Taking the numbers from the user and link it with corresponding
%frequencies and adding them to become one signal

for i=1:(Number_of_keys)
    while(1)
        input_array(i)=input("Enter the key number: ","s");
        valid=ismember(char(input_array(i)),key_pad_array);
        if(valid)
            [indexV(i),indexH(i)]=find(key_pad_array==char(input_array(i)));
            break
        else
            disp("Invalid key number");
        end
    end
    V_freq=key_pad_V_index(indexV(i));
    H_freq=key_pad_H_index(indexH(i));
    Func = [Func,sin(2*pi*V_freq*t)+sin(2*pi*H_freq*t)];
    
end
t = linspace(0,1*Number_of_keys,Fs*Number_of_keys);
FFT_Funct=fftshift(fft(Func));
figure
plot(f,real(FFT_Funct))
figure;
plot(t,Func)
sound(Func)
%%
% decode module  :  we split the received signal into  input user element
% and pass it into all filter by the convolution and catch the max value
% and save it into the matrix  and get the index of the horizontal and
% vertical and select the numbers of keypad by these indexs 
L = 80 ;
Filter_out=zeros(1,8);
decoded="";
n=0:L-1;
Fb=[key_pad_V_index,key_pad_H_index];
ww = 0:pi/300:pi;
for i=1:(length(Func)/Fs)
    time_seg=Func((i-1)*Fs+1:i*Fs);
    for j=1:8
        BPF=cos(2*pi*Fb(j)*n/Fs);
        B = abs(1/(max(freqz(BPF,1,ww)))); 
        BPF = B*BPF ;
        Filter_out(j)=max(conv(time_seg,BPF));
    end
    indexH=find(Filter_out==max(Filter_out(1:4)));
    indexV=find(Filter_out==max(Filter_out(5:8)))-4;
    decoded(i)=key_pad_array(indexH,indexV);
end
decoded
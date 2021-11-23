function  [Hf,f] = chirpz_time2frequency(Ht,t,fstart,fstop,npts)
% See ChirpZ.doc in .../Environetix/Notes/
Ht = Ht(:).';
N = length(Ht);
M = npts;
L = 2^nextpow2(N+M-1);

fspan = fstop-fstart;

df = fspan/(M-1);
fo = fstop;

k = 0:(M-1);
f = fo-k*df;

[t,inds] = sort(t);
Ht = Ht(inds);
t1 = t(1);  
dt = t(2)-t(1);

wo = 2*pi*fo*dt;
w1 = 2*pi*df*dt;

n = 0:(N-1);
y = zeros(1,L); y(n+1) = Ht.*exp( -j*wo*n+j*w1*n.^2/2 );

m = [[0:(M-1)] [(1-N):-1]];
tempVm = exp(-j*w1*m.^2/2);
v = zeros(1,L); v(1:M) = tempVm(1:M); v(L+1+([(1-N):-1])) = tempVm((M+1):end);

scaleFactor = exp(-j*(2*pi*f*t1-w1*k.^2/2))*dt;

temp = ifft(fft(v).*fft(y));

Hf = scaleFactor.*temp(1:M);

[f,inds] = sort(f);
Hf = Hf(inds);









